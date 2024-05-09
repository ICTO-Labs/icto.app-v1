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

shared ({ caller }) actor class () = self {
    //Convert Time.Now to seconds
    func timeNow(): Nat{
        Int.abs(Time.now()/1_000_000_000)
    };
    // Contract info
    type ContractInfo = {
        title: Text;
        description: Text;
        tokenId: Principal;
        lockDuration: Nat;
        unlockSchedule: [(Nat, Nat)];
        startTime: Nat;
        isStarted: Bool;
        isPaused: Bool;
        isCanceled: Bool;
        owner: Principal;
        allowTransfer: Bool;
    };
    type ContractData = {
        title: Text;
        description: Text;
        tokenId: Principal;
        lockDuration: Nat;
        unlockSchedule: [(Nat, Nat)];
        startTime: Nat;
        isStarted: Bool;
        totalAmount: Nat;
        totalClaimedAmount: Nat;
        cyclesBalance: Nat;
        isPaused: Bool;
        isCanceled: Bool;
        owner: Principal;
        allowTransfer: Bool;
    };

    type Recipient = {
        principal: Principal;
        amount: Nat;
        note: Text;
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
        claimedAt: Nat; // Claimed time (seconds)
    };
    // Contract init
    var contractInfo: ContractInfo = { 
        title = "Vesting Contract";
        description = "This contract allows you to lock tokens for a period of time or release them according to a vesting schedule.";
        tokenId = Principal.fromText("aaaaa-aa");
        lockDuration = 0;
        unlockSchedule = [];
        startTime = timeNow();
        isStarted = false;
        isPaused = false;
        isCanceled = false;
        owner = caller;
        allowTransfer = false;
    };

    // Saving the recipient data (claim info, histories)
    var recipientClaimInfo = HashMap.HashMap<Principal, RecipientClaimInfo>(0, Principal.equal, Principal.hash);
    var totalAmount: Nat = 0;
    var totalClaimedAmount: Nat = 0;

    private func checkOwner(caller: Principal) {
        assert(Principal.equal(contractInfo.owner, caller));
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

    // Update recipient info
    private func addOrUpdateRecipient(principal: Principal, recipient: Recipient, vestingCliff: Nat, claimInterval: Nat, vestingDuration: Nat) {
        assert(contractInfo.isStarted == false);
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
            cyclesBalance = Cycles.balance();
        };
    };

    // Get all recipients
    public query func getRecipients(): async [RecipientClaim] {
        let _arr = Buffer.Buffer<RecipientClaim>(0);
        for ((history) in recipientClaimInfo.entries()) {
            _arr.add(history.1);
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
                    let numIntervals = elapsedTime / claimInterval;
                    let maxClaimableAmount = allocatedAmount - claimInfo.claimedAmount;

                    if (numIntervals > 0) {
                        let amountPerInterval = allocatedAmount / (vestingDuration / claimInterval);
                        let claimableAmountInIntervals = numIntervals * amountPerInterval;
                        claimableAmount := Nat.min(claimableAmountInIntervals, maxClaimableAmount);
                    };
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

                    // Update claim info
                    let newClaimedAmount = claimInfo.claimedAmount + claimableAmount;
                    let newRemainingAmount = claimInfo.remainingAmount - claimableAmount;
                    let newClaimHistory = Array.append<ClaimRecord>(
                                        claimInfo.claimHistory,
                                        [{
                                            amount = claimableAmount;
                                            claimedAt = pickTime;
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
                note = "";
            },
            vestingCliff, claimInterval, vestingDuration);
        #ok(true);    
    }
}