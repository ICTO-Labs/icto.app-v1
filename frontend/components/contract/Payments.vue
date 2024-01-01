<script setup>
    import { ref, onMounted } from "vue";
    import {useListContract} from "@/services/Contract";
    import CountUp from 'vue-countup-v3'

    const contracts = ref([])
    const getList = async()=>{
        contracts.value = await useListContract();
    }

    onMounted(()=>{
        getList()
    })
    
</script>
<template>
    <div class="row g-6 g-xl-9">
        <div class="col-sm-6 col-xl-4" v-for="contract in contracts">
            <!--begin::Card-->
            <div class="card h-100">
                <!--begin::Card header-->
                <div class="card-header flex-nowrap border-0 pt-9">
                    <!--begin::Card title-->
                    <div class="card-title m-0">
                        <!--begin::Icon-->
                        <div class="symbol symbol-45px w-45px bg-light me-5">
                            <img src="https://psh4l-7qaaa-aaaap-qasia-cai.raw.icp0.io/6ytv5-fqaaa-aaaap-qblcq-cai.png" alt="image" class="p-3">
                        </div>
                        <!--end::Icon-->
                        <!--begin::Title-->
                        <router-link :to="`/contract/${contract}`" class="fs-4 fw-bold text-hover-primary text-gray-600 m-0">{{ contract }}</router-link>
                        <!--end::Title-->
                    </div>
                    <!--end::Card title-->
                </div>
                <!--end::Card header-->
                <!--begin::Card body-->
                <div class="card-body d-flex flex-column px-9 pt-6 pb-8">
                    <!--begin::Heading-->
                    <div class="fs-2tx fw-bolder mb-3"><CountUp :end-val="1902"/></div>
                    <!--end::Heading-->
                    <!--begin::Stats-->
                    <div class="d-flex align-items-center flex-wrap mb-5 mt-auto fs-6">
                        <!--SVG file not found: icons/duotune/arrows/Up-right.svg-->
                        <!--begin::Number-->
                        <div class="fw-bolder text-danger me-2"><CountUp :end-val="1902"/></div>
                        <!--end::Number-->
                        <!--begin::Label-->
                        <div class="fw-bold text-gray-400"> unlocked!</div>
                        <!--end::Label-->
                    </div>
                    <!--end::Stats-->
                    <!--begin::Indicator-->
                    <div class="d-flex align-items-center fw-bold">
                        <span class="badge bg-light text-gray-700 px-3 py-2 me-2">0.5%</span>
                        <span class="text-gray-400 fs-7">MRR</span>
                        <i class="fas fa-exclamation-circle fs-7 ms-2" data-bs-toggle="tooltip" title="" data-bs-original-title="Recurring" aria-label="Recurring"></i>
                    </div>
                    <!--end::Indicator-->
                </div>
                <!--end::Card body-->
            </div>
            <!--end::Card-->
        </div>
    </div>
</template>