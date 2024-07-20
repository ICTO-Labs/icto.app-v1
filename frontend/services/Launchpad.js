import Connect from "@/ic/actor/Connect";
import config from "@/config";
import { useQuery } from "@tanstack/vue-query";
export const install = async (params, whitelist, canisterId="2phil-viaaa-aaaap-qhoka-cai") =>{
    try{
        return await Connect.canister(canisterId, 'launchpad_detail').install(params, whitelist);
    }catch(e){
        console.log('installLaunchpad', e);
        return {err: 'An unexpected error occurred, please check the console log!'}
    }
}

//Deposit
export const useCommit = async (canisterId, amount, refCode) =>{
    try{
        return await Connect.canister(canisterId, 'launchpad_detail').commit(Number(amount), refCode);
    }catch(e){
        console.log('commitLaunchpad', e);
        return {err: 'An unexpected error occurred, please check the console log!'}
    }
}

//Get details
export const getInfo = (canisterId) =>{
    try{
        return useQuery({
            queryKey: ['getInfo', canisterId],
            queryFn: async () => await Connect.canister(canisterId, 'launchpad_detail').launchpadInfo(),
            keepPreviousData: false,
            retry: 3,
            refetchInterval: 0
        })
        // return await Connect.canister(canisterId, 'launchpad_detail').launchpadInfo();
    }catch(e){
        console.log('detailsLaunchpad', e);
        return {err: 'An unexpected error occurred, please check the console log!'}
    }
}

//Get status
export const getStatus = (canisterId) =>{
    try{
        return useQuery({
            queryKey: ['getStatus', canisterId],
            queryFn: async () => await Connect.canister(canisterId, 'launchpad_detail').status(),
            keepPreviousData: false,
            retry: 3,
            refetchInterval: 10
        })
        // return await Connect.canister(canisterId, 'launchpad_detail').status();
    }catch(e){
        console.log('statusLaunchpad', e);
        return {err: 'An unexpected error occurred, please check the console log!'}
    }
}

//Get top affiliates
export const getTopAffiliates = (canisterId, num=5) =>{
    try{
        return useQuery({
            queryKey: ['getTopAffiliates', canisterId],
            queryFn: async () => await Connect.canister(canisterId, 'launchpad_detail').getTopAffiliates(Number(num)),
            keepPreviousData: false,
            retry: 3,
            refetchInterval: 1000
        })
        // return await Connect.canister(canisterId, 'launchpad_detail').topAffiliates();
    }catch(e){
        console.log('topAffiliatesLaunchpad', e);
        return {err: 'An unexpected error occurred, please check the console log!'}
    }
}

//Create short link
export const useCreateShortlink = async (url, targetUrl) =>{
    try{
        return await Connect.canister(config.SHORTLINK_CANISTER_ID, 'shortLink').createLink(url, targetUrl, [], [], []);
    }catch(e){
        console.log('createShortlink', e);
        return {err: 'An unexpected error occurred, please check the console log!'}
    }
}