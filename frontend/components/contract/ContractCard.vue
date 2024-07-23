<script setup> 
    import moment from 'moment';
    import { onMounted, ref } from 'vue';
    import "vue3-circle-progress/dist/circle-progress.css";
    import CircleProgress from "vue3-circle-progress";
    import { currencyFormat, parseTokenAmount } from "@/utils/token"
    import { shortPrincipal, shortAccount } from '@/utils/common';
    import config from '@/config';
    import { useGetContract, useCancelContract } from "@/services/Contract";
    const props = defineProps(['contractId', 'contractInfo']);
    const { data: contract, error, isError, isLoading, isRefetching, refetch } = useGetContract(props.contractId);
    // const contract = ref(null);
    const getContract = async () => {
        contract.value = await useGetContract(props.contractId);
        console.log('contract valueeeeeeeeeeeeeeee', contract.value);
    }

</script>
<template>
    <div class="card h-100 border border-2 border-gray-300 border-hover">
        <!--begin::Card header-->
        <div class="card-header">
            <div class="card-title">
                <h4>
                    <router-link :to="`/token-claim/${props.contractId}`" class="fs-5 fw-bolder mb-1 text-gray-800 text-hover-primary">{{ contract?.title }}</router-link>
                </h4>
            </div>
            <div class="card-toolbar" data-bs-toggle="tooltip" data-bs-placement="top" data-bs-trigger="hover" title="" data-bs-original-title="Click to add a user">
                <div class="badge bg-light text-muted px-3 py-2 me-2 fw-normal fs-7 fw-bold">{{ contract?.totalRecipients}} recipients</div>
            </div>
        </div>
        
        <!--begin::Card body-->
        <div class="card-body d-flex flex-column px-9 pt-6 pb-8">
            <div class="fs-6 text-gray-800 mb-6">{{ contract?.description }}</div>
            <div class="d-flex flex-wrap">

                <div class="symbol-circle me-5">
                    <circle-progress :percent="(Number(contract?.totalClaimedAmount)/Number(contract?.totalAmount))*100" :show-percent="true" size="80" border-width="7" border-bg-width="7" class="circle-small"/>
                </div>
                
                <!--begin::Labels-->
                <div class="d-flex flex-column justify-content-center flex-row-fluid pe-11 mb-5">
                <div class="d-flex fs-7 fw-semibold align-items-center mb-3">
                    <div class="bullet bg-success me-3"></div>
                    <div class="text-gray-500">Total Amount</div>
                    <div class="ms-auto fw-bold text-gray-700">{{ currencyFormat(parseTokenAmount(contract?.totalAmount, contract?.tokenInfo.decimals)) }}</div>
                </div>
                <div class="d-flex fs-7 fw-semibold align-items-center mb-3">
                    <div class="bullet bg-primary me-3"></div>
                    <div class="text-gray-500">Claimed</div>
                    <div class="ms-auto fw-bold text-gray-700">{{ currencyFormat(parseTokenAmount(contract?.totalClaimedAmount, contract?.tokenInfo.decimals)) }}</div>
                </div>
                <div class="d-flex fs-7 fw-semibold align-items-center mb-3">
                    <div class="bullet bg-gray-400 me-3"></div>
                    <div class="text-gray-500">Remaining</div>
                    <div class="ms-auto fw-bold text-gray-700">{{ currencyFormat(parseTokenAmount(contract?.totalAmount - contract?.totalClaimedAmount, contract?.tokenInfo.decimals)) }}</div>
                </div>
                </div>
                <!--end::Labels-->
            </div>
            <div class="card card-dashed h-xl-100 flex-row flex-stack flex-wrap p-4 mb-5">
                <div class="symbol symbol-45px w-45px me-5">
                    <img :src="`https://${config.CANISTER_STORAGE_ID}.raw.icp0.io/${contract?.tokenInfo?.canisterId}.png`" :alt="contract?.tokenInfo.name">
                </div>
                <div class="d-flex flex-stack flex-grow-1 flex-wrap flex-md-nowrap">
                    <div class="mb-3 mb-md-0 fw-bold">
                        <h4 class="fs-6 text-gray-800 fw-bolder">{{ contract?.tokenInfo.name }}
                            <div class="badge badge-light-primary ms-auto">{{contract?.tokenInfo.standard}}</div>
                        </h4>
                        <div class="fs-7 text-gray-700">{{ contract?.tokenInfo.canisterId }} <Copy :text="contract?.tokenInfo.canisterId"></Copy></div>
                    </div>
                </div>
            </div>
                                                
            <div class="d-flex flex-stack flex-wrapr">
                <div class="d-flex flex-column me-2">
                    <span class="fs-8 text-gray-400 text-hover-primary me-2">Created</span>
                    <span class="badge bg-light text-gray-700 px-3 py-2">{{ moment.unix(Number(contract?.created)).format("lll") }}</span>
                </div>
                
                <div class="d-flex flex-column me-2">
                    <span class="text-gray-400 fs-8 me-2 text-hover-primary">Created By</span>
                    <span class="text-gray-700 fw-bold fs-7" :title="contract?.owner">{{ shortPrincipal(contract?.owner) }} <Copy :text="contract?.owner"></Copy></span>
                </div>
                <div class="d-flex flex-column">
                    <span class="fs-8 text-gray-400 text-hover-primary">Status</span>
                    <span class="badge badge-light-success me-auto">Started</span>
                </div>
            </div>
            
            <!--end::Indicator-->
        </div>
        <!--end::Card body-->
    </div>
    <!--end::Card-->
</template>