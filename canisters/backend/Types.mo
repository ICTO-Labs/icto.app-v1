import Time "mo:base/Time";
import Principal "mo:base/Principal";

module {
    public type CanisterSettings = {
        freezing_threshold  : Nat;
        controllers         : [Principal];
        memory_allocation   : Nat;
        compute_allocation  : Nat;
    };
    public type CanisterStatus = {
        status              : { #stopped; #stopping; #running };
        freezing_threshold  : Nat;
        memory_size         : Nat;
        cycles              : Nat;
        settings            : CanisterSettings;
        module_hash         : ?[Nat8];
        // idle_cycles_burned_per_second : Float;
    };
    //Display data for backend, not contract, edit contract/types/common
    public type ContractData = {
        contractId: Text;
        createdBy: Text;
        name: Text;
        description: Text;
        durationTime: Nat;
        durationUnit: Nat;
        unlockSchedule: Nat;
        canCancel: Text;
        canChange: Text;
        canView: Text;
        startNow: Bool;
        startTime: Time.Time;
        created: Time.Time;
        tokenId: Text;
        tokenName: Text;
        tokenStandard: Text;
        totalAmount: Nat;
        recipients: [Recipient];
    };
    public type Recipient = {
        amount: Nat;
        address: Text;
        title: ?Text;
        note: ?Text;
    }; 

}