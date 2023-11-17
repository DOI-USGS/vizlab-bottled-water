<template>
  <header id="grid-container-title">
    <div
      id="panel-container"
      :class="{ mobile: mobileView}"
    >
      <div
        class="panel-wrap"
        :class="{ mobile: mobileView}"
      >
        <div
          class="panel start start-shadow glass-under"
          :class="{ mobile: mobileView}"
        /> 
        <div
          class="panel glass-under"
          :class="{ mobile: mobileView}"
        />        
        <div
          class="panel glass-under"
          :class="{ mobile: mobileView}"
        />
        <div
          class="panel glass-under"
          :class="{ mobile: mobileView}"
        />
        <div
          class="panel glass-under"
          :class="{ mobile: mobileView}"
        />
        <div
          class="panel glass-under"
          :class="{ mobile: mobileView}"
        />
        <div
          class="panel glass-under"
          :class="{ mobile: mobileView}"
        />
        <div
          class="panel glass-under"
          :class="{ mobile: mobileView}"
        />
        <div
          class="panel glass-under"
          :class="{ mobile: mobileView}"
        />
        <div
          class="panel glass-under"
          :class="{ mobile: mobileView}"
        />
        <div
          v-if="!mobileView"
          class="panel glass-under"
          :class="{ mobile: mobileView}"
        />
        <div
          v-if="!mobileView"
          class="panel glass-under"
        />
        <div
          v-if="!mobileView"
          class="panel glass-under"
        />
        <div
          v-if="!mobileView"
          class="panel glass-under"
        />
        <div
          class="panel end end-shadow glass-under"
          :class="{ mobile: mobileView}"
        />
        <div
          class="panel neck end-shadow glass-under"
          :class="{ mobile: mobileView}"
        />
        <div
          class="panel cap end-shadow glass-under"
          :class="{ mobile: mobileView}"
        />
      </div>
    </div>
    <div
      id="page-title"
      :class="{ mobile: mobileView}"
    >
      <h1>
        <span class="highlight-words">Water bottling</span><br v-if="mobileView"><span class="later-words"> across the U.S.</span>
      </h1>
    </div>
    <div
      id="overlay-container"
      class="overlay"
      :class="{ mobile: mobileView}"
    >
      <div
        id="overlay-panel"
        class="glass-over"
        :class="{ mobile: mobileView}"
      />
    </div>
  </header>
</template>
<script>
  import { isMobile } from 'mobile-device-detect';
  
  export default {
    name: "Title",
    components: {
    },
    props: {
      data: Object
    },
    data() {
      return {
        publicPath: import.meta.env.BASE_URL, // find the files when on different deployment roots
        mobileView: isMobile, // test for mobile

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
  $shadow-color: rgba(87, 103, 130);
  $panel-height-monitor: 25rem;
  $panel-height-laptop: 17rem;
  $panel-height-mobile-large: 18rem;
  $panel-height-mobile-small: 10rem;
  $water-fill-percentage: 0.45;
  $start-end-percentage: 0.64;
  $neck-percentage: 0.06;
  $cap-percentage: 0.12;
  $full-width-monitor: $start-end-percentage*$panel-height-monitor*2 + 13*0.23*$panel-height-monitor + $neck-percentage*$panel-height-monitor + $cap-percentage*$panel-height-monitor;
  $full-width-laptop: $start-end-percentage*$panel-height-laptop*2 + 13*0.23*$panel-height-laptop + $neck-percentage*$panel-height-laptop + $cap-percentage*$panel-height-laptop;
  $full-width-mobile-large: 4.5rem*9 + 11rem*2 + 1rem + 2.5rem;
  $full-width-mobile-small: 2.55rem*9 + 4.5rem*2 + 0.75rem + 2.25rem;

  #grid-container-title {
    display: grid;
    grid-template-columns: min(86vw, 1600px);
    grid-template-rows: max-content;
    grid-template-areas:
      "title";
    align-content: center;
    text-align: center;
    margin: auto;
    @media screen and (max-height: 770px) {
      grid-template-columns: min(90vw, 1600px);
    }
    @media screen and (max-width: 600px) {
      grid-template-columns: 100%;
      width: $full-width-mobile-small;
    }
  }
  #page-title {
    grid-area: title;
    align-self: center;
    width: min(86vw, 1600px);
    padding-right: $neck-percentage*$panel-height-monitor + $cap-percentage*$panel-height-monitor;
    @media screen and (max-height: 770px) {
      width: min(90vw, 1600px);
      padding-right: $neck-percentage*$panel-height-laptop + $cap-percentage*$panel-height-laptop;
    }
    @media screen and (max-width: 600px) {
      width: 100%;
      padding-right: 0.75rem + 2.25rem;
    }
  }
  #page-title.mobile {
    width: min(86vw, 1600px);
    padding-right: 1rem + 2.5rem;
    @media screen and (max-width: 600px) {
      width: 100%;
      padding-right: 0.75rem + 2.25rem;
    }
  }
  .highlight-words {
    color: #4365A8; 
    z-index: 0;
  }
  #panel-container {
    grid-area: title;
    position: relative;
    height: $panel-height-monitor;
    width: $full-width-monitor;
    @media screen and (max-height: 770px) {
      height: $panel-height-laptop;
      width: $full-width-laptop;
    }
    @media screen and (max-width: 600px) {
      height: $panel-height-mobile-small;
      width: $full-width-mobile-small;
    }
  }
  #panel-container.mobile {
    height: $panel-height-mobile-large;
    width: $full-width-mobile-large;
    @media screen and (max-width: 600px) {
      height: $panel-height-mobile-small;
      width: $full-width-mobile-small;
    }
  }
  .panel-wrap {
    justify-content: center;
    display: flex;
    flex-wrap: nowrap;
    position: absolute;
    width: min(86vw, 1600px);
    @media screen and (max-height: 770px) {
      width: min(90vw, 1600px);
    }
  }
  .panel-wrap.mobile {
    width: min(86vw, 1600px);
    @media screen and (max-width: 600px) {
      width: 100%;
    }
  }
  .panel {
    width: 0.23*$panel-height-monitor;
    height: $panel-height-monitor;
    border-radius: 0.08*$panel-height-monitor;
    @media screen and (max-height: 770px) {
      width: 0.23*$panel-height-laptop;
      height: $panel-height-laptop;
      border-radius: 0.08*$panel-height-laptop;
    }
    @media screen and (max-width: 600px) {
      width: 2.55rem;
      border-radius: 0.8rem;
      height: $panel-height-mobile-small;
    }
  }
  .panel.mobile {
    width: 4.5rem;
    height: $panel-height-mobile-large;
    border-radius: 1.3rem;
    @media screen and (max-width: 600px) {
      width: 2.55rem;
      border-radius: 0.8rem;
      height: $panel-height-mobile-small;
    }
  }
  #overlay-container {
    grid-area: title;
    align-self: end;
    position: relative;
    width: min(86vw, 1600px);
    @media screen and (max-height: 770px) {
      width: min(90vw, 1600px);
    }
  }
  #overlay-container.mobile {
    width: 100%;
  }
  #overlay-panel {
    margin: auto;
    width: $full-width-monitor;
    height: $panel-height-monitor*($water-fill-percentage+0.01);
    border-top-left-radius: 0rem;
    border-top-right-radius: 0rem;
    border-bottom-left-radius: 0.16*$panel-height-monitor;
    border-bottom-right-radius: 0.44*$panel-height-monitor;
    @media screen and (max-height: 770px) {
      width: $full-width-laptop;
      height: $panel-height-laptop*($water-fill-percentage+0.01);
      border-bottom-left-radius: 0.16*$panel-height-laptop;
      border-bottom-right-radius: 0.44*$panel-height-laptop;
    }
  }
  #overlay-panel.mobile {
    width: $full-width-mobile-large;
    height: $panel-height-mobile-large*($water-fill-percentage+0.01);
    border-top-left-radius: 0rem;
    border-top-right-radius: 0rem;
    border-bottom-left-radius: 4rem;
    border-bottom-right-radius: 7.5rem;
    @media screen and (max-width: 600px) {
      width: $full-width-mobile-small;
      height: $panel-height-mobile-small*($water-fill-percentage+0.01);
      border-top-left-radius: 0rem;
      border-top-right-radius: 0rem;
      border-bottom-left-radius: 2rem;
      border-bottom-right-radius: 4rem;
    }
  }
  .glass-under {
    background: linear-gradient(0deg, #DAE6EF, #DAE6EF $water-fill-percentage*100%, white ($water-fill-percentage+0.01)*100%);
    z-index: -1;
    box-shadow: 8px 4px 18px 10px rgba($shadow-color, 0.25);
  }
  .start {
    width: $start-end-percentage*$panel-height-monitor;
    border-top-left-radius: 0.16*$panel-height-monitor;
    border-bottom-left-radius: 0.16*$panel-height-monitor;
    @media screen and (max-height: 770px) {
      width: $start-end-percentage*$panel-height-laptop;
      border-top-left-radius: 0.16*$panel-height-laptop;
      border-bottom-left-radius: 0.16*$panel-height-laptop;
    }
    @media screen and (max-width: 600px) {
      width: 4.5rem;
      border-top-left-radius: 2rem;
      border-bottom-left-radius: 2rem;
    }
  }
  .start.mobile {
    width: 11rem;
    border-top-left-radius: 4rem;
    border-bottom-left-radius: 4rem;
    @media screen and (max-width: 600px) {
      width: 4.5rem;
      border-top-left-radius: 2rem;
      border-bottom-left-radius: 2rem;
    }
  }
  .start-shadow {
    box-shadow: 0 4px 18px 8px rgba($shadow-color, 0.3);
  }
  .end {
    width: $start-end-percentage*$panel-height-monitor;
    border-top-right-radius: 0.44*$panel-height-monitor;
    border-bottom-right-radius: 0.44*$panel-height-monitor;
    @media screen and (max-height: 770px) {
      width: $start-end-percentage*$panel-height-laptop;
      border-top-right-radius: 0.44*$panel-height-laptop;
      border-bottom-right-radius: 0.44*$panel-height-laptop;
    }
    @media screen and (max-width: 600px) {
      width: 4.5rem;
      border-top-right-radius: 5rem;
      border-bottom-right-radius: 5rem;
    }
  }
  .end.mobile {
    width: 11rem;
    border-top-right-radius: 7.5rem;
    border-bottom-right-radius: 7.5rem;
    @media screen and (max-width: 600px) {
      width: 4.5rem;
      border-top-right-radius: 5rem;
      border-bottom-right-radius: 5rem;
    }
  }
  .end-shadow {
    box-shadow: 6px 4px 18px 8px rgba($shadow-color, 0.25);
  }
  .neck {
    width: $neck-percentage*$panel-height-monitor;
    height: 0.23*$panel-height-monitor;
    align-self: center;
    border-radius: 0rem;
    background: linear-gradient(0deg, #DAE6EF, #DAE6EF 30%, white 30.5%);
    @media screen and (max-height: 770px) {
      width: $neck-percentage*$panel-height-laptop;
      height: 0.23*$panel-height-laptop;
    }
    @media screen and (max-width: 600px) {
      height: 2.94rem;
      width: 0.75rem;
      background: linear-gradient(0deg, #DAE6EF, #DAE6EF 34.5%, white 35%);
    }
  }
  .neck.mobile {
    width: 1rem;
    height: 4.5rem;
    align-self: center;
    border-radius: 0rem;
    background: linear-gradient(0deg, #DAE6EF, #DAE6EF 31%, white 31.5%);
    @media screen and (max-width: 600px) {
      height: 2.94rem;
      width: 0.75rem;
      background: linear-gradient(0deg, #DAE6EF, #DAE6EF 34.5%, white 35%);
    }
  }
  .cap {
    width: $cap-percentage*$panel-height-monitor;
    height: 0.27*$panel-height-monitor;
    align-self: center;
    border-top-left-radius: 0rem;
    border-bottom-left-radius: 0rem;
    border-top-right-radius: 0.04*$panel-height-monitor;
    border-bottom-right-radius: 0.04*$panel-height-monitor;
    background: white;
    box-shadow: 4px 2px 14px 4px rgba($shadow-color, 0.2);
    @media screen and (max-height: 770px) {
      width: $cap-percentage*$panel-height-laptop;
      height: 0.27*$panel-height-laptop;
      border-top-right-radius: 0.04*$panel-height-laptop;
      border-bottom-right-radius: 0.04*$panel-height-laptop;
    }
    @media screen and (max-width: 600px) {
      width: 2.25rem;
      height: 3.5rem;
      border-top-right-radius: 0.6rem;
      border-bottom-right-radius: 0.6rem;
    }
  }
  .cap.mobile {
    width: 2.5rem;
    height: 5.5rem;
    border-top-left-radius: 0rem;
    border-bottom-left-radius: 0rem;
    border-top-right-radius: 0.6rem;
      border-bottom-right-radius: 0.6rem;
    @media screen and (max-width: 600px) {
      width: 2.25rem;
      height: 3.5rem;
      border-top-right-radius: 0.6rem;
      border-bottom-right-radius: 0.6rem;
    }
  }
  .glass-over {
    backdrop-filter: blur(0.08rem);
    -webkit-backdrop-filter: blur(0.08rem);
  }
  .glass-over.cap {
    z-index: -1;
  }
  .glass-over.neck {
    z-index: -1;
  }
</style>