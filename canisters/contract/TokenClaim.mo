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
    totalAmount: Nat;//Token will be sent (sum of recipents's amount)
    unlockedAmount: Nat;//unlockedAmount
    recipients: [Types.Recipient];
    owner: Principal;//Contract owner
}) = this {

// shared ({ caller }) actor class () = self {

    let ICRC1 : Ledger.ICRC1 = actor(tokenInfo.canisterId);

    // Saving the recipient data (claim info, histories)
    var recipientClaimInfo = HashMap.HashMap<Principal, RecipientClaimInfo>(0, Principal.equal, Principal.hash);
    var totalAmount: Nat = 0;
    var totalClaimedAmount: Nat = 0;
    var totalRecipients: Nat = 0;
    var E8S = 100_000_000;

    //Convert Time.Now to seconds
    func timeNow(): Nat{
        Int.abs(Time.now()/1_000_000_000)
    };

    // Contract info
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
    };
    type ContractData = {
        title: Text;
        description: Text;
        tokenInfo: Types.TokenInfo;
        lockDuration: Nat;
        unlockSchedule: Nat;
        startTime: Nat;
        isStarted: Bool;
        totalAmount: Nat;
        totalRecipients: Nat;
        totalClaimedAmount: Nat;
        cyclesBalance: Nat;
        isPaused: Bool;
        isCanceled: Bool;
        owner: Principal;
        allowTransfer: Bool;
        created: Time.Time;
    };

    type Recipient = {
        principal: Principal;
        amount: Nat;
        note: ?Text;
    };

    type VestingSchedule = {
        cliff: Nat;
        claimInterval: Nat;
        vestingDuration: Nat;
        recipients: [Recipient];
    };

    // Recipient and Claim info
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
        txId: Nat; // Transaction ID
        claimedAt: Nat; // Claimed time (seconds)
    };
    // Contract init
    var contractInfo: ContractInfo = { 
        title = title;
        description = description;
        tokenInfo = tokenInfo;
        lockDuration = durationTime*durationUnit;
        unlockSchedule = unlockSchedule;
        startTime = timeNow();
        created = timeNow();
        isStarted = true;
        isPaused = false;
        isCanceled = false;
        owner = owner;
        allowTransfer = false;
    };


    private func checkOwner(caller: Principal) {
        assert(Principal.equal(contractInfo.owner, caller));
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
                totalAmount += recipient.amount;
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
    
    private func processRecipent(): (){
        for(recipient in recipients.vals()) {
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

    processRecipent();//Init process recipients

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
    public shared(msg) func startContract(): async Result.Result<Bool, Text>{
        if(contractInfo.isStarted == true) return #err("Contract is already started");
        checkOwner(msg.caller);
        contractInfo := {
            contractInfo with
            startTime = timeNow();
            isStarted = true; // Mark contract is started
        };
        #ok(true);
    };
    // // Get contract info
    // public query func getContractInfo(): async ContractInfo {
    //     return contractInfo;
    // };
    // Get contract data with totalAmount and totalClaimedAmount
    public query func getContractInfo(): async ContractData {
        { 
            contractInfo with
            totalAmount = totalAmount;
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

    // Claim tokens
    public shared(msg) func claim(): async Result.Result<Nat, Text>{
        let principal = msg.caller;
        switch (recipientClaimInfo.get(principal)) {
            case (?claimInfo) {
                var pickTime = timeNow();
                let claimableAmount: Nat = calculateClaimableAmount(principal, pickTime);
                if (claimableAmount > 0) {
                    //Transfer Token
                    let txId = 1;//TODO: Implement token transfer

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