<script setup>
    import SingleCollection from '@/components/marketplace/SingleCollection.vue';
</script>
<template>
    <Toolbar :current="`Marketplace`"/>

    <div class="row g-6 g-xl-9">
        <SingleCollection />
    </div>
</template>