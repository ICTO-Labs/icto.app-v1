import { createRouter, createWebHistory } from 'vue-router'
import Page404 from './components/layout/404.vue'
import Dashboard from './views/Dashboard.vue'
import Contract from './views/contract/Contract.vue'
import NewContract from './views/contract/NewContract.vue'
import Tokens from './views/token/Index.vue'
import TokenDetail from './views/token/TokenDetail.vue'
import ContractDetail from './views/contract/ContractDetail.vue'
import Launchpad from './views/launchpad/Launchpad.vue'
import Create from './views/launchpad/Create.vue'
import LaunchpadDetail from './views/launchpad/LaunchpadDetail/index.vue'
import Marketplace from './views/marketplace/Marketplace.vue'
import CollectionDetail from './views/marketplace/Collection.vue'
import ItemDetail from './views/marketplace/Item.vue'
import LocksIndex from './views/tokenlocks/Index.vue'
import LiquidityLocks from './views/tokenlocks/liquidity/Index.vue'
import LiquidityDetail from './views/tokenlocks/liquidity/Detail.vue'
import TokenLocks from './views/tokenlocks/Token.vue'
import NftLocks from './views/tokenlocks/Nft.vue'

import Airdrop from './views/airdrop/Index.vue';
import AirdropDetail from './views/airdrop/Detail.vue';
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
      path: '/token-claim',
      meta: {title: 'Token Claims'},
      name: 'token-claim',
      component: Contract,
    },
    {
      path: '/token-claim/create',
      meta: {title: 'New Contract'},
      name: 'new-contract',
      component: NewContract
    },
    {
      path: '/launchpad',
      meta: {title: 'Launchpad'},
      name: 'launchpad',
      component: Launchpad,
    },
    {
      path: '/launchpad/create',
      meta: {title: 'Create Fairlaunch'},
      name: 'create-fairlaunch',
      component: Create,
    },
    {
      path: '/launchpad/:launchpadId',
      meta: {title: 'Launchpad Detail'},
      name: 'launchpad-detail',
      component: LaunchpadDetail,
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
      path: '/locks',
      meta: {title: 'Locks'},
      name: 'locks',
      component: LocksIndex,
      children: [
        { path: 'liquidity', component: LiquidityLocks, name: 'Liquidity'},
        { path: 'liquidity/:contractId', component: LiquidityDetail, name: 'LiquidityDetail'},
        { path: 'token', component: TokenLocks, name: 'Token'},
        { path: 'nft', component: NftLocks, name: 'Nft'},
      ],
    },
    {
      path: '/tokens',
      meta: {title: 'Tokens'},
      name: 'tokens',
      component: Tokens
    },
    {
      path: '/airdrop',
      meta: {title: 'Airdrop'},
      children: [
        { path: '', component: Airdrop, name: 'Airdrop' },
        { path: ':airdropId', component: AirdropDetail, name: 'AirdropDetail'},
      ],
    },
    {
      path: '/token/:tokenId',
      meta: {title: 'Token Detail'},
      name: 'token-detail',
      component: TokenDetail
    },
    {
      path: '/token-claim/:contractId',
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
