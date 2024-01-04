<script setup>
    import { ref } from "vue";
    import {useGetMyContracts} from "@/services/Contract";
    import ContractCard from './ContractCard.vue';
    const { data: contracts, error, isError, isLoading, isRefetching, refetch } = useGetMyContracts(0);
</script>
<template>
    <div class="row g-6 g-xl-9">
        <div v-if="isLoading">Loading...</div>
        <div v-if="isError">{{ error }}</div>
        <div class="col-sm-6 col-xl-4" v-for="contract in contracts">
           <ContractCard :contractId="contract" />
        </div>
    </div>
</template>