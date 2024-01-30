<script setup>
    import { defineProps } from 'vue';
    const props = defineProps(['nft', 'collectionInfo']);
    import { showModal } from '@/utils/common';

    const transferNFT = (token)=>{
        const newObj = {...token};
        newObj.status = true;
        newObj.action = 'transfer';
        newObj.isNFT = true;
        showModal("showTransferTokenModal", newObj)
    }
</script>
<template>
    <div class="bg-light bg-opacity-75 p-3 rounded-3 nft-item">
        <div class="card-xl-stretch">
            <!--begin::Overlay-->
            <a class="d-block overlay" data-fslightbox="lightbox-hot-sales" href="http://be2us-64aaa-aaaaa-qaabq-cai.localhost:8000/">
            <!--begin::Image-->
            <div class="overlay-wrapper bgi-no-repeat bgi-position-center bgi-size-cover card-rounded min-h-150px" :style="`background-image:url('http://localhost:5500/sample/${props.nft}.svg')`"></div>
            <!--end::Image-->
            <!--begin::Action-->
            <div class="overlay-layer card-rounded bg-dark bg-opacity-25">
                <i class="bi bi-eye-fill fs-2x text-white"></i>
            </div>
            <!--end::Action-->
            </a>
            <!--end::Overlay-->
            <!--begin::Body-->
            <div class="mt-5">
            <!--begin::Title-->
            <a href="#" class="fs-6 text-dark fw-bolder text-hover-primary text-dark lh-base">ICTO NFT Card</a>
            <div class="fs-6 fw-bolder mt-5 d-flex flex-stack">
                <!--begin::Label-->
                <span class="badge border-dashed fs-2 fw-bolder text-dark p-1">
                <span class="fs-6 fw-bold text-gray-400">#</span>{{props.nft.id}}
                </span>
                <!--end::Label-->
                <!--begin::Action-->
                <a href="#" class="btn btn-primary btn-sm" @click="transferNFT(props.collectionInfo)">Transfer <i class="fas fa-paper-plane"></i>
                </a>
                <!--end::Action-->
            </div>
            <!--end::Text-->
            </div>
            <!--end::Body-->
        </div>
    </div>
</template>
<style scoped>
    .nft-item:hover{
        box-shadow: 0 5px 10px rgba(0, 69, 219, 0.07)
    }
</style>