import { reactive } from 'vue'
import { principalToAccountId } from '@/utils/common.js'
const isLogged = localStorage.getItem('isLogged');
const lastLogged = localStorage.getItem('lastLogged');
const connector = localStorage.getItem('connector');
const _identity = null
export const walletStore = reactive({
    isLogged: isLogged?isLogged:null,
    lastLogged: lastLogged?lastLogged:null,
    connector: connector?connector:null,
    identity: _identity?_identity:null,
    isAuthenticated: false, 
    account: null,
    accounts: null,
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
    },
    setAccount(accounts){
        this.accounts = accounts;
    },
    setCurrentAccount(account){
        this.account = account;
    },
    setLastLogged(){
        localStorage.setItem("lastLogged", new Date().valueOf());
    },
    setLoginState(status){
        if(typeof status =='string'){
            this.isLogged = true;
            this.connector = status;
            localStorage.setItem("connector", status);
            localStorage.setItem("isLogged", true);
        }else{
            this.isLogged = false;
            this.connector = null;
        }
    },
    logout(){
        localStorage.removeItem("isLogged");
        localStorage.removeItem("connector");
        localStorage.removeItem("lastLogged");
        this.isLogged = false;
        this.connector = null;
        this.setIdentity(false);
        this.setAccount([]);
        this.setBalance(0);
        this.setLoginState(null);
        this.setCurrentAccount({});

    }
})

export default walletStore;