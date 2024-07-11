<script setup>
    import { ref, watch, onMounted } from "vue";
    import {LineChart,useLineChart} from "vue-chart-3";
    import {Chart,registerables} from "chart.js";
    import chartjsPluginAnnotation from "chartjs-plugin-annotation";

    Chart.register(...registerables, chartjsPluginAnnotation);
    import moment from "moment";

    const props = defineProps(['contractInfo', 'isChanged']);
    const contractInfo = ref(props.contractInfo);
    // const { data: contractInfo, error, isError, isLoading, isRefetching, refetch } = useGetContract(props.contractId);
    const chartDetail = ref({
        label: [],
        data: []
    })
    const chatSeries = ref([]);
    const chartData = ref({});
    watch(props, async() =>{
        console.log('contract', props.contractInfo);
        generateChartData();
    })

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
        let startTime = Number(contractInfo.value.startTime);
        let unlockSchedule = Number(contractInfo.value.unlockSchedule);
        let durationTime = Number(contractInfo.value.durationTime);
        let durationUnit = Number(contractInfo.value.durationUnit);
        let cliffUnit = Number(contractInfo.value.cliffUnit);
        let cliffTime = Number(contractInfo.value.cliffTime);
        let unlockAmount = Number(durationUnit*durationTime/unlockSchedule);
        let unlockUnit = Number(durationUnit*durationTime/unlockSchedule);
        let blockCliff = Math.ceil(cliffUnit*cliffTime / durationTime);

        //For line chart
        const vestingType = durationTime*durationUnit === unlockSchedule ? 'single' : 'step';
        const numSteps = Math.floor(durationTime*durationUnit/ (vestingType == 'single'?durationTime:unlockSchedule));
        const vestingValue = 1 / numSteps;

        lineChartData.value = [];
        lineChartLabel.value = [];
        let currentValue = 0;

        let start = 0;
        lineChartData.value.push({ x: 0, y: 0 });
        lineChartLabel.value.push(0);
        //Settting cliff
        calculateAnnotationCliff(blockCliff);
        for (let i = 0; i < blockCliff; i++) {
                start ++;
                lineChartData.value.push({ x: i * Number(contractInfo.value.durationTime)*Number(contractInfo.value.durationUnit), y: 0 });
                lineChartLabel.value.push(start);
        }

        // Adding points for the chart
        for (let i = 1; i <= numSteps; i++) {
            start ++;
            currentValue = Math.min(currentValue + vestingValue, 1); // Not greater than 1
            if(vestingType == 'single'){//Single
                //Set fullyVested value if single
                if(start == durationUnit+blockCliff){
                    currentValue = 1;
                }else currentValue = 0;
                lineChartData.value.push({ x: i * Number(durationTime), y: currentValue });
            }else{//Step
                lineChartData.value.push({ x: i * Number(durationTime), y: currentValue });
            }
            // lineChartData.value.push({ x: cliffUnit*cliffTime + i * Number(durationTime), y: currentValue });
            lineChartLabel.value.push(start);
        }
        //Settting fully vested
        if(vestingType == 'single'){
            chartOptions.value.plugins.annotation.annotations.fullyVested.value = start;
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
            lineChartData.value.push({ x: durationTime*durationUnit + i * Number(contractInfo.value.durationTime), y: 1 });
            lineChartLabel.value.push(start);
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
                            borderColor: '#ccc',
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
                            borderColor: '#ccc',
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
                            color: 'rgba(208, 208, 208, 0.2)',
                            content: 'ICTO.APP',
                            font: {
                            size: (ctx) => ctx.chart.chartArea.height / 10
                            },
                            position: 'center'
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
    const xseries = [{
            name: "Unlock",
            data: chatSeries.value,//[34, 44, 54, 64, 74, 84, 94, 104, 114, 124, 134]
        }];
    const xchartOptions = {
            chart: {
                type: 'area',
                height: 250
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
                size: 0,
                hover: {
                    sizeOffset: 4
                }
            },
            toolbar: {
                show: false,
            },
            tooltip: {
                enabled: false,
                x: {
                    format: ""
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
                    format: '',
                    show: false,
                },
                type: 'numeric',
                categories: chartDetail.value.label,
            },
            yaxis: {
                labels: {
                    show: false,
                }
            },
            annotations: {
                xaxis: [
                    {
                        x: 1, //moment().unix(),
                        strokeDashArray: 1,
                        borderColor: '#018FFB',
                        label: {
                            position: 'top',
                            orientation: 'horizontal',
                            borderColor: '#018FFB',
                            style: {
                                color: '#fff',
                                background: '#018FFB',
                            },
                            text: 'Cliff',
                        }
                    },
                    {
                        x: Number(contractInfo.value.durationUnit)*Number(contractInfo.value.durationTime)/Number(contractInfo.value.unlockSchedule), //moment().unix(),
                        strokeDashArray: 1,
                        borderColor: '#018FFB',
                        label: {
                            borderColor: '#018FFB',
                            position: 'bottom', 
                            orientation: 'horizontal',
                            style: {
                                color: '#fff',
                                background: '#018FFB',
                            }, 
                            text: 'Fully vested', 
                        }
                    },
                ]
            }
        }
    onMounted(() => {
        generateChartData();
    })   
</script>
<template>
    <!-- <apexchart type="line" height="250" :options="xchartOptions" :series="xseries" v-if="chartDetail"></apexchart> -->
    <LineChart :chartData="chartData" :options="chartOptions"/>
</template>