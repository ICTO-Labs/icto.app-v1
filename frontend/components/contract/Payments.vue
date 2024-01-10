<script setup>
    import { watch } from "vue";
    import {useGetMyContracts} from "@/services/Contract";
    import ContractCard from './ContractCard.vue';
    import walletStore from '@/store'
    const { data: contracts, error, isError, isLoading, isRefetching, refetch } = useGetMyContracts(0);
console.log('contracts', contracts);
    watch(
    () => walletStore.isLogged,
    (newValue, oldValue) => {
        console.log('login state changed', walletStore.isLogged);
        refetch()
    },
    { deep: true }
    )
</script>
<template>
    <div class="row g-6 g-xl-9">
        <div v-if="isLoading || isRefetching">Refetching data...</div>
        <div v-if="isError">{{ error }}</div>
        <Empty v-if="contracts && contracts.length == 0  && !isLoading && !isRefetching" />
        <div class="col-sm-6 col-xl-4" v-for="contract in contracts">
           <ContractCard :contractId="contract" />
        </div>
    </div>
</template>