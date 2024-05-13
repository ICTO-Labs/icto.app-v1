// import Contract "../contract/Contract";
import Principal "mo:base/Principal";
import Array "mo:base/Array";
import HashMap "mo:base/HashMap";
import Buffer "mo:base/Buffer";
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

actor {
    stable var currentValue: Nat = 0;
    stable var CONTRACT_VERSION: Text = "0.1.1";
    stable var INIT_CONTRACT_CYCLES: Nat = 300_000_000_000;
    let ic: IC.Self = actor "aaaaa-aa";
    private stable var _admins : [Text] = ["lekqg-fvb6g-4kubt-oqgzu-rd5r7-muoce-kppfz-aaem3-abfaj-cxq7a-dqe"];
    private stable var _contracts : [Text] = [];
    private stable var INDEXING_CANISTER : Text = "avqkn-guaaa-aaaaa-qaaea-cai";
    
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
    public shared (msg) func createContract(contract: ContractTypes.ContractData): async Text{
        assert not Principal.isAnonymous(msg.caller);
        let _controllers = [msg.caller];
        Cycles.add(INIT_CONTRACT_CYCLES);

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
        for(recipient in contract.recipients.vals()) {
            await mapCanister(recipient.address, _contractId);
        };

        _contractId;
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
