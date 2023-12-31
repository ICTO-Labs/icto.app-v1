import { reactive } from 'vue'
import { principalToAccountId } from '@/utils/common.js'
const isLogged = localStorage.getItem('isLogged');
const connector = localStorage.getItem('connector');
const _identity = null
export const walletStore = reactive({
    isLogged: isLogged?isLogged:null,
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
    setLoginState(status){
        this.isLogged = status?true:false;
        this.connector = status;
        localStorage.setItem("connector", status);
        localStorage.setItem("isLogged", this.isLogged);
    },
    logout(){
        this.isLogged = null;
        this.connector = null;
        localStorage.removeItem("isLogged");
        localStorage.removeItem("connector");
        this.setIdentity(false);
        this.setAccount([]);
        this.setBalance(0);
        this.setLoginState(null);
        this.setCurrentAccount({});

    }
})