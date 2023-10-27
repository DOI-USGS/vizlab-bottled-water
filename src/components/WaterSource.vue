<template>
  <section id="water_source">
    <div id="grid-container-source">
      <div
        id="title"
        class="text-container"
      >
        <h3 v-html="sourceText.title" />
      </div>
      <div
        id="text1"
        class="text-container"
      >
        <p v-html="sourceText.paragraph1" />
      </div>
      <div id="grid-container-illustration">
        <div
          id="img-illustration-public-supply"
          class="img-container"
        >
          <img
            class="illustration"
            src="../assets/images/public-supply.png"
          >
        </div>
        <div
          id="img-illustration-self-supply"
          class="img-container"
        >
          <img
            class="illustration"
            src="../assets/images/self-supply.png"
          >
        </div>
      </div>
      <div
        id="text2"
        class="text-container"
      >
        <p v-html="sourceText.paragraph2" />
      </div>
      <sourceBarplots id="source-barplots" />
    </div>
  </section>
</template>
<script>
  import { isMobile } from 'mobile-device-detect';
  import waterSourceText from "./../assets/text/waterSourceText.js";

  export default {
    name: "WaterSourceSection",
    components: {
      sourceBarplots: () => import("./../components/SourceBarplots.vue"),
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

  #grid-container-source {
    display: grid;
    grid-template-columns: 1fr;
    grid-template-rows: 0.5fr max-content max-content max-content max-content;
    grid-template-areas:
      "title"
      "text1"
      "illustration"
      "text2"
      "source-bars";
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
  #source-barplots {
    grid-area: source-bars;
  }
  #grid-container-illustration {
    grid-area: illustration;
    display: grid;
    grid-template-columns: 1fr 1fr;
    grid-template-rows: max-content;
    grid-template-areas:
      "public-supply self-supply";
    justify-content: center;
    margin: 4rem auto 4rem auto;
    max-width: 1400px;
    @media screen and (max-width: 600px) {
      grid-template-columns: 1fr;
      grid-template-rows: max-content max-content;
      row-gap: 2rem;
      grid-template-areas:
        "public-supply"
        "self-supply";
    }
  }
  #img-illustration-public-supply {
    grid-area: public-supply;
  }
  #img-illustration-self-supply {
    grid-area: self-supply;
  }
  .illustration {
    width: 90%;
  }
</style>