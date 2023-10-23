#' @title munge inventory data
#' @description function that cleans the raw inventory data,
#' correcting variable names and data entry errors
#' @param inventory_txt the raw inventory data downloaded from ScienceBase
#' @return a dataframe of cleaned data w/ all spaces removed
#' from variable names, cleaned water source info, and source
#' category information
munge_inventory_data <- function(inventory_txt) {
  
  # read in txt, with empty, 9999, and -9999 values as NA
  readr::read_tsv(inventory_txt, col_types = cols(), na = c('', 'NA', '9999', '-9999')) %>%
    # clean data
    mutate(
      # # fix types in WB_TYPE
      WB_TYPE = case_when(
        WB_TYPE == 'Bottled Water' ~ 'Bottled water',
        WB_TYPE == 'Soft Drinks' ~ 'Soft drinks',
        TRUE ~ WB_TYPE),
      # standardize water source variables
      water_source = case_when(
        WTRSRC == 'Well(s)' ~ 'Well',
        WTRSRC == 'Spring(s)' ~ 'Spring',
        WTRSRC == 'SW Intake(s)' ~ 'Surface water intake',
        tolower(WTRSRC) == 'public supply' ~ 'Public supply',
        WTRSRC == 'Combination of different sources' ~ 'Combination',
        WTRSRC == 'Other (e.g., humidity, sea water)' ~ 'Other',
        TRUE ~ str_to_sentence(WTRSRC)
      ),
      # define source category based on water source
      source_category = case_when(
        water_source %in% c('Undetermined', 'Public supply',
                            'Combination') ~ water_source,
        TRUE ~ 'Self-supply'
      ),
      # set shared attribute for all entries
      facility_category = 'Bottling facility'
    ) %>%
    # pull state and county fips
    separate_wider_delim(STATE_NAME, delim = ':', names = c('state_fips', 'state_name'), cols_remove = FALSE) %>%
    separate_wider_delim(COUNTY, delim = ':', names = c('full_fips', 'county_name'), cols_remove = FALSE) %>%
    # need to drop first 2 digits to get county fips b/c refers to state
    mutate(county_fips = sub('..', '', full_fips))
}

#' @title Get county facility counts
#' @description Get counts of facilities for each county - overall and by type
#' @param sites_sf sf object of inventory sites
#' @param counties_sf sf object of U.S. counties
#' @param types vector of facility types
#' @return summarized dataframe with the overall county of facilities in each
#' county as well as the count by facility type
get_county_facility_counts <- function(sites_sf, counties_sf, types) {
  
  # Join county data to sites data to get county fields for later spatial join
  county_sites <- sites_sf %>%
    st_drop_geometry() %>%
    dplyr::select(-STATE_NAME) %>%
    left_join(st_drop_geometry(counties_sf), by = c('full_fips' = 'GEOID'), keep = TRUE) %>%
    dplyr::select(WB_TYPE, FAC_ID, STATE_NAME, STATEFP, STUSPS, NAMELSAD, GEOID, WB_TYPE)

  # Get count of facilities in each county
  facility_summary_county <- county_sites %>%
    filter(WB_TYPE %in% types) %>%
    group_by(STATE_NAME, STATEFP, STUSPS, NAMELSAD, GEOID) %>%
    summarize(site_count = n()) %>%
    mutate(WB_TYPE = 'All') %>%
    ungroup()

  # Get count of facilities, by type, in each county
  facility_type_summary_county <- county_sites %>%
    filter(WB_TYPE %in% types) %>%
    group_by(STATE_NAME, STATEFP, STUSPS, NAMELSAD, GEOID, WB_TYPE) %>%
    summarize(site_count = n()) %>%
    mutate(WB_TYPE = factor(WB_TYPE, levels = types)) %>%
    ungroup()

  # Get max count, across types
  facility_max_count_county <- facility_type_summary_county %>%
    group_by(GEOID) %>%
    summarize(max_count = max(site_count, na.rm = TRUE)) %>%
    mutate(max_count = ifelse(is.na(max_count), 0, max_count))

  # Join together overall count and count by type
  county_summary_all <- bind_rows(facility_summary_county,
                                  facility_type_summary_county) %>%
    left_join(facility_max_count_county, by = 'GEOID')

  return(county_summary_all)
}
