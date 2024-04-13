<script setup>
	import { ref } from 'vue';
	const stats = ref({
		contracts: "200+",
		users: "425+",
		transactions: "1.244+",
		tvl: "$12K+"
	})
	const partners = ref([
		{
			name: "Dfinity Grants",
			link: "https://dfinity.org/grants",
			logo: "/media/partners/dfinity-grants.svg"
		},
		{
			name: "ICPSwap",
			link: "https://icpswap.com",
			logo: "/media/partners/icpswap.svg"
		},
		{
			name: "Canister Geek",
			link: "https://cusyh-iyaaa-aaaah-qcpba-cai.raw.icp0.io/",
			logo: "/media/partners/canister-geek.svg"
		},
		{
			name: "Bitfinity",
			link: "https://bitfinity.network",
			logo: "/media/partners/bitfinity.webp"
		}
	]);
	const features = ref([
		{
			title: "Token Deployment",
			img: "/media/features/deploy-token.png",
			description: "Easily create and launch custom tokens on the Internet Computer using ICTO's deployment feature. Configure token details, leverage the official ICRC standard, and rapidly integrate your token into the expanding IC ecosystem.",
			link: {
				label: "Deploy your token",
				url: "/tokens"
			}
		},
		{
			title: "Liquidity Locks",
			img: "/media/features/liquidity-locks.png",
			description: "Seal your commitment to the project by visibly locking liquidity. Unlike burning tokens (hard to track), lock them securely for added transparency and trust. Ideal for token sales, ensuring fair distribution and milestone-based releases.",
			link: {
				label: "Configure your Token lock",
				url: "/token-locks"
			}
		},
		{
			title: "Trust and transparency",
			img: "/media/features/lock-details.png",
			description: "Investors can now visualize the locked value of their position relative to the entire TVL pool - providing the clearest insight into actual exposure.",
			link: {
				label: "Explore locked liquidity",
				url: "/token-locks/liquidity"
			}
		},
		{
			title: "Airdrop and Distribution",
			img: "/media/features/airdrop.png",
			description: "Offer an efficient way to reward your community and drive engagement. Easily configure airdrop parameters, approve recipients, and distribute tokens seamlessly on the Internet Computer platform. This encourages broader adoption and participation in your ecosystem.",
			link: {
				label: "Create an airdrop campaign",
				url: "/airdrop"
			}
		},
		{
			title: "Launchpad with DAO Model",
			img: "/media/features/launchpad.png",
			description: "Launchpad with customizable vesting, payroll, and governance tools for investor protection and streamlined project development.",
			link: {
				label: "Start your project",
				url: "/new-launchpad"
			}
		}
	])
</script>
<template>
	<div class="card1 mt-0 dashboard">
		<div class="card-body p-lg-10">
			<div class="row">
				<!--begin::Col-->
				<div class="col-md-6">
					<!--begin::Feature post-->
					<div class="h-100 d-flex flex-column justify-content-between pe-lg-6 mb-lg-0 mb-10">
						<!--begin::Body-->
						<div class="mb-5">
							<!--begin::Title-->
							<h1 class="fs-4x">Centralize all your token requirements</h1>
							<h3 class="fs-2x mt-5 text-dark fw-normal">
								ICTO allows companies to create, vest, lock or distribute their tokens through airdrops.
							</h3>
							<div class="mt-10 d-flex">
								<router-link to="/tokens" class="btn btn-danger me-3">Launch your Token <i class="fas fa-angle-double-up"></i></router-link>
								<router-link to="/token-locks" class="btn btn-success">Configure a Token lock <i class="fas fa-lock"></i></router-link>
							</div>
						</div>
						
					</div>
					<!--end::Feature post-->
				</div>
				<!--end::Col-->
				<!--begin::Col-->
				<div class="col-md-6 justify-content-between d-flex flex-column">
					<!--begin::Post-->
					<div class="ps-lg-6 mb-16 mt-md-0 mt-17">
						<!--begin::Footer-->
						<div class="d-flex flex-stack flex-wrap">
							<!--begin::Item-->
							<div class="d-flex align-items-center pe-2 card p-2 box-shadow">
								<img src="/media/features/payment.png" class="w-100" alt="">
							</div>
						</div>
						<!--end::Footer-->
					</div>
					<!--end::Post-->
				</div>
				<!--end::Col-->
			</div>
				<div class="d-flex flex-center flex-wrap position-relative px-5 card-rounded" style="background:linear-gradient(90deg, #f2c602 0%, #dea004 100%);">
					<span class="badge badge-secondary fw-bolder position-absolute translate-middle top-0 start-50">OUR PARTNERS</span>
					<span v-for="partner in partners" class="d-flex flex-center m-3 m-md-6" :title="partner.name" :key="partner.name">
						<a :title="partner.name" :href="partner.link" target="_blank">
							<img :src="partner.logo" class="mh-30px mh-lg-40px" :alt="partner.name">
						</a>
					</span>
				</div>
		</div>
	</div>
	
	<div class="mt-0">
		<div class="card-body p-lg-10">
			<div class="row">
				<h2 class="fs-3x  text-center">Secure and automate your token operations</h2>
				<p class="w-full text-center fs-3">Focus on building your company, free from worrying about your token management and operations.<br>We've combined all your essential token needs in one place.</p>
			</div>
			<div class="row mt-5" v-for="(feature, idx) in features">
				<div :class="`col-md-6 p-10 ${idx%2==0?'order-md-1':'order-md-2'}`">
					<div class="card p-5 box-shadow">
						<img :src="feature.img" class="w-100" />
					</div>
				</div>
				<div :class="`col-md-6 ${idx%2==0?'order-md-2':'order-md-1'}`">
					<div class="flex flex-1 flex-col gap-3 mt-20 ps-5">
						<h3 class="fs-2x">{{ feature.title }}</h3>
						<p class="fs-3">{{ feature.description }}</p>
						<router-link class="flex gap-2 py-3 fs-3" :to="feature.link.url"><p>{{ feature.link.label }} <i class="fas fa-chevron-right text-primary"></i></p>
						</router-link>
					</div>
				</div>
			</div>
		</div>
	</div>
	
	<div class="row g-5 g-xxl-8">
		<!--begin::Col-->
		<div class="col-xxl-4">
			<!--begin::Mixed Widget 5-->
			<div class="card card-xxl-stretch mb-xl-8">
				<!--begin::Beader-->
				<div class="card-header border-0 py-5">
					<h3 class="card-title align-items-start flex-column">
						<span class="card-label fw-bolder fs-3 mb-1">Trust in data</span>
					</h3>
				</div>
				<!--end::Header-->
				<!--begin::Body-->
				<div class="card-body d-flex flex-column py-3">
					<!--begin::Items-->
					<div class="mt-0">
						<!--begin::Item-->
						<div class="d-flex flex-stack mb-5">
							<!--begin::Section-->
							<div class="d-flex align-items-center me-2">
								<!--begin::Symbol-->
								<div class="symbol symbol-50px me-3">
									<div class="symbol-label bg-light">
										<span class="svg-icon svg-icon-danger svg-icon-2hx">
											<svg xmlns="http://www.w3.org/2000/svg" width="24" height="24" viewBox="0 0 24 24" fill="none">
												<path opacity="0.3" d="M21.25 18.525L13.05 21.825C12.35 22.125 11.65 22.125 10.95 21.825L2.75 18.525C1.75 18.125 1.75 16.725 2.75 16.325L4.04999 15.825L10.25 18.325C10.85 18.525 11.45 18.625 12.05 18.625C12.65 18.625 13.25 18.525 13.85 18.325L20.05 15.825L21.35 16.325C22.35 16.725 22.35 18.125 21.25 18.525ZM13.05 16.425L21.25 13.125C22.25 12.725 22.25 11.325 21.25 10.925L13.05 7.62502C12.35 7.32502 11.65 7.32502 10.95 7.62502L2.75 10.925C1.75 11.325 1.75 12.725 2.75 13.125L10.95 16.425C11.65 16.725 12.45 16.725 13.05 16.425Z" fill="black"/>
												<path d="M11.05 11.025L2.84998 7.725C1.84998 7.325 1.84998 5.925 2.84998 5.525L11.05 2.225C11.75 1.925 12.45 1.925 13.15 2.225L21.35 5.525C22.35 5.925 22.35 7.325 21.35 7.725L13.05 11.025C12.45 11.325 11.65 11.325 11.05 11.025Z" fill="black"/>
											</svg>
										</span>
									</div>
								</div>
								<!--end::Symbol-->
								<!--begin::Title-->
								<div>
									<a href="#" class="fs-6 text-gray-800 text-hover-primary fw-bolder">Canister Contracts</a>
								</div>
								<!--end::Title-->
							</div>
							<!--end::Section-->
							<!--begin::Label-->
							<div class="badge badge-light fw-bold py-4 px-3 fs-5">{{ stats.contracts }}</div>
							<!--end::Label-->
						</div>
						<!--end::Item-->
						<!--begin::Item-->
						<div class="d-flex flex-stack mb-5">
							<!--begin::Section-->
							<div class="d-flex align-items-center me-2">
								<!--begin::Symbol-->
								<div class="symbol symbol-50px me-3">
									<div class="symbol-label bg-light">
										<span class="svg-icon svg-icon-warning svg-icon-2hx">
											<svg xmlns="http://www.w3.org/2000/svg" width="24" height="24" viewBox="0 0 24 24" fill="none">
												<path opacity="0.3" d="M22 12C22 17.5 17.5 22 12 22C6.5 22 2 17.5 2 12C2 6.5 6.5 2 12 2C17.5 2 22 6.5 22 12ZM12 7C10.3 7 9 8.3 9 10C9 11.7 10.3 13 12 13C13.7 13 15 11.7 15 10C15 8.3 13.7 7 12 7Z" fill="black"/>
												<path d="M12 22C14.6 22 17 21 18.7 19.4C17.9 16.9 15.2 15 12 15C8.8 15 6.09999 16.9 5.29999 19.4C6.99999 21 9.4 22 12 22Z" fill="black"/>
											</svg>
										</span>
									</div>
								</div>
								<!--end::Symbol-->
								<!--begin::Title-->
								<div>
									<a href="#" class="fs-6 text-gray-800 text-hover-primary fw-bolder">Active Users</a>
								</div>
								<!--end::Title-->
							</div>
							<!--end::Section-->
							<!--begin::Label-->
							<div class="badge badge-light fw-bold py-4 px-3 fs-5">{{ stats.users }}</div>
							<!--end::Label-->
						</div>
						<!--end::Item-->
						<!--begin::Item-->
						<div class="d-flex flex-stack mb-5">
							<!--begin::Section-->
							<div class="d-flex align-items-center me-2">
								<!--begin::Symbol-->
								<div class="symbol symbol-50px me-3  text-primary">
									<div class="symbol-label bg-light text-primary">
										<span class="svg-icon svg-icon-primary svg-icon-2hx">
											<svg xmlns="http://www.w3.org/2000/svg" width="24" height="24" viewBox="0 0 24 24" fill="none">
												<rect x="8" y="9" width="3" height="10" rx="1.5" fill="black"/>
												<rect opacity="0.5" x="13" y="5" width="3" height="14" rx="1.5" fill="black"/>
												<rect x="18" y="11" width="3" height="8" rx="1.5" fill="black"/>
												<rect x="3" y="13" width="3" height="6" rx="1.5" fill="black"/>
											</svg>
										</span>
									</div>
								</div>
								<!--end::Symbol-->
								<!--begin::Title-->
								<div class="py-1">
									<a href="#" class="fs-6 text-gray-800 text-hover-primary fw-bolder">Transactions</a>
								</div>
								<!--end::Title-->
							</div>
							<!--end::Section-->
							<!--begin::Label-->
							<div class="badge badge-light fw-bold py-4 px-3 fs-5">{{ stats.transactions }}</div>
							<!--end::Label-->
						</div>
						<div class="d-flex flex-stack">
							<!--begin::Section-->
							<div class="d-flex align-items-center me-2">
								<!--begin::Symbol-->
								<div class="symbol symbol-50px me-3  text-primary">
									<div class="symbol-label bg-light text-primary">
										<!--begin::Svg Icon | path: assets/media/icons/duotune/general/gen026.svg-->
										<span class="svg-icon svg-icon-success svg-icon-2hx">
											<svg xmlns="http://www.w3.org/2000/svg" width="24px" height="24px" viewBox="0 0 24 24">
												<path d="M10.0813 3.7242C10.8849 2.16438 13.1151 2.16438 13.9187 3.7242V3.7242C14.4016 4.66147 15.4909 5.1127 16.4951 4.79139V4.79139C18.1663 4.25668 19.7433 5.83365 19.2086 7.50485V7.50485C18.8873 8.50905 19.3385 9.59842 20.2758 10.0813V10.0813C21.8356 10.8849 21.8356 13.1151 20.2758 13.9187V13.9187C19.3385 14.4016 18.8873 15.491 19.2086 16.4951V16.4951C19.7433 18.1663 18.1663 19.7433 16.4951 19.2086V19.2086C15.491 18.8873 14.4016 19.3385 13.9187 20.2758V20.2758C13.1151 21.8356 10.8849 21.8356 10.0813 20.2758V20.2758C9.59842 19.3385 8.50905 18.8873 7.50485 19.2086V19.2086C5.83365 19.7433 4.25668 18.1663 4.79139 16.4951V16.4951C5.1127 15.491 4.66147 14.4016 3.7242 13.9187V13.9187C2.16438 13.1151 2.16438 10.8849 3.7242 10.0813V10.0813C4.66147 9.59842 5.1127 8.50905 4.79139 7.50485V7.50485C4.25668 5.83365 5.83365 4.25668 7.50485 4.79139V4.79139C8.50905 5.1127 9.59842 4.66147 10.0813 3.7242V3.7242Z" fill="#00A3FF"/>
												<path class="permanent" d="M14.8563 9.1903C15.0606 8.94984 15.3771 8.9385 15.6175 9.14289C15.858 9.34728 15.8229 9.66433 15.6185 9.9048L11.863 14.6558C11.6554 14.9001 11.2876 14.9258 11.048 14.7128L8.47656 12.4271C8.24068 12.2174 8.21944 11.8563 8.42911 11.6204C8.63877 11.3845 8.99996 11.3633 9.23583 11.5729L11.3706 13.4705L14.8563 9.1903Z" fill="white"/>
											</svg>
										</span>
										<!--end::Svg Icon-->
									</div>
								</div>
								<!--end::Symbol-->
								<!--begin::Title-->
								<div class="py-1">
									<a href="#" class="fs-6 text-gray-800 text-hover-primary fw-bolder">Total Value Locked</a>
								</div>
								<!--end::Title-->
							</div>
							<!--end::Section-->
							<!--begin::Label-->
							<div class="badge badge-light fw-bold py-4 px-3 fs-5">{{ stats.tvl }}</div>
							<!--end::Label-->
						</div>
						<!--end::Item-->
					</div>
					<!--end::Items-->
			</div>
				<!--end::Body-->
			</div>
			<!--end::Mixed Widget 5-->
		</div>
		<!--end::Col-->
		<!--begin::Col-->
		<div class="col-xxl-8">
			<!--begin::Tables Widget 5-->
			<div class="card card-xxl-stretch mb-5 mb-xl-8">
				<!--begin::Header-->
				<div class="card-header border-0 py-5">
					<h3 class="card-title align-items-start flex-column">
						<span class="card-label fw-bolder fs-3 mb-1">Product Roadmaps</span>
					</h3>

				</div>
				<!--end::Header-->
				<!--begin::Body-->
				<div class="card-body py-3">
					<div class="tab-content">
						<!--begin::Tap pane-->
						<div class="tab-pane fade show active" id="kt_table_widget_5_tab_1">
							<div class="timeline-label">
								<!--begin::Item-->
								<div class="timeline-item mb-2">
									<!--begin::Label-->
									<div class="timeline-label fw-bolder text-gray-800 fs-6"></div>
									<!--end::Label-->
									<!--begin::Badge-->
									<div class="timeline-badge">
										<i class="fa fa-genderless text-success fs-1"></i>
									</div>
									<!--end::Badge-->
									<!--begin::Content-->
									<div class="timeline-content">
										<div class="fw-bolder text-primary ps-3">Q1/2024</div>
										<span class="fw-bolder text-gray-800 ps-3 d-flex justify-content-between p-1">Deploy ICRC Token <span class="badge badge-light-success fs-8 fw-bold">Done</span></span>
									</div>
									<!--end::Content-->
								</div>
								<!--end::Item-->
								<!--begin::Item-->
								<div class="timeline-item mb-2">
									<div class="timeline-label fw-bolder text-gray-800 fs-6"></div>
									<div class="timeline-badge">
										<i class="fa fa-genderless text-warning fs-1"></i>
									</div>
									<div class="timeline-content fw-bolder text-gray-800 ps-3">
										<div class="fw-bolder text-primary">Q2/2024</div>
										<div class="d-flex justify-content-between p-1">Token locks: LP Lock contract <span class="badge badge-light-success fs-8 fw-bold">Done</span></div>
										<div class="d-flex justify-content-between p-1">Airdrop distribution <span class="badge badge-light-success fs-8 fw-bold">Done</span></div>
										<div class="fw-normal d-flex justify-content-between p-1">Vesting/Payment contract <span class="badge badge-light-warning fs-8 fw-bold">Inprogress</span></div>
										<div class="d-flex justify-content-between p-1">Launchpad with DAOs model <span class="badge badge-light-warning fs-8 fw-bold">Inprogress</span></div>
									</div>
								</div>
								<div class="timeline-item mb-2">
									<div class="timeline-label fw-bolder text-gray-800 fs-6"></div>
									<div class="timeline-badge">
										<i class="fa fa-genderless text-danger fs-1"></i>
									</div>
									<div class="timeline-content fw-bolder text-gray-800 ps-3">
										<div class="fw-bolder text-primary">Q3/2024</div>
										<div class="fw-normal d-flex justify-content-between p-1">Launch ICTO NFT Card Gen 2.0 <span class="badge badge-light-danger fs-8 fw-bold">Scheduled</span></div>
										<div class="fw-normal d-flex justify-content-between p-1">Token tracking <span class="badge badge-light-danger fs-8 fw-bold">Scheduled</span></div>
									</div>
								</div>
								<!--end::Item-->
							</div>
						</div>
						<!--end::Tap pane-->
					</div>
				</div>
				<!--end::Body-->
			</div>
			<!--end::Tables Widget 5-->
		</div>
		<!--end::Col-->
	</div>

	
	<div class="pt-10">
		<!--begin::Container-->
		<div class="container">
			<!--begin::Row-->
			<div class="row py-0 py-lg-0">
				<!--begin::Col-->
				<div class="col-lg-4 pe-lg-16 mb-10 mb-lg-0 footer-branch text-center">
					<div>
						<img src="/media/logos/logo-vertical.png" class="h-60px" />
						<h5 class="fw-bold text-gray-600 mb-6 mt-5">Centralize your token needs!<br />Entirely on-chain with <a href="https://internetcomputer.org" target="_blank" title="Internet Computer">Internet Computer</a></h5>
						<div class="flex">
							<a href="https://github.com/ICTO-Labs" class="mb-6" target="_blank">
								<i class="fab fa-github h-20px me-2 fs-2x"></i>
							</a>
							<a href="https://twitter.com/icto_app" target="_blank" class="mb-6">
								<i class="fab fa-twitter h-20px me-2 fs-2x"></i>
							</a>
							<a href="https://t.me/icto_app" class="mb-6" target="_blank">
								<i class="fab fa-telegram h-20px me-2 fs-2x"></i>
							</a>
							<a href="#" class="mb-6" target="_blank">
								<i class="fab fa-discord h-20px me-2 fs-2x"></i>
							</a>
						</div>
					</div>
				</div>
				<!--end::Col-->
				<!--begin::Col-->
				<div class="col-lg-8 ps-lg-16">
					<!--begin::Navs-->
					<div class="d-flex justify-content-center">
						<!--begin::Links-->
						<div class="d-flex fw-bold flex-column ms-lg-20 me-20">
							<!--begin::Subtitle-->
							<h5 class="fw-bold text-gray-400 mb-3">Our services</h5>
							<!--end::Subtitle-->
							<router-link to="/tokens" class="mb-3">
								<span>Deploy Token</span>
							</router-link>
							<router-link to="/token-locks" class="mb-3">
								<span>Liquidity Locks</span>
							</router-link>
							<router-link to="/airdrop" class="mb-3">
								<span>Airdrop Campaign</span>
							</router-link>
							<router-link to="/payments" class="mb-3">
								<span>Payment Contract</span>
							</router-link>
							<router-link to="/marketplace">
								<span>NFT Marketplace</span>
							</router-link>
						</div>
						<!--end::Links-->
						<!--begin::Links-->
						<div class="d-flex fw-bold flex-column ms-lg-20 text-secondary me-20">
							<!--begin::Subtitle-->
							<h5 class="fw-bold text-gray-400 mb-3">More for ICTO</h5>
							<!--end::Subtitle-->
							<!--begin::Link-->
							<a href="/about-us" class="mb-3">About Us</a>
							<a href="#" class="mb-3">FAQ</a>
							<!--end::Link-->
							<!--begin::Link-->
							<a href="https://docs.icto.app" target="_blank" class="mb-3">Documents</a>
							<!--end::Link-->
							<!--begin::Link-->
							<a href="#" class="mb-3">Privacy Notice</a>
							<!--end::Link-->
							<!--begin::Link-->
							<a href="https://github.com/ICTO-Labs" class="mb-3">Terms of Use</a>
							<!--end::Link-->
						</div>
						<!--end::Links-->
						<!--begin::Links-->
						<div class="d-flex fw-bold flex-column ms-lg-20">
							<!--begin::Subtitle-->
							<h5 class="fw-bold text-gray-400 mb-3">Stay Connected</h5>
							<!--end::Subtitle-->
							<!--begin::Link-->
							<a href="https://twitter.com/icto_app" target="_blank" class="mb-3">
								<i class="fab fa-twitter me-2"></i>
								<span>Twitter</span>
							</a>
							<!--end::Link-->
							<!--begin::Link-->
							<a href="https://github.com/ICTO-Labs" class="mb-3" target="_blank">
								<i class="fab fa-github me-2"></i>
								<span>Github</span>
							</a>
							<!--end::Link-->
							
							<!--begin::Link-->
							<a href="#" class="mb-3" target="_blank">
								<i class="fab fa-discord me-2"></i>
								<span>Discord</span>
							</a>
							<!--end::Link-->
							<!--begin::Link-->
							<a href="https://t.me/icto_app" class="mb-3" target="_blank">
								<i class="fab fa-telegram me-2"></i>
								<span>Telegram</span>
							</a>
							<a href="https://t.me/icto_app" class="mb-3" target="_blank">
								<i class="fab fa-medium me-2"></i>
								<span>Medium</span>
							</a>
							<!--end::Link-->
						</div>
						<!--end::Links-->
						
					</div>
					<!--end::Navs-->
				</div>
				<!--end::Col-->
			</div>
			<!--end::Row-->
		</div>
		<!--end::Container-->
	</div>
</template>
<style scoped>
	.dashboard{
		margin-top: -80px !important;
	}
	@media (max-width: 990px) {
		.dashboard {
			margin-top: auto !important;
		}
	}
</style>