<script setup>
    import { ref, watch, onMounted } from "vue";
    import {LineChart,useLineChart} from "vue-chart-3";
    import {Chart,registerables} from "chart.js";
    import { formatTokenAmount } from "@/utils/token";
    Chart.register(...registerables);
    import moment from "moment";
    import config from "@/config";

    const props = defineProps(['contractInfo', 'contractId']);
    const contractInfo = ref(props.contractInfo);
    console.log('CAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA', contractInfo.value);
    // const { data: contractInfo, error, isError, isLoading, isRefetching, refetch } = useGetContract(props.contractId);
    const chartDetail = ref({
        label: [],
        data: []
    })
    const chatSeries = ref([]);
    const chartData = ref({});
    watch(contractInfo, async() =>{
        generateChartData();
    })
    const generateChartData = ()=>{
        chartDetail.value.label = [];
        chartDetail.value.data = [];
        let startTime = Number(contractInfo.value.startTime);
        let unlockSchedule = Number(contractInfo.value.unlockSchedule);
        let lockDuration = Number(contractInfo.value.lockDuration);
        let unlockAmount = Number(contractInfo.value.totalAmount)/(formatTokenAmount(lockDuration/unlockSchedule, contractInfo.value.tokenInfo.decimals));
        //Generate data
        let _startCount = 0;
        let _maxLoop = 100;//Limit the loop!
        for (let i = startTime; i <= startTime+(lockDuration)+unlockSchedule; i +=unlockSchedule) {
            _startCount++
            if(_startCount >= _maxLoop) break;
            chatSeries.value.push({
                x: moment.unix(i).format('H:mm MMM D, YY'),
                y: (unlockAmount*(_startCount)).toFixed(2)
            })
            chartDetail.value.label.push(moment.unix(i).utc().format('H:mm MMM D, YY'));
            chartDetail.value.data.push(Number((unlockAmount*(_startCount-1)).toFixed(2)))
        }
        
        chartData.value = {
            labels: chartDetail.value.label,
            datasets: [{
                label: 'Unlock',
                data: chartDetail.value.data,
                backgroundColor: ['#77CEFF'],
                borderColor: '#018FFB',
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
    const xseries = [{
            name: "Unlock",
            data: chatSeries.value,//[34, 44, 54, 64, 74, 84, 94, 104, 114, 124, 134]
        }];
    const xchartOptions = {
            chart: {
                type: 'area',
                height: 350
            },
            stroke: {
                curve: 'stepline',
            },
            dataLabels: {
                enabled: false
            },
            title: {
                text: '',
                align: 'left'
            },
            markers: {
                size: 5,
                hover: {
                    sizeOffset: 4
                }
            },
            tooltip: {
                x: {
                    format: "H:m MMM dd, yyyy"
                }
            },
            fill: {
                type: "gradient",
                gradient: {
                    shadeIntensity: 1,
                    opacityFrom: 0.7,
                    opacityTo: 0.9,
                    stops: [0, 90, 100]
                }
            },
            xaxis: {
                labels: {
                    format: 'H:m MMM dd, yyyy',
                },
                type: 'datetime',
                categories: chartDetail.value.label,
            },
            annotations: {
                xaxis: [{
                x: 1704361048*1000, //moment().unix(),
                strokeDashArray: 1,
                borderColor: '#018FFB',
                label: {
                    borderColor: '#018FFB',
                    style: {
                        color: '#fff',
                        background: '#018FFB',
                    },
                    text: 'Today',
                }
                }]
            }
        }
    onMounted(() => {
        generateChartData();
    })   
</script>
<template>
    <!-- <apexchart type="line" height="350" :options="xchartOptions" :series="xseries" v-if="chartDetail"></apexchart> -->
    <LineChart :chartData="chartData" :options="chartOptions" />
</template>