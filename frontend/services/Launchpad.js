import Connect from "@/ic/actor/Connect";
import config from "@/config";
import { useQuery } from "@tanstack/vue-query";
export const install = async (params, whitelist, canisterId="avqkn-guaaa-aaaaa-qaaea-cai") =>{
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
            queryFn: async () => await Connect.canister(canisterId, 'launchpad_detail', true).launchpadInfo(),
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
            queryFn: async () => await Connect.canister(canisterId, 'launchpad_detail', true).status(),
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
export const getTopAffiliates = (canisterId, num=20) =>{
    try{
        return useQuery({
            queryKey: ['getTopAffiliates', canisterId],
            queryFn: async () => {
                let _res = await Connect.canister(canisterId, 'launchpad_detail', true).getTopAffiliates(Number(num));
                //Sort by volume
                _res.sort((a, b) => Number(b[1].volume) - Number(a[1].volume));
                return _res;
            },
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

export const getParticipantInfo = (canisterId, address) =>{
    try{
        return useQuery({
            queryKey: ['getParticipantInfo', canisterId, address],
            queryFn: async () => await Connect.canister(canisterId, 'launchpad_detail', true).getParticipantInfo(address),
            keepPreviousData: false,
            retry: 3,
            refetchInterval: 0
        })
    }catch(e){
        console.log('getParticipantInfo', e);
        return {err: 'An unexpected error occurred, please check the console log!'}
    }
}
export const checkEligibleToCommit = async (canisterId) =>{
    try{
        return await Connect.canister(canisterId, 'launchpad_detail').checkEligibleToCommit();
    }catch(e){
        console.log('checkEligibleToCommit', e);
        return {err: 'An unexpected error occurred, please check the console log!'}
    }
}

//Create short link
export const useCreateShortlink = async (shortName, path, canisterId) =>{
    try{
        return await Connect.canister(config.SHORTLINK_CANISTER_ID, 'shortLink').createLink(shortName, path, canisterId, [], [], []);
    }catch(e){
        console.log('createShortlink', e);
        return {err: 'An unexpected error occurred, please check the console log!'}
    }
}
//Get short link by path and canisterId
export const getShortlink = (path, canisterId) =>{
    try{
        return useQuery({
            queryKey: ['getShortlink', path+"_"+canisterId],
            queryFn: async () => await Connect.canister(config.SHORTLINK_CANISTER_ID, 'shortLink').getLinkByCanisterId(path, canisterId),
            keepPreviousData: false,
            retry: 3,
            refetchInterval: 0
        })
    }catch(e){
        console.log('getShortlink', e);
        return {err: 'An unexpected error occurred, please check the console log!'}
    }
}

//Delete short link
export const deleteShortLink = async (shortName) =>{
    try{
        return await Connect.canister(config.SHORTLINK_CANISTER_ID, 'shortLink').deleteLink(shortName);
    }catch(e){
        console.log('deleteShortlink', e);
        return {err: 'An unexpected error occurred, please check the console log!'}
    }
}