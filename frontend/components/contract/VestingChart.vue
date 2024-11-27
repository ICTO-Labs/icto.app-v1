<script setup>
    import { ref, watch, computed, onMounted } from "vue";
    import { LineChart } from "vue-chart-3";
    import { Chart, registerables } from "chart.js";
    import chartjsPluginAnnotation from "chartjs-plugin-annotation";
    import moment from "moment";
    Chart.register(...registerables, chartjsPluginAnnotation);

    const props = defineProps(['contractInfo', 'isChanged']);
    const contractInfo = computed(() => props.contractInfo);

    const lineChartLabel = ref([]);
    const lineChartData = ref([]);
    const chartData = ref({});
    const chartOptions = ref({});
    const {
            durationTime,
            durationUnit,
            cliffTime,
            cliffUnit,
            unlockSchedule,
        } = contractInfo.value;
    const initialUnlockPercentage = 30;
    const totalAmount = 10000000;
    
        
    const generateLabels = () => {
        const { durationTime, durationUnit, unlockSchedule } = contractInfo.value;

        // Total duration in seconds
        const totalDurationInSeconds = durationTime * durationUnit;

        // Number of blocks
        const vestingType = durationTime*durationUnit === unlockSchedule ? 'single' : 'step';
        const numSteps = Math.floor(durationTime*durationUnit/ (vestingType == 'single'?durationTime:unlockSchedule));
        const totalBlocks = Math.floor(totalDurationInSeconds / (vestingType == 'single'?durationTime:unlockSchedule));

        // Map time units
        const units = {
            86400: "days",
            604800: "weeks",
            2628002: "months",
            7884006: "quarters",
            31536000: "years",
        };
        const startTime = new Date();

        const timeUnit = units[unlockSchedule] || "days";

        // Create time labels increasing from startTime
        const startDate = moment(startTime); // startTime is passed in
        lineChartLabel.value = Array.from({ length: totalBlocks }, (_, i) =>
            startDate.clone().add(i, timeUnit).format("hh:mm MM-DD-YYYY ") // Format time as needed
        );
        // Map time units
        // const units = {
        //     86400: "Day",
        //     604800: "Week",
        //     2628002: "Month",
        //     7884006: "Quarter",
        //     31536000: "Year",
        // };
        // const unitLabel = units[unlockSchedule] || "Day";

        // // Create labels based on block number
        // lineChartLabel.value = Array.from({ length: totalBlocks}, (_, i) => `${unitLabel} ${i + 1}`);
    };

    // Function to calculate the vesting schedule based on blocks
    const calculateUnlockSchedule = () => {
        const {
            durationTime,
            durationUnit,
            cliffTime,
            cliffUnit,
            unlockSchedule,
        } = contractInfo.value;
        // Total duration in seconds
        const totalDurationInSeconds = durationTime * durationUnit;

        // Number of blocks
        const vestingType = durationTime*durationUnit === unlockSchedule ? 'single' : 'step';
        // const totalBlocks = Math.floor(totalDurationInSeconds / (vestingType == 'single'?durationTime:unlockSchedule));

        // Cliff time in seconds
        const cliffTimeInSeconds = durationTime * cliffUnit;
        const cliffBlocks = Math.ceil(cliffTimeInSeconds / unlockSchedule);

        // Total number of blocks (including cliff)
        const vestingBlocks = Math.floor(totalDurationInSeconds / (vestingType == 'single'?durationTime:unlockSchedule));
        const totalBlocks = vestingBlocks + cliffBlocks;

        
        // Calculate the unlock value
        const unlocks = [];
        const initialUnlock = (initialUnlockPercentage / 100) * totalAmount;
        const remainingAmount = totalAmount - initialUnlock;
        const perUnlock = remainingAmount / (totalBlocks - cliffBlocks);
        console.log('perUnlock', perUnlock, totalBlocks, cliffBlocks)
        for (let i = 0; i < totalBlocks; i++) {
            if (i < cliffBlocks) {
                unlocks.push(initialUnlock); // During cliff
            } else {
                if(vestingType == 'single'){
                    if(i == totalBlocks-1){
                        unlocks.push(totalAmount);
                    }else{
                        unlocks.push(0);
                    }
                }else{
                    unlocks.push(
                        Math.min(totalAmount, initialUnlock + (i - cliffBlocks + 1) * perUnlock)
                    );
                }
            }
        }

        lineChartData.value = unlocks;
    };

    // Update `chartData` and `chartOptions`
    const updateChart = () => {
        chartData.value = {
            labels: lineChartLabel.value,
            datasets: [
                {
                    data: lineChartData.value,
                    backgroundColor: ['#77CEFF', '#ccc'],
                    borderColor: '#018FFB',
                    fill: true,
                    stepped: true,
                    pointStyle: 'circle',
                    pointRadius: 0,
                    pointHoverRadius: 0,
                    spanGaps: true,
                },
            ],
        };

        chartOptions.value = {
            responsive: true,
            plugins: {
                tooltip: {
                    mode: 'index',
                    intersect: false,
                },
                legend: {
                    display: false,
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
                                display: false,
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
                                    size: (ctx) => ctx.chart.chartArea.height / 10,
                                },
                                position: 'center',
                            },
                        },
                    },
                },
            },
            hover: {
                mode: 'index',
                intersect: false,
            },
        };
    };

    // Watch for changes and update the chart
    watch(contractInfo, () => {
        generateLabels();
        calculateUnlockSchedule();
        updateChart();
        console.log('lineChartLabel', lineChartLabel.value);
        console.log('lineChartData', lineChartData.value);
    }, { deep: true });

    onMounted(() => {
        generateLabels();
        calculateUnlockSchedule();
        updateChart();
    })
</script>

<template>
    <LineChart :chartData="chartData" :options="chartOptions" />
</template>
