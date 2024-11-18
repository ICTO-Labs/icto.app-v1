import ICP "./types/ICP";
import ICRC1 "./types/ICRC1";

module {
    //IC Ledger Canister Interface
    public type ICP = actor {
        account_balance : shared query ICP.AccountBalanceArgs -> async ICP.Tokens;
        archives : shared query () -> async ICP.Archives;
        decimals : shared query () -> async { decimals : Nat32 };
        name : shared query () -> async { name : Text };
        query_blocks : shared query ICP.GetBlocksArgs -> async ICP.QueryBlocksResponse;
        symbol : shared query () -> async { symbol : Text };
        transfer : shared ICP.TransferArgs -> async ICP.TransferResult;
        transfer_fee : shared query ICP.TransferFeeArg -> async ICP.TransferFee;
    };

    //ICRC-1 Ledger Canister Interface
    public type ICRC1 = actor {
        get_transactions : shared query (ICRC1.GetTransactionsRequest) -> async (ICRC1.GetTransactionsResponse);
        icrc1_transfer : (ICRC1.TransferArg) -> async (ICRC1.Result);
        icrc1_balance_of : shared query (ICRC1.Account) -> async (Nat);
        icrc1_fee : shared query () -> async (Nat);
    };

};