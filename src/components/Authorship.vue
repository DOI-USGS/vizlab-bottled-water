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
        <span id="primary-author-statment">
          The {{ appTitle }} data visualization was made by the <a
            href="https://labs.waterdata.usgs.gov/visualizations/index.html#/"
            target="_blank"
          >USGS Vizlab</a> in collaboration with the USGS Water Use program. Development was led by 
          <span
            v-for="(author, index) in primaryAuthors" 
            :id="`initial-${author.initials}`"
            :key="`${author.initials}-attribution`"
            :class="'author first'"
          >
            <a
              :href="author.profile_link"
              target="_blank"
              v-text="author.fullName"
            />
            <span v-if="index != Object.keys(primaryAuthors).length - 1 && Object.keys(primaryAuthors).length > 2">, </span>
            <span v-if="index == Object.keys(primaryAuthors).length - 2"> and </span>
          </span>
        </span>
        <span>
          with contributions from
        </span>
        <span
          v-if="showAdditionalAuthors"
          id="additional-author-statement"
        >
          <span
            v-for="(author, index) in additionalAuthors" 
            :id="`author-${author.initials}`"
            :key="`${author.initials}-attribution`"
            :class="'author'"
          >
            <a
              :href="author.profile_link"
              target="_blank"
              v-text="author.fullName"
            />
            <span v-if="index != Object.keys(additionalAuthors).length - 1 && Object.keys(additionalAuthors).length > 2">, </span>
            <span v-if="index == Object.keys(additionalAuthors).length - 2"> and </span>
          </span>.
        </span>
        <span
          v-if="showContributionStatements"
          id="contribution-statements"
        >
          <span id="primary-author-contribution">
            <span
              v-for="author in primaryAuthors" 
              :id="`author-${author.initials}`"
              :key="`${author.initials}-contribution`"
              :class="'author'"
            >
              <span v-text="author.firstName" /> <span v-text="author.contribution" />. 
            </span>
          </span>
          <span
            v-if="showAditionalContributionStatement"
            id="additional-author-contribution"
          >
            <span
              v-for="author in additionalAuthors" 
              :id="`author-${author.initials}`"
              :key="`${author.initials}-contribution`"
              :class="'author'"
            >
              <span v-text="author.firstName" /> <span v-text="author.contribution" />. 
            </span>
          </span>
        </span>
      </p>
    </div>
  </section>
</template>

<script>
import { isMobile } from 'mobile-device-detect';
import authors from "@/assets/text/authors";
export default {
  name: "AuthorshipSection",
    components: {
    },
    props: {
    },
    data() {
      return {
        publicPath: import.meta.env.BASE_URL, // allows the application to find the files when on different deployment roots
        appTitle: import.meta.env.VITE_APP_TITLE, // Pull in title of page from Vue environment (set in .env)
        mobileView: isMobile, // test for mobile
        primaryAuthors: authors.primaryAuthors,
        additionalAuthors: authors.additionalAuthors,
        showAuthors: null, // Turn on or off attribution for all authors
        showAdditionalAuthors: null, // If showAuthors is true, turn on or off attribution for additional authors
        showContributionStatements: true, // If showAuthors is true, turn on or off contribution statements for ALL authors
        showAditionalContributionStatement: null // If showAuthors is true and if showContributionStatements is true, turn on or off contriubtion statements for ADDITIONAL authors
      }
    },
    mounted(){   
      console.log(this.appTitle)
      this.showAuthors = this.primaryAuthors.length > 0 ? true: false; // Show author statements for any authors
      this.showAdditionalAuthors =  this.additionalAuthors.length > 0 ? true : false; // Show author statements for additional authors if any are listed
      this.showAditionalContributionStatement = this.additionalAuthors.length > 0 ? true : false; // Show contributions statements for additional authors if any are listed AND showContributionStatements is true
    },
    methods:{
      isMobile() {
              if(/Android|webOS|iPhone|iPad|iPod|BlackBerry|IEMobile|Opera Mini/i.test(navigator.userAgent)) {
                  return true
              } else {
                  return false
              }
          }
    }
}
</script>
<style>
  #author-container {
    height: auto;
    padding: 10px 0px 0px 0px;
  }
</style>