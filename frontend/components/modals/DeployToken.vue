<script setup>
	import {ref, onMounted} from "vue";
	import { useCreateToken } from '@/services/Token';
	import { showLoading, showSuccess } from '@/utils/common';
	const deployTokenModal = ref(false);
    import { VueFinalModal } from 'vue-final-modal'
    import EventBus from "@/services/EventBus";

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
		showLoading("Deploying Token...");
		let canister_id = await useCreateToken(newToken.value);
		if(canister_id) showSuccess("Token deployed successfully..."+canister_id)
		console.log(canister_id);
	}
    const closeModal = ()=>{ deployTokenModal.value = false};

</script>
<template>
	 <VueFinalModal v-model="deployTokenModal" :z-index-base="2000" classes="modal fade show" content-class="modal-dialog modal-lg">
            <div class="modal-content">
               
                <div class="modal-header">
                    <h5 class="modal-title">Deploy New Token</h5>
                    <div class="btn btn-icon btn-sm btn-active-light-danger ms-2" data-bs-dismiss="modal" aria-label="Close" @click="closeModal()">
                        <span class="svg-icon svg-icon-2x">
                            <svg xmlns="http://www.w3.org/2000/svg" width="24" height="24" viewBox="0 0 24 24" fill="none">
                                <rect opacity="0.5" x="6" y="17.3137" width="16" height="2" rx="1" transform="rotate(-45 6 17.3137)" fill="black"></rect>
                                <rect x="7.41422" y="6" width="16" height="2" rx="1" transform="rotate(45 7.41422 6)" fill="black"></rect>
                            </svg>
                        </span>
                    </div>
                </div>
                <div class="">
                    <form class="form" @submit.prevent="deployToken">
                    <div class="card mb-xl-8">
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
                                        <div class="row">
                                            <div class="col-md-6 fv-row">
                                                <label class="fs-6 fw-bold form-label mb-2"></label>
                                                <div class="row fv-row">
                                                    <div class="col-12">
                                                        <button type="submit" class="btn btn-sm btn-lg btn-danger btn-block">Deploy Token <i class="fas fa-upload"></i></button>
                                                    </div>
                                                </div>
                                            </div>
                                            
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