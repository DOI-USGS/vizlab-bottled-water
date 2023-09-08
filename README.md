# Impacts of Bottled Water

This draft project currently
1) calculates statistics (e.g., area, total population, mean precipitation) for a series of focal regions
2) Has an in-development javascript website using data visualizaiton to communicate the impacts of bottled water in the United States
* Explore location and type of bottling facilities nationally
* Exploration of water sources for those facilities
* Exploration of water use data, where available

## To run the R pipeline
This repo contains an R pipeline that uses the [`targets` package](https://books.ropensci.org/targets/) to process the National Bottled Water Inventory and generate static charts and maps. To run this pipeline, clone the repo, install `targets`, and run the following from the directory:
```
library(targets)
tar_make()
```

## To build the website locally
Clone the repo. In the directory, run `npm install` to install the required modules. This repository requires `npm v20` to run. If you are using a later version of `npm`, you may [try using `nvm` to manage multiple versions of npm](https://betterprogramming.pub/how-to-change-node-js-version-between-projects-using-nvm-3ad2416bda7e).

Once the dependencies have been installed, run `npm run dev` to run locally from your browser.
