source('3_visualize/src/plot_utils.R')
source('3_visualize/src/sf_utils_shift.R')
source('3_visualize/src/mapping_utils.R')

p3_targets <- list(

  ##### Spatial context layers ##### 
  # Apply shifting to the sites 
  tar_target(p3_inventory_sites_shifted,
             apply_shifts_to_sites(
               sites_sf = p2_inventory_sites_sf,
               proj_str = p1_proj,
               states_shp = p1_nws_states_shp
             )),

  # Apply shifting to the state/territory polygons 
  tar_target(p3_spatial_shifted,
             generate_usa_map_data(proj_str = p1_proj,
                                   outline_states = TRUE, 
                                   states_shp = p1_nws_states_shp)),
  
  # get simplified state geometries, for plotting
  tar_target(p3_conus_sf,
             rmapshaper::ms_simplify(p2_conus_sf, keep=0.7)),
  
  # get simplified and cropped counties, for plotting
  tar_target(p3_counties_sf,
             p2_counties_sf %>% 
               rmapshaper::ms_simplify(keep = 0.01) %>%
               st_intersection(st_union(p3_conus_sf)) %>%
               add_centroids() %>%
               left_join(p2_states_sf %>% 
                           st_drop_geometry() %>% 
                           dplyr::select(STATE, STATE_NAME = NAME, FIPS), 
                         by=c('STATEFP'='FIPS'))),

  ##### Figure parameters #####
  tar_target(p3_site_type_colors,
             {
               colors <-  MetBrewer::met.brewer("Archambault", n=length(p2_facility_types), type="discrete")
               colors <- replace(colors, c(6), c('#66BCAA'))
               names(colors) <- p2_facility_types
               return(colors)
             }),
  
  tar_target(p3_sites_map_params,
             tibble(
               site_size = 1.5,
               site_fill_colors = "#000000",
               site_color = '#666666',
               site_alpha = 0.5,
               site_pch = 21, 
               site_stroke = 0.25,
               state_fill = '#E2E2E2', 
               state_color = "#ffffff",
               state_size = 0.5
             )),
  
  ##### Site location maps + figures #####
  
  ###### Conus maps #####
  tar_target(p3_sites_map_conus_FY21,
             map_sites(filter(p2_inventory_sites_sf_CONUS, FY_Entered == 2021),
                       states = p2_conus_sf, 
                       site_size = 1.1,
                       fill_by_type = FALSE,
                       site_fill_colors = p3_sites_map_params$site_fill_colors, 
                       site_color = p3_sites_map_params$site_color,
                       site_alpha = p3_sites_map_params$site_alpha,
                       site_pch = p3_sites_map_params$site_pch, 
                       site_stroke = p3_sites_map_params$site_stroke,
                       state_fill = p3_sites_map_params$state_fill, 
                       state_color = p3_sites_map_params$state_color,
                       state_size = p3_sites_map_params$state_size,
                       simplify = TRUE, 
                       simplification_keep = 0.7,
                       legend_position = c(0.9, 0.3), 
                       legend_title_size = 18, 
                       legend_text_size = 14)),
  
  tar_target(p3_sites_map_conus_FY22,
             map_sites(filter(p2_inventory_sites_sf_CONUS, FY_Entered == 2022),
                       states = p2_conus_sf, 
                       site_size = 1.1,
                       fill_by_type = FALSE,
                       site_fill_colors = p3_sites_map_params$site_fill_colors, 
                       site_color = p3_sites_map_params$site_color,
                       site_alpha = p3_sites_map_params$site_alpha,
                       site_pch = p3_sites_map_params$site_pch, 
                       site_stroke = p3_sites_map_params$site_stroke,
                       state_fill = p3_sites_map_params$state_fill, 
                       state_color = p3_sites_map_params$state_color,
                       state_size = p3_sites_map_params$state_size,
                       simplify = TRUE, 
                       simplification_keep=0.7,
                       legend_position = c(0.9, 0.3), 
                       legend_title_size = 18, 
                       legend_text_size = 14)),
  
  tar_target(p3_sites_map_conus_fy_comparison,
             combine_conus_maps(p3_sites_map_conus_FY21, p3_sites_map_conus_FY22, 
                                title1 = 'FY21', title2 = 'FY22',
                                width = 16, height = 9, text_color = 'black',
                                title_font_size = 36,
                                legend_font_size = 14,
                                plot_title_font_size = 18)),
  
  tar_target(p3_sites_map_conus_fy_comparison_png,
             save_figure(p3_sites_map_conus_fy_comparison, outfile = '3_visualize/out/sites_map_conus_fy_comparison.png', 
                         bkgd_color = "#ffffff", width = 16, height = 9, dpi = 300),
             format = 'file'),
  
  tar_target(p3_sites_map_conus,
             map_sites(p2_inventory_sites_sf_CONUS,
                       states = p2_conus_sf,
                       site_size = p3_sites_map_params$site_size,
                       fill_by_type = FALSE,
                       site_fill_colors = p3_sites_map_params$site_fill_colors, 
                       site_color = p3_sites_map_params$site_color,
                       site_alpha = p3_sites_map_params$site_alpha,
                       site_pch = p3_sites_map_params$site_pch, 
                       site_stroke = p3_sites_map_params$site_stroke,
                       state_fill = p3_sites_map_params$state_fill, 
                       state_color = p3_sites_map_params$state_color,
                       state_size = p3_sites_map_params$state_size,
                       simplify = TRUE, 
                       simplification_keep = 0.7,
                       legend_position = c(0.9, 0.3), 
                       legend_title_size = 24, 
                       legend_text_size = 20)),
  
  tar_target(p3_sites_map_conus_png,
             save_figure(p3_sites_map_conus, outfile = '3_visualize/out/sites_map_conus.png', 
                       bkgd_color = "#ffffff", width = 16, height = 9, dpi = 300),
             format = 'file'),
  
  
  ###### National maps - not shifted ######
  tar_target(p3_sites_maps,
             map_sites(p2_inventory_site_groups_sf,
                       states = p2_spatial_sf,
                       site_size = p3_sites_map_params$site_size,
                       fill_by_type = FALSE,
                       site_fill_colors = p3_sites_map_params$site_fill_colors, 
                       site_color = p3_sites_map_params$site_color,
                       site_alpha = p3_sites_map_params$site_alpha,
                       site_pch = p3_sites_map_params$site_pch, 
                       site_stroke = p3_sites_map_params$site_stroke,
                       state_fill = p3_sites_map_params$state_fill, 
                       state_color = p3_sites_map_params$state_color,
                       state_size = p3_sites_map_params$state_size,
                       simplify = TRUE, 
                       simplification_keep = 0.7,
                       legend_position = c(0.9, 0.3), 
                       legend_title_size = 24, 
                       legend_text_size = 20),
             pattern = map(p2_inventory_site_groups_sf, p2_spatial_sf),
             iteration = 'list'),
  
  tar_target(p3_sites_map,
             combine_into_national_map(maps = p3_sites_maps,
                                       spatial_data = p2_spatial_sf,
                                       groups = p2_spatial_groups,
                                       width = 16, height = 9, text_color = 'black',
                                       title_font_size = 36,
                                       legend_font_size = 14)),
  # INCOMPLETE
  tar_target(p3_sites_map_png,
             save_figure(p3_sites_map, outfile = '3_visualize/out/sites_map_national_to_scale.png', bkgd_color = '#ffffff',
                       width = 16, height = 9, dpi = 300),
             format = 'file'),
  
  ###### National maps - shifted ######
  tar_target(p3_sites_map_shifted,
             map_sites(p3_inventory_sites_shifted,
                       states = p3_spatial_shifted,
                       site_size = p3_sites_map_params$site_size,
                       fill_by_type = FALSE,
                       site_fill_colors = p3_sites_map_params$site_fill_colors, 
                       site_color = p3_sites_map_params$site_color,
                       site_alpha = p3_sites_map_params$site_alpha,
                       site_pch = p3_sites_map_params$site_pch, 
                       site_stroke = p3_sites_map_params$site_stroke,
                       state_fill = p3_sites_map_params$state_fill, 
                       state_color = p3_sites_map_params$state_color,
                       state_size = 0.5,
                       simplify = FALSE, 
                       simplification_keep = 0.7,
                       legend_position = c(0.7, 0.91), 
                       legend_title_size = 24, 
                       legend_text_size = 20)),
  
  tar_target(p3_sites_map_shifted_annotated,
             annotate_shifted_map(p3_sites_map_shifted, text_color = 'black', plot_title_font_size = 16, width = 16, height = 9)),
  
  tar_target(p3_sites_map_shifted_png,
             save_figure(p3_sites_map_shifted_annotated, outfile = '3_visualize/out/sites_map_national_shifted.png', 
                      bkgd_color = "#ffffff", width=16, height=9, dpi=300),
             format = 'file'),
  
  tar_target(p3_sites_map_shifted_FY21,
             map_sites(filter(p3_inventory_sites_shifted, FY_Entered == 2021),
                       states = p3_spatial_shifted,
                       site_size = p3_sites_map_params$site_size,
                       fill_by_type = FALSE,
                       site_fill_colors = p3_sites_map_params$site_fill_colors, 
                       site_color = p3_sites_map_params$site_color,
                       site_alpha = p3_sites_map_params$site_alpha,
                       site_pch = p3_sites_map_params$site_pch, 
                       site_stroke = p3_sites_map_params$site_stroke,
                       state_fill = p3_sites_map_params$state_fill, 
                       state_color = p3_sites_map_params$state_color,
                       state_size = 0.5,
                       simplify = FALSE, 
                       simplification_keep = 0.7,
                       legend_position = c(0.7, 0.91), 
                       legend_title_size = 24, 
                       legend_text_size = 20)),
  
  tar_target(p3_sites_map_shifted_annotated_FY21,
             annotate_shifted_map(p3_sites_map_shifted_FY21, text_color = 'black', plot_title_font_size = 16, width = 16, height = 9)),
  
  tar_target(p3_sites_map_shifted_FY21_png,
             save_figure(p3_sites_map_shifted_annotated_FY21, outfile = '3_visualize/out/sites_map_national_shifted_FY21.png', 
                         bkgd_color = "#ffffff", width=16, height=9, dpi=300),
             format = 'file'),
  
  tar_target(p3_sites_map_shifted_FY22,
             map_sites(filter(p3_inventory_sites_shifted, FY_Entered == 2022),
                       states = p3_spatial_shifted,
                       site_size = p3_sites_map_params$site_size,
                       fill_by_type = FALSE,
                       site_fill_colors = p3_sites_map_params$site_fill_colors, 
                       site_color = p3_sites_map_params$site_color,
                       site_alpha = p3_sites_map_params$site_alpha,
                       site_pch = p3_sites_map_params$site_pch, 
                       site_stroke = p3_sites_map_params$site_stroke,
                       state_fill = p3_sites_map_params$state_fill, 
                       state_color = p3_sites_map_params$state_color,
                       state_size = 0.5,
                       simplify = FALSE, 
                       simplification_keep = 0.7,
                       legend_position = c(0.7, 0.91), 
                       legend_title_size = 24, 
                       legend_text_size = 20)),
  
  tar_target(p3_sites_map_shifted_annotated_FY22,
             annotate_shifted_map(p3_sites_map_shifted_FY22, text_color = 'black', plot_title_font_size = 16, width = 16, height = 9)),

  tar_target(p3_sites_map_shifted_FY22_png,
             save_figure(p3_sites_map_shifted_annotated_FY22, outfile = '3_visualize/out/sites_map_national_shifted_FY22.png', 
                         bkgd_color = "#ffffff", width=16, height=9, dpi=300),
             format = 'file'),
  
  tar_target(p3_sites_map_shifted_FY23,
             map_sites(filter(p3_inventory_sites_shifted, FY_Entered == 2023),
                       states = p3_spatial_shifted,
                       site_size = p3_sites_map_params$site_size,
                       fill_by_type = FALSE,
                       site_fill_colors = p3_sites_map_params$site_fill_colors, 
                       site_color = p3_sites_map_params$site_color,
                       site_alpha = p3_sites_map_params$site_alpha,
                       site_pch = p3_sites_map_params$site_pch, 
                       site_stroke = p3_sites_map_params$site_stroke,
                       state_fill = p3_sites_map_params$state_fill, 
                       state_color = p3_sites_map_params$state_color,
                       state_size = 0.5,
                       simplify = FALSE, 
                       simplification_keep = 0.7,
                       legend_position = c(0.7, 0.91), 
                       legend_title_size = 24, 
                       legend_text_size = 20)),
  
  tar_target(p3_sites_map_shifted_annotated_FY23,
             annotate_shifted_map(p3_sites_map_shifted_FY23, text_color = 'black', plot_title_font_size = 16, width = 16, height = 9)),
  
  tar_target(p3_sites_map_shifted_FY23_png,
             save_figure(p3_sites_map_shifted_annotated_FY23, outfile = '3_visualize/out/sites_map_national_shifted_FY23.png', 
                         bkgd_color = "#ffffff", width=16, height=9, dpi=300),
             format = 'file'),
  
  tar_target(p3_sites_map_shifted_fy_comparison,
             combine_two_images(image_1_file = p3_sites_map_shifted_FY21_png, image_2_file = p3_sites_map_shifted_png, 
                                image_1_title = 'FY21', image_2_title = 'Current', width = 16, height = 6, bkgd_color = 'white')),
  
  tar_target(p3_sites_map_shifted_fy_comparison_png,
             save_figure(p3_sites_map_shifted_fy_comparison, outfile = '3_visualize/out/sites_map_shifted_fy_comparison.png', 
                      bkgd_color = "#ffffff", width = 16, height = 6, dpi = 300),
             format = 'file'),
  
  
  ###### CONUS - Sites with wateruse (maps and figures) ######
  tar_target(p3_sites_map_conus_wateruse,
             map_wateruse_sites(
               map_of_all_sites = p3_sites_map_conus,
               site_size = p3_sites_map_params$site_size,
               site_fill_colors = '#8F8F8F', 
               site_color = '#E2E2E2',
               site_pch = p3_sites_map_params$site_pch,
               site_stroke = p3_sites_map_params$site_stroke,
               wu_sites = filter(p2_inventory_sites_sf_CONUS, WUDataFlag == 'Y'),
               wu_site_size = 2,
               wu_site_fill_colors = '#0008E6', 
               wu_site_color = '#0008E6',
               wu_site_alpha = 1,
               wu_site_pch = 4,
               wu_site_stroke = 1.1,
               legend_position = c(0.73, 0.95), 
               legend_title_size = 24, 
               legend_text_size = 20)),
  
  tar_target(p3_sites_map_conus_wateruse_png,
             save_figure(p3_sites_map_conus_wateruse, outfile = '3_visualize/out/sites_map_conus_wateruse.png', 
                      bkgd_color = "#ffffff", width = 16, height = 9, dpi = 300),
             format = 'file'),
  
  tar_target(p3_sites_wateruse_chart,
             chart_wateruse_availability(p2_inventory_sites,
                                         has_wu_color = '#0008E6',
                                         no_wu_color = '#A6a6a6')),
  
  tar_target(p3_sites_figure_wateruse,
             combine_wu_map_and_chart(
               p3_sites_map_conus_wateruse,
               p3_sites_wateruse_chart,
               width = 16,
               height = 9
             )),
  
  tar_target(p3_sites_figure_wateruse_png,
             save_figure(p3_sites_figure_wateruse, 
                      outfile = '3_visualize/out/sites_figure_wateruse.png', 
                      bkgd_color = "#ffffff", width = 16, height = 9, dpi = 300),
             format = 'file'),
  
  ###### Facility types (maps and figures) ######
  tar_target(p3_sites_map_conus_type,
             map_sites(filter(p2_inventory_sites_sf_CONUS, WB_TYPE == p2_facility_types),
                       states = p2_conus_sf, 
                       site_size = 1.3,
                       fill_by_type = TRUE,
                       site_fill_colors = p3_site_type_colors, 
                       site_color = '#DEDEDE',
                       site_alpha = 1,
                       site_pch = p3_sites_map_params$site_pch, 
                       site_stroke = p3_sites_map_params$site_stroke,
                       state_fill = '#DEDEDE', 
                       state_color = "#ffffff",
                       state_size = p3_sites_map_params$state_size,
                       simplify=TRUE, 
                       simplification_keep=0.7,
                       legend_position = c(0.9, 0.3), 
                       legend_title_size = 18, 
                       legend_text_size = 14),
             pattern=map(p2_facility_types),
             iteration = 'list'),
  
  tar_target(p3_sites_map_conus_type_combined,
             combine_small_multiples(p3_sites_map_conus_type,
                                     p2_facility_types,
                                     title_font_size = 36,
                                     legend_font_size = 12,
                                     plot_title_font_size = 14,
                                     text_color = 'grey20',
                                     point_layer = 2,
                                     point_size = 1)),
  
  tar_target(p3_sites_map_conus_type_png,
             save_figure(p3_sites_map_conus_type, 
                      outfile = sprintf('3_visualize/out/sites_map_conus_%s.png', p2_facility_types), 
                      bkgd_color = "#ffffff", width = 16, height = 9, dpi = 300),
             pattern = map(p2_facility_types, p3_sites_map_conus_type),
             format = 'file'),
  
  tar_target(p3_sites_map_conus_type_combined_png,
             save_figure(p3_sites_map_conus_type_combined, 
                      outfile = '3_visualize/out/sites_map_conus_types_combined.png', 
                      bkgd_color = "#ffffff", width = 16, height = 9, dpi = 300),
             format = 'file'),
  
  tar_target(p3_type_summary_plot_png,
             generate_type_summary_chart(type_summary = p2_facility_type_summary,
                                         colors = p3_site_type_colors,
                                         title_text_size = 20,
                                         axis_text_size = 16,
                                         bkgd_color = 'white',
                                         width = 8,
                                         height = 6,
                                         outfile = '3_visualize/out/type_summary.png',
                                         dpi = 300),
             format = 'file'),
  
  tar_target(p3_type_facet_map_png,
             generate_facility_type_facet_map(type_summary = p2_facility_type_summary,
                                              type_summary_state = p2_facility_type_summary_state,
                                              colors = p3_site_type_colors,
                                              width = 16, height = 9,
                                              bkgd_color = 'white',
                                              text_color = 'black',
                                              outfile = '3_visualize/out/state_facet.png',
                                              dpi = 300),
             format = 'file'),
  
  ##### Site count figures #####
  # Matrix of counts by state, w/ type summary counts and state summary counts
  tar_target(p3_state_matrix_png,
             generate_site_count_matrix(type_summary = p2_facility_type_summary, 
                                        type_summary_state = p2_facility_type_summary_state, 
                                        state_summary = p2_facility_summary_state,
                                        palette = 'acton',
                                        palette_dir = -1,
                                        bar_fill = '#7A7A7A',
                                        width = 16, height = 9,
                                        outfile = '3_visualize/out/state_count_matrix.png',
                                        dpi = 300),
             format = 'file'),
  
  # proportional symbol map of counts by state
  tar_target(p3_state_site_counts,
             map_site_counts(p2_facility_summary_state,
                             states = p2_conus_sf, conus = TRUE,
                             site_color = '#ffffff',
                             min_radius = 10,
                             palette = "acton", 
                             palette_dir = -1,
                             state_fill = '#ffffff', 
                             state_color = "#7A7A7A",
                             state_size = p3_sites_map_params$state_size,
                             simplify = TRUE, 
                             simplification_keep = 0.7,
                             width = 16, 
                             height = 9, 
                             bkgd_color = '#ffffff')),
  
  tar_target(p3_state_site_counts_png,
             save_figure(p3_state_site_counts, outfile = '3_visualize/out/state_site_counts_conus.png', 
                         bkgd_color = "#ffffff", width = 16, height = 9, dpi = 300),
             format = 'file'),

  # proportional symbol map, by county
  # NOTE NOT USING SIZE_ADJ variable to plot right now, just count
  tar_target(p3_facility_summary_county,
             p2_facility_summary_county %>%
               mutate(size_adj = calcPropRadius(site_count, min(p2_facility_summary_county$site_count), min_radius = 5))),
  
  # join the summary data and state names to the cropped county data
  tar_target(p3_county_data_sf,
             p3_counties_sf %>%
               left_join(p2_facility_summary_county, by=c('STATEFP', 'COUNTYFP', 'GEOID', 'NAME', 'NAMELSAD'))),
  
  # get CONUS subset
  tar_target(p3_county_data_conus_sf,
             filter(p3_county_data_sf, (STATE_NAME %in% state.name) & !(STATE %in% c('AK','HI')))),
  
  # Map total county of facilities, by county
  tar_target(p3_county_site_counts_png,
             map_county_counts_total(p3_county_data_conus_sf,
                                     p3_conus_sf,
                                     outfile = '3_visualize/out/county_site_count_total.png')),
  
  # Map total county of facilities, by county and by type
  tar_target(p3_min_count_across_types,
             min(filter(p3_county_data_conus_sf, !(WB_TYPE=='All')) %>% pull(site_count),  na.rm = TRUE)),
  tar_target(p3_max_count_across_types,
             max(filter(p3_county_data_conus_sf, !(WB_TYPE=='All')) %>% pull(site_count),  na.rm = TRUE)),
  
  tar_target(p3_county_site_counts_types_png,
             map_county_counts_type(p3_county_data_conus_sf,
                                    p3_conus_sf,
                                    min_count = p3_min_count_across_types,
                                    max_count = p3_max_count_across_types,
                                    type = p2_facility_types,
                                    site_colors = p3_site_type_colors,
                                    outfile_template = '3_visualize/out/county_site_count_%s.png'),
             pattern = map(p2_facility_types)),
  
  ##### Water source figures #####
  tar_target(p3_supply_colors,
             {
               supply_colors <- c('#4DC49D', '#D8BF32', '#BD5EC6', '#D4D4D4')
               color_names <- c('public supply', 'self supply', 'both', 'undetermined')
               names(supply_colors) <- color_names
               return(supply_colors)
             }),
  
  tar_target(p3_supply_summary_png,
             generate_supply_summary(supply_summary = p2_supply_summary,
                                     supply_colors = p3_supply_colors,
                                     title_text_size = 20,
                                     axis_text_size = 16,
                                     legend_text_size = 16,
                                     bkgd_color = 'white',
                                     width = 8, height = 6,
                                     outfile = '3_visualize/out/supply_summary.png',
                                     dpi = 300),
             format = 'file'),
  
  tar_target(p3_supply_summary_percent_png,
             generate_supply_summary_percent(supply_summary = p2_supply_summary,
                                     supply_colors = p3_supply_colors,
                                     title_text_size = 20,
                                     axis_text_size = 16,
                                     legend_text_size = 16,
                                     bkgd_color = 'white',
                                     width = 8, height = 6,
                                     outfile = '3_visualize/out/supply_summary_percent.png',
                                     dpi = 300),
             format = 'file'),
  
  
  ##### Regional data maps and plots  ##### 
  # TODO:
  # figure out different simplification for diff regions 
  tar_target(p3_regions_map,
             map_regions(regions = p1_regions_sf,
                         region_info = p1_region_info,
                         states = p2_conus_sf, 
                         state_fill = '#E2E2E2', 
                         state_color = "#ffffff",
                         state_size = 0.5,
                         simplify=TRUE, simplification_keep=0.7)),
  
  tar_target(p3_regions_map_png,
             save_figure(p3_regions_map, outfile = '3_visualize/out/region_map.png', 
                      bkgd_color = "#ffffff", width = 16, height = 9, dpi = 300),
             format = 'file'),
  
  # in progress
  tar_target(p3_region_stream_sites_map,
             map_region_streams_sites(p1_regions_sf_unique_proj, p2_region_streams, p2_region_facilities, site_colors = p3_site_type_colors),
             pattern = map(p1_regions_sf_unique_proj, p2_region_streams, p2_region_facilities),
             iteration = 'list'),
  
  tar_target(p3_region_states_map,
             map_region_on_states(p1_regions_sf_unique_proj, p2_region_state_summary, p2_conus_sf,
                                  region_fill = "#000000", region_color = "#E2E2E2",
                                  state_fill = "#E2E2E2", state_color = "#ffffff"),
             pattern = map(p1_regions_sf_unique_proj, p2_region_state_summary),
             iteration = 'list')
)