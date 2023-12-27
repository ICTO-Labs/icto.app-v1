<script setup>
    import { VueFinalModal } from 'vue-final-modal'
    import EventBus from "@/services/EventBus";
    import { onMounted, ref } from 'vue';
    import _api from "@/ic/api";
    import { decodeICRCMetadata } from "@/utils/token";
    import LoadingButton from "@/components/LoadingButton.vue"
	import { showSuccess, showError, clearToast, validatePrincipal } from '@/utils/common';
    import { useAssetStore } from '@/store/token';
    import { usetGetMetadata } from '@/services/Token';
    const storeAsset = useAssetStore();

    const importTokenModal = ref(false);
    const tokenStandard = ref('icrc3');
    const canisterId = ref('2ouva-viaaa-aaaaq-aaamq-cai');
    const isImported = ref(false);
    const agree = ref(false);
    const tokenInfo = ref(null);
    const isLoading = ref(false);

    onMounted(()=>{
        EventBus.on("showImportTokenModal", isOpen => {
            importTokenModal.value = isOpen;
            //reset
            agree.value = false;
            isImported.value = false;
            isLoading.value = false;
            tokenInfo.value = null;
            // canisterId.value = '';
        });
    })

    const checkCanisterId = async ()=>{
        isImported.value = false;
        tokenInfo.value = null;
        agree.value = false;
    }
    const importToken = async()=>{
        isLoading.value = true;
        if(validatePrincipal(canisterId.value.trim())){
            clearToast();
            let _tokenInfo = await usetGetMetadata(canisterId.value, tokenStandard.value);
            isLoading.value = false;
            if(!_tokenInfo || _tokenInfo.standard != tokenStandard.value){
                isLoading.value = false;
                // showError('Canister not found or did not match the token standard: '+tokenStandard.value.toUpperCase());
            }else{
                tokenInfo.value = _tokenInfo;
                isImported.value = true;
            }
        }else{
            showError("Invalid Canister ID")
            isLoading.value = false;
        }
        isLoading.value = false;
       
    }

    const confirmImport = ()=>{
        let _rs = storeAsset.addAsset(canisterId.value, tokenInfo.value.name, tokenInfo.value.symbol, tokenStandard.value)
        if(_rs){
            EventBus.emit("showImportTokenModal", false);
            showSuccess("Token imported!")
        }else {
            showError("Token existed!")
        }
    }

    const closeModal = ()=>{ importTokenModal.value = false};
</script>

<template>
    <VueFinalModal v-model="importTokenModal" :z-index-base="2000" classes="modal fade show" content-class="modal-dialog modal-lg">
            <div class="modal-content">
               
                <div class="modal-header">
                    <h5 class="modal-title">Import Token</h5>
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
                    <div class="row gy-4">
                        <div class="col-sm-12">
                            <div class="form-group">
                                <label class="form-label"><span class="required">Token Standard</span></label>
                                <div class="form-control-wrap">
                                    <select class="form-select" v-model="tokenStandard">
                                        <option value="icrc3" selected>ICRC-3</option>
                                        <option value="icrc2">ICRC-2</option>
                                        <option value="icrc1">ICRC-1</option>
                                    </select>
                                </div>
                            </div>
                        </div>

                        <div class="col-sm-12">
                            <div class="form-group">
                                <label class="form-label"><span class="required">Canister ID</span> </label>
                                <div class="form-control-wrap">
                                    <input type="text" class="form-control w-100" placeholder="Canister ID" required v-model="canisterId" @keyup="checkCanisterId">
                                </div>
                            </div>
                        </div>
                        <div class="col-sm-12 text-center" v-if="!isImported">
                            <!-- <button type="submit" class="btn btn-primary btn-block" @click="importToken" :disabled="!importButtonReady || isLoading">
                                <em class="icon ni ni-send"></em><span class="text-capitalize">Import</span>
                            </button> -->
                            <LoadingButton 
                                :loading="isLoading"
                                class="btn btn-primary btn-block"
                                @click="importToken">Import
                            </LoadingButton>
                        </div>
                        <div v-if="isImported" class="mt-10">
                            <div class="d-flex align-items-center mb-10 alert alert-dismissible bg-light-primary d-flex flex-column flex-sm-row w-100 p-5 mb-10">
                                <div class="me-5 position-relative">
                                    <div class="symbol symbol-45px symbol-circle">
                                        <span class="symbol-label bg-primary text-white fw-semibold">
                                            {{tokenInfo.symbol.charAt(0)}}
                                        </span>
                                     </div>
                                </div>
                                <div class="fw-semibold">
                                    <a href="#" class="fs-5 fw-bold text-gray-900 text-hover-primary">{{tokenInfo.name}} ({{tokenInfo.symbol}})</a>
                                    <div class="text-gray-500">
                                        {{ canisterId }}
                                    </div>
                                </div>
                                <div class="badge badge-primary ms-auto">{{tokenInfo.standard.toLocaleUpperCase()}}</div>
                            </div>
                            <div class="col-sm-12">
                                <div class="alert alert-dismissible bg-light-danger border border-danger border-dashed flex-sm-row w-100 p-5 mb-10">
                                    <h4 class="mb-1 text-danger">Warning!</h4>
                                    <em class="icon ni ni-alert-circle"></em> 
                                        Anyone can create a token on Internet Computer with any name and logo, including creating fake versions of existing tokens and tokens that claim to represent projects that do not have a token.
                                        <br />            
                                        <span class="text-danger">These risks are always present. Please DYOR before investing!</span>
                                </div>
                            </div> 
                        <div class="col-sm-12">
                            <div class="form-check form-check-custom form-check-solid">
                                <input class="form-check-input" type="checkbox" id="flexCheckDefault" v-model="agree"/>
                                <label class="form-check-label" for="flexCheckDefault">
                                    I have read the risk warning carefully and agree to take the risk myself
                                </label>
                            </div>
                        </div>
                        <div class="col-sm-12 text-center mt-5">
                            <button type="submit" class="btn btn-primary btn-block" @click="confirmImport" :disabled="!agree">
                                <em class="icon ni ni-send"></em><span class="text-capitalize">Confirm</span>
                            </button>
                        </div>
                        </div>
                        
                        
                    </div>

                </div>
                </div>
                
        </div>

    </VueFinalModal>

</template>