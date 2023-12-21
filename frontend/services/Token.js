import { useQuery } from "@tanstack/vue-query";
import Connect from "@/ic/actor/Connect";
import { useStorage } from '@vueuse/core'
import { txtToPrincipal } from "@/utils/common";
import RosettaApi from '@/services/RosettaApi';
import config from '@/config';
import { walletStore } from "@/store";
const rosettaApi = new RosettaApi();

export const useGetMyBalance = async(tokenId) => {
    const auth = useStorage('auth', {});
    console.log(auth.value.identity);

    return await Connect.canister(tokenId, 'icrc1').icrc1_balance_of({
        owner: txtToPrincipal(auth.value.principal),
        subaccount: []
    });
    // return useQuery({
    //     queryKey: ['tokenBalance', tokenId],
    //     queryFn: async () => await Connect.canister(tokenId, 'icrc1').icrc1_balance_of({
    //         owner: Principal.fromText(auth.value.principal),
    //         subaccount: []
    //     }),
    //     keepPreviousData: true,
    //   })
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
