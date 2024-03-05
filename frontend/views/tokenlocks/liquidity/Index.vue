<script setup>
    import { onMounted, ref } from 'vue';
    import { useRoute } from 'vue-router';
    import { useGetContracts } from "@/services/Deployer";
    import { shortPrincipal, shortAccount } from '@/utils/common';
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
                                            <th class="w-100px">Pair</th>
                                            <th class="min-w-110px">Pair Name</th>
                                            <th class="min-w-150px">Locked By</th>
                                            <th class="min-w-100px">Created Time</th>
                                            <th class="min-w-100px">Unlock Time</th>
                                            <th class="min-w-80px">Status</th>
                                            <th class="min-w-50px">Action</th>
                                        </tr>
                                    </thead>
                                    <!--end::Table head-->
                                    <!--begin::Table body-->
                                    <tbody>
                                        <tr v-for="contract in contracts" v-if="contracts.length>0">
                                            <td>
                                                <div class="d-flex flex-wrap justify-content-start">
                                                    <div class="symbol-group symbol-hover mb-3">
                                                        <div class="symbol symbol-35px symbol-circle" data-bs-toggle="tooltip" title="" data-bs-original-title="Alan Warden">
                                                            <span class="symbol-label bg-warning text-inverse-warning fw-bolder">X</span>
                                                        </div>
                                                        <div class="symbol symbol-35px symbol-circle" data-bs-toggle="tooltip" title="" data-bs-original-title="Michael Eberon">
                                                            <span class="symbol-label bg-primary text-inverse-warning fw-bolder">I</span>
                                                        </div>
                                                    </div>
                                                </div>
                                            </td>
                                            <td class="text-muted"> 
                                                <router-link :to="{name: 'LiquidityDetail', params: {contractId: contract.contractId[0]}}" class="fw-bolder">{{contract.poolName}} <span class="badge badge-light-primary">{{contract.provider}}</span></router-link>
                                                <span class="text-muted d-block">{{contract.poolId}} - Position ID: {{contract.positionId}}</span>
                                            </td>
                                            <td>
                                                <span href="#" class="text-dark fw-bolder text-hover-primary mb-1 fs-6">{{shortPrincipal(contract.positionOwner)}}</span> <Copy :text="contract.positionOwner"></Copy>
                                                <span class="text-muted fw-bold d-block">6102c3...4e6a2</span>
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
                                                <span class="badge badge-light-success" v-if="contract.status == 'locked'"><i class="fas fa-lock text-success"></i> Locked</span>
                                                <span class="badge badge-light-danger" v-if="contract.status == 'unlocked'"><i class="fas fa-unlock text-danger"></i> Unlocked</span>
                                                <span class="badge badge-light-info" v-else><i class="fas fa-unlock-art text-info"></i> Created</span>
                                            </td>
                                            <td class="text-end">
                                                <a href="#" class="btn btn-sm btn-icon btn-bg-light btn-active-color-primary">
                                                    <!--begin::Svg Icon | path: icons/duotune/arrows/arr064.svg-->
                                                    <span class="svg-icon svg-icon-2">
                                                        <svg xmlns="http://www.w3.org/2000/svg" width="24" height="24" viewBox="0 0 24 24" fill="none">
                                                            <rect opacity="0.5" x="18" y="13" width="13" height="2" rx="1" transform="rotate(-180 18 13)" fill="black"></rect>
                                                            <path d="M15.4343 12.5657L11.25 16.75C10.8358 17.1642 10.8358 17.8358 11.25 18.25C11.6642 18.6642 12.3358 18.6642 12.75 18.25L18.2929 12.7071C18.6834 12.3166 18.6834 11.6834 18.2929 11.2929L12.75 5.75C12.3358 5.33579 11.6642 5.33579 11.25 5.75C10.8358 6.16421 10.8358 6.83579 11.25 7.25L15.4343 11.4343C15.7467 11.7467 15.7467 12.2533 15.4343 12.5657Z" fill="black"></path>
                                                        </svg>
                                                    </span>
                                                    <!--end::Svg Icon-->
                                                </a>
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