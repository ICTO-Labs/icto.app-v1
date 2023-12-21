<script setup>
    import { ref, watch } from "vue";
    import {LineChart,useLineChart} from "vue-chart-3";
    import {Chart,registerables} from "chart.js";
    Chart.register(...registerables);
    import { useGetContract, useGetPaymentHistory, useCancelContract } from "@/services/Contract";

    const props = defineProps(['contractInfo', 'contractId']);
    const { data: contractInfo, error, isError, isLoading, isRefetching, refetch } = useGetContract(props.contractId);

    const chartDetail = ref({
        label: [],
        data: []
    })
    const chartData = ref({});
    watch(contractInfo, async() =>{
        generateChartData();
    })
    const generateChartData = ()=>{
        chartDetail.value.label = [];
        chartDetail.value.data = [];
        let startTime = Number(contractInfo.value.startTime);
        let unlockSchedule = Number(contractInfo.value.unlockSchedule);
        let durationTime = Number(contractInfo.value.durationTime);
        let durationUnit = Number(contractInfo.value.durationUnit);
        let unlockAmount = Number(contractInfo.value.totalAmount)/(durationUnit*durationTime/unlockSchedule);
        //Generate data
        let _startCount = 0;
        let _maxLoop = 100;//Limit the loop!
        for (let i = startTime; i <= startTime+(durationUnit*durationTime); i +=unlockSchedule) {
            _startCount++
            if(_startCount >= _maxLoop) break;
            chartDetail.value.label.push(moment.unix(i).format('H:mm MMM, YY'));
            chartDetail.value.data.push(unlockAmount*(_startCount-1))
        }
        chartData.value = {
            labels: chartDetail.value.label,
            datasets: [{
                label: 'Unlock',
                data: chartDetail.value.data,
                backgroundColor: ['#77CEFF'],
                borderColor: '#288feb',
                fill: true,
                stepped: true,
                pointStyle: 'circle',
                pointRadius: 5,
                pointHoverRadius: 10
            }, ],
        };
    }

    const chartOptions = ref({
        responsive: true,
        plugins: {
            tooltip: {
                mode: 'index',
                intersect: false
            },
            legend: {
                display: false
            }
        },
        hover: {
            mode: 'index',
            intersec: false
        },
    })
</script>
<template>
    <LineChart :chartData="chartData" :options="chartOptions" />
</template>