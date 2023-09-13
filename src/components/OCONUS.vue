<template>
  <section id="oconus_map">
    <div id="grid-container-interactive">
      <div id="title">
        <h4> Counts of bottling facilities in <span id="state-dropdown-container"></span> by county
          <!-- Dropdown v-model="selectedOption" :options="dropdownOptions"/ -->
        </h4>
      </div>
      <div id="text">
        <div class='text-container'>
            <!--p>
              The bottled water industry estimates that the United States consumed 15 billion gallons (57 billion liters) of bottled water in 2020. That’s 45 gallons of bottled water per person. If you consider how much water it takes to produce each bottle of water (not including the packaging), the number is closer to 63 gallons—enough to fill a standard bathtub one-and-a-half times. 
            </p -->
            <p>This map shows the approximate number of bottling facilities in every county where data are available. Use the dropdown menu above to filter the data by state, or click on the facility type in the bar chart below to filter the data by facility type. </p>
        </div>
      </div>
      <div id="chart-container">
      </div>           
      <div id="oconus-container">
      </div>
      <mapLabels 
        id = "map-inset-svg"
        class="map labels"
      />
    </div>
  </section>
</template>
<script>
import * as d3Base from 'd3';
import { csv } from 'd3';
import { isMobile } from 'mobile-device-detect';
// import Dropdown from '@/components/Dropdown.vue'
import { ref, onMounted } from 'vue'
import mapLabels from '@/components/MapLabels.vue'

export default {
  name: "OCONUS",
  components: {
    mapLabels
    // Dropdown
  },
  props: {
    data: Object
  },
  data() {
    return {
      // selectedOption: 'all states and territories',
      dropdownOptions: [],

      d3: null,
      publicPath: import.meta.env.BASE_URL, // find the files when on different deployment roots
      mobileView: isMobile, // test for mobile
      statePolysCONUSJSON: null,
      statePolysAKJSON: null,
      statePolysGUMPJSON: null,
      statePolysHIJSON: null,
      statePolysPRVIJSON: null,
      statePolyASJSON: null,
      statePolys: null,
      countyPolys: null,
      countyPoints: null,
      dataAll: null,
      mapDimensions: null,
      dimensions: null,
      wrapper: null,
      mapBounds: null,
      mapProjection: null,
      mapPath: null,
      mapProjectionAK: null,
      mapPathAK: null,
      mapProjectionHI: null,
      mapPathHI: null,
      mapProjectionPRVI: null,
      mapPathPRVI: null,
      mapProjectionGUMP: null,
      mapPathGUMP: null,
      genericPath: null,
      genericProjection: null,
      chartBounds: null,
      currentType: null,
      stateGroups: null,
      countyGroups: null,
      countyCentroidGroups: null,
      selectedText: null,
      stateList: null,
      currentState: null,
      defaultViewName: null,
      currentlyZoomed: false,
      currentScale: null,
    }
  },
  mounted(){      
    this.d3 = Object.assign(d3Base);

    const self = this;
    this.loadData() // read in data 
 
  },
  setup() {
    const self = this;
    // const selectedOption = ref('')
    // const dropdownOptions = ref([])

    onMounted(async () => {
      // const data = await csv(self.publicPath + 'state_facility_type_summary.csv')

      // Assuming the column name in the CSV is 'name'
      // dropdownOptions.value = data.map(d => d.state_name)
    })

    return { }
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

      // TO-DO use topojson in place of geojsons
      // Keep only essential attribute fields to reduce size
      let promises = [
        self.d3.json(self.publicPath + "states_poly_CONUS.geojson"),
        self.d3.json(self.publicPath + "counties_crop_poly_oconus.geojson"),
        self.d3.json(self.publicPath + "counties_crop_centroids_oconus.geojson"),
        self.d3.csv(self.publicPath + 'state_facility_type_summary.csv'),
        self.d3.json(self.publicPath + "states_poly_AK.geojson"),
        self.d3.json(self.publicPath + "states_poly_GU_MP.geojson"),
        self.d3.json(self.publicPath + "states_poly_HI.geojson"),
        self.d3.json(self.publicPath + "states_poly_PR_VI.geojson"),
        self.d3.json(self.publicPath + "states_poly_AS.geojson")
      ];
      Promise.all(promises).then(self.callback)
    },
    callback(data){
      const self = this;

      // assign data
      this.statePolysCONUSJSON = data[0];
      const statePolysCONUS = this.statePolysCONUSJSON.features;

      const countyPolyJSON = data[1];
      this.countyPolys = countyPolyJSON.features;

      const countyPointJSON = data[2];
      this.countyPoints = countyPointJSON.features;

      this.dataAll = data[3];

      this.statePolysAKJSON = data[4];
      const statePolysAK = this.statePolysAKJSON.features;

      this.statePolysGUMPJSON = data[5];
      const statePolysGUMP = this.statePolysGUMPJSON.features;

      this.statePolysHIJSON = data[6];
      const statePolysHI = this.statePolysHIJSON.features;

      this.statePolysPRVIJSON = data[7];
      const statePolysPRVI = this.statePolysPRVIJSON.features;

      this.statePolysASJSON = data[8];
      const statePolysAS = this.statePolysASJSON.features;

      // TO DO - If area-specific polys (e.g. this.statePolysAK) aren't used for scaling in initMap(), 
      // could simply load in a single geojson of OCONUS + CONUS states
      this.statePolys = statePolysCONUS.concat(statePolysAK, statePolysHI, statePolysGUMP, statePolysPRVI, statePolysAS)

      // set active
      this.defaultViewName = 'all states and territories'
      this.currentState = this.defaultViewName;
      

      // set current scale
      this.currentScale = 1;

      // get list of unique states
      this.stateList = [... new Set(this.dataAll.map(d => d.state_name))]
      this.stateList.unshift(this.defaultViewName)
      
      this.currentType = 'All'
      this.dropdownOptions = this.stateList
      
      // add dropdown
      self.addDropdown(this.stateList)

      // set universal map frame dimensions
      const map_width = 900
      this.mapDimensions = {
        width: map_width,
        height: map_width * 0.75,
        margin: {
          top: 20,
          right: 5,
          bottom: 5,
          left: 5
        }
      }
      this.mapDimensions.boundedWidth = this.mapDimensions.width - this.mapDimensions.margin.left - this.mapDimensions.margin.right
      this.mapDimensions.boundedHeight = this.mapDimensions.height - this.mapDimensions.margin.top - this.mapDimensions.margin.bottom
        
      self.initMap()

      // define histogram dimensions
      const width = 400;
      this.dimensions = {
        width,
        height: width*0.7,
        margin: {
          top: 30,
          right: 10,
          bottom: 50,
          left: 50
        }
      }
      this.dimensions.boundedWidth = this.dimensions.width - this.dimensions.margin.left - this.dimensions.margin.right
      this.dimensions.boundedHeight = this.dimensions.height - this.dimensions.margin.top - this.dimensions.margin.bottom

      self.initChart()

      // Draw initial view ('all states and territories')
      self.drawHistogram(this.currentState)
      self.drawCounties(this.currentState, this.currentScale)
      self.drawMap(this.currentState, this.currentScale)
      self.drawCountyPoints(this.currentState, this.currentScale, this.currentType)

    },
    addDropdown(data) {
      const self = this;

      const dropdownContainer = this.d3.select("#state-dropdown-container")

      const dropdown = dropdownContainer
        .append("select")
        .attr("id", "state-dropdown")
        .attr("class", "dropdown")
        .on("change", function() { 
          this.selectedText = this.options[this.selectedIndex].text;
          this.style.width = 20 + (this.selectedText.length * 12) + "px";

          let selectedArea = this.value

          if (selectedArea === self.defaultViewName) {
            // If dropdown has _changed_ to 'all states and territories' that means we need to reset the map and zoom out
            self.reset()
          } else {
            // If dropdown has _changed_ to a specific state that means we need to zoom into that state
            // The zoom function will take care of redrawing the map and histogram
            let stateData = self.statePolys.filter(d => d.properties.NAME === this.value)
            
            let zoomPath;
            switch(selectedArea) {
              case 'Alaska':
                zoomPath = self.mapPathAK;
                break;
              case 'Hawaii':
                zoomPath = self.mapPathHI;
                break;
              case 'Puerto Rico':
                zoomPath = self.mapPathPRVI;
                break;
              case 'Virgin Islands':
                zoomPath = self.mapPathPRVI;
                break;
              case 'Guam':
                zoomPath = self.mapPathGUMP;
                break;
              case 'Northern Mariana Islands':
                zoomPath = self.mapPathGUMP;
                break;
              case 'American Samoa':
                zoomPath = self.mapPathAS;
                break;
              default:
                zoomPath = self.mapPath;
            }
            
            self.zoomToState(stateData[0], zoomPath, 'dropdown')
          }
          // self.drawHistogram(selectedArea) 
          // self.drawCounties(selectedArea, this.currentScale)
          // self.drawMap(selectedArea, this.currentScale)
          // self.drawCountyPoints(selectedArea, this.currentScale, self.currentType)
        })


      // const dropdownDefaultText = this.defaultViewName
      // let titleOption = dropdown.append("option")
      //   .attr("class", "option title")
      //   .attr("disabled", "true")
      //   .text(dropdownDefaultText)
      //   .append("text")
      //   .text(" ▼")

      let stateOptions = dropdown.selectAll("stateOptions")
        .data(data)
        .enter()
        .append("option")
        .attr("class", "option stateName")
        .attr("value", d => d)
        .text(d => d)

      // set default value
      dropdown.property('value', this.currentState)

      let selectId = document.getElementById("state-dropdown");
      this.selectedText = selectId.options[selectId.selectedIndex].text;
      selectId.style.width = 20 + (this.selectedText.length * 8.5) + "px";
    },
    initMap() {
      // draw canvas for map
      this.wrapper = this.d3.select("#oconus-container")
        .append("svg")
          .attr("viewBox", [0, 0, (this.mapDimensions.width), (this.mapDimensions.height)].join(' '))
          .attr("width", "100%")
          .attr("height", "100%")
          // .attr("width", this.mapDimensions.width)
          // .attr("height", this.mapDimensions.height)
          .attr("id", "map-svg")

      // assign role for accessibility
      this.wrapper.attr("role", "figure")
        .attr("tabindex", 0)
        .append("title")

      this.mapBounds = this.wrapper.append("g")
        .style("transform", `translate(${
          this.mapDimensions.margin.left
        }px, ${
          this.mapDimensions.margin.top
        }px)`)
        .attr("id", "map-bounds")

      // If pre-project, would use generic projection
      // this.genericProjection = this.d3.geoAlbers()
      //   .scale(1)
      //   .translate([0, 0]);

      // this.genericPath = this.d3.geoPath()
      //   .projection(this.genericProjection);

      // Use relative widths and heights to determine placement
      // [[left, bottom], [right, top]]
      const boundsStatePolysCONUS = this.d3.geoBounds(this.statePolysCONUSJSON)
      const conusWidth = boundsStatePolysCONUS[1][0] - boundsStatePolysCONUS[0][0]
      const conusHeight = boundsStatePolysCONUS[1][1] - boundsStatePolysCONUS[0][1]
      
      const boundsStatePolysAK = this.d3.geoBounds(this.statePolysAKJSON)
      const akWidth = (180 - Math.abs(boundsStatePolysAK[1][0])) + (180 - boundsStatePolysAK[0][0])
      const akHeight = boundsStatePolysAK[1][1] - boundsStatePolysAK[0][1]
      const akConusHeightRatio = akHeight/conusHeight
      const akConusWidthRatio = akWidth/conusWidth

      const boundsStatePolysHI = this.d3.geoBounds(this.statePolysHIJSON)
      const hiWidth = boundsStatePolysHI[1][0] - boundsStatePolysHI[0][0]
      const hiConusWidthRatio = hiWidth/conusWidth

      // Get height vars

      const heightX = this.mapDimensions.height / (1 + akConusHeightRatio)
      const conusPropHeight = heightX
      const akPropHeight = conusPropHeight * akConusHeightRatio
      const widthX = this.mapDimensions.width / (1 + hiConusWidthRatio)
      const conusPropWidth = widthX
      const hiPropWidth = conusPropWidth * hiConusWidthRatio
      const akPropWidth = conusPropWidth * akConusWidthRatio

      // Set universal map scale
      const mapScale = 800

      // // Locator map projection
      // const mapProjectionLocator = this.d3.geoOrthographic()
      //   .rotate([139.984, -17.437, 0])
      //   .scale(100)
      //   .translate([this.mapDimensions.width * 0.8, akPropHeight / 3]);

      // const mapPathLocator = this.d3.geoPath()
      //   .projection(mapProjectionLocator);

      // CONUS map projection
      this.mapProjection = this.d3.geoConicEqualArea() 
        .center([0, 38])
        .rotate([96, 0, 0])
        .parallels([29.5, 45.5])
        .scale(mapScale) // alabama : 3500 1200
        .translate([hiPropWidth + conusPropWidth / 2, akPropHeight + conusPropHeight / 2.2]); // alabama : [-this.mapDimensions.width / 4, 20]

      this.mapPath = this.d3.geoPath()
        .projection(this.mapProjection);

      // Alaska map projection
      this.mapProjectionAK = this.d3.geoConicEqualArea()
        .center([0, 64])
        .rotate([151, 0, 0])
        .parallels([58.5, 65])
        .scale(mapScale)
        .translate([akPropWidth / 2.5, akPropHeight / 3]); // alabama : [-this.mapDimensions.width / 4, 20]

      this.mapPathAK = this.d3.geoPath()
        .projection(this.mapProjectionAK);

      // Hawaii map projection
      this.mapProjectionHI = this.d3.geoConicEqualArea()
        .center([0, 20.25])
        .rotate([157, 0, 0])
        .parallels([19.5, 21])
        .scale(mapScale)
        .translate([hiPropWidth, this.mapDimensions.height / 2]); // alabama : [-this.mapDimensions.width / 4, 20]

      this.mapPathHI = this.d3.geoPath()
        .projection(this.mapProjectionHI);

      // Puerto Rico and U.S. Virgin Islands map projection
      this.mapProjectionPRVI = this.d3.geoConicEqualArea()
        .center([0, 18.1])
        .rotate([65.9, 0, 0])
        .parallels([17.9, 18.2])
        .scale(mapScale)
        .translate([this.mapDimensions.width - hiPropWidth, this.mapDimensions.height * 0.92]); // alabama : [-this.mapDimensions.width / 4, 20]

      this.mapPathPRVI = this.d3.geoPath()
        .projection(this.mapProjectionPRVI);

      // Guam and Northern Mariana Islands map projection
      this.mapProjectionGUMP = this.d3.geoConicEqualArea()
        .center([0, 13.4])
        .rotate([-144.75, 0, 0])
        .parallels([13.2, 13.6])
        .scale(mapScale)
        .translate([hiPropWidth, this.mapDimensions.height * 0.8]);

      this.mapPathGUMP = this.d3.geoPath()
        .projection(this.mapProjectionGUMP);

      // American Samoa map projection
      this.mapProjectionAS= this.d3.geoConicEqualArea()
        .center([0, -14.2])
        .rotate([170.1, 0, 0])
        .parallels([-14.3, -14.1])
        .scale(mapScale)
        .translate([hiPropWidth, this.mapDimensions.height * 0.92]);

      this.mapPathAS = this.d3.geoPath()
        .projection(this.mapProjectionAS);

      // Add map groups to svg
      // const locatorMapGroup = this.mapBounds.append("g")
      //   .attr("class", "locator-map")
      //   .attr("role", "figure")

      // locatorMapGroup.selectAll("path")
      //   .data(this.statePolys)
      //   .enter()
      //   .append("path")
      //   .attr("class", "locator-paths")
      //   .attr("id", d => "state-" + d.properties.FIPS)
      //   .attr("d", mapPathLocator)

      this.mapBounds.append("g")
        .attr("class", "counties")
        .attr("role", "list")
        .attr("tabindex", 0)
        .attr("aria-label", "county polygons")

      this.mapBounds.append("g")
        .attr("class", "county_centroids")
        .attr("role", "list")
        // .attr("tabindex", 0)
        .attr("aria-label", "county centroids")

      this.mapBounds.append("g")
        .attr("class", "states")
        .attr("role", "list")
        .attr("tabindex", 0)
        .attr("aria-label", "state polygons")
      
    },
    initChart() {
      // draw canvas for histogram
      const chartSVG = this.d3.select("#chart-container")
        .append("svg")
          .attr("viewBox", [0, 0, (this.dimensions.width), (this.dimensions.height)].join(' '))
          .attr("width", "100%")
          .attr("height", "100%")
          // .attr("width", this.dimensions.width)
          // .attr("height", this.dimensions.height)
          .attr("id", "chart-svg")

      // assign role for accessibility
      chartSVG.attr("role", "figure")
        .attr("tabindex", 0)
        .append("title")

      this.chartBounds = chartSVG.append("g")
        .style("transform", `translate(${
          this.dimensions.margin.left
        }px, ${
          this.dimensions.margin.top
        }px)`)
      
      // init static elements for histogram
      this.chartBounds.append("g")
          .attr("class", "rects")
          .attr("role", "list")
          .attr("tabindex", 0)
          .attr("aria-label", "bar chart bars")
      this.chartBounds.append("g")
          .attr("class", "x-axis")
          .style("transform", `translateY(${
            this.dimensions.boundedHeight
          }px)`)
          .attr("role", "presentation")
          .attr("aria-hidden", true)
        .append("text")
          .attr("class", "x-axis-label")
          .attr("x", this.dimensions.boundedWidth / 2)
          .attr("y", this.dimensions.margin.bottom - 10)
          .style("fill", "black")
          .style("text-anchor", "middle")
          .style("font-size", "1.4em")
          .attr("role", "presentation")
          .attr("aria-hidden", true)
      this.chartBounds.append("g")
        .attr("class", "y-axis")
    },
    drawHistogram(state) {
      const self = this;

      const rawData = this.dataAll

      let data;
      let dataTypes = [... new Set(this.dataAll.map(d => d.WB_TYPE))]
      if (state === this.defaultViewName) {
        let dataArray = []
        dataTypes.forEach(function(type) {
          let totalCount = rawData
            .filter(d => d.WB_TYPE === type)
            .map(d => parseInt(d.site_count))
            .reduce(function(acc, value) {
              return acc + value
            })
          let dataObj = {
            state_name: self.defaultViewName,
            state_abbr: null,
            WB_TYPE: type,
            site_count: totalCount
          }
          dataArray.push(dataObj)
        })
        data = dataArray
      } else {
        data = rawData.filter(d => 
          d.state_name === state)
      }
      
      // accessor functions
      const xAccessor = d => d.WB_TYPE
      const yAccessor = d => parseInt(d.site_count) // # values in each bin
      const colorAccessor = d => d.WB_TYPE
      const identifierAccessor = d => d.WB_TYPE.replace(' ', '-')

      //add title
      this.d3.select("#chart-container").select("Title")
        .text(`Bar chart of distribution of facility types for ${state}`)

      // create scales   
      const xScale = this.d3.scaleBand()
        .rangeRound([0, this.dimensions.boundedWidth])
        .domain(dataTypes) // if want to only include types in each state: data.map(d => d.WB_TYPE)
        .padding(0) //0.05
      
      const yScale = this.d3.scaleLinear()
        .domain([0, this.d3.max(data, yAccessor)]) // use y accessor w/ raw data
        .range([this.dimensions.boundedHeight, 0])
        .nice()

      const colorScale = this.d3.scaleOrdinal()
        .domain([... new Set(data.map(d => colorAccessor(d)))].sort())
        .range(["darkmagenta","teal","gold","indianred","steelblue","pink"])
      
      // draw data
      let rectGroups = self.chartBounds.selectAll(".rects")
        .selectAll(".rect")
        .data(data, d => d.WB_TYPE)        

      const oldRectGroups = rectGroups.exit()

      oldRectGroups.selectAll('rect')
        .transition(self.getExitTransition())
        .attr("y", d => this.dimensions.boundedHeight)
        .attr("height", 0)

      oldRectGroups.selectAll('text')
        .transition(self.getExitTransition())
        .attr("y", d => this.dimensions.boundedHeight)

      oldRectGroups.transition(self.getExitTransition()).remove()

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
        .attr("y", this.dimensions.boundedHeight)
        .attr("width", xScale.bandwidth())
        .attr("height", 0)
        .style("fill", d => colorScale(colorAccessor(d)))
      
      // append text and set default position
      newRectGroups.append("text")
        .attr("x", d => xScale(xAccessor(d)) + xScale.bandwidth()/2)
        .attr("y", this.dimensions.boundedHeight)
      
      // update rectGroups to include new points
      rectGroups = newRectGroups.merge(rectGroups)

      const barRects = rectGroups.select("rect")
      
      barRects.transition(self.getUpdateTransition())
          .attr("id", d => 'rect-' + identifierAccessor(d))
          .attr("x", d => xScale(xAccessor(d)))
          .attr("y", d => yScale(yAccessor(d)))
          .attr("width", xScale.bandwidth()) // if negative, bump up to 0
          .attr("height", d => this.dimensions.boundedHeight - yScale(yAccessor(d)))
          .attr("fill", d => colorScale(colorAccessor(d)))
          .attr("class", d => 'bar ' + identifierAccessor(d))
      
      barRects
        .on("click", (event, d) => {
          this.currentType = colorAccessor(d)
          let currentIdentifier = this.currentType.replace(' ', '-')
          self.drawCountyPoints(state, this.currentScale, this.currentType)

          this.d3.selectAll('.bar')
            .style("opacity", 0.5)

          this.d3.selectAll('#rect-' + currentIdentifier)
            .style("opacity", 1)
        })
        .on("mouseover", (event, d) => {
          this.currentType = colorAccessor(d)
          let currentIdentifier = this.currentType.replace(' ', '-')
          self.drawCountyPoints(state, this.currentScale, this.currentType)

          this.d3.selectAll('.bar')
            .transition(self.getUpdateTransition())
            .style("opacity", 0.5)

          this.d3.selectAll('#rect-' + currentIdentifier)
            .transition(self.getUpdateTransition())
            .style("opacity", 1)
        })

      self.chartBounds.selectAll(".rects")
        .on("mouseleave", (event, d) => {
          this.currentType = 'All'
          self.drawCountyPoints(state, this.currentScale, this.currentType)

          this.d3.selectAll('.bar')
            .transition(self.getUpdateTransition())
            .style("opacity", 1)
        })

      // Trigger with enter key - BUT - how get back to total?
      rectGroups.each(function() {
        this.addEventListener("keypress", function(event) {
            if (event.key === 'Enter' | event.keyCode === 13) {
              let targetId = event.target.id
              let targetIdSplit = targetId.split('-')
              this.currentType = targetIdSplit.length === 4 ? (targetIdSplit[2] + ' ' + targetIdSplit[3]) : targetIdSplit[2]
              self.drawCountyPoints(state, self.currentScale, this.currentType)
              // let currentIdentifier = this.currentType.replace(' ', '-')
              // self.d3.selectAll('.bar')
              //   .transition(self.getUpdateTransition())
              //   .style("opacity", 0.5)

              // self.d3.selectAll('#rect-' + currentIdentifier)
              //   .transition(self.getUpdateTransition())
              //   .style("opacity", 1)
            }
        })
      })

      const barText = rectGroups.select("text")
        .transition(self.getUpdateTransition())
          .attr("x", d => xScale(xAccessor(d)) + xScale.bandwidth()/2)
          .attr("y", d => yScale(yAccessor(d)) - 5)
          .style("text-anchor", "middle")
          .text(yAccessor)
          .attr("fill", "#666")
          .style("font-size", "12px")
          .style("font-family", "sans-serif")

      const xAxisGenerator = this.d3.axisBottom()
        .scale(xScale)

      const xAxis = this.chartBounds.select(".x-axis")

      xAxis
        .transition(self.getUpdateTransition())
        .call(xAxisGenerator)
        .select(".domain").remove()

      xAxis.selectAll(".tick line").attr("stroke", "None")

      const xAxisLabel = xAxis.select(".x-axis-label")

      if (state === this.defaultViewName) {
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

      // const yAxis = this.chartBounds.select(".y-axis")
      //   .transition(self.getUpdateTransition())
      //   .call(yAxisGenerator)
      //   .attr("role", "presentation")
      //   .attr("aria-hidden", true)
    },
    drawMap(state, scale) {
      const self = this;

      let data;
      // let selectedMapPath;
      // let featureBounds;

      if (state === this.defaultViewName) {
        data = this.statePolys
        // selectedMapPath = this.mapPath
        // featureBounds = null;
      // } else if (state === 'Alaska') {
      //   data = this.statePolysAK
      //   selectedMapPath = this.mapPathAK
      //   featureBounds = self.calculateScaleTranslation(data[0], selectedMapPath)
      // } else if (state === 'Puerto Rico' | state === 'Virgin Islands') {
      //   data = this.statePolysPRVI
      //   selectedMapPath = this.mapPath
      //   featureBounds = self.calculateScaleTranslation(data, selectedMapPath)
      } else {
        data = this.statePolys.filter(d => 
          d.properties.NAME === state)
        
        // Could set path for area here
        // let stateMapPath;
        // switch(state) {
        //     case 'Alaska':
        //       stateMapPath =  this.mapPathAK;
        //       break;
        //     case 'Hawaii':
        //       stateMapPath = this.mapPathHI;
        //       break;
        //     case 'Puerto Rico':
        //       stateMapPath = this.mapPathPRVI;
        //       break;
        //     case 'Virgin Islands':
        //       stateMapPath = this.mapPathPRVI;
        //       break;
        //     case 'Guam':
        //       stateMapPath = self.mapPathGUMP;
        //       break;
        //     case 'Northern Mariana Islands':
        //       stateMapPath = self.mapPathGUMP;
        //       break;
        //     case 'American Samoa':
        //       stateMapPath = self.mapPathAS;
        //       break;
        //     default:
        //       stateMapPath = this.mapPath;
        //   }

        // selectedMapPath = this.mapPath
        // featureBounds = self.calculateScaleTranslation(data, selectedMapPath)
      }

      this.stateGroups = this.mapBounds.selectAll(".states")
        .selectAll(".state")
        .data(data, d => d.properties.FIPS)

      const oldStateGroups = this.stateGroups.exit()

      oldStateGroups.selectAll('path')
        .transition(self.getExitTransition())
        .style("stroke", "#ffffff")
        .style("fill", "#ffffff")

      oldStateGroups.remove() //.transition(self.getExitTransition())

      const newStateGroups = this.stateGroups.enter().append("g")
        .attr("class", "state")
        .attr("id", d => 'state-group-' + d.properties.FIPS)
        .attr("tabindex", "0")
        .attr("role", "listitem")
        .attr("aria-label", d => d.properties.NAME)
      
      let stateStrokeWidth = state === this.defaultViewName ? 0.5 : 1 * 2/scale
      let stateStrokeColor = state === this.defaultViewName ? "#949494" : "#636363"
      newStateGroups.append("path")
        .attr("class", "state-paths")
        .attr("id", d => "state-" + d.properties.FIPS)
        .attr("d", d => {
          // let computedBounds = self.calculateScaleTranslation(d, selectedMapPath)
          // // console.log(d.properties.NAME)
          // // console.log(computedBounds)
          // // console.log(this.genericProjection)
          // this.genericProjection
          //   .scale(computedBounds.scale)
          //   .translate(computedBounds.translation)
          // // console.log(this.genericProjection)
          // return this.genericPath(d)
          // return d.properties.NAME === 'Alaska' ? this.mapPathAK(d) : this.mapPath(d)
          switch(d.properties.NAME) {
            case 'Alaska':
              return this.mapPathAK(d);
            case 'Hawaii':
              return this.mapPathHI(d);
            case 'Puerto Rico':
              return this.mapPathPRVI(d);
            case 'Virgin Islands':
              return this.mapPathPRVI(d);
            case 'Guam':
              return this.mapPathGUMP(d);
            case 'Northern Mariana Islands':
              return this.mapPathGUMP(d);
            case 'American Samoa':
              return this.mapPathAS(d);
            default:
              return this.mapPath(d);
          }
        })
        .style("stroke", stateStrokeColor)
        .style("stroke-width", stateStrokeWidth)
        .style("fill", "#ffffff") // "None"
        .style("fill-opacity", 0)
        .on("click", (e, d) => {
          let zoomPath;
          // let zoomPath = d.properties.NAME === 'Alaska' ? this.mapPathAK : selectedMapPath
          switch(d.properties.NAME) {
            case 'Alaska':
              zoomPath = this.mapPathAK;
              break;
            case 'Hawaii':
              zoomPath = this.mapPathHI;
              break;
            case 'Puerto Rico':
              zoomPath = this.mapPathPRVI;
              break;
            case 'Virgin Islands':
              zoomPath = this.mapPathPRVI;
              break;
            case 'Guam':
              zoomPath = this.mapPathGUMP;
              break;
            case 'Northern Mariana Islands':
              zoomPath = this.mapPathGUMP;
              break;
            case 'American Samoa':
              zoomPath = self.mapPathAS;
              break;
            default:
              zoomPath = this.mapPath;
          }
          self.zoomToState(d, zoomPath, 'click')
        })

      this.stateGroups = newStateGroups.merge(this.stateGroups)

      const stateShapes = this.stateGroups.select("path")

      if (!(state === this.defaultViewName)) {
        let selectedStateId = data[0].properties.FIPS
        this.d3.selectAll('#state-group-'+ selectedStateId)
          .raise()
      }

      stateShapes
          .transition(self.getUpdateTransition())
          .style("stroke", stateStrokeColor) //#636363
          .style("stroke-width", stateStrokeWidth)
          .style("fill", "#ffffff") // "None"
          .style("fill-opacity", 0)
      

      // const allStates = d3.selectAll(".state-paths")
      // if (currentState === this.defaultViewName) {
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
      // if (!(state === this.defaultViewName)) {
      //   const selectedStateData = data.filter(d => d.properties.NAME === state)
      //   console.log(selectedStateData)
      //   const selectedStateId = selectedStateData[0].properties.FIPS

      //   const selectedStateGroup = d3.selectAll('#state-group-'+ selectedStateId)
      //     .raise()

      //   stateShapes
      //     .transition(self.getUpdateTransition())
      //     .style("fill", "#ffffff")
      //     .style("stroke", "#ffffff")

      //   const selectedState = d3.selectAll('#state-'+ selectedStateId)
      //     .transition(self.getUpdateTransition())
      //     .style("fill", "None")
      //     .style("stroke", "#636363")
      //     .style("stroke-width", 1)
        
      //   currentState = state
      // }

      // // would need to add separate group w/ states on TOP of counties and county
      // // points just to trigger interaction on THIS group of states
      // // ideally would use <use>
      // if (state === this.defaultViewName) {
      //   stateShapes
      //     .on("mouseover", (event, d) => {
      //       console.log(d)
      //       d3.selectAll("#state-" + d.properties.FIPS)
      //         .style("opacity", 1)
      //         .style("stroke-opacity", 1)
      //     })
      //     .on("mouseout", (event, d) => {
      //       d3.selectAll("#state-" + d.properties.FIPS)
      //         .style("opacity", 0)
      //         .style("stroke-opacity", 1)
      //     })
      // }
    },
    drawCounties(state, scale) {
      const self = this;

      let data; 

      if (state === this.defaultViewName) {
        data = this.countyPolys
      } else {
        data = this.countyPolys.filter(d => 
          d.properties.STATE_NAME === state)
      }
      
      this.countyGroups = this.mapBounds.selectAll(".counties")
        .selectAll(".county")
        .data(data, d => d.properties.GEOID)

      const oldCountyGroups = this.countyGroups.exit()

      oldCountyGroups.selectAll('path')
        .transition(self.getExitTransition())
        .style("stroke", "None")
        .style("fill", "None")

      oldCountyGroups.transition(self.getExitTransition()).remove()

      const newCountyGroups = this.countyGroups.enter().append("g")
          .attr("class", "county")
          .attr("id", d => "county-group-" + d.properties.GEOID)
          .attr("tabindex", "0")
          .attr("role", "listitem")
          .attr("aria-label", d => d.properties.NAME + ', ' + d.properties.STATE_NAME)

      let countyStrokeWidth = state === this.defaultViewName ? 0.1 : 0.5 * 1/scale
      let countyStrokeColor = state === this.defaultViewName ? "#E3E3E3" : "#939393"
      newCountyGroups.append("path")
          .attr("id", d => "county-" + d.properties.GEOID)
          .attr("d", d => {
            // return d.properties.STATE_NAME === 'Alaska' ? this.mapPathAK(d) : this.mapPath(d)
            switch(d.properties.STATE_NAME) {
              case 'Alaska':
                return this.mapPathAK(d);
              case 'Hawaii':
                return this.mapPathHI(d);
              case 'Puerto Rico':
                return this.mapPathPRVI(d);
              case 'Virgin Islands':
                return this.mapPathPRVI(d);
              case 'Guam':
                return this.mapPathGUMP(d);
              case 'Northern Mariana Islands':
                return this.mapPathGUMP(d);
              case 'American Samoa':
                return this.mapPathAS(d);
              default:
                return this.mapPath(d);
          }
          })
          // .attr("d", this.mapPath)
          .style("stroke", countyStrokeColor)
          .style("stroke-width", countyStrokeWidth)
          .style("fill", "None")

      this.countyGroups = newCountyGroups.merge(this.countyGroups)

      const countyShapes = this.countyGroups.select("path")
      
      countyShapes.transition(self.getUpdateTransition())
        .style("stroke", countyStrokeColor)
        .style("stroke-width", countyStrokeWidth)

      // if (!(state === this.defaultViewName)) {
      //   let scaleFactor = 2/scale
      //   countyShapes.transition(self.getUpdateTransition())
      //       .style("stroke", "#939393") //D1D1D1
      //       .style("stroke-width", 0.5 * scaleFactor)
      //       .style("fill", "#ffffff")
      // } else {
      //   countyShapes.transition(self.getUpdateTransition())
      //       .style("stroke", "#D1D1D1") //D1D1D1
      //       .style("stroke-width", 0.1)
      //       .style("fill", "#ffffff")
      // }

      // // Add county mouseover if at state level
      // if (!(state === this.defaultViewName)) {
      //   countyShapes
      //     .on("mouseover", (event, d) => {
      //       this.d3.selectAll("#county-" + d.properties.GEOID)
      //         .style("fill", "#D1D1D1")
      //     })
      //     .on("mouseout", (event, d) => {
      //       this.d3.selectAll("#county-" + d.properties.GEOID)
      //         .style("fill", "#ffffff")
      //     })
      // }
    },
    drawCountyPoints(state, scale, type) {
      const self = this;

      const sizeAccessor = d => parseInt(d.properties.site_count)
      const colorAccessor = d => d.properties.WB_TYPE

      let dataPoints;
      let dataMax;
      if (state === this.defaultViewName) {
        dataPoints = this.countyPoints.filter(d => 
          d.properties.WB_TYPE === type)
        if (type === 'All') {
          dataMax = this.d3.max(this.countyPoints, sizeAccessor) //this.countyPoints OR dataPoints
        } else {
          // let typeSubset = this.countyPoints.filter(d => 
          //   d.properties.WB_TYPE !== 'All')
          dataMax = this.d3.max(this.countyPoints, sizeAccessor) //this.countyPoints OR dataPoints OR typeSubset
        }
        
      } else {
        // Get max value for state, in any category
        let stateData = this.countyPoints.filter(d => 
          d.properties.STATE_NAME === state)
        dataMax =  this.d3.max(stateData, sizeAccessor)
        dataPoints = this.countyPoints.filter(d => 
          d.properties.STATE_NAME === state && d.properties.WB_TYPE === type)
      }

      // create scales   
      let scaleFactor = scale === 1 ? 1 : 2/scale
      
      const sizeScale = this.d3.scaleLinear()
        .range([0.8 * scaleFactor, 10 * scaleFactor]) // .rangeRound
        .domain([1, dataMax]) //this.d3.max(dataPoints, sizeAccessor)

      const colorScale = this.d3.scaleOrdinal()
        .domain([... new Set(this.countyPoints.map(d => colorAccessor(d)))].sort())
        .range(["grey", "darkmagenta","teal","gold","indianred","steelblue","pink"])

      // county centroids
      this.countyCentroidGroups = this.mapBounds.selectAll(".county_centroids")
        .selectAll(".county_centroid")
        .data(dataPoints, d => d.properties.GEOID)

      const oldCountyCentroidGroups = this.countyCentroidGroups.exit()

      oldCountyCentroidGroups.selectAll('path')
        .transition(self.getExitTransition())
        // .attr("d", this.mapPath.pointRadius(0))
        .attr("d", d => {
          switch(d.properties.STATE_NAME) {
            case 'Alaska':
              return this.mapPathAK.pointRadius(0)(d);
            case 'Hawaii':
              return this.mapPathHI.pointRadius(0)(d);
            case 'Puerto Rico':
              return this.mapPathPRVI.pointRadius(0)(d);
            case 'Virgin Islands':
              return this.mapPathPRVI.pointRadius(0)(d);
            case 'Guam':
              return this.mapPathGUMP.pointRadius(0)(d);
            case 'Northern Mariana Islands':
              return this.mapPathGUMP.pointRadius(0)(d);
            case 'American Samoa':
              return this.mapPathAS.pointRadius(0)(d);
            default:
              return this.mapPath.pointRadius(0)(d);
          }
        })

      // CAN'T REMOVE W/ ZOOM, B/C IF REMOVED, RE-ADDED W/O TRANSLATION ON CHART MOUSEOVER
      // oldCountyCentroidGroups.transition(self.getExitTransition()).remove()

      const newCountyCentroidGroups = this.countyCentroidGroups.enter().append("g")
        .attr("class", "county_centroid")
        .attr("id", d => "county-point-group" + d.properties.GEOID)
        .attr("tabindex", "0")
        .attr("role", "listitem")
        .attr("aria-label", d => `There are ${
          sizeAccessor(d)
        } facilities in ${
          d.properties.NAMELSAD
        }`)
    
      // append points
      newCountyCentroidGroups.append("path")
        .attr("id", d => "county-point-" + d.properties.GEOID)
        // // .attr("d", this.mapPath.pointRadius(0))
        // NEED IF REMOVING EXIT POINTS
        // .attr("d", d => {
        //   // return d.properties.STATE_NAME === 'Alaska' ? this.mapPathAK.pointRadius(0)(d) : this.mapPath.pointRadius(0)(d)
        //   switch(d.properties.STATE_NAME) {
        //     case 'Alaska':
        //       return this.mapPathAK.pointRadius(0)(d);
        //     case 'Hawaii':
        //       return this.mapPathHI.pointRadius(0)(d);
        //     case 'Puerto Rico':
        //       return this.mapPathPRVI.pointRadius(0)(d);
        //     case 'Virgin Islands':
        //       return this.mapPathPRVI.pointRadius(0)(d);
        //     case 'Guam':
        //       return this.mapPathGUMP.pointRadius(0)(d);
        //     case 'Northern Mariana Islands':
        //       return this.mapPathGUMP.pointRadius(0)(d);
        //     case 'American Samoa':
        //       return this.mapPathAS.pointRadius(0)(d);
        //     default:
        //       return this.mapPath.pointRadius(0)(d);
        //   }
        // })
        .style("fill", d => colorScale(colorAccessor(d)))
        // .style("stroke", "#ffffff")

      // update rectGroups to include new points
      this.countyCentroidGroups = newCountyCentroidGroups.merge(this.countyCentroidGroups)

      const countyCentroidPoints = this.countyCentroidGroups.select("path")

      countyCentroidPoints
          .transition(self.getUpdateTransition())
          // .attr("d", this.mapPath.pointRadius(d => sizeScale(sizeAccessor(d))))
          .attr("d", d => {
            // return d.properties.STATE_NAME === 'Alaska' ? this.mapPathAK.pointRadius(sizeScale(sizeAccessor(d)))(d) : this.mapPath.pointRadius(sizeScale(sizeAccessor(d)))(d)
            switch(d.properties.STATE_NAME) {
              case 'Alaska':
                return this.mapPathAK.pointRadius(sizeScale(sizeAccessor(d)))(d);
              case 'Hawaii':
                return this.mapPathHI.pointRadius(sizeScale(sizeAccessor(d)))(d);
              case 'Puerto Rico':
                return this.mapPathPRVI.pointRadius(sizeScale(sizeAccessor(d)))(d);
              case 'Virgin Islands':
                return this.mapPathPRVI.pointRadius(sizeScale(sizeAccessor(d)))(d);
              case 'Guam':
                return this.mapPathGUMP.pointRadius(sizeScale(sizeAccessor(d)))(d);
              case 'Northern Mariana Islands':
                return this.mapPathGUMP.pointRadius(sizeScale(sizeAccessor(d)))(d);
              case 'American Samoa':
                return this.mapPathAS.pointRadius(sizeScale(sizeAccessor(d)))(d);
              default:
                return this.mapPath.pointRadius(sizeScale(sizeAccessor(d)))(d);
            }
          })
          // .style("stroke", "#000000")
          // .style("stroke-width", 1)
          .style("fill", d => colorScale(colorAccessor(d)))


      // // Add county mouseover if at state level
      // if (!(state === this.defaultViewName)) {
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
    },
    // define transitions
    getUpdateTransition() {
      return this.d3.transition()
        .duration(500)
        //.delay(500)
        .ease(this.d3.easeCubicInOut)
    },
    getExitTransition() {
      return this.d3.transition()
        .duration(500)
        .ease(this.d3.easeCubicInOut)
    },
    drawBars() {

    },
    calculateScaleTranslation(feature, path) {
      const b = path.bounds(feature)

      const s = .95 / Math.max((b[1][0] - b[0][0]) / this.mapDimensions.width, (b[1][1] - b[0][1]) / this.mapDimensions.height)
      const t = [(this.mapDimensions.width - s * (b[1][0] + b[0][0])) / 2, (this.mapDimensions.height - s * (b[1][1] + b[0][1])) / 2];

      return {
        'scale': s,
        'translation': t
      };
    },
    calculateScaleCenter(features, path, width, height) {
      const self = this;

      // Get the bounding box of the paths (in pixels!) and calculate a
      // scale factor based on the size of the bounding box and the map
      // size.
      var bbox_path = path.bounds(features),
          scale = 0.95 / Math.max(
            (bbox_path[1][0] - bbox_path[0][0]) / width,
            (bbox_path[1][1] - bbox_path[0][1]) / height
          );

      // Get the bounding box of the features (in map units!) and use it
      // to calculate the center of the features.
      var bbox_feature = this.d3.geoBounds(features),
          center = [
            (bbox_feature[1][0] + bbox_feature[0][0]) / 2,
            (bbox_feature[1][1] + bbox_feature[0][1]) / 2];

      return {
        'scale': scale,
        'center': center
      };
    },
    zoomToState(d, path, callMethod) {
      const self = this;
      
      // Store name of selected state
      let zoomedState = d.properties.NAME

      // Determine if need to zoom in or out
      let zoomAction = this.currentState === zoomedState ? 'Zoom out' : 'Zoom in'

      console.log(`You selected ${d.properties.NAME} by ${callMethod}. Currently shown area is ${this.currentState}. This.currentlyZoomed is ${this.currentlyZoomed}. Planned zoom action is ${zoomAction}`)

      // If need to zoom out, zoom out to all states + territories
      if (zoomAction === 'Zoom out') return self.reset();

      // If user clicked on map to zoom
      if (callMethod === 'click') {
        let dropdown = this.d3.select('select')
        // Update dropdown text
        dropdown.property('value', zoomedState)
        // Update dropdown width
        let selectId = document.getElementById("state-dropdown");
        selectId.style.width = 20 + (zoomedState.length * 12) + "px";
      }

      // Hide the inset map borders and labels
      this.d3.select("#map-inset-svg")
        .classed("hide", true)

      // If not already zoomed in
      if (!this.currentlyZoomed) {
        console.log(`this.currentlyZoomed is ${this.currentlyZoomed} and planned zoom action is ${zoomAction}, so going to zoom in from full view`)

        // const [[x0, y0], [x1, y1]] = this.mapPath.bounds(d);
        // event.stopPropagation();

        // function zoomed(event) {
        //   console.log("called zoomed")
        //   const {transform} = event;
        //   console.log(transform)
        //   self.mapBounds.attr("transform", transform);
        //   self.mapBounds.attr("stroke-width", 1 / transform.k);
        //   console.log("transformed mapBounds")
        // }
        
        // const zoom = this.d3.zoom()
        //   // .on('zoom', (event) => {
        //   //   this.mapBounds.attr("transform", event.transform);
        //   // })
        //   .scaleExtent([1, 40])
        //   .on("zoom", zoomed);

        // this.wrapper.transition(self.getUpdateTransition()).call(
        //   zoom.transform,
        //   self.d3.zoomIdentity
        //     .translate(this.mapDimensions.width / 2, this.mapDimensions.height / 2)
        //     .scale(Math.min(8, 0.9 / Math.max((x1 - x0) / this.mapDimensions.width, (y1 - y0) / this.mapDimensions.height)))
        //     .translate(-(x0 + x1) / 2, -(y0 + y1) / 2),
        //   this.d3.pointer(event, this.wrapper.node())
        // );

        const bounds = path.bounds(d),
            dx = bounds[1][0] - bounds[0][0],
            dy = bounds[1][1] - bounds[0][1],
            x = (bounds[0][0] + bounds[1][0]) / 2,
            y = (bounds[0][1] + bounds[1][1]) / 2,
            scale = .9 / Math.max(dx / this.mapDimensions.width, dy / this.mapDimensions.height),
            translate = [this.mapDimensions.width / 2 - scale * x, this.mapDimensions.height / 2 - scale * y];

        // set global scale variable
        this.currentScale = scale;

        self.drawCountyPoints(zoomedState, this.currentScale, this.currentType)
        self.drawCounties(zoomedState, this.currentScale)
        self.drawMap(zoomedState, this.currentScale)
        self.drawHistogram(zoomedState)
        
        // Transition map groups
        this.stateGroups.transition(self.getUpdateTransition)
          .attr("transform", "translate(" + translate + ") scale(" + scale + ")");
          
        this.countyGroups.transition(self.getUpdateTransition)
          .attr("transform", "translate(" + translate + ")scale(" + scale + ")");

        this.countyCentroidGroups.transition(self.getUpdateTransition)
          .attr("transform", "translate(" + translate + ")scale(" + scale + ")");

        // set current state to zoomed state
        this.currentlyZoomed = true;
        this.currentState = zoomedState;
        console.log(`Zoomed in on ${zoomedState}, so this.currentlyZoomed is ${this.currentlyZoomed}`)

      } else {
        // If already zoomed in,
        console.log(`this.currentlyZoomed is ${this.currentlyZoomed} and planned zoom action is ${zoomAction}, so going to zoom out and then in to state`)

        // NEED TO REVAMP - THIS IS MESSY

        // First draw whole map AND zoom out to whole map
        // self.drawHistogram('All')
        self.drawCountyPoints(this.defaultViewName, 1, this.currentType)
        self.drawCounties(this.defaultViewName, 1)
        self.drawMap(this.defaultViewName, 1)

        this.stateGroups
          .attr("transform", "");

        this.countyGroups
          .attr("transform", "");

        this.countyCentroidGroups
          .attr("transform", "");

        // Then zoom in to state and draw state
        const bounds = path.bounds(d),
          dx = bounds[1][0] - bounds[0][0],
          dy = bounds[1][1] - bounds[0][1],
          x = (bounds[0][0] + bounds[1][0]) / 2,
          y = (bounds[0][1] + bounds[1][1]) / 2,
          scale = .9 / Math.max(dx / this.mapDimensions.width, dy / this.mapDimensions.height),
          translate = [this.mapDimensions.width / 2 - scale * x, this.mapDimensions.height / 2 - scale * y];
        
        // set global scale variable
        this.currentScale = scale;

        // redraw map and histogram for state
        self.drawCountyPoints(zoomedState, this.currentScale, this.currentType)
        self.drawCounties(zoomedState, this.currentScale)
        self.drawMap(zoomedState, this.currentScale)
        self.drawHistogram(zoomedState)
        
        // Transition map groups
        this.stateGroups.transition(self.getUpdateTransition)
          .attr("transform", "translate(" + translate + ") scale(" + scale + ")");

        this.countyGroups.transition(self.getUpdateTransition)
          .attr("transform", "translate(" + translate + ")scale(" + scale + ")");

        this.countyCentroidGroups.transition(self.getUpdateTransition)
          .attr("transform", "translate(" + translate + ")scale(" + scale + ")");

        // set current state to zoomed state
        this.currentlyZoomed = true;
        this.currentState = zoomedState;
        console.log(`Zoomed in on ${zoomedState}, so this.currentlyZoomed is ${this.currentlyZoomed}`)
      }
    },
    reset() {
      const self = this;

      this.currentState = this.defaultViewName //this.d3.select(null);
      this.currentScale = 1;

      this.d3.select('select').property('value', this.defaultViewName)
      let selectId = document.getElementById("state-dropdown");
      selectId.style.width = 20 + (this.currentState.length * 8) + "px";

      this.d3.select("#map-inset-svg")
        .classed("hide", false)

      self.drawHistogram(this.defaultViewName)
      self.drawCounties(this.defaultViewName, this.currentScale)
      self.drawMap(this.defaultViewName, this.currentScale)
      self.drawCountyPoints(this.defaultViewName, this.currentScale, this.currentType)

      this.stateGroups.transition(self.getExitTransition)
          .attr("transform", "");

      this.countyGroups.transition(self.getExitTransition)
        .attr("transform", "");

      this.countyCentroidGroups.transition(self.getExitTransition)
        .attr("transform", "");

      this.currentlyZoomed = false;
      console.log(`Zoomed out, so this.currentlyZoomed is ${this.currentlyZoomed}`)
    }
  }
}
</script>
<style lang="scss">
  .bar {
    stroke: white;
    stroke-width: 0.5;
  }
  .county_centroid {
    stroke: white;
    stroke-width: 0.3;
  }
  .dropdown {
    // font-size: 20px;
    // display: flex;
    flex-direction: row;
    transition: width 2s, height 2s, transform 2s;
    will-change: width;
    background-color: white;
    margin: 0px 5px 0px 5px;
    padding: 0.5rem;
    box-shadow:  rgba(0, 0, 0, 0.2) 0px 6px 10px 0px,
    rgba(0, 0, 0, 0.1) 0px 0px 0px 1px;
    border-radius: 5px;
  }
  .dropdown:hover {
    box-shadow:  rgba(0, 0, 0, 0.3) 0px 6px 10px 0px,
    rgba(0, 0, 0, 0.2) 0px 0px 0px 1px;
  }
</style>
<style scoped lang="scss">
  $pal_red: '#FD5901';
  $pal_or: '#F78104';
  $pal_yell: '#FAAB36';
  $pal_teal: '#008083';
  $pal_blue_dark: '#042054';


  #grid-container-interactive {
    display: grid;
    grid-template-columns: 1.5fr 3fr;
    column-gap: 1rem;
    grid-template-rows: 1fr max-content max-content;
    grid-template-areas:
      "title title"
      "text map"
      "chart map";
    justify-content: center;
    margin: auto;
    max-width: 1600px;
  }
  #title {
    grid-area: title;
    align-self: center;
    font-size: 20px;
    font-family: sans-serif;
  }
  #state-dropdown-container {
    grid-area: title;
  }
  #chart-container {
    grid-area: chart;
    align-self: center;
  }
  #oconus-container {
    grid-area: map;
    align-self: center;
  }
  #map-inset-svg {
    grid-area: map;
    pointer-events: none;
    width: 100%;
    height: 100%;
  }
  #text {
    grid-area: text;
    justify-self: start;
  }
  .hide {
    display: none;
  }
</style>