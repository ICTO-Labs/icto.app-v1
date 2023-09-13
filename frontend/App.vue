<script setup>
/*
 * Connect2ic provides essential utilities for IC app development
 */
 import { RouterLink, RouterView } from 'vue-router'

import { createClient } from "@connect2ic/core"
import { defaultProviders } from "@connect2ic/core/providers"
import { ConnectDialog, Connect2ICProvider } from "@connect2ic/vue"
import "@connect2ic/core/style.css"
/*
 * Import backend canister definitions
 */
import * as backend from "../.dfx/local/canisters/backend"
/*
 * Import layout and default components
 */
import Dashboard from "./components/Dashboard.vue"
import Header from "./components/layout/Header.vue"
import Footer from "./components/layout/Footer.vue"
import Toolbar from "./components/layout/Toolbar.vue"
import ScrollTop from "./components/ScrollTop.vue"
import Modals from "./components/Modals.vue"
const client = createClient({
  canisters: {
    backend,
  },
  providers: defaultProviders,
  globalProviderConfig: {
    dev: true,//import.meta.env.DEV,
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
                <RouterView />
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
		  <Modals />
      <ScrollTop />
      <!--end::Main-->
    </div>
  </Connect2ICProvider>
</template>