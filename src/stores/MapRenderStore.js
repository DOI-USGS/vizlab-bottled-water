import { defineStore } from 'pinia'

// Tracks whether the OCONUS map has finished its initial render. The text
// sections below the map wait on this so they don't render before the map.
export const useMapRenderStore = defineStore('MapRenderStore', {
    state: () => {
        return {
            mapRenderedOnInitialLoad: false,
        }
    },
    actions: {
        recordMapRender() {
            this.mapRenderedOnInitialLoad = true
        }
    }
})
