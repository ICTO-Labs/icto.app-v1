<script setup>
    const modalInfo = {
        modal: 'showLiquidityLocksModal',
        label: 'Create Token Locks',
        icon: 'fa-lock'
    };

</script>
<template>
    <Toolbar current="Liquidity" :parents="[{title: 'Token Locks', to: '/token-locks'}]" :modal="modalInfo" />

    Token
</template>