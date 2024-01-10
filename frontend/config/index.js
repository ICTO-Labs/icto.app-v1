const NETWORK = {
    "dev": {
        canister_id: "bkyz2-fmaaa-aaaaa-qaaaq-cai",
        deployer_id: "be2us-64aaa-aaaaa-qaabq-cai",
        backend_id: "bd3sg-teaaa-aaaaa-qaaba-cai",
        host: "http://127.0.0.1:8000",
        identityProvider: "http://127.0.0.1:8000/?canisterId=br5f7-7uaaa-aaaaa-qaaca-cai#authorize",
        scan: "http://127.0.0.1:8000/?canisterId=bd3sg-teaaa-aaaaa-qaaba-cai&id="
    },
    "staging": {
        canister_id: "xq3hn-siaaa-aaaap-qbg7a-cai",
        host: "https://icp0.io",
        scan: "https://dashboard.internetcomputer.org/canister/"
    },
    "ic": {
        canister_id: "can63-sqaaa-aaaap-qbjaq-cai",
        host: "https://icp0.io",
        scan: "https://dashboard.internetcomputer.org/canister/",
        identityProvider: "https://identity.ic0.app/#authorize"
    }
}
const ENV = "dev";// //dev, staging, ic

const config = {
    APP_VERSION: '2.0.1',
    ENV: ENV,
    IDENTITY_PROVIDER: NETWORK[ENV]['identityProvider'],
    HOST: NETWORK[ENV]['host'],//https://boundary.ic0.app/
    CANISTER_MANAGER_ID: NETWORK[ENV]['canister_id'],
    DEPLOYER_CANISTER_ID: NETWORK[ENV]['deployer_id'],
    BACKEND_CANISTER_ID: NETWORK[ENV]['backend_id'],
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
    MAX_CHUNK_SIZE: 1900000,
    WALLET_CONFIG: {
        "nns": true,
        "stoic": true,
        "plug": true,
        "bitfinity": true,
    },
}
export const defaultTokens = [
    {symbol: 'ICP', name: 'Internet Computer', canisterId: 'ryjl3-tyaaa-aaaaa-aaaba-cai', standard: 'ledger'}
]
export default config;