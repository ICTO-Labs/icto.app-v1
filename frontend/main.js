import { createApp } from "vue"
// import Vue3Toasity from 'vue3-toastify'
// import { toast } from 'vue3-toastify';
// import 'vue3-toastify/dist/index.css'

import Toast, { POSITION } from "vue-toastification";
import "vue-toastification/dist/index.css";

import VueSweetalert2 from 'vue-sweetalert2'
import 'sweetalert2/dist/sweetalert2.min.css'

import { createVfm } from 'vue-final-modal'
import 'vue-final-modal/style.css'

import VueDatePicker from '@vuepic/vue-datepicker';
import '@vuepic/vue-datepicker/dist/main.css'

import { createPinia } from 'pinia'
import { VueQueryPlugin } from "@tanstack/vue-query";
import VueApexCharts from "vue3-apexcharts";

import router from './router.js'
import App from "./App.vue"

import ClickToCopy from '@/components/ClickToCopy.vue';
import Copy from '@/components/icons/Copy.vue'
import ICP from '@/components/icons/ICP.vue'
import ICPValue from '@/components/icons/ICPValue.vue'
import Spinner from '@/components/icons/Spinner.vue'
import Verified from '@/components/icons/Verified.vue'
import Empty from '@/components/layout/Empty.vue'
import Toolbar from '@/components/layout/Toolbar.vue'

const app = createApp(App)
const vfm = createVfm()
const pinia = createPinia()

app.use(router)
app.use(Toast, {
    shareAppContext: true,
    multiple: true,
    maxToasts: 2,
    position: POSITION.BOTTOM_LEFT,
    hideProgressBar: true,
    theme: 'colored'
})
app.use(VueSweetalert2)
window.Swal =  app.config.globalProperties.$swal
app.use(pinia)
app.use(vfm)
app.use(VueApexCharts);
app.component('ClickToCopy', ClickToCopy);
app.component('Copy', Copy);
app.component('ICP', ICP);
app.component('ICPValue', ICPValue);
app.component('Spinner', Spinner);
app.component('Verified', Verified);
app.component('Toolbar', Toolbar);
app.component('Empty', Empty);
app.component('VueDatePicker', VueDatePicker);
app.use(VueQueryPlugin)
app.mount("#root")
