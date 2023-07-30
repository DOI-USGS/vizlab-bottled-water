<template>
  <div id="visualization">
    <OCONUS />
  </div>
</template>

<script>

export default {
    name: 'Visualization',
    components: {
      OCONUS: () => import( /* webpackPreload: true */ /*webpackChunkName: "section"*/ "./../components/OCONUS"),
      //References: () => import( /*webpackChunkName: "References"*/ "./../components/References")
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
