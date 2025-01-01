<script setup>
    import { ref, onMounted, watchEffect, watch, computed } from 'vue';
    import Tokenomic from '@/components/launchpad/Tokenomic.vue';
    import VueCountdown from '@chenfengyuan/vue-countdown';
    import Timeline from '@/components/launchpad/Timeline.vue';
    import Links from '@/components/Links.vue';
    import RefererLink from '@/components/launchpad/RefererLink.vue';
    import MyStats from '@/components/launchpad/MyStats.vue';
    import ProjectScore from '@/components/launchpad/ProjectScore.vue';
    import BlockIDNotice from '@/components/launchpad/BlockIDNotice.vue';
    import 'vue-skeletor/dist/vue-skeletor.css';
    import { Skeletor } from 'vue-skeletor';

    import moment from 'moment';
    import { timeFromNano, showError, showSuccess, showLoading, closeMessage, getPoolStatus, getRef, saveRef, shortPrincipal } from '@/utils/common';
    import { getInfo, useCommit, getStatus, getTopAffiliates, checkEligibleToCommit, useCreateShortlink, getShortlink, deleteShortLink } from '@/services/Launchpad';
    import { formatTokenomic } from '@/utils/launchpad';
    import { useRoute } from 'vue-router';
    import { parseTokenAmount, formatTokenAmount, currencyFormat } from '@/utils/token';
    import { useGetMyBalance, useTokenApprove } from '@/services/Token';
    import walletStore from "@/store";
    const router = useRoute();
    const launchpadId = router.params.launchpadId;
    const purchaseToken = ref(null);
    const eligibleToCommit = ref(null);
    const saleToken = ref(null);
    const depositAmount = ref(0);
    const countdown = ref(10 * 24 * 60 * 60 * 1000);
    const myBalance = ref(0);
    const tokennomics = ref([]);
    const projectAssessment = ref({
        isDAO: true,
        isKYC: true,
        isAudited: true,
        isVerified: true,
        autoLockLP: true,
        percentLPLock: 88,
        teamAllocationPercent: 10,
    });
    // const { data: tokenTransactions, isError, error, isLoading: isTransLoading, isRefetching: isTransRefetching, refetch: refreshTransactions } = useGetTransactions(tokenId, 'icrc2', 0, 100);
    const { data: launchpadInfo, isError, error, isLoading, isRefetching, refetch, isFetched } = getInfo(launchpadId);
    const { data: topAffiliates } = getTopAffiliates(launchpadId);
    const { data: status, isError: isStatusError, error: statusError, isLoading: isStatusLoading, isRefetching: isStatusRefetching, refetch: refetchStatus } = getStatus(launchpadId);
    console.log('launchpadInfo', launchpadInfo);

    const onCountdownEnd = ()=>{
        console.log('Countdown end');
        if(status?.status == 'LIVE'){
            refetchStatus();
        }
    }
    // const launchpadInfo = ref(null);
    // import { useGetLaunchpad } from "@/services/Launchpad";
    const myStatsRef = ref(null)
    const updateMyStats = () => {
        myStatsRef.value?.refetch()
    }
    const checkPurchaseBalance = async()=>{
        // showLoading('Checking balance...');
        const _balance = await useGetMyBalance(purchaseToken.value.canisterId);
        myBalance.value = _balance;
        // closeMessage();
    }
    const getLaunchpadInfo = async () => {
        const _info = await getInfo();
        if (_info) {
            // launchpadInfo.value = _info;
            purchaseToken.value = launchpadInfo?.purchaseToken[0];
            depositAmount.value = parseTokenAmount(launchpadInfo?.launchParams?.minimumAmount, purchaseToken.value.decimals);
            countdown.value = moment.unix(Number(launchpadInfo?.timeline?.startTime)).diff(moment().utc());
        }
    }

    const launchStatus = computed(() => {
        return status.value?.status;
    });

    const selectMax = () => {
        //Select max will deduct the twite fees, one for approving, one for depositing
        let _max = myBalance.value;
        let _min = parseTokenAmount(launchpadInfo?.value?.launchParams?.minimumAmount, purchaseToken.value.decimals);
        //Subtract 0.0001 ICP for approving
        let _transactionFee = parseTokenAmount(purchaseToken.value.transferFee, purchaseToken.value.decimals);
        _max = _max - _transactionFee;
        //Subtract 0.0001 ICP for depositing
        let _finalAmount = _max - _transactionFee;
        if(_finalAmount < _min){
            showError('Insufficient funds, please top up your account, required: '+ (Number(_min)+_transactionFee*2).toFixed(4)+' '+purchaseToken.value.symbol);
            return;
        }else{
            depositAmount.value = _finalAmount.toFixed(4);
        }
    }

    const checkAmount = () => {
        if (depositAmount.value < launchpadInfo?.value?.launchParams?.minimumAmount) {
            depositAmount.value = launchpadInfo?.value?.launchParams?.minimumAmount;
            showError('Minimum amount is ' + launchpadInfo?.value?.launchParams?.minimumAmount);
        }
        if (depositAmount.value > launchpadInfo?.value?.launchParams?.maximumAmount) {
            depositAmount.value = launchpadInfo?.value?.launchParams?.maximumAmount;
            showError('Maximum amount is ' + launchpadInfo?.value?.launchParams?.maximumAmount);
        }
    }
    const checkEligible = async () => {
        eligibleToCommit.value = await checkEligibleToCommit(launchpadId);
    }

    const depositBtn = async () => {
        // checkAmount();
        Swal.fire({
		title: "Are you sure?",
		text: "Commit amount: "+ depositAmount.value + " "+ purchaseToken.value.symbol + " to this campaign?",
		icon: "warning",
		showCancelButton: true,
		confirmButtonColor: "#3085d6",
		cancelButtonColor: "#d33",
		confirmButtonText: "Yes, I confirmed!"
		}).then(async (result) => {
            if (result.isConfirmed) {
                let _amount = Number(formatTokenAmount(depositAmount.value, purchaseToken.value.decimals));

                //Step 1: Approve token
                showLoading("Approving ICP...");
                let _approved = await useTokenApprove(purchaseToken.value.canisterId, {spender: launchpadId, amount: depositAmount.value}, 8);
                if(_approved == null){
                    closeMessage();
                    return;
                }
                console.log('_approved', _approved);
                if(_approved && _approved.hasOwnProperty('Err')){
                    if (_approved.Err?.InsufficientFunds) {
                        showError('Insufficient Funds', true);
                    }else{
                        showError("Approve not succeed: "+JSON.stringify(_approved), true);
                    }
                    return;
                }
                //Step 2: Deposit
                showLoading('Processing your deposit, please wait...');
                let _refCode = getRef();
                try{
                    let _deposit = await useCommit(launchpadId, _amount, _refCode);
                    console.log('Deposit', launchpadId, _deposit, _amount);

                    if(_deposit && "ok" in _deposit) {
                        showSuccess('Your commit has been successfully processed!', true);
                        updateMyStats();
                    }else{
                        showError('Can not process, please try again later: '+JSON.stringify(_deposit), true);
                    }
                }catch(e){
                    showError(e, true);
                }
                
                refetchStatus();//Refresh status
            }
        });
        
    }
    
    watchEffect(() => {
        if (isFetched.value && launchpadInfo.value) {
            purchaseToken.value = launchpadInfo.value.purchaseToken;
            saleToken.value = launchpadInfo.value.saleToken;
            // depositAmount.value = parseTokenAmount(launchpadInfo.value.launchParams.minimumAmount, purchaseToken.value.decimals);
            tokennomics.value = formatTokenomic(launchpadInfo.value.distribution);
            if(walletStore.isLogged == true){
                console.log('Logged:', walletStore.isLogged);
                checkPurchaseBalance();
                checkEligible();
            };
        };
        if(status.value){
            if(status.value.status == "LIVE"){
                countdown.value = moment(timeFromNano(launchpadInfo?.value?.timeline?.endTime).valueOf()).diff(moment().utc());
            }else{
                countdown.value = moment(timeFromNano(launchpadInfo?.value?.timeline?.startTime).valueOf()).diff(moment().utc());
            }
        }
    });

    onMounted(() => {
        // getLaunchpadInfo();
        const urlParams = new URLSearchParams(window.location.search);
        const ref = urlParams.get('r');
        if (ref) {
            console.log('have ref:', ref);
            saveRef(ref.trim());
            // localStorage.setItem('refBy', ref);
        }
    });
</script>

<template>
    <Toolbar :current="launchpadInfo?launchpadInfo?.projectInfo?.name:'Launchpad details'" :parents="[{title: 'Launchpad', to: '/launchpad'}]" />

    <div class="row g-xxl-9">
        <div class="col-xxl-8">
            <div class="card mb-5 mb-xl-5">
                <div class="card-body pt-7 pb-0 px-0">
                    <div class="banner pb-10">
                        <Skeletor v-if="isLoading" height="220"></Skeletor>
                        <img src="https://i.imghippo.com/files/fySW2749NPI.png" alt="banner" v-else/>
                    </div> 
                    <div class="d-flex flex-wrap flex-sm-nowrap mb-1 px-5">
                        <!--begin: Pic-->
                        <div class="me-7 mb-4">
                            <div class="symbol symbol-80px symbol-lg-100px symbol-fixed position-relative">
                                <Skeletor v-if="isLoading" height="100px" width="100px"></Skeletor>
                                <img :src="launchpadInfo?.projectInfo?.logo" alt="image" v-else />
                            </div>
                        </div>
                        <!--end::Pic-->
                        <!--begin::Info-->
                        <div class="flex-grow-1">
                            <div class="d-flex justify-content-between align-items-start flex-wrap mb-2">
                                <!--begin::User-->
                                <div class="d-flex flex-column">
                                    <!--begin::Name-->
                                    <div class="d-flex align-items-center mb-1">
                                        <Skeletor v-if="isLoading" height="24px" width="100%"></Skeletor>
                                        <span class="text-gray-900 text-hover-primary fs-2 fw-bolder me-1" v-else>{{launchpadInfo?.projectInfo?.name}}</span>
                                        <Verified v-if="!isLoading" title="Verified by ICTO"></Verified>
                                    </div>
                                    <!--end::Name-->
                                    <!--begin::Info-->
                                    <div class="d-flex flex-wrap fw-bold fs-6 mb-2 pe-2">
                                        <Skeletor circle size="24" pill v-if="isLoading" v-for="i in 3" :key="i" class="me-2 mt-2" />
                                        <Links :links="launchpadInfo?.projectInfo?.links[0]" v-else />
                                    </div>
                                    <div v-if="isLoading" class="d-flex flex-wrap my-2">
                                        <Skeletor pill height="24px" width="100px" v-for="i in 3" :key="i" class="me-2"></Skeletor> 
                                    </div>
                                    <div v-else>
                                        <span class="badge badge-warning fw-bold px-4 py-2 ps-4 me-4"><i class="fas fa-percent text-white"></i> AFFILIATE</span> 
                                        <span class="badge badge-light-danger fw-bolder me-auto px-4 py-2 ps-4"><i class="fas fa-fire text-danger"></i> HOT #1</span>
                                        <span class="badge badge-light-success fw-bolder me-auto px-4 py-2 ps-4 ms-4" ><i class="fas fa-shield-alt text-success"></i> BLOCKID</span>
                                    </div>
                                    <!--end::Info-->
                                </div>
                                <div class="d-flex my-4">
                                    <Skeletor v-if="isLoading" height="20px"></Skeletor>
                                    <div class="d-flex fs-7 align-items-center" v-html="getPoolStatus(status?.status)" v-else></div>
                                </div>
                            </div>
                        </div>
                    </div>

                    <div class="separator"></div>
                    <div class="px-5 py-5">
                        <Skeletor v-for="i in 5" :key="i" v-if="isLoading"></Skeletor>
                        <div v-html="launchpadInfo?.projectInfo?.description" v-else></div>
                    </div>
                </div>
            </div>
            <div class="card mb-5 mb-xl-5">
                <div class="card-header ps-6">
                    <h3 class="card-title">Launch info</h3>
                </div>
                <div class="card-body p-1">
                    <div class="px-5 py-5" v-if="isLoading">
                        <Skeletor v-for="i in 5" :key="i"></Skeletor>
                    </div>
                    <div class="table-responsive" v-else>
                        <table class="table table-flush align-middle table-row-bordered table-hover gy-3 gs-5">
                            <tbody class="fs-7 fw-bold text-gray-600">
                                <tr>
                                    <td>Token Name</td>
                                    <td class="text-end fw-bolder"><img :src="launchpadInfo?.saleToken?.logo" class="w-30px" /> {{launchpadInfo?.saleToken?.name}}</td>
                                </tr>
                                <tr>
                                    <td>Token Symbol</td>
                                    <td class="text-end fw-bolder">{{launchpadInfo?.saleToken?.symbol}}</td>
                                </tr>
                                <tr>
                                    <td>Token Decimals</td>
                                    <td class="text-end fw-bolder">{{launchpadInfo?.saleToken?.decimals}}</td>
                                </tr>
                                <tr>
                                    <td>Token Canister</td>
                                    <td class="text-end fw-bolder text-primary">---</td>
                                </tr>
                                <tr>
                                    <td>Total Supply</td>
                                    <td class="text-end fw-bolder">88,888,888</td>
                                </tr>
                                <tr>
                                    <td>Tokens For Fairlaunch</td>
                                    <td class="text-end fw-bolder">{{currencyFormat(parseTokenAmount(launchpadInfo?.distribution?.fairlaunch?.total, saleToken.decimals))}}</td>
                                </tr>
                                <tr>
                                    <td>Tokens For Liquidity</td>
                                    <td class="text-end fw-bolder">{{currencyFormat(parseTokenAmount(launchpadInfo?.distribution?.liquidity?.total, saleToken.decimals))}}</td>
                                </tr>
                                <tr>
                                    <td>Initial Market Cap (estimate)</td>
                                    <td class="text-end fw-bolder">---</td>
                                </tr>
                                <tr>
                                    <td>Soft Cap</td>
                                    <td class="text-end fw-bolder">{{currencyFormat(parseTokenAmount(launchpadInfo?.launchParams?.softCap, purchaseToken.decimals))}} {{ purchaseToken.symbol }}</td>
                                </tr>
                                <tr>
                                    <td>Hard Cap</td>
                                    <td class="text-end fw-bolder">{{currencyFormat(parseTokenAmount(launchpadInfo?.launchParams?.hardCap, purchaseToken.decimals))}} {{ purchaseToken.symbol }}</td>
                                </tr>
                                <tr>
                                    <td>Min per user</td>
                                    <td class="text-end fw-bolder">{{parseTokenAmount(launchpadInfo?.launchParams?.minimumAmount, purchaseToken.decimals)}} {{ purchaseToken.symbol }}</td>
                                </tr>
                                <tr>
                                    <td>Limit per user</td>
                                    <td class="text-end fw-bolder">{{parseTokenAmount(launchpadInfo?.launchParams?.maximumAmount, purchaseToken.decimals)}} {{ purchaseToken.symbol }}</td>
                                </tr>
                                <tr>
                                    <td>Presale Start Time</td>
                                    <td class="text-end fw-bolder">{{timeFromNano(launchpadInfo?.timeline?.startTime)}}</td>
                                </tr>
                                <tr>
                                    <td>Presale End Time</td>
                                    <td class="text-end fw-bolder">{{timeFromNano(launchpadInfo?.timeline?.endTime)}}</td>
                                </tr>
                                <tr>
                                    <td>Listing On</td>
                                    <td class="text-end fw-bolder"><a href="https://app.icpswap.com" target="_blank">ICPSwap <i class="fas fa-external-link"></i></a></td>
                                </tr>
                            </tbody>
                        </table>
                    </div>
                </div>
            </div>
            <div class="card mb-5 mb-xl-5">
                <div class="card-header ps-6">
                    <h3 class="card-title">Tokenomics</h3>
                </div>
                <div class="card-body">
                    <Skeletor v-if="isLoading" height="20px"></Skeletor>
                    <Tokenomic :data="tokennomics" :legend="1" v-else/>
                </div>
            </div>
            <div class="card mb-5 mb-xl-5" v-if="status?.affiliate > 0">
                <div class="card-header ps-6">
                    <h3 class="card-title">Top Affiliates</h3>
                </div>
                <div class="card-body p-5">
                    <RefererLink :launchpadId="launchpadId" />
                    <div class="table-responsive">
                        <table class="table table-flush align-middle table-row-bordered table-hover gy-3 gs-5">
                            <thead>
                                <tr class="fw-bold">
                                    <th class="text-center pe-3">#</th>
                                    <th>Referer</th>
                                    <th class="text-end pe-3">Reward (estimate)</th>
                                    <th class="text-end pe-3">Aff Volume</th>
                                    <th class="text-end pe-3">Ref Count</th>
                                </tr>
                            </thead>
                            <tbody class="fs-7 text-gray-600">
                                <tr v-for="(affiliate, idx) in topAffiliates">
                                    <td class="text-center pe-3">{{idx+1}}.</td>
                                    <td>{{shortPrincipal(affiliate[0])}} <Copy :text="affiliate[0]"></Copy></td>
                                    <td class="text-end pe-3 fw-bold text-success">{{ currencyFormat(parseTokenAmount(Number(affiliate[1]?.volume)/Number(status?.totalAffiliateVolume)*Number(status?.affiliateRewardPool), launchpadInfo?.saleToken?.decimals)) }} {{ launchpadInfo?.saleToken?.symbol }}</td>
                                    <td class="text-end pe-3 fw-bold text-primary">{{ currencyFormat(parseTokenAmount(affiliate[1]?.volume, purchaseToken?.decimals)) }} {{ purchaseToken?.symbol }}</td>
                                    <td class="text-end pe-3 fw-bold">{{ affiliate[1]?.refCount }}</td>
                                </tr>
                            </tbody>
                        </table>
                    </div>
                    
                </div>
            </div>
        </div>
        <!--end::Col-->
        <!--begin::Col-->
        <div class="col-xxl-4">
            <div class="card mb-5  mb-xl-5">
                <!--begin::Body-->
                <div class="card-header align-items-center border-0 ps-5 pb-0">
                    <h3 class="card-title align-items-start flex-column">
                        <span class="fw-bolder mb-2 text-dark">Project Score</span>
                    </h3>
                    <div class="card-toolbar">
                        <a href="https://docs.icto.app/" target="_blank" class="badge badge-light fw-bolder me-auto px-4 py-3">More ></a>
                    </div>
                </div>
                <div class="card-body pt-0 p-0">
                    <div v-if="isLoading" class="p-5">
                        <Skeletor v-for="i in 4" :key="i" />
                    </div>
                    <div v-else>
                        <ProjectScore :assessment="projectAssessment"/>
                    </div>
                    <div class="pt-5 mb-5 text-center"></div>
                    <div class="separator"></div>
                    <div class="text-center countdown p-5">
                        <vue-countdown :time="countdown" v-slot="{ days, hours, minutes, seconds }"  @end="onCountdownEnd">
                            <div class="fw-bolder fs-6 text-primary p-5">
                                <span v-if="status?.status == 'LIVE'">
                                    POOL ENDS IN
                                </span>
                                <span v-else-if="status?.status == 'UPCOMING'">
                                    POOL STARTS IN
                                </span>
                                <span class="text-muted" v-else>
                                    POOL ENDED
                                </span>
                            </div>
                            <div class="countdown-time">
                                <ul>
                                    <li>
                                        <Skeletor v-if="isLoading" height="49px" pill as="button"></Skeletor>
                                        <button id="days-xdrake20220408" v-else>{{days}}</button>
                                        <p>DAYS</p>
                                    </li>
                                    <li>
                                        <Skeletor v-if="isLoading" height="49px" pill as="button"></Skeletor>
                                        <button id="hours-xdrake20220408" v-else>{{ hours }}</button>
                                        <p>HOURS</p>
                                    </li>
                                    <li>
                                        <Skeletor v-if="isLoading" height="49px" pill as="button"></Skeletor>
                                        <button id="minutes-xdrake20220408" v-else>{{ minutes }}</button>
                                        <p>MINS</p>
                                    </li>
                                    <li>
                                        <Skeletor v-if="isLoading" height="49px" pill as="button"></Skeletor>
                                        <button id="seconds-xdrake20220408" v-else>{{ seconds }}</button>
                                        <p>SECS</p>
                                    </li>
                                </ul>
                            </div>
                        </vue-countdown>
                    </div>
                    <!-- <div class="text-center">
                        <span class="badge badge-light text-success">This contract is verified by <a href="https://blockid.cc" target="_blank"><span class=" badge badge-light text-success"><i class="fas fa-shield-alt text-success"></i> BlockID</span></a></span> 
                    </div> -->

                    <div class="px-5">
                        <div class="bg-light-success p-3 mb-3 border-rounded text-success" v-if="status?.totalAmountCommitted>launchpadInfo?.launchParams?.softCap">
                            🎉 Congratulations, Softcap has been reached!
                        </div>
                        <div class="bg-light-success p-3 mb-3 border-rounded text-success" v-if="status?.totalAmountCommitted>launchpadInfo?.launchParams?.hardCap">
                            <i class="fas fa-check-circle text-success" ></i> Congratulations, Hardcap has been reached!
                        </div>
                        <div class="bg-light-danger p-3 mb-3 border-rounded text-danger" v-if="status?.totalAmountCommitted<launchpadInfo?.launchParams?.softCap && status.status == 'REFUNDING'">
                            <i class="fas fa-times-circle text-danger" ></i> Softcap has not been reached! 
                            Refund will be processed soon.
                        </div>
                        <div class="d-flex flex-column mb-5">
                            <div class="d-flex fs-7 align-items-center">
                                <div class="bullet bg-primary bullet-dot me-3"></div>
                                <div class="text-gray-500">Current commit</div>
                                <div class="ms-auto fw-bold text-gray-700"></div>
                                <Skeletor v-if="isLoading" height="16px" width="100px" pill></Skeletor>
                                <div class="text-primary fw-bold" v-else>
                                    {{currencyFormat(parseTokenAmount(status?.totalAmountCommitted, purchaseToken?.decimals))}} {{ purchaseToken?.symbol }}</div>
                            </div>

                            <div class="h-8px bg-light rounded mb-1">
                                <div class="bg-primary rounded h-8px" role="progressbar" :style="`width: ${(Number(status?.totalAmountCommitted)/Number(launchpadInfo?.launchParams?.hardCap)*100).toFixed(2)}%;`"></div>
                            </div>
                            <div class="indicator-wrapper">
                                <div class="triangle" :style="`left: ${(Number(launchpadInfo?.launchParams?.softCap)/Number(launchpadInfo?.launchParams?.hardCap)*100).toFixed(2)}%;`"></div> 
                            </div>
                            <div class="d-flex justify-content-between w-100 fs-7 fw-bold mb-1">
                                <div class="text-primary">Soft cap: {{currencyFormat(parseTokenAmount(launchpadInfo?.launchParams?.softCap, purchaseToken?.decimals))}} {{ purchaseToken?.symbol }}</div>
                                <div class="text-danger">Hard cap: {{currencyFormat(parseTokenAmount(launchpadInfo?.launchParams?.hardCap, purchaseToken?.decimals))}} {{ purchaseToken?.symbol }}</div>
                            </div>
                            <MyStats :launchpadId="launchpadId" :stats="status" :launchpadInfo="launchpadInfo" v-if="launchpadInfo" ref="myStatsRef" />
                            
                            <div v-if="status?.status == 'LIVE'">
                                <div class="separator"></div>
                                <div class="form-group fs-7 mt-5">
                                    <label class="form-label required fs-7">Amount</label>
                                    <div class="float-right">Balance: 
                                        <span class="fw-bold text-primary"><a href="javascript:void(0)" @click="selectMax()" class="text-primary" title="Select Max">{{myBalance}}</a> {{ purchaseToken?.symbol }}</span> 
                                        <a href="javascript:void(0)" @click="selectMax()" title="Select max" class="badge badge-light-danger ms-5"> MAX</a>
                                        <a href="javascript:void(0)" @click="checkPurchaseBalance()" title="Refresh my Balance" class="badge badge-light-primary ms-2"><i class="fas fa-refresh text-primary"></i> </a>
                                    </div>
                                    <div class="form-control-wrap mt-2">
                                        <input type="text" class="form-control form-control-solid form-control-sm" placeholder="Enter amount" v-model="depositAmount" :disabled="status.status !='LIVE' || !walletStore.isLogged" />
                                    </div>
                                </div>
                                <div class="pt-5 d-flex flex-column">
                                    <button class="btn btn-primary btn-sm btn-block" @click="depositBtn" :disabled="status.status !='LIVE' || !walletStore.isLogged">Commit</button>
                                </div>  
                            </div>
                            <BlockIDNotice :launchpadId="launchpadId" v-if="launchpadInfo" />
                        </div>
                        <div class="table-responsive">
                            <table class="table table-flush align-middle table-row-bordered gy-3">
                                <tbody class="fs-7 fw-bold text-gray-600">
                                    <tr>
                                        <td>Status</td>
                                        <td class="text-end text-success">
                                            <Skeletor v-if="isLoading" height="24px" pill as="div"></Skeletor>
                                            <div v-html="getPoolStatus(status?.status)" v-else></div>
                                        </td>
                                    </tr>
                                    <tr>
                                        <td>Launch Type</td>
                                        <td class="text-end text-gray">
                                            <Skeletor v-if="isLoading" height="24px" pill as="div"></Skeletor>
                                            <div v-else>{{status?.whitelistEnabled?"WHITELIST":"PUBLIC"}}</div>
                                        </td>
                                    </tr>
                                    <tr>
                                        <td>Affiliate Program</td>
                                        
                                        <td class="text-end text-primary">
                                            <Skeletor v-if="isLoading" height="24px" pill as="div"></Skeletor>
                                            <div v-else>{{status?.affiliate > 0 ?"ENABLED":"NOT ENABLED"}} ({{ status?.affiliate }}%)</div>
                                        </td>
                                    </tr>
                                    <tr>
                                        <td>Pool Size</td>
                                        <td class="text-end">
                                            <Skeletor v-if="isLoading" height="24px" pill as="div"></Skeletor>
                                            <div v-else>{{currencyFormat(parseTokenAmount(status?.totalAmountCommitted, purchaseToken?.decimals))}} {{ purchaseToken?.symbol }} ({{(Number(status?.totalAmountCommitted)/Number(launchpadInfo?.launchParams?.hardCap)*100).toFixed(2)}}%)</div>
                                        </td>
                                    </tr>
                                    <tr>
                                        <td>Total Participants</td>
                                        <td class="text-end">
                                            <Skeletor v-if="isLoading" height="24px" pill as="div"></Skeletor>
                                            <div v-else>{{status?.totalParticipants}}</div>
                                        </td>
                                    </tr>
                                    <tr>
                                        <td>Total Swap Transactions</td>
                                        <td class="text-end">
                                            <Skeletor v-if="isLoading" height="24px" pill as="div"></Skeletor>
                                            <div v-else>{{status?.totalTransactions}}</div>
                                        </td>
                                    </tr>
                                </tbody>
                            </table>
                        </div>
                    </div>
                </div>
                <!--end: Card Body-->
            </div>
            
            <div class="card mb-5 mb-xl-5">
                <!--begin::Header-->
                <div class="card-header align-items-center border-0 mt-4 ps-5">
                    <h3 class="card-title align-items-start flex-column">
                        <span class="fw-bolder mb-2 text-dark">Timeline</span>
                        <span class="text-muted fw-bold fs-7"></span>
                    </h3>
                </div>
                <!--end::Header-->
                <!--begin::Body-->
                <div class="card-body pt-0 ps-0">
                    <Skeletor v-if="isLoading" height="20px"></Skeletor>
                    <Timeline :status="status?.status" :timeline="launchpadInfo?.timeline" v-else />
                </div>
                <!--end: Card Body-->
            </div>

            <div class="card mb-5 mb-xl-5" v-if="status && status.affiliate > 0">
                <div class="card-header align-items-center border-0 mt-4 ps-5">
                    <h3 class="card-title align-items-start flex-column">
                        <span class="fw-bolder mb-2 text-dark">Affiliate Program</span>
                        <span class="text-muted fw-bold fs-7"></span>
                    </h3>
                </div>
                <div class="card-body pt-0 p-0">
                    <div class="px-5">
                        <div class="table-responsive">
                            <table class="table table-flush align-middle table-row-bordered gy-3">
                                <tbody class="fs-7 fw-bold text-gray-600">
                                    <tr>
                                        <td>Total Affiliate Volume</td>
                                        <td class="text-end text-primary">{{currencyFormat(parseTokenAmount(status?.totalAffiliateVolume, purchaseToken?.decimals))}} {{ purchaseToken?.symbol }}</td>
                                    </tr>
                                    <tr>
                                        <td>Total Rewards</td>
                                        <td class="text-end">{{currencyFormat(parseTokenAmount(status?.affiliateRewardPool, launchpadInfo?.saleToken?.decimals))}} {{ launchpadInfo?.saleToken?.symbol }}</td>
                                    </tr>
                                    <tr>
                                        <td>Reward Percentage</td>
                                        <td class="text-end text-success">{{((Number(status?.totalAffiliateVolume)*100/Number(status?.totalAmountCommitted)).toFixed(2)) || 0}}%</td>
                                    </tr>
                                    <tr>
                                        <td>Referer Transaction Count</td>
                                        <td class="text-end">{{status?.refererTransaction}}</td>
                                    </tr>
                                </tbody>
                            </table>
                        </div>
                    </div>
                </div>
                <!--end: Card Body-->
            </div>
        </div>
        <!--end::Col-->
    </div>

</template>
<style scoped>
    .countdown {
        width: 100%;
        padding: 10px 20px 20px 20px;
        box-sizing: border-box;
        text-align: center;
    }
    .countdown .countdown-time ul {
        display: flex;
        justify-content: center;
        list-style-type: none
    }
    .countdown .countdown-time ul li {
        padding: 0 10px;
        position: relative;
    }
    .countdown .countdown-time ul li:before {
        content: ":";
        position: absolute;
        right: -3px;
        top: 8px;
        font-size: 27px;
        line-height: 30px;
        color: #a1a5b7;
    }
    .countdown .countdown-time ul li:last-child:before {
        display: none;
    }
    .countdown .countdown-time ul li button {
        background: #a1a5b7;
        border: none;
        border-radius: 5px;
        font-size: 27px;
        line-height: 30px;
        display: flex;
        justify-content: center;
        align-items: center;
        color: #FFFFFF;
        width: 48.15px;
        height: 48.15px;
    }
    .countdown .countdown-time ul li p {
        font-size: 11px;
        line-height: 30px;
        text-align: center;
        color: #a1a5b7;
        padding: 0px;
    }
    .indicator-wrapper {
        --line-width: 2px;
        --triangle-size: 6px;
    }
    .indicator-wrapper .triangle {
        position: relative;
        --triangle-sides-border: var(--triangle-size) solid transparent;
        display: block;
        width: 0;
        height: 0;
        border-left: var(--triangle-sides-border);
        border-right: var(--triangle-sides-border);
        border-bottom: var(--triangle-size) solid #50cd89;
        margin-bottom: 3px;
    }
    .marker1 {
        position: relative;
        display: block;
        width: 0;
        text-align: center;
        color: #50cd89;
        font-size: 12px;
        font-weight: 600;
        line-height: 1;
    }
    .indicator-wrapper .indicator-line-wrapper{
        position: relative;
        margin-bottom: 6px;
    }
    .indicator-wrapper .indicator-line-wrapper .min-indicator {
        position: absolute;
        display: block;
        width: 1px;
        height: 15px;
        background-color: #50cd89;
    }
    .progress-container {
        position: relative;
        margin-top: 30px;
        }

        .progress {
        height: 20px;
        }

        .markers {
        position: relative;
        width: 100%;
        height: 30px;
        }

        .marker {
        position: absolute;
        text-align: center;
        }

        .arrow {
        display: block;
        font-size: 20px;
        line-height: 1;
        }

        .label {
        font-size: 12px;
        display: block;
        }

    .banner {
        width: 100%;
        margin: -1.75rem 0 0 0; /* Remove padding */
    }

    .banner img {
        border-radius: 10px;
        width: 100%;
        height: auto;
        display: block;
        object-fit: cover;
    }
</style>