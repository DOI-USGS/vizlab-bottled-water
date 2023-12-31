# Adapted from https://github.com/DOI-USGS/gw-conditions/blob/main/3_visualize/src/svg_utils_mapping.R

#' @title generate map data for U.S. states and territories
#' @description generate an sf object containing polygons for all
#' U.S. states and territories
#' @param proj_str proj4 string to use for CONUS
#' @param outline_states logical argument determining whether or not
#' state outlines should be included
#' @param states_shp the shapefile with spatial data for U.S. states
#' and territories
#' @return an sf object with conus and oconus
generate_usa_map_data <- function(proj_str = NULL, outline_states = FALSE, states_shp) {
  if(is.null(proj_str)) {
    # Albers Equal Area
    proj_str <- '+proj=aea +lat_0=23 +lon_0=-96 +lat_1=29.5 +lat_2=45.5 +x_0=0 +y_0=0 +ellps=GRS80 +towgs84=0,0,0,0,0,0,0 +units=m +no_defs +type=crs'
  }
  
  conus_sf <- maps::map("usa", fill = TRUE, plot=FALSE) %>%
    sf::st_as_sf() %>% 
    st_transform(proj_str) %>% 
    st_buffer(0) %>%
    mutate(location = 'mainland')
  
  if(outline_states) conus_sf <- use_state_outlines(conus_sf, proj_str)
  
  # Now add oconus ("outside" conus)
  oconus_sf <- build_oconus_sf(proj_str, states_shp) %>%
    mutate(location = 'not mainland')
  usa_sf <- bind_rows(conus_sf, oconus_sf)
  
  return(usa_sf)
}

#' @title process map data to allow for state outlines to be used
#' @description generate an sf object containing polygons for all
#' U.S. states in CONUS, with separate polygons for islands 
#' @param usa_border_sf sf object with CONUS polygons, including islands
#' @param proj_str proj4 string to use for CONUS
#' @return an sf object with islands as separate polygons from states
use_state_outlines <- function(usa_border_sf, proj_str) {
  
  # Need to remove islands from state outlines and then add back in 
  # later so that they can be drawn as individual polygons. Otherwise,
  # drawn with the state since the original state maps data only has 1
  # ID per state.
  
  usa_islands_sf <- usa_border_sf %>% 
    filter(ID != "main") %>%
    mutate(location = 'not mainland')
  usa_addl_islands_sf <- generate_addl_islands(proj_str) %>%
    mutate(location = 'mainland')
  usa_mainland_sf <- usa_border_sf %>% 
    filter(ID == "main") %>% 
    st_erase(usa_addl_islands_sf) 
  
  # Have to manually add in CO because in `maps`, it is an incomplete
  # polygon and gets dropped somewhere along the way.
  co_sf <- maps::map("state", "colorado", fill = TRUE, plot=FALSE) %>%
    sf::st_as_sf() %>%
    st_transform(proj_str) %>%
    mutate(location = 'mainland')
  
  maps::map("state", fill = TRUE, plot=FALSE) %>%
    sf::st_as_sf() %>%
    st_transform(proj_str) %>%
    st_buffer(0) %>% 
    # Get rid of islands from state outline data
    st_intersection(usa_mainland_sf) %>%
    dplyr::select(-ID.1) %>% # st_intersection artifact that is unneeded
    # Add islands back in as separate polygons from states
    bind_rows(usa_islands_sf) %>%
    bind_rows(usa_addl_islands_sf) %>% 
    st_buffer(0) %>%
    st_cast("MULTIPOLYGON") %>% # Needed to bring back to correct type to use st_coordinates
    rmapshaper::ms_simplify(0.5) %>%
    bind_rows(co_sf) # bind CO after bc otherwise it gets dropped in st_buffer(0)
  
}

#' @title generate additional islands
#' @description generate an sf object containing polygons for a
#' remaining set of geometries that must be rendered separately
#' from the main state polygons
#' @param proj_str proj4 string to use for CONUS
#' @return an sf object with a set of separate polygons
generate_addl_islands <- function(proj_str) {
  # These are not called out specifically as islands in the maps::map("usa") data
  # but cause lines to be drawn across the map if not treated separately. This creates those shapes.
  
  # Counties to be considered as separate polygons
  
  separate_polygons <- list(
    `upper penninsula` = list(
      state = "michigan",
      counties = c(
        "alger",
        "baraga",
        "chippewa",
        "delta",
        "dickinson",
        "gogebic",
        "houghton",
        "iron",
        "keweenaw",
        "luce",
        "mackinac",
        "marquette",
        "menominee",
        "ontonagon",
        "schoolcraft"
      )),
    `eastern shore` = list(
      state = "virginia",
      counties = c(
        "accomack",
        "northampton"
      )),
    # TODO: borders still slightly wonky bc it doesn't line up with counties perfectly. 
    `nags head` = list(
      state = "north carolina",
      counties = c(
        "currituck"
      )),
    # This + simplifying to 0.5 took care of the weird line across NY
    `staten island` = list(
      state = "new york",
      counties = c(
        "richmond"
      )))
  
  purrr::map(names(separate_polygons), function(nm) {
    maps::map("county", fill = TRUE, plot=FALSE) %>%
      sf::st_as_sf() %>%
      st_transform(proj_str) %>% 
      st_buffer(0) %>%
      filter(ID %in% sprintf("%s,%s", separate_polygons[[nm]][["state"]],
                             separate_polygons[[nm]][["counties"]])) %>% 
      mutate(ID = nm) 
  }) %>% 
    bind_rows() %>% 
    group_by(ID) %>% 
    summarize(geom = st_union(geom))
}

#' @title erase spatial geometries
#' @description erase specified geometries `y` from `x`
#' @param x set of geometries from which `y` should be removed
#' @param y set of geometries to be removed from `x`
#' @return an sf object equivalent to `x` without the geometries
#' present in `y`
st_erase <- function(x, y) st_difference(x, st_union(st_combine(y)))
