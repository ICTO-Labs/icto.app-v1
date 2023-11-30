import { defineStore } from "pinia";
import { deleteWalletInfoStorage, getWalletInfoStorage, setWalletInfoStorage } from "../utils/storage";

export const useWalletStore = defineStore({
    id: "wallet",
    state: () => ({
        icp: 0,
        principal: "",
        address: ""
    }),
    getters: {
        getWalletInfo: (state) => {
            state = getWalletInfoStorage();
            return state;
        },
    },
    actions: {
        setWalletInfo(principal, address, icpAmount) {
            if (principal === '') {
                this.$state = {
                    icp: 0,
                    principal: "",
                    address: "",
                };
                deleteWalletInfoStorage();
            } else {
                const walletInfo = {
                    icp: icpAmount,
                    principal: principal,
                    address: address
                };
                setWalletInfoStorage(walletInfo);
                this.$state = walletInfo;
            }
        }

    }
});