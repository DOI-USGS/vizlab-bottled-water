<template>
  <div id="visualization">
    <VizTitle />
    <p id="byline">
      U.S. Geological Survey<span class="byline-sep"> &middot; </span><span class="pub-date">Published {{ datePublished }} &middot; Updated {{ dateUpdated }}</span>
    </p>
    <OCONUS />
    <InventorySection v-if="checkIfMapIsRendered" />
    <WaterSourceSection v-if="checkIfMapIsRendered" />
    <WaterUseSection v-if="checkIfMapIsRendered" />
    <BottledWaterFocusSection v-if="checkIfMapIsRendered" />
    <ReferencesSection v-if="checkIfMapIsRendered" />
    <AuthorshipSection v-if="checkIfMapIsRendered" />
  </div>
</template>

<script setup>
  import { storeToRefs } from 'pinia';
  import VizTitle from "@/components/VizTitle.vue";
  import OCONUS from "@/components/OCONUS.vue";
  import InventorySection from "@/components/InventorySection.vue";
  import WaterSourceSection from "@/components/WaterSource.vue";
  import WaterUseSection from "@/components/WaterUse.vue";
  import BottledWaterFocusSection from "@/components/BottledWaterFocus.vue";
  import AuthorshipSection from "@/components/AuthorshipSection.vue";
  import ReferencesSection from "@/components/ReferencesSection.vue";
  import { useMapRenderStore } from '@/stores/MapRenderStore';

  // Keep these in step with the datePublished/dateModified in index.html
  const datePublished = 'November 21, 2023';
  const dateUpdated = 'August 17, 2026';

  // The sections below the map wait for the map's initial render
  const { mapRenderedOnInitialLoad: checkIfMapIsRendered } = storeToRefs(useMapRenderStore());
</script>

<style lang="scss">
  #byline {
    text-align: center;
    font-style: italic;
    font-size: 0.8em;
    margin: 1.5rem auto 0 auto;
    color: #6E6E6E;
  }
  .pub-date {
    color: #6E6E6E;
  }
  @media screen and (max-width: 600px) {
    // stack the dates onto their own line rather than letting them wrap awkwardly
    #byline .byline-sep {
      display: none;
    }
    #byline .pub-date {
      display: block;
    }
  }
  #visualization {
    width: 86vw;
    position: relative;
    padding: 6rem 0rem 5rem 0rem;
    margin: auto;
    max-width: 1600px;
    @media screen and (max-height: 770px) {
      padding: 4rem 0rem 5rem 0rem;
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
  .img-container {
    max-width: 100vw;
    text-align: center;
  }
</style>
