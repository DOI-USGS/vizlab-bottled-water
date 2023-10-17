source('1_fetch/src/file_utils.R')
source('2_process/src/spatial_utils.R')
source('2_process/src/data_utils.R')

p2_targets <- list(
  ##### Set up state spatial data #####

  # U.S. states
  tar_target(p2_conus_oconus_sf,
             tigris::states(cb = TRUE) %>%
               st_transform(p1_proj) %>%
               mutate(group = case_when(
                 STUSPS %in% c(state.abb[!state.abb %in% c('AK', 'HI')], 'DC') ~ 'CONUS',
                 STUSPS %in% c('GU', 'MP') ~ 'GU_MP',
                 STUSPS %in% c('PR', 'VI') ~ 'PR_VI',
                 TRUE ~ STUSPS
               )) %>%
               filter(group %in% c('CONUS', 'AK', 'HI', 'GU_MP', 'PR_VI', 'AS'))),

  # CONUS states
  tar_target(p2_conus_sf,
             p2_conus_oconus_sf %>%
               filter(STUSPS %in% state.abb[!state.abb %in% c('AK', 'HI')]) %>%
               add_centroids() %>%
               mutate(location = 'mainland')),

  # All U.S. counties
  tar_target(p2_counties_conus_oconus_sf,
             tigris::counties() %>%
               st_transform(crs = p1_proj) %>%
               left_join(p2_conus_oconus_sf %>%
                           st_drop_geometry() %>%
                           dplyr::select(STUSPS, STATE_NAME = NAME, STATEFP, group),
                         by = 'STATEFP') %>%
               filter(group %in% c('CONUS', 'AK', 'HI', 'GU_MP', 'PR_VI', 'AS'))),

  ##### Munge site inventory data ######
  tar_target(p2_inventory_sites,
             munge_inventory_data(p1_inventory_csv)),

  # Get unique facility types
  tar_target(p2_facility_types,
             p2_inventory_sites %>%
               arrange(WB_TYPE) %>%
               pull(WB_TYPE) %>%
               unique()),

  tar_target(p2_inventory_sites_sf,
             p2_inventory_sites %>%
               # convert to sf. According to metadata, crs is Spherical Web
               # Mercator, which uses WGS84 as a datum
               st_as_sf(coords = c("LONGITUDE", "LATITUDE"), crs = 4326, remove = FALSE) %>%
               st_transform(p1_proj)),

  ###### All U.S. states and territories ######

  # Get count of facilities, by type
  tar_target(p2_facility_type_summary,
             p2_inventory_sites %>%
               group_by(WB_TYPE) %>%
               summarize(site_count = n()) %>%
               arrange(desc(site_count)) %>%
               mutate(WB_TYPE = factor(WB_TYPE, levels = WB_TYPE))),

  # Get count of facilities, by state
  tar_target(p2_facility_summary_state,
             p2_inventory_sites %>%
               group_by(state_name, state_abbr) %>%
               summarize(site_count = n())),

  # Get count of facilities, by state and by type
  tar_target(p2_facility_type_summary_state,
             p2_inventory_sites %>%
               left_join(p2_conus_oconus_sf, by = c('state_fips' = 'STATEFP')) %>%
               group_by(NAME, state_abbr, WB_TYPE) %>%
               summarize(site_count = n()) %>%
               mutate(WB_TYPE = factor(WB_TYPE, levels = p2_facility_type_summary$WB_TYPE))),

  tar_target(p2_facility_type_summary_state_csv,
             write_to_csv(data = p2_facility_type_summary_state,
                          outfile = 'public/state_facility_type_summary.csv'),
             format = 'file'),

  # Get summary counts of facilities, by county
  tar_target(p2_facility_summary_county,
             get_county_facility_counts(sites_sf = p2_inventory_sites_sf,
                                        counties_sf = p2_counties_conus_oconus_sf,
                                        states_sf = p2_conus_oconus_sf,
                                        types = p2_facility_types)),

  # Get summary of facility supply source categories, by type
  tar_target(p2_source_category_order,
             c('Undetermined', 'Combination', 'Self-supply', 'Public supply')),

  tar_target(p2_supply_summary,
             p2_inventory_sites %>%
               mutate(WB_TYPE = factor(WB_TYPE, levels = p2_facility_type_summary$WB_TYPE)) %>%
               group_by(WB_TYPE, source_category) %>%
               summarize(site_count = n()) %>%
               mutate(source_category = factor(source_category, levels = p2_source_category_order)) %>%
               group_by(WB_TYPE) %>%
               mutate(percent = site_count/sum(site_count)*100)),

  # Get summary of facility supply source categories, by type and by state
  tar_target(p2_supply_summary_state,
             p2_inventory_sites %>%
               mutate(WB_TYPE = factor(WB_TYPE, levels = p2_facility_type_summary$WB_TYPE)) %>%
               group_by(state_name, state_abbr, WB_TYPE, source_category) %>%
               summarize(site_count = n()) %>%
               mutate(source_category = factor(source_category, levels = p2_source_category_order))),

  # Get summary of facility supply sources, by type
  tar_target(p2_source_order,
             c('Undetermined', 'Combination', 'Well', 'Spring', 'Surface water intake', 'Public supply')),

  tar_target(p2_source_summary,
             p2_inventory_sites %>%
               mutate(WB_TYPE = factor(WB_TYPE, levels = p2_facility_type_summary$WB_TYPE)) %>%
               filter(!water_source == 'Other') %>% # exclude other for now (only 6 facilities)
               group_by(WB_TYPE, water_source) %>%
               summarize(site_count = n()) %>%
               mutate(water_source = factor(water_source, levels = p2_source_order)) %>%
               group_by(WB_TYPE) %>%
               mutate(percent = site_count/sum(site_count)*100,
                      ratio = site_count/sum(site_count))),
  ###### Water Use  ######
  tar_target(p2_exclude_states,
             c("AK", "HI", "GU", "PR", "VI")),
  tar_target(p2_water_use,
            read_csv(p1_water_use_csv, col_types = cols())),

  tar_target(
    p2_inventory_sites_wu_conus_sf,
    p2_inventory_sites_sf %>%
      left_join(p2_water_use, by = 'FAC_ID') %>%
      mutate(has_wu = !is.na(Annual_MGD)) %>% # WU_DATA_FLAG field has errors
      filter(!STATE_ABBV %in% p2_exclude_states)),

  tar_target(
    p2_inventory_sites_wu_conus_summary_sf,
    p2_inventory_sites_wu_conus_sf %>%
      dplyr::select(WB_TYPE, FAC_ID, has_wu, water_source, source_category) %>%
      distinct(FAC_ID, .keep_all = TRUE)),

  ###### CONUS ######
  # get CONUS subset
  tar_target(p2_inventory_sites_sf_CONUS,
             filter(p2_inventory_sites_sf,
                    state_name %in% state.name,
                    !(state_abbr %in% c('AK','HI')))),
  tar_target(p2_bw_inventory_sites_county_CONUS,
             p2_inventory_sites_sf_CONUS |>
               janitor::clean_names() |>
               filter(wb_type == "Bottled water") |>
               group_by(full_fips, source_category) |>
               summarize(site_count = n()) |>
               group_by(full_fips) |>
               mutate(percent = site_count/sum(site_count)*100) |>
               # Filter out type 'undetermined' for now
               filter(source_category %in%
                        c("Self-supply", "Combination", "Public supply")) |>
               mutate(source_category = factor(source_category, levels =
                                                 c("Self-supply", "Combination", "Public supply"))) |>
               st_drop_geometry()),

  ##### Regional statistics #####

  # get region areas
  tar_target(p2_region_areas,
             p1_regions_sf %>%
               mutate(area_m2 = st_area(p1_regions_sf),
                      area_km2 = set_units(area_m2, km^2),
                      area_ha = set_units(area_m2, hectares),
                      area_mi2 = set_units(area_m2, mi^2)) %>%
               st_drop_geometry()),

  # Identify which states each region overlaps
  tar_target(p2_region_state_summary,
             p2_conus_sf %>%
               sf::st_intersection(p1_regions_sf) %>%
               group_by(region) %>%
               summarize(states = list(NAME)) %>%
               st_drop_geometry()),

  # Number of bottling facilities in each region
  tar_target(p2_region_facility_count,
             p1_regions_sf %>%
               mutate(facility_count = lengths(st_intersects(p1_regions_sf, p2_inventory_sites_sf))) %>%
               st_drop_geometry() %>%
               dplyr::select(region, facility_count)),

  # Get intersection of facilities and each region
  # (may use for mapping later)
  tar_target(p2_region_facilities,
             p2_inventory_sites_sf %>%
               st_intersection(p1_regions_sf) %>%
               group_by(region) %>%
               tar_group(),
             pattern = map(p1_regions_sf),
             iteration = 'group'),

  # Summary of facility type and sources, by region
  tar_target(p2_region_facility_summary,
             p2_region_facilities %>%
               group_by(region, WB_TYPE, water_source, source_category) %>%
               summarise(total_count=n(),.groups = 'drop')),

  # Get population in each region
  tar_target(p2_region_pop,
             {
               # read in world pop tiff
               world_pop <- raster(p1_population_tif)

               # crop raster to states, including buffer so that extends into Canada
               pop_cropped <- crop_to_buffered_conus(world_pop, buffer = 250000)

               # get total pop for each region
               region_pop <- summarize_raster_for_regions(pop_cropped, p1_regions_sf,
                                                          summary_fxn = 'sum', summary_name = 'population',
                                                          id_col_to_include = 'region')
             }),

  # Get mean 30-year ppt in each region
  tar_target(p2_region_ppt,
             {
               # use PRISM package function to identify correct subset
               lowRes <- prism_archive_subset(type = "ppt", temp_period = "annual normals", resolution = "4km")

               # for targets dependency tracking, ensure that matches tracked directory
               tar_assert_identical(lowRes, basename(p1_PRISM_4km_dir), "identified prism subset doesn't match tracked directory")

               # convert to raster
               lowRes_rast <- raster(pd_to_file(lowRes))

               # get ppt means for each region
               region_ppt <- summarize_raster_for_regions(lowRes_rast, p1_regions_sf,
                                                          summary_fxn = 'mean', summary_name = 'mean_ppt_mm',
                                                          id_col_to_include = 'region')
             }),

  # Get mean percent impervious for each region
  tar_target(p2_region_impervious,
             {
               # get percent impervious means for each region
               region_imper <- summarize_raster_for_regions(p1_NLCD, p1_regions_sf,
                                                          summary_fxn = 'mean', summary_name = 'mean_per_imperv',
                                                          id_col_to_include = 'region')
             },
             pattern = map(p1_NLCD, p1_regions_sf)),

  # Get Koppen climate types in each region
  tar_target(p2_region_climate,
             {
               climate <- raster(p1_climate_tif)

               # crop raster to states, including buffer so that extends into Canada
               climate_cropped <- crop_to_buffered_conus(climate, buffer = 250000)

               # get climate types in each region
               region_climate <- summarize_categorical_raster_for_regions(climate_cropped, p1_regions_sf, id_col_to_include = 'region') %>%
                 # join w/ legend to add climate categories
                 left_join(p1_climate_legend, by = 'value') %>%
                 dplyr::select(region, climate, percent)

             }),

  # Load stream polylines
  tar_target(
    p2_streams_sf,
    st_read(p1_hydro_gdb, quiet = TRUE, layer='Stream') %>%
      st_zm() %>%
      st_transform(crs = st_crs(p1_proj))),

  # Get intersection of streams and each region
  # (may use for mapping later)
  tar_target(
    p2_region_streams,
    p2_streams_sf %>%
      st_intersection(p1_regions_sf) %>%
      group_by(region) %>%
      tar_group(),
    pattern = map(p1_regions_sf),
    iteration = 'group'),

  # Identify major stream w/i each region
  # retain geometry here for use in mapping in 3_visualize
  # but iterate as list to handle multilinestrings
  tar_target(
    p2_region_stream_summary_sf,
    identify_major_stream(p2_region_streams),
    pattern = map(p2_region_streams),
    iteration = 'list'),

  # drop geometry and combine into summary
  tar_target(
    p2_region_stream_summary,
    purrr::map_dfr(p2_region_stream_summary_sf, ~st_drop_geometry(.x))),

  # Compile regional statistics
  tar_target(p2_region_summary,
             purrr::reduce(list(p1_region_info, p2_region_facility_count,
                                dplyr::select(p2_region_stream_summary, region, primary_river),
                                p2_region_areas, p2_region_state_summary, p2_region_pop, p2_region_ppt, p2_region_impervious),
                           dplyr::left_join, by = 'region')),

  # Save regional output
  tar_target(p2_region_summary_csv,
             write_to_csv(p2_region_summary %>%
                            dplyr::select(-tar_group) %>%
                            rowwise() %>%
                            mutate(states = paste(unlist(states), sep='', collapse=', ')),
                          '2_process/out/region_summary.csv'),
             format = 'file'),

  tar_target(p2_region_summary_facility_csv,
             write_to_csv(p2_region_facility_summary, '2_process/out/region_facilities.csv'),
             format = 'file'),

  tar_target(p2_region_summary_climate_csv,
             write_to_csv(p2_region_climate, '2_process/out/region_climate.csv'),
             format = 'file')
)
