<script setup>
    import { ref, onMounted } from 'vue';
    import { formatPoolMeta } from '@/utils/pool';
    import EventBus from "@/services/EventBus";
    import LoadingButton from "@/components/LoadingButton.vue"
    import { VueFinalModal } from 'vue-final-modal'
    import { useGetPoolMeta, useGetPoolLP, useApprovePosition } from '@/services/SwapPool';
    import { showError, showSuccess, showLoading, closeMessage} from '@/utils/common';
    import moment from 'moment';
    const newLockModal = ref(false);
	const poolCanister = ref("z6v2h-2qaaa-aaaag-qblva-cai");///z6v2h-2qaaa-aaaag-qblva-cai
	const poolName = ref("");
    const showDetail = ref(false);
    const positionId = ref("");
    const timeNow = moment().utc();
    const unlockDate = ref(moment().utc().add(30, 'days'));
    const unlockDays = ref(unlockDate.value.diff(timeNow, 'days'));
	const isLoading = ref(false);
	const poolMeta = ref(null);
    const lockStep = ref(1);
	const userLP = ref([]);
    const _poolMeta = {
            "token0":[
                [
                    "name", { "Text":"Canister Token" }
                ],
                [
                    "symbol",{ "Text":"XCANIC" }
                ],
                [
                    "decimals", { "Nat":"8" }
                ],
                [
                    "ownerAccount", { "Text":"6102c39ede652286711a1019b6e2e67c0b765241db23b3e96b9f203b6174e6a2" }
                ]
            ],
            "token1":[
                [
                    "name", { "Text":"Internet Computer" }
                ],
                [
                    "symbol", { "Text":"ICP" }
                ],
                [
                    "decimals", { "Nat":"8" }
                ],
                [
                    "fee", { "Nat":"3000" }
                ]
            ]
        }
        // poolMeta.value = formatPoolMeta(_poolMeta);
        // poolName.value = `${poolMeta.value.token0.symbol}/${poolMeta.value.token1.symbol}`;

    const getPoolMeta = async ()=> {
        if(poolCanister.value != ""){
            //fetch pool meta
            isLoading.value = true;
            // let _meta = await useGetPoolMeta(poolCanister.value);
            // if(_meta == null){
            //     isLoading.value = false;
            //     showError("Pool not found, please check your pool canister");
            //     return;
            // }
            poolMeta.value = formatPoolMeta(_poolMeta);
            poolName.value = `${poolMeta.value.token0.symbol}/${poolMeta.value.token1.symbol}`;
            await getPoolLP(poolCanister.value);
            isLoading.value = false;
        }
    };
    
    const handleDate = ()=>{
        let _now = moment().utc();
        console.log('object', unlockDate.value.valueOf());
        let _unlockDate = moment(unlockDate.value).utc();
        console.log('dfff', _now.format("DD/MM/YYYY hh:mm"), _unlockDate.format("DD/MM/YYYY hh:mm"));
        unlockDays.value = _unlockDate.diff(_now, 'days');
    }
    const getPoolLP = async ()=> {
        userLP.value = [];
        userLP.value = await useGetPoolLP(poolCanister.value);
    };
    const approvePosition = async (poolId) => {
        Swal.fire({
		title: "Approve position "+poolId+"?",
		text: "Grant ICTO permission to manage position ID (including transfer this position to smart contract). Confirm?",
		icon: "warning",
		showCancelButton: true,
		confirmButtonColor: "#3085d6",
		cancelButtonColor: "#d33",
		confirmButtonText: "Yes, I confirm"
        }).then(async (result) => {
            if(result.isConfirmed){
                showLoading("Approving Position...");
                console.log('start 1');
                let _rs = await useApprovePosition(poolCanister.value, poolId);
                console.log('start 2');
                if(!_rs){
                    showError("Approved failed, please try again later");
                }
                setTimeout(()=>{
                    lockStep.value = 2;
                    showSuccess("Approved success");
                    closeMessage()
                }, 3000);
            }
        });
    };
    const lockPosition = async (poolId) => {
        console.log('unlockDays.value', unlockDate.value);
        Swal.fire({
            title: "Lock position "+poolId+"",
            text: "Confirm lock this position, unlock date "+moment(unlockDate.value).format('MM/DD/YYYY, HH:mm')+"?",
            icon: "warning",
            showCancelButton: true,
            confirmButtonColor: "#3085d6",
            cancelButtonColor: "#d33",
            confirmButtonText: "Yes, I confirm"
		}).then(async (result) => {
			if(result.isConfirmed){
				//Step 1: Approve LP
                // showLoading("Approving Position...");
                // let _rs = await useApprovePosition(poolCanister.value, poolId);
                // if(!_rs){
                //     showError("Approved failed, please try again later");
                // }
                showLoading("Creating a liquidity lock contract, please wait...");
                //Step 2: Lock LP
                setTimeout(()=>{
                    lockStep.value = 3;
                    showSuccess("Contract created successfully, your liquidity locks contract ID: be2us-64aaa-aaaaa-qaabq-cai", 'swal');
                    goBack();
                    // closeMessage()
                }, 3000);
			}
		});
    };
    const showLPDetail = (position)=>{
        showDetail.value = true;
        positionId.value = position;
    }
    const goBack = ()=>{
        showDetail.value = false;
    }

    const closeModal = ()=>{ newLockModal.value = false};
    onMounted(()=>{
        EventBus.on("showNewLockModal", isOpen => {
            newLockModal.value = isOpen;
            isLoading.value = false;
        });
    })
</script>
<template>
    <VueFinalModal v-model="newLockModal" :z-index-base="2000" classes="modal fade show" content-class="modal-dialog modal-lg modal-dialog-scrollable">
        <div class="modal-content">
            <div class="modal-header  pt-5 pb-3">
                <h5 class="modal-title">Create liquidity lock</h5>
                <div class="btn btn-icon btn-sm btn-bg-light btn-active-light-danger ms-2" data-bs-dismiss="modal" aria-label="Close" @click="closeModal()">
                    <i class="fas fa-times"></i>
                </div>
            </div>
            <div class="modal-body pt-0 pb-5">
                <form class="form" @submit.prevent="getPoolMeta">
                    <div class="card mb-xl-1">
                        <div class="card-body">
                                <div class="current" v-if="!showDetail">
                                    <div class="w-100">
                                        <div class="row mb-5">
                                            <div class="col-md-12 fv-row">
                                                <label class="required fs-6 fw-bold form-label mb-2">Pool Canister</label>
                                                <div class="row fv-row">
                                                    <div class="col-10">
                                                        <input type="text" class="form-control form-control-sm" v-model="poolCanister" required placeholder="Pool canister on ICPSwap, ie: XCANIC/ICP"/>
                                                    </div>
                                                    <div class="col-2">
                                                        <LoadingButton class="btn btn-primary btn-sm" type="button" @click="getPoolMeta" :disabled="isLoading">Check</LoadingButton>
                                                    </div>
                                                </div>
                                                <div class="form-text">Note: Currently we only support pools created from <strong>ICPSwap</strong>. Find your LP <a href="https://info.icpswap.com/swap" target="_blank">here</a> <i class="fas fa-link"></i> </div>
                                            </div>
                                        </div>
                                        <div class="row mb-5" v-if="isLoading">
                                            <div class="col-md-12 fv-row">
                                                <label class="fs-6 fw-bold form-label mb-2 mb-5"><i class="fas fa-spinner fa-spin fa-1x"></i> Loading your LP position.</label>
                                            </div>
                                        </div>

                                        <div class="row mb-5" v-if="poolName !='' && !isLoading">
                                            <div class="col-md-12 fv-row">
                                                <label class="fs-6 fw-bold form-label mb-2 mb-5">Your {{poolName}} LP <span class="badge badge-primary">{{ userLP.length }}</span></label>
                                                <div class="row fv-row">
                                                    <div class="col-lg-6" v-for="pool in userLP">
                                                        <div class="d-flex d-flex-column align-items-center bg-light-primary rounded mb-7 p-5 cursor">
                                                            <div class="symbol symbol-45px symbol-circle me-5" data-bs-toggle="tooltip" title="" data-bs-original-title="Susan Redwood">
                                                                <span class="symbol-label bg-primary text-inverse-primary fw-bold fs-3">{{pool.id}}</span>
                                                            </div>
                                                            <div class="flex-grow-1 me-2">
                                                                <a href="#" class="fw-bolder text-gray-800 text-hover-primary fs-6" @click.stop="showLPDetail(pool.id)">{{poolName}}</a>
                                                                <span class="fw-bold d-block text-success py-1">Value: {{pool.liquidity}}</span>
                                                            </div>
                                                            <button type="button" class="btn btn-sm btn-danger" @click.stop="showLPDetail(pool.id)">Show</button>
                                                        </div>
                                                    </div>
                                                </div>
                                            </div>
                                        </div>
                                        
                                    </div>
                                </div>
                                <div class="row fv-row" v-if="showDetail">
                                    <div class="card h-100">
                                        <div class="card-body p-2">
                                            <div class="fs-2hx fw-bolder">
                                                XCANIC
                                                <button @click="goBack" class="float-right btn btn-block btn-light-primary btn-sm"><i class="fas fa-arrow-left"></i>Return</button>
                                            </div>
                                            <div class="fs-6 fw-bold text-gray-400 mb-7">qi26q-6aaaa-aaaap-qapeq-cai <Copy text="qi26q-6aaaa-aaaap-qapeq-cai" /></div>
                                            <div class="fs-6 d-flex justify-content-between mb-4">
                                                <div class="fw-bold">Position ID</div>
                                                <div class="d-flex fw-bolder">{{ positionId }}</div>
                                            </div>
                                            <div class="fs-6 d-flex justify-content-between mb-4">
                                                <div class="fw-bold">Total locked value</div>
                                                <div class="d-flex fw-bolder">$6,570</div>
                                            </div>
                                            <div class="fs-6 justify-content-between mt-4">
                                                <div class="row mb-2">
                                                    <div class="col-md-12 fv-row">
                                                        <label class="required fs-6 fw-bold form-label mb-2"><i class="fas fa-lock"></i> Unlock Date</label>
                                                        <div class="row fv-row">
                                                            <div class="col-12">
                                                                <VueDatePicker v-model="unlockDate" :min-date="timeNow" :enable-time-picker="true" time-picker-inline auto-apply @update:model-value="handleDate"></VueDatePicker>
                                                            </div>
                                                            <div class="form-text text-danger">
                                                                <i class="fas fa-warning text-danger"></i> Please carefully consider the unlock time. You can only claim locked positions after this time.
                                                            </div>
                                                        </div>
                                                    </div>
                                                </div>
                                                <div class="separator separator-dashed mb-2"></div>
                                                <div class="fs-6 d-flex justify-content-between mb-4">
                                                    <div class="fw-bold">Service fee</div>
                                                    <div class="d-flex fw-bolder">0 <span class="text-primary ms-1">$ICTO</span></div>
                                                </div>
                                                <div class="fs-6 d-flex justify-content-between mb-4">
                                                    <div class="fw-bold">Unlock date</div>
                                                    <div class="d-flex fw-bolder">{{ unlockDate?moment(unlockDate).format('MM/DD/YYYY, HH:mm'):0 }}</div>
                                                </div>
                                                <div class="fs-6 d-flex justify-content-between mb-4">
                                                    <div class="fw-bold">Days until unlock</div>
                                                    <div class="d-flex fw-bolder">{{ unlockDays || 0 }}</div>
                                                </div>
                                                <div class="row mb-5">
                                                    <div class="col-md-6 d-flex flex-column gap-7 gap-md-10">
                                                        <button @click="approvePosition(positionId)" class="btn btn-block btn-primary btn-sm" :disabled="lockStep==2">Approve</button>
                                                    </div>
                                                    <div class="col-md-6 d-flex flex-column gap-7 gap-md-10">
                                                        <button @click="lockPosition(positionId)" class="btn btn-block btn-primary btn-sm" :disabled="lockStep==1">Lock</button>
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
<style scoped>
.slide-left-enter-active, .slide-left-leave-active {
    transition: transform 0.5s;
}

.slide-left-enter, .slide-left-leave-to {
    transform: translateX(-100%);
}


</style>