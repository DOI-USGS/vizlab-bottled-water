export_county_data_to_geojson <- function(data, centroids_sf, outfile) {
  
  data_sf <- centroids_sf %>%
    dplyr::select(GEOID, geometry, geometry_point) %>%
    full_join(data, by = 'GEOID')
  
  data_sf_wide <- data_sf %>%
    dplyr::select(GEOID, STATE_NAME, NAMELSAD, site_count, WB_TYPE, max_count, geometry_point) %>%
    filter(!(is.na(WB_TYPE))) %>%
    arrange(STATE_NAME, GEOID, WB_TYPE) %>%
    pivot_wider(names_from = 'WB_TYPE', values_from = 'site_count', values_fill = 0) %>%
    st_drop_geometry() %>%
    rename(geometry = geometry_point) %>%
    st_as_sf(sf_column_name = 'geometry')
  
  write_to_geojson(data = data_sf_wide,
                   cols_to_keep = NULL, # keep all columns
                   outfile = outfile)
}

