<script setup>
    import { onMounted, ref } from 'vue';
    import { useRoute } from 'vue-router';
    import { useGetContract } from "@/services/Locks";
    import { shortPrincipal, shortAccount } from '@/utils/common';
    import { useGetPoolMeta, useGetPosition, useGetPoolValue } from '@/services/SwapPool';
    import { currencyFormat } from "@/utils/token";

    import moment from "moment";
    const route = useRoute();
    const contractId = ref(route.params.contractId);

    const contract = ref({});
    const positionData = ref(null);
    const poolValue = ref(null);
    const poolMeta = ref(null);
    const isLoading = ref(false);
    const getContract = async ()=>{
        console.log('contractId.value', contractId.value);
        isLoading.value = true;
        contract.value = await useGetContract(contractId.value);
        contract.value.status = "locked";
        isLoading.value = false;
        await getPoolMeta();
        await getPosition();
        console.log(contract.value);
    }

    const getPosition = async()=>{
        positionData.value = {
            "tickUpper": "-50520",
            "tokensOwed0": "0",
            "tokensOwed1": "0",
            "feeGrowthInside1LastX128": "125453138640630681595162903735054254",
            "liquidity": "733643428395",
            "feeGrowthInside0LastX128": "1046503367790843981308566033923109780471",
            "tickLower": "-93120"
        };
        // positionData.value = await useGetPosition(contract.value.poolId, contract.value.positionId);
        console.log(positionData.value);
        if(poolMeta.value){
            poolValue.value = useGetPoolValue(Number(poolMeta.value.sqrtPriceX96), Number(positionData.value.tickLower), Number(positionData.value.tickUpper), Number(positionData.value.liquidity), Number(poolMeta.value.tick));
            console.log('pool poolValue', poolValue.value);
        }

    }
    const getPoolMeta = async()=>{
        poolMeta.value = {
            "fee": "3000",
            "key": "qi26q-6aaaa-aaaap-qapeq-cai_ryjl3-tyaaa-aaaaa-aaaba-cai_3000",
            "sqrtPriceX96": "793229283657030679523849971",
            "tick": "-92085",
            "liquidity": "1153285799503",
            "token0": {
                "address": "qi26q-6aaaa-aaaap-qapeq-cai",
                "standard": "DIP20",
                "name": "XCANIC"
            },
            "token1": {
                "address": "ryjl3-tyaaa-aaaaa-aaaba-cai",
                "standard": "ICP",
                "name": "ICP"
            },
            "maxLiquidityPerTick": "11505743598341114571880798222544994",
            "nextPositionId": "115"
        };
        // poolMeta.value = await useGetPoolMeta(contract.value.poolId);
        console.log('pool meta', poolMeta.value);
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
                <div :class="`px-9 pt-7 card-rounded h-275px w-100 bg-${contract.status=='locked'?'success':contract.status=='unlocked'?'danger':'info'}`">
                    
                    <!--begin::Balance-->
                    <div class="d-flex text-center flex-column text-white pt-3">
                        <span class="fw-bold fs-4" v-if="contract.status =='locked'">Liquidity {{ contract.status }} <i class="fas fa-lock text-white"></i></span>
                        <span class="fw-bold fs-4" v-if="contract.status =='unlocked'">Contract Unlocked <i class="fas fa-unlock text-white"></i></span>
                        <span class="fw-bold fs-4" v-if="contract.status == 'created'">Contract Created <i class="fas fa-waiting text-white"></i></span>
                        <span class="fw-bolder fs-3x pt-1" v-if="poolValue">${{poolValue.totalValueInUSD.toFixed(2)}}</span>
                        <span class="fw-bold fs-7 pt-1">Locked by: {{ contract.positionOwner }} <Copy :text="contract.positionOwner"></Copy></span>
                    </div>
                    <!--end::Balance-->
                </div>
                <!--end::Header-->
                <!--begin::Items-->
                <div class="bg-body shadow-sm card-rounded mx-9 mb-9 px-6 py-9 position-relative z-index-1" style="margin-top: -100px">
                    <div class="row g-0">
                        <div class="col px-6 py-8 rounded-2 me-3 mb-7 d-flex flex-center flex-column" v-if="poolMeta">
                            <div class="symbol symbol-125px symbol-circle mb-5">
                                <img src="https://psh4l-7qaaa-aaaap-qasia-cai.raw.icp0.io/qi26q-6aaaa-aaaap-qapeq-cai.png" alt="image">
                            </div>
                            <a href="#" class="fs-4 text-gray-800 text-hover-primary fw-bolder mb-0" v-if="poolMeta">{{ poolMeta.token0.name }}</a>
                            <span class="text-primary">{{ poolMeta.token0.address }} <Copy :text="poolMeta.token0.address"/></span>
                            <span class="fs-4 fw-bold" v-if="poolValue">{{ currencyFormat(poolValue.amount0) }}</span>

                        </div>
                        <div class="col px-6 py-3 rounded-2 d-flex flex-column flex-center bg-light">
                            <div class="w-100">
                                <table class="table table-sm">
                                    <tr>
                                        <td class="text-start fw-bold w-50 text-danger">Lock expires</td>
                                        <td>{{ moment(Number(contract.created)/1000000).add(Number(contract.durationTime)*Number(contract.durationUnit), 'seconds').fromNow() }}</td>
                                    </tr>
                                    <tr>
                                        <td class="text-start fw-bold w-50">Positon Id</td>
                                        <td>{{ contract.positionId }}</td>
                                    </tr>
                                    <tr>
                                        <td class="text-start fw-bold text-gray-400 pt-3" colspan="2">LIQUIDITY PRICE RANGE 
                                            <span :class="`text-end fw-normal badge badge-light-${poolValue.isInrange ? 'success' : 'warning'}`" v-if="poolValue">
                                                <i class="bullet bullet-dot bg-success h-8px w-8px me-1" v-if="poolValue.isInrange"></i>
                                                <i class="fas fa-exclamation-circle text-warning fs-1x" v-else></i>
                                                {{ poolValue.isInrange ? "In range": "Out of range" }}
                                            </span>
                                        </td>
                                    </tr>
                                    <tr>
                                        <td class="text-start fw-bold text-gray-400 pt-3" colspan="2">
                                            <div class="row p-0" v-if="poolValue">
                                                <div class="col">
                                                    <div class="border border-dashed border-gray-300 text-center rounded pt-2 pb-2">
                                                        <span class="fs-7 fw-bold text-dark d-block"><i class="fas fa-chevron-down text-danger"></i> Min Price</span>
                                                        <div class="fs-1hx fw-bolder text-gray-900 counted">{{ poolValue.minprice }}</div>
                                                        <div class="fw-normal fs-7 text-gray-400" v-if="poolMeta">
                                                            <span class="fw-bold">{{ poolMeta.token1.name }}</span> per <span class="fw-bold">{{ poolMeta.token0.name }}</span>
                                                        </div>
                                                    </div>
                                                </div>
                                                <div class="col">
                                                    <div class="border border-dashed border-gray-300 text-center rounded pt-2 pb-2">
                                                        <span class="fs-7 fw-bold text-dark d-block"> <i class="fas fa-chevron-up text-success"></i> Max Price</span>
                                                        <div class="fs-1hx fw-bolder text-gray-900 counted">{{ poolValue.maxprice }}</div>
                                                        <div class="fw-normal fs-7 text-gray-400" v-if="poolMeta">
                                                            <span class="fw-bold">{{ poolMeta.token1.name }}</span> per <span class="fw-bold">{{ poolMeta.token0.name }}</span>
                                                        </div>
                                                    </div>
                                                </div>
                                            </div>
                                            <div class="row pt-3 p-0" v-if="poolValue">
                                                <div class="col">
                                                    <div class="border border-dashed border-gray-300 text-center rounded pt-2 pb-2">
                                                        <span class="fs-7 fw-bold text-primary d-block">Current Price</span>
                                                        <div class="fs-1hx fw-bolder text-gray-900 counted">{{ poolValue.price }}</div>
                                                        <div class="fw-normal fs-7 text-gray-400" v-if="poolMeta">
                                                            <span class="fw-bold">{{ poolMeta.token1.name }}</span> per <span class="fw-bold">{{ poolMeta.token0.name }}</span>
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
                                        <td class="text-start fw-bold">Created at</td>
                                        <td>{{ moment(Number(contract.created)/1000000).format("YYYY-MM-DD hh:mm:ss") }}</td>
                                    </tr>
                                    <tr>
                                        <td class="text-start fw-bold">Unlock at</td>
                                        <td>{{ moment(Number(contract.created)/1000000).add(Number(contract.durationTime)*Number(contract.durationUnit), 'seconds').format("YYYY-MM-DD hh:mm:ss") }}</td>
                                    </tr>
                                </table>
                            </div>
                        </div>
                        <div class="col px-6 py-8 rounded-2 me-3 mb-7 d-flex flex-center flex-column" v-if="poolMeta">
                            <div class="symbol symbol-125px symbol-circle mb-5">
                                <img src="https://psh4l-7qaaa-aaaap-qasia-cai.raw.icp0.io/ryjl3-tyaaa-aaaaa-aaaba-cai.png" alt="image">
                            </div>
                            <a href="#" class="fs-4 text-gray-800 text-hover-primary fw-bolder mb-0" v-if="poolMeta">{{ poolMeta.token1.name }}</a>
                            <span class="text-primary">{{ poolMeta.token1.address }} <Copy :text="poolMeta.token1.address"/></span>
                            <span class="fs-4 fw-bold" v-if="poolValue">{{ currencyFormat(poolValue.amount1) }}</span>
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
                        <span class="card-label fw-bolder fs-3 mb-1">Transactions</span>
                    </h3>
                    <div class="card-toolbar">
                        <button type="button" class="btn btn-sm btn-bg-light btn-active-dark" @click="getContract()" :disabled="isLoading">{{isLoading?'Loading...':'Refresh'}}</button>
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
                                        <tr>
                                            <td>
                                                <span class="badge badge-light-info"><i class="fas fa-arrow-right text-info"></i> DEPOSIT</span>
                                            </td>
                                            <td class="text-muted"> 
                                                <span class="text-dark fw-bolder text-hover-primary">lekqg-fvb6g-4kubt-oqgzu-rd5r7-muoce-kppfz-aaem3-abfaj-cxq7a-dqe</span> <Copy :text="contract.positionOwner"></Copy>
                                            </td>
                                            <td>
                                                <span class="text-dark fw-bolder text-hover-primary mb-1 fs-6">{{contractId}}</span> <Copy :text="contract.positionOwner"></Copy>
                                            </td>
                                            <td class="text-center fw-bold">6</td>
                                            <td class="text-muted ">
                                                <span class="text-muted d-block">{{ moment(Number(contract.created)/1000000).format("YYYY-MM-DD hh:mm:ss") }}</span>
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
</template>