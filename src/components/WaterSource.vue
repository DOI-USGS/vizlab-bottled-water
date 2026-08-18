<template>
  <section id="water_source">
    <div id="grid-container-source">
      <div
        id="title"
        class="text-container title-text"
      >
        <h2 v-html="sourceText.title" />
      </div>
      <div
        id="text"
        class="text-container"
      >
        <p v-html="sourceText.paragraph1" />
        <br>
        <p v-html="sourceText.paragraph2" />
        <br>
        <p v-html="sourceText.paragraph3" />
        <br>
        <p v-html="sourceText.paragraph4" />
      </div>
      <sourceBarplots id="source-barplots" />
    </div>
  </section>
</template>
<script setup>
  import sourceBarplots from "@/components/SourceBarplots.vue";
  import waterSourceText from "@/assets/text/waterSourceText.js";

  const sourceText = waterSourceText.waterSourceText;
</script>
<style lang="scss">

  #grid-container-source {
    display: grid;
    grid-template-columns: 1fr;
    grid-template-rows: 0.5fr max-content max-content max-content;
    grid-template-areas:
      "title"
      "text"
      "source-bars";
    justify-content: center;
  }
  #title {
    grid-area: title;
    justify-self: start;
  }
  #text {
    grid-area: text;
    justify-self: start;
  }
  #source-barplots {
    grid-area: source-bars;
  }
</style>