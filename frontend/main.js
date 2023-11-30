import { createApp } from "vue"
import Vue3Toasity from 'vue3-toastify'
import 'vue3-toastify/dist/index.css'
import VueSweetalert2 from 'vue-sweetalert2'
import 'sweetalert2/dist/sweetalert2.min.css'

import { createVfm } from 'vue-final-modal'
import 'vue-final-modal/style.css'
import { createPinia } from 'pinia'

import router from './router.js'
import App from "./App.vue"
const app = createApp(App)
const vfm = createVfm()
const pinia = createPinia()

app.use(router)
app.use(Vue3Toasity)
app.use(VueSweetalert2)
window.Swal =  app.config.globalProperties.$swal

app.use(pinia)
app.use(vfm)

app.mount("#root")
