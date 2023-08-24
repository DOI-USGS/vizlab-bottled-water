<template>
    <svg id="inset-map-svg" xmlns="http://www.w3.org/2000/svg" xmlns:xlink="http://www.w3.org/1999/xlink" width="100%" height="100%" viewBox="0 0 900 675" preserveAspectRatio="xMidYMid meet">
    <g id="map-borders">
        <g>
        <!--line class="borders" y1="270" x2=".5" y2="270"/ -->
        <!-- line class="borders" x1="3.5" y1="270" x2="513" y2="270"/ -->
        <polyline class="borders" points="514.5 270 515 270 515 269.5"/>
        <line class="borders" x1="515" y1="266.5" x2="515" y2="2"/>
        <line class="borders" x1="515" y1=".5" x2="515"/>
        </g>
        <g>
        <line class="borders" x1="0" y1="270" x2="900" y2="270"/>
        </g>
        <g>
        <line class="borders" x1="740" y1="675" x2="740" y2="674.5"/>
        <line class="borders" x1="740" y1="671.6" x2="740" y2="567"/>
        <polyline class="borders" points="740 565.5 740 565 740.5 565"/>
        <line class="borders" x1="743.5" y1="565" x2="898" y2="565"/>
        <line class="borders" x1="899.5" y1="565" x2="900" y2="565"/>
        </g>
        <g>
        <line class="borders" x1="150" y1="270" x2="150" y2="270.5"/>
        <line class="borders" x1="150" y1="273.5" x2="150" y2="673"/>
        <line class="borders" x1="150" y1="674.5" x2="150" y2="675"/>
        </g>
        <g>
        <line class="borders" y1="425" x2=".5" y2="425"/>
        <line class="borders" x1="3.5" y1="425" x2="148" y2="425"/>
        <line class="borders" x1="149.5" y1="425" x2="150" y2="425"/>
        </g>
        <g>
        <line class="borders" x1="2.4" y1="595" x2="2.9" y2="595"/>
        <line class="borders" x1="5.9" y1="595" x2="148" y2="595"/>
        <line class="borders" x1="149.5" y1="595" x2="150" y2="595"/>
        </g>
    </g>
    <g id="map-labels">
        <text class="labels" transform="translate(93.1 35.2)">Alaska</text>
        <text class="labels" transform="translate(53.4 301.5)">Hawaii</text>
        <text class="labels" transform="translate(18.2 447.4)">Northern Mariana<tspan x="35.1" y="19.2">Islands</tspan></text>
        <text class="labels" transform="translate(368.6 297.4)">Contiguous United States</text>
        <text class="labels" transform="translate(755.1 587.5)">Puerto Rico and the<tspan x="5.8" y="19.2">U.S. Virgin Islands</tspan></text>
        <text class="labels" transform="translate(56.9 587.9)">Guam</text>
        <text class="labels" transform="translate(21.3 615.7)">American Samoa</text>
    </g>
    <image width="1500" height="1500" transform="translate(581.5 0) scale(.18)" xlink:href="../assets/images/locator_map.png"/>
    </svg>
</template>

<script>
export default {
    name: "mapLabels"
}
</script>
<style lang="scss" scoped>
    .borders {
        stroke-dasharray: 0 0 2 6;
        fill: none;
        stroke: #606161;
        stroke-miterlimit: 10;
        stroke-width: .5px;
    }

    .labels {
        fill: #231f20;
        font-family: SourceSansPro-It, 'Source Sans Pro';
        font-size: 16px;
        font-style: italic;
    }
</style>