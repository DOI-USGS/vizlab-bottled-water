<template>
  <section id="authorship">
    <div class="text-container title-text">
      <h2>Authors</h2>
    </div>
    <div
      v-if="showAuthors"
      id="author-container"
      class="text-container"
    >
      <p>
        This visualization was developed by the <a
          href="https://water.usgs.gov/vizlab/"
          target="_blank"
        >USGS Vizlab</a> and led by <span v-html="formatAuthors(primaryAuthors)" /><span
          v-if="showAdditionalAuthors"
        >, with contributions from <span v-html="formatAuthors(additionalAuthors)" /></span>.
      </p>
    </div>
  </section>
</template>

<script setup>
  import { computed } from "vue";
  import authors from "@/assets/text/authors";

  const primaryAuthors = authors.primaryAuthors;
  const additionalAuthors = authors.additionalAuthors;

  const showAuthors = computed(() => primaryAuthors.length > 0);
  const showAdditionalAuthors = computed(() => additionalAuthors.length > 0);

  // Link the author's name to their staff profile, where they have one
  function createLink(author) {
    return author.profile_link
      ? `<a href="${author.profile_link}" target="_blank">${author.fullName}</a>`
      : author.fullName;
  }

  // Join names as "A", "A and B", or "A, B, and C"
  function formatAuthors(list) {
    const names = list.map(createLink);
    if (names.length < 2) return names.join("");
    if (names.length === 2) return names.join(" and ");
    return `${names.slice(0, -1).join(", ")}, and ${names.slice(-1)}`;
  }
</script>

<style>
  #author-container {
    height: auto;
    padding: 10px 0px 0px 0px;
    font-style: italic;
    font-weight: 300;
  }
  #author-container a {
    font-weight: 400;
  }
</style>
