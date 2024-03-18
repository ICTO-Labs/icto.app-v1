import canisters from '../../canister_ids.json';
const NETWORK = {
    "dev": {
        canister_id: "aax3a-h4aaa-aaaaa-qaahq-cai",
        deployer_id: "be2us-64aaa-aaaaa-qaabq-cai",
        token_deployer_id: "c5kvi-uuaaa-aaaaa-qaaia-cai",
        backend_id: "bd3sg-teaaa-aaaaa-qaaba-cai",
        gov_token_id: "ajuq4-ruaaa-aaaaa-qaaga-cai",//governance token, required for charges
        host: "http://127.0.0.1:8000",
        identityProvider: "http://127.0.0.1:8000/?canisterId=br5f7-7uaaa-aaaaa-qaaca-cai#authorize",
        scan: "http://127.0.0.1:8000/?canisterId=bd3sg-teaaa-aaaaa-qaaba-cai&id="
    },
    "staging": {
        canister_id: "bkyz2-fmaaa-aaaaa-qaaaq-cai",
        deployer_id: "be2us-64aaa-aaaaa-qaabq-cai",
        backend_id: "bd3sg-teaaa-aaaaa-qaaba-cai",
        host: "https://icp-api.io",
        scan: "https://dashboard.internetcomputer.org/canister/"
    },
    "ic": {
        canister_id: canisters.frontend.ic,//"y3yam-6aaaa-aaaap-qb7aq-cai",
        deployer_id: canisters.deployer.ic,//"p7bu5-uyaaa-aaaap-qca3q-cai",
        token_deployer_id: canisters.token_deployer.ic,//"p7bu5-uyaaa-aaaap-qca3q-cai",
        backend_id: canisters.backend.ic, //"ys3lq-iiaaa-aaaap-qb7ba-cai",
        host: "https://icp-api.io",
        scan: "https://dashboard.internetcomputer.org/canister/",
        identityProvider: "https://identity.ic0.app/#authorize"
    }
}
const ENV = process.env.NODE_ENV == "development" ? "dev" : "ic";
const config = {
    APP_VERSION: '2.0.1',
    ENV: ENV,
    IDENTITY_PROVIDER: NETWORK[ENV]['identityProvider'],
    HOST: NETWORK[ENV]['host'],//https://boundary.ic0.app/
    CANISTER_MANAGER_ID: NETWORK[ENV]['canister_id'],
    DEPLOYER_CANISTER_ID: NETWORK[ENV]['deployer_id'],
    TOKEN_DEPLOYER_CANISTER_ID: NETWORK[ENV]['token_deployer_id'],
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
        NETWORK[ENV]['deployer_id'],
        NETWORK[ENV]['token_deployer_id'],
        NETWORK[ENV]['backend_id'],
        'ryjl3-tyaaa-aaaaa-aaaba-cai',
        'aaaaa-aa',
        'rkp4c-7iaaa-aaaaa-aaaca-cai',
        'nn2xz-fiaaa-aaaap-qa6lq-cai'
    ],
    E8S: 100_000_000,
    CYCLES: 1_000_000_000_000,
    FEE: 10_000,
    LAUNCHPAD_FEE: 3,
    MIN_DEPOSIT: 10_000*10,
    LOGIN_TIMEOUT: 30*60*1000, //Reauth when reach the timeout
    IC_SCAN: NETWORK[ENV]['scan'],
    MAX_CHUNK_SIZE: 1900000,
    WALLET_CONFIG: {
        "nns": true,
        "stoic": true,
        "plug": true,
        "bitfinity": true,
    },
    SERVICE_CANISTER_ID: NETWORK[ENV]['gov_token_id'], 
    SERVICE_FEES: {
        "DEPLOY_TOKEN": 1,//1 ICP
        "PAYMENT_CONTRACT": 10,
        "VESTING_CONTRACT": 10,
        "LOCKS_CONTRACT": 10,
    },
}
export const defaultTokens = [
    {symbol: 'ICP', name: 'Internet Computer', canisterId: 'ryjl3-tyaaa-aaaaa-aaaba-cai', standard: 'ledger'}
]
export default config;