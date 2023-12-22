import { useQuery, useMutation } from "@tanstack/vue-query";
import Connect from "@/ic/actor/Connect";
import { useStorage } from '@vueuse/core'
import { txtToPrincipal } from "@/utils/common";
import RosettaApi from '@/services/RosettaApi';
import config from '@/config';
import { walletStore } from "@/store";
import { showError } from "../utils/common";
const rosettaApi = new RosettaApi();
export const useGetMyBalance = async(tokenId) => {
    try{
        let _balance = await Connect.canister(tokenId, 'icrc1').icrc1_balance_of({
            owner: txtToPrincipal(walletStore.principal),
            subaccount: []
        });
        if("err" in _balance){
            showError(_balance.err);
            return 0;
        }else{
            return Number(_balance)/config.E8S
        }
    }catch(e){
        console.log('object', e);
        return 0;
    }
}
export const usetGetMetadata = async(tokenId, standard)=>{
    try{
        return await Connect.canister(tokenId, standard).icrc1_metadata();
    }catch(e){
        throw e;
    }
}

export const useICPBalance = (address)=>{
    let _address = address?address:walletStore.address;
    console.log('_address', _address, walletStore.address);
    if(_address == '') return 0;
     return useQuery({
        queryKey: ['icpBalance', _address],
        queryFn: async () => {
            try{
                let _balance = await rosettaApi.getAccountBalance(_address);
                return _balance.value.div(config.E8S).toNumber();
            }catch(e){
                throw new Error("Network Error: "+_address);
            }
        },
        keepPreviousData: true,
      })
}

export const useCreateToken = async (payload)=>{
    try {
        const _decimals = parseInt(payload.decimals);
        const _supply = BigInt(0);
        const _fee = parseInt(payload.fee);
        const canisterId = await Connect.canister(config.DEPLOYER_CANISTER_ID, 'deployer').createTokenCanister(
            payload.name,
            payload.symbol,
            payload.description,
            _supply,
            payload.logo,
            _decimals,
            _fee
        );
        return canisterId;
    } catch (error) {
        throw error;
    }
}
export const useGetUserTokens = (page)=> {
    return useQuery({
        queryKey: ['user_tokens', page],
        queryFn: async () => {
            return await Connect.canister(config.DEPLOYER_CANISTER_ID, 'deployer').getUserTokens(walletStore.principal, page);
        },
    });
};