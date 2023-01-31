#' @title re-project and combine spatial data
#' @description re-project and then combine 1 or more sf objects into a
#' single sf object
#' @param ... 1 or more sf objects
#' @param proj projection to which all passed sf objects will be transformed
#' @return a single sf object of all passed geometries, in the specified
#' projection
reproject_and_combine_spatial_data <- function(..., proj) {
  regions <- list(...)
  purrr::map_df(regions, function(region_sf) {
    st_transform(region_sf, proj) %>%
      dplyr::select(region, geometry)
  })
}

#' @title Add centroids
#' @description Adds centroids as a point geometry to a polygon sf object
#' @param polygon_sf the polygon sf object
#' @return returns the polygon sf object with an additional field
#' `geometry_point` that is the point geometry of the polygon centroid
add_centroids <- function(polygon_sf) {
  mutate(polygon_sf, geometry_point = st_geometry(st_centroid(polygon_sf)))
}

#' @title summarize raster for regions
#' @description function that uses a specified `summary_fxn` to compute
#' a summary statistic (named by `summary_name`) for a set of polygons or
#' polygon (`poly`) given the values in the specified `raster`
#' @param raster the raster from which values will be summarized
#' @param poly the polygon(s) for which raster values should be summarized
#' @param summary_fxn the function to be used to compute the summary values,
#' e.g. 'mean', 'sum', 'max' - see predefine summary operations listed
#' in documentation for `exact_extract`: 
#' https://cran.r-project.org/web/packages/exactextractr/exactextractr.pdf
#' @param summary_name the name to be use for the summary statistic
#' @param id_col_to_include name of column in poly dataset that should be 
#' appended to the summary dataframe
#' @return a summary dataframe w/ a row for each polygon element in `poly`
#' with the requested summary value of `raster` within that polygon. The
#' dataframe includes the column `id_col_to_include` from `poly` and names
#' the output value based on `summary_name`
summarize_raster_for_regions <- function(raster, poly, summary_fxn, summary_name, id_col_to_include) {
  # reproject poly to projection of raster
  poly_proj <- poly %>% st_transform(crs(raster))
  
  # get summary value for each region
  poly_summary <- exact_extract(raster, poly_proj, summary_fxn, 
                               append_cols = id_col_to_include, progress = FALSE) %>%
    rename(!!summary_name := !!summary_fxn)
}

#' @title summarize categorical raster for regions
#' @description function that summarizes the proportion each category within a
#' polygon, based on a categorical raster
#' @param raster the raster from which values will be summarized
#' @param poly the polygon(s) for which raster values should be summarized
#' @param id_col_to_include name of column in poly dataset that should be 
#' appended to the summary dataframe and used to summarize the output
#' @return a summary dataframe w/ a row for each categorical value within each
#' polygon, and a column that indicates the percent of the polygon that
#' falls into each category. The dataframe includes the column 
#' `id_col_to_include` from `poly`
summarize_categorical_raster_for_regions <- function(raster, poly, id_col_to_include) {
  # reproject poly to projection of raster
  poly_proj <- poly %>% st_transform(crs(raster))
  
  coverage <- exactextractr::exact_extract(raster, poly_proj, function(df) {
    df %>%
      group_by(!!sym(id_col_to_include), value) %>%
      summarize(area = sum(coverage_area)) %>%
      group_by(!!sym(id_col_to_include)) %>%
      mutate(percent = area/sum(area)*100) %>%
      ungroup() %>%
      mutate(percent = format(percent, scientific=FALSE))
  },
  summarize_df = TRUE, coverage_area = TRUE, include_cols = id_col_to_include)
}

#' @title crop to buffered conus
#' @description crops a raster to a buffered CONUS, using the specified
#' `buffer` value
#' @param raster raster to be cropped
#' @param buffer value with which to buffer CONUS prior to cropping raster
#' @return a raster cropped to the extent of the buffered CONUS
crop_to_buffered_conus <- function(raster, buffer) {
  # crop raster to states, including buffer so that extends into Canada
  states_buff <- spData::us_states %>% 
    st_transform(crs(raster)) %>% 
    st_buffer(buffer)
  
  raster_cropped <- crop(raster, extent(states_buff))
  
  return(raster_cropped)
}

#' @title identify major stream
#' @description identify the major stream within given region
#' @param regional_streams streams within given region (computed
#' previously with st_intersection)
#' @return A single-row dataframe identifying the primary stream,
#' based on Strahler order and length of stream within region
identify_major_stream <- function(regional_streams) {
  # Subset streams to highest and second-highest Strahler values
  higher_order_subset <- regional_streams %>%
    filter(Strahler >= max(Strahler)-1) 
  
  # Identify which of stream subset is the primary stream, based on total_length w/i region
  main_stream <- higher_order_subset %>%
    mutate(intersection_length = st_length(higher_order_subset)) %>%
    group_by(region, Name) %>%
    summarize(Strahler = first(Strahler), total_length = sum(intersection_length)) %>%
    group_by(region) %>%
    arrange(desc(total_length), desc(Strahler)) %>%
    rename(primary_river = Name) %>%
    slice(1)
}