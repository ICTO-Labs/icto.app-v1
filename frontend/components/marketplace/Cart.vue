<script setup>
    import { ref, onMounted } from "vue";
    import config from "@/config";
    import EventBus from "@/services/EventBus";
    import { VueFinalModal } from 'vue-final-modal'
    import LoadingButton from "@/components/LoadingButton.vue"
	import { showLoading, closeMessage, showSuccess, showError, validateAddress, validatePrincipal } from '@/utils/common';
    import { useTransferToken } from "@/services/Token"
    const cartModal = ref(false);
    const carts = ref([]);
    
    const closeModal = ()=>{ cartModal.value = false};
    const removeItem = (idx)=>{ carts.value.splice(idx, 1)};
    const emptyCart = ()=>{ carts.value = []};

    onMounted(() => {
        EventBus.on("showCartPoppup", obj => {
            console.log('obj', obj);
            cartModal.value = obj.status;
            carts.value.push(obj.nft);
        });  
    })
</script>
<template>
    <div v-if="cartModal" class="bg-white p-3 rounded-3 cartPopup w-450px shadow">
        <div class="card p-0 card-xl-stretch mb-5 mb-xl-8">
            <div class="card-header min-h-30px p-0 border-0 pt-0">
                <h3 class="card-title align-items-start flex-column">
                    <span class="card-label fw-bolder text-dark"><i class="fas fa-cart-plus"></i> Cart <span class="badge badge-circle badge-primary ms-2">{{ carts.length }}</span></span>
                </h3>
                <div class="card-toolbar">
                    <button class="me-3 btn btn-sm btn-light-warning" @click="emptyCart">Empty cart</button>
                    <button class="btn btn-icon btn-sm btn-light-danger" @click="closeModal"><i class="fas fa-times"></i></button>
                </div>
            </div>
            <div class="separator my-2"></div>
            <div class="card-body p-2 scroll-y mh-350px">
                <!--begin::Table container-->
                <div class="table-responsive">
                    <!--begin::Table-->
                    <table class="table table-row-dashed table-row-gray-300 align-middle gs-0 gy-4">
                        <!--begin::Table head-->
                        <thead>
                            <tr class="fw-bolder text-muted">
                                <th class="w-25px">
                                    <div class="form-check form-check-sm form-check-custom form-check-solid">
                                        <input class="form-check-input" type="checkbox" value="1" data-kt-check="true" data-kt-check-target=".widget-9-check">
                                    </div>
                                </th>
                                <th class="min-w-150px">Item</th>
                                <th class="min-w-120px text-end">Price</th>
                            </tr>
                        </thead>
                        <!--end::Table head-->
                        <!--begin::Table body-->
                        <tbody>
                            <tr v-for="(item, idx) in carts">
                                <td>
                                    <div class="form-check form-check-sm form-check-custom form-check-solid">
                                        <input class="form-check-input widget-9-check" type="checkbox" value="1">
                                    </div>
                                </td>
                                <td>
                                    <div class="d-flex align-items-center">
                                        <div class="w-80px me-5 position-relative">
                                            <span @click="removeItem(idx)" title="Remove" class="btn btn-icon btn-circle btn-active-color-primary w-20px h-20px bg-danger shadow position-absolute">
                                                <i class="bi bi-x fs-2  text-white"></i>
                                            </span>
                                            <img :src="`http://localhost:5500/sample/${item}.svg`" alt="" class="w-100">
                                        </div>
                                        <div class="d-flex justify-content-start flex-column">
                                            <span class="text-dark fw-bolder text-hover-primary fs-6">#{{ item }}</span>
                                            <span class="text-muted fw-bold text-muted d-block fs-7"></span>
                                        </div>
                                    </div>
                                </td>
                                
                                <td class="text-end">
                                    <a href="#" class="text-dark fw-bolder text-hover-primary d-block fs-6">7.8</a>
                                    <span class="text-muted fw-bold text-muted d-block fs-7">~$32</span>
                                </td>
                            </tr>
                        </tbody>
                        <!--end::Table body-->
                    </table>
                    <!--end::Table-->
                </div>
                <!--end::Table container-->
            </div>
        </div>
    </div>
    <button id="kt_explore_toggle" v-if="!cartModal" @click="cartModal=true" class="explore-toggle btn btn-sm bg-body btn-color-gray-700 btn-active-danger shadow-sm position-fixed px-5 fw-bolder zindex-2 top-50 mt-10 end-0 fs-6 rounded-end-0" >
			<span id="kt_explore_toggle_label"><i class="fas fa-shopping-cart"></i></span>
            <div class="position-absolute translate-middle top-0 start-0 bg-danger rounded-circle border border-4 border-white h-20px w-20px animation-blink" v-if="carts.length>0"></div>
		</button>
</template>
<style scoped>
    .cartPopup{
        height:450px;
        position: fixed;
        bottom: 54px;
        right:10px;
        -webkit-animation: expand 1s;
    }
    @-webkit-keyframes expand{
        0%{height:0px}
        100%{height:450px}
    }
    @-webkit-keyframes close{
        100%{height:450px}
        0%{height:0px}
    }
</style>