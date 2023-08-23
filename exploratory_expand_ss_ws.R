# This is an exploratory script that breaks down water_sources self_supply category by well, sw intake, and spring and plots
library(targets)
library(tidyverse)
#library(waffle) - this one doesn't let me geofacet

library(ggwaffle) # install.packages("devtools") devtools::install_github("liamgilbey/ggwaffle")

library(cowplot)
library(showtext)

# import font
font_legend <- 'Source Sans Pro'
font_add_google(font_legend)
showtext_opts(dpi = 300, regular.wt = 200, bold.wt = 700)
showtext_auto(enable = TRUE)

annotate_text <-"Shadows Into Light"
font_add_google(annotate_text)

tar_load(p2_inventory_sites)
tar_load(p2_facility_type_summary)
tar_load(p2_supply_summary)
tar_load(p2_supply_summary_state)

supply_colors <- c('#4DC49D', '#CC5500', '#000080', '#FF3131', '#D8BF32', '#BD5EC6', '#D4D4D4')
color_names <- c('public supply', 'well', 'spring', 'sw intake', 'self supply', 'both', 'undetermined')
names(supply_colors) <- color_names

# Get more info out of `self supply`
p2_expand_self_supply <- p2_inventory_sites |>
  mutate(source_category = case_when(water_source == "well" ~ "well",
                                     water_source == "sw intake" ~ "sw intake",
                                     water_source == "spring" ~ "spring",
                                     TRUE ~ source_category))

# Get summary of facility supply sources, by type
p2_supply_summary <-
  p2_expand_self_supply |>
  mutate(WB_TYPE = factor(WB_TYPE, levels=p2_facility_type_summary$WB_TYPE)) |>
  group_by(WB_TYPE, source_category) |>
  summarize(site_count = n()) |>
  mutate(source_category = factor(source_category, levels=c('undetermined', 'both', 'well', 'spring', 'sw intake','self supply', 'public supply'))) |>
  group_by(WB_TYPE) |>
  mutate(percent = site_count/sum(site_count)*100)

# Get summary of facility supply sources, by type and by state
p2_supply_summary_state <-
  p2_expand_self_supply |>
  mutate(WB_TYPE = factor(WB_TYPE, levels=p2_facility_type_summary$WB_TYPE)) |>
  group_by(state_name, state_abbr, WB_TYPE, source_category) |>
  summarize(site_count = n()) |>
  mutate(source_category = factor(source_category, levels=c('undetermined', 'both', 'well', 'spring', 'sw intake','self supply', 'public supply')))

supply_summary = p2_supply_summary
supply_summary_state = p2_supply_summary_state
supply_colors = supply_colors
selected_facility_type = 'All'
width = 16
height = 9
bkgd_color = 'white'
text_color = 'black'
outfile_template = '3_visualize/out/state_sources_facet_expand_supply.png'
dpi = 300

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

if (!(selected_facility_type == 'All')) {
  supply_summary_state <- supply_summary_state %>%
    filter(WB_TYPE == selected_facility_type) %>%
    arrange(state_name) %>%
    group_by(state_name, state_abbr) %>%
    mutate(percent = site_count/sum(site_count)*100) |>
    mutate(ratio = site_count/sum(site_count))
  supply_summary <- supply_summary %>%
    filter(WB_TYPE == selected_facility_type) %>%
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

  supply_summary <- supply_summary %>%
    group_by(source_category) %>%
    summarize(site_count = sum(site_count)) %>%
    mutate(percent = site_count/sum(site_count)*100) |>
    mutate(ratio = site_count/sum(site_count))
}

grid <- geofacet::us_state_grid1 %>%
  add_row(row = 7, col = 10, code = "PR", name = "Puerto Rico") %>% # add PR
  add_row(row = 7, col = 11, code = "VI", name = "U.S. Virgin Islands") %>% # add VI
  add_row(row = 6, col = 1, code = "GU", name = "Guam") # add GU

# Alternative `geom_waffle` approach to `geofacet` by
ws_state_waffle <- waffle_iron(supply_summary_state, mapping = aes_d(group = "source_category"), rows = 10) |>
  rename(source_category = group) |>
  left_join(supply_summary_state, by = c("source_category"))

plt <- ggplot(ws_state_waffle, aes(x, y, fill = source_category, values = ratio)) +
  geom_waffle() +
  coord_equal() +
  geofacet::facet_geo(~ state_abbr, grid = grid, move_axes = TRUE) +
  scale_fill_manual(name = 'source_category', values = supply_colors)

  ggsave("geowaffle_test.png", plt, width = width, height = height, dpi = dpi, bg = "white")

# facet wrapped waffle charts
state_facet <- supply_summary_state %>%
  ggplot(aes(values = ratio, fill = source_category)) +
  waffle::geom_waffle(color = "white", size = 1.3, n_rows = 10,
                      make_proportional = TRUE,
                      stat = "identity", na.rm = TRUE) +
  scale_fill_manual(name = 'source_category', values = supply_colors) +
  theme_bw() +
  theme_facet(base = 12, bkgd_color = bkgd_color, text_color = text_color) +
  facet_wrap(~state_abbr)
  # +
  # geofacet::facet_geo(~ state_abbr, grid = grid, move_axes = TRUE) #Doesnt work


national_plot <- supply_summary %>%
  mutate(ratio = site_count/sum(site_count)) |>
  ggplot(aes(values = ratio, fill = source_category)) +
  waffle::geom_waffle(color = "white", size = 1.125, n_rows = 10,
                      make_proportional = TRUE,
                      stat = "identity", na.rm = TRUE) +
  scale_fill_manual(name = 'source_category', values = supply_colors, drop = FALSE) +
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
  ggtitle('National')

plot_margin <- 0.0009

plot_arrow <- ggplot() +
  theme_void() +
  # add arrow using `geom_curve()`
  geom_curve(aes(x = 13, y = 5,
                 xend = 11, yend = 1),
             arrow = grid::arrow(length = unit(0.6, 'lines')),
             curvature = 0.5, angle = 100, ncp = 10,
             color ='black')

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
            y = 0.25,
            height = 0.45 ,
            width = 0.32 - plot_margin * 2) +
  # plot arrow
  draw_plot(plot_arrow + theme(legend.position = 'none'),
            x = 0.04,
            y = 0.68,
            height = 0.07 ,
            width = 0.055 - plot_margin) +
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
            y = 0.065,
            height = 0.13 ,
            width = 0.3 - plot_margin) +
  draw_label(sprintf('Distribution of\nwater sources for\n%s facilities',
                     tolower(selected_facility_type)),
             x = 0.025, y = 0.98,
             size = 34,
             hjust = 0,
             vjust = 1,
             color = 'black',
             lineheight = 1)+
  # arrow label
  draw_label("Proportion of\nfacility type (1%)",
             fontfamily = annotate_text,
             x = 0.15,
             y = 0.76,
             size = 20,
             color = "black")

ggsave(outfile_template, facet_plot, width = width, height = height, dpi = dpi)



# state source categories waffle chart ------------------------------------
# Define the list of state names
state_names_list <- unique(supply_summary_state$state_name)

# Function to create waffle chart and save the output
create_and_save_waffle <- function(state_name) {
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
  output_dir <- "3_visualize/out/state_source_waffle_expand_supply_all"
  if (!dir.exists(output_dir)) {
    dir.create(output_dir, recursive = TRUE)
  }

  # Save the plot as a PNG file
  output_path <- file.path(output_dir, paste0(state_name, ".png"))
  ggsave(output_path, plot = p, width = 6, height = 4, bg = "white")  # Adjust width and height as needed
}

# Iterate through each state name and create/save the plots
purrr::map(state_names_list, create_and_save_waffle)


# expanded state source self supply treemaps -----------------------------
#install.packages("treemapify")
library(treemapify)

state_names_list <- unique(supply_summary_state$state_name)

create_and_save_treemap <- function(state_name) {
  state_data <- supply_summary_state %>% filter(state_name == !!state_name)

  p <- ggplot(state_data, aes(area = percent, fill = source_category, label = paste0(source_category, "\n", round(percent), "%"))) +
    geom_treemap() +
    geom_treemap_text(color = "black", place = "centre",
                      grow = TRUE) +
    scale_fill_manual(name = 'Water source', values = supply_colors, drop = FALSE) +
    theme_bw() +
    theme_facet(base = 12, bkgd_color = bkgd_color, text_color = text_color) +
    labs(title = paste(state_name,": Distribution of water sources for all facilities")) +
    theme(legend.position = "none",
          # legend.direction = "horizontal",
          # legend.box = "horizontal",
          # legend.margin = margin(t = 0.05, b = -0.5, unit = "cm"),
          # legend.key.size = unit(0.5, "cm"),
          # legend.text = element_text(size = 10),
          plot.title = element_text(margin = margin(t = 4, b = 4)),
          plot.margin = margin(15,15, 10,15))

  # Create the output directory if it doesn't exist
  output_dir <- "3_visualize/out/state_source_treemap_expand_supply_all"
  if (!dir.exists(output_dir)) {
    dir.create(output_dir, recursive = TRUE)
  }

  # Save the plot as a PNG file
  output_path <- file.path(output_dir, paste0(state_name, ".png"))
  ggsave(output_path, plot = p, width = 6, height = 4, bg = "white")  # Adjust width and height as needed
}

# Iterate through each state name and create/save the plots
purrr::map(state_names_list, create_and_save_treemap)
