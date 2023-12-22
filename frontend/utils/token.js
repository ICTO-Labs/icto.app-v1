import _api from "@/ic/api";
import { useWalletStore } from '@/store/wallet'
import {Principal} from "@dfinity/principal";
import { showError } from "./common";

export const decodeICRCMetadata = (metadata, standard)=>{
    return metadata.reduce((acc, next) => {
        switch (next[0]) {
          case standard+':name':
            return Object.assign(acc, { name: next[1].Text })
          case standard+':symbol':
            return Object.assign(acc, { symbol: next[1].Text })
          case standard+':decimals':
            return Object.assign(acc, { decimals: Number(next[1].Nat) })
          case standard+':fee':
            return Object.assign(acc, { fee: (next[1].Nat).toString() })
          default:
            return Object.assign(acc, { [next[0]]: next[1] })
        }
      }, {})
}

export const getMyBalance = async(canisterId, standard)=>{
  const walletData = useWalletStore();
  try{
    if(standard == 'dip20'){
      return await _api.canister(canisterId, standard).balanceOf(Principal.fromText(walletData.wallet.principal));
    }else{
      return await _api.canister(canisterId, standard).icrc1_balance_of(
          {
              owner: Principal.fromText(walletData.wallet.principal),
              subaccount: []
          }
      );
    }
  }catch(e){
    showError("Please login to continue!")
    return 0;
  }
  
}

export const currencyFormat = (value, e8s)=>{
  if(e8s){
    value = value/100_000_000;
  }
  return new Intl.NumberFormat('en-US', { maximumSignificantDigits: 6 }).format(value);
  // let val = (value/1).toFixed(6).replace(',', '.').replace(/[.,]000000$/, "")
  // return val.toString().replace(/\B(?=(\d{3})+(?!\d))/g, ",")
}