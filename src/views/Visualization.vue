<template>
  <div id="visualization">
    <header>
      <div class="text-container">
        <h1>{{ title }}</h1>
      </div>
    </header>
    <InventorySection />
    <WaterSourceSection />
    <WaterUseSection />
    <ReferencesSection />
    <AuthorshipSection />
  </div>
</template>

<script>
import { ref } from 'vue'
export default {
    name: 'VisualizationContent',
    components: {
      InventorySection: () => import("./../components/Inventory.vue"),
      WaterSourceSection: () => import("./../components/WaterSource.vue"),
      WaterUseSection: () => import("./../components/WaterUse.vue"),
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
      padding: 2rem 0.5rem 0.5rem 0.5rem;
    }  
  }
  *:focus {
    outline: none;
  }
  [contenteditable="true"]:focus {
      outline: auto;
  }
  img {
    max-width: 100%;
  }
  .image-float {
    float: right;
  }
</style>
