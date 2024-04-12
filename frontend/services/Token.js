import { useQuery, useMutation } from "@tanstack/vue-query";
import Connect from "@/ic/actor/Connect";
import { useStorage } from '@vueuse/core'
import { decodeICRCMetadata, decodeTransaction, getTokenInfo } from "@/utils/token";
import RosettaApi from '@/services/RosettaApi';
import config from '@/config';
import walletStore from "@/store";
import { showError, showSuccess, principalToAccountId, txtToPrincipal } from "@/utils/common";
const rosettaApi = new RosettaApi();
export const useGetMyBalance = async(tokenId) => {
    if(!walletStore.principal){ 
        showError('Please login first');
        return 0;
    }else{
        try{
            let _balance = await Connect.canister(tokenId, 'icrc1').icrc1_balance_of({
                owner: txtToPrincipal(walletStore.principal),
                subaccount: []
            });
            let _token = getTokenInfo(tokenId);
            return Number(_balance)/ (_token ? Math.pow(10, _token.decimals) : config.E8S);
        }catch(e){
            return 0;
        }
    }
}
export const useGetTokenBalance = async(tokenId, principal, standard='icrc1')=>{
    try{
        let _token = getTokenInfo(tokenId);
        let _decimals = _token ? Math.pow(10, _token.decimals) : config.E8S;
        var _balance = 0;
        let _standard = standard.toLowerCase();
        if(_standard == 'icp' || _standard == 'icrc1' || _standard == 'icrc2'){
            _balance = await Connect.canister(tokenId, 'icrc1').icrc1_balance_of({
                owner: txtToPrincipal(principal),
                subaccount: [] 
            });
            return Number(_balance)/_decimals
        }else if(_standard == 'dip20'){
            _balance = await Connect.canister(tokenId, 'dip20').balanceOf(txtToPrincipal(principal));
            return Number(_balance)/_decimals;
        }
    }catch(e){
        console.log('useGetTokenBalance', e);
        return 0;
    }
}
export const useTransferFrom = async(tokenId, payload, standard="icrc2")=>{
    let _token = getTokenInfo(tokenId);
    const _amount = BigInt(parseFloat(payload.amount) * (_token ? Math.pow(10, _token.decimals) : config.E8S));
    const _fee = BigInt(_token?_token.fee:0);
    const _from = txtToPrincipal(payload.from);
    const _to = txtToPrincipal(payload.to);
    const response = await Connect.canister(tokenId, standard).icrc2_transfer_from({
            spender_subaccount: [],
            from: {
                owner: _from,
                subaccount: [],
            },
            to: {
                owner: _to,
                subaccount: [],
            },
            amount: _amount,
            fee: [_fee],
            memo: [],
            created_at_time: [],
        })
    console.log('useTransferFrom', response);    
}
export const useTokenApprove = async(tokenId, payload, standard="icrc2")=>{
    let _token = getTokenInfo(tokenId);
    const _amount = BigInt(parseFloat(payload.amount) * (_token ? Math.pow(10, _token.decimals) : config.E8S));
    const _fee = BigInt(_token?_token.fee:0);
    const _spender = txtToPrincipal(payload.spender);
    try{
        const response =  await Connect.canister(tokenId, standard).icrc2_approve({
            from_subaccount: [],
            spender: {
                owner: _spender,
                subaccount: [],
            },
            amount: _amount,
            expires_at: [],
            expected_allowance: [],
            memo: [],
            fee: [_fee],
            created_at_time: []
        });
        return response;
    }catch(e){
        return null;
    }
}
export const useGetTransactions = (tokenId, standard, start, length)=>{
    return useQuery({
        queryKey: ['tokenTransactions', tokenId],
        queryFn: async () => {
            let _payload = {
                "start": Number(start),
                "length": Number(length)
            };
            console.log('payload', _payload, tokenId, standard, start, length);
            let _data = await Connect.canister(tokenId, 'icrc2', true).get_transactions(_payload);
            console.log('_data transaction', _data);
            let _rs = {
                transactions: decodeTransaction(_data.transactions),
                first_index: _data.first_index,
                log_length: _data.log_length
            }
            return _rs;
        },
        keepPreviousData: false,
    })
}
export const useGetTokenSupply = (tokenId, standard)=>{
    return useQuery({
        queryKey: ['tokenSupply', tokenId],
        queryFn: async () => {
            try{
                return await Connect.canister(tokenId, standard, true).icrc1_total_supply();
            }catch(e){
                throw new Error("Network Error: "+tokenId);
            }
        },
        keepPreviousData: true,
      })
}
export const useGetTokenOwner = (tokenId, standard)=>{
    return useQuery({
        queryKey: ['tokenOwner', tokenId],
        queryFn: async () => {
            try{
                let _rs = await Connect.canister(tokenId, standard, true).icrc1_minting_account();
                return {
                    principal: _rs[0].owner.toText(),
                    subaccount: principalToAccountId(_rs[0].owner, _rs[0].subaccount[0])
                }
            }catch(e){
                throw new Error("Network Error: "+tokenId);
            }
        },
        keepPreviousData: true,
      })
}
export const usetGetMetadata = async(tokenId, standard="icrc2")=>{
    try{
        let _tokenInfo =  await Connect.canister(tokenId, standard, true).icrc1_metadata();
        if(!_tokenInfo || "err" in _tokenInfo){
			// showError('Canister not found or did not match the token standard: '+standard.toUpperCase());
            return null;
		}else{
			return decodeICRCMetadata(tokenId, _tokenInfo);
		}
    }catch(e){
        throw e;
    }
}

export const useTransferToken = async(tokenId, to, amount)=>{
    const _p = txtToPrincipal(to);
    let _token = getTokenInfo(tokenId);
    const _amount = BigInt(parseFloat(amount) * (_token ? Math.pow(10, _token.decimals) : config.E8S));
    console.log('_amount', _amount, amount);
    // const _fee = BigInt(_token.fee>0?parseInt(_token.fee)/Math.pow(10, _token.decimals):0);
    const _fee = BigInt(_token?_token.fee:0);

    // const _amount = amount*config.E8S;
    try{
        let _payload = {
            from_subaccount: [],
            to: {
                owner: _p,
                subaccount: [],
            },
            amount: _amount,
            fee: [_fee],
            memo: [],
            created_at_time: [],
        }
        console.log('_payload', _payload);;
        let response = await Connect.canister(tokenId, 'icrc1').icrc1_transfer(_payload);
        console.log('response', response);
        if ("Err" in response) {
            console.log('response.Err', response);
            showError("Some error occured! Please try again"+JSON.stringify(response.Err));
        } else {
            showSuccess("Transferred successfully!");
            return true;
        }
    }catch(e){
        return false;
        showError(e);
    }
}

export const useICPBalance = (address)=>{
    let _address = address?address:walletStore.address;
    console.log('_address', _address, walletStore.address);
    if(_address == '') return 0;
     return useQuery({
        queryKey: ['icpBalance', _address],
        queryFn: async () => {
            try{
                let _balance = await rosettaApi.getAccountBalance(_address);
                return _balance.value.div(config.E8S).toNumber();
            }catch(e){
                throw new Error("Network Error: "+_address);
            }
        },
        keepPreviousData: true,
      })
}

export const useCreateToken = async (payload)=>{
    try {
        const _decimals = parseInt(payload.decimals);
        const _supply = BigInt(0);
        const _fee = parseInt(payload.fee);
        const canisterId = await Connect.canister(config.TOKEN_DEPLOYER_CANISTER_ID, 'token_deployer').createTokenCanister(
            payload.name,
            payload.symbol,
            payload.description,
            _supply,
            payload.logo,
            _decimals,
            _fee
        );
        return canisterId;
    } catch (error) {
        throw error;
    }
}

export const useInstallToken = async (payload)=>{
    try {
        const _payload = {...payload};
        _payload.transfer_fee = _payload.transfer_fee*config.E8S;
        const canisterId = await Connect.canister(config.TOKEN_DEPLOYER_CANISTER_ID, 'token_deployer').install(_payload);
        return canisterId;
    } catch (error) {
        throw error;
    }
}
export const useGetUserTokens = (page)=> {
    return useQuery({
        queryKey: ['user_tokens', page],
        queryFn: async () => {
            const _rs = await Connect.canister(config.TOKEN_DEPLOYER_CANISTER_ID, 'token_deployer').getUserTokens(walletStore.principal, page);
            if (_rs && typeof _rs === 'object' && 'err' in _rs) {
                throw new Error(_rs.err);
            }
            return _rs;
        },
    });
};