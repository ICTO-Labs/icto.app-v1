import { useQuery, useMutation } from "@tanstack/vue-query";
import Connect from "@/ic/actor/Connect";
import config from "../config";
import {Principal} from "@dfinity/principal";

export const useGetBlockIdScore = (principal)=>{
    return useQuery({
        queryKey: ['getBlockIdScore', principal],
        queryFn: async () => {
            if(!principal) return 0;
            let _res = await Connect.canister(config.BLOCKID_CANISTER_ID, 'blockId').getWalletScore(Principal.fromText(principal), 'block-id');
            console.log('blockIdScore', _res);
            if(_res){
                return Number(_res.totalScore);
            } else return 0;
        },
        keepPreviousData: false,
        retry: 3,
        refetchInterval: 0
    })
}