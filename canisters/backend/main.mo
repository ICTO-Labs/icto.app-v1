import Contract "../contract/Contract";
import Principal "mo:base/Principal";
import Array "mo:base/Array";
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

actor {
    stable var currentValue: Nat = 0;
    stable var CONTRACT_VERSION: Text = "0.1.1";
    stable var INIT_CONTRACT_CYCLES: Nat = 300_000_000_000;
    let ic: IC.Self = actor "aaaaa-aa";
    let contracts = Buffer.Buffer<Text>(0);
    private stable var _contracts : Trie.Trie<Text, Types.ContractData> = Trie.empty(); //mapping of contract_anister_id -> Contract details

    // system func timer(set : Nat64 -> ()) : async () {
    //     set(fromIntWrap(Time.now()) + 60_000_000_000); // 10 seconds from now
    //     await increment();
    // };
    private func keyT(x : Text) : Trie.Key<Text> {
        return { hash = Text.hash(x); key = x };
    };
    private func key(x : Nat32) : Trie.Key<Nat32> {
        return { hash = x; key = x };
    };
    func updateValue(): async(){
        currentValue += 1;
    };
    //Generate time now to second
    func timeNow(): Nat{
        Int.abs(Time.now()/1_000_000_000)
    };
    public func increment(): async () {
        await updateValue();
    };

    let cron_id = Timer.recurringTimer(#seconds (5), updateValue);

    public shared func cancel(): async () {
        Timer.cancelTimer(cron_id);
    };
    public query func getValue(): async Nat {
        currentValue;
    };
    public query func get_cron_id() : async (Timer.TimerId) {
        return cron_id;
    };
    public shared (msg) func whoami() : async Principal {
        msg.caller
    };
    public shared (msg) func transfer_from(canisterId: Text, payload: Actor.TransferFromArg) : async Actor.TransferFromResult {
        let ICRC : Actor.ICRC = actor(canisterId);
        await ICRC.icrc2_transfer_from(payload)
    };
    public func canister_status(canister_id: IC.canister_id): async Types.CanisterStatus{
        await ic.canister_status({canister_id = canister_id})
    };
    public shared (msg) func createContract(contract: ContractTypes.ContractData): async Text{
        // assert not Principal.isAnonymous(msg.caller);
        let _controllers = [Principal.fromText("lekqg-fvb6g-4kubt-oqgzu-rd5r7-muoce-kppfz-aaem3-abfaj-cxq7a-dqe")];
        Cycles.add(INIT_CONTRACT_CYCLES);

        //must add VERSION to contract data
        let newContractCanister = await Contract.Contract(contract);
        let newContractCanisterPrincipal = Principal.fromActor(newContractCanister);
        //Update settings;
        // await CA.updateCanisterSettings({
        // canisterId = newUserCanisterPrincipal;
        // settings = {
        //     controllers = controllers;
        //     compute_allocation = ?0;
        //     memory_allocation = ?0;
        //     freezing_threshold = ?2592000;
        // }
        // });

        let _contractCanisterId = Principal.toText(newContractCanisterPrincipal);
        contracts.add(Principal.toText(newContractCanisterPrincipal));
        //Add to contracts Trie
        _contracts := Trie.put(
            _contracts,
            keyT(_contractCanisterId),
            Text.equal,
            contract
        ).0;

        _contractCanisterId;
    };
    public query func getContracts(_page : Nat) : async ([Types.ContractData]) {
        var lower : Nat = _page * 9;
        var upper : Nat = lower + 9;
        var b : Buffer.Buffer<Types.ContractData> = Buffer.Buffer<Types.ContractData>(0);
        for ((i, v) in Trie.iter(_contracts)) {
            b.add(v);
        };
        let arr = Buffer.toArray(b);
        b := Buffer.Buffer<Types.ContractData>(0);
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
    public query func listContract(): async [Text] {
        contracts.toArray();
    };

    public func cancelContract(canister_id: Principal) : async (){
        await ic.stop_canister({ canister_id = canister_id });
        await ic.delete_canister({ canister_id = canister_id });
    };
};
