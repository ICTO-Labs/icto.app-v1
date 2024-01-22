<script setup>
    import { shortAccount } from '@/utils/common';
    import { showModal } from '@/utils/common';
    const buyNow = ()=>{
        showModal('showBuyModal', { status: true, 
            nft: 'uncommon'
        });
    }
</script>
<template>
    <Toolbar :current="`ICTO NFT Card #2302`" :parents="[{title: 'Marketplace', to: '/marketplace'}, {title: 'ICTO NFT Card', to: '/marketplace/2ouva-viaaa-aaaaq-aaamq-cai'}]"/>
    <div class="row g-xxl-9">
        <!--begin::Col-->
        <div class="col-xxl-6">
            <!--begin::Security summary-->
            <div class="card1 card-xxl-stretch overflow-hidden">
                
                <div class="card-body p-0">
                    <div class="row gy-4">
                        <div class="col-sm-12">
                            <img :src="`http://localhost:5500/sample/uncommon.svg`" class="w-100 max-h-350" />
                        </div>

                        <div class="align-items-center mb-2">
                            <h4 class=" p-2">Description</h4>
                            <div class="fs-7 text-muted p-2">
                                <p>This second generation collection builds on our popular first release by introducing increased rarity and exclusive traits for only 3,460 tokens.</p>
                                <p>
                                We focused on higher scarcity and prestige for Gen 2 holders. Owners can also customize names and images for each token. Join our growing community focused on utility!
                                </p>
                            </div>
                        </div>
                    </div>
                </div>
            </div>
        </div>
        <div class="col-xxl-6">
            <div class="card mb-2 mb-xl-10">
                <div class="card-body p-5">
                    <h3 class="fs-6 fw-bolder">
                            <router-link to="/" class="text-primary">ICTO NFT Card <Verified /></router-link>
                    </h3>
                    <h1 class="text-dark">
                        <router-link to="/"  class="text-dark">ICTO NFT Card #2302</router-link> <a href="#" class="fs-6 fw-bold ms-2">View Onchain <i class="fas fa-link"></i></a>
                    </h1>
                    <div class="d-flex align-items-center d-column">
                        <div class="d-flex align-items-center min-w-125px py-3 me-6 mb-3 col">
                            <span class="fw-bold me-2">Creator: </span> <a href="#">{{ shortAccount('6102c39ede652286711a1019b6e2e67c0b765241db23b3e96b9f203b6174e6a2')  }}</a> <Verified :size="5"/>
                        </div>
                        <div class="d-flex align-items-center min-w-125px py-3 me-6 mb-3 col">
                            <span class="fw-bold me-2">Owner: </span>  <a href="#">{{ shortAccount('6102c39ede652286711a1019b6e2e67c0b765241db23b3e96b9f203b6174e6a2')  }}</a>
                        </div>
                    </div>
                    <div class="d-flex align-items-center d-column mb-5">
                        <!--begin::Stat-->
                        <div class="border border-gray-300 border-dashed rounded min-w-125px py-3 px-4 me-6 mb-3 col">
                            <!--begin::Number-->
                            <div class="d-flex align-items-center">
                                <!--begin::Svg Icon | path: icons/duotune/arrows/arr066.svg-->
                                <span class="svg-icon svg-icon-3 svg-icon-success me-2">
                                    <svg xmlns="http://www.w3.org/2000/svg" width="24" height="24" viewBox="0 0 24 24" fill="none">
                                        <rect opacity="0.5" x="13" y="6" width="13" height="2" rx="1" transform="rotate(90 13 6)" fill="black"></rect>
                                        <path d="M12.5657 8.56569L16.75 12.75C17.1642 13.1642 17.8358 13.1642 18.25 12.75C18.6642 12.3358 18.6642 11.6642 18.25 11.25L12.7071 5.70711C12.3166 5.31658 11.6834 5.31658 11.2929 5.70711L5.75 11.25C5.33579 11.6642 5.33579 12.3358 5.75 12.75C6.16421 13.1642 6.83579 13.1642 7.25 12.75L11.4343 8.56569C11.7467 8.25327 12.2533 8.25327 12.5657 8.56569Z" fill="black"></path>
                                    </svg>
                                </span>
                                <!--end::Svg Icon-->
                                <div class="fs-4 fw-bolder counted">196</div>
                            </div>
                            <!--end::Number-->
                            <!--begin::Label-->
                            <div class="fw-bold fs-6 text-gray-400">Points</div>
                            <!--end::Label-->
                        </div>
                        <!--end::Stat-->
                        <div class="border border-gray-300 border-dashed rounded min-w-125px py-3 px-4 me-6 mb-3 col">
                            <!--begin::Number-->
                            <div class="d-flex align-items-center">
                                <!--begin::Svg Icon | path: icons/duotune/arrows/arr065.svg-->
                                <span class="svg-icon svg-icon-3 svg-icon-success me-2">
                                    <svg xmlns="http://www.w3.org/2000/svg" width="24" height="24" viewBox="0 0 24 24" fill="none">
                                        <rect opacity="0.5" x="13" y="6" width="13" height="2" rx="1" transform="rotate(90 13 6)" fill="black"></rect>
                                        <path d="M12.5657 8.56569L16.75 12.75C17.1642 13.1642 17.8358 13.1642 18.25 12.75C18.6642 12.3358 18.6642 11.6642 18.25 11.25L12.7071 5.70711C12.3166 5.31658 11.6834 5.31658 11.2929 5.70711L5.75 11.25C5.33579 11.6642 5.33579 12.3358 5.75 12.75C6.16421 13.1642 6.83579 13.1642 7.25 12.75L11.4343 8.56569C11.7467 8.25327 12.2533 8.25327 12.5657 8.56569Z" fill="black"></path>
                                    </svg>
                                </span>
                                <!--end::Svg Icon-->
                                <div class="fs-4 fw-bolder counted">16.2</div>
                            </div>
                            <!--end::Number-->
                            <!--begin::Label-->
                            <div class="fw-bold fs-6 text-gray-400">Age (days)</div>
                            <!--end::Label-->
                        </div>
                    </div>
                    <h5>PRICE</h5>
                    <div class="row">
                        <div class="col">
                            <div class="fw-bolder fs-2">200<span class="text-muted fs-4 fw-bold ms-2">ICP</span>
                                <span class="text-muted fw-bold text-muted d-block fs-6">≈ $0</span>
                            </div>
                        </div>
                        <div class="col mt-1">
                            <div class="d-flex flex-column">
                                <button class="btn btn-danger" @click.stop="buyNow"><i class="fas fa-wallet"></i> Buy Now</button>
                            </div>
                        </div>
                    </div>
                </div>
            </div>
            <div class="card mb-5 mb-xl-10">
                <div class="card-header p-5 min-h-50px card-header-stretch">
                    <div class="card-title py-0">
                        <h3 class="m-0 text-gray-900">
                            <i class="fas fa-tag"></i> Offers
                        </h3>
                    </div>
                </div>
                <div class="card-body p-5">
                    <div class="row p-5">
                        There are currently no offers!
                    </div>
                </div>
            </div>
        </div>
    </div>

    <div class="card mb-5 mb-xl-10 mt-10">
        <!--begin::Card header-->
        <div class="card-header border-0 pt-0">
            <h3 class="card-title align-items-start flex-column">
                <ul class="nav">
                    <li class="nav-item">
                        <a class="nav-link btn btn-sm btn-color-muted btn-active btn-active-dark active fw-bolder px-4 me-1 fs-6" data-bs-toggle="tab" href="#kt_tab_pane_1">Item History</a>
                    </li>
                    <li class="nav-item">
                        <a class="nav-link btn btn-sm btn-color-muted btn-active btn-active-dark fw-bolder px-4 me-1 fs-6" data-bs-toggle="tab" href="#kt_tab_pane_2">Point History</a>
                    </li>
                </ul>

                
            </h3>
            <div class="card-toolbar">
                <button class="btn btn-sm btn-light-primary">Refresh</button>
            </div>
        </div>
        <!--end::Card header-->
        <!--begin::Card body-->
        <div class="card-body p-0">
            <div class="tab-content" id="myTabContent">
                <div class="tab-pane fade active show" id="kt_tab_pane_1" role="tabpanel">
                    <!--begin::Table wrapper-->
                    <div class="table-responsive">
                        <!--begin::Table-->
                        <table class="table table-flush align-middle table-row-bordered table-row-solid gy-4 gs-9">
                            <!--begin::Thead-->
                            <thead class="border-gray-200 fs-5 fw-bold bg-lighten">
                                <tr>
                                    <th class="min-w-100px">Action</th>
                                    <th class="min-w-100px">Price</th>
                                    <th class="min-w-100px">From</th>
                                    <th class="min-w-150px">To</th>
                                    <th class="min-w-150px">Time</th>
                                </tr>
                            </thead>
                            <!--end::Thead-->
                            <!--begin::Tbody-->
                            <tbody class="fw-6 fw-bold text-gray-600">
                                <tr>
                                    <td>
                                        <span class="text-hover-primary text-info">Sale</span>
                                    </td>
                                    <td>
                                        <span class="text-hover-primary text-success">+12</span>
                                    </td>
                                    <td>
                                        <span class="text-hover-primary text-primary">196</span>
                                    </td>
                                    <td>System</td>
                                    <td>2 mins ago</td>
                                </tr>
                                <tr>
                                    <td>
                                        <span class="text-hover-primary text-info">Sale</span>
                                    </td>
                                    <td>
                                        <span class="text-hover-primary text-success">+2</span>
                                    </td>
                                    <td>
                                        <span class="text-hover-primary text-primary">184</span>
                                    </td>
                                    <td>System</td>
                                    <td>2 days ago</td>
                                </tr>
                            </tbody>
                            <!--end::Tbody-->
                        </table>
                        <!--end::Table-->
                    </div>
                    <!--end::Table wrapper-->
                </div>
                <div class="tab-pane fade" id="kt_tab_pane_2" role="tabpanel">
                    <!--begin::Table wrapper-->
                    <div class="table-responsive">
                        <!--begin::Table-->
                        <table class="table table-flush align-middle table-row-bordered table-row-solid gy-4 gs-9">
                            <!--begin::Thead-->
                            <thead class="border-gray-200 fs-5 fw-bold bg-lighten">
                                <tr>
                                    <th class="min-w-100px">Before points</th>
                                    <th class="min-w-100px">Change</th>
                                    <th class="min-w-100px">After points</th>
                                    <th class="min-w-150px">From</th>
                                    <th class="min-w-150px">Descriptions</th>
                                    <th class="min-w-150px">Time</th>
                                </tr>
                            </thead>
                            <!--end::Thead-->
                            <!--begin::Tbody-->
                            <tbody class="fw-6 fw-bold text-gray-600">
                                <tr>
                                    <td>
                                        <span class="text-hover-primary text-info">184</span>
                                    </td>
                                    <td>
                                        <span class="text-hover-primary text-success">+12</span>
                                    </td>
                                    <td>
                                        <span class="text-hover-primary text-primary">196</span>
                                    </td>
                                    <td>System</td>
                                    <td>Staking event #2</td>
                                    <td>2 mins ago</td>
                                </tr>
                                <tr>
                                    <td>
                                        <span class="text-hover-primary text-info">182</span>
                                    </td>
                                    <td>
                                        <span class="text-hover-primary text-success">+2</span>
                                    </td>
                                    <td>
                                        <span class="text-hover-primary text-primary">184</span>
                                    </td>
                                    <td>System</td>
                                    <td>Daily age bonus</td>
                                    <td>2 days ago</td>
                                </tr>
                                <tr>
                                    <td>
                                        <span class="text-hover-primary text-info">0</span>
                                    </td>
                                    <td>
                                        <span class="text-hover-primary text-success">+182</span>
                                    </td>
                                    <td>
                                        <span class="text-hover-primary text-primary">182</span>
                                    </td>
                                    <td>System</td>
                                    <td>Bonus point from Pioneer Gen 1</td>
                                    <td>16 days ago</td>
                                </tr>
                            </tbody>
                            <!--end::Tbody-->
                        </table>
                        <!--end::Table-->
                    </div>
                    <!--end::Table wrapper-->
                </div>
            </div>
        </div>
        <!--end::Card body-->
    </div>
</template>