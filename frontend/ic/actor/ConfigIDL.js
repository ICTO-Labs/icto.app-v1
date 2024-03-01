import icIDL from '@/ic/candid/ic.did';
import cyclesIDL from '@/ic/candid/cycles.did';
import ledgerIDL from '@/ic/candid/ledger.did';
import nnsIDL from '@/ic/candid/nns.did';
import icrc1IDL from '@/ic/candid/icrc1.did';
import icrc2IDL from '@/ic/candid/icrc2.did';
import icrc3IDL from '@/ic/candid/icrc2.did';
import extIDL from '@/ic/candid/extNFT.did';
import contractIDL from '@/ic/candid/contract.did';
import swapPoolIDL from '@/ic/candid/icpswap/swapPool.did';
import {idlFactory as deployerIDL} from '../../../src/declarations/deployer/deployer.did.js';
import {idlFactory as tokenDeployerIDL} from '../../../src/declarations/token_deployer/token_deployer.did.js';
import {idlFactory as backendIDL} from '../../../src/declarations/backend/backend.did.js';

export const preloadIdls = {
    'cycles' : cyclesIDL,
    'nns': nnsIDL,
    'ledger' : ledgerIDL,
    'icrc1' : icrc1IDL,
    'icrc2' : icrc2IDL,
    'icrc3' : icrc3IDL,
    'EXT': extIDL,
    'IC': icIDL,
    'contract': contractIDL,
    'deployer': deployerIDL,
    'token_deployer': tokenDeployerIDL,
    'backend': backendIDL,
    'swapPool': swapPoolIDL,
}
export const mapIdls = {
    'aaaaa-aa' : icIDL,
    '2ouva-viaaa-aaaaq-aaamq-cai': icrc1IDL,
};
export default preloadIdls;