<script setup>
    import { ref, reactive, watch, watchEffect } from 'vue';
    import { getInfo, useCommit, getStatus, getTopAffiliates, useCreateShortlink, getShortlink, deleteShortLink } from '@/services/Launchpad';
    import { showError, showSuccess, showLoading } from '@/utils/common';
    import walletStore from '@/store/';
    const props = defineProps(['launchpadId']);
    const { data: myShortLink, isError: isLinkError, error: linkError, isLoading: isLinkLoading, isFetched, refetch } = getShortlink('launchpad', props.launchpadId);
    const referrerLink = ref(`https://icto.app/launchpad/${props.launchpadId}?r=${walletStore.principal}`);
    const customLink = ref('');
    const currentLink = ref('');
    const shortLink = ref(null);

    watchEffect(() => {
        if (isFetched.value && myShortLink.value) {
            try{
                currentLink.value = myShortLink.value[0][0][0];
            }catch(e){
                console.log('myShortLink_ERR', e);
            }
        }
    });
    watch(() => walletStore.isLogged, (newIsLogged) => {
        if (newIsLogged) {
            referrerLink.value = `https://icto.app/launchpad/${props.launchpadId}?r=${walletStore.principal}`;
            refetch();
            try{
                currentLink.value = myShortLink.value[0][0][0];
            }catch(e){
                console.log('myShortLink_ERR', e);
            }
        } else {
            currentLink.value = "";
            customLink.value = "";
            shortLink.value = null;
        }
    }, { immediate: true });

    const toValidUrlId = (input) => {
        return input
        .toLowerCase()
        .replace(/[^a-z0-9\s-]/g, '')
        .trim()
        .replace(/\s+/g, '-')
        .replace(/-+/g, '-');
    };
    const handleCreateShortLink = async () => {
        let _customLink = customLink.value;
        if(_customLink == ''){
            return showError("Please enter your short link");
        }
        let _newShortLink = toValidUrlId(_customLink);
        Swal.fire({
            title: "Are you sure?",
            text: "Create ref short link: `https://icto.link/"+ _newShortLink + "` for this launchpad campaign?",
            icon: "warning",
            showCancelButton: true,
            confirmButtonColor: "#3085d6",
            cancelButtonColor: "#d33",
            confirmButtonText: "Yes, I confirmed!"
            }).then(async (result) => {
                if (result.isConfirmed) {
                    showLoading('Registering your ref short link, please wait...');
                    let _rs = await useCreateShortlink(_newShortLink, 'launchpad', props.launchpadId);
                    console.log('_rs_rs_rs_rs_rs_rs', _rs);
                    if(_rs) {
                        currentLink.value = _newShortLink;
                        showSuccess('Your short link has been registered!', true);
                    }else{
                        showError('Can not create the short link, please try again!', true);
                    }
                    refetch();//Refresh status
                }
        });
    };

    const handleDeleteShortLink = async () => {
        Swal.fire({
            title: "Are you sure?",
            text: "Delete registered short link: `https://icto.link/"+ currentLink.value + "`?",
            icon: "warning",
            showCancelButton: true,
            confirmButtonColor: "#3085d6",
            cancelButtonColor: "#d33",
            confirmButtonText: "Yes, I confirmed!"
            }).then(async (result) => {
                if (result.isConfirmed) {
                    showLoading('Deleting, please wait...');
                    let _rs = await deleteShortLink(currentLink.value);
                    if(_rs) {
                        showSuccess('Your short link has been deleted, you can create new one!', true);
                    }else{
                        showError('Can not delete the short link, please try again!', true);
                    }
                    refetch();//Refresh status
                }
        });
    };
</script>
<template>
    <div v-if="walletStore.isLogged">
        <div class="col-md-12 fv-row">
            <label class="d-flex align-items-center fs-7 fw-bold mb-2"><span class="">Your referer link</span></label>
            <div class="input-group mb-3">
                <input type="text" :value="referrerLink" class="form-control form-control-sm" readonly/>
                <span class="input-group-text fs-7"><Copy :text="referrerLink"/></span>
            </div>
        </div>
        <div class="row mb-5">
            <div class="col-md-6 fv-row">
                <label class="d-flex align-items-center fs-7 fw-bold mb-2"><span class="">Create custom short link</span></label>
                <div class="input-group mb-3" v-if="currentLink!==''">
                    <input type="text" class="form-control form-control-sm" :value="`/${currentLink}`" disabled/>
                    <span class="btn btn-sm btn-danger input-group-text fs-7" @click="handleDeleteShortLink">Delete</span>
                </div>
                <div class="input-group mb-3" v-else>
                    <input type="text" class="form-control form-control-sm" placeholder="Enter your short link" v-model="customLink" />
                    <span class="btn btn-sm btn-primary input-group-text fs-7" @click="handleCreateShortLink">Create</span>
                </div>
            </div>
            <div class="col-md-6 fv-row">
                <label class="d-flex align-items-center fs-7 fw-bold mb-2">
                    <span v-if="currentLink!==''">Current link</span>
                    <span v-else>Preview</span>
                </label>
                <div class="input-group mb-3" v-if="currentLink!==''">
                    <input class="form-control form-control-sm" :value="`https://icto.link/${currentLink}`" disabled />
                    <span class="btn btn-sm btn-secondary"><Copy :text="`https://icto.link/${currentLink}`"/></span>
                </div>
                <div class="input-group mb-3" v-else >
                    <input class="form-control form-control-sm" :value="`https://icto.link/${currentLink || '<NOT_REGISTERED>'}`" disabled />
                    <span class="btn btn-sm btn-secondary"><Copy /></span>
                </div>
            </div>
        </div>

    </div>
</template>

