<script setup>
import { onMounted } from 'vue';
import { useWallet, useConnect, useDialog } from "@connect2ic/vue"
const {wallet} = useWallet()
import { useWalletStore } from '../stores/wallet'
import _api from "../ic/api";
const walletStore = useWalletStore()
import icrc1IDL from '../ic/candid/icrc1.did';

const emit = defineEmits(["onConnect", "onDisconnect"])
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

const onConnect = () => {
  emit("onConnect", {})
}

const onDisconnect = () => {
  emit("onDisconnect", {})
}


let { activeProvider, isConnected, disconnect, status, connect, principal } = useConnect({
  // providers,
  onConnect,
  onDisconnect,
})

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
	console.log('status.value: ', status)

	walletStore.setWalletInfo(principal.value, 'address', 0);
}

const getLogin = async ()=>{
	let _wallet = walletStore.getWalletInfo;
	console.log('walletStore:', _wallet)
	let _fetch = await _api.connect(activeProvider).canister("2ouva-viaaa-aaaaq-aaamq-cai").icrc1_metadata();
	// _fetch = await _fetch.icrc1_metadata();
	// const _icrc = await activeProvider.value.createActor('2ouva-viaaa-aaaaq-aaamq-cai', icrc1IDL).icrc1_metadata();
	console.log('ICRC1', _fetch);
}

</script>

<template>

    <!--begin::User-->
    <div class="d-flex align-items-center ms-1 ms-lg-3" id="kt_header_user_menu_toggle">
											<!--begin::Menu wrapper-->
											<div class="cursor-pointer symbol symbol-30px symbol-md-40px" data-kt-menu-trigger="click" data-kt-menu-attach="parent" data-kt-menu-placement="bottom-end">
                                                <button class="btn btn-sm btn-success" @click="getLogin"><span class="fw-bolder">Get {{ walletStore.principal }}</span> </button>
                                                <button class="btn btn-sm btn-success" @click="checkLogin"><span class="fw-bolder">Check login</span> </button>
                                                <button v-if="!isConnected" class="btn btn-sm btn-danger" @click="() => isICX ? connect('icx') : open()">Connect</button>
                                                <button v-if="isConnected" class="btn btn-sm btn-primary"><span class="fw-bolder">My Wallet</span> </button>
                                                
											</div>
											<!--begin::Menu-->
											<div class="menu menu-sub menu-sub-dropdown menu-column menu-rounded menu-gray-800 menu-state-bg menu-state-primary fw-bold py-4 fs-6 w-275px" data-kt-menu="true" v-show="isConnected" >
												<!--begin::Menu item-->
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
															<span class="badge badge-light-success fw-bolder fs-8 px-2 py-1 ms-2">{{ activeProvider.meta.id }}</span></div>
															<a href="#" class="fw-bold text-muted text-hover-primary fs-7" v-if="isConnected">Principal: {{ principal.value }}</a>
														</div>
														<!--end::Username-->
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
											<!--end::Menu-->
											<!--end::Menu wrapper-->
										</div>
										<!--end::User -->

 


</template>