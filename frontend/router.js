import { createRouter, createWebHistory } from 'vue-router'
import Page404 from './components/layout/404.vue'
import DashboardVue from './components/Dashboard.vue'
import Payments from './components/payment/Payments.vue'
import CreatePayment from './components/payment/CreatePayment.vue'
const router = createRouter({
  history: createWebHistory(import.meta.env.BASE_URL),
  routes: [
    {
      path: '/',
      name: 'home',
      component: DashboardVue
    },
    {
      path: '/payments',
      name: 'payments',
      component: Payments
    },
    {
      path: '/create-payment',
      name: 'create-payment',
      component: CreatePayment
    },
    { path: '/:pathMatch(.*)*', name: 'not-found', component: Page404},
  ]
})

export default router
