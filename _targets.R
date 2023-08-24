library(targets)

# Note, sometimes theres issues downloading the waffle package. If this is the case, download from remotes:
# remotes::install_github("hrbrmstr/waffle")

tar_option_set(packages = c("tidyverse",
                            'utils',
                            'tools',
                            'readxl',
                            'sbtools',
                            'httr',
                            'sf',
                            'rmapshaper',
                            'spData',
                            'tigris',
                            'ggspatial',
                            'ggrepel',
                            'cowplot',
                            'sysfonts',
                            'showtext',
                            'grid',
                            'magick',
                            'scales',
                            'units',
                            'prism',
                            'raster',
                            'exactextractr',
                            'treemap',
                            'treemapify',
                            'waffle',
                            'ggfx',
                            'FedData')) # need development version

# Phase target makefiles
source("1_fetch.R")
source("2_process.R")
source("3_visualize.R")

# Combined list of target outputs
c(p1_targets, p2_targets, p3_targets)
