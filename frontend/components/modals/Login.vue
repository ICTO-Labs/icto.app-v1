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
                                <a href="javascript:void(0)" @click="walletLogin('ii')" :class="`w-100 btn btn-primary ${!config.WALLET_CONFIG['nns']?'disabled':''}`">
                                    <div class="d-flex align-items-center">
                                        <div class="symbol symbol-45px me-5 symbol-circle bg-white">
                                            <img src="/partner/ii.png" alt="I" class="h-45 align-self-center">
                                        </div>
                                        <div class="d-flex justify-content-start flex-column">
                                            <a href="#" class="text-light-dark fw-bolder fs-6">Internet Identity</a>
                                        </div>
                                    </div>
                                </a>
                            </div>
                            <div class="col-md-6">
                                <a href="javascript:void(0)" @click="walletLogin('plug')" :class="`w-100 btn btn-secondary ${!config.WALLET_CONFIG['plug']?'disabled':''}`">
                                    <div class="d-flex align-items-center">
                                        <div class="symbol symbol-45px me-5 symbol-circle bg-white">
                                            <img src="/partner/plug.png" alt="P" class="h-45 align-self-center">
                                        </div>
                                        <div class="d-flex justify-content-start flex-column">
                                            <a href="#" class="text-gray-600 fw-bolder fs-6">Plug Wallet</a>
                                        </div>
                                    </div>
                                </a>
                            </div>
                            <div class="col-md-6">
                                <a href="javascript:void(0)" @click="walletLogin('stoic')" :class="`w-100 btn btn-secondary ${!config.WALLET_CONFIG['stoic']?'disabled':''}`">
                                    <div class="d-flex align-items-center">
                                        <div class="symbol symbol-45px me-5 symbol-circle bg-white">
                                            <img src="/partner/stoic.png" alt="S" class="h-45 align-self-center">
                                        </div>
                                        <div class="d-flex justify-content-start flex-column">
                                            <a href="#" class="text-gray-600 fw-bolder fs-6">Stoic Wallet</a>
                                        </div>
                                    </div>
                                </a>
                            </div>
                            <div class="col-md-6">
                                <a href="javascript:void(0)" @click="walletLogin('bitfinity')" :class="`w-100 btn btn-secondary ${!config.WALLET_CONFIG['bitfinity']?'disabled':''}`">
                                    <div class="d-flex align-items-center">
                                        <div class="symbol symbol-45px me-5 symbol-circle bg-white">
                                            <img src="/partner/bitfinity.png" alt="B" class="h-45 align-self-center">
                                        </div>
                                        <div class="d-flex justify-content-start flex-column">
                                            <a href="#" class="text-gray-600 fw-bolder fs-6">Bitfinity Wallet</a>
                                        </div>
                                    </div>
                                </a>
                            </div>
                        </div>
                </div>
        </div>

    </VueFinalModal>

</template>
<style>
   
    a.disabled {
        pointer-events: none;
        cursor: default;
    }
</style>