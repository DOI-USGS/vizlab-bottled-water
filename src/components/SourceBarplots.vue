<template>
  <section>
    <div id="grid-container-barplots">
      <div
        id="toggle-container"
        class="text-container"
        aria-hidden="true"
      >
        <div class="graph-buttons-switch">
          <input
            id="id_Count"
            type="radio"
            class="graph-buttons-switch-input"
            name="CountPercent"
            value="Count"
            checked
          >
          <label
            id="Count"
            for="id_Count"
            tabindex="0"
            class="graph-buttons-switch-label graph-buttons-switch-label-off"
          >Count</label>
          <input
            id="id_Percent"
            type="radio"
            class="graph-buttons-switch-input"
            name="CountPercent"
            value="Percent"
          >
          <label
            id="Percent"
            for="id_Percent"
            tabindex="0"
            class="graph-buttons-switch-label graph-buttons-switch-label-on"
          >Percent</label>
          <span class="graph-buttons-switch-selection" />
        </div>
        <p v-if="!mobileView">
          of facilities by water source
        </p>
        <p v-if="mobileView">
          of facilities
        </p>
      </div>
      <div id="legend-container" />
      <div id="barplot-container" />
    </div>
  </section>
</template>
<script>
import * as d3Base from 'd3';
import texturesBase from 'textures';
import { isMobile } from 'mobile-device-detect';

export default {
  name: "SupplyBarplots",
  components: {
  },
  data() {
    return {

      d3: null,
      textures: null,
      textureCombination: null,
      publicPath: import.meta.env.BASE_URL, // find the files when on different deployment roots
      mobileView: isMobile, // test for mobile
      sourceSummary: null,
      colorScale: null,
      barplotDimensions: null,
      barplotBounds: null,
      xScale: null,
      yScale: null,
      yAxis: null,
      bars: null
    }
  },
  mounted(){      
    this.d3 = Object.assign(d3Base);
    this.textures = Object.assign(texturesBase);

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
      this.sourceSummary = data[0];

      // ID unique sources
      const waterSources = Array.from(new Set(this.sourceSummary.map(d => d.water_source)));

      // Set default summaryType
      const summaryType = 'Count'

      // Add toggle
      self.addToggle()

      // Initialize barplot
      self.initBarplot(this.sourceSummary)

      // Generate color scale
      this.colorScale = self.makeColorScale(waterSources)

      // Draw legend
      self.addLegend(waterSources)

      // Draw barplot
      self.drawBarplot(summaryType)
    },
    // function to wrap text added with d3 modified from
    // https://stackoverflow.com/questions/24784302/wrapping-text-in-d3
    // which is adapted from https://bl.ocks.org/mbostock/7555321
    wrapHorizontalLabels(text, width) {
      const self = this;
      text.each(function () {
          var text = self.d3.select(this),
              words = text.text().split(/\s+/).reverse(),
              word,
              line = [],
              lineNumber = 0,
              lineHeight = 0.6,
              x = 0,
              y = text.attr("x"), // Use x b/c wrapping horizontal labels
              dy = 0, //parseFloat(text.attr("dy")),
              tspan = text.text(null)
                          .append("tspan")
                          .attr("x", x)
                          .attr("y", y)
                          .attr("dy", dy + "rem");
          while (word = words.pop()) {
              line.push(word);
              tspan.text(line.join(" "));
              if (tspan.node().getComputedTextLength() > width) {
                  line.pop();
                  tspan.text(line.join(" "));
                  line = [word];
                  tspan = text.append("tspan")
                              .attr("x", x)
                              .attr("y", y)
                              .attr("dy", ++lineNumber * lineHeight + dy + "em")
                              .text(word);
              }
          }
      });
    },
    initBarplot(data) {
      const self = this;

      const width = document.getElementById("barplot-container").offsetWidth; // Match #barplot-container settings
      const height = window.innerHeight*0.55; // Match #barplot-container settings
      this.barplotDimensions = {
        width,
        height,
        margin: {
          top: 15,
          right: this.mobileView ? 0 : 5,
          bottom: this.mobileView ? 50 : 30,
          left: this.mobileView ? 30 : 85
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
        .domain(this.d3.union(this.sourceSummary.map(d => d.WB_TYPE).sort(this.d3.ascending)))
        .range([0, this.barplotDimensions.boundedWidth])
        .padding(this.mobileView ? 0.1 : 0.3);

      // x-axis
      const xAxis = this.barplotBounds.append("g")
        .attr("class", "x-axis")
        .attr("transform", `translate(0,${this.barplotDimensions.boundedHeight})`)
        .attr("role", "presentation")
        .attr("aria-hidden", true)

      xAxis
        .call(this.d3.axisBottom(this.xScale).tickSize(0).tickPadding(10))
        .select(".domain").remove()

      xAxis
        .selectAll("text")
        .attr("class", "axis-text")
        .style("text-anchor", "middle")
        // Wrap x-axis labels on mobile
        .call(d => this.mobileView ? self.wrapHorizontalLabels(d, 10) : d);

      // scale for y-axis
      this.yScale = this.d3.scaleLinear()
        .range([this.barplotDimensions.boundedHeight, 0])

      // create y axis generator
      this.yAxis = this.d3.axisLeft()
        .scale(this.yScale)
        .ticks(7)
        .tickSize(- this.barplotDimensions.boundedWidth)

      // y-axis
      this.barplotBounds.append("g")
        .attr("class", "y-axis")
        // On mobile, translate y axis in negative x direction by the left margin
        .attr("transform", this.mobileView ? `translate(-${this.barplotDimensions.margin.left - 4},0)` : "translate(0,0)")
        .attr("role", "presentation")
        .attr("aria-hidden", true)
        .append("text")
          .attr("class", "y-axis axis-title")
          .attr("x", -this.barplotDimensions.boundedHeight / 2)
          .attr("transform", "rotate(-90)")
          .style("text-anchor", "middle")
          .attr("role", "presentation")
          .attr("aria-hidden", true)

      // Add groups for bars
      this.bars = this.barplotBounds.append("g")
        .attr("class", "rects")
        .attr("role", "list")
        .attr("contenteditable", "true")
        .attr("aria-label", "bar plot bars")

      // Add textures - https://riccardoscalco.it/textures/
      this.textureCombination = this.textures.lines().stroke('#6F927C').strokeWidth(5).size(9).orientation("2/8").background("white");;
      barplotSVG.call(this.textureCombination);
    },
    makeColorScale(data) {
      const self = this;

      const categoryColors = {
        'Public supply': '#AB9230',
        'Surface water intake': '#283A70',
        'Spring': '#4365A8',
        'Well': '#8E9CBE',
        'Combination': this.textureCombination.url(),
        'Undetermined': '#D4D4D4'
      }; //Combination base color: '#6F927C'

      const colorScale = this.d3.scaleOrdinal()
        .domain(data)
        .range(data.map(category => categoryColors[category]));

      return colorScale;
    },
    drawBarplot(currentSummaryType) {
      // https://stackoverflow.com/questions/66603432/d3-js-how-to-add-the-general-update-pattern-to-a-stacked-bar-chart

      const self = this;

      // Build data series
      // https://observablehq.com/@d3/stacked-bar-chart/2
      const expressed = currentSummaryType === 'Count' ? 'site_count' : 'ratio'
      const series = this.d3.stack()
        .keys(this.d3.union(this.sourceSummary.map(d => d.water_source))) // distinct series keys, in input order
        .value(([, D], key) => D.get(key)[expressed]) // get value for each series key and stack
        (this.d3.index(this.sourceSummary, d => d.WB_TYPE, d => d.water_source));

      // Update domain of yScale
      this.yScale
        .domain([0, this.d3.max(series, d => this.d3.max(d, d => d[1]))])
      
      // If Count, make 'nice' (adds nice round value at top)
      this.yScale = currentSummaryType === 'Count' ? this.yScale.nice() : this.yScale

      // Redefine scale of y axis
      this.yAxis.scale(this.yScale)

      // Set formatting for y axis
      const countFormat = this.mobileView ? this.d3.format(".2s") : this.d3.format(",")
      // Integrate axis title into label for 20k on mobile
      this.yAxis = currentSummaryType === 'Count' ? this.yAxis.tickFormat((d) => d === 20000 && this.mobileView ? '20k facilities' : countFormat(d)) : this.yAxis.tickFormat(this.d3.format(".0%"))

      // Select y-axis
      const yAxis = this.barplotBounds.select(".y-axis")

      // Re-append axis to chart then remove domain
      yAxis
        .call(this.yAxis)
        .select(".domain").remove()
      
      // Add class to y-axis labels, for styling
      const yAxisText = yAxis
        .selectAll("g")
        .selectAll("text")
        .attr("id", d => currentSummaryType === 'Count' ? "axis-text-" + d : "axis-text-" + d * 100) // label-specific id
        .attr("class", "axis-text")
        .attr("text-anchor", this.mobileView ? "start" : "end")

      // Add class to y-axis ticks, for styling
      yAxis
        .selectAll(".tick line")
        .attr("class", "y-axis-tick")
        .attr("x1", d => {
          // On mobile, use width of label to adjust starting x value of tick line
          const idValue = currentSummaryType === 'Count' ? d : d * 100
          return this.mobileView ? self.d3.select('#axis-text-' + idValue)._groups[0][0].getBBox().width + 1 : 0;
        })
        // On mobile, adjust end value of tick line to account for x transformation of y axis
        .attr("x2", this.mobileView ? this.barplotDimensions.boundedWidth + this.barplotDimensions.margin.left : this.barplotDimensions.boundedWidth)

      // Add title to y-axis
      const axisTitle = currentSummaryType === 'Count' ? 'Number of facilities' : 'Percent of facilities';
      const axisOffset = currentSummaryType === 'Count' ? 25 : 35
      yAxis.select(".y-axis.axis-title")
        .attr("y", - this.barplotDimensions.margin.left + axisOffset)
        .text(this.mobileView ? '' : axisTitle) // Don't add the axis title on mobile

      // Set up transition.
      const dur = 1000;
      const t = this.d3.transition().duration(dur);
      
      // Update groups for bars, assigning data
      const rectGroups = this.bars.selectAll("g")
        .data(series, d => d.key)
        .join(
          enter => enter
              .append("g")
              .attr("class", d => d.key),
          
          null, // no update function

          exit => {
            exit
              .transition()
              .duration(dur / 2)
              .style("fill-opacity", 0)
              .remove();
          }
        )

      // Update bars within groups
      rectGroups.selectAll('rect')
        .data(D => D.map(d => (d.key = D.key, d)))
        .join(
            enter => enter
                .append("rect")
                .attr("class", d => d.key + ' ' + d.data[0])
                .attr("role", "listitem")
                .attr("x", d => this.xScale(d.data[0]))
                .attr("y", d => this.yScale(0))
                .attr("width", this.xScale.bandwidth())
                .attr("height", this.barplotDimensions.boundedHeight - this.yScale(0))
                .style("fill", d => this.colorScale(d.key))
            ,
            null,
            exit => {
              exit
                .transition()
                .duration(dur / 2)
                .style("fill-opacity", 0)
                .remove();
            }
          )
        .transition(t)
        .delay((d, i) => i * 20)
        .attr("aria-label", d => {
          let ariaText = currentSummaryType === 'Count' ? 
            `There are ${d.data[1].get(d.key)[expressed]} ${d.data[0]} facilities with` :
            `${Math.round(d.data[1].get(d.key).percent)} percent of ${d.data[0]} facilities have`
          ariaText = ariaText + ` a water source of ${d.key}`
          return ariaText
        })
        .attr("x", d => this.xScale(d.data[0]))
        .attr("y", d => this.yScale(d[1]))
        .attr("width", this.xScale.bandwidth())
        .attr("height", d => this.yScale(d[0]) - this.yScale(d[1]))
        .style("fill", d => this.colorScale(d.key))
    },
    addLegend(data) {
      const self = this;

      const containerWidth = document.getElementById("legend-container").offsetWidth; // Match #legend-container settings
      const desktopWidth = containerWidth > 870 ? containerWidth : 870
      const width = this.mobileView ? containerWidth : desktopWidth;
      const height = this.mobileView ? 110 : 60;
      const legendDimensions = {
        width,
        height,
        margin: {
          top: 7,
          right: this.mobileView ? 0 : 5,
          bottom: 5,
          left: 0
        }
      }
      legendDimensions.boundedWidth = legendDimensions.width - legendDimensions.margin.left - legendDimensions.margin.right
      legendDimensions.boundedHeight = legendDimensions.height - legendDimensions.margin.top - legendDimensions.margin.bottom

      // draw canvas for legend
      const legendSVG = this.d3.select("#legend-container")
        .append("svg")
          .attr("viewBox", [0, 0, (legendDimensions.width), (legendDimensions.height)].join(' '))
          .attr("width", "100%")
          .attr("height", "100%")
          .attr("id", "legend-svg")
          .attr("aria-hidden", "true")

      const legendRectSize = 15; // Size of legend color rectangles
      const interItemSpacing = this.mobileView ? 15 : 25;
      const intraItemSpacing = 6;

      // Add group for bounds
      const legendBounds = legendSVG.append("g")
        .style("transform", `translate(${
          legendDimensions.margin.left
        }px, ${
          legendDimensions.margin.top
        }px)`)

      // Add legend title
      legendBounds.append("text")
        .text('Water source:')
        .attr("id", "legend-title")
        .attr("y", legendRectSize - intraItemSpacing)
        .attr("alignment-baseline", "middle")
        .attr("dominant-baseline", "middle") // required for Firefox

      // Append group for each legend entry
      const legendGroup = legendBounds.selectAll(".legend-item")
        .data(data)
        .enter()
        .append("g")
        .attr("class", "legend-item")

      // Add rectangles for each group
      legendGroup.append("rect")
        .attr("width", legendRectSize)
        .attr("height", legendRectSize)
        .style("fill", d => this.colorScale(d))

      // Add text for each group
      legendGroup.append("text")
        .attr("class", "legend-text")
        .attr("x", legendRectSize + intraItemSpacing) // put text to the right of the rectangle
        .attr("y", legendRectSize - intraItemSpacing)
        .attr("text-anchor", "start") // left-align text
        .attr("alignment-baseline", "middle") // center text
        .attr("dominant-baseline", "middle") // required for Firefox
        .text(d => d);

      // Position legend groups
      // https://stackoverflow.com/questions/20224611/d3-position-text-element-dependent-on-length-of-element-before
      let selfSupplyStart;
      let selfSupplyEnd;
      const xBuffer = 6; // set xBuffer for use in mobile row x translations
      legendGroup
        .attr("transform", (d, i) => {
          // Compute total width of preceeding legend items, with spacing
          // Start with width of legend title
          const titleWidth = this.d3.select('#legend-title')._groups[0][0].getBBox().width + interItemSpacing;
          
          // Begin right of legend
          let cumulativeWidth = titleWidth;
          if (this.mobileView) {
            // On mobile, only use preceding items in same row to find cumulative width
            // row 1: items 0 and 1
            if (i < 2) {
              for (let j = 0; j < i; j++) {
                cumulativeWidth = cumulativeWidth + legendGroup._groups[0][j].getBBox().width + interItemSpacing;
              }
            }
            // row 2: items 2, 3 and 4
            else if (i < 5) {
              for (let j = 2; j < i; j++) {
                cumulativeWidth = cumulativeWidth + legendGroup._groups[0][j].getBBox().width + interItemSpacing;
              }
            }
            // row 3: item 5 
            else if (i === 5) {
              for (let j = 2; j < i; j++) {
                // Actually storing width of row 2 here, to use to set selfSupplyEnd
                cumulativeWidth = cumulativeWidth + legendGroup._groups[0][j].getBBox().width + interItemSpacing;
              }
            }
          } else {
            // on desktop, iterate through all preceding items to find cumulative width, since all items in 1 row
            for (let j = 0; j < i; j++) {
              cumulativeWidth = cumulativeWidth + legendGroup._groups[0][j].getBBox().width + interItemSpacing;
            }
          }
          
          // If first of self-supply items, store cumulative width
          if (i === 2) {
            selfSupplyStart = this.mobileView ? 0 : cumulativeWidth;
          }
          // If last item, store cumulative width
          if (i === 5) {
            selfSupplyEnd = this.mobileView ? cumulativeWidth - interItemSpacing - titleWidth + xBuffer : cumulativeWidth - interItemSpacing;
          }

          let yTranslation = 0;
          // Determine x and y translation on mobile
          // set y translation for each row
          // adjust row starting position for 2nd and third rows by -titleWidth
          if (this.mobileView) {
            if (i < 2) {
              yTranslation = 0;
            } else if (i < 5) {
              yTranslation = legendRectSize * 2;
              cumulativeWidth = cumulativeWidth - titleWidth + xBuffer;
            } else {
              yTranslation = legendRectSize * 5.75
              cumulativeWidth = xBuffer; // for last item just translate by xBuffer
            } 
          }

          // translate each group by that width and height
          return "translate(" + cumulativeWidth + "," + yTranslation + ")"
        })

        // Append bracket for self-supply items
        // Don't need scale for d3.line() b/c using computed svg units
        const line = this.d3.line()
          .x(d => d.x)
          .y(d => d.y)

        const bracketHeightStart = this.mobileView ? legendRectSize * 3 + intraItemSpacing : legendRectSize + intraItemSpacing;
        const bracketHeightEnd = bracketHeightStart + intraItemSpacing;
        const bracketBuffer = this.mobileView ? xBuffer / 2 : interItemSpacing / 4
        const bracketStart = this.mobileView ? selfSupplyStart + bracketBuffer : selfSupplyStart - bracketBuffer
        
        legendBounds
          .append('path') // add a path to the existing svg
          .datum([
            { x: bracketStart, y: bracketHeightStart},
            { x: bracketStart, y: bracketHeightEnd},
            { x: selfSupplyEnd + bracketBuffer, y: bracketHeightEnd},
            { x: selfSupplyEnd + bracketBuffer, y: bracketHeightStart}
          ])
          .attr('d', line)
          .attr('class', 'bracket')

        // Append group title for self-supply items
        legendBounds.append("text")
          .text('Self-supply')
          .attr("id", "legend-group-title")
          .attr("x", selfSupplyStart + (selfSupplyEnd - selfSupplyStart) / 2)
          .attr("y", bracketHeightEnd + intraItemSpacing)
          .attr("alignment-baseline", "hanging")
          .attr("dominant-baseline", "hanging") // required for Firefox
          .attr("text-anchor", "middle")
    },
    addToggle() {
      // https://codepen.io/meijer3/pen/WzweRo

      const self = this;
      
      const toggleLabels = this.d3.selectAll('.graph-buttons-switch label').on("mousedown touchstart", function(event) {
        const dragger = self.d3.select(this.parentNode)
        let startx = 0;
        let touchEndX = 0;
        
        dragger
          // The touchstart and touchmove events allow the white box to be dragged within the toggle on mobile
          .on("touchstart", function(event) {
            // only triggered on mobile
            startx = self.d3.pointer(event.touches[0])[0]
            // If start on right, correct
            startx = (startx < dragger.select('label').node().getBoundingClientRect().width)? startx : startx - (dragger.select('label').node().getBoundingClientRect().width)
          })
          .on("touchmove", function(event) {
            // only triggered on mobile
            let xcoord = self.d3.pointer(event.touches[0])[0] - startx

            xcoord = ( xcoord > dragger.select('label').node().getBoundingClientRect().width) ? dragger.select('label').node().getBoundingClientRect().width : xcoord
            xcoord = ( xcoord < 0) ? 2 : xcoord
            dragger.select('.graph-buttons-switch-selection').attr('style','left:' + xcoord + 'px;');
            touchEndX = xcoord
          })
          .on("touchend", function (event) {
            // only triggered on mobile
            dragger.on("mousedown touchstart", null)
            dragger.on("touchmove mousemove", null) 
            dragger.on("mouseup touchend", null)
            
            // Get x coordinate of pointer event
            const xcoord = touchEndX

            //  coordinate over width of first label? 0 left | 1 right
            const id = (xcoord < dragger.select('label').node().getBoundingClientRect().width) ? 0 : 1;
            const altID = id === 0 ? 1 : 0

            const chos = dragger.selectAll('input').filter(function(d, i) { return i == id; })
            chos.node().checked = true;
            
            //remove styling
            dragger.select('.graph-buttons-switch-selection').attr('style','');
            
            // Do action
            self.drawBarplot(chos.node().value)
          })
          .on("mouseup", function (event) {
            // triggered on desktop and mobile
            dragger.on("mousedown touchstart", null)
            dragger.on("touchmove mousemove", null) 
            dragger.on("mouseup touchend", null)

            // Get x coordinate of pointer event
            const xcoord = self.d3.pointer(event)[0]

            //  coordinate over width of first label? 0 left | 1 right
            const id = (xcoord < dragger.select('label').node().getBoundingClientRect().width) ? 0 : 1;
            const altID = id === 0 ? 1 : 0

            const chos = dragger.selectAll('input').filter(function(d, i) { return i == id; })
            chos.node().checked = true;
            
            //remove styling
            dragger.select('.graph-buttons-switch-selection').attr('style','');
            
            // Do action
            self.drawBarplot(chos.node().value)
          });          
      });

      toggleLabels.each(function() {
        this.addEventListener("keypress", function(event) {
            if (event.key === 'Enter' | event.keyCode === 13) {
              let targetId = event.target.id

              // Shift toggle
              const chos = document.getElementById("id_" + targetId)
              chos.checked = true;

              // Do action
              self.drawBarplot(targetId)
            }
        })
      })
    }
  }
}
</script>
<style lang="scss">
  // Elements added w/ D3
  .axis-title {
    font-size: 1.6rem;
    fill: #000000;
    font-weight: 700;
  }
  .axis-text {
    font-size: 1.6rem;
    @media screen and (max-width: 600px) {
      font-size: 1.4rem;
    }
  }
  .y-axis-tick {
    stroke: #CCCCCC;
    stroke-width: 0.075rem;
  }
  #legend-title {
    font-size: 1.6rem;
    font-weight: 700;
    @media screen and (max-width: 600px) {
      font-size: 1.4rem;
    }
  }
  .legend-text {
    font-size: 1.6rem;
    @media screen and (max-width: 600px) {
      font-size: 1.4rem;
    }
  }
  #legend-group-title {
    font-size: 1.6rem;
    font-style: italic;
    @media screen and (max-width: 600px) {
      font-size: 1.4rem;
    }
  }
  .bracket {
    stroke: black;
    stroke-width: 0.1rem;
    fill: none;
  }
</style>
<style scoped lang="scss">
  $switchWidth: 7.9rem;
  #grid-container-barplots {
    display: grid;
    grid-template-columns: 1fr;
    grid-template-rows: max-content max-content max-content;
    grid-template-areas:
      "toggle"
      "legend"
      "barplot";
    row-gap: 2rem;
    justify-content: center;
    margin: 2rem auto 1rem auto;
    width: 100%;
    @media screen and (max-height: 770px) {
      width: 100%;
    }
    @media screen and (max-width: 600px) {
      grid-template-rows: max-content max-content max-content;
      grid-template-areas:
      "toggle"
      "legend"
      "barplot";
      width: 100%;
    }
  }
  #toggle-container {
    grid-area: toggle;
    display: flex;
    width: 100%;
  }
  .graph-buttons-switch {
    display: flex;
    height: 2.8rem;
    width: $switchWidth * 2.03;
    border-radius: 0.2rem;
    position: relative;
    margin: 0rem 0.5rem 0rem 0.5rem;
    background: rgba(0, 0, 0, 0.3);
    -webkit-box-shadow: inset 0 0.1rem 0.3rem rgba(0, 0, 0, 0.1), 0 0.1remx rgba(255, 255, 255, 0.1);
    box-shadow: inset 0 0.1rem 0.3rem rgba(0, 0, 0, 0.1), 0 0.1rem rgba(255, 255, 255, 0.1);

      -webkit-touch-callout: none; /* iOS Safari */
      -webkit-user-select: none; /* Safari */
      -khtml-user-select: none; /* Konqueror HTML */
        -moz-user-select: none; /* Firefox */
          -ms-user-select: none; /* Internet Explorer/Edge */
              user-select: none; /* Non-prefixed version, currently
                                    supported by Chrome and Opera */
    @media screen and (max-width: 600px) {
      height: 2.6rem;
    }
  }
  .graph-buttons-switch-label {
    position: relative;
    z-index: 2;
    float: left;
    width: $switchWidth;
    line-height: 2.4rem;
    text-align: center;
    cursor: pointer;
    @media screen and (max-width: 600px) {
      line-height: 2.2rem;
      width: $switchWidth * 1.02;
    }
  }
  .graph-buttons-switch-label-off {
    padding-left: 0.2rem;
    padding-right: 0.2rem;
  }
  .graph-buttons-switch-label-on {
    padding-left: 0.2rem;
    padding-right: 0.2rem;
  }
  .graph-buttons-switch-input {display: none;}
  .graph-buttons-switch-input:checked + .graph-buttons-switch-label {
    font-weight: bold;
    -webkit-transition: 0.3s ease-out;
    -moz-transition: 0.3s ease-out;
    -o-transition: 0.3s ease-out;
    transition: 0.3s ease-out;
  }
  .graph-buttons-switch-input:checked + .graph-buttons-switch-label-on ~ .graph-buttons-switch-selection {left: $switchWidth;}
  .graph-buttons-switch-selection {
    display: block;
    position: absolute;
    z-index: 1;
    top: 0.2rem;
    left: 0.2rem;
    width: $switchWidth;
    height: 2.4rem;
    background: rgba(255, 255, 255,1);
    border-radius: 0.2rem;
    -webkit-box-shadow: inset 0 0.1rem rgba(255, 255, 255,0.6), 0 0 0.2rem rgba(0, 0, 0, 0.3);
    box-shadow: inset 0 0.1rem rgba(255, 255, 255,0.6), 0 0 0.2rem rgba(0, 0, 0, 0.3);
    -webkit-transition: left 0.3s ease-out,background 0.3s;
    -moz-transition: left 0.3s ease-out,background 0.3s;
    -o-transition: left 0.3s ease-out,background 0.3s;
    transition: left 0.3s ease-out,background 0.3s ;
  /* 	transition: background 0.3s ; */
    @media screen and (max-width: 600px) {
      height: 2.2rem;
    }
  }
  #legend-container {
    grid-area: legend;
    width: 90%;
    justify-self: center;
    padding-top: 2rem;
    @media screen and (max-width: 600px) {
      width: 100%;
      padding-top: 1rem;
    }
  }
  #barplot-container {
    grid-area: barplot;
    width: 90%;
    justify-self: center;
    max-height: 55vh;
    @media screen and (max-height: 770px) {
      max-height: 70vh;
    }
    @media screen and (max-width: 600px) {
      width: 100%;
    }
  }
</style>