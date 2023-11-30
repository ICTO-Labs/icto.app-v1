import Nat64 "mo:base/Nat64";
import Nat "mo:base/Nat";
import Text "mo:base/Text";
import Principal "mo:base/Principal";
import Result "mo:base/Result";
import Time "mo:base/Time";

module {
    public type Duration = {#seconds : Nat; #nanoseconds : Nat};
    public type TimerId = Nat;
    public type ContractData = {
        tokenId: Text;
        amount: Nat;
        duration: Nat;
        receivers: [Principal];
        version: Text;
        };
    public  type SchedulingInterval = {
        delay_nano : Nat64;
        interval_nano : Nat64;
        iterations : Nat64;
    };
    public  type TransferHistory = {
        to: Principal;
        amount: Nat64;
        time: Time.Time;
        txId: Nat;
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

}