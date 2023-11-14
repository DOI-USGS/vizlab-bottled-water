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
        <div class="panel neck end-shadow glass-under"/>
        <div class="panel cap end-shadow glass-under" />
      </div>
      <h1 id="page-title">
        <span class="highlight-words">Water bottling</span>
      </h1>
      <div class="panel-wrap">
        <div class="panel start glass-over" /> 
        <div
          class="panel glass-over"
          :class="{ mobile: mobileView}"
        />        
        <div
          class="panel glass-over"
          :class="{ mobile: mobileView}"
        />
        <div
          class="panel glass-over"
          :class="{ mobile: mobileView}"
        />
        <div
          class="panel glass-over"
          :class="{ mobile: mobileView}"
        />
        <div
          class="panel glass-over"
          :class="{ mobile: mobileView}"
        />
        <div
          class="panel glass-over"
          :class="{ mobile: mobileView}"
        />
        <div
          class="panel glass-over"
          :class="{ mobile: mobileView}"
        />
        <div
          class="panel glass-over"
          :class="{ mobile: mobileView}"
        />
        <div
          v-if="!mobileView"
          class="panel glass-over"
        />
        <div
          v-if="!mobileView"
          class="panel glass-over"
        />
        <div
          v-if="!mobileView"
          class="panel glass-over"
        />
        <div class="panel end glass-over" />
        <div class="panel neck glass-over"/>
        <div class="panel cap glass-over" />
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
    margin: auto;
  }
  #page-title {
    margin: 0rem 0rem 0rem 2.25rem;
    @media screen and (max-height: 770px) {
      margin: 0rem 0rem 0rem 1.75rem;
    }
    @media screen and (max-width: 600px) {
      margin: 0rem 0rem 0rem 1.5rem;
    }
  }
  .first-words {
    margin-right: 5.25rem;
    @media screen and (max-width: 790px) {
      margin-right: 0rem;
    }
    @media screen and (max-height: 770px) {
      margin-right: 6rem;
    }
    @media screen and (max-width: 600px) {
      margin-right: 0rem;
    }
  }
  .highlight-words {
    color: #4365A8; 
    z-index: 0;
  }
  .later-words {
    margin-left: 5.25rem;
    @media screen and (max-width: 790px) {
      margin-left: 0rem;
    }
    @media screen and (max-height: 770px) {
      margin-left: 6rem;
    }
    @media screen and (max-width: 600px) {
      margin-left: 0rem;
    }
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
  .panel {
    width: 3.5rem;
    height: 17rem;
    border-radius: 1rem;
    @media screen and (max-height: 770px) {
      width: 3.25rem;
      height: 14rem;
    }
    @media screen and (max-width: 600px) {
      width: 2.7rem;
      border-radius: 0.9rem;
      height: 10rem;
    }
  }
  .panel.mobile {
    width: 5rem;
    border-radius: 1.5rem;
    @media screen and (max-width: 600px) {
      width: 2.7rem;
      border-radius: 0.9rem;
      height: 10rem;
    }
  }
  .glass-under {
    background: linear-gradient(0deg, #DAE6EF, #DAE6EF 45%, white 46%);
    z-index: -1;
    box-shadow: 8px 4px 18px 10px rgba($shadow-color, 0.25);
  }
  .start {
    width: 8.5rem;
    border-top-left-radius: 2.5rem;
    border-bottom-left-radius: 2.5rem;
    @media screen and (max-height: 770px) {
      width: 7rem;
    }
    @media screen and (max-width: 600px) {
      width: 5.1rem;
      border-top-left-radius: 2rem;
      border-bottom-left-radius: 2rem;
    }
  }
  .start-shadow {
    box-shadow: 0 4px 18px 8px rgba($shadow-color, 0.3);
  }
  .end {
    width: 9.5rem;
    border-top-right-radius: 6.5rem;
    border-bottom-right-radius: 6.5rem;
    @media screen and (max-height: 770px) {
      width: 7.5rem;
      border-top-right-radius: 5.5rem;
      border-bottom-right-radius: 5.5rem;
    }
    @media screen and (max-width: 600px) {
      width: 5.1rem;
      border-top-right-radius: 5rem;
      border-bottom-right-radius: 5rem;
    }
  }
  .end-shadow {
    box-shadow: 6px 4px 18px 8px rgba($shadow-color, 0.25);
  }
  .neck {
    width: 1rem;
    height: 5rem;
    align-self: center;
    border-radius: 0rem;
    background: linear-gradient(0deg, #DAE6EF, #DAE6EF 34.5%, white 35%);
    @media screen and (max-height: 770px) {
      height: 4.12rem;
      width: 0.75rem;
    }
    @media screen and (max-width: 600px) {
      height: 2.94rem;
      width: 0.75rem;
    }
  }
  .glass-over.neck {
    z-index: -1;
  }
  .cap {
    width: 2.75rem;
    height: 5.5rem;
    align-self: center;
    border-top-left-radius: 0rem;
    border-bottom-left-radius: 0rem;
    background: white;
    box-shadow: 4px 2px 14px 4px rgba($shadow-color, 0.2);
    @media screen and (max-height: 770px) {
      height: 5rem;
      width: 2.25rem;
    }
    @media screen and (max-width: 600px) {
      height: 4.25rem;
      width: 2.25rem;
    }
  }
  .glass-over.cap {
    z-index: -1;
  }
  .glass-over {
    backdrop-filter: blur(0.08rem);
    -webkit-backdrop-filter: blur(0.08rem);
  }
  .img-container {
    max-width: 100vw;
    text-align: center;
  }
</style>
