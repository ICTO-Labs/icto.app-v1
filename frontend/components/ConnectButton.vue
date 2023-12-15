<script setup>
import { onMounted, ref, watch } from 'vue';
import { useWallet, useConnect, useDialog } from "@connect2ic/vue"
import { useWalletStore } from '../stores/wallet'
import _api from "@/ic/api";
import { principalToAccountId, getAccountBalance, shortPrincipal, shortAccount } from '@/utils/common';
import Copy from "@/components/icons/Copy.vue";
const walletStore = useWalletStore()

const props = defineProps({
  dark: {
    type: Boolean,
    default: false,
  },
  style: {
    type: String,
    default: "",
  },
})

//@ts-ignore
const isICX = !!window.icx

const { open } = useDialog()

const getBalance = async(address)=>{
	let _balance = await getAccountBalance(address);
	let _icpBalance = _balance.div(100000000).toNumber();
	walletStore.setBalance(_icpBalance);
	console.log('_balance:', _icpBalance)

}
const {activeProvider, isConnected, principal, disconnect} = useConnect({
        onConnect: (res) => {
            // Signed in
			console.log('login')
            isConnectedWallet.value = true;
			let _accountId = '';
			try{
				_accountId = principalToAccountId(res.principal, 0);
			}catch(e){
				console.log('ee', e)
			}
			console.log('_accountId: ', _accountId);
			getBalance(_accountId);
			walletStore.setWalletInfo(res.principal, _accountId, 0);
            console.log("connectWallet onConnect", res)
        },
        onDisconnect: (res) => {
            // Signed out
			isConnectedWallet.value = false;
			walletStore.$reset();
            console.log("onDisconnect", res)
        }
    })
const isConnectedWallet = ref(isConnected.value);
watch()(
	()=>{
		if (isConnected.value == false){
			console.log('watch isConnected', isConnected.value);
			isConnectedWallet.value = false;
			walletStore.$reset();
		}
	}
)
const logout = ()=>{
	Swal.fire({
		title: "Are you sure?",
		text: "Logout and delete this session!",
		icon: "warning",
		showCancelButton: true,
		confirmButtonColor: "#3085d6",
		cancelButtonColor: "#d33",
		confirmButtonText: "Yes, log me out!"
		}).then((result) => {
		if (result.isConfirmed) {
			disconnect();
		}
		});
}

const checkLogin = ()=>{
	console.log('principal: ', principal.value)
	console.log('wallet: ', wallet)
	console.log('isConnected: ', isConnected)

	walletStore.setWalletInfo(principal.value, 'address', 0);
}

</script>

<template>

    <!--begin::User-->
    <div class="d-flex align-items-center ms-1 ms-lg-3" id="kt_header_user_menu_toggle">
											<!--begin::Menu wrapper-->
											<div class="cursor-pointer symbol symbol-30px symbol-md-40px" data-kt-menu-trigger="click" data-kt-menu-attach="parent" data-kt-menu-placement="bottom-end">
                                                <button v-if="!isConnectedWallet" class="btn btn-sm btn-danger" @click="() => isICX ? connect('icx') : open()">Connect <i class="fas fa-chevron-circle-right"></i></button>
                                                <button v-if="isConnectedWallet" class="btn btn-sm btn-primary"><span class="fw-bolder"><i class="fas fa-wallet"></i>My Wallet</span> </button>
                                                
											</div>
											<!--begin::Menu-->
											<div class="menu menu-sub menu-sub-dropdown menu-column menu-rounded menu-gray-800 menu-state-bg menu-state-primary fw-bold py-4 fs-6 w-275px" data-kt-menu="true" >
												<!--begin::Menu item-->
												<div v-show="isConnectedWallet">
												<div class="menu-item px-3">
													<div class="menu-content d-flex align-items-center px-3">
														<!--begin::Avatar-->
														<div class="symbol symbol-50px me-5">
															<img alt="Logo" :src="activeProvider.meta.icon.light" v-if="activeProvider"/>
														</div>
														<!--end::Avatar-->
														<!--begin::Username-->
														<div class="d-flex flex-column">
															<div class="fw-bolder d-flex align-items-center fs-5" v-if="activeProvider">{{ activeProvider.meta.name }}
															<span class="badge badge-success fw-bolder fs-8 px-2 py-1 ms-2">{{ activeProvider.meta.id.toUpperCase() }}</span></div>
														</div>
														<!--end::Username-->
													</div>
													<div class="menu-item px-5">
														<div class="mb-1">       
															<div class="fw-semibold text-gray-600 fs-7">Principal ID:</div> 
															<div class="fw-bold text-gray-800 fs-6"><span data-bs-toggle="tooltip" :title="walletStore.wallet.principal">{{ shortPrincipal(walletStore.wallet.principal) }}</span> <Copy :text="walletStore.wallet.principal"></Copy></div>          
														</div>
														<div class="mb-1">       
															<div class="fw-semibold text-gray-600 fs-7">Address ID:</div> 
															<div class="fw-bold text-gray-800 fs-6"> <span data-bs-toggle="tooltip" :title="walletStore.wallet.address">{{ shortAccount(walletStore.wallet.address) }}</span> <Copy :text="walletStore.wallet.address"></Copy></div>          
														</div>
														<div class="mb-1">       
															<div class="fw-semibold text-gray-600 fs-7">Balance:</div> 
															<div class="fw-bold text-gray-800 fs-6"> {{ walletStore.wallet.balance }} <span class="badge badge-light-primary fw-bolder fs-8 px-2 py-1 ms-2">ICP</span></div>          
														</div>
													</div>
													
												</div>
												<!--end::Menu item-->
												<!--begin::Menu separator-->
												<div class="separator my-2"></div>
												<!--end::Menu separator-->
												<!--begin::Menu item-->
												<div class="menu-item px-5">
													<a href="../../demo1/dist/account/overview.html" class="menu-link px-5">My Profile</a>
												</div>
												<!--end::Menu item-->
												<!--begin::Menu item-->
												<div class="menu-item px-5">
													<a href="../../demo1/dist/pages/projects/list.html" class="menu-link px-5">
														<span class="menu-text">My Projects</span>
														<span class="menu-badge">
															<span class="badge badge-light-danger badge-circle fw-bolder fs-7">3</span>
														</span>
													</a>
												</div>
												<!--end::Menu item-->
												<!--begin::Menu item-->
												<div class="menu-item px-5">
													<a href="../../demo1/dist/account/statements.html" class="menu-link px-5">My Statements</a>
												</div>
												<!--end::Menu item-->
												<!--begin::Menu separator-->
												<div class="separator my-2"></div>
												<!--end::Menu separator-->
												<!--begin::Menu item-->
												<div class="menu-item px-5 my-1">
													<a href="../../demo1/dist/account/settings.html" class="menu-link px-5">Account Settings</a>
												</div>
												<!--end::Menu item-->
												<!--begin::Menu item-->
												<div class="menu-item px-5">
                                                    <a v-if="isConnected" href="#" class="menu-link px-5 text-danger"  @click="() => logout()">Logout</a>
												</div>
												<!--end::Menu item-->
												<!--begin::Menu separator-->
												<div class="separator my-2"></div>
												<!--end::Menu separator-->
												<!--begin::Menu item-->
												<div class="menu-item px-5">
													<div class="menu-content px-5">
														<label class="form-check form-switch form-check-custom form-check-solid pulse pulse-success" for="kt_user_menu_dark_mode_toggle">
															<input class="form-check-input w-30px h-20px" type="checkbox" value="1" name="mode" id="kt_user_menu_dark_mode_toggle" data-kt-url="../../demo1/dist/index.html" />
															<span class="pulse-ring ms-n1"></span>
															<span class="form-check-label text-gray-600 fs-7">Dark Mode</span>
														</label>
													</div>
												</div>
												<!--end::Menu item-->
											</div>
											</div>
											<!--end::Menu-->
											<!--end::Menu wrapper-->
										</div>
										<!--end::User -->

 


</template>