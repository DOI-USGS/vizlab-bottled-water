<template>
  <section id="water_use">
    <div id="grid-container-use">
      <div
        id="title"
        class="text-container"
      >
        <h3 v-html="useText.title" />
      </div>
      <div
        id="text1"
        class="text-container"
      >
        <p v-html="useText.paragraph1" />
      </div>
      <div
        id="img-infographic"
        class="img-container"
      >
        <img
          class="infographic"
          src="../assets/images/water-use_infographic.png"
        >
      </div>
    </div>
  </section>
</template>
<script>
  import { isMobile } from 'mobile-device-detect';
  import waterUseText from "./../assets/text/waterUseText.js";

  export default {
    name: "WaterUseSection",
    components: {
    },
    props: {
      data: Object
    },
    data() {
      return {

        publicPath: import.meta.env.BASE_URL, // find the files when on different deployment roots
        mobileView: isMobile, // test for mobile
        
        useText: waterUseText.waterUseText
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

  #grid-container-use {
    display: grid;
    grid-template-columns: 1fr;
    grid-template-rows: 0.5fr max-content max-content max-content;
    grid-template-areas:
      "title"
      "text1";
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
  #img-infographic {
    text-align: center;
    margin: 4rem 0rem 4rem 0rem;
  }
  .infographic {
    width: 60%;
    margin: auto;
    @media screen and (max-height: 770px) {
      width: 65%;
    }
    @media screen and (max-width: 600px) {
      width: 100%;
    }
  }
</style>