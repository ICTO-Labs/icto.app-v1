<script setup>
    import { ref, watch, onMounted, computed } from "vue";
    import {LineChart,useLineChart} from "vue-chart-3";
    import {Chart,registerables} from "chart.js";
    import chartjsPluginAnnotation from "chartjs-plugin-annotation";
    import { getTimeFromNanoToSeconds } from "@/utils/common";
    import { numberFromE8s } from "@/utils/token"
    Chart.register(...registerables, chartjsPluginAnnotation);
    import moment from "moment";
    const props = defineProps(['contractInfo', 'isChanged']);
    // const contractInfo = ref(props.contractInfo);
    const contractInfo = computed(() => props.contractInfo);

    // const { data: contractInfo, error, isError, isLoading, isRefetching, refetch } = useGetContract(props.contractId);
    const chartDetail = ref({
        label: [],
        data: []
    })
    const chatSeries = ref([]);
    const chartData = ref({});
    watch(props, async() =>{
        generateChartData();
    }, { deep: true })

    const lineChartData = ref([]);
    const lineChartLabel = ref([]);

    

    const calculateAnnotationCliff = (blockCliff)=>{
        if(blockCliff > 0){
            chartOptions.value.plugins.annotation.annotations.cliff.value = blockCliff;
            chartOptions.value.plugins.annotation.annotations.cliff.label.display = true;
        }else{
            chartOptions.value.plugins.annotation.annotations.cliff.value = 0;
            chartOptions.value.plugins.annotation.annotations.cliff.label.display = false;
        }
    }
    const generateChartData = async ()=>{
        chartDetail.value.label = [];
        chartDetail.value.data = [];
        chatSeries.value = [];
        chartData.value = [];

        const {
            startTime,
            unlockSchedule,
            durationTime,
            durationUnit,
            cliffTime,
            cliffUnit,
            totalAmount
        } = contractInfo.value;

        console.log('contractInfo', contractInfo.value);
        let startTimeSeconds = getTimeFromNanoToSeconds(startTime);
        const totalDurationSeconds = Number(durationTime) * Number(durationUnit);
        const cliffDurationSeconds = Number(cliffTime) * Number(cliffUnit);
        const numUnlocks = Math.min(Number(unlockSchedule), 31);
        const tokenAmount = numberFromE8s(totalAmount);
        let blockCliff = durationUnit == 0 ? 0 : Math.ceil(Number(cliffUnit)*Number(cliffTime) / Number(durationTime));

        const addDay = (days)=>{
            return moment.unix(startTimeSeconds).add(days, 'day').format('YYYY-MM-DD');
        }

        const hideToday = ()=>{
            chartOptions.value.plugins.annotation.annotations.currentTime.value = 0;
            chartOptions.value.plugins.annotation.annotations.currentTime.label.display = false;
        }
        // let unlockSchedule = Number(contractInfo.value.unlockSchedule);
        // let durationTime = Number(contractInfo.value.durationTime);
        // let durationUnit = Number(contractInfo.value.durationUnit);
        // let cliffUnit = Number(contractInfo.value.cliffUnit);
        // let cliffTime = Number(contractInfo.value.cliffTime);
        // let unlockAmount = Number(durationUnit*durationTime/unlockSchedule);
        // let unlockUnit = Number(durationUnit*durationTime/unlockSchedule);
        // let blockCliff = Math.ceil(cliffUnit*cliffTime / durationTime);

        
        //For line chart
        // const vestingType = Number(durationTime)*Number(durationUnit) === Number(unlockSchedule) ? 'single' : 'step';
        const vestingType = Number(durationUnit) == 0 ? 'single' : 'step';
        const numSteps = Math.floor(Number(durationTime)*Number(durationUnit)/ (vestingType == 'single'?Number(durationTime):Number(unlockSchedule)));
        const vestingValue = tokenAmount / numSteps;

        lineChartData.value = [];
        lineChartLabel.value = [];
        let currentValue = 0;

        let start = 0;
        lineChartData.value.push({ x: 0, y: 0 });
        lineChartLabel.value.push(addDay(-1));//-1 day
        lineChartLabel.value.push(moment().format('YYYY-MM-DD'));//Today
        //Add start time
        console.log('start time', moment.unix(startTimeSeconds).format('YYYY-MM-DD'));
        // chartOptions.value.plugins.annotation.annotations.startTime.value = moment.unix(startTimeSeconds).format('YYYY-MM-DD');
        // chartOptions.value.plugins.annotation.annotations.currentTime.value = moment().format('YYYY-MM-DD');
        //Settting cliff
        calculateAnnotationCliff(blockCliff);
        for (let i = 0; i < blockCliff; i++) {
                start ++;
                lineChartData.value.push({ x: i * Number(durationTime)*Number(durationUnit), y: 0 });
                lineChartLabel.value.push(addDay(start));
        }

        // Adding points for the chart
        for (let i = 1; i <= numSteps; i++) {
            start ++;
            currentValue = Math.min(currentValue + vestingValue, tokenAmount); // Not greater than 1
            if(vestingType == 'single'){//Single
                //Set fullyVested value if single
                if(start == durationUnit+blockCliff){
                    currentValue = tokenAmount;
                }else currentValue = 0;
                lineChartData.value.push({ x: i * Number(durationTime), y: currentValue });
            }else{//Step
                lineChartData.value.push({ x: i * Number(durationTime), y: currentValue });
            }
            // lineChartData.value.push({ x: cliffUnit*cliffTime + i * Number(durationTime), y: currentValue });
            lineChartLabel.value.push(addDay(start));
        }
        //Settting fully vested
        if(vestingType == 'single'){
            chartOptions.value.plugins.annotation.annotations.fullyVested.value = start;
            hideToday();
        }else{
            chartOptions.value.plugins.annotation.annotations.fullyVested.value = start;
        }
        if(start == 0){
            chartOptions.value.plugins.annotation.annotations.fullyVested.label.rotation = '0';
            chartOptions.value.plugins.annotation.annotations.fullyVested.label.content = 'Unlock immediately';
        }else{
            chartOptions.value.plugins.annotation.annotations.fullyVested.label.rotation = 'vertical';
            chartOptions.value.plugins.annotation.annotations.fullyVested.label.content = 'Fully vested';
            //Rotation label limit
            if(start > 30){
                chartOptions.value.plugins.annotation.annotations.fullyVested.label.rotation = '90';
            }
        }
        

        // Adding more 3 points for the chart
        for (let i = 0; i < 3; i++) {
            start ++;
            lineChartData.value.push({ x: Number(durationTime)*Number(durationUnit) + i * Number(durationTime), y: tokenAmount });
            lineChartLabel.value.push(addDay(start));
        }

        //Generate data

        chartData.value = {
            labels: lineChartLabel.value,
            datasets: [
                {
                    data: lineChartData.value,
                    backgroundColor: ['#77CEFF', '#ccc'],
                    borderColor: '#018FFB',
                    fill: true,
                    stepped: true, //vestingType == 'step' ? true : false,
                    pointStyle: 'circle',
                    pointRadius: 0,
                    pointHoverRadius: 0,
                    spanGaps: true
                },
            ],
        };
    }

    const chartOptions = ref({
        responsive: true,
        scales: {
            x: {
                title: {
                    display: true,
                    text: 'Unlock Schedule'
                }
            },
            y: {
                beginAtZero: true,
                title: {
                    display: true,
                    text: 'Token Amount'
                }
            }
        },
        plugins: {
            tooltip: {
                mode: 'index',
                intersect: false
            },
            legend: {
                display: false
            },
            annotation: {
                annotations: {
                    cliff: {
                        type: 'line',
                        scaleID: 'x',
                        borderWidth: 1,
                        borderColor: 'gray',
                        value: 0,
                        label: {
                            rotation: 'vertical',
                            content: 'Cliff',
                            display: true,
                            position: 'center',
                            backgroundColor: 'rgba(245, 245, 245)',
                            color: 'gray',
                        },
                    },
                    fullyVested: {
                        type: 'line',
                        scaleID: 'x',
                        borderWidth: 1,
                        borderColor: 'gray',
                        value: 0,
                        label: {
                            rotation: 'vertical',
                            content: 'Fully vested',
                            display: true,
                            position: 'center',
                            backgroundColor: 'rgba(245, 245, 245)',
                            color: 'gray',
                        },
                    },
                    copyright: {
                        type: 'box',
                        backgroundColor: 'transparent',
                        borderWidth: 0,
                        label: {
                            drawTime: 'afterDatasetsDraw',
                            display: true,
                            color: 'rgba(208, 208, 208, 0.3)',
                            content: 'ICTO.APP',
                            font: {
                            size: (ctx) => ctx.chart.chartArea.height / 10
                            },
                            position: 'center'
                        }
                    },
                    currentTime: {
                        type: 'line',
                        scaleID: 'x',
                        borderWidth: 1,
                        borderColor: 'green',
                        borderDash: [3, 3],
                        value: moment().format('YYYY-MM-DD'),
                        label: {
                            rotation: 'horizontal',
                            content: 'Today',
                            display: true,
                            position: 'center',
                            backgroundColor: 'rgba(60, 179, 113, 0.9)',
                            color: 'white'
                        }
                    }
                }
            }
        },
        hover: {
            mode: 'index',
            intersec: false
        },
        
    })
    onMounted(() => {
        generateChartData();
    })   
</script>
<template>
    <!-- <apexchart type="line" height="250" :options="xchartOptions" :series="xseries" v-if="chartDetail"></apexchart> -->
    <LineChart :chartData="chartData" :options="chartOptions"/>
</template>