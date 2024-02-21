<script setup>
	import {ref, onMounted} from "vue";
	import { useCreateToken, useTokenApprove, useTransferFrom  } from '@/services/Token';
	import { useChargeFee  } from '@/services/Backend';
	import { showError, showSuccess } from '@/utils/common';
	const deployTokenModal = ref(false);
    import { VueFinalModal } from 'vue-final-modal'
    import EventBus from "@/services/EventBus";
    import LoadingButton from "@/components/LoadingButton.vue";
    import config from "@/config";
    import walletStore from "@/store";
    const isLoading = ref(false);
	const newToken = ref({
		name: "Test Token",
		symbol: "TEST",
		decimals: 8,
		description: "",
		logo: "",
		fee: 0,
		supply: 0,
	})
    onMounted(()=>{
        EventBus.on("showDeployTokenModal", isOpen => {
            deployTokenModal.value = isOpen;
        });
    })

	const deployToken = async()=>{
        Swal.fire({
		title: "Are you sure?",
		text: "Deploy new token $"+newToken.value.symbol+" will charge "+config.SERVICE_FEES.DEPLOY_TOKEN+" $ICTO as service fee. Non-refundable once the token is deployed!",
		icon: "warning",
		showCancelButton: true,
		confirmButtonColor: "#3085d6",
		cancelButtonColor: "#d33",
		confirmButtonText: "Yes, I confirmed!"
		}).then(async (result) => {
            if (result.isConfirmed) {
                // let _approve = await useTokenApprove(config.SERVICE_CANISTER_ID, {spender: config.BACKEND_CANISTER_ID, amount: config.SERVICE_FEES.DEPLOY_TOKEN});
                // console.log('_approve', _approve);
                let _transfer = await useChargeFee({from: walletStore.principal, to: 'v57dj-hev4p-lsvdl-dckvv-zdcvg-ln2sb-tfqba-nzb4g-iddrv-4rsq3-mae', amount: 1});
                console.log('transfer', _transfer);
                return;
                isLoading.value = true;
                let canister_id = await useCreateToken(newToken.value);
                isLoading.value = false;
                if(typeof(canister_id) =='string') showSuccess("Token deployed successfully! Your token ID: "+canister_id, true);
                else{
                    showError(canister_id.err, true);
                }
                // console.log(canister_id);
            }
        })
	}
    const closeModal = ()=>{ deployTokenModal.value = false};

</script>
<template>
        <VueFinalModal v-model="deployTokenModal" :z-index-base="2000" classes="modal fade show" content-class="modal-dialog modal-lg modal-dialog-scrollable">
            <div class="modal-content">
                <div class="modal-header  pt-5 pb-3">
                    <h5 class="modal-title">Deploy New Token</h5>
                    <div class="btn btn-icon btn-sm btn-bg-light btn-active-light-danger ms-2" data-bs-dismiss="modal" aria-label="Close" @click="closeModal()">
                        <i class="fas fa-times"></i>
                    </div>
                </div>
                <div class="modal-body pt-0 pb-5">
                    <form class="form" @submit.prevent="deployToken">
                    <div class="card mb-xl-1">
                        <div class="card-body">
                                <div class="current" data-kt-stepper-element="content">
                                    <div class="w-100">
                                        <div class="row mb-5">
                                            <div class="col-md-6 fv-row">
                                                <label class="required fs-6 fw-bold form-label mb-2">Token Name</label>
                                                <div class="row fv-row">
                                                    <div class="col-12">
                                                        <input type="text" class="form-control" v-model="newToken.name" required placeholder="Token Name"/>
                                                    </div>
                                                </div>
                                            </div>
                                            <div class="col-md-6 fv-row">
                                                <label class="required fs-6 fw-bold form-label mb-2">Token Symbol</label>
                                                <div class="row fv-row">
                                                    <div class="col-12">
                                                        <input type="text" class="form-control" v-model="newToken.symbol" required placeholder="Token Symbol"/>
                                                    </div>
                                                </div>
                                            </div>
                                        </div>
                                        <div class="row mb-5">
                                            <div class="col-md-12 fv-row">
                                                <label class="fs-6 fw-bold form-label mb-2">Description <small>(optional)</small></label>
                                                <div class="row fv-row">
                                                    <div class="col-12">
                                                        <textarea class="form-control fw-normal" v-model="newToken.description" placeholder="Introduce about your token, this will not display on chain!"></textarea>
                                                    </div>
                                                </div>
                                            </div>
                                        </div>
                                        <div class="row mb-5">
                                            <div class="col-md-6 fv-row">
                                                <label class="required fs-6 fw-bold form-label mb-2">Decimals</label>
                                                <div class="row fv-row">
                                                    <div class="col-12">
                                                        <input type="text" class="form-control" v-model="newToken.decimals" required placeholder="Decimals" disabled />
                                                    </div>
                                                </div>
                                            </div>
                                            <div class="col-md-6 fv-row">
                                                <label class="required fs-6 fw-bold form-label mb-2">Transfer Fee</label>
                                                <div class="row fv-row">
                                                    <div class="col-12">
                                                        <input type="text" class="form-control" v-model="newToken.fee" required placeholder="Transfer Fee"/>
                                                    </div>
                                                </div>
                                            </div>
                                        </div>
                                        <div class="row mb-5">
                                            <div class="col-md-12 fv-row">
                                                <label class="fs-6 fw-bold form-label mb-2">Logo <small>(optional)</small></label>
                                                <div class="row fv-row">
                                                    <div class="col-12">
                                                        <input type="file" class="form-control" v-on:change="uploadLogo" placeholder="Decimals"/>
                                                    </div>
                                                </div>
                                            </div>
                                        </div>
                                        <div class="alert bg-light-warning mb-5"> 
                                            <div>- Your connected wallet will be fully controlled this token. ICTO will have no control over this canister.</div>
                                            <div>- Deploy new token will charges <strong>{{ config.SERVICE_FEES.DEPLOY_TOKEN }} $ICTO</strong> as service fee.</div>
                                        </div>
                                        <div class="d-flex flex-column gap-7 gap-md-10">
                                            <LoadingButton 
                                            :loading="isLoading"
                                            class="btn btn-danger btn-block"
                                            type="submit"><i class="fas fa-angle-double-up"></i> Start Deploy
                                            </LoadingButton>
                                        </div>
                                    </div>
                                </div>
                        </div>
                    </div>
                </form>
        </div>
    </div>
</VueFinalModal>

</template>