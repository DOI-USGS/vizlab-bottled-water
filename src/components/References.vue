<template>
  <section id="references">    
    <div class="text-container title-text">
      <h2>{{ text.title }}</h2>
    </div>
    <div class="text-container">
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
      </div>
    </div>
  </section>
</template>

<script setup>
  import referencesText from "@/assets/text/referencesText";

  const text = referencesText.referencesContent;
</script>
<style scoped lang="scss">
  // One blank line between entries. The markup previously carried a <br> on top
  // of the default paragraph margins, which double-spaced the list.
  p {
    margin: 0 0 2rem 0;
  }
  button:not([disabled]):focus{
    outline: none;
  }
</style>