# Water bottling across the U.S.

This project
1) calculates statistics (e.g., area, total population, mean precipitation) for a series of focal regions

2) Pulls, processes, and visualizes data from the USGS [Inventory of water bottling facilities in the United States, 2023, and select water-use data, 1955-2022](https://www.sciencebase.gov/catalog/item/649d8a39d34ef77fcb03f8a6)

3) Builds a javascript website using data visualization to communicate the motivation for the USGS [Water Mission Area's Bottled Water Assessment project](https://www.usgs.gov/mission-areas/water-resources/science/withdrawals-bottled-water), the distribution of bottling facilities across the United States, where bottling facilities source water, and the available water use data for bottled water facilities. The website can be accessed [here](https://labs.waterdata.usgs.gov/visualizations/bottled-water)

## To run the R pipeline
This repo contains an R pipeline that uses the [`targets` package](https://books.ropensci.org/targets/) to process the national inventory of water bottling facilities and generate static charts and maps.

Two data files must be downloaded manually to run the pipeline
1) [2020 global gridded population count data](https://sedac.ciesin.columbia.edu/data/set/gpw-v4-population-count-rev11/data-download). Downloading the data requires creating a free account and logging in. Select "Population Count, v4.11" with options 2020, tif format, 30-second resolution. Unzip the folder into 1_fetch/in. Final directory path should be `'1_fetch/in/gpw-v4-population-count-rev11_2020_30_sec_tif/gpw_v4_population_count_rev11_2020_30_sec.tif'`.

2) The [Koppen climate classifications data](http://www.gloh2o.org/koppen/). This analysis used version V1 of the maps, as described in Betck et al., 2018, which can be downloaded [here](https://figshare.com/articles/dataset/Present_and_future_K_ppen-Geiger_climate_classification_maps_at_1-km_resolution/6396959/2). The `'Beck_KG_V1.zip` should be downloaded and placed in `'1_fetch/in'`. Final file path should be `'1_fetch/in/Beck_KG_V1.zip'`.

To run this pipeline, clone the repo, install `targets`, download the data as instructed above, and run the following from the directory:
```
library(targets)
tar_make()
```

## To build the website locally
Clone the repo. In the directory, run `npm install` to install the required modules. This repository requires `npm v20` to run. If you are using a later version of `npm`, you may [try using `nvm` to manage multiple versions of npm](https://betterprogramming.pub/how-to-change-node-js-version-between-projects-using-nvm-3ad2416bda7e).

Once the dependencies have been installed, run `npm run dev` to run locally from your browser.
