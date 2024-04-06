import { actor } from "./Actor";
import walletStore from '@/store/'
import { preloadIdls, mapIdls } from './ConfigIDL';
class CreateActor {
    _canister = false;
    _idl = false;
    _actor = false;
    _type = "";
    constructor(canister, idl, isAnonymous=false) {
        if (canister) this._canister = canister;
        if (idl) this._idl = idl;
        return new Proxy(this, {
            get : (target, name) => {
                return async function() {
                    if (!target._actor) {
                        if(isAnonymous == true){
                            target._actor = await actor.create({
                                identity: null,
                                canisterId: canister,
                                idlFactory: idl,
                            });
                        }else{
                            if(walletStore.connector == "plug"){
                                target._actor = await window.ic.plug.createActor({
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
                        
                    }
                    try{
                        return await target._actor[name](...arguments);
                    }catch(e){
                        console.log('e', e, );
                        return null;
                    }
                    
                }
            }
        });
    }
}

class Connect {
    _requiredAuth = false;
    _preloadedIdls = preloadIdls;
    _mapIdls = mapIdls;
    _canisters = {};
    _actor = null;
    _provider = null;

    constructor(cid, idl, isAnonymous=false) {
        console.log('Canister: ',cid, idl, isAnonymous);
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
            this._canisters[cid] = new CreateActor(cid, idl, isAnonymous);//await this.provider.value.createActor(cid, idl);
        }
        return this._canisters[cid];
    }
}


export default {
    canister : (cid, idl, isAnonymous) => new Connect(cid, idl, isAnonymous)
};