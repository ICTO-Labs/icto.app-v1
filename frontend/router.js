import { createRouter, createWebHistory } from 'vue-router'
import Page404 from './components/layout/404.vue'
import DashboardVue from './components/Dashboard.vue'
import Payments from './components/contract/Payments.vue'
import NewContract from './views/contract/NewContract.vue'
import MyToken from './views/token/MyToken.vue'
import TokenDetail from './views/token/TokenDetail.vue'
import ContractDetail from './views/contract/ContractDetail.vue'
const router = createRouter({
  history: createWebHistory(import.meta.env.BASE_URL),
  routes: [
    {
      path: '/',
      name: 'home',
      meta: {title: 'Home'},
      component: DashboardVue
    },
    {
      path: '/contract',
      title: 'Contract',
      name: 'contract',
      component: Payments
    },
    {
      path: '/new-contract',
      meta: {title: 'New Contract'},
      name: 'new-contract',
      component: NewContract
    },
    {
      path: '/my-token',
      meta: {title: 'My Tokens'},
      name: 'my-token',
      component: MyToken
    },
    {
      path: '/token/:tokenId',
      meta: {title: 'Token Detail'},
      name: 'token-detail',
      component: TokenDetail
    },
    {
      path: '/contract/:contractId',
      meta: {title: 'Contract Detail Detail'},
      name: 'contract-detail',
      component: ContractDetail
    },
    { path: '/:pathMatch(.*)*', name: 'not-found',  meta: {title: 'Not Found'}, component: Page404},
  ]
})

export default router
