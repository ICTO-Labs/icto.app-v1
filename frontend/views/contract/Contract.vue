<script setup>
    import { useRoute } from 'vue-router';
    const router = useRoute();
    console.log(router);

    import Payments from '@/components/contract/Payments.vue';
    
</script>
<template>
   <Payments v-if="router.path == '/payments'"/>
</template>