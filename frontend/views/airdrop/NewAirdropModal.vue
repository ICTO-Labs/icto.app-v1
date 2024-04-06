<script setup>
    import { ref, onMounted } from 'vue';
    import EventBus from "@/services/EventBus";
    import LoadingButton from "@/components/LoadingButton.vue"
    import Codemirror from "codemirror-editor-vue3";
    import { VueFinalModal } from 'vue-final-modal'
    import moment from 'moment';
    import { usetGetMetadata, useGetMyBalance, useTokenApprove } from '@/services/Token';
    import { showError, closeMessage, showLoading, validatePrincipal } from '@/utils/common';
    import LoadingLabel from "@/components/LoadingLabel.vue"
    import walletStore from "@/store";
    import { QuillEditor } from '@vueup/vue-quill'
    import '@vueup/vue-quill/dist/vue-quill.snow.css';

    const newAirdropModal = ref(false);
    const isLoading = ref(false);
    const tokenInfo = ref(null);
    const tokenBalance = ref(0);
    const codemirror = ref(null);
    const lockStep = ref(1);
    const currentStep = ref(0);
    const steps = ref([
                "current",
                "pending",
                "pending",
                "pending"
            ]);
    const changeStep = (index)=>{
        steps.value[index] = "current";
        currentStep.value = index;
        for (let i = 0; i < steps.value.length; i++) {
            if (i != index) {
                if(i < index){ 
                    steps.value[i] = "completed";
                }else{
                    steps.value[i] = "pending";
                }
            }else{
                steps.value[i] = 'current'
            }
        }
    }  
    const getTokenBalance = async ()=>{
		isLoading.value = true;
        tokenBalance.value = 0;
		tokenBalance.value = await useGetMyBalance(airdrop.value.tokenId);
        stats.value.tokenBalance = tokenBalance.value;
		isLoading.value = false;
	}
    const stats = ref({
        totalRecipients: 0,
        totalAmount: 0,
        currentApproval: 0,
        tokenBalance: 0,
        error: 0
    });
    const airdrop = ref({
        tokenId: 'ryjl3-tyaaa-aaaaa-aaaba-cai',
        type: 1,
        recipients: [],
        claimFee: 0,
        startTime: new Date(),
        endTime: moment(new Date()).add(1, 'days').toDate(),
        title: '',
        description: '',
        website: '',
        twitter: '',
        telegram: '',
        discord: ''
    });
    const recipients = ref('');
    const loadSampleData = ()=>{
        recipients.value = `vkdhi-vlxfv-56jyt-tcyxp-qlhlk-4lnpb-k2r4q-uctef-ppvdr-iphm5-zqe,10
sarfp-y2id5-s2kqj-dgkrz-tk7ft-fpvhy-drpzc-bq7t3-sbqp7-txxlv-iqe,20
7mrjg-jibqe-nd4lb-xxksz-lv4vu-emumn-jgml4-gqlcy-cqq3z-rypfs-jae,10
5s246-2xf3s-vym4q-rxwf5-k6snu-anhsz-2tze5-vaxuh-alkvb-dudii-bqe,15
zxcjx-7yvay-ow7hh-nbocq-5aaru-n7nwq-xyhau-jnr6m-f36ho-xzufk-rae,50`;
        checkingRecipients();
    }
    const cmOptions = ref({
        mode: "text/javascript", // Language mode
        theme: "dracula", // Theme
    });
    const checkingRecipients = ()=>{
        let _recipients = recipients.value.split('\n');
        let _totalAmount = 0;
        let _totalError = 0;
        let _totalRecipients = 0;
        _recipients.forEach((item, idx)=>{
            let _item = item.split(',');
            if(_item.length >= 2){
                //Check recipient principal
                if(validatePrincipal(_item[0])){
                    _totalAmount += parseInt(_item[1])|0;
                    _totalRecipients++;
                    codemirror.value.cminstance.removeLineClass(idx, "background", "codemirror-error-line");
                }else{
                    codemirror.value.cminstance.addLineClass(idx, "background", "codemirror-error-line");
                    _totalError++;
                }
            }
        });
        stats.value.totalRecipients = _totalRecipients;
        stats.value.totalAmount = _totalAmount;
        stats.value.error = _totalError;
    }
    
    const getTokenInfo = async ()=>{
        if(airdrop.value.tokenId){
            isLoading.value = true;
            try{
                tokenInfo.value = await usetGetMetadata(airdrop.value.tokenId, 'icrc1');
                console.log(tokenInfo.value);
            }catch(e){
                console.log(e);
                showError('Token not found or did not match the token standard: ICRC1');
            }
            isLoading.value = false;

        }else tokenInfo.value = null;
    }

    const approveToken = async()=>{
        if(!tokenInfo.value){
            showError('Please enter a valid Token Canister ID!');
            changeStep(0);
            return;
        };
        if(stats.value.totalRecipients < 5){
            showError('Minimum recipients must be greater than 5!');
            changeStep(0);
            return;
        }
        Swal.fire({
		title: "Are you sure?",
		html: "Approve <strong>"+stats.value.totalAmount+ " "+tokenInfo.value.symbol+"</strong> to start the airdrop campaign?",
		icon: "warning",
		showCancelButton: true,
		confirmButtonColor: "#3085d6",
		cancelButtonColor: "#d33",
		confirmButtonText: "Yes, I confirmed!"
		}).then(async (result) => {
            if (result.isConfirmed) {
                showLoading("Approving token...");
                let _payload = {
                    spender: walletStore.principal,
                    amount: stats.value.totalAmount,
                };
                try{
                    let _approved = true;
                    // let _approved = await useTokenApprove(airdrop.value.tokenId, _payload);
                    if(_approved){
                        changeStep(2);
                    }else{
                        showError('Failed to approve token');
                    }
                    console.log('_approved', _approved);
                    stats.value.currentApproval = 1;
                }catch(e){
                    showError('Failed to approve token');
                }
                closeMessage();
                isLoading.value = false;
            }
        })
    }

    const createAirdrop = async()=>{
        console.log('airdrop', airdrop.value);
        console.log('stats', stats.value);
    }
    const closeModal = ()=>{ newAirdropModal.value = false};
    onMounted(()=>{
        EventBus.on("showNewAirdropModal", isOpen => {
            newAirdropModal.value = isOpen;
            isLoading.value = false;
        });
    })

</script>
<template>
    <VueFinalModal v-model="newAirdropModal" :z-index-base="2000" classes="modal fade show" content-class="modal-dialog modal-lg modal-dialog-scrollable">
        <div class="modal-content">
            <div class="modal-header pt-5 pb-3">
                <h5 class="modal-title">New Airdrop Setup</h5>
                <div class="btn btn-icon btn-sm btn-bg-light btn-active-light-danger ms-2" data-bs-dismiss="modal" aria-label="Close" @click="closeModal()">
                    <i class="fas fa-times"></i>
                </div>
            </div>
            <div class="modal-body pt-0 pb-5">
                <form class="form" @submit.prevent="createAirdrop">
                    <!--begin::Stepper-->
                    <div class="stepper stepper-pills">
                        <!--begin::Nav-->
                        <div class="stepper-nav flex-center flex-wrap mb-5">
                            <!--begin::Step 1-->
                            <div :class="`stepper-item mx-2 my-4  ${steps[0]}`">
                                <div class="stepper-icon w-40px h-40px">
                                    <i class="stepper-check fas fa-check"></i>
                                    <span class="stepper-number">1</span>
                                </div>
                                <div class="stepper-label">
                                    <h3 class="stepper-title">
                                        Prepare
                                    </h3>
                                </div>
                            </div>
                            <!--begin::Step 2-->
                            <div :class="`stepper-item mx-2 my-4  ${steps[1]}`" data-kt-stepper-element="nav" data-kt-stepper-action="step">
                                <div class="stepper-line w-40px"></div>
                                <div class="stepper-icon w-40px h-40px">
                                    <i class="stepper-check fas fa-check"></i>
                                    <span class="stepper-number">2</span>
                                </div>
                                <div class="stepper-label">
                                    <h3 class="stepper-title">
                                        Approve
                                    </h3>
                                </div>
                            </div>

                            <!--begin::Step 3-->
                            <div :class="`stepper-item mx-2 my-4  ${steps[2]}`" data-kt-stepper-element="nav" data-kt-stepper-action="step">
                                <div class="stepper-line w-40px"></div>
                                <div class="stepper-icon w-40px h-40px">
                                    <i class="stepper-check fas fa-check"></i>
                                    <span class="stepper-number">3</span>
                                </div>
                                <div class="stepper-label">
                                    <h3 class="stepper-title">
                                        Project info
                                    </h3>
                                </div>
                            </div>

                            <!--begin::Step 4-->
                            <div :class="`stepper-item mx-2 my-4  ${steps[3]}`" data-kt-stepper-element="nav" data-kt-stepper-action="step">
                                <div class="stepper-line w-40px"></div>
                                <div class="stepper-icon w-40px h-40px">
                                    <i class="stepper-check fas fa-check"></i>
                                    <span class="stepper-number">4</span>
                                </div>
                                <div class="stepper-label">
                                    <h3 class="stepper-title">
                                        Start
                                    </h3>
                                </div>
                            </div>
                        </div>
                        <!--end::Nav-->

                            <!--begin::Group-->
                            <div class="mb-5">
                                <div :class="`flex-column ${steps[0]}`" data-kt-stepper-element="content">
                                    <div class="w-100">
                                        <div class="row mb-2">
                                            <div class="col-md-12 fv-row">
                                                <div class="row fv-row">
                                                    <div class="col-md-6">
                                                        <label class="required fs-6 fw-bold form-label mb-2">Token Canister ID</label>
                                                        <input type="text" class="form-control" v-model="airdrop.tokenId" @change="getTokenInfo" placeholder="Token Canister Id"/>
                                                    </div>
                                                    <div class="col-md-6">
                                                        <label class="fs-6 fw-bold form-label mb-2">Balance
                                                        <LoadingLabel 
                                                            :loading="isLoading"
                                                            class="badge badge-light-primary ms-5"
                                                            @click="getTokenBalance"><i class="fas fa-arrows-rotate"></i> Refresh
                                                        </LoadingLabel>

                                                    </label>
                                                        <input type="text" class="form-control" :value="`${tokenBalance} ${tokenInfo?tokenInfo.symbol:'ICP'}`" placeholder="" readonly />
                                                    </div>
                                                </div>
                                                <div class="form-text">Note: Currently we only support <strong>ICRC</strong> standard Tokens!</div>
                                            </div>
                                        </div>
                                        <div class="row">
                                            <!--begin::Col-->
                                            <div class="col-lg-6">
                                                <!--begin::Option-->
                                                <input type="radio" class="btn-check" name="airdrop_type" value="1" checked="checked" id="normal" v-model="airdrop.type">
                                                <label class="btn btn-outline btn-outline-dashed btn-outline-default p-2 d-flex align-items-center mb-2" for="normal">
                                                    <i class="fas fa-wallet me-5 fs-2x"></i>
                                                    <span class="d-block fw-bold text-start">
                                                        <span class="text-dark fw-bolder d-block fs-5">Designated wallet</span>
                                                        <span class="text-muted fs-7">Only designated wallet can be claimed</span>
                                                    </span>
                                                </label>
                                                <!--end::Option-->
                                            <div class="fv-plugins-message-container invalid-feedback"></div></div>
                                            <!--end::Col-->
                                            <!--begin::Col-->
                                            <div class="col-lg-6">
                                                <!--begin::Option-->
                                                <input type="radio" class="btn-check" name="airdrop_type" value="2" id="any-wallet" v-model="airdrop.type">
                                                <label class="btn btn-outline btn-outline-dashed btn-outline-default p-2 d-flex align-items-center" for="any-wallet">
                                                    <i class="fas fa-random me-5 fs-2x"></i>
                                                    <span class="d-block fw-bold text-start">
                                                        <span class="text-dark fw-bolder d-block fs-5">Any wallet</span>
                                                        <span class="text-muted fs-7">Any wallet can join and claim the airdrop</span>
                                                    </span>
                                                </label>
                                                <!--end::Option-->
                                            </div>
                                            <!--end::Col-->
                                        </div>
                                        <div class="separator separator-dashed mb-3"></div>

                                        <div class="row mb-2" v-if="airdrop.type == 1">
                                            <div class="col-md-12 fv-row">
                                                <div class="d-flex justify-content-between">
                                                    <label class="required fs-6 fw-bold form-label mb-2">Recipients</label>
                                                    <div>
                                                    <span class="badge badge-light-primary fs-7 fw-bold me-2">Valid: {{stats.totalRecipients}}</span>
                                                    <span class="badge badge-light-danger fs-7 fw-bold" v-if="stats.error > 0">Error: {{stats.error}}</span>
                                                    </div>
                                                </div>

                                                <Codemirror
                                                    v-model:value="recipients"
                                                    :options="cmOptions"
                                                    border
                                                    placeholder=""
                                                    :height="200"
                                                    @change="checkingRecipients"
                                                    ref="codemirror"
                                                />

                                                <div class="d-flex flex-wrap w-100">
                                                    <div class="flex-grow-1"><strong>Format:</strong> Principal,Amount (Minimum: 5 recipients)</div>
                                                    <div class="">
                                                        <a href="#" @click="loadSampleData()">Load sample data</a>
                                                    </div>
                                                </div>
                                            </div>
                                        </div>
                                        <div class="row mb-5" v-if="airdrop.type == 2">
                                            <div class="col-md-4 fv-row">
                                                <label class="d-flex align-items-center fs-6 fw-bold mb-2"><span class="required">Total recipients</span></label>
                                                <div class="input-group mb-3">
                                                    <input type="text" class="form-control" placeholder="0" v-model="stats.totalRecipients">
                                                    <span class="input-group-text"><i class="fas fa-users"></i></span>
                                                </div>
                                            </div>
                                            <div class="col-md-4 fv-row">
                                                <label class="d-flex align-items-center fs-6 fw-bold mb-2"><span class="required">Total airdrop amount</span></label>
                                                <div class="input-group mb-3">
                                                    <input type="text" class="form-control" placeholder="0" v-model="stats.totalAmount">
                                                    <span class="input-group-text">{{ tokenInfo?.symbol || '---' }}</span>
                                                </div>
                                            </div>
                                            <div class="col-md-4 fv-row">
                                                <label class="d-flex align-items-center fs-6 fw-bold mb-2"><span class="">Each recipient</span></label>
                                                <div class="input-group mb-3">
                                                    <input type="text" class="form-control" placeholder="0" :value="stats.totalAmount/stats.totalRecipients" readonly />
                                                    <span class="input-group-text">{{ tokenInfo?.symbol || '---' }}</span>
                                                </div>
                                            </div>
                                        </div>
                                        
                                        
                                    </div>
                                </div>
                                <div :class="`flex-column ${steps[1]}`"  data-kt-stepper-element="content">
                                    <div class="row mb-5">
                                        <div class="col-md-6 fv-row">
                                            <label class="d-flex align-items-center fs-6 fw-bold mb-2"><span class="required">Start Time</span></label>
                                            <VueDatePicker v-model="airdrop.startTime" :min-date="new Date()" :enable-time-picker="true" placeholder="Start time" time-picker-inline auto-apply></VueDatePicker>

                                        </div>
                                        <div class="col-md-6 fv-row">
                                            <label class="d-flex align-items-center fs-6 fw-bold mb-2"><span class="required">End Time</span></label>
                                            <VueDatePicker v-model="airdrop.endTime" :min-date="new Date()" :enable-time-picker="true" placeholder="End time" time-picker-inline auto-apply></VueDatePicker>
                                        </div>
                                    </div>
                                    <div class="row mb-5">
                                        <div class="col-md-6 fv-row">
                                            <label class="d-flex align-items-center fs-6 fw-bold mb-2"><span class="required">Distribution Type:</span></label>
                                            <select class="form-control">
                                                <option value="1">Manual claim</option>
                                                <option value="2" v-if="airdrop.type==1">Auto distribution</option>
                                            </select>
                                        </div>
                                        <div class="col-md-6 fv-row">
                                            <label class="d-flex align-items-center fs-6 fw-bold mb-2"><span class="required">Claim Fee</span> <small>(set 0 for free)</small></label>
                                            <div class="input-group mb-3">
                                                <input type="number" class="form-control" placeholder="0" v-model="airdrop.claimFee">
                                                <span class="input-group-text" id="softcap">ICP</span>
                                            </div>
                                        </div>
                                    </div>
                                    <div class="row mb-5 border bg-light-primary border-dashed border-gray-300 rounded m-1">
                                        <div class="row g-0 text-default fw-bold fs-7 p-2">
                                            <div class="col px-2 rounded-2 me-7 mb-2 d-flex">
                                                <div class="flex-grow-1">Your token balance</div>
                                                <div class="fw-bolder fs-6">{{ stats.tokenBalance }} {{ tokenInfo?tokenInfo.symbol:'---' }}</div>
                                            </div>
                                            <div class="col px-2 rounded-2 mb-2 d-flex">
                                                <div class="flex-grow-1">Your current approval</div>
                                                <div class="fw-bolder fs-6">{{ stats.currentApproval }} {{ tokenInfo?tokenInfo.symbol:'---' }}</div>
                                            </div>
                                        </div>
                                        <div class="row g-0 text-default fw-bold fs-7 px-2">
                                            <div class="col px-2 rounded-2 me-7 mb-2 d-flex">
                                                <div class="flex-grow-1">Total amount of tokens to send</div>
                                                <div class="fw-bolder fs-6">{{ stats.totalAmount }} {{ tokenInfo?tokenInfo.symbol:'---' }}</div>
                                            </div>
                                            <div class="col px-2 rounded-2 mb-2 d-flex">
                                                <div class="flex-grow-1">Total recipients</div>
                                                <div class="fw-bolder fs-6">{{ stats.totalRecipients }}</div>
                                            </div>
                                        </div>
                                    </div>
                                </div>
                                <div :class="`flex-column ${steps[2]}`"  data-kt-stepper-element="content">
                                    <div class="row mb-5">
                                        <div class="col-md-12 fv-row">
                                            <label class="d-flex align-items-center fs-6 fw-bold mb-2"><span class="required">Campaign Title</span></label>
                                            <input type="text" class="form-control" v-model="airdrop.title" placeholder="Airdrop campaign"/>
                                        </div>
                                    </div>
                                    <div class="row mb-5">
                                        <div class="col-md-12 fv-row">
                                            <label class="d-flex align-items-center fs-6 fw-bold mb-2"><span class="required">Description</span></label>
                                            <QuillEditor theme="snow" v-model:content="airdrop.description" contentType="html" style="height: 150px"/>
                                            <!-- <textarea class="form-control" v-model="airdrop.description" placeholder="Airdrop description" rows="3"></textarea> -->
                                        </div>
                                    </div>
                                    <div class="row mb-5">
                                        <div class="col-md-6 fv-row">
                                            <label class="d-flex align-items-center fs-6 fw-bold mb-2">Website</label>
                                            <input class="form-control" v-model="airdrop.website" placeholder="Website" />
                                        </div>
                                        <div class="col-md-6 fv-row">
                                            <label class="d-flex align-items-center fs-6 fw-bold mb-2">Twitter (X)</label>
                                            <input class="form-control" v-model="airdrop.twitter" placeholder="Website" />
                                        </div>
                                    </div>
                                    <div class="row mb-5">
                                        <div class="col-md-6 fv-row">
                                            <label class="d-flex align-items-center fs-6 fw-bold mb-2">Telegram</label>
                                            <input class="form-control" v-model="airdrop.telegram" placeholder="Telegram" />
                                        </div>
                                        <div class="col-md-6 fv-row">
                                            <label class="d-flex align-items-center fs-6 fw-bold mb-2">Discord</label>
                                            <input class="form-control" v-model="airdrop.discord" placeholder="Discord" />
                                        </div>
                                    </div>

                                    <div class="notice bg-light-warning mb-5 p-2" role="alert">
                                        <div class="alert-text>">
                                            <p class="mb-0">- Please make sure to provide accurate information to avoid any issues with your airdrop campaign.</p>
                                            <p class="mb-0">- All information can be changed in the Airdrop panel.</p>
                                        </div>
                                    </div>    
                                </div>
                                <div :class="`flex-column ${steps[3]}`"  data-kt-stepper-element="content">
                                    4
                                </div>
                            </div>
                            <!--end::Group-->

                            <!--begin::Actions-->
                            <div class="d-flex flex-stack">
                                <div class="me-2">
                                    <button type="button" class="btn btn-light btn-sm btn-active-light-primary" @click="changeStep(currentStep-1)" v-if="currentStep>0">
                                        Back
                                    </button>
                                </div>
                                <div>
                                    <button type="button" class="btn btn-primary btn-sm" @click="createAirdrop()" v-if="currentStep==2">
                                        <span class="indicator-label">
                                            Create Airdrop
                                        </span>
                                    </button>
                                    <button type="button" class="btn btn-danger btn-sm"  @click="approveToken()" v-if="currentStep==1">
                                        <em class="fas fa-chevron-circle-down"></em> Approve
                                    </button>
                                    <button type="button" class="btn btn-primary btn-sm"  @click="changeStep(currentStep+1)" v-if="currentStep<2 && currentStep!=1" :disabled="!tokenInfo || stats.totalRecipients <5">
                                        <span v-if="!tokenInfo">Enter Token Canister</span>
                                        <span v-else-if="stats.totalRecipients<5">Minimum 5 recipients</span>
                                        <span v-else>Continue</span>
                                    </button>
                                </div>
                                <!--end::Wrapper-->
                            </div>
                            <!--end::Actions-->
                    </div>
                    <!--end::Stepper-->
                </form>
            </div>
        </div>
    </VueFinalModal>
</template>
<style scoped>
    .ql-snow{
        height: 150px !important;
        background: #cccccc !important;
    }
</style>