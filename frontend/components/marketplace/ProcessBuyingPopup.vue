<script setup>
    import { ref, onMounted } from "vue";
    import config from "@/config";
    import EventBus from "@/services/EventBus";
    import { showModal, showLoading, closeMessage, showSuccess, showError, validateAddress, validatePrincipal } from '@/utils/common';
    import {
        lockNFT, transferICP, settleNFT
    } from "@/services/Marketplace";
    import walletStore from '@/store/';
    const balance = 100*config.E8S;
    const currentStep = ref(0);

    const setStep = (step)=>{ currentStep.value = step };
 
    const processBuyingPopup = ref(false);
    const nft = ref(null);
    
    const closeModal = ()=>{ processBuyingPopup.value = false};
    const isWorking = ref(false);

    const processBuying = async ()=>{
        console.log('walletData.balance: ', balance);
        if(balance/config.E8S < nft.value.price){
            return showError('Your balance is insufficient!');
        }
        //Step 1: Register transaction
        // showLoading('Registering NFT transaction...');
        setStep(1);
        await new Promise(r => setTimeout(r, 3000));
        setStep(2);
        await new Promise(r => setTimeout(r, 5000));
        setStep(3);
        await new Promise(r => setTimeout(r, 3000));
        isWorking.value = false
        setStep(4);
        showSuccess("Your purchase was made successfully!")
        return;
        let _step1 = await lockNFT(nft.value.canisterId, nft.value.tokenId, nft.value.price);
        console.log('_step1: ', _step1);

        if("err" in _step1){
            closeSwal();
            return showError(JSON.stringify(_step1.err));
        }

        //Step 2: Sending ICP to system
        // showLoading('Making a payment...');
        setStep(2);
        let _step2 = await transferICP(_step1.ok, nft.value.price);
        console.log('_step2: ', _step2);
        //Step 3: Settling purchase
        // showLoading('Transferring NFT to your wallet...');
        setStep(3);
        let _step3 = await settleNFT(nft.value.canisterId, nft.value.tokenId);
        console.log('_step3: ', _step3);

        if(_step3){
            showSuccess("Your purchase was made successfully, Check your `Collected` ");
            // await this.getNFT();
            isWorking.value = false;//Done, ready to process next order
        }else{
            showError("Some thing wen wrong, please try again!");
        }
        // await walletStore.getBalance();//Update balance!
    }

    onMounted(() => {
        EventBus.on("showProcessBuyingPopup", async (obj) => {
            console.log('obj', obj);
            if(isWorking.value == true){
                showError("Please wait utils last order completed!", true)
            }else{
                isWorking.value = true;
                processBuyingPopup.value = obj.status;
                nft.value = obj.nft;
                //Start process
                await processBuying();
            }
        });  
    })
</script>
<template>
    <div v-if="processBuyingPopup" class="bg-white p-3 rounded-3 cartPopup w-300px shadow top-25">
        <div class="card p-0 card-xl-stretch mb-5 mb-xl-8">
            <div class="card-header min-h-30px p-0 border-0 pt-0 ps-2">
                <h3 class="card-title align-items-start flex-column">
                    <span class="card-label fw-bolder fs-6 text-dark" v-if="currentStep<4"><Spinner /> Buying NFT</span>
                    <span class="card-label fw-bolder fs-6 text-dark" v-else><i class="fas fa-check-circle text-success"></i> Completed</span>
                </h3>
                <div class="card-toolbar">
                    <button class="btn btn-icon btn-sm btn-light-danger" @click="closeModal"><i class="fas fa-times"></i></button>
                </div>
            </div>
            <div class="separator my-2"></div>
            <div class="card-body p-2">
                <div class="accordion" id="kt_accordion_1">
                    <div class="accordion-item">
                        <h2 class="accordion-header" id="kt_accordion_1_header_1">
                            <button :class="`accordion-button fs-6 fw-bold ${currentStep == 1?'':'collapsed'}`" type="button" data-bs-toggle="collapse" data-bs-target="#kt_accordion_1_body_1" aria-expanded="true" aria-controls="kt_accordion_1_body_1">
                                Step 1: Checking available
                            </button>
                        </h2>
                        <div id="kt_accordion_1_body_1" :class="`accordion-collapse collapse ${currentStep == 1?'show':''}`" aria-labelledby="kt_accordion_1_header_1" data-bs-parent="#kt_accordion_1">
                            <div class="accordion-body">
                                <i class="fas fa-check-circle text-success ms-2" v-if="currentStep>1"></i>
                                <Spinner v-else />
                                Locking the NFT #{{ nft.tokenId }}...
                            </div>
                        </div>
                    </div>

                    <div class="accordion-item">
                        <h2 class="accordion-header" id="kt_accordion_1_header_2">
                            <button :class="`accordion-button fs-6 fw-bold ${currentStep == 2?'':'collapsed'}`" type="button" data-bs-toggle="collapse" data-bs-target="#kt_accordion_1_body_2" aria-expanded="false" aria-controls="kt_accordion_1_body_2">
                            Step 2: Making Payment
                            </button>
                        </h2>
                        <div id="kt_accordion_1_body_2" :class="`accordion-collapse collapse ${currentStep == 2?'show':''}`" aria-labelledby="kt_accordion_1_header_2" data-bs-parent="#kt_accordion_1">
                            <div class="accordion-body">
                                <i class="fas fa-check-circle text-success ms-2" v-if="currentStep>2"></i>
                                <Spinner v-else />
                                Transfer 3.882 ICP to seller...
                            </div>
                        </div>
                    </div>

                    <div class="accordion-item">
                        <h2 class="accordion-header" id="kt_accordion_1_header_3">
                            <button :class="`accordion-button fs-6 fw-bold ${currentStep == 3 || currentStep == 4?'':'collapsed'}`" type="button" data-bs-toggle="collapse" data-bs-target="#kt_accordion_1_body_3" aria-expanded="false" aria-controls="kt_accordion_1_body_3">
                            Step 3: Verify Payment
                            </button>
                        </h2>
                        <div id="kt_accordion_1_body_3" :class="`accordion-collapse collapse ${currentStep == 3 || currentStep == 4?'show':''}`" aria-labelledby="kt_accordion_1_header_3" data-bs-parent="#kt_accordion_1">
                            <div class="accordion-body">
                                <i class="fas fa-check-circle text-success ms-2" v-if="currentStep>3"></i>
                                <Spinner v-else />
                                Transferring NFT to your wallet...
                            </div>
                        </div>
                    </div>
                </div>
            </div>
        </div>
    </div>
    <button id="kt_explore_toggle" class="explore-toggle btn btn-sm bg-body btn-color-gray-700 btn-active-danger shadow-sm position-fixed px-5 fw-bolder zindex-2 top-25 mt-5 end-0 fs-6 rounded-end-0 shadow" @click="processBuyingPopup=true" v-if="!processBuyingPopup && isWorking">
            <Spinner />
            <div class="position-absolute translate-middle top-0 start-0 bg-danger rounded-circle border border-4 border-white h-20px w-20px animation-blink"></div>
	</button>
</template>
<style scoped>
    .cartPopup{
        position: fixed;
        /* bottom: 54px; */
        /* top: 140px; */
        right:10px;
        -webkit-animation: expand 2s;
        /* box-shadow: 0 -19px 19px 2px rgba(0, 0, 0, 0.1); */
    }
    @-webkit-keyframes expand{
        0%{width:0px}
        100%{width:300px}
    }
    @-webkit-keyframes close{
        100%{height:450px}
        0%{height:0px}
    }
</style>