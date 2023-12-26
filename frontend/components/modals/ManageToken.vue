<script setup>
    import { ref, onMounted } from "vue";
    import EventBus from "@/services/EventBus";
    import { VueFinalModal } from 'vue-final-modal'
    import LoadingButton from "@/components/LoadingButton.vue"
	import { showSuccess, showError, clearToast, validatePrincipal } from '@/utils/common';
    import { useMintToken } from "@/services/Token"
    const to = ref('');
    const amount = ref(0);
    const manageTokenModal = ref(false);
    const isLoading = ref(false);
    const tokenInfo = ref(null);
    
    const mint = ()=>{
        if(!validatePrincipal(to.value.trim())){
            showError("Receipient Principal ID is invalid!")
        }else if(amount.value <= 0){
            showError("Amount must be greater than 0!")
        }else{
            window.Swal.fire({
                icon: 'question',
                title: 'Confirmation',
                html: 'Please confirm that you are about to mint <span class="text-danger">'+amount.value+'</span> <strong>'+tokenInfo.value.symbol+'</strong> to <span class="text-danger">'+to.value+'</span>?',
                showCancelButton: true,
                confirmButtonText: 'Confirm',
                confirmButtonColor: '#bbbbbb'
            }).then(async (result) => {
                if (result.isConfirmed) {
                    isLoading.value = true;
                    //Close the dialog
                    let _rs = await useMintToken(tokenInfo.value.canister, to.value, amount.value);
                    if(_rs){
                        EventBus.emit('showManageTokenModal', {
                            status: false
                        })
                    }
                    isLoading.value = false;
                }
            })
        }
        
    }
    const checkPrincipal = ()=>{
        if(!validatePrincipal(to.value.trim())){
            showError("Receipient Principal ID is invalid!")
        }
    }
    const closeModal = ()=>{ manageTokenModal.value = false};

    onMounted(() => {
        EventBus.on("showManageTokenModal", obj => {
            console.log('obj', obj);
            manageTokenModal.value = obj.status;
            tokenInfo.value = obj;
            to.value = '';
            amount.value = 0;
            isLoading.value = false;
        });  
    })
</script>
<template>
    <VueFinalModal v-model="manageTokenModal" :z-index-base="2000" classes="modal fade show" content-class="modal-dialog modal-lg ">
        <div class="modal-content">
            <a href="#" @click.stop="closeModal" class="close" data-bs-dismiss="modal" aria-label="Close">
                <em class="icon ni ni-cross"></em>
            </a>
            <div class="modal-header">
                <h5 class="modal-title"><span class="text-capitalize">Mint </span> {{ tokenInfo.name }} (<span class="text-blue">{{ tokenInfo.symbol }}</span>) </h5>
            </div>
            <div class="modal-body pt-3 pb-0">
                <div class="pl-10 pb-3">
                    <div class="row gy-4">
                        <div class="col-sm-8">
                            <div class="form-group">
                                <label class="form-label required">Min to Principal</label>
                                <div class="form-control-wrap">
                                    <input type="text" class="form-control" placeholder="Min to Principal" required v-model="to" @change="checkPrincipal">
                                </div>
                            </div>
                        </div>

                        <div class="col-sm-4">
                            <div class="form-group">
                                <label class="form-label required">Amount to mint</label>
                                <div class="form-control-wrap">
                                    <input type="text" class="form-control" v-model="amount" required />
                                </div>
                            </div>
                        </div>
                        
                        <div class="col-sm-12 text-center">
                            <LoadingButton 
                                :loading="isLoading"
                                class="btn btn-primary btn-block"
                                @click="mint">Mint {{ tokenInfo.symbol }}
                            </LoadingButton>
                        </div>
                    </div>

                </div>
            </div>
            <div class="modal-footer bg-light">
                <ul class="btn-toolbar g-4 align-center">
                    <li><a href="javascript:void(0)" @click="closeModal" class="link link-primary">Close</a></li>
                </ul>
            </div>
        </div>
    </VueFinalModal>
</template>