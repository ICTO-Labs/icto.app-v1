<script>
import { defineComponent, computed } from 'vue';
import { useProjectScore } from '@/utils/launchpad';

export default defineComponent({
    name: 'ProjectScoreComponent',
    props: {
    assessment: {
            type: Object,
            required: true,
        },
    },
    setup(props) {
        const { calculateScore } = useProjectScore();
    
        const score = computed(() => calculateScore(props.assessment));
        
        const gaugeStyle = computed(() => {
        const rotation = score.value * 1.8; // 180 degrees = 100%
        return {
                transform: `rotate(${rotation}deg)`
            };
        });

        const needleStyle = computed(() => {
        const rotation = score.value * 1.8 - 90; // -90 to adjust starting position
            return {
                transform: `translateX(-50%) rotate(${rotation}deg)`
            };
        });

        const scoreLabel = computed(() => {
            if (score.value >= 80) return 'Excellent';
            if (score.value >= 60) return 'Good';
            if (score.value >= 40) return 'Neutral';
            if (score.value >= 20) return 'Risky';
            return 'High Risk';
        });

        return {
            score,
            gaugeStyle,
            needleStyle,
            scoreLabel,
        };
    },
});
</script>
<template>
    <div class="project-score">
        <div class="gauge">
            <div class="gauge-body">
                <div class="gauge-fill" :style="gaugeStyle"></div>
                <div class="gauge-cover">
                <div class="gauge-value">{{ Math.round(score) }}</div>
                <div class="gauge-label">{{ scoreLabel }}</div>
                </div>
                <div class="gauge-needle" :style="needleStyle"></div>
            </div>
        </div>
    </div>
</template>
<style scoped>
    .project-score {
        font-family: Arial, sans-serif;
    }

    .gauge {
        width: 200px;
        height: 100px;
        position: relative;
        margin: auto;
    }

    .gauge-body {
        width: 100%;
        height: 0;
        padding-bottom: 50%;
        background: #e6e6e6;
        position: relative;
        border-top-left-radius: 100% 200%;
        border-top-right-radius: 100% 200%;
        overflow: hidden;
    }

    .gauge-fill {
        position: absolute;
        top: 100%;
        left: 0;
        width: 100%;
        height: 100%;
        background: linear-gradient(to right, #ff4e50, #f9d423, #4CAF50);
        transform-origin: center top;
        transform: rotate(0deg);
        transition: transform 0.2s ease-out;
    }

    .gauge-cover {
        width: 75%;
        height: 150%;
        background: #ffffff;
        border-radius: 50%;
        position: absolute;
        top: 25%;
        left: 50%;
        transform: translateX(-50%);
        display: flex;
        flex-direction: column;
        align-items: center;
        justify-content: center;
        padding-bottom: 25%;
        box-sizing: border-box;
    }

    .gauge-value {
        font-size: 25px;
        font-weight: bold;
        margin-top: -10px;
    }

    .gauge-label {
        font-size: 14px;
        color: #666;
        margin-top: 0px;
    }

    .gauge-labels {
        display: flex;
        justify-content: space-between;
        padding: 0 0px;
        margin-top: 5px;
    }

    .gauge-label-min, .gauge-label-max {
        font-size: 14px;
        color: #666;
    }
</style>