import Connect from "@/ic/actor/Connect";
import config from "@/config";

export const useCreateLiquidLocker = async (payload) => {
    const response = await Connect.canister(config.LOCK_DEPLOYER_CANISTER_ID, 'lock_deployer').createContract(payload);
    return response;
}

export const useGetContracts = async (page=0) =>{
    return await Connect.canister(config.LOCK_DEPLOYER_CANISTER_ID, 'lock_deployer').getContracts(page);
}
