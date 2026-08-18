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
        id="text-intro"
        class="text-container"
      >
        <p v-html="sourceText.paragraph1" />
        <br>
        <p v-html="sourceText.paragraph2" />
      </div>
      <sourceBarplots id="source-barplots" />
      <div
        id="chart-caption"
        class="text-container"
      >
        <p
          class="caption"
          v-html="sourceText.paragraph4"
        />
      </div>
      <div
        id="text-detail"
        class="text-container"
      >
        <p v-html="sourceText.paragraph3" />
      </div>
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
    grid-template-rows: 0.5fr max-content max-content max-content max-content;
    grid-template-areas:
      "title"
      "text-intro"
      "source-bars"
      "chart-caption"
      "text-detail";
    justify-content: center;
  }
  #title {
    grid-area: title;
    justify-self: start;
  }
  #text-intro {
    grid-area: text-intro;
    justify-self: start;
  }
  #source-barplots {
    grid-area: source-bars;
  }
  #chart-caption {
    grid-area: chart-caption;
    justify-self: start;
  }
  #text-detail {
    grid-area: text-detail;
    justify-self: start;
  }
</style>