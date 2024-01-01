<script setup>
    import moment from 'moment';
    import {useListContract} from "@/services/Contract";
    import "vue3-circle-progress/dist/circle-progress.css";
    import CircleProgress from "vue3-circle-progress";
    import { currencyFormat } from "@/utils/token"
    import { shortPrincipal, shortAccount } from '@/utils/common';

    const { data: contracts, error, isError, isLoading, isRefetching, refetch } = useListContract(0);

</script>
<template>
    <div class="row g-6 g-xl-9">
        <div v-if="isLoading">Loading...</div>
        <div v-if="isError">{{ error }}</div>
        
        <div class="col-sm-6 col-xl-4" v-for="contract in contracts">
            <!--begin::Card-->
            <div class="card h-100">
                <!--begin::Card header-->
                <div class="card-header">
                    <div class="card-title">
                        <h3><router-link :to="`/contract/${contract.contractId}`" class="fs-4 fw-bolder mb-1 text-gray-800 text-hover-primary">{{ contract.name }}</router-link></h3>
                    </div>
                </div>
               
                <!--begin::Card body-->
                <div class="card-body d-flex flex-column px-9 pt-6 pb-8">
                    <div class="fs-6 fw-bold text-muted mb-6">{{ contract.description }}</div>
                    <div class="d-flex flex-wrap">

                        <div class="symbol-circle me-3">
                            <circle-progress :percent="59" :show-percent="true" size="90" border-width="8" border-bg-width="8" class="circle-small"/>
                        </div>
                        
                      <!--begin::Labels-->
                      <div class="d-flex flex-column justify-content-center flex-row-fluid pe-11 mb-5">
                        <div class="d-flex fs-6 fw-semibold align-items-center mb-3">
                          <div class="bullet bg-success me-3"></div>
                          <div class="text-gray-500">Total Amount</div>
                          <div class="ms-auto fw-bold text-gray-700">{{ currencyFormat(Number(contract?.totalAmount)) }}</div>
                        </div>
                        <div class="d-flex fs-6 fw-semibold align-items-center mb-3">
                          <div class="bullet bg-primary me-3"></div>
                          <div class="text-gray-500">Unlocked</div>
                          <div class="ms-auto fw-bold text-gray-700">{{ currencyFormat(Number(contract?.unlockedAmount || 0)) }}</div>
                        </div>
                        <div class="d-flex fs-6 fw-semibold align-items-center mb-3">
                          <div class="bullet bg-gray-400 me-3"></div>
                          <div class="text-gray-500">Remaining</div>
                          <div class="ms-auto fw-bold text-gray-700">{{ currencyFormat(Number(contract?.totalAmount) - Number(contract?.unlockedAmount)) }}</div>
                        </div>
                      </div>
                      <!--end::Labels-->
                    </div>
                    <div class="card card-dashed h-xl-100 flex-row flex-stack flex-wrap p-4 mb-5">
                        <div class="symbol symbol-45px w-45px me-5">
                            <img src="https://psh4l-7qaaa-aaaap-qasia-cai.raw.icp0.io/6ytv5-fqaaa-aaaap-qblcq-cai.png" alt="image">
                        </div>
                        <div class="d-flex flex-stack flex-grow-1 flex-wrap flex-md-nowrap">
                            <div class="mb-3 mb-md-0 fw-bold">
                                <h4 class="fs-6 text-gray-800 fw-bolder">{{ contract.tokenName }}
                                    <div class="badge badge-light-primary ms-auto">{{contract.tokenStandard.toLocaleUpperCase()}}</div>
                                </h4>
                                <div class="fs-7 text-gray-700">{{ contract.tokenId }} <Copy :text="contract.tokenId"></Copy></div>
                            </div>
                        </div>
                    </div>
                                                        
                    <div class="d-flex flex-stack flex-wrapr">
                        <div class="d-flex flex-column me-2">
                            <span class="fs-8 text-gray-400 text-hover-primary me-2">Created</span>
                            <span class="badge bg-light text-gray-700 px-3 py-2">{{ moment.unix(Number(contract.created)).format("lll") }}</span>
                        </div>
                        
                        <div class="d-flex flex-column me-2">
                            <span class="text-gray-400 fs-8 me-2 text-hover-primary">Created By</span>
                            <span class="text-gray-700 fw-bold fs-7" :title="contract.createdBy">{{ shortPrincipal(contract.createdBy) }} <Copy :text="contract.createdBy"></Copy></span>
                        </div>
                        <div class="d-flex flex-column">
                            <span class="fs-8 text-gray-400 text-hover-primary">Status</span>
                            <span class="badge badge-light-success me-auto">Unlocking</span>
                        </div>
                    </div>
                    
                    <!--end::Indicator-->
                </div>
                <!--end::Card body-->
            </div>
            <!--end::Card-->
        </div>
    </div>
</template>