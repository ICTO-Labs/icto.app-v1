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
import IC "../backend/IC";
import TokenLock "contracts/TokenLock";
import Types "./Types";

// shared ({ caller = deployer }) actor Deployer {
shared ({ caller }) actor class () = self {
    //Stable Memory
    private func deployer() : Principal = caller;
    private stable var _contracts : Trie.Trie<Text, Types.LockContract> = Trie.empty(); //mapping of token_canister_id -> Token details
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
    //Create canister with contract
    private func create_canister(owner: Principal, contract: Types.LockContractInit) : async (Text) {
        try{
            Cycles.add(CYCLES_FOR_INSTALL);
            let _contract = {
                contract with
                positionOwner = owner;
                created = Time.now();
                lockedTime = null;
                unlockedTime = null;
                withdrawnTime = null;
                contractId = null;
                version = CURRENT_LOCK_VERSION;
                status = "created";
            };
            let contractId = await TokenLock.Contract(_contract);
            let canister_id = Principal.fromActor(contractId);
            // ignore blackhole_canister(contractId);//Remove controller of canister - available in Mainnet
            Principal.toText(canister_id);
        } catch (e) {
            return Debug.trap("Canister creation failed " # debug_show Error.message(e));
        };
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

    func genObject(obj: Types.LockContract, status: Text): Types.LockContract{
        switch(status){
            case ("locked"){
                return {
                    obj with
                    lockedTime = ?Time.now();
                    status = status;
                };
            };
            case ("unlocked"){
                return {
                    obj with
                    unlockedTime = ?Time.now();
                    status = status;
                };
            };
            case ("withdrawn"){
                return {
                    obj with
                    withdrawnTime = ?Time.now();
                    status = status;
                };
            };
            case _ {
                return obj;
            };
        }
    };
    private func updateStatus(canister_id: Text, status: Text): async (){
        let contract = await getContract(canister_id);
        switch (contract) {
            case (?c) {
                var _contract = genObject(c, status);
                if(status == "increase"){
                    let _remoteContract = await getRemoteContract(canister_id);
                    _contract := {
                        c with
                        status = _remoteContract.status;
                        unlockedTime = null;
                        durationTime = _remoteContract.durationTime;
                        durationUnit = _remoteContract.durationUnit;
                    };
                };
                
                _contracts := Trie.put(
                    _contracts,
                    keyT(canister_id),
                    Text.equal,
                    _contract,
                ).0;
            };
            case _ {};
        };
    };
    public shared ({ caller }) func updateContractStatus(canister_id : Text, status :  Text) : async () {
        //Check if caller is sub canister (callback) or admin
        assert(Principal.equal(caller, Principal.fromText(canister_id)) or _isAdmin(Principal.toText(caller)));
        await updateStatus(canister_id, status);
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

 public query func getUserContracts(uid : Text, _page : Nat) : async ([Types.LockContract]) {
        var lower : Nat = _page * 9;
        var upper : Nat = lower + 9;
        var b : Buffer.Buffer<Types.LockContract> = Buffer.Buffer<Types.LockContract>(0);
        for ((i, v) in Trie.iter(_owners)) {
            if (v == uid) {
                switch (Trie.find(_contracts, keyT(i), Text.equal)) {
                    case (?t) {
                        b.add(t);
                    };
                    case _ {};
                };
            };
        };
        let arr = Buffer.toArray(b);
        b := Buffer.Buffer<Types.LockContract>(0);
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

    public query func getContracts(_page : Nat) : async ([Types.LockContract]) {
        var lower : Nat = _page * 9;
        var upper : Nat = lower + 9;
        var b : Buffer.Buffer<Types.LockContract> = Buffer.Buffer<Types.LockContract>(0);
        for ((i, v) in Trie.iter(_owners)) {
            switch (Trie.find(_contracts, keyT(i), Text.equal)) {
                case (?t) {
                    b.add(t);
                };
                case _ {};
            };
        };
        let arr = Buffer.toArray(b);
        b := Buffer.Buffer<Types.LockContract>(0);
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

    public query func getTotalContract() : async (Nat) {
        return Trie.size(_contracts);
    };

    //Create Contract Canister
    //
    public shared (msg) func createContract(contract : Types.LockContractInit) : async Result.Result<Text, Text> {
        assert not Principal.isAnonymous(msg.caller);//reject anonymous
        let _balance = Cycles.balance();
        if (_balance < CYCLES_FOR_INSTALL + MIN_CYCLES_IN_DEPLOYER) return #err("Not enough cycles in deployer");

        var canister_id : Text = await create_canister(msg.caller, contract);
        let _contract = {
            contract with
            contractId = ?canister_id;
            positionOwner = msg.caller;
            created = Time.now();
            lockedTime = null;
            unlockedTime = null;
            withdrawnTime = null;
            version = CURRENT_LOCK_VERSION;
            status = "created";
        };
        _contracts := Trie.put(
            _contracts,
            keyT(canister_id),
            Text.equal,
            _contract,
        ).0;
        _owners := Trie.put(_owners, keyT(canister_id), Text.equal, Principal.toText(msg.caller)).0;
        //Transfer position to contract
        let _transfered = await transferPosition(contract.poolId, msg.caller, Principal.fromText(canister_id), contract.positionId);
        if(_transfered == false){
            return #err("Failed to transfer position. You can manually transfer position to the contract canister: " # canister_id);
        };
        ignore await checkTransaction(Principal.fromText(canister_id));//Trigger check balance from smartcontract
        return #ok(canister_id);
    };

    //Transfer from
    private func transferPosition(poolId: Text, from: Principal, to: Principal, positionId: Nat) : async Bool{
        let POOL = actor(poolId) : actor {
            transferPosition : shared (Principal, Principal, Nat) -> async { #ok : Bool; #err : Types.PoolError };
        };
        switch(await POOL.transferPosition(from, to, positionId)){
            case (#ok(true)){
                return true;
            };
            case (#ok(false)){
                return false;
            };
            case (#err(err)){
                return false;
            }
        };
    };

    //Remote check transaction from created contract.
    private func checkTransaction(contractId: Principal): async Result.Result<Bool, Text>{
        let SmartContract = actor(Principal.toText(contractId)) : actor {
            verify : shared () -> async { #ok : Bool; #err : Text };
        };
        await SmartContract.verify();
    };
    //Getting remote contract data
    private func getRemoteContract(canister_id: Text) : async Types.LockContract {
        let SmartContract = actor(canister_id) : actor {
            getContract : query () -> async Types.LockContract;
        };
        return await SmartContract.getContract();
    };

    private func isOwnerOfPosition(poolId: Text, owner: Principal, positionId: Nat) : async Bool {
        let POOL = actor(poolId) : actor {
            checkOwnerOfUserPosition: shared query (Principal, Nat) -> async { #ok : Bool; #err : Types.PoolError };
        };
        switch(await POOL.checkOwnerOfUserPosition(owner, positionId)){
            case (#ok(true)){
                return true;
            };
            case (#ok(false)){
                return false;
            };
            case (#err(err)){
                return false;
            }
        };
    };

    //Queries
    public query func getContract(canister_id : Text) : async (?Types.LockContract) {
        switch (Trie.find(_contracts, keyT(canister_id), Text.equal)) {
            case (?t) {
                return ?t;
            };
            case _ {
                return null;
            };
        };
    };

    public query func getAllContracts() : async [(Text, Types.LockContract)] {
        var b : Buffer.Buffer<(Text, Types.LockContract)> = Buffer.Buffer<(Text, Types.LockContract)>(0);
        for ((i, v) in Trie.iter(_contracts)) {
            b.add((i, v));
        };
        return Buffer.toArray(b);
    };

    //Add to beta test - remove unused canister
    public shared ({caller}) func cancelContract(canister_id: Principal) : async (){
        assert (_isAdmin(Principal.toText(caller)));
        _contracts := Trie.remove(_contracts, keyT(Principal.toText(canister_id)), Text.equal).0;
        await ic.stop_canister({ canister_id = canister_id });
        await ic.delete_canister({ canister_id = canister_id });
    };
};
