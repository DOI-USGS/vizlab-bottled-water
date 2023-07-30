<template>
  <div id="visualization">
    <OCONUS />
  </div>
</template>

<script>

export default {
    name: 'Visualization',
    components: {
      OCONUS: () => import("./../components/OCONUS.vue"),
    },
    computed: {
    },
    mounted(){
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

}

</style>
