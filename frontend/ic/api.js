import { ref, onMounted, onUnmounted } from 'vue'
// import { useWallet, useConnect, useDialog } from "@connect2ic/vue"


// let { activeProvider } = useConnect()
//Import IDL FILE

import icIDL from './candid/ic.did';
import cyclesIDL from './candid/cycles.did';
import ledgerIDL from './candid/ledger.did';
import nnsIDL from './candid/nns.did';
import icrc1IDL from './candid/icrc1.did';

class CreateActor {
    _canister = false;
    _idl = false;
    _actor = false;
    _type = "";
    constructor(provider, canister, idl, type) {
        console.log('provider: ', provider);
        if (canister) this._canister = canister;
        if (idl) this._idl = idl;
        if (type) this._type = type;
        return new Proxy(this, {
            get : (target, name) => {
                return async function() {
                    if (!target._actor) {
                        target._actor = await provider.createActor(canister, idl);
                    }
                    return await target._actor[name](...arguments);
                }
            }
        });
    }
}

class ICnetwork {
    _requiredAuth = false;
    _preloadedIdls = {
        'ledger' : ledgerIDL,
        'ICRC1' : icrc1IDL,
        'IC': icIDL
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

    constructor(provider, _requiredAuth) {
        console.log('call API', window.client.activeProvider)
        this.provider =  provider;
        if(_requiredAuth && _requiredAuth === true) this._requiredAuth = true;
    }

    canister(cid, idl) {
        if (!idl){
            if (Object.prototype.hasOwnProperty.call(this._mapIdls, cid)) {
                idl = this._mapIdls[cid];
            } else {
                idl = this._preloadedIdls['ledger'];
            }
        }else if (typeof idl == 'string'){
            if (Object.prototype.hasOwnProperty.call(_preloadedIdls, idl)) {
                idl = _preloadedIdls[idl];
            } else {
                throw new Error(idl + " is not a preloaded IDL");
            }
        }
        if (!Object.prototype.hasOwnProperty.call(this._canisters, cid)){
            this._canisters[cid] = new CreateActor(this.provider, cid, idl);//await this.provider.value.createActor(cid, idl);
        }
        return this._canisters[cid];
    }
}

class icConnect {
    _requiredAuth = false;
    _preloadedIdls = {
        'ledger' : ledgerIDL,
        'icrc-1' : icrc1IDL,
        'IC': icIDL
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
        console.log('call API', window.client.activeProvider)
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
            this._canisters[cid] = new CreateActor(window.client.activeProvider, cid, idl);//await this.provider.value.createActor(cid, idl);
        }
        return this._canisters[cid];
    }
}
export default {
    connect : (provider) => new ICnetwork(provider),
    authConnect: (provider) => new ICnetwork(provider, true),
    canister : (cid, idl) => new icConnect(cid, idl)
};