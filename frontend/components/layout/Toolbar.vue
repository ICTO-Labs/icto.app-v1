<script setup>
import { useRoute } from 'vue-router';
const router = useRoute();
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
					<!-- <li class="breadcrumb-item">
						<span class="bullet bg-gray-200 w-5px h-2px"></span>
					</li> -->
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
				<router-link to="/new-contract" class="btn btn-sm btn-primary" v-if="router.name != 'new-contract'">New Contract</router-link>
			</div>
			<!--end::Actions-->
		</div>
	</div>
	<!--end::Toolbar-->
</template>