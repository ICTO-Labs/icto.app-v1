<script setup>
	import {onMounted, ref} from "vue";
	import { useGetTokenSupply, useGetTokenOwner, usetGetMetadata, useGetTransactions } from '@/services/Token';
	import { showModal, shortPrincipal, shortAccount } from '@/utils/common';
	import TokenChart from "@/components/token/TokenChart.vue";
	import {useRoute} from 'vue-router';
	import config from "@/config";
	import moment from "moment";
	import { currencyFormat } from "@/utils/token";

	const route = useRoute();
  	const tokenId = route.params.tokenId; // read parameter id (it is reactive) 
	const tokenInfo = ref(null);
	const isLoading = ref(false);
	const { data: tokenSupply, refetch: refetchSupply } = useGetTokenSupply(tokenId, 'icrc1');
	const { data: tokenOwner, refetch: refetchOwner } = useGetTokenOwner(tokenId, 'icrc1');
	const { data: tokenTransactions, isError, error, isLoading: isTransLoading, isRefetching: isTransRefetching, refetch: refreshTransactions } = useGetTransactions(tokenId, 'icrc2', 0, 10);

	const getTokenInfo = async()=>{
		let _tokenInfo = await usetGetMetadata(tokenId);
		isLoading.value = true;
		if("err" in _tokenInfo){
			showError('Canister not found or did not match the token standard: '+tokenStandard.value.toUpperCase());
		}else{
			tokenInfo.value = _tokenInfo;
		}
	}
	const transferToken = (action)=>{
		const newObj = {...tokenInfo.value};
		newObj.status = true;
		newObj.canisterId = tokenId;
		newObj.action = action;
		showModal("showTransferTokenModal", newObj);
	}

	onMounted(()=>{
		getTokenInfo();
	})
	
</script>
<template>
	<Toolbar :current="tokenInfo?tokenInfo.name:''" :parents="[{title: 'Tokens', to: '/my-token'}]" />
	<div class="d-flex flex-column flex-lg-row">
		<!--begin::Sidebar-->
		<div class="flex-column flex-lg-row-auto me-lg-10  w-lg-250px w-xl-300px mb-10 order-1 order-lg-1">
			<!--begin::Card-->
			<div class="card card-flush mb-0" data-kt-sticky="true" data-kt-sticky-name="subscription-summary" data-kt-sticky-offset="{default: false, lg: '200px'}" data-kt-sticky-width="{lg: '250px', xl: '300px'}" data-kt-sticky-left="auto" data-kt-sticky-top="150px" data-kt-sticky-animation="false" data-kt-sticky-zindex="95" style="">
				<!--begin::Card header-->
				<div class="card-header">
					<!--begin::Card title-->
					<div class="card-title">
						<h2>Token Info</h2>
					</div>
					<!--end::Card title-->
					<!--begin::Card toolbar-->
					<div class="card-toolbar">
						<!--begin::More options-->
						<button @click="getTokenInfo" class="btn btn-sm btn-light btn-icon" data-kt-menu-trigger="click" data-kt-menu-placement="bottom-end">
							<i class="fas fa-sync"></i>
						</button>
					</div>
					<!--end::Card toolbar-->
				</div>
				<!--end::Card header-->
				<!--begin::Card body-->
				<div class="card-body pt-0 fs-6">
					<!--begin::Section-->
					<div class="mb-7">
						<!--begin::Details-->
						<div class="d-flex align-items-center" v-if="tokenInfo">
							<div class="symbol symbol-50px symbol-circle me-3">
								<img src="https://psh4l-7qaaa-aaaap-qasia-cai.raw.icp0.io/6ytv5-fqaaa-aaaap-qblcq-cai.png" />
								<!-- <span class="symbol-label fs-2x fw-bold text-primary bg-light-primary">{{ tokenInfo?tokenInfo.symbol.charAt(0):'IC' }}</span> -->
							</div>
							<!--begin::Info-->
							<div class="d-flex flex-column">
								<!--begin::Name-->
								<div class="fs-4 fw-bolder text-gray-900 text-hover-primary me-2">{{ tokenInfo.name }}
									<div class="badge badge-light-primary ms-auto">{{tokenInfo.standard.toUpperCase()}}</div>
								</div>
								<!--end::Name-->
								<!--begin::Email-->
								<div class="fs-7 text-gray-600 text-hover-primary">{{tokenInfo.symbol }}</div>
								<!--end::Email-->
							</div>
							<!--end::Info-->
						</div>
						<!--end::Details-->
					</div>
					<div class="separator separator-dashed mb-7"></div>
					<div class="mb-7">
						<!--begin::Title-->
						<h5 class="mb-4">Token ID</h5>
						<div class="mb-0">
							<span class="fw-bold fs-7 text-primary">{{ tokenId }}</span> <Copy :text="tokenId"></Copy>
						</div>
						<!--end::Details-->
					</div>
					<div class="separator separator-dashed mb-7"></div>
					<div class="mb-0">
						<!--begin::Title-->
						<h5 class="mb-4">Token Data</h5>
						<table class="table fs-6 fw-bold gs-0 gy-2 gx-2">
							<tbody>
								<tr class="">
									<td class="text-gray-400">Total Supply:</td>
									<td class="text-gray-800"><span v-if="tokenInfo">{{currencyFormat(Number(tokenSupply)/Math.pow(10, tokenInfo.decimals))}}</span></td>
								</tr>
							<tr class="">
								<td class="text-gray-400">Decimals:</td>
								<td class="text-gray-800"><span v-if="tokenInfo">{{tokenInfo.decimals}}</span></td>
							</tr>
							<tr class="">
								<td class="text-gray-400">Transfer Fee:</td>
								<td>
									<span v-if="tokenInfo">{{tokenInfo.fee}}</span>
								</td>
							</tr>
							<tr class="">
								<td class="text-gray-400">Holders:</td>
								<td class="text-gray-800 w-50"><span v-if="tokenInfo">2</span></td>
							</tr>
							</tbody>
						</table>
					</div>
					<div class="separator separator-dashed mb-7"></div>
					<div class="mb-0">
						<h5 class="mb-4">Token Canister</h5>
						<table class="table fs-6 fw-bold gs-0 gy-2 gx-2 w-100">
							<tbody>
								<tr class="">
									<td class="text-gray-400">Cycles:</td>
									<td class="text-gray-800">3T</td>
								</tr>
								<tr class="">
									<td class="text-gray-400">Memory Size:</td>
									<td class="w-50">
										<span v-if="tokenInfo">102 MB</span>
									</td>
								</tr>
							</tbody>
						</table>
					</div>
				</div>
				<!--end::Card body-->
			</div>
			<!--end::Card-->
		</div>
		<div class="flex-lg-row-fluid order-2 order-lg-2 mb-lg-0">
			<div class="card card-flush pt-3 mb-10 mb-xl-10">
				<div class="card-header">
					<div class="card-title">
						<h2 class="fw-bolder">Token overview</h2>
					</div>
					<div class="card-toolbar">
						<button type="button" class="btn btn-sm btn-primary me-2">Swap <i class="fas fa-exchange-alt"></i></button>
						<button type="button" class="btn btn-sm btn-light-primary me-2" @click="transferToken('transfer')">Mint <i class="fas fa-paper-plane"></i></button>
						<button type="button" class="btn btn-sm btn-light-danger" @click="transferToken('burn')">Burn <i class="fas fa-burn"></i></button>
					</div>
				</div>
				<div class="card-body pt-0">
					<div class="mb-0">
						<div class="d-flex flex-wrap py-5">
							<div class="flex-equal me-5 table-responsive">
								<table class="table fs-6 fw-bold gs-0 gy-2 gx-2 m-0">
									<tbody>
										<tr>
											<td class="text-gray-400 min-w-175px w-175px">Token Owner:</td>
											<td class="text-gray-800 min-w-200px">
												<a href="#" class="text-gray-800 text-hover-primary" v-if="tokenOwner">{{ tokenOwner.principal }}</a> <Copy  v-if="tokenOwner" :text="tokenOwner.principal"></Copy>
											</td>
										</tr>
										<tr>
											<td class="text-gray-400"></td>
											<td class="text-gray-800"><a href="" class="text-gray-800 text-hover-primary" v-if="tokenOwner">{{ tokenOwner.subaccount }}</a> <Copy  v-if="tokenOwner" :text="tokenOwner.subaccount"></Copy></td>
										</tr>
										<tr>
											<td class="text-gray-400">Controller(s):</td>
											<td class="text-gray-800 text-hover-primary" v-if="tokenOwner">mcccp-fqaaa-aaaap-qanfq-cai  <Copy :text="tokenOwner.principal"></Copy></td>
										</tr>
										<tr><td colspan="2">
											<div class="separator separator-dashed mb-7"></div>
										</td></tr>
										<tr>
											<td class="text-gray-400">Price:</td>
											<td class="text-success">$---</td>
										</tr>
										<tr>
											<td class="text-gray-400">Market Cap:</td>
											<td class="text-success">$----</td>
										</tr>
								</tbody></table>
							</div>
						</div>

						<TokenChart />
						<!--end::Row-->
					</div>
				</div>
			</div>
			<div class="card card-flush pt-3 mb-5 mb-xl-10">
				<!--begin::Card header-->
				<div class="card-header">
					<!--begin::Card title-->
					<div class="card-title">
						<h2 class="fw-bolder">Transactions</h2>
					</div>
					<!--begin::Card title-->
					<div class="card-toolbar">
						<button type="button" class="btn btn-sm btn-light-primary" @click="refreshTransactions" :disabled="isTransLoading || isTransRefetching">{{isTransLoading || isTransRefetching?'Loading...':'Refresh'}}</button>
					</div>
				
				</div>
				<!--end::Card header-->
				<!--begin::Card body-->
				<div class="card-body pt-3">
					<div class="mb-10">
						<!--begin::Product table-->
						<div class="table-responsive">
							<!--begin::Table-->
							<table class="table align-middle table-row-dashed fs-6 gy-4 mb-0">
								<!--begin::Table head-->
								<thead>
									<!--begin::Table row-->
									<tr class="border-bottom border-gray-200 text-start text-gray-400 fw-bolder fs-7 text-uppercase gs-0">
										<th class="min-w-80px">Kind</th>
										<th class="min-w-150px">From</th>
										<th class="min-w-125px">To</th>
										<th class="min-w-125px text-end">Amount</th>
										<th class="min-w-125px text-end">Time</th>
									</tr>
									<!--end::Table row-->
								</thead>
								<!--end::Table head-->
								<!--begin::Table body-->
								<tbody class="fw-bold text-gray-800">
									<!-- <div v-if="isTransLoading || isTransRefetching">Loading...</div>
									<div v-if="isError">{{ error }}</div> -->
									<tr v-if="tokenTransactions" v-for="tran in tokenTransactions.transactions">
										<td>
											<span :class="`badge badge-light-${tran.kind=='BURN'?'danger':tran.kind=='TRANSFER'?'success':'primary'}`">{{tran.kind}}</span>
										</td>
										<td>
											<label class="w-150px"><ClickToCopy :text="tran.from.principal">{{tran.kind=='MINT'?'...':shortPrincipal(tran.from.principal)}}</ClickToCopy></label>
											<div class="fw-normal text-gray-600"><ClickToCopy :text="tran.from.subaccount">{{shortAccount(tran.from.subaccount)}}</ClickToCopy></div>
										</td>
										<td>
											<label class="w-150px"><ClickToCopy :text="tran.to.principal">{{tran.kind=='BURN'?'...':shortPrincipal(tran.to.principal)}}</ClickToCopy></label>
											<div class="fw-normal text-gray-600"><ClickToCopy :text="tran.to.subaccount">{{shortAccount(tran.to.subaccount)}}</ClickToCopy></div>
										</td>
										<td class="text-end">{{currencyFormat((tran.amount/config.E8S))}}</td>
										<td class="text-end">
											{{moment.unix(tran.timestamp).format("lll")}}
										</td>
									</tr>
								</tbody>
								<!--end::Table body-->
							</table>
							<!--end::Table-->
						</div>
						<!--end::Product table-->
					</div>
					<!--end::Section-->
				</div>
				<!--end::Card body-->
			</div>
			<!--end::Card-->
			
		</div>
		<!--end::Content-->
		
	</div>
</template>