<template>
  <section id="water_use">
  <div id="grid-container">
        <div id="title">
            <h3> How much water are bottling facilities using?
            </h3>
        </div>
        <div class="text-container"> <div class="text-container"><p>
          Water use data can be difficult to find for beverage-bottling facilities. Most states don’t make these data publicly available, and some states even have laws prohibiting the sharing of these data. Because the data are limited, we can’t make broad generalizations about the water usage of bottling facilities. However, we do have fairly comprehensive data from a few counties across the U.S. The charts below show how the amount of water used for bottling varies by the type of facility in each of these counties.  
        </p></div></div>
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