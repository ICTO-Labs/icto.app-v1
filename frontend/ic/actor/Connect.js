import { actor } from "./Actor";
import { useStorage } from '@vueuse/core'
const auth = useStorage('auth',);
import icIDL from '@/ic/candid/ic.did';
import cyclesIDL from '@/ic/candid/cycles.did';
import ledgerIDL from '@/ic/candid/ledger.did';
import nnsIDL from '@/ic/candid/nns.did';
import icrc1IDL from '@/ic/candid/icrc1.did';
import contractIDL from '@/ic/candid/contract.did';

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
                        target._actor = await actor.create({
                            identity: auth.value.identity,
                            canisterId: canister,
                            idlFactory: idl,
                          });;
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
        'IC': icIDL,
        'contract': contractIDL,
    };
    _mapIdls = {
        'aaaaa-aa' : icIDL,
        'cycles' : cyclesIDL,
        'ledger' : ledgerIDL,
        'nns': nnsIDL,
        '2ouva-viaaa-aaaaq-aaamq-cai': icrc1IDL
    };
    _canisters = {};
    _actor = null;
    _provider = null;

    constructor(cid, idl) {
        cid = cid.trim();
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