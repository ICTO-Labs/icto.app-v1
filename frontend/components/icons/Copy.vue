<script>
    import {copyToClipboard} from "@/utils/common.js";
    export default {
        props: ['text', 'item'],
        data(){
            return{
                isCopied: false
            }
        },
        methods: {
            async copyToClipboard(){
                copyToClipboard(this.text, this.item);
                this.changeCopyBtn();
            },
            changeCopyBtn(){
                this.isCopied = true;
                setInterval(()=>{
                    this.isCopied = false;
                }, 3000)
            }
        }
    };

</script>
<template>
    <em class="copy fas fa-copy" v-if="!isCopied" href="javascript:void(0)" @click.stop="copyToClipboard('1', 'Canister ID')" title="Copy"></em>
    <em v-else  class="fas fa-check text-success"></em>
</template>
<style>
    .copy{
        cursor: pointer;
        font-size: 12px;
    }
    .copy:hover{
        color: #009ef7;
    }
</style>