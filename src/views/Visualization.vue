<template>
  <div id="visualization">
    <header>
      <h1>{{ title }}</h1>
    </header>
    <OCONUS />
    <References />
    <Authorship />
  </div>
</template>

<script>
import { ref } from 'vue'
export default {
    name: 'Visualization',
    components: {
      OCONUS: () => import("./../components/OCONUS.vue"),
      Authorship: () => import("./../components/Authorship.vue"),
      References: () => import("./../components/References.vue"),
    },
    setup() {
      const title = ref('What are the impacts of bottled water?')

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
  top: 5rem;
  left: 5rem;
}

h1 {
  color: $pal_blue_dark;
}

</style>
