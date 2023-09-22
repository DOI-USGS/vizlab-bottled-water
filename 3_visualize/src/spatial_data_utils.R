#' @title export county data to topojson
#' @description join county data to county centroids, reformat, and export
#' @param data county level facility count data
#' @param centroids_sf sf object with county centroids
#' @param tmp_dir temporary directory to which to write intermediate geojson
#' @param outfile filepath to which topojson should be written
#' @param precision precision to which all coordinates should be rounded
#' @return the filepath of the saved topojson
export_county_data_to_topojson <- function(data, centroids_sf, tmp_dir, outfile,
                                           precision) {
  
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
  
  export_to_topojson(data_sf = data_sf_wide, 
                     cols_to_keep = NULL, # keep all columns
                     tmp_dir = tmp_dir, 
                     outfile = outfile, 
                     precision = precision)
}

