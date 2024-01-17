<script setup>
    import { onMounted, ref } from "vue";
    import EventBus from "@/services/EventBus";
    import walletStore from "@/store";
    import { shortPrincipal, shortAccount } from '@/utils/common';
	import { useAssetStore } from "@/store/token";
	const storeAssets = useAssetStore();

    const openWallet = ref(false);
    onMounted(() => {
        EventBus.on("showWalletModal", (status) =>{
            console.log('ok')
            openWallet.value = status;
        });
    });
    const closeWallet = ()=>{
        openWallet.value = false;
    }
    const importToken = ()=>{
		EventBus.emit("showImportTokenModal", true)
	}
    const logout = ()=>{
        Swal.fire({
            title: "Are you sure?",
            text: "Logout and delete this session!",
            icon: "warning",
            showCancelButton: true,
            confirmButtonColor: "#3085d6",
            cancelButtonColor: "#d33",
            confirmButtonText: "Yes, log me out!"
            }).then(async (result) => {
                if(result.isConfirmed){
                    await walletStore.logout()
                }
            });
    }
</script>
<template>
<div :class="`bg-body drawer drawer-end ${openWallet?'drawer-on':''} wallet-modal`">
  <div class="card shadow-none rounded-0 w-100">
    <!--begin::Header-->
    <div class="card-header">
        <h3 class="card-title align-items-start flex-column">
            <span class="fw-bolder mb-2 text-primary"><i class="fas fa-wallet text-primary me-2"></i> My Wallet</span>
            <span class="text-muted fw-bold fs-7">Connected: {{walletStore?.account?.name}} <span class="badge badge-success fw-bolder fs-8 px-2 py-1 ms-2">{{ walletStore.connector }}</span></span>
        </h3>

      <div class="card-toolbar">
        <button type="button" class="btn btn-sm btn-icon btn-active-light-primary me-n5" id="kt_activities_close" @click="closeWallet">
          <span class="svg-icon svg-icon-1">
            <svg xmlns="http://www.w3.org/2000/svg" width="24" height="24" viewBox="0 0 24 24" fill="none">
              <rect opacity="0.5" x="6" y="17.3137" width="16" height="2" rx="1" transform="rotate(-45 6 17.3137)" fill="black"></rect>
              <rect x="7.41422" y="6" width="16" height="2" rx="1" transform="rotate(45 7.41422 6)" fill="black"></rect>
            </svg>
          </span>
        </button>
      </div>
    </div>
    <div class="p-2 position-relative">
      <!--begin::Content-->
      <div id="kt_activities_scroll" class="position-relative scroll-y me-n5 pe-5">
        <div class="menu-item px-3">
          <div class="menu-content d-flex align-items-center px-3" v-show="walletStore.isLogged">
            <!--begin::Avatar-->
            <div class="symbol symbol-circle bg-light-primary symbol-60px me-5">
              <img alt="Logo" :src="`/partner/${walletStore.connector}.png`" />
            </div>
            <!--end::Avatar-->
            <div class="d-flex flex-column">
                <div class="mb-1">       
						<div class="fw-semibold text-gray-600 fs-7">Principal ID:</div> 
						<div class="fw-bold text-gray-800 fs-6">
                            <ClickToCopy :text="walletStore.principal">{{ walletStore.principal }}</ClickToCopy>
                            </div>          
					</div>
                <div class="mb-1">       
                    <div class="fw-semibold text-gray-600 fs-7">Address ID:</div> 
                    <div class="fw-bold text-gray-800 fs-6">
                        <ClickToCopy :text="walletStore.address">{{ walletStore.address }}</ClickToCopy>
                    </div>       
                </div>
            </div>
          </div>
          <ul class="nav nav-tabs nav-line-tabs nav-line-tabs-2x mb-5 fs-5 fw-bold">
            <li class="nav-item">
              <a class="nav-link active" data-bs-toggle="tab" href="#wallet_tokens">Tokens</a>
            </li>
            <li class="nav-item">
              <a class="nav-link" data-bs-toggle="tab" href="#wallet_nfts">NFTs</a>
            </li>
            <li class="nav-item">
              <a class="nav-link" data-bs-toggle="tab" href="#wallet_airdrops">Airdrops</a>
            </li>
          </ul>
          <div class="tab-content" id="icto_wallet">
            <div class="tab-pane fade active show" id="wallet_tokens" role="tabpanel">
                <div class="py-1">
                  <!--begin::Table container-->
                  <div class="table-responsive">
                    <!--begin::Table-->
                    <table class="table table-row-dashed table-row-gray-300 align-middle gs-0 gy-4">
                      <!--begin::Table head-->
                      <thead>
                        <tr class="fw-bolder text-muted">
                          <th class="min-w-150px">Token</th>
                          <th class="min-w-140px">Balance</th>
                          <th class="min-w-120px">Price</th>
                          <th class="min-w-100px text-end">Actions</th>
                        </tr>
                      </thead>
                      <!--end::Table head-->
                      <!--begin::Table body-->
                      <tbody>
                        <tr>
                          <td>
                            <div class="d-flex align-items-center">
                              <div class="symbol symbol-45px me-5 symbol-circle">
                                <img src="https://app.icpswap.com/static/media/icp.971d3265d25976274074de359ddc638b.svg" alt="">
                              </div>
                              <div class="d-flex justify-content-start flex-column">
                                <a href="#" class="text-dark fw-bolder text-hover-primary fs-6">Internet Computer (ICP)</a>
                                <span class="text-muted fw-bold text-muted d-block fs-7">ICRC-2</span>
                              </div>
                            </div>
                          </td>
                          <td>
                            <a href="#" class="text-dark fw-bolder text-hover-primary d-block fs-6">881</a>
                            <span class="text-muted fw-bold text-muted d-block fs-7">≈ $5029</span>
                          </td>
                          <td class="text-end">
                            <div class="d-flex flex-column w-100 me-2">
                              <div class="d-flex flex-stack mb-2">
                                <span class="text-muted me-2 fs-7 fw-bold">$12.54</span>
                              </div>
                            </div>
                          </td>
                          <td>
                            <div class="d-flex justify-content-end flex-shrink-0">
                              <a href="#" class="btn btn-icon btn-bg-light btn-active-color-primary btn-sm">
                                <i class="fas fa-paper-plane"></i>
                              </a>
                            </div>
                          </td>
                        </tr>
                        <tr v-for="token in storeAssets.assets">
                          <td>
                            <div class="d-flex align-items-center">
                              <div class="symbol symbol-45px me-5">
                                <img src="https://psh4l-7qaaa-aaaap-qasia-cai.raw.icp0.io/6ytv5-fqaaa-aaaap-qblcq-cai.png" alt="">
                              </div>
                              <div class="d-flex justify-content-start flex-column">
                                <a href="#" class="text-dark fw-bolder text-hover-primary fs-6">{{token.name}} ({{token.symbol}})</a>
                                <span class="text-muted fw-bold text-muted d-block fs-7">ICRC-2</span>
                              </div>
                            </div>
                          </td>
                          <td>
                            <a href="#" class="text-dark fw-bolder text-hover-primary d-block fs-6">1.231</a>
                            <span class="text-muted fw-bold text-muted d-block fs-7">≈ ${{1231*0.54}}</span>
                          </td>
                          <td class="text-end">
                            <div class="d-flex flex-column w-100 me-2">
                              <div class="d-flex flex-stack mb-2">
                                <span class="text-muted me-2 fs-7 fw-bold">$0.54</span>
                              </div>
                            </div>
                          </td>
                          <td>
                            <div class="d-flex justify-content-end flex-shrink-0">
                              <a href="#" class="btn btn-icon btn-bg-light btn-active-color-primary btn-sm">
                                <i class="fas fa-paper-plane"></i>
                              </a>
                            </div>
                          </td>
                        </tr>
                      </tbody>
                      <!--end::Table body-->
                    </table>
                    <!--end::Table-->
                  </div>
                </div>
            </div>
          
          <div class="tab-pane fade" id="wallet_nfts" role="tabpanel">
            <div class="container">
                <div class="row">
                <!--begin::Col-->
                <div class="col-md-4 mb-10" v-for="nft in 35">
                    <!--begin::Hot sales post-->
                    <div class="bg-light bg-opacity-75 p-5 rounded-3">
                    <div class="card-xl-stretch">
                        <!--begin::Overlay-->
                        <a class="d-block overlay" data-fslightbox="lightbox-hot-sales" href="http://be2us-64aaa-aaaaa-qaabq-cai.localhost:8000/">
                        <!--begin::Image-->
                        <div class="overlay-wrapper bgi-no-repeat bgi-position-center bgi-size-cover card-rounded min-h-125px" style="background-image:url('http://be2us-64aaa-aaaaa-qaabq-cai.localhost:8000/')"></div>
                        <!--end::Image-->
                        <!--begin::Action-->
                        <div class="overlay-layer card-rounded bg-dark bg-opacity-25">
                            <i class="bi bi-eye-fill fs-2x text-white"></i>
                        </div>
                        <!--end::Action-->
                        </a>
                        <!--end::Overlay-->
                        <!--begin::Body-->
                        <div class="mt-5">
                        <!--begin::Title-->
                        <a href="#" class="fs-6 text-dark fw-bolder text-hover-primary text-dark lh-base">ICTO NFT Card</a>
                        <div class="fs-6 fw-bolder mt-5 d-flex flex-stack">
                            <!--begin::Label-->
                            <span class="badge border-dashed fs-2 fw-bolder text-dark p-1">
                            <span class="fs-6 fw-bold text-gray-400">#</span>{{nft}}
                            </span>
                            <!--end::Label-->
                            <!--begin::Action-->
                            <a href="#" class="btn btn-primary btn-sm">Transfer <i class="fas fa-paper-plane"></i>
                            </a>
                            <!--end::Action-->
                        </div>
                        <!--end::Text-->
                        </div>
                        <!--end::Body-->
                    </div>
                    </div>
                </div>
                </div>
            </div>
          </div>
          <div class="tab-pane fade" id="wallet_airdrops" role="tabpanel"> Coming soon </div>
		  </div>
        </div>
      </div>
    </div>
    <div class="card-footer py-5 text-center" id="kt_activities_footer">
		<div class="d-flex flex-column gap-7 gap-md-10">
            <button class="btn btn-sm btn-light-primary" type="button" @click="importToken()"><span class="fw-bolder">+ Import Token</span> </button>
        </div>
	</div>
  </div>
</div>
<div style="z-index: 109;" class="drawer-overlay" v-if="openWallet" @click="closeWallet"></div>
</template>