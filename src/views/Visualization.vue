<template>
  <div id="visualization">
    <OCONUS />
    <References />
    <Authorship />
  </div>
</template>

<script>

export default {
    name: 'Visualization',
    components: {
      OCONUS: () => import("./../components/OCONUS.vue"),
      Authorship: () => import("./../components/Authorship.vue"),
      References: () => import("./../components/References.vue"),
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
  width: 100vw;
  position: relative;
  top: 0;
  left: 20px;

}

</style>
