import { useQuery } from "@tanstack/vue-query";
import Connect from "@/ic/actor/Connect";
import { useStorage } from '@vueuse/core'
import { txtToPrincipal } from "@/utils/common";
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
