<script setup>
	import ContractPreview from './modals/ContractPreview.vue'
	import ImportToken from './modals/ImportToken.vue'
	import DeployToken from './modals/DeployToken.vue'
	import TransferToken from './modals/TransferToken.vue'
	import Login from './modals/Login.vue'
	import BuyModal from './marketplace/BuyModal.vue'
	import ProcessBuyingModal from './marketplace/ProcessBuyingModal.vue'
</script>
<template>
	<ContractPreview />
	<ImportToken />
	<DeployToken />
	<TransferToken />
	<Login />
	<BuyModal />
	<ProcessBuyingModal />
</template>