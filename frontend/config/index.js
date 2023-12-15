const NETWORK = {
    "development": {
        canister_id: "bkyz2-fmaaa-aaaaa-qaaaq-cai",
        endpoint: "http://127.0.0.1:8000",
        scan: "http://127.0.0.1:8000/?canisterId=bd3sg-teaaa-aaaaa-qaaba-cai&id="
    },
    "staging": {
        canister_id: "xq3hn-siaaa-aaaap-qbg7a-cai",
        endpoint: "https://icp0.io",
        scan: "https://dashboard.internetcomputer.org/canister/"
    },
    "ic": {
        canister_id: "can63-sqaaa-aaaap-qbjaq-cai",
        endpoint: "https://icp0.io",
        scan: "https://dashboard.internetcomputer.org/canister/"
    }
}
const ENV = "ic";// //development, staging, ic

const config = {
    APP_VERSION: '2.0.1',
    ENV: ENV,
    IC_ENDPOINT: NETWORK[ENV]['endpoint'],//https://boundary.ic0.app/
    CANISTER_MANAGER_ID: NETWORK[ENV]['canister_id'],
    CANIC_CANISTER_ID: "mxftc-eyaaa-aaaap-qanga-cai",
    CANISTER_CYCLE_MINTING: "rkp4c-7iaaa-aaaaa-aaaca-cai",
    CANISTER_IC_MANAGEMENT: "aaaaa-aa",
    CANISTER_STORAGE_ID: "psh4l-7qaaa-aaaap-qasia-cai",
    LEDGER_CANISTER_ID: "ryjl3-tyaaa-aaaaa-aaaba-cai",
    BLACKHOLE_CANISTER_ID: "nn2xz-fiaaa-aaaap-qa6lq-cai",
    CUSTOM_DOMAIN_MAXLENGTH: 32,//Max length for custom domain
    CANISTER_WHITE_LIST: [
        NETWORK[ENV]['canister_id'],
        'ryjl3-tyaaa-aaaaa-aaaba-cai',
        'aaaaa-aa',
        'rkp4c-7iaaa-aaaaa-aaaca-cai',
        'nn2xz-fiaaa-aaaap-qa6lq-cai'
    ],
    E8S: 100_000_000,
    CYCLES: 1_000_000_000_000,
    FEE: 10_000,
    MIN_DEPOSIT: 10_000*10,
    IC_SCAN: NETWORK[ENV]['scan'],
    MAX_CHUNK_SIZE: 1900000
}
export const defaultTokens = [
    {symbol: 'ICP', name: 'Internet Computer', canisterId: 'ryjl3-tyaaa-aaaaa-aaaba-cai', standard: 'ledger'}
]
export default config;