<template>
  <div id="visualization">
    <header>
      <h1>{{ title }}</h1>
      <div class="text-container"></div>
    </header>
    <Inventory />
    <WaterSource />
    <WaterUse />
    <References />
    <Authorship />
  </div>
</template>

<script>
import { ref } from 'vue'
export default {
    name: 'Visualization',
    components: {
      Inventory: () => import("./../components/Inventory.vue"),
      WaterSource: () => import("./../components/WaterSource.vue"),
      WaterUse: () => import("./../components/WaterUse.vue"),
      Authorship: () => import("./../components/Authorship.vue"),
      References: () => import("./../components/References.vue"),
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

$pal_red: '#FD5901';
$pal_or: '#F78104';
$pal_yell: '#FAAB36';
$pal_teal: '#008083';
$pal_blue_dark: '#042054';

#visualization {
  width: calc(100vw - 10rem);
  position: relative;
  padding: 3rem 0 5rem 5rem;
  @media screen and (max-width: 600px) {
    width: calc(100vw - 1rem);
    position: relative;
    padding: 0.5rem 0.5rem 0.5rem 0.5rem;
  }  
}

h1 {
  color: $pal_blue_dark;
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
