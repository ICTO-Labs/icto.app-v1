<script setup>
    import moment from 'moment';
    import config from "@/config"
    import { useGetClaimRecord } from "@/services/Contract";
    import { recordForm } from '@dfinity/candid';
    import { onMounted, ref, watchEffect } from 'vue';
    import walletStore from "@/store";
    import { parseTokenAmount } from '@/utils/token';
    const props = defineProps(['contractId', 'tokenDecimals']);
    // const { data: claimRecord, isLoading, isError, error} = useGetClaimRecord(props.contractId);
    const claimRecords = ref([]);
    const tokenDecimals = ref(props.tokenDecimals);

    const getMyClaim = async()=>{
        claimRecords.value = await useGetClaimRecord(props.contractId);
        console.log('claimRecords.value++++++++++++++++++++++++', claimRecords.value);
    }

    watchEffect(() => {
        if(walletStore.isLogged){
            getMyClaim();
        }
    });
    onMounted(()=>{
        getMyClaim();
    })
</script>
<template>
    <div class="card-body pt-0">
        <div class="table-responsive">
        <div id="kt_profile_overview_table_wrapper" class="dataTables_wrapper dt-bootstrap4 no-footer">
            <div class="table-responsive">
            <table id="kt_profile_overview_table" class="table table-row-bordered table-row-dashed gy-4 align-middle fw-bold dataTable no-footer">
                <thead class="fs-7 text-gray-500 text-uppercase">
                <tr>
                    <th class="min-w-20px sorting" rowspan="1" colspan="1">#</th>
                    <th class="min-w-250px sorting" rowspan="1" colspan="1">Recipient</th>
                    <th class="min-w-90px sorting text-center" rowspan="1" colspan="1">Claimed Amount</th>
                    <th class="min-w-90px sorting" rowspan="1" colspan="1">Time</th>
                    <th class="min-w-90px sorting" rowspan="1" colspan="1">TxId</th>
                </tr>
                </thead>
                <tbody class="fs-6 fw-normal">
                <tr class="odd" v-for="(record, idx) in claimRecords[0]">
                    <td>
                        {{ idx +1}}.
                    </td>
                    <td>
                        <span class="fs-6 fw-normal text-primary">
                            {{ walletStore.principal }}
                        </span>
                    </td>
                    <td class="text-center">{{ parseTokenAmount(record.amount, tokenDecimals) }}</td>
                    <td> {{ moment.unix(Number(record.claimedAt)).format('lll') }} </td>
                    <td> #{{ record.txId }} </td>
                </tr>
                </tbody>
            </table>
            </div>
        </div>
        <!--end::Table-->
        </div>
        <!--end::Table container-->
    </div>
</template>