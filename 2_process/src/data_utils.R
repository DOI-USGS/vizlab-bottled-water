#' @title munge inventory data
#' @description function that cleans the raw inventory data,
#' correcting variable names and data entry errors
#' @param inventory  the raw inventory data provided by 
#' collaborators and read in from .xlsx
#' @return a dataframe of cleaned data w/ all spaces removed
#' from variable names, cleaned water source info, and source
#' category information
munge_inventory_data <- function(inventory) {
  inventory %>%
    # replace all spaces in variable names with '.'
    rename_all(~ make.names(.)) %>%
    # clean data
    mutate(
      # set -9999 lat and long values to NA
      across(Latitude:Longitude, ~na_if(., -9999)),
      # fix types in WB_TYPE
      WB_TYPE = case_when(
        WB_TYPE == 'Bottled water' ~ 'Bottled Water',
        WB_TYPE == 'Soft drinks' ~ 'Soft Drinks',
        TRUE ~ WB_TYPE),
      # standardize water source variables
      water_source = case_when(
        Water.Source.s. == 'Well(s)' ~ 'well',
        Water.Source.s. == 'Spring(s)' ~ 'spring',
        Water.Source.s. == 'SW Intake(s)' ~ 'sw intake',
        tolower(Water.Source.s.) == 'public supply' ~ 'public supply',
        Water.Source.s. == 'Combination of different sources' ~ 'combination',
        TRUE ~ NA_character_
      ),
      # define source category based on water source
      source_category = case_when(
        is.na(water_source) ~ 'undetermined',
        water_source == 'public supply' ~ water_source,
        water_source == 'combination' ~ 'both',
        TRUE ~ 'self supply'
      ),
      # set shared attribute for all entries
      facility_category = 'Bottling facility'
      ) #%>%
  # COMMENTED OUT for now b/c of missing values
    # # pull state and county fips
    # separate(State, c('state_fips', NA), sep=':', remove = FALSE) %>%
    # separate(County, c('full_fips', NA), sep=':', remove = FALSE) %>%
    # # need to drop first 2 digits to get county fips b/c refers to state
    # mutate(county_fips = sub('..', '', full_fips))
}