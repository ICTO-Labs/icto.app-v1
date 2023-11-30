import {AuthClient} from "@dfinity/auth-client";
import EventBus from "./EventBus";
import { toast } from 'vue3-toastify';

class walletManager {
    checkLoginStatus(){
        var is_connected = localStorage.getItem("_w_connected");
        const logout = () => {
            localStorage.removeItem("_w_connected");
            StoicIdentity.disconnect();
            walletData.setIdentity(false);
            walletData.setAccount([]);
            walletData.setBalance(0);
            walletData.setLoginState(false);
            walletData.setCurrentAccount({});
        };
        if (is_connected) {
            switch (is_connected) {
                case "plug":
                    (async () => {
                        const connected = await window?.ic?.plug.isConnected();
                        console.log('connected: ', connected);
                        if (connected) {
                            if (!window.ic["plug"].agent) {
                                console.log('create agent')
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
                            walletData.setIdentity(id);
                            walletData.setAccount([
                                {
                                    name: "Plug Wallet",
                                    address: principalToAccountIdentifier(id.getPrincipal().toText(), 0),
                                },
                            ]);
                            walletData.setCurrentAccount({ name: "Plug Wallet", address: principalToAccountIdentifier(id.getPrincipal().toText(), 0)});
                            await walletData.loginAction('plug');
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
                            walletData.setIdentity(id);
                            walletData.setAccount([
                                {
                                    name: "Bitfinity Wallet",
                                    address: principalToAccountIdentifier(id.getPrincipal().toText(), 0),
                                },
                            ]);
                            walletData.setCurrentAccount({ name: "Bitfinity Wallet", address: principalToAccountIdentifier(id.getPrincipal().toText(), 0)});
                            walletData.loginAction('bitfinity');
                        }else {
                            console.log("Infinity wallet not connected");
                            // logout();
                        }
                    })();
                    break;
                case "nns":
                    (async () => {
                        const authClient = await AuthClient.create({
                            idleOptions: {
                                disableIdle: true, // set to true to disable idle timeout
                            }
                        });
                        const identity = authClient.getIdentity();
                        console.log('_principal: ', identity._principal);
                        console.log('connected: ', identity);
                        if (identity) {
                            walletData.setIdentity(identity);
                            walletData.setAccount([
                                {
                                    name: "Internet Identity",
                                    address: principalToAccountIdentifier(identity.getPrincipal().toString(), 0),
                                },
                            ]);
                            walletData.setCurrentAccount({ name: "Internet Identity", address: principalToAccountIdentifier(identity.getPrincipal().toString(), 0)});
                            walletData.loginAction('nns');
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
        localStorage.removeItem("_w_connected");
        StoicIdentity.disconnect();
        walletData.setIdentity(false);
        walletData.setAccount([]);
        walletData.setBalance(0);
        walletData.setLoginState(false);
        walletData.setCurrentAccount({});
        walletData.logoutAction();
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
        const host = config.IC_ENDPOINT;
        // Make the request

        try {
            const result = await window.ic.plug.requestConnect({
                whitelist,
                host,
            });
            const connectionState = result ? "allowed" : "denied";
            console.log(`The Connection was ${connectionState}!`);
            if(result){
                window.Swal.close();
                // Get the user principal id
                const pid = await window.ic.plug.agent.getPrincipal();//await window.ic.plug.getPrincipal();
                // const id = await window.ic.plug.agent._identity;
                var id = {
                    type: "plug",
                    getPrincipal : () => pid
                }
                const _current_account = {
                    name: "Plug Wallet",
                    address: principalToAccountIdentifier(id.getPrincipal().toText(), 0),
                };
                walletData.setIdentity(id);
                walletData.setAccount([_current_account]);
                walletData.setCurrentAccount(_current_account);
                await walletData.loginAction('plug');
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
                    address: principalToAccountIdentifier(id.getPrincipal().toText(), 0),
                };
                walletData.setIdentity(id);
                walletData.setAccount([_current_account]);
                walletData.setCurrentAccount(_current_account);
                walletData.loginAction('bitfinity');
                loginSuccessAction();
            }

        } catch (e) {
            window.Swal.close();
            console.log(e);
        }
    };
    async nnsWallet(){
        this.connectLoading();
        const auth  = await AuthClient.create();
        auth.login({
            maxTimeToLive: 7 * 24 * 60 * 60 * 1000 * 1000 * 1000,
            disableDefaultIdleCallback: true,
            onSuccess: async () => {
                window.Swal.close();
                let pid = await auth.getIdentity();
                const _current_account = {
                    name: "Internet Identity",
                    address: principalToAccountIdentifier(pid.getPrincipal().toString(), 0),
                };
                walletData.setIdentity(pid);
                walletData.setAccount([_current_account]);
                walletData.setCurrentAccount(_current_account);
                walletData.loginAction('nns');
                loginSuccessAction();
            },
            onError: ()=>{
                window.Swal.close();
                console.log('ERROR');
            }
        });
    }
    async notLogin(){
        if(!walletData.isLogged){
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
                walletData.setIdentity(null);
                walletData.setAccount([]);
                walletData.setBalance(0);
                walletData.setLoginState(false);
                walletData.setCurrentAccount({});
                // walletData.setCanicLockedBalance(0);
                walletData.logoutAction();
            }
        })
    }
    btnLogin() {
        EventBus.emit("showLoginModal", true);
    }
}

export const WalletManager = new walletManager();
export default {
    WalletManager
}