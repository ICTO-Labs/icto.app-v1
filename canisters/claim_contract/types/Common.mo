import Nat64 "mo:base/Nat64";
import Nat "mo:base/Nat";
import Text "mo:base/Text";
import Principal "mo:base/Principal";
import Result "mo:base/Result";
import Time "mo:base/Time";
import Bool "mo:base/Bool";

module {
    public type Duration = {#seconds : Nat; #nanoseconds : Nat};
    public type TimerId = Nat;
    public type ContractData = {
        title: Text;
        description: Text;
        durationTime: Nat;
        durationUnit: Nat;
        cliffTime: Nat;
        cliffUnit: Nat;
        unlockSchedule: Nat;
        allowCancel: Bool;
        startNow: Bool;
        startTime: Nat;
        created: Time.Time;
        tokenInfo: TokenInfo;
        recipients: ?[Recipient];
        owner: Principal;
        distributionType: DistributionType;
        vestingType: VestingType;
        totalAmount: Nat;
        initialUnlockPercentage: Nat;//Percentage of total amount to unlock immediately, the rest will be vested
        maxRecipients: Nat;
        blockId: Nat;//BlockID Score required to claim, 0 for no requirement
        autoTransfer: Bool;
    };
    
    // public type ContractData = {
    //     title: Text;
    //     description: Text;
    //     durationTime: Nat;
    //     durationUnit: Nat;
    //     cliffTime: Nat;
    //     cliffUnit: Nat;
    //     unlockSchedule: Nat;
    //     canCancel: Text;
    //     canChange: Text;
    //     canView: Text;
    //     startNow: Bool;
    //     startTime: Time.Time;
    //     created: Time.Time;
    //     tokenInfo: TokenInfo;
    //     totalAmount: Nat;
    //     unlockedAmount: Nat;
    //     recipients: [Recipient];
    //     owner: Principal;
    // };
    public type Recipient = {
        amount: Nat;
        address: Text;
        note: ?Text;
    };
    public type UserInfo = {
        amount: Nat;
        unlockedAmount: Nat;
        lastUnlockTime: Int;
    };
    public type Allocation = {
        userId : Text;//Principal or Address
        amount : Nat;//Total amount
        startTime : Time.Time;
        durationTime : Time.Time;
        unlockAmount : Nat;//Send each schedule
    };
    public  type SchedulingInterval = {
        delay_nano : Nat64;
        interval_nano : Nat64;
        iterations : Nat64;
    };
    public  type TransferHistory = {
        to: Text;
        amount: Nat;
        time: Time.Time;
        txId: ?Nat;
    };
    public type BurnHistory = {
        amount: Nat64;
        time: Time.Time;
        txId: Nat;
    };
    public type TokenResult<Ok, Err> = {
        #Ok: Ok;
        #Err: Err;
    };
    public type TokenInfo = {
        canisterId: Text;
        name: Text;
        standard: Text;
        symbol: Text;
        decimals: Nat;
        fee: Nat;
    };
    public type DistributionType = {
        #Whitelist;
        #Public;
    };
    public type ContractStatus = {
        #NOT_STARTED;  // Not started
        #PENDING;      // Up to start time, but not started, may be canister has not received token yet
        #STARTED;      // Started
        #PAUSED;       // Paused
        #ENDED;        // Ended (claimed all or time ended)
        #CANCELED;     // Canceled
    };
    public type VestingType = {
        #Standard; // Vesting step by step
        #Single;  // Unlock immediately
    };

}