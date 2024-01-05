<script setup>
    import { VueFinalModal } from 'vue-final-modal'
    import EventBus from "@/services/EventBus";
    import { DURATION, SCHEDULE} from "@/config/constants"
    import { onMounted, ref } from 'vue';
    import { showLoading } from "@/utils/common"
    import moment from 'moment';
    import Copy from "@/components/icons/Copy.vue";
    import _api from "@/ic/api";
    import { currencyFormat } from "@/utils/token";
    import {Principal} from "@dfinity/principal";
    import { useCreateContract } from "@/services/Contract";
    import { useTokenApprove, useTransferFrom } from "@/services/Token";
    import LoadingButton from '@/components/LoadingButton.vue';
    const contractData = ref(null);
    const contractDetailsModal = ref(false);
    const isLoading = ref(false);
    import walletStore from '@/store/'
    import config from '../../config';

    const closeModal = ()=>{
        contractDetailsModal.value = false;
    }
    const calTotalAmount = (recipients)=>{
		return recipients.reduce((acc,cur) => acc + Number(cur.amount), 0);
	}
    const createContract = async()=>{
        Swal.fire({
		title: "Are you sure?",
		text: "Create new contract!",
		icon: "warning",
		showCancelButton: true,
		confirmButtonColor: "#3085d6",
		cancelButtonColor: "#d33",
		confirmButtonText: "Yes, I confirmed!"
		}).then(async (result) => {
		if (result.isConfirmed) {
            isLoading.value = true;
            console.log('contractData.value: ', contractData.value.token);
            let tokenInfo = await contractData.value.token;
            let _totalAmount = 0;
            let recipients = contractData.value.recipients.map(recipient=>{
                _totalAmount += Number(recipient.amount);
                return {address: recipient.address, amount: Number(recipient.amount), title: [""+recipient.title+""], note: [""+recipient.note+""]}
            });
            // let recipients = [
            //      {address: "udh45-qy6i6-si637-5wxbo-huuba-estc4-esa7g-yo6wj-lo4pb-37fsh-aqe", amount: 600, note: ["Senior Developer"], title: ["Kenny"]},
            //      {address: "gqowl-5o7x3-4c22f-aaytt-37ma3-gkxe4-jox3l-fzjwe-rirfz-fw2kn-tae", amount: 230, note: ["Senior Developer"], title: ["John"]},
            //      {address: "v57dj-hev4p-lsvdl-dckvv-zdcvg-ln2sb-tfqba-nzb4g-iddrv-4rsq3-mae", amount: 150, note: ["J.Developer"], title: ["Jasson"]},
            //      {address: "kouzf-7czpb-er7e4-iwral-6assg-b3qqw-hargn-uhonr-iyegx-gxs4w-oqe", amount: 420, note: ["Designer"], title: ["Matthew"]},
            //      {address: "nivbr-btueu-rgdah-w4pcd-wqtmb-fr4ny-hp3ie-a7e6p-4ndto-ajwhj-fqe", amount: 135, note: ["3D Designer"], title: ["Peter"]},
            // ];
            let _data = {
                name: contractData.value.name,
                description: contractData.value.description,
                durationTime: Number(contractData.value.durationTime),
                durationUnit: Number(contractData.value.durationUnit),
                unlockSchedule: Number(contractData.value.unlockSchedule),
                canCancel: contractData.value.canCancel,
                canChange: contractData.value.canChange,
                canView: contractData.value.canView,
                startNow: contractData.value.startNow,
                startTime: moment(contractData.value.startTime).unix(),
                created: moment().unix(),
                tokenId: tokenInfo.canisterId,
                tokenName: tokenInfo.name,
                tokenStandard: tokenInfo.standard,
                tokenSymbol: tokenInfo.symbol,
                totalAmount: _totalAmount,
                unlockedAmount: 0,
                recipients: recipients,
                owner: Principal.fromText(walletStore.principal)
            };
            console.log('creating contract...', _data);
            //Step 1. Approved

            // let _approve = await useTokenApprove(tokenInfo.canisterId, {spender: config.BACKEND_CANISTER_ID, amount: _totalAmount});
            // let _transfer = await useTransferFrom(tokenInfo.canisterId, {from: walletStore.principal, to: config.BACKEND_CANISTER_ID, amount: _totalAmount});
            // return;
            // showLoading("Deploying your contract data");
            let _rs = await useCreateContract(_data);
            isLoading.value = false;
            console.log('rs', _rs);
            if(_rs && typeof(_rs) == 'string'){
                // showSuccess("Contract has been created successfully. View contract: "+_rs);
                EventBus.on("showContractDetailsModal", {status: false});//Close the preview
                Swal.fire({
                            icon: 'success',
                            title: 'Success',
                            html: '<p>Your contract has been created successfully.</p><p>View contract: <a href="/contract/'+_rs+'">'+_rs+'</a></p>',
                        })
            }else{
                Swal.fire({
                            icon: 'error',
                            title: 'Oops...',
                            text: (typeof(_rs) == 'object' && ("err" in _rs))?_rs.err:'Something went wrong, please try again!',
                        })
            }
        
		}
		});
    }
    onMounted(()=>{
        EventBus.on("showContractDetailsModal", obj => {
            console.log('obj: ', obj);
            contractDetailsModal.value = obj.status;
            contractData.value = obj
        });
    })
</script>

<template>
    <VueFinalModal v-model="contractDetailsModal" :z-index-base="2000" classes="modal fade show" content-class="modal-dialog modal-lg modal-dialog-scrollable modal-dialog-centered" aria-hidden="true" content-transition="vfm-fade"
      overlay-transition="vfm-fade">
            <div class="modal-content absolute inset-0 h-full overflow-auto">
               
                <div class="modal-header pt-5 pb-3">
                    <h4 class="modal-title">{{ contractData.name }}</h4>
                    <div class="btn btn-icon btn-sm btn-bg-light btn-active-light-danger ms-2" data-bs-dismiss="modal" aria-label="Close" @click="closeModal()">
                        <i class="fas fa-times"></i>
                    </div>
                </div>
                <div class="modal-body">
                    <div class="pl-10">
                        <div class="pb-5">
                            <!--begin::Wrapper-->
                            <div class="fs-6 pb-5">
                                
                                <div class="fw-bold">Contract Name</div>
                                <div class="text-gray-600">{{contractData.name}}</div>

                                <div class="fw-bold mt-5">Description</div>
                                <div class="text-gray-600">{{contractData.description}}</div>
                                
                                <div class="d-flex flex-column flex-sm-row gap-7 gap-md-10 mt-5">
                                    <div class="flex-root d-flex flex-column">
                                        <span class="fw-bold">Token Name</span>
                                        <span class="fs-6 text-gray-600 text-hover-primary">{{contractData.token.name}} ({{contractData.token.symbol}})</span>
                                    </div>
                                    <div class="flex-root d-flex flex-column">
                                        <span class="fw-bold">Token ID</span>
                                        <span class="fs-6 text-gray-600 text-hover-primary">{{contractData.token.canisterId}} <Copy :text="contractData.token.canisterId"></Copy></span>
                                    </div>
                                </div>

                                <div class="d-flex flex-column flex-sm-row gap-7 gap-md-10 mt-5">
                                    <div class="flex-root d-flex flex-column">
                                        <span class="fw-bold">Duration</span>
                                        <span class="fs-6 text-gray-600">{{contractData.durationUnit}} {{DURATION[contractData.durationTime]}}</span>
                                    </div>
                                    <div class="flex-root d-flex flex-column">
                                        <span class="fw-bold">Unlock Schedule</span>
                                        <span class="fs-6 text-gray-600">{{SCHEDULE[contractData.unlockSchedule]}}</span>
                                    </div>
                                </div>
                                <div class="d-flex flex-column flex-sm-row gap-7 gap-md-10 mt-5" v-if="contractData.startNow">
                                    <div class="flex-root d-flex flex-column">
                                        <span class="fw-bold">Contract Start</span>
                                        <span class="fs-6 text-gray-600">Start upon contract creation</span>
                                    </div>
                                    <div class="flex-root d-flex flex-column">
                                        <span class="fw-bold">Contract End (expected)</span>
                                        <span class="fs-6 text-gray-600">{{moment().add(Number(contractData.durationTime), 'seconds').format()}}</span>
                                    </div>
                                </div>
                                <div class="d-flex flex-column flex-sm-row gap-7 gap-md-10 mt-5" v-if="!contractData.startNow">
                                    <!-- <div class="flex-root d-flex flex-column">
                                        <span class="fw-bold">Start Date</span>
                                        <span class="fs-6 text-gray-600">{{contractData.startDate}}</span>
                                    </div> -->
                                    <div class="flex-root d-flex flex-column">
                                        <span class="fw-bold">Start Time</span>
                                        <span class="fs-6 text-gray-600">{{contractData.startTime}}</span>
                                    </div>
                                </div>
                               
                            </div>

                            <div class="d-flex flex-column gap-7 gap-md-10">
                                <div class="d-flex justify-content-between flex-column">
                                    <label class="fs-5 fw-bold form-label mb-2 text-primary">Recipients <span class="badge badge-light-primary">{{contractData.recipients.length}}</span></label>
                                    <div class="table-responsive border-bottom mb-9 table-rounded border">
                                        <table class="table table-hover align-middle table-row-dashed fs-7 gy-1 mb-0">
                                            <thead>
                                                <tr class="border-bottom fs-6 fw-bold text-gray-800 bg-light">
                                                    <th class="min-w-50px pb-2 text-center">#</th>
                                                    <th class="min-w-70px text-end fs-6 pb-2">Amount</th>
                                                    <th class="min-w-175px pb-2">Recipient</th>
                                                </tr>
                                            </thead>

                                            <tbody class="fw-semibold text-gray-600">
                                                <tr v-for="(recipient, idx) in contractData.recipients">
                                                    <td class="text-center">{{ idx+1 }}.</td>
                                                    <td class="text-end text-gray-800 fw-bold">{{ (recipient.amount) }}</td>
                                                    <td>
                                                        <div class="mb-1">       
															<div class="fw-bold text-gray-800 fs-7" v-if="recipient.title">
                                                                {{ recipient.title }}
                                                                <span class="fw-normal badge badge-light-info" v-if="recipient.note && recipient.note != ''">{{ recipient.note }}</span>
                                                            </div> 
															<div class="fw-bold text-gray-600 fs-7" v-else>Recipient #{{ idx+1 }}</div> 
															<div class="text-gray-800 fs-7">
                                                                <ClickToCopy :text="recipient.address">{{ recipient.address }}</ClickToCopy>   
                                                            </div>
														</div>
                                                    </td>
                                                </tr>
                                                <tr class="bg-light">
                                                    <td class="text-end fw-bold">Total:</td>
                                                    <td class="text-end fw-bold text-danger">{{currencyFormat(contractData.totalAmount)}}</td>
                                                    <td>${{ contractData.token.symbol }}</td>
                                                </tr>
                                                <tr class="bg-light">
                                                    <td class="text-end fw-bold">Creation Fee:</td>
                                                    <td class="text-end fw-bold text-danger">0</td>
                                                    <td>$ICP</td>
                                                </tr>
                                            </tbody>
                                        </table>
                                    </div>
                                </div>
                            </div>

                            <div class="alert bg-light-danger border border-danger border-dashed d-flex flex-column flex-sm-row w-100 p-5 mb-10">
                                <div class="d-flex flex-column pe-0 pe-sm-10">
                                    <h5 class="mb-1">Important!</h5>
                                    <span>
                                        Double-check the contract deployment timing and related settings accurately. 
                                        The smart contract is autonomous and not controlled by ICTO or the creator to ensure transparency. 
                                        Once it's initiated, only those set within the contract can cancel.
                                    </span>
                                </div>
                            </div>
                            <div class="d-flex flex-column gap-7 gap-md-10">
                                <LoadingButton 
                                :loading="isLoading"
                                class="btn btn-danger btn-block"
                                @click="createContract()">Create contract
                            </LoadingButton>
                                <!-- <button class="btn btn-danger btn-sm" @click="createContract()">Confirm! Create my contract</button> -->
                            </div>
                            
                        </div>
                    </div>
                </div>
        </div>

    </VueFinalModal>

</template>