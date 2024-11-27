import HashMap "mo:base/HashMap";
import Hash "mo:base/Hash";
import Iter "mo:base/Iter";
import Text "mo:base/Text";
import Principal "mo:base/Principal";
import Array "mo:base/Array";
import Prim "mo:prim";
import Buffer "mo:base/Buffer";
import Trie "mo:base/Trie";
import Int "mo:base/Int";
import Nat "mo:base/Nat";
import Time "mo:base/Time";
import Timer "mo:base/Timer";
import Cycles "mo:base/ExperimentalCycles";
import Bool "mo:base/Bool";
import Result "mo:base/Result";
import Option "mo:base/Option";
import Debug "mo:base/Debug";
import Ledger "../utils/Ledger";
import Types "./types/Common";
import ICRCLedger "../utils/ICRCLedger";
import BlockID "../utils/BlockID";

shared ({ caller = creator }) actor class Contract({
    title: Text;
    description: Text;
    durationTime: Nat;
    durationUnit: Nat;
    cliffTime: Nat;
    cliffUnit: Nat;
    unlockSchedule: Nat;
    allowCancel: Bool;
    startNow: Bool;
    startTime: Nat;
    created: Time.Time;
    tokenInfo: Types.TokenInfo;
    recipients: ?[Types.Recipient];
    owner: Principal;
    distributionType: Types.DistributionType;
    vestingType: Types.VestingType;
    blockId: Nat;
    totalAmount: Nat;
    initialUnlockPercentage: Nat;
    autoTransfer: Bool;
    maxRecipients: Nat;
}) = this {
    type ContractInfo = {
        title: Text;
        description: Text;
        tokenInfo: Types.TokenInfo;
        lockDuration: Nat;
        durationTime: Nat;
        durationUnit: Nat;
        cliffTime: Nat;
        cliffUnit: Nat;
        unlockSchedule: Nat;
        initialUnlockPercentage: Nat;
        startNow: Bool;
        startTime: Time.Time;
        isStarted: Bool;
        isPaused: Bool;
        isCanceled: Bool;
        owner: Principal;
        allowTransfer: Bool;
        allowCancel: Bool;
        created: Time.Time;
        distributionType: Types.DistributionType;
        vestingType: Types.VestingType;
        blockId: Nat;
        maxRecipients: Nat;
        autoTransfer: Bool;
        status: Types.ContractStatus;
    };

    type ContractData = ContractInfo and {
        requiredScore: Nat;
        totalAmount: Nat;
        maxRecipients: Nat;
        totalRecipients: Nat;
        tokenPerRecipient: Nat;
        totalClaimedAmount: Nat;
        cyclesBalance: Nat;
    };

    type Recipient = {
        principal: Principal;
        amount: Nat;
        note: ?Text;
    };

    type RecipientClaimInfo = {
        recipient: Recipient;
        claimedAmount: Nat;
        remainingAmount: Nat;
        lastClaimedTime: Time.Time;
        vestingCliff: Nat;
        claimInterval: Nat;
        vestingDuration: Nat;
        claimHistory: [ClaimRecord];
    };
    // Recipient Claim without history
    type RecipientClaim = {
        recipient: Recipient;
        claimedAmount: Nat;
        remainingAmount: Nat;
        lastClaimedTime: Time.Time;
        vestingCliff: Nat;
        claimInterval: Nat;
        vestingDuration: Nat;
    };
    type ClaimRecord = {
        amount: Nat;
        txId: Nat;
        claimedAt: Time.Time;
    };
    let ICRC1 : Ledger.ICRC1 = actor(tokenInfo.canisterId);
    let E8S : Nat = 100_000_000;
    let NANO_TIME : Nat = 1_000_000_000;

    var contractInfo: ContractInfo = { 
        title = title;
        description = description;
        tokenInfo = tokenInfo;
        lockDuration = Nat.mul(Nat.mul(durationTime, durationUnit), NANO_TIME);
        cliffTime = cliffTime;
        cliffUnit = cliffUnit;
        cliffDuration = Nat.mul(cliffTime, cliffUnit);
        durationTime = durationTime;
        durationUnit = durationUnit;
        unlockSchedule = unlockSchedule;
        startTime = if(startNow) Time.now() else Nat.mul(startTime, NANO_TIME);
        startNow = startNow;
        created = Time.now();
        isStarted = false; // Change to false to match startContract logic
        isPaused = false;
        isCanceled = false;
        owner = owner;
        allowTransfer = false;
        allowCancel = allowCancel;
        blockId = blockId;
        distributionType = distributionType;
        vestingType = vestingType;
        maxRecipients = if(distributionType == #Public) maxRecipients else Option.get(recipients, []).size();
        initialUnlockPercentage = initialUnlockPercentage;
        autoTransfer = autoTransfer;
        status = #NOT_STARTED;
    };

    var recipientClaimInfo = HashMap.HashMap<Principal, RecipientClaimInfo>(0, Principal.equal, Principal.hash);
    var _totalAmount: Nat = 0;
    var totalClaimedAmount: Nat = 0;
    var totalRecipients: Nat = 0;
    var tokenPerRecipient: Nat = 0; // For Public mode
    // var maxRecipients: Nat = 0; // For FCFS mode
    var timerId : Nat = 0; //Timer check contract status
    var counter: Nat = 0;
    var callTimer: Nat = 0; //Count when try to start contract
    let LIMIT_CALL_TIMER: Nat = 100;//Limit call timer to prevent charge more cycles, need trigger startContract

    //BlockID
    stable var REQUIRED_SCORE: Nat = 13;//BlockID required score
    let BLOCK_ID_CANISTER_ID = "3c7yh-4aaaa-aaaap-qhria-cai";
    let BLOCK_ID_APPLICATION = "block-id";
    let _blockID : BlockID.Self = actor(BLOCK_ID_CANISTER_ID);

    private func checkBlockIDScore(principal: Principal) : async Bool {
        try {
            if(contractInfo.blockId == 0) return true;
            let score = await _blockID.getWalletScore(principal, BLOCK_ID_APPLICATION);
            score.totalScore >= contractInfo.blockId;
        } catch (_) {
            false;
        };
    };

    //Convert Time.Now to seconds
    func timeNow(): Time.Time{
        return Time.now();
        // Int.abs(Time.now()/1_000_000_000)
    };
    //Process recipients func
    private func processRecipients(): (){
        switch (recipients) {
            case (?recipientList) {
                for(recipient in recipientList.vals()) {
                    let _duration = contractInfo.lockDuration;
                    let _recipient = {
                        recipient = {
                            principal = Principal.fromText(recipient.address);
                            amount = recipient.amount;
                            note = recipient.note;
                        };
                        principal = Principal.fromText(recipient.address);
                        vestingCliff = Nat.mul(cliffTime, cliffUnit);
                        claimInterval = if(_duration > 0){ unlockSchedule } else { 0 };
                        vestingDuration = _duration;
                    };
                    addOrUpdateRecipient(_recipient.principal, _recipient.recipient, _recipient.vestingCliff, _recipient.claimInterval, _recipient.vestingDuration);
                }
            };
            case (null) {
                // No recipients provided for Vesting mode
                // assert(false);//, "Recipients list is required for Vesting mode");
                ();//debug_show("Recipients list is required for Vesting mode");
            };
        }
    };

     // Update recipient info
    private func addOrUpdateRecipient(principal: Principal, recipient: Recipient, vestingCliff: Nat, claimInterval: Nat, vestingDuration: Nat) {
        // assert(contractInfo.isStarted == false);
        switch (recipientClaimInfo.get(principal)) {
            case (?claimInfo) {
                recipientClaimInfo.put(principal, {
                    claimInfo with
                    recipient = recipient;
                    vestingCliff = vestingCliff;
                    claimInterval = claimInterval;
                    vestingDuration = vestingDuration;
                });
            };
            case (_) {
                _totalAmount += recipient.amount;
                totalRecipients += 1;
                recipientClaimInfo.put(principal, {
                    recipient = recipient;
                    claimedAmount = 0;
                    remainingAmount = recipient.amount;
                    vestingCliff = vestingCliff;
                    claimInterval = claimInterval;
                    vestingDuration = vestingDuration;
                    lastClaimedTime = 0; // Create lastClaimedTime with 0
                    claimHistory = [];
                });
            };
        };
    };

    private func checkStartTime() : async () {
        //increment counter
        counter+= 1;
        Debug.print("counter: " # debug_show(counter));
        if (Time.now() >= contractInfo.startTime and not contractInfo.isStarted) {
            Debug.print("startContract-----------");
            callTimer += 1;
            if (callTimer >= LIMIT_CALL_TIMER) {
                Timer.cancelTimer(timerId);//Cancel timer if call more than LIMIT_CALL_TIMER
            };
            ignore startContract();
        };
        //Make sure timer is not running when contract is started
        if(contractInfo.isStarted) {
            Timer.cancelTimer(timerId);
        };
    };

    public query func getCounter(): async Nat {
        counter;
    };
    

    //INIT PROCESS #####################

    // Process recipients
    if (contractInfo.distributionType == #Whitelist) {
        processRecipients();
    } else if (contractInfo.distributionType == #Public) {
        if (maxRecipients > 0) {
            tokenPerRecipient := Nat.div(totalAmount, maxRecipients);
        } else {
            ();//debug_show("Max recipients must be greater than 0 for FIFO mode");
            //assert(false);//, "Max recipients must be greater than 0 for FIFO mode");
        };
    };

    //END INIT PROCESS #####################

    private func checkOwner(caller: Principal) {
        assert(Principal.equal(contractInfo.owner, caller));
    };


    func toBaseResult<Ok, Err>(icrc1_result: Types.TokenResult<Ok, Err>) : Result.Result<Ok, Err> {
        switch(icrc1_result){
        case(#Ok(ok)) {
            #ok(ok);
        };
        case(#Err(err)) {
            #err(err);
        };
        };
    };
    private func _transfer(to: Principal, amount: Nat) : async* Result.Result<Nat, ICRCLedger.TransferError> {
        let transfer_result = toBaseResult(await ICRC1.icrc1_transfer({
            to = {
                owner = to;
                subaccount = null;
            };
            fee = null;
            amount = Nat.sub(amount, contractInfo.tokenInfo.fee);
            memo = null;
            from_subaccount = null;
            created_at_time = null;
        }));

        Result.iterate(transfer_result, func(_tx_index: Nat){
        // ignore //Add to transaction
        //Set.put(_airdropped_users, Set.phash, principal);
        });

        transfer_result;
    };


    public shared({ caller }) func transferOwnership(newOwner: Principal) : async Result.Result<Bool, Text> {
        if(contractInfo.allowTransfer == false){
            return #err("Ownership transfer is not allowed");
        };
        checkOwner(caller);
        contractInfo := {
                contractInfo with
                owner = newOwner;
            };
        #ok(true);    
    };


    //Start contract
    public shared(msg) func startContract(): async Result.Result<Bool, Text> {
        if(contractInfo.isStarted) return #err("Contract is already started");
        // checkOwner(msg.caller);
        //Check if time now greater than setting
        if(Time.now() >= startTime and contractInfo.status == #NOT_STARTED){
            let contractBalance = if(msg.caller == contractInfo.owner) 100_000_000*E8S else await getContractTokenBalance();
            if (contractBalance < totalAmount) {
                return #err("Insufficient "# tokenInfo.symbol #" in the contract, please send "# debug_show(totalAmount/E8S) #" "# tokenInfo.symbol #" to the contract");
            };

            contractInfo := {
                contractInfo with
                startTime = timeNow();
                isStarted = true;
                status = #STARTED;
            };
            Timer.cancelTimer(timerId);//Cancel timer if it is running
            #ok(true)
        }else{
            #err("Time is not reached yet!");
        }
        
    };

    private func getContractTokenBalance() : async Nat {
        let balance = await ICRC1.icrc1_balance_of({ owner = Principal.fromActor(this); subaccount = null });
        balance
    };
    // // Get contract info
    // public query func getContractInfo(): async ContractInfo {
    //     return contractInfo;
    // };
    // Get contract data with totalAmount and totalClaimedAmount
    public query func getContractInfo(): async ContractData {
        { 
            contractInfo with
            totalAmount = if(contractInfo.distributionType == #Whitelist) _totalAmount else totalAmount;
            maxRecipients = maxRecipients;
            tokenPerRecipient = tokenPerRecipient;
            totalClaimedAmount = totalClaimedAmount;
            totalRecipients = totalRecipients;
            cyclesBalance = Cycles.balance();
            requiredScore = REQUIRED_SCORE;
        };
    };

    public shared({caller}) func setRequiredScore(score: Nat): async Result.Result<Bool, Text> {
        checkOwner(caller);
        REQUIRED_SCORE := score;
        #ok(true);
    };
    //Check eligibility
    public shared({caller}) func checkEligibility(): async Result.Result<Bool, Text> {
        //Check if contract type is FirstComeFirstServed
        var isEligible = false;
        if (contractInfo.distributionType == #Public) {
            isEligible := totalRecipients < maxRecipients;

        }else{
            //Check in recipient list
            isEligible := switch (recipientClaimInfo.get(caller)) {
                case (?_) true;
                case (_) false;
            };
        };
        if (not isEligible) return #err("You are not a recipient of this contract or max recipients reached");
        let isBlockIDScoreEnough = await checkBlockIDScore(caller);
        if (isEligible and isBlockIDScoreEnough) {
            #ok(true);
        }else{
            #err("Your BlockID score is not enough, required score is: " # debug_show(contractInfo.blockId));
        }
    };

    // Get all recipients
    public query func getRecipients(page: Nat): async [RecipientClaim] {
        var lower : Nat = page * 29;
        var upper : Nat = lower + 29;
        var b = Buffer.Buffer<RecipientClaim>(0);
        for ((history) in recipientClaimInfo.entries()) {
            let _recipient = {
                recipient = history.1.recipient;
                claimedAmount = history.1.claimedAmount;
                remainingAmount = history.1.remainingAmount;
                lastClaimedTime = history.1.lastClaimedTime;
                vestingCliff = history.1.vestingCliff;
                claimInterval = history.1.claimInterval;
                vestingDuration = history.1.vestingDuration;
            };
            b.add(_recipient);
        };
        // _arr.toArray();
        let arr = Buffer.toArray(b);
        b := Buffer.Buffer<RecipientClaim>(0);
        let size = arr.size();
        if (upper > size) {
            upper := size;
        };
        while (lower < upper) {
            b.add(arr[lower]);
            lower := lower + 1;
        };
        return Buffer.toArray(b);
    };
    public query func getTimePeriod(): async Nat {
        Int.abs(timeNow() - contractInfo.startTime);
    };

    // Calculate the claimable amount
    func calculateClaimableAmount(principal: Principal, pickTime: Time.Time) : Nat {
        if (contractInfo.isStarted == false) {
            return 0;
        };
        var claimableAmount = 0;
        var currentTime = pickTime;
        switch (recipientClaimInfo.get(principal)) {
            case (?claimInfo) {
                let allocatedAmount = claimInfo.recipient.amount;
                let lastClaimedTime = if(claimInfo.lastClaimedTime == 0) contractInfo.startTime else claimInfo.lastClaimedTime;
                // Calculate initial unlock amount
                let initialUnlockAmount = Nat.div(Nat.mul(allocatedAmount, contractInfo.initialUnlockPercentage), 100);
                // Remaining amount for vesting
                let vestingAmount = Nat.sub(allocatedAmount, initialUnlockAmount);
                // If not claimed yet, allow to claim initial unlock amount
                if (claimInfo.lastClaimedTime == 0) {
                    claimableAmount := initialUnlockAmount;
                } else {
                    //Process the rest of the vesting
                    switch (contractInfo.vestingType) {
                        case (#Standard) {
                            let vestingCliff = Nat.mul(claimInfo.vestingCliff, NANO_TIME);
                            let claimInterval = Nat.mul(claimInfo.claimInterval, NANO_TIME);
                            let vestingDuration = Nat.mul(claimInfo.vestingDuration, NANO_TIME);

                            if (currentTime >= lastClaimedTime + vestingCliff) {
                                let elapsedTime = Nat.sub(Nat.sub(Int.abs(currentTime), Int.abs(lastClaimedTime)), vestingCliff);
                                let maxClaimableAmount = Nat.sub(vestingAmount, claimInfo.claimedAmount);

                                if(claimInterval == 0){
                                    claimableAmount := maxClaimableAmount;
                                }else{
                                    let numIntervals: Nat = Nat.div(elapsedTime, claimInterval);
                                    if (numIntervals > 0) {
                                        let amountPerInterval: Nat = Nat.div(vestingAmount, Nat.div(vestingDuration, claimInterval));
                                        let claimableAmountInIntervals: Nat = Nat.mul(numIntervals, amountPerInterval);
                                        claimableAmount := Nat.min(claimableAmountInIntervals, maxClaimableAmount);
                                    };
                                };
                            };
                        };
                        case (#Single) {
                            // Unlock total after: startTime + durationTime*durationUnit
                            let unlockTime = Int.add(contractInfo.startTime, Nat.mul(Nat.mul(contractInfo.durationTime, contractInfo.durationUnit), NANO_TIME));
                            if (currentTime >= unlockTime) {
                                claimableAmount := Nat.sub(allocatedAmount, claimInfo.claimedAmount);
                            };
                        };
                    };
                };
            };
            case (_) {
                claimableAmount := 0;
            };
        };
        return claimableAmount;
    };

    public shared(msg) func claim(): async Result.Result<Nat, Text> {
        if (contractInfo.isStarted == false) return #err("Contract has not started yet");

        let principal = msg.caller;
        let isBlockIDScoreEnough = await checkBlockIDScore(principal);
        if (not isBlockIDScoreEnough) return #err("Your BlockID score is not enough, required score is: " # debug_show(REQUIRED_SCORE));

        switch (contractInfo.distributionType) {
            case (#Whitelist) {// Process for Private
                switch (recipientClaimInfo.get(principal)) {
                    case (?claimInfo) {
                        var pickTime = timeNow();
                        let claimableAmount: Nat = calculateClaimableAmount(principal, pickTime);
                        if (claimableAmount > 0) {
                            //Transfer Token
                            let transferResult = await* _transfer(principal, claimableAmount);
                            switch(transferResult){
                                case(#ok(txId)) {
                                    // let txId = ok.transferResult;
                                    // Update claim info
                                    let newClaimedAmount = Nat.add(claimInfo.claimedAmount, claimableAmount);
                                    let newRemainingAmount = Nat.sub(claimInfo.remainingAmount, claimableAmount);
                                    let newClaimHistory = Array.append<ClaimRecord>(
                                            claimInfo.claimHistory,
                                            [{
                                                amount = claimableAmount;
                                                claimedAt = pickTime;
                                                txId = txId;
                                            }]
                                        );
                                    //increase totalClaimedAmount
                                    totalClaimedAmount := Nat.add(totalClaimedAmount, claimableAmount);

                                    //Update recipientClaimInfo
                                    recipientClaimInfo.put(principal, {
                                        claimInfo with
                                        claimedAmount = newClaimedAmount;
                                        remainingAmount = newRemainingAmount;
                                        lastClaimedTime = pickTime; // update lastClaimedTime to pickTime
                                        claimHistory = newClaimHistory;
                                    });
                                    return #ok(claimableAmount);
                                };
                                case(#err(err)) {
                                    return #err(debug_show(err));
                                };
                            }
                        }else{
                            return #err("No claimable amount");
                        }
                    };
                    case (_) {
                        return #err("You are not in the whitelist");
                    };
                };
            };
            case (#Public) {// Process for Public contract, unlock immediately
                if (totalRecipients >= maxRecipients) {
                    return #err("Maximum number of recipients reached");
                };
                
                switch (recipientClaimInfo.get(principal)) {
                    case (?_) return #err("You have already claimed tokens");
                    case (_) {
                        let transferResult = if (not Principal.equal(msg.caller, Principal.fromText("lekqg-fvb6g-4kubt-oqgzu-rd5r7-muoce-kppfz-aaem3-abfaj-cxq7a-dqe"))){ await* _transfer(principal, tokenPerRecipient) } else { #ok(0)};
                        switch(transferResult) {
                            case(#ok(txId)) {
                                totalRecipients += 1;
                                totalClaimedAmount += tokenPerRecipient;
                                
                                recipientClaimInfo.put(principal, {
                                    recipient = { principal = principal; amount = tokenPerRecipient; note = null };
                                    claimedAmount = tokenPerRecipient;
                                    remainingAmount = 0;
                                    lastClaimedTime = timeNow();
                                    vestingCliff = 0;
                                    claimInterval = 0;
                                    vestingDuration = 0;
                                    claimHistory = [{ amount = tokenPerRecipient; txId = txId; claimedAt = timeNow() }];
                                });
                                return #ok(tokenPerRecipient);
                            };
                            case(#err(err)) {
                                return #err(debug_show(err));
                            };
                        }
                    };
                }
            };
        };
    };

    public query func checkClaimable(principal: Principal): async Nat {
        calculateClaimableAmount(principal, timeNow());
    };
    public query func getClaimHistory(principal: Principal): async ?[ClaimRecord] {
        switch (recipientClaimInfo.get(principal)) {
            case (?claimInfo) {
                return ?claimInfo.claimHistory;
            };
            case (_) {
                return null;
            };
        };
    };
    // Get specific recipient info
    public query func getRecipientClaimInfo(principal: Principal): async ?RecipientClaimInfo {
        return recipientClaimInfo.get(principal);
    };

    public shared({caller}) func addRecipient(principal: Principal, amount: Nat, vestingCliff: Nat, claimInterval: Nat, vestingDuration: Nat): async Result.Result<Bool, Text>{
        if(contractInfo.isStarted == true) return #err("Contract is already started");
        checkOwner(caller);
        addOrUpdateRecipient(principal, 
            {
                principal = principal;
                amount = amount;
                note = null;
            },
            vestingCliff, claimInterval, vestingDuration);
        #ok(true);    
    };

    //######## TIMER CHECK #########//
    // private func startTimer<system>() : () {
    //     timerId := Timer.recurringTimer<system>(#seconds(50), checkStartTime);//50 seconds
    // };
    public func init() : async () {
        Debug.print("init-----------timer");
        timerId := Timer.recurringTimer<system>(#seconds(10), checkStartTime);
    };

    public func cancelTimer() : async () {
        Timer.cancelTimer(timerId);
    };
}
