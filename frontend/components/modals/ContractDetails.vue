<script setup>
    import { VueFinalModal } from 'vue-final-modal'
    import EventBus from "@/services/EventBus";
    import { onMounted, ref } from 'vue';
    import _api from "@/ic/api";
    import { currencyFormat } from "@/utils/token";
    import LoadingButton from "@/components/LoadingButton.vue"
    const contractData = ref(null);
    const contractDetailsModal = ref(false);
    const isLoading = ref(false);

    onMounted(()=>{
        EventBus.on("showContractDetailsModal", obj => {
            console.log('obj: ', obj);
            contractDetailsModal.value = obj.status;
            contractData.value = obj
        });
    })
</script>

<template>
    <VueFinalModal v-model="contractDetailsModal" :z-index-base="2000" classes="modal fade show" content-class="modal-dialog modal-lg modal-scroll" aria-hidden="true" >
            <div class="modal-content">
               
                <div class="modal-header">
                    <h5 class="modal-title">Contract Details</h5>
                    <div class="btn btn-icon btn-sm btn-active-light-danger ms-2" data-bs-dismiss="modal" aria-label="Close" @click="contractDetailsModal.value = false">
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
                        <div class="pb-12">
                            <!--begin::Wrapper-->
                            <div class="d-flex flex-column gap-7 gap-md-10">
                               
                                <!--begin::Contract details-->
                                <div class="d-flex flex-column flex-sm-row gap-7 gap-md-10 fw-bold">
                                    <div class="flex-root d-flex flex-column">
                                        <span class="text-muted">Canister ID</span>
                                        <span class="fs-5">{{contractData.token.canisterId}}</span>
                                    </div>

                                    <div class="flex-root d-flex flex-column">
                                        <span class="text-muted">Date</span>
                                        <span class="fs-5">04 December, 2023</span>
                                    </div>

                                    <div class="flex-root d-flex flex-column">
                                        <span class="text-muted">Invoice ID</span>
                                        <span class="fs-5">#INV-000414</span>
                                    </div>

                                    <div class="flex-root d-flex flex-column">
                                        <span class="text-muted">Shipment ID</span>
                                        <span class="fs-5">#SHP-0025410</span>
                                    </div>
                                </div>
                                <!--end::Contract details-->


                                <div class="d-flex justify-content-between flex-column">
                                    <div class="table-responsive border-bottom mb-9">
                                        <table class="table align-middle table-row-dashed fs-6 gy-5 mb-0">
                                            <thead>
                                                <tr class="border-bottom fs-6 fw-bold text-muted">
                                                    <th class="min-w-50px pb-2 text-center">#</th>
                                                    <th class="min-w-175px pb-2">Recipient</th>
                                                    <th class="min-w-70px text-end pb-2">Amount</th>
                                                </tr>
                                            </thead>

                                            <tbody class="fw-semibold text-gray-600">
                                                <tr v-for="(recipient, idx) in contractData.recipients">
                                                    <td class="text-center">{{ idx+1 }}</td>
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
                                                    <td class="text-end">{{ currencyFormat(recipient.amount) }}</td>
                                                </tr>
                                                <tr>
                                                    <td></td>
                                                    <td class="text-end">Total:</td>
                                                    <td class="text-end fw-bold text-danger">{{currencyFormat(contractData.totalAmount)}}</td>
                                                </tr>
                                            </tbody>
                                        </table>
                                    </div>
                                </div>


                                
                            </div>
                        </div>
                    </div>
                </div>
                <div class="modal-footer bg-light">
                    <div class="btn-toolbar g-4 align-center">
                        <a href="javascript:void(0)" @click="loginModal=false" class="btn btn-danger">Transfer your {{ contractData.token.symbol }} to ICTO</a>
                        <a href="javascript:void(0)" @click="loginModal=false" class="link link-primary">Close</a>
                    </div>
                </div>
        </div>

    </VueFinalModal>

</template>