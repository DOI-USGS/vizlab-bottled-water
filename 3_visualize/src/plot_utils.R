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
              height = 1-plot_margin*2 ,
              width = 1-plot_margin*2)
  
  ggsave(outfile, width = width, height = height, dpi = 300) #, bg = "transparent", limitsize = FALSE)
  return(outfile)
}

#' @title 
#' @description 
#' @param 
#' @param 
#' @return 
map_region_streams_sites <- function(region, region_streams, region_facilities, site_colors) {
  region <- region[[1]]
  
  region_streams <- region_streams %>%
    filter(!(is.na(Strahler)), !(Strahler == -999))
  
  orig_levels <- unique(region_streams$Strahler)
  if (length(levels) > 3) {
    region_streams <- filter(region_streams, Strahler >= max(orig_levels) - 3)
  }
  
  region_streams_joined <- region_streams %>%
    st_transform(crs = st_crs(region)) %>%
    group_by(Name, Strahler) %>%
    group_modify(~ {
      if (nrow(.x) > 1 & 'MULTILINESTRING' %in% st_geometry_type(.x)) {
        merged <- .x$Shape %>%  
          st_union() %>%
          st_line_merge() %>%
          st_as_sf()%>%
          rename(geometry = x)
      } else if (nrow(.x) > 1) {
        merged <- .x$Shape %>%  
          st_union() %>%
          st_as_sf()%>%
          rename(geometry = x)
      } else {
        merged <- dplyr::select(.x, geometry = Shape)
      }
      return(merged)
    }) 

  max_level <- max(region_streams_joined$Strahler)
  region_streams_joined <- region_streams_joined %>%
    mutate(width = case_when(
      Strahler == max_level ~ 1.5,
      Strahler == max_level - 1 ~ 1,
      Strahler == max_level - 2 ~ 0.8,
      TRUE ~ 0.5
    ))

  region_facilities <- st_transform(region_facilities, crs = st_crs(region))

  ggplot() +
    geom_sf(data = region, fill='white', color='grey80') +
    geom_sf(data = region_streams_joined, aes(size = width, geometry=geometry), color = 'lightblue') +
    scale_size_identity("Strahler") +
    geom_sf(data = region_facilities, aes(fill = WB_TYPE), color="white", pch=21, size=2, stroke = 0.5) +
    scale_fill_manual(name = 'WB_TYPE', values = site_colors) +
    theme_void() +
    ggtitle(region$region)
}

#' @title 
#' @description 
#' @param 
#' @param 
#' @return 
map_data_on_us <- function(states, plot_in, state_fill, state_color, state_size, simplify=TRUE, simplification_keep=NA, legend=TRUE) {
  
  if (simplify) {
    if (is.na(simplification_keep)) message('Using default of 0.05 for proportion of points to retain')
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

#' @title 
#' @description 
#' @param 
#' @param 
#' @return 
map_regions <- function(regions, region_info, states, state_fill, state_color, state_size, simplify=TRUE, simplification_keep=0.5) {
  
  regions <- regions %>% 
    left_join(region_info, by = 'region')
  
  region_plot <- geom_sf(data = regions,
                         aes(fill = region,
                             color = region),
                         alpha = 0.5,
                         lwd = 0.1) 
    
    
  
  regions_on_conus <- map_data_on_us(states, plot_in = region_plot, state_fill, state_color, state_size, simplify=simplify, simplification_keep=simplification_keep, legend=TRUE)
  
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
    geom_sf(data = ca_inset_area, fill=NA, color='grey20', size=0.25) +
    geom_text_repel(data = regions, aes(label = stringr::str_wrap(full_name, 30), 
                                        fill = NA, color = region, geometry = geometry), 
                    nudge_x = x_offsets, nudge_y = y_offsets,
                    min.segment.length = 15, stat = "sf_coordinates",
                    size = 6, hjust = 0) +
    theme(legend.position = "none")
  
  ca_region_map <- ggplot() +
    geom_sf(data = ca_inset_area, fill='white', color='grey20', size=0.5) +
    geom_sf(data = filter(regions, region=='california'), aes(fill = region, color = region)) +
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

#' @title 
#' @description 
#' @param 
#' @param 
#' @return 
map_sites <- function(sites, states, site_size, fill_by_type, site_fill_colors, site_color, site_alpha, 
                      site_pch, site_stroke, state_fill, state_color, state_size, simplify=TRUE, simplification_keep=NA,
                      legend_position, legend_title_size, legend_text_size) {
  
  if (fill_by_type) {
    site_plot <- geom_sf(data = sites,
                         aes(fill = WB_TYPE),
                         color = site_color,
                         pch = site_pch,
                         size = site_size,
                         stroke = site_stroke,
                         alpha= site_alpha)
  } else {
    site_plot <- geom_sf(data = sites,
                         aes(fill = facility_category,
                             color = facility_category),
                         pch = site_pch,
                         size = site_size,
                         stroke = site_stroke,
                         alpha= site_alpha) 
  }

  final_plot <- map_data_on_us(states, plot_in = site_plot, state_fill, state_color, state_size, simplify=simplify, simplification_keep=simplification_keep, legend=TRUE)
  
  if (fill_by_type) {
    final_plot <- final_plot +
      scale_fill_manual(name='WB_TYPE', values = site_fill_colors) +
      theme(legend.position = legend_position,
            legend.title = element_text(size=legend_title_size),
            legend.text = element_text(size=legend_text_size)) +
      guides(
        fill = guide_legend(title="Facility type"),
        color = 'none'
      )
  } else {
    final_plot <- final_plot + 
      scale_fill_manual(name='Bottling facility', breaks=c('Bottling facility'),values=c(site_fill_colors)) +
      scale_color_manual(name='Bottling facility', breaks=c('Bottling facility'),values=c(site_color)) +
      theme(legend.position = legend_position,
            legend.title = element_text(size=legend_title_size),
            legend.text = element_text(size=legend_text_size)) +
      guides(
        fill = guide_legend(title=element_blank()),
        color = 'none'
      )
  }
      
  return(final_plot)
}

#' @title 
#' @description 
#' @param 
#' @param 
#' @return
map_wateruse_sites <- function(map_of_all_sites, site_size, site_fill_colors, site_color, site_pch, site_stroke, wu_sites, 
                               wu_site_size, wu_site_fill_colors, wu_site_color, wu_site_alpha, wu_site_pch, wu_site_stroke,
                               legend_position, legend_title_size, legend_text_size) {
  
  map <- map_of_all_sites +  
    geom_sf(data = wu_sites, 
            aes(fill = WUDataFlag,
                color = WUDataFlag),
            pch = wu_site_pch,
            size = wu_site_size,
            stroke = wu_site_stroke,
            alpha= wu_site_alpha) + 
    theme_void() +
    scale_fill_manual(name=c('Bottling facility', unique(wu_sites$WUDataFlag)), breaks = c('Bottling facility', unique(wu_sites$WUDataFlag)), 
                      values = c(site_fill_colors, wu_site_fill_colors), labels=c('Bottling facility', 'Has water use data')) +
    scale_color_manual(name=c('Bottling facility', unique(wu_sites$WUDataFlag)), breaks = c('Bottling facility', unique(wu_sites$WUDataFlag)),
                      values = c(site_color, wu_site_color), labels=c('Bottling facility', 'Has water use data')) +
    theme(legend.position = legend_position,
          legend.title=element_text(size=legend_title_size),
          legend.text=element_text(size=legend_text_size)) +
    guides(
      fill = guide_legend(title=element_blank(), override.aes = list(pch = c(site_pch, wu_site_pch), 
                                                                     fill = c(site_fill_colors, wu_site_fill_colors),
                                                                     color = c(site_color, wu_site_color),
                                                                     stroke = c(site_stroke, wu_site_stroke),
                                                                     size = c(site_size, wu_site_size))),
      color = "none"
    )
  
  
  # fill = c(site_fill_colors,wu_site_fill_colors),
  
  return(map)
}

#' @title 
#' @description 
#' @param 
#' @param 
#' @return 
calcPropRadius <- function(value, minimum_value, min_radius) {
  #Flannery appearance compensation formula
  radius <- 1.0083 * ((value/minimum_value)^0.5715) * min_radius
  
  #return the computed radius
  return(radius)
};

#' @title 
#' @description 
#' @param 
#' @param 
#' @return 
map_site_counts <- function(site_summary, states, conus=TRUE, site_color, min_radius, palette, palette_dir, 
                            state_fill, state_color, state_size, simplify=TRUE, simplification_keep=NA,
                            width, height, bkgd_color) {
  # browser()
  
  if (conus) {
    site_summary <- filter(site_summary, (state_name %in% state.name) & !(state_abbr %in% c('AK','HI')))
  }
  
  site_summary <- site_summary %>%
    mutate(size_adj = calcPropRadius(site_count, min(site_summary$site_count), min_radius = min_radius))
  
  states <- states %>%
    left_join(site_summary, by=c("NAME"='state_name'))
  
  site_plot <- geom_sf(data = states,
                       aes(size = size_adj,
                           fill = size_adj,
                           geometry = geometry_point),
                       pch = 21,
                       color = site_color)
  
  final_plot <- map_data_on_us(states, plot_in = site_plot, state_fill, state_color, state_size, simplify=simplify, simplification_keep=simplification_keep, legend=TRUE) +
    scico::scale_fill_scico(palette = palette, begin = 0, end = 1, direction = palette_dir)
  
  
  # # need to make custom sized and colored circles
  # legend_circles <- data.frame(
  #   x0 = c(1, 1, 1),
  #   r = c(4, 2, 1))
  # # ggplot() + ggforce::stat_circle(data= circles, aes(x0 = x0, y0 = r, r = r, fill="r"), color = 'white', size =1 ) + coord_fixed() + theme_void()
  # 
  # canvas <- grid::rectGrob(
  #   x = 0, y = 0, 
  #   width = width, height = height,
  #   gp = grid::gpar(fill = bkgd_color, alpha = 1, col = bkgd_color)
  # )
  # 
  # plot <- ggdraw(ylim = c(0,1), 
  #                xlim = c(0,1)) +
  #   # a background
  #   draw_grob(canvas,
  #             x = 0, y = 1,
  #             height = height, width = width,
  #             hjust = 0, vjust = 1) +
  #   draw_image(final_plot, 
  #              x = -0.05, 
  #              y = 0.05, 
  #              width = 0.8, 
  #              hjust = 0, vjust = 0, 
  #              halign = 0, valign = 0) +
  #   draw_image(legend,
  #              x = 0.8,
  #              y = 0.05,
  #              hjust = 0, vjust = 0,
  #              halign = 0, valign = 0)
  
  return(final_plot)
}

map_county_counts_total <- function(county_counts, states, outfile) {
  
  total_count_data <- county_counts %>%
    filter(WB_TYPE=='All') %>%
    arrange(site_count)
  
  total_count <- ggplot() +
    geom_sf(data = county_counts,
            fill='grey95', color='grey80', size=0.1) +
    geom_sf(data = states,
            fill = NA,
            color = 'white',
            size = 0.6) +
    geom_sf(data = total_count_data,
            aes(size = site_count,
                geometry = geometry_point),
            pch = 21,
            fill = 'orange',
            color = 'grey95') +
    scale_size(limits = c(min(total_count_data$site_count), max(total_count_data$site_count)), 
               range = c(1,10), breaks = c(50, 100, 500, 1000), 
               labels = c(50, 100, 500, 1000),
               name = stringr::str_wrap("Count of bottling facilities", 25)) +
    theme_void()
  
  ggsave(outfile, total_count, width = 16, height = 9, dpi = 300, bg = 'white')
  
  return(outfile)
}

map_county_counts_type <- function(county_counts, states, min_count, max_count, type, site_colors, outfile_template) {
  
  count_data <- county_counts %>%
    filter(WB_TYPE==type) %>%
    arrange(site_count)
  
  type_plot <- ggplot() +
    geom_sf(data = county_counts %>%
              dplyr::select(geometry),
            fill='grey95', color='grey80', size=0.1) +
    geom_sf(data = states,
            fill = NA,
            color = 'white',
            size = 0.6) +
    geom_sf(data = count_data,
            aes(size = site_count,
                geometry = geometry_point),
            fill = site_colors[type],
            pch = 21,
            color = 'grey95') +
    scale_size(limits = c(min_count, max_count), 
               range = c(1,10), breaks = c(50, 250, 500, 750), 
               labels = c(50, 250, 500, 750),
               name = stringr::str_wrap(sprintf("Count of %s bottling facilities", type), 25)) +
    theme_void()
  
  outfile <- sprintf(outfile_template, type)
  ggsave(outfile, type_plot, width = 16, height = 9, dpi = 300, bg = 'white')
  
  return(outfile)
}

#' @title 
#' @description 
#' @param 
#' @param 
#' @return 
combine_small_multiples <- function(plots, plot_types, title_font_size, legend_font_size, plot_title_font_size, text_color, point_layer, point_size) {
  # browser()
  # import fonts
  font_legend <- 'Source Sans Pro'
  font_add_google(font_legend)
  showtext_opts(dpi = 300, regular.wt = 200, bold.wt = 700)
  showtext_auto(enable = TRUE)
  
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
            text = element_text(family = font_legend, color = text_color, size=legend_font_size)) + 
      guides(
        fill=guide_legend(title="Facility type", nrow=1)
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
    plot <- modify_size(plot, layer=point_layer, size=point_size)
    mod_plot <- draw_plot(
      plot + 
        ggtitle(plot_types[i]) +
        theme(legend.position = 'none',
              plot.title = element_text(hjust = 0.5),
              text = element_text(family = font_legend, color = text_color, size=plot_title_font_size)),
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

#' @title 
#' @description 
#' @param 
#' @param 
#' @return 
modify_size <- function(plot, layer, size) {
  plot$layers[[layer]]$aes_params$size <-  size
  return(plot)
}

#' @title 
#' @description 
#' @param 
#' @param 
#' @return 
combine_conus_maps <- function(map1, map2, title1, title2, width, height, text_color, title_font_size, legend_font_size, plot_title_font_size) {
  font_legend <- 'Source Sans Pro'
  font_add_google(font_legend)
  showtext_opts(dpi = 300, regular.wt = 200, bold.wt = 700)
  showtext_auto(enable = TRUE)
  
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
            text = element_text(family = font_legend, color = text_color, size=legend_font_size)) + 
      guides(
        fill=guide_legend(title="Facility type", nrow=1)
      ))
  
  # browser()
  
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
                      text = element_text(family = font_legend, color = text_color, size=plot_title_font_size)),
              x = 0,
              y = 0,
              height = 0.8,
              width = (1 - plot_margin*2) / 2) +
    draw_plot(map2 + 
                ggtitle(title2) +
                theme(legend.position = 'none',
                      plot.title = element_text(hjust = 0.5),
                      text = element_text(family = font_legend, color = text_color, size=plot_title_font_size)),
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

#' @title 
#' @description 
#' @param 
#' @param 
#' @return
combine_into_national_map <- function(maps, spatial_data, groups, width, height, text_color, 
                          title_font_size, legend_font_size) {
  
  font_legend <- 'Source Sans Pro'
  font_add_google(font_legend)
  showtext_opts(dpi = 300, regular.wt = 200, bold.wt = 700)
  showtext_auto(enable = TRUE)
  
  plot_margin <- 0.005
  
  # background
  canvas <- grid::rectGrob(
    x = 0, y = 0, 
    width = width, height = height,
    gp = grid::gpar(fill = '#ffffff', alpha = 1, col = 'white')
  )
  
  # browser()
  conus_index <- which(groups$name == 'CONUS')
  conus_bbox <- sf::st_bbox(spatial_data[[conus_index]])
  conus_x_extent <- conus_bbox$xmax - conus_bbox$xmin
  conus_y_extent <- conus_bbox$ymax - conus_bbox$ymin
  conus_width <- 0.6
  
  spatial_extents <- purrr::map2_df(spatial_data, groups$name, function(spatial_area, name) {
    bbox <- sf::st_bbox(spatial_area)
    extent_df <- tibble(
      name = name,
      x_extent = bbox$xmax - bbox$xmin,
      y_extent = bbox$ymax - bbox$ymin
    )
    return(extent_df)
  }) %>%
    mutate(
      x = case_when(
        name == 'CONUS' ~ 0.2,
        name == 'Alaska' ~ -0.01,
        name == 'Hawaii' ~ 0.05,
        name == 'Puerto Rico' ~ 0.8,
        name == 'U.S. Virgin Islands' ~ 0.9,
        name == 'Guam' ~ 0.05
      ),
      y = case_when(
        name == 'CONUS' ~ -0.2,
        name == 'Alaska' ~ 0.3,
        name == 'Hawaii' ~ -0.3,
        name == 'Puerto Rico' ~ -0.4,
        name == 'U.S. Virgin Islands' ~ -0.45,
        name == 'Guam' ~ -0.45
      ),
      width = conus_width * (x_extent/conus_x_extent),
      text_x = case_when(
        name == 'CONUS' ~ -0.5,
        name == 'Alaska' ~ x + width/2 - 0.1,
        name == 'Hawaii' ~ x + width/2 - 0.05,
        TRUE ~ x + width/2
      ),
      text_y = case_when(
        name == 'CONUS' ~ -0.5,
        name == 'Hawaii' ~ y + 0.5,
        TRUE ~ y + 0.5 + 0.025
      ))
  
  final_plot <-  ggdraw(ylim = c(0,1), 
                        xlim = c(0,1)) +
    # a background
    draw_grob(canvas,
              x = 0, y = 1,
              height = 9, width = 16,
              hjust = 0, vjust = 1) +
    purrr::map2(maps, spatial_extents$name, function(map, group_name) {
      placement <- filter(spatial_extents, name == group_name)
      plot <- draw_plot(map,
                        x = placement$x,
                        y = placement$y,
                        width = placement$width)
      return(plot)
    }) +
    purrr::map2(maps, spatial_extents$name, function(map, group_name) {
      placement <- filter(spatial_extents, name == group_name)
      label <- draw_label(group_name,
                   x = placement$text_x, 
                   y = placement$text_y, 
                   hjust = 0.5,
                   vjust = 0.5,
                   size = 6, 
                   fontfamily = font_legend,
                   color = text_color)
      return(label)
    })
  
  return(final_plot)
}

#' @title 
#' @description 
#' @param 
#' @param 
#' @return
chart_wateruse_availability <- function(sites, has_wu_color, no_wu_color) {
  wu_summary <- sites %>%
    group_by(WUDataFlag, facility_category) %>% 
    summarize(count = n(), percent = count/nrow(sites)) %>%
    mutate(type = ifelse(is.na(WUDataFlag), 'No water use data', 'Has water use data')) 
  max_per <- max(wu_summary$percent)
  min_per <- min(wu_summary$percent)
  wu_summary_plot <- wu_summary %>%
    ggplot() +
    geom_bar(aes(x=facility_category, y=count, fill=WUDataFlag), stat='identity', position="fill") +
    scale_fill_manual(name = 'WUDataFlag', values = has_wu_color, na.value = no_wu_color) +
    theme_void() +
    scale_y_continuous(position = 'right',
                       breaks = rev(c(max_per/2, max_per + min_per/2)),
                       labels = rev(c(sprintf('%s%% do not have water use data', round(max_per*100, 1)), 
                                      sprintf("%s%% have water use data", round(min_per*100,1)))),
                       expand = c(0,0)) +
    scale_x_discrete(expand = c(0,0)) +
    theme(
      axis.title = element_blank(),
      axis.text.y = element_text(size = 20, hjust = 0, margin=margin(0,0,0,5)),
      axis.text.x =element_blank(),
      legend.position = 'none',
      plot.title = element_text(hjust = 0, size=24, margin=margin(0,0,15,0))
    ) +
    ggtitle('Bottling facilities')
  return(wu_summary_plot)
}

#' @title 
#' @description 
#' @param 
#' @param 
#' @return
combine_wu_map_and_chart <- function(wu_map, wu_chart, width, height) {
  # browser()
  font_legend <- 'Source Sans Pro'
  font_add_google(font_legend)
  showtext_opts(dpi = 300, regular.wt = 200, bold.wt = 700)
  showtext_auto(enable = TRUE)
  
  plot_margin <- 0.005
  
  # background
  canvas <- grid::rectGrob(
    x = 0, y = 0, 
    width = width, height = height,
    gp = grid::gpar(fill = '#ffffff', alpha = 1, col = 'white')
  )
  # browser()
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

#' @title 
#' @description 
#' @param 
#' @param 
#' @return
annotate_shifted_map <- function(shifted_map, text_color, plot_title_font_size, width, height) {
  font_legend <- 'Source Sans Pro'
  font_add_google(font_legend)
  showtext_opts(dpi = 300, regular.wt = 200, bold.wt = 700)
  showtext_auto(enable = TRUE)
  
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

#' @title 
#' @description 
#' @param 
#' @param 
#' @return
generate_site_count_matrix <- function(type_summary, type_summary_state, state_summary,
                                       palette, palette_dir, bar_fill, width, height, outfile, dpi) {
  # main matrix
  state_matrix <- type_summary_state %>% 
    arrange(state_name) %>%
    ggplot(aes(x=reorder(state_abbr, state_abbr), y=WB_TYPE)) +
    geom_tile(aes(fill=site_count), color='white', width=1, height=1) +
    theme_minimal() +
    scico::scale_fill_scico(palette = palette, begin = 0, end = 1, direction = palette_dir) +
    scale_x_discrete(position = 'top') +
    scale_y_discrete(labels = function(x) str_wrap(x, width = 10)) +
    theme(
      axis.title = element_blank(),
      legend.position = 'top',
      axis.text = element_text(size=10),
      legend.title.align = 0.5,
      legend.background = element_rect(fill='#ffffff', color=NA)
    ) +
    guides(fill=guide_colourbar(title="Facility count", title.position = "top"))
  
  # bottom bar chart
  type_totals <- type_summary %>%
    ggplot(aes(x = site_count, y=WB_TYPE)) +
    geom_bar(stat='identity', fill=bar_fill, color='#ffffff', width=1) +
    scale_x_continuous(position = 'top',
                       breaks = c(0, 5000, 10000, 15000, 20000),
                       labels = c(0, "5k", "10k", "15k", "20k sites")) + 
    theme_minimal() +
    theme(
      panel.grid = element_blank(),
      panel.grid.major.x = element_line(color = 'grey90', size=0.5),
      axis.text.y = element_blank(),
      axis.title = element_blank(),
      axis.text.x=element_text(size=10))
  
  # right-hand bar chart
  state_totals <- state_summary %>%
    ggplot(aes(x = reorder(state_abbr, state_abbr), y=site_count)) +
    geom_bar(fill=bar_fill, color='white', stat='identity', width=1) +
    scale_x_discrete(position = 'top') +
    scale_y_continuous(trans = "reverse",
                       breaks = rev(c(0, 1000, 2000, 3000, 4000, 5000, 6000)), 
                       labels = rev(c("0 sites", "1k", "2k", "3k", "4k", "5k", "6k"))) + 
    theme_minimal() +
    theme(
      panel.grid = element_blank(),
      axis.title = element_blank(),
      panel.grid.major.y = element_line(color = 'grey90', size=0.5), 
      axis.text=element_text(size=10)
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
  top_row <- plot_grid(plots[[1]], right_plot, ncol = 2, align = 'h', axis = 'tb', rel_widths = c(1, 0.15))
  bottom_row <- plot_grid(plots[[2]], NULL, ncol = 2, align = 'h', axis = 'tb', rel_widths = c(1, 0.15))
  all <- plot_grid(top_row, bottom_row, ncol = 1, axis = 'lb', rel_heights = c(1, 0.5))
  
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
  
  ggsave(outfile, final_plot, width = width, height = height, dpi=dpi)
  return(outfile)
}

#' @title 
#' @description 
#' @param 
#' @param 
#' @return
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

#' @title 
#' @description 
#' @param 
#' @param 
#' @return
generate_facility_type_facet_map <- function(type_summary, type_summary_state, colors, width, height,
                                 bkgd_color, text_color, outfile, dpi) {

  grid <- geofacet::us_state_grid1 %>% 
    add_row(row = 7, col = 10, code = "PR", name = "Puerto Rico") %>% # add PR
    add_row(row = 7, col = 11, code = "VI", name = "U.S. Virgin Islands") %>% # add VI
    add_row(row = 6, col = 1, code = "GU", name = "Guam") # add GU
  
  state_cartogram <- type_summary_state %>% 
    arrange(state_name) %>% 
    group_by(state_name) %>%
    mutate(percent = site_count/sum(site_count)*100) %>%
    ggplot(aes(1, y = percent)) +
    geom_bar(aes(fill = WB_TYPE), stat='identity') +
    scale_fill_manual(name = 'WB_TYPE', values = colors) +
    theme_bw() +
    theme_facet(base = 12, bkgd_color = bkgd_color, text_color = text_color) +
    geofacet::facet_geo(~ state_abbr, grid = grid, move_axes = TRUE)
  
  national_plot <- type_summary %>% 
    mutate(percent = site_count/sum(site_count)*100) %>%
    ggplot(aes(1, y = percent)) +
    geom_bar(aes(fill = WB_TYPE), stat='identity') +
    scale_fill_manual(name = 'WB_TYPE', values=colors) +
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
      plot.title = element_text(hjust = 0.5, size=20),
      axis.text.y = element_text(size=14),
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
                                     text = element_text(size=16)) + 
                               guides(
                                 fill = guide_legend(title="Facility type", ncol=3)
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

generate_facility_source_facet_map <- function(supply_summary, supply_summary_state, supply_colors, selected_facility_type, 
                                               width, height,bkgd_color, text_color, outfile_template, dpi) {
  
  if (!(selected_facility_type == 'All')) {
    supply_summary_state <- supply_summary_state %>% 
      filter(WB_TYPE == selected_facility_type) %>%
      arrange(state_name) %>% 
      group_by(state_name, state_abbr) %>%
      mutate(percent = site_count/sum(site_count)*100)
    supply_summary <- supply_summary %>% 
      filter(WB_TYPE == selected_facility_type) %>%
      mutate(percent = site_count/sum(site_count)*100) 
  } else {
    supply_summary_state <- supply_summary_state %>% 
      arrange(state_name) %>% 
      group_by(state_name, state_abbr, source_category) %>%
      summarize(site_count = sum(site_count)) %>%
      group_by(state_name, state_abbr) %>%
      mutate(percent = site_count/sum(site_count)*100)
    supply_summary <- supply_summary %>% 
      group_by(source_category) %>%
      summarize(site_count = sum(site_count)) %>%
      mutate(percent = site_count/sum(site_count)*100) 
  }
  
  grid <- geofacet::us_state_grid1 %>% 
    add_row(row = 7, col = 10, code = "PR", name = "Puerto Rico") %>% # add PR
    add_row(row = 7, col = 11, code = "VI", name = "U.S. Virgin Islands") %>% # add VI
    add_row(row = 6, col = 1, code = "GU", name = "Guam") # add GU
  
  state_cartogram <- supply_summary_state %>%
    ggplot(aes(1, y = percent)) +
    geom_bar(aes(fill = source_category), stat='identity') +
    scale_fill_manual(name = 'source_category', values = supply_colors) +
    theme_bw() +
    theme_facet(base = 12, bkgd_color = bkgd_color, text_color = text_color) +
    geofacet::facet_geo(~ state_abbr, grid = grid, move_axes = TRUE)
  
  national_plot <- supply_summary %>%
    ggplot(aes(1, y = percent)) +
    geom_bar(aes(fill = source_category), stat='identity') +
    scale_fill_manual(name = 'source_category', values=supply_colors) +
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
      plot.title = element_text(hjust = 0.5, size=20),
      axis.text.y = element_text(size=14),
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
                                     text = element_text(size=16)) + 
                               guides(
                                 fill = guide_legend(title="Water source", ncol=1, reverse = TRUE)
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
    draw_label(sprintf('Distribution of water sources for %s facilities', tolower(selected_facility_type)),
               x = 0.025, y = 0.93, 
               size = 36, 
               hjust = 0, 
               vjust = 1,
               color = 'black',
               lineheight = 1)
  
  outfile <- ifelse(selected_facility_type=='All', outfile_template, sprintf(outfile_template, selected_facility_type))
  ggsave(outfile, facet_plot, width = width, height = height, dpi = dpi)
  return(outfile)
}

#' @title 
#' @description 
#' @param 
#' @param 
#' @return
generate_type_summary_chart <- function(type_summary, colors, title_text_size, axis_text_size, bkgd_color,
                            width, height, outfile, dpi) {
  
  type_summmary_plot <- type_summary %>% ggplot() +
    geom_bar(aes(x = WB_TYPE, y = site_count, fill = WB_TYPE), stat = 'identity') +
    geom_text(aes(WB_TYPE, site_count + 800, label = comma(site_count), fill = NULL), data = type_summary, size = axis_text_size/2.6) +
    scale_fill_manual(name = 'WB_TYPE', values = colors) +
    scale_x_discrete(labels = function(x) str_wrap(x, width = 6), expand = c(0,0)) +
    ylim(0, 20000) +
    scale_y_continuous(label=comma, 
                       breaks = rev(c(0, 5000, 10000, 15000, 20000))) +
    theme_minimal() +
    theme(
      axis.title = element_blank(),
      panel.grid = element_blank(),
      panel.grid.major.y = element_line(color = "lightgrey", size = 0.5),
      axis.ticks.y = element_line(color = "lightgrey", size = 0.5),
      legend.position = 'none',
      plot.title = element_text(hjust = 0.5, size = title_text_size, margin = margin(0,0,15,0)),
      axis.text = element_text(size = axis_text_size),
      legend.title.align = 0.5,
      plot.background = element_rect(fill = bkgd_color, color = NA)
    ) +
    ggtitle('Count of facilities by type, nationally')
  
  ggsave(outfile, type_summmary_plot, width = width, height = height, dpi = dpi)
  return(outfile)
}

#' @title 
#' @description 
#' @param 
#' @param 
#' @return
generate_supply_summary <- function(supply_summary, supply_colors, title_text_size,
                        axis_text_size, legend_text_size, bkgd_color, width, height, outfile, dpi) {
  supply_plot <- supply_summary %>% ggplot() +
    geom_bar(aes(x = WB_TYPE, y = site_count, fill=source_category), stat="identity") +
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
      plot.title = element_text(hjust = 0.5, size = title_text_size, margin=margin(0,0,15,0)),
      axis.text = element_text(size = axis_text_size, color = 'black'),
      legend.title.align = 0.5,
      legend.text = element_text(size = legend_text_size),
      legend.title = element_text(size = legend_text_size),
      plot.background = element_rect(fill = bkgd_color, color = NA)
    ) +
    ggtitle('Source of water by facility type, nationally')+ 
    guides(
      fill=guide_legend(title="Water source", nrow=2)
    )
  
  ggsave(outfile, supply_plot, width = width, height = height, dpi = dpi)
  return(outfile)
}

#' @title 
#' @description 
#' @param 
#' @param 
#' @return
generate_supply_summary_percent <- function(supply_summary, supply_colors, title_text_size,
                                    axis_text_size, legend_text_size, bkgd_color, width, height, outfile, dpi) {
  supply_plot_percent <- supply_summary %>% ggplot() +
    geom_bar(aes(x = WB_TYPE, y = site_count, fill = source_category), stat="identity", position="fill") +
    scale_x_discrete(labels = function(x) str_wrap(x, width = 6), expand = c(0,0)) +
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
      plot.title = element_text(hjust = 0.5, size = title_text_size, margin = margin(0, 0, 15, 0)),
      axis.text =  element_text(size = axis_text_size),
      legend.title.align = 0.5,
      legend.text = element_text(size = legend_text_size),
      legend.title = element_text(size = legend_text_size),
      plot.background = element_rect(fill = bkgd_color, color = NA)
    ) +
    ggtitle('Source of water by facility type, nationally') + 
    guides(
      fill=guide_legend(title="Water source", nrow=1)
    )
  
  ggsave(outfile, supply_plot_percent, width = width, height = height, dpi = dpi)
  return(outfile)
}

#' @title 
#' @description 
#' @param 
#' @param 
#' @return
combine_two_images <- function(image_1_file, image_2_file,image_1_title, image_2_title , width, height, bkgd_color) {
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

#' @title 
#' @description 
#' @param 
#' @param 
#' @return
map_region_on_states <- function(region, region_states, states, region_fill, region_color, state_fill, state_color) {
  
  region <- region[[1]]
  states_subset <- states %>%
    filter(NAME %in% region_states$states) %>%
    st_transform(sf::st_crs(region))
  
  ggplot() +
    geom_sf(data = states_subset, fill = state_fill, color = state_color, stroke = 0.5) +
    geom_sf(data = region, fill = region_fill, color = region_color, alpha=0.5) +
    theme_void()
  
}

#' @title 
#' @description 
#' @param 
#' @param 
#' @return
generate_source_summary_bar_chart <- function(supply_summary_state, supply_colors, selected_facility_type,
                                              title_text_size, axis_text_size, legend_text_size, width, 
                                              height, bkgd_color, text_color, outfile_template, dpi) {
  
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
    geom_bar(aes(fill = source_category), stat='identity') +
    scale_fill_manual(name = 'source_category', values = supply_colors) +
    scale_y_continuous(breaks = rev(c(0, 25, 50, 75, 100)),
                       labels = rev(c("0%", "25%", "50%","75%", "100%")),
                       expand = c(0,0)) +
    theme_minimal() +
    theme(
      axis.title = element_blank(),
      plot.title = element_text(hjust = 0.5, size = title_text_size, color = text_color, margin=margin(0,0,15,0)),
      axis.text.x = element_text(size = axis_text_size, color = text_color),
      axis.text.y = element_text(size = legend_text_size, color = text_color),
      panel.grid.major.y = element_blank(),
      axis.ticks.y = element_line(color = "grey60", size = 0.5),
      legend.position = 'bottom',
      legend.text = element_text(size = legend_text_size, color = text_color),
      legend.title = element_text(size = legend_text_size, color = text_color)) +
    guides(fill = guide_legend(title = 'Source category')) +
    ggtitle('Distribution of Water Sources by State for Bottled Water Facilities')
  
  outfile <- sprintf(outfile_template, selected_facility_type)
  
  ggsave(outfile, width = width, height = height, dpi=dpi, bg=bkgd_color)
}
