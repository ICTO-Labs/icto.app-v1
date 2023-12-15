<script setup>
import { RouterLink, RouterView } from 'vue-router'
import config from './config'
import { createClient } from "@connect2ic/core"
import { defaultProviders } from "@connect2ic/core/providers"
import { ConnectDialog, Connect2ICProvider } from "@connect2ic/vue"
import {
  InternetIdentity,
  PlugWallet,
  StoicWallet,
  NFID
} from "@connect2ic/core/providers"
import "@connect2ic/core/style.css"
/*
 * Import backend canister definitions
 */
import * as backend from "../src/declarations/backend"
/*
 * Import layout and default components
 */
import Header from "./components/layout/Header.vue"
import Footer from "./components/layout/Footer.vue"
import Toolbar from "./components/layout/Toolbar.vue"
import ScrollTop from "./components/ScrollTop.vue"
import Modals from "./components/Modals.vue"
const client = window.client = createClient({
  canisters: {
    backend
  },
  providers: [
    new InternetIdentity(),
    new PlugWallet(),
    // new NFID(),
    // new StoicWallet(),
  ],
  globalProviderConfig: {
    dev: true,//import.meta.env.DEV,
    host: "http://localhost:8000",//config.IC_ENDPOINT,
  },
})

</script>

<template>
  <Connect2ICProvider :client="client">
    <div class="App">
      
      <ConnectDialog />
      <!--begin::Main-->
		  <!--begin::Root-->
      <div class="d-flex flex-column flex-root">
        <!--begin::Page-->
        <div class="page d-flex flex-row flex-column-fluid">
          <!--begin::Wrapper-->
          <div class="wrapper d-flex flex-column flex-row-fluid" id="kt_wrapper">
            <Header></Header>
            <!--begin::Content-->
            <div class="content d-flex flex-column flex-column-fluid" id="kt_content">
              <Toolbar />
              <!--begin::Post-->
              <div class="post d-flex flex-column-fluid" id="kt_post">
                
              <!--begin::Container-->
              <div id="kt_content_container" class="container-xxl">
                <Modals />
                <RouterView />
							</div>
							<!--end::Container-->
                
              </div>
              <!--end::Post-->
            </div>
            <!--end::Content-->
            <Footer></Footer>
          </div>
          <!--end::Wrapper-->
        </div>
        <!--end::Page-->
      </div>
      <!--end::Root-->
      <ScrollTop />
      <!--end::Main-->
    </div>
  </Connect2ICProvider>
</template>