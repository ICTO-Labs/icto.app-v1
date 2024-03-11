<script setup>
    import { ref, onMounted } from 'vue';
    import { formatTokenMeta, isInRange } from '@/utils/pool';
    import EventBus from "@/services/EventBus";
    import LoadingButton from "@/components/LoadingButton.vue"
    import { VueFinalModal } from 'vue-final-modal'
    import { useGetPoolMeta, useGetTokenMeta, useGetPoolLP, useApprovePosition, useTransferPosition, useGetPoolValue } from '@/services/SwapPool';
    import { useCreateLiquidLocker } from '@/services/Deployer';
    import { showError, showSuccess, showLoading, closeMessage} from '@/utils/common';
    import { currencyFormat } from "@/utils/token";
    import walletStore from '@/store/';
    import moment from 'moment';
    import config from '@/config';
    const newLockModal = ref(false);
	const poolCanister = ref("z6v2h-2qaaa-aaaag-qblva-cai");///z6v2h-2qaaa-aaaag-qblva-cai
	const poolName = ref("");
    const showDetail = ref(false);
    const positionDetail = ref(null);
    const timeNow = moment();
    const durationTime = ref(86400);
    const durationUnit = ref(7);
    const unlockDate = ref(moment().add(durationUnit.value*durationTime.value, 'seconds'));
    const unlockDays = ref(unlockDate.value.diff(timeNow, 'days'));
	const isLoading = ref(false);
	const poolMeta = ref(null);
	const tokenMeta = ref(null);
    const lockStep = ref(1);
	const userLP = ref([]);
    const currentTick = ref(0);
    const sqrtPriceX96 = ref(0);
    let _tokenMeta = {
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
            let _poolMeta = await useGetPoolMeta(poolCanister.value);
            if(_poolMeta == null){
                isLoading.value = false;
                showError("Pool not found, please check your pool canister");
                return;
            }
            poolMeta.value = _poolMeta;
            sqrtPriceX96.value = Number(poolMeta.value.sqrtPriceX96)
            currentTick.value = Number(poolMeta.value.tick);
            //Step2. get Token meta
            if(config.ENV != "dev"){
                // _tokenMeta = await useGetTokenMeta(poolCanister.value);
            }
            if(_tokenMeta == null){
                isLoading.value = false;
                showError("Token not found, please check your pool canister");
                return;
            }
            tokenMeta.value = formatTokenMeta(_tokenMeta);//formatPoolMeta(_tokenMeta);
            poolName.value = `${tokenMeta.value.token0.symbol}/${tokenMeta.value.token1.symbol}`;
            await getPoolLP(poolCanister.value);
            isLoading.value = false;
        }
    };
    
    const handleDate = ()=>{
        let _now = moment();
        let _unlockDate = moment().add(durationUnit.value*durationTime.value, 'seconds');
        unlockDate.value = _unlockDate;
        unlockDays.value = _unlockDate.diff(_now, 'days');
    }
    const getPoolLP = async ()=> {
        userLP.value = [];
        userLP.value = await useGetPoolLP(poolCanister.value);
        userLP.value.forEach((pos)=>{
            pos.value = useGetPoolValue(sqrtPriceX96.value, Number(pos.tickLower), Number(pos.tickUpper), Number(pos.liquidity), currentTick.value);
        })
    };

    const approvePosition = async (positionId) => {
        Swal.fire({
		title: "Approve position "+positionId+"?",
		text: "Grant ICTO permission to manage position ID (including transfer this position to smart contract). Confirm?",
		icon: "warning",
		showCancelButton: true,
		confirmButtonColor: "#3085d6",
		cancelButtonColor: "#d33",
		confirmButtonText: "Yes, I confirm"
        }).then(async (result) => {
            if(result.isConfirmed){
                showLoading("Approving Position...");
                let _rs = await useApprovePosition(poolCanister.value, config.DEPLOYER_CANISTER_ID, positionId);
                if(!_rs){
                    showError("Approved failed, please try again later!");
                }else{
                    lockStep.value = 2;
                    showSuccess("Approved success");
                }
                closeMessage();
            }
        });
    };
    const lockPosition = async (positionId) => {
        console.log('unlockDays.value', unlockDate.value);
        Swal.fire({
            title: "Lock position "+positionId+"",
            text: "Confirm lock this position, unlock time: "+moment(unlockDate.value).format('YYYY-MM-DD hh:mm:ss')+"?",
            icon: "warning",
            showCancelButton: true,
            confirmButtonColor: "#3085d6",
            cancelButtonColor: "#d33",
            confirmButtonText: "Yes, I confirm"
		}).then(async (result) => {
			if(result.isConfirmed){
                //Step 2: Lock LP
                showLoading("Creating a liquidity lock contract, please wait...");
                let _payload = {
                    "positionId": Number(positionId),
                    "durationTime": Number(durationTime.value),
                    "durationUnit": Number(durationUnit.value),
                    "provider": "ICPSwap",
                    "meta": [],
                    "poolName": poolName.value,
                    "poolId": poolCanister.value,
                    "token0": {
                        "address": "qi26q-6aaaa-aaaap-qapeq-cai",
                        "standard": "DIP20",
                        "name": "XCANIC"
                    },
                    "token1": {
                        "address": "ryjl3-tyaaa-aaaaa-aaaba-cai",
                        "standard": "ICP",
                        "name": "ICP"
                    }
                }
                let _contract = await useCreateLiquidLocker(_payload);

                if(_contract && "ok" in _contract){
                    lockStep.value = 3;
                    showSuccess("Contract created successfully, your liquidity locks contract ID: "+_contract.ok, true);
                    goBack();
                    await getPoolLP();
                }else{
                    if(_contract && "err" in _contract){
                        showError(_contract.err, true);
                    }else{
                        showError("Create contract failed, check console log for further information!", true);
                    }
                }
			}
		});
    };
    const showLPDetail = (position)=>{
        showDetail.value = true;
        positionDetail.value = position;
    }
    const goBack = ()=>{
        showDetail.value = false;
    }

    const closeModal = ()=>{ newLockModal.value = false};
    onMounted(()=>{
        EventBus.on("showNewLockModal", isOpen => {
            newLockModal.value = isOpen;
            isLoading.value = false;
            showDetail.value = false;
            userLP.value = [];
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
                    <div class="card1 mb-xl-1">
                        <div class="card-body">
                                <div class="current" v-if="!showDetail">
                                    <div class="w-100">
                                        <div class="row mb-5">
                                            <div class="col-md-12 fv-row">
                                                <label class="required fs-6 fw-bold form-label mb-2">ICPSwap Pair</label>
                                                <div class="row fv-row">
                                                    <div class="col-10">
                                                        <input type="text" class="form-control form-control-sm" v-model="poolCanister" disabled placeholder="Pool canister on ICPSwap, ie: XCANIC/ICP"/>
                                                    </div>
                                                    <div class="col-2">
                                                        <LoadingButton class="btn btn-primary btn-sm" type="button" @click="getPoolMeta" :disabled="isLoading">Check</LoadingButton>
                                                    </div>

                                                    <!-- <button type="button" class="btn btn-sm btn-light-primary" @click="approvePosition(6)"> Create Contract</button> -->
                                                </div>
                                                <div class="form-text">Note: Currently we only support pools created from <strong>ICPSwap</strong>. Find your LP <a href="https://info.icpswap.com/swap" target="_blank">here</a> <i class="fas fa-link"></i> </div>
                                            </div>
                                        </div>
                                        <div class="row mb-5" v-if="isLoading">
                                            <div class="col-md-12 fv-row">
                                                <label class="fs-6 fw-bold form-label mb-2 mb-5"><i class="fas fa-spinner fa-spin fa-1x"></i> Loading your LP...</label>
                                            </div>
                                        </div>

                                        <div class="row mb-5" v-if="poolName !='' && !isLoading">
                                            <div class="col-md-12 fv-row">
                                                <label class="fs-6 fw-bold form-label mb-2 mb-5">Your {{poolName}} Positions <span class="badge badge-primary">{{ userLP.length }}</span></label>
                                                <div class="row fv-row">
                                                    <div class="col-lg-6" v-for="position in userLP">
                                                        <!-- <div :class="`fw-normal fs-8 py-1 px-2 badge badge-${isInRange(currentTick, position.tickLower, position.tickUpper) ? 'primary' : 'warning'} position-absolute`">{{ isInRange(currentTick, position.tickLower, position.tickUpper) ? "In range": "Out of range" }}</div> -->

                                                        <div class="d-flex d-flex-column align-items-center bg-light-primary rounded mb-5 p-2 border border-primary border-hover">
                                                            <div class="symbol symbol-65px symbol-circle me-5" title="Position" >
                                                                <span :class="`symbol-label bg-${position.isInrange ? 'success' : 'warning'} text-inverse-primary fw-bold fs-1`">{{position.id}}</span>
                                                            </div>
                                                            <div class="flex-grow-1 me-2">
                                                                <div class="d-flex d-flex-column p-0 min-h-auto">
                                                                    <div class="flex-grow-1 p-0">
                                                                        <a href="#" class="fw-bolder text-dark text-hover-primary fs-6" @click.stop="showLPDetail(position)">
                                                                            <span class="fw-normal text-gray">Value:</span> ${{position.value.totalValueInUSD.toFixed(2)}} 
                                                                        </a>
                                                                    </div>
                                                                    <div class="flex-grow-1 text-end">
                                                                        <span :class="`fw-normal badge badge-light-${position.isInrange ? 'success' : 'warning'}`">
                                                                            <i class="bullet bullet-dot bg-success h-8px w-8px me-1" v-if="position.isInrange"></i>
                                                                            <i class="fas fa-exclamation-circle text-warning fs-1x" v-else></i>
                                                                            {{ position.isInrange ? "In range": "Out of range" }}
                                                                        </span>
                                                                        <!-- <span :class="`fw-normal badge badge-light-${isInRange(currentTick, position.tickLower, position.tickUpper) ? 'success' : 'warning'}`">
                                                                            <i class="bullet bullet-dot bg-success h-8px w-8px me-1" v-if="isInRange(currentTick, position.tickLower, position.tickUpper)"></i>
                                                                            <i class="fas fa-warning text-warning fs-1x" v-else></i>
                                                                            {{ isInRange(currentTick, position.tickLower, position.tickUpper) ? "In range": "Out of range" }}</span> -->
                                                                        
                                                                    </div>
                                                                </div>
                                                                    
                                                                <div class="d-flex flex-stack pt-1">
                                                                    <div class="d-flex align-items-center me-2">
                                                                        <div class="bullet bg-primary me-3"></div>
                                                                        <div class="fs-7 text-gray-800 text-hover-primary">{{ tokenMeta.token0.symbol }} amount:</div>
                                                                    </div>
                                                                    <div class="fs-7 fw-bold px-3">{{currencyFormat(position.value.amount0)}}</div>
                                                                </div>
                                                                <div class="d-flex flex-stack">
                                                                    <div class="d-flex align-items-center me-2">
                                                                        <div class="bullet bg-primary me-3"></div>
                                                                        <div class="fs-7 text-gray-800 text-hover-primary">{{ tokenMeta.token1.symbol }} amount:</div>
                                                                    </div>
                                                                    <div class="fs-7 fw-bold px-3">{{position.value.amount1.toFixed(2)}}</div>
                                                                </div>

                                                                <div class="d-flex flex-column gap-7 gap-md-10 mt-2 mb-2">
                                                                    <button href="#" class="btn btn-sm btn-danger badge " @click.stop="showLPDetail(position)"><i class="fas fa-lock"></i> Create liquidity lock</button>
                                                                </div>

                                                            </div>
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
                                                {{ poolName }}
                                                <button @click="goBack" class="float-right btn btn-block btn-light-primary btn-sm"><i class="fas fa-arrow-left"></i>Return</button>
                                            </div>
                                            <div class="fs-6 fw-bold text-gray-400 mb-7">Pool: {{ poolCanister }} <Copy :text="poolCanister" /></div>
                                            <div class="fs-6 d-flex justify-content-between mb-4">
                                                <div class="fw-bold">Position ID</div>
                                                <div class="d-flex fw-bolder">{{ positionDetail.id }}</div>
                                            </div>
                                            <div class="fs-6 d-flex justify-content-between mb-4">
                                                <div class="fw-bold">Total locked value</div>
                                                <div class="d-flex fw-bolder">${{ positionDetail.value.totalValueInUSD.toFixed(4) }}</div>
                                            </div>
                                            <div class="fs-6 justify-content-between mt-4">
                                                <div class="row mb-2">
                                                    <div class="col-md-12 fv-row">
                                                        <label class="required fs-6 fw-bold form-label mb-2"><i class="fas fa-unlock-alt"></i> Unlock duration</label>
                                                        <div class="row fv-row">
                                                            <div class="col-4">
                                                                <input type="text" class="form-control" v-model="durationUnit" required placeholder="Number" @change="handleDate"/>
                                                            </div>
                                                            <div class="col-8">
                                                                <select name="duration" class="form-select" data-hide-search="true" data-placeholder="Month" v-model="durationTime"  @change="handleDate">
                                                                    <option value="60">Minute</option>
                                                                    <option value="3600">Hour</option>
                                                                    <option value="86400">Day</option>
                                                                    <option value="604800">Week</option>
                                                                    <option value="2628002">Month</option>
                                                                    <option value="7884006">Quarter</option>
                                                                    <option value="31536000">Year</option>
                                                                </select>
                                                            </div>
                                                        </div>
                                                        <div class="form-text text-danger">
                                                            <i class="fas fa-warning text-danger"></i> Please carefully consider the unlock duration. You can only withdraw locked position after this time.
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
                                                    <div class="d-flex fw-bolder">{{ unlockDate?moment(unlockDate).format('YYYY-MM-DD hh:mm:ss'):0 }}</div>
                                                </div>
                                                <div class="fs-6 d-flex justify-content-between mb-4">
                                                    <div class="fw-bold">Days until unlock</div>
                                                    <div class="d-flex fw-bolder">~{{ unlockDays || 0 }} {{ unlockDays>1?" days": "day" }}</div>
                                                </div>
                                                <div class="row mb-5">
                                                    <div class="col-md-6 d-flex flex-column gap-7 gap-md-10">
                                                        <button @click="approvePosition(positionDetail.id)" class="btn btn-block btn-primary" :disabled="lockStep==2"><em class="fas fa-chevron-circle-down"></em> Approve</button>
                                                    </div>
                                                    <div class="col-md-6 d-flex flex-column gap-7 gap-md-10">
                                                        <button @click="lockPosition(positionDetail.id)" class="btn btn-block btn-primary" :disabled="lockStep==1"><em class="fas fa-lock me-1"></em>Lock</button>
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