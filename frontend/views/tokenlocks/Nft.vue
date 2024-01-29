<script setup>
    const modalInfo = {
        modal: 'showLiquidityLocksModal',
        label: 'Create NFT Locks',
        icon: 'fa-lock'
    };

</script>
<template>
    <Toolbar current="Liquidity" :parents="[{title: 'Token Locks', to: '/token-locks'}]" :modal="modalInfo" />

    NFT
</template>