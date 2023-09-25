<template>
  <section id="water_use">
    <div id="grid-container-use">
      <div id="title">
          <h3> 
            How much water are bottling facilities using?
          </h3>
      </div>
      <div id="text">
        <div class="text-container">
          <p>
            ORIGINAL: Water use data can be difficult to find for beverage-bottling facilities. Most states don't make these data publicly available, and some states even have laws prohibiting the sharing of these data. Because the data are limited, we can't make broad generalizations about the water usage of bottling facilities. However, we do have fairly comprehensive data for some facilities across the U.S. The charts below show how much data is available, and how the amount of water used in bottled water facilities varies by water source.  
          </p>
        </div>
        <div class="text-container">
          <p>
            ALTERNATIVE A: Acquiring water use data can be challenging.  Some states do not require reporting of some types of water use.  Other states require reporting to state or local agencies, but cannot share site-specific withdrawals.  For bottled water and other beverage facilities, the withdrawal amounts are sometimes below reporting thresholds, or the facilities purchase water from public supply systems, and those data are not available.  
          </p>
        </div>
        <div class="text-container">
          <p>
            ALTERNATIVE B: Available water use data are limited, but based on data for several states and facilities, we can start to see how water use for water bottling facilities varies by source.   [Note: we're only digging into water use for bottled water facilities here]
          </p>
        </div>
      </div>
      <div id="img-wu-sites-map" class="img-container">
        <div class="text-container">
          <p>
            For how many inventoried facilities does USGS have water use data?
          </p>
        </div>
        <img src="../assets/images/wu_sites.png">
      </div>
      <div id="img-wu-sites-bar" class="img-container">
        <div class="text-container">
          <p>
            For what porportion of bottled water facilities do we have water use data? Of the XX percent of facilities that have available water use data, about XX percent are bottled water facilities.  Of those XX bottled water facilities, XX percent of the withdrawals are from wells, XX percent are from public supply, XX percent are from springs, and XX percent are from a combination of different sources.
          </p>
        </div>
        <img src="../assets/images/wu_types_sources.png">
      </div>
      <div class="img-bw-use-map">
        <div class="text-container">
          <p>
            Among bottled water facilities with data, how much water is used, and how does that use vary by water source? This map shows [average annual values / values for the most recent year available] and is based on limited available data (Buchwald and others, 2023).
          </p>
        </div>
        <img src="../assets/images/wu_bw_use.png">
      </div>
    </div>
  </section>
</template>
<script>
  import { isMobile } from 'mobile-device-detect';

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