<script setup>
    import { watch } from "vue";
    import {useGetMyContracts} from "@/services/Contract";
    import ContractCard from './ContractCard.vue';
    import walletStore from '@/store'
    const { data: contracts, error, isError, isLoading, isRefetching, refetch } = useGetMyContracts(0);

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
        <div v-if="isLoading || isRefetching">Loading...</div>
        <div v-if="isError">{{ error }}</div>
        <div class="col-sm-6 col-xl-4" v-for="contract in contracts" v-if="!isLoading && !isRefetching">
           <ContractCard :contractId="contract" />
        </div>
    </div>
</template>