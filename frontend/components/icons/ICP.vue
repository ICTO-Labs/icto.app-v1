<script setup>
    const props = defineProps(['size']);
    const size = props.size || 1;
</script>
<template>
    <span class="me-1">
        <img src="/media/icp.png" alt="ICP" width="24">
    </span>
</template>

<style scoped>
.btn-icon {
    /* Add your button styles here */
}
</style>
