<template>
  <div id="visualization">
    <header id="title-container">
      <div class="panel-wrap">
        <div class="panel start start-shadow glass-under" /> 
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
        <div class="panel end end-shadow glass-under" />
        <div class="panel neck end-shadow glass-under" />
        <div class="panel cap end-shadow glass-under" />
      </div>
      <div id="page-title">
        <h1>
          <span class="highlight-words">Water bottling</span><span class="later-words"> across the U.S.</span>
        </h1>
      </div>
      <div class="panel-wrap overlay">
        <div
          id="overlay-panel"
          class="glass-over"
          :class="{ mobile: mobileView}"
        />
      </div>
    </header>
    <InventorySection />
    <WaterSourceSection />
    <WaterUseSection />
    <BottledWaterFocusSection />
    <ReferencesSection />
    <AuthorshipSection />
  </div>
</template>

<script>
import { ref } from 'vue'
import { isMobile } from 'mobile-device-detect';
export default {
    name: 'VisualizationContent',
    components: {
      InventorySection: () => import("./../components/Inventory.vue"),
      WaterSourceSection: () => import("./../components/WaterSource.vue"),
      WaterUseSection: () => import("./../components/WaterUse.vue"),
      BottledWaterFocusSection: () => import("./../components/BottledWaterFocus.vue"),
      AuthorshipSection: () => import("./../components/Authorship.vue"),
      ReferencesSection: () => import("./../components/References.vue"),
    },
    setup() {
      const title = ref('Water bottling across the United States')

      return {
        title
      }
    },
    data() {
      return {
        mobileView: isMobile,
      };
    },
    computed: {
    },
    mounted(){
      console.log("App loaded");

    },
    methods:{

    }
} 
</script>

<style lang="scss">
  $shadow-color: rgba(87, 103, 130);
  $panel-height-monitor: 25rem;
  $panel-height-laptop: 17rem;
  $water-fill-percentage: 0.45;
  #visualization {
    width: 86vw;
    position: relative;
    padding: 6rem 0rem 5rem 0rem;
    margin: auto;
    max-width: 1600px;
    @media screen and (max-height: 770px) {
      width: 90vw;
    }
    @media screen and (max-width: 600px) {
      width: calc(100vw - 1rem);
      position: relative;
      padding: 4rem 0.5rem 4rem 0.5rem;
    }  
  }
  *:focus {
    outline: none;
  }
  [tabindex="0"]:focus {
      outline: none;
  }
  [tabindex="0"]:focus-visible {
      outline: auto;
  }
  a:focus {
    font-weight: 700;
  }
  img {
    max-width: 100%;
  }
  .image-float {
    float: right;
  }
  #title-container {
    width: fit-content;
    margin: 0rem auto 0rem auto;
  }
  #page-title {
    margin: 0rem 0rem 0rem 2.5rem;
    @media screen and (max-height: 770px) {
      margin: 0rem 0rem 0rem 2rem;
    }
    @media screen and (max-width: 600px) {
      margin: 0rem 0rem 0rem 1.5rem;
    }
  }
  .highlight-words {
    color: #4365A8; 
    z-index: 0;
  }
  .panel-wrap {
    display: flex;
    justify-content: flex-start;
    position: absolute;
    top: 5.5rem; // same as top padding on #visualization -0.5rem
    @media screen and (max-width: 600px) {
      top: 3.5rem; // same as top padding on #visualization -0.5rem
      margin-left: 0.25rem;
    }
  }
  .panel-wrap.overlay {
    top: 5.5rem + (1 - $water-fill-percentage)*$panel-height-monitor; // same as top padding on #visualization -0.5rem
    @media screen and (max-height: 770px) {
      top: 5.5rem + (1 - $water-fill-percentage)*$panel-height-laptop;
    }
    @media screen and (max-width: 600px) {
      top: 3.5rem + (1 - $water-fill-percentage)*10; // same as top padding on #visualization -0.5rem
      margin-left: 0.25rem;
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
      height: 10rem;
    }
  }
  .panel.mobile {
    width: 5rem;
    border-radius: 1.5rem;
    @media screen and (max-width: 600px) {
      width: 2.55rem;
      border-radius: 0.8rem;
      height: 10rem;
    }
  }
  #overlay-panel {
    width: 0.64*$panel-height-monitor + 13*0.23*$panel-height-monitor + 0.64*$panel-height-monitor;
    height: $panel-height-monitor*($water-fill-percentage+0.01);
    border-top-left-radius: 0rem;
    border-top-right-radius: 0rem;
    border-bottom-left-radius: 0.16*$panel-height-monitor;
    border-bottom-right-radius: 0.44*$panel-height-monitor;
    @media screen and (max-height: 770px) {
      width: 0.64*$panel-height-laptop + 13*0.23*$panel-height-laptop + 0.64*$panel-height-laptop;
      height: $panel-height-laptop*($water-fill-percentage+0.01);
      border-bottom-left-radius: 0.16*$panel-height-laptop;
      border-bottom-right-radius: 0.44*$panel-height-laptop;
    }
  }
  #overlay-panel.mobile {
    width: 5rem;
    @media screen and (max-width: 600px) {
      width: 4.5*2rem + 2.55*9rem;
      border-top-left-radius: 0rem;
      border-top-right-radius: 0rem;
      border-bottom-left-radius: 2rem;
      border-bottom-right-radius: 4rem;
      height: 10rem*($water-fill-percentage+0.01);
    }
  }
  .glass-under {
    background: linear-gradient(0deg, #DAE6EF, #DAE6EF $water-fill-percentage*100%, white ($water-fill-percentage+0.01)*100%);
    z-index: -1;
    box-shadow: 8px 4px 18px 10px rgba($shadow-color, 0.25);
  }
  .start {
    width: 0.64*$panel-height-monitor;
    border-top-left-radius: 0.16*$panel-height-monitor;
    border-bottom-left-radius: 0.16*$panel-height-monitor;
    @media screen and (max-height: 770px) {
      width: 0.64*$panel-height-laptop;
      border-top-left-radius: 0.16*$panel-height-laptop;
      border-bottom-left-radius: 0.16*$panel-height-laptop;
    }
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
    width: 0.64*$panel-height-monitor;
    border-top-right-radius: 0.44*$panel-height-monitor;
    border-bottom-right-radius: 0.44*$panel-height-monitor;
    @media screen and (max-height: 770px) {
      width: 0.64*$panel-height-laptop;
      border-top-right-radius: 0.44*$panel-height-laptop;
      border-bottom-right-radius: 0.44*$panel-height-laptop;
    }
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
    width: 0.06*$panel-height-monitor;
    height: 0.23*$panel-height-monitor;
    align-self: center;
    border-radius: 0rem;
    background: linear-gradient(0deg, #DAE6EF, #DAE6EF 31%, white 31.5%);
    @media screen and (max-height: 770px) {
      width: 0.06*$panel-height-laptop;
      height: 0.23*$panel-height-laptop;
    }
    @media screen and (max-width: 600px) {
      height: 2.94rem;
      width: 0.75rem;
      background: linear-gradient(0deg, #DAE6EF, #DAE6EF 34.5%, white 35%);
    }
  }
  .cap {
    width: 0.12*$panel-height-monitor;
    height: 0.27*$panel-height-monitor;
    align-self: center;
    border-top-left-radius: 0rem;
    border-bottom-left-radius: 0rem;
    border-top-right-radius: 0.04*$panel-height-monitor;
    border-bottom-right-radius: 0.04*$panel-height-monitor;
    background: white;
    box-shadow: 4px 2px 14px 4px rgba($shadow-color, 0.2);
    @media screen and (max-height: 770px) {
      width: 0.12*$panel-height-laptop;
      height: 0.27*$panel-height-laptop;
      border-top-right-radius: 0.04*$panel-height-laptop;
      border-bottom-right-radius: 0.04*$panel-height-laptop;
    }
    @media screen and (max-width: 600px) {
      height: 3.5rem;
      width: 2.25rem;
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
  .img-container {
    max-width: 100vw;
    text-align: center;
  }
</style>
