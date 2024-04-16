<script setup>
	import {onMounted, ref} from "vue";
	import { useGetDeployerTokens } from '@/services/Token';
	import { showModal, showLoading, showSuccess } from '@/utils/common';
	const myToken = ref([]);
	const showMyTokens = ref(false);
	const isLoading = ref(false);
	// const { data: myToken, isLoading, isError, error, isRefetching, refetch} = useGetUserTokens(0, router.query.me);
	const deployToken = ()=>{
		showModal("showDeployTokenModal", true);
	}
	const mintToken = (token)=>{
		const newObj = {...token};
		newObj.status = true;
		newObj.canisterId = token.canister;
		showModal("showTransferTokenModal", newObj);
	}
	const filter = (e)=>{
		showMyTokens.value = e.target.checked;
		console.log('showMyTokens.value', showMyTokens.value);
		getTokens();
	}
	const getTokens = async ()=>{
		isLoading.value = true;
		myToken.value = await useGetDeployerTokens(0, showMyTokens.value);
		isLoading.value = false;
	}
	onMounted(()=>{
		getTokens();
	})
</script>
<template>
	<Toolbar :current="`Tokens`" :showBtn="{modal: 'showDeployTokenModal', icon: 'fa-angle-double-up', label: 'Deploy Token'}"/>

	<div class="card card-xl-stretch mb-5 mb-xl-10">
	<div class="card-header border-0 pt-5">
		<h3 class="card-title align-items-start flex-column">
			<span class="card-label fw-bolder fs-3 mb-1">Tokens <span class="badge badge-light-primary">{{ myToken?myToken.length:0 }}</span></span>
			<span class="text-muted mt-1 fw-bold fs-7" v-if="isLoading">Loading...</span>
		</h3>
		<div class="card-toolbar">
			<ul class="nav">
				<li class="nav-item me-5">
					<div class="form-check form-switch pt-2">
						<input class="form-check-input" type="checkbox" value="" id="myTokens" @change="filter"/>
						<label class="form-check-label" for="myTokens">
							Show only my tokens
						</label>
					</div>
				</li>
				<li class="nav-item">
					
					<a href="#" class="btn btn-sm btn-bg-light btn-active-dark me-3" @click="getTokens()" :disabled="isLoading">{{isLoading?'Loading...':'Refresh'}}</a>
					<!-- <a href="#" class="btn btn-sm btn-danger btn-active-dark me-3" @click="deployToken()" ><i class="fas fa-angle-double-up"></i> Deploy Token</a> -->
				</li>
				
			</ul>
		</div>
	</div>
	<div class="card-body py-3">
		<div class="table-responsive" >
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
							<div class="symbol symbol-45px symbol-circle">
								<span class="symbol-label fs-2x fw-bold text-primary bg-light-primary" v-if="token && token.logo">
									<img :src="token?.logo" class="w-100"/>
								</span>
							</div>
						</td>
						<td>
							<router-link :to="`/token/${token.canister}`" class="text-dark fw-bold text-hover-primary mb-1 fs-6">{{ token?.name }}</router-link>
						</td>
						<td class="text-dark fs-6 fw-bold">{{ token?.symbol }}</td>
						<td class="text-muted fw-bold">{{ token?.canister }} <Copy :text="token.canister"></Copy></td>
						<td class="">
							<span class="badge badge-primary">ICRC2</span>
						</td>
						<td class="">
							
							<a href="#" class="btn btn-sm btn-bg-light me-2 btn-active-color-primary" @click="mintToken(token)">Mint <i class="fas fa-paper-plane"></i></a>
							<router-link :to="`/token/${token?.canister}`" class="btn btn-sm btn-icon btn-bg-light btn-active-color-primary">
								<i class="fas fa-arrow-right"></i>
							</router-link>
						</td>
					</tr>
				</tbody>
				<!--end::Table body-->
			</table>
			<Empty v-if="myToken && myToken.length ==0"></Empty>
		</div>
	</div>
	<!--end::Body-->
</div>
	
</template>