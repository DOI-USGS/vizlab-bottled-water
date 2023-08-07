<template>
  <div id="grid-container">
    <div id="map-container">
        <div id="title">
            <h3> Bottling facilities in 
              <Dropdown v-model="selectedOption" :options="dropdownOptions"/>
            </h3>
        </div>
    </div>
  </div>
</template>
<script>
import * as d3Base from 'd3';
import { csv } from 'd3';
import { isMobile } from 'mobile-device-detect';
import Dropdown from '@/components/Dropdown.vue'
import { ref, onMounted } from 'vue'

export default {
  name: "OCONUS",
    components: {
      Dropdown
    },
    props: {
      data: Object
    },
    data() {
      return {
        selectedOption: 'all states and territories',
        dropdownOptions: [],

        d3: null,
        publicPath: import.meta.env.BASE_URL, // find the files when on different deployment roots
        mobileView: isMobile, // test for mobile
        statePolyJSON: null,
        countyPolyJSON: null,
        countyPointJSON: null,
        dataRaw: null,
      }
  },
  mounted(){      
    this.d3 = Object.assign(d3Base);

    const self = this;
    this.loadData() // read in data 
 
  },
  setup() {
    const self = this;
    const selectedOption = ref('')
    const dropdownOptions = ref([])
    publicPath = import.meta.env.BASE_URL;

    onMounted(async () => {
      const data = await csv(self.publicPath + 'state_facility_type_summary.csv')

      // Assuming the column name in the CSV is 'name'
      dropdownOptions.value = data.map(d => d.state_name)
    })

    return { selectedOption, dropdownOptions }
  },
  /* computed: {
    computedDropdownOptions() {
      const dataAll = this.dataRaw

      // get list of unique states
      const stateList = [... new Set(dataAll.map(d => d.state_name))]
      return stateList.map(data => `Option: ${data}`)
    }
  }, */
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
          self.d3.json(self.publicPath + "states_poly.geojson"),
          self.d3.json(self.publicPath + "counties_crop_poly.geojson"),
          self.d3.json(self.publicPath + "counties_crop_centroids.geojson"),
          self.d3.csv(self.publicPath + 'state_facility_type_summary.csv')
        ];
        Promise.all(promises).then(self.callback)
      },
      callback(data){
        const self = this;

        // assign data
        this.statePolyJSON = data[0];
        const statePolys = this.statePolyJSON.features;

        this.countyPolyJSON = data[1];
        const countyPolys = this.countyPolyJSON.features;

        this.countyPointJSON = data[2];
        const countyPoints = this.countyPointJSON.features;

        this.dataRaw = data[3];
        const dataAll = this.dataRaw

        // get list of unique states
        const stateList = [... new Set(dataAll.map(d => d.state_name))]
        stateList.unshift('All')
        let currentState = 'All'//stateList[0]
        let currentType = 'All'
        this.dropdownOptions = stateList

     /*    // add dropdown
        const dropdown = this.d3.select("#state-dropdown-container")
          .append("select")
          .attr("class", "dropdown")
          .attr("id", "state-dropdown")
          .on("change", function() { 
            let selectedText = this.options[this.selectedIndex].text;
            this.style.width = 20 + (selectedText.length * 12) + "px";

            drawHistogram(this.value) 
            drawCounties(this.value)
            drawMap(this.value)
            drawCountyPoints(this.value, currentType)
          })

        const dropdownDefaultText = 'all states and territories'
        let titleOption = dropdown.append("option")
          .attr("class", "option title")
          .attr("disabled", "true")
          .text(dropdownDefaultText)

        let stateOptions = dropdown.selectAll("stateOptions")
          .data(stateList)
          .enter()
          .append("option")
          .attr("class", "option stateName")
          .attr("value", d => d)
          .text(d => d)

          var selectId = document.getElementById("state-dropdown");
          let selectedText = selectId.options[selectId.selectedIndex].text;
          selectId.style.width = 20 + (selectedText.length * 8.5) + "px"; */

          // set universal map frame dimensions
          const map_width = 900
          let mapDimensions = {
            width: map_width,
            height: map_width * 0.65,
            margin: {
              top: 20,
              right: 5,
              bottom: 5,
              left: 5
            }
          }
          mapDimensions.boundedWidth = mapDimensions.width - mapDimensions.margin.left - mapDimensions.margin.right
          mapDimensions.boundedHeight = mapDimensions.height - mapDimensions.margin.top - mapDimensions.margin.bottom
          
          // define histogram dimensions
          const width = 400;
          let dimensions = {
            width,
            height: width*0.9,
            margin: {
              top: 30,
              right: 10,
              bottom: 50,
              left: 50
            }
          }
          dimensions.boundedWidth = dimensions.width - dimensions.margin.left - dimensions.margin.right
          dimensions.boundedHeight = dimensions.height - dimensions.margin.top - dimensions.margin.bottom

          // draw canvas for map
          const wrapper = this.d3.select("#map-container")
            .append("svg")
              .attr("viewBox", [0, 0, (mapDimensions.width), (mapDimensions.height)].join(' '))
              .attr("width", "100%")
              .attr("height", "100%")
              // .attr("width", mapDimensions.width)
              // .attr("height", mapDimensions.height)
              .attr("id", "map-svg")

          // assign role for accessibility
          wrapper.attr("role", "figure")
            .attr("tabindex", 0)
            .append("title")

          const mapBounds = wrapper.append("g")
            .style("transform", `translate(${
              mapDimensions.margin.left
            }px, ${
              mapDimensions.margin.top
            }px)`)
            .attr("id", "map-bounds")

          // init static elements for map
          const mapProjection = this.d3.geoAlbers()
            .center([0, 38])
            .rotate([96, 0, 0])
            .parallels([29.5, 45.5])
            .scale(1200) // alabama : 3500 1200
            .translate([mapDimensions.width / 2, mapDimensions.height / 2]); // alabama : [-mapDimensions.width / 4, 20]

          const mapPath = this.d3.geoPath()
            .projection(mapProjection);

          mapBounds.append("g")
            .attr("class", "counties")
            .attr("role", "list")
            .attr("tabindex", 0)
            .attr("aria-label", "county polygons")

          mapBounds.append("g")
            .attr("class", "states")
            .attr("role", "list")
            .attr("tabindex", 0)
            .attr("aria-label", "state polygons")

          mapBounds.append("g")
            .attr("class", "county_centroids")
            .attr("role", "list")
            // .attr("tabindex", 0)
            .attr("aria-label", "county centroids")

          // draw canvas for histogram
          const chartSVG = this.d3.select("#map-container")
            .append("svg")
              .attr("viewBox", [0, 0, (dimensions.width), (dimensions.height)].join(' '))
              .attr("width", "100%")
              .attr("height", "100%")
              // .attr("width", dimensions.width)
              // .attr("height", dimensions.height)
              .attr("id", "chart-svg")

          // assign role for accessibility
          chartSVG.attr("role", "figure")
            .attr("tabindex", 0)
            .append("title")

          const bounds = chartSVG.append("g")
            .style("transform", `translate(${
              dimensions.margin.left
            }px, ${
              dimensions.margin.top
            }px)`)
          
          // init static elements for histogram
          bounds.append("g")
              .attr("class", "rects")
              .attr("role", "list")
              .attr("tabindex", 0)
              .attr("aria-label", "bar chart bars")
          bounds.append("g")
              .attr("class", "x-axis")
              .style("transform", `translateY(${
                dimensions.boundedHeight
              }px)`)
              .attr("role", "presentation")
              .attr("aria-hidden", true)
            .append("text")
              .attr("class", "x-axis-label")
              .attr("x", dimensions.boundedWidth / 2)
              .attr("y", dimensions.margin.bottom - 10)
              .style("fill", "black")
              .style("text-anchor", "middle")
              .style("font-size", "1.4em")
              .attr("role", "presentation")
              .attr("aria-hidden", true)
          bounds.append("g")
            .attr("class", "y-axis")


          const drawHistogram = (state) => {
            let data;
            let dataTypes = [... new Set(dataAll.map(d => d.WB_TYPE))]
            if (state === 'All') {
              let dataArray = []
              dataTypes.forEach(function(type) {
                let totalCount = dataAll
                  .filter(d => d.WB_TYPE === type)
                  .map(d => parseInt(d.site_count))
                  .reduce(function(acc, value) {
                    return acc + value
                  })
                let dataObj = {
                  state_name: 'All',
                  state_abbr: null,
                  WB_TYPE: type,
                  site_count: totalCount
                }
                dataArray.push(dataObj)
              })
              data = dataArray
            } else {
              data = dataAll.filter(d => 
                d.state_name === state)
            }
            console.log(data)

            // const data = dataAll.filter(d => 
            //   d.state_name === state)
            
            // accessor functions
            const xAccessor = d => d.WB_TYPE
            const yAccessor = d => parseInt(d.site_count) // # values in each bin
            const colorAccessor = d => d.WB_TYPE
            const identifierAccessor = d => d.WB_TYPE.replace(' ', '-')

            //add title
            chartSVG.select("Title")
              .text(`Bar chart of distribution of facility types for ${state}`)

            // create scales   
            const xScale = this.d3.scaleBand()
              .rangeRound([0, dimensions.boundedWidth])
              .domain(dataTypes) // if want to only include types in each state: data.map(d => d.WB_TYPE)
              .padding(0.05)
            
            const yScale = this.d3.scaleLinear()
              .domain([0, this.d3.max(data, yAccessor)]) // use y accessor w/ raw data
              .range([dimensions.boundedHeight, 0])
              .nice()

            const colorScale = this.d3.scaleOrdinal()
              .domain([... new Set(data.map(d => colorAccessor(d)))].sort())
              .range(["darkmagenta","teal","gold","indianred","steelblue","pink"])
            
            // draw data

             const getUpdateTransition = this.d3.transition()
               .duration(1000)
               .delay(1000)
               .ease(this.d3.easeCubicInOut)
             const getExitTransition = this.d3.transition()
               .duration(1000)
               .ease(this.d3.easeCubicInOut)

            let rectGroups = bounds.selectAll(".rects")
              .selectAll(".rect")
              .data(data, d => d.WB_TYPE)        

            const oldRectGroups = rectGroups.exit()

            oldRectGroups.selectAll('rect')
              //.transition(getExitTransition())
              .attr("y", d => dimensions.boundedHeight)
              .attr("height", 0)

            oldRectGroups.selectAll('text')
              //.transition(getExitTransition())
              .attr("y", d => dimensions.boundedHeight)

            //oldRectGroups.transition(getExitTransition()).remove()

            const newRectGroups = rectGroups.enter().append("g")
              .attr("class", d => "rect " + state)
              .attr("id", d => 'rect-group-' + identifierAccessor(d))
              .attr("tabindex", "0")
              .attr("role", "listitem")
              .attr("aria-label", d => `There are ${
                yAccessor(d)
              } ${
                xAccessor(d)
              } facilities in ${
                state
              }`)

            // append rects and set default y and height, so that when appear, come up from bottom
            newRectGroups.append("rect") 
              .attr("x", d => xScale(xAccessor(d)))
              .attr("y", dimensions.boundedHeight)
              .attr("width", xScale.bandwidth())
              .attr("height", 0)
              .style("fill", d => colorScale(colorAccessor(d)))
            
              // append text and set default position
            newRectGroups.append("text")
              .attr("x", d => xScale(xAccessor(d)) + xScale.bandwidth()/2)
              .attr("y", dimensions.boundedHeight)
            
            // update rectGroups to include new points
            rectGroups = newRectGroups.merge(rectGroups)

            const barRects = rectGroups.select("rect")
            
            barRects//.transition(getUpdateTransition())
                .attr("id", d => 'rect-' + identifierAccessor(d))
                .attr("x", d => xScale(xAccessor(d)))
                .attr("y", d => yScale(yAccessor(d)))
                .attr("width", xScale.bandwidth()) // if negative, bump up to 0
                .attr("height", d => dimensions.boundedHeight - yScale(yAccessor(d)))
                .attr("fill", d => colorScale(colorAccessor(d)))
                .attr("class", d => 'bar ' + identifierAccessor(d))
            
            barRects
              .on("click", (event, d) => {
                currentType = colorAccessor(d)
                let currentIdentifier = currentType.replace(' ', '-')
                drawCountyPoints(state, currentType)
               console.log(currentIdentifier)
               this.d3.selectAll('.bar')
                  .style("opacity", 0.5)

               this.d3.selectAll('#rect-' + currentIdentifier)
                  .style("opacity", 1)
              })
              .on("mouseover", (event, d) => {
                currentType = colorAccessor(d)
                let currentIdentifier = currentType.replace(' ', '-')
                drawCountyPoints(state, currentType)

               this.d3.selectAll('.bar')
                  //.transition(getUpdateTransition())
                  .style("opacity", 0.5)

               this.d3.selectAll('#rect-' + currentIdentifier)
                  //.transition(getUpdateTransition())
                  .style("opacity", 1)
              })
              .on("mouseout", (event, d) => {
                currentType = 'All'
                drawCountyPoints(state, currentType)

               this.d3.selectAll('.bar')
                  //.transition(getUpdateTransition())
                  .style("opacity", 1)
              })

            // Trigger with enter key - BUT - how get back to total?
            console.log(rectGroups)
            console.log(newRectGroups)
            rectGroups.each(function() {
              this.addEventListener("keypress", function(event) {
                  if (event.key === 'Enter' | event.keyCode === 13) {
                    let targetId = event.target.id
                    let targetIdSplit = targetId.split('-')
                    let targetType = targetIdSplit.length === 4 ? (targetIdSplit[2] + ' ' + targetIdSplit[3]) : targetIdSplit[2]
                    drawCountyPoints(state, targetType)
                  }
              })
            })

            const barText = rectGroups.select("text")
             // .transition(getUpdateTransition())
                .attr("x", d => xScale(xAccessor(d)) + xScale.bandwidth()/2)
                .attr("y", d => yScale(yAccessor(d)) - 5)
                .style("text-anchor", "middle")
                .text(yAccessor)
                .attr("fill", "#666")
                .style("font-size", "12px")
                .style("font-family", "sans-serif")

            const xAxisGenerator = this.d3.axisBottom()
              .scale(xScale)

            const xAxis = bounds.select(".x-axis")

            xAxis
              // .transition(getUpdateTransition())
              .call(xAxisGenerator)
              .select(".domain").remove()

            xAxis.selectAll(".tick line").attr("stroke", "None")

            const xAxisLabel = xAxis.select(".x-axis-label")

            if (state === 'All') {
              xAxisLabel
              .text('Distribution of facility types nationally')
            } else {
              xAxisLabel
                .text(`Distribution of facility types in ${
                  state
                }`)
            }

            // const yAxisGenerator = d3.axisLeft()
            //   .scale(yScale)

            // const yAxis = bounds.select(".y-axis")
            //   .transition(getUpdateTransition())
            //   .call(yAxisGenerator)
            //   .attr("role", "presentation")
            //   .attr("aria-hidden", true)

          }
          
          const drawMap = (state) => {
            let data = statePolys
            if (state === 'All') {
              data = statePolys
            } else {
              data = statePolys.filter(d => 
                d.properties.NAME === state)
            }

            // // set transitions
            // const updateTransition = d3.transition()
            //   .duration(1000)
            //   .delay(1000)
            //   .ease(d3.easeCubicInOut)

            // const exitTransition = d3.transition()
            //   .duration(1000)
            //   .ease(d3.easeCubicInOut)

            let stateGroups = mapBounds.selectAll(".states")
              .selectAll(".state")
              .data(data, d => d.properties.GEOID)

            const oldStateGroups = stateGroups.exit()

            oldStateGroups.selectAll('path')
              //.transition(getExitTransition())
              .style("stroke", "#ffffff")
              .style("fill", "#ffffff")

            // oldStateGroups.transition(getExitTransition()).remove()

            const newStateGroups = stateGroups.enter().append("g")
              .attr("class", "state")
              .attr("id", d => 'state-group-' + d.properties.GEOID)
              .attr("tabindex", "0")
              .attr("role", "listitem")
              .attr("aria-label", d => d.properties.NAME)

            newStateGroups.append("path")
              .attr("class", "state-paths")
              .attr("id", d => "state-" + d.properties.GEOID)
              .attr("d", mapPath)
              .style("stroke", "None")
              .style("stroke-width", 0)
              .style("fill", "None")

            stateGroups = newStateGroups.merge(stateGroups)

            const stateShapes = stateGroups.select("path")

            if (!(state === "All")) {
              let selectedStateId = data[0].properties.GEOID
              this.d3.selectAll('#state-group-'+ selectedStateId)
                .raise()
              stateShapes
               // .transition(getUpdateTransition())
                .style("fill", "None")
                .style("stroke", "#636363")
                .style("stroke-width", 1)
            } else {
              stateShapes
               // .transition(getUpdateTransition())
                .style("stroke", "#949494") //#636363
                .style("stroke-width", 0.5)
                .style("fill", "None")
            }
            

            // const allStates = d3.selectAll(".state-paths")
            // if (currentState === 'All') {
            //   allStates
            //     .style("stroke", "#949494") //#636363
            //     .style("stroke-width", 0.5)
            //     .style("fill", "#ffffff")
            // } else {
            //   allStates
            //     .style("stroke", "#949494") //#636363
            //     .style("stroke-width", 0.5)
            //     .style("fill", "#ffffff")
            // }

            // // style ALL state paths identically
            // const allStates = d3.selectAll(".state-paths")
            //   .style("stroke", "#949494") //#636363
            //   .style("stroke-width", 0.5)
            //   .style("fill", "#ffffff") // set to none or white to not show other states
            //   .style("opacity", 0)
            //   .style("stroke-opacity", 1)

            // // If a single state is selected, highlight that state
            // if (!(state === 'All')) {
            //   const selectedStateData = data.filter(d => d.properties.NAME === state)
            //   console.log(selectedStateData)
            //   const selectedStateId = selectedStateData[0].properties.GEOID

            //   const selectedStateGroup = d3.selectAll('#state-group-'+ selectedStateId)
            //     .raise()

            //   stateShapes
            //     .transition(getUpdateTransition())
            //     .style("fill", "#ffffff")
            //     .style("stroke", "#ffffff")

            //   const selectedState = d3.selectAll('#state-'+ selectedStateId)
            //     .transition(getUpdateTransition())
            //     .style("fill", "None")
            //     .style("stroke", "#636363")
            //     .style("stroke-width", 1)
              
            //   currentState = state
            // }

            // // would need to add separate group w/ states on TOP of counties and county
            // // points just to trigger interaction on THIS group of states
            // // ideally would use <use>
            // if (state === 'All') {
            //   stateShapes
            //     .on("mouseover", (event, d) => {
            //       console.log(d)
            //       d3.selectAll("#state-" + d.properties.GEOID)
            //         .style("opacity", 1)
            //         .style("stroke-opacity", 1)
            //     })
            //     .on("mouseout", (event, d) => {
            //       d3.selectAll("#state-" + d.properties.GEOID)
            //         .style("opacity", 0)
            //         .style("stroke-opacity", 1)
            //     })
            // }

          }

          const drawCounties = (state) => {
            let data;
            if (state === 'All') {
              data = countyPolys
            } else {
              data = countyPolys.filter(d => 
                d.properties.STATE_NAME === state)
            }

            // // set transitions
            // const updateTransition = d3.transition()
            //   .duration(1000)
            //   .delay(1000)
            //   .ease(d3.easeCubicInOut)

            // const exitTransition = d3.transition()
            //   .duration(1000)
            //   .ease(d3.easeCubicInOut)
            
            let countyGroups = mapBounds.selectAll(".counties")
              .selectAll(".county")
              .data(data, d => d.properties.GEOID)

            const oldCountyGroups = countyGroups.exit()

            oldCountyGroups.selectAll('path')
              //.transition(getExitTransition())
              .style("stroke", "None")
              .style("fill", "None")

            //oldCountyGroups.transition(getExitTransition()).remove()

            const newCountyGroups = countyGroups.enter().append("g")
                .attr("class", "county")
                .attr("id", d => "county-group-" + d.properties.GEOID)
                .attr("tabindex", "0")
                .attr("role", "listitem")
                .attr("aria-label", d => d.properties.NAMELSAD + ', ' + d.properties.STATE_NAME)

            newCountyGroups.append("path")
                .attr("id", d => "county-" + d.properties.GEOID)
                .attr("d", mapPath)
                .style("stroke", "None")
                .style("stroke-width", 0)
                .style("fill", "None")

            countyGroups = newCountyGroups.merge(countyGroups)

            const countyShapes = countyGroups.select("path")
            
            if (!(state === "All")) {
              countyShapes//.transition(getUpdateTransition())
                  .attr("d", mapPath)
                  .style("stroke", "#939393") //D1D1D1
                  .style("stroke-width", 0.1)
                  .style("fill", "#ffffff")
            } else {
              countyShapes//.transition(getUpdateTransition())
                  .attr("d", mapPath)
                  .style("stroke", "#D1D1D1") //D1D1D1
                  .style("stroke-width", 0.1)
                  .style("fill", "#ffffff")
            }

            // Add county mouseover if at state level
            if (!(state === 'All')) {
              countyShapes
                .on("mouseover", (event, d) => {
                  this.d3.selectAll("#county-" + d.properties.GEOID)
                    .style("fill", "#D1D1D1")
                })
                .on("mouseout", (event, d) => {
                  this.d3.selectAll("#county-" + d.properties.GEOID)
                    .style("fill", "#ffffff")
                })
            }
          }
          
          const drawCountyPoints = (state, type) => {
            let dataPoints;
            if (state === 'All') {
              dataPoints = countyPoints.filter(d => 
                d.properties.WB_TYPE === type)
            } else {
              dataPoints = countyPoints.filter(d => 
                d.properties.STATE_NAME === state && d.properties.WB_TYPE === type)
            }

            const sizeAccessor = d => parseInt(d.properties.site_count)
            const colorAccessor = d => d.properties.WB_TYPE

            // create scales   
            const sizeScale = this.d3.scaleLinear()
              .rangeRound([0.7, 10])
              .domain([1, this.d3.max(dataPoints, sizeAccessor)])
            
            const colorScale = this.d3.scaleOrdinal()
              .domain([... new Set(countyPoints.map(d => colorAccessor(d)))].sort())
              .range(["grey", "darkmagenta","teal","gold","indianred","steelblue","pink"])
            
            // // set transitions
            // const updateTransition = d3.transition()
            //   .duration(1000)
            //   .delay(1000)
            //   .ease(d3.easeCubicInOut)
          
            // const exitTransition = d3.transition()
            //   .duration(1000)
            //   .ease(d3.easeCubicInOut)

            // county centroids
            let countyCentroidGroups = mapBounds.selectAll(".county_centroids")
              .selectAll(".county_centroid")
              .data(dataPoints, d => d.properties.GEOID)

            const oldCountyCentroidGroups = countyCentroidGroups.exit()

            oldCountyCentroidGroups.selectAll('path')
              //.transition(getExitTransition())
              .attr("d", mapPath.pointRadius(0))

            //oldCountyCentroidGroups.transition(getExitTransition()).remove()

            const newCountyCentroidGroups = countyCentroidGroups.enter().append("g")
              .attr("class", "county_centroid")
              .attr("id", d => "county-point-group" + d.properties.GEOID)
              .attr("tabindex", "0")
              .attr("role", "listitem")
              .attr("aria-label", d => `There are ${
                sizeAccessor(d)
              } facilities in ${
                d.properties.site_count
              }`)
          
            // append rects and set default y and height, so that when appear, come up from bottom
            newCountyCentroidGroups.append("path")
              .attr("id", d => "county-point-" + d.properties.GEOID)
              .attr("d", mapPath.pointRadius(0))
              .style("fill", d => colorScale(colorAccessor(d)))
              .style("stroke", "#ffffff")

            // update rectGroups to include new points
            countyCentroidGroups = newCountyCentroidGroups.merge(countyCentroidGroups)

            const countyCentroidPoints = countyCentroidGroups.select("path")

            countyCentroidPoints
              //.transition(getUpdateTransition())
                .attr("d", mapPath.pointRadius(d => sizeScale(sizeAccessor(d))))
                .style("stroke", "#ffffff")
                .style("stroke-width", 0.5)
                .style("fill", d => colorScale(colorAccessor(d)))


            // // Add county mouseover if at state level
            // if (!(state === 'All')) {
            //   countyCentroidPoints
            //     .on("mouseover", (event, d) => {
            //       d3.selectAll("#county-" + d.properties.GEOID)
            //         .style("fill", "#D1D1D1")
            //       d3.selectAll("#county-point-" + d.properties.GEOID)
            //         .style("fill", "#000000")
            //     })
            //     .on("mouseout", (event, d) => {
            //       d3.selectAll("#county-" + d.properties.GEOID)
            //         .style("fill", "#ffffff")
            //       d3.selectAll("#county-point-" + d.properties.GEOID)
            //         .style("fill", d => colorScale(colorAccessor(d)))
            //     })
            // }
          }

          // let selectedStateIndex = 0
          drawHistogram(currentState)
          drawCounties(currentState)
          drawMap(currentState)
          drawCountyPoints(currentState, currentType)

      },

      drawBars() {

      }
    }
}
</script>
<style scoped lang="scss">
// handwriting font
@import url('https://fonts.googleapis.com/css2?family=Nanum+Pen+Script&display=swap');
$writeFont: 'Nanum Pen Script', cursive;

#map-container {
    display: grid;
    grid-template-columns: 2.5fr 1fr;
    grid-template-rows: 0.5fr 3fr;
    grid-template-areas:
      "title title"
      "map chart";
    justify-content: center;
    margin: auto;
    max-width: 1600px;
    //height: 88vh;
    //background-color: blue;
}

#map-svg {
    grid-area: map;
    align-self: center;
    background-color: yellow;
}

#chart-svg {
    grid-area: chart;
    background-color: green;
    align-self: center;
}

#title {
    grid-area: title;
    align-self: center;
    font-size: 20px;
    font-family: sans-serif;
    //background-color: red;
}

.dropdown {
    font-size: 20px;
    /* display: flex;
    flex-direction: row;
    transition: width 2s, height 2s, transform 2s;
    will-change: width; */
}


</style>