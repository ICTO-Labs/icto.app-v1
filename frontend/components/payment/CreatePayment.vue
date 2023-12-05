<script setup>
	import {ref, computed} from "vue";
	import {validateAddress, showError} from "@/utils/common"
	import {currencyFormat} from "@/utils/token"
	import { useWalletStore } from '@/stores/wallet'
    import LoadingLabel from "@/components/LoadingLabel.vue"
	import EventBus from "@/services/EventBus";
	import { useAssetStore } from "@/stores/token";
	import { getMyBalance  } from "@/utils/token";
	
	const isLoading = ref(false);
	const storeAsset = useAssetStore();
	const walletStore = useWalletStore();
	const token = ref({symbol: 'icp', name: 'Internet Computer', canisterId: 'ryjl3-tyaaa-aaaaa-aaaba-cai', standard: 'ledger'});
	const tokenBalance = ref(walletStore.wallet.balance);
	const totalAmount = ref(0);
	const newRecipient = ref({amount:"", address: "6102c39ede652286711a1019b6e2e67c0b765241db23b3e96b9f203b6174e6a2", title: "", note: ""});
	const recipients = ref([]);

	const contractData = ref({
		startNow: true,
		startDate: new Date(),
		startTime: new Date(),
		durationValue: 1,
		durationTime: 2628002,
		unlockSchedule: 86400,
		recipients: [],
		canView: 'both',
		canCancel: 'neither',
		canChange: 'neither',
	})
	const setSelectedToken = async ()=>{
		resetRecipients();
		tokenBalance.value = 0;
		await getTokenBalance();
	}
	const calTotalToken = ()=>{
		totalAmount.value = recipients.value.reduce((acc,cur) => acc + cur.amount, 0);
	}
	const getTokenBalance = async ()=>{
		isLoading.value = true;
		totalAmount.value = 0;
		let _balance = await getMyBalance(token.value.canisterId, 'icrc-1');
		tokenBalance.value = Number(_balance)/100_000_000;
		isLoading.value = false;
		console.log('_balance', _balance);
	}
	const resetInput = ()=>{
		newRecipient.value = {amount:"", address: "", title: "", note: ""};
	}
	const resetRecipients = ()=>{ recipients.value = []};
	const removeRecipient = (idx)=>{
		recipients.value.splice(idx, 1);
		calTotalToken();
	}
	const addRecipient = ()=>{
		if(!validateAddress(newRecipient.value.address.trim())){
			showError("Recipient wallet address is not valid!");
			return;
		}
		if(newRecipient.value.amount <= 0 || newRecipient.value.amount > (tokenBalance.value-totalAmount.value)){
			showError("Not enough "+token.value.symbol+", check remaining amount!");
			return;
		}
		recipients.value.push({address:newRecipient.value.address.trim(), amount: newRecipient.value.amount, title: newRecipient.value.title??"", note:newRecipient.value.note??""})
		resetInput();
		calTotalToken();
	}
	const importToken = ()=>{
		EventBus.emit("showImportTokenModal", true)
	}
	
	const tokenInfo = computed(()=>{
		return token.value;
	})

	const reviewContract = ()=>{
		if(recipients.value.length == 0){
			showError("No recipient!")
			return;
		}
		contractData.value.recipients = recipients.value;
		contractData.value.token = token.value;
		contractData.value.totalAmount = totalAmount.value;
		console.log('contractData', contractData.value);
		EventBus.emit("showContractDetailsModal", {...contractData.value, status: true})
	}
</script>
<template>
	<div class="card  mb-xl-8">
		<div class="card-header align-items-center">
			<label class="fs-4 fw-bold form-label mb-2 text-primary">Create New Contract</label>
		</div>
		<div class="card-body pt-5">
			<form class="form" id="modal-create-contract">
				<!--begin::Step 1-->
				<div class="current" data-kt-stepper-element="content">
					<div class="w-100">
						<div class="row mb-10">
							<div class="col-md-6 fv-row">
								<label class="d-flex align-items-center fs-6 fw-bold mb-2">
									<span class="required">Token</span> 
									<i class="fas fa-exclamation-circle ms-2 fs-7" data-bs-toggle="tooltip" title="Specify your Token"></i>
									<a href="#" class="badge badge-light-primary ms-5" @click="importToken">+ Import</a>

									</label>
									<select class="form-select" @change="setSelectedToken" v-model="token" placeholder="Select token">
										<option :value="{symbol: 'icp', name: 'Internet Computer', canisterId: 'ryjl3-tyaaa-aaaaa-aaaba-cai', standard: 'ledger'}" selected>Internet Computer (ICP)</option>
										<option :value="asset" v-for="asset in storeAsset.assets"  :key="asset.canisterId">{{ asset.name }} ({{ asset.symbol }}) | {{ asset.canisterId }}</option>
									</select>
							</div>
							<div class="col-md-6 fv-row">
								<label class="fs-6 fw-bold form-label mb-2">Balance
									<LoadingLabel 
										:loading="isLoading"
										class="badge badge-light-primary ms-5"
										@click="getTokenBalance"><i class="fas fa-arrows-rotate"></i> Refresh
									</LoadingLabel>

								</label>
								<input type="text" readonly class="form-control form-control-solid" :value="currencyFormat(tokenBalance)">
							</div>
						</div>
						<div class="row mb-10">
							<div class="col-md-6 fv-row">
								<label class="required fs-6 fw-bold form-label mb-2">Duration</label>
								<div class="row fv-row">
									<div class="col-4">
										<input type="text" class="form-control" v-model="contractData.durationValue"/>
									</div>
									<div class="col-8">
										<select name="duration" class="form-select" data-hide-search="true" data-placeholder="Month" v-model="contractData.durationTime">
											<option value="1">Second</option>
											<option value="60">Minute</option>
											<option value="3600">Hour</option>
											<option value="86400">Day</option>
											<option value="604800">Week</option>
											<option value="2628002" selected>Month</option>
											<option value="7884006">Quarter</option>
											<option value="31536000">Year</option>
										</select>
									</div>
								</div>
							</div>
							<div class="col-md-6 fv-row">
								<label class="required fs-6 fw-bold form-label mb-2">Unlock schedule</label>
								<div class="row fv-row">
									<div class="col-12">
										<select name="releaseFrequencyPeriod" class="form-select" v-model="contractData.unlockSchedule">
											<option value="1">Per Second</option>
											<option value="60">Per Minute</option>
											<option value="3600">Hourly</option>
											<option value="86400">Daily</option>
											<option value="604800">Weekly</option>
											<option value="2628002">Monthly</option>
											<option value="7884006">Quarterly</option>
											<option value="31536000">Yearly</option>
										</select>
									</div>
								</div>
							</div>
						</div>


					</div>
				</div>
			</form>
		</div>
	</div>
	
	<div class="card mb-xl-8" >
		<div class="card-header align-items-center">
			<label class="fs-4 fw-bold form-label mb-2 text-primary">Recipients <span class="badge badge-light-primary">{{recipients.length}}</span></label>
			<div class="card-toolbar">
				<div class="d-flex">
					<div class="fw-bolder fs-2 text-primary px-10">
						{{currencyFormat(tokenBalance)}}
						<span class="text-muted fs-4 fw-bold">{{tokenInfo.symbol.toUpperCase()}}</span>
						<div class="fs-7 fw-normal text-muted">
							Your balance
							<LoadingLabel 
										:loading="isLoading"
										class="badge badge-light-primary ms-5"
										@click="getTokenBalance"><i class="fas fa-arrows-rotate"></i> Refresh
							</LoadingLabel>
						</div>
					</div>
					<div class="fw-bolder fs-2 text-success px-10">
						{{currencyFormat((tokenBalance - totalAmount))}}
						<span class="text-muted fs-4 fw-bold">{{tokenInfo.symbol.toUpperCase()}}</span>
						<div class="fs-7 fw-normal text-muted">Remaining amount</div>
					</div>
					<div class="fw-bolder fs-2 text-danger px-10">
						{{currencyFormat(totalAmount)}}
						<span class="text-muted fs-4 fw-bold">{{tokenInfo.symbol.toUpperCase()}}</span>
						<div class="fs-7 fw-normal text-muted">Will be sent</div>
					</div>
				</div>
			</div>

		</div>
		<div class="card-body pt-5">
			<div class="table-responsive">
				<table class="table align-middle table-row-bordered gs-0 gy-4">
					<thead>
					<tr class="fw-bolder text-muted bg-light">
						<th class="ps-4 min-w-25px rounded-start">#</th>
						<th class="w-120px text-end">Amount</th>
						<th class="min-w-400px required">Address</th>
						<th class="min-w-50px">Title</th>
						<th class="min-w-100px">Note</th>
						<th class="w-100px text-end rounded-end"></th>
					</tr>
					</thead>
					<tbody>
					<tr v-if="recipients.length == 0">
						<td colspan="6" class="bg-white">
							<div class="fw-bold text-danger">No recipient!</div>
						</td>
					</tr>
					<tr v-else v-for="(recipient, idx) in recipients">
						<td>
							<span class="badge badge-light-primary">#{{idx+1}}</span>
						</td>
						<td>
							<span class="text-muted fw-bold text-muted d-block fs-7 text-end">
								{{currencyFormat(recipient.amount)}} {{tokenInfo.symbol.toUpperCase()}}
							</span>
						</td>
						<td>
							<span class="text-muted fw-bold text-muted d-block fs-7">
								{{recipient.address}}
							</span>
						</td>
						<td>
							<span class="text-muted text-muted d-block fs-7">
								{{recipient.title}}
							</span>
						</td>
						<td>
							<span class="text-muted text-muted d-block fs-7">
								{{recipient.note}}
							</span>
						</td>
						<td class="text-center">
							<button type="button" class="btn btn-icon btn-danger btn-sm" @click="removeRecipient(idx)">
								<i class="fas fa-trash"></i>
							</button>
						</td>
					</tr>
					</tbody>
					<tfoot>
					<tr class="bg-light ">
						<td class="">
							<span class="badge badge-light-success">New</span>
						</td>
						<td>
							<label class="required fs-7 form-label mb-2">Amount</label>
							<input type="number" class="form-control form-control-sm text-red" v-model="newRecipient.amount" min="0" placeholder="---">
						</td>
						<td>
							<label class="required fs-7 form-label mb-2">Recipient wallet address</label>
							<input type="text" class="form-control form-control-sm d-block" v-model="newRecipient.address" placeholder="Address (Account ID)" ref="address">
						</td>
						<td>
							<label class=" fs-7 form-label mb-2">Title (option)</label>
							<input type="text" class="form-control form-control-sm mb-1" v-model="newRecipient.title" placeholder="Title or name, eg: Seed round">
						</td>
						<td>
							<label class=" fs-7 form-label mb-2">Note (option)</label>
							<span class="text-muted fw-bold text-muted d-block fs-7">
								<input type="text" class="form-control d-block form-control-sm"  v-model="newRecipient.note" placeholder="Note">
							</span>
						</td>
						<td class="text-end">
							<label class="fs-7 form-label mb-2">&nbsp;</label>
							<button type="button" class="btn btn-primary d-block btn-sm px-4 me-2" @click="addRecipient()"> <span class="svg-icon svg-icon-3">
									<svg xmlns="http://www.w3.org/2000/svg" width="24" height="24" viewBox="0 0 24 24" fill="none">
													<rect opacity="0.5" x="11.364" y="20.364" width="16" height="2" rx="1" transform="rotate(-90 11.364 20.364)" fill="black"></rect>
													<rect x="4.36396" y="11.364" width="16" height="2" rx="1" fill="black"></rect>
									</svg>
								</span> Add</button>

						</td>
					</tr>
					</tfoot>
				</table>
			</div>
		</div>
	</div>
	<div class="card mb-xl-8">
		<div class="card-header align-items-center">
			<label class="fs-4 fw-bold form-label mb-2 text-primary">Settings</label>
		</div>
		<div class="card-body pt-10">
			<div class="row mb-10">
				<div class="col-md-4 fv-row">
					<label class="required fs-6 fw-bold form-label mb-2">Who can view the contract?</label>
					<select v-model="contractData.canView" class="form-select">
						<option value="public">Public</option>
						<option value="both" selected>Only Sender and Recipient</option>
					</select>
				</div>
				<div class="col-md-4 fv-row">
					<label class="required fs-6 fw-bold form-label mb-2">Who can cancel contract?</label>
					<select v-model="contractData.canCancel" class="form-select">
						<option value="recipient">Only Recipient</option>
						<option value="sender">Only Sender</option>
						<option value="both">Both</option>
						<option value="neither">Neither</option>
					</select>
				</div>
				<div class="col-md-4 fv-row">
					<label class="required fs-6 fw-bold form-label mb-2">Who can change recipient?</label>
					<select v-model="contractData.canChange" class="form-select" disabled >
						<option value="recipient">Only Recipient</option>
						<option value="sender">Only Sender</option>
						<option value="both">Both</option>
						<option value="neither">Neither</option>
					</select>
				</div>
			</div>
			<div class="row">
				<div class="col-md-4 fv-row">
					<label class="fs-6 fw-bold form-label mb-2">Start now</label>
					<label class="form-check form-switch form-check-custom form-check-solid">
						<input class="form-check-input" type="checkbox" v-model="contractData.startNow"/>
						<span class="form-check-label fw-bold text-muted">Start upon contract creation</span>
					</label>
				</div>
				<div class="col-md-4 fv-row" v-if="!contractData.startNow">
					<label class="required  fs-6 fw-bold form-label mb-2">Start Date</label>
					<VueDatePicker v-model="contractData.startDate" :min-date="new Date()" :enable-time-picker="false" auto-apply></VueDatePicker>
				</div>
				<div class="col-md-4 fv-row" v-if="!contractData.startNow">
					<label class="required  fs-6 fw-bold form-label mb-2">Start Time</label>
					<VueDatePicker v-model="contractData.startTime" time-picker :min-date="new Date()" auto-apply></VueDatePicker>
				</div>
			</div>
		</div>
	</div>
	<div class="d-flex flex-stack pt-0">
		<div>
			<button type="button" class="btn btn-lg btn-primary" @click="reviewContract">Review Contract
				<span class="svg-icon svg-icon-3 ms-1 me-0">
					<svg xmlns="http://www.w3.org/2000/svg" width="24" height="24" viewBox="0 0 24 24" fill="none">
						<rect opacity="0.5" x="18" y="13" width="13" height="2" rx="1" transform="rotate(-180 18 13)" fill="black" />
						<path d="M15.4343 12.5657L11.25 16.75C10.8358 17.1642 10.8358 17.8358 11.25 18.25C11.6642 18.6642 12.3358 18.6642 12.75 18.25L18.2929 12.7071C18.6834 12.3166 18.6834 11.6834 18.2929 11.2929L12.75 5.75C12.3358 5.33579 11.6642 5.33579 11.25 5.75C10.8358 6.16421 10.8358 6.83579 11.25 7.25L15.4343 11.4343C15.7467 11.7467 15.7467 12.2533 15.4343 12.5657Z" fill="black" />
					</svg>
				</span>
			</button>
		</div>
	</div>
</template>