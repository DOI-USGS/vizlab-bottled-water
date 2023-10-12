#' @title munge inventory data
#' @description function that cleans the raw inventory data,
#' correcting variable names and data entry errors
#' @param inventory_csv the raw inventory data provided by 
#' collaborators as a csv file
#' @return a dataframe of cleaned data w/ all spaces removed
#' from variable names, cleaned water source info, and source
#' category information
munge_inventory_data <- function(inventory_csv) {
  # read in csv, with empty, 9999, and -9999 values as NA
  readr::read_csv(inventory_csv, col_types = cols(), na = c('', 'NA', '9999', '-9999')) %>%
    # Remove columns w/ entirely NA values
    dplyr::select(where(function(x) !all(is.na(x)))) %>%
    # clean data
    mutate(
      # fix types in WB_TYPE
      WB_TYPE = case_when(
        WB_TYPE == 'Bottled water' ~ 'Bottled Water',
        WB_TYPE == 'Soft drinks' ~ 'Soft Drinks',
        TRUE ~ WB_TYPE),
      # standardize water source variables
      water_source = case_when(
        WTRSRC == 'Well(s)' ~ 'well',
        WTRSRC == 'Spring(s)' ~ 'spring',
        WTRSRC == 'SW Intake(s)' ~ 'surface water intake',
        tolower(WTRSRC) == 'public supply' ~ 'public supply',
        WTRSRC == 'Combination of different sources' ~ 'combination',
        WTRSRC == 'Other (e.g., humidity, sea water)' ~ 'other',
        TRUE ~ WTRSRC
      ),
      # define source category based on water source
      source_category = case_when(
        water_source %in% c('undetermined', 'public supply', 
                            'combination') ~ water_source,
        TRUE ~ 'self supply'
      ),
      # set shared attribute for all entries
      facility_category = 'Bottling facility'
    ) %>%
    # pull state and county fips
    separate_wider_delim(STATE_NAME, delim = ':', names = c('state_fips', 'state_name'), cols_remove = FALSE) %>%
    separate_wider_delim(COUNTY, delim = ':', names = c('full_fips', 'county_name'), cols_remove = FALSE) %>%
    # need to drop first 2 digits to get county fips b/c refers to state
    mutate(county_fips = sub('..', '', full_fips),
           # fix bad STATE_ABBV values
           state_abbr = case_when(
             state_name == 'Illinois' ~ 'IL',
             state_name == 'Maryland' ~ 'MD',
             state_name == 'Texas' ~ 'TX',
             state_name == 'Virgin Islands' ~ 'VI',
             TRUE ~ STATE_ABBV
           ))
}

#' @title  
#' @description  
#' @param  
#' @return  
get_county_facility_counts <- function(sites_sf, counties_sf, states_sf, types) {
  
  county_sites <- sites_sf %>% 
    dplyr::select(-STATE_NAME) %>%
    st_intersection(counties_sf) %>%
    # Catch incorrect duplicate for facility on county line
    filter(!(FAC_ID == 'WI00862' & GEOID == '55027')) %>%
    left_join(states_sf %>% 
                st_drop_geometry() %>% 
                dplyr::select(STUSPS, STATE_NAME = NAME, STATEFP, group), 
              by = c('STATEFP', 'STUSPS', 'STATE_NAME', 'group'))
  
  # Get count of facilities, by type, in each county
  facility_summary_county <- county_sites %>%
    filter(WB_TYPE %in% types) %>%
    group_by(STATE_NAME, STATEFP, STUSPS, NAMELSAD, GEOID) %>%
    summarize(site_count = n()) %>%
    mutate(WB_TYPE = 'All') %>%
    ungroup() %>%
    st_drop_geometry()
  
  # Get count of facilities, by type, in each county
  facility_type_summary_county <- county_sites %>%
    filter(WB_TYPE %in% types) %>%
    group_by(STATE_NAME, STATEFP, STUSPS, NAMELSAD, GEOID, WB_TYPE) %>%
    summarize(site_count = n()) %>%
    mutate(WB_TYPE = factor(WB_TYPE, levels = types)) %>%
    ungroup() %>%
    st_drop_geometry()
  
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