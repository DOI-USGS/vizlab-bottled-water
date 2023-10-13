<template>
  <section id="water_use">
    <div id="grid-container-use">
      <div
        id="title"
        class="text-container"
      >
        <h3 v-html="useText.title" />
      </div>
      <div
        id="text1"
        class="text-container"
      >
        <img
          :class="mobileView ? 'availability-map img-mobile' : 'availability-map image-float'"
          src="../assets/images/bottled_water_availability_map.png"
        >
        <p v-html="useText.paragraph1" />
        <br>
        <p v-html="useText.paragraph2" />
      </div>
      <div
        id="img-wu-bars"
        class="img-container"
      >
        <img src="../assets/images/water_use_data_availability_barplots.png">
      </div>
      <div
        id="text2"
        class="text-container"
      >
        <p v-html="useText.paragraph3" />
      </div>
      <div
        id="img-bw-use-beeswarm"
        class="img-container"
      >
        <img
          v-if="!mobileView"
          src="../assets/images/annual_bottled_water_use_beeswarm.png"
        >
        <img
          v-if="mobileView"
          src="../assets/images/annual_bottled_water_use_beeswarm_mobile.png"
        >
      </div>
    </div>
  </section>
</template>
<script>
  import { isMobile } from 'mobile-device-detect';
  import waterUseText from "./../assets/text/waterUseText.js";

  export default {
    name: "WaterUseSection",
    components: {
    },
    props: {
      data: Object
    },
    data() {
      return {

        publicPath: import.meta.env.BASE_URL, // find the files when on different deployment roots
        mobileView: isMobile, // test for mobile
        
        useText: waterUseText.waterUseText
      }
    },
    mounted(){      
      const self = this;
    },
    methods:{
      isMobile() {
              if(/Android|webOS|iPhone|iPad|iPod|BlackBerry|IEMobile|Opera Mini/i.test(navigator.userAgent)) {
                  return true
              } else {
                  return false
              }
      }
    }
  }
</script>
<style scoped lang="scss">

  #grid-container-use {
    display: grid;
    grid-template-columns: 1fr;
    grid-template-rows: 0.5fr max-content max-content max-content max-content;
    grid-template-areas:
      "title"
      "text1"
      "use-bars"
      "text2"
      "bw-use-source";
    justify-content: center;
  }
  #title {
    grid-area: title;
    justify-self: start;
  }
  #text1 {
    grid-area: text1;
    justify-self: start;
  }
  #img-wu-bars {
    grid-area: use-bars;
  }
  #img-bw-use-beeswarm {
    grid-area: bw-use-source;
  }
  .img-container {
    max-width: 100vw;
  }
  .availability-map {    
    width: 60vw;
    max-width: 1000px;
    margin: 0rem 0rem 0rem 0rem;
  }
  .availability-map.img-mobile {
    width: 100%;
    margin: 0;
  }
</style>