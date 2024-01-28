import { createRouter, createWebHistory } from 'vue-router'
import Page404 from './components/layout/404.vue'
import Dashboard from './views/Dashboard.vue'
import Contract from './views/contract/Contract.vue'
import NewContract from './views/contract/NewContract.vue'
import MyToken from './views/token/MyToken.vue'
import TokenDetail from './views/token/TokenDetail.vue'
import ContractDetail from './views/contract/ContractDetail.vue'
import Launchpad from './views/launchpad/Launchpad.vue'
import NewLaunchpad from './views/launchpad/NewLaunchpad.vue'
import Marketplace from './views/marketplace/Marketplace.vue'
import CollectionDetail from './views/marketplace/Collection.vue'
import ItemDetail from './views/marketplace/Item.vue'
import LocksIndex from './views/tokenlocks/Index.vue'
import LiquidityLocks from './views/tokenlocks/Liquidity.vue'
import OverviewLocks from './views/tokenlocks/Overview.vue'
import TokenLocks from './views/tokenlocks/Token.vue'
import NftLocks from './views/tokenlocks/Nft.vue'
const router = createRouter({
  history: createWebHistory(import.meta.env.BASE_URL),
  routes: [
    {
      path: '/',
      name: 'home',
      meta: {title: 'Home'},
      component: Dashboard
    },
    {
      path: '/payments',
      meta: {title: 'Payments'},
      name: 'contract',
      component: Contract,
    },
    {
      path: '/launchpad',
      meta: {title: 'Launchpad'},
      name: 'launchpad',
      component: Launchpad,
    },
    {
      path: '/new-launchpad',
      meta: {title: 'New Launchpad'},
      name: 'new-launchpad',
      component: NewLaunchpad,
    },
    {
      path: '/marketplace',
      meta: {title: 'Marketplace'},
      name: 'marketplace',
      component: Marketplace,
    },
    {
      path: '/marketplace/:canisterId',
      meta: {title: 'Collection'},
      name: 'collection-detail',
      component: CollectionDetail,
    },
    {
      path: '/marketplace/:canisterId/:itemId',
      meta: {title: 'Item'},
      name: 'item-detail',
      component: ItemDetail,
    },
    {
      path: '/vesting',
      meta: {title: 'Vesting'},
      name: 'vesting',
      component: Contract,
    },
    {
      path: '/token-locks',
      meta: {title: 'Token Locks'},
      name: 'token-locks',
      component: LocksIndex,
      children: [
        { path: 'liquidity', component: LiquidityLocks, name: 'Liquidity'},
        { path: 'token', component: TokenLocks, name: 'Token'},
        { path: 'nft', component: NftLocks, name: 'Nft'},
      ],
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
      meta: {title: 'Contract Details', navs: [{title: 'Payments', to: '/payments'}]},
      name: 'contract-detail',
      component: ContractDetail
    },
    { path: '/:pathMatch(.*)*', name: 'not-found',  meta: {title: 'Not Found'}, component: Page404},
  ]
})
const DEFAULT_TITLE = " | ICTO";

router.afterEach((to, from) => {
  document.title = to.meta.title + DEFAULT_TITLE;
});
export default router
