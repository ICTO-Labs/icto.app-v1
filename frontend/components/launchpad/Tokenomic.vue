<script setup>
    import { ref, watch, onMounted } from "vue";
    import {PieChart} from "vue-chart-3";
    import {Chart,registerables} from "chart.js";
    import chartjsPluginOutlabels from "@energiency/chartjs-plugin-piechart-outlabels";
    Chart.register(...registerables, chartjsPluginOutlabels);
    const props = defineProps(['data', 'legend']);
    console.log('props', props.data);
    const chartData = ref(props.data);//Key, value pair
    watch(() => [props.data, props.legend], ([newData, newTimeline]) => {
        console.log('newStatus', newData);
        chartData.value = newData;
        generateChartData();
    });

    //Extract key/value to two arrays
    const _labels = ref([]);
    const _data = ref([]);

    
    const generateChartData = () => {
        _labels.value = [];
        _data.value = [];
        for (const allocate of chartData.value) {
            _labels.value.push(allocate.title);
            _data.value.push(allocate.value);
        }
    }
    //Initial data
    generateChartData();

    const data = ref({
        labels: _labels,//['Fairlaunch', 'DEXs listing', 'Incentives', 'Marketing ', 'Team & Dev'],
        datasets: [{
            data: _data,//[20, 61, 5, 5, 9],
        }]
    });
    const options = ref({
        responsive: true,
        maintainAspectRatio: false,
        zoomOutPercentage: 55,
        plugins: {
            legend: {
                display: props.legend==1?true:false,
                position: "right",
                labels: {
                }
            },
            outlabels: {
                padding: {
                    top: 0,
                    bottom: 0,
                    left: 4,
                    right: 4
                },
                text: '%l: %p',
                color: 'white',
                stretch: 30,
                textAlign: 'bottom',
                font: {
                    resizable: true,
                    minSize: 12,
                    maxSize: 18,
                    lineHeight: 2,
                },
            }
        },
        layout: {
            padding: 100
        }
    });
</script>
<template>
    <div>
        <PieChart :chartData="data" :options="options" />
    </div>
</template>
