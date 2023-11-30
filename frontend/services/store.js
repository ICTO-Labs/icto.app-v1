import { reactive } from 'vue'
const _accounts = false;//JSON.parse(localStorage.getItem('accounts'));
const _principal = false;//JSON.parse(localStorage.getItem('principal'));
const _w_connected = localStorage.getItem('_w_connected');
const _current_account = JSON.parse(localStorage.getItem('_current_account'));
const _account_index = JSON.parse(localStorage.getItem('_account_index'));
export const walletData = reactive({
    isLogged: _w_connected?_w_connected:false,
    principal: _principal?_principal:false,
    txtPrincipal: "2vxsx-fae",//Default unlogin
    accounts: _accounts?_accounts:false,
    account: _current_account?_current_account:false,
    currentAccount: _account_index?_account_index:0,
    setIdentity(principal){
        this.principal = principal;
        if(principal){
            this.txtPrincipal = principal.getPrincipal().toText();
        }else{
            this.txtPrincipal = "2vxsx-fae"
        }
    },
    setAccount(accounts){
        this.accounts = accounts;
    },
    async loginAction(wallet){ //Default login action
        this.setCurrentAccountIdx(0);
        this.setLoginState(wallet);
        localStorage.setItem("_w_connected", wallet);
    },
    logoutAction(){
        this.stakingBalance = 0;
        this.xcanicBalance = 0;
        this.balance = 0;
        this.cycleBalance = 0;
    },
    setLoginState(status){
        this.isLogged = status
    },
    setCurrentAccount(account){
        this.account = account;
        localStorage.setItem('_current_account', JSON.stringify(account));//Save for Reload check
        axios.defaults.headers.common['Wallet-Address'] = walletData?.account?.address; // Set header for all requests
    },
    setCurrentAccountIdx(current){
        this.currentAccount = current
    }
})