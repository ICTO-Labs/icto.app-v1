import { reactive } from 'vue'
import { principalToAccountId } from '@/utils/common.js'
const isLogged = localStorage.getItem('isLogged');
const connector = localStorage.getItem('connector');
const _identity = null
export const walletStore = reactive({
    isLogged: isLogged?isLogged:false,
    connector: connector?connector:'ic',
    identity: _identity?_identity:null,
    isAuthenticated: false, 
    principal: '', 
    _principal: '', 
    address: '', 
    balance: 0,
    setIdentity(identity){
        this.identity = identity;
        if(identity){
            this._principal = identity.getPrincipal();
            this.principal = identity.getPrincipal().toString();//String
            this.address = principalToAccountId(this.principal, 0);
        }else{
            this.address = '';
            this.principal = '';
            this._principal = '';
        }
    },
    setAuthStatus(status){
        this.isAuthenticated = status;
    },
    setBalance(balance){
        this.balance = balance;
    }
})