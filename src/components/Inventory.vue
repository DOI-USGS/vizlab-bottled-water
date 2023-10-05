<template>
    <section id="inventory_intro">
        <div id="grid-container-inventory">
            <div id="title">
               <h3 v-html="inventoryText.title" />
            </div>
            <br>
            <OCONUS id="oconus"/>
            <div id="text" class="text-container">
               <p v-html="inventoryText.paragraph1" />
               <br>
               <img class='image-float' src="../assets/images/bottled-water_consumption-pictogram_small_2023-09-19.png">
               <p v-html="inventoryText.paragraph2" />
               <br>
               <p v-html="inventoryText.paragraph3" />
               <br>
               <p v-html="inventoryText.paragraph4" />
               <br>
               <li v-html="inventoryText.bullet1" />
               <li v-html="inventoryText.bullet2" />
               <li v-html="inventoryText.bullet3" />
            </div>
        </div>
    </section>
</template>
<script>
import { isMobile } from 'mobile-device-detect';
import inventoryText from "./../assets/text/inventoryText.js";

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
    .image-float {
        float: right;
        width: 50vw;
        max-width: 1000px;
        margin: 0px 0px 1rem 1rem;
    }
</style>