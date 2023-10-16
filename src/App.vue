<template>
  <div id="app">
    <WindowSize v-if="checkTypeOfEnv === '-test build-'" />
    <HeaderUSGS
      ref="headerUSGS"
    />
    <InternetExplorerPage v-if="isInternetExplorer" />
    <!-- an empty string in this case means the 'prod' version of the application   -->
    <router-view
      v-if="!isInternetExplorer"
    /> 
    <PreFooterCodeLinks v-if="!isInternetExplorer" />
    <!-- PreFooterVisualizationsLinks v-if="!isInternetExplorer" / -->
    <FooterUSGS />
  </div>
</template>

<script>
    import WindowSize from "./components/WindowSize.vue";
    import HeaderUSGS from './components/HeaderUSGS.vue';
    import { isMobile } from 'mobile-device-detect';
    export default {
        name: 'App',
        components: {
            WindowSize,
            HeaderUSGS,
            InternetExplorerPage: () => import( "./components/InternetExplorerPage.vue"),
            PreFooterCodeLinks: () => import(  "./components/PreFooterCodeLinks.vue"),
            FooterUSGS: () => import(  "./components/FooterUSGS.vue") 
        },
        data() {
            return {
                isInternetExplorer: false,
                title: import.meta.env.VITE_APP_TITLE,
                publicPath: import.meta.env.BASE_URL, // this is need for the data files in the public folder
                mobileView: isMobile,
            }
        },
        computed: {
          checkTypeOfEnv() {
              return import.meta.env.VITE_APP_TIER
          },
          windowWidth: function() {
            return this.$store.state.windowWidth
          },
          windowHeight: function () {
              return this.$store.state.windowHeight
          }
        },
        mounted(){
       
        },
        created() {
            // We do not support for Internet Explorer. This tests if the browser used is IE.
            this.$browserDetect.isIE ? this.isInternetExplorer = true : this.isInternetExplorer = false;
            // Add window size tracking by adding a listener and a way to store the values in the Vuex state
            window.addEventListener('resize', this.handleResize);
            this.handleResize();
        },
        destroyed() {
            window.removeEventListener('resize', this.handleResize);
        },
        methods:{
          handleResize() {
                this.$store.commit('recordWindowWidth', window.innerWidth);
                this.$store.commit('recordWindowHeight', window.innerHeight);
            },
          
        }
    }
</script>

<style lang="scss">
  // Fonts
  @import url('https://fonts.googleapis.com/css2?family=Source+Sans+Pro:wght@200;300;400;500;600;700;800&display=swap');
  @import url('https://fonts.googleapis.com/css2?family=Averia+Sans+Libre:ital,wght@300;400;700&display=swap');
  @import url('https://fonts.googleapis.com/css2?family=Gloria+Hallelujah&display=swap');
  $SourceSans: 'Source Sans Pro', sans-serif;
  $AveriaSansLibre: 'Averia Sans Libre';
  $GloriaHallelujah: 'Gloria Hallelujah';
  $textcolor: rgb(21, 21, 21);

  $pale_blue: #F5FAFC;

  // whole page except header fit within viewport - no scrolling
  #app {
    width: 100%;
    height: calc(100vh + 85.7px); //85.7 is the height of the USGS header
  }

  // Type
  html,
  :root {
    font-size: 62.5%;
  }
  body {
    height: 100%;
    background-color: #ffffff;
    margin: 0;
    padding: 0;
    line-height: 1.2;
    font-size: 2rem;
    font-weight: 400;
    -webkit-font-smoothing: antialiased;
    -moz-osx-font-smoothing: grayscale;
    width: 100%;
    @media screen and (max-width: 600px) {
      font-size: 1.6rem;
    }
  }
  h1{
    font-size: 7rem;
    font-weight: 700;
    font-family: $AveriaSansLibre;
    line-height: 13rem;
    text-align: left;
    color: $textcolor;
    // text-shadow: 0.1rem 0.1rem 10rem rgba(0,0,0,.8);
    @media screen and (max-height: 770px) {
      font-size: 5.5rem;
      line-height: 10rem;
    }
    @media screen and (max-width: 600px) {
      font-size: 4rem;
      line-height: 7rem;
    }
  }
  h2{
    font-weight: 700;
    text-align: left;
    font-family: $SourceSans;
    font-size: 5rem;
    color: $textcolor;
    margin-top: 0.5rem;
    line-height: 1.2;
    @media screen and (max-width: 600px) {
      font-size: 3rem;
    }
  }
  h3{
    font-size: 3rem;
    padding-top: 1rem;
    padding-bottom: 1rem;
    font-family: $SourceSans;
    font-weight: 700;
    color: $textcolor;
    @media screen and (max-height: 770px) {
      font-size: 3rem;
    }
    @media screen and (max-width: 600px) {
        font-size: 2rem;
    }  
  }
  h4{
    font-size: 2.5rem;
    padding-top: 0em;
    padding-bottom: .25em;
    font-family: $SourceSans;
    font-weight: 700;
    color: $textcolor;
    @media screen and (max-width: 600px) {
      font-size: 2rem;
    }  
  }
  p, text, li {
    // padding: 1em 0 0 0; 
    font-family: $SourceSans;
    color: $textcolor;
  }
  li {
    margin-left: 1rem;
    padding-bottom: 0.5rem;
  }
  input[type=button] {
    font-family: $SourceSans;
  }

  // General Layout  
  .text-container {
    min-width: 30vw;
    max-width: 90vw;
    // margin: 0 auto;
    padding: 1rem 1rem 1rem 0rem;   
    left:0;
    @media screen and (max-width: 600px) {
      max-width: 95vw;
      padding: 0.5rem;
    }  
  }
  .flex-container {
    display: flex;
    flex-wrap: wrap;
    align-items: flex-start;
    justify-content: space-evenly;
    align-content: space-around;
    max-width: 30%;
    margin: auto;
    @media screen and (max-width: 600px) {
        max-width: 100%;
    }
  }
  .flex-item {
    padding: 2rem;
    min-width: 40rem;
    flex: 0 0 auto;
    align-self: center;
  }
  @media (max-width: 600px) {
    .flex-container {
      flex-direction: column;
    }
    .flex-item {
      flex: none;
      padding: 0 0 1em 0;
      height: 100%;
    }
  }
  .figure-content {
    border: 0.1rem white;
    display: flex;
    flex-wrap: wrap;
    align-items: flex-start;
    justify-content: space-evenly;
    align-content: space-around;
    max-width: 100%;
    margin: auto;
    @media screen and (max-width: 600px) {
        padding: 0rem; 
    }
  }
  .legend-text {
      fill: black;
      font-family: $SourceSans;
      font-size: 1.6rem;
    }
  .viz-comment {
    font-family: $GloriaHallelujah;
    font-size: 1.8rem;
    @media screen and (max-width: 600px) {
      font-size: 1.6rem;
    }
  }
  .viz-emph {
    font-weight:700;
    fill: white;
    font-family: $SourceSans;
    font-size: 2rem;
  }
  .emph {
    font-weight: bold;
  }
  .italic {
    font-style: italic;
  }
  .pseudo-caption {
    font-size: 1.6rem;
    margin: 0 1rem;
  }
  // Link Styling

  sup {
    opacity: .4;
  }
  .sticky-header {
    position: fixed;
    top: 0;
    left: 0;
    width: 100vw;
  }
</style>
