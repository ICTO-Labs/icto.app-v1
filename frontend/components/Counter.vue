<script setup>
import { useCanister } from "@connect2ic/vue"
import { ref, watchEffect } from "vue"
import { Principal } from "@dfinity/principal";
let count = ref()
const [backend] = useCanister("backend")

const refreshCounter = async () => {
  console.log('refreshing...')
  const freshCount = await backend.value.getValue()
  console.log('Refresh: ', freshCount)
  count.value = freshCount
}


const increment = async () => {
  console.log('start: ', backend)
  await backend.value.increment()
  await refreshCounter()
  console.log('done')
}

const whoami = async ()=>{
  const me = await backend.value.whoami()
  console.log('ok, me: ', Principal.fromUint8Array(me._arr).toText())
}

watchEffect(() => {
  if (backend.value) {
    refreshCounter()
  }
})

</script>
<template>
  <div class="example">
    <p style="font-size: 2.5em">{{ count?.toString() }}</p>
    <button class="connect-button" @click="increment">+</button>
    <button class="connect-button" @click="whoami">Check</button>
  </div>
</template>
