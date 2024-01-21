<script setup>
    import { ref } from "vue"
    const props = defineProps(["amount", "noUSD"]);
    const amount = ref(0);
    const toUSD = ref(props.amount*12.82);
</script>
<template>
    <div class="fw-bolder fs-2">
        <slot></slot>
        <span class="text-muted fs-4 fw-bold ms-2">ICP</span>
        <span class="text-muted fw-bold text-muted d-block fs-6" v-if="!noUSD">≈ ${{ toUSD|0 }}</span>
    </div>
</template>