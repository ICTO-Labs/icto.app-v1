<script setup>
    import moment from 'moment';
    import config from "@/config"
    import { useGetPaymentHistory } from "@/services/Contract";
    const props = defineProps(['contractId']);
    const { data: paymentHistory, isLoading, isError, error} = useGetPaymentHistory(props.contractId);
    console.log('paymentHistory', paymentHistory);;
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
                    <th class="min-w-90px sorting text-center" rowspan="1" colspan="1">Unlock Amount</th>
                    <th class="min-w-90px sorting" rowspan="1" colspan="1">Time</th>
                    <th class="min-w-90px sorting" rowspan="1" colspan="1">TxId</th>
                </tr>
                </thead>
                <span v-if="isLoading">Loading...</span>
                <span v-else-if="isError">Error: {{ error.message }}</span>
                <tbody class="fs-6 fw-normal">
                <tr class="odd" v-for="(payment, idx) in paymentHistory">
                    <td>
                        {{ idx +1}}.
                    </td>
                    <td>
                        <span class="fs-6 fw-normal text-primary">
                            {{ payment[1].to }}
                        </span>
                    </td>
                    <td class="text-center">{{ Number(payment[1].amount)/config.E8S }}</td>
                    <td> {{ moment.unix(Number(payment[1].time)).format('lll') }} </td>
                    <td> # </td>
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