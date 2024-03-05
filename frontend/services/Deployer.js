import Connect from "@/ic/actor/Connect";
import config from "@/config";

export const useCreateLiquidLocker = async (payload) => {
    const response = await Connect.canister(config.DEPLOYER_CANISTER_ID, 'deployer').createContract(payload);
    return response;
}

export const useGetContracts = async (page=0) =>{
    return await Connect.canister(config.DEPLOYER_CANISTER_ID, 'deployer').getContracts(page);
}
