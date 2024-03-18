import BigNumber from "bignumber.js";
import { useWalletStore } from '@/store/wallet'
import {Principal} from "@dfinity/principal";
import { showError, principalToAccountId } from "./common";
import config from "../config";
import tokenList from "@/ic/tokenList";
export const decodeTransaction = (transactions)=>{
  return transactions
      .map((transaction, txId) => {
        console.log('transaction', transaction);
        const timestamp = Math.round(Number(transaction.timestamp) / 1_000_000_000) // ns to s
        // const txId = Number(transaction.index);
        if (transaction.kind === 'transfer' && transaction.transfer[0]) {
          const transfer = transaction.transfer[0]
          const from = principalToAccountId(transfer.from.owner, transfer.from.subaccount[0])
          const to = principalToAccountId(transfer.to.owner, transfer.to.subaccount[0])

          return {
            kind: 'TRANSFER',
            from: {
              principal: transfer.from.owner.toText(),
              subaccount: from
            },
            to: {
              principal: transfer.to.owner.toText(),
              subaccount: to
            },
            amount: Number(transfer.amount),
            fee:
              transfer.fee && transfer.fee[0]
                ? transfer.fee[0]
                : 0,
            isInbound: from==to,
            status: {
              type: 'applied'
            },
            timestamp,
            txId,
            memo: transfer.memo && transfer.memo[0] ? Buffer.from(transfer.memo[0]).toString('hex') : undefined
          }
        } else if (transaction.kind === 'burn' && transaction.burn[0]) {
          const burn = transaction.burn[0]
          const from = principalToAccountId(burn.from.owner, burn.from.subaccount[0])
          return {
            kind: 'BURN',
            from: {
              principal: burn.from.owner.toText(),
              subaccount: from
            },
            to: 'Burn',
            isInbound: false,
            amount: Number(burn.amount),
            fee: 0, // TODO: 0 or defaultFee?
            type: 'burn',
            status: {
              type: 'applied'
            },
            timestamp,
            txId,
            memo: burn.memo && burn.memo[0] ? Buffer.from(burn.memo[0]).toString('hex') : undefined
          }
        } else if (transaction.kind === 'mint' && transaction.mint[0]) {
          const mint = transaction.mint[0]
          const to = principalToAccountId(mint.to.owner, mint.to.subaccount[0])

          return {
            kind: 'MINT',
            from: 'Mint',
            to: {
              principal: mint.to.owner.toText(),
              subaccount: to
            },
            isInbound: false,
            amount: Number(mint.amount),
            fee: 0, // TODO: 0 or defaultFee?
            status: {
              type: 'applied'
            },
            timestamp,
            txId,
            memo: mint.memo && mint.memo[0] ? Buffer.from(mint.memo[0]).toString('hex') : undefined
          }
        }
        return undefined
      })
      .filter((tx) => tx !== undefined)
}
export const decodeICRCMetadata = (tokenId, metadata)=>{
  const meta = {tokenId: tokenId};
  metadata.forEach((entry) => {
    const [first, second] = entry;
    if (first.includes('decimals')) {
      meta.decimals = Number(second.Nat);
    } else if (first.includes('symbol')) {
      meta.symbol = second.Text;
    } else if (first.includes('name')) {
      meta.name = second.Text;
      meta.standard = first.split(":")[0];//get standard
    } else if (first.includes('fee')) {
      meta.fee = Number(second.Nat);
    } else if (first.includes('logo')) {
      meta.logo = second.Text;
    }
  });
  return meta;
    // return metadata.reduce((acc, next) => {
    //     switch (next[0]) {
    //       case standard+':name':
    //         return Object.assign(acc, { name: next[1].Text })
    //       case standard+':symbol':
    //         return Object.assign(acc, { symbol: next[1].Text })
    //       case standard+':decimals':
    //         return Object.assign(acc, { decimals: Number(next[1].Nat) })
    //       case standard+':fee':
    //         return Object.assign(acc, { fee: (next[1].Nat).toString() })
    //       default:
    //         return Object.assign(acc, { [next[0]]: next[1] })
    //     }
    //   }, {})
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

export const getTokenInfo = (canisterId)=>{
  console.log(canisterId);
  const token = tokenList.find((token) => token.canisterId === canisterId);
  console.log('token', token);
  return token;
}
export const parseTokenAmount = (amount, decimals) => {
  // return new BigNumber(amount).dividedBy(Math.pow(10, decimals)).toFormat();
  if (amount !== 0 && !amount) return new BigNumber(0);
  if (typeof amount === "bigint") amount = Number(amount);
  if (typeof decimals === "bigint") decimals = Number(decimals);
  if (Number.isNaN(Number(amount))) return new BigNumber(String(amount));
  return new BigNumber(String(amount)).dividedBy(10 ** Number(decimals));

}
export const balanceActuallyToAccount = (amount, transferFee, decimals) => {
  const _amount = new BigNumber(amount ?? 0).minus(parseTokenAmount(transferFee, decimals));
  return _amount.isGreaterThan(0) ? _amount.toFormat() : 0;
};

export const getPercentage = (amount, total) => {
  if(amount == 0 || total == 0 || amount > total) return 0;
  return ((amount / total) * 100).toFixed(2);
}