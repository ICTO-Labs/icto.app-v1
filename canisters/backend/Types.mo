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
        title: Text;
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
        tokenInfo: TokenInfo;
        totalAmount: Nat;
        recipients: [Recipient];
    };
    public type Recipient = {
        amount: Nat;
        address: Text;
        note: ?Text;
    }; 
    public type TokenInfo = {
        canisterId: Text;
        name: Text;
        standard: Text;
        decimals: Nat;
        symbol: Text;
        fee: Nat;
    };
    public type DistributionType = {
        #Whitelist;
        #Public;
    };
    public type ContractMetadata = {
        id: Text;
        owner: Text;
        distributionType: DistributionType;
        createdAt: Int;
        launchpadId: ?Text;
    };

}