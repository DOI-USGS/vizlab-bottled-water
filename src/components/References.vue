<template>
  <section id="references">       
    <div class="text-content">
      <h3>{{ text.title }}</h3>
      <div>
        <div
          v-for="reference in text.references"
          :key="reference.subTitle"
        >
          <p>
            <span v-html="reference.num" />. <span v-html="reference.authors" />, <span v-html="reference.year" />, 
            <a
              :href="reference.link"
              target="_blank"
            ><span v-html="reference.title" /></a><span v-if="reference.type != ''">, </span><span v-html="reference.type" /><span v-if="reference.ref != ''">, </span><span v-html="reference.ref" />.
          </p>
          <br>
        </div>
      </div>
    </div>
  </section>
</template>

<script>
    import referencesText from "@/assets/text/referencesText";
    export default {
        name: 'ReferencesSection',
        data() {
            return {
                text: referencesText.referencesContent
            }
        }
    }
</script>
<style scoped lang="scss">
  button:not([disabled]):focus{
    outline: none;
  }
</style>