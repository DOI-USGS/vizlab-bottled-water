<template>
  <section id="water_source">
  <div id="grid-container">
        <div id="title">
            <h3> Where does bottled water come from?
            </h3>
        </div>
        <div class="text-container"><p>
          Beverage-bottling facilities get water through public supply (water withdrawn by a water supplier and delivered to many users) or self-supply (water withdrawn from a private source for private use). In each case, the water can come from several different pools of the water cycle, like groundwater, surface water, or springs. 
          </p>
        </div>
        <div class="text-container"> <p>
          Water source data are not readily available for most bottling facilities. [DATA RELEASE] et al. 2023 performed new mapping analyses to infer where facilities source their water from. These analyses make some assumptions, like assuming that a facility near a well uses that well to source their water, and a facility within a public-supply zone uses public-supply water. Though imperfect, these estimates improve our understanding of where bottling facilities are sourcing their water. The charts below show the primary sources of bottled water in each state. We have noted where these numbers are known from available data versus estimated using our analyses. 
        </p></div>
  </div>
</section>
</template>
<script>
import { isMobile } from 'mobile-device-detect';

export default {
  name: "WaterSource",
  components: {
    // Dropdown
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


#map-container {
    display: grid;
    grid-template-columns: 1fr 3fr;
    grid-template-rows: 0.5fr 3fr;
    grid-template-areas:
      "title title"
      "chart map";
    justify-content: center;
    margin: auto;
    max-width: 1600px;
    //height: 88vh;
}

#oconus-container {
    grid-area: map;
    align-self: center;
}

#chart-container {
    grid-area: chart;
    align-self: center;
}

#title {
    grid-area: title;
    align-self: center;
    font-size: 20px;
    font-family: sans-serif;
    //background-color: red;
}

.dropdown {
    font-size: 20px;
    /* display: flex;
    flex-direction: row;
    transition: width 2s, height 2s, transform 2s;
    will-change: width; */
}


</style>