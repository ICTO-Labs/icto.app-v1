<script setup>
    import { ref } from "vue";
    import config from "@/config"
    import { Money3Component as money3 } from 'v-money3'
    import {currencyFormat, formatTokenAmount} from "@/utils/token";
    import { txtToPrincipal } from "@/utils/common";
    import { install } from "@/services/Launchpad";
    import Tokenomic from "@/components/launchpad/Tokenomic.vue";

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
            ]);
    const changeStep = (index)=>{
        steps.value[index] = "current";
        currentStep.value = index;
        for (let i = 0; i < steps.value.length; i++) {
            if (i !== index) {
                if(i < index){
                    steps.value[i] = "completed";
                }else{
                    steps.value[i] = "pending";
                }
            }
        }
    }          
    const changeListing = ()=>{
        if(launchpad.value.listing == 'manually'){
            launchpad.value.listingLiquidity = 0;
            launchpad.value.listingTime = 0;
        }
    }   
    const addMorePie = ()=>{
        launchpad.value.tokenomics.push({
            title: "Allocation #"+(launchpad.value.tokenomics.length+1),
            value: 0
        })
    }
    const removePie = (index)=>{
        launchpad.value.tokenomics.splice(index, 1);
    }
    const tokenInfo = ref({
        name: "ICTO Token Test",
        symbol: "xICTO",
        standard: "icrc3",
        supply: 100000000,
        controllers: "lekqg-fvb6g-4kubt-oqgzu-rd5r7-muoce-kppfz-aaem3-abfaj-cxq7a-dqe"
    })
    const launchpad = ref({
        DAOModel: false,
        whitelist: false,
        whitelistType: 0,
        whitelistAllocation: 100,
        whitelistData: "",
        totalToken: 0,
        softcap: 0,
        hardcap: 0,
        minPrice: 0,
        maxPrice: 0,
        maxBuy:10000,
        minBuy: 5,
        affiliate: false,
        affiliateAmount: 5,
        currency: config.LEDGER_CANISTER_ID,
        listingLiquidity: 0,
        listing: 'ICPSwap',
        tokenomics: [{ title: "Public Sale", value: 25 }]
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
    const calTokenPrice = ()=>{
        if(launchpad.value.totalToken > 0){
            if(launchpad.value.softcap) launchpad.value.minPrice = launchpad.value.softcap/launchpad.value.totalToken;
            if(launchpad.value.hardcap) launchpad.value.maxPrice = launchpad.value.hardcap/launchpad.value.totalToken;
        }
    }

    const installLaunchpad = async ()=>{
        // let _res = await deposit(300);
        //     console.log(_res);
        // return;
        let _projectInfo = {
            name: "Test Launchpad",
            description: "Checking the launchpad detail",
            isAudited: true,
            isVerified: true,
            links: [["https://icto.app"]],
            logo: "",
            banner: [],
            metadata: []
        };
        let _timeline = {
            createdTime: moment().valueOf()*1e6,
            startTime: moment().add(1, "minutes").valueOf()*1e6,
            endTime: moment().add(2, "minutes").valueOf()*1e6,
            claimTime: moment().add(3, "minutes").valueOf()*1e6,
            listingTime: moment().add(4, "minutes").valueOf()*1e6,
        };
        let _purchaseToken = {
            name: "ICTO Token Test",
            symbol: "xICTO",
            decimals : 8,
            transferFee: 0,
            metadata : [],
            logo: "",
            canisterId: "b77ix-eeaaa-aaaaa-qaada-cai"
        };
        let _params = {
            projectInfo : _projectInfo,
            timeline : _timeline,
            purchaseToken : [_purchaseToken],
            saleToken: [_purchaseToken],
            launchParams: {
                sellAmount: Number(formatTokenAmount(250_000_000, _purchaseToken.decimals)),
                softCap: Number(formatTokenAmount(1_000, _purchaseToken.decimals)),
                hardCap: Number(formatTokenAmount(10_000, _purchaseToken.decimals)),
                minimumAmount: Number(formatTokenAmount(100, _purchaseToken.decimals)),
                maximumAmount: Number(formatTokenAmount(9000, _purchaseToken.decimals))
            },
            vesting: {
                cliff: 0,//Seconds
                duration: 30*24*60*60,//Seconds
                unlockFrequency: 0,//0: unlock immediately, 1: fully unlock after, others: unlock after each period
            },
            tokenomics: [{
                title: "Public Sale",
                value: 25
            }, {
                title: "Liquidity",
                value: 65
            }, {
                title: "Team",
                value: 10
            }],
            distribution: {
                fairlaunch: 250_000_000,
                liquidity: 650_000_000,
                team: {
                    title: "Team",
                    description: "Team allocation",
                    total: 100_000_000,
                    vesting: {
                        cliff: 0,//Seconds
                        duration: 30*24*60*60,//Seconds
                        unlockFrequency: 0,//0: unlock immediately, 1: fully unlock after, others: unlock after each period
                    },
                    recipients: [
                        {
                            amount: 60_000_000,
                            address: "lekqg-fvb6g-4kubt-oqgzu-rd5r7-muoce-kppfz-aaem3-abfaj-cxq7a-dqe",
                            note: ["Founder"]
                        },
                        {
                            amount: 40_000_000,
                            address: "v57dj-hev4p-lsvdl-dckvv-zdcvg-ln2sb-tfqba-nzb4g-iddrv-4rsq3-mae",
                            note: ["Developer"]
                        }
                    ]
                },
                others: []
            },
            creator : "lekqg-fvb6g-4kubt-oqgzu-rd5r7-muoce-kppfz-aaem3-abfaj-cxq7a-dqe",
            affiliate: 0,//Percent
            fee: 3,
            restrictedArea: []
        };
        let _whitelist = ["lekqg-fvb6g-4kubt-oqgzu-rd5r7-muoce-kppfz-aaem3-abfaj-cxq7a-dqe"];
        console.log('installll', _params);
        let _rs = await install(_params, _whitelist);
        console.log('_', _rs);
    }
</script>
<template>
    <Toolbar :current="`Create`" :parents="[{title: 'Launchpad', to: '/launchpad'}]"/>

    <div class="stepper stepper-pills stepper-column d-flex flex-column flex-xl-row flex-row-fluid first" id="kt_create_account_stepper" data-kt-stepper="true">
            <!--begin::Aside-->
            <div class="d-flex justify-content-center bg-body rounded justify-content-xl-start flex-row-auto w-100 w-xl-300px w-xxl-300px me-9">
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
                                <h3 class="stepper-title">Launch Info</h3>
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
                                <h3 class="stepper-title">Additional Info</h3>
                                <div class="stepper-desc fw-bold">Introduce about your project</div>
                            </div>
                            <!--end::Label-->
                        </div>
                        <!--end::Step 4-->
                        <!--begin::Step 5-->
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
                <form class="py-5 w-100 px-10 fv-plugins-bootstrap5 fv-plugins-framework" novalidate="novalidate" id="kt_create_account_form">
                    <!--begin::Step 1-->
                    <div :class="steps[0]" data-kt-stepper-element="content">
                        <!--begin::Wrapper-->
                        <div class="w-100">
                            <!--begin::Heading-->
                            <div class="pb-10 pb-lg-15">
                                <!--begin::Title-->
                                <h2 class="fw-bolder d-flex align-items-center text-dark">Choose Launchpad Type
                                <i class="fas fa-exclamation-circle ms-2 fs-7" data-bs-toggle="tooltip" title="" data-bs-original-title="Billing is issued based on your selected account type" aria-label="Billing is issued based on your selected account type"></i></h2>
                                <!--end::Title-->
                                <!--begin::Notice-->
                                <div class="text-muted fw-bold fs-6">If you need more info, please check out
                                <a href="#" class="link-primary fw-bolder">Help Page</a>.</div>
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
                                        <input type="radio" class="btn-check" name="account_type" value="personal" checked="checked" id="normal">
                                        <label class="btn btn-outline btn-outline-dashed btn-outline-default p-7 d-flex align-items-center mb-10" for="normal">
                                            <!--begin::Svg Icon | path: icons/duotune/communication/com005.svg-->
                                            <span class="svg-icon svg-icon-3x me-5">
                                                <svg xmlns="http://www.w3.org/2000/svg" width="24" height="24" viewBox="0 0 24 24" fill="none">
                                                    <path d="M20 14H18V10H20C20.6 10 21 10.4 21 11V13C21 13.6 20.6 14 20 14ZM21 19V17C21 16.4 20.6 16 20 16H18V20H20C20.6 20 21 19.6 21 19ZM21 7V5C21 4.4 20.6 4 20 4H18V8H20C20.6 8 21 7.6 21 7Z" fill="black"></path>
                                                    <path opacity="0.3" d="M17 22H3C2.4 22 2 21.6 2 21V3C2 2.4 2.4 2 3 2H17C17.6 2 18 2.4 18 3V21C18 21.6 17.6 22 17 22ZM10 7C8.9 7 8 7.9 8 9C8 10.1 8.9 11 10 11C11.1 11 12 10.1 12 9C12 7.9 11.1 7 10 7ZM13.3 16C14 16 14.5 15.3 14.3 14.7C13.7 13.2 12 12 10.1 12C8.10001 12 6.49999 13.1 5.89999 14.7C5.59999 15.3 6.19999 16 7.39999 16H13.3Z" fill="black"></path>
                                                </svg>
                                            </span>
                                            <!--end::Svg Icon-->
                                            <!--begin::Info-->
                                            <span class="d-block fw-bold text-start">
                                                <span class="text-dark fw-bolder d-block fs-4 mb-2">Normal</span>
                                                <span class="text-muted fw-bold fs-6">Start launchpad from your existed Token</span>
                                            </span>
                                            <!--end::Info-->
                                        </label>
                                        <!--end::Option-->
                                    <div class="fv-plugins-message-container invalid-feedback"></div></div>
                                    <!--end::Col-->
                                    <!--begin::Col-->
                                    <div class="col-lg-6">
                                        <!--begin::Option-->
                                        <input type="radio" class="btn-check" name="account_type" value="corporate" id="dao-model" @click="installLaunchpad">
                                        <label class="btn btn-outline btn-outline-dashed btn-outline-default p-7 d-flex align-items-center" for="dao-model">
                                            <!--begin::Svg Icon | path: icons/duotune/finance/fin006.svg-->
                                            <span class="svg-icon svg-icon-3x me-5">
                                                <svg xmlns="http://www.w3.org/2000/svg" width="24" height="24" viewBox="0 0 24 24" fill="none">
                                                    <path opacity="0.3" d="M20 15H4C2.9 15 2 14.1 2 13V7C2 6.4 2.4 6 3 6H21C21.6 6 22 6.4 22 7V13C22 14.1 21.1 15 20 15ZM13 12H11C10.5 12 10 12.4 10 13V16C10 16.5 10.4 17 11 17H13C13.6 17 14 16.6 14 16V13C14 12.4 13.6 12 13 12Z" fill="black"></path>
                                                    <path d="M14 6V5H10V6H8V5C8 3.9 8.9 3 10 3H14C15.1 3 16 3.9 16 5V6H14ZM20 15H14V16C14 16.6 13.5 17 13 17H11C10.5 17 10 16.6 10 16V15H4C3.6 15 3.3 14.9 3 14.7V18C3 19.1 3.9 20 5 20H19C20.1 20 21 19.1 21 18V14.7C20.7 14.9 20.4 15 20 15Z" fill="black"></path>
                                                </svg>
                                            </span>
                                            <!--end::Svg Icon-->
                                            <!--begin::Info-->
                                            <span class="d-block fw-bold text-start">
                                                <span class="text-dark fw-bolder d-block fs-4 mb-2">DAO Model</span>
                                                <span class="text-muted fw-bold fs-6">Tokens will be governed by the community</span>
                                            </span>
                                            <!--end::Info-->
                                        </label>
                                        <!--end::Option-->
                                    </div>
                                    <!--end::Col-->
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
                                <h2 class="fw-bolder d-flex align-items-center text-dark">Verify Token</h2>
                                <div class="text-muted fw-bold fs-6">Verify token and choose currency, fees etc...</div>
                            </div>
                            <div class="fv-row fv-plugins-icon-container fv-plugins-bootstrap5-row-valid">
                                <div class="row mb-5">
                            <div class="col-md-12 fv-row">
                                <label class="d-flex flex-stack fs-6 fw-bold mb-2"><span class="required">Token Canister ID</span>
                                    <a href="#" class="badge badge-light-danger ms-5" v-if="tokenId">- Remove</a>
                                    <a href="#" class="badge badge-light-primary ms-5" v-if="tokenId==''">+ Paste</a>
                                </label>
                                <input type="text" class="form-control fs-6" v-model="tokenId" placeholder="Enter Token Canister ID" required />
                            </div>
                        </div>
                        <div class="d-flex align-items-center mb-5" v-if="tokenInfo">
                            
							<div class="symbol symbol-50px symbol-circle me-3">
								<img src="https://psh4l-7qaaa-aaaap-qasia-cai.raw.icp0.io/6ytv5-fqaaa-aaaap-qblcq-cai.png" />
								<!-- <span class="symbol-label fs-2x fw-bold text-primary bg-light-primary">{{ tokenInfo?tokenInfo.symbol.charAt(0):'IC' }}</span> -->
							</div>
							<!--begin::Info-->
							<div class="d-flex flex-column">
								<!--begin::Name-->
								<a href="#" class="fs-4 fw-bolder text-gray-900 text-hover-primary me-2">{{ tokenInfo.name }}</a>
								<!--end::Name-->
								<a href="#" class="fs-7 text-gray-600 text-hover-primary">{{tokenInfo.symbol }} <span class="badge badge-light-info">{{ tokenInfo.standard }}</span></a>
                                
							</div>
							<!--end::Info-->
						</div>
                    <!--end::Summary-->
                    
                    <div class="separator separator-dashed my-0"></div>
                    <div class="py-1 fs-6 px-5 notice bg-light-primary rounded border-primary border border-dashed p-6">
                        <div class="fw-bolder mt-2">Canister ID</div>
                        <div class="text-primary"><ClickToCopy :text="tokenId">{{ tokenId }}</ClickToCopy></div>
                        <div class="fw-bolder mt-3">Total supply</div>
                        <div class="text-gray-600">{{ currencyFormat(tokenInfo.supply) }}</div>
                        <div class="fw-bolder mt-3">Controllers</div>
                        <div class="text-gray-600">{{ tokenInfo.controllers }}</div>
                    </div>
                    <div class="separator separator-dashed mb-10"></div>

                        <div class="row mb-3">
                            <div class="col-md-6 fv-row">
                                <label class="fs-6 fw-bold form-label mb-2">Currency</label>
                                <div class="row fv-row">
                                    <div class="col-12">
                                        <select name="listing" class="form-select" v-model="launchpad.currency" readonly>
                                            <option :value="config.LEDGER_CANISTER_ID">ICP</option>
                                            <option value="icto" disabled>ICTO</option>
                                        </select>
                                        <div class="form-text">Participants will pay with <strong>ICP</strong> for your token</div>
                                    </div>
                                </div>
                            </div>
                            <div class="col-md-6 fv-row">
                            <label class="d-flex align-items-center fs-6 fw-bold mb-2"><span class="">Launch Fee</span></label>

                            <div class="input-group mb-3">
                                <span class="input-group-text" id="hardcap">%</span>
                                <input type="text" class="form-control" :value="config.LAUNCHPAD_FEE" disabled>
                            </div>
                            <div class="form-text">ICP raised only (Recommended)</div>
                            
                        </div>
                        </div>
                        <div class="row mb-2">
                            <div class="col-md-6 fv-row">
                                <label class="d-flex align-items-center fs-6 fw-bold mb-2"><span class="">Affiliate Program</span></label>
                                <div class="form-check form-check-solid form-switch fv-row">
                                    <input class="form-check-input w-45px h-30px" type="checkbox" id="allowmarketing" checked="checked" v-model="launchpad.affiliate">
                                    <label class="form-check-label" for="allowmarketing"></label>
                                </div>
                            
                            </div>
                            <div class="col-md-6 fv-row" v-if="launchpad.affiliate">
                                <label class="d-flex align-items-center fs-6 fw-bold mb-2"><span class="">Affiliate amount (%)</span></label>
                                <div class="input-group">
                                    <input type="number" min="0" max="5" class="form-control fw-normal" v-model="launchpad.affiliateAmount" placeholder="Min:1 - Max: 5, Set 0 = disable" />
                                </div>
                                <div class="form-text">The amount of raised currency that uses for the affiliate program.</div>
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
                                <h2 class="fw-bolder d-flex align-items-center text-dark">Launch Info</h2>
                                <div class="text-muted fw-bold fs-6">All details about your sales
</div>
                            </div>
                            <div class="fv-row fv-plugins-icon-container fv-plugins-bootstrap5-row-valid">
                                <div class="row mb-5">
                                    <div class="col-md-12 fv-row">
                                        <label class="d-flex align-items-center fs-6 fw-bold mb-2"><span class="required">Total <span v-if="tokenInfo" class="text-primary">{{tokenInfo.symbol }}</span> for sell</span></label>
                                        <money3 v-model.number="launchpad.totalToken" class="form-control"  v-bind="money3Config" @change="calTokenPrice"></money3>
                                    </div>
                                </div>
                                <div class="row mb-5">
                                    <div class="col-md-3 fv-row">
                                        <label class="d-flex align-items-center fs-6 fw-bold mb-2"><span class="required">Soft cap</span></label>

                                        <div class="input-group mb-3">
                                            <span class="input-group-text" id="softcap">ICP</span>
                                            <money3 v-model.number="launchpad.softcap" class="form-control"  v-bind="money3Config" @change="calTokenPrice"></money3>
                                        </div>
                                        <div class="form-text">Minimum ICP amount</div>

                                    </div>
                                    <div class="col-md-3 fv-row">
                                        <label class="d-flex align-items-center fs-6 fw-bold mb-2"><span class="">&nbsp;</span></label>

                                        <div class="input-group mb-3">
                                            <span class="input-group-text" id="hardcap">$</span>
                                            <input type="text" class="form-control" :value="currencyFormat(launchpad.softcap*icpPrice)" disabled>
                                        </div>
                                    </div>
                                    <div class="col-md-3 fv-row">
                                        <label class="d-flex align-items-center fs-6 fw-bold mb-2"><span class="">Token Price</span></label>
                                        <div class="input-group mb-3">
                                            <span class="input-group-text" id="hardcap">ICP</span>
                                            <input type="text" class="form-control" v-model="launchpad.minPrice" disabled>
                                        </div>
                                    </div>
                                    <div class="col-md-3 fv-row">
                                        <label class="d-flex align-items-center fs-6 fw-bold mb-2"><span class="">&nbsp;</span></label>
                                        <div class="input-group mb-3">
                                            <span class="input-group-text" id="hardcap">$</span>
                                            <input type="text" class="form-control" :value="launchpad.minPrice*icpPrice" disabled>
                                        </div>
                                    </div>
                                </div>
                                <div class="row mb-5">
                                    <div class="col-md-3 fv-row">
                                        <label class="d-flex align-items-center fs-6 fw-bold mb-2"><span class="required">Hard cap</span></label>
                                        <div class="input-group mb-3">
                                            <span class="input-group-text" id="hardcap">ICP</span>
                                            <money3 v-model.number="launchpad.hardcap" class="form-control"  v-bind="money3Config" @change="calTokenPrice"></money3>
                                        </div>
                                        <div class="form-text">Maximum ICP amount</div>
                                    </div>
                                    <div class="col-md-3 fv-row">
                                        <label class="d-flex align-items-center fs-6 fw-bold mb-2"><span class="">&nbsp;</span></label>
                                        <div class="input-group mb-3">
                                            <span class="input-group-text" id="hardcap">$</span>
                                            <input type="text" class="form-control" :value="currencyFormat(launchpad.hardcap*icpPrice)" disabled>
                                        </div>
                                    </div>
                                    <div class="col-md-3 fv-row">
                                        <label class="d-flex align-items-center fs-6 fw-bold mb-2"><span class="">Token Price</span></label>
                                        <div class="input-group mb-3">
                                            <span class="input-group-text" id="hardcap">ICP</span>
                                            <input type="text" class="form-control" v-model="launchpad.maxPrice" disabled>
                                        </div>
                                    </div>
                                    <div class="col-md-3 fv-row">
                                        <label class="d-flex align-items-center fs-6 fw-bold mb-2"><span class="">&nbsp;</span></label>
                                        <div class="input-group mb-3">
                                            <span class="input-group-text" id="hardcap">$</span>
                                            <input type="text" class="form-control" :value="launchpad.maxPrice*icpPrice" disabled>
                                        </div>
                                    </div>
                                </div>
                                <div class="row mb-5">
                                    <div class="col-md-6 fv-row">
                                        <label class="d-flex align-items-center fs-6 fw-bold mb-2"><span class="required">Minimum contribution</span></label>
                                        <div class="input-group mb-3">
                                            <span class="input-group-text" id="minbuy">ICP</span>
                                            <input type="text" class="form-control" v-model="launchpad.minBuy" required>
                                        </div>
                                    </div>
                                    <div class="col-md-6 fv-row">
                                        <label class="d-flex align-items-center fs-6 fw-bold mb-2"><span class="required">Maximum contribution</span></label>
                                        <div class="input-group mb-3">
                                            <span class="input-group-text" id="maxbuy">ICP</span>
                                            <money3 v-model.number="launchpad.maxBuy" class="form-control"  v-bind="money3Config" @change="calTokenPrice" required></money3>
                                        </div>
                                    </div>
                                </div>
                                <div class="row mb-5">
                                    <div class="col-md-6 fv-row">
                                        <label class="d-flex align-items-center fs-6 fw-bold mb-2"><span class="required">Start Time (UTC)</span></label>
                                        <VueDatePicker v-model="launchpad.startTime" :min-date="new Date()" :enable-time-picker="true" placeholder="Start time" time-picker-inline auto-apply></VueDatePicker>
                                    </div>
                                    <div class="col-md-6 fv-row">
                                        <label class="d-flex align-items-center fs-6 fw-bold mb-2"><span class="required">End Time (UTC)</span></label>
                                        <VueDatePicker v-model="launchpad.endTime" :min-date="new Date()" :enable-time-picker="true" time-picker-inline auto-apply  placeholder="End time"></VueDatePicker>
                                    </div>
                                </div>
                                <!-- <div class="separator separator-dashed mb-7"></div>
                                <div class="row mb-5">
                                    <div class="col-md-12 fv-row">
                                        <div class="form-check form-switch form-check-custom">
                                            <input class="form-check-input" type="checkbox" id="whitelist" checked="checked" v-model="launchpad.whitelist">
                                            <label class="form-check-label  fs-6 fw-bold" for="whitelist">Enable Whitelist</label>
                                        </div>
                                        <div class="form-text text-primary">The public sale will begin one hour after the whitelist sale starts!</div>
                                    </div>
                                </div>
                                <div class="row mb-5" v-if="launchpad.whitelist">
                                    <div class="col-md-12 fv-row">
                                        <label class="d-flex align-items-center fs-6 fw-bold mb-2"><span class="">Whitelist allocation (%)</span></label>
                                        <input type="number" min="10" max="100" class="form-control fw-normal" v-model="launchpad.whitelistAllocation" placeholder="Percent" required />
                                        <div class="form-text">The remaining tokens after the whitelist sale will be transferred to the public sale!</div>
                                    </div>
                                </div>

                                <div class="mb-5 fv-row fv-plugins-icon-container" v-if="launchpad.whitelist">
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
                                </div>
                                <div class="row mb-5" v-if="launchpad.whitelist">
                                    <div class="col-md-12 fv-row"  v-if="launchpad.whitelistType==0">
                                        <input type="text" class="form-control fw-normal fs-7" v-model="launchpad.whitelistData" placeholder="Enter NFT Canister ID, Ex: oeee4-qaaaa-aaaak-qaaeq-cai" required />
                                        <div class="form-text">Support EXT NFT Collection (From Entrepot, Toniq marketplace)</div>
                                    </div>
                                    <div class="col-md-12 fv-row" v-if="launchpad.whitelistType==1" >
                                        <textarea class="form-control fw-normal fs-7" v-model="launchpad.whitelistData" placeholder="Each Principal will be listed on a separate line" rows="4"></textarea>
                                    </div>
                                </div> -->
                        
                                <div class="separator separator-dashed mb-3"></div>
                                <div class="row mb-10">
                                    <div class="col-md-6 fv-row">
                                            <label class="fs-6 fw-bold form-label mb-2">Listing on DEX</label>
                                            <div class="row fv-row">
                                                <div class="col-12">
                                                    <select name="listing" class="form-select" v-model="launchpad.listing" @change="changeListing">
                                                        <option value="manually">Manually (For seed/presale)</option>
                                                        <option value="ICPSwap" selected>Auto listing (ICPSwap)</option>
                                                    </select>
                                                    <div class="form-text">Will be add lidquidity after a successful launch.</div>
                                                </div>
                                            </div>
                                        </div>
                                    <div class="col-md-6 fv-row">
                                        <label class="d-flex align-items-center fs-6 fw-bold mb-2"><span class="">{{ launchpad.listing !='manually'?launchpad.listing:'' }} Liquidity(%)</span></label>
                                        <input type="number" min="51" max="100" class="form-control" v-model="launchpad.listingLiquidity" placeholder="Min: 51, Max: 100" :disabled="launchpad.listing == 'manually'" />

                                        <div class="form-text">
                                            The percentage of raised funds that should be allocated to LP
                                        </div>
                                    </div>
                                </div>
                                <div class="row mb-10">
                                    <div class="col-md-6 fv-row">
                                        <label class="d-flex align-items-center fs-6 fw-bold mb-2"><span class="">Listing Time (UTC)</span></label>
                                        <VueDatePicker v-model="launchpad.listingTime" :min-date="new Date()" :enable-time-picker="true" placeholder="Select listing time" time-picker-inline auto-apply :disabled="launchpad.listing == 'manually'"></VueDatePicker>
                                    </div>
                                    <div class="col-md-6 fv-row">
                                        <label class="d-flex align-items-center fs-6 fw-bold mb-2"><span class="">Liquidity Lock-up</span></label>
                                        <input type="text" class="form-control" v-model="launchpad.liquidityLockup" placeholder="Days" disabled />
                                    </div>
                                </div>
                                <div class="separator separator-dashed mb-3"></div>
                                <div class="row mb-10">
                                    <div class="col-md-12 fv-row">
                                        <label class="fs-5 fw-bolder form-label mb-2"><i class="fas fa-chart-pie text-primary"></i> Tokenomics design</label>
                                        <div v-for="(allocate, index) in launchpad.tokenomics" :key="index" class="row fv-row mb-2">
                                            <div class="col-7"><input type="text" v-model="allocate.title" class="form-control form-control-sm" placeholder="Allocation" /></div>
                                            <div class="col-3"><input type="number" v-model="allocate.value" min="0" max="100" class="form-control form-control-sm" placeholder="%" /></div>
                                            <div class="col-2 d-flex flex-column">
                                                <button type="button" class="btn btn-sm btn-light-primary" @click="addMorePie()" v-show="index == 0">+ Add more</button>
                                                <button type="button" class="btn btn-sm btn-light-danger" @click="removePie(index)" v-show="index != 0">Remove</button>
                                            </div>
                                        </div>
                                    </div>
                                    <div class="col-md-12 fv-row p-40 mh-250">
                                        <Tokenomic :data="launchpad.tokenomics"></Tokenomic>
                                    </div>
                                </div>
                                
                                

                                        </div>
                                    </div>
                                </div>
                                <!--end::Step 3-->
                                <!--begin::Step 4-->
                                <div data-kt-stepper-element="content" :class="steps[3]">
                                    <!--begin::Wrapper-->
                                    <div class="w-100">
                                        <!--begin::Heading-->
                                        <div class="pb-10 pb-lg-15">
                                            <!--begin::Title-->
                                            <h2 class="fw-bolder text-dark">Additional Info</h2>
                                            <!--end::Title-->
                                            <!--begin::Notice-->
                                            <div class="text-muted fw-bold fs-6">If you need more info, please check out
                                            <a href="#" class="text-primary fw-bolder">Help Page</a>.</div>
                                            <!--end::Notice-->
                                        </div>
                                        <!--end::Heading-->
                                        <!--begin::Input group-->
                                        <div class="d-flex flex-column mb-7 fv-row fv-plugins-icon-container">
                                            <!--begin::Label-->
                                            <label class="d-flex align-items-center fs-6 fw-bold form-label mb-2">
                                                <span class="required">Project Name</span>
                                            </label>
                                            <!--end::Label-->
                                            <input type="text" class="form-control " placeholder="" name="card_name" value="">
                                        </div>
                                        <div class="d-flex flex-column mb-7 fv-row fv-plugins-icon-container">
                                            <!--begin::Label-->
                                            <label class="d-flex align-items-center fs-6 fw-bold form-label mb-2">
                                                <span class="required">Description</span>
                                            </label>
                                            <!--end::Label-->
                                            <textarea class="form-control"></textarea>
                                        </div>
                                        <div class="d-flex flex-column mb-7 fv-row fv-plugins-icon-container">
                                            <!--begin::Label-->
                                            <label class="d-flex align-items-center fs-6 fw-bold form-label mb-2">
                                                <span class="required">Twitter Link</span>
                                            </label>
                                            <!--end::Label-->
                                            <input type="text" class="form-control fw-normal" name="twitter" placeholder="https://twitter.com/icto_app" >
                                            <div class="fs-7 fw-normal text-muted">Create a public post with launchpad id (will be available after completing the steps) using this twitter account, we will review and issue a project verification checkmark <Verified></Verified></div>

                                        </div>
                                        <div class="d-flex flex-column mb-7 fv-row fv-plugins-icon-container">
                                            <!--begin::Label-->
                                            <label class="d-flex align-items-center fs-6 fw-bold form-label mb-2">
                                                <span class="">Official Website</span>
                                            </label>
                                            <!--end::Label-->
                                            <input type="text" class="form-control fw-normal" name="twitter" placeholder="https://website.com" >
                                        </div>
                                        <div class="d-flex flex-column mb-7 fv-row fv-plugins-icon-container">
                                            <!--begin::Label-->
                                            <label class="d-flex align-items-center fs-6 fw-bold form-label mb-2">
                                                <span class="">Telegram</span>
                                            </label>
                                            <!--end::Label-->
                                            <input type="text" class="form-control fw-normal" name="twitter" placeholder="https://t.me/icto_app" >
                                        </div>
                                        <div class="d-flex flex-column mb-7 fv-row fv-plugins-icon-container">
                                            <!--begin::Label-->
                                            <label class="d-flex align-items-center fs-6 fw-bold form-label mb-2">
                                                <span class="">Discord</span>
                                            </label>
                                            <!--end::Label-->
                                            <input type="text" class="form-control fw-normal" name="twitter" placeholder="https://dg.gg/icto_app" >
                                        </div>
                                        <div class="d-flex flex-column mb-7 fv-row fv-plugins-icon-container">
                                            <!--begin::Label-->
                                            <label class="d-flex align-items-center fs-6 fw-bold form-label mb-2">
                                                <span class="">Open Chat</span>
                                            </label>
                                            <!--end::Label-->
                                            <input type="text" class="form-control fw-normal" name="twitter" placeholder="https://oc.app/icto_app" >
                                        </div>
                                        <!--end::Input group-->
                                        
                                    </div>
                                    <!--end::Wrapper-->
                                </div>
                                <!--end::Step 4-->
                                <!--begin::Step 5-->
                                <div data-kt-stepper-element="content" :class="steps[4]">
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
                                            <!--begin::Text-->
                                            <div class="fs-6 text-gray-600 mb-5">Writing headlines for blog posts is as much an art as it is a science and probably warrants its own post, but for all advise is with what works for your great &amp; amazing audience.</div>
                                            <!--end::Text-->
                                            <!--begin::Alert-->
                                            <!--begin::Notice-->
                                            <div class="notice d-flex bg-light-warning rounded border-warning border border-dashed p-6">
                                                <!--begin::Icon-->
                                                <!--begin::Svg Icon | path: icons/duotune/general/gen044.svg-->
                                                <span class="svg-icon svg-icon-2tx svg-icon-warning me-4">
                                                    <svg xmlns="http://www.w3.org/2000/svg" width="24" height="24" viewBox="0 0 24 24" fill="none">
                                                        <rect opacity="0.3" x="2" y="2" width="20" height="20" rx="10" fill="black"></rect>
                                                        <rect x="11" y="14" width="7" height="2" rx="1" transform="rotate(-90 11 14)" fill="black"></rect>
                                                        <rect x="11" y="17" width="2" height="2" rx="1" transform="rotate(-90 11 17)" fill="black"></rect>
                                                    </svg>
                                                </span>
                                                <!--end::Svg Icon-->
                                                <!--end::Icon-->
                                                <!--begin::Wrapper-->
                                                <div class="d-flex flex-stack flex-grow-1">
                                                    <!--begin::Content-->
                                                    <div class="fw-bold">
                                                        <h4 class="text-gray-900 fw-bolder">We need your attention!</h4>
                                                        <div class="fs-6 text-gray-700">To start using great tools, please, please
                                                        <a href="#" class="fw-bolder">Create Team Platform</a></div>
                                                    </div>
                                                    <!--end::Content-->
                                                </div>
                                                <!--end::Wrapper-->
                                            </div>
                                            <!--end::Notice-->
                                            <!--end::Alert-->
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
                                        <button type="button" class="btn btn-lg btn-light-primary me-3" @click="changeStep(currentStep-1)" v-if="currentStep>0">
                                        <!--begin::Svg Icon | path: icons/duotune/arrows/arr063.svg-->
                                        <span class="svg-icon svg-icon-4 me-1">
                                            <svg xmlns="http://www.w3.org/2000/svg" width="24" height="24" viewBox="0 0 24 24" fill="none">
                                                <rect opacity="0.5" x="6" y="11" width="13" height="2" rx="1" fill="black"></rect>
                                                <path d="M8.56569 11.4343L12.75 7.25C13.1642 6.83579 13.1642 6.16421 12.75 5.75C12.3358 5.33579 11.6642 5.33579 11.25 5.75L5.70711 11.2929C5.31658 11.6834 5.31658 12.3166 5.70711 12.7071L11.25 18.25C11.6642 18.6642 12.3358 18.6642 12.75 18.25C13.1642 17.8358 13.1642 17.1642 12.75 16.75L8.56569 12.5657C8.25327 12.2533 8.25327 11.7467 8.56569 11.4343Z" fill="black"></path>
                                            </svg>
                                        </span>
                                        <!--end::Svg Icon-->Back</button>
                                    </div>
                                    <!--end::Wrapper-->
                                    <!--begin::Wrapper-->
                                    <div>
                                        <button type="button" class="btn btn-lg btn-primary me-3" data-kt-stepper-action="submit">
                                            <span class="indicator-label">Submit
                                            <!--begin::Svg Icon | path: icons/duotune/arrows/arr064.svg-->
                                            <span class="svg-icon svg-icon-3 ms-2 me-0">
                                                <svg xmlns="http://www.w3.org/2000/svg" width="24" height="24" viewBox="0 0 24 24" fill="none">
                                                    <rect opacity="0.5" x="18" y="13" width="13" height="2" rx="1" transform="rotate(-180 18 13)" fill="black"></rect>
                                                    <path d="M15.4343 12.5657L11.25 16.75C10.8358 17.1642 10.8358 17.8358 11.25 18.25C11.6642 18.6642 12.3358 18.6642 12.75 18.25L18.2929 12.7071C18.6834 12.3166 18.6834 11.6834 18.2929 11.2929L12.75 5.75C12.3358 5.33579 11.6642 5.33579 11.25 5.75C10.8358 6.16421 10.8358 6.83579 11.25 7.25L15.4343 11.4343C15.7467 11.7467 15.7467 12.2533 15.4343 12.5657Z" fill="black"></path>
                                                </svg>
                                            </span>
                                            <!--end::Svg Icon--></span>
                                            <span class="indicator-progress">Please wait...
                                            <span class="spinner-border spinner-border-sm align-middle ms-2"></span></span>
                                        </button>
                                        <button type="button" class="btn btn-lg btn-primary" @click="changeStep(currentStep+1)" v-if="currentStep<=3">Continue
                                        <!--begin::Svg Icon | path: icons/duotune/arrows/arr064.svg-->
                                        <span class="svg-icon svg-icon-4 ms-1 me-0">
                                            <svg xmlns="http://www.w3.org/2000/svg" width="24" height="24" viewBox="0 0 24 24" fill="none">
                                                <rect opacity="0.5" x="18" y="13" width="13" height="2" rx="1" transform="rotate(-180 18 13)" fill="black"></rect>
                                                <path d="M15.4343 12.5657L11.25 16.75C10.8358 17.1642 10.8358 17.8358 11.25 18.25C11.6642 18.6642 12.3358 18.6642 12.75 18.25L18.2929 12.7071C18.6834 12.3166 18.6834 11.6834 18.2929 11.2929L12.75 5.75C12.3358 5.33579 11.6642 5.33579 11.25 5.75C10.8358 6.16421 10.8358 6.83579 11.25 7.25L15.4343 11.4343C15.7467 11.7467 15.7467 12.2533 15.4343 12.5657Z" fill="black"></path>
                                            </svg>
                                        </span>
                                        <!--end::Svg Icon--></button>
                                    </div>
                                    <!--end::Wrapper-->
                                </div>
                                <!--end::Actions-->
                            <div></div><div></div><div></div><div></div></form>
                <!--end::Form-->
            </div>
            <!--end::Content-->
        </div>
</template>