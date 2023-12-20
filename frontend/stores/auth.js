import { defineStore } from "pinia";
import { useStorage } from '@vueuse/core'
import { AuthClient } from "@dfinity/auth-client";
import { createActor, canisterId } from "../../src/declarations/backend";
import { principalToAccountId } from '@/utils/common.js'
import { toRaw } from "vue";
const defaultOptions = {
    createOptions: {
      idleOptions: {
        disableIdle: true,
      },
    },
    loginOptions: {
      identityProvider:
        process.env.DFX_NETWORK === "ic"
          ? "https://identity.ic0.app/#authorize"
          : `http://127.0.0.1:8000/?canisterId=a3shf-5eaaa-aaaaa-qaafa-cai#authorize`,
    },
  };
  
  function actorFromIdentity(identity) {
    return createActor(canisterId, {
      agentOptions: {
        identity,
      },
    });
  }
  
  export const useAuthStore = defineStore("auth", {
    id: "auth",
    state: () => {
      let _auth = {
        isReady: false,
        isAuthenticated: null,
        authClient: null,
        identity: null,
        backendActor: null,
        principal: null,
        address: null,
        balance: 0,
        connector: 'ic'
      };
      useStorage('auth', _auth);
      return _auth;
      // return useStorage('auth', _auth);
    },
    actions: {
      async init() {
        const authClient = await AuthClient.create(defaultOptions.createOptions);
        this.authClient = authClient;
        const isAuthenticated = await authClient.isAuthenticated();
        const identity = isAuthenticated ? authClient.getIdentity() : null;
        const backendActor = identity ? actorFromIdentity(identity) : null;
        this.isAuthenticated = isAuthenticated;
        this.identity = identity;
        this.principal = identity?identity.getPrincipal().toString():null;
        this.address = principalToAccountId(this.principal, 0),
        this.backendActor = backendActor;
        this.isReady = true;
        this.connector = 'ic';
      },
      async login() {
        const authClient = toRaw(this.authClient);
        authClient.login({
          ...defaultOptions.loginOptions,
          onSuccess: async () => {
            this.isAuthenticated = await authClient.isAuthenticated();
            this.identity = this.isAuthenticated
              ? authClient.getIdentity()
              : null;
            this.backendActor = this.identity
              ? actorFromIdentity(this.identity)
              : null;
            this.principal  = this.identity?this.identity.getPrincipal().toString():null;
            this.address = principalToAccountId(this.principal, 0);
            //save to store
          },  
        });
      },
      async plugLogin() {
        const authClient = toRaw(this.authClient);
        authClient.login({
          ...defaultOptions.loginOptions,
          onSuccess: async () => {
            this.isAuthenticated = await authClient.isAuthenticated();
            this.identity = this.isAuthenticated
              ? authClient.getIdentity()
              : null;
            this.backendActor = this.identity
              ? actorFromIdentity(this.identity)
              : null;
            this.principal  = this.identity?this.identity.getPrincipal().toString():null;
            this.address = principalToAccountId(this.principal, 0);
            //save to store
          },  
        });
      },
      setBalance(balance){
        this.balance = balance;
      },
      async logout() {
        const authClient = toRaw(this.authClient);
        await authClient?.logout();
        this.isAuthenticated = false;
        this.identity = null;
        this.backendActor = null;
        this.principal = null;
        this.address = null;
      },
    },
  });