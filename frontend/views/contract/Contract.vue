<script setup>
    import { useRoute } from 'vue-router';
    const router = useRoute();
    console.log(router);

    import Payments from '@/components/contract/Payments.vue';
    import Toolbar from '../../components/layout/Toolbar.vue';
    
</script>
<template>
    <Toolbar :current="`Payments`" :parents="[]"/>
    <Payments v-if="router.path == '/payments'"/>
</template>