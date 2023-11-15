<template>
  <div id="visualization">
    <Title />
    <OCONUS />
    <InventorySection v-if="checkIfMapIsRendered" />
    <WaterSourceSection v-if="checkIfMapIsRendered" />
    <WaterUseSection v-if="checkIfMapIsRendered" />
    <BottledWaterFocusSection v-if="checkIfMapIsRendered" />
    <ReferencesSection v-if="checkIfMapIsRendered" />
    <AuthorshipSection v-if="checkIfMapIsRendered" />
  </div>
</template>

<script>
import { ref } from 'vue'
import { isMobile } from 'mobile-device-detect';
export default {
    name: 'VisualizationContent',
    components: {
      Title: () => import("./../components/Title.vue"),
      OCONUS: () => import("./../components/OCONUS.vue"),
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
