import config from "@/config";
export const processDataForBackend = (originalData, tokenInfo) => {
    const processedData = JSON.parse(JSON.stringify(originalData));

    processedData.totalToken *= config.E8S;
    processedData.softcap *= config.E8S;
    processedData.hardcap *= config.E8S;
    processedData.minPrice *= config.E8S;
    processedData.maxPrice *= config.E8S;
    processedData.maxBuy *= config.E8S;
    processedData.minBuy *= config.E8S;

    for (const key in processedData.timeline) {
        processedData.timeline[key] = Math.round(processedData.timeline[key] * 1e6);
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