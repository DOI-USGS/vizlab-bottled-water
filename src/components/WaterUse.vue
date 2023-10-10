<template>
  <section id="water_use">
    <div id="grid-container-use">
      <div class="text-container">
        <h3 v-html="useText.title" />
      </div>
      <div id="text">
        <div class="text-container">
          <p v-html="useText.paragraph1" />
        </div>
      </div>
      <div id="img-wu-sites-map" class="img-container">
        <div class="text-container">
          <p v-html="useText.subtitle1" />
        </div>
        <img src="../assets/images/bottled_water_availability_map.png">
      </div>
      <div id="img-wu-sites-bar" class="img-container">
        <div class="text-container">
          <p v-html="useText.subtitle2" />
          <br>
          <p v-html="useText.paragraph2" />
        </div>
        <img src="../assets/images/water_use_data_availability_barplots.png">
      </div>
      <div class="img-bw-use-map">
        <div class="text-container">
          <p v-html="useText.paragraph3" />
        </div>
        <img src="../assets/images/annual_bottled_water_use_beeswarm.png">
      </div>
    </div>
  </section>
</template>
<script>
  import { isMobile } from 'mobile-device-detect';
  import waterUseText from "./../assets/text/waterUseText.js";

  export default {
    name: "WaterUse",
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
  $pal_red: '#FD5901';
  $pal_or: '#F78104';
  $pal_yell: '#FAAB36';
  $pal_teal: '#008083';
  $pal_blue_dark: '#042054';

  #grid-container-use {
    display: grid;
    grid-template-columns: 1fr;
    grid-template-rows: 0.5fr max-content max-content max-content max-content max-content;
    grid-template-areas:
      "title"
      "text"
      "wu-sites-map"
      "wu-sites-bar"
      "bw-use-map"
      "bw-use-source";
    justify-content: center;
    margin: auto;
    max-width: 1600px;
  }
  #title {
    grid-area: title;
    align-self: center;
    font-size: 20px;
    font-family: sans-serif;
  }
  #text {
    grid-area: text;
    justify-self: start;
  }
  #img-wu-sites-map {
    grid-area: wu-sites-map;
  }
  #img-wu-sites-bar {
    grid-area: wu-sites-bar;
  }
  #img-bw-use-map {
    grid-area: bw-use-map;
  }
  #img-bw-use-source {
    grid-area: bw-use-source;
  }
  .img-container {
    max-width: 100vw;
  }
</style>