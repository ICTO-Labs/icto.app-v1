<script setup>
    import { watch, ref, computed } from "vue";
    import {useGetMyContracts, useGetContractsByWallet} from "@/services/Contract";
    import ContractCard from '@/components/contract/ContractCard.vue';
    import walletStore from '@/store';
    // const contracts = ref([]);
    // const isLoading = ref(false);
    const filter = ref('all');
    const { data: contracts, error, isError, isLoading, isRefetching, refetch } = useGetContractsByWallet();
    watch(
        () => walletStore.isLogged, (newValue, oldValue) => {
            refetch();
        }
    )

    const filteredContracts = computed(() => {
        switch(filter.value) {
            case 'public':
                return contracts.value.publicContracts;
            case 'whitelist':
                return contracts.value.privateContracts;
            case 'all':
            default:
                return [
                    ...contracts.value.publicContracts,
                    ...contracts.value.privateContracts
                ];
        }
    });
</script>
<template>
    <Toolbar :current="`Token Claims`"/>
    <div class="d-flex flex-wrap flex-stack mb-6">
        <h3 class="fw-bolder my-2"> Claim Contracts 
            <span class="fs-6 text-gray-400 fw-bold ms-1">{{ filter.toUpperCase() }}</span>
        </h3>
        <div class="d-flex flex-wrap my-2">
            <div class="me-4">
                <select name="status" data-control="select2" class="form-select form-select-sm form-select-white" v-model="filter">
                    <option value="all">All</option>
                    <option value="public">Only public</option>
                    <option value="whitelist">Only related to me</option>
                    <option value="created">Only created by me</option>
                </select>
            </div>
            <router-link to="/token-claim/new" class="btn btn-primary btn-sm cursor-pointer"> New Contract </router-link>
        </div>
    </div>
    <div class="row g-6 g-xl-9" v-if="isLoading">
        <div class="col-md-12 fv-row">
            <label class="fs-6 fw-bold form-label mb-2 mb-5"><i class="fas fa-spinner fa-spin fa-1x"></i> Loading your contracts...</label>
        </div>
    </div>
    <div class="row g-6 g-xl-9 mb-10" v-if="filteredContracts && filteredContracts.length > 0">
        <div class="col-sm-6 col-xl-4" v-for="contract in filteredContracts" :key="contract">
            <ContractCard :contractId="contract"/>
        </div>
    </div>
</template>