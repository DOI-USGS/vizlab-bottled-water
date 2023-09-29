##### Average annual bottled water use exploration #####
##### Elmera Azadpour, 09/27/2023 #####

library(targets)
library(tidyverse)
library(sf)
library(cowplot)
library(showtext)
library(viridis)

# load bottled water inventory data
tar_load(p2_bw_only_inventory)

# load conus data for maps
tar_load(p3_conus_sf)

#load colors
tar_load(p3_wu_availability_facilities_colors)

# renaming
bw_only_inventory_sf = p2_bw_only_inventory
conus_sf = p3_conus_sf
supply_colors = p3_wu_availability_facilities_colors
# drop geom from df for barplots
bw_only_inventory <- bw_only_inventory_sf |>
  st_drop_geometry()
# additional parameters for plotting
conus_outline_col = 'grey50'
scale_leg_title ="Annual Bottled Water Use (MGD)"
size_range = c(0.25, 8)
width = 16
height = 9
bkgd_color = 'white'
text_color = 'black'
dpi = 300

font_legend <- 'Source Sans Pro'
font_add_google(font_legend)
showtext_opts(dpi = 300, regular.wt = 200, bold.wt = 700)
showtext_auto(enable = TRUE)

# cowplot
plot_margin <- 0.025

canvas <- grid::rectGrob(
  x = 0, y = 0,
  width = width, height = height,
  gp = grid::gpar(fill = bkgd_color, alpha = 1, col = bkgd_color)
)

# get average annaul water use for each year by water source
bw_only_inventory_avg_yr_mgd <- bw_only_inventory_sf |>
  filter(wu_data_flag == "Y",
         !year_of_data == -9999) |>
  group_by(water_source, year_of_data) |>
  summarize(count = n(),
            avg_annual_wu = mean(annual_mgd)) |>
  mutate(
    water_source = factor(str_to_title(water_source),
                          levels = c("Public Supply", "Well", "Spring", "Surface Water Intake", "Combination", "Other"))
  ) |>
  filter(!water_source == "Other") # drop v small other water use in 2020

legend_data <- data.frame(avg_annual_wu = c(0.25, 10))

size_leg <- ggplot() +
  geom_point(data = legend_data, aes(x = 1, y = 1, size = avg_annual_wu), shape = 16) +
  scale_size_continuous(name = "Average annual bottled water use (MGD)",
                        range = c(0.25, 10), limits = c(0, max(bw_only_inventory_avg_yr_mgd$avg_annual_wu)),
                        guide = guide_legend(
                          direction = "horizontal",
                          nrow = 1,
                          label.position = "bottom",
                          title.position = "left")) +
  theme_void() +
  theme(text = element_text(family = font_legend, size = 14))

pull_leg <- cowplot::get_legend(size_leg)

# plot map of average annual water use (mgd) faceted by year
map_bw_avg_wu_facet_yr <- ggplot() +
  geom_sf(data = conus_sf,
          fill = bkgd_color,
          color = conus_outline_col,
          size = 0.6,
          linetype = "solid") +
  geom_sf(data = bw_only_inventory_avg_yr_mgd,
          aes(geometry = geometry, size = avg_annual_wu, color = water_source, fill = water_source),
          pch = 21,
          stroke = 0.4,
          color = bkgd_color,
          alpha = 0.75) +
  scale_fill_manual(name = 'Water source', values = supply_colors,
                    guide = guide_legend(title.position = "left", override.aes = list(color = bkgd_color),
                                         nrow = 1)) +
  scale_color_manual(name = "", values = supply_colors,
                     guide = NULL) +
  ggtitle("Average annual bottled water use (MGD)") +
  scale_size_continuous(name = NULL,
              range = c(0.25, 10), limits = c(0, max(bw_only_inventory_avg_yr_mgd$avg_annual_wu)),
              guide = NULL
             ) +
  theme_void() +
  theme(legend.position = "bottom",
        strip.text = element_text(size = 14, margin = margin(b=10, t= 10)),
        plot.title = element_text(size = 14, margin = margin(b=20, t= 20)),
        text = element_text(family = font_legend, size = 14)
        ) +
  facet_wrap(~year_of_data, nrow = 5)

plt_yr <- ggdraw(ylim = c(0,1), # 0-1 scale makes it easy to place viz items on canvas
              xlim = c(0,1)) +
  # a background
  draw_grob(canvas,
            x = 0, y = 1,
            height = height, width = width,
            hjust = 0, vjust = 1) +
  draw_plot(map_bw_avg_wu_facet_yr + theme(legend.position = "none",
                                     plot.title = element_blank()),
            x = 0.995,
            y = -0.01,
            height = 0.95,
            width = 1 - plot_margin,
            hjust = 1,
            vjust = 0) +
  # size legend
  draw_plot(pull_leg,
            x = -0.15,
            y = 0.34,
            height = 1.2,
            width = 0.8) +
  # color legend
  draw_plot(cowplot::get_legend(map_bw_avg_wu_yr),
            x = 0.32,
            y = 0.34,
            height = 1.2,
            width = 0.8)

ggsave("3_visualize/out/explore_average_annual_bw_use_map.png", plt_yr, width = width, height = height, dpi = dpi, bg = bkgd_color)

##### proportional symbol map of average annual MGD of use - colored by # of years of data #####
bw_avg_annual_facet_source <- ggplot() +
  geom_sf(data = conus_sf,
          fill = bkgd_color,
          color = conus_outline_col,
          size = 0.6,
          linetype = "solid") +
  geom_sf(data = bw_only_inventory_avg_yr_mgd,
          aes(geometry = geometry, size = avg_annual_wu,  color = year_of_data, fill = year_of_data),
          pch = 21,
          stroke = 0.4,
          color = bkgd_color,
          alpha = 0.75) +
  scale_size_continuous(name = NULL,
                        range = c(0.25, 10), limits = c(0, max(bw_only_inventory_avg_yr_mgd$avg_annual_wu)),
                        guide = NULL
  ) +
  facet_wrap(~water_source, nrow = 2) +
  scale_fill_viridis_b(name = "", alpha = 0.75) +
  theme_void() +
  theme(legend.position = "bottom",
        strip.text = element_text(size = 14, margin = margin(b=10, t= 10)),
        plot.title = element_text(size = 14, margin = margin(b=20, t= 20)),
        text = element_text(family = font_legend, size = 14),
        legend.key.width = unit(2, "cm"),
        legend.key.height = unit(0.75, "cm")
  )

plt_src <- ggdraw(ylim = c(0,1), # 0-1 scale makes it easy to place viz items on canvas
              xlim = c(0,1)) +
  # a background
  draw_grob(canvas,
            x = 0, y = 1,
            height = height, width = width,
            hjust = 0, vjust = 1) +
  draw_plot(bw_avg_annual_facet_source + theme(legend.position = "none"),
            x = 0.995,
            y = -0.01,
            height = 0.95,
            width = 1 - plot_margin,
            hjust = 1,
            vjust = 0) +
  # size legend
  draw_plot(pull_leg,
            x = -0.13,
            y = 0.34,
            height = 1.2,
            width = 0.8) +
  # color legend
  draw_plot(cowplot::get_legend(bw_avg_annual_facet_source),
            x = 0.30,
            y = 0.33,
            height = 1.2,
            width = 0.8)

  ggsave("3_visualize/out/avg_annual_mgd_by_year.png", plt_src, width = width, height = height, dpi = dpi, bg = bkgd_color)

  #####  histogram of # of years of data across BW facilities #####
  bw_only_inventory_yr_count <- bw_only_inventory_sf |>
    filter(wu_data_flag == "Y",
           !year_of_data == -9999) |>
    group_by(year_of_data) |>
    summarize(count = n()) |>
    st_drop_geometry()

  hist_bw <- ggplot(bw_only_inventory_yr_count, aes(x = year_of_data, y = count)) +
    geom_bar(stat = "identity", fill = "#1599CF", color = "grey80") +
    labs(y = "Count of bottled water facilities", x = NULL) +
    theme_minimal() +
    theme(text = element_text(family = font_legend, size = 14),
          panel.grid.minor = element_blank(),
          axis.title.y = element_text(margin = margin(r = 10))) +
    scale_y_continuous(limits = c(0, 75), breaks = seq(0, 75, by = 15))

  #####  bar plot showing total # of years of data and the y axis count of bottled water facilities  #####
  total_yrs_bw_facilities <- bw_only_inventory_yr_count |>
    summarize(total_years = n_distinct(year_of_data),
              total_count = sum(count))

  total_yrs_bw_facilities_barplot <- ggplot(total_yrs_bw_facilities, aes(x = total_years, y = total_count)) +
    geom_bar(stat = "identity", fill = "#1599CF", color = "grey80", width = 0.1) +
    labs(y = "Total count of bottled water facilities", x = "Total number of years of data") +
    theme_minimal() +
    theme(text = element_text(family = font_legend, size = 14),
          panel.grid.minor = element_blank(),
          axis.title.y = element_text(margin = margin(r = 10)),
          axis.title.x = element_text(margin = margin(t = 10))) +
    scale_x_continuous(breaks = total_yrs_bw_facilities$total_years, labels = total_yrs_bw_facilities$total_years)

  # combine plots
  combined_plot <- plot_grid(hist_bw, total_yrs_bw_facilities_barplot, ncol = 2, rel_widths = c(0.9, 0.25))

  ggsave("3_visualize/out/yrs_bw_facilities_barplot.png",
         combined_plot,  width = width, height = height, dpi = dpi, bg = bkgd_color)

  #####  map where color = # of years for which there are bottled water data  #####
  bw_only_inventory_yr_count_sf <- bw_only_inventory_sf |>
    filter(wu_data_flag == "Y",
           !year_of_data == -9999) |>
    group_by(year_of_data) |>
    summarize(count = n())

  count_yrs_bw_map <- ggplot() +
    geom_sf(data = conus_sf,
            fill = bkgd_color,
            color = conus_outline_col,
            size = 0.6,
            linetype = "solid") +
    geom_sf(data = bw_only_inventory_yr_count_sf,
            aes(geometry = geometry,  color = count, fill = count),
            pch = 21,
            stroke = 0.6,
            color = bkgd_color,
            alpha = 0.75,
            size = 5) +
    scale_fill_viridis_b(name = "Count of years with bottled water data", alpha = 0.75,
                         guide = guide_colorsteps(title.position = "top", title.hjust = 0.5,
                                            override.aes = list(color = bkgd_color),
                                            nrow = 1)) +
    theme_void() +
    theme(legend.position = "top",
          text = element_text(family = font_legend, size = 14),
          legend.key.width = unit(2, "cm"),
          legend.key.height = unit(0.75, "cm")
    )

  plt_count_yrs_map <- ggdraw(ylim = c(0,1), # 0-1 scale makes it easy to place viz items on canvas
                    xlim = c(0,1)) +
    # a background
    draw_grob(canvas,
              x = 0, y = 1,
              height = height, width = width,
              hjust = 0, vjust = 1) +
    draw_plot(count_yrs_bw_map + theme(legend.position = "none"),
              x = 0.995,
              y = -0.01,
              height = 0.95,
              width = 1 - plot_margin,
              hjust = 1,
              vjust = 0) +
    # color legend
    draw_plot(cowplot::get_legend(count_yrs_bw_map),
              x = 0.1,
              y = 0.3,
              height = 1.2,
              width = 0.8)

  ggsave("3_visualize/out/count_yrs_bw_data_map.png",
         plt_count_yrs_map, width = width, height = height, dpi = dpi, bg = bkgd_color)
