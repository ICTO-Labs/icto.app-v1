
<script>
import VueCountdown from '@chenfengyuan/vue-countdown';
import moment from 'moment';
export default {
    name: 'NotificationBar',
    components: {
        VueCountdown
    },
    props: {
        message: {
            type: String,
            default: ''
        },
        useHtml: {
            type: Boolean,
            default: false
        },
        type: {
            type: String,
            default: 'info',
            validator: value => ['info', 'success', 'warning', 'error'].includes(value)
        },
        dismissible: {
            type: Boolean,
            default: true
        },
        duration: {
            type: Number,
            default: 0
        }
    },
    data() {
        return {
            visible: true,
            countdown: moment("2025-01-12 08:45").diff(moment())
        }
    },
    mounted() {
        if (this.duration > 0) {
            setTimeout(() => {
                this.dismiss()
            }, this.duration)
        }
    },
    methods: {
        dismiss() {
            this.visible = false
            this.$emit('dismiss')
        },
        onCountdownEnd(){
            this.visible = false;
            console.log('Countdown end');
        }
    }
}
</script>

<template>
    <div v-if="visible" class="notification-bar" :class="type">
        <div class="notification-content">
            <div v-if="useHtml" class="message">
                <span v-html="message"></span>
                <vue-countdown :time="countdown" @end="onCountdownEnd" v-slot="{ days, hours, minutes, seconds }">
                    <span class="hide-on-mobile">Remaining: {{ days }} days, {{ hours }} hours, {{ minutes }} minutes, {{ seconds }} seconds</span>
                </vue-countdown>
            </div>
            <slot v-else>{{ message }}</slot>
            <button v-if="dismissible" class="close-button" @click="dismiss">
                ×
            </button>
        </div>
    </div>
</template>

<style scoped>
.notification-bar {
    width: 100%;
    padding: 5px;
    transition: all 0.3s ease;
}

.notification-content {
    max-width: 1200px;
    margin: 0 auto;
    display: flex;
    justify-content: space-between;
    align-items: center;
}

.message :deep(a) {
    color: inherit;
    text-decoration: underline;
}

.message :deep(a:hover) {
    opacity: 0.8;
}

.close-button {
    background: transparent;
    border: none;
    color: inherit;
    cursor: pointer;
    font-size: 20px;
    padding: 0 8px;
    margin-left: 16px;
}

/* Notification types */
.info {
    background-color: #2196F3;
    color: white;
}

.success {
    background-color: #4CAF50;
    color: white;
}

.warning {
    background-color: #FFC107;
    color: black;
}

.error {
    background-color: #F44336;
    color: white;
}
@media screen and (max-width: 768px) {
    .hide-on-mobile {
        display: none;
    }
}
</style>