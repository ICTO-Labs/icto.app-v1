<script setup>
	import {ref} from "vue";
	import { useGetUserTokens } from '@/services/Token';
	import { showModal, showLoading, showSuccess } from '@/utils/common';
	import Copy from '@/components/icons/Copy.vue'
	const { data: myToken, isLoading, isError, error, isRefetching, refetch} = useGetUserTokens(0);
	const deployToken = ()=>{
		showModal("showDeployTokenModal", true);
	}
	const mintToken = (token)=>{
		const newObj = {...token};
		newObj.status = true;
		showModal("showManageTokenModal", newObj);
	}
</script>
<template>
	<div class="card card-xl-stretch mb-5 mb-xl-10">
	<div class="card-header border-0 pt-5">
		<h3 class="card-title align-items-start flex-column">
			<span class="card-label fw-bolder fs-3 mb-1">My Tokens <span class="badge badge-light-primary">{{ myToken?myToken.length:0 }}</span></span>
			<span class="text-muted mt-1 fw-bold fs-7" v-if="isLoading">Loading...</span>
			<span class="text-muted mt-1 fw-bold fs-7" v-if="isError">{{ error }}</span>
		</h3>
		<div class="card-toolbar">
			<ul class="nav">
				<li class="nav-item">
					<a href="#" class="btn btn-sm btn-bg-light btn-active-dark me-3" @click="refetch()" :disabled="isRefetching">{{isRefetching?'Loading...':'Refresh'}}</a>
					<a href="#" class="btn btn-sm btn-primary btn-active-dark me-3" @click="deployToken()" >Deploy Token</a>
				</li>
				
			</ul>
		</div>
	</div>
	<div class="card-body py-3">
		<div class="table-responsive">
			<table class="table table-row-dashed table-row-gray-200 align-middle gs-0 gy-4">
				<thead>
					<tr class="fw-400 fw-bold">
						<th class="w-50px">#</th>
						<th class="min-w-150px">Token Name</th>
						<th class="min-w-150px">Token Symbol</th>
						<th class="min-w-140px">Canister ID</th>
						<th class="min-w-110px">Standard</th>
						<th class="min-w-50px">Manage</th>
					</tr>
				</thead>
				<tbody>
					<tr v-for="token in myToken">
						<td>
							<div class="symbol symbol-65px symbol-circle">
								<span class="symbol-label fs-2x fw-bold text-primary bg-light-primary">{{ token.symbol.charAt(0) }}</span>
							</div>
						</td>
						<td>
							<router-link :to="`/token/${token.canister}`" class="text-dark fw-bold text-hover-primary mb-1 fs-6">{{ token.name }}</router-link>
							<span class="text-muted fw-bold d-block">{{ token.description }}</span>
						</td>
						<td class="text-dark fs-6 fw-bold">{{ token.symbol }}</td>
						<td class="text-muted fw-bold">{{ token.canister }} <Copy :text="token.canister"></Copy></td>
						<td class="">
							<span class="badge badge-primary">ICRC3</span>
						</td>
						<td class="">
							<router-link :to="`/token/${token.canister}`" class="btn btn-sm btn-icon btn-bg-light btn-active-color-primary">
								<!--begin::Svg Icon | path: icons/duotune/arrows/arr064.svg-->
								<span class="svg-icon svg-icon-2">
									<svg xmlns="http://www.w3.org/2000/svg" width="24" height="24" viewBox="0 0 24 24" fill="none">
										<rect opacity="0.5" x="18" y="13" width="13" height="2" rx="1" transform="rotate(-180 18 13)" fill="black"></rect>
										<path d="M15.4343 12.5657L11.25 16.75C10.8358 17.1642 10.8358 17.8358 11.25 18.25C11.6642 18.6642 12.3358 18.6642 12.75 18.25L18.2929 12.7071C18.6834 12.3166 18.6834 11.6834 18.2929 11.2929L12.75 5.75C12.3358 5.33579 11.6642 5.33579 11.25 5.75C10.8358 6.16421 10.8358 6.83579 11.25 7.25L15.4343 11.4343C15.7467 11.7467 15.7467 12.2533 15.4343 12.5657Z" fill="black"></path>
									</svg>
								</span>
								<!--end::Svg Icon-->
							</router-link>
							<a href="#" class="btn btn-sm btn-icon" @click="mintToken(token)"><em class="fas fa-send"></em> Mint</a>
						</td>
					</tr>
				</tbody>
				<!--end::Table body-->
			</table>
		</div>
	</div>
	<!--end::Body-->
</div>
	
</template>