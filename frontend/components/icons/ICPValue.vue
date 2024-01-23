<script setup>
    import { ref, watchEffect } from "vue";
    import walletStore from "@/store";
    const props = defineProps(["amount", "noUSD"]);
    const toUSD = ref(0);
    watchEffect(() => {
        toUSD.value = props.amount*walletStore.icpPrice;
    });
    console.log(walletStore.icpPrice);
    console.log('use icp');
</script>
<template>
    <div class="fw-bolder fs-2">
        <slot></slot>
        <span class="text-muted fs-4 fw-bold ms-2">ICP</span>
        <span class="text-muted fw-bold d-block fs-6" v-if="!noUSD">≈ ${{ toUSD }}</span>
    </div>
</template>