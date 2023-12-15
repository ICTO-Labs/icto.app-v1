import { Actor, HttpAgent } from "@dfinity/agent";
//Import IDL FILE
import icIDL from './candid/ic.did';
import cyclesIDL from './candid/cycles.did';
import ledgerIDL from './candid/ledger.did';
import nnsIDL from './candid/nns.did';
import icrc1IDL from './candid/icrc1.did';
import contract from './candid/contract.did';
import config from "../config";

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
                        console.log('target', target);
                    }
                    return await target._actor[name](...arguments);
                }
            }
        });
    }
}


class icConnect {
    _requiredAuth = false;
    _preloadedIdls = {
        'ledger' : ledgerIDL,
        'icrc-1' : icrc1IDL,
        'IC': icIDL,
        'contract': contract,
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
            this._canisters[cid] = new CreateActor(window.client.activeProvider, cid, idl);//await this.provider.value.createActor(cid, idl);
        }
        return this._canisters[cid];
    }
}
export const contractApi = (canisterId, idl) => {
    let _preloadedIdls = {
        'ledger' : ledgerIDL,
        'icrc-1' : icrc1IDL,
        'IC': icIDL,
        'contract': contract,
    };
    if (Object.prototype.hasOwnProperty.call(_preloadedIdls, idl)) {
        idl = _preloadedIdls[idl];
    } else {
        throw new Error(idl + " is not a preloaded IDL");
    }

    let agent = new HttpAgent({
        host: "http://localhost:8000",
      });
    // Fetch root key for certificate validation during development
    agent.fetchRootKey().catch(err => {
        console.warn("Unable to fetch root key. Check to ensure that your local replica is running");
        console.error(err);
      });
    
    // Creates an actor with using the candid interface and the HttpAgent
    return Actor.createActor(idl, {
      agent,
      canisterId,
    });
  };
export const createActor = (canisterId, idl, options) => {
    let _preloadedIdls = {
        'ledger' : ledgerIDL,
        'icrc-1' : icrc1IDL,
        'IC': icIDL,
        'contract': contract,
    };
    if (Object.prototype.hasOwnProperty.call(_preloadedIdls, idl)) {
        idl = _preloadedIdls[idl];
    } else {
        throw new Error(idl + " is not a preloaded IDL");
    }
    const agent = options.agent || new HttpAgent({host: 'http://localhost:80001/'});
    console.log(agent);
    // Fetch root key for certificate validation during development
    agent.fetchRootKey().catch(err => {
        console.warn("Unable to fetch root key. Check to ensure that your local replica is running");
        console.error(err);
      });
  
    // Creates an actor with using the candid interface and the HttpAgent
    return Actor.createActor(idl, {
      agent,
      canisterId,
      ...(options ? options.actorOptions : {}),
    });
  };
export default {
    canister : (cid, idl) => new icConnect(cid, idl)
};