<script setup>
import { RouterLink, RouterView } from 'vue-router'
import Header from "./components/layout/Header.vue"
import Footer from "./components/layout/Footer.vue"
import Toolbar from "./components/layout/Toolbar.vue"
import ScrollTop from "./components/ScrollTop.vue"
import Modals from "./components/Modals.vue"
import Popup from "./components/Popup.vue"
import Wallet from "./components/Wallet.vue"
import WalletManager from "@/services/WalletManager";

WalletManager.checkLoginStatus();
</script>

<template>
      <ConnectDialog />
      <!--begin::Main-->
      <div class="d-flex flex-column flex-root">
        <!--begin::Page-->
        <div class="page d-flex flex-row flex-column-fluid">
          <!--begin::Wrapper-->
          <div class="wrapper d-flex flex-column flex-row-fluid" id="kt_wrapper">
            <Header></Header>
            <!--begin::Content-->
            <div class="content d-flex flex-column flex-column-fluid" id="kt_content">
              <!--begin::Post-->
              <div class="post d-flex flex-column-fluid" id="kt_post">
                <!--begin::Container-->
                <div id="kt_content_container" class="container-xxl">
                  <RouterView />
                </div>
                <Popup />
                <!--end::Container-->
              </div>
              <!--end::Post-->
            </div>
            <Modals />
            <!--end::Content-->
            <Wallet />
            <Footer></Footer>
          </div>
          <!--end::Wrapper-->
        </div>
        <!--end::Page-->
      </div>
      <!--end::Root-->
      <ScrollTop />
      <!--end::Main-->
</template>