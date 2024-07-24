import { useQuery } from "@tanstack/vue-query";
import Connect from "@/ic/actor/Connect";
import config from "../config";
import walletStore from "@/store/";
import { Principal } from "@dfinity/principal";

export const useCreateContract = async (data)=>{
    try{
        return await Connect.canister(config.BACKEND_CANISTER_ID, 'backend').createContract(data);
    }catch(e){
        return {err: e}
    }
    
}
export const useGetMyContracts = async ()=>{
    try{
        if(walletStore.isLogged){
            return await Connect.canister(config.INDEXING_CANISTER_ID, 'indexing', true).getUserContracts(walletStore.principal);
        }else return [];
    }catch(e){
        throw new Error(e);
    }
}
export const useCancelContract = async (contractId)=>{
    return await Connect.canister(config.BACKEND_CANISTER_ID, 'contract').whoami();
}
export const useGetMyClaimedAmount = async (contractId)=>{
    if(walletStore.isLogged){
        return await Connect.canister(contractId, 'token_claim', true).checkClaimable(walletStore._principal);
    }else return 0;
}
export const useGetRecipientInfo = async (contractId)=>{
    if(walletStore.isLogged){
        let _rs = await Connect.canister(contractId, 'token_claim', true).getRecipientClaimInfo(walletStore._principal);
        if(_rs && _rs.length > 0){
            return _rs[0];
        }else return null;
    }else return null;
}
export const useClaim = async (contractId)=>{
    try{
        return await Connect.canister(contractId, 'token_claim').claim();
    }catch(e){
        throw new Error(e);
    }
}
export const useGetContract = (contractId) => {
    try{
        return useQuery({
            queryKey: ['getContractInfo', contractId],
            queryFn: async () => await Connect.canister(contractId, 'token_claim', true).getContractInfo(),
            keepPreviousData: true,
            retry: 3,
            refetchInterval: 0
        })
        // return await Connect.canister(contractId, 'token_claim', true).getContractInfo()
    }catch(e){
        throw new Error(e);
    }
}
export const useGetContractRecipients = async (contractId, page) => {
    try{
        return await Connect.canister(contractId, 'token_claim', true).getRecipients(page);
    }catch(e){
        throw new Error(e);
    }
}
export const useGetClaimRecord = async (contractId) => {
    try{
        if(walletStore.isLogged){
            return await Connect.canister(contractId, 'token_claim', true).getClaimHistory(walletStore._principal);
        }else return [];
    }catch(e){
        throw new Error(e);
    }
}
// export const useGetClaimRecord = (contractId) => {
//     let _principal = walletStore.isLogged?walletStore._principal:Principal.fromText("2vxsx-fae");
//     return useQuery({
//         queryKey: ['claimRecord', contractId],
//         queryFn: async () => await Connect.canister(contractId, 'token_claim').getClaimHistory(_principal),
//         keepPreviousData: true,
//         retry: 3,
//         refetchInterval: 0
//     })
// }
