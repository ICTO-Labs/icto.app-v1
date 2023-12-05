import { defineStore } from "pinia";
import { useStorage } from '@vueuse/core'

export const useAssetStore = defineStore({
    id: "assetState",
    state: () => ({
      assets: useStorage('importedTokens', []),
    }),
    getters: {
        getWalletToken: (state) => {
            state = getWalletToken();
            return state;
        },
        totalAssets: (state) => state.assets.length,
    },
   actions: {
        addAsset(canisterId, name, symbol, standard) {
            const found = this.assets.some(el => el.canisterId == canisterId);
            if(found){
                return false;
            }else{
                const asset = {
                    canisterId,
                    name,
                    symbol,
                    standard,
                    };
                this.assets = [asset, ...this.assets];
                return true;
            }
    },
  
    async removeAsset(canisterId) {
      this.assets = this.assets.filter((asset) => asset.canisterId !== canisterId);
    },
   },
  });