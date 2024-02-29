<script setup>
    const modalInfo = {
        modal: 'showLiquidityLocksModal',
        label: 'Create NFT Locks',
        icon: 'fa-lock'
    };
    const btnObj = {
        label: 'New locks',
        icon: 'fa-plus',
        modal: 'showNewLockModal'
    }
</script>
<template>
    <Toolbar current="Liquidity" :parents="[{title: 'Token Locks', to: '/token-locks'}]" :modal="modalInfo" :showBtn="btnObj"/>

    NFT
</template>