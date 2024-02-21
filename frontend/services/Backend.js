import config from "@/config";
import { showError, showSuccess, principalToAccountId, txtToPrincipal } from "@/utils/common";
import Connect from "@/ic/actor/Connect";
export const useChargeFee = async(payload)=>{
    console.log('payload', payload);
    const _amount = BigInt(parseInt(payload.amount) * config.E8S);
    const _fee = BigInt(parseInt(0));
    const _from = txtToPrincipal(payload.from);
    const _to = txtToPrincipal(payload.to);
    const response = await Connect.canister(config.BACKEND_CANISTER_ID, 'backend').transfer_from(config.SERVICE_CANISTER_ID, {
            spender_subaccount: [],
            from: {
                owner: _from,
                subaccount: [],
            },
            to: {
                owner: _to,
                subaccount: [],
            },
            amount: _amount,
            fee: [_fee],
            memo: [],
            created_at_time: [],
        })
    console.log('useTransferFrom', response);
    return response; 
}