import { reactive } from 'vue'
import { principalToAccountId } from '@/utils/common.js'
const isLogged = localStorage.getItem('isLogged');
const lastLogged = localStorage.getItem('lastLogged');
const connector = localStorage.getItem('connector');
const lastFetch = localStorage.getItem('lastFetch');
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
    lastFetch: lastFetch,//Timestamp
    icpPrice: 0,//source from Binance
    priceChange: 0,//24h change
    setICPPrice(price, change){
        this.lastFetch = new Date().valueOf();
        localStorage.setItem("lastFetch", this.lastFetch);
        this.icpPrice = price;
        this.priceChange = change.toFixed(2);
    },
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
            this.getICPPrice();
        }else{
            this.isLogged = false;
            this.connector = null;
        }
    },
    logout(){
        localStorage.removeItem("isLogged");
        localStorage.removeItem("connector");
        localStorage.removeItem("lastLogged");
        localStorage.removeItem("lastFetch");
        this.isLogged = false;
        this.connector = null;
        this.setIdentity(false);
        this.setAccount([]);
        this.setBalance(0);
        this.setLoginState(null);
        this.setCurrentAccount({});

    },
    async getICPPrice() {
        this.getICPPriceWithChange();
        setInterval(() => {//Fetch every 10 min
            let now = new Date().valueOf();
            if(this.icpPrice == 0 || now - this.lastFetch > 10*60*1000){
                this.getICPPriceWithChange();
            }
        }, 60*1000);
    },
    async getICPPriceWithChange() {
        try {
            const response = await fetch('https://api.coingecko.com/api/v3/simple/price?ids=internet-computer&vs_currencies=usd&include_24hr_change=true');
            const data = await response.json();
            const icpPrice = parseFloat(data['internet-computer'].usd);
            const icpPriceChange = parseFloat(data['internet-computer'].usd_24h_change);
            this.setICPPrice(icpPrice, icpPriceChange);
        } catch (error) {
            console.error('Error fetching ICP price:', error);
            return null;
        }
    },
    async fetchICPPrice() {
        try {
            const response = await fetch('https://api.binance.com/api/v3/ticker/price?symbol=ICPUSDT');
            const data = await response.json();
            const icpPrice = parseFloat(data.price);
            this.setICPPrice(icpPrice);
        } catch (error) {
            console.error('Error fetching ICP price:', error);
            return null;
        }
    }

})

export default walletStore;