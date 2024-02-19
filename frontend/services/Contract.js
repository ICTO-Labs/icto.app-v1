import { useQuery } from "@tanstack/vue-query";
import Connect from "@/ic/actor/Connect";
import config from "../config";

export const useCreateContract = async (data)=>{
    try{
        return await Connect.canister(config.BACKEND_CANISTER_ID, 'backend').createContract(data);
    }catch(e){
        return {err: e}
    }
    
}
export const useGetMyContracts = async (page=0)=>{
    try{
        return await Connect.canister(config.BACKEND_CANISTER_ID, 'backend').getMyContracts(page)
    }catch(e){
        throw new Error(e);
    }
}
export const useCancelContract = async (contractId)=>{
    return await Connect.canister(config.BACKEND_CANISTER_ID, 'contract').whoami();
}
export const useGetContract = async (contractId) => {
    try{
        return await Connect.canister(contractId, 'contract').get()
    }catch(e){
        throw new Error(e);
    }
}
export const useGetPaymentHistory = (contractId) => {
    return useQuery({
        queryKey: ['paymentHistory', contractId],
        queryFn: async () => await Connect.canister(contractId, 'contract').history(),
        keepPreviousData: true,
        retry: 0,
        refetchInterval: 0
      })
}
