// Launchpad contract template - using this as a base for new launchpad canisters
import Buffer "mo:base/Buffer";
import Result "mo:base/Result";
import Text "mo:base/Text";
import Bool "mo:base/Bool";
import Prim "mo:⛔";
import Nat "mo:base/Nat";
import HashMap "mo:base/HashMap";
import Array "mo:base/Array";
import Iter "mo:base/Iter";
import Option "mo:base/Option";
import Time "mo:base/Time";
import Principal "mo:base/Principal";
import Error "mo:base/Error";
import ICRCLedger "../token_deployer/ICRCLedger";
// import Cycles "mo:base/ExperimentalCycles";
import BlockID "../utils/BlockID";
import Types "./types/Common";
import Nat64 "mo:base/Nat64";
import Int "mo:base/Int";
import Timer "mo:base/Timer";
import Debug "mo:base/Debug";

import TaskManager "./TaskManager";

shared ({ caller = deployer }) actor class LaunchpadCanister() = this {
    private var timerId : Nat = 0;
    private stable var autoProcessEnabled : Bool = true;

    //BlockID
    stable var REQUIRED_SCORE: Nat = 0;//BlockID required score
    let BLOCK_ID_CANISTER_ID = "3c7yh-4aaaa-aaaap-qhria-cai";
    let BLOCK_ID_APPLICATION = "block-id";
    let _blockID : BlockID.Self = actor(BLOCK_ID_CANISTER_ID);
    private func checkBlockIDScore(principal: Principal) : async Bool {
        try {
            if(REQUIRED_SCORE == 0) return true;
            let score = await _blockID.getWalletScore(principal, BLOCK_ID_APPLICATION);
            score.totalScore >= REQUIRED_SCORE;
        } catch (_) {
            false;
        };
    };

    private stable var PurchaseLedger : ICRCLedger.Self = actor("ryjl3-tyaaa-aaaaa-aaaba-cai");//For fee payment - Default: ICP Token
    private stable var PurchaseCanisterId : ?Principal = null;//For purchase token distribution
    private stable var SaleCanisterId : ?Principal = null;//For sale token distribution
    private stable var PurchaseFee : Nat = 10_000; //0.0001 ICP - default fee
    private stable var _admins : [Text] = [Principal.toText(deployer)];
    private stable var TOTAL_AMOUNT_COMMITED : Nat = 0;//Total commit amount
    private stable var installed : Bool = false;
    private stable var LAUNCH_STATUS : Text = "UPCOMING";
    private stable var launchpadDetail : ?Types.LaunchpadDetail = null;
    // private let participants : Buffer.Buffer<Types.Participant> = Buffer.Buffer<Types.Participant>(0);

    private stable var _participants : [(Text, Types.Participant)] = []; //Store Participant Info
    private var participants         : HashMap.HashMap<Text, Types.Participant> = HashMap.fromIter(_participants.vals(), 0, Text.equal, Text.hash);

    private stable var AFFILIATE_PERCENTAGE = 3;
    private stable var SOFTCAP = 0;
    private stable var HARDCAP = 0;
    private stable var totalAffiliateVolume : Nat = 0;
    private stable var refererTransaction : Nat = 0;//Total affiliate transaction
    private stable var _affiliateStats : [(Text, Types.AffiliateStats)] = []; //Store Participant Info
    private var affiliateStats = HashMap.HashMap<Text, Types.AffiliateStats>(10, Text.equal, Text.hash);

    // private let participants : Buffer.Buffer<Types.Participant> = Buffer.Buffer<Types.Participant>(0);
    private var transactions : Buffer.Buffer<Types.Transaction> = Buffer.Buffer<Types.Transaction>(0);
    stable var transactionsArray : [Types.Transaction] = [];

    private var refunds : Buffer.Buffer<Types.Transaction> = Buffer.Buffer<Types.Transaction>(0);
    stable var refundsArray: [Types.Transaction] = [];
    private stable var _owner : Principal = deployer;
    private stable var whitelist : [Text] = [];
    private stable var managerAddress : Text = "";

    //Task Manager
    private stable var taskManagerEntries: [(Nat, TaskManager.Task)] = [];
    private stable var nextTaskId: Nat = 0;
    private var taskManager = TaskManager.TaskManager();


    //Split media from detail, allow update
    private stable var _logo: Text = "";
    private stable var _banner: Text = "";

    // Stable for auto process
    private stable var lastProcessedIndex : Nat = 0;
    private stable var pendingTransfers : [(Principal, Nat, Text)] = [];
    private stable var processedTransactions : [Types.Transaction] = [];
    private stable var processingState : {
        #NotStarted;
        #Processing: {processed: Nat; total: Nat};
        #Completed;
        #Failed: Text;
    } = #NotStarted;

    // Batch transfer functions
    private func startBatchProcess(processType: {#Distribution; #Refund}) : async Result.Result<(), Text> {
        if (not installed) {
            return #err("Launchpad not installed");
        };

        switch(processingState) {
            case (#Processing(_)) {
                return #err("Another process is running"); 
            };
            case (#Completed) {
                return #err("Process already completed");
            };
            case (_) {};
        };

        try {
            // Reset pending transfers array and tracking variables
            pendingTransfers := [];
            lastProcessedIndex := 0;
            processedTransactions := [];
            
            // Create a temporary HashMap to track processed participants
            let processedParticipants = HashMap.HashMap<Text, Bool>(10, Text.equal, Text.hash);
            
            label processLoop for ((principal, participant) in participants.entries()) {
                // Skip if participant was already processed
                switch(processedParticipants.get(principal)) {
                    case (?true) { continue processLoop; };
                    case (_) {};
                };

                let amount = switch(processType) {
                    case (#Distribution) {
                        await calculateTokenAmount(participant);
                    };
                    case (#Refund) {
                        participant.totalAmount;
                    };
                };
                
                if (amount > 0) {
                    pendingTransfers := Array.append(
                        pendingTransfers,
                        [(Principal.fromText(principal), amount, debug_show(processType))]
                    );
                    processedParticipants.put(principal, true);
                };
            };

            processingState := #Processing({
                processed = 0;
                total = pendingTransfers.size();
            });
            
            #ok()
        } catch (e) {
            processingState := #Failed("Failed to start process: " # Error.message(e));
            #err("Failed to start process: " # Error.message(e))
        }
    };

    private func calculateTokenAmount(participant: Types.Participant) : async Nat {
        // Implement token distribution calculation logic
        let launchpad = await getLaunchpadDetail();
        let percentage = participant.totalAmount * 100 / TOTAL_AMOUNT_COMMITED;
        percentage * launchpad.distribution.fairlaunch.total / 100
    };

    //Process batch transfer
    private func processBatch() : async Result.Result<Text, Text> {
        switch(processingState) {
            case (#Processing(state)) {
                let batchSize = 50;
                var currentProcessed = 0;
                
                try {
                    let processStart = lastProcessedIndex;
                    let processEnd = Nat.min(lastProcessedIndex + batchSize, pendingTransfers.size());
                    
                    // Track processed transactions in this batch
                    let processedInBatch = HashMap.HashMap<Text, Bool>(10, Text.equal, Text.hash);
                    
                    label processLoop for (i in Iter.range(processStart, processEnd - 1)) {
                        let (recipient, amount, transferType) = pendingTransfers[i];
                        let recipientText = Principal.toText(recipient);
                        
                        // Skip if already processed in this batch
                        switch(processedInBatch.get(recipientText)) {
                            case (?true) { continue processLoop; };
                            case (_) {};
                        };
                        
                        let result = await processTransfer(recipient, amount, transferType);
                        
                        switch(result) {
                            case (#ok(txId)) {
                                processedTransactions := Array.append(
                                    processedTransactions,
                                    [{
                                        participant = recipientText;
                                        amount = amount;
                                        time = Time.now();
                                        method = transferType;
                                        txId = ?txId;
                                    }]
                                );
                                processedInBatch.put(recipientText, true);
                                currentProcessed += 1;
                            };
                            case (#err(e)) {
                                processingState := #Failed(e);
                                return #err(e);
                            };
                        };
                    };

                    lastProcessedIndex := processEnd;

                    // Update state
                    if (lastProcessedIndex >= pendingTransfers.size()) {
                        processingState := #Completed;
                        lastProcessedIndex := 0;
                    } else {
                        processingState := #Processing({
                            processed = state.processed + currentProcessed;
                            total = state.total;
                        });
                    };

                    #ok("Processed: " # Nat.toText(currentProcessed))
                } catch (e) {
                    processingState := #Failed(Error.message(e));
                    #err("Processing failed: " # Error.message(e))
                }
            };
            case (_) {
                #err("No active processing")
            };
        }
    };

    private func processTransfer(to: Principal, amount: Nat, transferType: Text) : async Result.Result<Nat, Text> {
        try {
            let _ICRCActor = await createICRC1Actor(switch(transferType) {
                case ("#Refund") { Principal.toText(Option.get(PurchaseCanisterId, Principal.fromText("ryjl3-tyaaa-aaaaa-aaaba-cai"))) };
                case ("#Distribution") { Principal.toText(Option.get(SaleCanisterId, Principal.fromText("ryjl3-tyaaa-aaaaa-aaaba-cai")))};
                case (_) { "ryjl3-tyaaa-aaaaa-aaaba-cai" };
            });
            
            // Create current timestamp to avoid duplicate
            let now = Time.now();
            
            // Create unique memo for this transaction (combine transferType and timestamp)
            let memoText = Principal.toText(to) # "_" # Nat.toText(amount) # "_" # transferType;
            let memoBlob = Text.encodeUtf8(memoText);
            let _depositAccount = await _createUserAddress(to);//Create user subaccount
            
            let result = await _ICRCActor.icrc1_transfer({
                from_subaccount = switch(transferType) {
                    case ("#Refund") { _depositAccount.subaccount };
                    case (_) { null };
                }; // Use the subaccount, which is created for the to user
                to = { owner = to; subaccount = null };
                amount = Nat.sub(amount, PurchaseFee);
                fee = null;
                memo = ?memoBlob; // Add memo to avoid duplicate
                created_at_time = ?Nat64.fromNat(Int.abs(now)); // Add timestamp
            });
            
            switch(result) {
                case (#Ok(blockIndex)) { #ok(blockIndex) };
                case (#Err(e)) { #err(debug_show(e)) };
            }
        } catch (e) {
            #err("Transfer failed: " # Error.message(e))
        }
    };

    //End of initialize modules

    //Callback to notify the deployer
    let _Deployer = actor(Principal.toText(deployer)) : actor{
        callback: shared (Text, Text) -> async ();
    };

    //Create ICRCLedger actor
    private func createICRC1Actor(id : Text) : async ICRCLedger.Self {
        actor(id);
    };

    public shared (msg) func install(_info : Types.LaunchpadDetail, _whitelist: [Text]) : async Result.Result<Bool, Text> {
        // assert(_isAdmin(Principal.toText(msg.caller)));//Only admin can install
        if(not isAuthorized(msg.caller)){
            return #err("NOT_AUTHORIZED");
        };
        if(installed){
            return #err("ALREADY_INSTALLED");
        };
        managerAddress := Principal.toText(deployer);
        whitelist := _whitelist;
        _owner := msg.caller;
        launchpadDetail := ?_info;
        //Save media to stable
        _logo := _info.projectInfo.logo;
        _banner := Option.get(_info.projectInfo.banner, "");
        installed := true;
        SOFTCAP := _info.launchParams.softCap;
        HARDCAP := _info.launchParams.hardCap;
        AFFILIATE_PERCENTAGE := _info.affiliate;
        REQUIRED_SCORE := _info.blockId;
        //Setting ledger for fee payment
        PurchaseLedger := actor(_info.purchaseToken.canisterId);
        PurchaseFee := await PurchaseLedger.icrc1_fee();
        PurchaseCanisterId := ?Principal.fromText(_info.purchaseToken.canisterId);
        // Start the timer
        ignore startAutoProcess();
        return #ok(installed);
    };

    //Admin start auto process
    public shared (msg) func adminStartAutoProcess() : async Result.Result<Bool, Text> {
        assert(_isAdmin(Principal.toText(msg.caller)));
        ignore startAutoProcess();
        return #ok(true);
    };
    

    //Allow owner to update project info
    public shared (msg) func updateProjectInfo(name: Text, description: Text, logo: Text, banner: ?Text) : async Result.Result<Bool, Text> {
        if(not isAuthorized(msg.caller)){
            return #err("NOT_AUTHORIZED");
        };
        _logo := logo;
        _banner := Option.get(banner, "");
        switch(await getLaunchpadDetail()){
            case (info){
                let _newProjectInfo : Types.ProjectInfo = {
                    name = name;
                    description = description;
                    isAudited = info.projectInfo.isAudited;
                    isVerified = info.projectInfo.isVerified;
                    links = info.projectInfo.links;
                    logo = logo;
                    banner = banner;
                    metadata = info.projectInfo.metadata;
                };
                let _newInfo : Types.LaunchpadDetail = {
                    info with
                    projectInfo = _newProjectInfo;
                };
                launchpadDetail := ?_newInfo;
                return #ok(true);
            };
        };
    };

    //Admin update time start
    public shared (msg) func updateTimeStart(startTime: Time.Time, endTime: Time.Time, claimTime: Time.Time, listingTime: Time.Time): async Result.Result<Bool, Text> {
        assert(_isAdmin(Principal.toText(msg.caller)));
        switch(await getLaunchpadDetail()){
            case (info){
                let _newTimeline: Types.Timeline = {
                    createdTime = info.timeline.createdTime;
                    startTime = startTime;
                    endTime = endTime;
                    claimTime = claimTime;
                    listingTime = listingTime;
                };
                launchpadDetail := ?{
                    info with
                    timeline = _newTimeline;
                };
                return #ok(true);
            };
        };
    };

    //Check if the caller is authorized
    private func isAuthorized(caller : Principal) : Bool {
        _isAdmin(Principal.toText(caller)) or Principal.equal(_owner, caller)
    };
    // Function to start auto process
    private func startAutoProcess(): async () {
        if (timerId == 0) {
            Debug.print("Starting auto process...");
            timerId := Timer.recurringTimer<system>(#seconds(10), checkAndProcessPool);
        };
    };

    // Function to stop auto process
    private func stopAutoProcess() {
        if (timerId != 0) {
            Timer.cancelTimer(timerId);
            timerId := 0;
        };
    };

    // Main function to check and process pool
    private func checkAndProcessPool() : async () {
        if (not autoProcessEnabled or not installed) return;

        let launchpad = await getLaunchpadDetail();
        // Check end time
        if (Time.now() > launchpad.timeline.endTime) {
            Debug.print("End time reached" # debug_show(processingState));
            switch(processingState) {
                case (#NotStarted) {
                    // Check condition to start processing
                    if (TOTAL_AMOUNT_COMMITED >= launchpad.launchParams.softCap) {
                        //Success flow
                        // //1. Deploy token
                        // let launchpadId = Principal.fromActor(this);
                        // let tokenId = await TokenService.deployToken(launchpad.saleToken, launchpadId);
                        // Debug.print("Token deployed: " # Principal.toText(tokenId));
                        // //2. SALE TOKEN
                        // //2.1 Create vesting contract for fairlaunch
                        // if(launchpad.distribution.fairlaunch.vesting.duration > 0){
                        //     let saleTokenInfo: Types.TokenInfo = {
                        //         launchpad.saleToken with canisterId = tokenId;
                        //     };
                        //     let fairlaunchVestingId = await ClaimService.createContract(launchpad.distribution.fairlaunch, saleTokenInfo, launchpadId, launchpad.title, "fairlaunch");
                        //     Debug.print("Fairlaunch vesting contract created: " # Principal.toText(fairlaunchVestingId));
                        // }else{//Unlock immediately
                        //     ignore await startBatchProcess(#Distribution);
                        // };

                        // //2.2 Create vesting contract for team
                        // if(launchpad.distribution.team.vesting.duration > 0){
                        //     let saleTokenInfo: Types.TokenInfo = {
                        //         launchpad.saleToken with canisterId = tokenId;
                        //     };
                        //     let teamVestingId = await ClaimService.createContract(launchpad.distribution.team, saleTokenInfo, launchpadId, launchpad.title, "team");
                        //     Debug.print("Team vesting contract created: " # Principal.toText(teamVestingId));
                        // };

                        // //2.3 Create vesting contract for liquidity


                        // //3. PURCHASE TOKEN (Default ICP)
                        // let saleTokenInfo: Types.TokenInfo = {
                        //     launchpad.saleToken with canisterId = tokenId;
                        // };
                        // //3.1 Create vesting contract for purchase token : liquidity, team
                        // let purchaseTokenInfo: Types.TokenInfo = launchpad.purchaseToken;
                        // let liquidityVestingId = await ClaimService.createContract(launchpad.distribution.liquidity, purchaseTokenInfo, launchpadId, launchpad.title, "liquidity");
                        // Debug.print("Liquidity vesting contract created: " # Principal.toText(liquidityVestingId));
                        //4. Process refund (if have in refund list: excepted for error)
                        //5. Close the launchpad
                        // ignore await startBatchProcess(#Distribution);
                    } else {
                        // Start refund if not meet softcap
                        ignore await startBatchProcess(#Refund);
                    };
                };
                case (#Processing(_)) {
                    // Continue processing batch if in progress
                    ignore await processBatch();
                };
                case (#Completed) {
                    // Stop timer if completed
                    stopAutoProcess();
                    autoProcessEnabled := false;
                };
                case (#Failed(error)) {
                    // Log error and try again later
                    Debug.print("Processing failed: " # error);
                };
            };
        };
    };

    //Update owner
    public shared (msg) func updateOwner(owner: Principal): async () {
        assert(_isAdmin(Principal.toText(msg.caller)));
        _owner := owner;
    };

    public shared (msg) func checkEligibleToCommit() : async Result.Result<Bool, Text> {
        let _eligible = await checkBlockIDScore(msg.caller);
        if (_eligible) {
            return #ok(true);
        } else {
            return #err("Your BlockID score is not enough, required score is " # debug_show(REQUIRED_SCORE) # ", please increase your score on https://blockid.cc");
        };
    };

    public shared ({caller}) func updateScore(score: Nat): async (){
        assert(_isAdmin(Principal.toText(caller)));
        REQUIRED_SCORE:= score
    };
    //Trigger success flow
    public shared (msg) func triggerSuccessFlow(amount: Nat, to: Principal): async Result.Result<Nat, Text> {
        assert(_isAdmin(Principal.toText(msg.caller)));
        //TODO: Run success flow
        //1. Mint token to participants
        //2. Distribute affiliate reward
        //3. Process refund
        //4. Process PurchaseLedger refund
        //5. Close the launchpad
        //Trigger marnually with quokka token
        let _tx = await PurchaseLedger.icrc1_transfer({
            from = { owner = Principal.fromActor(this); subaccount = null };
            to = { owner = to; subaccount = null };
            amount = amount;
            fee = null;
            memo = null;
            created_at_time = null;
            from_subaccount = null;
        });
        switch(_tx){
            case (#Ok(txId)){
                return #ok(txId);
            };
            case (#Err(e)){
                return #err("Error: " # debug_show(e));
            };
        };
    };

    public shared (msg) func commit(amount : Nat, refCode: ?Text) : async Result.Result<Bool, Text> {
        if(not installed){
            return #err("LAUNCHPAD_NOT_INSTALLED");
        };
        let participantId : Principal = msg.caller;
        let participantTxt : Text = Principal.toText(participantId);
        if (not (await checkBlockIDScore(participantId))) {
            return #err("Your BlockID score is not enough, required score is " # debug_show(REQUIRED_SCORE) # ", please increase your score on https://blockid.cc");
        };
        if (isInWhitelist(participantTxt)) {
            // investors can participate the launchpad in the range of specified date
            let now : Time.Time = Time.now();
            let launchpad = await getLaunchpadDetail();
            if(now < launchpad.timeline.startTime) return #err("This pool is not started yet!");
            if (launchpad.timeline.startTime <= now and now < launchpad.timeline.endTime) {
                //Check total amount participant has committed
                let participantInfo = await getParticipantInfo(participantTxt);
                if (participantInfo.totalAmount >= launchpad.launchParams.maximumAmount) {
                    return #err("You have reached the maximum commit limit");
                };
                //Check minimum deposit amount
                if (amount + participantInfo.totalAmount < launchpad.launchParams.minimumAmount) {
                    return #err("Commit amount must be greater than " #debug_show(launchpad.launchParams.minimumAmount));
                };
                if(amount + participantInfo.totalAmount > launchpad.launchParams.maximumAmount){
                    return #err("Commit amount must be less than " #debug_show(launchpad.launchParams.maximumAmount));
                };
                //Check total commit amount
                if (TOTAL_AMOUNT_COMMITED + amount + participantInfo.totalAmount > launchpad.launchParams.hardCap) {
                    return #err("Total commit amount exceeded");
                };

                //Transfer token from investor to user subaccount
                var _txId :Nat = 0;
                let _depositAccount = await _createUserAddress(participantId);
                switch (
                    await PurchaseLedger.icrc2_transfer_from({ 
                    from = { owner = participantId; subaccount = null }; 
                    spender_subaccount = null; 
                    to = _depositAccount; 
                    fee = null; 
                    memo = null; 
                    from_subaccount = null; 
                    created_at_time = null; 
                    amount = amount })) {
                case (#Ok(txId)){
                    _txId := txId;
                    ();
                };
                case (#Err(e)) return #err("Payment error: " # debug_show(e));
                };
                //Recheck hardcap to ensure in case of multiple deposit at the same time
                if (TOTAL_AMOUNT_COMMITED + amount <= launchpad.launchParams.hardCap) {
                    TOTAL_AMOUNT_COMMITED += amount;
                    //Add transaction
                    transactions.add({
                        participant = participantTxt;
                        time = now;
                        method = "deposit";
                        amount = amount;
                        txId = ?_txId;
                    });
                    //Update participant info
                    updateParticipantInfo(participantTxt, amount);

                    //Process ref transaction if not the same as the participant
                    if(not Text.equal(Option.get(refCode, ""), participantTxt)){
                        processRefTransaction(refCode, amount);//Process affiliate link
                    };
                    
                    return #ok(true);
                }else{
                    //Moving to refund list
                    refunds.add({
                        participant = participantTxt;
                        time = now;
                        method = "refund";
                        amount = amount;
                        txId = ?_txId;
                    });
                    return #err("Total commit amount exceeded, your deposit will be refunded.");
                };
            } else {
                return #err("This pool has been finished");
            };
        } else {
            return #err("You are not in the whitelist");
        };
    };

    //Process if the transaction is a referral transaction
    private func processRefTransaction(refCode: ?Text, amount: Nat) : () {
        switch (refCode) {
            case null { /* Non-affiliate transaction */ };
            case (?code) {
                totalAffiliateVolume += amount;
                refererTransaction += 1;//Increase affiliate transaction
                let stats = switch (affiliateStats.get(code)) {
                    case null { { volume = 0; projectedReward = 0; refCount = 0 } };
                    case (?s) { s };
                };
                affiliateStats.put(code, { volume = stats.volume + amount; projectedReward = 0; refCount = stats.refCount + 1; }); // Will update
            };
        };

        // Update projected rewards for all affiliates
        updateProjectedRewards();
    };

    private func updateProjectedRewards() {
        //Only count the affiliate reward pool if there are any affiliate transactions
        let affiliateRewardPool = totalAffiliateVolume * AFFILIATE_PERCENTAGE/100;

        for ((code, stats) in affiliateStats.entries()) {
            let projectedReward = (stats.volume / totalAffiliateVolume) * affiliateRewardPool;
            affiliateStats.put(code, { volume = stats.volume; projectedReward = projectedReward; refCount = stats.refCount });
        };
    };

    public query func getAffiliateStats(refCode: Text) : async ?Types.AffiliateStats {
        affiliateStats.get(refCode)
    };

    public query func getTopAffiliates(limit: Nat) : async [(Text, Types.AffiliateStats)] {
        let affiliateArray = Array.sort<(Text, Types.AffiliateStats)>(
        Iter.toArray(affiliateStats.entries()),
        func (a, b) {
            if (a.1.volume > b.1.volume) { #less }
            else if (a.1.volume < b.1.volume) { #greater }
            else { #equal }
            }
        );
        Array.subArray(affiliateArray, 0, Nat.min(limit, affiliateArray.size()))
    };

    //Check if the caller is the owner of the canister
    private func isInWhitelist(participant : Text) : Bool {
        if (whitelist.size() == 0) {
            return true;
        };
        //Find participant in whilist and return true
        for (_principal in whitelist.vals()) {
            if (Text.equal(_principal, participant)) {
                return true;
            }
        };
        return false;
    };

    public shared func getParticipantInfo(participant : Text) : async Types.Participant {
        return switch (participants.get(participant)) {
            case (?user) {
                return user;
            };
            case (_) {
                return {
                    totalAmount = 0;
                    commit = 0;
                    lastDeposit = null;
                };
            };
        };
    };
    public shared func getTransactionList() : async [Types.Transaction] {
        return Buffer.toArray(transactions);
    };
    public shared func getRefundList() : async [Types.Transaction] {
        return Buffer.toArray(refunds);
    };
    public shared func status() : async Types.LaunchpadStatus {
        let _detail = await getLaunchpadDetail();
        let _status = getStatusByTime(_detail);//Check status by time
        return {
            totalAmountCommitted = TOTAL_AMOUNT_COMMITED;
            totalParticipants = participants.size();
            totalTransactions = transactions.size();
            whitelistEnabled = if(whitelist.size() > 0){ true } else false;
            status = _status;
            affiliate = _detail.affiliate;
            cycle = 0; //Cycles.balance();
            installed = installed;
            totalAffiliateVolume = totalAffiliateVolume;
            refererTransaction = refererTransaction;
            affiliateRewardPool = totalAffiliateVolume * AFFILIATE_PERCENTAGE/100;
        };
    };
    private func getStatusByTime(_detail: Types.LaunchpadDetail) : Text {
        if(Time.now() < _detail.timeline.startTime) return "UPCOMING";
        if(_detail.timeline.startTime <= Time.now() and Time.now() < _detail.timeline.endTime){
            LAUNCH_STATUS := "LIVE";
        }else if(Time.now() >= _detail.timeline.endTime and Time.now() < _detail.timeline.claimTime){
            LAUNCH_STATUS := "FINISHED";
        }else if(Time.now() >= _detail.timeline.claimTime){
            if(TOTAL_AMOUNT_COMMITED >= _detail.launchParams.softCap){
                LAUNCH_STATUS := "CLAIMING"; 
            }else{
                LAUNCH_STATUS := "REFUNDING";
            };
        }else{
            LAUNCH_STATUS := "CLOSED";
        };
        return LAUNCH_STATUS;
    };
    public shared (msg) func reinstall() : async () {
        assert(_isAdmin(Principal.toText(msg.caller)));
        installed := false;
        launchpadDetail := null;
        whitelist := [];
        transactions.clear();
        _participants := [];
        participants := HashMap.fromIter(_participants.vals(), 0, Text.equal, Text.hash);
        TOTAL_AMOUNT_COMMITED := 0;
        LAUNCH_STATUS := "NOT_STARTED";
        totalAffiliateVolume := 0;
        affiliateStats := HashMap.HashMap<Text, Types.AffiliateStats>(10, Text.equal, Text.hash);
        AFFILIATE_PERCENTAGE := 0;
        SOFTCAP := 0;
        HARDCAP := 0;
    };
    //Update affiliate percentage
    public shared (msg) func updateAffiliatePercentage(percentage: Nat): async (){
        assert(_isAdmin(Principal.toText(msg.caller)));
        AFFILIATE_PERCENTAGE := percentage;
    };
    //Get launchpad detail
    public shared func launchpadInfo() : async Types.LaunchpadDetail {
        let _detail = await getLaunchpadDetail();
        return _detail;
    };
    //Get project logo
    public shared func getProjectLogo() : async Text {
        let _detail = await getLaunchpadDetail();
        return _detail.projectInfo.logo;
    };
    //Get project banner
    public shared func getProjectBanner() : async Text {
        let _detail = await getLaunchpadDetail();
        switch(_detail.projectInfo.banner){
            case (?banner) {
                return banner;
            };
            case (_) {
                return "";
            };
        };
    };
    
    private func getLaunchpadDetail() : async Types.LaunchpadDetail {
        return switch (launchpadDetail) {
            case (?launchpadDetail) {
                return launchpadDetail;
            };
            case (_) {
                throw Error.reject("NOT_INSTALLED_YET");
            };
        };
    };

    private func updateParticipantInfo(participant: Text, amount: Nat): () {
        switch(participants.get(participant)){
            case (?user){
                let _userInfo = {
                    user with totalAmount = user.totalAmount + amount;
                    commit = user.commit + 1;
                    lastDeposit = ?Time.now();
                };
                participants.put(participant, _userInfo);
                ();
            };
            case _{
                let _userInfo = {
                    totalAmount = amount;
                    commit = 1;
                    lastDeposit = ?Time.now();
                };
                participants.put(participant, _userInfo);
                ();
            }
        }
    };

    private func _isAdmin(p : Text) : (Bool) {
        Prim.isController(Principal.fromText(p)) or 
        Array.find<Text>(_admins, func(admin : Text) = admin == p) != null
    };

    //Create user deposit by subaccount
    private func _createUserAddress(userPrincipal : Principal) : async Types.Account {
        let depositAccount : Types.Account = {
            owner = Principal.fromActor(this);  // Launchpad canister
            subaccount = ?Principal.toBlob(userPrincipal);  // Create a subaccount based on the user's principal
        };
        Debug.print("Created deposit address for principal: " # debug_show(userPrincipal));
        return depositAccount;
    };

    //////////////////////// AUTO PROCESS THE STREAMLINE 

    // Define task execution functions
    private func executeDeployToken(params: ?Text): async Result.Result<Text, Text> {
        try {
            // Call the existing deploy token function
            // ...
            return #ok("Token deployed successfully");
        } catch (e) {
            return #err("Deploy token failed: " # Error.message(e));
        };
    };
    private func executeDistribution(params: ?Text): async Result.Result<Text, Text> {
        try {
            // Call the existing distribution function
            // ...
            return #ok("Distribution completed successfully");
        } catch (e) {
            return #err("Distribution failed: " # Error.message(e));
        };
    };
    private func executeCreateLockToken(params: ?Text): async Result.Result<Text, Text> {
        try {
            // Call the existing create lock token function
            // ...
            return #ok("Lock token created successfully");
        } catch (e) {
            return #err("Create lock token failed: " # Error.message(e));
        };
    };
    private func executeCreateLP(params: ?Text): async Result.Result<Text, Text> {
        try {
            // Call the existing create LP function
            // ...
            return #ok("LP created successfully");
        } catch (e) {
            return #err("Create LP failed: " # Error.message(e));
        };
    };
    
    // Initialize map of executors
    private func initExecutors(): HashMap.HashMap<TaskManager.TaskType, TaskManager.TaskExecutor> {
        let executors = HashMap.HashMap<TaskManager.TaskType, TaskManager.TaskExecutor>(0, func(a, b) { a == b }, func(a) { 0 });
        executors.put(#DeployToken, executeDeployToken);
        executors.put(#Distribution, executeDistribution);
        executors.put(#CreateLockToken, executeCreateLockToken);
        executors.put(#CreateLP, executeCreateLP);
        return executors;
    };

    // Start the process
    public shared(msg) func startProcess(): async Result.Result<Text, Text> {
        try {
            let executors = initExecutors();
            
            // Create tasks in order
            let deployTokenId = taskManager.createTask(#DeployToken, null);
            let distributionId = taskManager.createTask(#Distribution, null);
            let createLockTokenId = taskManager.createTask(#CreateLockToken, null);
            let createLPId = taskManager.createTask(#CreateLP, null);
            
            // Execute and check the first task
            await taskManager.executeTask(deployTokenId, executors);
            let deployResult = await checkTaskStatus(deployTokenId, "Deploy token");
            switch(deployResult) {
                case (#err(e)) { return #err(e); };
                case (#ok(_)) { /* Continue */ };
            };
            
            // Execute and check the second task
            await taskManager.executeTask(distributionId, executors);
            let distResult = await checkTaskStatus(distributionId, "Distribution");
            switch(distResult) {
                case (#err(e)) { return #err(e); };
                case (#ok(_)) { /* Continue */ };
            };
            
            // Execute and check the third task
            await taskManager.executeTask(createLockTokenId, executors);
            let lockResult = await checkTaskStatus(createLockTokenId, "Create lock token");
            switch(lockResult) {
                case (#err(e)) { return #err(e); };
                case (#ok(_)) { /* Continue */ };
            };
            
            // Execute and check the last task
            await taskManager.executeTask(createLPId, executors);
            let lpResult = await checkTaskStatus(createLPId, "Create LP");
            switch(lpResult) {
                case (#err(e)) { return #err(e); };
                case (#ok(_)) { return #ok("All tasks completed successfully"); };
            };
            
            return #ok("All tasks completed successfully");
        } catch (e) {
            return #err("Process failed: " # Error.message(e));
        };
    };

    // Helper function to check task status
    private func checkTaskStatus(taskId: Nat, taskName: Text): async Result.Result<(), Text> {
        switch (taskManager.getTask(taskId)) {
            case (null) { 
                return #err(taskName # " task not found"); 
            };
            case (?task) {
                switch (task.status) {
                    case (#Completed) {
                        return #ok(());
                    };
                    case (#Failed(error)) { 
                        return #err(taskName # " failed: " # error); 
                    };
                    case (_) { 
                        return #err(taskName # " task is in unexpected status"); 
                    };
                };
            };
        };
    };
    // Other APIs
    public query func getAllTasks(): async [TaskManager.Task] {
        return taskManager.getAllTasks();
    };
    
    public query func getTask(taskId: Nat): async ?TaskManager.Task {
        return taskManager.getTask(taskId);
    };
    
    public shared(msg) func retryTask(taskId: Nat): async Result.Result<Text, Text> {
        assert(_isAdmin(Principal.toText(msg.caller)));
        switch (taskManager.retryTask(taskId)) {
            case (null) { return #err("Task not found"); };
            case (?task) {
                await taskManager.executeTask(taskId, initExecutors());
                return #ok("Task retry initiated." # debug_show(task));
            };
        };
    };

    //////////////////////// END AUTO PROCESS THE STREAMLINE 

    // Query functions
    public query func getProcessingStatus() : async {
        state: {#NotStarted; #Processing: {processed: Nat; total: Nat}; #Completed; #Failed: Text};
        processedCount: Nat;
        totalTransactions: Nat;
    } {
        {
            state = processingState;
            processedCount = processedTransactions.size();
            totalTransactions = pendingTransfers.size();
        }
    };

    public query func getProcessedTransactions(start: Nat, limit: Nat) : async [Types.Transaction] {
        let end = Nat.min(start + limit, processedTransactions.size());
        Array.subArray(processedTransactions, start, Nat.sub(end, start))
    };

    // System upgrade hooks
    system func preupgrade() {
        transactionsArray := Buffer.toArray(transactions);
        refundsArray := Buffer.toArray(refunds);
        _participants := Iter.toArray(participants.entries());
        _affiliateStats := Iter.toArray(affiliateStats.entries());
        taskManagerEntries := taskManager.toStable();
        nextTaskId := taskManager.getNextTaskId();

        // _pendingTransfers := pendingTransfers;
        // _processedTransactions := processedTransactions;
        // _lastProcessedIndex := lastProcessedIndex;
        // _processingState := processingState;
    };

    system func postupgrade() {
        participants := HashMap.fromIter(_participants.vals(), 0, Text.equal, Text.hash);
        transactions := Buffer.fromArray(transactionsArray);
        refunds := Buffer.fromArray(refundsArray);
        affiliateStats := HashMap.fromIter(_affiliateStats.vals(), 0, Text.equal, Text.hash);
        taskManager.fromStable(taskManagerEntries, nextTaskId);
        taskManagerEntries := [];
        // pendingTransfers := _pendingTransfers;
        // processedTransactions := _processedTransactions;
        // lastProcessedIndex := _lastProcessedIndex;
        // processingState := _processingState;
    };
}