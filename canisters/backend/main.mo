// import Contract "../contract/Contract";
import Principal "mo:base/Principal";
import Array "mo:base/Array";
import HashMap "mo:base/HashMap";
import Buffer "mo:base/Buffer";
import Option "mo:base/Option";
import Cycles "mo:base/ExperimentalCycles";
import Time "mo:base/Time";
import Int "mo:base/Int";
import Timer "mo:base/Timer";
import Text "mo:base/Text";
import IC "./IC";
import Types "./Types";
import Actor "./Actor";
import ContractTypes "../contract/types/Common";//Common
import Trie "mo:base/Trie";
import TokenClaim "../contract/TokenClaim";
import Debug "mo:base/Debug";
import Result "mo:base/Result";
import ICRCLedger "../token_deployer/ICRCLedger";

actor {
    stable var currentValue: Nat = 0;
    stable var CONTRACT_VERSION: Text = "0.1.1";
    stable var CYCLES_FOR_INSTALL: Nat = 300_000_000_000;
    private stable var MIN_CYCLES_IN_DEPLOYER: Nat = 2_000_000_000_000;//Minimum cycles in deployer
    let ic: IC.Self = actor "aaaaa-aa";
    private stable var _admins : [Text] = ["lekqg-fvb6g-4kubt-oqgzu-rd5r7-muoce-kppfz-aaem3-abfaj-cxq7a-dqe"];
    private stable var _contracts : [Text] = [];
    private stable var INDEXING_CANISTER : Text = "avqkn-guaaa-aaaaa-qaaea-cai";
    private let icrcLedger : ICRCLedger.Self = actor ("ryjl3-tyaaa-aaaaa-aaaba-cai");//For ICRC transfer

    private func createICRC1Actor(id : Text) : async ICRCLedger.Self {
        actor(id);
    };
    private func mapCanister(user: Text, canister_id: Text): async (){
        let INDEXING = actor(INDEXING_CANISTER) : actor {
            addUserContract : shared (Text, Text) -> async ();
        };
        await INDEXING.addUserContract(user, canister_id);
    };

    private func _isAdmin(p : Text) : (Bool) {
        for (i in _admins.vals()) {
            if (i == p) {
                return true;
            };
        };
        return false;
    };


    private func keyT(x : Text) : Trie.Key<Text> {
        return { hash = Text.hash(x); key = x };
    };
    private func key(x : Nat32) : Trie.Key<Nat32> {
        return { hash = x; key = x };
    };
    
    //Generate time now to second
    func timeNow(): Nat{
        Int.abs(Time.now()/1_000_000_000)
    };
    public shared (msg) func whoami() : async Principal {
        msg.caller
    };
    private func transferFrom(canisterId: Text, payload: Actor.TransferFromArg) : async Actor.TransferFromResult {
        let ICRC : Actor.ICRC = actor(canisterId);
        await ICRC.icrc2_transfer_from(payload)
    };
    public func canister_status(canister_id: IC.canister_id): async Types.CanisterStatus{
        await ic.canister_status({canister_id = canister_id})
    };
    public shared({ caller }) func addController(canister_id: IC.canister_id, controllers: [Principal]): async () {
        assert (_isAdmin(Principal.toText(caller)));
        await ic.update_settings({
            canister_id = canister_id;
            settings = {
                controllers = ?controllers;
                compute_allocation = ?0;
                memory_allocation = ?0;
                freezing_threshold = ?2592000;
            }
        });
    };
    public shared (msg) func createContract(contract: ContractTypes.ContractData): async Result.Result<Principal, Text>{
        assert not Principal.isAnonymous(msg.caller);
        if (not _isAdmin(Principal.toText(msg.caller))){//Only admin can create contract
            return #err("Sorry, only admin can create contract in testing phase!");
        };
        let _controllers = [msg.caller];
        let _cycleBalance = Cycles.balance();
        if (_cycleBalance < CYCLES_FOR_INSTALL + MIN_CYCLES_IN_DEPLOYER) return #err("Not enough cycles in deployer, balance: "# debug_show(_cycleBalance) #"T");
        Cycles.add(CYCLES_FOR_INSTALL);

        //must add VERSION to contract data
        let newContractId = await TokenClaim.Contract(contract);
        let newContractPrincipal = Principal.fromActor(newContractId);
        //Update settings;
        // await CA.updateCanisterSettings({
        // canisterId = newContractPrincipal;
        // settings = {
        //     controllers = controllers;
        //     compute_allocation = ?0;
        //     memory_allocation = ?0;
        //     freezing_threshold = ?2592000;
        // }
        // });

        let _contractId = Principal.toText(newContractPrincipal);
        addContract(_contractId);//Add to contract list
        //Map created contract
        let _recipients = Option.get(contract.recipients, []);
        if(_recipients.size() > 0){
            for(recipient in _recipients.vals()) {
                await mapCanister(recipient.address, _contractId);
            };
        };

        //Transfer token to new contract, skipp admin for testing purpose
        if (not _isAdmin(Principal.toText(msg.caller))){
            let _tokenActor = await createICRC1Actor(contract.tokenInfo.canisterId);
            switch (await _tokenActor.icrc2_transfer_from({ from = { owner = msg.caller; subaccount = null }; spender_subaccount = null; to = { owner = newContractPrincipal; subaccount = null }; fee = null; memo = null; from_subaccount = null; created_at_time = null; amount = contract.totalAmount })) {
            case (#Ok(_)) ();
            case (#Err(e)) return #err("Payment error: " # debug_show(e));
            };
        };

        #ok(newContractPrincipal);
    };

    public shared({ caller }) func cancelContract(canister_id: Principal) : async (){
        assert (_isAdmin(Principal.toText(caller)));
        await ic.stop_canister({ canister_id = canister_id });
        await ic.delete_canister({ canister_id = canister_id });
    };
    
    public shared({ caller }) func addAdmin(p : Text) : async () {
        assert (_isAdmin(Principal.toText(caller)));
        var b : Buffer.Buffer<Text> = Buffer.Buffer<Text>(0);
        for (i in _admins.vals()) {
            if (p != i) {
                b.add(i);
            };
        };
        b.add(p);
        _admins := Buffer.toArray(b);
    };
    private func addContract(p : Text) : () {
        var b : Buffer.Buffer<Text> = Buffer.Buffer<Text>(0);
        b.add(p);
        _contracts := Buffer.toArray(b);
    };

    public shared({ caller }) func removeAdmin(p : Text) : async () {
        assert (_isAdmin(Principal.toText(caller)));
        var b : Buffer.Buffer<Text> = Buffer.Buffer<Text>(0);
        for (i in _admins.vals()) {
            if (p != i) {
                b.add(i);
            };
        };
        _admins := Buffer.toArray(b);
    };

    public query func getAdmins() : async ([Text]) {
        return _admins;
    };

    //Update Indexing canister
    public shared ({ caller }) func updateIndexingCanister(i : Text) : async () {
        assert (_isAdmin(Principal.toText(caller)));
        INDEXING_CANISTER := i;
    };

};
