<script setup>
    import { ref, onMounted } from "vue";
    import NFTItem from "@/components/marketplace/NFTItem.vue";
    import { getCollectionInfo, getCollectionStats } from "@/services/Marketplace";
    import { useRoute } from "vue-router";
    import CountUp from 'vue-countup-v3'

    const router = useRoute();
    const items = ref([
        {tokenId: "common", price: 2, image: ""},
        {tokenId: "rare", price: 5},
        {tokenId: "legendary", price: 10},
        {tokenId: "epic", price: 8},
        {tokenId: "mythical", price: 15},
        {tokenId: "unique", price: 20},
        {tokenId: "special", price: 12},
        {tokenId: "limited", price: 25},
        {tokenId: "exclusive", price: 30},
        {tokenId: "premium", price: 18},
    ])

    const canisterId = router.params.canisterId;
    const collectionInfo = ref({});
    const stats = ref({});

    onMounted(async () => {
        collectionInfo.value = await getCollectionInfo(canisterId);
        stats.value = await getCollectionStats(canisterId);
    })
</script>
<template>
    <Toolbar :current="`ICTO NFT Card`" :parents="[{title: 'Marketplace', to: '/marketplace'}]"/>
        <!--begin::Navbar-->
        <div class="card mb-6">
            <div class="card-body pt-9 pb-0">
                <!--begin::Details-->
                <div class="d-flex flex-wrap flex-sm-nowrap mb-3">
                    <!--begin: Pic-->
                    <div class="me-7 mb-4">
                        <div class="symbol symbol-100px symbol-lg-160px symbol-fixed position-relative">
                            <img src="https://psh4l-7qaaa-aaaap-qasia-cai.raw.icp0.io/6ytv5-fqaaa-aaaap-qblcq-cai.png" alt="image">
                            
                        </div>
                    </div>
                    <!--end::Pic-->
                    <!--begin::Info-->
                    <div class="flex-grow-1">
                        <!--begin::Title-->
                        <div class="d-flex justify-content-between align-items-start flex-wrap mb-2">
                            <!--begin::User-->
                            <div class="d-flex flex-column">
                                <!--begin::Name-->
                                <div class="d-flex align-items-center mb-2">
                                    <a href="#" class="text-gray-900 text-hover-primary fs-2 fw-bolder me-1">ICTO NFT Card</a>
                                    <a href="#">
                                       <Verified />
                                    </a>
                                </div>
                                <!--end::Name-->
                                <!--begin::Info-->
                                <div class="d-flex flex-wrap fw-bold fs-6 mb-4 pe-2">
                                    <a href="#" class="d-flex align-items-center text-gray-400 text-hover-primary me-5 mb-2">
                                    <!--begin::Svg Icon | path: icons/duotune/communication/com006.svg-->
                                    <span class="svg-icon svg-icon-4 me-1">
                                        <svg xmlns="http://www.w3.org/2000/svg" width="24" height="24" viewBox="0 0 24 24" fill="none">
                                            <path opacity="0.3" d="M22 12C22 17.5 17.5 22 12 22C6.5 22 2 17.5 2 12C2 6.5 6.5 2 12 2C17.5 2 22 6.5 22 12ZM12 7C10.3 7 9 8.3 9 10C9 11.7 10.3 13 12 13C13.7 13 15 11.7 15 10C15 8.3 13.7 7 12 7Z" fill="black"></path>
                                            <path d="M12 22C14.6 22 17 21 18.7 19.4C17.9 16.9 15.2 15 12 15C8.8 15 6.09999 16.9 5.29999 19.4C6.99999 21 9.4 22 12 22Z" fill="black"></path>
                                        </svg>
                                    </span>
                                    <!--end::Svg Icon-->Governance</a>
                                    <a href="#" class="d-flex align-items-center text-gray-400 text-hover-primary me-5 mb-2">
                                    <!--begin::Svg Icon | path: icons/duotune/general/gen018.svg-->
                                    <span class="svg-icon svg-icon-4 me-1">
                                        <svg xmlns="http://www.w3.org/2000/svg" width="24" height="24" viewBox="0 0 24 24" fill="none">
                                            <path opacity="0.3" d="M18.0624 15.3453L13.1624 20.7453C12.5624 21.4453 11.5624 21.4453 10.9624 20.7453L6.06242 15.3453C4.56242 13.6453 3.76242 11.4453 4.06242 8.94534C4.56242 5.34534 7.46242 2.44534 11.0624 2.04534C15.8624 1.54534 19.9624 5.24534 19.9624 9.94534C20.0624 12.0453 19.2624 13.9453 18.0624 15.3453Z" fill="black"></path>
                                            <path d="M12.0624 13.0453C13.7193 13.0453 15.0624 11.7022 15.0624 10.0453C15.0624 8.38849 13.7193 7.04535 12.0624 7.04535C10.4056 7.04535 9.06241 8.38849 9.06241 10.0453C9.06241 11.7022 10.4056 13.0453 12.0624 13.0453Z" fill="black"></path>
                                        </svg>
                                    </span>
                                    <!--end::Svg Icon-->Internet Computer</a>
                                    <a href="#" class="d-flex align-items-center text-gray-400 text-hover-primary mb-2">
                                    <!--begin::Svg Icon | path: icons/duotune/communication/com011.svg-->
                                    <span class="svg-icon svg-icon-4 me-1">
                                        <svg xmlns="http://www.w3.org/2000/svg" width="24" height="24" viewBox="0 0 24 24" fill="none">
                                            <path opacity="0.3" d="M21 19H3C2.4 19 2 18.6 2 18V6C2 5.4 2.4 5 3 5H21C21.6 5 22 5.4 22 6V18C22 18.6 21.6 19 21 19Z" fill="black"></path>
                                            <path d="M21 5H2.99999C2.69999 5 2.49999 5.10005 2.29999 5.30005L11.2 13.3C11.7 13.7 12.4 13.7 12.8 13.3L21.7 5.30005C21.5 5.10005 21.3 5 21 5Z" fill="black"></path>
                                        </svg>
                                    </span>
                                    <!--end::Svg Icon-->NFT</a>
                                </div>
                                <!--end::Info-->
                            </div>
                            <!--end::User-->
                            <!--begin::Actions-->
                            <div class="d-flex my-4">
                                <a href="#" class="btn btn-sm btn-light me-2" id="kt_user_follow_button">
                                    <!--begin::Indicator-->
                                    <span class="indicator-label"><i class="fas fa-flag"></i> Report</span>
                                    <!--end::Indicator-->
                                </a>
                                <a href="#" class="btn btn-sm btn-primary me-0" data-bs-toggle="modal" data-bs-target="#kt_modal_offer_a_deal">Follow</a>
                            </div>
                            <!--end::Actions-->
                        </div>
                        <!--end::Title-->
                        <!--begin::Stats-->
                        <div class="d-flex flex-wrap flex-stack">
                            <!--begin::Wrapper-->
                            <div class="d-flex flex-column flex-grow-1 pe-8">
                                <!--begin::Stats-->
                                <div class="d-flex flex-wrap">
                                    <!--begin::Stat-->
                                    <div class="border border-gray-300 border-dashed rounded min-w-100px p-2 mb-3 me-3">
                                        <!--begin::Number-->
                                        <div class="d-flex align-items-center">
                                            <div class="fs-2 fw-bolder counted">
                                                <count-up :end-val="100"></count-up>
                                            </div>
                                        </div>
                                        <!--end::Number-->
                                        <!--begin::Label-->
                                        <div class="fw-bold fs-6 text-gray-400">Volume</div>
                                        <!--end::Label-->
                                    </div>
                                    <!--end::Stat-->
                                    <!--begin::Stat-->
                                    <div class="border border-gray-300 border-dashed rounded min-w-100px p-2 mb-3 me-3">
                                        <!--begin::Number-->
                                        <div class="d-flex align-items-center">
                                            <div class="fs-2 fw-bolder counted">
                                                <count-up :end-val="30"></count-up>
                                            </div>
                                        </div>
                                        <!--end::Number-->
                                        <!--begin::Label-->
                                        <div class="fw-bold fs-6 text-gray-400">Floor</div>
                                        <!--end::Label-->
                                    </div>
                                    <!--end::Stat-->
                                    <!--begin::Stat-->
                                    <div class="border border-gray-300 border-dashed rounded min-w-100px p-2 mb-3 me-3">
                                        <div class="d-flex align-items-center">
                                            <div class="fs-2 fw-bolder counted">
                                                <count-up :end-val="collectionInfo.total"></count-up>
                                            </div>
                                        </div>
                                        <div class="fw-bold fs-6 text-gray-400">Sales</div>
                                    </div>
                                    <div class="border border-gray-300 border-dashed rounded min-w-100px p-2 mb-3 me-3">
                                        <div class="d-flex align-items-center">
                                            <div class="fs-2 fw-bolder counted">
                                                <count-up :end-val="collectionInfo.average"></count-up>
                                            </div>
                                        </div>
                                        <div class="fw-bold fs-6 text-gray-400">Avg Price</div>
                                    </div>
                                    <div class="border border-gray-300 border-dashed rounded min-w-100px p-2 mb-3 me-3">
                                        <div class="d-flex align-items-center">
                                            <div class="fs-2 fw-bolder counted">
                                                <count-up :end-val="collectionInfo.listing"></count-up>
                                            </div>
                                        </div>
                                        <div class="fw-bold fs-6 text-gray-400">Listing</div>
                                    </div>
                                    <div class="border border-gray-300 border-dashed rounded min-w-100px p-2 mb-3 me-3">
                                        <div class="d-flex align-items-center">
                                            <div class="fs-2 fw-bolder counted">
                                                <count-up :end-val="collectionInfo.tokens"></count-up>
                                            </div>
                                        </div>
                                        <div class="fw-bold fs-6 text-gray-400">Total supply</div>
                                    </div>
                                    <!--end::Stat-->
                                </div>
                                <!--end::Stats-->
                            </div>
                            <!--end::Wrapper-->
                           
                        </div>
                        <!--end::Stats-->
                    </div>
                    <!--end::Info-->
                </div>
                <!--end::Details-->
                <!--begin::Navs-->
                <div class="d-flex overflow-auto h-55px">
                    <ul class="nav nav-stretch nav-line-tabs nav-line-tabs-2x border-transparent fs-5 fw-bolder flex-nowrap">
                        <!--begin::Nav item-->
                        <li class="nav-item">
                            <a class="nav-link text-active-primary me-6 active" href="#">Items</a>
                        </li>
                        <!--end::Nav item-->
                        <!--begin::Nav item-->
                        <li class="nav-item">
                            <a class="nav-link text-active-primary me-6" href="#">Transactions</a>
                        </li>
                        <!--end::Nav item-->
                      
                        <!--begin::Nav item-->
                        <li class="nav-item">
                            <a class="nav-link text-active-primary me-6 " href="#">My Activities</a>
                        </li>
                     
                    </ul>
                </div>
                <!--begin::Navs-->
            </div>
        </div>
        <!--end::Navbar-->
        <!--begin::Documents toolbar-->
        <div class="d-flex flex-wrap flex-stack mb-6">
            <!--begin::Title-->
            <h3 class="fw-bolder my-2">Items
            <span class="fs-6 text-gray-400 fw-bold ms-1">100+ items</span></h3>
            <!--end::Title-->
            <!--begin::Controls-->
            <div class="d-flex my-2">
                <!--begin::Search-->
                <div class="d-flex align-items-center position-relative me-4">
                    <!--begin::Svg Icon | path: icons/duotune/general/gen021.svg-->
                    <span class="svg-icon svg-icon-3 position-absolute ms-3">
                        <svg xmlns="http://www.w3.org/2000/svg" width="24" height="24" viewBox="0 0 24 24" fill="none">
                            <rect opacity="0.5" x="17.0365" y="15.1223" width="8.15546" height="2" rx="1" transform="rotate(45 17.0365 15.1223)" fill="black"></rect>
                            <path d="M11 19C6.55556 19 3 15.4444 3 11C3 6.55556 6.55556 3 11 3C15.4444 3 19 6.55556 19 11C19 15.4444 15.4444 19 11 19ZM11 5C7.53333 5 5 7.53333 5 11C5 14.4667 7.53333 17 11 17C14.4667 17 17 14.4667 17 11C17 7.53333 14.4667 5 11 5Z" fill="black"></path>
                        </svg>
                    </span>
                    <!--end::Svg Icon-->
                    <input type="text" id="kt_filter_search" class="form-control form-control-white form-control-sm w-150px ps-9" placeholder="Search NFT">
                </div>
                <!--end::Search-->
                <a href="#" class="btn btn-primary btn-sm" data-bs-toggle="tooltip" title="" data-bs-original-title="Coming soon">Refresh</a>
            </div>
            <!--end::Controls-->
        </div>
        <!--end::Documents toolbar-->
        <div class="row g-6 g-xl-9 mb-6 mb-xl-9 mt-5">
            <div class="row p-3">
                <div class="col-md-6 col-lg-4 col-xl-3 mb-5" v-for="nft in ['common', 'uncommon', 'rare', 'veryrare', 'epic', 'legend']">
                    <NFTItem :nft="nft" ></NFTItem>
                </div>
            </div>
        </div>
        
</template>