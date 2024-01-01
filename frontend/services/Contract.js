import { useQuery } from "@tanstack/vue-query";
import Connect from "@/ic/actor/Connect";
import config from "../config";

export const useCreateContract = async (data)=>{
    return await Connect.canister(config.BACKEND_CANISTER_ID, 'backend').createContract(data);
}
export const useListContract = (page=0)=>{
    return useQuery({
        queryKey: ['listContracts', page],
        queryFn: async () => await Connect.canister(config.BACKEND_CANISTER_ID, 'backend').getContracts(page),
        keepPreviousData: true,
        retry: 0,
        refetchInterval: 0
      })
    // return await Connect.canister(config.BACKEND_CANISTER_ID, 'backend').getContracts(page);
}
export const useCancelContract = async (contractId)=>{
    return await Connect.canister(config.BACKEND_CANISTER_ID, 'contract').whoami();
}
export const useGetContract = (contractId) => {
    return useQuery({
        queryKey: ['contractInfo', contractId],
        queryFn: async () => {
          try{
            return await Connect.canister(contractId, 'contract').get()
          }catch(e){
            throw e;
          }
        },
        keepPreviousData: true,
        retry: 0,
        refetchInterval: 0
      })
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
