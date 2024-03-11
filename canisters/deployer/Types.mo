import Time "mo:base/Time";
import Principal "mo:base/Principal";
import Text "mo:base/Text";
import Nat "mo:base/Nat";

module {
    public type LockContract = {
        version: Text;//Contract version
        contractId: ?Text;//This contract id
        poolId : Text;//Pool canister id
        provider: Text;//CEX, DEX Provider: ICPswap, Sonic, etc
        positionId: Nat;//Position ID
        positionOwner: Principal;//Position Owner
        poolName: Text;//Pool Name: XCANIC/ICP, etc
        durationTime: Nat;//Duration unlock in second
        durationUnit: Nat;//Unit of duration. Time = durationTime*durationUnit
        meta: [Text];//Meta data
        status : Text;//created/locked/unlocked
        lockedTime: ?Time.Time;//Locked time
        unlockedTime: ?Time.Time;//Unlocked time
        withdrawnTime: ?Time.Time;//withdrawn time
        created: Time.Time;//Created time
        token0: TokenInfo;
        token1: TokenInfo;
        // owner: Principal;//Contract owner
    };
    public type TokenInfo = {
        address: Text;
        standard: Text;
        name: Text;
    };
    public type LockStatus = {
        #created;
        #locked;
        #unlocked;
    };
    public type LockContractInit = {
        poolId : Text;//Pool canister id
        provider: Text;//CEX, DEX Provider: ICPswap, Sonic, etc
        positionId: Nat;//Position ID
        poolName: Text;//Pool Name: XCANIC/ICP, etc
        durationTime: Nat;//Duration unlock in second
        durationUnit: Nat;//Unit of duration. Time = durationTime*durationUnit
        meta: [Text];//Meta data
        token0: TokenInfo;
        token1: TokenInfo;
    };
    public type PoolError = {
        #CommonError;
        #InternalError : Text;
        #UnsupportedToken : Text;
        #InsufficientFunds;
    };
}