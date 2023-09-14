#' @title save a figure
#' @description save a figure to file, as an image
#' @param figure the figure to be saved to file
#' @param outfile the filepath to which the figure should be saved
#' @param bkgd_color the background color for the saved image (only
#' used if the passed figure is not already 16x9 with a background)
#' @param width width of the figure
#' @param height height of the figure
#' @param dpi dpi at which the figure should be saved
#' @return the filepath of the saved figure
save_figure <- function(figure, outfile, bkgd_color, width, height, dpi) {
  plot_margin <- 0.025

  # background
  canvas <- grid::rectGrob(
    x = 0, y = 0,
    width = width, height = height,
    gp = grid::gpar(fill = bkgd_color, alpha = 1, col = bkgd_color)
  )

  # Build final figure
  ggdraw(ylim = c(0,1),
                       xlim = c(0,1)) +
    # background
    draw_grob(canvas,
              x = 0, y = 1,
              height = height, width = width,
              hjust = 0, vjust = 1) +
    # place figure
    draw_plot(figure,
              x = plot_margin,
              y = plot_margin,
              height = 1 - plot_margin*2 ,
              width = 1 - plot_margin*2)

  ggsave(outfile, width = width, height = height, dpi = 300)
  return(outfile)
}

#' @title map data on us
#' @description Map passed spatial data on top of of the passed spatial data for
#' the U.S./CONUS
#' @param states sf object of U.S. states - either CONUS or CONUS + OCONUS
#' @param plot_in existing map to be added to basemap of U.S. states
#' @param state_fill color for fill for states
#' @param state_color color for border for states
#' @param state_size size of border for states
#' @param simplify logical, whether or not to simplify the passed state geometry.
#' Defaults to TRUE
#' @param simplification_keep if simplify = TRUE, percentage of points to retain
#' @param legend logical, whether on to to include the map legend
#' @return plot object with `plot_in` added to basemap built from `states`
map_data_on_us <- function(states, plot_in, state_fill, state_color, state_size,
                           simplify = TRUE, simplification_keep = NA,
                           legend = TRUE) {

  if (simplify) {
    if (is.na(simplification_keep)) message('Using default of 0.05 for proportion
                                            of points to retain')
    states <- ms_simplify(states, keep = simplification_keep)
  }

  # Map of states
  p <- ggplot() +
    geom_sf(data = filter(states, location == 'mainland'),
            color = state_color,
            fill = state_fill,
            size = state_size) +
    geom_sf(data = filter(states, location == 'not mainland'),
            color = state_color,
            fill = state_fill,
            size = 0.05) +
    theme_void() +
    plot_in

  if (legend==FALSE) {
    p <- p +
      theme(
        legend.position = 'none')
  }

  return(p)
}


map_w_state_abbr <- function(states, plot_in, state_color, state_size,
                             simplify = TRUE, state_fill,simplification_keep = NA,
                             legend = TRUE, font_legend, font_size){

  if (simplify) {
    if (is.na(simplification_keep)) message('Using default of 0.05 for proportion
                                            of points to retain')
    states <- ms_simplify(states, keep = simplification_keep)
  }

  state_name_to_abb <- data.frame(state_name = state.name, state_abb = state.abb)
  states$ID = str_to_title( states$ID )
  states_with_abbr <- states %>%
    left_join(state_name_to_abb, by = c("ID" = "state_name")) |>
    mutate(
      # fix types in WB_TYPE
      state_abb = case_when(
        ID == 'District Of Columbia' ~ 'DC',
        TRUE ~ state_abb))

  # Map of states
  p <- ggplot() +
    geom_sf(data = filter(states_with_abbr, location == 'mainland'),
            color = state_color,
            fill = state_fill,
            size = state_size) +
    geom_sf_text(data = filter(states_with_abbr, location == 'mainland',
                               !state_abb %in% c("DC", "MD", "NJ", "DE", "VT", "NH", "RI", "CT"),
                               !(row_number() %in% 50:63)),
                 aes(label = state_abb),
                 size = 4) +
    geom_sf(data = filter(states_with_abbr, location == 'not mainland'),
            color = state_color,
            fill = state_fill,
            size = 0.05) +
    # add state abbreviations
    ggrepel::geom_text_repel(
      data = filter(states_with_abbr, state_abb %in% c("DC", "MD", "NJ", "DE", "VT", "NH", "RI", "CT"),
                    !(row_number() %in% 50:63)),
      aes(label = state_abb, geometry = geom),
      stat = "sf_coordinates",
      min.segment.length = unit(0, 'lines'),
      nudge_y = 0.2,
      box.padding = 0.4,
      direction = "x",
      size = 4
    ) +
    theme_void() +
    theme(text = element_text(family = font_legend,
                              size = font_size))

  if (legend==FALSE) {
    p <- p +
      theme(
        legend.position = 'none')
  }

  return(p)
}


#' @title map regions
#' @description map location of regions on CONUS basemap
#' @param regions sf object of study regions
#' @param region_info dataframe of information for each region
#' @param state_fill color for fill for states
#' @param state_color color for border for states
#' @param state_size size of border for states
#' @param simplify logical, whether or not to simplify the passed state geometry.
#' Defaults to TRUE
#' @param simplification_keep if simplify = TRUE, percentage of points to retain
#' @return plot object - CONUS basemap with regions added and labeled
map_regions <- function(regions, region_info, states, state_fill, state_color,
                        state_size, simplify = TRUE, simplification_keep = 0.5) {

  regions <- regions %>%
    left_join(region_info, by = 'region')

  region_plot <- geom_sf(data = regions,
                         aes(fill = region,
                             color = region),
                         alpha = 0.5,
                         lwd = 0.1)



  regions_on_conus <- map_data_on_us(states, plot_in = region_plot, state_fill,
                                     state_color, state_size, simplify = simplify,
                                     simplification_keep = simplification_keep,
                                     legend=TRUE)

  ca_inset_area <- regions %>%
    filter(region == 'california') %>%
    st_buffer(dist = 12000) %>%
    st_bbox() %>%
    st_as_sfc()

  # nudging based on color, which is set w/ region
  # california, florida, great lakes, new england, texas, valley and ridge
  # x_offsets <- c(100000, 50000, -300000, 150000, 50000, 1300000)
  # y_offsets <- c(-5000, 105000, 600000, 20000, 150000, -5000)
  x_offsets <- c(90000, 100000, -300000, 150000, 110000, 1500000)
  y_offsets <- c(-1000000, 105000, 600000, -100000, -350000, -5000)

  conus_w_inset <- regions_on_conus +
    geom_sf(data = ca_inset_area, fill = NA, color = 'grey20', size = 0.25) +
    geom_text_repel(data = regions, aes(label = stringr::str_wrap(full_name, 30),
                                        fill = NA, color = region,
                                        geometry = geometry),
                    nudge_x = x_offsets, nudge_y = y_offsets,
                    min.segment.length = 15, stat = "sf_coordinates",
                    size = 6, hjust = 0) +
    theme(legend.position = "none")

  ca_region_map <- ggplot() +
    geom_sf(data = ca_inset_area, fill = 'white', color = 'grey20', size = 0.5) +
    geom_sf(data = filter(regions, region == 'california'), aes(fill = region,
                                                              color = region)) +
    theme_void()

  final_plot <- ggdraw() +
    draw_plot(conus_w_inset,
              x = 0.5,
              y = 0,
              height = 0.9,
              hjust = 0.5) +
    draw_plot(ca_region_map + theme(legend.position = 'none'),
              x = -0.04,
              y = 0.05,
              width = 0.25,
              height = 0.25) +
    draw_line(
      x = c(0.14, 0.0235),
      y = c(0.37, 0.289),
      color = "grey20", size = 0.2
    ) +
    draw_line(
      x = c(0.145, 0.146),
      y = c(0.37, 0.289),
      color = "grey20", size = 0.2
    ) +
    draw_label('Regional study areas',
               x = 0.020, y = 0.96,
               size = 36,
               hjust = 0,
               vjust = 1,
               color = 'black',
               lineheight = 1)

  return(final_plot)
}

#' @title map sites
#' @description map location of inventoried facilities on the passed state
#' geometry (CONUS OR CONUS + OCONUS)
#' @param sites sf object of inventory sites
#' @param states sf object of U.S. states - either CONUS or CONUS + OCONUS
#' @param site_size size of site points
#' @param fill_by_type logical, whether or not to color the fill of the sites
#' according to the type of the facility
#' @param site_fill_colors color(s) for fill of site points
#' @param site_color color for border of site points
#' @param site_alpha alpha for site points
#' @param site_pch type of symbol to use for site points
#' @param site_stroke size of border for site points
#' @param state_fill color for fill for states
#' @param state_color color for border for states
#' @param state_size size of border for states
#' @param simplify logical, whether or not to simplify the passed state geometry.
#' Defaults to TRUE
#' @param simplification_keep if simplify = TRUE, percentage of points to retain
#' @param legend_position position for the legend: c(x_offset, y_offset)
#' @param legend_title_size font size for the legend title
#' @param legend_text_size font size for the legend text
#' @return plot object - map of `sites` locations within `states`
map_sites <- function(sites, states, site_size, fill_by_type, site_fill_colors,
                      site_color, site_alpha, site_pch, site_stroke, state_fill,
                      state_color, state_size, simplify = TRUE, simplification_keep = NA,
                      legend_position, legend_title_size, legend_text_size) {

  if (fill_by_type) {
    site_plot <- geom_sf(data = sites,
                         aes(fill = WB_TYPE),
                         color = site_color,
                         pch = site_pch,
                         size = site_size,
                         stroke = site_stroke,
                         alpha = site_alpha)
  } else {
    site_plot <- geom_sf(data = sites,
                         aes(fill = facility_category,
                             color = facility_category),
                         pch = site_pch,
                         size = site_size,
                         stroke = site_stroke,
                         alpha = site_alpha)
  }

  final_plot <- map_data_on_us(states, plot_in = site_plot, state_fill,
                               state_color, state_size, simplify = simplify,
                               simplification_keep = simplification_keep,
                               legend = TRUE)

  if (fill_by_type) {
    final_plot <- final_plot +
      scale_fill_manual(name = 'WB_TYPE', values = site_fill_colors) +
      theme(legend.position = legend_position,
            legend.title = element_text(size = legend_title_size),
            legend.text = element_text(size = legend_text_size)) +
      guides(
        fill = guide_legend(title="Facility type"),
        color = 'none'
      )
  } else {
    final_plot <- final_plot +
      scale_fill_manual(name = 'Bottling facility', breaks = c('Bottling facility'),
                        values = c(site_fill_colors)) +
      scale_color_manual(name = 'Bottling facility', breaks = c('Bottling facility'),
                         values = c(site_color)) +
      theme(legend.position = legend_position,
            legend.title = element_text(size = legend_title_size),
            legend.text = element_text(size = legend_text_size)) +
      guides(
        fill = guide_legend(title = element_blank()),
        color = 'none'
      )
  }

  return(final_plot)
}

#' @title map water use sites
#' @description on map of all sites, indicate which have water use data
#' @param map_of_all_sites plot object - map of all sites in CONUS
#' @param site_size size of site points
#' @param site_fill_colors color(s) for fill of site points
#' @param site_color color for border of site points
#' @param site_pch type of symbol to use for site points
#' @param site_stroke size of border for site points
#' @param wu_sites sf object of sites with water use data
#' @param wu_site_size size of points for sites with water use data
#' @param wu_site_fill_colors fill color of points for sites with water use data
#' @param wu_site_color border color of points for sites with water use data
#' @param wu_site_alpha alpha of points for sites with water use data
#' @param wu_site_pch type of symbol for points for sites with water use data
#' @param wu_site_stroke size of border for points for sites with water use data
#' @param legend_position position for the legend: c(x_offset, y_offset)
#' @param legend_title_size font size for the legend title
#' @param legend_text_size font size for the legend text
#' @return map of all sites, with sites with water use data highlighted
map_wateruse_sites <- function(map_of_all_sites, site_size, site_fill_colors,
                               site_color, site_pch, site_stroke, wu_sites,
                               wu_site_size, wu_site_fill_colors, wu_site_color,
                               wu_site_alpha, wu_site_pch, wu_site_stroke,
                               legend_position, legend_title_size,
                               legend_text_size) {

  map <- map_of_all_sites +
    geom_sf(data = wu_sites,
            aes(fill = WU_DATA_FLAG,
                color = WU_DATA_FLAG),
            pch = wu_site_pch,
            size = wu_site_size,
            stroke = wu_site_stroke,
            alpha = wu_site_alpha) +
    theme_void() +
    scale_fill_manual(name = c('Bottling facility', unique(wu_sites$WU_DATA_FLAG)),
                      breaks = c('Bottling facility', unique(wu_sites$WU_DATA_FLAG)),
                      values = c(site_fill_colors, wu_site_fill_colors),
                      labels = c('Bottling facility', 'Has water use data')) +
    scale_color_manual(name = c('Bottling facility', unique(wu_sites$WU_DATA_FLAG)),
                       breaks = c('Bottling facility', unique(wu_sites$WU_DATA_FLAG)),
                       values = c(site_color, wu_site_color),
                       labels = c('Bottling facility', 'Has water use data')) +
    theme(legend.position = legend_position,
          legend.title = element_text(size = legend_title_size),
          legend.text = element_text(size = legend_text_size)) +
    guides(
      fill = guide_legend(title = element_blank(),
                          override.aes = list(pch = c(site_pch, wu_site_pch),
                                              fill = c(site_fill_colors, wu_site_fill_colors),
                                              color = c(site_color, wu_site_color),
                                              stroke = c(site_stroke, wu_site_stroke),
                                              size = c(site_size, wu_site_size))),
      color = "none"
    )

  return(map)
}

#' @title combine small multiples
#' @description combine series of maps into small multiples arrangement
#' @param plots vector of plot grobs of facility locations to be combined
#' @param plot_types vector of facility types represented in `plots`
#' @param title_font_size font size for title
#' @param legend_font_size font size for legend
#' @param plot_title_font_size font size for individual plot titles
#' @param font_legend font for the legend text
#' @param text_color color for text
#' @param point_layer number of layer within passed plots that represents points
#' @param point_size desired size for points on small multiples plots
#' @return a final plot with the input `plots` arranged as small multiples
combine_small_multiples <- function(plots, plot_types, title_font_size,
                                    legend_font_size, plot_title_font_size,
                                    font_legend, text_color, point_layer,
                                    point_size) {

  plot_margin <- 0.005

  # background
  canvas <- grid::rectGrob(
    x = 0, y = 0,
    width = 16, height = 9,
    gp = grid::gpar(fill = 'white', alpha = 1, col = 'white')
  )

  # Extract from plot
  plot_legend <- get_legend(
    plots[[1]] +
      theme(legend.position = 'bottom',
            text = element_text(family = font_legend, color = text_color,
                                size = legend_font_size)) +
      guides(
        fill = guide_legend(title = "Facility type", nrow = 1)
      ))

  final_plot <-  ggdraw(ylim = c(0,1),
                        xlim = c(0,1)) +
    # a background
    draw_grob(canvas,
              x = 0, y = 1,
              height = 9, width = 16,
              hjust = 0, vjust = 1)

  subplot_width <- (1-plot_margin*((length(plots)/2)-1+2))/(length(plots)/2)

  plot_list <- purrr::map(seq(1,length(plots)), function(i) {
    row <- ifelse(i <= length(plots)/2, 1, 2)
    column <- ifelse(i <= length(plots)/2, i, i-(length(plots)/2))
    y = ifelse(row == 1, 0.4, plot_margin)
    plot <- plots[[i]]
    plot <- modify_size(plot, layer = point_layer, size = point_size)
    mod_plot <- draw_plot(
      plot +
        ggtitle(plot_types[i]) +
        theme(legend.position = 'none',
              plot.title = element_text(hjust = 0.5),
              text = element_text(family = font_legend, color = text_color,
                                  size = plot_title_font_size)),
      x = plot_margin+((column-1)*subplot_width),
      y = y,
      height = 0.5 ,
      width = subplot_width)
    return(mod_plot)
  })

  final_plot <- final_plot +
    plot_list +
    # Don't add legend for now, since adding plot titles
    # draw_plot(plot_legend,
    #           x = 0,
    #           y = 0.35) +
    # draw title
    draw_label('Facility locations, by type',
               x = plot_margin, y = 1-plot_margin,
               size = title_font_size,
               hjust = 0,
               vjust = 1,
               fontfamily = font_legend,
               color = text_color)

  return(final_plot)
}

#' @title modify size
#' @description modify size of points on existing plot
#' @param plot existing plot w/ points layer
#' @param layer number indicating layer that contains plotted points
#' @param size replacement size for points within existing plot
#' @return a plot object with resized points
modify_size <- function(plot, layer, size) {
  plot$layers[[layer]]$aes_params$size <-  size
  return(plot)
}

#' @title combine conus maps
#' @description combine two map plot objects, arranging them side by side
#' @param map1 the first map
#' @param map2 the second map
#' @param title1 title for the first map
#' @param title2 title for the second map
#' @param width width for the combined plot canvas
#' @param height height for the combined plot canvas
#' @param text_color color for text
#' @param title_font_size font size for title
#' @param legend_font_size font size for legend
#' @param plot_title_font_size font size for individual plot titles
#' @param font_legend font for the legend text
#' @return plot object with the two maps arranged side by side with a legend
combine_conus_maps <- function(map1, map2, title1, title2, width, height,
                               text_color, title_font_size, legend_font_size,
                               plot_title_font_size, font_legend) {

  plot_margin <- 0.005

  # background
  canvas <- grid::rectGrob(
    x = 0, y = 0,
    width = width, height = height,
    gp = grid::gpar(fill = 'white', alpha = 1, col = 'white')
  )

  # Extract from plot
  plot_legend <- get_legend(
    map2 +
      theme(legend.position = 'top',
            text = element_text(family = font_legend, color = text_color,
                                size = legend_font_size)) +
      guides(
        fill = guide_legend(title = "Facility type", nrow = 1)
      ))

  final_plot <-  ggdraw(ylim = c(0,1),
                        xlim = c(0,1)) +
    # a background
    draw_grob(canvas,
              x = 0, y = 1,
              height = 9, width = 16,
              hjust = 0, vjust = 1) +
    draw_plot(plot_legend,
              x = 0,
              y = 0.35) +
    draw_plot(map1 +
                ggtitle(title1) +
                theme(legend.position = 'none',
                      plot.title = element_text(hjust = 0.5),
                      text = element_text(family = font_legend,
                                          color = text_color,
                                          size = plot_title_font_size)),
              x = 0,
              y = 0,
              height = 0.8,
              width = (1 - plot_margin*2) / 2) +
    draw_plot(map2 +
                ggtitle(title2) +
                theme(legend.position = 'none',
                      plot.title = element_text(hjust = 0.5),
                      text = element_text(family = font_legend,
                                          color = text_color,
                                          size = plot_title_font_size)),
              x = ((1 - plot_margin*2) / 2) + plot_margin*2,
              y = 0,
              height = 0.8,
              width = (1 - plot_margin*2) / 2) +
    # draw title
    draw_label('Water Bottling Facilities',
               x = plot_margin, y = 1-plot_margin,
               size = title_font_size,
               hjust = 0,
               vjust = 1,
               fontfamily = font_legend,
               color = text_color)
}

#' @title chart water use availability
#' @description chart the availability of water use data across sites as a stacked
#' bar chart
#' @param sites dataframe of inventory sites w/ attribute information indicating
#' if the site has water use data or does not
#' @param has_wu_color color to use if site has water use data
#' @param no_wu_color color to use if site does not have water use data
#' @return stacked bar chart indicating percent of sites that have water use data
#' and percent of sites that do not
chart_wateruse_availability <- function(sites, has_wu_color, no_wu_color) {
  wu_summary <- sites %>%
    group_by(WU_DATA_FLAG, facility_category) %>%
    summarize(count = n(), percent = count/nrow(sites)) %>%
    mutate(type = ifelse(is.na(WU_DATA_FLAG), 'No water use data', 'Has water use data'))
  max_per <- max(wu_summary$percent)
  min_per <- min(wu_summary$percent)
  wu_summary_plot <- wu_summary %>%
    ggplot() +
    geom_bar(aes(x = facility_category, y = count, fill = WU_DATA_FLAG),
             stat = 'identity', position = "fill") +
    scale_fill_manual(name = 'WU_DATA_FLAG', values = has_wu_color,
                      na.value = no_wu_color) +
    theme_void() +
    scale_y_continuous(position = 'right',
                       breaks = rev(c(max_per/2, max_per + min_per/2)),
                       labels = rev(c(sprintf('%s%% do not have water use data',
                                              round(max_per*100, 1)),
                                      sprintf("%s%% have water use data",
                                              round(min_per*100,1)))),
                       expand = c(0,0)) +
    scale_x_discrete(expand = c(0,0)) +
    theme(
      axis.title = element_blank(),
      axis.text.y = element_text(size = 20, hjust = 0, margin = margin(0,0,0,5)),
      axis.text.x = element_blank(),
      legend.position = 'none',
      plot.title = element_text(hjust = 0, size = 24, margin = margin(0,0,15,0))
    ) +
    ggtitle('Bottling facilities')
  return(wu_summary_plot)
}

#' @title combine water use map and chart
#' @description combine the map of sites with water use data with the bar chart
#' indicating the percent of sites that do and do not have water use data
#' @param wu_map the water use map
#' @param wu_chart the water use bar chart
#' @param width width for the combined plot canvas
#' @param height height for the combined plot canvas
#' @param font_legend font for the legend text
#' @return the final plot with the map and chart arranged side by side
combine_wu_map_and_chart <- function(wu_map, wu_chart, width, height, font_legend) {

  plot_margin <- 0.005

  # background
  canvas <- grid::rectGrob(
    x = 0, y = 0,
    width = width, height = height,
    gp = grid::gpar(fill = '#ffffff', alpha = 1, col = 'white')
  )

  final_plot <-  ggdraw(ylim = c(0,1),
                        xlim = c(0,1)) +
    # a background
    draw_grob(canvas,
              x = 0, y = 1,
              height = height, width = width,
              hjust = 0, vjust = 1) +
    draw_plot(
      wu_map,
      x = -0.01,
      y = 0,
      width = 0.7
    ) +
    draw_plot(
      wu_chart,
      x = 0.7,
      y = 0.5,
      height = 0.5,
      width = 0.3,
      vjust = 0.5
    )

  return(final_plot)
}

#' @title annotate shifted map
#' @description annotated a U.S. map with OCONUS entities shifted to plot next
#' to CONUS
#' @param shifted_map the map plot object
#' @param text_color color for text
#' @param plot_title_font_size font size for individual plot titles
#' @param width width for the final plot canvas
#' @param height height for the final plot canvas
#' @param font_legend font for the legend text
#' @return an annotated version of `shifted_map`
annotate_shifted_map <- function(shifted_map, text_color, plot_title_font_size,
                                 width, height, font_legend) {

  plot_margin <- 0.005

  # background
  canvas <- grid::rectGrob(
    x = 0, y = 0,
    width = width, height = height,
    gp = grid::gpar(fill = '#ffffff', alpha = 1, col = 'white')
  )

  # pts for inset lines from left to right
  left_x <- 0.05
  bottom_y <- 0.05
  right_x <- 0.96
  a_x <- 0.143
  a_y <- 0.17
  b_x <- 0.155
  b_y <- 0.625
  c_x <- 0.2
  c_y <- 0.37
  d_x <- 0.35
  d_y <- 0.3
  e_y <- 0.22
  f_x <- 0.39
  f_y <- d_y + (f_x - d_x)*(d_y - c_y)/(d_x - c_x)
  g_x <- 0.47
  h_x <- 0.55
  i_x <- 0.755
  j_x <- 0.785
  j_y <- 0.2

  line_size <- 0.2
  line_type <- 'dotted'
  font_face <- "italic"

  final_plot <-  ggdraw(ylim = c(0,1),
                        xlim = c(0,1)) +
    # a background
    draw_grob(canvas,
              x = 0, y = 1,
              height = height, width = width,
              hjust = 0, vjust = 1) +
    draw_plot(
      shifted_map,
      x = 0.5,
      y = 0,
      width = 1,
      hjust = 0.5
    ) +
    draw_line(
      x = c(i_x, j_x, right_x),
      y = c(bottom_y, j_y, j_y),
      color = "grey10", size = line_size,
      linetype = line_type
    ) +
    # Around AK and HI
    draw_line(
      x = c(a_x, a_x, c_x, d_x, f_x, h_x),
      y = c(bottom_y, a_y, c_y, d_y, f_y, bottom_y),
      color = "grey10", size = line_size,
      linetype = line_type
    ) +
    # HI
    draw_line(
      x = c(d_x, d_x, g_x),
      y = c(d_y, e_y, bottom_y),
      color = "grey10", size = line_size,
      linetype = line_type
    ) +
    # guam + northern mariana
    draw_line(
      x = c(left_x, b_x,  c_x),
      y = c(b_y, b_y, c_y),
      color = "grey10", size = line_size,
      linetype = line_type
    ) +
    # around AS
    draw_line(
      x = c(left_x, a_x),
      y = c(a_y, a_y),
      color = "grey10", size = line_size,
      linetype = line_type
    ) +
    draw_label(
      'Puerto Rico and U.S. Virgin Islands',
      x = 0.79,
      y = 0.177,
      size = plot_title_font_size,
      hjust = 0,
      vjust = 1,
      fontfamily = font_legend,
      fontface = font_face,
      color = text_color
    ) +
    draw_label(
      'Hawaii',
      x = 0.475,
      y = 0.08,
      size = plot_title_font_size,
      hjust = 0,
      vjust = 1,
      fontfamily = font_legend,
      fontface = font_face,
      color = text_color
    ) +
    draw_label(
      'Alaska',
      x = 0.3,
      y = 0.12,
      size = plot_title_font_size,
      hjust = 0,
      vjust = 1,
      fontfamily = font_legend,
      fontface = font_face,
      color = text_color
    ) +
    draw_label(
      'American Samoa',
      x = 0.029,
      y = 0.148,
      size = plot_title_font_size,
      hjust = 0,
      vjust = 1,
      fontfamily = font_legend,
      fontface = font_face,
      color = text_color
    ) +
    draw_label(
      'Guam',
      x = 0.075,
      y = 0.23,
      size = plot_title_font_size,
      hjust = 0,
      vjust = 1,
      fontfamily = font_legend,
      fontface = font_face,
      color = text_color
    ) +
    draw_label(
      stringr::str_wrap('Northern Mariana Islands', 8),
      x = 0.052,
      y = 0.47,
      size = plot_title_font_size,
      hjust = 0,
      vjust = 1,
      fontfamily = font_legend,
      fontface = font_face,
      color = text_color
    )

  return(final_plot)
}

#' @title generate site count matrix
#' @description generate a matrix of facility types, by state, with each matrix
#' cell filled according to the number of that facility type in that state. The
#' matrix has a bar chart of counts by type at right, and a bar chart of counts
#' by state below
#' @param type_summary dataframe with count of facilities by type
#' @param type_summary_state dataframe with count of facilities by type, by state
#' @param state_summary dataframe with count of facilities by state
#' @param palette name of scico palette to use for the matrix fill (site count)
#' @param palette_dir direction to use for the specified palette
#' @param bar_fill color for the fill of bars in the two bar charts
#' @param width width for the final plot
#' @param height height for the final plot
#' @param outfile filepath for saving the final plot
#' @param dpi dpi at which to save the final plot
#' @return the filepath of the saved plot
generate_site_count_matrix <- function(type_summary, type_summary_state,
                                       state_summary, palette, palette_dir,
                                       bar_fill, width, height, outfile, dpi) {
  # main matrix
  state_matrix <- type_summary_state %>%
    arrange(state_name) %>%
    ggplot(aes(x = reorder(state_abbr, state_abbr), y = WB_TYPE)) +
    geom_tile(aes(fill = site_count), color = 'white', width = 1, height = 1) +
    theme_minimal() +
    scico::scale_fill_scico(palette = palette, begin = 0, end = 1,
                            direction = palette_dir) +
    scale_x_discrete(position = 'top') +
    scale_y_discrete(labels = function(x) str_wrap(x, width = 10)) +
    theme(
      axis.title = element_blank(),
      legend.position = 'top',
      axis.text = element_text(size = 10),
      legend.title.align = 0.5,
      legend.background = element_rect(fill = '#ffffff', color = NA)
    ) +
    guides(fill = guide_colourbar(title = "Facility count", title.position = "top"))

  # bottom bar chart
  type_totals <- type_summary %>%
    ggplot(aes(x = site_count, y = WB_TYPE)) +
    geom_bar(stat = 'identity', fill = bar_fill, color = '#ffffff', width = 1) +
    scale_x_continuous(position = 'top',
                       breaks = c(0, 5000, 10000, 15000, 20000),
                       labels = c(0, "5k", "10k", "15k", "20k sites")) +
    theme_minimal() +
    theme(
      panel.grid = element_blank(),
      panel.grid.major.x = element_line(color = 'grey90', size=0.5),
      axis.text.y = element_blank(),
      axis.title = element_blank(),
      axis.text.x = element_text(size = 10))

  # right-hand bar chart
  state_totals <- state_summary %>%
    ggplot(aes(x = reorder(state_abbr, state_abbr), y = site_count)) +
    geom_bar(fill = bar_fill, color = 'white', stat = 'identity', width = 1) +
    scale_x_discrete(position = 'top') +
    scale_y_continuous(trans = "reverse",
                       breaks = rev(c(0, 1000, 3000, 5000, 7000, 9000)),
                       labels = rev(c("0 sites", "1k", "3k", "5k", "7k", "9k"))) +
    theme_minimal() +
    theme(
      panel.grid = element_blank(),
      axis.title = element_blank(),
      panel.grid.major.y = element_line(color = 'grey90', size = 0.5),
      axis.text = element_text(size = 10)
    )

  canvas <- grid::rectGrob(
    x = 0, y = 0,
    width = width, height = height,
    gp = grid::gpar(fill = 'white', alpha = 1, col = 'white')
  )

  # Extract from plot
  plot_legend <- get_legend(state_matrix)

  # define plots for grid
  main_plot <- state_matrix + theme(legend.position = 'none')
  right_plot <- type_totals + theme(legend.position = 'none')
  bottom_plot <- state_totals + theme(legend.position = 'none')

  # arrange plots
  plots <- align_plots(main_plot, bottom_plot, align = 'v', axis = 'l')
  top_row <- plot_grid(plots[[1]], right_plot, ncol = 2, align = 'h',
                       axis = 'tb', rel_widths = c(1, 0.15))
  bottom_row <- plot_grid(plots[[2]], NULL, ncol = 2, align = 'h', axis = 'tb',
                          rel_widths = c(1, 0.15))
  all <- plot_grid(top_row, bottom_row, ncol = 1, axis = 'lb',
                   rel_heights = c(1, 0.5))

  plot_margin = 0.015

  final_plot <- ggdraw(ylim = c(0,1),
                       xlim = c(0,1)) +
    # a white background
    draw_grob(canvas,
              x = 0, y = 1,
              height = height, width = width,
              hjust = 0, vjust = 1) +
    draw_plot(all,
              x = plot_margin/2,
              y = plot_margin,
              height = 0.85,
              width = 1-plot_margin*2) +
    # add legend
    draw_plot(plot_legend,
              x = plot_margin +0.75,
              y = 0.245,
              height = 0.01 ,
              width = 0.3) +
    # draw title
    draw_label('Count of facilities by type and by state',
               x = plot_margin, y = 1-plot_margin*4,
               size = 36,
               hjust = 0,
               vjust = 1,
               color = 'black',
               lineheight = 1)

  ggsave(outfile, final_plot, width = width, height = height, dpi = dpi)
  return(outfile)
}

#' @title theme facet
#' @description a function specifying a theme for a facet map
#' @param base base size for text
#' @param bkgd_color background color for the plot
#' @param text_color color for text
#' @return the applied theme
theme_facet <- function(base = 12, bkgd_color, text_color){
  theme(
    strip.background = element_blank(),
    strip.text = element_text(size = 11, vjust = 1, color = text_color),
    strip.placement = "inside",
    strip.background.x = element_blank(),
    axis.line = element_blank(),
    axis.ticks = element_blank(),
    axis.text = element_blank(),
    axis.title = element_blank(),
    panel.border = element_blank(),
    plot.title = element_text(size = 14, face = "bold"),
    plot.background = element_blank(),
    panel.background = element_blank(),
    panel.spacing.x = unit(5, "pt"),
    panel.spacing.y = unit(5, "pt"),
    panel.grid = element_blank(),
    plot.margin = margin(0, 0, 0, 0, "pt"),
    legend.background = element_rect(fill = bkgd_color, color = NA))

}


#' @title generate U.S. grid with Puerto Rico, Virgin Islands and Guam
#' @param row[abbr] numeric, add row number associated with territory
#' @param col[abbr] numeric, add col number associated with territory
#' @param code[abbr] character, add two letter abbreviation associated with territory
#' @param name[abbr] character, add long name associated with territory
#' @return dataframe with row, col, and (state) code, and (state) name
grid_pr_vi_gu <- function(rowPR = 7, colPR = 10, codePR = "PR", namePR = "Puerto Rico",
                          rowVI = 7, colVI = 11, codeVI = "VI", nameVI = "U.S. Virgin Islands",
                          rowGU = 6, colGU = 1, codeGU = "GU", nameGU = "Guam") {

  grid <- geofacet::us_state_grid1 %>%
    add_row(row = rowPR, col = colPR, code = codePR, name = namePR) %>% # add PR
    add_row(row = rowVI, col = colVI, code = codeVI, name = nameVI) %>% # add VI
    add_row(row = rowGU, col = colGU, code = codeGU, name = nameGU) # add GU

}

#' @title generate facility type facet map
#' @description generate a facet map showing the distribution of facilities
#' nationally and by state
#' @param type_summary dataframe with count of facilities by type
#' @param type_summary_state dataframe with count of facilities by type, by state
#' @param colors vector of colors to use for facility types
#' @param width width for the final plot
#' @param height height for the final plot
#' @param bkgd_color background color for the plot
#' @param text_color color for text
#' @param outfile filepath for saving the final plot
#' @param dpi dpi at which to save the final plot
#' @return the filepath of the saved plot
generate_facility_type_facet_map <- function(type_summary, type_summary_state,
                                             colors, width, height, bkgd_color,
                                             text_color, outfile, dpi) {

  state_cartogram <- type_summary_state %>%
    arrange(state_name) %>%
    group_by(state_name) %>%
    mutate(percent = site_count/sum(site_count)*100) %>%
    ggplot(aes(1, y = percent)) +
    geom_bar(aes(fill = WB_TYPE), stat = 'identity') +
    scale_fill_manual(name = 'WB_TYPE', values = colors) +
    theme_bw() +
    theme_facet(base = 12, bkgd_color = bkgd_color, text_color = text_color) +
    geofacet::facet_geo(~ state_abbr, grid = grid_pr_vi_gu(), move_axes = TRUE)

  national_plot <- type_summary %>%
    mutate(percent = site_count/sum(site_count)*100) %>%
    ggplot(aes(1, y = percent)) +
    geom_bar(aes(fill = WB_TYPE), stat = 'identity') +
    scale_fill_manual(name = 'WB_TYPE', values = colors) +
    scale_x_discrete(expand = c(0,0)) +
    scale_y_continuous(breaks = rev(c(0, 25, 50, 75, 100)),
                       labels = rev(c(0, 25, 50, 75, "100%")),
                       expand = c(0,0)) +
    theme_minimal() +
    theme(
      axis.title = element_blank(),
      panel.grid = element_blank(),
      axis.ticks.y = element_line(color = "lightgrey", size = 0.5),
      axis.text.x = element_blank(),
      legend.position = 'bottom',
      plot.title = element_text(hjust = 0.5, size = 20),
      axis.text.y = element_text(size = 14),
      legend.title.align = 0.5,
      panel.margin = margin(0, 0, 0, 0, "pt")
    ) +
    ggtitle('Nationally')

  plot_margin <- 0.005

  # background
  canvas <- grid::rectGrob(
    x = 0, y = 0,
    width = width, height = height,
    gp = grid::gpar(fill = bkgd_color, alpha = 1, col = bkgd_color)
  )

  # Extract from plot
  facet_legend <- get_legend(national_plot +
                               theme(legend.position = 'left',
                                     text = element_text(size = 16)) +
                               guides(
                                 fill = guide_legend(title = "Facility type",
                                                     ncol = 3)
                               ))

  # compose final plot
  facet_plot <- ggdraw(ylim = c(0,1),
                       xlim = c(0,1)) +
    # a background
    draw_grob(canvas,
              x = 0, y = 1,
              height = height, width = width,
              hjust = 0, vjust = 1) +
    # national-level plot
    draw_plot(national_plot + theme(legend.position = 'none'),
              x = 0.025,
              y = 0.3,
              height = 0.45 ,
              width = 0.32 - plot_margin * 2) +
    # state cartogram
    draw_plot(state_cartogram + theme(legend.position = 'none'),
              x = 0.975,
              y = 0.15,
              height = 0.7,
              width = 1 - (0.4 + plot_margin * 3),
              hjust = 1,
              vjust = 0) +
    # add legend
    draw_plot(facet_legend,
              x = 0.05,
              y = 0.15,
              height = 0.13 ,
              width = 0.3 - plot_margin) +
    draw_label('Distribution of facility types nationally and by state',
               x = 0.025, y = 0.93,
               size = 36,
               hjust = 0,
               vjust = 1,
               color = 'black',
               lineheight = 1)

  ggsave(outfile, facet_plot, width = width, height = height, dpi = dpi)
  return(outfile)
}


#' @title generate dataframe with count of facilities, or all, by water source
#' @param supply_summary dataframe with count of facilities by water source
#' @param selected_facility_type type of facility to plot. If 'All', summary
#' across facility types is plotted
#' @return df with count of facilities by type, or for all, by source source
process_supply_sum <- function(supply_summary, selected_facility_type) {

  if (!(selected_facility_type == 'All')) {
    supply_summary <- supply_summary %>%
      filter(WB_TYPE == selected_facility_type) %>%
      mutate(percent = site_count/sum(site_count)*100) |>
      mutate(ratio = site_count/sum(site_count))
  } else {
    supply_summary <- supply_summary %>%
      group_by(source_category) %>%
      summarize(site_count = sum(site_count)) %>%
      mutate(percent = site_count/sum(site_count)*100) |>
      mutate(ratio = site_count/sum(site_count))
  }

}

#' @title generate dataframe with count of facilities, or all, by water source for each state
#' @param supply_summary_state dataframe with count of facilities by water
#' source, by state
#' @param selected_facility_type type of facility to plot. If 'All', summary
#' across facility types is plotted
#' @return df with count of facilities by type, or for all, by source source for each state
process_supply_state_sum <- function(supply_summary_state, selected_facility_type) {

  if (!(selected_facility_type == 'All')) {
    supply_summary_state <- supply_summary_state %>%
      filter(WB_TYPE == selected_facility_type) %>%
      arrange(state_name) %>%
      group_by(state_name, state_abbr) %>%
      mutate(percent = site_count/sum(site_count)*100) |>
      mutate(ratio = site_count/sum(site_count))
  } else {
    supply_summary_state <- supply_summary_state %>%
      arrange(state_name) %>%
      group_by(state_name, state_abbr, source_category) %>%
      summarize(site_count = sum(site_count)) %>%
      group_by(state_name, state_abbr) %>%
      mutate(percent = site_count/sum(site_count)*100) |>
      mutate(ratio = site_count/sum(site_count))
  }

}

#' @title generate facility source facet map
#' @description generate a facet map showing the distribution of facility water
#' sources nationally and by state
#' @param supply_summary dataframe with count of facilities by water source
#' @param supply_summary_state dataframe with count of facilities by water
#' source, by state
#' @param supply_colors vector of colors to use for water source categories
#' @param selected_facility_type type of facility to plot. If 'All', summary
#' across facility types is plotted
#' @param width width for the final plot
#' @param height height for the final plot
#' @param bkgd_color background color for the plot
#' @param text_color color for text
#' @param outfile_template filepath template for saving the final plot
#' @param dpi dpi at which to save the final plot
#' @return the filepath of the saved plot
generate_facility_source_facet_map <- function(supply_summary, supply_summary_state,
                                               supply_colors, selected_facility_type,
                                               width, height, bkgd_color, text_color,
                                               outfile_template, dpi) {

  supply_summary_state <- process_supply_state_sum(supply_summary_state = supply_summary_state,
                                                   selected_facility_type = selected_facility_type)

  supply_summary <- process_supply_sum(supply_summary = supply_summary,
                                       selected_facility_type = selected_facility_type)

  state_cartogram <- supply_summary_state %>%
    ggplot(aes(1, y = percent)) +
    geom_bar(aes(fill = source_category), stat = 'identity') +
    scale_fill_manual(name = 'source_category', values = supply_colors) +
    theme_bw() +
    theme_facet(base = 12, bkgd_color = bkgd_color, text_color = text_color) +
    geofacet::facet_geo(~ state_abbr, grid = grid_pr_vi_gu(), move_axes = TRUE)

  national_plot <- supply_summary %>%
    ggplot(aes(1, y = percent)) +
    geom_bar(aes(fill = source_category), stat = 'identity') +
    scale_fill_manual(name = 'source_category', values = supply_colors) +
    scale_x_discrete(expand = c(0,0)) +
    scale_y_continuous(breaks = rev(c(0, 25, 50, 75, 100)),
                       labels = rev(c(0, 25, 50, 75, "100%")),
                       expand = c(0,0)) +
    theme_minimal() +
    theme(
      axis.title = element_blank(),
      panel.grid = element_blank(),
      axis.ticks.y = element_line(color = "lightgrey", size = 0.5),
      axis.text.x = element_blank(),
      legend.position = 'bottom',
      plot.title = element_text(hjust = 0.5, size = 20),
      axis.text.y = element_text(size = 14),
      legend.title.align = 0.5,
      panel.margin = margin(0, 0, 0, 0, "pt")
    ) +
    ggtitle('Nationally')

  plot_margin <- 0.005

  # background
  canvas <- grid::rectGrob(
    x = 0, y = 0,
    width = width, height = height,
    gp = grid::gpar(fill = bkgd_color, alpha = 1, col = bkgd_color)
  )

  # Extract from plot
  facet_legend <- get_legend(national_plot +
                               theme(legend.position = 'left',
                                     text = element_text(size = 16)) +
                               guides(
                                 fill = guide_legend(title = "Water source",
                                                     ncol = 1)
                               ))

  # compose final plot
  facet_plot <- ggdraw(ylim = c(0,1),
                       xlim = c(0,1)) +
    # a background
    draw_grob(canvas,
              x = 0, y = 1,
              height = height, width = width,
              hjust = 0, vjust = 1) +
    # national-level plot
    draw_plot(national_plot + theme(legend.position = 'none'),
              x = 0.025,
              y = 0.3,
              height = 0.45 ,
              width = 0.32 - plot_margin * 2) +
    # state cartogram
    draw_plot(state_cartogram + theme(legend.position = 'none'),
              x = 0.975,
              y = 0.15,
              height = 0.7,
              width = 1 - (0.4 + plot_margin * 3),
              hjust = 1,
              vjust = 0) +
    # add legend
    draw_plot(facet_legend,
              x = 0.05,
              y = 0.15,
              height = 0.13 ,
              width = 0.3 - plot_margin) +
    draw_label(sprintf('Distribution of water sources for %s facilities',
                       tolower(selected_facility_type)),
               x = 0.025, y = 0.93,
               size = 36,
               hjust = 0,
               vjust = 1,
               color = 'black',
               lineheight = 1)

  outfile <- ifelse(selected_facility_type == 'All', outfile_template,
                    sprintf(outfile_template, selected_facility_type))
  ggsave(outfile, facet_plot, width = width, height = height, dpi = dpi)
  return(outfile)
}

#' @title generate facility source facet map for bottled water only
#' @description generate a facet map showing the distribution of bottled water facility water
#' sources nationally and by state
#' @param supply_summary dataframe with count of facilities by water source
#' @param supply_summary_state dataframe with count of facilities by water
#' source, by state
#' @param supply_colors vector of colors to use for water source categories
#' @param selected_facility_type type of facility to plot. If 'All', summary
#' across facility types is plotted
#' @param width width for the final plot
#' @param height height for the final plot
#' @param bkgd_color background color for the plot
#' @param text_color color for text
#' @param outfile_template filepath template for saving the final plot
#' @param dpi dpi at which to save the final plot
#' @return the filepath of the saved plot
generate_facility_bw_source_facet_map <- function(supply_summary, supply_summary_state,
                                               supply_colors, selected_facility_type,
                                               width, height, bkgd_color, text_color,
                                               outfile_template, dpi) {

  supply_summary_state <- process_supply_state_sum(supply_summary_state = supply_summary_state,
                                                   selected_facility_type = selected_facility_type)

  supply_summary <- process_supply_sum(supply_summary = supply_summary,
                                       selected_facility_type = selected_facility_type)

  supply_summary_tx <- supply_summary_state |>
    filter(state_abbr == "TX")

  supply_summary_ri <- supply_summary_state |>
    filter(state_abbr == "RI")

  supply_summary_vt <- supply_summary_state |>
    filter(state_abbr == "VT")

  font_legend <- "Source Sans Pro"
  sysfonts::font_add_google(font_legend)
  showtext::showtext_opts(dpi = 300, regular.wt = 200, bold.wt = 900)
  showtext::showtext_auto(enable = TRUE)

  annotate_legend <- "Neucha"
  sysfonts::font_add_google(annotate_legend)
  showtext::showtext_opts(dpi = 300, regular.wt = 200, bold.wt = 900)
  showtext::showtext_auto(enable = TRUE)

  state_cartogram <- supply_summary_state %>%
    ggplot(aes(1, y = percent)) +
    ggfx::with_shadow(
      geom_bar(aes(fill = source_category), stat = 'identity'),
      colour = "black",
      x_offset = 2,
      y_offset = 2,
      sigma = 5,
      stack = TRUE,
      with_background = FALSE
    ) +
    #geom_bar(aes(fill = source_category), stat = 'identity') +
    scale_fill_manual(name = 'source_category', values = supply_colors) +
    theme_bw() +
    theme_facet(base = 12, bkgd_color = bkgd_color, text_color = text_color) +
    theme(strip.text = element_text(family = font_legend, vjust = -1),
          plot.margin = margin(50, 50, 50, 50, "pt"),
          panel.spacing.y = unit(-5, "pt"),
          panel.spacing.x = unit(4, "pt")) +
    geofacet::facet_geo(~ state_abbr, grid = grid_pr_vi_gu(), move_axes = TRUE)

  national_plot <- supply_summary %>%
    ggplot(aes(1, y = percent)) +
    geom_bar(aes(fill = source_category), stat = 'identity') +
    scale_fill_manual(name = 'source_category', values = supply_colors) +
    scale_x_discrete(expand = c(0,0)) +
    scale_y_continuous(breaks = rev(c(0, 25, 50, 75, 100)),
                       labels = rev(c(0, 25, 50, 75, "100%")),
                       expand = c(0,0)) +
    ggtitle('National') +
    theme_minimal() +
    theme(
      axis.title = element_blank(),
      panel.grid = element_blank(),
      axis.ticks.y = element_line(color = "lightgrey", linewidth = 0.5),
      axis.text.x = element_blank(),
      legend.position = 'bottom',
      plot.title = element_text(hjust = 0.5, size = 22, margin = margin(b = 10), family = font_legend),
      axis.text.y = element_text(size = 14),
      legend.title.align = 0.5,
      panel.margin = margin(0, 0, 0, 0, "pt"),
      text = element_text(size = 20, family = font_legend)
    )

  plot_margin <- 0.005

  # background
  canvas <- grid::rectGrob(
    x = 0, y = 0,
    width = width, height = height,
    gp = grid::gpar(fill = bkgd_color, alpha = 1, col = bkgd_color)
  )

  # Extract from plot
  facet_legend <- get_legend(national_plot +
                               theme(legend.position = 'left',
                                     text = element_text(size = 14, family = font_legend)) +
                               guides(
                                 fill = guide_legend(title = "Water source",
                                                     nrow = 1,
                                                     reverse = TRUE)
                               ))
  plot_arrow_tx <- ggplot() +
    theme_void() +
    geom_curve(aes(x = -2.5, y = 5.5, xend = -1.25, yend = 6),
               arrow = arrow(length = unit(0.08, "npc"), type="closed"),
               colour = text_color, linewidth = 0.45, curvature = -0.3, angle = 100)

  plot_arrow_combo <- ggplot() +
    theme_void() +
    geom_curve(aes(x = -1.25, y = 5, xend = -2.5, yend = 5.5),
               arrow = arrow(length = unit(0.08, "npc"), type = "closed"),
               colour = text_color, linewidth = 0.45, curvature = 0.3, angle = 100)

  plot_arrow_vt <- ggplot() +
    theme_void() +
    geom_curve(aes(x = -1.25, y = 5, xend = -0.5, yend = 4.5),
               arrow = arrow(length = unit(0.08, "npc"), type = "closed"),
               colour = text_color, linewidth = 0.45, curvature = 0.3, angle = 100)

  # compose final plot
  facet_plot <- ggdraw(ylim = c(0,1),
                       xlim = c(0,1)) +
    # a background
    draw_grob(canvas,
              x = 0, y = 1,
              height = height, width = width,
              hjust = 0, vjust = 1) +
    # national-level plot
    draw_plot(national_plot + theme(legend.position = 'none'),
              x = 0.025,
              y = 0.3,
              height = 0.45 ,
              width = 0.32 - plot_margin * 2) +
    # state cartogram
    draw_plot(state_cartogram + theme(legend.position = 'none'),
              x = 0.964,
              y = 0.128,
              height = 0.8,
              width = 1 - (0.4 + plot_margin * 5),
              hjust = 1,
              vjust = 0) +
    # add legend
    draw_plot(facet_legend,
              x = 0.05,
              y = 0.19,
              height = 0.13 ,
              width = 0.3 - plot_margin) +
    draw_label(sprintf('Distribution of water sources\n for %s facilities',
                       tolower(selected_facility_type)),
               x = 0.025, y = 0.93,
               size = 38,
               hjust = 0,
               vjust = 1,
               color = 'black',
               lineheight = 1,
               fontfamily = font_legend,
               fontface = "bold") +
    # plot arrow - TX
    draw_plot(plot_arrow_tx,
              x = 0.533,
              y = 0.168,
              height = 0.07 ,
              width = 0.035 - plot_margin) +
    draw_label(paste("Texas\nsources", paste0(round(max(supply_summary_tx$percent)), "%"),"\nfrom public supply"),
              x = 0.536,
              y = 0.130,
              size = 16,
              color = text_color,
              fontfamily = annotate_legend) +
    # plot arrow - combination = mix of sources callout
    draw_plot(plot_arrow_combo,
              x = 0.348,
              y = 0.60,
              height = 0.08,
              width = 0.035 - plot_margin) +
    draw_label("Combination =\n a mix of sources",
               x = 0.381,
               y = 0.554,
               size = 16,
               color = text_color,
               fontfamily = annotate_legend) +
    # plot arrow - RI
    draw_plot(plot_arrow_combo,
              x = 0.928,
              y = 0.539,
              height = 0.08,
              width = 0.035 - plot_margin) +
    draw_label(paste("Rhode Island\nsources", paste0(round(max(supply_summary_ri$percent)), "%"),"\nfrom a mix\n of sources"),
               x = 0.955,
               y = 0.5,
               size = 16,
               color = text_color,
               fontfamily = annotate_legend) +
  # plot arrow - VT
    draw_plot(plot_arrow_vt,
              x = 0.753,
              y = 0.775,
              height = 0.08,
              width = 0.035 - plot_margin) +
    draw_label(paste("Vermont\nsources", paste0(round(max(supply_summary_vt$percent)), "%"),"\nfrom self supply"),
               x = 0.753,
               y = 0.899,
               size = 16,
               color = text_color,
               fontfamily = annotate_legend)


  outfile <- ifelse(selected_facility_type == 'All', outfile_template,
                    sprintf(outfile_template, selected_facility_type))
  ggsave(outfile, facet_plot, width = width, height = height, dpi = dpi)
  return(outfile)
}

#' @title generate sankey diagram of water sources and facilitity types
#' @param supply_summary dataframe with count of facilities by water source
#' @param supply_colors vector of colors to use for water source categories
#' @param font_legend font used for the plot
#' @param width width for the final plot
#' @param height height for the final plot
#' @param bkgd_color background color for the plot
#' @param text_color color for text
#' @param outfile_template filepath template for saving the final plot
#' @param dpi dpi at which to save the final plot
#' @return the filepath of the saved plot
generate_national_sankey <- function(supply_summary, supply_colors, font_legend, width, height, bkgd_color, text_color, outfile_template, dpi) {

  # Create the ggplot
  sankey <- ggplot(data = supply_summary,
                  aes(axis1 = source_category, axis2 = WB_TYPE, y = site_count)) +
    geom_alluvium(aes(fill = source_category),
                  curve_type = "arctan", width = 0.1, alpha = 0.8) +
    geom_stratum(alpha = 0, width = 0.1, size = 0.5, color = text_color) +
    ggfx::with_shadow(
      colour = bkgd_color, x_offset = 3, y_offset = 2, sigma = 3,
      geom_text(stat = "stratum",
                aes(label = after_stat(stratum)),
                family = font_legend, fontface = "bold", size = 3.5)
    ) +
    scale_x_discrete(limits = c("source_category", "WB_TYPE"),
                     expand = c(0.15, 0.05)) +
    theme_void() +
    scale_fill_manual(name = 'source_category', values = supply_colors) +
    #scale_alpha_manual(values = c(0.9, 0.7, 0.5, 0.3)) +
    theme(legend.position = "none")

  plot_margin <- 0.005

  # background
  canvas <- grid::rectGrob(
    x = 0, y = 0,
    width = width, height = height,
    gp = grid::gpar(fill = bkgd_color, alpha = 1, col = bkgd_color)
  )

  # compose final plot
  sankey_plot <- ggdraw(ylim = c(0,1),
                       xlim = c(0,1)) +
    # a background
    draw_grob(canvas,
              x = 0, y = 1,
              height = height, width = width,
              hjust = 0, vjust = 1) +
    # plot sankey
    draw_plot(sankey,
              x = 0.992,
              y = 0.06,
              height = 0.8,
              width = 1 - (0.01 + plot_margin * 2),
              hjust = 1,
              vjust = 0) +
    # add title
    draw_label("Distribution of water sources by facility types",
               x = 0.025, y = 0.94,
               size = 38,
               hjust = 0,
               vjust = 1,
               color = text_color,
               lineheight = 1,
               fontfamily = font_legend,
               fontface = "bold")

  ggsave(outfile_template, sankey_plot, width = width, height = height, dpi = dpi, bg = bkgd_color)
  return(outfile_template)

}


#' @title create expanded self supply stacked bottled water conus maps across facilities
#' @param site sites with water use data
#' @param proj_str, set map projection
#' @param font_legend font used for the plot
#' @param width width for the final plot
#' @param height height for the final plot
#' @param bkgd_color background color for the plot
#' @param text_color color for text
#' @param outfile_template filepath template for saving the final plot
#' @param dpi dpi at which to save the final plot
#' @param get_percent logical where if TRUE, creates a map of percent distribution of water sources for bottled water facilities with expanded self supply facilities,
#' if FALSE, return map of counts of bottled water with expanded self supply facilities.
#' @param supply_colors vector of colors to use for water source categories
#' @param selected_facility_type type of facility to plot. If 'Bottled Water', filter sites data for bottled water facilities only
#' @return the filepath of the saved plot
generate_bw_expand_ss_map <- function(site, proj_str, width, height, bkgd_color, text_color, outfile_template, dpi,
                                      get_percent, supply_colors, font_legend, selected_facility_type) {
  
  conus_sf <- tigris::states(cb = TRUE) %>%
    st_transform(proj_str) %>%
    filter(STUSPS %in% state.abb[!state.abb %in% c('AK', 'HI')]) %>%
    rmapshaper::ms_simplify(keep = 0.4)

  counties_sf <- tigris::counties() %>%
    st_transform(crs = proj_str) %>%
    filter(STATEFP %in% conus_sf$STATEFP) %>%
    rmapshaper::ms_simplify(keep = 0.2) %>%
    st_intersection(st_union(conus_sf))


  # Get summary of facility supply sources, by type
  supply_summary <- site |>
    janitor::clean_names() |>
    filter(wb_type == selected_facility_type) |>
    group_by(full_fips, water_source) |>
    summarize(site_count = n()) |>
    filter(!water_source == "other") |> # Filter out type 'other' for now
    mutate(water_source = factor(water_source, levels = names(supply_colors))) |>
    group_by(full_fips) |>
    mutate(percent = site_count/sum(site_count)*100)

  county_bw_sf <- counties_sf %>%
    left_join(supply_summary, by = c('GEOID' = 'full_fips')) |>
    drop_na(water_source) |>
    janitor::clean_names()

  if (get_percent == FALSE) {

    fnl_plt <- ggplot() +
      geom_sf(data = conus_sf,
              fill = "white",
              color = 'gray',
              size = 0.6,
              linetype = "solid" ) +
      geom_sf(data = counties_sf,
              color = "lightgray",
              fill = NA,
              size = 0.1) +
      # by site count
      geom_point(data = county_bw_sf,
                 aes(size = site_count, geometry = geometry, color = source_category_name),
                 alpha = 0.5,
                 stat = "sf_coordinates") +
      scale_x_continuous(expand = c(0,0)) +
      scale_y_continuous(expand = c(0,0)) +
      scale_size(range = c(0.25, 2), limits = c(0, 250), name = '',
                 guide = guide_legend(
                   direction = "horizontal",
                   nrow = 1,
                   label.position = "bottom")) +
      scale_color_manual(name = 'Water source',
                         values = supply_colors) +
      guides(color = guide_legend(title = "",
                                  nrow = 1,
                                  label.position = "bottom")) +
      theme_void() +
      theme(
        legend.position = "bottom",
        plot.title = element_text(hjust = 0.5, size = 14, margin = margin(t = 1, b = 40)),
        plot.margin = unit(c(1,1,1,1), "cm"),
        strip.text = element_text(margin = margin(b = 10), family = font_legend, size = 14),
        strip.background = element_blank(),
        panel.spacing = unit(2, "lines")
      ) +
      facet_wrap(~source_category_name)

    # bivariate_color_scale <- purrr::map2_df(names(supply_colors), supply_colors, function(source_category_name, supply_colors) {
    #   tibble(
    #     ws_category = rep(source_category_name, 5),
    #     size = c(250, 200, 150, 100, 50),
    #     fill = rep(supply_colors, 5)
    #   )
    # }) %>%
    #   mutate(ws_category = factor(ws_category, levels = rev(color_names)))
    #
    # legend_list <- purrr::map2(names(supply_colors), supply_colors, function(source_category_name, supply_colors) {
    #   ggplot() +
    #     geom_tile(
    #       data = filter(bivariate_color_scale, ws_category == source_category_name),
    #       mapping = aes(
    #         x = alpha,
    #         y = ws_category,
    #         fill = fill,
    #         alpha = alpha)
    #     ) +
    #     scale_fill_identity() +
    #     scale_alpha(range = c(0.1,1), limits = c(0, 100), name = '') +
    #     scale_y_discrete(position = "right", expand = c(0,0)) +
    #     theme_void() +
    #     theme(
    #       legend.position = 'none',
    #       plot.margin = unit(c(0,6,6.5,0), "cm")
    #     )
    # })
  } else {

    fnl_plt <- ggplot() +
      geom_sf(data = conus_sf,
              fill = "white",
              color = 'gray',
              size = 0.6,
              linetype = "solid" ) +
      geom_sf(data = counties_sf,
              color = "lightgray",
              fill = NA,
              size = 0.1) +
      # by percent
      geom_point(data = county_bw_sf,
                 aes(size = percent, geometry = geometry, color = source_category_name),
                 alpha = 0.5,
                 stat = "sf_coordinates") +
      scale_x_continuous(expand = c(0,0)) +
      scale_y_continuous(expand = c(0,0)) +
      scale_size(range = c(0.25, 2), limits = c(0, 100), name = '',
                 guide = guide_legend(
                   direction = "horizontal",
                   nrow = 1,
                   label.position = "bottom")) +
      scale_color_manual(name = 'Water source',
                         values = supply_colors) +
      guides(color = guide_legend(title = "",
                                  nrow = 1,
                                  label.position = "bottom")) +
      theme_void() +
      theme(
        legend.position = "bottom",
        plot.title = element_text(hjust = 0.5, size = 14, margin = margin(t = 1, b = 40)),
        plot.margin = unit(c(1,1,1,1), "cm"),
        strip.text = element_text(margin = margin(b = 10), family = font_legend, size = 14),
        strip.background = element_blank(),
        panel.spacing = unit(2, "lines")
      ) +
      facet_wrap(~source_category_name)
#
#     # legend
#     bivariate_color_scale <- purrr::map2_df(names(supply_colors), supply_colors, function(source_category_name, supply_colors) {
#       tibble(
#         ws_category = rep(source_category_name, 5),
#         alpha = c(0, 30, 60, 90, 120),
#         fill = rep(supply_colors, 5)
#       )
#     }) %>%
#       mutate(ws_category = factor(ws_category, levels = rev(color_names)))
#
#     legend_list <- purrr::map2(names(supply_colors), supply_colors, function(source_category_name, supply_colors) {
#       ggplot() +
#         geom_tile(
#           data = filter(bivariate_color_scale, ws_category == source_category_name),
#           mapping = aes(
#             x = alpha,
#             y = ws_category,
#             fill = fill,
#             alpha = alpha)
#         ) +
#         scale_fill_identity() +
#         scale_alpha(range = c(0.1,1), limits = c(0, 100), name = '') +
#         scale_y_discrete(position = "right", expand = c(0,0)) +
#         theme_void() +
#         theme(
#           legend.position = 'none',
#           plot.margin = unit(c(0,6,6.5,0), "cm")
#         )
#     })

  }

  # arranged_legends <- cowplot::plot_grid(plotlist = legend_list, nrow = 3, ncol = 3, scale = 1)
  #
  # # cowplot
  # plot_margin <- 0.005
  #
  # canvas <- grid::rectGrob(
  #   x = 0, y = 0,
  #   width = 16, height = 9,
  #   gp = grid::gpar(fill = bkgd_color, alpha = 1, col = bkgd_color)
  # )
  #
  # plt <- ggdraw(ylim = c(0,1), # 0-1 scale makes it easy to place viz items on canvas
  #                   xlim = c(0,1)) +
  #   # a background
  #   draw_grob(canvas,
  #             x = 0, y = 1,
  #             height = 16, width = 9,
  #             hjust = 0, vjust = 1) +
  #   draw_label('Distribution of Water Sources for Bottled Water Facilities with Expanded Self Supply',
  #              x = 0.025, y = 0.97,
  #              size = 28,
  #              hjust = 0,
  #              vjust = 1,
  #              color = text_color,
  #              lineheight = 1,
  #              fontfamily = font_legend,
  #              fontface = "bold") +
  #   # public supply  legend
  #   draw_plot(legend_list[[1]],
  #             x = 0.71,
  #             y = -0.22,
  #             width = 0.35,
  #             height = 0.3) +
  #   # well legend
  #   draw_plot(legend_list[[2]],
  #             x = 0.71,
  #             y = 0.197,
  #             width = 0.35,
  #             height = 0.3) +
  #   # spring legend
  #   draw_plot(legend_list[[3]],
  #             x = 0.062,
  #             y = -0.22,
  #             width = 0.35,
  #             height = 0.3) +
  #   # sw intake legend
  #   draw_plot(legend_list[[4]],
  #             x = 0.385,
  #             y = -0.22,
  #             width = 0.35,
  #             height = 0.3) +
  #   # both legend
  #   draw_plot(legend_list[[5]],
  #             x = 0.385,
  #             y = 0.197,
  #             width = 0.35,
  #             height = 0.3) +
  #   # undetermined legend
  #   draw_plot(legend_list[[6]],
  #             x = 0.062,
  #             y = 0.197,
  #             width = 0.35,
  #             height = 0.3)
  #
  # if (get_percent == TRUE) {
  #   fnl_plt <- plt +
  #     draw_plot(map_perc,
  #               x = 0.995,
  #               y = 0.015,
  #               height = 0.95,
  #               width = 1 - plot_margin,
  #               hjust = 1,
  #               vjust = 0) +
  #     # public supply legend with % labels
  #     draw_label('0         10      25      75      100%',
  #                fontfamily = font_legend,
  #                x = 0.72,
  #                y = 0.03,
  #                size = 15,
  #                hjust = 0,
  #                vjust = 0,
  #                color = text_color)
  #
  # } else {
  #   fnl_plt <- plt +
  #     draw_plot(map_count,
  #               x = 0.995,
  #               y = 0.015,
  #               height = 0.95,
  #               width = 1 - plot_margin,
  #               hjust = 1,
  #               vjust = 0) +
  #     # public supply legend with count labels
  #     draw_label('0         30      60      90      120',
  #                fontfamily = font_legend,
  #                x = 0.72,
  #                y = 0.03,
  #                size = 15,
  #                hjust = 0,
  #                vjust = 0,
  #                color = text_color)
  # }
  ggsave(outfile_template, fnl_plt, width = width, height = height, dpi = dpi, bg =  bkgd_color)

}

#' @title create expanded self supply stacked barplot for all facilities
#' @param source_summary count, percent, and ratio of facilities by expanded water source
#' @param supply_colors vector of colors to use for water source categories
#' @param font_legend font used for the plot
#' @param width width for the final plot
#' @param height height for the final plot
#' @param bkgd_color background color for the plot
#' @param text_color color for text
#' @param outfile_template filepath template for saving the final plot
#' @param dpi dpi at which to save the final plot
#' @param get_percent if else statement where if TRUE, create a stacked barplot of percent distribution of water sources with expanded self supply facilities,
#' if FALSE, return barplot of site count distributions of water sources with expanded self supply facilities.
#' @param bracket_png_path path for bracket png made to group self supply categories together in final figure
#' @return the filepath of the saved plot
expanded_ss_barplot <- function(source_summary, supply_colors, font_legend,
                                width, height, bkgd_color, text_color, outfile_template, dpi,
                                get_percent, bracket_png_path) {
  
  # target `p3_font_legend` sometimes doesnt load on my end ?
  font_legend <- 'Source Sans Pro'
  font_add_google(font_legend)
  showtext_opts(dpi = 300, regular.wt = 200, bold.wt = 700)
  showtext_auto(enable = TRUE)

  if (get_percent == TRUE) {

  expand_ss <- source_summary |>
    ggplot(aes(x = WB_TYPE, y = percent, fill = water_source)) +
    geom_bar(stat="identity", position = "stack") +
    scale_fill_manual(name = 'water_source', values = supply_colors, drop = FALSE) +
    scale_x_discrete(expand = c(0,0)) +
    scale_y_continuous(breaks = seq(0, 100, by = 25),  # Specify breaks at 0, 25, 50, 75, and 100
                       labels = c("0", "25", "50", "75", "100%"),  # Specify labels for the breaks
                       expand = c(0, 0.1)) +
    theme_minimal() +
    theme(
      axis.title = element_blank(),
      panel.grid = element_blank(),
      axis.ticks.y = element_line(color = "lightgrey", size = 0.5),
      axis.text.x = element_text(size = 14),
      legend.position = 'bottom',
      plot.title = element_text(hjust = 0.5, size = 20),
      axis.text.y = element_text(size = 14),
      #legend.title.align = 0.5,
      legend.title = element_text(vjust = 1, size = 14),
      legend.title.align = 0.5,
      #panel.margin = margin(0, 0, 0, 0, "pt"),
      legend.spacing.x = unit(0.5, "cm"),
      text = element_text(family = font_legend, size = 14),
      plot.margin = margin(30, 20, 20, 30),
      legend.text = element_text(family = font_legend, size = 14)
    ) +
    # ggtitle('National') +
    guides(fill = guide_legend(title = "Water source",
                               title.position = "top",
                               nrow = 1,
                               reverse = TRUE))

  } else {

  expand_ss <- source_summary |>
    ggplot(aes(x = WB_TYPE, y = site_count, fill = water_source)) +
    geom_bar(stat="identity", position = "stack") +
    scale_fill_manual(name = 'water_source', values = supply_colors, drop = FALSE) +
    scale_x_discrete(expand = c(0,0)) +
    scale_y_continuous(breaks = seq(0, 20000, by = 5000),
                       labels = c("0", "5000", "10000", "15000", "20000")) + # Specify labels for the breaks) +
    theme_minimal() +
    theme(
      axis.title = element_blank(),
      panel.grid = element_blank(),
      axis.ticks.y = element_line(color = "lightgrey", size = 0.5),
      axis.text.x = element_text(size = 14),
      legend.position = 'bottom',
      plot.title = element_text(hjust = 0.5, size = 20),
      axis.text.y = element_text(size = 14),
      #legend.title.align = 0.5,
      legend.title = element_text(vjust = 1, size = 14),
      legend.title.align = 0.5,
      #panel.margin = margin(0, 0, 0, 0, "pt"),
      legend.spacing.x = unit(0.5, "cm"),
      text = element_text(family = font_legend, size = 14),
      plot.margin = margin(30, 20, 20, 30),
      legend.text = element_text(family = font_legend, size = 14)
    ) +
    # ggtitle('National') +
    guides(fill = guide_legend(title = "Water source",
                               title.position = "top",
                               nrow = 1,
                               reverse = TRUE))

  }

  plot_margin <- 0.005

  # background
  canvas <- grid::rectGrob(
    x = 0, y = 0,
    width = width, height = height,
    gp = grid::gpar(fill = bkgd_color, alpha = 1, col = bkgd_color)
  )

  # compose final plot
  expand_ss_barplot <- ggdraw(ylim = c(0,1),
                       xlim = c(0,1)) +
    # a background
    draw_grob(canvas,
              x = 0, y = 1,
              height = height, width = width,
              hjust = 0, vjust = 1) +
    # plot barplot
    draw_plot(expand_ss,
              x = 0.992,
              y = 0.06,
              height = 0.8,
              width = 1 - (0.01 + plot_margin * 2),
              hjust = 1,
              vjust = 0) +
    # add title
    draw_label("Distribution of water sources with expanded self supply by facility types",
               x = 0.025, y = 0.94,
               size = 32,
               hjust = 0,
               vjust = 1,
               color = text_color,
               lineheight = 1,
               fontfamily = font_legend,
               fontface = "bold") +
    # add bracket for self supply categories
    draw_image(magick::image_read(bracket_png_path),
               x = 0.321,
               y = -0.66,
               width = 0.3,
               height = 1.5) +
    draw_label("self supply",
               x = 0.475, y = 0.07,
               size = 14,
               hjust = 0,
               vjust = 1,
               color = text_color,
               lineheight = 1,
               fontfamily = font_legend)


  ggsave(outfile_template, expand_ss_barplot, width = width, height = height, dpi = dpi, bg = bkgd_color)

}

#' @title generate facility source facet tree map
#' @description generate a faceted treemap showing the distribution of facility water
#' sources nationally and by state
#' @param supply_summary dataframe with count of facilities by water source
#' @param supply_summary_state dataframe with count of facilities by water
#' source, by state
#' @param supply_colors vector of colors to use for water source categories
#' @param selected_facility_type type of facility to plot. If 'All', summary
#' across facility types is plotted
#' @param width width for the final plot
#' @param height height for the final plot
#' @param bkgd_color background color for the plot
#' @param text_color color for text
#' @param outfile_template filepath template for saving the final plot
#' @param dpi dpi at which to save the final plot
#' @param font_legend font used for the plot
#' @return the filepath of the saved plot
generate_facility_source_facet_treemap <- function(supply_summary, supply_summary_state,
                                                   supply_colors, selected_facility_type,
                                                   width, height, bkgd_color, text_color,
                                                   outfile_template, dpi, font_legend){

  supply_summary_state <- process_supply_state_sum(supply_summary_state = supply_summary_state,
                                                   selected_facility_type = selected_facility_type)

  supply_summary <- process_supply_sum(supply_summary = supply_summary,
                                       selected_facility_type = selected_facility_type)

  # state level treemaps
  tm <- treemap(dtf = supply_summary_state, vSize = 'percent', index = c('state_abbr', 'source_category', 'site_count'), type = 'index')
  tm_df <- tm$tm

  tm_df_plot <- tm_df %>%
    # calculate end coordinates with height and width
    mutate(x1 = x0 + w,
           y1 = y0 + h) %>%
    # get center coordinates for labels
    mutate(x = (x0+x1)/2,
           y = (y0+y1)/2)

  # adjust coordinates
  tm_df_plot_mod <- filter(tm_df_plot, !is.na(source_category)) %>%
    group_by(state_abbr) %>%
    group_modify( ~{
      min_x <- min(.x$x0)
      min_y <- min(.x$y0)
      .x <- .x %>%
        mutate(x_start = x0 - min_x,
               x_end = x1 - min_x,
               y_start = y0 - min_y,
               y_end = y1 - min_y)
    })

  # geofacet
  state_facet <- ggplot(tm_df_plot_mod, aes(xmin = x_start, ymin = y_start, xmax = x_end, ymax = y_end)) +
    # add fill and borders for groups and subgroups
    geom_rect(aes(fill = source_category),
              show.legend = TRUE, color = text_color) +
    geofacet::facet_geo(~state_abbr, grid = grid_pr_vi_gu(), move_axes = TRUE) +
    theme(panel.grid = element_blank(),
          panel.background = element_rect(color = text_color, fill = NA),
          strip.background = element_rect(color = text_color, fill = NA),
          axis.text = element_blank(),
          strip.text = element_text(hjust = 0.3, margin = margin(b=-1), family = font_legend)
    ) +
    scale_fill_manual(name = 'source_category', values = supply_colors) +
    theme_facet(base = 12, bkgd_color = bkgd_color, text_color = text_color)

  # national level treemap
  tm <- treemap(dtf = supply_summary, vSize = 'percent', index = c('source_category'), type = 'index')
  tm_df <- tm$tm

  tm_df_plot_national <- tm_df %>%
    # calculate end coordinates with height and width
    mutate(x1 = x0 + w,
           y1 = y0 + h) %>%
    # get center coordinates for labels
    mutate(x = (x0+x1)/2,
           y = (y0+y1)/2)


  # facet plot w/ original coordinates
  national_plot <- ggplot(tm_df_plot_national, aes(xmin = x0, ymin = y0, xmax = x1, ymax = y1)) +
    # add fill and borders for groups and subgroups
    geom_rect(aes(fill = source_category),
              show.legend = FALSE, color = text_color) +
    scale_fill_manual(name = 'source_category', values = supply_colors, drop = FALSE) +
    scale_x_discrete(expand = c(0,0)) +
    scale_y_continuous(breaks = rev(c(0, .25, .50, .75, 1.00)),
                       labels = rev(c(0, 25, 50, 75, "100%")),
                       expand = c(0,0)) +
    ggtitle('National') +
    theme_minimal() +
    theme(
      axis.title = element_blank(),
      panel.grid = element_blank(),
      axis.ticks = element_blank(),
      axis.text = element_blank(),
      legend.position = 'bottom',
      plot.title = element_text(hjust = 0.5, size = 20, family = font_legend),
      legend.title.align = 0.5,
      panel.margin = margin(0, 0, 0, 0, "pt"),
      text = element_text(family = font_legend)
    )

  plot_margin <- 0.0009

  # background
  canvas <- grid::rectGrob(
    x = 0, y = 0,
    width = width, height = height,
    gp = grid::gpar(fill = bkgd_color, alpha = 1, col = bkgd_color)
  )

  # Extract from plot
  facet_legend <- get_legend(state_facet +
                               theme(legend.position = 'left',
                                     text = element_text(size = 16, family = font_legend)) +
                               guides(
                                 fill = guide_legend(title = "Water source",
                                                     ncol = 1,
                                                     override.aes = list(linetype = 0)
                                 )))

  get_perc <- paste0(round(supply_summary$percent), "%")
  get_src <- supply_summary$source_category
  # names(get_perc) <- get_src

  # compose final plot
  facet_plot <- ggdraw(ylim = c(0,1),
                       xlim = c(0,1)) +
    # a background
    draw_grob(canvas,
              x = 0, y = 1,
              height = height, width = width,
              hjust = 0, vjust = 1) +
    # national-level plot
    draw_plot(national_plot + theme(legend.position = 'none'),
              x = 0.025,
              y = 0.3,
              height = 0.45 ,
              width = 0.32 - plot_margin * 2) +
    # state cartogram
    draw_plot(state_facet + theme(legend.position = 'none'),
              x = 0.975,
              y = 0.03,
              height = 0.96,
              width = 1 - (0.4 + plot_margin * 3),
              hjust = 1,
              vjust = 0) +
    # add legend
    draw_plot(facet_legend,
              x = 0.04,
              y = 0.13,
              height = 0.13 ,
              width = 0.3 - plot_margin) +
    draw_label(sprintf('Distribution of water sources\n for %s facilities',
                       tolower(selected_facility_type)),
               x = 0.025, y = 0.98,
               size = 38,
               hjust = 0,
               vjust = 1,
               color = text_color,
               lineheight = 1,
               fontfamily = font_legend)
  # For adding percent labels to the treemap blocks
  # +
  #   # undetermined label perc
  #   draw_label(get_perc[1],
  #              x = 0.323,
  #              y = 0.322,
  #              size = 18,
  #              color = text_color,
  #              fontfamily = font_legend
  #   ) +
  #   # both label perc
  #   draw_label(get_perc[2],
  #              x = 0.323,
  #              y = 0.378,
  #              size = 18,
  #              color = text_color,
  #              fontfamily = font_legend
  #   ) +
  #   # self supply label perc
  #   draw_label(get_perc[3],
  #              x = 0.186,
  #              y = 0.368,
  #              size = 18,
  #              color = text_color,
  #              fontfamily = font_legend
  #   ) +
  #   # public supply label perc
  #   draw_label(get_perc[4],
  #              x = 0.186,
  #              y = 0.58,
  #              size = 18,
  #              color = text_color,
  #              fontfamily = font_legend
  #   )

  outfile <- ifelse(selected_facility_type == 'All', outfile_template,
                    sprintf(outfile_template, selected_facility_type))
  ggsave(outfile, facet_plot, width = width, height = height, dpi = dpi)
  return(outfile)
}

#' @title generate individual state level facility source tree maps
#' @description generate individual state level treemap showing the distribution of facility water
#' sources
#' @param supply_summary dataframe with count of facilities by water source
#' @param supply_summary_state dataframe with count of facilities by water
#' source, by state
#' @param supply_colors vector of colors to use for water source categories
#' @param selected_facility_type type of facility to plot. If 'All', summary
#' across facility types is plotted
#' @param width width for the final plot
#' @param height height for the final plot
#' @param bkgd_color background color for the plot
#' @param text_color color for text
#' @param outfile_subfolder filepath of subfolder for saving the final state level plots
#' @param dpi dpi at which to save the final plot
#' @param font_legend font used for the plot
#' @return the filepath of the saved state level plots in the `outfile_subfolder`
generate_facility_source_treemap <- function(supply_summary, supply_summary_state,
                                             supply_colors, selected_facility_type,
                                             width, height, bkgd_color, text_color,
                                             outfile_subfolder, dpi, font_legend){

  supply_summary_state <- process_supply_state_sum(supply_summary_state = supply_summary_state,
                                                   selected_facility_type = selected_facility_type)

  supply_summary <- process_supply_sum(supply_summary = supply_summary,
                                       selected_facility_type = selected_facility_type)

  state_names_list <- unique(supply_summary_state$state_name)

  save_state_treemap <- function(state_name) {
    state_data <- supply_summary_state |>  filter(state_name == !!state_name)

    p <- ggplot(state_data, aes(area = percent, fill = source_category, label = paste0(source_category, "\n", round(percent), "%"))) +
      treemapify::geom_treemap() +
      treemapify::geom_treemap_text(color = text_color,
                        grow = F, place = "middle", reflow = T, size = 14) +
      scale_fill_manual(name = 'Water source', values = supply_colors, drop = FALSE) +
      theme_bw() +
      theme_facet(base = 12, bkgd_color = bkgd_color, text_color = text_color) +
      labs(title = paste(state_name,": Distribution of water sources for all facilities")) +
      theme(legend.position = "none",
            plot.title = element_text(margin = margin(t = 4, b = 4)),
            plot.margin = margin(15,15, 10,15))

    # Create the output directory if it doesn't exist
    output_dir <- outfile_subfolder
    if (!dir.exists(output_dir)) {
      dir.create(output_dir, recursive = TRUE)
    }

    # Save the plot as png
    output_path <- file.path(output_dir, paste0(state_name, ".png"))
    ggsave(output_path, plot = p, width = width, height = height, bg = bkgd_color)
  }

  # Iterate through each state name and create/save the plots
  purrr::map(state_names_list, save_state_treemap)

  # Return a character vector of file paths
  output_paths <- file.path(outfile_subfolder, paste0(state_names_list, ".png"))
  return(output_paths)
}

#' @title generate individual state level facility source waffle charts
#' @description generate individual state level waffle charts showing the distribution of facility water
#' sources
#' @param supply_summary dataframe with count of facilities by water source
#' @param supply_summary_state dataframe with count of facilities by water
#' source, by state
#' @param supply_colors vector of colors to use for water source categories
#' @param selected_facility_type type of facility to plot. If 'All', summary
#' across facility types is plotted
#' @param width width for the final plot
#' @param height height for the final plot
#' @param bkgd_color background color for the plot
#' @param text_color color for text
#' @param outfile_subfolder filepath of subfolder for saving the final state level plots
#' @param dpi dpi at which to save the final plot
#' @param font_legend font used for the plot
#' @return the filepath of the saved state level plots in the `outfile_subfolder`
generate_facility_source_waffle <- function(supply_summary, supply_summary_state,
                                             supply_colors, selected_facility_type,
                                             width, height, bkgd_color, text_color,
                                             outfile_subfolder, dpi, font_legend){

  supply_summary_state <- process_supply_state_sum(supply_summary_state = supply_summary_state,
                                                   selected_facility_type = selected_facility_type)

  supply_summary <- process_supply_sum(supply_summary = supply_summary,
                                       selected_facility_type = selected_facility_type)

  state_names_list <- unique(supply_summary_state$state_name)

  save_state_waffle <- function(state_name) {
    state_data <- supply_summary_state |>  filter(state_name == !!state_name)

    p <- ggplot(state_data, aes(values = ratio, fill = source_category)) +
      geom_waffle(color = "white", size = 1, n_rows = 10,
                  make_proportional = TRUE,
                  stat = "identity", na.rm = TRUE) +
      scale_fill_manual(name = 'Water source', values = supply_colors, drop = FALSE) +
      theme_bw() +
      theme_facet(base = 12, bkgd_color = bkgd_color, text_color = text_color) +
      labs(title = paste(state_name,": Distribution of water sources for all facilities")) +
      theme(legend.position = "top",
            legend.direction = "horizontal",
            legend.box = "horizontal",
            legend.margin = margin(t = 0.05, b = -0.5, unit = "cm"),
            legend.key.size = unit(0.5, "cm"),
            legend.text = element_text(size = 10),
            plot.title = element_text(margin = margin(t = 4, b = 4)),
            plot.margin = margin(15,15, 10,15))

    # Create the output directory if it doesn't exist
    output_dir <- outfile_subfolder
    if (!dir.exists(output_dir)) {
      dir.create(output_dir, recursive = TRUE)
    }

    # Save the plot as png
    output_path <- file.path(output_dir, paste0(state_name, ".png"))
    ggsave(output_path, plot = p, width = width, height = height, bg = bkgd_color)
  }

  # Iterate through each state name and create/save the plots
  purrr::map(state_names_list, save_state_waffle)

  # Return a character vector of file paths
  output_paths <- file.path(outfile_subfolder, paste0(state_names_list, ".png"))
  return(output_paths)
}

#' @title generate type summary chart
#' @description generate summary of counts of facilities by facility type
#' @param type_summary dataframe with count of facilities by type
#' @param colors vector of colors to use for facility types
#' @param title_text_size font size for plot title
#' @param axis_text_size font size for plot axes
#' @param bkgd_color background color for the plot
#' @param width width for the final plot
#' @param height height for the final plot
#' @param outfile filepath for saving the final plot
#' @param dpi dpi at which to save the final plot
#' @return the filepath of the saved plot
generate_type_summary_chart <- function(type_summary, colors, title_text_size,
                                        axis_text_size, bkgd_color,
                                        width, height, outfile, dpi) {

  type_summmary_plot <- type_summary %>% ggplot() +
    geom_bar(aes(x = WB_TYPE, y = site_count, fill = WB_TYPE), stat = 'identity') +
    geom_text(aes(WB_TYPE, site_count + 800, label = comma(site_count), fill = NULL),
              data = type_summary, size = axis_text_size/2.6) +
    scale_fill_manual(name = 'WB_TYPE', values = colors) +
    scale_x_discrete(labels = function(x) str_wrap(x, width = 6), expand = c(0,0)) +
    ylim(0, 20000) +
    scale_y_continuous(label = comma,
                       breaks = rev(c(0, 5000, 10000, 15000, 20000))) +
    theme_minimal() +
    theme(
      axis.title = element_blank(),
      panel.grid = element_blank(),
      panel.grid.major.y = element_line(color = "lightgrey", size = 0.5),
      axis.ticks.y = element_line(color = "lightgrey", size = 0.5),
      legend.position = 'none',
      plot.title = element_text(hjust = 0.5, size = title_text_size,
                                margin = margin(0,0,15,0)),
      axis.text = element_text(size = axis_text_size),
      legend.title.align = 0.5,
      plot.background = element_rect(fill = bkgd_color, color = NA)
    ) +
    ggtitle('Count of facilities by type, nationally')

  ggsave(outfile, type_summmary_plot, width = width, height = height, dpi = dpi)
  return(outfile)
}

#' @title generate suppy summary
#' @description generate summary of water supply by facility type
#' @param supply_summary dataframe with count of facilities by water source
#' @param supply_colors vector of colors to use for water source categories
#' @param title_text_size font size for plot title
#' @param axis_text_size font size for plot axes
#' @param legend_text_size font size for plot legend
#' @param bkgd_color background color for the plot
#' @param width width for the final plot
#' @param height height for the final plot
#' @param outfile filepath for saving the final plot
#' @param dpi dpi at which to save the final plot
#' @return the filepath of the saved plot
generate_supply_summary <- function(supply_summary, supply_colors, title_text_size,
                        axis_text_size, legend_text_size, bkgd_color, width,
                        height, outfile, dpi) {
  supply_plot <- supply_summary %>% ggplot() +
    geom_bar(aes(x = WB_TYPE, y = site_count, fill = source_category),
             stat = "identity") +
    scale_x_discrete(labels = function(x) str_wrap(x, width = 6),
                     expand = c(0,0)) +
    scale_fill_manual(name = 'source_category', values = supply_colors) +
    scale_y_continuous(labels = unit_format(unit = "k", scale = 1e-3)) +
    theme_minimal() +
    ylab(label = 'Number of facilities') +
    theme(
      axis.title.y = element_text(size = title_text_size),
      axis.title.x = element_blank(),
      panel.grid = element_blank(),
      panel.grid.major.y = element_line(color = "lightgrey", size = 0.5),
      axis.ticks.y = element_line(color = "lightgrey", size = 0.5),
      legend.position = 'bottom',
      plot.title = element_text(hjust = 0.5, size = title_text_size,
                                margin = margin(0,0,15,0)),
      axis.text = element_text(size = axis_text_size, color = 'black'),
      legend.title.align = 0.5,
      legend.text = element_text(size = legend_text_size),
      legend.title = element_text(size = legend_text_size),
      plot.background = element_rect(fill = bkgd_color, color = NA)
    ) +
    ggtitle('Source of water by facility type, nationally')+
    guides(
      fill = guide_legend(title = "Water source", nrow = 2, reverse = TRUE)
    )

  ggsave(outfile, supply_plot, width = width, height = height, dpi = dpi)
  return(outfile)
}

#' @title generate supply summary percent
#' @description generate summary of water supply by facility type, as a stacked
#' bar chart showing the percent of water derived from the various water sources
#' for each facility type
#' @param supply_summary dataframe with count of facilities by water source
#' @param supply_colors vector of colors to use for water source categories
#' @param title_text_size font size for plot title
#' @param axis_text_size font size for plot axes
#' @param legend_text_size font size for plot legend
#' @param bkgd_color background color for the plot
#' @param width width for the final plot
#' @param height height for the final plot
#' @param outfile filepath for saving the final plot
#' @param dpi dpi at which to save the final plot
#' @return the filepath of the saved plot
generate_supply_summary_percent <- function(supply_summary, supply_colors,
                                            title_text_size, axis_text_size,
                                            legend_text_size, bkgd_color, width,
                                            height, outfile, dpi) {
  supply_plot_percent <- supply_summary %>% ggplot() +
    geom_bar(aes(x = WB_TYPE, y = site_count, fill = source_category),
             stat = "identity", position = "fill") +
    scale_x_discrete(labels = function(x) str_wrap(x, width = 6),
                     expand = c(0,0)) +
    scale_y_continuous(breaks = rev(c(0, 0.25, 0.50, 0.75, 1)),
                       labels = rev(c(0, 25, 50, 75, "100%")),
                       expand = c(0,0)) +
    scale_fill_manual(name = 'source_category', values = supply_colors) +
    theme_minimal() +
    theme(
      axis.title = element_blank(),
      panel.grid = element_blank(),
      axis.ticks.y = element_line(color = "lightgrey", size = 0.5),
      legend.position = 'bottom',
      plot.title = element_text(hjust = 0.5, size = title_text_size,
                                margin = margin(0, 0, 15, 0)),
      axis.text =  element_text(size = axis_text_size),
      legend.title.align = 0.5,
      legend.text = element_text(size = legend_text_size),
      legend.title = element_text(size = legend_text_size),
      plot.background = element_rect(fill = bkgd_color, color = NA)
    ) +
    ggtitle('Source of water by facility type, nationally') +
    guides(
      fill = guide_legend(title = "Water source", nrow = 2, reverse = TRUE)
    )

  ggsave(outfile, supply_plot_percent, width = width, height = height, dpi = dpi)
  return(outfile)
}

#' @title combine two images
#' @description combine two images into a single plot
#' @param image_1_file filepath for the first image
#' @param image_2_file filepath for the second image
#' @param image_1_title title for the first image
#' @param image_2_title title for the second image
#' @param width width for the final plot
#' @param height height for the final plot
#' @param bkgd_color background color for the plot
#' @return a plot object with the two plot images arranged side by side
combine_two_images <- function(image_1_file, image_2_file, image_1_title,
                               image_2_title, width, height, bkgd_color) {
  image_1 <- magick::image_read(image_1_file)
  image_2 <- magick::image_read(image_2_file)

  canvas <- grid::rectGrob(
    x = 0, y = 0,
    width = width, height = height,
    gp = grid::gpar(fill = bkgd_color, alpha = 1, col = bkgd_color)
  )

  plot <- ggdraw(ylim = c(0,1),
                 xlim = c(0,1)) +
    # a background
    draw_grob(canvas,
              x = 0, y = 1,
              height = height, width = width,
              hjust = 0, vjust = 1) +
    draw_image(image_1,
               x = -0.05,
               y = 0.05,
               width = 0.54,
               hjust = 0, vjust = 0,
               halign = 0, valign = 0) +
    draw_image(image_2,
               x = 0.48,
               y = 0.05,
               width = 0.54,
               hjust = 0, vjust = 0,
               halign = 0, valign = 0) +
    draw_label(image_1_title,
               x = 0.25,
               y = 0.8,
               hjust = 0.5) +
    draw_label(image_2_title,
               x = 0.75,
               y = 0.8,
               hjust = 0.5)

  return(plot)
}

#' @title generate source summary bar chart
#' @description generate a bar chart showing the distribution of water sources
#' (as a percentage of total) for facilities of `selected_facility_type` in
#' each state
#' @param supply_summary_state dataframe with count of facilities by water
#' source, by state
#' @param supply_colors vector of colors to use for water source categories
#' @param selected_facility_type type of facility to plot. If 'All', summary
#' across facility types is plotted
#' @param title_text_size font size for plot title
#' @param legend_text_size font size for plot legend
#' @param axis_text_size font size for plot axes
#' @param width width for the final plot
#' @param height height for the final plot
#' @param bkgd_color background color for the plot
#' @param text_color color for text
#' @param outfile_template filepath template for saving the final plot
#' @param dpi dpi at which to save the final plot
#' @return the filepath of the saved plot
generate_source_summary_bar_chart <- function(supply_summary_state, supply_colors,
                                              selected_facility_type,
                                              title_text_size, axis_text_size,
                                              legend_text_size, width, height,
                                              bkgd_color, text_color,
                                              outfile_template, dpi) {

  bottled_water_summary <- supply_summary_state %>%
    filter(WB_TYPE == selected_facility_type) %>%
    arrange(state_name) %>%
    group_by(state_name) %>%
    mutate(percent = site_count/sum(site_count)*100)

  states <- unique(bottled_water_summary$state_abbr)

  supply_ranking <- bottled_water_summary %>%
    filter(source_category == 'public supply') %>%
    arrange(desc(percent)) %>%
    pull(state_abbr)

  supply_ranking <- c(supply_ranking, states[!(states %in% supply_ranking)])

  bottled_water_summary <- bottled_water_summary %>%
    mutate(state_abbr = factor(state_abbr, levels = supply_ranking))

  ggplot(bottled_water_summary, aes(state_abbr, y = percent)) +
    geom_bar(aes(fill = source_category), stat = 'identity') +
    scale_fill_manual(name = 'source_category', values = supply_colors) +
    scale_y_continuous(breaks = rev(c(0, 25, 50, 75, 100)),
                       labels = rev(c("0%", "25%", "50%","75%", "100%")),
                       expand = c(0,0)) +
    theme_minimal() +
    theme(
      axis.title = element_blank(),
      plot.title = element_text(hjust = 0.5, size = title_text_size,
                                color = text_color, margin = margin(0,0,15,0)),
      axis.text.x = element_text(size = axis_text_size, color = text_color),
      axis.text.y = element_text(size = legend_text_size, color = text_color),
      panel.grid.major.y = element_blank(),
      axis.ticks.y = element_line(color = "grey60", size = 0.5),
      legend.position = 'bottom',
      legend.text = element_text(size = legend_text_size, color = text_color),
      legend.title = element_text(size = legend_text_size, color = text_color)) +
    guides(fill = guide_legend(title = 'Source category', reverse = TRUE)) +
    ggtitle(sprintf('Distribution of Water Sources by State for %s Facilities',
                    selected_facility_type))

  outfile <- sprintf(outfile_template, selected_facility_type)

  ggsave(outfile, width = width, height = height, dpi = dpi, bg = bkgd_color)
}
