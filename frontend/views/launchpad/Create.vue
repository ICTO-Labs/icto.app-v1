<script setup>
import { ref } from "vue";
import config from "@/config"
import { Money3Component as money3 } from 'v-money3'
import { currencyFormat, formatTokenAmount } from "@/utils/token";
import { txtToPrincipal, showLoading, showSuccess, showError } from "@/utils/common";
import { install } from "@/services/Launchpad";
import Tokenomic from "@/components/launchpad/Tokenomic.vue";
import TokenDistribution from "@/components/launchpad/TokenDistribution.vue";
import Links from "@/components/launchpad/Links.vue";
import Review from "@/components/launchpad/Review.vue";
import { processDataForBackend } from "@/utils/launchpad";
import { QuillEditor } from '@vueup/vue-quill'

import moment from "moment";
const icpPrice = ref(13.75);
const tokenBalance = ref(0);
const tokenId = ref("b77ix-eeaaa-aaaaa-qaada-cai");
const currentStep = ref(0);
const steps = ref([
    "current",
    "pending",
    "pending",
    "pending",
    "pending",
    "pending",
]);
const changeStep = (index) => {
    steps.value[index] = "current";
    currentStep.value = index;
    for (let i = 0; i < steps.value.length; i++) {
        if (i !== index) {
            if (i < index) {
                steps.value[i] = "completed";
            } else {
                steps.value[i] = "pending";
            }
        }
    }
}
const changeListing = () => {
    if (launchpad.value.listing == 'manually') {
        launchpad.value.listingLiquidity = 0;
        launchpad.value.listingTime = 0;
        launchpad.value.listingTokenAmount = 0;
    } else {
        launchpad.value.listingLiquidity = 51;
        calTokenLiquidity();
    }
}
const calTokenLiquidity = () => {
    if (launchpad.value.listingLiquidity > 0) {
        launchpad.value.listingTokenAmount = (launchpad.value.launchParams.sellAmount * launchpad.value.listingLiquidity / 100);
        launchpad.value.distribution.liquidity.total = launchpad.value.listingTokenAmount;
    }
}

const tokenInfo = ref({
    name: "ICTO Token Test",
    symbol: "xICTO",
    standard: "icrc3",
    supply: 100000000,
    controllers: "lekqg-fvb6g-4kubt-oqgzu-rd5r7-muoce-kppfz-aaem3-abfaj-cxq7a-dqe"
})

const whitelist = ref([]);
const launchpad = ref({
    governanceModel: 1,//0: Standard, 1: Governance
    fee: 3,//Launchpad fee
    whitelistEnabled: 0,
    totalToken: 0,
    softcap: 0,
    hardcap: 0,
    minPrice: 0,
    maxPrice: 0,
    maxBuy: 10000,
    minBuy: 5,
    creator: "lekqg-fvb6g-4kubt-oqgzu-rd5r7-muoce-kppfz-aaem3-abfaj-cxq7a-dqe",
    affiliate: 3,
    affiliateEnabled: 0,
    currency: "uwp4v-7qaaa-aaaap-qhpiq-cai",
    listingLiquidity: 51,
    listingTokenAmount: 0,
    listing: 'ICPSwap',
    restrictedArea: [],
    tokenomics: [{ title: "Public Sale", value: 25 }],
    distribution: {
        fairlaunch: {
            title: "Fairlaunch",
            description: "Tokens available for public sale",
            total: 0,
            vesting: {
                cliff: 0,
                duration: 0,
                unlockFrequency: 0,
            },
            recipients: []
        },
        liquidity: {
            title: "Liquidity",
            description: "Tokens reserved for liquidity",
            total: 0,
            vesting: {
                cliff: 0,
                duration: 365 * 24 * 60 * 60,
                unlockFrequency: 0,
            },
            recipients: []
        },
        team: {
            title: "Team",
            description: "Team allocation",
            total: 20_000,
            vesting: {
                cliff: 0,
                duration: 2 * 365 * 24 * 60 * 60,
                unlockFrequency: 0,
            },
            recipients: [
            {
                        amount: 10_000,
                        address: "lekqg-fvb6g-4kubt-oqgzu-rd5r7-muoce-kppfz-aaem3-abfaj-cxq7a-dqe",
                        note: "Founder"
                    },
                    {
                        amount: 10_000,
                        address: "v57dj-hev4p-lsvdl-dckvv-zdcvg-ln2sb-tfqba-nzb4g-iddrv-4rsq3-mae",
                        note: "Developer"
                    }
            ]
        },
        others: []
    },
    saleToken: {
        name: "ICTO Token Test",
        symbol: "tICTO",
        decimals: 8,
        transferFee: 0,
        metadata: [],
        logo: "",
        canisterId: ""
    },
    purchaseToken: {
        name: "Test ICP",
        symbol: "tICP",
        decimals: 8,
        transferFee: 10_000,
        metadata: [],
        logo: "https://psh4l-7qaaa-aaaap-qasia-cai.raw.icp0.io/uwp4v-7qaaa-aaaap-qhpiq-cai.png",
        canisterId: "uwp4v-7qaaa-aaaap-qhpiq-cai"
    },
    launchParams: {
        sellAmount: 250_000,
        softCap: 10_000,
        hardCap: 20_000,
        minimumAmount: 5,
        maximumAmount: 5000
    },
    projectInfo: {
        name: "ICTO Test Launchpad",
        description: `Project Title: Aim for a short, unambiguous, and memorable title. 
Overview: This is a high-level summary (no more than one or two paragraphs).
Project Justification: Explain the problem or opportunity and why the project is necessary.
Objectives: Set specific and measurable project goals.
Phases of Work: Break down the project into phases that describe the desired outcome for each.
Metrics for Evaluating and Monitoring: Include the metrics you’ll use to evaluate the project’s success. 
Timeline: Outline the timeline for each phase, including the basic tasks that you will accomplish, with start and end dates.
Estimated Budget: Include the budget and projected costs.`,
        isAudited: false,
        isVerified: false,
        links: ["https://icto.app", "https://x.com/icto_app", "https://youtube.com/icto_app", "https://github.com/ICTO-Labs", "https://t.me/icto_app"],
        logo: "",
        banner: [],
        metadata: []
    },
    timeline:{
        createdTime: moment().valueOf(),
        startTime: moment().add(1, "minutes").valueOf(),
        endTime: moment().add(10, "minutes").valueOf(),
        claimTime: moment().add(15, "minutes").valueOf(),
        listingTime: moment().add(20, "minutes").valueOf(),
    }
})
const money3Config = {
    masked: true,
    prefix: '',
    suffix: '',
    thousands: ',',
    decimal: '.',
    precision: 0,
    disableNegative: false,
    disabled: false,
    min: 0,
    max: null,
    allowBlank: false,
    minimumNumberOfCharacters: 0,
    shouldRound: true,
    focusOnRight: false,
};
const calTokenPrice = () => {
    if (launchpad.value.launchParams.sellAmount > 0) {
        launchpad.value.distribution.fairlaunch.total = launchpad.value.launchParams.sellAmount;
        if (launchpad.value.launchParams.softCap) launchpad.value.minPrice = launchpad.value.launchParams.softCap / launchpad.value.launchParams.sellAmount;
        if (launchpad.value.launchParams.hardCap) launchpad.value.maxPrice = launchpad.value.launchParams.hardCap / launchpad.value.launchParams.sellAmount;
        calTokenLiquidity();
    }
}

//Process upload image to base64
const processImage = (event, type='banner') => {
    const file = event.target.files[0];
    const reader = new FileReader();
    reader.onload = () => {
        if (type == 'logo') {
            launchpad.value.projectInfo.logo = reader.result;
        } else if(type == 'tokenLogo') {
            launchpad.value.saleToken.logo = reader.result;
        } else {
            launchpad.value.projectInfo.banner = [reader.result];
        }
    };
    reader.readAsDataURL(file);
}

const updateDistribution = (newDistribution) => {
    launchpad.value.distribution = newDistribution;
};
const updateUrls = (newUrls) => {
    launchpad.value.projectInfo.links = newUrls;
};

const installLaunchpad = async () => {
    let _formattedData = processDataForBackend(launchpad.value);
    console.log('launchpad', launchpad.value);
    console.log('_formattedData', _formattedData);

    Swal.fire({
		title: "Are you sure?",
		text: "Create your fundraising campaign with the information provided??",
		icon: "warning",
		showCancelButton: true,
		confirmButtonColor: "#3085d6",
		cancelButtonColor: "#d33",
		confirmButtonText: "Yes, I confirmed!"
		}).then(async (result) => {
            if (result.isConfirmed) {
                showLoading('Creating new launch, please wait...');
                let _rs = await install(_formattedData, whitelist.value, "2phil-viaaa-aaaap-qhoka-cai");
                if(_rs && "ok" in _rs) {
                    showSuccess('Launchpad created. Your launchpad canister Id: 2phil-viaaa-aaaap-qhoka-cai', true);
                }else{
                    showError(_rs.err, true);
                }
                console.log('_', _rs);
            }
        });
}
</script>
<template>
    <Toolbar :current="`Create`" :parents="[{ title: 'Launchpad', to: '/launchpad' }]" />

    <div class="stepper stepper-pills stepper-column d-flex flex-column flex-xl-row flex-row-fluid first"
        id="kt_create_account_stepper" data-kt-stepper="true">
        <!--begin::Aside-->
        <div
            class="d-flex justify-content-center bg-body rounded justify-content-xl-start flex-row-auto w-100 w-xl-300px w-xxl-300px me-9">
            <!--begin::Wrapper-->
            <div class="px-6 px-lg-10 px-xxl-5 py-20">
                <!--begin::Nav-->
                <div class="stepper-nav">
                    <!--begin::Step 1-->
                    <div :class="`stepper-item ${steps[0]}`" data-kt-stepper-element="nav">
                        <!--begin::Line-->
                        <div class="stepper-line w-40px"></div>
                        <!--end::Line-->
                        <!--begin::Icon-->
                        <div class="stepper-icon w-40px h-40px">
                            <i class="stepper-check fas fa-check"></i>
                            <span class="stepper-number">1</span>
                        </div>
                        <!--end::Icon-->
                        <!--begin::Label-->
                        <div class="stepper-label">
                            <h3 class="stepper-title">Launch Method</h3>
                            <div class="stepper-desc fw-bold">Choose launchpad method</div>
                        </div>
                        <!--end::Label-->
                    </div>
                    <!--end::Step 1-->
                    <!--begin::Step 2-->
                    <div :class="`stepper-item ${steps[1]}`" data-kt-stepper-element="nav">
                        <!--begin::Line-->
                        <div class="stepper-line w-40px"></div>
                        <!--end::Line-->
                        <!--begin::Icon-->
                        <div class="stepper-icon w-40px h-40px">
                            <i class="stepper-check fas fa-check"></i>
                            <span class="stepper-number">2</span>
                        </div>
                        <!--end::Icon-->
                        <!--begin::Label-->
                        <div class="stepper-label">
                            <h3 class="stepper-title">Verify Token</h3>
                            <div class="stepper-desc fw-bold">Verify your token canister</div>
                        </div>
                        <!--end::Label-->
                    </div>
                    <!--end::Step 2-->
                    <!--begin::Step 3-->
                    <div :class="`stepper-item ${steps[2]}`" data-kt-stepper-element="nav">
                        <!--begin::Line-->
                        <div class="stepper-line w-40px"></div>
                        <!--end::Line-->
                        <!--begin::Icon-->
                        <div class="stepper-icon w-40px h-40px">
                            <i class="stepper-check fas fa-check"></i>
                            <span class="stepper-number">3</span>
                        </div>
                        <!--end::Icon-->
                        <!--begin::Label-->
                        <div class="stepper-label">
                            <h3 class="stepper-title">Launch Setting</h3>
                            <div class="stepper-desc fw-bold">All details about your sales
                            </div>
                        </div>
                        <!--end::Label-->
                    </div>
                    <!--end::Step 3-->
                    <!--begin::Step 4-->
                    <div :class="`stepper-item ${steps[3]}`" data-kt-stepper-element="nav">
                        <!--begin::Line-->
                        <div class="stepper-line w-40px"></div>
                        <!--end::Line-->
                        <!--begin::Icon-->
                        <div class="stepper-icon w-40px h-40px">
                            <i class="stepper-check fas fa-check"></i>
                            <span class="stepper-number">4</span>
                        </div>
                        <!--end::Icon-->
                        <!--begin::Label-->
                        <div class="stepper-label">
                            <h3 class="stepper-title">Token Distribution</h3>
                            <div class="stepper-desc fw-bold">Configure token allocation</div>
                        </div>
                        <!--end::Label-->
                    </div>
                    <!--end::Step 4-->
                    <!--begin::Step 4-->
                    <div :class="`stepper-item ${steps[4]}`" data-kt-stepper-element="nav">
                        <!--begin::Line-->
                        <div class="stepper-line w-40px"></div>
                        <!--end::Line-->
                        <!--begin::Icon-->
                        <div class="stepper-icon w-40px h-40px">
                            <i class="stepper-check fas fa-check"></i>
                            <span class="stepper-number">5</span>
                        </div>
                        <!--end::Icon-->
                        <!--begin::Label-->
                        <div class="stepper-label">
                            <h3 class="stepper-title">Additional Info</h3>
                            <div class="stepper-desc fw-bold">Introduce about your project</div>
                        </div>
                        <!--end::Label-->
                    </div>
                    <!--end::Step 4-->
                    <!--begin::Step 5-->
                    <div :class="`stepper-item ${steps[5]}`" data-kt-stepper-element="nav">
                        <!--begin::Line-->
                        <div class="stepper-line w-40px"></div>
                        <!--end::Line-->
                        <!--begin::Icon-->
                        <div class="stepper-icon w-40px h-40px">
                            <i class="stepper-check fas fa-check"></i>
                            <span class="stepper-number">6</span>
                        </div>
                        <!--end::Icon-->
                        <!--begin::Label-->
                        <div class="stepper-label">
                            <h3 class="stepper-title">Completed</h3>
                            <div class="stepper-desc fw-bold">Review your information</div>
                        </div>
                        <!--end::Label-->
                    </div>
                    <!--end::Step 5-->
                </div>
                <!--end::Nav-->
            </div>
            <!--end::Wrapper-->
        </div>
        <!--begin::Aside-->
        <!--begin::Content-->
        <div class="d-flex flex-row-fluid flex-center bg-body rounded">
            <!--begin::Form-->
            <form class="py-5 w-100 px-10 fv-plugins-bootstrap5 fv-plugins-framework" novalidate="novalidate"
                id="kt_create_account_form">
                <!--begin::Step 1-->
                <div :class="steps[0]" data-kt-stepper-element="content">
                    <!--begin::Wrapper-->
                    <div class="w-100">
                        <!--begin::Heading-->
                        <div class="pb-10 pb-lg-15">
                            <!--begin::Title-->
                            <h2 class="fw-bolder d-flex align-items-center text-dark">Choose Launchpad Type
                                <i class="fas fa-exclamation-circle ms-2 fs-7" data-bs-toggle="tooltip" title=""
                                    data-bs-original-title="Billing is issued based on your selected account type"
                                    aria-label="Billing is issued based on your selected account type"></i>
                            </h2>
                            <!--end::Title-->
                            <!--begin::Notice-->
                            <div class="text-muted fw-bold fs-6">If you need more info, please check out
                                <a href="https://docs.icto.app" target="_blank"
                                    class="link-primary fw-bolder">Document</a>.
                            </div>
                            <!--end::Notice-->
                        </div>
                        <!--end::Heading-->
                        <!--begin::Input group-->
                        <div class="fv-row fv-plugins-icon-container fv-plugins-bootstrap5-row-valid">
                            <!--begin::Row-->
                            <div class="row">
                                <!--begin::Col-->
                                <div class="col-lg-6">
                                    <!--begin::Option-->
                                    <input type="radio" class="btn-check" value="0" name="governanceModel"
                                        checked="checked" id="standard" v-model="launchpad.governanceModel">
                                    <label
                                        class="btn btn-outline btn-outline-dashed btn-outline-default p-7 d-flex align-items-center mb-10"
                                        for="standard">
                                        <span class="me-5">
                                            <i class="fas fa-rocket fs-3x"></i>
                                        </span>
                                        <!--begin::Info-->
                                        <span class="d-block fw-bold text-start">
                                            <span class="text-dark fw-bolder d-block fs-4 mb-2">Standard
                                                Launchpad</span>
                                            <span class="text-muted fw-bold fs-6">Launch your project with automated,
                                                smart contract-controlled fundraising.</span>
                                        </span>
                                        <!--end::Info-->
                                    </label>
                                    <!--end::Option-->
                                </div>
                                <!--end::Col-->
                                <!--begin::Col-->
                                <div class="col-lg-6">
                                    <!--begin::Option-->
                                    <input type="radio" class="btn-check" value="1" name="governanceModel"
                                        id="governance-model" v-model="launchpad.governanceModel">
                                    <label
                                        class="btn btn-outline btn-outline-dashed btn-outline-default p-7 d-flex align-items-center"
                                        for="governance-model">
                                        <span class="me-5">
                                            <i class="fas fa-user-shield fs-3x"></i>
                                        </span>
                                        <!--begin::Info-->
                                        <span class="d-block fw-bold text-start">
                                            <span class="text-dark fw-bolder d-block fs-4 mb-2">DAO-Governed
                                                Launchpad</span>
                                            <span class="text-muted fw-bold fs-6">Leverage community trust and oversight
                                                for your fundraising campaign.</span>
                                        </span>
                                        <!--end::Info-->
                                    </label>
                                    <!--end::Option-->
                                </div>
                                <!--end::Col-->
                            </div>

                            <div class="row">
                                <div v-if="launchpad.governanceModel == 0" class="alert bg-light-warning">
                                    <h5 class="mb-2 text-primary"><i class="fas fa-rocket text-primary"></i> Standard
                                        Launchpad</h5>
                                    <div>
                                        A fully automated, smart contract-controlled fundraising model. Offers
                                        transparency and security through code-enforced rules, without DAO intervention.
                                        Ideal for projects seeking a streamlined, predictable fundraising process.
                                    </div>
                                </div>
                                <div v-show="launchpad.governanceModel == 1" class="alert bg-light-warning">
                                    <h5 class="mb-2 text-danger"><i class="fas fa-user-shield text-danger"></i>
                                        DAO-Governed Launchpad</h5>
                                    <div>
                                        Combines smart contract automation with community oversight. Enhances
                                        credibility through DAO monitoring and potential intervention. Suited for
                                        projects valuing community trust and willing to embrace decentralized governance
                                        in their fundraising efforts!
                                    </div>
                                </div>
                            </div>
                            <!--end::Row-->
                        </div>
                        <!--end::Input group-->
                    </div>
                    <!--end::Wrapper-->
                </div>
                <!--end::Step 1-->
                <!--begin::Step 2-->
                <div data-kt-stepper-element="content" :class="steps[1]">
                    <!--begin::Wrapper-->
                    <div class="w-100">
                        <div class="pb-10 pb-lg-15">
                            <h2 class="fw-bolder d-flex align-items-center text-dark">Token infomation</h2>
                            <div class="text-muted fw-bold fs-6">Enter token and choose currency, fee etc...</div>
                        </div>
                        <div class="alert alert-dismissible bg-light-primary d-flex flex-column flex-sm-row p-5 mb-10">
                            <span class="svg-icon svg-icon-2hx svg-icon-primary me-4 mb-5 mb-sm-0">
                                <svg xmlns="http://www.w3.org/2000/svg" width="24" height="24" viewBox="0 0 24 24" fill="none">
                                    <path opacity="0.3" d="M14 2H6C4.89543 2 4 2.89543 4 4V20C4 21.1046 4.89543 22 6 22H18C19.1046 22 20 21.1046 20 20V8L14 2Z" fill="black"></path>
                                    <path d="M20 8L14 2V6C14 7.10457 14.8954 8 16 8H20Z" fill="black"></path>
                                    <rect x="13.6993" y="13.6656" width="4.42828" height="1.73089" rx="0.865447" transform="rotate(45 13.6993 13.6656)" fill="black"></rect>
                                    <path d="M15 12C15 14.2 13.2 16 11 16C8.8 16 7 14.2 7 12C7 9.8 8.8 8 11 8C13.2 8 15 9.8 15 12ZM11 9.6C9.68 9.6 8.6 10.68 8.6 12C8.6 13.32 9.68 14.4 11 14.4C12.32 14.4 13.4 13.32 13.4 12C13.4 10.68 12.32 9.6 11 9.6Z" fill="black"></path>
                                </svg>
                            </span>
                            <div class="d-flex flex-column pe-0">
                                <h4 class="fw-bold">Token infomation</h4>
                                <span>Your token will deployed after reaching the softcap. We are using the latest ICRC standards released by Dfinity, which is the standard that SNS projects are using!</span>
                            </div>
                        </div>
                        <div class="fv-row fv-plugins-icon-container fv-plugins-bootstrap5-row-valid">
                            <div class="row mb-5">
                                <div class="col-md-6 fv-row">
                                    <label class="d-flex align-items-center fs-6 fw-bold mb-2"><span
                                            class="required">Token Name</span></label>
                                    <input type="text" class="form-control" v-model="launchpad.saleToken.name" required
                                        placeholder="Enter token name">
                                </div>
                                <div class="col-md-6 fv-row">
                                    <label class="d-flex align-items-center fs-6 fw-bold mb-2"><span
                                            class="required">Token Symbol</span></label>
                                    <input type="text" class="form-control" v-model="launchpad.saleToken.symbol"
                                        required placeholder="Enter token symbol">
                                </div>
                            </div>
                            <div class="row mb-5">
                                <div class="col-md-6 fv-row">
                                    <label class="d-flex align-items-center fs-6 fw-bold mb-2"><span
                                            class="required">Token Decimals</span></label>
                                    <input type="text" class="form-control" v-model="launchpad.saleToken.decimals"
                                        required placeholder="Enter token decimals">
                                </div>
                                <div class="col-md-6 fv-row">
                                    <label class="d-flex align-items-center fs-6 fw-bold mb-2"><span
                                            class="required">Transfer Fee</span></label>
                                    <input type="text" class="form-control" v-model="launchpad.saleToken.transferFee"
                                        required placeholder="Enter transfer fee">
                                </div>
                            </div>
                            <div class="row mb-5">
                                <div class="col-md-12 fv-row">
                                    <label class="d-flex align-items-center fs-6 fw-bold mb-2">
                                        <span class="required">Logo</span>
                                        <span class="w-30px"><img :src="launchpad.saleToken.logo" class="w-30px"></span>
                                    </label>
                                    <input type="file" class="form-control" required @change="processImage($event, 'tokenLogo')">
                                </div>
                            </div>

                            <div class="separator separator-dashed mb-5"></div>

                            <div class="row mb-3">
                                <div class="col-md-6 fv-row">
                                    <label class="fs-6 fw-bold form-label mb-2">Currency</label>
                                    <div class="row fv-row">
                                        <div class="col-12">
                                            <select name="listing" class="form-select" v-model="launchpad.currency"
                                                readonly>
                                                <option value="uwp4v-7qaaa-aaaap-qhpiq-cai">tICP (Test ICP)</option>
                                            </select>
                                            <div class="form-text">Participants will commit with <strong>tICP</strong> for
                                                your token</div>
                                        </div>
                                    </div>
                                </div>
                                <div class="col-md-6 fv-row">
                                    <label class="d-flex align-items-center fs-6 fw-bold mb-2"><span class="">Launch
                                            Fee</span></label>

                                    <div class="input-group mb-3">
                                        <span class="input-group-text" id="fee">%</span>
                                        <input type="text" class="form-control" :value="config.LAUNCHPAD_FEE" disabled>
                                    </div>
                                    <div class="form-text">ICP raised only (Recommended)</div>

                                </div>
                            </div>
                            <div class="row mb-2">
                                <div class="col-md-6 fv-row">
                                    <div class="form-check form-switch form-check-custom form-check-solid mb-2">
                                        <input class="form-check-input h-20px w-30px" type="checkbox"
                                            id="allowmarketing" v-model="launchpad.whitelistEnabled">
                                        <label class="form-check-label fw-bold fs-6" for="allowmarketing"
                                            title="Affiliate"> Affiliate Program (%)</label>
                                    </div>
                                    <div class="input-group" v-if="launchpad.whitelistEnabled">
                                        <input type="number" min="0" max="5" class="form-control fw-normal"
                                            v-model="launchpad.affiliate"
                                            placeholder="Min:1 - Max: 5, Set 0 = disable" />
                                    </div>
                                    <div class="form-text" v-if="launchpad.affiliate">The amount of raised currency that
                                        uses for the affiliate program.</div>
                                </div>

                            </div>
                        </div>
                    </div>
                </div>
                <!--end::Step 2-->
                <!--begin::Step 3-->
                <div data-kt-stepper-element="content" :class="steps[2]">
                    <div class="w-100">
                        <div class="pb-10 pb-lg-15">
                            <h2 class="fw-bolder d-flex align-items-center text-dark">Launch Settings</h2>
                            <div class="text-muted fw-bold fs-6">Setting sales params</div>
                        </div>
                        <div class="fv-row fv-plugins-icon-container fv-plugins-bootstrap5-row-valid">
                            <div class="row mb-5">
                                <div class="col-md-12 fv-row">
                                    <label class="d-flex align-items-center fs-6 fw-bold mb-2"><span
                                            class="required">Total <span v-if="tokenInfo"
                                                class="text-primary">{{ launchpad.saleToken.symbol }}</span> for
                                            sell</span></label>
                                    <money3 v-model.number="launchpad.launchParams.sellAmount" class="form-control"
                                        v-bind="money3Config" @change="calTokenPrice"></money3>
                                </div>
                            </div>
                            <div class="row mb-5">
                                <div class="col-md-3 fv-row">
                                    <label class="d-flex align-items-center fs-6 fw-bold mb-2"><span
                                            class="required">Soft cap</span></label>

                                    <div class="input-group mb-3">
                                        <span class="input-group-text" id="softcap">ICP</span>
                                        <money3 v-model.number="launchpad.launchParams.softCap" class="form-control"
                                            v-bind="money3Config" @change="calTokenPrice"></money3>
                                    </div>
                                    <div class="form-text">Minimum ICP amount</div>

                                </div>
                                <div class="col-md-3 fv-row">
                                    <label class="d-flex align-items-center fs-6 fw-bold mb-2"><span
                                            class="">&nbsp;</span></label>

                                    <div class="input-group mb-3">
                                        <span class="input-group-text" id="hardcap">$</span>
                                        <input type="text" class="form-control"
                                            :value="currencyFormat(launchpad.launchParams.softCap * icpPrice)" disabled>
                                    </div>
                                </div>
                                <div class="col-md-3 fv-row">
                                    <label class="d-flex align-items-center fs-6 fw-bold mb-2"><span class="">Token
                                            Price</span></label>
                                    <div class="input-group mb-3">
                                        <span class="input-group-text" id="hardcap">ICP</span>
                                        <input type="text" class="form-control" v-model="launchpad.minPrice" disabled>
                                    </div>
                                </div>
                                <div class="col-md-3 fv-row">
                                    <label class="d-flex align-items-center fs-6 fw-bold mb-2"><span
                                            class="">&nbsp;</span></label>
                                    <div class="input-group mb-3">
                                        <span class="input-group-text" id="hardcap">$</span>
                                        <input type="text" class="form-control" :value="launchpad.minPrice * icpPrice"
                                            disabled>
                                    </div>
                                </div>
                            </div>
                            <div class="row mb-5">
                                <div class="col-md-3 fv-row">
                                    <label class="d-flex align-items-center fs-6 fw-bold mb-2"><span
                                            class="required">Hard cap</span></label>
                                    <div class="input-group mb-3">
                                        <span class="input-group-text" id="hardcap">ICP</span>
                                        <money3 v-model.number="launchpad.launchParams.hardCap" class="form-control"
                                            v-bind="money3Config" @change="calTokenPrice"></money3>
                                    </div>
                                    <div class="form-text">Maximum ICP amount</div>
                                </div>
                                <div class="col-md-3 fv-row">
                                    <label class="d-flex align-items-center fs-6 fw-bold mb-2"><span
                                            class="">&nbsp;</span></label>
                                    <div class="input-group mb-3">
                                        <span class="input-group-text" id="hardcap">$</span>
                                        <input type="text" class="form-control"
                                            :value="currencyFormat(launchpad.launchParams.hardCap * icpPrice)" disabled>
                                    </div>
                                </div>
                                <div class="col-md-3 fv-row">
                                    <label class="d-flex align-items-center fs-6 fw-bold mb-2"><span class="">Token
                                            Price</span></label>
                                    <div class="input-group mb-3">
                                        <span class="input-group-text" id="hardcap">ICP</span>
                                        <input type="text" class="form-control" v-model="launchpad.maxPrice" disabled>
                                    </div>
                                </div>
                                <div class="col-md-3 fv-row">
                                    <label class="d-flex align-items-center fs-6 fw-bold mb-2"><span
                                            class="">&nbsp;</span></label>
                                    <div class="input-group mb-3">
                                        <span class="input-group-text" id="hardcap">$</span>
                                        <input type="text" class="form-control" :value="launchpad.maxPrice * icpPrice"
                                            disabled>
                                    </div>
                                </div>
                            </div>
                            <div class="row mb-5">
                                <div class="col-md-6 fv-row">
                                    <label class="d-flex align-items-center fs-6 fw-bold mb-2"><span
                                            class="required">Minimum contribution</span></label>
                                    <div class="input-group mb-3">
                                        <span class="input-group-text" id="minbuy">ICP</span>
                                        <input type="text" class="form-control"
                                            v-model="launchpad.launchParams.minimumAmount" required>
                                    </div>
                                </div>
                                <div class="col-md-6 fv-row">
                                    <label class="d-flex align-items-center fs-6 fw-bold mb-2"><span
                                            class="required">Maximum contribution</span></label>
                                    <div class="input-group mb-3">
                                        <span class="input-group-text" id="maxbuy">ICP</span>
                                        <money3 v-model.number="launchpad.launchParams.maximumAmount"
                                            class="form-control" v-bind="money3Config" @change="calTokenPrice" required>
                                        </money3>
                                    </div>
                                </div>
                            </div>
                            <div class="separator separator-dashed mb-5"></div>
                            <div class="row mb-5">
                                <div class="col-md-12 fv-row">
                                    <div class="form-check form-switch form-check-custom">
                                        <input class="form-check-input" type="checkbox" id="whitelist" checked="checked"
                                            v-model="launchpad.whitelistEnabled">
                                        <label class="form-check-label  fs-6 fw-bold" for="whitelist">Enable
                                            Whitelist</label>
                                    </div>
                                    <div class="form-text text-primary">Only wallet principal on the whitelist can
                                        participate</div>
                                </div>
                            </div>
                            <!-- <div class="row mb-5" v-if="launchpad.whitelist">
                                    <div class="col-md-12 fv-row">
                                        <label class="d-flex align-items-center fs-6 fw-bold mb-2"><span class="">Whitelist allocation (%)</span></label>
                                        <input type="number" min="10" max="100" class="form-control fw-normal" v-model="launchpad.whitelistAllocation" placeholder="Percent" required />
                                        <div class="form-text">The remaining tokens after the whitelist sale will be transferred to the public sale!</div>
                                    </div>
                                </div> -->

                            <!-- <div class="mb-5 fv-row fv-plugins-icon-container" v-if="launchpad.whitelist">
                                    <label class="d-flex align-items-center fs-6 form-label mb-3">Specify whitelist type
                                    </label>
                                    <div class="row mb-2" data-kt-buttons="true">
                                        <div class="col">
                                            <label :class="`btn btn-outline btn-outline-dashed btn-outline-default w-100 p-4 ${launchpad.whitelistType == 0?'active':''}`">
                                                <input type="radio" class="btn-check" name="account_team_size" value="0" v-model="launchpad.whitelistType">
                                                <span class="fw-bolder fs-6">By holders of NFT collection</span>
                                            </label>
                                        </div>
                                        <div class="col">
                                            <label :class="`btn btn-outline btn-outline-dashed btn-outline-default w-100 p-4 ${launchpad.whitelistType == 1?'active':''}`">
                                                <input type="radio" class="btn-check" name="account_team_size" value="1" v-model="launchpad.whitelistType">
                                                <span class="fw-bolder fs-6">By principal list</span>
                                            </label>
                                        </div>
                                        <div class="col">
                                            <label :class="`btn btn-outline btn-outline-dashed btn-outline-default w-100 p-4 ${launchpad.whitelistType == 2?'active':''}`">
                                                <input type="radio" class="btn-check" name="account_team_size" value="2" v-model="launchpad.whitelistType">
                                                <span class="fw-bolder fs-6">Draw from register</span>
                                            </label>
                                        </div>
                                    </div>
                                </div> -->
                            <div class="row mb-5" v-if="launchpad.whitelistEnabled">
                                <!-- <div class="col-md-12 fv-row"  v-if="launchpad.whitelistType==0">
                                        <input type="text" class="form-control fw-normal fs-7" v-model="launchpad.whitelistData" placeholder="Enter NFT Canister ID, Ex: oeee4-qaaaa-aaaak-qaaeq-cai" required />
                                        <div class="form-text">Support EXT NFT Collection (From Entrepot, Toniq marketplace)</div>
                                    </div> -->
                                <div class="col-md-12 fv-row">
                                    <textarea class="form-control fw-normal fs-7" v-model="whitelist"
                                        placeholder="Each Principal will be listed on a separate line"
                                        rows="6"></textarea>
                                </div>
                            </div>

                            <div class="separator separator-dashed mb-3"></div>
                            <div class="row mb-5">
                                <div class="col-md-6 fv-row">
                                    <label class="fs-6 fw-bold form-label mb-2">Listing on DEX</label>
                                    <div class="row fv-row">
                                        <div class="col-12">
                                            <select name="listing" class="form-select" v-model="launchpad.listing"
                                                @change="changeListing">
                                                <option value="manually">Manually (For seed/presale)</option>
                                                <option value="ICPSwap" selected>Auto listing (ICPSwap)</option>
                                            </select>
                                            <div class="form-text">Will be add lidquidity after a successful launch.
                                            </div>
                                        </div>
                                    </div>
                                </div>
                                <div class="col-md-3 fv-row">
                                    <label class="d-flex align-items-center fs-6 fw-bold mb-2"><span class="">{{
        launchpad.listing != 'manually' ? launchpad.listing : '' }}
                                            Liquidity(%)</span></label>
                                    <input type="number" min="51" max="100" class="form-control"
                                        v-model="launchpad.listingLiquidity" placeholder="Min: 51, Max: 100"
                                        :disabled="launchpad.listing == 'manually'" @change="calTokenLiquidity" />

                                    <div class="form-text">
                                        The percentage of raised funds that should be allocated to LP
                                    </div>
                                </div>
                                <div class="col-md-3 fv-row">
                                    <label class="d-flex align-items-center fs-6 fw-bold mb-2"><span class="">Token for
                                            Liquidity</span></label>
                                    <input type="text" class="form-control" disabled
                                        :value="currencyFormat(launchpad.listingTokenAmount)" />

                                    <div class="form-text">
                                        Token amount for liquidity
                                    </div>
                                </div>
                            </div>
                            <div class="separator separator-dashed mb-5"></div>
                            <div class="row mb-5">
                                <div class="col-md-6 fv-row">
                                    <label class="d-flex align-items-center fs-6 fw-bold mb-2"><span
                                            class="required">Start Time (UTC)</span></label>
                                    <VueDatePicker v-model="launchpad.timeline.startTime" :min-date="new Date()"
                                        :enable-time-picker="true" placeholder="Start time" time-picker-inline
                                        auto-apply></VueDatePicker>
                                </div>
                                <div class="col-md-6 fv-row">
                                    <label class="d-flex align-items-center fs-6 fw-bold mb-2"><span
                                            class="required">End Time (UTC)</span></label>
                                    <VueDatePicker v-model="launchpad.timeline.endTime" :min-date="launchpad.timeline.startTime"
                                        :enable-time-picker="true" time-picker-inline auto-apply placeholder="End time">
                                    </VueDatePicker>
                                </div>
                            </div>
                            <div class="row mb-10">
                                <div class="col-md-6 fv-row">
                                    <label class="d-flex align-items-center fs-6 fw-bold mb-2"><span class="">Claim
                                            Time (UTC)</span></label>
                                    <VueDatePicker v-model="launchpad.timeline.claimTime" :min-date="launchpad.timeline.endTime"
                                        :enable-time-picker="true" placeholder="Select claim time" time-picker-inline
                                        auto-apply></VueDatePicker>
                                </div>
                                <div class="col-md-6 fv-row">
                                    <label class="d-flex align-items-center fs-6 fw-bold mb-2"><span class="">Listing
                                            Time (UTC)</span></label>
                                    <VueDatePicker v-model="launchpad.timeline.listingTime" :min-date="launchpad.timeline.claimTime"
                                        :enable-time-picker="true" placeholder="Select listing time" time-picker-inline
                                        auto-apply :disabled="launchpad.listing == 'manually'"></VueDatePicker>
                                </div>
                            </div>
                            <div class="separator separator-dashed mb-3"></div>
                            <div class="row mb-10">
                                <div class="col-md-12 fv-row p-40 mh-250">
                                    <!-- <Tokenomic :data="launchpad.tokenomics"></Tokenomic> -->
                                </div>
                            </div>



                        </div>
                    </div>
                </div>
                <div data-kt-stepper-element="content" :class="steps[3]">
                    <div class="w-100">
                        <div class="pb-8 pb-lg-10">
                            <h2 class="fw-bolder text-dark">Token Distribution</h2>
                            <div class="text-muted fw-bold fs-6">
                                Configure token allocation parameters
                            </div>
                        </div>
                        <div class="mb-0">
                            <TokenDistribution :initial-distribution="launchpad.distribution" @update:distribution="updateDistribution"/>
                        </div>
                    </div>
                </div>
                <div data-kt-stepper-element="content" :class="steps[4]">
                    <div class="w-100">
                        <div class="pb-10 pb-lg-15">
                            <h2 class="fw-bolder text-dark">Additional Info</h2>
                            <div class="text-muted fw-bold fs-6">If you need more info, please check out
                                <a href="#" class="text-primary fw-bolder">Help Page</a>.
                            </div>
                        </div>
                        <div class="d-flex flex-column mb-3 fv-row fv-plugins-icon-container">
                            <label class="d-flex align-items-center fs-6 fw-bold form-label mb-2">
                                <span class="required">Project Name</span>
                            </label>
                            <input type="text" class="form-control "  v-model="launchpad.projectInfo.name" placeholder="Project name" name="name" value="">
                        </div>
                        <div class="d-flex flex-column mb-3 fv-row fv-plugins-icon-container">
                            <label class="d-flex align-items-center fs-6 fw-bold form-label mb-2">
                                <span class="required">Logo</span>
                                <img :src="launchpad.projectInfo.logo" class="w-60px" />
                            </label>
                            <input type="file" class="form-control" name="logo" value="" @change="processImage($event, 'logo')">
                        </div>
                        <!-- <div class="d-flex flex-column mb-3 fv-row fv-plugins-icon-container">
                            <label class="d-flex align-items-center fs-6 fw-bold form-label mb-2">
                                <span class="">Launchpad Banner</span>
                            </label>
                            <input type="file" class="form-control" name="banner" value="" @change="processImage($event, 'banner')">
                        </div> -->
                        <div class="d-flex flex-column mb-3 fv-row fv-plugins-icon-container">
                            <label class="d-flex align-items-center fs-6 fw-bold form-label mb-2">
                                <span class="required">Description</span>
                            </label>
                            <!-- <textarea class="form-control" rows="5" v-model="launchpad.projectInfo.description" placeholder="Project description"></textarea> -->
                            <QuillEditor theme="snow" v-model:content="launchpad.projectInfo.description" contentType="html" style="height: 150px"/>

                        </div>
                        <div class="d-flex flex-column mb-3 fv-row fv-plugins-icon-container">
                            <label class="d-flex align-items-center fs-6 fw-bold form-label mb-2">
                                <span class="required">Project links</span>
                            </label>
                            <Links :initial-urls="launchpad.projectInfo.links" @update:urls="updateUrls" ></Links>
                        </div>
                    </div>
                    <!--end::Wrapper-->
                </div>
                <!--end::Step 4-->
                <!--begin::Step 5-->
                <div data-kt-stepper-element="content" :class="steps[5]">
                    <!--begin::Wrapper-->
                    <div class="w-100">
                        <!--begin::Heading-->
                        <div class="pb-8 pb-lg-10">
                            <!--begin::Title-->
                            <h2 class="fw-bolder text-dark">Your Are Done!</h2>
                            <!--end::Title-->
                            <!--begin::Notice-->
                            <div class="text-muted fw-bold fs-6">
                                Review your details and submit
                            </div>
                            <!--end::Notice-->
                        </div>
                        <!--end::Heading-->
                        <!--begin::Body-->
                        <div class="mb-0">
                            <Review :launchpad="launchpad" />
                        </div>
                        <!--end::Body-->
                    </div>
                    <!--end::Wrapper-->
                </div>
                <!--end::Step 5-->
                <!--begin::Actions-->
                <div class="d-flex flex-stack pt-10">
                    <!--begin::Wrapper-->
                    <div class="mr-2">
                        <button type="button" class="btn btn-lg btn-light-primary me-3"
                            @click="changeStep(currentStep - 1)" v-if="currentStep > 0">
                            <span class="svg-icon svg-icon-4 me-1">
                                <svg xmlns="http://www.w3.org/2000/svg" width="24" height="24" viewBox="0 0 24 24"
                                    fill="none">
                                    <rect opacity="0.5" x="6" y="11" width="13" height="2" rx="1" fill="black"></rect>
                                    <path
                                        d="M8.56569 11.4343L12.75 7.25C13.1642 6.83579 13.1642 6.16421 12.75 5.75C12.3358 5.33579 11.6642 5.33579 11.25 5.75L5.70711 11.2929C5.31658 11.6834 5.31658 12.3166 5.70711 12.7071L11.25 18.25C11.6642 18.6642 12.3358 18.6642 12.75 18.25C13.1642 17.8358 13.1642 17.1642 12.75 16.75L8.56569 12.5657C8.25327 12.2533 8.25327 11.7467 8.56569 11.4343Z"
                                        fill="black"></path>
                                </svg>
                            </span> Back </button>
                    </div>
                    <!--end::Wrapper-->
                    <!--begin::Wrapper-->
                    <div>
                        <button type="button" class="btn btn-lg btn-danger me-3" v-if="currentStep==5" @click="installLaunchpad">
                            Create Launchpad
                        </button>
                        <button type="button" class="btn btn-lg btn-primary" @click="changeStep(currentStep+1)"
                            v-if="currentStep<=4">Continue
                            <!--begin::Svg Icon | path: icons/duotune/arrows/arr064.svg-->
                            <span class="svg-icon svg-icon-4 ms-1 me-0">
                                <svg xmlns="http://www.w3.org/2000/svg" width="24" height="24" viewBox="0 0 24 24"
                                    fill="none">
                                    <rect opacity="0.5" x="18" y="13" width="13" height="2" rx="1"
                                        transform="rotate(-180 18 13)" fill="black"></rect>
                                    <path
                                        d="M15.4343 12.5657L11.25 16.75C10.8358 17.1642 10.8358 17.8358 11.25 18.25C11.6642 18.6642 12.3358 18.6642 12.75 18.25L18.2929 12.7071C18.6834 12.3166 18.6834 11.6834 18.2929 11.2929L12.75 5.75C12.3358 5.33579 11.6642 5.33579 11.25 5.75C10.8358 6.16421 10.8358 6.83579 11.25 7.25L15.4343 11.4343C15.7467 11.7467 15.7467 12.2533 15.4343 12.5657Z"
                                        fill="black"></path>
                                </svg>
                            </span>
                            <!--end::Svg Icon--></button>
                    </div>
                    <!--end::Wrapper-->
                </div>
                <!--end::Actions-->
                <div></div>
                <div></div>
                <div></div>
                <div></div>
            </form>
            <!--end::Form-->
        </div>
        <!--end::Content-->
    </div>
</template>