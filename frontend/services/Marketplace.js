import Connect from "@/ic/actor/Connect";
import config from "@/config";
import walletStore from "@/store/index";
import {
    getRandomBytes
} from "@/utils/common";

export const lockNFT = async(canister_id, token_id, price)=>{
    return await Connect.canister(canister_id, 'EXT-GEN2').lock(token_id, Number(price)*config.E8S, walletStore.address, getRandomBytes());
}
export const transferICP = async(toAddress, price)=>{
    let args = {
        from_subaccount: [getSubAccountArray(0)],
        to: toAddress,
        amount: { "e8s": price*config.E8S },
        fee: { "e8s": 10000 },
        memo: 0,
        created_at_time: []
    }
    return await Connect.canister(config.LEDGER_CANISTER_ID).send_dfx(args);
}
export const settleNFT = async(canister_id, token_id)=>{
    return await Connect.canister(canister_id, 'EXT-GEN2').settle(token_id);
}
//Todo: List to sell a NFT on the marketplace
export const listNFT = async(canister_id, token_id, price)=>{
    let args = {
        'token' : token_id,
        'from_subaccount' : [getSubAccountArray(0)],//[getSubAccountArray(_account_index)],
        'price' : (price == 0 ? [] : [Math.floor(Number(price)*config.E8S)])
    };
    let _rs = await Connect.canister(canister_id, 'EXT-GEN2').list(args);
    return _rs;
}