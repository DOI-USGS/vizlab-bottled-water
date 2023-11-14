# Water bottling across the U.S.

This project
1) calculates statistics (e.g., area, total population, mean precipitation) for a series of focal regions
2) Pulls, processes, and visualizes data from the USGS [Inventory of water bottling facilities in the United States, 2023, and select water-use data, 1955-2022](https://www.sciencebase.gov/catalog/item/649d8a39d34ef77fcb03f8a6)
2) Builds a javascript website using data visualization to communicate the motivation for the USGS [Water Mission Area's Bottled Water Assessment project](https://www.usgs.gov/mission-areas/water-resources/science/withdrawals-bottled-water), the distribution of bottling facilities across the United States, where bottling facilities source water, and the available water use data for bottled water facilities.

## To run the R pipeline
This repo contains an R pipeline that uses the [`targets` package](https://books.ropensci.org/targets/) to process the national inventory of water bottling facilities and generate static charts and maps. To run this pipeline, clone the repo, install `targets`, and run the following from the directory:
```
library(targets)
tar_make()
```

## To build the website locally
Clone the repo. In the directory, run `npm install` to install the required modules. This repository requires `npm v20` to run. If you are using a later version of `npm`, you may [try using `nvm` to manage multiple versions of npm](https://betterprogramming.pub/how-to-change-node-js-version-between-projects-using-nvm-3ad2416bda7e).

Once the dependencies have been installed, run `npm run dev` to run locally from your browser.
