<template>
  <section id="main-container">
    <section id="grid-container">
      <div id="title-container">
        <h2>Bottled water facilities across the United States</h2>
      </div>
      <div id="intro-container"></div>
    </section>
  </section>
</template>
<script>
import * as d3Base from 'd3';
import { isMobile } from 'mobile-device-detect';
export default {
  name: "OCONUS",
    components: {

    },
    props: {
    },
    data() {
      return {
        d3: null,
        publicPath: process.env.BASE_URL, // find the files when on different deployment roots
        mobileView: isMobile, // test for mobile
       
      }
  },
  mounted(){      
    this.d3 = Object.assign(d3Base);
 
  },
    methods:{
      isMobile() {
              if(/Android|webOS|iPhone|iPad|iPod|BlackBerry|IEMobile|Opera Mini/i.test(navigator.userAgent)) {
                  return true
              } else {
                  return false
              }
      },
    }
}
</script>
<style scoped lang="scss">
// handwriting font
@import url('https://fonts.googleapis.com/css2?family=Nanum+Pen+Script&display=swap');
$writeFont: 'Nanum Pen Script', cursive;

#grid-container {
  display: grid;
  padding: 20px 0 20px 0;
  gap: 5px;
  grid-template-columns: 100%;
  grid-template-rows: max-content max-content max-content max-content;
  grid-template-areas:
    "title"
    "intro"
    "buttons"
    "chart";
  justify-content: center;
  margin: auto;
  max-width: 90vw;
  min-width: 90vw;
}
#title-container {
  grid-area: title;
}
#intro-container {
  grid-area: intro;
  padding-left: 5px;
}


</style>