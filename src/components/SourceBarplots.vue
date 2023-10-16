<template>
    <section>
      <div id="grid-container-barplots">
        <div id="barplot-container" />
      </div>
    </section>
</template>
<script>
import * as d3Base from 'd3';
import { isMobile } from 'mobile-device-detect';

export default {
  name: "supplyBarplots",
  components: {
  },
  data() {
    return {

      d3: null,
      publicPath: import.meta.env.BASE_URL, // find the files when on different deployment roots
      mobileView: isMobile, // test for mobile
      summaryType: null
    }
  },
  mounted(){      
    this.d3 = Object.assign(d3Base);

    const self = this;
    this.loadData() // read in data 
 
  },
  methods:{
    isMobile() {
            if(/Android|webOS|iPhone|iPad|iPod|BlackBerry|IEMobile|Opera Mini/i.test(navigator.userAgent)) {
                return true
            } else {
                return false
            }
    },
    loadData(data) {
      const self = this;

      let promises = [
        self.d3.csv(self.publicPath + 'source_summary.csv')
      ];
      Promise.all(promises).then(self.callback)
    },
    callback(data){
      const self = this;

      // Assign data
      const sourceSummary = data[0];

      // Set default summaryType
      this.summaryType = 'Count'

      // Build barplots
      self.initBarplot(sourceSummary)
    },
    initBarplot(data) {
      const  width = 800;
      const height = 400;
      const barplotDimensions = {
        width,
        height,
        margin: {
          top: 15,
          right: 5,
          bottom: 40,
          left: 15
        }
      }
      barplotDimensions.boundedWidth = barplotDimensions.width - barplotDimensions.margin.left - barplotDimensions.margin.right
      barplotDimensions.boundedHeight = barplotDimensions.height - barplotDimensions.margin.top - barplotDimensions.margin.bottom

      // draw canvas for histogram
      const barplotSVG = this.d3.select("#barplot-container")
        .append("svg")
          .attr("viewBox", [0, 0, (barplotDimensions.width), (barplotDimensions.height)].join(' '))
          .attr("width", "100%")
          .attr("height", "100%")
          .attr("id", "barplot-svg")

      // assign role for accessibility
      barplotSVG.attr("role", "figure")
        .attr("tabindex", 0)
        .attr("contenteditable", "true")
        .append("title")
        .text("Sources of water used by bottling facilities")

      this.barplotBounds = barplotSVG.append("g")
        .style("transform", `translate(${
          barplotDimensions.margin.left
        }px, ${
          barplotDimensions.margin.top
        }px)`)
    }
  }
}
</script>
<style lang="scss">
// Elements added w/ D3
</style>
<style scoped lang="scss">

</style>