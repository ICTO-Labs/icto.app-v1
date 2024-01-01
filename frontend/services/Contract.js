import { useQuery } from "@tanstack/vue-query";
import Connect from "@/ic/actor/Connect";
import config from "../config";

export const useCreateContract = async (data)=>{
    return await Connect.canister(config.BACKEND_CANISTER_ID, 'backend').createContract(data);
}
export const useListContract = async()=>{
    return await Connect.canister(config.BACKEND_CANISTER_ID, 'backend').listContract();
}
export const useCancelContract = async (contractId)=>{
    return await Connect.canister(config.BACKEND_CANISTER_ID, 'contract').whoami();
}
export const useGetContract = (contractId) => {
    return useQuery({
        queryKey: ['contractInfo', contractId],
        queryFn: async () => await Connect.canister(contractId, 'contract').get(),
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
