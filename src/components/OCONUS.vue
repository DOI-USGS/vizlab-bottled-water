<template>
  <section id="main-container">
    <section id="grid-container">
      <div id="title-container">
        <h2>Five droughts that changed history</h2>
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
#nav-button-container {
  grid-area: buttons;
  position: sticky;
  top: 0px;
  padding: 10px 0px 10px 0px;
  z-index: 20;
  background-color: white;
}
.scrollButton {
  padding: 3px 6px 4px 5px;
  margin-left: 5px;
  border: 0.5px solid darkgrey;
  font-weight: bold;
  border-radius: 3px;
  @media only screen and (max-width: 600px) {
    padding: 2px 4px 2px 3px;
    margin: 2px;
    border-radius: 4px;
  }
}
#button-1950s {
  margin-left: 0px;
}
.scrollButton:hover {
  border-color: darkgrey;
  font-weight: bold;
  @media only screen  and (max-width: 800px){
    border-color: white
  }
}
.scrollButton:focus {
  border: 0.5px solid darkgrey;
  font-weight: bold;
}
.scrollButton:active {
  border-color: darkgrey;
  font-weight: bold;
}
#inset-container {
  grid-area: chart;
  justify-self: end;
}
#inset-image-container {
  position: sticky;
  top: 55px;
  @media only screen and (max-width: 600px) {
    top: 75px;
  }
}
.inset-map {
  height: 150px;
  filter: url(#shadow2);
  @media only screen and (max-width: 600px) {
    height: 75px;
  }
}
.inset-map.default {
  position: sticky;
}
.inset-map.drought-specific {
  position: absolute;
  right: 0;
}
#chart-container {
  grid-area: chart;
}
#swarm_vertical {
  width: 100%;
  transform: rotate(180deg);
  pointer-events: none;
}
#chart-overlay-dynamic {
  grid-area: chart;
}
#chart-overlay-static {
  grid-area: chart;
  pointer-events: none;
}
// Class for paths in AI-generated annotation_drawings-01.svg
.cls-1 {
  fill: none;
  stroke: black;
  stroke-width: 1;
}
#annotation-container {
  //grid-area: chart; // places annotation-container in grid, on top of chart - blocks end of chart unless transition added
  //align-self: end; // places annotation-container in grid, on top of chart - blocks end of chart unless transition added
  height: 20vh;
  width: 100vw;
  padding: 20px 0 10px 0;
  position: sticky;
  justify-self: center;
  bottom: 0;
  background-color: white;
  opacity: 0.9;
  box-shadow: 0px -5px 5px #B9B9B9;
}
.reveal{
  position: relative;
  transform: translateY(21vh);
  opacity: 0;
  transition: 1s all ease;
}
.reveal.active {
  transform: translateY(0);
  opacity: 1;
}
.droughtText.mobile {
  margin: 0 5vw 0 5vw;
  position: absolute;
}
.droughtText.narration {
  margin: 0 5vw 0 5vw;
  position: absolute;
}
.hidden{
  visibility: hidden;
  opacity: 0;
  transition: visibility 0s 0.3s, opacity 0.3s linear;
}
.hiddenText{
  visibility: hidden;
  opacity: 0;
}
.visible{
  visibility: visible;
  opacity: 1;
  transition: opacity 0.3s linear;
}
.visibleText{
  visibility: visible;
  opacity: 1;
}
.hide {
  display: none;
}
.show {
  display: inline;
}
.currentButton {
  background-color: black;
  border-color: black;
  color: white;
}
.currentButton:hover {
  background-color: darkgrey;
  color: white;
}
#filter-svg {
  width: 0;
  height: 0;
}
.page-section {
  margin: auto;
  padding: 1em;
  max-width: 1200px;
}
#region-grid-container {
  display: grid;
  width: 100%;
  grid-template-columns: 80% 20%;
  grid-template-rows: minmax(30vh, 80vh) max-content;
  grid-template-areas:
    "radial violin"
    "description description"; 
  @media screen and (max-width: 600px) {
    padding: 5px 0 0px 0;
    //height: 100vh;
    grid-template-columns: 100%;
    grid-template-rows:  max-content max-content max-content 100vh ;
    grid-template-areas:
    "instructions"
    "map"
    "description"
    "violin"; 
  }
}
#radial-chart {
  grid-area: radial;
  place-self: center;
  max-height: 115%;
  max-width: 115%;
}
#region-map {
  grid-area: radial;
  place-self: center;
  margin-left: 0.5%; //nudges map right
  width: 6.5vw;
}
#casc-svg {
  max-height: 150px;
  grid-area: map;
  width: 100%;
  height: 100%;
}
#wedges-svg {
  grid-area: radial;
  place-self: center;
  display: flex;
  width: 115%;
  height: 115%;
}
.wedge path {
  stroke: none;
  fill: white;
  fill-opacity: 0;
}
#violin-container {
  grid-area: violin;
  position: relative;
  display: flex;
  justify-content: center;
  align-items: center;
}
.violin-chart {
  transform: rotate(180deg);
  position: absolute;
  max-height: 95%;
  max-width: 100%;
}
.regionText {
  grid-area: description;
}
.polarAxisText {
  pointer-events: none;
}
#chart-instructions {
  font-style: italic;
  @media screen and (max-width: 600px) {
    grid-area: instructions;
    align-self: start;
  }
}
.references-list{
  padding-left: 42px ;
  padding-top: 3px;
  padding-bottom: 7px;
  text-indent: -22px ;
}
#methods-container{
  display: grid;
  width: 100%;
  grid-template-columns: 50% 50%;
  grid-template-rows: auto;
  grid-template-areas:
    "methods1 image_grid1"
    "methods2 image_grid2"
    "methods3 image_grid3";
  @media screen and (max-width: 600px) {
    padding: 5px 0 0px 0;
    //height: 100vh;
    grid-template-columns: 100%;
    grid-template-rows:  auto ;
    grid-template-areas:
    "methods1" 
    "image_grid1"
    "methods2" 
    "image_grid2"
    "methods3" 
    "image_grid3";
  }
}
#explainer1 {
  grid-area: image_grid1;
}
#explainer2 {
  grid-area: image_grid2;
}
#explainer3 {
  grid-area: image_grid3;
}
.explainer_image{
  margin-left: auto;
  margin-right: auto;
  padding: 5px;
  width: 100%;
}
#methods1{
  grid-area: methods1;
}
#methods2{
  grid-area: methods2;
}
#methods3{
  grid-area: methods3;
}
.methods_text {
  padding: 1em 0 1em 0; 
  max-width: 700px;
}
#references-container {
  height: auto;
}
#authors-container {
  height: auto;
}
</style>
<style lang="scss">
.droughtText {
  z-index: 10;
  font-weight: 400;
  font-size: 1em;
  -webkit-user-select: none; /* Safari */
  -ms-user-select: none; /* IE 10 and IE 11 */
  user-select: none; /* Standard syntax */
}
.droughtText.mobile {
  z-index: 10;
  font-weight: 500;
  font-size: 1em;
}
.droughtText.quote {
  font-style: italic;
}
.droughtText.desktop.quote {
  text-shadow: 2px 4px 4px rgba(179,179,179,0.6);
}
.droughtText.desktop.quote:hover {
  font-style: italic;
  font-weight: 500;
}
.droughtTitle {
  font-weight: 700;
}
.yAxisText {
  font-size: 2em;
  @media only screen and (max-width: 600px) {
    font-size: 1.6em;
  }
}
.yAxisTick {
  stroke: #949494;
  stroke-width: 0.5;
}
.droughtCircle {
  stroke: #949494;
  stroke-width: 1;
  fill: #ffffff
}
.hidden{
  visibility: hidden;
  opacity: 0;
  transition: visibility 0s 0.3s, opacity 0.3s linear;
}
.visible{
  visibility: visible;
  opacity: 1;
  transition: opacity 0.3s linear;
}
.currentCircle {
  stroke: #000000;
  fill: #000000;
  transform-box:fill-box; 
  transform-origin: left;  
  transform:scale(1.1,1.1);
}
</style>