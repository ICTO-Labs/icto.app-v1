<script setup>
    import { ref, watch, watchEffect, computed, defineExpose } from 'vue';
    import { getParticipantInfo } from '@/services/Launchpad';
    import { parseTokenAmount, formatTokenAmount, currencyFormat } from '@/utils/token';
    import walletStore from '@/store/';
    const props = defineProps(['launchpadId', 'stats', 'launchpadInfo']);
    const { data: myStats, isError, error, isLoading, isFetched, refetch } = getParticipantInfo(props.launchpadId, walletStore.principal);

    defineExpose({
        refetch
    })
    watch(() => walletStore.isLogged, (newIsLogged) => {
        if (newIsLogged) {
            refetch();
        }
    }, { immediate: true });
    // Calculate the number of tokens to receive
    const tokensToReceive = computed(() => {
        if (props?.stats?.totalAmountCommitted === 0) return 0;
        const share = Number(myStats?.value?.totalAmount) / Number(props?.stats?.totalAmountCommitted) || 0;
        return share * Number(props?.launchpadInfo?.launchParams?.sellAmount);
    });

    // Calculate the pool share
    const poolShare = computed(() => {
        if (props?.stats?.totalAmountCommitted === 0) return 0;
        return (Number(myStats?.value?.totalAmount) / Number(props?.stats?.totalAmountCommitted) * 100).toFixed(3);
    });

</script>
<template>
    <div v-if="walletStore.isLogged">
        <div class="table-responsive border border-primary border-dashed rounded px-4 mb-3 mt-5 pt-2">
            <table class="table table-flush align-middle table-row-bordered gy-2">
                <tbody class="fs-7 fw-bold text-gray-600">
                    <tr>
                        <td>Your commitment</td>
                        <td class="text-end text-primary">{{ currencyFormat(parseTokenAmount(myStats?.totalAmount, launchpadInfo?.purchaseToken?.decimals))}} {{launchpadInfo?.purchaseToken?.symbol}} </td>
                    </tr>
                    <tr>
                        <td>Pool share</td>
                        <td class="text-end text-gray">{{poolShare}}%</td>
                    </tr>
                    <tr>
                        <td>Tokens to receive </td>
                        <td class="text-end text-primary">{{currencyFormat(parseTokenAmount(tokensToReceive, launchpadInfo?.saleToken?.decimals))}} {{launchpadInfo?.saleToken?.symbol}} </td>
                    </tr>
                </tbody>
            </table>
        </div>
    </div>
</template>

