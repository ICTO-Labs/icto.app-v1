<script setup>
    import { ref } from 'vue';
    import { formatPoolMeta } from '@/utils/pool';
	const poolCanister = ref("z6v2h-2qaaa-aaaag-qblva-cai");
	const poolName = ref("");
	const poolMeta = ref(null);
    let _poolMeta = {
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
        poolMeta.value = formatPoolMeta(_poolMeta);
        poolName.value = `${poolMeta.value.token0.symbol}/${poolMeta.value.token1.symbol}`;

    const getPoolMeta = ()=> {};

</script>
<template>
    <Toolbar current="Liquidity" :parents="[{title: 'Token Locks', to: '/token-locks'}]" />
    <form class="form" @submit.prevent="getPoolMeta">
        <div class="card mb-xl-1">
            <div class="card-body">
                    <div class="current" data-kt-stepper-element="content">
                        <div class="w-100">
                            <div class="row mb-5">
                                <div class="col-md-8 fv-row">
                                    <label class="required fs-6 fw-bold form-label mb-2">Pool Canister</label>
                                    <div class="row fv-row">
                                        <div class="col-12">
                                            <input type="text" class="form-control" v-model="poolCanister" required  @change="getPoolMeta" placeholder="Pool canister on ICPSwap, ie: XCANIC/ICP"/>
                                            <div class="form-text">Note: Currently we only support pools created from <strong>ICPSwap</strong>, please add LP on ICPSwap before locking. Find your pools <a href="https://info.icpswap.com/swap" target="_blank">here</a> <i class="fas fa-link"></i> </div>
                                        </div>
                                    </div>
                                </div>
                                <div class="col-md-4 fv-row">
                                    <label class="fs-6 fw-bold form-label mb-2">Name</label>
                                    <div class="row fv-row">
                                        <div class="col-12">
                                            <input type="text" class="form-control form-control-solid" :value="poolName" readonly/>
                                        </div>
                                    </div>
                                </div>
                            </div>
                            <div class="row mb-5">
                                <div class="col-md-12 fv-row">
                                    <label class="fs-6 fw-bold form-label mb-2 mb-5">Your LP Positions</label>
                                    <div class="row fv-row">
                                        <div class="col-lg-4">
                                            <div class="d-flex d-flex-column align-items-center bg-light-primary rounded p-5 mb-7">
                                                <div class="symbol symbol-35px symbol-circle me-5" data-bs-toggle="tooltip" title="" data-bs-original-title="Susan Redwood">
                                                    <span class="symbol-label bg-primary text-inverse-primary fw-bolder">1</span>
                                                </div>
                                                <div class="flex-grow-1 me-2">
                                                    <span class="fw-bolder text-gray-800 text-hover-primary fs-6">{{poolName}} 
                                                    </span>
                                                    <span class="fw-bold d-block text-success py-1">Value: $3.10k</span>
                                                </div>
                                                <button class="btn btn-sm btn-danger"><i class="fas fa-lock"></i> Lock</button>
                                            </div>
                                        </div>
                                        <div class="col-lg-4">
                                            <div class="d-flex d-flex-column align-items-center bg-light-primary rounded p-5 mb-7">
                                                <div class="symbol symbol-35px symbol-circle me-5" data-bs-toggle="tooltip" title="" data-bs-original-title="Susan Redwood">
                                                    <span class="symbol-label bg-primary text-inverse-primary fw-bolder">3</span>
                                                </div>
                                                <div class="flex-grow-1 me-2">
                                                    <span class="fw-bolder text-gray-800 text-hover-primary fs-6">{{poolName}} 
                                                    </span>
                                                    <span class="fw-bold d-block text-success py-1">Value: $871</span>
                                                </div>
                                                <button class="btn btn-sm btn-danger"><i class="fas fa-lock"></i> Lock</button>
                                            </div>
                                        </div>
                                        <div class="col-lg-4">
                                            <div class="d-flex d-flex-column align-items-center bg-light-primary rounded p-5 mb-7">
                                                <div class="symbol symbol-35px symbol-circle me-5" data-bs-toggle="tooltip" title="" data-bs-original-title="Susan Redwood">
                                                    <span class="symbol-label bg-primary text-inverse-primary fw-bolder">10</span>
                                                </div>
                                                <div class="flex-grow-1 me-2">
                                                    <span class="fw-bolder text-gray-800 text-hover-primary fs-6">{{poolName}} 
                                                    </span>
                                                    <span class="fw-bold d-block text-success py-1">Value: $209</span>
                                                </div>
                                                <button class="btn btn-sm btn-danger"><i class="fas fa-lock"></i> Lock</button>
                                            </div>
                                        </div>
                                        <div class="col-lg-4">
                                            <div class="d-flex d-flex-column align-items-center bg-light-primary rounded p-5 mb-7">
                                                <div class="symbol symbol-35px symbol-circle me-5" data-bs-toggle="tooltip" title="" data-bs-original-title="Susan Redwood">
                                                    <span class="symbol-label bg-primary text-inverse-primary fw-bolder">25</span>
                                                </div>
                                                <div class="flex-grow-1 me-2">
                                                    <span class="fw-bolder text-gray-800 text-hover-primary fs-6">{{poolName}} 
                                                    </span>
                                                    <span class="fw-bold d-block text-success py-1">Value: $101k</span>
                                                </div>
                                                <button class="btn btn-sm btn-danger"><i class="fas fa-lock"></i> Lock</button>
                                            </div>
                                        </div>
                                    </div>
                                </div>
                            </div>
                            
                        </div>
                    </div>
            </div>
        </div>
    </form>
</template>
