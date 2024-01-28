import Connect from "@/ic/actor/Connect";
import config from "@/config";
import walletStore from "@/store/index";
import { getSubAccountArray, getRandomBytes} from "@/utils/common";
import { currencyFormat } from "@/utils/token";

const defaultStandard = 'EXT';//Default standard for marketplace: EXT
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

export const getCollectionStats = async canister_id =>{
    let _stats;
    try{
        if(canister_id == config.CANIC_CANISTER_ID || canister_id == 'gtb2b-tiaaa-aaaah-qcxca-cai')
            _stats = await Connect.canister(canister_id, defaultStandard).stats();
        else
            _stats = await Connect.canister(canister_id, defaultStandard).ext_marketplaceStats();
        return {
            total : currencyFormat((Number(_stats[0])/1000000/100).toFixed(2)),
            high : currencyFormat((Number(_stats[1])/1000000/100).toFixed(2)),
            low : currencyFormat((Number(_stats[2])/1000000/100).toFixed(2)),
            floor : currencyFormat((Number(_stats[3])/1000000/100).toFixed(2)),
            listings : Number(_stats[4]),
            tokens : Number(_stats[5]),
            sales : Number(_stats[6]),
            average : currencyFormat((Number(_stats[6]) ? (Number((_stats[0]/_stats[6])/1000000n)/100).toFixed(2) : "-")),
        }
    }catch(e){
        console.log('err', e);
        return {
            total : 22,
            high : 21,
            low : 5,
            floor : 2,
            listings : 12,
            tokens : 2233,
            sales : 22,
            average : 13,
        }
    }
}
export const validateExt = async canister_id =>{
    let extensions = await Connect.canister(canister_id, defaultStandard).ext_extensions();
    if (extensions.includes('@ext/nonfungible'))
        return true;
    else return false;
}
export const getRegistry = async canister_id =>{
    return await Connect.canister(canister_id, defaultStandard).getRegistry();
}
export const getListings = async canister_id =>{
   return await Connect.canister(canister_id, defaultStandard).listings();
}

export const getCollectionInfo = async canister_id =>{
    if(canister_id == config.CANIC_CANISTER_ID)
        return await Connect.canister(canister_id, 'CANICNFT').getCollectionInfo();
    else
        return await Connect.canister(canister_id, defaultStandard).getCollectionInfo();
}