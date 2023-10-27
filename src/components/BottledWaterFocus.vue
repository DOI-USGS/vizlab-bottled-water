<template>
  <section id="bottled_water_focus">
    <div id="grid-container-bw">
      <div
        id="title"
        class="text-container"
      >
        <h3 v-html="bottledWaterFocusText.title" />
      </div>
      <div
        id="text1"
        class="text-container"
      >
        <p v-html="bottledWaterFocusText.paragraph1" />
      </div>
      <div
        id="text2"
        class="text-container"
      >
        <p v-html="bottledWaterFocusText.paragraph2" />
      </div>
      <div
        id="grid-container-source-maps"
      >
        <div
          id="source-map-title-self"
          class="text-container map-title-container"
        >
          <p class="viz-emph">
            Self-supply
          </p>
        </div>
        <div
          id="img-source-self-count"
          class="img-container"
        >
          <img
            class="source-map"
            src="../assets/images/map_bottled_water_Self-supply_count.png"
            alt="CONUS, county level proportional symbols map, binned into five categories: 25, 50, 100, 300, and 600, show counts of bottled water facilities that source water from self-supply. Generally, many counties across Texas, Florida, California, and Colorado display the greatest count of self-supply facilities. The top three counties with the greatest number of self-supply sourcing facilities include Harris County, Texas (33), Palm Beach County (14) and Lee County, Florida (14)."
          >
        </div>
        <div
          id="img-source-self-percent"
          class="img-container"
        >
          <img
            class="source-map"
            src="../assets/images/map_bottled_water_Self-supply_perc.png"
            alt="CONUS, county level choropleth map, binned into five categories: 1, 25, 50, 75, and 100%, show percents of bottled water facilities that source water from self-supply. Generally, many counties across the Eastern, South Central, and Western United States display the greatest percent of facilities that source from self-supply."
          >
        </div>
        <div
          id="source-map-title-combo"
          class="text-container map-title-container"
        >
          <p class="viz-emph">
            Combination
          </p>
        </div>
        <div
          id="img-source-combo-count"
          class="img-container"
        >
          <img
            class="source-map"
            src="../assets/images/map_bottled_water_combination_count.png"
            alt="CONUS, county level proportional symbols map, binned into five categories: 25, 50, 100, 300, and 600, show counts of bottled water facilities that source water from self-supply. Massachusetts, California, New York, and Illinois lead in the number of facilities that source from combination. The top three counties with the greatest number of combination sourcing facilities include Middlesex County, Massachusetts (21), Los Angeles County, California (20), and San Diego County, California (18)."
          >
        </div>
        <div
          id="img-source-combo-percent"
          class="img-container"
        >
          <img
            class="source-map"
            src="../assets/images/map_bottled_water_combination_perc.png"
            alt="CONUS, county level choropleth map, binned into five categories: 1, 25, 50, 75, and 100%, show percents of bottled water facilities that source water from combination. A large portion of counties in the Midwest and Eastern United States have the highest percentage of facilities utilizing combination sources for their water supply."
          >
        </div>
        <div
          id="source-map-title-public"
          class="text-container map-title-container"
        >
          <p class="viz-emph">
            Public supply
          </p>
        </div>
        <div
          id="img-source-public-count"
          class="img-container"
        >
          <img
            class="source-map"
            src="../assets/images/map_bottled_water_public_supply_count.png"
            alt="CONUS, county level proportional symbols map, binned into five categories: 25, 50, 100, 300, and 600, show counts of bottled water facilities that source water from public supply. Largely, California, Texas, and Florida lead in the number of facilities that source from public supply. The top three counties with the greatest number of public supply sourcing facilities include Los Angeles County, California (679), Orange County, California (259), and San Diego County, California (165)."
          >
        </div>
        <div
          id="source-public-percent"
          class="img-container"
        >
          <img
            class="source-map"
            src="../assets/images/map_bottled_water_public_supply_perc.png"
            alt="CONUS, county level choropleth map, binned into five categories: 1, 25, 50, 75, and 100%, show percents of bottled water facilities that source water from public supply. Many counties in the Western and Southwestern United States shows the highest percentage of facilities that obtain their water from public supply sources"
          >
        </div>
      </div>
      <div
        id="text3"
        class="text-container"
      >
        <p v-html="bottledWaterFocusText.paragraph3" />
      </div>
      <div
        id="img-infographic-bw"
        class="img-container"
      >
        <img
          class="infographic-bw"
          src="../assets/images/bottled_water_use_infographic.png"
          v-if="!mobileView"
        >
        <img
          class="infographic-bw"
          src="../assets/images/bottled_water_use_infographic_top.png"
          v-if="mobileView"
        >
        <img
          class="infographic-bw"
          src="../assets/images/bottled_water_use_infographic_bottom.png"
          v-if="mobileView"
        >
      </div>
      <div
        id="text4"
        class="text-container"
      >
        <p v-html="bottledWaterFocusText.paragraph4" />
      </div>
      <div
        id="img-bw-use-beeswarm"
        class="img-container"
      >
        <img
          v-if="!mobileView"
          class="beeswarm"
          src="../assets/images/annual_bottled_water_use_beeswarm.png"
          alt="Beeswarm plot displays average annual water use, in million gallons per day (MGD), by bottled water facilities across water sources. Generally, many combination and spring sources display average annual water use less than or equal to 0.1 MGD. In contrast, combination and well sources display the greatest average annual water use greater than 1.0 MGD."
        >
        <img
          v-if="mobileView"
          class="beeswarm"
          src="../assets/images/annual_bottled_water_use_beeswarm_mobile.png"
          alt="Beeswarm plot displays average annual water use, in million gallons per day (MGD), by bottled water facilities across water sources. Generally, many combination and spring sources display average annual water use less than or equal to 0.1 MGD. In contrast, combination and well sources display the greatest average annual water use greater than 1.0 MGD."
        >
      </div>
      <div
        id="text5"
        class="text-container"
      >
        <p v-html="bottledWaterFocusText.paragraph5" />
      </div>
    </div>
  </section>
</template>
<script>
  import { isMobile } from 'mobile-device-detect';
  import bottledWaterFocusText from "./../assets/text/bottledWaterFocusText.js";

  export default {
    name: "BottledWaterFocusSection",
    components: {
    },
    props: {
      data: Object
    },
    data() {
      return {

        publicPath: import.meta.env.BASE_URL, // find the files when on different deployment roots
        mobileView: isMobile, // test for mobile

        bottledWaterFocusText: bottledWaterFocusText.bottledWaterFocusText
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

  #grid-container-bw {
    display: grid;
    grid-template-columns: 1fr;
    grid-template-rows: 0.5fr max-content max-content max-content;
    grid-template-areas:
      "title"
      "text1"
      "text2"
      "source-maps"
      "text3"
      "img-infographic-bw"
      "text4"
      "bw-use-source"
      "text5";
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
  #text2 {
    grid-area: text2;
    justify-self: start;
  }
  #text3 {
    grid-area: text3;
    justify-self: start;
  }
  #text4 {
    grid-area: text4;
    justify-self: start;
  }
  #text5 {
    grid-area: text5;
    justify-self: start;
  }
  #img-bw-use-beeswarm {
    grid-area: bw-use-source;
  }
  .beeswarm {
    width: 90%;
    max-width: 1200px;
  }
  #grid-container-source-maps {
    grid-area: source-maps;
    display: grid;
    grid-template-columns: 1fr 1fr;
    grid-template-rows: max-content max-content max-content max-content;
    grid-template-areas:
      "title-self title-self"
      "count-self perc-self"
      "title-combo title-combo"
      "count-combo perc-combo"
      "title-public title-public"
      "count-public perc-public";
    justify-content: center;
    align-content: center;
    margin: 1rem auto 2rem auto;
    max-width: 1400px;
    @media screen and (max-width: 600px) {
      grid-template-columns: 1fr;
      grid-template-rows: max-content max-content max-content max-content max-content max-content max-content;
      grid-template-areas:
        "title-self"
        "count-self"
        "perc-self"
        "title-combo"
        "count-combo"
        "perc-combo"
        "title-public"
        "count-public"
        "perc-public";
      margin: 0rem auto 3rem auto;
    }
  }
  .map-title-container {
    text-align: center;
    margin-top: 2rem;
  }
  #source-map-title-self {
    grid-area: title-self;
  }
  #source-map-title-combo {
    grid-area: title-combo;
  }
  #source-map-title-public {
    grid-area: title-public;
  }
  #img-source-self-count {
    grid-area: count-self;
  }
  #img-source-combo-count {
    grid-area: count-combo;
  }
  #img-source-public-count {
    grid-area: count-public;
  }
  #img-source-self-percent {
    grid-area: perc-self;
  }
  #img-source-combo-percent {
    grid-area: perc-combo;
  }
  #img-source-public-percent {
    grid-area: perc-public;
  }
  .source-map {
    max-width: 90%;
    @media screen and (max-width: 600px) {
      max-width: 100%;
    }
  }
  #img-infographic-bw {
    text-align: center;
    margin: 4rem 0rem 4rem 0rem;
    @media screen and (max-width: 600px) {
      margin: 3rem 0rem 3rem 0rem;
    }
  }
  .infographic-bw {
    width: 60%;
    margin: auto;
    @media screen and (max-height: 770px) {
      width: 65%;
    }
    @media screen and (max-width: 600px) {
      width: 90%;
    }
  }
</style>
