import { defineStore } from "pinia";
import { useStorage } from '@vueuse/core'

export const useWalletStore = defineStore({
    id: "walletState",
    state: () => ({
        wallet: useStorage('loggedWallet', {principal: null, address: null, balance: 0}),
    }),
    getters: {
        getWalletInfo: (state) => {
            state = getWalletInfo();
            return state;
        },
    },
    actions: {
        setWalletInfo(principal, address, balance) {
            this.wallet = {principal, address, balance};
        },
        removeWalletInfo(){
            this.wallet =  {principal: null, address: null, balance: 0};
        },
        setBalance(balance){
            this.wallet = {...this.wallet, balance: balance}
        }

    }
});