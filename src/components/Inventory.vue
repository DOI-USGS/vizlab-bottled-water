<template>
    <section id="inventory_intro">
        <div id="grid-container-inventory">
            <div id="title">
                <h3>
                    Where is water being bottled?
                </h3>
            </div>
            <br>
            <OCONUS id="oconus"/>
            <div id="text">
                <div class="text-container">
                    <p>
                        The bottled water industry estimates that the United States consumed 15 billion gallons (57 billion liters) of bottled water in 2020 (International Bottled Water Association). That's 45 gallons of bottled water per person. If you consider how much water it takes to produce each bottle of water (not including the packaging), the number is closer to 63 gallons—enough to fill a standard bathtub one-and-a-half times. 
                    </p>
                </div>
                <img src="../assets/images/bottled-water_consumption-pictogram_small_2023-09-08.png">
                <div class="text-container">
                    <p>
                        Despite what we know about bottled water consumption, data about how much water is taken from the environment for bottled water and other beverages are harder to come by. Reporting is highly, and some states do not permit public sharing of beverage-bottling data. Without these data, we can't measure the impact that bottled water has on the water cycle locally, regionally, or nationally.  
                    </p>
                </div>
                <div class="text-container">
                    <p>
                        To help fill this gap, the USGS Water Mission Area's Bottled Water Impacts project conducted an inventory of bottling facilities across the United States (LINK TO DATA RELEASE). The inventory helps answer the following questions:  
                    </p>
                </div>
                <div class="text-container">
                    <li>
                        How many beverage bottling facilities are there, and where are they located?
                    </li>
                    <li>
                        Where are these facilities sourcing their water (e.g., groundwater, spring water, public supply)?
                    </li>
                    <li>
                        How much water are bottling facilities using to make their products? 
                    </li>
                </div>
            </div>
        </div>
    </section>
</template>
<script>
import { isMobile } from 'mobile-device-detect';

export default {
  name: "Iventory",
  components: {
    OCONUS: () => import("./../components/OCONUS.vue"),
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

    #grid-container-inventory {
        display: grid;
        grid-template-columns: 1fr;
        grid-template-rows: 0.5fr max-content max-content;
        grid-template-areas:
            "title"
            "oconus"
            "text";
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
    #oconus {
        grid-area: oconus
    }
    #text {
        grid-area: text;
        justify-self: start;
    }
</style>