<script setup>
    import { onMounted, ref } from 'vue';
    import { useRoute } from 'vue-router';
    import { useGetContracts } from "@/services/Deployer";
    import { shortPrincipal, shortAccount, principalToAccountId } from '@/utils/common';
    import config from '@/config';
    import moment from "moment";
    const contracts = ref([]);
    const isLoading = ref(false);
    const getContracts = async ()=>{
        isLoading.value = true;
        contracts.value = await useGetContracts();
        isLoading.value = false;
        console.log(contracts.value);
    }
    onMounted(() => {
        getContracts();
    });
    const route = useRoute();
    const currentPair = ref(route.params.pairId);
    const modalInfo = {
        modal: 'showLiquidityLocksModal',
        label: 'Create Liquidity Locks',
        icon: 'fa-lock'
    };
    const btnObj = {
        label: 'New locks',
        icon: 'fa-plus',
        modal: 'showNewLockModal'
    }
</script>
<template>
    <Toolbar current="Liquidity" :parents="[{title: 'Token Locks', to: '/token-locks'}]" :modal="modalInfo" :showBtn="btnObj"/>

    <div class="row g-5 g-xxl-8">
        <div class="col-xxl-12">
            <!--begin::Tables Widget 5-->
            <div class="card card-xxl-stretch mb-5 mb-xl-8">
                <!--begin::Header-->
                <div class="card-header border-0 pt-5">
                    <h3 class="card-title align-items-start flex-column">
                        <span class="card-label fw-bolder fs-3 mb-1">Locked contracts</span>
                        <span class="text-muted mt-1 fw-bold fs-7">Total contract locked with ICTO</span>
                    </h3>
                    <div class="card-toolbar">
                        <button type="button" class="btn btn-sm btn-bg-light btn-active-dark" @click="getContracts(false)" :disabled="isLoading">{{isLoading?'Loading...':'Refresh'}}</button>
                    </div>
                </div>
                <!--end::Header-->
                <!--begin::Body-->
                <div class="card-body py-3">
                    <div class="tab-content">
                        <!--begin::Tap pane-->
                        <div class="tab-pane fade show active" id="kt_table_widget_5_tab_1">
                            <!--begin::Table container-->
                            <div class="table-responsive">
                                <!--begin::Table-->
                                <table class="table table-row-dashed table-row-gray-200 align-middle gs-0 gy-4">
                                    <!--begin::Table head-->
                                    <thead class="fs-7 text-gray-400 text-uppercase">
                                        <tr class="border-0 fw-bolder">
                                            <th class="min-w-80px"></th>
                                            <th class="min-w-175px">Pair Name</th>
                                            <th class="min-w-150px">Created By</th>
                                            <th class="min-w-100px">Created Time</th>
                                            <th class="min-w-100px">Unlock Time</th>
                                            <th class="min-w-80px">Status</th>
                                        </tr>
                                    </thead>
                                    <!--end::Table head-->
                                    <!--begin::Table body-->
                                    <tbody>
                                        <tr v-for="contract in contracts" v-if="contracts.length>0">
                                            <td>
                                                <div class="d-flex flex-wrap justify-content-start">
                                                    <div class="symbol-group symbol-hover mb-0">
                                                        <div class="symbol symbol-35px symbol-circle">
                                                            <img :src="`https://${config.CANISTER_STORAGE_ID}.raw.icp0.io/${contract?.token0?.address}.png`" alt="Token0">
                                                        </div>
                                                        <div class="symbol symbol-35px symbol-circle">
                                                            <img :src="`https://${config.CANISTER_STORAGE_ID}.raw.icp0.io/${contract?.token1?.address}.png`" alt="Token1">
                                                        </div>
                                                    </div>
                                                </div>
                                            </td>
                                            <td class="text-muted"> 
                                                <router-link :to="{name: 'LiquidityDetail', params: {contractId: contract.contractId[0]}}" class="fw-bolder">{{contract.poolName}} <span class="badge badge-light-primary">{{contract.provider}}</span></router-link>
                                                <span class="text-dark fw-bold d-block"><span class="badge badge-primary">{{contract.positionId}}</span> {{contract.contractId[0]}} <Copy :text="contract.contractId[0]"></Copy></span>
                                            </td>
                                            <td>
                                                <span href="#" class="text-dark fw-bolder text-hover-primary mb-1 fs-6">{{shortPrincipal(contract.positionOwner)}}</span> <Copy :text="contract.positionOwner"></Copy>
                                                <span class="text-muted fw-bold d-block">{{shortAccount(principalToAccountId(contract.positionOwner, 0))}}</span>
                                            </td>
                                            <td class="text-muted ">
                                                <span class="text-dark fw-bold">{{ moment(Number(contract.created)/1000000).fromNow() }}</span>
                                                <span class="text-muted d-block">{{ moment(Number(contract.created)/1000000).format("YYYY-MM-DD hh:mm:ss") }}</span>
                                            </td>
                                            <td class="text-muted ">
                                                <span class="text-dark fw-bold">{{ moment(Number(contract.created)/1000000).add(Number(contract.durationTime)*Number(contract.durationUnit), 'seconds').fromNow() }}</span>
                                                <span class="text-muted d-block">{{ moment(Number(contract.created)/1000000).add(Number(contract.durationTime)*Number(contract.durationUnit), 'seconds').format("YYYY-MM-DD hh:mm:ss") }}</span>
                                            </td>
                                            <td class="">
                                                <span class="badge badge-light-success" v-if="contract.status == 'locked'">Locked <i class="fas fa-lock text-success"></i></span>
                                                <span class="badge badge-light-danger" v-else-if="contract.status == 'unlocked'">Unlocked <i class="fas fa-lock-open text-danger"></i></span>
                                                <span class="badge badge-secondary" v-else-if="contract.status == 'withdrawn'">Withdrawn <i class="fas fa-anchor"></i></span>
                                                <span class="badge badge-light-info" v-else>Created <i class="fas fa-unlock-art text-info"></i></span>
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