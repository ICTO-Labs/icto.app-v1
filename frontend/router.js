import { createRouter, createWebHistory } from 'vue-router'
import DashboardVue from './components/Dashboard.vue'
const router = createRouter({
  history: createWebHistory(import.meta.env.BASE_URL),
  routes: [
    {
      path: '/',
      name: 'home',
      component: DashboardVue
    },
    { path: '/:pathMatch(.*)*', name: 'not-found', component: { template: '<div>Notfound!</div>'}},
  ]
})

export default router
