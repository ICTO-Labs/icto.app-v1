<script setup>
import { watchEffect } from "vue";
import walletStore from "@/store";
import LoadingLabel from "@/components/LoadingLabel.vue"
import { showModal, isAnonymous } from '@/utils/common';
import Arrow from "./icons/Arrow.vue";
watchEffect(() => {
	if(walletStore.isLogged && !walletStore.principal && isAnonymous(walletStore.principal)){
		walletStore.logout();
	}
});

import _api from "@/ic/api";

const logout = ()=>{
	Swal.fire({
		title: "Are you sure?",
		text: "Logout and delete this session!",
		icon: "warning",
		showCancelButton: true,
		confirmButtonColor: "#3085d6",
		cancelButtonColor: "#d33",
		confirmButtonText: "Yes, log me out!"
		}).then(async (result) => {
			if(result.isConfirmed){
				await walletStore.logout()
			}
		});
}

const login = ()=>{
	showModal('showLoginModal', true);
}

const showWallet = ()=>{
	walletStore.isLogged ? showModal('showWalletModal', true) : showModal('showLoginModal', true);	
}

</script>

<template>

    <!--begin::User-->
	<div class="d-flex align-items-center ms-1 ms-lg-3">
		<!--begin::Menu wrapper-->
		<div class="position-relative  p-2 rounded" id="kt_drawer_chat_toggle" data-bs-toggle="tooltip" data-bs-placement="bottom" title="" :data-bs-original-title="`Source: CoinGecko`">
			<!--begin::Svg Icon | path: icons/duotune/communication/com012.svg-->
			<span class="fw-bold">ICP:</span> <span :class="`${walletStore.priceChange>0?'text-success':'text-danger'}`">${{ walletStore.icpPrice }}</span>
			<Arrow :type="walletStore.priceChange > 0 ? 'up': 'down'" :size="4"/>
			<!--end::Svg Icon-->
			<!-- <span :class="`bullet bullet-dot ${walletStore.priceChange>0?'bg-success':'bg-danger'} h-6px w-6px position-absolute translate-middle top-0 start-0 animation-blink`"></span> -->
		</div>
		<!--end::Menu wrapper-->
	</div>
    <div class="d-flex align-items-center ms-1 ms-lg-3" id="kt_header_user_menu_toggle">
		<!--begin::Menu wrapper-->
		<div class="cursor-pointer symbol symbol-30px symbol-md-40px" data-kt-menu-trigger="click" data-kt-menu-attach="parent" data-kt-menu-placement="bottom-end">
			<button v-if="!walletStore.isLogged || walletStore.isLogged === false" class="btn btn-sm btn-danger" @click="login()">Connect <i class="fas fa-chevron-circle-right"></i></button>
			<button v-if="walletStore.isLogged || walletStore.isLogged == 'true'" class="btn btn-sm btn-primary" @click.stop="showWallet"><span class="fw-bolder"><i class="fas fa-wallet"></i> My Wallet</span> </button>
			
		</div>
		
		<!--end::Menu wrapper-->
	</div>
	<!--end::User -->
</template>