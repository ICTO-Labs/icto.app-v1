<script setup>
    import { VueFinalModal } from 'vue-final-modal'
    import EventBus from "@/services/EventBus";
    import { DURATION, SCHEDULE} from "@/config/constants"
    import { onMounted, ref } from 'vue';
    import { showSuccess} from "@/utils/common"
    import moment from 'moment';
    import Copy from "@/components/icons/Copy.vue";
    import _api from "@/ic/api";
    import { currencyFormat } from "@/utils/token";
    import { useCanister } from "@connect2ic/vue"
    const [backend, { loading, error }] = useCanister("backend", {mode: "anonymous" })
    import LoadingButton from '@/components/LoadingButton.vue';
    const contractData = ref(null);
    const contractDetailsModal = ref(false);
    const isLoading = ref(false);

    const closeModal = ()=>{
        contractDetailsModal.value = false;
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
            // let recipients = contractData.value.recipients.map(recipient=>{
            //     return {address: recipient.address, amount: recipient.amount, title: [recipient.title], note: [recipient.note]}
            // });
            let recipients = [
                 {address: "lekqg-fvb6g-4kubt-oqgzu-rd5r7-muoce-kppfz-aaem3-abfaj-cxq7a-dqe", amount: 60, note: ["Developer"], title: ["Fern"]},
            ];
            let _data = {
                name: contractData.value.name,
                durationTime: Number(contractData.value.durationTime),
                durationUnit: Number(contractData.value.durationUnit),
                unlockSchedule: Number(contractData.value.unlockSchedule),
                canCancel: contractData.value.canCancel,
                canChange: contractData.value.canChange,
                canView: contractData.value.canView,
                startNow: contractData.value.startNow,
                startTime: moment(contractData.value.startTime).unix(),
                tokenId: tokenInfo.canisterId,
                tokenName: tokenInfo.name,
                tokenStandard: tokenInfo.standard,
                totalAmount: 1000,
                recipients: recipients
            };
            console.log('creating contract...', _data);
            let _rs = await backend.value.createContract(_data);
            isLoading.value = false;
            console.log('rs', _rs);
            if(_rs){
                showSuccess("Contract has been created successfully. Canister ID: "+_rs);
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
               
                <div class="modal-header">
                    <h4 class="modal-title">{{ contractData.name }}</h4>
                    <div class="btn btn-icon btn-sm btn-active-light-danger ms-2" data-bs-dismiss="modal" aria-label="Close" @click="closeModal()">
                        <span class="svg-icon svg-icon-2x">
                            <svg xmlns="http://www.w3.org/2000/svg" width="24" height="24" viewBox="0 0 24 24" fill="none">
                                <rect opacity="0.5" x="6" y="17.3137" width="16" height="2" rx="1" transform="rotate(-45 6 17.3137)" fill="black"></rect>
                                <rect x="7.41422" y="6" width="16" height="2" rx="1" transform="rotate(45 7.41422 6)" fill="black"></rect>
                            </svg>
                        </span>
                    </div>
                </div>
                <div class="modal-body">
                    <div class="pl-10">
                        <div class="pb-5">
                            <!--begin::Wrapper-->
                            <div class="fs-6 pb-5">
                                <div class="fw-bold">Contract Name</div>
                                <div class="text-gray-600">{{contractData.name}}</div>
                                
                                <div class="d-flex flex-column flex-sm-row gap-7 gap-md-10 mt-5">
                                    <div class="flex-root d-flex flex-column">
                                        <span class="fw-bold">Token Name</span>
                                        <span class="fs-6 text-gray-600">{{contractData.token.name}} ({{contractData.token.symbol}})</span>
                                    </div>
                                    <div class="flex-root d-flex flex-column">
                                        <span class="fw-bold">Canister ID</span>
                                        <span class="fs-6 text-gray-600">{{contractData.token.canisterId}} <Copy :text="contractData.token.canisterId"></Copy></span>
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
															<div class="fw-bold text-gray-600 fs-7" v-if="recipient.title">{{ recipient.title }}</div> 
															<div class="fw-bold text-gray-600 fs-7" v-else>Recipient #{{ idx+1 }}</div> 
															<div class="text-gray-800 fs-7">
                                                                {{ recipient.address }}    
                                                            </div>
															<div class="text-gray-600 fs-8">
                                                                {{ recipient.note }}    
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
                                                    <td class="text-end fw-bold text-danger">3</td>
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
                <div class="modal-footer bg-light">
                    <div class="btn-toolbar g-4 align-center">
                        <a href="javascript:void(0)" @click="closeModal()" class="link link-primary">Close</a>
                    </div>
                </div>
        </div>

    </VueFinalModal>

</template>