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
        <p v-html="useText.paragraph1" />
      </div>
      <div
        id="img-infographic-wu"
        class="img-container"
      >
        <img
          v-if="!mobileView"  
          class="infographic-wu"
          src="../assets/images/water-use_infographic.webp"
          alt="Infographic explaining the low availability of water use data for beverage bottling facilities. A map of the conterminous United States shows the locations of bottling facilities with available water use data in blue and bottling facilities without available water use data in gray. A bar chart to the right of the map shows the percentage of facilities for which USGS was able to acquire water use data in blue, and percentage of facilities without available water use data in gray. Text at the bottom points to the bar chart and reads, “USGS acquired water use data for 0.6% of beverage bottling facilities.”"
        >
        <img
          v-if="mobileView"  
          class="infographic-wu"
          src="../assets/images/water-use_infographic_mobile.webp"
          alt="Infographic explaining the low availability of water use data for beverage bottling facilities. A map of the conterminous United States shows the locations of bottling facilities with available water use data in blue and bottling facilities without available water use data in gray. A bar chart to the right of the map shows the percentage of facilities for which USGS was able to acquire water use data in blue, and percentage of facilities without available water use data in gray. Text at the bottom points to the bar chart and reads, “USGS acquired water use data for 0.6% of beverage bottling facilities.”"
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
    grid-template-rows: 0.5fr max-content max-content max-content;
    grid-template-areas:
      "title"
      "text1"
      "img-infographic-wu";
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
  #img-infographic-wu {
    text-align: center;
    margin: 4rem 0rem 0.5rem 0rem;
  }
  .infographic-wu {
    width: 60%;
    margin: auto;
    @media screen and (max-height: 770px) {
      width: 65%;
    }
    @media screen and (max-width: 600px) {
      width: 95%;
    }
  }
</style>