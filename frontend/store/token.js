import { defineStore } from "pinia";
import { useStorage } from '@vueuse/core'
import { useGetMyBalance } from "@/services/Token";
import { showSuccess} from "@/utils/common";
import { TOKEN_DATA } from "@/config/constants";

export const useAssetStore = defineStore({
    id: "assetState",
    state: () => ({
        assets: useStorage('importedTokens', TOKEN_DATA),
    }),
    getters: {
        getWalletToken: (state) => {
            state = getWalletToken();
            return state;
        },
        totalAssets: (state) => state.assets.length,
    },
    actions: {
        addAsset(canisterId, logo='', name, symbol, standard, decimals, fee, balance=0) {
            const found = this.assets.some(el => el.canisterId == canisterId);
            if(found){
                return false;
            }else{
                const asset = {
                    canisterId,
                    logo,
                    name,
                    symbol,
                    standard,
                    decimals,
                    fee,
                    balance
                    };
                this.assets = [asset, ...this.assets];
                return true;
            }
        },
        updateBalanceAll(){
            const _assets = this.assets;
            Promise.all(_assets.map(async (asset) => {
                const balance = await useGetMyBalance(asset.canisterId);
                asset.balance = balance;
                this.updateBalance(asset.canisterId, balance);
            })).then(() =>{
                showSuccess("Balance reloaded!")
            });
        },
        updateBalance(canisterId, balance){
            console.log('update', canisterId, balance);
            this.assets.map((asset) => {
                if(asset.canisterId == canisterId){
                    asset.balance = balance;
                }
            });
        },
        async removeAsset(canisterId) {
            this.assets = this.assets.filter((asset) => asset.canisterId !== canisterId);
        },
    },
});