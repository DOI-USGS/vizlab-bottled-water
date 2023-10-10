<template>
    <svg id="inset-map-svg" xmlns="http://www.w3.org/2000/svg" xmlns:xlink="http://www.w3.org/1999/xlink" width="100%" height="100%" viewBox="0 0 900 675" preserveAspectRatio="xMidYMid meet">
    <g id="map-borders">
        <g id="vertical-ak-border">
            <line class="borders" x1="515" y1="266.5" x2="515" y2="2"/>
        </g>
        <g id="horizontal-ak-border">
            <line class="borders" x1="0" y1="270" x2="515" y2="270"/>
        </g>
        <g id="pr-vi-borders">
            <line class="borders" x1="740" y1="671.6" x2="740" y2="567"/>
            <line class="borders" x1="743.5" y1="565" x2="898" y2="565"/>
        </g>
        <g id="vertical-island-border">
            <line class="borders" x1="150" y1="273.5" x2="150" y2="673"/>
        </g>
        <g id="horizontal-hi-border">
            <line class="borders" x1="0" y1="425" x2="148" y2="425"/>
        </g>
        <g id="horizontal-as-border">
            <line class="borders" x1="0" y1="595" x2="148" y2="595"/>
        </g>
    </g>
    <g id="map-labels">
        <text class="labels" transform="translate(180 35.2)">Alaska</text>
        <text class="labels" transform="translate(53.4 301.5)">Hawaii</text>
        <text class="labels" transform="translate(18.2 447.4)">Northern Mariana<tspan x="35.1" y="19.2">Islands</tspan></text>
        <text class="labels" transform="translate(368.6 297.4)">Contiguous United States</text>
        <text class="labels" transform="translate(755.1 587.5)">Puerto Rico and the<tspan x="5.8" y="19.2">U.S. Virgin Islands</tspan></text>
        <text class="labels" transform="translate(56.9 587.9)">Guam</text>
        <text class="labels" transform="translate(21.3 615.7)">American Samoa</text>
    </g>
    <image width="750" height="750" transform="translate(5 5) scale(.18)" xlink:href="../assets/images/locator_map.png"/>
    </svg>
</template>

<script>
export default {
    name: "mapLabels"
}
</script>
<style lang="scss" scoped>
    .borders {
        stroke-dasharray: 0 0 0.5 4;
        fill: none;
        stroke: #606161;
        stroke-miterlimit: 10;
        stroke-width: .75px;
    }

    .labels {
        fill: #231f20;
        font-family: SourceSansPro-It, 'Source Sans Pro';
        font-size: 16px;
        font-style: italic;
    }
</style>