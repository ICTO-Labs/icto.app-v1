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
import Cycles "mo:base/ExperimentalCycles";
import Bool "mo:base/Bool";
import Result "mo:base/Result";
import Ledger "Ledger";
import Types "./types/Common";//Common
import ICRCLedger "../token_deployer/ICRCLedger";

shared ({ caller = creator }) actor class Contract({
    title: Text;
    description: Text;
    durationTime: Nat;
    durationUnit: Nat;
    cliffTime: Nat;
    cliffUnit: Nat;
    unlockSchedule: Nat;
    canCancel: Text;
    canChange: Text;
    canView: Text;
    startNow: Bool;
    startTime: Time.Time;
    created: Time.Time;
    tokenInfo: Types.TokenInfo;
    recipients: ?[Types.Recipient];
    owner: Principal;
    distributionType: Text;
    totalAmount: Nat;
    maxRecipients: Nat;
}) = this {
    //Define Types
    type DistributionType = {
        #Vesting;
        #FirstComeFirstServed;
    };

    type ContractInfo = {
        title: Text;
        description: Text;
        tokenInfo: Types.TokenInfo;
        lockDuration: Nat;
        unlockSchedule: Nat;
        startTime: Nat;
        isStarted: Bool;
        isPaused: Bool;
        isCanceled: Bool;
        owner: Principal;
        allowTransfer: Bool;
        created: Time.Time;
        distributionType: DistributionType;
    };

    type ContractData = ContractInfo and {
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
        lastClaimedTime: Nat;
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
        lastClaimedTime: Nat;
        vestingCliff: Nat;
        claimInterval: Nat;
        vestingDuration: Nat;
    };
    type ClaimRecord = {
        amount: Nat;
        txId: Nat;
        claimedAt: Nat;
    };
    let ICRC1 : Ledger.ICRC1 = actor(tokenInfo.canisterId);
    let E8S : Nat = 100_000_000;

    var contractInfo: ContractInfo = { 
        title = title;
        description = description;
        tokenInfo = tokenInfo;
        lockDuration = durationTime * durationUnit;
        unlockSchedule = unlockSchedule;
        startTime = 0;
        created = Time.now();
        isStarted = false; // Thay đổi thành false để phù hợp với logic startContract
        isPaused = false;
        isCanceled = false;
        owner = owner;
        allowTransfer = false;
        distributionType = if (distributionType == "FirstComeFirstServed") #FirstComeFirstServed else #Vesting;    
    };

    var recipientClaimInfo = HashMap.HashMap<Principal, RecipientClaimInfo>(0, Principal.equal, Principal.hash);
    var _totalAmount: Nat = 0;
    var totalClaimedAmount: Nat = 0;
    var totalRecipients: Nat = 0;
    var tokenPerRecipient: Nat = 0; // Cho chế độ FIFO
    // var maxRecipients: Nat = 0; // Cho chế độ FIFO

    //Convert Time.Now to seconds
    func timeNow(): Nat{
        Int.abs(Time.now()/1_000_000_000)
    };
    //Process recipients func
    private func processRecipients(): (){
        switch (recipients) {
            case (?recipientList) {
                for(recipient in recipientList.vals()) {
                    let _duration = durationTime*durationUnit;
                    let _recipient = {
                        recipient = {
                            principal = Principal.fromText(recipient.address);
                            amount = recipient.amount;
                            note = recipient.note;
                        };
                        principal = Principal.fromText(recipient.address);
                        vestingCliff = cliffTime*cliffUnit;
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

    //INIT PROCESSING #####################

    // Process recipients
    if (contractInfo.distributionType == #Vesting) {
        processRecipients();
    } else if (contractInfo.distributionType == #FirstComeFirstServed) {
        if (maxRecipients > 0) {
            tokenPerRecipient := totalAmount / maxRecipients;
        } else {
            ();//debug_show("Max recipients must be greater than 0 for FIFO mode");
            //assert(false);//, "Max recipients must be greater than 0 for FIFO mode");
        };
    };

    //END INIT PROCESSING #####################

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
            amount = amount-contractInfo.tokenInfo.fee;
            memo = null;
            from_subaccount = null;
            created_at_time = null;
        }));

        Result.iterate(transfer_result, func(tx_index: Nat){
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
        if(Time.now() >= startTime){
            let contractBalance = await getContractBalance();
            if (contractBalance < totalAmount) {
                return #err("Insufficient balance in contract to start distribution");
            };

            contractInfo := {
                contractInfo with
                startTime = timeNow();
                isStarted = true;
            };
            #ok(true)
        }else{
            #err("Time is not reached yet!");
        }
        
    };

    private func getContractBalance() : async Nat {
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
            totalAmount = if(contractInfo.distributionType == #Vesting) _totalAmount else totalAmount;
            maxRecipients = maxRecipients;
            tokenPerRecipient = tokenPerRecipient;
            totalClaimedAmount = totalClaimedAmount;
            totalRecipients = totalRecipients;
            cyclesBalance = Cycles.balance();
        };
    };

    // Get all recipients
    public query func getRecipients(): async [RecipientClaim] {
        let _arr = Buffer.Buffer<RecipientClaim>(0);
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
            _arr.add(_recipient);
        };
        _arr.toArray();
    };
    public query func getTimePeriod(): async Nat {
        timeNow()-contractInfo.startTime;
    };

    // Calculate the claimable amount
    func calculateClaimableAmount(principal: Principal, pickTime: Nat) : Nat {
        if (contractInfo.isStarted == false) {
            return 0;
        };
        var claimableAmount = 0;
        var currentTime = pickTime;
        switch (recipientClaimInfo.get(principal)) {
            case (?claimInfo) {
                let allocatedAmount = claimInfo.recipient.amount;
                let lastClaimedTime = if(claimInfo.lastClaimedTime == 0) contractInfo.startTime else claimInfo.lastClaimedTime;
                let vestingCliff = claimInfo.vestingCliff;
                let claimInterval = claimInfo.claimInterval;
                let vestingDuration = claimInfo.vestingDuration;

                if (currentTime >= lastClaimedTime + vestingCliff) {
                    let elapsedTime = currentTime - lastClaimedTime - vestingCliff;
                    let maxClaimableAmount = allocatedAmount - claimInfo.claimedAmount;

                    if(claimInterval == 0){
                        claimableAmount := maxClaimableAmount;
                    }else{
                        let numIntervals = elapsedTime / claimInterval;
                        if (numIntervals > 0) {
                            let amountPerInterval = allocatedAmount / (vestingDuration / claimInterval);
                            let claimableAmountInIntervals = numIntervals * amountPerInterval;
                            claimableAmount := Nat.min(claimableAmountInIntervals, maxClaimableAmount);
                        };
                    }
                    
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
        
        switch (contractInfo.distributionType) {
            case (#Vesting) {// Process for Vesting
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
                                    let newClaimedAmount = claimInfo.claimedAmount + claimableAmount;
                                    let newRemainingAmount = claimInfo.remainingAmount - claimableAmount;
                                    let newClaimHistory = Array.append<ClaimRecord>(
                                            claimInfo.claimHistory,
                                            [{
                                                amount = claimableAmount;
                                                claimedAt = pickTime;
                                                txId = txId;
                                            }]
                                        );
                                    //increase totalClaimedAmount
                                    totalClaimedAmount += claimableAmount;

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
                        return #err("You are not a recipient of this contract");
                    };
                };
            };
            case (#FirstComeFirstServed) {// Process for FIFO
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

    // Claim tokens
    private func claim_bk(): async Result.Result<Nat, Text>{
        let principal = msg.caller;
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
                            let newClaimedAmount = claimInfo.claimedAmount + claimableAmount;
                            let newRemainingAmount = claimInfo.remainingAmount - claimableAmount;
                            let newClaimHistory = Array.append<ClaimRecord>(
                                                claimInfo.claimHistory,
                                                [{
                                                    amount = claimableAmount;
                                                    claimedAt = pickTime;
                                                    txId = txId;
                                                }]
                                            );
                            //increase totalClaimedAmount
                            totalClaimedAmount += claimableAmount;

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
                    // let txId = transferResult;//TODO: Implement token transfer

                    // // Update claim info
                    // let newClaimedAmount = claimInfo.claimedAmount + claimableAmount;
                    // let newRemainingAmount = claimInfo.remainingAmount - claimableAmount;
                    // let newClaimHistory = Array.append<ClaimRecord>(
                    //                     claimInfo.claimHistory,
                    //                     [{
                    //                         amount = claimableAmount;
                    //                         claimedAt = pickTime;
                    //                         txId = txId;
                    //                     }]
                    //                 );
                    // //increase totalClaimedAmount
                    // totalClaimedAmount += claimableAmount;

                    // //Update recipientClaimInfo
                    // recipientClaimInfo.put(principal, {
                    //     claimInfo with
                    //     claimedAmount = newClaimedAmount;
                    //     remainingAmount = newRemainingAmount;
                    //     lastClaimedTime = pickTime; // update lastClaimedTime to pickTime
                    //     claimHistory = newClaimHistory;
                    // });
                    // return #ok(claimableAmount);
                }else{
                    return #err("No claimable amount");
                }
            };
            case (_) {
                return #err("You are not a recipient of this contract");
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
    }
}