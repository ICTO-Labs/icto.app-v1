<template>
    <div class="card card-docs mb-2">
        <div class="card card-flush w-lg-650px py-5">
            <div class="card-body py-15 py-lg-20">
                <!--begin::Title-->
                <h1 class="fw-bolder fs-2hx text-gray-900 mb-4">
                    😱 Oops!
                </h1>
                <!--end::Title--> 
                <!--begin::Text-->
                <div class="fw-semibold fs-6 text-gray-500 mb-7">
                    We’re sorry but this page can’t be found!
                </div>
                <!--end::Text--> 

                <!--begin::Link-->
                <div class="mb-0">
                    <router-link to="/"><button color="primary" class="btn btn-sm btn-primary">Return to Home</button></router-link>
                </div>    
                <!--end::Link-->

            </div>
        </div>
    </div>
</template>