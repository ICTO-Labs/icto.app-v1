import Buffer "mo:base/Buffer";
import Result "mo:base/Result";
import Text "mo:base/Text";
import Bool "mo:base/Bool";
import Nat "mo:base/Nat";
import HashMap "mo:base/HashMap";
import Array "mo:base/Array";
import Iter "mo:base/Iter";
import Option "mo:base/Option";
import Time "mo:base/Time";
import Principal "mo:base/Principal";
import Error "mo:base/Error";
import ICRCLedger "../token_deployer/ICRCLedger";
import Cycles "mo:base/ExperimentalCycles";

import Types "./Types";
shared ({ caller = deployer }) actor class LaunchpadCanister() = this {

    private let defaultTokenInfo : Types.TokenInfo = {
        name = "Internet Computer";
        symbol = "ICP";
        decimals = 8;
        metadata = null;
        logo = "";
        transferFee = 10_000;
        canisterId = "ryjl3-tyaaa-aaaaa-aaaba-cai";
    };
    var SECOND_TO_NANO = 1_000_000_000;//Conver second (s) to nano second rate
    var TIME_DIFF = 1_000_000;//Convert from momen().unix() => Minisecond (JS) to Nanosecond (Motoko)
    var E8S = 100_000_000;
    private var PurchaseLedger : ICRCLedger.Self = actor("ryjl3-tyaaa-aaaaa-aaaba-cai");//For fee payment - Default: ICP Token
    private stable var _admins : [Text] = ["lekqg-fvb6g-4kubt-oqgzu-rd5r7-muoce-kppfz-aaem3-abfaj-cxq7a-dqe"];
    private stable var TOTAL_AMOUNT_COMMITED : Nat = 0;//Total commit amount
    private stable var installed : Bool = false;
    private stable var LAUNCH_STATUS : Text = "UPCOMING";
    private stable var launchpadDetail : ?Types.LaunchpadDetail = null;
    private var tokenInfo : Types.TokenInfo = defaultTokenInfo;
    // private let participants : Buffer.Buffer<Types.Participant> = Buffer.Buffer<Types.Participant>(0);

    private stable var _participants : [(Text, Types.Participant)] = []; //Store Participant Info
    private var participants         : HashMap.HashMap<Text, Types.Participant> = HashMap.fromIter(_participants.vals(), 0, Text.equal, Text.hash);

    private stable var AFFILIATE_PERCENTAGE = 3;
    private stable var SOFTCAP = 0;
    private stable var HARDCAP = 0;
    private var totalAffiliateVolume : Nat = 0;
    private var refererTransaction : Nat = 0;//Total affiliate transaction
    private var affiliateStats = HashMap.HashMap<Text, Types.AffiliateStats>(10, Text.equal, Text.hash);

    // private let participants : Buffer.Buffer<Types.Participant> = Buffer.Buffer<Types.Participant>(0);
    private let transactions : Buffer.Buffer<Types.Transaction> = Buffer.Buffer<Types.Transaction>(0);
    private let refunds : Buffer.Buffer<Types.Transaction> = Buffer.Buffer<Types.Transaction>(0);
    private stable var owner : ?Principal = null;
    private stable var whitelist : [Text] = [];
    private stable var managerAddress : Text = "";

    //Callback to notify the deployer
    let Deployer = actor(Principal.toText(deployer)) : actor{
        callback: shared (Text, Text) -> async ();
    };
    public shared (msg) func install(_info : Types.LaunchpadDetail, _whitelist: [Text]) : async Result.Result<Bool, Text> {
        if(installed){
            return #err("ALREADY_INSTALLED");
        };
        managerAddress := Principal.toText(deployer);
        whitelist := _whitelist;
        owner := ?msg.caller;
        launchpadDetail := ?_info;
        installed := true;
        SOFTCAP := _info.launchParams.softCap;
        HARDCAP := _info.launchParams.hardCap;
        AFFILIATE_PERCENTAGE := _info.affiliate;
        //Setting ledger for fee payment
            PurchaseLedger := actor(_info.purchaseToken.canisterId);
        return #ok(installed);
    };

    public shared (msg) func commit(amount : Nat, refCode: ?Text) : async Result.Result<Bool, Text> {
        if(not installed){
            return #err("LAUNCHPAD_NOT_INSTALLED");
        };
        let participantId : Principal = msg.caller;
        let participantTxt : Text = Principal.toText(participantId);
        if (isInWhitelist(participantTxt)) {
            // investors can participate the launchpad in the range of specified date
            let now : Time.Time = Time.now();
            let launchpad = await getLaunchpadDetail();
            if(now < launchpad.timeline.startTime) return #err("This pool is not started yet!");
            if (launchpad.timeline.startTime <= now and now < launchpad.timeline.endTime) {
                var launchpadId = Principal.fromActor(this);
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

                //Transfer token from investor to launchpad
                var _txId :Nat = 0;
                if (not _isAdmin(participantTxt)) switch (await PurchaseLedger.icrc2_transfer_from({ from = { owner = participantId; subaccount = null }; spender_subaccount = null; to = { owner = launchpadId; subaccount = null }; fee = null; memo = null; from_subaccount = null; created_at_time = null; amount = amount })) {
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

    public shared (msg) func getParticipantInfo(participant : Text) : async Types.Participant {
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
    public shared (msg) func getTransactionList() : async [Types.Transaction] {
        return Buffer.toArray(transactions);
    };
    public shared (msg) func getRefundList() : async [Types.Transaction] {
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
            cycle = Cycles.balance();
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
            LAUNCH_STATUS := "CLAIMING"; 
        }else{
            LAUNCH_STATUS := "CLOSED";
        };
        return LAUNCH_STATUS;
    };
    public shared (msg) func reinstall() : async () {
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
    public shared (msg) func launchpadInfo() : async Types.LaunchpadDetail {
        await getLaunchpadDetail();//launchpadDetail;
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

    private func getTokenInfo(_tokenInfo: ?Types.TokenInfo): async Types.TokenInfo {
        return switch (_tokenInfo) {
            case (?_tokenInfo) {
                return _tokenInfo;
            };
            case (_) {
                return defaultTokenInfo;
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
        for (i in _admins.vals()) {
            if (i == p) {
                return true;
            };
        };
        return false;
    };
}