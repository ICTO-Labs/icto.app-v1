export const DURATION = {
    "1": "Second",
    "60": "Minute",
    "3600": "Hour",
    "86400": "Day",
    "604800": "Week",
    "2628002": "Month",
    "7884006": "Quarter",
    "31536000": "Year",
};
export const SCHEDULE = {
    "1": "Per Second",
    "60": "Per Minute",
    "3600": "Hourly",
    "86400": "Daily",
    "604800": "Weekly",
    "2628002": "Monthly",
    "7884006": "Quarterly",
    "31536000": "Yearly",
};

//Default init tokens
export const TOKEN_DATA = [
    {
        name: "Internet Computer", 
        decimals: 8, 
        fee: 10000, 
        symbol: "ICP", 
        logo: "/media/icons/ryjl3-tyaaa-aaaaa-aaaba-cai.svg", 
        standard: "ICRC2", 
        canisterId: "ryjl3-tyaaa-aaaaa-aaaba-cai",
        balance: 0,
        type: "default"
    },
    {
        name: "Quokka", 
        decimals: 8, 
        fee: 100000, 
        symbol: "QUOKKA", 
        logo: "/media/icons/k25mb-qiaaa-aaaap-qpodq-cai.png", 
        standard: "ICRC2", 
        canisterId: "k25mb-qiaaa-aaaap-qpodq-cai",
        balance: 0,
        type: "default"
    },
    {
        name: "ckETH", 
        decimals: 18, 
        fee: 200, 
        symbol: "ckETH", 
        logo: "/media/icons/ss2fx-dyaaa-aaaar-qacoq-cai.png", 
        standard: "ICRC2", 
        canisterId: "ss2fx-dyaaa-aaaar-qacoq-cai",
        balance: 0,
        type: "default"
    },
    {
        name: "ckBTC", 
        decimals: 8, 
        fee: 1000000, 
        symbol: "ckBTC", 
        logo: "/media/icons/mxzaz-hqaaa-aaaar-qaada-cai.png", 
        standard: "ICRC2", 
        canisterId: "mxzaz-hqaaa-aaaar-qaada-cai",
        balance: 0,
        type: "default"
    },
];