import Contract "../contract/Contract";
import Principal "mo:base/Principal";
import Array "mo:base/Array";
import Buffer "mo:base/Buffer";
import Cycles "mo:base/ExperimentalCycles";
import Time "mo:base/Time";
import Int "mo:base/Int";
import Timer "mo:base/Timer";
import IC "./IC";
import Types "./Types";
import ContractTypes "../contract/types/Common";//Common

actor {
    stable var currentValue: Nat = 0;
    stable var CONTRACT_VERSION: Text = "0.1.1";
    stable var INIT_CONTRACT_CYCLES: Nat = 300_000_000_000;
    let ic: IC.Self = actor "aaaaa-aa";
    let contracts = Buffer.Buffer<Text>(0);
    // system func timer(set : Nat64 -> ()) : async () {
    //     set(fromIntWrap(Time.now()) + 60_000_000_000); // 10 seconds from now
    //     await increment();
    // };
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
        contracts.add(Principal.toText(newContractCanisterPrincipal));
        Principal.toText(newContractCanisterPrincipal);
    };

    public query func listContract(): async [Text] {
        contracts.toArray();
    };

    public func cancelContract(canister_id: Principal) : async (){
        await ic.stop_canister({ canister_id = canister_id });
        await ic.delete_canister({ canister_id = canister_id });
    };
};
