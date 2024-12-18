import TokenDeployer "canister:token_deployer";
import Result "mo:base/Result";
import Principal "mo:base/Principal";
import Types "../types/Common";

actor class TokenService() = self {
    private func prepairInitArgs(args: Types.TokenInfo, launchpadId: Principal): TokenDeployer.InitArgsRequested {
        {
            token_symbol = args.symbol;
            transfer_fee = args.transferFee;
            token_name = args.name;
            minting_account = { owner = launchpadId; subaccount = null };
            initial_balances = [];
            fee_collector_account = null;
            logo = args.logo;
        }
    };

    public func deployToken(tokenInfo: Types.TokenInfo, launchpadId: Principal): async Result.Result<Principal, Text> {
        let args = prepairInitArgs(tokenInfo, launchpadId);
        await TokenDeployer.install(args);
    }
}