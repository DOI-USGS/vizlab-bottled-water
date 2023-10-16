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
      summaryType: null,
      barplotDimensions: null,
      barplotBounds: null,
      xScale: null,
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

      // Initialize barplot
      self.initBarplot(sourceSummary)

      // Generate color scale
      const colorScale = self.makeColorScale(sourceSummary)

      // Draw barplot
      self.drawBarplot(sourceSummary, colorScale, this.summaryType)

      // Draw legend
      self.addLegend()
    },
    initBarplot(data) {
      const  width = 800;
      const height = 400;
      this.barplotDimensions = {
        width,
        height,
        margin: {
          top: 15,
          right: 5,
          bottom: 40,
          left: 35
        }
      }
      this.barplotDimensions.boundedWidth = this.barplotDimensions.width - this.barplotDimensions.margin.left - this.barplotDimensions.margin.right
      this.barplotDimensions.boundedHeight = this.barplotDimensions.height - this.barplotDimensions.margin.top - this.barplotDimensions.margin.bottom

      // draw canvas for barplot
      const barplotSVG = this.d3.select("#barplot-container")
        .append("svg")
          .attr("viewBox", [0, 0, (this.barplotDimensions.width), (this.barplotDimensions.height)].join(' '))
          .attr("width", "100%")
          .attr("height", "100%")
          .attr("id", "barplot-svg")

      // assign role for accessibility
      barplotSVG.attr("role", "figure")
        .attr("tabindex", 0)
        .attr("contenteditable", "true")
        .append("title")
        .text("Sources of water used by bottling facilities")

      // Add group for bounds
      this.barplotBounds = barplotSVG.append("g")
        .style("transform", `translate(${
          this.barplotDimensions.margin.left
        }px, ${
          this.barplotDimensions.margin.top
        }px)`)

      // scale for the x-axis
      this.xScale = this.d3.scaleBand()
        .domain(data.map(d => d.WB_TYPE).sort(this.d3.ascending))
        .range([0, this.barplotDimensions.boundedWidth])
        .padding(0.1);

      // x-axis
      this.barplotBounds.append("g")
        .attr("transform", `translate(0,${this.barplotDimensions.boundedHeight})`)
        .attr("role", "presentation")
        .attr("aria-hidden", true)
        .call(this.d3.axisBottom(this.xScale))
        .selectAll("text")
        .style("text-anchor", "middle");

      this.barplotBounds.append("g")
        .attr("class", "rects")
        .attr("role", "list")
        .attr("tabindex", 0)
        .attr("contenteditable", "true")
        .attr("aria-label", "bar plot bars")
    },
    makeColorScale(data) {
      const self = this;

      const categoryColors = {
        'public supply': '#E2A625',
        'surface water intake': '#213958',
        'spring': '#3f6ca6',
        'well': '#90aed5',
        'combination': '#787979',
        'undetermined': '#D4D4D4'
      };

      const waterSources = Array.from(new Set(data.map(d => d.water_source)));
      const colorScale = this.d3.scaleOrdinal()
        .domain(waterSources)
        .range(waterSources.map(category => categoryColors[category]));

      return colorScale;
    },
    drawBarplot(data, colorScale, currentSummaryType) {
      const self = this;

      // Accessor function
      const xAccessor = d => d.WB_TYPE
      const yAccessor = d => currentSummaryType === 'Count' ? parseInt(d.site_count) : d.percent // # values in each bin
      const colorAccessor = d => d.water_source

      const yScale = this.d3.scaleLinear()
        .domain([0, this.d3.max(data, yAccessor)]) // use y accessor w/ raw data
        .range([this.barplotDimensions.boundedHeight, 0])
        .nice()

      // y-axis
      this.barplotBounds.append("g")
        .attr("class", "y-axis")
        .attr("role", "presentation")
        .attr("aria-hidden", true)
        .call(this.d3.axisLeft(yScale))

      const rectGroups = self.barplotBounds.selectAll(".rects")
        .selectAll(".rect")
        .data(data, d => d.WB_TYPE)
        .enter().append("g")
        .attr("class", d => "rect " + xAccessor(d) + " " + colorAccessor(d))

      rectGroups.append("rect") 
        .attr("x", d => this.xScale(xAccessor(d)))
        .attr("y", d => yScale(yAccessor(d))) //this.barplotDimensions.boundedHeight
        .attr("width", this.xScale.bandwidth())
        .attr("height", d => this.barplotDimensions.boundedHeight - yScale(yAccessor(d))) //0
        .style("fill", d => colorScale(colorAccessor(d)))
    },
    addLegend() {

    }
  }
}
</script>
<style lang="scss">
// Elements added w/ D3
</style>
<style scoped lang="scss">

</style>