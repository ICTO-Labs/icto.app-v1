<script setup>
    import { onMounted, ref } from 'vue';
    import { useRoute } from 'vue-router';
    import { useGetContract, useWithdrawPosition, useGetTransaction, useIncreaseDuration } from "@/services/Locks";
    import { shortPrincipal, shortAccount } from '@/utils/common';
    import { useGetPoolMeta, useGetPosition, useGetPoolValue } from '@/services/SwapPool';
    import { currencyFormat } from "@/utils/token";
    import { showSuccess, showError, showLoading, closeMessage, prettyValue } from "@/utils/common";
    import { VueFinalModal } from 'vue-final-modal';
    import moment from "moment";
    const route = useRoute();
    const contractId = ref(route.params.contractId);

    const contract = ref({});
    const transactions = ref([]);
    const increaseLock = ref({
        durationTime: 86400,
        durationUnit: 30,
        unlockDate: null,
        unlockDays: 0
    });
    const handleDate = ()=>{
        if(!contract.value) return;
        let _created = Number(contract.value.created)/1000000;
        let _unlockDate = moment(_created).add((Number(contract.value.durationTime)*Number(contract.value.durationUnit)) + (increaseLock.value.durationUnit*increaseLock.value.durationTime), 'seconds');
        increaseLock.value.unlockDate = _unlockDate;
        var today = moment().startOf('day');
        var days = Math.round(moment.duration(_unlockDate - today).asDays());
        increaseLock.value.unlockDays = days;// _unlockDate.diff(moment(), 'days');
    }
    const positionData = ref(null);
    const poolValue = ref(null);
    const poolMeta = ref(null);
    const isLoading = ref(false);
    const getContract = async ()=>{
        isLoading.value = true;
        contract.value = await useGetContract(contractId.value);
        console.log('contract.value', contract.value);
        if(contract.value){
            contract.value.status = "locked";
        }
        isLoading.value = false;
        await getPoolMeta();
        await getPosition();
        await getTransaction();
        handleDate();
        console.log(contract.value);
    }

    const getTransaction = async()=>{
        isLoading.value = true;
        let _rs = await useGetTransaction(contractId.value);
        transactions.value = _rs;
        isLoading.value = false;
        console.log('object', _rs);
    }

    const getPosition = async()=>{
        // positionData.value = {
        //     "tickUpper": "-50520",
        //     "tokensOwed0": "0",
        //     "tokensOwed1": "0",
        //     "feeGrowthInside1LastX128": "125453138640630681595162903735054254",
        //     "liquidity": "733643428395",
        //     "feeGrowthInside0LastX128": "1046503367790843981308566033923109780471",
        //     "tickLower": "-93120"
        // };
        if(contract.value){
            positionData.value = await useGetPosition(contract.value.poolId, contract.value.positionId);
            console.log(positionData.value);
            if(poolMeta.value){
                poolValue.value = useGetPoolValue(Number(poolMeta.value.sqrtPriceX96), Number(positionData.value.tickLower), Number(positionData.value.tickUpper), Number(positionData.value.liquidity), Number(poolMeta.value.tick));
                console.log('pool poolValue', poolValue.value);
            }
        }
        
    }

    const withdraw = async()=>{
        Swal.fire({
		title: "Withdraw locked position "+contract.value.positionId+"?",
		text: "Are you sure you want to withdraw this locked position?",
		icon: "warning",
		showCancelButton: true,
		confirmButtonColor: "#3085d6",
		cancelButtonColor: "#d33",
		confirmButtonText: "Yes, I confirm"
        }).then(async (result) => {
            if(result.isConfirmed){
                showLoading('Withdrawing position '+contract.value.positionId+'...');
                let _rs = await useWithdrawPosition(contractId.value);
                closeMessage();
                console.log('object', _rs);
                if(_rs && "ok" in _rs && _rs.ok == true){
                    showSuccess('You position have been successfully withdrawn!', true);
                }else{
                    if(_rs) showError(_rs.err, true);
                    else showError("An unexpected error occurred, please try again later!", true)
                }
            }
        });
    }

    const getPoolMeta = async()=>{
        // poolMeta.value = {
        //     "fee": "3000",
        //     "key": "qi26q-6aaaa-aaaap-qapeq-cai_ryjl3-tyaaa-aaaaa-aaaba-cai_3000",
        //     "sqrtPriceX96": "793229283657030679523849971",
        //     "tick": "-92085",
        //     "liquidity": "1153285799503",
        //     "token0": {
        //         "address": "qi26q-6aaaa-aaaap-qapeq-cai",
        //         "standard": "DIP20",
        //         "name": "XCANIC"
        //     },
        //     "token1": {
        //         "address": "ryjl3-tyaaa-aaaaa-aaaba-cai",
        //         "standard": "ICP",
        //         "name": "ICP"
        //     },
        //     "maxLiquidityPerTick": "11505743598341114571880798222544994",
        //     "nextPositionId": "115"
        // };
        if(contract.value){
            poolMeta.value = await useGetPoolMeta(contract.value.poolId);
            console.log('pool meta', poolMeta.value);
        }
    }

    const increaseModal = ref(false);
    const showIncreaseModal = ()=>{
        increaseModal.value = true;
    }
    const increase = async ()=>{
        Swal.fire({
		title: "Increase unlock time?",
		text: "Are you sure you want to increase unlock time?",
		icon: "warning",
		showCancelButton: true,
		confirmButtonColor: "#3085d6",
		cancelButtonColor: "#d33",
		confirmButtonText: "Yes, I confirm"
        }).then(async (result) => {
            if(result.isConfirmed){
                showLoading('Increasing unlock time...');
                let _rs = await useIncreaseDuration(contractId.value, increaseLock.value.durationUnit, increaseLock.value.durationTime);
                console.log('_rs', _rs);
                if(_rs && "ok" in _rs){
                    showSuccess("Unlock time has been increased successfull", true);
                }else{
                    if(_rs){
                        showError(_rs.err, true);
                    }else showError("An unexpected error occurred, please try again later!", true)
                }
            }
        });

        
    }
    const closeModal = ()=>{
        increaseModal.value = false;
    }
    onMounted(() => {
        getContract();
    });
    const modalInfo = {
        modal: 'showLiquidityLocksModal',
        label: 'Create Liquidity Locks',
        icon: 'fa-lock'
    };
    const btnObj = {
        label: 'New lock',
        icon: 'fa-plus',
        modal: 'showNewLockModal'
    }
</script>
<template>
    <Toolbar :current="contractId" :parents="[{title: 'Token Locks', to: '/token-locks'}, {title: 'Liquidity', to: '/token-locks/liquidity'}]" :modal="modalInfo" :showBtn="btnObj"/>
    <div class="col-xl-12">
        <!--begin::Mixed Widget 1-->
        <div class="card card-xl-stretch mb-xl-8">
            <!--begin::Body-->
            <div class="card-body p-0">
                <!--begin::Header-->
                <div :class="`px-9 pt-7 card-rounded h-275px w-100 bg-${contract?.status=='locked'?'success':contract?.status=='unlocked'?'danger':'info'}`">
                    <div class="d-flex flex-stack">
                        <h3 class="m-0 text-white fw-bolder fs-3">Liquidity Lock</h3>
                        <div class="ms-1">
                            <button type="button" class="btn btn-sm btn-light-danger border-0 me-n3" @click.stop="withdraw"><i class="fas fa-donate"></i> Withdraw</button>
                        </div>
                    </div>
                    <!--begin::Balance-->
                    <div class="d-flex text-center flex-column text-white pt-3">
                        <span class="fw-bold fs-4" v-if="contract?.status =='locked'">Liquidity {{ contract?.status }} <i class="fas fa-lock text-white"></i></span>
                        <span class="fw-bold fs-4" v-else-if="contract?.status =='unlocked'">Contract Unlocked <i class="fas fa-unlock text-white"></i></span>
                        <span class="fw-bold fs-4" v-else-if="contract?.status == 'created'">Contract Created <i class="fas fa-waiting text-white"></i></span>
                        <span class="fw-bold fs-4" v-else>Lock Contract</span>
                        <span class="fw-bolder fs-3x pt-1">${{poolValue?.totalValueInUSD?.toFixed(2) || '0'}}</span>
                        <span class="fw-bold fs-7 pt-1">Locked by: <span class="fw-bold">{{ contract?.positionOwner }}</span> <Copy :text="contract.positionOwner" v-if="contract" class="btn-color-white"></Copy></span>
                    </div>
                    <!--end::Balance-->
                </div>
                <!--end::Header-->
                <!--begin::Items-->
                <div class="bg-body shadow-sm card-rounded mx-9 mb-9 px-6 py-2 position-relative z-index-1" style="margin-top: -60px">
                    <div class="row g-0">
                        <div class="col-md px-6 py-5 rounded-2 me-3 mb-7 d-flex flex-center flex-column">
                            <div class="symbol symbol-125px symbol-circle mb-5">
                                <img src="https://psh4l-7qaaa-aaaap-qasia-cai.raw.icp0.io/qi26q-6aaaa-aaaap-qapeq-cai.png" alt="image">
                            </div>
                            <a href="#" class="fs-4 text-gray-800 text-hover-primary fw-bolder mb-0">{{ poolMeta?.token0?.name || '---' }}</a>
                            <span class="text-primary">{{ poolMeta?.token0?.address || '---' }} <Copy :text="poolMeta.token0.address"  v-if="poolMeta"/></span>
                            <span class="fs-4 fw-bold">{{ currencyFormat(poolValue?.amount0 || 0) }}</span>

                        </div>
                        <div class="col-md px-6 py-1 rounded-2 d-flex flex-column flex-center bg-light">
                            <div class="w-100">
                                <table class="table table-sm">
                                    <tr>
                                        <td class="text-start fw-bold text-gray-400 pt-0" colspan="2">LIQUIDITY PRICE RANGE 
                                            <span :class="`text-end fw-normal badge badge-light-${poolValue.isInrange ? 'success' : 'warning'}`" v-if="poolValue">
                                                <i class="bullet bullet-dot bg-success h-8px w-8px me-1" v-if="poolValue.isInrange"></i>
                                                <i class="fas fa-exclamation-circle text-warning fs-1x" v-else></i>
                                                {{ poolValue.isInrange ? "In range": "Out of range" }}
                                            </span>
                                        </td>
                                    </tr>
                                    <tr>
                                        <td class="text-start fw-bold text-gray-400 pt-3" colspan="2">
                                            <div class="row p-0">
                                                <div class="col">
                                                    <div class="border border-dashed border-gray-300 bg-white text-center rounded pt-2 pb-2">
                                                        <span class="fs-7 fw-bold text-dark d-block"><i class="fas fa-chevron-down text-danger"></i> Min Price</span>
                                                        <div class="fs-1hx fw-bolder text-gray-900 counted">{{ poolValue?.minprice || '---' }}</div>
                                                        <div class="fw-normal fs-7 text-gray-400">
                                                            <span class="fw-bold">{{ poolMeta?.token1?.name || '---' }}</span> per <span class="fw-bold">{{ poolMeta?.token0?.name || '---' }}</span>
                                                        </div>
                                                    </div>
                                                </div>
                                                <div class="col">
                                                    <div class="border border-dashed border-gray-300 bg-white text-center rounded pt-2 pb-2">
                                                        <span class="fs-7 fw-bold text-dark d-block"> <i class="fas fa-chevron-up text-success"></i> Max Price</span>
                                                        <div class="fs-1hx fw-bolder text-gray-900 counted">{{ poolValue?.maxprice || '---' }}</div>
                                                        <div class="fw-normal fs-7 text-gray-400">
                                                            <span class="fw-bold">{{ poolMeta?.token1?.name||'---' }}</span> per <span class="fw-bold">{{ poolMeta?.token0?.name||'---' }}</span>
                                                        </div>
                                                    </div>
                                                </div>
                                            </div>
                                            <div class="row pt-3 p-0">
                                                <div class="col">
                                                    <div class="border border-dashed border-primary bg-white text-center rounded pt-2 pb-2">
                                                        <span class="fs-7 fw-bold text-primary d-block">Current Price</span>
                                                        <div class="fs-1hx fw-bolder text-gray-900 counted">{{ poolValue?.price || '---' }}</div>
                                                        <div class="fw-normal fs-7 text-gray-400">
                                                            <span class="fw-bold">{{ poolMeta?.token1?.name || '---' }}</span> per <span class="fw-bold">{{ poolMeta?.token0?.name || '---' }}</span>
                                                        </div>
                                                    </div>
                                                </div>
                                            </div>
                                        </td>
                                    </tr>
                                    <tr>
                                        <td class="text-start fw-bold text-gray-400 pt-3" colspan="2">CONTRACT DATA</td>
                                    </tr>
                                    <tr>
                                        <td class="text-start fw-bold w-50 text-danger">Lock expires</td>
                                        <td>
                                            {{ contract?moment(Number(contract.created)/1000000).add(Number(contract.durationTime)*Number(contract.durationUnit), 'seconds').fromNow():'---' }}
                                            <a href="#" class="badge badge-light-primary ms-5" @click="showIncreaseModal">+ Increase</a>

                                        </td>
                                    </tr>
                                    <tr>
                                        <td class="text-start fw-bold w-50">Positon Id</td>
                                        <td>{{ contract?.positionId||'---' }}</td>
                                    </tr>
                                    <tr>
                                        <td class="text-start fw-bold">Created at</td>
                                        <td>{{ contract?moment(Number(contract.created)/1000000).format("YYYY-MM-DD hh:mm:ss"):'---' }}</td>
                                    </tr>
                                    <tr>
                                        <td class="text-start fw-bold">Unlock at</td>
                                        <td>{{ contract?moment(Number(contract.created)/1000000).add(Number(contract.durationTime)*Number(contract.durationUnit), 'seconds').format("YYYY-MM-DD hh:mm:ss"):'---' }}</td>
                                    </tr>
                                </table>
                            </div>
                        </div>
                        <div class="col-md px-6 py-5 rounded-2 me-3 mb-7 d-flex flex-center flex-column">
                            <div class="symbol symbol-125px symbol-circle mb-5">
                                <img src="https://psh4l-7qaaa-aaaap-qasia-cai.raw.icp0.io/ryjl3-tyaaa-aaaaa-aaaba-cai.png" alt="image">
                            </div>
                            <a href="#" class="fs-4 text-gray-800 text-hover-primary fw-bolder mb-0">{{ poolMeta?.token1?.name || '---' }}</a>
                            <span class="text-primary">{{ poolMeta?.token1?.address || '---' }} <Copy :text="poolMeta.token1.address" v-if="poolMeta"/></span>
                            <span class="fs-4 fw-bold">{{ currencyFormat(poolValue?.amount1 || 0) }}</span>
                        </div>
                    </div>
                </div>
                <!--end::Items-->
            </div>
            <!--end::Body-->
        </div>
        <!--end::Mixed Widget 1-->
    </div>
    <div class="row g-5 g-xxl-8">
        <div class="col-xxl-12">
            <!--begin::Tables Widget 5-->
            <div class="card card-xxl-stretch mb-5 mb-xl-8">
                <!--begin::Header-->
                <div class="card-header border-0 pt-5">
                    <h3 class="card-title align-items-start flex-column">
                        <span class="card-label fw-bolder fs-3 mb-1">Histories</span>
                    </h3>
                    <div class="card-toolbar">
                        <button type="button" class="btn btn-sm btn-bg-light btn-active-dark" @click="getTransaction()" :disabled="isLoading">{{isLoading?'Loading...':'Refresh'}}</button>
                    </div>
                </div>
                <!--end::Header-->
                <!--begin::Body-->
                <div class="card-body py-3">
                    <div class="tab-content" v-if="contract">
                        <!--begin::Tap pane-->
                        <div class="tab-pane fade show active" id="kt_table_widget_5_tab_1">
                            <!--begin::Table container-->
                            <div class="table-responsive">
                                <!--begin::Table-->
                                <table class="table table-row-dashed table-row-gray-200 align-middle gs-0 gy-4">
                                    <!--begin::Table head-->
                                    <thead class="fs-7 text-gray-400 text-uppercase">
                                        <tr class="border-0 fw-bolder">
                                            <th class="w-100px">Method</th>
                                            <th class="min-w-110px">From</th>
                                            <th class="min-w-150px">To</th>
                                            <th class="min-w-80px">Position Id</th>
                                            <th class="min-w-80px">Time</th>
                                        </tr>
                                    </thead>
                                    <!--end::Table head-->
                                    <!--begin::Table body-->
                                    <tbody>
                                        <tr v-for="transaction in transactions" v-if="transactions && transactions.length>0">
                                            <td>
                                                <span class="badge badge-light-info"><i class="fas fa-arrow-right text-info"></i> {{ transaction[1].method }}</span>
                                            </td>
                                            <td class="text-muted"> 
                                                <span class="text-dark fw-bolder text-hover-primary">{{ transaction[1].from }}</span> <Copy :text="contract.positionOwner"></Copy>
                                            </td>
                                            <td>
                                                <span class="text-dark fw-bolder text-hover-primary mb-1 fs-6">{{ transaction[1].to }}</span> <Copy :text="transaction[1].to"></Copy>
                                            </td>
                                            <td class="text-center fw-bold">6</td>
                                            <td class="text-muted ">
                                                <span class="text-muted d-block">{{ moment(Number(transaction[1].time)/1000000).format("YYYY-MM-DD hh:mm:ss") }}</span>
                                            </td>
                                        </tr>
                                        
                                    </tbody>
                                    <!--end::Table body-->
                                </table>
                            </div>
                            <!--end::Table-->
                        </div>
                        <!--end::Tap pane-->
                    </div>
                </div>
                <!--end::Body-->
            </div>
            <!--end::Tables Widget 5-->
        </div>
    </div>

    <VueFinalModal v-model="increaseModal" :z-index-base="2000" classes="modal fade show" content-class="modal-dialog modal-lg modal-dialog-scrollable">
        <div class="modal-content">
            <div class="modal-header pb-3">
                <h5 class="modal-title">Increase unlock time</h5>
                <div class="btn btn-icon btn-sm btn-bg-light btn-active-light-danger ms-2" data-bs-dismiss="modal" aria-label="Close" @click="closeModal()">
                    <i class="fas fa-times"></i>
                </div>
            </div>
            <div class="modal-body pt-0 pb-5">
                <form class="form" @submit.prevent="increase">
                    <div class="card1 mb-xl-1">
                        <div class="card-body p-0">
                                <div class="row fv-row">
                                    <div class="card h-100">
                                        <div class="card-body p-2">
                                            <div class="fs-6 justify-content-between">
                                                <div class="row mb-5">
                                                    <div class="col-md-12 fv-row">
                                                        <label class="required fs-6 fw-bold form-label mb-2">Additional duration <i class="fas fa-unlock-alt"></i> </label>
                                                        <div class="row fv-row">
                                                            <div class="col-6">
                                                                <input type="text" class="form-control" v-model="increaseLock.durationUnit" required placeholder="Number" @change="handleDate"/>
                                                            </div>
                                                            <div class="col-6">
                                                                <select name="duration" class="form-select" data-hide-search="true" data-placeholder="Month" v-model="increaseLock.durationTime"  @change="handleDate">
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
                                                    </div>
                                                </div>
                                                <div class="row pb-5">
                                                    <label class="fs-6 fw-bold form-label mb-2">Confirm change</label>
                                                    <div class="col-lg-5">
                                                        <div class="border border-gray-300 bg-white text-center rounded pt-2 pb-2">
                                                            <span class="fs-6 fw-bold text-gray-600 d-block">Current unlock time</span>
                                                            <div class="fs-1hx fw-bolder text-gray-900 counted">
                                                                {{ contract?moment(Number(contract.created)/1000000).add(Number(contract.durationTime)*Number(contract.durationUnit), 'seconds').format("YYYY-MM-DD hh:mm:ss"):'---' }}
                                                            </div>
                                                            <div>
                                                                {{ contract?moment(Number(contract.created)/1000000).add(Number(contract.durationTime)*Number(contract.durationUnit), 'seconds').fromNow():'---' }}
                                                            </div>
                                                        </div>
                                                    </div>
                                                    <div class="col-lg-2">
                                                        <div class="text-center rounded pt-8">
                                                            <i class="fas fa-arrow-right fs-1 text-danger"></i> 
                                                        </div> 
                                                    </div>
                                                    <div class="col-lg-5">
                                                        <div class="border border-gray-300 bg-white text-center rounded pt-2 pb-2">
                                                            <span class="fs-6 fw-bold text-gray-600 d-block"> New unlock time</span>
                                                            <div class="fs-1hx fw-bolder text-gray-900 counted">
                                                                {{ increaseLock.unlockDate?moment(increaseLock.unlockDate).format('YYYY-MM-DD hh:mm:ss'):0 }}
                                                            </div>
                                                            <div>
                                                                {{ increaseLock.unlockDays>0?'in '+increaseLock.unlockDays+' days':0 }}
                                                            </div>
                                                            
                                                        </div>
                                                    </div>
                                            </div>
                                                <div class="row mb-5">
                                                    <div class="col-md-12 d-flex flex-column gap-7 gap-md-10">
                                                        <button type="submit" class="btn btn-block btn-primary"><em class="fas fa-chevron-circle-down"></em> Submit</button>
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