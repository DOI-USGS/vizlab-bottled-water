<template>
  <section id="main-container">
    <section id="grid-container">
      <div id="title-container">
        <div id="title">
               <h3> Bottling facilities in 
                <span id = "state-dropdown-container"></span>
                </h3>
            </div>

      </div>
      <div id="map-container">

      </div>
    </section>
  </section>
</template>
<script>
import * as d3Base from 'd3';
import { isMobile } from 'mobile-device-detect';
export default {
  name: "OCONUS",
    components: {

    },
    props: {
      data: Object
    },
    data() {
      return {
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

        this.statePolyJSON = data[0];
        const statePolys = this.statePolyJSON.features;
        console.log(statePolys)

        this.countyPolyJSON = data[1];
        const countyPolys = this.countyPolyJSON.features;
        console.log(countyPolys)

        this.countyPointJSON = data[2];
        const countyPoints = this.countyPointJSON.features;
        console.log(countyPoints)

        this.dataRaw = data[3];
        const dataAll = this.dataRaw

        // get list of unique states
        const stateList = [... new Set(dataAll.map(d => d.state_name))]
        stateList.unshift('All')
        let currentState = 'All'//stateList[0]
        let currentType = 'All'

        // add dropdown
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

#grid-container {
  display: grid;
  padding: 20px 0 20px 0;
  gap: 5px;
  grid-template-columns: 100%;
  grid-template-rows: max-content max-content max-content max-content;
  grid-template-areas:
    "title"
    "intro"
    "buttons"
    "chart";
  justify-content: center;
  margin: auto;
  max-width: 90vw;
  min-width: 90vw;
}
#title-container {
  grid-area: title;
}
#intro-container {
  grid-area: intro;
  padding-left: 5px;
}


</style>