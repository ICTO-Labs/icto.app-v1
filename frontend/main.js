import { createApp } from "vue"
import Vue3Toasity from 'vue3-toastify'
import { toast } from 'vue3-toastify';
import 'vue3-toastify/dist/index.css'
import VueSweetalert2 from 'vue-sweetalert2'
import 'sweetalert2/dist/sweetalert2.min.css'

import { createVfm } from 'vue-final-modal'
import 'vue-final-modal/style.css'

import VueDatePicker from '@vuepic/vue-datepicker';
import '@vuepic/vue-datepicker/dist/main.css'

import { createPinia } from 'pinia'
import { VueQueryPlugin } from "@tanstack/vue-query";

import router from './router.js'
import App from "./App.vue"
const app = createApp(App)
const vfm = createVfm()
const pinia = createPinia()

app.use(router)
app.use(Vue3Toasity, {
    multiple: false,
    position: toast.POSITION.BOTTOM_RIGHT,
    hideProgressBar: true,
    theme: 'colored'
})
app.use(VueSweetalert2)
window.Swal =  app.config.globalProperties.$swal
app.use(pinia)
app.use(vfm)
app.component('VueDatePicker', VueDatePicker);
app.use(VueQueryPlugin)
app.mount("#root")
