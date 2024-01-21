<script setup>
    import { ref, onMounted } from "vue";
    import config from "@/config";
    import EventBus from "@/services/EventBus";
    import { VueFinalModal } from 'vue-final-modal'
    import LoadingButton from "@/components/LoadingButton.vue"
	import { showModal, showLoading, closeMessage, showSuccess, showError, validateAddress, validatePrincipal } from '@/utils/common';
    import { useMintToken } from "@/services/Token"
    const nft = ref(null);
    const processBuyingModal = ref(false);
    const isLoading = ref(false);
    
    const processAction = ()=>{
        processBuyingModal.value = false;
        
    }
    const closeModal = ()=>{ processBuyingModal.value = false};

    onMounted(() => {
        EventBus.on("showProcessBuyingModal", obj => {
            console.log('obj', obj);
            processBuyingModal.value = obj.status;
        });  
    })
</script>
<template>
    <VueFinalModal v-model="processBuyingModal" :z-index-base="2000" classes="modal fade show" content-class="modal-dialog modal-lg ">
        <div class="modal-content">
            <div class="modal-header">
                <h5 class="modal-title">
                    <span class="fs-4 text-danger">Pending transaction</span>
                    <div class="text-dark fw-normal fs-7">Buying NFT from marketplace</div>
                </h5>

                <div class="btn btn-icon btn-sm btn-bg-light btn-active-light-danger ms-2" data-bs-dismiss="modal" aria-label="Close" @click="closeModal()">
                    <i class="fas fa-times"></i>
                </div>
            </div>
            <div class="modal-body pt-3 pb-5">
                <div class="card-body ">
                    <div class="accordion" id="kt_accordion_1">
                        <div class="accordion-item">
                            <h2 class="accordion-header" id="kt_accordion_1_header_1">
                                <button class="accordion-button py-3 fs-6 fw-bold" type="button" data-bs-toggle="collapse" data-bs-target="#kt_accordion_1_body_1" aria-expanded="true" aria-controls="kt_accordion_1_body_1">
                                    Step 1: Checking NFT available
                                </button>
                            </h2>
                            <div id="kt_accordion_1_body_1" class="accordion-collapse collapse show" aria-labelledby="kt_accordion_1_header_1" data-bs-parent="#kt_accordion_1">
                                <div class="accordion-body">
                                    Locking the NFT if available for buy <span class="spinner-border spinner-border-sm align-middle ms-2"></span>
                                </div>
                            </div>
                        </div>

                        <div class="accordion-item">
                            <h2 class="accordion-header" id="kt_accordion_1_header_2">
                                <button class="accordion-button py-3 fs-6 fw-bold collapsed" type="button" data-bs-toggle="collapse" data-bs-target="#kt_accordion_1_body_2" aria-expanded="false" aria-controls="kt_accordion_1_body_2">
                                Step 2: Making Payment
                                </button>
                            </h2>
                            <div id="kt_accordion_1_body_2" class="accordion-collapse collapse" aria-labelledby="kt_accordion_1_header_2" data-bs-parent="#kt_accordion_1">
                                <div class="accordion-body">
                                    Transfer 3.12 ICP to address: 6102c39ede652286711a1019b6e2e67c0b765241db23b3e96b9f203b6174e6a2 <span class="spinner-border spinner-border-sm align-middle ms-2"></span>
                                </div>
                            </div>
                        </div>

                        <div class="accordion-item">
                            <h2 class="accordion-header" id="kt_accordion_1_header_3">
                                <button class="accordion-button py-3 fs-6 fw-bold collapsed" type="button" data-bs-toggle="collapse" data-bs-target="#kt_accordion_1_body_3" aria-expanded="false" aria-controls="kt_accordion_1_body_3">
                                Step 3: Verify Payment
                                </button>
                            </h2>
                            <div id="kt_accordion_1_body_3" class="accordion-collapse collapse" aria-labelledby="kt_accordion_1_header_3" data-bs-parent="#kt_accordion_1">
                                <div class="accordion-body">
                                ...
                                </div>
                            </div>
                        </div>
                    </div>
                </div>
            </div>
        </div>
    </VueFinalModal>
</template>