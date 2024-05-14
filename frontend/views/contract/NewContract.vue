<script setup>
	import {ref, computed} from "vue";
	import {validateAddress, validatePrincipal, showError} from "@/utils/common"
	import {currencyFormat} from "@/utils/token"
	import { useWalletStore } from '@/store/wallet'
    import LoadingLabel from "@/components/LoadingLabel.vue"
	import EventBus from "@/services/EventBus";
	import { useAssetStore } from "@/store/token";
	import { useGetMyBalance } from '@/services/Token';
	import PreviewChart from '@/components/contract/PreviewChart.vue';
    import { DURATION, SCHEDULE} from "@/config/constants"


	import VueMultiselect from 'vue-multiselect'
	import config from '@/config'
	const isLoading = ref(false);
	const storeAsset = useAssetStore();
	const walletStore = useWalletStore();
	const token = ref({symbol: 'ICP', name: 'Internet Computer', canisterId: 'ryjl3-tyaaa-aaaaa-aaaba-cai', standard: 'icrc1', decimals: 8, fee: 10000});
	const tokenBalance = ref(walletStore.wallet.balance);
	const totalAmount = ref(0);
	const newRecipient = ref({amount:"", address: "", title: "", note: ""});
	const recipients = ref([]);
	const props = defineProps({
		options: {
			type: Array,
			required: true
		}
		});
	const contractData = ref({
		name: "",
		description: "",
		startNow: true,
		startDate: new Date(),
		startTime: new Date(),
		durationUnit: 1,
		durationTime: 2628002,
		unlockSchedule: 86400,
		cliffUnit: 0,
		cliffTime: 2628002,
		totalAmount: 1000,
		recipients: [],
		canView: 'both',
		canCancel: 'neither',
		canChange: 'neither',
	})
	const customLabel = ({ name, canisterId })=>{
		return `${name} | Canister ID: ${canisterId}`
    }
	const setSelectedToken = async ()=>{
		resetRecipients();
		tokenBalance.value = 0;
		await getTokenBalance();
	}
	const validateVesting = ()=>{
		if(contractData.value.cliffUnit < 0) contractData.value.cliffUnit = 0;
		if(contractData.value.durationUnit < 0) contractData.value.durationUnit = 0;
		
		let cliffInSeconds = contractData.value.cliffUnit*contractData.value.cliffTime;
		let durationInSeconds = contractData.value.durationUnit*contractData.value.durationTime;
		let unlockSchedule = contractData.value.unlockSchedule;
		if (cliffInSeconds > durationInSeconds) {
			contractData.value.cliffUnit = contractData.value.durationUnit;
			contractData.value.cliffTime = contractData.value.durationTime;
		}
		if (Number(contractData.value.unlockSchedule) > Number(contractData.value.durationTime)){
			contractData.value.unlockSchedule = contractData.value.durationTime;
		}

	}
	const calTotalToken = ()=>{
		totalAmount.value = recipients.value.reduce((acc,cur) => acc + Number(cur.amount), 0);
	}
	const getTokenBalance = async ()=>{
		isLoading.value = true;
		totalAmount.value = 0;
		tokenBalance.value = await useGetMyBalance(token.value.canisterId);
		isLoading.value = false;
		calTotalToken();
	}
	const resetInput = ()=>{
		newRecipient.value = {amount:0, address: "", title: "", note: ""};
	}
	const resetRecipients = ()=>{ recipients.value = []};
	const removeRecipient = (idx)=>{
		recipients.value.splice(idx, 1);
		calTotalToken();
	}
	const findRecipientIdx = (address)=>{
		return recipients.value.findIndex(x => x.address == address);
	}
	const addRecipient = ()=>{
		let _to = newRecipient.value.address.trim();
		if(token.value.standard  != 'ledger' && !validatePrincipal(_to)){
			showError("Please use a valid Principal ID!");
			return;
		}
		if(newRecipient.value.amount <= 0){
			showError("Please enter a valid amount!");
			return;
		}
		let idx = findRecipientIdx(_to);
		if(idx > -1){//Update amount if existed
			recipients.value[idx].amount += Number(newRecipient.value.amount);
			recipients.value[idx].note = newRecipient.value.note??"";
		}else{
			recipients.value.push({address:_to, amount: Number(newRecipient.value.amount), title: newRecipient.value.title??"", note:newRecipient.value.note??""})
		}

		resetInput();
		calTotalToken();
	}
	const importToken = ()=>{
		EventBus.emit("showImportTokenModal", true)
	}
	const deployToken = ()=>{
		EventBus.emit("showDeployTokenModal", true)
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
		EventBus.emit("showContractDetailsModal", {...contractData.value, status: true})
	}
</script>
<template>
    <Toolbar :current="`New Contract`" :parents="[{title: 'Token Claim', to: '/token-claim'}]"/>

	<form class="form" @submit.prevent="reviewContract">
		<div class="row gy-5 g-xl-8">
			<div class="col-md-7 fv-row">
				<div class="card card-xl-stretch mb-xl-8">
					<div class="card-header align-items-center">
						<label class="fs-4 fw-bold form-label mb-2 text-primary">Create New Contract</label>
					</div>
					<div class="card-body pt-5 pb-2">
						<div class="w-100">
							<div class="row mb-5">
								<div class="col-md-12 fv-row">
									<label class="d-flex align-items-center fs-6 fw-bold mb-2"><span class="required">Contract Name</span></label>
									<input type="text" class="form-control fw-normal" v-model="contractData.name" name="name" placeholder="Your contract name, campaign..." required />
								</div>
							</div>
							<div class="row mb-5">
								<div class="col-md-12 fv-row">
									<label class="d-flex align-items-center fs-6 fw-bold mb-2"><span class="required">Description</span></label>
									<textarea class="form-control fw-normal" v-model="contractData.description" name="description" placeholder="Contract description" required></textarea>
								</div>
							</div>
							<div class="row mb-5">
								<div class="col-md-8 fv-row">
									<label class="d-flex align-items-center fs-6 fw-bold mb-2">
										<span class="required">Token</span> 
										<i class="fas fa-exclamation-circle ms-2 fs-7" data-bs-toggle="tooltip" title="Specify your Token"></i>
										<a href="#" class="badge badge-light-primary ms-5" @click="importToken">+ Import</a>
										<a href="#" class="badge badge-light-danger ms-5" @click="deployToken">+ Deploy New Token</a>
									</label>

									<VueMultiselect v-model="token" :options="storeAsset.assets" track-by="name" @update:model-value="setSelectedToken" :option-height="40" :custom-label="customLabel" :allow-empty="false" placeholder="Select Token..." selectLabel="" deselectLabel="">
										<template v-slot:singleLabel="{ option }">
											<img class="option__image" :src="`https://${config.CANISTER_STORAGE_ID}.raw.icp0.io/${option.canisterId}.png`">
											<span class="option__desc">
												<span class="option__title">{{ option.name }} ({{ option.symbol }} )
													<span class="badge badge-light-primary ms-auto">{{ option.standard?option.standard.toUpperCase():'' }}</span>
												</span>
											</span>
										</template>
										<template v-slot:option="{ option }">
											<img class="option__image" :src="`https://${config.CANISTER_STORAGE_ID}.raw.icp0.io/${option.canisterId}.png`" alt="Select Token">
											<span class="option__desc">
												<span class="option__title">{{ option.name }} ({{ option.symbol }} ) · {{ option.canisterId }} 
													<div class="badge badge-light-primary ms-auto">{{ option.standard?option.standard.toUpperCase():'' }}</div></span>
											</span>
										</template>
									</VueMultiselect>

										<!-- <VueMultiselect v-model="token" :options="storeAsset.assets" track-by="name" @update:model-value="setSelectedToken" :option-height="104" :custom-label="customLabel" :show-labels="false">
											<template slot="singleLabel" slot-scope="props">
												<img class="option__image" src="https://app.icpswap.com/static/media/icp.971d3265.svg" ><span class="option__desc"><span class="option__title">{{ props.option.name }} - {{ props.option.canisterId }}</span></span>
											</template>
											<template slot="option" slot-scope="props">
												<img class="option__image" src="https://app.icpswap.com/static/media/icp.971d3265.svg">
												<div class="option__desc">
													<span class="option__title">{{ props.option.name }}</span>
													<span class="option__small">{{ props.option.canisterId }}</span>
												</div>
											</template>
										</VueMultiselect> -->
										<!-- <select class="form-select" @change="setSelectedToken" v-model="token" placeholder="Select token">
											<option :value="{symbol: 'icp', name: 'Internet Computer', canisterId: 'ryjl3-tyaaa-aaaaa-aaaba-cai', standard: 'ledger'}" selected>Internet Computer (ICP)</option>
											<option :value="asset" v-for="asset in storeAsset.assets"  :key="asset.canisterId">{{ asset.name }} ({{ asset.symbol }}) | {{ asset.canisterId }}</option>
										</select> -->
								</div>
								<div class="col-md-4 fv-row">
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
								<div class="col-md-4 fv-row">
									<label class="required fs-6 fw-bold form-label mb-2">Vesting Duration</label>
									<div class="row fv-row">
										<div class="col-4">
											<input type="text" class="form-control" v-model="contractData.durationUnit" required placeholder="Number" @change="validateVesting"/>
										</div>
										<div class="col-8">
											<select name="duration" class="form-select" @change="validateVesting" v-model="contractData.durationTime" >
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
								<div class="col-md-4 fv-row">
									<label class="required fs-6 fw-bold form-label mb-2">Cliff</label>
									<div class="row fv-row">
										<div class="col-4">
											<input type="text" class="form-control" v-model="contractData.cliffUnit" @change="validateVesting" required placeholder="Number"/>
										</div>
										<div class="col-8">
											<select name="cliff" class="form-select" @change="validateVesting" v-model="contractData.cliffTime" >
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
								<div class="col-md-4 fv-row">
									<label class="required fs-6 fw-bold form-label mb-2">Unlock schedule</label>
									<div class="row fv-row">
										<div class="col-12">
											<select name="releaseFrequencyPeriod" class="form-select" v-model="contractData.unlockSchedule" @change="validateVesting">
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
				</div>
			</div>
			<div class="col-md-5 fv-row">
				<div class="card card-xl-stretch mb-xl-8">
					<div class="card-header align-items-center">
						<label class="fs-4 fw-bold form-label mb-2 text-primary">Vesting Schedule</label>
					</div>
					<div class="card-body pt-5 pb-2">
						<PreviewChart :contractInfo="contractData"></PreviewChart>
						
						<!-- <div class="d-flex align-items-center mb-3">
							<div class="flex-grow-1">
								<span class="text-gray-800 text-hover-primary fw-bold fs-6">Vesting duration</span>
							</div>
							<span class="badge badge-secondary fs-8 fw-bolder">
								{{contractData.durationUnit}} {{DURATION[contractData.durationTime]}}
							</span>
						</div>
						<div class="d-flex align-items-center mb-3">
							<div class="flex-grow-1">
								<span class="text-gray-800 text-hover-primary fw-bold fs-6">Cliff</span>
							</div>
							<span class="badge badge-secondary fs-8 fw-bolder">
								{{contractData.cliffUnit}} {{DURATION[contractData.cliffTime]}}
							</span>
						</div>
						<div class="d-flex align-items-center mb-5">
							<div class="flex-grow-1">
								<span class="text-gray-800 text-hover-primary fw-bold fs-6">Unlock schedule</span>
							</div>
							<span class="badge badge-secondary fs-8 fw-bolder">
								{{SCHEDULE[contractData.unlockSchedule]}}
							</span>
						</div> -->
					</div>
				</div>
			</div>
		</div>
	
	<div class="card mb-xl-8" >
		<div class="card-header align-items-center">
			<label class="fs-4 fw-bold form-label mb-2 text-primary">Recipients <span class="badge badge-light-primary">{{recipients.length}}</span></label>
			<div class="card-toolbar">
				<div class="d-flex">
					<div class="fw-bolder fs-2 text-primary px-10">
						{{currencyFormat(tokenBalance)}}
						<span class="text-muted fs-4 fw-bold">{{tokenInfo.symbol}}</span>
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
						{{currencyFormat((tokenBalance - totalAmount > 0?(tokenBalance - totalAmount):0))}}
						<span class="text-muted fs-4 fw-bold">{{tokenInfo.symbol}}</span>
						<div class="fs-7 fw-normal text-muted">Remaining amount</div>
					</div>
					<div class="fw-bolder fs-2 text-danger px-10">
						{{currencyFormat(totalAmount)}}
						<span class="text-muted fs-4 fw-bold">{{tokenInfo.symbol}}</span>
						<div class="fs-7 fw-normal text-muted">Will be sent</div>
					</div>
				</div>
			</div>

		</div>
		<div class="card-body pt-5  pb-2">
			<div class="table-responsive border-bottom mb-5 border table-rounded ">
				<table class="table align-middle gs-0 table-row-dashed fs-6 gy-2 mb-0 table-hover">
					<thead>
					<tr class="fw-bolder fs-7 text-gray-800 border-bottom border-gray-200 bg-light">
						<th class="ps-4 w-25px ">#</th>
						<th class="w-150px text-end">Amount</th>
						<th class="min-w-400px">Principal ID</th>
						<th class="min-w-100px">Note</th>
						<th class="w-100px text-end"></th>
					</tr>
					</thead>
					<tbody>
					<tr v-if="recipients.length == 0">
						<td colspan="6" class="bg-white">
							<div class="fw-bold text-danger p-2">No recipient!</div>
						</td>
					</tr>
					<tr v-else v-for="(recipient, idx) in recipients">
						<td class="text-center">
							{{idx+1}}.
						</td>
						<td>
							<span class="text-muted fw-bold text-gray-800 d-block fs-7 text-end">
								{{currencyFormat(recipient.amount)}} {{tokenInfo.symbol.toUpperCase()}}
							</span>
						</td>
						<td>
							<span class="text-muted fw-bold text-gray-800 d-block fs-7">
								<ClickToCopy :text="recipient.address">{{recipient.address}}</ClickToCopy>
							</span>
						</td>
						<td>
							<span class="fw-bold text-gray-800 d-block fs-7">
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
					<tr class="bg-light fw-bolder">
						<td class="">
							<span class="badge badge-light-success">New</span>
						</td>
						<td>
							<label class="required fs-7 form-label mb-2">Amount</label>
							<input type="number" class="form-control form-control-sm text-red" v-model="newRecipient.amount" min="0" placeholder="---">
						</td>
						<td>
							<label class="required fs-7 form-label mb-2">Recipient Principal ID</label>
							<input type="text" class="form-control form-control-sm d-block" v-model="newRecipient.address" placeholder="Enter Principal ID" ref="address">
						</td>
						<td>
							<label class=" fs-7 form-label mb-2">Note <span class="text-muted fs-8">(optional)</span></label>
							<span class="text-muted fw-bold text-muted d-block fs-7">
								<input type="text" class="form-control d-block form-control-sm"  v-model="newRecipient.note" placeholder="Note">
							</span>
						</td>
						<td class="text-end">
							<label class="fs-7 form-label mb-2">&nbsp;</label>
							<button type="button" class="btn btn-primary d-block btn-sm px-4 me-2" @click="addRecipient()"> + Add</button>

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
		<div class="card-body pt-5">
			<div class="row mb-10">
				<div class="col-md-4 fv-row">
					<label class="fs-6 fw-bold form-label mb-2">Contract can be canceled?</label>
					<label class="form-check form-switch form-check-custom form-check-solid">
						<input class="form-check-input" type="checkbox" v-model="contractData.canCancel"/>
						<span class="form-check-label fw-bold text-muted">Allow the owner to cancel</span>
					</label>
				</div>
				<div class="col-md-4 fv-row">
					<label class="fs-6 fw-bold form-label mb-2">Start now</label>
					<label class="form-check form-switch form-check-custom form-check-solid">
						<input class="form-check-input" type="checkbox" v-model="contractData.startNow"/>
						<span class="form-check-label fw-bold text-muted">Start upon contract creation</span>
					</label>
				</div>
				<div class="col-md-4 fv-row" v-if="!contractData.startNow">
					<label class="required  fs-6 fw-bold form-label mb-2">Specify start time</label>
					<VueDatePicker v-model="contractData.startTime" :min-date="new Date()" :enable-time-picker="true" time-picker-inline auto-apply></VueDatePicker>
				</div>
			</div>
			
			<div class="d-flex flex-column pe-0">
				<button type="submit" class="btn btn-lg btn-primary btn-block">Preview Contract
					<span class="svg-icon svg-icon-3 ms-1 me-0">
						<svg xmlns="http://www.w3.org/2000/svg" width="24" height="24" viewBox="0 0 24 24" fill="none">
							<rect opacity="0.5" x="18" y="13" width="13" height="2" rx="1" transform="rotate(-180 18 13)" fill="black" />
							<path d="M15.4343 12.5657L11.25 16.75C10.8358 17.1642 10.8358 17.8358 11.25 18.25C11.6642 18.6642 12.3358 18.6642 12.75 18.25L18.2929 12.7071C18.6834 12.3166 18.6834 11.6834 18.2929 11.2929L12.75 5.75C12.3358 5.33579 11.6642 5.33579 11.25 5.75C10.8358 6.16421 10.8358 6.83579 11.25 7.25L15.4343 11.4343C15.7467 11.7467 15.7467 12.2533 15.4343 12.5657Z" fill="black" />
						</svg>
					</span>
				</button>
			</div>
		</div>
	</div>
	
</form>

</template>