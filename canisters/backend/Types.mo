import Time "mo:base/Time";

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
    public type ContractData = {
        name: Text;
        durationTime: Nat;
        durationUnit: Nat;
        unlockSchedule: Nat;
        canCancel: Text;
        canChange: Text;
        canView: Text;
        startNow: Bool;
        startTime: Time.Time;
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