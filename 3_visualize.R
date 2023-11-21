source('1_fetch/src/file_utils.R')
source('3_visualize/src/plot_utils.R')
source('3_visualize/src/sf_utils_shift.R')
source('3_visualize/src/mapping_utils.R')
source('3_visualize/src/spatial_data_utils.R')

p3_targets <- list(

  ##### Spatial context layers #####
  tar_target(p3_conus_sf,
             rmapshaper::ms_simplify(p2_conus_sf, keep=0.2)),

  tar_target(p3_counties_conus_sf,
             p2_counties_conus_oconus_sf %>%
               filter(STATEFP %in% p3_conus_sf$STATEFP) %>%
               rmapshaper::ms_simplify(keep = 0.2) %>%
               st_intersection(st_union(p3_conus_sf))),

  tar_target(p3_conus_oconus_group_simplification,
             tibble(
               group = unique(p2_conus_oconus_sf$group)) %>%
               mutate(
                 simplification_low = case_when(
                   group %in% c('AS') ~ 0.06,
                   group %in% c('PR_VI', 'GU_MP') ~ 0.1,
                   group %in% c('HI') ~ 0.15,
                   group %in% c('AK') ~ 0.015,
                   TRUE ~ 0.3
                 ),
                 simplification_high = case_when(
                   group %in% c('AS') ~ 0.03,
                   group %in% c('GU_MP') ~ 0.05, # may need to be increased?
                   group %in% c('PR_VI') ~ 0.03,
                   group %in% c('HI') ~ 0.05,
                   group %in% c('AK') ~ 0.01,
                   TRUE ~ 0.02
                 )
               )),

  tar_target(p3_conus_oconus_low_sf,
             purrr::pmap_dfr(p3_conus_oconus_group_simplification, function(...) {
               current_group = tibble(...)
               p2_conus_oconus_sf %>%
                 filter(group == current_group$group) %>%
                 rmapshaper::ms_simplify(keep = current_group$simplification_low)
             }) %>%
               st_make_valid() %>%
               mutate(data_id = paste(GEOID, 'low', sep = '_'))),

  tar_target(p3_conus_oconus_high_sf,
             purrr::pmap_dfr(p3_conus_oconus_group_simplification, function(...) {
               current_group = tibble(...)
               p2_conus_oconus_sf %>%
                 filter(group == current_group$group) %>%
                 rmapshaper::ms_simplify(keep = current_group$simplification_high)
             }) %>%
               st_make_valid() %>%
               mutate(data_id = paste(GEOID, 'high', sep = '_'))),

  tar_target(p3_conus_oconus_county_group_simplification,
             tibble(
               group = unique(p2_conus_oconus_sf$group)) %>%
               mutate(simplification = case_when(
                 group %in% c('GU_MP', 'PR_VI', 'HI') ~ 0.02,
                 group %in% c('AS') ~ 0.5,
                 group %in% c('AK') ~ 0.06,
                 TRUE ~ 0.04
               ))),

  tar_target(p3_counties_conus_oconus_sf,
             # Simplify county polygons
             purrr::pmap_dfr(p3_conus_oconus_county_group_simplification, function(...) {
               current_group = tibble(...)
               p2_counties_conus_oconus_sf %>%
                 filter(group == current_group$group) %>%
                 rmapshaper::ms_simplify(keep = current_group$simplification)
             }) %>%
               # Then crop to simplified state polygons (low simplification)
               st_intersection(st_union(p3_conus_oconus_low_sf)) %>%
               # Then add centroids
               add_centroids() %>%
               # Cast polygons to multipolygons to ensure consistent geometry
               sf::st_cast("MULTIPOLYGON")),

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

  ##### TOPOJSONS #####
  # Requires system installation of mapshaper
  # https://github.com/mbloch/mapshaper

  # Export topojson for each state group in p3_conus_oconus_high_sf
  # (high simplification for national map view)
  tar_target(p3_conus_oconus_high_topojsons,
             export_to_topojson(data_sf = filter(p3_conus_oconus_high_sf,
                                                 group == p3_conus_oconus_group_simplification$group),
                                cols_to_keep = c('GEOID', 'NAME', 'data_id', 'geometry'),
                                tmp_dir = '3_visualize/tmp',
                                outfile = sprintf("public/states_polys_%s.json",
                                                  p3_conus_oconus_group_simplification$group),
                                precision = 0.001),
             pattern = map(p3_conus_oconus_group_simplification),
             format = 'file'),

  # Export single topojson for p3_conus_oconus_low_sf
  # (low simplification for zoomed-in state views)
  tar_target(p3_conus_oconus_low_topojson,
             export_to_topojson(data_sf = p3_conus_oconus_low_sf,
                                cols_to_keep = c('GEOID', 'NAME', 'data_id', 'geometry'),
                                tmp_dir = '3_visualize/tmp',
                                outfile = "public/states_polys_CONUS_OCONUS_zoom.json",
                                precision = 0.001),
             format = 'file'),

  # export county polygons to topojson
  tar_target(p3_counties_conus_oconus_topojson,
             export_to_topojson(data_sf = p3_counties_conus_oconus_sf,
                                cols_to_keep = c('GEOID', 'NAMELSAD', 'STATE_NAME',
                                                 'geometry'),
                                tmp_dir = '3_visualize/tmp',
                                outfile = "public/counties_polys_CONUS_OCONUS_zoom.json",
                                precision = 0.001),
             format = 'file'),

  # export summarized county data w/ county centroid geometry
  tar_target(p3_county_centroids_conus_oconus_topojson,
             export_county_data_to_topojson(data = p2_facility_summary_county,
                                            centroids_sf = p3_counties_conus_oconus_sf,
                                            tmp_dir = '3_visualize/tmp',
                                            outfile = "public/counties_centroids_CONUS_OCONUS.json",
                                            precision = 0.001),
             format = 'file'),

  ##### Figure parameters #####
  tar_target(p3_font_legend,
             {
               # import font
               font_legend <- 'Source Sans Pro'
               font_add_google(font_legend)
               showtext_opts(dpi = 300, regular.wt = 200, bold.wt = 700)
               showtext_auto(enable = TRUE)
               return(font_legend)
             }),

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

  tar_target(p3_supply_colors,
             {
               supply_colors <- c('#D4D4D4', '#BD5EC6', '#D8BF32', '#4DC49D')
               names(supply_colors) <- p2_source_category_order
               return(supply_colors)
             }),

  ##### Site location maps + figures #####

  ###### Conus maps #####

  tar_target(p3_sites_map_conus,
             map_sites(site = p2_inventory_sites_sf_CONUS,
                       states = p3_conus_sf,
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
             save_figure(figure = p3_sites_map_conus,
                         outfile = '3_visualize/out/sites_map_conus.png',
                       bkgd_color = "#ffffff", width = 16, height = 9, dpi = 300),
             format = 'file'),

  ###### National maps - shifted ######
  tar_target(p3_sites_map_shifted,
             map_sites(sites = p3_inventory_sites_shifted,
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
             annotate_shifted_map(shifted_map = p3_sites_map_shifted,
                                  text_color = 'black', plot_title_font_size = 16,
                                  width = 16, height = 9, font_legend = p3_font_legend)),

  tar_target(p3_sites_map_shifted_png,
             save_figure(figure = p3_sites_map_shifted_annotated,
                         outfile = '3_visualize/out/sites_map_national_shifted.png',
                      bkgd_color = "#ffffff", width=16, height=9, dpi=300),
             format = 'file'),

  ###### CONUS - Sites with wateruse (maps and figures) ######
  tar_target(p3_sites_map_conus_wateruse,
             map_wateruse_sites(map_of_all_sites = p3_sites_map_conus,
                                site_size = p3_sites_map_params$site_size,
                                site_fill_colors = '#8F8F8F',
                                site_color = '#E2E2E2',
                                site_pch = p3_sites_map_params$site_pch,
                                site_stroke = p3_sites_map_params$site_stroke,
                                wu_sites = filter(p2_inventory_sites_sf_CONUS, WU_DATA_FLAG == 'Y'),
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
             save_figure(figure = p3_sites_map_conus_wateruse,
                         outfile = '3_visualize/out/sites_map_conus_wateruse.png',
                         bkgd_color = "#ffffff", width = 16, height = 9, dpi = 300),
             format = 'file'),

  tar_target(p3_sites_wateruse_chart,
             chart_wateruse_availability(sites = p2_inventory_sites,
                                         has_wu_color = '#0008E6',
                                         no_wu_color = '#A6a6a6')),

  tar_target(p3_sites_figure_wateruse,
             combine_wu_map_and_chart(wu_map = p3_sites_map_conus_wateruse,
                                      wu_chart = p3_sites_wateruse_chart,
                                      width = 16,
                                      height = 9,
                                      font_legend = p3_font_legend)),

  tar_target(p3_sites_figure_wateruse_png,
             save_figure(figure = p3_sites_figure_wateruse,
                         outfile = '3_visualize/out/sites_figure_wateruse.png',
                         bkgd_color = "#ffffff", width = 16, height = 9, dpi = 300),
             format = 'file'),

  ##### Facility types (maps and figures) #####
  tar_target(p3_sites_map_conus_type,
             map_sites(sites = filter(p2_inventory_sites_sf_CONUS, WB_TYPE == p2_facility_types),
                       states = p3_conus_sf,
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
             combine_small_multiples(plots = p3_sites_map_conus_type,
                                     plot_types = p2_facility_types,
                                     title_font_size = 36,
                                     legend_font_size = 12,
                                     plot_title_font_size = 14,
                                     font_legend = p3_font_legend,
                                     text_color = 'grey20',
                                     point_layer = 2,
                                     point_size = 1)),

  tar_target(p3_sites_map_conus_type_png,
             save_figure(figure = p3_sites_map_conus_type,
                         outfile = sprintf('3_visualize/out/sites_map_conus_%s.png', p2_facility_types),
                         bkgd_color = "#ffffff", width = 16, height = 9, dpi = 300),
             pattern = map(p2_facility_types, p3_sites_map_conus_type),
             format = 'file'),

  tar_target(p3_sites_map_conus_type_combined_png,
             save_figure(figure = p3_sites_map_conus_type_combined,
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

  ##### Water source figures #####
  tar_target(p3_supply_summary_png,
             generate_supply_summary(supply_summary = p2_supply_summary,
                                     supply_colors = p3_supply_colors,
                                     title_text_size = 24,
                                     axis_text_size = 20,
                                     legend_text_size = 20,
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

  tar_target(p3_source_summary_bar_pngs,
             generate_source_summary_bar_chart(supply_summary_state = p2_supply_summary_state,
                                               supply_colors = p3_supply_colors,
                                               selected_facility_type = p2_facility_types,
                                               title_text_size = 28,
                                               axis_text_size = 12,
                                               legend_text_size = 20,
                                               width = 16, height = 9,
                                               bkgd_color = 'white',
                                               text_color = 'black',
                                               outfile_template = '3_visualize/out/source_bar_chart_%s.png',
                                               dpi = 300),
             pattern = map(p2_facility_types),
             format = 'file'),

  tar_target(p3_source_facet_map_pngs,
             generate_facility_source_facet_map(supply_summary = p2_supply_summary,
                                                supply_summary_state = p2_supply_summary_state,
                                                supply_colors = p3_supply_colors,
                                                selected_facility_type = p2_facility_types,
                                                width = 16, height = 9,
                                                bkgd_color = 'white',
                                                text_color = 'black',
                                                outfile_template = '3_visualize/out/state_sources_facet_%s.png',
                                                dpi = 300),
             pattern = map(p2_facility_types),
             format = 'file'),
  tar_target(p3_supply_colors_new,
             {
               supply_colors <- c('#D4D4D4', '#6F927C', '#4365A8', '#AB9230')
               names(supply_colors) <- p2_source_category_order
               return(supply_colors)
             }),

  tar_target(p3_source_bottled_water_facet_map_png,
             generate_facility_bw_source_facet_map(supply_summary = p2_supply_summary,
                                                   supply_summary_state = p2_supply_summary_state,
                                                   supply_colors = p3_supply_colors_new,
                                                   reorder_source_category = c("Undetermined", "Self-supply", "Combination", "Public supply"),
                                                   supply_pattern = c("Combination" = 'stripe', 'Public supply' = "none",
                                                                      "Self-supply" = "none", "Undetermined" = "none"),
                                                   selected_facility_type = "Bottled water",
                                                   title_label = 'Distribution of water sources\nfor %s facilities',
                                                   subtitle_label = ' Barplots display percent of bottled water facilities\n in each category',
                                                   width = 16, height = 9,
                                                   bkgd_color = 'white',
                                                   text_color = 'black',
                                                   source_label = "Data: doi:10.5066/P90Z125H",
                                                   logo_path = '3_visualize/in/usgs_logo_black.png',
                                                   outfile_template = '3_visualize/out/state_sources_facet_%s_styled.png',
                                                   dpi = 300),
             format = 'file'),
  # Sankey - Twitter version
  tar_target(p3_national_source_facilities_sankey_png,
             generate_national_sankey(supply_summary = p2_supply_summary,
                                     supply_colors = p3_supply_colors_new,
                                     type_colors = rep(c("white"), 6),
                                     type_colors = c('grey80', 'grey80', 'grey80', 'grey80', 'grey80', "grey80"),
                                     reorder_facilities_category = c('Winery','Soft drinks', 'Ice', 'Distillery', 'Brewery', 'Bottled water'),
                                     square_instagram = FALSE,
                                     label_size = 6,
                                     font_legend = p3_font_legend,
                                     width = 16, height = 9,
                                     bkgd_color = 'white',
                                     text_color = 'black',
                                     source_label = "Data: doi:10.5066/P90Z125H",
                                     title_label = "Distribution of water sources by facility types",
                                     subtitle_label = " Line width is scaled to number of bottling facilities in each category",
                                     logo_path = '3_visualize/in/usgs_logo_black.png',
                                     outfile_template = '3_visualize/out/national_sources_facilities_sankey.png',
                                     dpi = 300),
             format = 'file'),
  # Sankey - Instagram square version
  tar_target(p3_national_source_facilities_sankey_ig_png,
             generate_national_sankey(supply_summary = p2_supply_summary,
                                      supply_colors = p3_supply_colors_new,
                                      type_colors = c('grey80', 'grey80', 'grey80', 'grey80', 'grey80', "grey80"),
                                      reorder_facilities_category = c('Winery','Soft drinks', 'Ice', 'Distillery', 'Brewery', 'Bottled water'),
                                      square_instagram = TRUE,
                                      label_size = 1.6,
                                      font_legend = p3_font_legend,
                                      width = 1080, height = 1080,
                                      bkgd_color = 'white',
                                      text_color = 'black',
                                      source_label = "Data: doi:10.5066/P90Z125H",
                                      logo_path = '3_visualize/in/usgs_logo_black.png',
                                      title_label = "Distribution of water sources by facility types",
                                      outfile_template = '3_visualize/out/national_sources_facilities_sankey_ig.png',
                                      dpi = 300),
             format = 'file'),

  tar_target(p3_supply_ext_ss_colors,
             {
               supply_colors <- c(p3_supply_colors_new[['Undetermined']],
                                  '#8E9CBE', '#4365A8', '#283A70',
                                  p3_supply_colors_new[['Combination']],
                                  p3_supply_colors_new[['Public supply']])
               names(supply_colors) <- rev(p2_source_order)
               return(supply_colors)
             }),

  # CONUS county level bottled water percent (choropleth) and count (proportional symbol) facilities maps - 16:9 version with all 6 source maps
  tar_target(p3_source_perc_count_bottled_water_facet_map_png,
             generate_bw_conus_map(supply_summary_county_bw = p2_bw_inventory_sites_county_CONUS,
                                   conus_sf = p3_conus_sf,
                                   counties_sf = p3_counties_conus_sf,
                                   reorder_source_category = c("Self-supply", "Combination", "Public supply"),
                                   count_size_range = c(0.8, 8),
                                   count_size_limit = max(p2_bw_inventory_sites_county_CONUS$site_count),
                                   perc_alpha_range = c(0.1,1),
                                   perc_alpha_limit = c(1, 100),
                                   supply_colors = p3_supply_colors_new,
                                   width = 16, height = 9,
                                   bkgd_color = 'white',
                                   text_color = 'black',
                                   conus_outline_col = 'grey50',
                                   counties_outline_col = "grey80",
                                   font_legend = p3_font_legend,
                                   map_count_legend = 'Count of facilities',
                                   map_perc_legend = 'Percent of facilities',
                                   outfile_template = '3_visualize/out/perc_count_bottled_water_map.png',
                                   dpi = 300),
             format = 'file'),

  # Create list of county level bottled water facilities by source category
  tar_target(p3_county_bw_list,
             county_bw_list(supply_summary_county_bw = p2_bw_inventory_sites_county_CONUS,
                            counties_sf = p3_counties_conus_sf,
                            reorder_source_category = p3_source_category_list),
             pattern = map(p3_source_category_list),
             iteration = 'list'),

  # CONUS county level bottled water count (proportional symbol) facilities basemaps maps list
  tar_target(p3_source_count_bottled_water_basemap_list,
             generate_bw_conus_count_basemap(conus_sf = p3_conus_sf,
                                supply_summary_county_bw = p3_county_bw_list,
                                counties_sf = p3_counties_conus_sf,
                                count_size_range = c(0.8, 8),
                                count_size_limit = max(p2_bw_inventory_sites_county_CONUS$site_count),
                                supply_colors = p3_supply_colors_new,
                                bkgd_color = 'white',
                                text_color = 'black',
                                conus_outline_col = 'grey50',
                                counties_outline_col = "grey80",
                                font_legend = p3_font_legend),
             pattern = map(p3_county_bw_list),
             iteration = 'list'),

  # CONUS county level bottled water percent (choropleth) facilities basemaps maps list
  tar_target(p3_source_perc_bottled_water_basemap_list,
             generate_bw_conus_perc_basemap(conus_sf = p3_conus_sf,
                                supply_summary_county_bw = p3_county_bw_list,
                                counties_sf = p3_counties_conus_sf,
                                perc_alpha_range = c(0.1,1),
                                perc_alpha_limit = c(1, 100),
                                supply_colors = p3_supply_colors_new,
                                bkgd_color = 'white',
                                text_color = 'black',
                                conus_outline_col = 'grey50',
                                counties_outline_col = "grey80",
                                font_legend = p3_font_legend),
             pattern = map(p3_county_bw_list),
             iteration = 'list'),

  # Create source category list to `map` by
  tar_target(p3_source_category_list,
             list("Self-supply", "Combination", "Public supply")
             ),
  # Drop undetermined for bw conus maps
  tar_target(p3_supply_colors_reduce,
             p3_supply_colors_new[unlist(p3_source_category_list)]
  ),
  # Count bottled water facilities legend for source categories
  tar_target(p3_source_bw_count_legend_list,
             generate_count_leg(supply_colors = p3_supply_colors_reduce,
                                source_category = p3_source_category_list,
                                map_count_legend = 'Count of facilities',
                                count_size_range = c(0.8, 8),
                                count_size_limit = max(p2_bw_inventory_sites_county_CONUS$site_count),
                                font_legend = p3_font_legend),
             pattern = map(p3_supply_colors_reduce, p3_source_category_list),
             iteration = 'list'),

  # Percent bottled water facilities legend for source categories
  tar_target(p3_source_bw_perc_legend_list,
             generate_perc_leg(supply_colors = p3_supply_colors_reduce,
                               source_category = p3_source_category_list,
                               map_perc_legend = 'Percent of facilities',
                               perc_alpha_range = c(0.1,1),
                               perc_alpha_limit = c(1, 100),
                               font_legend = p3_font_legend),
             pattern = map(p3_supply_colors_reduce, p3_source_category_list),
             iteration = 'list'),

  # Stylized CONUS county level bottled water maps with legends
  tar_target(p3_source_perc_count_bottled_water_map_pngs,
             style_bw_conus_map(count_map = p3_source_count_bottled_water_basemap_list,
                                perc_map = p3_source_perc_bottled_water_basemap_list,
                                count_leg = p3_source_bw_count_legend_list,
                                perc_leg = p3_source_bw_perc_legend_list,
                                source_category = p3_source_category_list,
                                width = 8, height = 6,
                                bkgd_color = 'white',
                                text_color = 'black',
                                font_legend = p3_font_legend,
                                outfile_template = '3_visualize/out/map_bottled_water_%s.png',
                                dpi = 300),
             pattern = map(p3_source_count_bottled_water_basemap_list, p3_source_perc_bottled_water_basemap_list,
                           p3_source_bw_count_legend_list, p3_source_bw_perc_legend_list, p3_source_category_list),
             format = 'file'),

  tar_target(
    ## export as resized png
    p3_source_perc_count_bottled_water_map_scaled_pngs,
    {
      scaled_files <- purrr::map(p3_source_perc_count_bottled_water_map_pngs,
                                 ~resize_and_export_image(image_file = .x,
                                               base_path = 'src/assets/images',
                                               file_extension = 'png',
                                               width = 700,
                                               density = 150,
                                               compression_option = 'None')) |>
        unlist()
    },
    pattern = map(p3_source_perc_count_bottled_water_map_pngs),
    format = 'file'
  ),
  tar_target(
    ## export as webp to optimize browser delivery
    p3_source_perc_count_bottled_water_map_webps,
    {
    webp_files <- purrr::map(p3_source_perc_count_bottled_water_map_pngs,
                             ~resize_and_export_image(image_file = .x,
                                                      base_path = 'src/assets/images',
                                                      file_extension = 'webp',
                                                      width = 700,
                                                      density = 150,
                                                      compression_option = 'WebP')) |>
        unlist()
      return(webp_files)
    },
    pattern = map(p3_source_perc_count_bottled_water_map_pngs),
    format = 'file'
  ),

  # Percent water source stacked barplots with expanded self supply facilities
  tar_target(p3_perc_expanded_self_supply_barplot_png,
             expanded_ss_barplot(source_summary = p2_source_summary,
                                 supply_colors = p3_supply_ext_ss_colors,
                                 reorder_source_category = c("Undetermined", "Well", "Spring",
                                                             "Surface water intake", "Combination", "Public supply"),
                                 font_legend = p3_font_legend,
                                 get_percent = TRUE,
                                 width = 16, height = 9,
                                 bkgd_color = 'white',
                                 text_color = 'black',
                                 bracket_png_path = '3_visualize/in/bracket.png',
                                 outfile_template = '3_visualize/out/perc_expanded_self_supply_barplot.png',
                                 dpi = 300),
             format = "file"),
  # Site count stacked barplots of water sources with expanded self supply facilities
  tar_target(p3_count_expanded_self_supply_barplot_png,
             expanded_ss_barplot(source_summary = p2_source_summary,
                                 supply_colors = p3_supply_ext_ss_colors,
                                 reorder_source_category = c("Undetermined", "Well", "Spring",
                                                             "Surface water intake", "Combination", "Public supply"),
                                 font_legend = p3_font_legend,
                                 get_percent = FALSE,
                                 width = 16, height = 9,
                                 bkgd_color = 'white',
                                 text_color = 'black',
                                 y_title = "Number of facilities",
                                 bracket_png_path = '3_visualize/in/bracket.png',
                                 outfile_template = '3_visualize/out/count_expanded_self_supply_barplot.png',
                                 dpi = 300),
             format = "file"),
  tar_target(p3_source_facet_map_all_types_png,
             generate_facility_source_facet_map(supply_summary = p2_supply_summary,
                                                supply_summary_state = p2_supply_summary_state,
                                                supply_colors = p3_supply_colors,
                                                selected_facility_type = 'All',
                                                width = 16, height = 9,
                                                bkgd_color = 'white',
                                                text_color = 'black',
                                                outfile_template = '3_visualize/out/state_sources_facet.png',
                                                dpi = 300),
             format = 'file'),

  ###### Water Use Figures - adapted from Alisha Chan's script ######
  # Water use source colors
  tar_target(p3_wu_availability_facilities_colors,
             {
               source_colors <- c(p3_supply_ext_ss_colors[c("Public supply", "Well", "Spring", "Surface water intake", "Combination")] , c('Other' = "black"))
               return(source_colors)
             }),
  # Map displaying all bottling facilities and bottling facilities with water use data
  tar_target(p3_wu_availability_map_png,
             wu_availability_map(conus_sf = p3_conus_sf,
                                 conus_outline_col = 'grey50',
                                 sites_wu_summary_sf = p2_inventory_sites_wu_conus_summary_sf,
                                 focal_color = "#4365A8",
                                 inventory_fill_name = "All bottling facilities",
                                 wu_fill_name = "Bottling facilities with water use data",
                                 alpha = 0.5,
                                 width = 16, height = 9,
                                 bkgd_color = 'white',
                                 text_color = 'black',
                                 outfile_template = '3_visualize/out/bottled_water_availability_map.png',
                                 dpi = 300),
             format = 'file'),
  # Beeswarm displaying annual bottled water use (MGD) - desktop version
  tar_target(p3_annual_bw_wu_beeswarm_png,
             annual_bw_wu_beeswarm(sites_wu_sf = p2_inventory_sites_wu_conus_sf,
                                   selected_facility_type = "Bottled water",
                                   axis_title = "Average annual water use by bottled water facilities, million gallons per day",
                                   scale_y_lim =  c(0, 2),
                                   scale_y_exp = c(0, 0.05),
                                   scale_x_exp= c(0, -0.1),
                                   mobile = FALSE,
                                   leg_nrow = 1,
                                   font_size = 22,
                                   point_size = 5,
                                   width = 16, height = 9,
                                   supply_color = p3_wu_availability_facilities_colors,
                                   bkgd_color = 'white',
                                   text_color = 'black',
                                   outfile_template = '3_visualize/out/annual_bottled_water_use_beeswarm.png',
                                   dpi = 300),
             format = 'file'),

  tar_target(p3_annual_bw_wu_beeswarm_scaled_png,
             resize_and_export_image(image_file = p3_annual_bw_wu_beeswarm_png,
                                     base_path = 'src/assets/images',
                                     file_extension = 'png',
                                     width = 1500,
                                     density = 200,
                                     compression_option = 'None'),
             format = 'file'),

  tar_target(p3_annual_bw_wu_beeswarm_webp,
             resize_and_export_image(image_file = p3_annual_bw_wu_beeswarm_png,
                                     base_path = 'src/assets/images',
                                     file_extension = 'webp',
                                     width = 1500,
                                     density = 200,
                                     compression_option = 'WebP'),
             format = 'file'),

  # Beeswarm displaying annual bottled water use (MGD) - mobile version
  tar_target(p3_annual_bw_wu_beeswarm_mobile_png,
             annual_bw_wu_beeswarm(sites_wu_sf = p2_inventory_sites_wu_conus_sf,
                                   selected_facility_type = "Bottled water",
                                   axis_title = "Average annual water use by bottled water facilities, million gallons per day",
                                   scale_y_lim =  c(0, 2),
                                   scale_y_exp = c(0, 0.05),
                                   scale_x_exp= c(0, -0.1),
                                   mobile = TRUE,
                                   leg_nrow = 3,
                                   font_size = 38,
                                   point_size = 5,
                                   width = 9, height = 16,
                                   supply_color = p3_wu_availability_facilities_colors,
                                   bkgd_color = 'white',
                                   text_color = 'black',
                                   outfile_template = '3_visualize/out/annual_bottled_water_use_beeswarm_mobile.png',
                                   dpi = 300),
             format = 'file'),

  tar_target(p3_annual_bw_wu_beeswarm_mobile_scaled_png,
             resize_and_export_image(image_file = p3_annual_bw_wu_beeswarm_mobile_png,
                                     base_path = 'src/assets/images',
                                     file_extension = 'png',
                                     width = 800,
                                     density = 200,
                                     compression_option = 'None'),
             format = 'file'),

  tar_target(p3_annual_bw_wu_beeswarm_mobile_webp,
             resize_and_export_image(image_file = p3_annual_bw_wu_beeswarm_mobile_png,
                                     base_path = 'src/assets/images',
                                     file_extension = 'webp',
                                     width = 800,
                                     density = 200,
                                     compression_option = 'WebP'),
             format = 'file'),

  # Combined barplots displaying % water use availability, % bottled water facilities, and % sources of bottled water facilities
  tar_target(p3_water_use_availablity_barplots_png,
             water_use_barplots(sites_wu_summary_sf = p2_inventory_sites_wu_conus_summary_sf,
                                width = 16, height = 9,
                                focal_color = "#4365A8",
                                supply_facil_cols = p3_wu_availability_facilities_colors,
                                bkgd_color = 'white',
                                text_color = 'black',
                                wu_avail_title = "Water use data availability",
                                wu_types_title = "Types of facilities with water use data",
                                wu_facil_title = "Sources for bottled water facilities\nwith water use data",
                                bracket1_png_path = '3_visualize/in/bracket1_water_use.png',
                                bracket2_png_path = '3_visualize/in/bracket2_water_use.png',
                                outfile_template = '3_visualize/out/water_use_data_availability_barplots.png',
                                dpi = 300),
             format = 'file'),

  # Individual % water use availability barplot
  tar_target(p3_perc_wu_availablity_barplot_png,
             perc_wu_avail_barplot(sites_wu_summary_sf = p2_inventory_sites_wu_conus_summary_sf,
                                width = 2, height = 6,
                                focal_color = "#4365A8",
                                text_size = 14,
                                bkgd_color = 'white',
                                text_color = 'black',
                                outfile_template = '3_visualize/out/perc_water_use_availability_barplot.png',
                                dpi = 300),
             format = 'file'),

  ######  state source faceted geofaceted treemaps   ######
  # tar_target(p3_source_facet_treemap_all_types_png,
  #            generate_facility_source_facet_treemap(supply_summary = p2_supply_summary,
  #                                               supply_summary_state = p2_supply_summary_state,
  #                                               supply_colors = p3_supply_colors,
  #                                               selected_facility_type = 'All',
  #                                               width = 16, height = 9,
  #                                               bkgd_color = 'white',
  #                                               text_color = 'black',
  #                                               font_legend = p3_font_legend,
  #                                               outfile_template = '3_visualize/out/state_sources_facet_treemap.png',
  #                                               dpi = 300),
  #            format = 'file'),
  #
  # tar_target(p3_source_facet_treemap_pngs,
  #            generate_facility_source_facet_treemap(supply_summary = p2_supply_summary,
  #                                               supply_summary_state = p2_supply_summary_state,
  #                                               supply_colors = p3_supply_colors,
  #                                               selected_facility_type = p2_facility_types,
  #                                               width = 16, height = 9,
  #                                               bkgd_color = 'white',
  #                                               text_color = 'black',
  #                                               font_legend = p3_font_legend,
  #                                               outfile_template = '3_visualize/out/state_sources_facet_treemap_%s.png',
  #                                               dpi = 300),
  #            pattern = map(p2_facility_types),
  #            format = 'file'),

  ######  individual state level treemaps of water source for all facilities output in subfolder: `3_visualize/out/state_source_treemap`  ######
  # tar_target(p3_source_treemap_all_types_png,
  #            generate_facility_source_treemap(supply_summary = p2_supply_summary,
  #                                             supply_summary_state = p2_supply_summary_state,
  #                                             supply_colors = p3_supply_colors,
  #                                             selected_facility_type = 'All',
  #                                             width = 6, height = 4,
  #                                             bkgd_color = 'white',
  #                                             text_color = 'black',
  #                                             font_legend = p3_font_legend,
  #                                             outfile_subfolder = '3_visualize/out/state_source_treemap_all',
  #                                             dpi = 300),
  #            format = 'file'),
  #
  # ######  individual state level waffle charts of water source for all facilities output in subfolder: `3_visualize/out/state_source_waffle`   ######
  # tar_target(p3_source_waffle_all_types_png,
  #            generate_facility_source_waffle(supply_summary = p2_supply_summary,
  #                                             supply_summary_state = p2_supply_summary_state,
  #                                             supply_colors = p3_supply_colors,
  #                                             selected_facility_type = 'All',
  #                                             width = 6, height = 4,
  #                                             bkgd_color = 'white',
  #                                             text_color = 'black',
  #                                             font_legend = p3_font_legend,
  #                                             outfile_subfolder = '3_visualize/out/state_source_waffle_all',
  #                                             dpi = 300),
  #            format = 'file'),

  ##### U.S. map with state abbreviation shift   #####
  tar_target(p3_map_shift_state_abbr,
             map_w_state_abbr(states = p3_spatial_shifted,
                              state_color = p3_sites_map_params$state_color,
                              state_size = 0.5,
                              state_fill = p3_sites_map_params$state_fill,
                              simplify = FALSE,
                              simplification_keep = 0.7,
                              legend = TRUE,
                              font_legend = p3_font_legend,
                              font_size = 18)
             ),
  tar_target(p3_map_shift_state_abbr_annotate,
             annotate_shifted_map(shifted_map = p3_map_shift_state_abbr,
                                  text_color = 'black', plot_title_font_size = 16,
                                  width = 16, height = 9, font_legend = p3_font_legend)
             ),
  tar_target(p3_map_shift_state_abbr_annotate_png,
             save_figure(figure = p3_map_shift_state_abbr_annotate,
                         outfile = '3_visualize/out/map_national_state_abbr_shifted.png',
                         bkgd_color = "#ffffff", width=16, height=9, dpi=300),
             format = 'file'),

  ##### Regional data maps and plots  #####
  # TODO:
  # figure out different simplification for diff regions
  tar_target(p3_regions_map,
             map_regions(regions = p1_regions_sf,
                         region_info = p1_region_info,
                         states = p3_conus_sf,
                         state_fill = '#E2E2E2',
                         state_color = "#ffffff",
                         state_size = 0.5,
                         simplify=TRUE, simplification_keep=0.7)),

  tar_target(p3_regions_map_png,
             save_figure(figure = p3_regions_map,
                         outfile = '3_visualize/out/region_map.png',
                         bkgd_color = "#ffffff", width = 16, height = 9, dpi = 300),
             format = 'file')
)
