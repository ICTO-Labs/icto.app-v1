<script setup>
    import { ref } from 'vue'
    import { contractApi } from '@/ic/api'
    import { useRoute } from 'vue-router';
    import moment from 'moment';
    import CountUp from 'vue-countup-v3'
    import "vue3-circle-progress/dist/circle-progress.css";
    import CircleProgress from "vue3-circle-progress";
    import config from "@/config"

    const route = useRoute();  
    const contract_id = route.params.contract_id; // read parameter id (it is reactive) 

    console.log('Start get contract');
    let contract = contractApi(contract_id, 'contract');
   
    const contractInfo = ref({});
    

    
    const getContract = async()=>{
        console.log('start.....')
        contractInfo.value = await contract.get();
        console.log('contractInfo', contractInfo.value);
    }
    
    getContract();

</script>
<template>
     <!--begin::Content-->
     <div id="kt_app_content" class="app-content  flex-column-fluid ">
                                                
                                                       
                                                <!--begin::Content container-->
                                                <div id="kt_app_content_container" class="app-container  container-xxl ">
                                                    
                                        <!--begin::Navbar-->
                                        <div class="card mb-6 mb-xl-9">
                                            <div class="card-body pt-9 pb-0">
                                                <!--begin::Details-->
                                                <div class="d-flex flex-wrap flex-sm-nowrap mb-6">
                                                    <!--begin::Wrapper-->
                                                    <div class="flex-grow-1">
                                                        <!--begin::Head-->
                                                        <div class="d-flex justify-content-between align-items-start flex-wrap mb-2">
                                                            <!--begin::Details-->
                                                            <div class="d-flex flex-column">
                                                                <!--begin::Status-->
                                                                <div class="d-flex align-items-center mb-1">
                                                                    <span class="text-primary fs-2 fw-bold me-3">{{contractInfo.name}}</span>
                                                                    <span class="badge badge-light-success me-auto">Ongoing...</span>
                                                                </div>

                                                                <div class="d-flex flex-wrap fw-bold fs-6 mb-4 pe-2">
															        <span href="#" class="d-flex align-items-center text-gray-400 text-hover-primary me-5 mb-2">
															            <img class="w-30px me-3" :src="`https://${config.CANISTER_STORAGE_ID}.raw.icp0.io/${contractInfo.tokenId}.png`" /> 
                                                                        {{contractInfo.tokenSymbol}} ({{contractInfo.tokenName}})
                                                                    </span> 
															<span class="d-flex align-items-center text-gray-400 text-hover-primary me-5 mb-2">
                                                                <span class="menu-bullet d-flex align-items-center me-2"><span class="bullet bg-success"></span></span> {{contractInfo.tokenId}}</span>
															<span href="#" class="d-flex align-items-center text-gray-400 text-hover-primary mb-2">
															<!--begin::Svg Icon | path: icons/duotune/communication/com011.svg-->
															<span class="badge badge-light-primary ms-auto">{{contractInfo.tokenStandard}}</span>
															</span>
														</div>
                                                                <!--end::Status-->
                                        
                                                                <!--begin::Description-->
                                                                <div class="d-flex flex-wrap fw-semibold mb-4 fs-5 text-gray-500">
                                                                    #1 Tool to get started with Web Apps any Kind &amp; size
                                                                </div>
                                                                <!--end::Description-->
                                                            </div>
                                                            <!--end::Details-->
                                        
                                                            <!--begin::Actions-->
                                                            <div class="d-flex mb-4">
                                                                <a href="#" class="btn btn-sm btn-bg-light btn-active-color-primary me-3" @click="getContract()">Refresh</a>
                                                                <a href="#" class="btn btn-sm btn-danger me-3" data-bs-toggle="modal" data-bs-target="#kt_modal_new_target">Cancel</a>
                                                              
                                                            </div>
                                                            <!--end::Actions-->
                                                        </div>
                                                        <!--end::Head-->
                                        
                                                        <!--begin::Info-->
                                                        <div class="d-flex flex-wrap justify-content-start">
                                                            <!--begin::Stats-->
                                                            <div class="d-flex flex-wrap">
                                                                <!--begin::Stat-->
                                                                <div class="border border-gray-300 border-dashed rounded min-w-125px py-3 px-4 me-6 mb-3">
                                                                    <!--begin::Number-->
                                                                    <div class="d-flex align-items-center">
                                                                        <div class="fs-4 fw-bold">{{ moment.unix(Number(contractInfo.startTime)).format("lll") }}</div>
                                                                    </div>
                                                                    <!--end::Number-->
                                        
                                                                    <!--begin::Label-->
                                                                    <div class="fw-semibold fs-6 text-gray-500">Start Date</div>
                                                                    <!--end::Label-->
                                                                </div>
                                                                <!--end::Stat-->
                                        
                                                                <!--begin::Stat-->
                                                                <div class="border border-gray-300 border-dashed rounded min-w-125px py-3 px-4 me-6 mb-3">
                                                                    <!--begin::Number-->
                                                                    <div class="d-flex align-items-center">
                                                                        <div class="fs-4 fw-bold counted">
                                                                            <count-up :end-val="Number(contractInfo.unlockSchedule)"></count-up>
                                                                        </div>
                                                                    </div>
                                                                    <!--end::Number-->
                                        
                                                                    <!--begin::Label-->
                                                                    <div class="fw-semibold fs-6 text-gray-500">Unlock Schedule</div>
                                                                    <!--end::Label-->
                                                                </div>
                                                                <!--end::Stat-->
                                        
                                                                <!--begin::Stat-->
                                                                <div class="border border-gray-300 border-dashed rounded min-w-125px py-3 px-4 me-6 mb-3">
                                                                    <!--begin::Number-->
                                                                    <div class="d-flex align-items-center">
                                                                        <div class="fs-4 fw-bold counted">
                                                                            <count-up :end-val="Number(contractInfo.totalAmount)"></count-up>
                                                                        </div>
                                                                    </div>
                                                                    <!--end::Number-->                                
                                        
                                                                    <!--begin::Label-->
                                                                    <div class="fw-semibold fs-6 text-gray-500">Total Amount</div>
                                                                    <!--end::Label-->
                                                                </div>
                                                                <div class="border border-gray-300 border-dashed rounded min-w-125px py-3 px-4 me-6 mb-3">
                                                                    <!--begin::Number-->
                                                                    <div class="d-flex align-items-center">
                                                                        <div class="fs-4 fw-bold counted">
                                                                            <count-up :end-val="contractInfo.recipients.length"></count-up>
                                                                        </div>
                                                                    </div>
                                                                    <!--end::Number-->                                
                                                                    <!--begin::Label-->
                                                                    <div class="fw-semibold fs-6 text-gray-500">Recipients</div>
                                                                    <!--end::Label-->
                                                                </div>
                                                                <div class="border border-gray-300 border-dashed rounded min-w-125px py-3 px-4 me-6 mb-3">
                                                                    <!--begin::Number-->
                                                                    <div class="d-flex align-items-center">
                                                                        <div class="fs-4 fw-bold counted">
                                                                            {{ contractInfo.tokenName }}
                                                                        </div>
                                                                    </div>
                                                                    <!--end::Number-->                                
                                                                    <!--begin::Label-->
                                                                    <div class="fw-semibold fs-6 text-gray-500">Token Name</div>
                                                                    <!--end::Label-->
                                                                </div>
                                                                <!--end::Stat-->
                                                            </div>
                                                            <!--end::Stats-->
                                        
                                                           
                                                        </div>
                                                        <!--end::Info-->
                                                    </div>
                                                    <!--end::Wrapper-->
                                                </div>
                                                <!--end::Details-->
                                        
                                                <div class="separator"></div>
                                        
                                                <!--begin::Nav-->
                                                <ul class="nav nav-stretch nav-line-tabs nav-line-tabs-2x border-transparent fs-5 fw-bold">
                                                                    <!--begin::Nav item-->
                                                        <li class="nav-item">
                                                            <a class="nav-link text-active-primary py-5 me-6 active" href="/metronic8/demo1/../demo1/apps/projects/project.html">
                                                                Overview                    </a>
                                                        </li>
                                                        <!--end::Nav item-->
                                                                    <!--begin::Nav item-->
                                                        <li class="nav-item">
                                                            <a class="nav-link text-active-primary py-5 me-6 " href="/metronic8/demo1/../demo1/apps/projects/targets.html">
                                                                Targets                    </a>
                                                        </li>
                                                        <!--end::Nav item-->
                                                                    <!--begin::Nav item-->
                                                        <li class="nav-item">
                                                            <a class="nav-link text-active-primary py-5 me-6 " href="/metronic8/demo1/../demo1/apps/projects/budget.html">
                                                                Budget                    </a>
                                                        </li>
                                                        <!--end::Nav item-->
                                                                    <!--begin::Nav item-->
                                                        <li class="nav-item">
                                                            <a class="nav-link text-active-primary py-5 me-6 " href="/metronic8/demo1/../demo1/apps/projects/users.html">
                                                                Users                    </a>
                                                        </li>
                                                        <!--end::Nav item-->
                                                                    <!--begin::Nav item-->
                                                        <li class="nav-item">
                                                            <a class="nav-link text-active-primary py-5 me-6 " href="/metronic8/demo1/../demo1/apps/projects/files.html">
                                                                Files                    </a>
                                                        </li>
                                                        <!--end::Nav item-->
                                                                    <!--begin::Nav item-->
                                                        <li class="nav-item">
                                                            <a class="nav-link text-active-primary py-5 me-6 " href="/metronic8/demo1/../demo1/apps/projects/activity.html">
                                                                Activity                    </a>
                                                        </li>
                                                        <!--end::Nav item-->
                                                                    <!--begin::Nav item-->
                                                        <li class="nav-item">
                                                            <a class="nav-link text-active-primary py-5 me-6 " href="/metronic8/demo1/../demo1/apps/projects/settings.html">
                                                                Settings                    </a>
                                                        </li>
                                                        <!--end::Nav item-->
                                                            </ul>
                                                <!--end::Nav-->
                                            </div>
                                        </div>
                                        <!--end::Navbar-->
                                        <!--begin::Row-->
                                        <div class="row gx-6 gx-xl-9">
                                            <!--begin::Col-->
                                            <div class="col-lg-6">
                                                <!--begin::Summary-->
                                        <div class="card card-flush h-lg-100">
                                            <!--begin::Card header-->
                                            <div class="card-header mt-6">
                                                <!--begin::Card title-->
                                                <div class="card-title flex-column">
                                                    <h3 class="fw-bold mb-1">Contract Summary</h3>
                                                    
                                                    <div class="fs-6 fw-semibold text-gray-500">24 Overdue Tasks</div>
                                                </div>
                                                <!--end::Card title-->
                                        
                                                <!--begin::Card toolbar-->
                                                <div class="card-toolbar">
                                                    <a href="#" class="btn btn-light btn-sm">View Tasks</a>
                                                </div>
                                                <!--end::Card toolbar-->
                                            </div>
                                            <!--end::Card header-->
                                        
                                            <!--begin::Card body-->
                                            <div class="card-body p-9 pt-5">
                                                <!--begin::Wrapper-->
                                                <div class="d-flex flex-wrap">
                                                    <!--begin::Chart-->
                                                    <div class="position-relative d-flex flex-center h-175px w-175px me-15 mb-7">
                                                        <div class="position-absolute translate-middle start-50 top-50 d-flex flex-column flex-center">
                                                            <circle-progress :percent="40" :show-percent="true"/>
                                                        </div>
                                        
                                                        <canvas id="project_overview_chart" width="175" height="175" style="display: block; box-sizing: border-box; height: 175px; width: 175px;"></canvas>
                                                    </div>
                                                    <!--end::Chart-->
                                        
                                                    <!--begin::Labels-->
                                                    <div class="d-flex flex-column justify-content-center flex-row-fluid pe-11 mb-5">
                                                        <!--begin::Label-->
                                                        <div class="d-flex fs-6 fw-semibold align-items-center mb-3">
                                                            <div class="bullet bg-primary me-3"></div>
                                                            <div class="text-gray-500">Active</div>
                                                            <div class="ms-auto fw-bold text-gray-700">30</div>
                                                        </div>
                                                        <!--end::Label-->
                                        
                                                        <!--begin::Label-->
                                                        <div class="d-flex fs-6 fw-semibold align-items-center mb-3">
                                                            <div class="bullet bg-success me-3"></div>
                                                            <div class="text-gray-500">Completed</div>
                                                            <div class="ms-auto fw-bold text-gray-700">45</div>
                                                        </div>
                                                        <!--end::Label-->
                                        
                                                        <!--begin::Label-->
                                                        <div class="d-flex fs-6 fw-semibold align-items-center mb-3">
                                                            <div class="bullet bg-danger me-3"></div>
                                                            <div class="text-gray-500">Overdue</div>
                                                            <div class="ms-auto fw-bold text-gray-700">0</div>
                                                        </div>
                                                        <!--end::Label-->
                                        
                                                        <!--begin::Label-->
                                                        <div class="d-flex fs-6 fw-semibold align-items-center">
                                                            <div class="bullet bg-gray-300 me-3"></div>
                                                            <div class="text-gray-500">Yet to start</div>
                                                            <div class="ms-auto fw-bold text-gray-700">25</div>
                                                        </div>
                                                        <!--end::Label-->
                                                    </div>
                                                    <!--end::Labels-->
                                                </div>
                                                <!--end::Wrapper-->
                                        
                                                
                                        <!--begin::Notice-->
                                        <div class="notice d-flex bg-light-primary rounded border-primary border border-dashed  p-6">
                                            
                                            <!--begin::Wrapper-->
                                            <div class="d-flex flex-stack flex-grow-1 ">
                                                            <!--begin::Content-->
                                                    <div class=" fw-semibold">
                                                        
                                                                            <div class="fs-6 text-gray-700 "><a href="#" class="fw-bold me-1">Invite New .NET Collaborators</a> to create great outstanding business to business .jsp modutr class scripts</div>
                                                                    </div>
                                                    <!--end::Content-->
                                                
                                                    </div>
                                            <!--end::Wrapper-->  
                                        </div>
                                        <!--end::Notice-->
                                            </div>
                                            <!--end::Card body-->
                                        </div>
                                        <!--end::Summary-->    </div>
                                            <!--end::Col-->
                                        
                                            <!--begin::Col-->
                                            <div class="col-lg-6">
                                                <!--begin::Graph-->
                                        <div class="card card-flush h-lg-100">
                                            <!--begin::Card header-->
                                            <div class="card-header mt-6">
                                                <!--begin::Card title-->
                                                <div class="card-title flex-column">
                                                    <h3 class="fw-bold mb-1">Tasks Over Time</h3>
                                        
                                                    <!--begin::Labels-->
                                                    <div class="fs-6 d-flex text-gray-500 fs-6 fw-semibold">
                                                        <!--begin::Label-->   
                                                        <div class="d-flex align-items-center me-6">
                                                            <span class="menu-bullet d-flex align-items-center me-2">
                                                                <span class="bullet bg-success"></span>
                                                            </span>                    
                                                            Complete
                                                        </div>
                                                        <!--end::Label-->
                                        
                                                        <!--begin::Label-->   
                                                        <div class="d-flex align-items-center">
                                                            <span class="menu-bullet d-flex align-items-center me-2">
                                                                <span class="bullet bg-primary"></span>
                                                            </span>
                                                            Incomplete
                                                        </div>            
                                                        <!--end::Label-->    
                                                    </div>
                                                    <!--end::Labels-->
                                                </div>
                                                <!--end::Card title-->
                                                
                                                <!--begin::Card toolbar-->
                                                <div class="card-toolbar">
                                                    <!--begin::Select-->
                                                    <select name="status" data-control="select2" data-hide-search="true" class="form-select form-select-solid form-select-sm fw-bold w-100px select2-hidden-accessible" data-select2-id="select2-data-9-8uqn" tabindex="-1" aria-hidden="true" data-kt-initialized="1">
                                                        <option value="1">2020 Q1</option>
                                                        <option value="2">2020 Q2</option>
                                                        <option value="3" selected="" data-select2-id="select2-data-11-8ozk">2020 Q3</option>
                                                        <option value="4">2020 Q4</option>
                                                    </select><span class="select2 select2-container select2-container--bootstrap5" dir="ltr" data-select2-id="select2-data-10-77z4" style="width: 100%;"><span class="selection"><span class="select2-selection select2-selection--single form-select form-select-solid form-select-sm fw-bold w-100px" role="combobox" aria-haspopup="true" aria-expanded="false" tabindex="0" aria-disabled="false" aria-labelledby="select2-status-jr-container" aria-controls="select2-status-jr-container"><span class="select2-selection__rendered" id="select2-status-jr-container" role="textbox" aria-readonly="true" title="2020 Q3">2020 Q3</span><span class="select2-selection__arrow" role="presentation"><b role="presentation"></b></span></span></span><span class="dropdown-wrapper" aria-hidden="true"></span></span>
                                                    <!--end::Select-->
                                                </div>
                                                <!--end::Card toolbar-->
                                            </div>
                                            <!--end::Card header-->
                                        
                                            <!--begin::Card body-->
                                            <div class="card-body pt-10 pb-0 px-5">
                                                aaa
                                            </div>
                                             <!--end::Card body-->
                                        </div>
                                        <!--end::Graph-->    </div>
                                            <!--end::Col-->
                                        
                                            
                                        </div>
                                        <!--end::Row-->
                                        
                                        <!--begin::Table-->
                                        <div class="card card-flush mt-6 mt-xl-9">
                                            <!--begin::Card header-->
                                            <div class="card-header mt-5">
                                                <!--begin::Card title-->
                                                <div class="card-title flex-column">
                                                    <h3 class="fw-bold mb-1">Contract Recipients</h3>
                                        
                                                    <div class="fs-6 text-gray-500">Total $260,300 sepnt so far</div>
                                                </div>
                                                <!--begin::Card title-->
                                        
                                            </div>
                                            <!--end::Card header-->
                                        
                                            <!--begin::Card body-->
                                            <div class="card-body pt-0">
                                                <!--begin::Table container-->
                                                <div class="table-responsive">
                                                    <!--begin::Table-->
                                                    <div id="kt_profile_overview_table_wrapper" class="dataTables_wrapper dt-bootstrap4 no-footer">
                                                        <div class="table-responsive">
                                                            <table id="kt_profile_overview_table" class="table table-row-bordered table-row-dashed gy-4 align-middle fw-bold dataTable no-footer">
                                                        <thead class="fs-7 text-gray-500 text-uppercase">
                                                            <tr><th class="min-w-250px sorting" rowspan="1" colspan="1">Recipient</th>
                                                                <th class="min-w-90px sorting" rowspan="1" colspan="1">Init Amount</th>
                                                                <th class="min-w-90px sorting" rowspan="1" colspan="1">Released</th>
                                                                <th class="min-w-90px sorting" rowspan="1" colspan="1">Remaining</th>
                                                            </tr>
                                                        </thead>
                                                        <tbody class="fs-6">
                                                            <tr class="odd" v-for="recipient in contractInfo.recipients">
                                                                <td>
                                                                    <!--begin::User-->
                                                                    <div class="d-flex align-items-center">
                                                                        <!--begin::Info-->
                                                                        <div class="d-flex flex-column justify-content-center">
                                                                            <a href="" class="fs-6 text-gray-800 text-hover-primary">
                                                                                {{ recipient.title[0] }}
                                                                                <span class="badge badge-light-info">{{ recipient.note[0] }}</span>
                                                                            </a>
                                    
                                                                            <div class="fw-semibold text-gray-500">{{ recipient.address }}</div>
                                                                        </div>
                                                                        <!--end::Info-->
                                                                    </div>
                                                                    <!--end::User-->
                                                                </td>
                                                                <td>{{ recipient.amount }}</td>
                                                                <td>
                                                                   30
                                                                </td>
                                                                <td>
                                                                   10
                                                                </td>
                                                              
                                                            </tr></tbody>
                                                    </table></div>
                                                    
                                                </div>
                                                    <!--end::Table-->
                                                </div>
                                                <!--end::Table container-->                                      
                                            </div>
                                            <!--end::Card body-->
                                        </div>
                                        <!--end::Card-->        </div>
                                                <!--end::Content container-->
                                            </div>
                                        <!--end::Content-->	
</template>
<style>
    .current-counter{
        font-size:36px;
        font-weight:500;
    }
    .current-counter {
            &::after {
                content: "%";
            }
    }
</style>