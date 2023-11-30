<script setup>
	import {ref} from "vue";
	import { toast } from 'vue3-toastify';
	import {validateAddress, showError} from "@/utils/common"
	import { useWallet, useBalance, useCanister  } from "@connect2ic/vue"
	import EventBus from "../../services/EventBus";
	const [assets, { refetch }] = useBalance()
	const token = ref("ICP");
	const tokenBalance = ref(0);
	const totalAmount = ref(0);
	const newRecipient = ref({amount:"", address: "6102c39ede652286711a1019b6e2e67c0b765241db23b3e96b9f203b6174e6a2", title: "", note: ""});
	const recipients = ref([]);

	const setSelectedToken = ()=>{
		tokenBalance.value = assets.value.filter(obj => obj.name == token.value).map(filteredObj => filteredObj.amount)[0];
	}
	const refreshBalance = ()=> refetch();
	const calTotalToken = ()=>{
		totalAmount.value = recipients.value.reduce((acc,cur) => acc + cur.amount, 0);
	}
	const resetInput = ()=>{
		newRecipient.value = {amount:"", address: "", title: "", note: ""};
	}
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
			showError("Not enough "+token.value+", check remaining amount!");
			return;
		}
		recipients.value.push({address:newRecipient.value.address.trim(), amount: Number(newRecipient.value.amount), title: newRecipient.value.title??"", note:newRecipient.value.note??""})
		resetInput();
		calTotalToken();
	}
	const importToken = ()=>{
		EventBus.emit("showImportTokenModal", true)
	}
</script>
<template>
	<div class="card  mb-xl-8">
		<div class="card-header align-items-center">
			<label class="fs-4 fw-bold form-label mb-2 text-primary">Payment Contract</label>
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
									</label>
								<div class="input-group flex-nowrap">
									<select class="form-select form-control" @change="setSelectedToken" v-model="token">
										<option :value="asset.name" v-for="asset in assets">{{ asset.name }}</option>
									</select>
									<span class="input-group-text">
										<button type="button" class="btn btn-primary btn-sm" @click="importToken">Import</button>
									</span>
	</div>

								
							</div>
							<div class="col-md-6 fv-row">
								<label class="fs-6 fw-bold form-label mb-2">Balance</label>
								<input type="text" readonly class="form-control form-control-solid" :value="tokenBalance">
							</div>
						</div>
						<div class="row mb-10">
							<div class="col-md-6 fv-row">
								<label class="required fs-6 fw-bold form-label mb-2">Duration</label>
								<div class="row fv-row">
									<div class="col-4">
										<input type="text" class="form-control" name="name" placeholder="" value="1" />
									</div>
									<div class="col-8">
										<select name="card_expiry_year" class="form-select" data-hide-search="true" data-placeholder="Year">
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
										<select name="releaseFrequencyPeriod" class="form-select">
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
	<div class="card mb-xl-8">
		<div class="card-header align-items-center">
			<label class="fs-4 fw-bold form-label mb-2 text-primary">Start Time</label>
		</div>
		<div class="card-body pt-10">
			<div class="row">
				<div class="col-md-6 fv-row">
					<label class="required fs-6 fw-bold form-label mb-2">Start time</label>
					<label class="form-check form-switch form-check-custom form-check-solid">
						<input class="form-check-input" type="checkbox" value="1" checked />
						<span class="form-check-label fw-bold text-muted">Start upon contract creation</span>
					</label>
				</div>
				<div class="col-md-3 fv-row">
					<label class=" fs-6 fw-bold form-label mb-2">Start date</label>
					<input type="text"  class="form-control" value="10.3981">
				</div>
				<div class="col-md-3 fv-row">
					<label class=" fs-6 fw-bold form-label mb-2">Start time</label>
					<input type="text"  class="form-control" value="10.3981">
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
						{{tokenBalance}}
						<span class="text-muted fs-4 fw-bold">{{token}}</span>
						<div class="fs-7 fw-normal text-muted">
							Your balance
							<a href="javascript:void(0)" class="text-primary" title="Reload balance" @click="refreshBalance">
							<span class="svg-icon svg-icon-primary"><svg class="h-20px" xmlns="http://www.w3.org/2000/svg" width="24" height="24" viewBox="0 0 24 24" fill="none">
<path d="M14.5 20.7259C14.6 21.2259 14.2 21.826 13.7 21.926C13.2 22.026 12.6 22.0259 12.1 22.0259C9.5 22.0259 6.9 21.0259 5 19.1259C1.4 15.5259 1.09998 9.72592 4.29998 5.82592L5.70001 7.22595C3.30001 10.3259 3.59999 14.8259 6.39999 17.7259C8.19999 19.5259 10.8 20.426 13.4 19.926C13.9 19.826 14.4 20.2259 14.5 20.7259ZM18.4 16.8259L19.8 18.2259C22.9 14.3259 22.7 8.52593 19 4.92593C16.7 2.62593 13.5 1.62594 10.3 2.12594C9.79998 2.22594 9.4 2.72595 9.5 3.22595C9.6 3.72595 10.1 4.12594 10.6 4.02594C13.1 3.62594 15.7 4.42595 17.6 6.22595C20.5 9.22595 20.7 13.7259 18.4 16.8259Z" fill="black"/>
<path opacity="0.3" d="M2 3.62592H7C7.6 3.62592 8 4.02592 8 4.62592V9.62589L2 3.62592ZM16 14.4259V19.4259C16 20.0259 16.4 20.4259 17 20.4259H22L16 14.4259Z" fill="black"/>
</svg></span></a>

						</div>
					</div>
					<div class="fw-bolder fs-2 text-success px-10">
						{{(tokenBalance - totalAmount).toFixed(6)}}
						<span class="text-muted fs-4 fw-bold">{{token}}</span>
						<div class="fs-7 fw-normal text-muted">Remaining amount</div>
					</div>
					<div class="fw-bolder fs-2 text-danger px-10">
						{{totalAmount}}
						<span class="text-muted fs-4 fw-bold">{{token}}</span>
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
						<th class="w-100px text-end">Amount</th>
						<th class="min-w-400px required">Address</th>
						<th class="min-w-50px">Title</th>
						<th class="min-w-100px">Note</th>
						<th class="w-100px text-end rounded-end"></th>
					</tr>
					</thead>
					<tbody>
					<tr v-if="recipients.length == 0">
						<td colspan="6" class="bg-white">
							No recipient!
						</td>
					</tr>
					<tr v-else v-for="(recipient, idx) in recipients">
						<td>
							<span class="badge badge-light-primary">#{{idx+1}}</span>
						</td>
						<td>
							<span class="text-muted fw-bold text-muted d-block fs-7 text-end">
								{{recipient.amount}} {{token}}
							</span>
	<!--													<input type="number" class="form-control form-control-sm text-red" :value="recipient.amount" min="0">-->
						</td>
						<td>
							<span class="text-muted fw-bold text-muted d-block fs-7">
								{{recipient.address}}
							</span>
	<!--													<input type="text" class="form-control form-control-sm d-block" :value="recipient.address">-->
						</td>
						<td>
							<span class="text-muted text-muted d-block fs-7">
								{{recipient.title}}
							</span>
	<!--													<input type="text" class="form-control form-control-sm mb-1" :value="recipient.title">-->
						</td>
						<td>
							<span class="text-muted text-muted d-block fs-7">
								{{recipient.note}}
							</span>
	<!--													<input type="text" class="form-control d-block form-control-sm" :value="recipient.note">-->
						</td>
						<td class="text-center">
							<button type="button" class="btn btn-icon btn-danger btn-sm" @click="removeRecipient(idx)">
								<span class="svg-icon svg-icon-3">
									<svg xmlns="http://www.w3.org/2000/svg" width="24" height="24" viewBox="0 0 24 24" fill="none">
										<path d="M5 9C5 8.44772 5.44772 8 6 8H18C18.5523 8 19 8.44772 19 9V18C19 19.6569 17.6569 21 16 21H8C6.34315 21 5 19.6569 5 18V9Z" fill="black"></path>
										<path opacity="0.5" d="M5 5C5 4.44772 5.44772 4 6 4H18C18.5523 4 19 4.44772 19 5V5C19 5.55228 18.5523 6 18 6H6C5.44772 6 5 5.55228 5 5V5Z" fill="black"></path>
										<path opacity="0.5" d="M9 4C9 3.44772 9.44772 3 10 3H14C14.5523 3 15 3.44772 15 4V4H9V4Z" fill="black"></path>
									</svg>
								</span>
							</button>
						</td>
					</tr>
					</tbody>
					<tfoot>
					<tr class="bg-light">
						<td class="">
							<span class="badge badge-light-success">New</span>
						</td>
						<td>
							<label class="required fs-7 form-label mb-2">Amount</label>
							<input type="number" class="form-control form-control-sm text-red" v-model="newRecipient.amount" min="0" placeholder="---">
						</td>
						<td>
							<label class="required fs-7 form-label mb-2">Recipient wallet address</label>
							<input type="text" class="form-control form-control-sm d-block" v-model="newRecipient.address" placeholder="Address (Account ID)">
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
			<label class="fs-4 fw-bold form-label mb-2 text-primary">Privacy</label>
		</div>
		<div class="card-body pt-10">
			<div class="row mb-10">
				<div class="col-md-4 fv-row">
					<label class="required fs-6 fw-bold form-label mb-2">Who can view the contract?</label>
					<select name="card_expiry_year" class="form-select" data-hide-search="true" data-placeholder="Year">
						<option value="public">Public</option>
						<option value="both" selected>Sender and Recipient</option>
					</select>
				</div>
				<div class="col-md-4 fv-row">
					<label class="required fs-6 fw-bold form-label mb-2">Who can cancel contract?</label>
					<select name="card_expiry_year" class="form-select" data-hide-search="true" data-placeholder="Year">
						<option value="recipient">Only Recipient</option>
						<option value="sender">Only Sender</option>
						<option value="both">Both</option>
						<option value="neither">Neither</option>
					</select>
				</div>
				<div class="col-md-4 fv-row">
					<label class="required fs-6 fw-bold form-label mb-2">Who can change recipient?</label>
					<select name="card_expiry_year" class="form-select" data-hide-search="true" data-placeholder="Year">
						<option value="recipient">Only Recipient</option>
						<option value="sender">Only Sender</option>
						<option value="both">Both</option>
						<option value="neither">Neither</option>
					</select>
				</div>
			</div>
		</div>
	</div>
	<div class="d-flex flex-stack pt-0">
		<div>
			<button type="button" class="btn btn-lg btn-primary" data-kt-stepper-action="next">Review Contract
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