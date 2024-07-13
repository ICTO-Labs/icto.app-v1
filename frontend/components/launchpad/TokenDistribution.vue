<script setup>
    import { ref, reactive, computed } from 'vue';
    import Tokenomic from '@/components/launchpad/Tokenomic.vue';
    const activeTab = ref("fairlaunch");
    import { currencyFormat } from '@/utils/token';

    const showTab = (tab) => {
        if(activeTab.value === tab) activeTab.value = "";
        else activeTab.value = tab;
    }

    const isActive = (tab) => {
        return activeTab.value === tab;
    }

    const distribution = reactive({
        fairlaunch: {
            title: "Fairlaunch",
            description: "Tokens available for public sale",
            total: 25_000,
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
            total: 15_000,
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
            total: 100_000_000,
            vesting: {
                cliff: 0,
                duration: 2 * 365 * 24 * 60 * 60,
                unlockFrequency: 0,
            },
            recipients: []
        },
        others: []
    });

    const addRecipient = (key, otherIndex = null) => {
        if (key === 'others') {
            if (otherIndex !== null) {
                distribution.others[otherIndex].recipients.push({
                    amount: 0,
                    address: "",
                    note: ""
                });
            }
        } else {
            distribution[key].recipients.push({
                amount: 0,
                address: "",
                note: ""
            });
        }
    };

    const addOther = () => {
        distribution.others.push({
            title: "",
            description: "",
            total: 0,
            vesting: { cliff: 0, duration: 0, unlockFrequency: 0 },
            recipients: []
        });
    };

    const removeRecipient = (key, index, otherIndex = null) => {
        if (key === 'others') {
            distribution.others[otherIndex].recipients.splice(index, 1);
        } else if (Array.isArray(distribution[key])) {
            distribution[key].splice(index, 1);
        } else {
            distribution[key].recipients.splice(index, 1);
        }
    };

    const removeOther = (index) => {
        distribution.others.splice(index, 1);
    };

    const getUnit = (seconds, timeUnit) => {
        return Math.floor(seconds / timeUnit);
    };
    const getTimeUnit = (seconds) => {
        if (seconds % 31536000 === 0) return 31536000; // Year
        if (seconds % 2628002 === 0) return 2628002;   // Month
        if (seconds % 604800 === 0) return 604800;     // Week
        return 86400; // Day
    };

    const setSeconds = (key, field, unit, time, index = null) => {
        const seconds = unit * time;
        if (index !== null) {
            distribution.others[index].vesting[field] = seconds;
        } else {
            distribution[key].vesting[field] = seconds;
        }
    };


    const calculateTotal = (key) => {
        if (key === 'team') {
            return distribution.team.recipients.reduce((sum, recipient) => sum + recipient.amount, 0);
        } else if (key.startsWith('others_')) {
            const index = parseInt(key.split('_')[1]);
            return distribution.others[index].recipients.reduce((sum, recipient) => sum + recipient.amount, 0);
        }
        return 0;
    };
    const totals = computed(() => {
        const result = {
            fairlaunch: distribution.fairlaunch.total,
            liquidity: distribution.liquidity.total,
            team: calculateTotal('team'),
            others: 0,
        };
        distribution.others.forEach((_, index) => {
            result[`others_${index}`] = calculateTotal(`others_${index}`);
            result['others'] += result[`others_${index}`];
        });
        return result;
    });
    const vestingUnits = computed(() => {
        const result = {};
        for (const key in distribution) {
            if (key !== 'others') {
                const vesting = distribution[key].vesting;
                result[key] = {
                    cliffUnit: getUnit(vesting.cliff, getTimeUnit(vesting.cliff)),
                    cliffTime: getTimeUnit(vesting.cliff),
                    durationUnit: getUnit(vesting.duration, getTimeUnit(vesting.duration)),
                    durationTime: getTimeUnit(vesting.duration),
                };
            }
        }
        distribution.others.forEach((other, index) => {
            result[`others_${index}`] = {
                cliffUnit: getUnit(other.vesting.cliff, getTimeUnit(other.vesting.cliff)),
                cliffTime: getTimeUnit(other.vesting.cliff),
                durationUnit: getUnit(other.vesting.duration, getTimeUnit(other.vesting.duration)),
                durationTime: getTimeUnit(other.vesting.duration),
            };
        });
        return result;
    });
    const tokenomics = computed(() => {
        const result = [
            { title: "Fairlaunch", value: totals.value.fairlaunch },
            { title: "Liquidity", value: totals.value.liquidity },
            { title: "Team", value: totals.value.team }
        ];

        distribution.others.forEach((other, index) => {
            result.push({ title: other.title || `Other ${index + 1}`, value: totals.value[`others_${index}`] });
        });
        return result;
    });
    const totalSupply = computed(() => {
        return tokenomics.value.reduce((sum, item) => sum + item.value, 0);
    });
</script>

<template>
    <div class="accordion" id="kt_accordion_1">
        <div v-for="(config, key) in distribution" :key="key" class="accordion-item">
            <h5 class="accordion-header" :id="`kt_accordion_1_header_${key}`">
                <button 
                    :class="`accordion-button fs-4 p-5 fw-bold ${isActive(key) ? '' : 'collapsed'}`" 
                    type="button" 
                    @click="showTab(key)"
                >
                    {{ config.title || (Array.isArray(config) ? 'Others ': key) }}
                    <!-- <span class="badge badge-light-primary badge-circle fw-n fs-7 ms-3" v-if="Array.isArray(config)">{{ distribution.others.length }}</span> -->
                    <div class="badge badge-primary text-right fw-bold py-2 px-2 ms-3">{{ currencyFormat(totals[key]) }}</div>

                </button>
            </h5>
            <div 
                :id="`kt_accordion_1_body_${key}`" 
                :class="`accordion-collapse collapse ${isActive(key) ? 'show' : ''}`"
            >
                <div class="accordion-body">
                    <template v-if="!Array.isArray(config)">
                        <div class="row mb-5">
                            <div class="col-md-4">
                                <label class="fs-7 fw-bold form-label mb-2">Total amount:</label>
                                <input v-if="key === 'fairlaunch' || key === 'liquidity'" :value="config.total.toLocaleString()" type="text" disabled class="form-control form-control-sm" />
                                <input v-else-if="key === 'team'" :value="totals.team.toLocaleString()" type="text" disabled class="form-control form-control-sm" />

                                <!-- <input v-model.number="config.total" type="number" placeholder="Total" class="form-control form-control-sm" /> -->
                            </div>
                            <div class="col-md-8">
                                <label class="fs-7 fw-bold form-label mb-2">Description:</label>
                                <input v-model="config.description" placeholder="Description"  class="form-control form-control-sm"/>
                            </div>
                        </div>
                        <!-- <input v-model="config.title" placeholder="Title" class="form-control"/> -->
                        
                        <h6>Vesting</h6>
                        <div class="row mb-5">
                            
                            <div class="col-md-4">
                                <label class="fs-7 fw-bold form-label mb-2 required">Unlock frequency:</label>
                                <select name="releaseFrequencyPeriod" class="form-select form-select-sm" v-model.number="config.vesting.unlockFrequency" >
												<optgroup label="Unlock Immediately">
													<option value="0">Unlock Immediately</option>
												</optgroup>
												<optgroup label="Single">
													<option value="-1">Fully unlocks after...</option>
												</optgroup>
												<!-- <optgroup label="Unlock linear">
													<option value="60">Unlock Linear</option>
												</optgroup> -->
												<optgroup label="Or choose schedule">
													<!-- <option value="60">Per Minute</option>
													<option value="3600">Hourly</option> -->
													<option value="86400">Daily</option>
													<option value="604800">Weekly</option>
													<option value="2628002">Monthly</option>
													<option value="7884006">Quarterly</option>
													<option value="31536000">Yearly</option>
												</optgroup>
											</select>
                                <!-- <input v-model.number="config.vesting.duration" type="number" placeholder="Duration (seconds)" class="form-control form-control-sm" /> -->
                            </div>
                            <div class="col-md-4">
                                <label class="fs-7 fw-bold form-label mb-2 required">Vesting Duration:</label>
                                <div class="row fv-row">
                                    <div class="col-4">
                                        <input type="number" class="form-control form-control-sm" placeholder="Number" 
                                            @input="setSeconds(key, 'duration', $event.target.value, vestingUnits[key].durationTime)"
                                            :value="vestingUnits[key].durationUnit"
                                            :disabled="config.vesting.unlockFrequency==0"/>
                                    </div>
                                    <div class="col-8">
                                        <select class="form-select form-select-sm" 
                                                @change="setSeconds(key, 'duration', vestingUnits[key].durationUnit, $event.target.value)"
                                                :value="vestingUnits[key].durationTime"
                                                :disabled="config.vesting.unlockFrequency==0">
                                            <option value="86400">Day</option>
                                            <option value="604800">Week</option>
                                            <option value="2628002">Month</option>
                                            <option value="7884006">Quarter</option>
                                            <option value="31536000">Year</option>
                                        </select>
                                    </div>
                                </div>

                                <!-- <input v-model.number="config.vesting.unlockFrequency" type="number" placeholder="Unlock Frequency (seconds)" class="form-control form-control-sm" /> -->
                            </div>
                            <div class="col-md-4">
                                <label class="fs-7 fw-bold form-label mb-2">Cliff:</label>
                                <div class="row fv-row">
                                    <div class="col-4">
                                        <input type="number" class="form-control form-control-sm" required placeholder="Number" 
                                            @input="setSeconds(key, 'cliff', $event.target.value, vestingUnits[key].cliffTime)"
                                            :value="vestingUnits[key].cliffUnit"
                                            :disabled="config.vesting.unlockFrequency==0"/>
                                    </div>
                                    <div class="col-8">
                                        <select class="form-select form-select-sm" 
                                                @change="setSeconds(key, 'cliff', vestingUnits[key].cliffUnit, $event.target.value)"
                                                :value="vestingUnits[key].cliffTime"
                                                :disabled="config.vesting.unlockFrequency==0">
                                            <option value="86400">Day</option>
                                            <option value="604800">Week</option>
                                            <option value="2628002">Month</option>
                                            <option value="7884006">Quarter</option>
                                            <option value="31536000">Year</option>
                                        </select>
                                    </div>
                                </div>
                                <!-- <input v-model.number="config.vesting.cliff" type="number" placeholder="Cliff (seconds)" class="form-control form-control-sm" /> -->
                            </div>
                        </div>

                        
                        <h6 v-if="key=='team'">Recipients <span class="badge badge-light fw-bold py-2 px-2 ms-2 text-primary">{{ config.recipients.length }}</span></h6>
                            <div class="row mb-0">
                                <div class="col-md-2">
                                    <label class="fs-7 fw-bold form-label mb-2 required">Amount:</label>
                                </div>
                                <div class="col-md-6">
                                    <label class="fs-7 fw-bold form-label mb-2 required">Principal:</label>
                                </div>
                                <div class="col-md-3">
                                    <label class="fs-7 fw-bold form-label mb-2">Note (option):</label>
                                </div>
                                <div class="col-md-1">
                                    <label class="fs-7 fw-bold form-label mb-2">&nbsp;</label>
                                </div>
                            </div>
                            <div v-for="(recipient, index) in config.recipients" :key="index" v-if="key=='team'">
                                <div class="row mb-2">
                                    <div class="col-md-2">
                                        <input v-model.number="recipient.amount" type="number" min="0" placeholder="Amount" class="form-control form-control-sm" />
                                    </div>
                                    <div class="col-md-6">
                                        <input v-model="recipient.address" :placeholder="`Principal #${index+1}`"  class="form-control form-control-sm" />
                                    </div>
                                    <div class="col-md-3">
                                        <input v-model="recipient.note" placeholder="Note" class="form-control form-control-sm" />
                                    </div>
                                    <div class="col-md-1">
                                        <div>
                                            <button @click="removeRecipient(key, index)" type="button" class="btn btn-danger btn-sm btn-icon"><i class="fas fa-trash"></i></button>
                                        </div>
                                    </div>
                                </div>
                            </div>
                        <button @click="addRecipient(key)" type="button" class="btn btn-primary btn-sm" v-if="key=='team'"><i class="fas fa-plus"></i> Add Recipient</button>
                    </template>
                    <template v-else>
                        <div v-for="(otherConfig, otherIndex) in config" :key="otherIndex" class="mb-5">
                            <h4> Allocation #{{otherIndex+1}} </h4>
                            <div class="row mb-5">
                                <div class="col-md-12">
                                    <label class="fs-7 fw-bold form-label mb-2">Name:</label>
                                    <input v-model="otherConfig.title" type="text" placeholder="Name, Ex: Advisors..." class="form-control form-control-sm" />
                                </div>
                            </div>
                            <div class="row mb-5">
                                <div class="col-md-4">
                                    <label class="fs-7 fw-bold form-label mb-2">Total amount:</label>
                                    <input :value="totals[`others_${otherIndex}`].toLocaleString()" type="text" readonly class="form-control form-control-sm" />
                                    <!-- <input v-model.number="otherConfig.total" type="number" placeholder="Total" class="form-control form-control-sm" /> -->
                                </div>
                                <div class="col-md-8">
                                    <label class="fs-7 fw-bold form-label mb-2">Description:</label>
                                    <input v-model="otherConfig.description" placeholder="Description"  class="form-control form-control-sm"/>
                                </div>
                            </div>
                            
                            
                            <h6>Vesting</h6>
                            <div class="row mb-5">
                                
                                <div class="col-md-4">
                                    <label class="fs-7 fw-bold form-label mb-2 required">Unlock frequency:</label>
                                    <select name="releaseFrequencyPeriod" class="form-select form-select-sm" v-model.number="otherConfig.vesting.unlockFrequency" >
                                                    <optgroup label="Unlock Immediately">
                                                        <option value="0">Unlock Immediately</option>
                                                    </optgroup>
                                                    <optgroup label="Single">
                                                        <option value="-1">Fully unlocks after...</option>
                                                    </optgroup>
                                                    <!-- <optgroup label="Unlock linear">
                                                        <option value="60">Unlock Linear</option>
                                                    </optgroup> -->
                                                    <optgroup label="Or choose schedule">
                                                        <!-- <option value="60">Per Minute</option>
                                                        <option value="3600">Hourly</option> -->
                                                        <option value="86400">Daily</option>
                                                        <option value="604800">Weekly</option>
                                                        <option value="2628002">Monthly</option>
                                                        <option value="7884006">Quarterly</option>
                                                        <option value="31536000">Yearly</option>
                                                    </optgroup>
                                                </select>
                                    <!-- <input v-model.number="config.vesting.duration" type="number" placeholder="Duration (seconds)" class="form-control form-control-sm" /> -->
                                <!-- </div> -->
                                    <!-- <label class="fs-6 fw-bold form-label mb-2">Cliff:</label>
                                    <input v-model.number="otherConfig.vesting.cliff" type="number" placeholder="Cliff (seconds)" class="form-control form-control-sm" /> -->
                                </div>
                                <div class="col-md-4">
                                    <label class="fs-7 fw-bold form-label mb-2 required">Duration:</label>
                                    <div class="row fv-row">
                                        <div class="col-4">
                                            <input type="number" class="form-control form-control-sm" placeholder="Number" 
                                                @input="setSeconds('others', 'duration', $event.target.value, vestingUnits[`others_${otherIndex}`].durationTime, otherIndex)"
                                                :value="vestingUnits[`others_${otherIndex}`].durationUnit"
                                                :disabled="otherConfig.vesting.unlockFrequency==0"/>
                                        </div>
                                        <div class="col-8">
                                            <select class="form-select form-select-sm" 
                                                    @change="setSeconds('others', 'duration', vestingUnits[`others_${otherIndex}`].durationUnit, $event.target.value, otherIndex)"
                                                    :value="vestingUnits[`others_${otherIndex}`].durationTime"
                                                    :disabled="otherConfig.vesting.unlockFrequency==0">
                                                <option value="86400">Day</option>
                                                <option value="604800">Week</option>
                                                <option value="2628002">Month</option>
                                                <option value="7884006">Quarter</option>
                                                <option value="31536000">Year</option>
                                            </select>
                                        </div>
                                    </div>
                                    <!-- <label class="fs-6 fw-bold form-label mb-2">Duration:</label>
                                    <input v-model.number="otherConfig.vesting.duration" type="number" placeholder="Duration (seconds)" class="form-control form-control-sm" /> -->
                                </div>
                                <div class="col-md-4">
                                    <label class="fs-7 fw-bold form-label mb-2">Cliff:</label>
                                    <div class="row fv-row">
                                        <div class="col-4">
                                            <input type="number" class="form-control form-control-sm" required placeholder="Number" 
                                                @input="setSeconds('others', 'cliff', $event.target.value, vestingUnits[`others_${otherIndex}`].cliffTime, otherIndex)"
                                                :value="vestingUnits[`others_${otherIndex}`].cliffUnit"
                                                :disabled="otherConfig.vesting.unlockFrequency==0"/>
                                        </div>
                                        <div class="col-8">
                                            <select class="form-select form-select-sm" 
                                                    @change="setSeconds('others', 'cliff', vestingUnits[`others_${otherIndex}`].cliffUnit, $event.target.value, otherIndex)"
                                                    :value="vestingUnits[`others_${otherIndex}`].cliffTime"
                                                    :disabled="otherConfig.vesting.unlockFrequency==0">
                                                <option value="86400">Day</option>
                                                <option value="604800">Week</option>
                                                <option value="2628002">Month</option>
                                                <option value="7884006">Quarter</option>
                                                <option value="31536000">Year</option>
                                            </select>
                                        </div>
                                    </div>
                                    <!-- <label class="fs-6 fw-bold form-label mb-2">Unlock Frequency:</label>
                                    <input v-model.number="otherConfig.vesting.unlockFrequency" type="number" placeholder="Unlock Frequency (seconds)" class="form-control form-control-sm" /> -->
                                </div>
                            </div>
                            <h6>Recipients  <span class="badge badge-light fw-bold py-2 px-2 ms-2 text-primary">{{ otherConfig.recipients.length }}</span></h6>
                            <div class="row mb-0">
                                <div class="col-md-2">
                                    <label class="fs-7 fw-bold form-label mb-2 required">Amount:</label>
                                </div>
                                <div class="col-md-6">
                                    <label class="fs-7 fw-bold form-label mb-2 required">Principal:</label>
                                </div>
                                <div class="col-md-3">
                                    <label class="fs-7 fw-bold form-label mb-2">Note (option):</label>
                                </div>
                                <div class="col-md-1">
                                    <label class="fs-7 fw-bold form-label mb-2">&nbsp;</label>
                                </div>
                            </div>
                            <div v-for="(recipient, recipientIndex) in otherConfig.recipients" :key="recipientIndex">
                                <div class="row mb-2">
                                    <div class="col-md-2">
                                        <input v-model.number="recipient.amount" type="number" min="0" placeholder="Amount" class="form-control form-control-sm" />
                                    </div>
                                    <div class="col-md-6">
                                        <input v-model="recipient.address" :placeholder="`Principal #${recipientIndex+1}`" class="form-control form-control-sm" />
                                    </div>
                                    <div class="col-md-3">
                                        <input v-model="recipient.note" placeholder="Note" class="form-control form-control-sm" />
                                    </div>
                                    <div class="col-md-1">
                                        <div>
                                            <button @click="removeRecipient('others', recipientIndex, otherIndex)" type="button" class="btn btn-danger btn-sm btn-icon"><i class="fas fa-trash"></i></button>
                                        </div>
                                    </div>
                                </div>
                            </div>
                            <button @click="addRecipient('others', otherIndex)" type="button" class="btn btn-primary btn-sm me-5"><i class="fas fa-plus"></i> Add Recipient</button>
                                <button @click="removeOther(otherIndex)" type="button" class="btn btn-danger btn-sm"><i class="fas fa-trash"></i> Remove this allocation</button>
                            <div class="separator separator-dashed mt-5"></div>

                        </div>
                        <button @click="addOther" type="button" class="btn btn-info btn-sm"><i class="fas fa-plus"></i> Add allocation</button>
                    </template>
                </div>
            </div>
        </div>

        <Tokenomic :data="tokenomics"></Tokenomic>

        <div>
            <div class="row">
                <div class="col-md-12 text-center">
                    <h5 class="fw-bold form-label mb-2 fs-4">Total Supply: <span class="text-danger">{{ currencyFormat(totalSupply) }}</span></h5>
                </div>
            </div>
        </div>
    </div>
</template>