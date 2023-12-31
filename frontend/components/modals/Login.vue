<script setup>
    import { walletData } from "@/services/store";
    import WalletManager from "@/services/WalletManager";
    import config from "@/config";

    const walletLogin = async (wallet)=>{
        switch (wallet) {
            case "stoic": await WalletManager.stoicWallet()
                break;
            case "plug": await WalletManager.plugWallet()
                break;
            case "bitfinity": await WalletManager.bitfinityWallet()
                break
            case "ii": await WalletManager.iiWallet()
                break
        }
    }

</script>
<script>
    import { VueFinalModal } from 'vue-final-modal'
    import EventBus from "@/services/EventBus.js";

    export default {
        components: { VueFinalModal },
        data() {
            return {
                loginModal: false
            }
        },
        mounted() {
            EventBus.on("showLoginModal", isOpen => {
                this.loginModal = isOpen;
            });
        }
    }
</script>

<template>
    <VueFinalModal v-model="loginModal" :z-index-base="2000" classes="modal fade show" content-class="modal-dialog modal-lg">
            <div class="modal-content" v-if="!walletData.isLogged" >
                <div class="modal-header pt-5 pb-3">
                    <h4 class="modal-title"><i class="fas fa-wallet text-gray-700"></i> Connect your wallet </h4>
                    <div class="btn btn-icon btn-sm btn-bg-light btn-active-light-danger ms-2" data-bs-dismiss="modal" aria-label="Close" @click="loginModal=false">
                        <i class="fas fa-times"></i>
                    </div>
                </div>
                <div class="modal-body">
                        <div class="row gy-4 btn-group-login">
                            <div class="col-md-6">
                                <div class="d-flex flex-column gap-7 gap-md-10">
                                    <a href="javascript:void(0)" @click="walletLogin('ii')" :class="`btn btn-primary ${!config.WALLET_CONFIG['nns']?'disabled':''}`">
                                        <img src="/partner/ii.png" alt="Internet Identity" class=" wallet-icon-small"> <span class="wallet-name">Internet Identity</span>
                                    </a>
                                </div>
                            </div>
                            <div class="col-md-6">
                                <div class="d-flex flex-column gap-7 gap-md-10">
                                <a href="javascript:void(0)" @click="walletLogin('plug')" :class="`btn btn-secondary ${!config.WALLET_CONFIG['plug']?'disabled':''}`">
                                    <img src="/partner/plug.png" alt="Plug" class="wallet-icon-small"> <span class="wallet-name">Plug Wallet</span>
                                </a></div>
                            </div>
                            <div class="col-md-6">
                                <div class="d-flex flex-column gap-7 gap-md-10">
                                <a href="javascript:void(0)" @click="walletLogin('stoic')" :class="`btn btn-secondary ${!config.WALLET_CONFIG['stoic']?'disabled':''}`">
                                    <img src="/partner/stoic.png" alt="Stoic" class="wallet-icon-small"> <span class="wallet-name">Stoic Wallet</span>
                                </a></div>
                            </div>
                            <div class="col-md-6">
                                <div class="d-flex flex-column gap-7 gap-md-10">
                                <a href="javascript:void(0)" @click="walletLogin('bitfinity')" :class="`btn btn-secondary ${!config.WALLET_CONFIG['bitfinity']?'disabled':''}`">
                                    <img src="/partner/bitfinity.png" alt="Infinity" class="wallet-icon-small"> <span class="wallet-name">Bitfinity Wallet</span>
                                </a>
                            </div>
                            </div>
                        </div>
                </div>
        </div>

    </VueFinalModal>

</template>
<style>
    .wallet-name{
        float: left;
        vertical-align: middle;
        line-height: 36px;
    }
    .btn-group-login img{
        margin-right: 20px;
    }
    .wallet-icon{
        background: #efefef;
        padding: 6px;
    }
    .wallet-icon-small{
        width: 38px;
        float: left;
        border-radius: 100%;
        border-color: #525050;
        background: #ffffff;
        padding: 2px;
    }
    a.disabled {
        pointer-events: none;
        cursor: default;
    }
</style>