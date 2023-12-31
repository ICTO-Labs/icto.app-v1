import { actor } from "./Actor";
import icIDL from '@/ic/candid/ic.did';
import cyclesIDL from '@/ic/candid/cycles.did';
import ledgerIDL from '@/ic/candid/ledger.did';
import nnsIDL from '@/ic/candid/nns.did';
import icrc1IDL from '@/ic/candid/icrc1.did';
import icrc2IDL from '@/ic/candid/icrc2.did';
import icrc3IDL from '@/ic/candid/icrc2.did';
import contractIDL from '@/ic/candid/contract.did';
import { walletStore } from '@/store/'
import {idlFactory as deployerIDL} from '../../../src/declarations/deployer/deployer.did.js'
import {idlFactory as backendIDL} from '../../../src/declarations/backend/backend.did.js'
class CreateActor {
    _canister = false;
    _idl = false;
    _actor = false;
    _type = "";
    constructor(canister, idl) {
        if (canister) this._canister = canister;
        if (idl) this._idl = idl;
        return new Proxy(this, {
            get : (target, name) => {
                return async function() {
                    if (!target._actor) {
                        if(walletStore.connector == "plug"){
                            target._actor = await window.ic[walletStore.connector].createActor({
                                canisterId: target._canister,
                                interfaceFactory: target._idl,
                            });
                        }else{
                            target._actor = await actor.create({
                                identity: walletStore.identity,
                                canisterId: canister,
                                idlFactory: idl,
                              });
                        }
                    }
                    return await target._actor[name](...arguments);
                }
            }
        });
    }
}

class Connect {
    _requiredAuth = false;
    _preloadedIdls = {
        'ledger' : ledgerIDL,
        'icrc1' : icrc1IDL,
        'icrc2' : icrc2IDL,
        'icrc3' : icrc3IDL,
        'IC': icIDL,
        'contract': contractIDL,
        'deployer': deployerIDL,
        'backend': backendIDL,
    };
    _mapIdls = {
        'aaaaa-aa' : icIDL,
        'cycles' : cyclesIDL,
        'ledger' : ledgerIDL,
        'nns': nnsIDL,
        '2ouva-viaaa-aaaaq-aaamq-cai': icrc1IDL,
    };
    _canisters = {};
    _actor = null;
    _provider = null;

    constructor(cid, idl) {
        console.log(cid, idl);
        if(!cid) throw new Error("No Canister Id");
        if (!idl){
            if (Object.prototype.hasOwnProperty.call(this._mapIdls, cid)) {
                idl = this._mapIdls[cid];
            } else {
                idl = this._preloadedIdls['ledger'];
            }
        }else if (typeof idl == 'string'){
            if (Object.prototype.hasOwnProperty.call(this._preloadedIdls, idl)) {
                idl = this._preloadedIdls[idl];
            } else {
                throw new Error(idl + " is not a preloaded IDL");
            }
        }
        if (!Object.prototype.hasOwnProperty.call(this._canisters, cid)){
            this._canisters[cid] = new CreateActor(cid, idl);//await this.provider.value.createActor(cid, idl);
        }
        return this._canisters[cid];
    }
}


export default {
    canister : (cid, idl) => new Connect(cid, idl)
};