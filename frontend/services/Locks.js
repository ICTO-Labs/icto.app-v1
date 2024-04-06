import Connect from "@/ic/actor/Connect";
import config from "@/config";

export const useGetContract = async (canisterId) =>{
    try{
        return await Connect.canister(canisterId, 'lock_contract', true).getContract();
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

export const useGetTransaction = async (canisterId) =>{
    try{
        return await Connect.canister(canisterId, 'lock_contract', true).getTransactions();
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

export const useCheckOvertime = async (canisterId) =>{
    try{
        return await Connect.canister(canisterId, 'lock_contract', true).checkOvertime();
    }catch(e){
        console.log('useCheckOvertime', e);
        return {err: 'An unexpected error occurred, please check the console log!'}
    }
}
export const useGetCyclesBalance = async (canisterId) =>{
    try{
        let _balance = await Connect.canister(canisterId, 'lock_contract', true).cycleBalance();
        console.log('balance', _balance);
        return Number(_balance)/config.CYCLES;
    }catch(e){
        console.log('useGetCyclesBalance', e);
        return {err: 'An unexpected error occurred, please check the console log!'}
    }
}