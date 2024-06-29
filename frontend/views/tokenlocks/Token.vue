<script setup>
    const modalInfo = {
        modal: 'showLiquidityLocksModal',
        label: 'Create Token Locks',
        icon: 'fa-lock'
    };

</script>
<template>
    <Toolbar current="Liquidity" :parents="[{title: 'Token Locks', to: '/locks'}]" :modal="modalInfo" :showBtn="{label: 'New locks', icon: 'fa-plus', modal: 'showNewLockModal'}" />

    Token
</template>