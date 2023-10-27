<template>
  <div id="visualization">
    <header>
      <div class="panel-wrap">
        <div class="panel start start-shadow glass-under" /> 
        <div class="panel glass-under" />        
        <div class="panel glass-under" />
        <div class="panel glass-under" />
        <div class="panel glass-under" />
        <div class="panel glass-under" />
        <div class="panel glass-under" />
        <div class="panel glass-under" />
        <div class="panel glass-under" />
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
      <div class="text-container">
        <h1><span class="first-words">Water bottling</span> across the U.S.</h1>
      </div>
      <div class="panel-wrap">
        <div class="panel start glass-over" /> 
        <div class="panel glass-over" />        
        <div class="panel glass-over" />
        <div class="panel glass-over" />
        <div class="panel glass-over" />
        <div class="panel glass-over" />
        <div class="panel glass-over" />
        <div class="panel glass-over" />
        <div class="panel glass-over" />
        <div
          v-if="!mobileView"
          class="panel glass-over"
        />
        <div
          v-if="!mobileView"
          class="panel glass-over"
        />
        <div class="panel end glass-over" />
        <div class="panel neck glass-over" />
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

  #visualization {
    width: 86vw;
    position: relative;
    padding: 5rem 0rem 5rem 0rem;
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
  .first-words {
    margin: 0rem 5.5rem 0rem 2.25rem;
    color: #2184B5;
    z-index: 0;
    @media screen and (max-height: 770px) {
      margin: 0rem 5.25rem 0rem 1.75rem;
    }
    @media screen and (max-width: 600px) {
      width: 3.5rem;
      height: 15rem;
    }
  }
  .panel-wrap {
    display: flex;
    justify-content: start;
    position: absolute;
    top: 5rem; // same as top padding on #visualization
    width: 100%;
    @media screen and (max-width: 600px) {
      top: 4rem; // same as top padding on #visualization
    }
  }
  .panel {
    width: 3.5rem;
    height: 15rem;
    @media screen and (max-height: 770px) {
      width: 2.7rem;
      height: 12rem;
    }
    @media screen and (max-width: 600px) {
      width: 2.5rem;
      height: 8.5rem;
    }
  }
  .glass-under {
    z-index: -1;
    background: rgba(255, 255, 255, 1);
    border-radius: 1rem;
    box-shadow: 8px 4px 18px 10px rgba(147, 148, 150, 0.25);
  }
  .glass-over {
    backdrop-filter: blur(0.08rem);
    -webkit-backdrop-filter: blur(0.08rem);
  }
  .start {
    width: 7rem;
    border-top-left-radius: 2.5rem;
    border-bottom-left-radius: 2.5rem;
    @media screen and (max-height: 770px) {
      width: 6rem;
    }
    @media screen and (max-width: 600px) {
      width: 5rem;
      border-top-left-radius: 2rem;
      border-bottom-left-radius: 2rem;
    }
  }
  .start-shadow {
    box-shadow: 0 4px 18px 8px rgba(147, 148, 150, 0.3);
  }
  .end {
    width: 8rem;
    border-top-right-radius: 5rem;
    border-bottom-right-radius: 5rem;
    @media screen and (max-height: 770px) {
      width: 7rem;
      border-top-right-radius: 4.5rem;
      border-bottom-right-radius: 4.5rem;
    }
    @media screen and (max-width: 600px) {
      width: 5rem;
      border-top-right-radius: 3rem;
      border-bottom-right-radius: 3rem;
    }
  }
  .end-shadow {
    box-shadow: 6px 4px 18px 8px rgba(147, 148, 150, 0.25);
  }
  .neck {
    width: 1rem;
    height: 4.75rem;
    align-self: center;
    border-radius: 0rem;
    @media screen and (max-height: 770px) {
      width: 0.75rem;
    }
  }
  .cap {
    width: 2.75rem;
    height: 5.5rem;
    align-self: center;
    border-top-left-radius: 0rem;
    border-bottom-left-radius: 0rem;
    @media screen and (max-height: 770px) {
      width: 2.5rem;
    }
  }
  .img-container {
    max-width: 100vw;
    text-align: center;
  }
</style>
