<script setup>
import { onMounted, ref, watchEffect } from "vue";
import EventBus from "@/services/EventBus";
import walletStore from "@/store";
import { showModal, showSuccess } from '@/utils/common';
import { useAssetStore } from "@/store/token";
import { currencyFormat } from "@/utils/token";

import NFTItem from "@/components/wallet/NFTItem.vue";
const collectionInfo = { 'name': "ICTO NFT Card", 'symbol': "NFT", 'canisterId': "1" };
const openWallet = ref(false);
const activeTab = ref('wallet_tokens');
const isLoading = ref(false);
onMounted(() => {
    EventBus.on("showWalletModal", (status) => {
        openWallet.value = status;
    });
});
const storeAssets = ref(null);
watchEffect(() => {
    if (walletStore.isLogged) {
        console.log('init storeAssets: ', walletStore.principal);
        storeAssets.value = useAssetStore();
        storeAssets.value.updateBalanceAll((cb) => {
            console.log('cb', cb);
        });
    }
});
const closeWallet = () => {
    openWallet.value = false;
}
const showTab = (tab) => {
    activeTab.value = tab;
}
const importToken = () => {
    showModal("showImportTokenModal", true)
}
const refreshBalance = async () => {
    isLoading.value = true;
    await storeAssets.value.updateBalanceAll(function (status) {
        console.log('status', status);
        isLoading.value = false;
        showSuccess("Balance updated successfully!");
    });
}
const removeToken = (tokenCanister) => {
    storeAssets.value.removeAsset(tokenCanister);
}
const transferToken = (token) => {
    const newObj = { ...token };
    newObj.status = true;
    newObj.action = 'transfer';
    showModal("showTransferTokenModal", newObj)
}
const resetAssets = () => {
    Swal.fire({
        title: "Are you sure?",
        text: "Reset assets to the default list?",
        icon: "warning",
        showCancelButton: true,
        confirmButtonColor: "#3085d6",
        cancelButtonColor: "#d33",
        confirmButtonText: "Yes, Reset it!"
    }).then(async (result) => {
        if (result.isConfirmed) {
            await storeAssets.value.resetAssets();
            showSuccess("Assets reseted successfully!");
        }
    });
}
const logout = () => {
    Swal.fire({
        title: "Are you sure?",
        text: "Disconnect your wallet and delete this session data?",
        icon: "warning",
        showCancelButton: true,
        confirmButtonColor: "#3085d6",
        cancelButtonColor: "#d33",
        confirmButtonText: "Yes, log me out!"
    }).then(async (result) => {
        if (result.isConfirmed) {
            openWallet.value = false;//Close modal
            await walletStore.logout()
        }
    });
}
</script>
<template>
    <div :class="`bg-body drawer drawer-end ${openWallet ? 'drawer-on' : ''} wallet-modal`">
        <div class="card shadow-none rounded-0 w-100">
            <!--begin::Header-->
            <div class="card-header">
                <h3 class="card-title align-items-start flex-column">
                    <span class="fw-bolder mb-2 text-primary"><i class="fas fa-wallet text-primary me-2"></i> My
                        Wallet</span>
                    <span class="text-muted fw-bold fs-7">Connected: <span
                            class="fw-bold text-gray-800">{{ walletStore?.account?.name }}</span>
                        <button class="btn btn-sm btn-light-danger fw-bolder fs-8 px-2 py-1 ms-2"
                            @click.stop="() => logout()">Disconnect</button>
                    </span>
                </h3>

                <div class="card-toolbar">
                    <button type="button" class="btn btn-sm btn-icon btn-active-light-primary me-n5"
                        id="kt_activities_close" @click="closeWallet">
                        <span class="svg-icon svg-icon-1">
                            <svg xmlns="http://www.w3.org/2000/svg" width="24" height="24" viewBox="0 0 24 24"
                                fill="none">
                                <rect opacity="0.5" x="6" y="17.3137" width="16" height="2" rx="1"
                                    transform="rotate(-45 6 17.3137)" fill="black"></rect>
                                <rect x="7.41422" y="6" width="16" height="2" rx="1" transform="rotate(45 7.41422 6)"
                                    fill="black"></rect>
                            </svg>
                        </span>
                    </button>
                </div>
            </div>
            <div class="p-2 position-relative">
                <!--begin::Content-->
                <div id="kt_activities_scroll" class="position-relative scroll-y me-n5 pe-5">
                    <div class="menu-item px-3">
                        <div class="menu-content d-flex align-items-center px-3 w-100 " v-show="walletStore.isLogged">
                            <!--begin::Avatar-->
                            <div class="symbol symbol-circle bg-light-primary symbol-60px me-5">
                                <img alt="Logo" :src="`/partner/${walletStore.connector}.png`" />
                            </div>
                            <!--end::Avatar-->
                            <div class="d-flex flex-column flex-wrap w-100 flex-wrap">
                                <div class="mb-1 w-100 flex-wrap">
                                    <div class="fw-semibold text-gray-600 fs-7">Principal ID:</div>
                                    <div class="fw-bold text-gray-800 fs-6 flex-wrap">
                                        {{ walletStore.principal }} <Copy :text="walletStore.principal"></Copy>
                                    </div>
                                </div>
                                <div class="mb-1 w-100">
                                    <div class="fw-semibold text-gray-600 fs-7">Address ID:</div>
                                    <div class="fw-bold text-gray-800 fs-6">
                                        {{ walletStore.address }} <Copy :text="walletStore.address"></Copy>
                                    </div>
                                </div>
                            </div>
                        </div>
                        <div class="separator my-2"></div>
                        <div class="card-header px-0 border-0">
                            <h3 class="card-title align-items-start flex-column">
                                <ul class="nav fs-5">
                                    <li class="nav-item">
                                        <a class="nav-link btn btn-sm btn-color-muted btn-active btn-active-primary fw-bolder fs-6 px-4 me-1"
                                            @click="showTab('wallet_tokens')"
                                            :class="{ active: activeTab === 'wallet_tokens' }">
                                            Tokens
                                        </a>
                                    </li>
                                    <li class="nav-item">
                                        <a class="nav-link btn btn-sm btn-color-muted btn-active btn-active-danger fw-bolder fs-6 px-4 me-1"
                                            @click="showTab('wallet_nfts')"
                                            :class="{ active: activeTab === 'wallet_nfts' }">
                                            NFTs
                                        </a>
                                    </li>
                                    <li class="nav-item">
                                        <a class="nav-link btn btn-sm btn-color-muted btn-active btn-active-success fw-bolder fs-6 px-4"
                                            @click="showTab('wallet_airdrops')"
                                            :class="{ active: activeTab === 'wallet_airdrops' }">
                                            Airdrops
                                        </a>
                                    </li>
                                </ul>
                            </h3>
                            <div class="card-toolbar">
                                <button type="button" @click="resetAssets" class="btn btn-sm btn-light-danger">
                                    <i class="fas fa-remove"></i> Reset
                                </button>
                                <button type="button" class="btn btn-sm btn-light-primary ms-5" @click="refreshBalance"
                                    :disabled="isLoading">
                                    <i :class="`fas fa-sync ${isLoading ? 'fa-spin fa-fixed-spin' : ''}`"></i> Balance
                                </button>
                            </div>
                        </div>
                        <div class="separator my-2"></div>

                        <div class="tab-content" id="icto_wallet">
                            <div :class="`tab-pane fade ${activeTab == 'wallet_tokens' ? 'active show' : ''}`"
                                id="wallet_tokens" role="tabpanel">
                                <div class="py-1">
                                    <!--begin::Table container-->
                                    <div class="table-responsive">
                                        <!--begin::Table-->
                                        <table class="table table-row-dashed table-row-gray-300 align-middle gs-0 gy-4">
                                            <!--begin::Table head-->
                                            <thead>
                                                <tr class="fw-bolder text-muted">
                                                    <th class="min-w-200px">Token</th>
                                                    <th class="min-w-80px">Balance</th>
                                                    <th class="min-w-50px text-end">Actions</th>
                                                </tr>
                                            </thead>
                                            <!--end::Table head-->
                                            <!--begin::Table body-->
                                            <tbody>
                                                <tr v-for="token in storeAssets.assets" v-if="storeAssets">
                                                    <td>
                                                        <div class="d-flex align-items-center">
                                                            <div class="symbol symbol-45px me-5 symbol-circle">
                                                                <img :src="token.logo" :alt="token.symbol"
                                                                    v-if="token.logo">
                                                                <div v-else
                                                                    class="symbol-label fs-3 bg-light-primary text-primary">
                                                                    {{ token.symbol.charAt(0) }}</div>
                                                            </div>
                                                            <div class="d-flex justify-content-start flex-column">
                                                                <span
                                                                    class="text-dark fw-bolder text-hover-primary fs-6">
                                                                    {{ token.symbol }} <span
                                                                        class="badge badge-light-primary fw-bolder fs-8 px-2 py-1 ms-2">{{
                                                                        token.standard.toUpperCase() }}</span></span>
                                                                <span
                                                                    class="text-muted fw-bold text-muted d-block fs-7">
                                                                    {{ token.name }}
                                                                </span>
                                                            </div>
                                                        </div>
                                                    </td>
                                                    <td>
                                                        <span
                                                            class="text-dark fw-bolder text-hover-primary d-block fs-6">
                                                            {{ currencyFormat(token.balance) }}
                                                        </span>
                                                        <!-- <span class="text-muted fw-bold text-muted d-block fs-7">≈ ${{1231*0.54}}</span> -->
                                                    </td>
                                                    <td>
                                                        <div class="d-flex justify-content-end flex-shrink-0">
                                                            <a href="#" @click="transferToken(token)"
                                                                class="btn btn-light-primary btn-sm">
                                                                <i class="fas fa-paper-plane"></i> Transfer
                                                            </a>
                                                            <a href="#" @click="removeToken(token.canisterId)"
                                                                class="btn btn-light-danger btn-sm ms-2"
                                                                v-if="token.type != 'default'">
                                                                <i class="fas fa-minus"></i> Remove
                                                            </a>
                                                        </div>
                                                    </td>
                                                </tr>
                                            </tbody>
                                            <!--end::Table body-->
                                        </table>
                                        <!--end::Table-->
                                    </div>
                                </div>
                            </div>

                            <div :class="`tab-pane fade ${activeTab == 'wallet_nfts' ? 'active show' : ''}`" id="wallet_nfts"
                                role="tabpanel">
                                <!--begin::Accordion-->
                                <div class="accordion" id="kt_accordion_1">
                                    <div class="accordion-item">
                                        <h2 class="accordion-header" id="kt_accordion_1_header_1">
                                            <button class="accordion-button fs-6 fw-bold p-3" type="button"
                                                data-bs-toggle="collapse" data-bs-target="#kt_accordion_1_body_1"
                                                aria-expanded="true" aria-controls="kt_accordion_1_body_1">
                                                ICTO NFT Card <span
                                                    class="badge badge-circle badge-primary ms-2">6</span>
                                            </button>
                                        </h2>
                                        <div id="kt_accordion_1_body_1" class="accordion-collapse collapse show"
                                            aria-labelledby="kt_accordion_1_header_1" data-bs-parent="#kt_accordion_1">
                                            <div class="accordion-body-none">
                                                <div class="row p-3">
                                                    <div class="col-md-4 mb-5"
                                                        v-for="nft in ['common', 'uncommon', 'rare', 'veryrare', 'epic', 'legend']">
                                                        <NFTItem :nft="nft" :collectionInfo="collectionInfo"></NFTItem>
                                                    </div>
                                                </div>
                                            </div>
                                        </div>
                                    </div>

                                    <div class="accordion-item">
                                        <h2 class="accordion-header" id="kt_accordion_1_header_2">
                                            <button class="accordion-button fs-6 fw-bold collapsed p-3" type="button"
                                                data-bs-toggle="collapse" data-bs-target="#kt_accordion_1_body_2"
                                                aria-expanded="false" aria-controls="kt_accordion_1_body_2">
                                                MOTOKO Ghost
                                            </button>
                                        </h2>
                                        <div id="kt_accordion_1_body_2" class="accordion-collapse collapse"
                                            aria-labelledby="kt_accordion_1_header_2" data-bs-parent="#kt_accordion_1">
                                            <div class="accordion-body">
                                                ...
                                            </div>
                                        </div>
                                    </div>

                                    <div class="accordion-item">
                                        <h2 class="accordion-header" id="kt_accordion_1_header_3">
                                            <button class="accordion-button fs-6 fw-bold collapsed  p-3" type="button"
                                                data-bs-toggle="collapse" data-bs-target="#kt_accordion_1_body_3"
                                                aria-expanded="false" aria-controls="kt_accordion_1_body_3">
                                                BTC Flower
                                            </button>
                                        </h2>
                                        <div id="kt_accordion_1_body_3" class="accordion-collapse collapse"
                                            aria-labelledby="kt_accordion_1_header_3" data-bs-parent="#kt_accordion_1">
                                            <div class="accordion-body">
                                                ...
                                            </div>
                                        </div>
                                    </div>
                                </div>
                                <!--end::Accordion-->

                            </div>
                            <div :class="`tab-pane fade ${activeTab == 'wallet_airdrops' ? 'active show' : ''}`"
                                id="wallet_airdrops" role="tabpanel"> Coming soon </div>
                        </div>
                    </div>
                </div>
            </div>
            <div class="card-footer py-5 text-center" id="kt_activities_footer">
                <div class="d-flex flex-column gap-7 gap-md-10">
                    <button class="btn btn-sm btn-primary" type="button" @click="importToken()"><span
                            class="fw-bolder">+ Import Token</span> </button>
                </div>
            </div>
        </div>
    </div>
    <div style="z-index: 109;" class="drawer-overlay" v-if="openWallet" @click="closeWallet"></div>
</template>
<style scoped>
.fa-fixed-spin {
    -webkit-transform-origin: 35% 50%;
    -ms-transform-origin: 35% 50%;
    transform-origin: 35% 50%;
}
</style>