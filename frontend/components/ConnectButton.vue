<script setup>
import EventBus from "@/services/EventBus";
import { walletStore } from "@/store";
import LoadingLabel from "@/components/LoadingLabel.vue"

import { shortPrincipal, shortAccount } from '@/utils/common';

import _api from "@/ic/api";
import Copy from "@/components/icons/Copy.vue";

const logout = ()=>{
	Swal.fire({
		title: "Are you sure?",
		text: "Logout and delete this session!",
		icon: "warning",
		showCancelButton: true,
		confirmButtonColor: "#3085d6",
		cancelButtonColor: "#d33",
		confirmButtonText: "Yes, log me out!"
		}).then(async (result) => {
			if(result.isConfirmed){
				await walletStore.logout()
			}
		});
}

const login = ()=>{
	EventBus.emit('showLoginModal', true);
}

</script>

<template>

    <!--begin::User-->
    <div class="d-flex align-items-center ms-1 ms-lg-3" id="kt_header_user_menu_toggle">
		<!--begin::Menu wrapper-->
		<div class="cursor-pointer symbol symbol-30px symbol-md-40px" data-kt-menu-trigger="click" data-kt-menu-attach="parent" data-kt-menu-placement="bottom-end">
			<button v-if="!walletStore.isLogged || walletStore.isLogged === false" class="btn btn-sm btn-danger" @click="login()">Connect <i class="fas fa-chevron-circle-right"></i></button>
			<button v-if="walletStore.isLogged || walletStore.isLogged == 'true'" class="btn btn-sm btn-primary"><span class="fw-bolder"><i class="fas fa-wallet"></i>My Wallet</span> </button>
			
		</div>
		<!--begin::Menu-->
		<div class="menu menu-sub menu-sub-dropdown menu-column menu-rounded menu-gray-800 menu-state-bg menu-state-primary fw-bold py-4 fs-6 w-275px" data-kt-menu="true" >
			<!--begin::Menu item-->
			<div v-show="walletStore.isLogged">
			<div class="menu-item px-3">
				<div class="menu-content d-flex align-items-center px-3">
					<!--begin::Avatar-->
					<div class="symbol symbol-50px me-5">
						<img alt="Logo" :src="`/partner/${walletStore.connector}.png`"/>
					</div>
					<!--end::Avatar-->
					<!--begin::Username-->
					<div class="d-flex flex-column">
						         
						<div class="fw-bolder d-flex align-items-center fs-5">{{walletStore?.account?.name}}
							<span class="badge badge-success fw-bolder fs-8 px-2 py-1 ms-2">{{ walletStore.connector }}</span>
						</div>
						<div class="d-flex fw-semibold align-items-center fs-6">
							<span class="text-gray-600 fs-6">PID:</span>  <span class="ms-2 me-2 fw-bold text-gray-800 fs-6" data-bs-toggle="tooltip" :title="walletStore.principal" v-show="walletStore.principal">{{ shortPrincipal(walletStore.principal) }}</span> <Copy :text="principal"></Copy>
						</div> 
					</div>
					
					<!--end::Username-->
				</div>
				<div class="separator my-2"></div>
				<div class="menu-item px-5">
					<div class="mb-1">       
						<div class="fw-semibold text-gray-600 fs-7">Principal ID:</div> 
						<div class="fw-bold text-gray-800 fs-6"><span data-bs-toggle="tooltip" :title="walletStore.principal" v-show="walletStore.principal">{{ shortPrincipal(walletStore.principal) }}</span> <Copy :text="walletStore.principal"></Copy></div>          
					</div>
					<div class="mb-1">       
						<div class="fw-semibold text-gray-600 fs-7">Address ID:</div> 
						<div class="fw-bold text-gray-800 fs-6"> <span data-bs-toggle="tooltip" :title="walletStore.address" v-show="walletStore.address">{{ shortAccount(walletStore.address) }}</span> <Copy :text="walletStore.address"></Copy></div>          
					</div>
					<div class="mb-1">       
						<div class="fw-semibold text-gray-600 fs-7">ICP Balance:</div> 
						<div class="fw-bold text-gray-800 fs-6"> {{ walletStore.balance }} 
							
							<LoadingLabel 
										:loading="isLoading"
										class="badge badge-light-primary ms-5"
										@click="refetch"><i class="fas fa-arrows-rotate"></i> Refresh
							</LoadingLabel>
						</div>          
					</div>
				</div>
				
			</div>
			<!--end::Menu item-->
			<!--begin::Menu separator-->
			<div class="separator my-2"></div>
			<!--end::Menu separator-->
			<!--begin::Menu item-->
			<div class="menu-item px-5">
				<a href="#" class="menu-link px-5">My Wallet</a>
			</div>
			<!--end::Menu item-->
			<!--begin::Menu item-->
			<div class="menu-item px-5">
				<a href="#" class="menu-link px-5">
					<span class="menu-text">My Tokens</span>
					<span class="menu-badge">
						<span class="badge badge-light-danger badge-circle fw-bolder fs-7">3</span>
					</span>
				</a>
			</div>
			<!--end::Menu item-->
			<!--begin::Menu item-->
			<div class="menu-item px-5">
				<a href="#" class="menu-link px-5">My Contracts</a>
			</div>
			<!--end::Menu item-->
			<!--begin::Menu separator-->
			<div class="separator my-2"></div>
			<!--end::Menu separator-->
			<!--begin::Menu item-->
			<div class="menu-item px-5 my-1">
				<a href="#" class="menu-link px-5">Account Settings</a>
			</div>
			<!--end::Menu item-->
			<!--begin::Menu item-->
			<div class="menu-item px-5">
				<a href="#" class="menu-link px-5 text-danger"  @click="() => logout()">Logout</a>
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