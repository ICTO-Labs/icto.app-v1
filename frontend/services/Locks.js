import Connect from "@/ic/actor/Connect";
import config from "@/config";

export const useGetContract = async (canisterId) =>{
    return await Connect.canister(canisterId, 'lock_contract').getContract();
}