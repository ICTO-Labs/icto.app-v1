import A "mo:base/AssocList";
import Array "mo:base/Array";
import Blob "mo:base/Blob";
import Bool "mo:base/Bool";
import Buffer "mo:base/Buffer";
import Cycles "mo:base/ExperimentalCycles";
import Error "mo:base/Error";
import Char "mo:base/Char";
import Hash "mo:base/Hash";
import HashMap "mo:base/HashMap";
import Int "mo:base/Int";
import Int16 "mo:base/Int16";
import Int8 "mo:base/Int8";
import Iter "mo:base/Iter";
import List "mo:base/List";
import Nat "mo:base/Nat";
import Nat8 "mo:base/Nat8";
import Nat32 "mo:base/Nat32";
import Nat64 "mo:base/Nat64";
import Option "mo:base/Option";
import Prelude "mo:base/Prelude";
import Principal "mo:base/Principal";
import Result "mo:base/Result";
import Text "mo:base/Text";
import Time "mo:base/Time";
import Trie "mo:base/Trie";
import Debug "mo:base/Debug";
import Trie2D "mo:base/Trie";
import IC "../utils/IC";
import LaunchpadContract "./Contract";
import Types "./types/Common";

// shared ({ caller = deployer }) actor Deployer {
shared ({ caller }) actor class () = self {
    //Stable Memory
    private func deployer() : Principal = caller;
    private stable var _contracts : Trie.Trie<Text, Types.LaunchpadDetail> = Trie.empty(); //mapping of token_canister_id -> Token details
    private stable var _owners : Trie.Trie<Text, Text> = Trie.empty(); //mapping  token_canister_id -> owner principal id
    private stable var _admins : [Text] = [Principal.toText(caller)];
    private stable var CYCLES_FOR_INSTALL: Nat = 300_000_000_000;//1T 1_000_000_000_000, 0.3T
    private stable var MIN_CYCLES_IN_DEPLOYER: Nat = 3_000_000_000_000;//3T
    private stable var CURRENT_LOCK_VERSION = "1.0.0";

    //IC Management Canister
    let ic: IC.Self = actor "aaaaa-aa";

    //Utility Functions
    private func key(x : Nat32) : Trie.Key<Nat32> {
        return { hash = x; key = x };
    };

    private func keyT(x : Text) : Trie.Key<Text> {
        return { hash = Text.hash(x); key = x };
    };

    private func textToNat(txt : Text) : Nat {
        assert (txt.size() > 0);
        let chars = txt.chars();

        var num : Nat = 0;
        for (v in chars) {
            let charToNum = Nat32.toNat(Char.toNat32(v) -48);
            assert (charToNum >= 0 and charToNum <= 9);
            num := num * 10 + charToNum;
        };

        return num;
    };

    public query func cycleBalance() : async Nat {
        Cycles.balance();
    };

    private func _isAdmin(p : Text) : (Bool) {
        for (i in _admins.vals()) {
            if (i == p) {
                return true;
            };
        };
        return false;
    };

    //Update Initial cycles for new token canister
    public shared ({ caller }) func updateInitCycles(i : Nat) : async () {
        assert (_isAdmin(Principal.toText(caller)));
        CYCLES_FOR_INSTALL := i;
    };
    public shared ({ caller }) func updateMinDeployerCycles(i : Nat) : async () {
        assert (_isAdmin(Principal.toText(caller)));
        MIN_CYCLES_IN_DEPLOYER := i;
    };
    public shared ({ caller }) func addAdmin(p : Text) : async () {
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

    public shared ({ caller }) func removeAdmin(p : Text) : async () {
        assert (_isAdmin(Principal.toText(caller)));
        var b : Buffer.Buffer<Text> = Buffer.Buffer<Text>(0);
        for (i in _admins.vals()) {
            if (p != i) {
                b.add(i);
            };
        };
        _admins := Buffer.toArray(b);
    };

    public query func getAllAdmins() : async ([Text]) {
        return _admins;
    };

    //Internal Functions
    //
    private func _isOwner(p : Principal, canister_id : Text) : async (Bool) {
        for ((i, v) in Trie.iter(_owners)) {
            if (canister_id == i and p == Principal.fromText(v)) {
                return true;
            };
        };
        return false;
    };


    private func blackhole_canister(a : actor {}) : async () {
        let cid = { canister_id = Principal.fromActor(a) };
        await (
            ic.update_settings({
                canister_id = cid.canister_id;
                settings = {
                    controllers = ?[];
                    compute_allocation = null;
                    memory_allocation = null;
                    freezing_threshold = ?31_540_000;
                };
            })
        );
    };

    //Queries
    //
    public query func getOwner(canister_id : Text) : async (?Text) {
        var owner : ?Text = Trie.find(_owners, keyT(canister_id), Text.equal);
        return owner;
    };

    public query func getUserTotalTokens(uid : Text) : async (Nat) {
        var size = 0;
        for ((i, v) in Trie.iter(_owners)) {
            if (v == uid) {
                size := size + 1;
            };
        };
        return size;
    };


    //Remote check transaction from created contract.
    private func checkTransaction(contractId: Principal): async Result.Result<Bool, Text>{
        let SmartContract = actor(Principal.toText(contractId)) : actor {
            verify : shared () -> async { #ok : Bool; #err : Text };
        };
        await SmartContract.verify();
    };


    //Add to beta test - remove unused canister
    public shared ({caller}) func cancelContract(canister_id: Principal) : async (){
        assert (_isAdmin(Principal.toText(caller)));
        _contracts := Trie.remove(_contracts, keyT(Principal.toText(canister_id)), Text.equal).0;
        await ic.stop_canister({ canister_id = canister_id });
        await ic.delete_canister({ canister_id = canister_id });
    };
};
