<script setup>
    import { ref } from 'vue';
    import NewLockModal from '@/components/tokenlocks/NewLockModal.vue';
    import { formatTokenMeta } from '@/utils/pool';
    import { showModal } from "@/utils/common";
	const poolCanister = ref("z6v2h-2qaaa-aaaag-qblva-cai");
	const poolName = ref("");
	const tokenMeta = ref(null);
    let _tokenMeta = {
            "token0":[
                [
                    "name", { "Text":"Canister Token" }
                ],
                [
                    "symbol",{ "Text":"XCANIC" }
                ],
                [
                    "decimals", { "Nat":"8" }
                ],
                [
                    "ownerAccount", { "Text":"6102c39ede652286711a1019b6e2e67c0b765241db23b3e96b9f203b6174e6a2" }
                ]
            ],
            "token1":[
                [
                    "name", { "Text":"Internet Computer" }
                ],
                [
                    "symbol", { "Text":"ICP" }
                ],
                [
                    "decimals", { "Nat":"8" }
                ],
                [
                    "fee", { "Nat":"3000" }
                ]
            ]
        }
        tokenMeta.value = formatTokenMeta(_tokenMeta);
        poolName.value = `${tokenMeta.value.token0.symbol}/${tokenMeta.value.token1.symbol}`;

    const getPoolMeta = ()=> {};
    const create = ()=> {
        showModal("showNewLockModal", true);
    };

</script>
<template>
    <Toolbar current="Liquidity" :parents="[{title: 'Token Locks', to: '/token-locks'}]" />
    <div class="card card-xl-stretch mb-5 mb-xl-10">
	<div class="card-header border-0 pt-5">
		<h3 class="card-title align-items-start flex-column">
			<span class="card-label fw-bolder fs-3 mb-1">Liquidity Locks <span class="badge badge-light-primary">{{ myToken?myToken.length:0 }}</span></span>
			<span class="text-muted mt-1 fw-bold fs-7" v-if="isLoading">Loading...</span>
			<span class="text-muted mt-1 fw-bold fs-7" v-if="isError">{{ error }}</span>
		</h3>
		<div class="card-toolbar">
			<ul class="nav">
				<li class="nav-item">
					<a href="#" class="btn btn-sm btn-bg-light btn-active-dark me-3" @click="refetch()" :disabled="isRefetching">{{isRefetching?'Loading...':'Refresh'}}</a>
					<a href="#" class="btn btn-sm btn-primary btn-active-dark me-3" @click="create()" >Create new locks</a>
				</li>
				
			</ul>
		</div>
	</div>
	<div class="card-body py-3">
		<div class="table-responsive" >
			<table class="table table-row-dashed table-row-gray-200 align-middle gs-0 gy-4">
				<thead>
					<tr class="fw-400 fw-bold">
						<th class="w-50px">#</th>
						<th class="min-w-150px">Token Name</th>
						<th class="min-w-150px">Token Symbol</th>
						<th class="min-w-140px">Canister ID</th>
						<th class="min-w-110px">Standard</th>
						<th class="min-w-50px">Manage</th>
					</tr>
				</thead>
				<tbody>
					
				</tbody>
				<!--end::Table body-->
			</table>
			<Empty v-if="myToken && myToken.length ==0"></Empty>

		</div>
	</div>
	<!--end::Body-->
</div>
<NewLockModal />
</template>
