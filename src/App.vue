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
@import url('https://fonts.googleapis.com/css2?family=Roboto+Mono:ital,wght@0,100;0,200;0,300;0,400;0,500;0,600;0,700;1,100;1,200;1,300;1,400;1,600;1,700&display=swap');
$SourceSans: 'Source Sans Pro', sans-serif;
$Roboto: 'Roboto Mono';
$textcolor: rgb(21, 21, 21);

$pal_red: '#FD5901';
$pal_or: '#F78104';
$pal_yell: '#FAAB36';
$pal_teal: '#008083';
$pal_blue_dark: '#042054';

@import url('https://fonts.googleapis.com/css2?family=Nanum+Pen+Script&display=swap');
$writeFont: 'Nanum Pen Script', cursive;
// whole page except header fit within viewport - no scrolling
#app {
  width: 100%;
  height: calc(100vh + 85.7px); //85.7 is the height of the USGS header
}

// Type
html,
body {
      height: 100%;
      background-color: $pal_or;
      margin: 0;
      padding: 0;
      line-height: 1.2;
      font-size: 20px;
      font-weight: 400;
      -webkit-font-smoothing: antialiased;
      -moz-osx-font-smoothing: grayscale;
      width: 100%;
      @media screen and (max-width: 600px) {
        font-size: 16px;
      }
  }
h1{
  font-size: 4rem;
  font-weight: 500;
  font-family: $Roboto;
  line-height: 1;
  text-align: left;
  text-shadow: 1px 1px 100px rgba(0,0,0,.8);
    color: $pal_blue_dark;
  @media screen and (max-width: 600px) {
    font-size: 4rem;
  }
}
h2{
  font-weight: 700;
  text-align: left;
  font-family: $SourceSans;
  font-size: 3rem;
  margin-top: 5px;
  line-height: 1.2;
  color: $pal_blue_dark;
  @media screen and (max-width: 600px) {
    font-size: 2rem;
  }
}
h3{
  font-size: 2rem;
  padding-top: 1rem;
  padding-bottom: 1rem;
  font-family: $SourceSans;
  font-weight: 700;
  color: $textcolor;
  @media screen and (max-width: 600px) {
      font-size: 1.5rem;
  }  
}
h4{
  font-size: 1em;
  padding-top: 0em;
  padding-bottom: .25em;
  font-family: $SourceSans;
  font-weight: 700;
  color: $textcolor;
  @media screen and (max-width: 600px) {
    font-size: 18px;
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
    padding: 10px 10px 10px 0px;   
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
    padding: 20px;
    min-width: 400px;
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
    border: 1px white;
    display: flex;
    flex-wrap: wrap;
    align-items: flex-start;
    justify-content: space-evenly;
    align-content: space-around;
    max-width: 100%;
    margin: auto;
    @media screen and (max-width: 600px) {
        padding: 0px; 
    }
  }

.legend-text {
    fill: black;
    font-family: $SourceSans;
    font-size: 16px;
  }
.viz-comment {
  font-family: $SourceSans;
  font-size: 26px;
  font-weight: 400;
  fill:rgb(224, 222, 222);
}
.viz-emph {
  font-weight:700;
  fill: white;
  font-family: $SourceSans;
  font-size: 26px;
}
.emph {
  font-weight: bold;
}
.italic {
  font-style: italic;
}
.pseudo-caption {
  font-size: .9em;
  margin: 0 10px;
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
