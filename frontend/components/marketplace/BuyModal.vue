<script setup>
    import { ref, onMounted } from "vue";
    import config from "@/config";
    import EventBus from "@/services/EventBus";
    import { VueFinalModal } from 'vue-final-modal'
    import LoadingButton from "@/components/LoadingButton.vue"
	import { showModal, showLoading, closeMessage, showSuccess, showError, validateAddress, validatePrincipal } from '@/utils/common';
    import { useMintToken } from "@/services/Token"
    const nft = ref(null);
    const buyModal = ref(false);
    const isLoading = ref(false);
    
    const processAction = ()=>{
        buyModal.value = false;
        showModal("showProcessBuyingPopup", {
            status: true,
            nft: {
                tokenId: nft.value,
                canisterId: "2ouva-viaaa-aaaaq-aaamq-cai",
                price: 3.9
            }
        })
    }
    const closeModal = ()=>{ buyModal.value = false};

    onMounted(() => {
        EventBus.on("showBuyModal", obj => {
            console.log('obj', obj);
            buyModal.value = obj.status;
            nft.value = obj.nft;
        });  
    })
</script>
<template>
    <VueFinalModal v-model="buyModal" :z-index-base="2000" classes="modal fade show" content-class="modal-dialog modal-lg ">
        <div class="modal-content">
            <div class="modal-header">
                <h5 class="modal-title">
                    <span class="fs-4 text-danger">Buy this Item?</span>
                    <div class="text-dark fw-normal fs-7">Collection: <span class="fw-bold">ICTO NFT Card</span></div>
                </h5>

                <div class="btn btn-icon btn-sm btn-bg-light btn-active-light-danger ms-2" data-bs-dismiss="modal" aria-label="Close" @click="closeModal()">
                    <i class="fas fa-times"></i>
                </div>
            </div>
            <div class="modal-body pt-3 pb-5">
                <div class="pl-10 pb-3">
                    <div class="row gy-4 mb-5">
                        <div class="col-sm-12">
                            <img :src="`http://localhost:5500/sample/${nft}.svg`" class="w-100 max-h-350" />
                        </div>
                    </div>
                   
                    <div class="row gy-4 mb-5">
                        <div class="col-sm-4">
                            <div class="form-group">
                                <label class="form-label">Price</label>
                                <div class="form-control-wrap">
                                    <ICP :amount="3.882">3.882</ICP>
                                </div>
                            </div>
                        </div>
                        <div class="col-sm-4">
                            <div class="form-group">
                                <label class="form-label">Floor Price</label>
                                <div class="form-control-wrap">
                                    <ICP :amount="1">1</ICP>
                                </div>
                            </div>
                        </div>
                        <div class="col-sm-4">
                            <div class="form-group">
                                <label class="form-label">Lowest Price</label>
                                <div class="form-control-wrap">
                                    <ICP :amount="0.91">0.91</ICP>
                                </div>
                            </div>
                        </div>
                    </div>
                    <div class="alert bg-light-warning mb-5">
                        NFT investing/trading has a high level of market risk, there are no refunds or returns, once a transaction is made it can not be reversed! Always do your research before investing any money.
                    </div>
                    <div class="d-flex flex-column gap-7 gap-md-10">
                        <button 
                            class="btn btn-danger btn-block"
                            @click="processAction">Confirm buy with 3.882 ICP
                        </button>
                    </div>
                </div>
            </div>
        </div>
    </VueFinalModal>
</template>