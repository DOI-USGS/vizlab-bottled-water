<template>
  <section id="water_source">
    <div id="grid-container-source">
      <div id="title">
        <h3> 
          Where are bottling facilities sourcing their water?
        </h3>
      </div>
      <div id="text">
        <div class="text-container">
          <p>
            Beverage-bottling facilities get water through public supply (water withdrawn by a water supplier and delivered to many users) or self-supply (water withdrawn from a private source for private use). In each case, the water can be sourced from several different pools of the water cycle, like groundwater, surface water, or springs. 
          </p>
        </div>
        <img src="../assets/images/public-supply_vs_self-supply.png">
        <div class="text-container">
          <p>
            Data on water sources by bottling facility are limited. [DATA RELEASE] et al. 2023 performed new mapping analyses to infer the source of water to bottling facilities. These analyses make some assumptions, like assuming that a facility near a well uses that well to source their water, and a facility within a public-supply zone uses public-supply water. Although this is an estimate, it improves the nations's understanding of where bottling facilities are sourcing their water. The charts below show the primary source of water for bottling facilities in each state. 
          </p>
        </div>
      </div>
      <div id="img-ws-national-types" class="img-container">
        <div class="text-container">
          <p>
            Where do different facility types source water?
          </p>
        </div>
        <img src="../assets/images/national_sources_facilities_sankey.png">
        <div class="text-container">
          <p>
            Water source percentage by facility type
          </p>
        </div>
        <img src="../assets/images/perc_expanded_self_supply_barplot.png">
        <div class="text-container">
          <p>
            Number of facilities with each source by facility type
          </p>
        </div>
        <img src="../assets/images/count_expanded_self_supply_barplot.png">
      </div>
      <div id="img-ws-bw-facet" class="img-container">
        <div class="text-container">
          <p>
            Let's look more closely at bottled water facilities specifically. Where do bottled water facilities in each state source water?
          </p>
        </div>
        <img src="../assets/images/state_sources_facet_Bottled Water_styled.png">
        <div class="text-container">
          <p>
            Digging even deeper, how does the source for bottled water facilities vary by county?
          </p>
        </div>
        <img src="../assets/images/map_perc_count_bottled_water_map.png">
      </div>
    </div>
  </section>
</template>
<script>
  import { isMobile } from 'mobile-device-detect';

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

  #grid-container-source {
      display: grid;
      grid-template-columns: 1fr;
      grid-template-rows: 0.5fr max-content max-content;
      grid-template-areas:
        "title"
        "text"
        "ws-national-types"
        "ws-bw-facet";
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
  #img-ws-national-types {
    grid-area: ws-national-types;
  }
  #img-ws-bw-facet {
    grid-area: ws-bw-facet;
  }
  .img-container {
    max-width: 100vw;
  }
  #text {
    grid-area: text;
    justify-self: start;
  }
  img {
    max-width: 900px;
  }
</style>