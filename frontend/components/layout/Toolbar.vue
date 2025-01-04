<script setup>
	import { ref } from 'vue';
	import { showModal} from "@/utils/common";
	import { useRoute } from 'vue-router';
	const props = defineProps(['current', 'parents', 'showBtn']);
	const router = useRoute();
	import walletStore from "@/store";
	const toolbarProps = ref({
		label: '',
		icon: '',
		modal: '',
		css: 'btn-danger'
	});
	if(props.showBtn){
		toolbarProps.value = props.showBtn;
		console.log('toolbarProps,', toolbarProps.value, props.showBtn);
	}
	const showWallet = ()=>{	
		walletStore.isLogged ? showModal('showWalletModal', true) : showModal('showLoginModal', true);	
	}
	const showBtnModal = ()=>{
		if(props.showBtn){
			walletStore.isLogged ? showModal(''+toolbarProps.value.modal+'', true) : showModal('showLoginModal', true);
		}
		showModal('showLiquidityLocksModal', {status: true})
	}
	console.log('router', router);
</script>
<template>
    <!--begin::Toolbar-->
    <div class="toolbar" id="kt_toolbar">
		<!--begin::Container-->
		<div id="kt_toolbar_container" class="container-xxl d-flex flex-stack">
			<!--begin::Page title-->
			<div data-kt-swapper="false" data-kt-swapper-mode="prepend" data-kt-swapper-parent="{default: '#kt_content_container', 'lg': '#kt_toolbar_container'}" class="page-title d-flex align-items-center flex-wrap me-3 mb-0 mb-lg-0">
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
				<a href="#" @click.stop="showBtnModal" :class="`btn btn-sm me-2 ${toolbarProps.css?toolbarProps.css:'btn-danger'}`" v-if="props.showBtn"><i :class="`fas ${toolbarProps.icon}`"></i> {{toolbarProps.label}}</a> 
				<router-link to="/token-claim/create" class="btn btn-sm btn-danger me-2" v-if="router.name =='token-claim' || router.name =='contract-detail'">New Contract</router-link>
				<router-link to="/launchpad/create" class="btn btn-sm btn-danger me-2" v-if="router.name =='launchpad' || router.name =='launchpad-detail'"><i class="fas fa-rocket"></i> Create</router-link>
				<!-- <a href="#" @click.stop="showWallet" class="btn btn-sm btn-primary me-2"><i class="fas fa-wallet"></i> My Wallet</a>  -->
			</div>
			<!--end::Actions-->
		</div>
	</div>
	<!--end::Toolbar-->
</template>