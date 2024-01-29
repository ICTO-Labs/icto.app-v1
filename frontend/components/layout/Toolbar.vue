<script setup>
	import { ref } from 'vue';
	import { showModal} from "@/utils/common";
	import { useRoute } from 'vue-router';
	const props = defineProps(['current', 'parents', 'modal']);
	const router = useRoute();
	import walletStore from "@/store";
	const btnLabel = ref('');
	const btnIcon = ref('');
	const modalName = ref('');
	if(props.modal){
		btnLabel.value = props.modal.label;
		btnIcon.value = props.modal.icon;
		modalName.value = props.modal.modal;
	}
	const showWallet = ()=>{	
		walletStore.isLogged ? showModal('showWalletModal', true) : showModal('showLoginModal', true);	
	}
	const showBtnModal = ()=>{
		if(props.modal){
			walletStore.isLogged ? showModal(modalName.value, true) : showModal('showLoginModal', true);
		}
		showModal('showLiquidityLocksModal', {status: true})
	}
</script>
<template>
    <!--begin::Toolbar-->
    <div class="p-2 mt-5 mb-5 px-0 " id="kt_toolbar">
		<!--begin::Container-->
		<div id="kt_toolbar_container" class="w-100 d-flex flex-stack">
			<!--begin::Page title-->
			<div data-kt-swapper="true" data-kt-swapper-mode="prepend" data-kt-swapper-parent="{default: '#kt_content_container', 'lg': '#kt_toolbar_container'}" class="page-title d-flex align-items-center flex-wrap me-3 mb-5 mb-lg-0">
				<!--begin::Breadcrumb-->
				<ul class="breadcrumb fw-bold fs-7 my-1">
					<!--begin::Item-->
					<li class="breadcrumb-item text-muted">
						<router-link to="/" class="text-muted text-hover-primary" title="Home"><i class="fas fa-home me-1"></i>Home</router-link>
					</li>
					<!--end::Item-->
					<!--begin::Item-->
					<li class="breadcrumb-item text-muted" v-for="nav in props.parents">
						<router-link :to="nav.to" class="text-muted text-hover-primary" :title="nav.title">{{ nav.title }}</router-link>
					</li>
					<!--end::Item-->
					<!--begin::Item-->
					<li class="breadcrumb-item ">{{ props.current }}</li>
					<!--end::Item-->
				</ul>
				<!--end::Breadcrumb-->
			</div>
			<!--end::Page title-->
			<!--begin::Actions-->
			<div class="d-flex align-items-center py-1">
				<!-- <router-link to="/new-contract" class="btn btn-sm btn-danger me-2">New Contract</router-link> -->
				<a href="#" @click.stop="showBtnModal" class="btn btn-sm btn-danger me-2" v-if="props.modal"><i :class="`fas ${btnIcon}`"></i> {{btnLabel}}</a> 
				<a href="#" @click.stop="showWallet" class="btn btn-sm btn-primary me-2"><i class="fas fa-wallet"></i> My Wallet</a> 
				<!-- <a href="#" @click="showProgress" class="btn btn-sm btn-light-info me-2">
					<span >
						<i class="fas fa-tasks"></i> 
						Buying...
						<span class="spinner-border spinner-border-sm align-middle ms-2"></span>
					</span>
				</a> -->
			</div>
			<!--end::Actions-->
		</div>
	</div>
	<!--end::Toolbar-->
</template>