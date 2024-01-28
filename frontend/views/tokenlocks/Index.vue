<script setup>
    import { useRoute } from 'vue-router';
    const route = useRoute();
    console.log('route', route);
</script>
<template>
    <Toolbar :current="`Token Locks`" v-if="route.name=='token-locks'"/>
    <Toolbar :current="route.name" :parents="[{title: 'Token Locks', to: '/token-locks'}]" v-else/>
    <div class="row" v-if="route.name == 'token-locks'">
        <div class="col-xl-4">
            <div class="card bgi-no-repeat card-xl-stretch mb-xl-8 border-hover">
                <div class="card-body">
                    <div class="p-2 d-flex align-items-center pb-5" for="liquidity">
                        <span class="svg-icon svg-icon-3x me-5">
                            <svg xmlns="http://www.w3.org/2000/svg" width="24" height="24" viewBox="0 0 24 24" fill="none">
                                <path opacity="0.3" d="M4.05424 15.1982C8.34524 7.76818 13.5782 3.26318 20.9282 2.01418C21.0729 1.98837 21.2216 1.99789 21.3618 2.04193C21.502 2.08597 21.6294 2.16323 21.7333 2.26712C21.8372 2.37101 21.9144 2.49846 21.9585 2.63863C22.0025 2.7788 22.012 2.92754 21.9862 3.07218C20.7372 10.4222 16.2322 15.6552 8.80224 19.9462L4.05424 15.1982ZM3.81924 17.3372L2.63324 20.4482C2.58427 20.5765 2.5735 20.7163 2.6022 20.8507C2.63091 20.9851 2.69788 21.1082 2.79503 21.2054C2.89218 21.3025 3.01536 21.3695 3.14972 21.3982C3.28408 21.4269 3.42387 21.4161 3.55224 21.3672L6.66524 20.1802L3.81924 17.3372ZM16.5002 5.99818C16.2036 5.99818 15.9136 6.08615 15.6669 6.25097C15.4202 6.41579 15.228 6.65006 15.1144 6.92415C15.0009 7.19824 14.9712 7.49984 15.0291 7.79081C15.0869 8.08178 15.2298 8.34906 15.4396 8.55884C15.6494 8.76862 15.9166 8.91148 16.2076 8.96935C16.4986 9.02723 16.8002 8.99753 17.0743 8.884C17.3484 8.77046 17.5826 8.5782 17.7474 8.33153C17.9123 8.08486 18.0002 7.79485 18.0002 7.49818C18.0002 7.10035 17.8422 6.71882 17.5609 6.43752C17.2796 6.15621 16.8981 5.99818 16.5002 5.99818Z" fill="black"></path>
                                <path d="M4.05423 15.1982L2.24723 13.3912C2.15505 13.299 2.08547 13.1867 2.04395 13.0632C2.00243 12.9396 1.9901 12.8081 2.00793 12.679C2.02575 12.5498 2.07325 12.4266 2.14669 12.3189C2.22013 12.2112 2.31752 12.1219 2.43123 12.0582L9.15323 8.28918C7.17353 10.3717 5.4607 12.6926 4.05423 15.1982ZM8.80023 19.9442L10.6072 21.7512C10.6994 21.8434 10.8117 21.9129 10.9352 21.9545C11.0588 21.996 11.1903 22.0083 11.3195 21.9905C11.4486 21.9727 11.5718 21.9252 11.6795 21.8517C11.7872 21.7783 11.8765 21.6809 11.9402 21.5672L15.7092 14.8442C13.6269 16.8245 11.3061 18.5377 8.80023 19.9442ZM7.04023 18.1832L12.5832 12.6402C12.7381 12.4759 12.8228 12.2577 12.8195 12.032C12.8161 11.8063 12.725 11.5907 12.5653 11.4311C12.4057 11.2714 12.1901 11.1803 11.9644 11.1769C11.7387 11.1736 11.5205 11.2583 11.3562 11.4132L5.81323 16.9562L7.04023 18.1832Z" fill="black"></path>
                            </svg>
                        </span>
                        <span class="d-block fw-bold text-start">
                            <span class="text-dark fw-bolder d-block fs-4 mb-2">Liquidity Locks</span>
                            <span class="text-muted fw-bold fs-6">Foster trust and stimulate trading activity through our transparent liquidity locks.</span>
                        </span>
                    </div>
                    <div class="d-flex flex-column gap-7 gap-md-10">
						<router-link to="/token-locks/liquidity" class="btn btn-sm btn-primary"><span class="fw-bolder">Continue <i class="fas fa-arrow-right"></i> </span> </router-link>
					</div>
                </div>
            </div>
        </div>
        <div class="col-xl-4">
            <div class="card bgi-no-repeat card-xl-stretch mb-xl-8">
                <div class="card-body">
                    <div class="p-2 d-flex align-items-center pb-5" for="liquidity">
                        <span class="svg-icon svg-icon-3x me-5">
                            <svg xmlns="http://www.w3.org/2000/svg" width="24" height="24" viewBox="0 0 24 24" fill="none">
                                <path d="M16.95 18.9688C16.75 18.9688 16.55 18.8688 16.35 18.7688C15.85 18.4688 15.75 17.8688 16.05 17.3688L19.65 11.9688L16.05 6.56876C15.75 6.06876 15.85 5.46873 16.35 5.16873C16.85 4.86873 17.45 4.96878 17.75 5.46878L21.75 11.4688C21.95 11.7688 21.95 12.2688 21.75 12.5688L17.75 18.5688C17.55 18.7688 17.25 18.9688 16.95 18.9688ZM7.55001 18.7688C8.05001 18.4688 8.15 17.8688 7.85 17.3688L4.25001 11.9688L7.85 6.56876C8.15 6.06876 8.05001 5.46873 7.55001 5.16873C7.05001 4.86873 6.45 4.96878 6.15 5.46878L2.15 11.4688C1.95 11.7688 1.95 12.2688 2.15 12.5688L6.15 18.5688C6.35 18.8688 6.65 18.9688 6.95 18.9688C7.15 18.9688 7.35001 18.8688 7.55001 18.7688Z" fill="black"></path>
                                <path opacity="0.3" d="M10.45 18.9687C10.35 18.9687 10.25 18.9687 10.25 18.9687C9.75 18.8687 9.35 18.2688 9.55 17.7688L12.55 5.76878C12.65 5.26878 13.25 4.8687 13.75 5.0687C14.25 5.1687 14.65 5.76878 14.45 6.26878L11.45 18.2688C11.35 18.6688 10.85 18.9687 10.45 18.9687Z" fill="black"></path>
                            </svg>
                        </span>
                        <span class="d-block fw-bold text-start">
                            <span class="text-dark fw-bolder d-block fs-4 mb-2">Token Locks</span>
                            <span class="text-muted fw-bold fs-6">Enhance your project's transparency and credibility by securely locking team tokens.</span>
                        </span>
                    </div>
                    <div class="d-flex flex-column gap-7 gap-md-10">
						<router-link to="/token-locks/token" class="btn btn-sm btn-primary"><span class="fw-bolder">Continue <i class="fas fa-arrow-right"></i> </span> </router-link>
					</div>
                </div>
            </div>
        </div>

        <div class="col-xl-4">
            <div class="card bgi-no-repeat card-xl-stretch mb-xl-8">
                <div class="card-body">
                    <div class="p-2 d-flex align-items-center pb-5" for="liquidity">
                        <span class="svg-icon svg-icon-3x me-5">
                            <svg xmlns="http://www.w3.org/2000/svg" width="24" height="24" viewBox="0 0 24 24" fill="none">
                                <path opacity="0.3" d="M21.25 18.525L13.05 21.825C12.35 22.125 11.65 22.125 10.95 21.825L2.75 18.525C1.75 18.125 1.75 16.725 2.75 16.325L4.04999 15.825L10.25 18.325C10.85 18.525 11.45 18.625 12.05 18.625C12.65 18.625 13.25 18.525 13.85 18.325L20.05 15.825L21.35 16.325C22.35 16.725 22.35 18.125 21.25 18.525ZM13.05 16.425L21.25 13.125C22.25 12.725 22.25 11.325 21.25 10.925L13.05 7.625C12.35 7.325 11.65 7.325 10.95 7.625L2.75 10.925C1.75 11.325 1.75 12.725 2.75 13.125L10.95 16.425C11.65 16.725 12.45 16.725 13.05 16.425Z" fill="black"></path>
                                <path d="M11.05 11.025L2.84998 7.725C1.84998 7.325 1.84998 5.925 2.84998 5.525L11.05 2.225C11.75 1.925 12.45 1.925 13.15 2.225L21.35 5.525C22.35 5.925 22.35 7.325 21.35 7.725L13.05 11.025C12.45 11.325 11.65 11.325 11.05 11.025Z" fill="black"></path>
                            </svg>
                        </span>
                        <span class="d-block fw-bold text-start">
                            <span class="text-dark fw-bolder d-block fs-4 mb-2">NFT Locks</span>
                            <span class="text-muted fw-bold fs-6">Guarantee the enduring worth of your NFTs and demonstrate steadfast backing for your project.</span>
                        </span>
                    </div>
                    <div class="d-flex flex-column gap-7 gap-md-10">
						<router-link to="/token-locks/nft" class="btn btn-sm btn-primary"><span class="fw-bolder">Continue <i class="fas fa-arrow-right"></i> </span> </router-link>
					</div>
                </div>
            </div>
        </div>
    </div>
    <router-view v-else></router-view>
</template>