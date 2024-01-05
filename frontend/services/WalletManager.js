import {AuthClient} from "@dfinity/auth-client";
import EventBus from "./EventBus";
import { principalToAccountId } from "@/utils/common";
import walletStore from "@/store";
import config from "@/config";
import { showSuccess } from "@/utils/common";

const loginSuccessAction = () =>{
    showSuccess("Login successful!")
    EventBus.emit("showLoginModal", false)
}
const defaultOptions = {
    createOptions: {
      idleOptions: {
        disableIdle: true,
      },
    },
    loginOptions: {
      identityProvider: config.IDENTITY_PROVIDER
    },
  };
class walletManager {
    checkLoginStatus(){
        var isLogged = localStorage.getItem("isLogged");
        console.log('isLogged', isLogged);
        const logout = () => {
            localStorage.removeItem("_w_connected");
            StoicIdentity.disconnect();
            walletStore.setIdentity(false);
            walletStore.setAccount([]);
            walletStore.setBalance(0);
            walletStore.setLoginState(false);
            walletStore.setCurrentAccount({});
        };
        if (isLogged) {
            switch (walletStore.connector) {
                case "plug":
                    (async () => {
                        const connected = await window?.ic?.plug.isConnected();
                        if (connected) {
                            if (!window.ic["plug"].agent) {
                                console.log('check plug login')
                                // window.ic["plug"].agent = await window.ic.plug.sessionManager.sessionData.agent;
                                await window.ic["plug"].createAgent({
                                    whitelist: config.CANISTER_WHITE_LIST,
                                    host: config.IC_ENDPOINT
                                });
                            }
                            
                            var pid = await window.ic.plug.agent.getPrincipal();//await window.ic["plug"].getPrincipal();
                            var id = {
                                type: "plug",
                                getPrincipal : () => pid
                            }
                            console.log('p', id.getPrincipal().toText());
                            walletStore.setIdentity(id);
                            walletStore.setAccount([
                                {
                                    name: "Plug Wallet",
                                    address: principalToAccountId(id.getPrincipal().toText(), 0),
                                },
                            ]);
                            walletStore.setCurrentAccount({ name: "Plug Wallet", address: principalToAccountId(id.getPrincipal().toText(), 0)});
                            walletStore.setLoginState('plug');
                        }else {
                            console.log("Plug not connected");
                            await this.plugWallet()
                            // logout();
                        }
                    })();
                    break;
                case "bitfinity":
                    (async () => {
                        const connected = await window?.ic?.bitfinityWallet.isConnected();
                        console.log('connected: ', connected);
                        if (connected) {
                            if (!window.ic.bitfinityWallet.agent) {
                                await window.ic.bitfinityWallet.requestConnect({
                                    whitelist: config.CANISTER_WHITE_LIST,
                                });
                            }

                            const pid = await window.ic.bitfinityWallet.getPrincipal();
                            var id = {
                                type: "bitfinity",
                                getPrincipal : () => pid
                            }
                            walletStore.setIdentity(id);
                            walletStore.setAccount([
                                {
                                    name: "Bitfinity Wallet",
                                    address: principalToAccountId(id.getPrincipal().toText(), 0),
                                },
                            ]);
                            walletStore.setCurrentAccount({ name: "Bitfinity Wallet", address: principalToAccountId(id.getPrincipal().toText(), 0)});
                            walletStore.loginAction('bitfinity');
                        }else {
                            console.log("Infinity wallet not connected");
                            // logout();
                        }
                    })();
                    break;
                case "ii":
                    (async () => {
                        console.log('check ii');
                        const authClient = await AuthClient.create(defaultOptions.createOptions);
                        const identity = authClient.getIdentity();
                        if (identity) {
                            walletStore.setIdentity(identity);
                            walletStore.setAccount([
                                {
                                    name: "Internet Identity",
                                    address: principalToAccountId(identity.getPrincipal().toString(), 0),
                                },
                            ]);
                            walletStore.setCurrentAccount({ name: "Internet Identity", address: principalToAccountId(identity.getPrincipal().toString(), 0)});
                            walletStore.setLoginState('ii');
                        }else {
                            console.log("Internet Identity not connected");
                            // logout();
                        }
                    })();
                    break;
                default:
                    break;
            }
        }
    };
    logoutAction(){
        localStorage.removeItem("isLogged");
        StoicIdentity.disconnect();
        walletStore.setIdentity(false);
        walletStore.setAccount([]);
        walletStore.setBalance(0);
        walletStore.setLoginState(false);
        walletStore.setCurrentAccount({});
        walletStore.logoutAction();
    };
    connectLoading(){
        window.Swal.fire({
            html: '<div class="spinner-grow spinner-grow-sm" role="status"></div> Connecting, please wait...',
            allowEscapeKey: false,
            allowOutsideClick: false,
            showConfirmButton: false,
            didOpen: () => {
                window.Swal.showLoading()
            }
        });
    };
    async plugWallet(){
        //Test if the user has Plug extension installed (other way?)
        if (typeof window?.ic?.plug == "undefined") {
            console.log("No plug extension");
            window.Swal.fire({icon: 'error', title: 'Error', text: 'No Plug Wallet extension!'});
            window.open('https://plugwallet.ooo/','_blank');
            return;
        }
        this.connectLoading();
        const whitelist = config.CANISTER_WHITE_LIST;
        // Host
        const host = config.HOST;
        // Make the request

        try {
            const result = await window.ic.plug.requestConnect({
                whitelist,
                host,
                timeout: 50000
            });
            const connectionState = result ? "allowed" : "denied";
            console.log(`The Connection was ${connectionState}!`);
            window.Swal.close();
            if(result){
                // Get the user principal id
                const pid = await window.ic.plug.agent.getPrincipal();//await window.ic.plug.getPrincipal();
                // const id = await window.ic.plug.agent._identity;
                var id = {
                    type: "plug",
                    getPrincipal : () => pid
                }
                const _current_account = {
                    name: "Plug Wallet",
                    address: principalToAccountId(id.getPrincipal().toText(), 0),
                };
                walletStore.setIdentity(id);
                walletStore.setAccount([_current_account]);
                walletStore.setCurrentAccount(_current_account);
                // await walletStore.loginAction('plug');
                walletStore.setLoginState('plug');
                loginSuccessAction();
            }
        }catch (e) {
            window.Swal.close();
            console.log('PLUG ERROR:', e);
        }
    };
    async bitfinityWallet(){
        if (typeof window?.ic?.bitfinityWallet == "undefined") {
            console.log("No infinityWallet extension");
            window.Swal.fire({icon: 'error', title: 'Error', text: 'No Infinity Wallet extension!'});
            window.open('https://wallet.infinityswap.one/','_blank');
            return;
        }
        this.connectLoading();

        // Host
        const host = "https://boundary.ic0.app/";
        const whitelist = config.CANISTER_WHITE_LIST;

        // Make the request
        try {
            const result = await window.ic.bitfinityWallet.requestConnect({
                whitelist,
                host,
                // timeout: 7 * 24 * 60 * 60 * 1000 * 1000 * 1000
            });

            if(result){
                window.Swal.close();
                const pid = await window.ic.bitfinityWallet.getPrincipal();
                var id = {
                    type: "bitfinity",
                    getPrincipal : () => pid
                }
                const _current_account = {
                    name: "Bitfinity Wallet",
                    address: principalToAccountId(id.getPrincipal().toText(), 0),
                };
                walletStore.setIdentity(id);
                walletStore.setAccount([_current_account]);
                walletStore.setCurrentAccount(_current_account);
                walletStore.loginAction('bitfinity');
                loginSuccessAction();
            }

        } catch (e) {
            window.Swal.close();
            console.log(e);
        }
    };
    async iiWallet(){
        this.connectLoading();
        const auth  = await AuthClient.create();
        auth.login({
            ...defaultOptions.loginOptions,
            maxTimeToLive: 7 * 24 * 60 * 60 * 1000 * 1000 * 1000,
            disableDefaultIdleCallback: true,
            onSuccess: async () => {
                window.Swal.close();
                let pid = await auth.getIdentity();
                const _current_account = {
                    name: "Internet Identity",
                    address: principalToAccountId(pid.getPrincipal().toString(), 0),
                };
                walletStore.setIdentity(pid);
                walletStore.setAccount([_current_account]);
                walletStore.setCurrentAccount(_current_account);
                walletStore.setLoginState('ii');

                loginSuccessAction();
            },
            onError: ()=>{
                window.Swal.close();
                console.log('ERROR');
            }
        });
    }
    async notLogin(){
        if(!walletStore.isLogged){
            EventBus.emit("showLoginModal", true);
            return true;
        }else{ return false}
    }
    async logout(){
        window.Swal.fire({
            icon: 'question',
            text: 'Are you sure you want to logout?',
            showCancelButton: true,
            confirmButtonText: 'Yes, Log me out!',
        }).then(async (result) => {
            if (result.isConfirmed) {
                localStorage.removeItem("_w_connected");
                localStorage.removeItem("_account_index");
                StoicIdentity.disconnect();
                walletStore.setIdentity(null);
                walletStore.setAccount([]);
                walletStore.setBalance(0);
                walletStore.setLoginState(false);
                walletStore.setCurrentAccount({});
                // walletStore.setCanicLockedBalance(0);
                walletStore.logoutAction();
            }
        })
    }
    btnLogin() {
        EventBus.emit("showLoginModal", true);
    }
}

export const WalletManager = new walletManager();
export default WalletManager;