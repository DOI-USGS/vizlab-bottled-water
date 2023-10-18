<template>
    <section>
      <div id="grid-container-barplots">
        <div id="toggle-container" />
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
      sourceSummaryCount: null,
      sourceSummaryPerc: null,
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
      
      // Build data series for stacked bar charts
      // Count
      this.sourceSummaryCount = this.d3.stack()
        .keys(this.d3.union(sourceSummary.map(d => d.water_source))) // distinct series keys, in input order
        .value(([, D], key) => D.get(key).site_count) // get value for each series key and stack
        (this.d3.index(sourceSummary, d => d.WB_TYPE, d => d.water_source)); // group by stack then series key
      // Percent
      this.sourceSummaryPerc = this.d3.stack()
        .keys(this.d3.union(sourceSummary.map(d => d.water_source))) // distinct series keys, in input order
        .value(([, D], key) => D.get(key).percent) // get value for each series key and stack
        (this.d3.index(sourceSummary, d => d.WB_TYPE, d => d.water_source)); // group by stack then series key

      // Set default summaryType
      this.summaryType = 'Count'

      // Add toggle
      self.addToggle()

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
        .domain(this.d3.union(data.map(d => d.WB_TYPE).sort(this.d3.ascending)))
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
        'Public supply': '#E2A625',
        'Surface water intake': '#213958',
        'Spring': '#3f6ca6',
        'Well': '#90aed5',
        'Combination': '#787979',
        'Undetermined': '#D4D4D4'
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
      const series = currentSummaryType === 'Count' ? this.sourceSummaryCount : this.sourceSummaryPerc

      let yScale = this.d3.scaleLinear()
        .domain([0, this.d3.max(series, d => this.d3.max(d, d => d[1]))])
        .range([this.barplotDimensions.boundedHeight, 0])
        // .nice()
      
      yScale = currentSummaryType === 'Count' ? yScale.nice() : yScale

      // y-axis
      this.barplotBounds.append("g")
        .attr("class", "y-axis")
        .attr("role", "presentation")
        .attr("aria-hidden", true)
        .call(this.d3.axisLeft(yScale))

      const rectGroups = self.barplotBounds.selectAll(".rects")
        .selectAll(".rect")
        .data(series)
        .enter()
        .append("g")
        .attr("class", d => d.key)

      rectGroups.selectAll('rect')
        .data(D => D.map(d => (d.key = D.key, d)))
        .enter()
        .append("rect") 
        .attr("class", d => d.key + ' ' + d.data[0])
        .attr("x", d => this.xScale(d.data[0]))
        .attr("y", d => yScale(d[1]))
        .attr("width", this.xScale.bandwidth())
        .attr("height", d => yScale(d[0]) - yScale(d[1]))
        .style("fill", d => colorScale(d.key))
    },
    addLegend() {

    },
    addToggle() {
      // https://codepen.io/meijer3/pen/WzweRo

      const self = this;

      const container = this.d3.select('#toggle-container')

      container.append('div')
        .attr('class','graph-buttons-switch')
        .html(self.createSwitch('Count','Percent'))
      
      this.d3.selectAll('.graph-buttons-switch label').on("mousedown touchstart", function(event) {
        var dragger = self.d3.select(this.parentNode)
        var startx = 0
        //d3.event.preventDefault(); // disable text dragging
        dragger
          .on("mousedown touchstart", function(event) {
            startx = self.d3.pointer(event)[0]
            // If start on right, correct
            startx = (startx<dragger.node().getBoundingClientRect().width /2)? startx:startx-(dragger.node().getBoundingClientRect().width /2)

          })
          .on("mousemove touchmove", function(event) {
            var xcoord = self.d3.pointer(event)[0]-startx

            xcoord = ( xcoord > dragger.node().getBoundingClientRect().width /2) ? dragger.node().getBoundingClientRect().width /2 : xcoord
            xcoord = ( xcoord < 0) ? 2 : xcoord
            dragger.select('.graph-buttons-switch-selection').attr('style','left:'+xcoord+'px;');
            
          })
          .on("mouseup touchend", function (event) {
            dragger.on("mousedown touchstart", null)
            dragger.on("touchmove mousemove", null) 
            dragger.on("mouseup touchend", null)
            var xcoord = self.d3.pointer(event)[0]
            // over width of first label? 0 left | 1 right
            var id = (xcoord < dragger.select('label').node().getBoundingClientRect().width) ? 0 : 1;
            
            dragger
              .selectAll('input')
              .filter(function(d, i) { return i == id; }).node().checked = true;

            var chos = dragger.selectAll('input').filter(function(d, i) { return i == id; })
            console.log(chos.node().value, chos.node().checked, self.d3.select('#id_Percent').property('checked'))
            //remove styling
            dragger.select('.graph-buttons-switch-selection').attr('style','');
            
            // Do action
            console.log(`Current selection is ${chos.node().value}`)
          });          
      });
    },
    createSwitch(def,alt){
      var html = '<input type="radio" class="graph-buttons-switch-input" name="'+def+alt+'" value="'+def+'" id="id_'+def+'" checked><label for="id_'+def+'" class="graph-buttons-switch-label graph-buttons-switch-label-off">'+def+'</label><input type="radio" class="graph-buttons-switch-input" name="'+def+alt+'" value="'+alt+'" id="id_'+alt+'"><label for="id_'+alt+'" class="graph-buttons-switch-label graph-buttons-switch-label-on" >'+alt+'</label><span class="graph-buttons-switch-selection"></span>';
      return html
    },
    funct(e) {
      const self = this;

      var r = this.d3.select('#response')
      r.transition().duration(100)
        .style('opacity','0').transition()
      .text(e).transition().duration(100).style('opacity','1')
    }
  }
}
</script>
<style lang="scss">
  // Elements added w/ D3
  .graph-buttons-switch {
    position: relative;
    background: rgba(0, 0, 0, 0.3);
    -webkit-box-shadow: inset 0 1px 3px rgba(0, 0, 0, 0.1), 0 1px rgba(255, 255, 255, 0.1);
    box-shadow: inset 0 1px 3px rgba(0, 0, 0, 0.1), 0 1px rgba(255, 255, 255, 0.1);

      -webkit-touch-callout: none; /* iOS Safari */
      -webkit-user-select: none; /* Safari */
      -khtml-user-select: none; /* Konqueror HTML */
        -moz-user-select: none; /* Firefox */
          -ms-user-select: none; /* Internet Explorer/Edge */
              user-select: none; /* Non-prefixed version, currently
                                    supported by Chrome and Opera */
  }
  .graph-buttons-switch-label {
    position: relative;
    z-index: 2;
    float: left;
    width: 78px;
    line-height: 26px;
    // font-size: 13px;
    // color: rgba(255, 255, 255, 0.85);
    text-align: center;
    cursor: pointer;
  }
  .graph-buttons-switch-label-off {padding-left: 2px;}
  .graph-buttons-switch-label-on {padding-right: 2px;}
  .graph-buttons-switch-input {display: none;}
  .graph-buttons-switch-input:checked + .graph-buttons-switch-label {
    font-weight: bold;
    // color: rgba(0, 0, 0, 0.65);
    /*text-shadow: 0 1px rgba(255, 255, 255, 0.25);*/
    -webkit-transition: 0.15s ease-out;
    -moz-transition: 0.15s ease-out;
    -o-transition: 0.15s ease-out;
    transition: 0.15s ease-out;
  }
  .graph-buttons-switch-input:checked + .graph-buttons-switch-label-on ~ .graph-buttons-switch-selection {left: 80px;}
  .graph-buttons-switch-selection {
    display: block;
    position: absolute;
    z-index: 1;
    top: 2px;
    left: 2px;
    width: 78px;
    height: 22px;
    background: rgba(255, 255, 255,1);
    border-radius: 2px;
    -webkit-box-shadow: inset 0 1px rgba(255, 255, 255,0.6), 0 0 2px rgba(0, 0, 0, 0.3);
    box-shadow: inset 0 1px rgba(255, 255, 255,0.6), 0 0 2px rgba(0, 0, 0, 0.3);
    -webkit-transition: left 0.15s ease-out,background 0.3s;
    -moz-transition: left 0.15s ease-out,background 0.3s;
    -o-transition: left 0.15s ease-out,background 0.3s;
    transition: left 0.15s ease-out,background 0.3s ;
  /* 	transition: background 0.3s ; */
  }
</style>
<style scoped lang="scss">
</style>