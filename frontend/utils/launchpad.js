import config from "@/config";
import moment from "moment";
import { ref } from 'vue';

export const processDataForBackend = (originalData, tokenInfo) => {
    console.log('originalData', originalData);
    const processedData = JSON.parse(JSON.stringify(originalData));

    processedData.totalToken *= config.E8S;
    processedData.softcap *= config.E8S;
    processedData.hardcap *= config.E8S;
    processedData.minPrice *= config.E8S;
    processedData.maxPrice *= config.E8S;
    processedData.maxBuy *= config.E8S;
    processedData.minBuy *= config.E8S;

    for (const key in processedData.timeline) {
            //Process timeline
    // processedData.timeline.startTime = processedData.timeline.startTime.valueOf();
    // processedData.timeline.endTime = processedData.timeline.endTime.valueOf();
    // processedData.timeline.claimTime = processedData.timeline.claimTime.valueOf();
    // processedData.timeline.listingTime = processedData.timeline.listingTime.valueOf();

        processedData.timeline[key] = Math.round(moment(processedData.timeline[key]).valueOf() * 1e6);
    }

    const processRecipients = (recipients) => {
        return recipients.map(recipient => ({
            ...recipient,
            amount: recipient.amount * config.E8S,
            note: [recipient.note]
        }));
    };

    for (const key in processedData.distribution) {
        const allocation = processedData.distribution[key];
        allocation.total *= config.E8S;
        
        if (allocation.recipients && Array.isArray(allocation.recipients)) {
            allocation.recipients = processRecipients(allocation.recipients);
        }
    }

    if (Array.isArray(processedData.distribution.others)) {
        processedData.distribution.others = processedData.distribution.others.map(allocation => ({
            ...allocation,
            total: allocation.total * config.E8S,
            recipients: processRecipients(allocation.recipients || [])
        }));
    }

    processedData.launchParams.sellAmount *= config.E8S;
    processedData.launchParams.softCap *= config.E8S;
    processedData.launchParams.hardCap *= config.E8S;
    processedData.launchParams.minimumAmount *= config.E8S;
    processedData.launchParams.maximumAmount *= config.E8S;

    //Process links
    processedData.projectInfo.links = [processedData.projectInfo.links];

    return processedData;
};

export const formatTokenomic = (distribution) => {
    let tokenomics = [];

    for (const key in distribution) {
    if (key !== 'others' && typeof distribution[key] === 'object' && distribution[key].title) {
        tokenomics.push({
            title: distribution[key].title,
            value: Number(distribution[key].total)/config.E8S
        });
    }
    }

    // Process 'others'
    if (Array.isArray(distribution.others)) {
        distribution.others.forEach(item => {
            if (item.title) {
            tokenomics.push({
                title: item.title,
                value: Number(item.total)/config.E8S
            });
            }
        });
    }
    return tokenomics;
};

export const useProjectScore = ()=>{
    const metrics = ref([
        { name: 'isDAO', type: 'boolean', weight: 10 },
        { name: 'isKYC', type: 'boolean', weight: 10 },
        { name: 'isAudited', type: 'boolean', weight: 15 },
        { name: 'isVerified', type: 'boolean', weight: 10 },
        { name: 'autoLockLP', type: 'boolean', weight: 10 },
        { name: 'percentLPLock', type: 'number', weight: 25, minValue: 10, maxValue: 100, isLowerBetter: false },
        { name: 'teamAllocationPercent', type: 'number', weight: 20, minValue: 0, maxValue: 100, isLowerBetter: true },
    ]);

    const addMetric = (metric) => {
        metrics.value.push(metric);
    };

    const removeMetric = (name) => {
        const index = metrics.value.findIndex(m => m.name === name);
        if (index !== -1) {
        metrics.value.splice(index, 1);
        }
    };

    const calculateScore = (assessment) => {
        let totalScore = 0;
        let totalWeight = 0;

        metrics.value.forEach(metric => {
        const value = assessment[metric.name];
        if (value !== undefined) {
            let score = 0;
            if (metric.type === 'boolean') {
            score = value ? metric.weight : 0;
            } else if (metric.type === 'number') {
            const range = (metric.maxValue || 100) - (metric.minValue || 0);
            const normalizedValue = (value - (metric.minValue || 0)) / range;
            score = metric.isLowerBetter ? 
                (1 - normalizedValue) * metric.weight :
                normalizedValue * metric.weight;
            }
            totalScore += score;
            totalWeight += metric.weight;
        }
        });

        return (totalScore / totalWeight) * 100;
    };

    return {
        metrics,
        addMetric,
        removeMetric,
        calculateScore
    };
}