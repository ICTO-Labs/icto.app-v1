import { createRouter, createWebHistory } from 'vue-router'
import Page404 from './components/layout/404.vue'
import DashboardVue from './components/Dashboard.vue'
import Payments from './components/contract/Payments.vue'
import NewContract from './components/contract/NewContract.vue'
import ContractDetail from './components/contract/ContractDetail.vue'
const router = createRouter({
  history: createWebHistory(import.meta.env.BASE_URL),
  routes: [
    {
      path: '/',
      name: 'home',
      component: DashboardVue
    },
    {
      path: '/contract',
      name: 'contract',
      component: Payments
    },
    {
      path: '/new-contract',
      name: 'new-contract',
      component: NewContract
    },
    {
      path: '/contract/:contract_id',
      name: 'contract-detail',
      component: ContractDetail
    },
    { path: '/:pathMatch(.*)*', name: 'not-found', component: Page404},
  ]
})

export default router
