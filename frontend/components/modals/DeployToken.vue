<script setup>
	import {ref, onMounted} from "vue";
	import { useCreateToken, useTokenApprove, useTransferFrom, useInstallToken  } from '@/services/Token';
	import { useChargeFee  } from '@/services/Backend';
	import { showError, showSuccess, txtToPrincipal, principalToText, closeMessage, showLoading } from '@/utils/common';
	const deployTokenModal = ref(false);
    import { VueFinalModal } from 'vue-final-modal'
    import EventBus from "@/services/EventBus";
    import LoadingButton from "@/components/LoadingButton.vue";
    import config from "@/config";
    import walletStore from "@/store";
    import token_deployer from "@/config/token_deloyer";
    import { Principal } from "@dfinity/principal";
    const isLoading = ref(false);
    const tabSelected = ref('deployer');//Options: deployer, custom
    import { useGetTotalPoolValue } from '@/services/SwapPool';

    const newToken = ref({
		token_name: "",
		token_symbol: "",
		logo: "",
		transfer_fee: 0,
        minting_account: null,
        initial_balances: [],
        fee_collector_account: []
	})
    onMounted(()=>{
        EventBus.on("showDeployTokenModal", isOpen => {
            deployTokenModal.value = isOpen;
            tabSelected.value = 'deployer';
        });
    })
    const handleFileUpload = async(event)=>{
        const file = event.target.files[0]
        if (file) {
            convertToBase64(file)
        }
    }
    const convertToBase64 = (file)=>{
        const reader = new FileReader()
        reader.readAsDataURL(file)
        reader.onload = () => {
            var stringLength = reader.result.length - 'data:image/png;base64,'.length;
            var sizeInBytes = 4 * Math.ceil((stringLength / 3))*0.5624896334383812;
            var sizeInKb=sizeInBytes/1000;
            if(sizeInKb>token_deployer.MAX_LOGO_SIZE) return showError("Logo size should be less than "+token_deployer.MAX_LOGO_SIZE+" KB!", true);
            else newToken.value.logo = reader.result;
            console.log('sizeInKb', sizeInKb, token_deployer.MAX_LOGO_SIZE);
        }
        reader.onerror = (error) => {
            console.error('Error converting file to base64:', error)
        }
    }
	const deployToken = async()=>{
        if(newToken.value.logo.length==0) return showError("Logo size should be less than "+token_deployer.MAX_LOGO_SIZE+" KB!", true);
        Swal.fire({
		title: "Are you sure?",
		text: "Deploy new token $"+newToken.value.token_symbol+" will charge "+config.SERVICE_FEES.DEPLOY_TOKEN+" ICP as service fee. Non-refundable once the token is deployed!",
		icon: "warning",
		showCancelButton: true,
		confirmButtonColor: "#3085d6",
		cancelButtonColor: "#d33",
		confirmButtonText: "Yes, I confirmed!"
		}).then(async (result) => {
            if (result.isConfirmed) {
                isLoading.value = true;
                showLoading("Approving token deployer to charge service fee...");
                newToken.value.minting_account = { owner: txtToPrincipal(walletStore.principal), subaccount: []};//Add minting account
                let _approved = await useTokenApprove(config.LEDGER_CANISTER_ID, {spender: config.TOKEN_DEPLOYER_CANISTER_ID, amount: config.SERVICE_FEES.DEPLOY_TOKEN*config.E8S});
                if(_approved == null){
                    isLoading.value = false;
                    closeMessage();
                    return;
                }
                if(_approved && _approved.hasOwnProperty('Err')){
                    isLoading.value = false;
                    if (_approved.Err?.InsufficientFunds) {
                        showError('Insufficient Funds', true);
                    }else{
                        showError("Approve not succeed, please see the console for further detail!", true);
                    }
                    return;
                }
                // return;
                showLoading("Installing token...");
                let response = await useInstallToken(newToken.value);
                isLoading.value = false;
                if(response && "ok" in response){
                    showSuccess("Token deployed successfully! Your token ID: "+principalToText(response.ok), true);
                }else{
                    showError(response.err, true);
                }
            }
        })
	}
    const deployCustom = ()=>{
        showError("Deploy with custom wasm and candid are under development!", true);
        return;
    }
    const swicthTab = (tab)=>{
        tabSelected.value = tab;
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
                        <div class="">
                                <div class="current">
                                    <div class="w-100 mt-5">
                                        <div class="row mb-5">
                                            <div class="col-md-6 fv-row">
                                                <label class="required fs-6 fw-bold form-label mb-2">Token Name</label>
                                                <div class="row fv-row">
                                                    <div class="col-12">
                                                        <input type="text" class="form-control" v-model="newToken.token_name" required placeholder="Token Name"/>
                                                    </div>
                                                </div>
                                            </div>
                                            <div class="col-md-6 fv-row">
                                                <label class="required fs-6 fw-bold form-label mb-2">Token Symbol</label>
                                                <div class="row fv-row">
                                                    <div class="col-12">
                                                        <input type="text" class="form-control" v-model="newToken.token_symbol" required placeholder="Token Symbol"/>
                                                    </div>
                                                </div>
                                            </div>
                                        </div>
                                        <div class="row mb-5">
                                            <div class="col-md-6 fv-row">
                                                <label class="required fs-6 fw-bold form-label mb-2">Decimals</label>
                                                <div class="row fv-row">
                                                    <div class="col-12">
                                                        <input type="text" class="form-control" placeholder="Decimals" disabled value="8" />
                                                    </div>
                                                </div>
                                            </div>
                                            <div class="col-md-6 fv-row">
                                                <label class="required fs-6 fw-bold form-label mb-2">Transfer Fee</label>
                                                <div class="row fv-row">
                                                    <div class="col-12">
                                                        <input type="text" class="form-control" v-model="newToken.transfer_fee" required placeholder="Transfer Fee"/>
                                                    </div>
                                                </div>
                                            </div>
                                        </div>
                                        <div class="row mb-5">
                                            <div class="col-md-12 fv-row">
                                                <label class="fs-6 fw-bold form-label mb-2 required">Logo <small class="text-danger">(Maximum size: {{token_deployer.MAX_LOGO_SIZE}} KB)</small></label>
                                                <div class="row fv-row">
                                                    <div class="col-12">
                                                        <input type="file" class="form-control" v-on:change="handleFileUpload" placeholder="Logo" required/>
                                                    </div>
                                                </div>
                                            </div>
                                        </div>
                                        <div class="alert bg-light-warning mb-5"> 
                                            <div>- The ICRC version that will be deployed is the official release from <strong>Dfinity</strong> via the <a href="https://dashboard.internetcomputer.org/canister/qaa6y-5yaaa-aaaaa-aaafa-cai" target="_blank">NNS SNS-WASM canister <i class="fa fa-up-right-from-square"></i></a></div>
                                            <div>- Your connected wallet will be fully controlled this token. ICTO will have no control over this canister.</div>
                                            <div>- Deploy new token will charges <strong>{{ config.SERVICE_FEES.DEPLOY_TOKEN }} ICP</strong> as service fee.</div>
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