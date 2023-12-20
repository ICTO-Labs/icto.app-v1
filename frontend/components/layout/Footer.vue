<template>
    <!--begin::Footer-->
    <div class="footer py-4 d-flex flex-lg-column" id="kt_footer">
						<!--begin::Container-->
						<div class="container-fluid d-flex flex-column flex-md-row align-items-center justify-content-between">
							<!--begin::Copyright-->
							<div class="text-dark order-2 order-md-1">
								<span class="fw-bold text-gray-800 me-1">2023 ©</span>
								<a href="https://icto.app" class="text-gray-800 text-hover-primary me-1 fw-bold me-2">ICTO.APP</a>
								<span class="text-muted fs-7"><i class="fas fa-code"></i> build: 8d788326</span>
							</div>
							<!--end::Copyright-->
							<!--begin::Menu-->
							<ul class="menu menu-gray-600 menu-hover-primary fw-bold order-1">
								<li class="menu-item">
									<router-link to="/about" target="_blank" class="menu-link px-2">About</router-link>
								</li>
								<li class="menu-item">
									<router-link to="/support" target="_blank" class="menu-link px-2">Support</router-link>
								</li>
								<li class="menu-item">
									<router-link to="/contact" class="menu-link px-2">Contact</router-link>
								</li>
							</ul>
							<!--end::Menu-->
						</div>
						<!--end::Container-->
					</div>
					<!--end::Footer-->
</template>