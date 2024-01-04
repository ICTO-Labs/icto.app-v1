<script>
    import {copyToClipboard, showSuccess} from "@/utils/common.js";
    export default {
        props: ['text', 'item'],
        data(){
            return{
                isCopied: false
            }
        },
        methods: {
            async copyToClipboard(){
                // const textToCopy = this.$el.textContent;
                copyToClipboard(this.text, this.item);
                showSuccess("Copied")
            }
        }
    };

</script>
<template>
    <div @click="copyToClipboard" title="Click to Copy" class="clickToCopy text-hover-primary">
      <slot></slot>
    </div>
</template>
<style scoped>
    .clickToCopy{
        cursor: pointer;
    }
</style>