<script setup>
    import { ref, watch } from 'vue';
    import { showError } from '@/utils/common';
    const props = defineProps({
        initialUrls: {
            type: Array,
            default: () => []
        }
    });

    const emit = defineEmits(['update:urls']);

    const urls = ref(props.initialUrls);
    const newUrl = ref('');

    const isValidUrl = (url) => {
        try {
            new URL(url);
            return true;
        } catch (e) {
            return false;
        }
    };

    const addUrl = () => {
        if (newUrl.value && isValidUrl(newUrl.value)) {
            urls.value.push(newUrl.value);
            newUrl.value = '';
        }else{
            showError('Invalid URL');
        }
    };

    const removeUrl = (index) => {
        urls.value.splice(index, 1);
    };

    watch(urls, (newUrls) => {
        emit('update:urls', newUrls);
    }, { deep: true });
</script>

<template>
    <div class="row mb-3" v-for="(url, index) in urls" :key="index" >
        <div class="col-md-10">
            <input :value="url" readonly class="form-control form-control-sm " />
        </div>
        <div class="col-md-2">
            <button @click="removeUrl(index)" class="btn btn-danger btn-sm ms-2" type="button">Remove</button>
        </div>
    </div>
    <div class="row mb-5">
        <div class="col-md-10">
            <input v-model="newUrl" placeholder="Enter new URL of X (Twitter), Discord, Telegram, Github, Website..." class="form-control form-control-sm" />
        </div>
        <div class="col-md-2">
            <button @click="addUrl" class="btn btn-primary btn-sm ms-2" type="button">Add URL</button>
        </div>
    </div>
</template>