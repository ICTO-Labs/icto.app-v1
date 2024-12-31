<script setup>
    import { ref, watch } from 'vue';
    import { timeFromNano } from '@/utils/common';
    const props = defineProps(['status', 'timeline']);
    const status = ref(props.status);
    const timeline = ref(props.timeline);
    watch(() => [props.status, props.timeline], ([newStatus, newTimeline]) => {
        console.log('newStatus', newStatus);
        status.value = newStatus;
        timeline.value = newTimeline;
    });
</script>
<template>
    <div class="timeline-label" v-if="status && timeline"> 
        <!-- Waiting for pool start -->
        <div class="timeline-item">
            <div class="timeline-label fw-bolder text-gray-800 fs-6 text-end pe-5">
                <i :class="status == 'UPCOMING' ? 'fa fa-caret-right text-success fs-4' : ''"></i>
            </div>
            <div class="timeline-badge">
                <i class="fa fa-check-circle text-success fs-4"></i>
            </div>
            <div class="fw-bolder timeline-content text-success">
                <span class="fw-bolder ps-3">Preperation</span>
                <div class="fw-normal justify-content-between p-1 ps-3">
                    DYOR before pool start
                </div>
            </div>
        </div>

        <!-- Pool started -->
        <div class="timeline-item">
            <div class="timeline-label fw-bolder text-gray-800 fs-6 text-end pe-5">
                <i :class="status == 'LIVE' ? 'fa fa-caret-right text-success fs-4' : ''"></i>
            </div>
            <div class="timeline-badge">
                <i :class="['LIVE', 'FINISHED', 'CLAIMING', 'REFUNDING'].includes(status) ? 'fa fa-check-circle text-success fs-4' : 'fa fa-circle text-muted fs-4'"></i>
            </div>
            <div class="timeline-content" :class="['LIVE', 'FINISHED', 'CLAIMING', 'REFUNDING'].includes(status) ? 'text-success' : 'text-muted'">
                <span class="fw-bolder ps-3">Pool Start</span>
                <div class="fw-normal justify-content-between p-1 ps-3">
                    Pool start at <span class="badge badge-light-danger fs-8 fw-bold">{{timeFromNano(timeline.startTime)}}</span>
                </div>
            </div>
        </div>

        <!-- Pool end -->
        <div class="timeline-item">
            <div class="timeline-label fw-bolder text-gray-800 fs-6 text-end pe-5">
                <i :class="status == 'FINISHED' ? 'fa fa-caret-right text-success fs-4' : ''"></i>
            </div>
            <div class="timeline-badge">
                <i :class="['FINISHED', 'CLAIMING', 'REFUNDING'].includes(status) ? 'fa fa-check-circle text-success fs-4' : 'fa fa-circle text-muted fs-4'"></i>
            </div>
            <div class="timeline-content fw-bolder" :class="['FINISHED', 'CLAIMING', 'REFUNDING'].includes(status) ? 'text-success' : 'text-muted'">
                <span class="fw-bolder ps-3">Pool End</span>
                <div class="fw-normal justify-content-between p-1 ps-3">
                    Pool end at <span class="badge badge-light-danger fs-8 fw-bold">{{timeFromNano(timeline.endTime)}}</span>
                </div>
            </div>
        </div>

        <!-- Claim tokens -->
        <div class="timeline-item">
            <div class="timeline-label fw-bolder text-gray-800 fs-6 text-end pe-5">
                <i :class="status == 'CLAIMING' || status == 'REFUNDING' ? 'fa fa-caret-right text-success fs-4' : ''"></i>
            </div>
            <div class="timeline-badge">
                <i :class="status === 'CLAIMING' || status === 'REFUNDING' ? 'fa fa-check-circle text-success fs-4' : 'fa fa-circle text-muted fs-4'"></i>
            </div>
            <div class="timeline-content fw-bolder" :class="status === 'CLAIMING' || status === 'REFUNDING' ? 'text-success' : 'text-muted'">
                <span class="fw-bolder ps-3">{{status === 'REFUNDING' ? 'Refund Tokens' : 'Claim Tokens'}}</span>
                <div class="fw-normal justify-content-between p-1 ps-3">
                    {{status === 'REFUNDING' ? 'Refund at' : 'Claim at'}} <span class="badge badge-light-danger fs-8 fw-bold">{{timeFromNano(timeline.claimTime)}}</span>
                </div>
            </div>
        </div>
    </div>
</template>