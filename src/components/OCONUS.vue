<template>
  <section id="oconus_map">
    <div id="grid-container-interactive" :class="{ mobile: mobileView}">
      <div id="title">
        <h2 class="grid-title">
          Counts of bottling facilities in <span id="state-dropdown-container" /> by county
        </h2>
      </div>
      <div id="text">
        <div v-if = "!mobileView">
          <p class="viz-comment">
            Click on the dropdown menu, bar chart, or map to explore!
          </p>
          <br>
          <p class="viz-comment" v-if="currentlyZoomed">
            Click on the zoomed map to return to the national view
          </p>
        </div>  
        <div class="text-container" v-if = "mobileView">
          <p class="viz-comment">
            Use the dropdown menu or tap on the bar chart to explore!
          </p>
        </div>
      </div>
      <div id="oconus-container" />
      <div id="chart-container"/>
      <div
        v-if="!mobileView"
        id="map-label-container"
      >
        <mapLabels
          id="map-inset-svg"
          class="map labels"
        />
      </div>
    </div>
  </section>
</template>
<script>
import * as d3Base from 'd3';
import * as topojson from "topojson-client";
import { csv } from 'd3';
import { isMobile } from 'mobile-device-detect';
// import DropdownMenu from '@/components/Dropdown.vue'
import { ref, onMounted } from 'vue'
import mapLabels from '@/components/MapLabels.vue'

export default {
  name: "OCONUS",
  components: {
    mapLabels
    // DropdownMenu
  },
  props: {
    data: Object
  },
  setup() {
    const self = this;

    onMounted(async () => {
    })

    return { }
  },
  data() {
    return {
      d3: null,
      publicPath: import.meta.env.BASE_URL, // find the files when on different deployment roots
      mobileView: isMobile, // test for mobile
      statePolysCONUSJSON: null,
      statePolysAKJSON: null,
      statePolysASJSON: null,
      statePolysGUMPJSON: null,
      statePolysHIJSON: null,
      statePolysPRVIJSON: null,
      statePolysZoom: null,
      statePolys: null,
      countyPolysZoom: null,
      countyPoints: null,
      dataAll: null,
      dataTypes: null,
      mapDimensions: null,
      chartDimensions: null,
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
      yScale: null,
      focalColor: null,
      defaultColor: null,
      currentType: null,
      stateGroups: null,
      countyGroups: null,
      countyCentroidGroups: null,
      selectedText: null,
      stateList: null,
      currentState: null,
      nationalViewName: null,
      currentlyZoomed: false,
      currentScale: null,
    }
  },
  mounted(){
    this.d3 = Object.assign(d3Base);

    const self = this;
    this.loadData() // read in data

  },
  /* computed: {
    computedDropdownOptions() {
      const dataAll = this.dataRaw

      // get list of unique states
      const stateList = [... new Set(dataAll.map(d => d.NAME))]
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
        self.d3.csv(self.publicPath + 'state_facility_type_summary.csv'),
        self.d3.json(self.publicPath + "states_polys_CONUS.json"),
        self.d3.json(self.publicPath + "states_polys_AK.json"),
        self.d3.json(self.publicPath + "states_polys_AS.json"),
        self.d3.json(self.publicPath + "states_polys_GU_MP.json"),
        self.d3.json(self.publicPath + "states_polys_HI.json"),
        self.d3.json(self.publicPath + "states_polys_PR_VI.json"),
        self.d3.json(self.publicPath + "states_polys_CONUS_OCONUS_zoom.json"),
        self.d3.json(self.publicPath + "counties_polys_CONUS_OCONUS_zoom.json"),
        self.d3.json(self.publicPath + "counties_centroids_CONUS_OCONUS.json")
      ];
      Promise.all(promises).then(self.callback)
    },
    callback(data){
      const self = this;

      // Assign data

      // State counts, by type
      this.dataAll = data[0];
      this.dataTypes = [... new Set(this.dataAll.map(d => d.WB_TYPE))]

      // High simplification state polgyons, for national view
      // Loaded separately so that CONUS, AK, and HI jsons can be used
      // to arrange national map view in `initMap()`
      const statePolysCONUStopoJSON = data[1];
      this.statePolysCONUSJSON = topojson.feature(statePolysCONUStopoJSON, statePolysCONUStopoJSON.objects.states_polys_CONUS)
      const statePolysCONUS = this.statePolysCONUSJSON.features;

      const statePolysAKtopoJSON = data[2];
      this.statePolysAKJSON = topojson.feature(statePolysAKtopoJSON, statePolysAKtopoJSON.objects.states_polys_AK);
      const statePolysAK = this.statePolysAKJSON.features;

      const statePolysAStopoJSON = data[3];
      this.statePolysASJSON = topojson.feature(statePolysAStopoJSON, statePolysAStopoJSON.objects.states_polys_AS)
      const statePolysAS = this.statePolysASJSON.features;

      const statePolysGUMPtopoJSON = data[4];
      this.statePolysGUMPJSON = topojson.feature(statePolysGUMPtopoJSON, statePolysGUMPtopoJSON.objects.states_polys_GU_MP);
      const statePolysGUMP = this.statePolysGUMPJSON.features;

      const statePolysHItopoJSON = data[5];
      this.statePolysHIJSON = topojson.feature(statePolysHItopoJSON, statePolysHItopoJSON.objects.states_polys_HI);
      const statePolysHI = this.statePolysHIJSON.features;

      const statePolysPRVItopoJSON = data[6];
      this.statePolysPRVIJSON = topojson.feature(statePolysPRVItopoJSON, statePolysPRVItopoJSON.objects.states_polys_PR_VI)
      const statePolysPRVI = this.statePolysPRVIJSON.features;

      // Low simplification state polygons, for zoom view
      const statePolysZoomTopoJSON = data[7];
      this.statePolysZoom = topojson.feature(statePolysZoomTopoJSON, statePolysZoomTopoJSON.objects.states_polys_CONUS_OCONUS_zoom).features;

      // County polygons, for zoom view
      const countyPolysZoomTopoJSON = data[8];
      this.countyPolysZoom = topojson.feature(countyPolysZoomTopoJSON, countyPolysZoomTopoJSON.objects.counties_polys_CONUS_OCONUS_zoom).features;

      // County centroids, with county facility counts data
      const countyPointsTopoJSON = data[9];
      this.countyPoints = topojson.feature(countyPointsTopoJSON, countyPointsTopoJSON.objects.counties_centroids_CONUS_OCONUS).features;

      // Concatenate low simplification state polygons into single object
      this.statePolys = statePolysCONUS.concat(statePolysAK, statePolysHI, statePolysGUMP, statePolysPRVI, statePolysAS)

      // Set national and current map view
      this.nationalViewName = 'all states and territories'
      this.currentState = this.mobileView ? 'Alabama' : this.nationalViewName;

      // Set current scale for view (1 = not zoomed)
      this.currentScale = 1;

      // Set default and current facility type
      this.currentType = 'Bottled water'
      this.defaultType = 'Bottled water'

      // Set up dropdown
      // get list of unique states
      this.stateList = [... new Set(this.dataAll.map(d => d.NAME))]
      if (!this.mobileView) this.stateList.unshift(this.nationalViewName)
      // add dropdown
      self.addDropdown(this.stateList)

      // Initialize map
      self.initMap()

      // Initialize chart
      self.initChart()

      // set primary colors
      this.focalColor = "#1599CF";
      this.defaultColor = "#B5B5B5";

      // Draw initial view ('all states and territories' on desktop, 'Alabama' on mobile)
      // For mobile, need to compute initial scale, based on currentState
      const currentStateData = this.statePolysZoom.filter(d => d.properties.NAME === this.currentState)[0]
      if (this.mobileView) {
        const bounds = this.mapPath.bounds(currentStateData),
              dx = bounds[1][0] - bounds[0][0],
              dy = bounds[1][1] - bounds[0][1],
              scale = .95 / Math.max(dx / this.mapDimensions.width, dy / this.mapDimensions.height)
        this.currentScale = scale
      }
      self.drawHistogram(this.currentState)
      self.drawCounties(this.currentState, this.currentScale)
      self.drawMap(this.currentState, this.currentScale)
      self.drawCountyPoints(this.currentState, this.currentScale, this.currentType)
      
      // On mobile, zoom to currentState
      if (this.mobileView) {
        self.zoomToState(currentStateData, this.mapPath, 'dropdown')
      }
    },
    addDropdown(data) {
      const self = this;

      const dropdownContainer = this.d3.select("#state-dropdown-container")

      const dropdown = dropdownContainer
        .append("select")
        .attr("id", "state-dropdown")
        .attr("class", "dropdown")
        .attr("tabindex", 0)
        .on("change", function() {
          // Update dropdown text + width
          self.updateDropdown(this.options[this.selectedIndex].text)

          let selectedArea = this.value

          if (selectedArea === self.nationalViewName) {
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
              case 'United States Virgin Islands':
                zoomPath = self.mapPathPRVI;
                break;
              case 'Guam':
                zoomPath = self.mapPathGUMP;
                break;
              case 'Commonwealth of the Northern Mariana Islands':
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
        })

      // Append options to dropdown
      let stateOptions = dropdown.selectAll("stateOptions")
        .data(data)
        .enter()
        .append("option")
        .attr("value", d => d)
        .text(d => d)

      // Set default value and width of dropdown
      self.updateDropdown(this.currentState)
    },
    updateDropdown(text) {
      // Update dropdown text
      this.d3.select('#state-dropdown')
        .property('value', text)

      // Add tmp dropdown, which will only ever have one option (the current one)
      // https://stackoverflow.com/questions/20091481/auto-resizing-the-select-element-according-to-selected-options-width
      const tmpSelect = document.createElement("select")
      tmpSelect.classList.add('dropdown') // Add dropdown class to match dropdown styling
      tmpSelect.classList.add('tmp-dropdown') // add tmp-dropdown class to match h3 styling
      const tmpOption = document.createElement("option");
      tmpOption.setAttribute("value", text);
      var t = document.createTextNode(text);
      tmpOption.appendChild(t);
      tmpSelect.appendChild(tmpOption);
      window.document.body.appendChild(tmpSelect)
      
      // Update dropdown width based on width of tmp dropdown
      const tmpDropdownWidth = tmpSelect.offsetWidth / 10 // Divide by 10 to get in rem instead of px
      const dropdownElement = document.getElementById("state-dropdown");
      const bufferForBorder = 2 // in rem, same as border-right in .dropdown class PLUS room for arrow background image
      dropdownElement.style.width = tmpDropdownWidth + bufferForBorder + "rem";

      // Remove tmp dropdown
      window.document.body.removeChild(tmpSelect)
    },
    getGeometryInfo(json, area_name) {
      const self = this;

      const bounds = this.d3.geoBounds(json),
            minX = bounds[0][0],
            maxX = bounds[1][0],
            minY = bounds[0][1],
            maxY = bounds[1][1],
            width = area_name === 'AK' ? (180 - Math.abs(maxX)) + (180 - minX) : maxX - minX,
            height = maxY - minY
      
      let center;
      switch(area_name) {
        case 'AK':
          center = [Math.abs(maxX - width / 2), minY + height / 2];
          break;
        case 'GU_MP':
          center = [-1 * (maxX - width / 2), minY + height / 2];
          break;
        default:
          center =  [Math.abs(maxX - width / 2), minY + height / 2];
      }

      const geometryInfo = {
        bounds,
        minX,
        maxX,
        minY,
        maxY,
        width,
        height,
        center,
        parallels: [minY + height * 1/3, minY + height * 2/3]
      }
      return geometryInfo
    },
    initMap() {
      const self = this;

      // set universal map frame dimensions - height= width * 0.45
      const width = 900;
      this.mapDimensions = {
        width,
        height: width * 0.45,
        margin: {
          top: 60,
          right: 0,
          bottom: 0,
          left: -15
        }
      }
      this.mapDimensions.boundedWidth = this.mapDimensions.width - this.mapDimensions.margin.left - this.mapDimensions.margin.right
      this.mapDimensions.boundedHeight = this.mapDimensions.height - this.mapDimensions.margin.top - this.mapDimensions.margin.bottom

      // draw canvas for map
      this.wrapper = this.d3.select("#oconus-container")
        .append("svg")
          .attr("viewBox", [0, 0, (this.mapDimensions.width), (this.mapDimensions.height)].join(' '))
          .attr("width", "100%")
          .attr("height", "100%")
          .attr("id", "map-svg")

      // assign role for accessibility
      this.wrapper.attr("role", "figure")

      this.mapBounds = this.wrapper.append("g")
        .style("transform", `translate(${
          this.mapDimensions.margin.left
        }px, ${
          this.mapDimensions.margin.top
        }px)`)
        .attr("id", "map-bounds")

      // Get geometry info for each area
      const conusGeometry = self.getGeometryInfo(this.statePolysCONUSJSON, 'CONUS')
      
      const akGeometry = self.getGeometryInfo(this.statePolysAKJSON, 'AK')
      const akScale = 0.5
      const akConusHeightRatio = (akGeometry.height * akScale)/conusGeometry.height
      const akConusWidthRatio = (akGeometry.width * akScale)/conusGeometry.width

      const islandScale = 2

      const asGeometry = self.getGeometryInfo(this.statePolysASJSON, 'AS')
      const asConusHeightRatio = (asGeometry.height * islandScale)/conusGeometry.height

      const gumpGeometry = self.getGeometryInfo(this.statePolysGUMPJSON, 'GU_MP')
      const gumpConusWidthRatio = (gumpGeometry.width * islandScale)/conusGeometry.width
      const gumpConusHeightRatio = (gumpGeometry.height * islandScale)/conusGeometry.height

      const hiGeometry = self.getGeometryInfo(this.statePolysHIJSON, 'HI')
      const hiConusWidthRatio = (hiGeometry.width * islandScale)/conusGeometry.width
      const hiConusHeightRatio = (hiGeometry.height * islandScale)/conusGeometry.height

      const prviGeometry = self.getGeometryInfo(this.statePolysPRVIJSON, 'PR_VI')
      const prviConusHeightRatio = (prviGeometry.height * islandScale)/conusGeometry.height

      // Get height vars
      const conusPropHeight = this.mapDimensions.boundedHeight
      const akPropHeight = conusPropHeight * akConusHeightRatio
      const asPropHeight = conusPropHeight * asConusHeightRatio
      const gumpPropHeight = conusPropHeight * gumpConusHeightRatio
      const hiPropHeight = conusPropHeight * hiConusHeightRatio
      const prviPropHeight = conusPropHeight * prviConusHeightRatio
      const conusPropWidth = this.mapDimensions.boundedWidth / (1 + akConusWidthRatio)
      const akPropWidth = conusPropWidth * akConusWidthRatio
      const gumpPropWidth = conusPropWidth * gumpConusWidthRatio
      const hiPropWidth = conusPropWidth * hiConusWidthRatio
      
      const totalPropHeight = akPropHeight + gumpPropHeight
      const remainingHeight = this.mapDimensions.height - totalPropHeight
      const verticalMargin = remainingHeight / 3
      const totalPropWidth = hiPropWidth + gumpPropWidth
      const remainingWidth = akPropWidth - totalPropWidth
      const horizontalMargin = remainingWidth / 3
      
      // Set universal map scale
      const mapScale = 850;

      // CONUS map projection
      this.mapProjection = this.d3.geoConicEqualArea()
        .center([0, conusGeometry.center[1]])
        .rotate([conusGeometry.center[0], 0, 0])
        .parallels(conusGeometry.parallels)
        .scale(mapScale)
        .translate([akPropWidth + conusPropWidth / 2, conusPropHeight / 2]);

      this.mapPath = this.d3.geoPath()
        .projection(this.mapProjection);

      // Alaska map projection
      this.mapProjectionAK = this.d3.geoConicEqualArea()
        .center([0, akGeometry.center[1] - 4]) // 64
        .rotate([akGeometry.center[0], 0, 0])
        .parallels(akGeometry.parallels)
        .scale(mapScale * akScale)
        .translate([akPropWidth / 2, akPropHeight / 2]);

      this.mapPathAK = this.d3.geoPath()
        .projection(this.mapProjectionAK);

      // American Samoa map projection
      this.mapProjectionAS = this.d3.geoConicEqualArea()
        .center([0, asGeometry.center[1]])
        .rotate([asGeometry.center[0], 0, 0])
        .parallels(asGeometry.parallels)
        .scale(mapScale * islandScale)
        .translate([horizontalMargin * 2 + gumpPropWidth + hiPropWidth / 2, akPropHeight + hiPropHeight + verticalMargin * 1.75 + asPropHeight / 2]);

      this.mapPathAS = this.d3.geoPath()
        .projection(this.mapProjectionAS);

      // Guam and Northern Mariana Islands map projection
      this.mapProjectionGUMP = this.d3.geoConicEqualArea()
        .center([0, gumpGeometry.center[1] - 0.7]) //15.4
        .rotate([gumpGeometry.center[0], 0, 0])
        .parallels(gumpGeometry.parallels)
        .scale(mapScale * islandScale)
        .translate([horizontalMargin + gumpPropWidth / 2, akPropHeight + verticalMargin + gumpPropHeight / 2]);

      this.mapPathGUMP = this.d3.geoPath()
        .projection(this.mapProjectionGUMP);

      // Hawaii map projection
      this.mapProjectionHI = this.d3.geoConicEqualArea()
        .center([0, hiGeometry.center[1]])
        .rotate([hiGeometry.center[0], 0, 0])
        .parallels(hiGeometry.parallels)
        .scale(mapScale * islandScale)
        .translate([horizontalMargin * 2 + gumpPropWidth + hiPropWidth / 2, akPropHeight + verticalMargin / 3 + hiPropHeight / 2]);

      this.mapPathHI = this.d3.geoPath()
        .projection(this.mapProjectionHI);

      // Puerto Rico and U.S. Virgin Islands map projection
      this.mapProjectionPRVI = this.d3.geoConicEqualArea()
        .center([0, prviGeometry.center[1]])
        .rotate([prviGeometry.center[0], 0, 0])
        .parallels(prviGeometry.parallels)
        .scale(mapScale * islandScale)
        .translate([horizontalMargin * 2 + gumpPropWidth + hiPropWidth / 2, akPropHeight + hiPropHeight + asPropHeight + verticalMargin * 3 + prviPropHeight / 2]);

      this.mapPathPRVI = this.d3.geoPath()
        .projection(this.mapProjectionPRVI);

      // Add map groups to svg
      this.mapBounds.append("g")
        .attr("class", "counties")

      this.mapBounds.append("g")
        .attr("class", "county_centroids")

      this.mapBounds.append("g")
        .attr("class", "states")

    },
    initChart() {
      const self = this;

      // define histogram dimensions relative to container dimensions
      const width = document.getElementById("chart-container").offsetWidth;
      const height = document.getElementById("chart-container").offsetHeight;
      this.chartDimensions = {
        width,
        height: height,
        margin: {
          top: 5,
          right: 5,
          bottom: 5,
          left: 5
        }
      }
      this.chartDimensions.boundedWidth = this.chartDimensions.width - this.chartDimensions.margin.left - this.chartDimensions.margin.right
      this.chartDimensions.boundedHeight = this.chartDimensions.height - this.chartDimensions.margin.top - this.chartDimensions.margin.bottom
      
      // draw canvas for histogram
      const chartSVG = this.d3.select("#chart-container")
        .append("svg")
          .attr("viewBox", [0, 0, (this.chartDimensions.width), (this.chartDimensions.height)].join(' '))
          .attr("width", "100%")
          .attr("height", "100%")
          .attr("id", "chart-svg")

      // assign role for accessibility
      chartSVG.attr("role", "figure")
        .attr("tabindex", 0)
        .append("title")

      this.chartBounds = chartSVG.append("g")
        .style("transform", `translate(${
          this.chartDimensions.margin.left
        }px, ${
          this.chartDimensions.margin.top
        }px)`)

      // init static elements for histogram
      this.chartBounds.append("g")
          .attr("class", "rects")
          .attr("role", "list")
          .attr("tabindex", 0)
          .attr("aria-label", "bar chart bars")

      // Y axis

      // scale for the x-axis
      this.yScale = this.d3.scaleBand()
        .domain(this.dataTypes)
        .range([0, this.chartDimensions.boundedHeight])
        .padding(0);

      // const yAxis = this.chartBounds.append("g")
      //     .attr("class", "y-axis")
      //     // .style("transform", `translateY(${
      //     //   this.chartDimensions.boundedHeight
      //     // }px)`)
      //     .attr("role", "presentation")
      //     .attr("aria-hidden", true)

      // yAxis
      //   .call(this.d3.axisLeft(this.yScale).tickSize(0).tickPadding(10))
      //   .select(".domain").remove()

      // yAxis
      //   .selectAll("text")
      //   .attr("class", "axis-label chart-text")
      //   .style("text-anchor", "end")
        // Wrap x-axis labels
        // .call(d => self.wrapHorizontalLabels(d, 7));

      // yAxis
      //   .append("text")
      //     .attr("class", "y-axis axis-title chart-text")
      //     .attr("x", -this.chartDimensions.margin.left + 5)
      //     .attr("y", -this.chartDimensions.margin.left + 5)
      //     .attr("transform", "rotate(-90)")
      //     .style("text-anchor", "middle")
      //     .attr("role", "presentation")
      //     .attr("aria-hidden", true)

      // this.chartBounds.append("g")
      //   .attr("class", "x-axis")
      //   .attr("role", "presentation")
      //   .attr("aria-hidden", true)
        // .append("text")
        //   .attr("class", "x-axis axis-title chart-text")
        //   .attr("x", this.chartDimensions.boundedWidth / 2)
        //   .attr("y", this.chartDimensions.boundedHeight)
        //   .style("text-anchor", "middle")
        //   .attr("role", "presentation")
        //   .attr("aria-hidden", true)
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
    drawHistogram(state) {
      const self = this;

      const rawData = this.dataAll

      let data;
      if (state === this.nationalViewName) {
        let dataArray = []
        this.dataTypes.forEach(function(type) {
          let totalCount = rawData
            .filter(d => d.WB_TYPE === type)
            .map(d => parseInt(d.site_count))
            .reduce(function(acc, value) {
              return acc + value
            })
          let dataObj = {
            NAME: self.nationalViewName,
            state_abbr: null,
            WB_TYPE: type,
            site_count: totalCount
          }
          dataArray.push(dataObj)
        })
        data = dataArray
      } else {
        data = rawData.filter(d =>
          d.NAME === state)
      }

      // accessor functions
      const yAccessor = d => d.WB_TYPE
      const xAccessor = d => parseInt(d.site_count) // # values in each bin
      const colorAccessor = d => d.WB_TYPE
      const identifierAccessor = d => d.WB_TYPE.replace(' ', '-')

      //add title
      this.d3.select("#chart-container").select("Title")
        .text(`Bar chart of distribution of facility types for ${state}`)

      // create x scale
      const xScale = this.d3.scaleLinear()
        .domain([0, this.d3.max(data, xAccessor)]) // use y accessor w/ raw data
        .range([this.chartDimensions.boundedWidth, 0])
        .nice()

      // const colorScale = this.d3.scaleOrdinal()
      //   .domain([... new Set(data.map(d => colorAccessor(d)))].sort())
      //   .range(["darkmagenta","teal","gold","indianred","steelblue","pink"])

      // draw data
      let rectGroups = self.chartBounds.selectAll(".rects")
        .selectAll(".rect")
        .data(data, d => d.WB_TYPE)

      const oldRectGroups = rectGroups.exit()

      oldRectGroups.selectAll('rect')
        .transition(self.getExitTransition())
        .attr("x", 0)
        .attr("width", 0)

      oldRectGroups.selectAll('text')
        .transition(self.getExitTransition())
        .attr("x", 0)

      oldRectGroups.transition(self.getExitTransition()).remove()

      const newRectGroups = rectGroups.enter().append("g")
        .attr("class", d => "rect " + state)
        .attr("id", d => 'rect-group-' + identifierAccessor(d))
        .attr("tabindex", "0")
        .attr("role", "listitem")
        .attr("aria-label", d => `There are ${
          xAccessor(d)
        } ${
          yAccessor(d)
        } facilities in ${
          state
        }`)

      // append rects and set default x and width, so that when appear, come out from left
      newRectGroups.append("rect")
        .attr("y", d => this.yScale(yAccessor(d)))
        .attr("x", 0)
        .attr("height", this.yScale.bandwidth())
        .attr("width", 0)
        .style("fill", d => d.WB_TYPE === this.currentType ? this.focalColor : this.defaultColor)



      // update rectGroups to include new points
      rectGroups = newRectGroups.merge(rectGroups)

      const barRects = rectGroups.select("rect")

      barRects.transition(self.getUpdateTransition())
          .attr("id", d => 'rect-' + identifierAccessor(d))
          .attr("y", d => this.yScale(yAccessor(d)) + this.yScale.bandwidth() - this.yScale.bandwidth() / 6)
          .attr("x", d => 0)
          .attr("height", this.yScale.bandwidth() / 6) // if negative, bump up to 0
          .attr("width", d => this.chartDimensions.boundedWidth - xScale(xAccessor(d)))
          .style("fill", d => d.WB_TYPE === this.currentType ? this.focalColor : this.defaultColor)
          .attr("class", d => 'bar ' + identifierAccessor(d))

      newRectGroups.append("rect")
        .attr("y", d => this.yScale(yAccessor(d)))
        .attr("x", 0)
        .attr("height", this.yScale.bandwidth())
        .attr("width", this.chartDimensions.boundedWidth)
        .style("fill", 'white')
        .style("fill-opacity", 0)

      // append text and set default position
      newRectGroups.append("text")
        .attr("y", d => this.yScale(yAccessor(d)) + this.yScale.bandwidth()/2)
        .attr("x", 0)

      rectGroups
        .on("click", (event, d) => {
          this.currentType = colorAccessor(d)
          let currentIdentifier = this.currentType.replace(' ', '-')
          self.drawCountyPoints(state, this.currentScale, this.currentType)

          this.d3.selectAll('.bar')
            .transition(self.getUpdateTransition())
            .style("fill", this.defaultColor)

          this.d3.selectAll('#rect-' + currentIdentifier)
            .transition(self.getUpdateTransition())
            .style("fill", this.focalColor)
        })
        // .on("mouseover", (event, d) => {
        //   this.currentType = colorAccessor(d)
        //   let currentIdentifier = this.currentType.replace(' ', '-')
        //   self.drawCountyPoints(state, this.currentScale, this.currentType)

        //   this.d3.selectAll('.bar')
        //     .transition(self.getUpdateTransition())
        //     .style("opacity", 0.5)
        //     .style("fill", this.defaultColor)

        //   this.d3.selectAll('#rect-' + currentIdentifier)
        //     .transition(self.getUpdateTransition())
        //     .style("opacity", 1)
        //     .style("fill", this.focalColor)
        // })

      // // When mouse leaves chart, change back to default type
      // self.chartBounds.selectAll(".rects")
      //   .on("mouseleave", (event, d) => {
      //     this.currentType = this.defaultType
      //     let currentIdentifier = this.currentType.replace(' ', '-')
      //     self.drawCountyPoints(state, this.currentScale, this.currentType)

      //     this.d3.selectAll('.bar')
      //       .transition(self.getUpdateTransition())
      //       .style("opacity", 1)
      //       .style("fill", this.defaultColor)

      //     this.d3.selectAll('#rect-' + currentIdentifier)
      //       .transition(self.getUpdateTransition())
      //       .style("opacity", 1)
      //       .style("fill", this.focalColor)
      //   })

      // Trigger with enter key - BUT - how get back to total?
      rectGroups.each(function() {
        this.addEventListener("keypress", function(event) {
            if (event.key === 'Enter' | event.keyCode === 13) {
              let targetId = event.target.id
              let targetIdSplit = targetId.split('-')
              this.currentType = targetIdSplit.length === 4 ? (targetIdSplit[2] + ' ' + targetIdSplit[3]) : targetIdSplit[2]
              let currentIdentifier = this.currentType.replace(' ', '-')

              // NOTE: need to use self.currentState, not `state` b/c `state` gets stale when attached to event listener
              self.drawCountyPoints(self.currentState, self.currentScale, this.currentType)

              self.d3.selectAll('.bar')
                .transition(self.getUpdateTransition())
                .style("fill", self.defaultColor)

              self.d3.selectAll('#rect-' + currentIdentifier)
                .transition(self.getUpdateTransition())
                .style("fill", self.focalColor)
            }
        })
      })

      const barText = rectGroups.select("text")
        .transition(self.getUpdateTransition())
          .attr("class", "bar-label chart-text")
          // .attr("y", d => this.yScale(yAccessor(d)) - this.yScale.bandwidth() * 2)
          .attr("y", d => this.yScale(yAccessor(d)) + this.yScale.bandwidth() / 2)
          .attr("x", 0)
          .style("text-anchor", "start")
          .attr("alignment-baseline", "middle") // center text
          .attr("dominant-baseline", "middle") // required for Firefox
          .text(d => {
            const count = xAccessor(d); 
            let suffix;
            switch(yAccessor(d)) {
            case 'Brewery':
              suffix = count > 1 ? 'Breweries' : yAccessor(d);
              break;
            case 'Distillery':
              suffix = count > 1 ? 'Distilleries' : yAccessor(d);
              break;
            case 'Winery':
              suffix = count > 1 ? 'Wineries' : yAccessor(d);
              break;
            case 'Soft drinks':
              suffix = count > 1 ? 'Soft drink facilities' : 'Soft drink facility';
              break;
            default:
              suffix =  count > 1 ? yAccessor(d) + ' facilities' : yAccessor(d) + ' facility';
            }

            return this.d3.format(',')(xAccessor(d)) + " " + suffix;
          })

      const yAxisLabel = this.chartBounds.select(".y-axis.axis-title")

      if (state === this.nationalViewName) {
        yAxisLabel
          .text('Distribution of facility types nationally')
      } else {
        yAxisLabel
          .text(`Distribution of facility types in ${
            state
          }`)
      }

      const xAxisGenerator = this.d3.axisBottom()
        .scale(xScale)
        .tickValues([]);

      const xAxis = this.chartBounds.select(".x-axis")

      xAxis
        .transition(self.getUpdateTransition())
        .call(xAxisGenerator)
        .select(".domain").remove()
        // .attr("role", "presentation")
        // .attr("aria-hidden", true)

      xAxis.selectAll(".tick line").attr("stroke", "None")

      // const xAxisLabel = xAxis.select(".x-axis.axis-title")

      // xAxisLabel
      //   .text('Number of facilities')

    },
    drawMap(state, scale) {
      const self = this;

      let data;

      if (state === this.nationalViewName) {
        data = this.statePolys
      } else {
        data = this.statePolysZoom.filter(d =>
          d.properties.NAME === state)
      }

      this.stateGroups = this.mapBounds.selectAll(".states")
        .selectAll(".state")
        .data(data, d => d.properties.data_id)

      const oldStateGroups = this.stateGroups.exit()

      oldStateGroups.selectAll('path')
        .transition(self.getExitTransition())
        .style("stroke", "#ffffff")
        .style("fill", "#ffffff")

      oldStateGroups.remove() //.transition(self.getExitTransition())

      const newStateGroups = this.stateGroups.enter().append("g")
        .attr("class", "state")
        .attr("id", d => 'state-group-' + d.properties.GEOID)

      let stateStrokeWidth = state === this.nationalViewName ? 0.5 : 1 * 1/scale
      let stateStrokeColor = state === this.nationalViewName ? "#949494" : "#757575"
      newStateGroups.append("path")
        .attr("class", "state-paths")
        .attr("id", d => "state-" + d.properties.GEOID)
        .attr("d", d => {
          switch(d.properties.NAME) {
            case 'Alaska':
              return this.mapPathAK(d);
            case 'Hawaii':
              return this.mapPathHI(d);
            case 'Puerto Rico':
              return this.mapPathPRVI(d);
            case 'United States Virgin Islands':
              return this.mapPathPRVI(d);
            case 'Guam':
              return this.mapPathGUMP(d);
            case 'Commonwealth of the Northern Mariana Islands':
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
          if (!this.mobileView) {
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
              case 'United States Virgin Islands':
                zoomPath = this.mapPathPRVI;
                break;
              case 'Guam':
                zoomPath = this.mapPathGUMP;
                break;
              case 'Commonwealth of the Northern Mariana Islands':
                zoomPath = this.mapPathGUMP;
                break;
              case 'American Samoa':
                zoomPath = self.mapPathAS;
                break;
              default:
                zoomPath = this.mapPath;
            }
            if (!(d.properties.NAME == 'Commonwealth of the Northern Mariana Islands') && !(d.properties.NAME == 'American Samoa')) {
              self.zoomToState(d, zoomPath, 'click')
            }
          }
        })

      this.stateGroups = newStateGroups.merge(this.stateGroups)

      const stateShapes = this.stateGroups.select("path")

      if (!(state === this.nationalViewName)) {
        let selectedStateId = data[0].properties.GEOID
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
      // if (currentState === this.nationalViewName) {
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
      // if (!(state === this.nationalViewName)) {
      //   const selectedStateData = data.filter(d => d.properties.NAME === state)
      //   console.log(selectedStateData)
      //   const selectedStateId = selectedStateData[0].properties.GEOID

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
      if (state === this.nationalViewName) {
        stateShapes
          .on("mouseover", (event, d) => {
            this.d3.selectAll("#state-" + d.properties.GEOID)
              .style("fill", "#000000")
              .style("fill-opacity", 0.1)
          })
          .on("mouseout", (event, d) => {
            this.d3.selectAll("#state-" + d.properties.GEOID)
              .style("fill", "#fffff")
              .style("fill-opacity", 0)
          })
      }
    },
    drawCounties(state, scale) {
      const self = this;

      let data;

      if (state === this.nationalViewName) {
        data = this.countyPolysZoom
      } else {
        data = this.countyPolysZoom.filter(d =>
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

      let countyStrokeWidth = state === this.nationalViewName ? 0.1 : 0.5 * 1/scale
      let countyStrokeColor = state === this.nationalViewName ? "#E3E3E3" : "#939393"
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
              case 'United States Virgin Islands':
                return this.mapPathPRVI(d);
              case 'Guam':
                return this.mapPathGUMP(d);
              case 'Commonwealth of the Northern Mariana Islands':
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

      // if (!(state === this.nationalViewName)) {
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
      // if (!(state === this.nationalViewName)) {
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

      const sizeAccessor = d => parseInt(d.properties[type])

      let dataPoints;
      let dataMax;
      if (state === this.nationalViewName) {
        dataPoints = this.countyPoints
        if (type === 'All') {
          dataMax = this.d3.max(this.countyPoints, sizeAccessor)
        } else {
          // Get max value for nation, in any category except 'All'
          dataMax = this.d3.max(this.countyPoints, d => parseInt(d.properties.max_count))
        }

      } else {

        dataPoints = this.countyPoints.filter(d => d.properties.STATE_NAME === state)
        // Get max value for state, in any category except 'All'
        dataMax = this.d3.max(dataPoints, d => parseInt(d.properties.max_count))
      }

      // create scales
      const scaleNumerator = scale > 15 ? 3: 2
      const scaleFactor = scale === 1 ? 1 : scaleNumerator/scale
      const rangeMin = scale === 1 ? 1.25 : 2.5
      const rangeMax = scale === 1 ? 15 : 18

      const sizeScale = this.d3.scaleLinear()
        .range([rangeMin * scaleFactor, rangeMax * scaleFactor])
        .domain([1, dataMax])

      // county centroids
      this.countyCentroidGroups = this.mapBounds.selectAll(".county_centroids")
        .selectAll(".county_centroid")
        .data(dataPoints, d => d.properties.GEOID)

      const oldCountyCentroidGroups = this.countyCentroidGroups.exit()

      oldCountyCentroidGroups.selectAll('path')
        // .transition(self.getExitTransition())
        .attr("d", d => {
          switch(d.properties.STATE_NAME) {
            case 'Alaska':
              return this.mapPathAK.pointRadius(0)(d);
            case 'Hawaii':
              return this.mapPathHI.pointRadius(0)(d);
            case 'Puerto Rico':
              return this.mapPathPRVI.pointRadius(0)(d);
            case 'United States Virgin Islands':
              return this.mapPathPRVI.pointRadius(0)(d);
            case 'Guam':
              return this.mapPathGUMP.pointRadius(0)(d);
            case 'Commonwealth of the Northern Mariana Islands':
              return this.mapPathGUMP.pointRadius(0)(d);
            case 'American Samoa':
              return this.mapPathAS.pointRadius(0)(d);
            default:
              return this.mapPath.pointRadius(0)(d);
          }
        })

      // Remove old county points
      oldCountyCentroidGroups.transition(self.getExitTransition()).remove()

      const newCountyCentroidGroups = this.countyCentroidGroups.enter().append("g")
        .attr("class", "county_centroid")
        .attr("id", d => "county-point-group" + d.properties.GEOID)

      // append points
      let centroidStrokeWidth = state === this.nationalViewName ? 0.5 : 1 * 1/scale
      newCountyCentroidGroups.append("path")
        .attr("id", d => "county-point-" + d.properties.GEOID)
        // Instantiate w/ 0 radius
        .attr("d", d => {
          switch(d.properties.STATE_NAME) {
            case 'Alaska':
              return this.mapPathAK.pointRadius(0)(d);
            case 'Hawaii':
              return this.mapPathHI.pointRadius(0)(d);
            case 'Puerto Rico':
              return this.mapPathPRVI.pointRadius(0)(d);
            case 'United States Virgin Islands':
              return this.mapPathPRVI.pointRadius(0)(d);
            case 'Guam':
              return this.mapPathGUMP.pointRadius(0)(d);
            case 'Commonwealth of the Northern Mariana Islands':
              return this.mapPathGUMP.pointRadius(0)(d);
            case 'American Samoa':
              return this.mapPathAS.pointRadius(0)(d);
            default:
              return this.mapPath.pointRadius(0)(d);
          }
        })
        .style("fill", this.focalColor)
        .style("stroke", "#ffffff")
        .style("stroke-width", centroidStrokeWidth)

      // update rectGroups to include new points
      this.countyCentroidGroups = newCountyCentroidGroups.merge(this.countyCentroidGroups)

      const countyCentroidPoints = this.countyCentroidGroups.select("path")

      countyCentroidPoints
          .transition(self.getUpdateTransition())
          .attr("d", d => {
            // if count is 0, set radius to 0, otherwise set based on count
            let scaledRadius = sizeAccessor(d) === 0 ? 0 : sizeScale(sizeAccessor(d));
            switch(d.properties.STATE_NAME) {
              case 'Alaska':
                return this.mapPathAK.pointRadius(scaledRadius)(d);
              case 'Hawaii':
                return this.mapPathHI.pointRadius(scaledRadius)(d);
              case 'Puerto Rico':
                return this.mapPathPRVI.pointRadius(scaledRadius)(d);
              case 'United States Virgin Islands':
                return this.mapPathPRVI.pointRadius(scaledRadius)(d);
              case 'Guam':
                return this.mapPathGUMP.pointRadius(scaledRadius)(d);
              case 'Commonwealth of the Northern Mariana Islands':
                return this.mapPathGUMP.pointRadius(scaledRadius)(d);
              case 'American Samoa':
                return this.mapPathAS.pointRadius(scaledRadius)(d);
              default:
                return this.mapPath.pointRadius(scaledRadius)(d);
            }
          })
          .style("fill", this.focalColor)
          .style("stroke", "#ffffff")
          .style("stroke-width", centroidStrokeWidth)


      // // Add county mouseover if at state level
      // if (!(state === this.nationalViewName)) {
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
      //         .style("fill", this.focalColor)
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
    zoomToState(d, path, callMethod) {
      const self = this;

      // Store name of selected state
      let zoomedState = d.properties.NAME

      // Determine if need to zoom in or out
      let zoomAction = this.currentState === zoomedState ? 'Zoom out' : 'Zoom in'
      zoomAction = this.mobileView ? 'Zoom in' : zoomAction;

      // console.log(`You selected ${d.properties.NAME} by ${callMethod}. Currently shown area is ${this.currentState}. This.currentlyZoomed is ${this.currentlyZoomed}. Planned zoom action is ${zoomAction}`)

      // If need to zoom out, zoom out to all states + territories
      if (zoomAction === 'Zoom out') return self.reset();

      // If user clicked on map to zoom
      if (callMethod === 'click') {
        let dropdown = this.d3.select('select')
        // Update dropdown text and width
        self.updateDropdown(zoomedState)
      }

      // Hide the inset map borders and labels
      this.d3.select("#map-inset-svg")
        .classed("hide", true)

      // Compute zoom and scale parameters
      const [[x0, y0], [x1, y1]] = path.bounds(d);
      const cx = (x0 + x1) / 2;
      const cy = (y0 + y1) / 2;
      const stateDims = {
        width: 2 * this.d3.max([ x1 - cx, cx - x0]),
        height: 2 * this.d3.max([ y1 - cy, cy - y0])
      };
      // Use full mapDims height so that zoomed area fills map area
      // Have to account for margins in translation b/c margins are applied in national view
      const zoom_scale = 0.95 * this.d3.min([
        this.mapDimensions.height/stateDims.height,
        this.mapDimensions.width/stateDims.width]);
      const translate = [this.mapDimensions.width / 2 - zoom_scale * cx - this.mapDimensions.margin.left, this.mapDimensions.height / 2 - zoom_scale * cy - this.mapDimensions.margin.top]

      // set global scale variable
      this.currentScale = zoom_scale;

      // Draw state, county, points, and bar chart for state
      self.drawCountyPoints(zoomedState, this.currentScale, this.currentType)
      self.drawCounties(zoomedState, this.currentScale)
      self.drawMap(zoomedState, this.currentScale)
      self.drawHistogram(zoomedState)

      // Zoom to state by transitioning map groups
      this.stateGroups.transition(self.getUpdateTransition)
        .attr("transform", "translate(" + translate + ") scale(" + zoom_scale + ")");

      this.countyGroups.transition(self.getUpdateTransition)
        .attr("transform", "translate(" + translate + ") scale(" + zoom_scale + ")");
      
      this.countyCentroidGroups.transition(self.getUpdateTransition)
        .attr("transform", "translate(" + translate + ") scale(" + zoom_scale + ")");

      // set current state to zoomed state
      this.currentlyZoomed = true;
      this.currentState = zoomedState;
      
      // console.log(`Zoomed in on ${zoomedState}, so this.currentlyZoomed is ${this.currentlyZoomed}`)
    },
    reset() {
      const self = this;

      this.currentState = this.nationalViewName //this.d3.select(null);
      this.currentScale = 1;

      // Update dropdown value and width
      self.updateDropdown(this.nationalViewName)

      this.d3.select("#map-inset-svg")
        .classed("hide", false)

      self.drawHistogram(this.nationalViewName)
      self.drawCounties(this.nationalViewName, this.currentScale)
      self.drawMap(this.nationalViewName, this.currentScale)
      self.drawCountyPoints(this.nationalViewName, this.currentScale, this.currentType)

      this.stateGroups.transition(self.getExitTransition)
          .attr("transform", "");

      this.countyGroups.transition(self.getExitTransition)
        .attr("transform", "");

      this.countyCentroidGroups.transition(self.getExitTransition)
        .attr("transform", "");

      this.currentlyZoomed = false;
      // console.log(`Zoomed out, so this.currentlyZoomed is ${this.currentlyZoomed}`)
    }
  }
}
</script>
<style lang="scss">
  .bar {
    stroke: white;
    stroke-width: 0;
  }
  .axis-title {
    fill: #000000;
    font-weight: 700;
  }
  .bar-label {
    fill: #666666;
  }
  .chart-text {
    user-select: none;
    @media screen and (max-height: 770px) {
      font-size: 1.7rem;
    }
  }
  #state-dropdown {
    width: 50px;
  }
  .dropdown {
    appearance: none; // removes default dropdown styling
    -moz-appearance: none; // removes default dropdown styling
    -webkit-appearance: none; // removes default dropdown styling
    background-image: url('../assets/images/arrow.png'); // Uses custom image for dropdown arrow
    background-repeat: no-repeat, repeat;
    background-position: right 0em top 60%;
    background-size: .3em auto;
    background-origin: content-box;
    border-right: 1rem solid transparent; // Add space to right of dropdown arrow
    transition: width 2s, transform 1s;
    background-color: white;
    margin: 0rem 0.5rem 0rem 0.5rem;
    padding: 0.5rem 0rem 0.5rem 1rem;
    box-shadow:  rgba(0, 0, 0, 0.2) 0rem 0.6rem 1rem 0rem,
    rgba(0, 0, 0, 0.1) 0rem 0rem 0rem 0.1rem;
    border-radius: 0.5rem;
    color: rgb(21, 21, 21);
  }
  .dropdown:hover {
    box-shadow:  rgba(0, 0, 0, 0.3) 0rem 0.6rem 1rem 0rem,
    rgba(0, 0, 0, 0.2) 0rem 0rem 0rem 0.1rem;
  }
  .tmp-dropdown {
    font-size: 3.25rem; // style same as h2 in App.vue
    padding-top: 1rem;
    padding-bottom: 1rem;
    font-weight: 700;
    @media screen and (max-height: 770px) {
      font-size: 3rem; // style same as h2 in App.vue
    }
    @media screen and (max-width: 600px) {
        font-size: 2.5rem; // style same as h2 in App.vue
    }
  }
</style>
<style scoped lang="scss">
  .grid-title {
    @media screen and (max-height: 770px) {
      padding-top: 0rem;
      padding-bottom: 0rem;
    }
    @media screen and (max-width: 600px) {
      padding-top: 0rem;
      padding-bottom: 0rem;
    }
  }
  #grid-container-interactive {
    display: grid;
    grid-template-columns: 20% 80%;
    column-gap: 2%;
    grid-template-rows: max-content 20vh max-content;
    row-gap: 2vh;
    grid-template-areas:
      "title title"
      "chart map"
      "text map";
    justify-content: center;
    margin: 1rem 0rem 3rem 0rem;
    @media screen and (max-height: 770px) {
      grid-template-rows: max-content 30vh max-content;
    }
  }
  #grid-container-interactive.mobile {
    grid-template-columns: 100%;
      grid-template-rows: max-content max-content max-content 30vh;
      grid-template-areas:
        "title"
        "text"
        "map"
        "chart";
      position: relative;
      padding: 0.5rem 0.5rem 0.5rem 0.5rem;
  }
  #title {
    grid-area: title;
    align-self: center;
  }
  #state-dropdown-container {
    grid-area: title;
  }
  #chart-container {
    grid-area: chart;
  }
  #oconus-container {
    grid-area: map;
    align-self: start;
    height: 100%;
    max-height: 70vh;
  }
  #map-label-container {
    pointer-events: none;
    grid-area: map;
    align-self: start;
    height: 100%;
    max-height: 70vh;
  }
  #text {
    grid-area: text;
    justify-self: start;
  }
  .hide {
    display: none;
  }
</style>
