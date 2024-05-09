//Mapping User Principal to ClaimInfo Contract
import HashMap "mo:base/HashMap";
import Hash "mo:base/Hash";
import Iter "mo:base/Iter";
import Text "mo:base/Text";
import Principal "mo:base/Principal";
import Array "mo:base/Array";
import Prim "mo:prim";
import Buffer "mo:base/Buffer";
import Trie "mo:base/Trie";
import Cycles "mo:base/ExperimentalCycles";

shared ({ caller }) actor class () = self {

    private stable var _admins : [Text] = [Principal.toText(caller)];
    // private stable var _userContracts : [(Text, Buffer.Buffer<Text>)] = [];
    // private let userContracts: HashMap.HashMap<Text, Buffer.Buffer<Text>> =  HashMap.fromIter<Text, Buffer.Buffer<Text>>(_userContracts.vals(), 0, Text.equal, Text.hash);
    private var _userContracts : [(Text, Buffer.Buffer<Text>)] = [];
    private let userContracts: HashMap.HashMap<Text, Buffer.Buffer<Text>> =  HashMap.fromIter<Text, Buffer.Buffer<Text>>(_userContracts.vals(), 0, Text.equal, Text.hash);

    // upgrade functions
    system func preupgrade() {
        _userContracts  := Iter.toArray(userContracts.entries());
    };

    system func postupgrade() {
        _userContracts  := [];
    };
    //End of upgrade functions

    private func _addUserContract(principalId: Text, contractId: Text): () {
        var buffer = _getUserContractsByPrincipal(principalId);
        if(Buffer.contains<Text>(buffer, contractId, Text.equal) == false){
            buffer.add(contractId);
        };
        userContracts.put(principalId, buffer);

    };

    private func _removeUserContract(principalId : Text, contractId : Text) {
        var buffer = _getUserContractsByPrincipal(principalId);
        buffer.filterEntries(func(_, entry) {
            return entry != contractId; 
        });
        userContracts.put(principalId, buffer);
    };

    private func _getUserContractsByPrincipal(principalId: Text): Buffer.Buffer<Text> {
        switch (userContracts.get(principalId)) {
            case (?contracts) {
                return contracts;
            };
            case (_) {
                return Buffer.Buffer<Text>(0);
            };
        };
    };

    private func _isAdmin(p : Text) : (Bool) {
        for (i in _admins.vals()) {
            if (i == p) {
                return true;
            };
        };
        return false;
    };
    
    public query func getUserContracts(principalId: Text): async [Text] {
        let _ucontracts = _getUserContractsByPrincipal(principalId);
        Buffer.toArray(_ucontracts);
    };

    public shared func getContracts(_page : Nat) : async () {
        
    };

    public query func cycleBalance() : async Nat {
        Cycles.balance();
    };

    public shared({ caller }) func addUserContract(user: Text, contractId: Text) : async () {
        assert(_isAdmin(Principal.toText(caller)));
        _addUserContract(user, contractId);
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

    public query func getAllAdmins() : async ([Text]) {
        return _admins;
    };
}