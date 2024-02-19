<script setup>
    import { watch, ref, onMounted } from "vue";
    import {useGetMyContracts} from "@/services/Contract";
    import ContractCard from './ContractCard.vue';
    import walletStore from '@/store';
    const contracts = ref([]);
    const isLoading = ref(false);
    // const { data: contracts, error, isError, isLoading, isRefetching, refetch } = useGetMyContracts(0);
    watch(
        () => walletStore.isLogged,
        (newValue, oldValue) => {
            getContracts();
        },
        { deep: true }
    )

    const getContracts = async () => {
        isLoading.value = true;
        contracts.value = await useGetMyContracts(0);
        console.log('contracts', contracts.value);

        isLoading.value = false;
    }
    onMounted(async () => {
        getContracts();
    });
</script>
<template>
    <div class="row g-6 g-xl-9" v-if="isLoading">
            <div class="col-md-12 fv-row">
                <label class="fs-6 fw-bold form-label mb-2 mb-5"><i class="fas fa-spinner fa-spin fa-1x"></i> Loading your contracts...</label>
            </div>
    </div>
    <Empty v-else-if="!contracts.length" title="No Contracts" description="You have not created any contracts yet." />
    <div class="row g-6 g-xl-9" v-if="contracts">
        <div class="col-sm-6 col-xl-4" v-for="contract in contracts">
            <ContractCard :contractId="contract" />
        </div>
    </div>
</template>