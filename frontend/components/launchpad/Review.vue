<script setup>
    import { ref } from 'vue';
    import { currencyFormat } from '@/utils/token';

    const props = defineProps({
        launchpad: {
            type: Object,
            required: true
        }
    });
    const showRecipientsFor = ref(null);

    const toggleRecipients = (key) => {
        showRecipientsFor.value = showRecipientsFor.value === key ? null : key;
    };

</script>
<template>
    <div class="launchpad-info">
        <h3>General Settings</h3>
        <table class="table table-flush align-middle table-row-bordered gy-3 table-hover">
            <tr>
                <td>Governance Model:</td>
                <td class="text-end">{{ launchpad.governanceModel ? 'Yes' : 'No' }}</td>
            </tr>
            <tr>
                <td>Whitelist:</td>
                <td class="text-end">{{ launchpad.whitelist > 0 ?"Yes":"No" }}</td>
            </tr>
            <!-- <tr>
                <td>Total Supply:</td>
                <td class="text-end">{{ launchpad.totalToken }}</td>
            </tr> -->
            <tr>
                <td>Affiliate:</td>
                <td class="text-end">{{ launchpad.affiliate>0? "Yes ("+launchpad.affiliate+"%)":"No" }}</td>
            </tr>
            <tr>
                <td>Listing Liquidity:</td>
                <td class="text-end">{{ launchpad.listingLiquidity }}%</td>
            </tr>
            <tr>
                <td>Listing Token Amount:</td>
                <td class="text-end">{{ currencyFormat(launchpad.listingTokenAmount) }}</td>
            </tr>
            <tr>
                <td>Listing on:</td>
                <td class="text-end">{{ launchpad.listing }}</td>
            </tr>
        </table>

        <h3>Sale Token</h3>
        <table class="table table-flush align-middle table-row-bordered gy-3 table-hover">
            <tbody>
                <tr>
                    <td>Name:</td>
                    <td class="text-end fw-bold"><img :src="launchpad.saleToken.logo" class="w-30px" /> {{ launchpad.saleToken.name }}</td>
                </tr>
                <tr>
                    <td>Symbol:</td>
                    <td class="text-end fw-bold">{{ launchpad.saleToken.symbol }}</td>
                </tr>
                <tr>
                    <td>Decimals:</td>
                    <td class="text-end fw-bold">{{ launchpad.saleToken.decimals }}</td>
                </tr>
                <tr>
                    <td>Transfer Fee:</td>
                    <td class="text-end fw-bold">{{ launchpad.saleToken.transferFee }}</td>
                </tr>
                <tr>
                    <td>Canister ID:</td>
                    <td class="text-end fw-bold"><div class="badge badge-light-danger">Your token will be deployed after reaching the softcap</div></td>
                </tr>
            </tbody>
        </table>

        <h3>Purchase Token</h3>
        <table class="table table-flush align-middle table-row-bordered gy-3 table-hover">
            <tbody>
                <tr>
                    <td>Name:</td>
                    <td class="text-end fw-bold"><img :src="launchpad.purchaseToken.logo" class="w-30px" /> {{ launchpad.purchaseToken.name }}</td>
                </tr>
                <tr>
                    <td>Symbol:</td>
                    <td class="text-end fw-bold">{{ launchpad.purchaseToken.symbol }}</td>
                </tr>
                <tr>
                    <td>Decimals:</td>
                    <td class="text-end fw-bold">{{ launchpad.purchaseToken.decimals }}</td>
                </tr>
                <tr>
                    <td>Transfer Fee:</td>
                    <td class="text-end fw-bold">{{ launchpad.purchaseToken.transferFee }}</td>
                </tr>
                <tr>
                    <td>Canister ID:</td>
                    <td class="text-end fw-bold">{{ launchpad.purchaseToken.canisterId }}</td>
                </tr>
            </tbody>
        </table>

        <h3>Launch Parameters</h3>
        <table class="table table-flush align-middle table-row-bordered gy-3 table-hover">
            <tbody>
                <tr>
                    <td>Sell Amount:</td>
                    <td class="text-end">{{ currencyFormat(launchpad.launchParams.sellAmount) }}</td>
                </tr>
                <tr>
                    <td>Soft Cap:</td>
                    <td class="text-end">{{ currencyFormat(launchpad.launchParams.softCap) }} ICP</td>
                </tr>
                <tr>
                    <td>Hard Cap:</td>
                    <td class="text-end">{{ currencyFormat(launchpad.launchParams.hardCap) }} ICP</td>
                </tr>
                <tr>
                    <td>Minimum Amount:</td>
                    <td class="text-end">{{ launchpad.launchParams.minimumAmount }} ICP</td>
                </tr>
                <tr>
                    <td>Maximum Amount:</td>
                    <td class="text-end">{{ launchpad.launchParams.maximumAmount }} ICP</td>
                </tr>
            </tbody>
        </table>
        <h3>Distribution</h3>

        <table class="table table-flush align-middle table-row-bordered gy-3 table-border table-hover">
            <thead>
                <tr class="fw-bolder p-3 ">
                    <th>Type</th>
                    <th>Total</th>
                    <th>Vesting Cliff(s)</th>
                    <th>Vesting Duration(s)</th>
                    <th>Unlock Frequency(s)</th>
                    <th>Recipients</th>
                </tr>
            </thead>
            <tbody>
                <template v-for="(value, key) in launchpad.distribution" :key="key">
                    <tr v-if="key !== 'others'">
                        <td class="fw-bolder">
                            <div>{{ key.charAt(0).toUpperCase() + key.slice(1) }}</div>
                            <div class="fw-normal">{{ value.description }}</div>
                        </td>
                        <td class="text-end fw-bold">{{ currencyFormat(value.total) }}</td>
                        <td class="text-center">{{ value.vesting.cliff }}</td>
                        <td class="text-center">{{ value.vesting.duration }}</td>
                        <td class="text-center">{{ value.vesting.unlockFrequency }}</td>
                        <td>
                            <button type="button" @click="toggleRecipients(key)" class="btn btn-sm btn-primary"
                                v-if="value.recipients && value.recipients.length">
                                Recipients ({{ value.recipients.length }})
                            </button>
                        </td>
                    </tr>
                    <tr v-if="showRecipientsFor === key">
                        <td colspan="5" class="px-5">
                            <table class="table table-sm table-flush align-middle table-row-bordered">
                                <thead>
                                    <tr class="fw-bold">
                                        <th>Amount</th>
                                        <th>Principal</th>
                                        <th>Note</th>
                                    </tr>
                                </thead>
                                <tbody>
                                    <tr v-for="(recipient, index) in value.recipients" :key="index">
                                        <td>{{ currencyFormat(recipient.amount) }}</td>
                                        <td>{{ recipient.address }}</td>
                                        <td>{{ recipient.note?recipient.note[0]:'' }}</td>
                                    </tr>
                                </tbody>
                            </table>
                        </td>
                    </tr>
                </template>
                <template v-for="(other, index) in launchpad.distribution.others" :key="`other-${index}`">
                    <tr>
                        <td class="fw-bolder">
                            <div>{{ other.title }}</div>
                            <div class="fw-normal">{{ other.description }}</div>
                        </td>
                        <td class="text-end fw-bold">{{ currencyFormat(other.total) }}</td>
                        <td class="text-center">{{ other.vesting.cliff }}</td>
                        <td class="text-center">{{ other.vesting.duration }}</td>
                        <td class="text-center">{{ other.vesting.unlockFrequency }}</td>
                        <td>
                            <button type="button" @click="toggleRecipients(`other-${index}`)" class="btn btn-sm btn-primary"
                                v-if="other.recipients && other.recipients.length">
                                Recipients ({{ other.recipients.length }})
                            </button>
                        </td>
                    </tr>
                    <tr v-if="showRecipientsFor === `other-${index}`">
                        <td colspan="5" class="px-5">
                            <table class="table table-sm table-flush align-middle table-row-bordered">
                                <thead>
                                    <tr class="fw-bold">
                                        <th>Amount</th>
                                        <th>Principal</th>
                                        <th>Note</th>
                                    </tr>
                                </thead>
                                <tbody>
                                    <tr v-for="(recipient, recipientIndex) in other.recipients" :key="recipientIndex">
                                        <td>{{ currencyFormat(recipient.amount) }}</td>
                                        <td>{{ recipient.address }}</td>
                                        <td>{{ recipient.note }}</td>
                                    </tr>
                                </tbody>
                            </table>
                        </td>
                    </tr>
                </template>
            </tbody>
        </table>

        <h3>Project Info</h3>
        <table class="table table-flush align-middle table-row-bordered gy-3 table-hover">
            <tbody>
                <tr>
                    <td>Logo:</td>
                    <td class="text-end"><img :src="launchpad.projectInfo.logo" class="w-80px"></td>
                </tr>
                <!-- <tr>
                    <td>Cover/Banner:</td>
                    <td class="text-end"><img :src="launchpad.projectInfo.banner" class="w-120px"></td>
                </tr> -->
                <tr>
                    <td>Name:</td>
                    <td class="text-end">{{ launchpad.projectInfo.name }}</td>
                </tr>
                <tr>
                    <td>Description:</td>
                    <td class="text-end">{{ launchpad.projectInfo.description }}</td>
                </tr>
                <tr>
                    <td>Is Audited:</td>
                    <td class="text-end">{{ launchpad.projectInfo.isAudited }}</td>
                </tr>
                <tr>
                    <td>Is Verified:</td>
                    <td class="text-end">{{ launchpad.projectInfo.isVerified }}</td>
                </tr>
                <tr>
                    <td>Links:</td>
                    <td class="text-end">
                        <ul class="" style="list-style: none;">
                            <li class="text-end" v-for="(link, index) in launchpad.projectInfo.links" :key="index">
                                <a :href="link" target="_blank">{{ link }}</a>
                            </li>
                        </ul>
                    </td>
                </tr>
        </tbody>
        </table>

        <h3>Launch Timelines</h3>
        <table class="table table-flush align-middle table-row-bordered gy-3 table-hover">
            <tbody>
                <tr>
                    <td>Start Time:</td>
                    <td class="text-end">{{ new Date(launchpad.timeline.startTime).toLocaleString() }}</td>
                </tr>
                <tr>
                    <td>End Time:</td>
                    <td class="text-end">{{ new Date(launchpad.timeline.endTime).toLocaleString() }}</td>
                </tr>
                <tr>
                    <td>Claim Time:</td>
                    <td class="text-end">{{ new Date(launchpad.timeline.claimTime).toLocaleString() }}</td>
                </tr>
                <tr>
                    <td>Listing Time:</td>
                    <td class="text-end">{{ new Date(launchpad.timeline.listingTime).toLocaleString() }}</td>
                </tr>
            </tbody>
        </table>
    </div>
</template>