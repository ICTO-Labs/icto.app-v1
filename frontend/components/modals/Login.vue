<script setup>
    import { walletData } from "../../services/store";
    import {WalletManager} from "../../services/WalletManager";
    import config from "../../config";
    const login = async (wallet)=>{
        switch (wallet) {
            case "stoic": await WalletManager.stoicWallet()
                break;
            case "plug": await WalletManager.plugWallet()
                break;
            case "bitfinity": await WalletManager.bitfinityWallet()
                break
            case "nns": await WalletManager.nnsWallet()
                break
        }
    }

</script>
<script>
    import { VueFinalModal } from 'vue-final-modal'
    import EventBus from "../../services/EventBus";

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
                <a href="#" @click.stop="loginModal=false" class="close" data-bs-dismiss="modal" aria-label="Close">
                    <em class="icon ni ni-cross"></em>
                </a>
                <div class="modal-header">
                    <h5 class="modal-title">Connect your wallet</h5>
                </div>
                <div class="modal-body">
                        <div class="row gy-4 btn-group-login">
                            <div class="col-md-6">
                                <a href="javascript:void(0)" @click="login('nns')" :class="`btn no-spacing btn-wider btn-secondary ${!config.WALLET_CONFIG['nns']?'disabled':''}`">
                                    <img src="/partner/nns.png" alt="Internet Identity" class=" wallet-icon-small"> Internet Identity
                                </a>
                            </div>
                            <div class="col-md-6">
                                <a href="javascript:void(0)" @click="login('stoic')" :class="`btn no-spacing btn-wider btn-light ${!config.WALLET_CONFIG['stoic']?'disabled':''}`">
                                    <img src="/partner/stoic.png" alt="Stoic" class="wallet-icon-small"> Stoic Wallet
                                </a>
                            </div>
                            <div class="col-md-6">
                                <a href="javascript:void(0)" @click="login('plug')" :class="`btn no-spacing btn-wider btn-light ${!config.WALLET_CONFIG['plug']?'disabled':''}`">
                                    <img src="/partner/plug.png" alt="Plug" class="wallet-icon-small"> Plug Wallet
                                </a>
                            </div>
                            <div class="col-md-6">
                                <a href="javascript:void(0)" @click="login('bitfinity')" :class="`btn no-spacing btn-wider btn-light ${!config.WALLET_CONFIG['bitfinity']?'disabled':''}`">
                                    <img src="/partner/bitfinity.png" alt="Infinity" class="wallet-icon-small"> Bitfinity Wallet
                                </a>
                            </div>
                        </div>
                </div>
                <div class="modal-footer bg-light">
                    <ul class="btn-toolbar g-4 align-center">
                        <li><a href="javascript:void(0)" @click="loginModal=false" class="link link-primary">Close</a></li>
                    </ul>
                </div>
        </div>

    </VueFinalModal>

</template>
<style>
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