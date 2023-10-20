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
        id="img-bw-use-beeswarm"
        class="img-container"
      >
        <img
          v-if="!mobileView"
          class="beeswarm"
          src="../assets/images/annual_bottled_water_use_beeswarm.png"
        >
        <img
          v-if="mobileView"
          class="beeswarm"
          src="../assets/images/annual_bottled_water_use_beeswarm_mobile.png"
        >
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
            src="../assets/images/map_bottled_water_self_supply_count.png"
          >
        </div>
        <div
          id="img-source-self-percent"
          class="img-container"
        >
          <img
            class="source-map"
            src="../assets/images/map_bottled_water_self_supply_perc.png"
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
          >
        </div>
        <div
          id="img-source-combo-percent"
          class="img-container"
        >
          <img
            class="source-map"
            src="../assets/images/map_bottled_water_combination_perc.png"
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
          >
        </div>
        <div
          id="source-public-percent"
          class="img-container"
        >
          <img
            class="source-map"
            src="../assets/images/map_bottled_water_public_supply_perc.png"
          >
        </div>
      </div>
      <div
        id="text3"
        class="text-container"
      >
        <p v-html="bottledWaterFocusText.paragraph3" />
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
      "bw-use-source"
      "text2"
      "source-maps"
      "text3";
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
  max-width: 1600px;
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
</style>