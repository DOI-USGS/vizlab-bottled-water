<template>
  <svg
    id="inset-map-svg"
    xmlns="http://www.w3.org/2000/svg"
    xmlns:xlink="http://www.w3.org/1999/xlink"
    width="100%"
    height="100%"
    viewBox="0 0 900 405"
    preserveAspectRatio="xMidYMid meet"
  >
    <g id="scale_place_labels">
      <text
        class="scale-labels labels"
        transform="translate(4.5 183.5)"
      >x2 <tspan
        class="place-labels labels"
        x="14"
      >Northern<tspan
        x="14"
        y="11"
      >Mariana Islands</tspan></tspan><tspan
        x="14"
        y="26"
        class="scale-labels labels"
      >(no data)</tspan></text>
      <text
        class="scale-labels labels"
        transform="translate(101.5 183.5)"
      >x2 <tspan
        class="place-labels labels"
        x="14"
      >Hawaii</tspan></text>
      <text
        class="scale-labels labels"
        transform="translate(258.5 11.6)"
      >x1 <tspan
        class="place-labels labels"
        x="14"
      >Contiguous United States</tspan></text>
      <text
        class="place-labels labels"
        transform="translate(198 168.8)"
      >Alaska<tspan
        class="scale-labels labels"
        x="32"
      > x0.5</tspan></text>
      <text
        class="scale-labels labels"
        transform="translate(101.5 330)"
      >x2 <tspan
        class="place-labels labels"
        x="14"
      >American Samoa</tspan>
        <tspan 
          class="scale-labels labels"
        > (no data)</tspan>
      </text>  
      <text
        class="scale-labels labels"
        transform="translate(101.5 374)"
      >x2 <tspan
        class="place-labels labels"
        x="14"
      >Puerto Rico & the U.S. Virgin Islands</tspan></text>
      <text
        class="place-labels labels"
        transform="translate(25 405)"
      >Guam</text>
    </g>
    <g id="corners">
      <polyline
        id="line-Hawaii"
        class="corner-lines"
        points="98 205 98 173 130 173"
      />
      <polyline
        id="line-NortherMarianaIslands"
        class="corner-lines"
        points="1 205 1 173 33 173"
      />
      <polyline
        id="line-AmericanSamoa"
        class="corner-lines"
        points="98 351 98 319 130 319"
      />
      <polyline
        id="line-PuertoRicoVirginIslands"
        class="corner-lines"
        points="98 395 98 363 130 363"
      />
      <polyline
        id="line-CONUS"
        class="corner-lines"
        points="255 17 255 1 271 1"
      />
      <polyline
        id="line-Alaska"
        class="corner-lines"
        points="255 165 255 173 247 173"
      />
    </g>
    <image
      width="95"
      height="95"
      transform="translate(1 1) scale(1)"
      xlink:href="../assets/images/locator_map.webp"
    />
  </svg>
</template>

<script>
export default {
    name: "MapLabels"
}
</script>
<style lang="scss" scoped>
  .labels {
    font-size: 1.1rem;
    fill: #6E6E6E;
    font-style: italic;
  }
  .corner-lines {
    fill: none;
    stroke: #949494;
    stroke-miterlimit: 10;
    stroke-width: .02rem;
  }
  .place-labels {
    font-weight: 400;
  }
  .scale-labels {
    font-weight: 300;
  }
</style>