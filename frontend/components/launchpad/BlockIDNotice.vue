<script setup>
    import { ref, onMounted, defineProps } from 'vue';
    import { checkEligibleToCommit } from '@/services/Launchpad';
    import { useRoute } from 'vue-router';
    import { useGetBlockIdScore } from '@/services/BlockId';
    import walletStore from '@/store/';

    const route = useRoute();
    const launchpadId = route.params.launchpadId;
    const props = defineProps({
        blockId: {
            type: String,
            required: true
        }
    });

    const eligibleToCommit = ref(false);
    const isLoading = ref(false);
    const {data: blockIdScore, isLoading: isLoadingBlockIdScore, refetch: refetchBlockIdScore} = useGetBlockIdScore(walletStore.principal);
    const checkEligible = async () => {
        refetchBlockIdScore;
        isLoading.value = true;
        eligibleToCommit.value = await checkEligibleToCommit(launchpadId);
        isLoading.value = false;
    }
    onMounted(() => {
        checkEligible();
    });
</script>
<template>
    <div class="notice bg-light-primary p-2 pb-0 rounded mt-3">
        <div class="fs-12"> 
            <div class="d-flex align-items-center justify-content-between pt-2">
                <div class="d-flex flex-column align-items-center">
                    <h4 class="text-primary mt-1">
                        <i class="fas fa-shield-alt text-primary fs-4"></i> BlockID verification
                    </h4>
                </div>
                <div class="d-flex flex-column align-items-center">
                    <a href="javascript:void(0)" @click="checkEligible" class="btn btn-sm btn-secondary btn-icon" :disabled="isLoading">
                        <i :class="`fas fa-sync-alt ${isLoading?'fa-spin':''}`"></i>
                    </a>
                </div>
            </div>
            <div>
                <table class="table table-border mb-0">
                    <thead>
                        <tr>
                            <th class="text-center">Required score</th>
                            <th class="text-center">Your score</th>
                        </tr>
                    </thead>
                    <tbody>
                        <tr>
                            <td class="text-center w-50"><span class="font-bold text-success fs-1 border border-dashed border-primary rounded px-5 py-2 bg-white">{{blockId || 0}}</span></td>
                            <td class="text-center w-50"><span class="font-bold text-primary fs-1 border border-dashed border-primary rounded px-5 py-2 bg-white">{{blockIdScore || 0}}</span></td>
                        </tr>
                        <tr>
                            <td colspan="2" class="text-center fw-bold fs-5">
                                <div v-if="isLoading">Loading...</div> 
                                <div class="align-items-center" v-else>

                                    <span class="text-info" v-if="!walletStore.isLogged">
                                        <i class="fas fa-info-circle text-info"></i> Connect wallet to check
                                    </span>
                                    <span class="text-success" v-else-if="eligibleToCommit && 'ok' in eligibleToCommit && walletStore.isLogged">
                                        <i class="fas fa-check-circle text-success"></i> Eligible
                                    </span>
                                    <span class="text-danger" v-else>
                                        <i class="fas fa-times-circle text-danger"></i> Not eligible
                                    </span>
                                </div>
                            </td>
                        </tr>
                        <tr>
                            <td colspan="2" class="text-center">
                                <div v-if="eligibleToCommit && 'err' in eligibleToCommit" class="mb-2 text-danger">
                                    {{ eligibleToCommit?.err || '0 point' }}
                                </div>
                                
                                <div class="text-center fs-9">
                                    Some projects require BlockID verification to participate. If you are not eligible, you can still join by verifying your wallet at <a href="https://blockid.cc" class="text-blue-600 hover:underline" target="_blank" rel="noopener">blockid.cc <i class="fas fa-external-link-alt"></i></a>
                                </div>
                            </td>
                        </tr>
                    </tbody>
                </table>
            </div>
        </div>
    </div>

</template>