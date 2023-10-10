<template>
  <section id="water_source">
    <div class="text-container">
      <h3 v-html="sourceText.title" />
      <p v-html="sourceText.paragraph1" />
    </div>
    <div id="grid-container-illustration">
      <div id="illustration-public-supply" class="img-container">
        <img class="illustration" src="../assets/images/public-supply.png">
      </div>
      <div id="illustration-self-supply" class="img-container">
        <img class="illustration" src="../assets/images/self-supply.png">
      </div>
    </div>
    <div class="text-container">
      <p v-html="sourceText.paragraph2" />
      <br>
      <p v-html="sourceText.subtitle1" />
    </div>
    <div id="img-ws-national-types" class="img-container">
      <img src="../assets/images/perc_expanded_self_supply_barplot.png">
      <img src="../assets/images/count_expanded_self_supply_barplot.png">
    </div>
    <div class="text-container">
      <p v-html="sourceText.paragraph3" />
    </div>
    <div v-if="!mobileView" id="source-maps-container">
      <div id="source-count-percent" class="img-container">
        <img class="source-map" src="../assets/images/perc_count_bottled_water_map.png">
      </div>
    </div>
    <div v-if="mobileView" id="grid-container-source-maps">
      <div id="source-self-count" class="img-container">
        <img class="source-map" src="../assets/images/map_bottled_water_self_supply_count.png">
      </div>
      <div id="source-self-percent" class="img-container">
        <img class="source-map" src="../assets/images/map_bottled_water_self_supply_perc.png">
      </div>
      <div id="source-combo-count" class="img-container">
        <img class="source-map" src="../assets/images/map_bottled_water_combination_count.png">
      </div>
      <div id="source-combo-percent" class="img-container">
        <img class="source-map" src="../assets/images/map_bottled_water_combination_perc.png">
      </div>
      <div id="source-public-count" class="img-container">
        <img class="source-map" src="../assets/images/map_bottled_water_public_supply_count.png">
      </div>
      <div id="source-public-percent" class="img-container">
        <img class="source-map" src="../assets/images/map_bottled_water_public_supply_perc.png">
      </div>
    </div>
  </section>
</template>
<script>
  import { isMobile } from 'mobile-device-detect';
  import waterSourceText from "./../assets/text/waterSourceText.js";

  export default {
    name: "WaterSource",
    components: {
    },
    props: {
      data: Object
    },
    data() {
      return {
        selectedOption: 'all states and territories',
        dropdownOptions: [],

        d3: null,
        publicPath: import.meta.env.BASE_URL, // find the files when on different deployment roots
        mobileView: isMobile, // test for mobile
        
        sourceText: waterSourceText.waterSourceText
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
<style lang="scss">
  $pal_red: '#FD5901';
  $pal_or: '#F78104';
  $pal_yell: '#FAAB36';
  $pal_teal: '#008083';
  $pal_blue_dark: '#042054';

  #grid-container-illustration {
      display: grid;
      grid-template-columns: 1fr 1fr;
      grid-template-rows: max-content;
      grid-template-areas:
        "public-supply self-supply";
      justify-content: center;
      margin: auto;
      max-width: 1600px;
      @media screen and (max-width: 600px) {
        grid-template-columns: 1fr;
        grid-template-rows: max-content max-content;
        grid-template-areas:
          "public-supply"
          "self-supply";
      }
  }
  .img-container {
    max-width: 100vw;
  }
  #illustration-public-supply {
    grid-area: public-supply;
  }
  #illustration-self-supply {
    grid-area: self-supply;
  }
  img {
    max-width: 100%;
  }
  .illustration {
    max-width: 100%;
  }
  #grid-container-source-maps {
    display: grid;
    grid-template-columns: 1fr;
        grid-template-rows: max-content max-content max-content max-content max-content max-content;
        grid-template-areas:
        "count-self"
        "perc-self"
        "count-combo"
        "perc-combo"
        "count-public"
        "perc-public";
      justify-content: center;
      margin: auto;
      max-width: 1600px;
  }
  #source-self-count {
    grid-area: count-self;
  }
  #source-combo-count {
    grid-area: count-combo;
  }
  #source-public-count {
    grid-area: count-public;
  }
  #source-self-percent {
    grid-area: perc-self;
  }
  #source-combo-percent {
    grid-area: perc-combo;
  }
  #source-public-percent {
    grid-area: perc-public;
  }
  .source-map {
    max-width: 100%;
  }
</style>