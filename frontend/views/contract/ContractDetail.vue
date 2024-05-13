    <script setup>
    import {ref, watch, onMounted, watchEffect} from 'vue'
    import {useRoute} from 'vue-router';
    import moment from 'moment';
    import { useGetContract, useCancelContract, useGetContractRecipients, useGetMyClaimedAmount, useClaim } from "@/services/Contract";
    import CountUp from 'vue-countup-v3'
    import "vue3-circle-progress/dist/circle-progress.css";
    import CircleProgress from "vue3-circle-progress";
    import config from "@/config";
    import { SCHEDULE } from "@/config/constants";
    import { currencyFormat } from "@/utils/token"
    import IndicativeChart from '@/components/contract/IndicativeChart.vue';
    import ClaimRecord from '@/components/contract/ClaimRecord.vue';
    import { showLoading, showSuccess, showError, closeMessage } from '@/utils/common';
    import walletStore from '@/store';
    const route = useRoute();
    const isLoading = ref(false);
    const contractId = route.params.contractId; // read parameter id (it is reactive) 
    // const contractInfo = ref({});
    // const { data: contractInfo, error, isError, isLoading, isRefetching, refetch } = useGetContract(contractId);
    const activeTab = ref('overview');
    const loadTab = (tab) => {
        activeTab.value = tab;
    };
    const claimAbleAmount = ref(0);
    const contractInfo = ref(null);
    const recipients = ref([]);
    const loadContract = async (init) => {
        isLoading.value = true;
        await Promise.all([
            fetchContractInfo(),
            fetchRecipients(),
            fetchMyClaimedAmount(),
        ]);
        isLoading.value = false;
        if(!init) showSuccess('Contract reloaded!');
    }
    const fetchMyClaimedAmount = async()=>{
        claimAbleAmount.value = await useGetMyClaimedAmount(contractId);
    }
    const fetchContractInfo = async()=>{
        contractInfo.value = await useGetContract(contractId);
    }

    watchEffect(() => {
        if(walletStore.isLogged){
            fetchMyClaimedAmount();
        }
    });


    const claimToken = async()=>{
        Swal.fire({
		title: "Are you sure?",
		text: "Claim all available tokens from this contract",
		icon: "warning",
		showCancelButton: true,
		confirmButtonColor: "#3085d6",
		cancelButtonColor: "#d33",
		confirmButtonText: "Yes, I confirmed!"
		}).then(async (result) => {
            if(result.isConfirmed) {
                showLoading('Claiming...');
                let _claimRs = await useClaim(contractId);
                if(_claimRs && "ok" in _claimRs){
                    showSuccess('All '+Number(_claimRs.ok)/config.E8S+' tokens has been claimed successfuly!', true);
                }else{
                    showError(_claimRs?_claimRs.err:"Claim failed, please try again later!", true);
                }
                loadContract(true);
            }
        });
        
    }

    const fetchRecipients = async()=>{
        recipients.value = await useGetContractRecipients(contractId);
    }

    const cancelContract = async()=>{
        let _me = await useCancelContract(contractId);
        console.log(_me.toText());
    }
    onMounted(() => {
        loadContract(true);
    });
    </script>
    <template>
    <!--begin::Content-->
    <Toolbar :current="contractInfo?.title" :parents="[{title: 'Token Claim', to: '/token-claim'}]"/>
    <div id="kt_app_content" class="app-content flex-column-fluid">
        <!--begin::Content container-->
        <div id="kt_app_content_container" class="app-container container-xxl" v-if="contractInfo">
        <!--begin::Navbar-->
        <div class="card mb-6 mb-xl-9">
            <div class="card-body pt-9 pb-0">
            <!--begin::Details-->
            <div class="d-flex flex-wrap flex-sm-nowrap mb-6">
                <div class="d-flex flex-center flex-shrink-0 bg-light rounded w-100px h-100px w-lg-150px h-lg-150px me-7 mb-4">
                <img class="mw-50px mw-lg-125px" :src="`https://psh4l-7qaaa-aaaap-qasia-cai.raw.icp0.io/6ytv5-fqaaa-aaaap-qblcq-cai.png`" alt="image">
                <!-- <img class="mw-50px mw-lg-75px" :src="`https://${config.CANISTER_STORAGE_ID}.raw.icp0.io/${contractInfo?.tokenId}.png`" alt="image"> -->
                </div>
                <!--begin::Wrapper-->
                <div class="flex-grow-1">
                <!--begin::Head-->
                <div class="d-flex justify-content-between align-items-start flex-wrap mb-2">
                    <!--begin::Details-->
                    <div class="d-flex flex-column">
                    <!--begin::Status-->
                    <div class="d-flex align-items-center mb-1">
                        <span class="text-primary fs-2 fw-bold me-3">{{contractInfo?.title}}</span>
                        <!-- <span class="badge badge-light-danger me-auto" v-if="contractInfo && contractInfo.totalAmount==contractInfo.unlockedAmount">Ended</span> -->
                        <!-- <span class="badge badge-light-success me-auto" v-else>Ongoing...</span> -->
                    </div>
                    <div class="d-flex flex-wrap fw-bold fs-6 mb-4 pe-2">
                        <span href="#" class="d-flex align-items-center text-gray-800 text-hover-primary me-5 mb-2">
                        {{contractInfo?.tokenInfo.symbol}} ({{contractInfo?.tokenInfo.name}}) </span>
                        <span class="d-flex align-items-center text-gray-800 text-hover-primary me-5 mb-2">
                        <span class="menu-bullet d-flex align-items-center me-2">
                            <span class="bullet bg-gray-300 me-3"></span>
                        </span> <span class="me-2">{{contractInfo?.tokenInfo.canisterId}}</span> <Copy :text="contractInfo?.tokenInfo.canisterId"></Copy>
                        </span>
                        <span href="#" class="d-flex align-items-center text-gray-400 text-hover-primary mb-2">
                        <span class="badge badge-light-primary ms-auto" v-if="contractInfo">{{contractInfo?.tokenInfo.standard}}</span>
                        </span>
                    </div>
                    
                    </div>
                    <div class="d-flex mb-4">
                    <button type="button" class="btn btn-sm btn-light-primary me-3" @click="loadContract(false)" :disabled="isLoading">{{isLoading?'Reloading...':'Refresh '}} <i class="fas fa-sync"></i></button>
                    <button type="button" class="btn btn-sm btn-success" @click="claimToken()">Claim {{claimAbleAmount?Number(claimAbleAmount)/config.E8S:0}} ICP <i class="fas fa-coins"></i></button>
                    <!-- <button type="button" class="btn btn-sm btn-light-danger" @click="cancelContract()">Cancel <i class="fas fa-ban"></i></button> -->

                    </div>
                    <!--end::Actions-->
                </div>
                <!--end::Head-->
                <div class="d-flex flex-wrap fw-semibold mb-4 fs-5 text-gray-600">
                        {{ contractInfo?.description }}
                        <!-- <span v-if="isLoading">Loading...</span>
                        <span v-if="isRefetching">isRefetching...</span>
                        <span v-else-if="isError">Error: {{ error.message }}</span> -->
                </div>
                </div>
                <!--end::Wrapper-->
            </div>
            <div class="d-flex flex-wrap flex-sm-nowrap mb-6">
                <!--begin::Info-->
                <div class="d-flex flex-wrap justify-content-start">
                <!--begin::Stats-->
                <div class="d-flex flex-wrap">
                    <!--begin::Stat-->
                    <div class="border border-gray-300 border-dashed rounded min-w-125px py-3 px-4 me-6 mb-3">
                    <!--begin::Number-->
                    <div class="d-flex align-items-center text-hover-primary">
                        <div class="fs-4 fw-bold">{{ moment.unix(Number(contractInfo?.startTime)).utc().format("lll") }}</div>
                    </div>
                    <div class="fw-semibold fs-6 text-gray-500">Start Date (UTC)</div>
                    </div>
                    <div class="border border-gray-300 border-dashed rounded min-w-125px py-3 px-4 me-6 mb-3 hover-primary">
                    <div class="d-flex align-items-center text-hover-primary">
                        <div class="fs-4 fw-bold">{{ moment.unix(Number(contractInfo?.startTime)+(Number(contractInfo.lockDuration))).utc().format("lll") }}</div>
                    </div>
                    <div class="fw-semibold fs-6 text-gray-500">End Date (UTC)</div>
                    </div>
                    <div class="border border-gray-300 border-dashed rounded min-w-125px py-3 px-4 me-6 mb-3">
                    <div class="d-flex align-items-center">
                        <div class="fs-4 fw-bold counted" v-if="contractInfo">
                            {{ SCHEDULE[Number(contractInfo.unlockSchedule)] }}
                        </div>
                    </div>
                    <div class="fw-semibold fs-6 text-gray-500">Unlock Schedule</div>
                    </div>
                    <div class="border border-gray-300 border-dashed rounded min-w-125px py-3 px-4 me-6 mb-3">
                    <div class="d-flex align-items-center ">
                        <div class="fs-4 fw-bold counted">
                            <count-up :end-val="Number(contractInfo.totalAmount)/config.E8S" v-if="contractInfo && contractInfo.totalAmount"></count-up>
                        </div>
                    </div>
                    <div class="fw-semibold fs-6 text-gray-500">Total Amount</div>
                    </div>
                    <div class="border border-gray-300 border-dashed rounded min-w-125px py-3 px-4 me-6 mb-3">
                    <div class="d-flex align-items-center">
                        <div class="fs-4 fw-bold counted">
                            <count-up :end-val="contractInfo.totalClaimedAmount?Number(contractInfo.totalClaimedAmount)/config.E8S:0" v-if="contractInfo"></count-up>
                        </div>
                    </div>
                    <div class="fw-bold fs-6 text-gray-500">Claimed Amount</div>
                    </div>
                    <div class="border border-gray-300 border-dashed rounded min-w-125px py-3 px-4 me-6 mb-3">
                    <div class="d-flex align-items-center">
                        <div class="fs-4 fw-bold counted">
                            <count-up :end-val="Number(contractInfo.totalRecipients)" v-if="contractInfo"></count-up>
                        </div>
                    </div>
                    <div class="fw-semibold fs-6 text-gray-500">Recipients</div>
                    </div>
                </div>
                </div>
            </div>
            <!--end::Details-->
            <div class="separator"></div>
            <ul class="nav nav-stretch nav-line-tabs nav-line-tabs-2x border-transparent fs-5 fw-bold">
                <li class="nav-item">
                <a :class="`nav-link text-active-primary py-5 me-6 ${activeTab == 'overview'?'active':''}`" data-bs-toggle="tab" href="#overview" @click.stop="loadTab('overview')">Overview</a>
                </li>
                <li class="nav-item">
                <a :class="`nav-link text-active-primary py-5 me-6 ${activeTab == 'record'?'active':''}`"  data-bs-toggle="tab" href="#record" @click.stop="loadTab('record')">My claim record</a>
                </li>
                <li class="nav-item">
                <a class="nav-link text-active-primary py-5 me-6 " href="#">Settings</a>
                </li>
            </ul>
            </div>
        </div>
        <!--end::Navbar-->
        <!--begin::Row-->
            <div class="tab-content" id="myTabContent">
            <div :class="`tab-pane fade ${activeTab == 'overview'?'show active':''}`" id="overview" role="tabpanel">
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
                        <div class="fs-6 fw-semibold text-gray-500"></div>
                        </div>
                        <!--end::Card title-->
                        <!--begin::Card toolbar-->
                        <div class="card-toolbar">
                        <a href="#" class="btn btn-light btn-sm">Copy Link</a>
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
                            <div class="position-absolute translate-middle start-50 top-50 d-flex flex-column flex-center h-175px">
                                <circle-progress :percent="(Number(contractInfo.totalClaimedAmount)/Number(contractInfo.totalAmount))*100" :show-percent="true" />
                            </div>
                        </div>
                        <!--end::Chart-->
                        <!--begin::Labels-->
                        <div class="d-flex flex-column justify-content-center flex-row-fluid pe-11 mb-5">
                            <div class="d-flex fs-6 fw-semibold align-items-center mb-3">
                                <div class="bullet bg-success me-3"></div>
                                    <div class="text-gray-500">Total Amount</div>
                                <div class="ms-auto fw-bold text-gray-700">{{ currencyFormat(Number(contractInfo?.totalAmount)/config.E8S) }}</div>
                            </div>
                            <div class="d-flex fs-6 fw-semibold align-items-center mb-3">
                                <div class="bullet bg-primary me-3"></div>
                                    <div class="text-gray-500">Claimed</div>
                                <div class="ms-auto fw-bold text-gray-700">{{ currencyFormat(Number(contractInfo?.totalClaimedAmount)/config.E8S) }}</div>
                            </div>
                            <div class="d-flex fs-6 fw-semibold align-items-center mb-3">
                                <div class="bullet bg-gray-300 me-3"></div>
                                    <div class="text-gray-500">Remaining</div>
                                <div class="ms-auto fw-bold text-gray-700">{{ currencyFormat(Number(contractInfo?.totalAmount)/config.E8S - Number(contractInfo?.totalClaimedAmount)/config.E8S) }}</div>
                            </div>
                            <div class="d-flex fs-6 fw-semibold align-items-center">
                                <div class="bullet bg-danger me-3"></div>
                                    <div class="text-gray-500">Pending</div>
                                <div class="ms-auto fw-bold text-gray-700">0</div>
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
                            <div class="fs-6 text-gray-700 ">
                                This smart contract  <a href="#" class="fw-bold me-1">operates independently</a> and is not subject to the control of any third party. If you are the contract creator, please maintain Cycles to ensure it has enough cycles to function properly
                            </div>
                            </div>
                            <!--end::Content-->
                        </div>
                        <!--end::Wrapper-->
                        </div>
                        <!--end::Notice-->
                    </div>
                    <!--end::Card body-->
                    </div>
                    <!--end::Summary-->
                </div>
                <!--end::Col-->
                <!--begin::Col-->
                <div class="col-lg-6">
                    <!--begin::Graph-->
                    <div class="card card-flush h-lg-100">
                    <!--begin::Card header-->
                    <div class="card-header mt-0">
                        <div class="card-title flex-column">
                        <h3 class="fw-bold mb-1">Indicative Graph</h3>
                        </div>
                    </div>
                    <div class="card-body pt-0 pb-0 px-5">
                        <IndicativeChart :contractInfo="contractInfo" :contractId="contractId"></IndicativeChart>
                        <!-- <LineChart :chartData="chartData" :options="chartOptions" /> -->
                    </div>
                    </div>
                    <!--end::Graph-->
                </div>
                <!--end::Col-->
                </div>
                <!--end::Row-->
                <!--begin::Table-->
                <div class="card card-flush mt-6 mt-xl-9">
                <!--begin::Card header-->
                <div class="card-header mt-5">
                    <!--begin::Card title-->
                    <div class="card-title flex-column">
                    <h3 class="fw-bold mb-1">Recipients</h3>
                    <div class="fs-6 text-gray-500">Total <span v-if="contractInfo">{{ contractInfo.totalClaimedAmount?Number(contractInfo.totalClaimedAmount)/config.E8S:0 }} ICP</span> claimed so far</div>
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
                                <tr>
                                    <th class="min-w-250px sorting" rowspan="1" colspan="1">Recipient</th>
                                    <th class="min-w-90px sorting" rowspan="1" colspan="1">Remaining</th>
                                    <th class="min-w-90px sorting" rowspan="1" colspan="1">Claimed</th>
                                    <th class="min-w-90px sorting" rowspan="1" colspan="1">Last Claimed</th>
                                </tr>
                            </thead>
                            <tbody class="fs-7">
                                <tr class="odd" v-for="recipient in recipients">
                                    <td>
                                    <!--begin::User-->
                                    <div class="d-flex align-items-center">
                                        <!--begin::Info-->
                                        <div class="d-flex flex-column justify-content-center">
                                        <span class="fs-6 text-primary">
                                            {{ recipient.recipient.principal }}
                                        </span>
                                        <div class="fw-bold text-gray-800">
                                            {{ recipient.recipient.note[0] }}
                                        </div>
                                        </div>
                                        <!--end::Info-->
                                    </div>
                                    <!--end::User-->
                                    </td>
                                    <td> <span class="fs-6 text-success">{{ Number(recipient.remainingAmount)/config.E8S }}</span> </td>
                                    <td> <span class="fs-6 text-danger">{{ Number(recipient.claimedAmount)/config.E8S }}</span> </td>
                                    <td> <span class="fs-7 text-gray">{{ recipient.lastClaimedTime>0?moment.unix(Number(recipient.lastClaimedTime)).fromNow():'None' }}</span> </td>
                                </tr>
                            </tbody>
                        </table>
                        </div>
                    </div>
                    <!--end::Table-->
                    </div>
                    <!--end::Table container-->
                </div>
                <!--end::Card body-->
                </div>
            </div>
            <div :class="`tab-pane fade ${activeTab == 'record'?'show active':''}`" id="payment-history" role="tabpanel">
                <div class="card card-flush mt-6 mt-xl-9">
                    <ClaimRecord :contractId="contractId"/>
                </div>
            </div>
        </div>
        <!--end::Card-->
        </div>
        <!--end::Content container-->
    </div>
    <!--end::Content-->
    </template>
    <style>
    .current-counter {
        font-size: 36px;
        font-weight: 500;
    }

    .current-counter {
        &::after {
        content: "%";
        }
    }
    </style>