import Connect from "@/ic/actor/Connect";
import config from "@/config";

export const useGetContract = async (canisterId) =>{
    try{
        return await Connect.canister(canisterId, 'lock_contract').getContract();
    }catch(e){
        console.log('useGetContract', e);
        return {err: 'An unexpected error occurred, please check the console log!'}
    }
}

export const useWithdrawPosition = async (canisterId) =>{
    try{
        return await Connect.canister(canisterId, 'lock_contract').withdraw();
    }catch(e){
        console.log('useWithdrawPosition', e);
        return {err: 'An unexpected error occurred, please check the console log!'}
    }
}

export const useGetTransaction = async (canisterId, page=0) =>{
    try{
        return await Connect.canister(canisterId, 'lock_contract').getTransactions(page);
    }catch(e){
        console.log('useGetTransaction', e);
        return {err: 'An unexpected error occurred, please check the console log!'}
    }
}

export const useIncreaseDuration = async (canisterId, durationUnit, durationTime) =>{
    try{
        return await Connect.canister(canisterId, 'lock_contract').increaseDuration(durationUnit, durationTime);
    }catch(e){
        console.log('useIncreaseDuration', e);
        return {err: 'An unexpected error occurred, please check the console log!'}
    }
}