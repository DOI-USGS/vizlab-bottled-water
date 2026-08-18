<template>
  <div>
    <WindowSize v-if="typeOfEnv === '-test build-'" />
    <HeaderUSWDSBanner v-if="typeOfEnv !== '-test build-'" />
    <HeaderUSGS />
    <WorkInProgressWarning v-if="typeOfEnv === '-beta build-'" />
    <!-- Uncomment during a lapse in government funding -->
    <!-- <ShutdownBanner /> -->
    <RouterView />
    <PreFooterCodeLinks />
    <FooterUSGS />
  </div>
</template>

<script setup>
  import { onMounted, onUnmounted } from "vue";
  import { RouterView } from 'vue-router'
  import WindowSize from "@/components/WindowSize.vue";
  import HeaderUSWDSBanner from "@/components/HeaderUSWDSBanner.vue";
  import HeaderUSGS from '@/components/HeaderUSGS.vue';
  import WorkInProgressWarning from "@/components/WorkInProgressWarning.vue";
  // Rendered only during a government shutdown - see the commented tag above
  import ShutdownBanner from "@/components/ShutdownBanner.vue";
  import PreFooterCodeLinks from "@/components/PreFooterCodeLinks.vue";
  import FooterUSGS from '@/components/FooterUSGS.vue';
  import { useWindowSizeStore } from '@/stores/WindowSizeStore';

  const windowSizeStore = useWindowSizeStore();
  const typeOfEnv = import.meta.env.VITE_APP_TIER;

  // Declare behavior on mounted
  onMounted(() => {
    // Add window size tracking by adding a listener
    window.addEventListener('resize', handleResize);
    handleResize();
  });

  onUnmounted(() => {
    window.removeEventListener('resize', handleResize);
  });

  // Functions
  function handleResize() {
    // store the window size values in the Pinia state
    windowSizeStore.windowWidth = window.innerWidth;
    windowSizeStore.windowHeight = window.innerHeight;
  }
</script>

<style scoped>
</style>
