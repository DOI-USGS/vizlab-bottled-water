<template>
  <section id="inventory_intro">
    <div id="grid-container-inventory">
      <OCONUS id="oconus" />
      <div
        id="text"
        class="text-container"
      >
        <p v-html="inventoryText.paragraph1" />
        <br>
        <p v-html="inventoryText.paragraph2" />
        <figure>
          <img
            class="pictogram"
            src="../assets/images/bottled-water_consumption-pictogram_less-text_20231016.png"
            alt="Pictogram showing 342 bottles of water with the text, “The average American drank 342 bottles of water in 2020.” Text below the pictogram reads, “Assuming standard, single-use bottles containing 16.9 oz (0.5 liter, or 0.132 gallons) of water. Bottled water consumption: https://bottledwater.org/bottled-water-consumption-shift/”"
          >
          <figcaption>
            Assuming standard, single-use bottles containing 16.9 oz (0.5 liter, or 0.132 gallons) of water. Bottled water consumption: <a href="https://bottledwater.org/bottled-water-consumption-shift/" target="_blank">https://bottledwater.org/bottled-water-consumption-shift/</a>
          </figcaption>
        </figure>
        <br>
        <p v-html="inventoryText.paragraph3" />
        <br>
        <p v-html="inventoryText.paragraph4" />
      </div>
    </div>
  </section>
</template>
<script>
import { isMobile } from 'mobile-device-detect';
import inventoryText from "./../assets/text/inventoryText.js";

export default {
  name: "InventorySection",
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
      
      inventoryText: inventoryText.inventoryText
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

  #inventory_intro {
    margin-top: 2rem;
    @media screen and (max-height: 770px) {
      margin-top: 5rem;
    }
    @media screen and (max-width: 600px) {
      margin-top: 0.2rem;
    }
  }
  #grid-container-inventory {
    display: grid;
    grid-template-columns: 1fr;
    grid-template-rows: 0.5fr max-content max-content;
    grid-template-areas:
        "oconus"
        "text";
    justify-content: center;
  }
  #oconus {
    grid-area: oconus;
  }
  #text {
    grid-area: text;
    justify-self: start;
  }
  .pictogram {      
    width: 98%;
    margin: 4rem 0rem 1.5rem 0rem;
    @media screen and (max-width: 600px) {
      margin: 2.5rem 0rem 1.5rem 0rem;
    }
  }
</style>