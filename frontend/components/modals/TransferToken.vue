<script setup>
    import { ref, onMounted } from "vue";
    import config from "@/config";
    import EventBus from "@/services/EventBus";
    import { VueFinalModal } from 'vue-final-modal'
    import LoadingButton from "@/components/LoadingButton.vue"
	import { showLoading, closeMessage, showSuccess, showError, validateAddress, validatePrincipal } from '@/utils/common';
    import { useMintToken, useGetMyBalance } from "@/services/Token"
    const action = ref('mint');
    const isNFT = ref(false);
    const to = ref('');
    const amount = ref(0);
    const actually = ref(0);
    const manageTokenModal = ref(false);
    const isLoading = ref(false);
    const tokenInfo = ref(null);
    const tokenBalance = ref(0);
    
    const processAction = ()=>{
        if(checkPrincipal()){
            if(amount.value <= 0){
            showError("Amount must be greater than 0!")
            }else{
                window.Swal.fire({
                    icon: 'question',
                    title: 'Confirmation',
                    html: 'Please confirm that you are about to '+action.value+' <span class="text-danger">'+amount.value+'</span> <strong>'+tokenInfo.value.symbol+'</strong> to <span class="text-danger">'+to.value+'</span> ?',
                    showCancelButton: true,
                    confirmButtonText: 'Confirm',
                    confirmButtonColor: '#bbbbbb'
                }).then(async (result) => {
                    if (result.isConfirmed) {
                        isLoading.value = true;
                        showLoading("Transfering...")
                        //Close the dialog
                        let _rs = await useMintToken(tokenInfo.value.canisterId, to.value, amount.value);
                        // if(_rs){
                        //     manageTokenModal.value = false;
                        // }
                        closeMessage();
                    }
                })
            }
        }
    }
    const selectMax = ()=>{
        amount.value = tokenBalance.value;
        checkActually();
    }
    const checkPrincipal = ()=>{
        if(tokenInfo.value.canisterId == config.LEDGER_CANISTER_ID && !validateAddress(to.value.trim())){
            showError("Please use Account ID to send ICP");
            return false;
        }
        if(tokenInfo.value.canisterId != config.LEDGER_CANISTER_ID && !validatePrincipal(to.value.trim())){
            showError("Receipient Principal ID is invalid!");
            return false;
        }
        return true;
    }
    const checkActually = ()=>{
        actually.value = amount.value>0?amount.value-(tokenInfo.value.fee?tokenInfo.value.fee/Math.pow(10, tokenInfo.value.decimals):0):0;
    }
    const closeModal = ()=>{ manageTokenModal.value = false};
    const checkBalance = async (canisterId)=>{tokenBalance.value = await useGetMyBalance(canisterId)};

    onMounted(() => {
        EventBus.on("showTransferTokenModal", (obj) => {
            tokenBalance.value = 0;
            checkBalance(obj.canisterId);
            manageTokenModal.value = obj.status;
            console.log(obj);
            // obj.fee = obj.fee>0?obj.fee/Math.pow(10, obj.decimals):0;
            tokenInfo.value = obj;
            to.value = '';
            action.value = obj.action;
            isNFT.value = obj.isNFT;
            if(obj.isNFT){
                amount.value = 1;
                actually.value = 1;
            }else{
                amount.value = 0;
                actually.value = 0;
            }
            
            isLoading.value = false;
        });  
    })
</script>
<template>
    <VueFinalModal v-model="manageTokenModal" :z-index-base="2000" classes="modal fade show" content-class="modal-dialog modal-lg modal-dialog-scrollable">
        <div class="modal-content">
            <div class="modal-header">
                <h5 class="modal-title">
                    <span class="text-capitalize">{{ action }} </span> {{ tokenInfo.symbol }} (<span class="text-blue">{{ tokenInfo.name }}</span>) 
                    <div class="text-dark fw-normal fs-7">Canister ID: <span class="fw-bold">{{ tokenInfo.canisterId }}</span> <Copy :text="tokenInfo.canisterId"></Copy></div>
                </h5>

                <div class="btn btn-icon btn-sm btn-bg-light btn-active-light-danger ms-2" data-bs-dismiss="modal" aria-label="Close" @click="closeModal()">
                    <i class="fas fa-times"></i>
                </div>
            </div>
            <div class="modal-body pt-3 pb-5">
                <div class="pl-10 pb-3">
                    <div class="row gy-4 mb-5" v-if="isNFT">
                        <div class="col-sm-12">
                            <img src="http://localhost:5500/sample/uncommon.svg" class="w-100 max-h-350" />
                        </div>
                    </div>
                    <div class="row gy-4 mb-5">
                        <div class="col-sm-12">
                            <div class="form-group">
                                <label class="form-label required text-capitalize">Principal ID / Account ID</label>
                                <div class="form-control-wrap">
                                    <input type="text" class="form-control" placeholder="Principal ID or Account ID" required v-model="to" @change="checkPrincipal">
                                </div>
                            </div>
                        </div>
                    </div>
                    <div class="row gy-4 mb-5">
                        <div class="col-lg-5">
                            <div class="form-group">
                                <label class="form-label required">Amount</label>
                                <div class="float-right">Balance: <a href="#" @click="selectMax" title="Select Max" class="fw-bold">{{ tokenBalance }}</a> <span class="text-blue">{{ tokenInfo.symbol }}</span></div>
                                <div class="form-control-wrap">
                                    <input type="text" class="form-control" v-model="amount" required @change="checkActually" :disabled="isNFT"/>
                                </div>
                            </div>
                        </div>
                        <div class="col-lg-2">
                            <div class="form-group">
                                <label class="form-label">Fee</label>
                                <div class="form-control-wrap">
                                    <input type="text" class="form-control" :value="tokenInfo.fee>0?tokenInfo.fee/Math.pow(10, tokenInfo.decimals):0" disabled />
                                </div>
                            </div>
                        </div>
                        <div class="col-lg-5">
                            <div class="form-group">
                                <label class="form-label">Actually received</label>
                                <div class="form-control-wrap">
                                    <input type="text" class="form-control" v-model="actually" disabled />
                                </div>
                            </div>
                        </div>
                    </div>
                    <div class="alert bg-light-warning mb-5">
                        Make sure that the receiving address is created by a wallet or platform that supports this token/NFT. 
                        <div>Otherwise, you will not be able to retrieve it once it has been confirmed!</div>
                    </div>
                    <div class="d-flex flex-column gap-7 gap-md-10">
                        <button 
                            class="btn btn-danger btn-block text-capitalize"
                            @click="processAction" :disabled="amount==0">{{ action }} {{ amount?amount:'' }} {{ tokenInfo.symbol }}
                        </button>
                    </div>
                </div>
            </div>
        </div>
    </VueFinalModal>
</template>