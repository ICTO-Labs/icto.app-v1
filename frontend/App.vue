<script setup>
import { RouterLink, RouterView } from 'vue-router'
import config from './config'
import { storeToRefs } from "pinia";
import { useAuthStore } from "@/store/auth";
import Header from "./components/layout/Header.vue"
import Footer from "./components/layout/Footer.vue"
import Toolbar from "./components/layout/Toolbar.vue"
import ScrollTop from "./components/ScrollTop.vue"
import Modals from "./components/Modals.vue"

const authStore = useAuthStore();
const { isReady, isAuthenticated } = storeToRefs(authStore);

if (isReady.value === false) {
  authStore.init();
}
</script>

<template>
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
</template>