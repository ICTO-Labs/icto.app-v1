<script setup>
    import { VueFinalModal } from 'vue-final-modal'
    import EventBus from "@/services/EventBus";
    import { DURATION, SCHEDULE} from "@/config/constants"
    import { onMounted, ref } from 'vue';
	import { showError, showSuccess, txtToPrincipal, principalToText, closeMessage, showLoading, getVariantType } from '@/utils/common';
    import moment from 'moment';
    import Copy from "@/components/icons/Copy.vue";
    import _api from "@/ic/api";
    import { currencyFormat, formatTokenAmount, parseTokenAmount } from "@/utils/token";
    import {Principal} from "@dfinity/principal";
    import { useCreateContract } from "@/services/Contract";
    import LoadingButton from '@/components/LoadingButton.vue';
    const contractData = ref(null);
    const contractDetailsModal = ref(false);
    const isLoading = ref(false);
    import walletStore from '@/store/'
    import config from '@/config';
	import { useCreateToken, useTokenApprove, useTransferFrom, useInstallToken  } from '@/services/Token';

    const closeModal = ()=>{
        contractDetailsModal.value = false;
    }
    const calInitialUnlock = (amount, initialUnlock)=>{
        return { initialUnlock: amount*initialUnlock/100, vestingAmount: amount-amount*initialUnlock/100 };
    }
    const calTotalAmount = (recipients)=>{
		return recipients.reduce((acc,cur) => acc + Number(cur.amount), 0);
	}
    const createContract = async()=>{
        Swal.fire({
		title: "Are you sure?",
		text: "Create new claim contract!",
		icon: "warning",
		showCancelButton: true,
		confirmButtonColor: "#3085d6",
		cancelButtonColor: "#d33",
		confirmButtonText: "Yes, I confirmed!"
		}).then(async (result) => {
		if (result.isConfirmed) {
            isLoading.value = true;
            //Step 1.
            // showLoading("Approving token...");
            // let _approved = await useTokenApprove(contractData.value.token.canisterId, {spender: config.TOKEN_DEPLOYER_CANISTER_ID, amount: (contractData.value.totalAmount+1)*config.E8S});
            // console.log('_approved', _approved);
            // if(_approved == null){
            //     isLoading.value = false;
            //     closeMessage();
            //     return;
            // }
            // if(_approved && _approved.hasOwnProperty('Err')){
            //     isLoading.value = false;
            //     if (_approved.Err?.InsufficientFunds) {
            //         showError('Insufficient Funds', true);
            //     }else{
            //         showError("Approve not succeed, please see the console for further detail!", true);
            //     }
            //     return;
            // }

            //Step 2.
            console.log('contractData.value: ', contractData.value.token);
            let tokenInfo = await contractData.value.token;
            let _totalAmount = 0;//Add fee for the contract transfer!!!!
            let recipients = contractData.value.recipients.map(recipient=>{
                _totalAmount += Number(formatTokenAmount(recipient.amount, tokenInfo.decimals));
                return {address: recipient.address, amount: Number(formatTokenAmount(recipient.amount, tokenInfo.decimals)), note: [""+recipient.note+""]}
            });
            let _data = {
                title: contractData.value.name,
                description: contractData.value.description,
                durationTime: Number(contractData.value.durationTime),
                durationUnit: Number(contractData.value.durationUnit),
                cliffTime: Number(contractData.value.durationTime),//Number(contractData.value.cliffTime),
                cliffUnit: Number(contractData.value.cliffUnit),
                unlockSchedule: Number(contractData.value.unlockSchedule),
                allowCancel: contractData.value.allowCancel,
                startNow: contractData.value.startNow,
                startTime: moment(contractData.value.startTime).unix(),
                created: moment().unix(),
                totalAmount: contractData.value.totalAmount*config.E8S,
                tokenInfo: {
                    canisterId: tokenInfo.canisterId,
                    name: tokenInfo.name,
                    standard: tokenInfo.standard,
                    symbol: tokenInfo.symbol,
                    decimals: tokenInfo.decimals,
                    fee: tokenInfo.fee,
                },
                recipients: [recipients],
                distributionType: contractData.value.distributionType,
                initialUnlock: Number(contractData.value.initialUnlock),
                vestingType: contractData.value.vestingType,
                autoTransfer: contractData.value.autoTransfer,
                blockId: contractData.value.useBlockId ? contractData.value.blockId : 0,
                maxRecipients: contractData.value.maxRecipients,
                owner: Principal.fromText(walletStore.principal)
            };
            console.log('creating contract...', _data);
            // //Step 1. Approved
            // let _extendAmount = _totalAmount+(tokenInfo.fee*2);//Extend the amount for the transfer fee
            // showLoading("Approving token...");
            // let _approve = await useTokenApprove(tokenInfo.canisterId, {spender: config.BACKEND_CANISTER_ID, amount: parseTokenAmount(_extendAmount,tokenInfo.decimals)}, tokenInfo.decimals);
            // console.log('_approve', _approve, _extendAmount);
            // let _transfer = await useTransferFrom(tokenInfo.canisterId, {from: walletStore.principal, to: config.BACKEND_CANISTER_ID, amount: _totalAmount});
            // return;
            showLoading("Deploying your contract data...");
            let _rs = await useCreateContract(_data);
            isLoading.value = false;
            console.log('rs', _rs);
            if(_rs && "ok" in _rs){
                // showSuccess("Contract has been created successfully. View contract: "+_rs);
                EventBus.on("showContractDetailsModal", {status: false});//Close the preview
                Swal.fire({
                    icon: 'success',
                    title: 'Success',
                    html: '<p>Your contract has been created successfully.</p><p>View contract: <a href="/token-claim/'+principalToText(_rs.ok)+'">'+principalToText(_rs.ok)+'</a></p>',
                })
            }else{
                console.log('_rs', _rs);
                Swal.fire({
                    icon: 'error',
                    title: 'Oops...',
                    text: (_rs && typeof(_rs) == 'object' && ("err" in _rs))?_rs.err:'Something went wrong, please try again!',
                })
            }
        
		}
		});
    }
    onMounted(()=>{
        EventBus.on("showContractDetailsModal", obj => {
            console.log('obj: ', obj);
            contractDetailsModal.value = obj.status;
            contractData.value = obj
        });
    })
</script>

<template>
    <VueFinalModal v-model="contractDetailsModal" :z-index-base="2000" classes="modal fade show" content-class="modal-dialog modal-lg modal-dialog-scrollable modal-dialog-centered" content-transition="vfm-fade" overlay-transition="vfm-fade">
            <div class="modal-content absolute inset-0 h-full overflow-auto">
                <div class="modal-header pt-5 pb-3">
                    <h4 class="modal-title">{{ contractData.name }}</h4>
                    <div class="btn btn-icon btn-sm btn-bg-light btn-active-light-danger ms-2" data-bs-dismiss="modal" aria-label="Close" @click="closeModal()">
                        <i class="fas fa-times"></i>
                    </div>
                </div>
                <div class="modal-body">
                    <div class="pl-10">
                        <div class="pb-5">
                            <!--begin::Wrapper-->
                            <div class="fs-6 pb-5">
                                
                                <div class="fw-bold">Contract Name</div>
                                <div class="text-gray-600">{{contractData.name}}</div>

                                <div class="fw-bold mt-5">Description</div>
                                <div class="text-gray-600">{{contractData.description}}</div>
                                
                                <div class="d-flex flex-column flex-sm-row gap-7 gap-md-10 mt-5">
                                    <div class="flex-root d-flex flex-column">
                                        <span class="fw-bold">Token Name</span>
                                        <span class="fs-6 text-gray-600 text-hover-primary">{{contractData.token.name}} ({{contractData.token.symbol}})</span>
                                    </div>
                                    <div class="flex-root d-flex flex-column">
                                        <span class="fw-bold">Token ID</span>
                                        <span class="fs-6 text-gray-600 text-hover-primary">{{contractData.token.canisterId}} <Copy :text="contractData.token.canisterId"></Copy></span>
                                    </div>
                                </div>

                                <div class="d-flex flex-column flex-sm-row gap-7 gap-md-10 mt-5" v-if="contractData.initialUnlock > 0">
                                    <div class="alert alert-info">
                                        <i class="fas fa-info-circle text-info"></i> 
                                        <span> This contract will unlock <span class="fw-bold text-danger">{{contractData.initialUnlock}}%</span> of the each recipient's amount immediately, the rest will be unlocked in the following schedule.</span>
                                    </div>
                                </div>
                                <div class="d-flex flex-column flex-sm-row gap-7 gap-md-10 mt-5">

                                    <div class="flex-root d-flex flex-column">
                                        <div class="d-flex flex-column flex-sm-row gap-7">
                                            <div class="flex-root d-flex flex-column">
                                                <span class="fw-bold">Vesting Duration</span>
                                                <span class="fs-6 text-gray-600">
                                                    <span v-if="contractData.durationUnit == 0" class="text-danger">Unlock immediately</span>
                                                    <span v-else>{{contractData.durationUnit}} {{DURATION[contractData.durationTime]}}</span>
                                                </span>
                                            </div>
                                            <div class="flex-root d-flex flex-column">
                                                <span class="fw-bold">Cliff</span>
                                                <span class="fs-6 text-gray-600">{{contractData.cliffUnit}} {{DURATION[contractData.cliffTime]}}</span>
                                            </div>
                                        </div>
                                    </div>
                                    <div class="flex-root d-flex flex-column">
                                        <span class="fw-bold">Unlock Schedule</span>
                                        <span class="fs-6 text-gray-600">
                                            <span v-if="contractData.durationUnit == 0" class="text-danger">None</span>
                                            <span v-else-if="contractData.unlockSchedule == contractData.durationTime*contractData.durationUnit" class="text-info">Fully unlock after {{contractData.durationUnit}} {{DURATION[contractData.durationTime]}}</span>
                                            <span v-else>{{SCHEDULE[contractData.unlockSchedule]}}</span>
                                        </span>
                                    </div>
                                </div>
                                <div class="d-flex flex-column flex-sm-row gap-7 gap-md-10 mt-5">
                                    <div class="flex-root d-flex flex-column">
                                        <span class="fw-bold">Contract Start</span>
                                        <span class="fs-6 text-gray-600">
                                            <span v-if="contractData.startNow">Start upon contract creation</span>
                                            <span v-else>{{contractData.startTime}}</span>
                                        </span>
                                    </div>
                                    <div class="flex-root d-flex flex-column">
                                        <span class="fw-bold">Contract End (expected)</span>
                                        <span class="fs-6 text-gray-600">{{moment().add(Number(contractData.durationTime), 'seconds').format()}}</span>
                                    </div>
                                </div>
                                <div class="d-flex flex-column flex-sm-row gap-7 gap-md-10 mt-5">
                                    <div class="flex-root d-flex flex-column">
                                        <span class="fw-bold">Require BlockID score</span>
                                        <span class="fs-6 text-gray-800">{{contractData.useBlockId ? contractData.blockId : 'No'}}</span>
                                    </div>
                                    <div class="flex-root d-flex flex-column">
                                        <span class="fw-bold">Distribution type</span>
                                        <span :class="getVariantType(contractData.distributionType) == 'Whitelist' ? 'text-danger' : 'text-success'">
                                            {{getVariantType(contractData.distributionType) == 'Whitelist' ? 'Whitelist' : 'Public'}}
                                        </span>
                                    </div>
                                </div>
                            </div>

                            <div class="d-flex flex-column gap-7 gap-md-10">
                                <div class="d-flex justify-content-between flex-column">
                                    <label class="fs-5 fw-bold form-label mb-2 text-primary">Recipients <span class="badge badge-light-primary">{{contractData.recipients.length}}</span></label>
                                    <div class="table-responsive border-bottom mb-9 table-rounded border">
                                        <table class="table table-hover align-middle table-row-dashed fs-7 gy-1 mb-0">
                                            <thead>
                                                <tr class="border-bottom fs-7 fw-bold text-gray-800 bg-light">
                                                    <th class="pb-2 text-center">#</th>
                                                    <th class="min-w-155px pb-2">Recipient</th>
                                                    <th class="min-w-70px text-end pb-2 pe-2">Initial Unlock</th>
                                                    <th class="min-w-70px text-end pb-2 pe-2">Vesting Amount</th>
                                                    <th class="min-w-70px text-end pb-2 pe-2">Total Amount</th>
                                                </tr>
                                            </thead>

                                            <tbody class="fw-semibold text-gray-600">
                                                <tr v-for="(recipient, idx) in contractData.recipients">
                                                    <td class="text-center">{{ idx+1 }}.</td>
                                                    <td class="fw-normal">
                                                        <ClickToCopy :text="recipient.address">{{ recipient.address }}
                                                        <span class="badge badge-light-primary fw-normal" v-if="recipient.note">{{ recipient.note }}</span></ClickToCopy>
                                                    </td>
                                                    <td class="text-end text-danger fw-bold  pe-2">{{ (calInitialUnlock(recipient.amount, contractData.initialUnlock).initialUnlock) }} {{ contractData.token.symbol }}</td>
                                                    <td class="text-end text-info fw-bold  pe-2">{{ (calInitialUnlock(recipient.amount, contractData.initialUnlock).vestingAmount) }} {{ contractData.token.symbol }}</td>
                                                    <td class="text-end text-gray-800 fw-bold  pe-2">{{ (recipient.amount) }} {{ contractData.token.symbol }}</td>
                                                </tr>
                                                <tr class="bg-light fs-7">
                                                    <td class="text-end fw-bold w-90" colspan="4">Amount:</td>
                                                    <td class="text-end fw-bold text-danger pe-2">{{currencyFormat(contractData.totalAmount)}} {{ contractData.token.symbol }}</td>
                                                </tr>
                                                <tr class="bg-light fs-7">
                                                    <td class="text-end fw-bold" colspan="4">Creation Fee:</td>
                                                    <td class="text-end fw-bold text-danger pe-2">0 ICP </td>
                                                </tr>
                                                
                                                <tr class="bg-light fs-7">
                                                    <td class="text-end fw-bold" colspan="4">Final amount:</td>
                                                    <td class="text-end fw-bold text-danger pe-2">{{currencyFormat(contractData.totalAmount)}} {{ contractData.token.symbol }}</td>
                                                </tr>

                                            </tbody>
                                        </table>
                                    </div>
                                </div>
                            </div>

                            <div class="alert bg-light-danger border border-danger border-dashed d-flex flex-column flex-sm-row w-100 p-5 mb-10">
                                <div class="d-flex flex-column pe-0 pe-sm-10">
                                    <h5 class="mb-1">Important!</h5>
                                    <span>
                                        Verify the start time of the contract and related settings accurately. The smart contract is autonomous and is not controlled by ICTO or its creator to ensure transparency.
                                    </span>
                                </div>
                            </div>
                            <div class="row mb-5">
                                <div class="col-md-12 d-flex flex-column gap-7 gap-md-10">
                                    <LoadingButton 
                                        :loading="isLoading"
                                        class="btn btn-danger btn-block"
                                        @click="createContract()"><em class="fas fa-chevron-circle-down"></em> Approve & Create contract
                                    </LoadingButton>
                                </div>
                            </div>
                            
                        </div>
                    </div>
                </div>
        </div>

    </VueFinalModal>

</template>