<script setup>
import { showModal} from "@/utils/common";
import { useRoute } from 'vue-router';
const router = useRoute();

const showWallet = ()=>{
	showModal('showWalletModal', true);
}
const showProgress = ()=>{
	showModal('showProcessBuyingModal', {status: true})
}
</script>
<template>
    <!--begin::Toolbar-->
    <div class="toolbar" id="kt_toolbar">
		<!--begin::Container-->
		<div id="kt_toolbar_container" class="container-xxl d-flex flex-stack">
			<!--begin::Page title-->
			<div data-kt-swapper="true" data-kt-swapper-mode="prepend" data-kt-swapper-parent="{default: '#kt_content_container', 'lg': '#kt_toolbar_container'}" class="page-title d-flex align-items-center flex-wrap me-3 mb-5 mb-lg-0">
				<!--begin::Title-->
				<h1 class="d-flex align-items-center text-dark fw-bolder fs-3 my-1">{{ router.meta.title }}</h1>
				<!--end::Title-->
				<!--begin::Separator-->
				<span class="h-20px border-gray-200 border-start mx-4"></span>
				<!--end::Separator-->
				<!--begin::Breadcrumb-->
				<ul class="breadcrumb  fw-bold fs-7 my-1">
					<!--begin::Item-->
					<li class="breadcrumb-item text-muted">
						<router-link to="/" class="text-muted text-hover-primary" title="Home">Home</router-link>
					</li>
					<!--end::Item-->
					<!--begin::Item-->
					<li class="breadcrumb-item text-muted" v-for="nav in router.meta.navs">
						<router-link :to="nav.to" class="text-muted text-hover-primary" :title="nav.title">{{ nav.title }}</router-link>
					</li>
					<!--end::Item-->
					<!--begin::Item-->
					<li class="breadcrumb-item text-dark">{{ router.meta.title }}</li>
					<!--end::Item-->
				</ul>
				<!--end::Breadcrumb-->
			</div>
			<!--end::Page title-->
			<!--begin::Actions-->
			<div class="d-flex align-items-center py-1">
				<router-link to="/new-contract" class="btn btn-sm btn-light-danger me-2">New Contract</router-link>
				<a href="#" @click="showWallet" class="btn btn-sm btn-light-primary me-2"><i class="fas fa-wallet"></i> My Wallet</a> 
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