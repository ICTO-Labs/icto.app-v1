import Result "mo:base/Result";
import Time "mo:base/Time";
import Principal "mo:base/Principal";
import Float "mo:base/Float";
import ICRCTypes "../../types/ICRCLedger";
import Nat64 "mo:base/Nat64";
import Nat8 "mo:base/Nat8";
import Int "mo:base/Int";
import Error "mo:base/Error";
module {
    public func createKongSwapLP(
        tokenId: Text,  // Token canister ID
        tokenAmount: Nat,  // Amount of token
        tokenPriceInICP: Float,  // Price of token in ICP
        lpFeeBps: Nat,  // LP fee in basis points (e.g., 30 for 0.3%)
        tokenDecimals: Nat,  // Token decimals (e.g., 8 for 10^8)
        kongCanister: Text,
        icpLedger: Text
    ) : async Result.Result<Text, Text> {
        // Calculate amounts and expiry
        let expiresAt = Time.now() + 60_000_000_000;  // 60 seconds from now
        
        // Handle decimals
        let icpDecimals : Nat = 100_000_000; // 10^8 for ICP
        let tokenDecimalAdjustment = Float.fromInt(10 ** tokenDecimals);
        
        // Calculate actual amounts with decimals
        let actualTokenAmount = Float.toInt(Float.fromInt(tokenAmount) * tokenDecimalAdjustment);
        let icpAmount = Float.toInt(Float.fromInt(tokenAmount) * tokenPriceInICP * Float.fromInt(icpDecimals));
        
        let icrcLedger : ICRCTypes.Self = actor (icpLedger);
        let tokenLedger : ICRCTypes.Self = actor (tokenId);
        let kongActor = actor(kongCanister) : actor {
            add_pool : shared AddPoolArgs -> async AddPoolReply;
        };
        var tx_id_0 : TxId = #BlockIndex(0);
        var tx_id_1 : TxId = #BlockIndex(0);
        try {
            // Approve Token spending for Kong
            let approveToken0 = await tokenLedger.icrc2_approve({
                amount = Int.abs(actualTokenAmount);
                expires_at = ?Nat64.fromIntWrap(expiresAt);
                spender = {
                    owner = Principal.fromText(kongCanister);
                    subaccount = null;
                };
                created_at_time = ?Nat64.fromIntWrap(Time.now());
                expected_allowance = ?Int.abs(actualTokenAmount);
                fee = ?0;
                from_subaccount = null;
                memo = null;
            });
            switch (approveToken0) {
                case (#Ok(txId)) {
                    tx_id_0 := #BlockIndex(txId);
                };
                case (#Err(error)) {
                    return #err("Failed to approve token 0: " # debug_show(error));
                };
            };
            // Approve ICP spending for Kong
            let approveToken1 = await icrcLedger.icrc2_approve({
                amount = Int.abs(icpAmount);
                expires_at = ?Nat64.fromIntWrap(expiresAt);
                spender = {
                    owner = Principal.fromText(kongCanister);
                    subaccount = null;
                };
                created_at_time = ?Nat64.fromIntWrap(Time.now());
                expected_allowance = ?Int.abs(icpAmount);
                fee = ?0;
                from_subaccount = null;
                memo = null;
            });
            switch (approveToken1) {
                case (#Ok(txId)) {
                    tx_id_1 := #BlockIndex(txId);
                };
                case (#Err(error)) {
                    return #err("Failed to approve token 1: " # debug_show(error));
                };
            };
            // Add liquidity pool
            let addPoolResult = await kongActor.add_pool({
                token_0 = "IC." # tokenId;
                amount_0 = Int.abs(actualTokenAmount);
                token_1 = "IC." # icpLedger;
                amount_1 = Int.abs(icpAmount);
                lp_fee_bps = ?Nat8.fromNat(lpFeeBps);
                on_kong = ?false;
                tx_id_0 = ?tx_id_0;
                tx_id_1 = ?tx_id_1;
            });
            return #ok("LP created successfully." # debug_show(addPoolResult));
        } catch (e) {
            return #err("Failed to create LP: " # Error.message(e));
        };
    };

    // Helper types
    type ICRCApproveArgs = {
        amount: Nat;
        expires_at: ?Nat64;
        spender: {
            owner: Principal;
        };
    };

    type TxId = { #TransactionId : Text; #BlockIndex : Nat };

    type AddPoolArgs = {
        token_0 : Text;
        token_1 : Text;
        amount_0 : Nat;
        amount_1 : Nat;
        tx_id_0 : ?TxId;
        tx_id_1 : ?TxId;
        lp_fee_bps : ?Nat8;
        on_kong : ?Bool;
    };
    type TransferIdReply = {
        transfer_id : Nat64;
        transfer : TransferReply;
    };
    type ICTransferReply = {
        is_send : Bool;
        block_index : Nat;
        chain : Text;
        canister_id : Text;
        amount : Nat;
        symbol : Text;
    };
    type TransferReply = { #IC : ICTransferReply };
    type TransfersResult = { #Ok : [TransferIdReply]; #Err : Text };

    type AddPoolReply = {
        ts : Nat64;
        request_id : Nat64;
        status : Text;
        tx_id : Nat64;
        lp_token_symbol : Text;
        add_lp_token_amount : Nat;
        transfer_ids : [TransferIdReply];
        amount_0 : Nat;
        amount_1 : Nat;
        claim_ids : [Nat64];
        symbol_0 : Text;
        symbol_1 : Text;
        chain_0 : Text;
        chain_1 : Text;
        symbol : Text;
        lp_fee_bps : Nat8;
        on_kong : Bool;
    };
}