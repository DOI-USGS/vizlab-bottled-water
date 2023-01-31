library(targets)

tar_option_set(packages = c("tidyverse",
                            'utils',
                            'tools',
                            'readxl',
                            'httr',
                            'sf',
                            'units',
                            'prism',
                            'raster',
                            'exactextractr',
                            'FedData')) # need development version

# Phase target makefiles
source("1_fetch.R")
source("2_process.R")

# Combined list of target outputs
c(p1_targets, p2_targets)