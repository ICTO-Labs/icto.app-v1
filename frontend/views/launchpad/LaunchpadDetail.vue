<script setup>
    import { ref, onMounted, watchEffect, watch } from 'vue';
    import Tokenomic from '@/components/launchpad/Tokenomic.vue';
    import VueCountdown from '@chenfengyuan/vue-countdown';
    import Timeline from '@/components/launchpad/Timeline.vue';
    import Links from '@/components/Links.vue';
    import RefererLink from '@/components/launchpad/RefererLink.vue';
    import MyStats from '@/components/launchpad/MyStats.vue';
    import moment from 'moment';
    import { timeFromNano, showError, showSuccess, showLoading, closeMessage, getPoolStatus, getRef, saveRef, shortPrincipal } from '@/utils/common';
    import { getInfo, useCommit, getStatus, getTopAffiliates, useCreateShortlink, getShortlink, deleteShortLink } from '@/services/Launchpad';
    import { formatTokenomic } from '@/utils/launchpad';
    import { useRoute } from 'vue-router';
    import { parseTokenAmount, formatTokenAmount, currencyFormat } from '@/utils/token';
    import { useGetMyBalance, useTokenApprove } from '@/services/Token';
    import walletStore from "@/store";
    const router = useRoute();
    const launchpadId = router.params.launchpadId;
    const purchaseToken = ref(null);
    const saleToken = ref(null);
    const depositAmount = ref(0);
    const countdown = ref(10 * 24 * 60 * 60 * 1000);
    const myBalance = ref(0);
    const tokennomics = ref([]);

    // const { data: tokenTransactions, isError, error, isLoading: isTransLoading, isRefetching: isTransRefetching, refetch: refreshTransactions } = useGetTransactions(tokenId, 'icrc2', 0, 100);
    const { data: launchpadInfo, isError, error, isLoading, isRefetching, refetch, isFetched } = getInfo(launchpadId);
    const { data: topAffiliates } = getTopAffiliates(launchpadId);
    const { data: status, isError: isStatusError, error: statusError, isLoading: isStatusLoading, isRefetching: isStatusRefetching, refetch: refetchStatus } = getStatus(launchpadId);
    console.log('launchpadInfo', launchpadInfo);
    watchEffect(() => {
        if (isFetched.value && launchpadInfo.value) {
            purchaseToken.value = launchpadInfo.value.purchaseToken;
            saleToken.value = launchpadInfo.value.saleToken;
            // depositAmount.value = parseTokenAmount(launchpadInfo.value.launchParams.minimumAmount, purchaseToken.value.decimals);
            tokennomics.value = formatTokenomic(launchpadInfo.value.distribution);
            //Check balance
            // checkPurchaseBalance();
            // countdown.value = moment(timeFromNano(launchpadInfo.value.timeline.startTime).valueOf()).diff(moment());
        };
        if(status.value){
            if(status.value.status == "LIVE"){
                countdown.value = moment(timeFromNano(launchpadInfo.value.timeline.endTime).valueOf()).diff(moment());
            }else{
                countdown.value = moment(timeFromNano(launchpadInfo.value.timeline.startTime).valueOf()).diff(moment());
            }
        }
    });

    const onCountdownEnd = ()=>{
        console.log('Countdown end');
        refetchStatus();
    }
    // const launchpadInfo = ref(null);
    // import { useGetLaunchpad } from "@/services/Launchpad";

    const checkPurchaseBalance = async()=>{
        const _balance = await useGetMyBalance(purchaseToken.value.canisterId);
        myBalance.value = _balance;
    }
    const getLaunchpadInfo = async () => {
        const _info = await getInfo();
        if (_info) {
            // launchpadInfo.value = _info;
            purchaseToken.value = launchpadInfo.purchaseToken[0];
            depositAmount.value = parseTokenAmount(launchpadInfo.launchParams.minimumAmount, purchaseToken.value.decimals);
            countdown.value = moment.unix(Number(launchpadInfo.timeline.startTime)).diff(moment());
        }
    }

    const checkAmount = () => {
        if (depositAmount.value < launchpadInfo.value.launchParams.minimumAmount) {
            depositAmount.value = launchpadInfo.value.launchParams.minimumAmount;
            showError('Minimum amount is ' + launchpadInfo.value.launchParams.minimumAmount);
        }
        if (depositAmount.value > launchpadInfo.value.launchParams.maximumAmount) {
            depositAmount.value = launchpadInfo.value.launchParams.maximumAmount;
            showError('Maximum amount is ' + launchpadInfo.value.launchParams.maximumAmount);
        }
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
                showLoading("Approving tICP...");
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
                        showError("Approve not succeed: "+JSON.stringify(_approved.Err), true);
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
                    }else{
                        showError('Can not process, please try again later!', true);
                    }
                }catch(e){
                    showError(e, true);
                }
                
                refetchStatus();//Refresh status
            }
        });
        
    }
    
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
    <Toolbar :current="tokenInfo?tokenInfo.name:'Launchpad details'" :parents="[{title: 'Launchpad', to: '/launchpad'}]" />

    <div class="" v-if="isLoading">Loading...</div>
    <div class="row g-xxl-9" v-if="launchpadInfo">
        <div class="col-xxl-8">
            <div class="card mb-5 mb-xl-5">
                <div class="card-body pt-7 pb-0 px-0">
                    <!-- <div class="banner" v-if="launchpadInfo.projectInfo.banner">
                        <img :src="launchpadInfo.projectInfo.banner" alt="banner" />
                    </div>  -->
                    <div class="d-flex flex-wrap flex-sm-nowrap mb-1 px-5">
                        <!--begin: Pic-->
                        <div class="me-7 mb-4">
                            <div class="symbol symbol-80px symbol-lg-100px symbol-fixed position-relative">
                                <img :src="launchpadInfo.projectInfo.logo" alt="image">
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
                                        <span class="text-gray-900 text-hover-primary fs-2 fw-bolder me-1">{{launchpadInfo.projectInfo.name}}</span>
                                        <Verified v-if="!launchpadInfo.projectInfo.isVerified" title="Verified by ICTO"></Verified>
                                    </div>
                                    <!--end::Name-->
                                    <!--begin::Info-->
                                    <div class="d-flex flex-wrap fw-bold fs-6 mb-2 pe-2">
                                        <Links :links="launchpadInfo.projectInfo.links[0]" />
                                    </div>
                                    <div>
                                        <span class="badge badge-warning fw-bold px-4 py-2 ps-4 me-4"><i class="fas fa-percent text-white"></i> AFFILIATE</span> 
                                        <span class="badge badge-light-danger fw-bolder me-auto px-4 py-2 ps-4"><i class="fas fa-fire text-danger"></i> HOT #1</span>
                                        <span class="badge badge-light-primary fw-bolder me-auto px-4 py-2 ps-4 ms-4" v-if="launchpadInfo.projectInfo.isAudited"><i class="fas fa-shield-alt text-primary"></i> AUDITED</span>
                                    </div>
                                    <!--end::Info-->
                                </div>
                                <div class="d-flex my-4">
                                    <div class="d-flex fs-7 align-items-center" v-html="getPoolStatus(status?.status)" v-if="status?.status"></div>
                                </div>
                            </div>
                        </div>
                    </div>

                    <div class="separator"></div>
                    <div class="px-5 py-5">
                        <div v-html="launchpadInfo.projectInfo.description"></div>
                    </div>
                </div>
            </div>
            <div class="card mb-5 mb-xl-5">
                <div class="card-header ps-6">
                    <h3 class="card-title">Launch info</h3>
                </div>
                <div class="card-body p-1">
                    <div class="table-responsive">
                        <table class="table table-flush align-middle table-row-bordered table-hover gy-3 gs-5">
                            <tbody class="fs-7 fw-bold text-gray-600">
                                <tr>
                                    <td>Token Name</td>
                                    <td class="text-end fw-bolder"><img :src="launchpadInfo.saleToken.logo" class="w-30px" /> {{launchpadInfo.saleToken.name}}</td>
                                </tr>
                                <tr>
                                    <td>Token Symbol</td>
                                    <td class="text-end fw-bolder">{{launchpadInfo.saleToken.symbol}}</td>
                                </tr>
                                <tr>
                                    <td>Token Decimals</td>
                                    <td class="text-end fw-bolder">{{launchpadInfo.saleToken.decimals}}</td>
                                </tr>
                                <tr>
                                    <td>Token Canister</td>
                                    <td class="text-end fw-bolder text-primary">--- <Copy :text="bkyz2-fmaaa-aaaaa-qaaaq-cai"></Copy></td>
                                </tr>
                                <tr>
                                    <td>Total Supply</td>
                                    <td class="text-end fw-bolder">0</td>
                                </tr>
                                <tr>
                                    <td>Tokens For Fairlaunch</td>
                                    <td class="text-end fw-bolder">{{currencyFormat(parseTokenAmount(launchpadInfo.distribution.fairlaunch.total, saleToken.decimals))}}</td>
                                </tr>
                                <tr>
                                    <td>Tokens For Liquidity</td>
                                    <td class="text-end fw-bolder">{{currencyFormat(parseTokenAmount(launchpadInfo.distribution.liquidity.total, saleToken.decimals))}}</td>
                                </tr>
                                <tr>
                                    <td>Initial Market Cap (estimate)</td>
                                    <td class="text-end fw-bolder">---</td>
                                </tr>
                                <tr>
                                    <td>Soft Cap</td>
                                    <td class="text-end fw-bolder">{{currencyFormat(parseTokenAmount(launchpadInfo.launchParams.softCap, purchaseToken.decimals))}} {{ purchaseToken.symbol }}</td>
                                </tr>
                                <tr>
                                    <td>Hard Cap</td>
                                    <td class="text-end fw-bolder">{{currencyFormat(parseTokenAmount(launchpadInfo.launchParams.hardCap, purchaseToken.decimals))}} {{ purchaseToken.symbol }}</td>
                                </tr>
                                <tr>
                                    <td>Min per user</td>
                                    <td class="text-end fw-bolder">{{parseTokenAmount(launchpadInfo.launchParams.minimumAmount, purchaseToken.decimals)}} {{ purchaseToken.symbol }}</td>
                                </tr>
                                <tr>
                                    <td>Limit per user</td>
                                    <td class="text-end fw-bolder">{{parseTokenAmount(launchpadInfo.launchParams.maximumAmount, purchaseToken.decimals)}} {{ purchaseToken.symbol }}</td>
                                </tr>
                                <tr>
                                    <td>Presale Start Time</td>
                                    <td class="text-end fw-bolder">{{timeFromNano(launchpadInfo.timeline.startTime)}}</td>
                                </tr>
                                <tr>
                                    <td>Presale End Time</td>
                                    <td class="text-end fw-bolder">{{timeFromNano(launchpadInfo.timeline.endTime)}}</td>
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
                    <Tokenomic :data="tokennomics" :legend="1"/>
                </div>
            </div>
            <div class="card" v-if="status.affiliate > 0">
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
                                    <td class="text-end pe-3 fw-bold text-success">{{ currencyFormat(parseTokenAmount(Number(affiliate[1].volume)/Number(status.totalAffiliateVolume)*Number(status.affiliateRewardPool), purchaseToken.decimals)) }} {{ purchaseToken.symbol }}</td>
                                    <td class="text-end pe-3 fw-bold text-primary">{{ currencyFormat(parseTokenAmount(affiliate[1].volume, purchaseToken.decimals)) }} {{ purchaseToken.symbol }}</td>
                                    <td class="text-end pe-3 fw-bold">{{ affiliate[1].refCount }}</td>
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
                <div class="card-body pt-0 p-0">
                    <div class="text-center countdown p-5" v-if="countdown">
                        <vue-countdown :time="countdown" v-slot="{ days, hours, minutes, seconds }"  @end="onCountdownEnd">
                            <div class="fw-bolder fs-6 text-primary p-5">
                                <span v-if="status.status == 'LIVE'">
                                    POOL ENDS IN
                                </span>
                                <span v-else-if="status.status == 'UPCOMING'">
                                    POOL STARTS IN
                                </span>
                                <span class="text-muted" v-else>
                                    POOL ENDED
                                </span>
                            </div>
                            <div class="countdown-time">
                                <ul>
                                    <li>
                                        <button id="days-xdrake20220408">{{days}}</button>
                                        <p>DAYS</p>
                                    </li>
                                    <li>
                                        <button id="hours-xdrake20220408">{{ hours }}</button>
                                        <p>HOURS</p>
                                    </li>
                                    <li>
                                        <button id="minutes-xdrake20220408">{{ minutes }}</button>
                                        <p>MINS</p>
                                    </li>
                                    <li>
                                        <button id="seconds-xdrake20220408">{{ seconds }}</button>
                                        <p>SECS</p>
                                    </li>
                                </ul>
                            </div>
                        </vue-countdown>
                    </div>
                    <div class="px-5">
                        <div class="bg-light-success p-3 mb-3 border-rounded text-success" v-if="status.totalAmountCommitted>launchpadInfo.launchParams.softCap">
                            <i class="fas fa-check-circle text-success" ></i> Congratulations, Softcap has been reached!
                        </div>
                        <div class="d-flex flex-column mb-5">
                            <div class="d-flex fs-7 align-items-center">
                                <div class="bullet bg-primary bullet-dot me-3"></div>
                                <div class="text-gray-500">Current commit</div>
                                <div class="ms-auto fw-bold text-gray-700"></div>
                                <div class="text-primary fw-bold">
                                    {{currencyFormat(parseTokenAmount(status.totalAmountCommitted, purchaseToken.decimals))}} {{ purchaseToken.symbol }}</div>
                            </div>

                            <div class="h-8px bg-light rounded mb-1">
                                <div class="bg-primary rounded h-8px" role="progressbar" :style="`width: ${(Number(status.totalAmountCommitted)/Number(launchpadInfo.launchParams.hardCap)*100).toFixed(2)}%;`"></div>
                            </div>
                            <div class="indicator-wrapper">
                                <div class="triangle" :style="`left: ${(Number(launchpadInfo.launchParams.softCap)/Number(launchpadInfo.launchParams.hardCap)*100).toFixed(2)}%;`"></div> 
                            </div>
                            <div class="d-flex justify-content-between w-100 fs-7 fw-bold mb-1">
                                <div class="text-primary">Soft cap: {{currencyFormat(parseTokenAmount(launchpadInfo.launchParams.softCap, purchaseToken.decimals))}} {{ purchaseToken.symbol }}</div>
                                <div class="text-danger">Hard cap: {{currencyFormat(parseTokenAmount(launchpadInfo.launchParams.hardCap, purchaseToken.decimals))}} {{ purchaseToken.symbol }}</div>
                            </div>
                            <MyStats :launchpadId="launchpadId" :stats="status" :launchpadInfo="launchpadInfo" />
                            
                            <div v-if="status.status == 'LIVE'">
                                <div class="separator"></div>
                                <div class="form-group fs-7 mt-5">
                                    <label class="form-label required fs-7">Amount</label>
                                    <div class="float-right">Balance: 
                                        <span class="fw-bold text-primary">{{myBalance}} {{ purchaseToken.symbol }}</span> 
                                        <a href="javascript:void(0)" @click="selectMax" title="Select Max" class="badge badge-light-primary ms-5">MAX</a>
                                    </div>
                                    <div class="form-control-wrap">
                                        <input type="text" class="form-control form-control-solid form-control-sm" placeholder="Enter amount" v-model="depositAmount" :disabled="status.status !='LIVE'" />
                                    </div>
                                </div>
                                <div class="pt-5 d-flex flex-column">
                                    <button class="btn btn-primary btn-sm btn-block" @click="depositBtn" :disabled="status.status !='LIVE'">Commit</button>
                                </div>  
                            </div>
                            
                        </div>
                        <div class="table-responsive">
                            <table class="table table-flush align-middle table-row-bordered gy-3">
                                <tbody class="fs-7 fw-bold text-gray-600">
                                    <tr>
                                        <td>Status</td>
                                        <td class="text-end text-success"><div v-html="getPoolStatus(status.status)"></div></td>
                                    </tr>
                                    <tr>
                                        <td>Launch Type</td>
                                        <td class="text-end text-gray">{{status.whitelistEnabled?"WHITELIST":"PUBLIC"}}</td>
                                    </tr>
                                    <tr>
                                        <td>Affiliate Program</td>
                                        <td class="text-end text-primary">{{status?.affiliate > 0 ?"ENABLED":"NOT ENABLED"}} ({{ status?.affiliate }}%)</td>
                                    </tr>
                                    <tr>
                                        <td>Pool Size</td>
                                        <td class="text-end">{{currencyFormat(parseTokenAmount(status.totalAmountCommitted, purchaseToken.decimals))}} {{ purchaseToken.symbol }} ({{(Number(status.totalAmountCommitted)/Number(launchpadInfo.launchParams.hardCap)*100).toFixed(2)}}%)</td>
                                    </tr>
                                    <tr>
                                        <td>Total Participants</td>
                                        <td class="text-end">{{status.totalParticipants}}</td>
                                    </tr>
                                    <tr>
                                        <td>Total Swap Transactions</td>
                                        <td class="text-end">{{status.totalTransactions}}</td>
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
                    <Timeline :status="status.status" :timeline="launchpadInfo.timeline" />
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
                                        <td class="text-end text-primary">{{currencyFormat(parseTokenAmount(status.totalAffiliateVolume, purchaseToken.decimals))}} {{ purchaseToken.symbol }}</td>
                                    </tr>
                                    <tr>
                                        <td>Total Rewards</td>
                                        <td class="text-end">{{currencyFormat(parseTokenAmount(status.affiliateRewardPool, purchaseToken.decimals))}} {{ purchaseToken.symbol }}</td>
                                    </tr>
                                    <tr>
                                        <td>Reward Percentage</td>
                                        <td class="text-end text-success">{{((Number(status.totalAffiliateVolume)*100/Number(status.totalAmountCommitted)).toFixed(2) || 0)}}%</td>
                                    </tr>
                                    <tr>
                                        <td>Referer Transaction Count</td>
                                        <td class="text-end">{{status.refererTransaction}}</td>
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
</style>