<template>
    <div class="row g-xxl-9">
        <!--begin::Col-->
        <div class="col-xxl-8">
            <!--begin::Security summary-->
            <div class="card1 card-xxl-stretch overflow-hidden">
                <div class="card-body p-0">
                    <div class="row gy-4">
                        <div class="col-sm-12">
                            <img :src="`http://localhost:5500/sample/uncommon.svg`" class="w-100 max-h-350" />
                        </div>
                    </div>
                </div>
            </div>
        </div>
        <div class="col-xxl-4">
            <div class="card mb-2 mb-xl-10">
                <div class="card-header card-header-stretch">
                    <div class="card-title">
                        <h3 class="text-primary">
                            <router-link to="/"><i class="fas fa-folder text-primary fs-4"></i> ICTO NFT Card</router-link>
                        </h3>
                    </div>
                </div>
                <div class="card-body">
                    <div class="fs-4 text-primary fw-bolder">ICTO NFT Card #2302</div>
                    <div class="d-flex align-items-center d-column mb-5">
                        <div class="fw-bolder fs-6">
                            <i class="fas fa-user"></i> Owner:<span class="text-muted fs-6 fw-bold ms-2">2c7436...d74f2</span>
                        </div>
                        <div class="fw-bolder fs-6 ms-3">
                            <a href="#" class="fs-6 fw-bold ms-2">View Onchain <i class="fas fa-link"></i></a>
                        </div>
                    </div>
                    <div class="row pt-3">
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
                    
                </div>
            </div>
            
            <div class="card mb-5 mb-xl-10">
                <div class="card-header card-header-stretch">
                    <div class="card-title py-0">
                        <h3 class="m-0 text-gray-900">
                            <i class="fas fa-shopping-cart"></i> Price
                        </h3>
                    </div>
                </div>
                <div class="card-body pt-5">
                    <div class="row">
                        <div class="col">
                            <div class="fw-bolder fs-2">200<span class="text-muted fs-4 fw-bold ms-2">ICP</span>
                                <span class="text-muted fw-bold text-muted d-block fs-6">≈ $0</span>
                            </div>
                        </div>
                        <div class="col mt-1">
                            <div class="d-flex flex-column">
                                <button class="btn btn-danger"><i class="fas fa-wallet"></i> Buy Now</button>
                            </div>
                        </div>
                    </div>
                </div>
            </div>
        </div>
    </div>
    <div class="card mb-5 mb-xl-10 mt-10" data-select2-id="select2-data-74-0rja">
        <!--begin::Card header-->
        <div class="card-header">
            <!--begin::Heading-->
            <div class="card-title">
                <h3>#2302 Points History</h3>
            </div>
            <!--end::Heading-->
            <!--begin::Toolbar-->
            <div class="card-toolbar">
                <a href="#" class="btn btn-sm btn-primary my-1">View All</a>
            </div>
            <!--end::Toolbar-->
        </div>
        <!--end::Card header-->
        <!--begin::Card body-->
        <div class="card-body p-0">
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
        <!--end::Card body-->
    </div>
</template>