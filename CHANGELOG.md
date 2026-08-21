# Change Log
All notable changes to this project will be documented in this file.
 
The format is based on [Keep a Changelog](http://keepachangelog.com/)
and this project adheres to [Semantic Versioning](http://semver.org/).
 
## [2.0.0] - 2026-08-17

### Added
- Added a change log
- Added a pull request template
- 404 page
- Captions beneath the water source bar chart, the county source maps, and the water use beeswarm chart
- Byline with publication and last-updated dates beneath the page title

### Changed
- Updated dependencies; switch from Vue 2 to Vue 3
- Replaced Vuex with Pinia for window size and map render state
- Components translated to the composition API
- CSS definitions moved out of components and into `src/assets/css/`
- Site moved to the water.usgs.gov/vizlab domain; updated all links and metadata to match
- Updated the USGS header, footer, USWDS banner, and prefooter link components to the current Vizlab versions
- Switched analytics to the shared Vizlab Google Analytics property
- Authorship section simplified to a single credit line, consistent with other Vizlab sites
- Water source section reordered so the bar chart sits mid-section rather than at the end
- Dropped unused dependencies and removed old build files

### Fixed
- Corrected the structured data (JSON-LD) block in `index.html`, which was not valid JSON
- Restored the map dropdown styling, which relied on a form reset from Vuetify's stylesheet
- Restored the content-box sizing the page layout is built against, after the USGS Viz ID stylesheet introduced a global border-box reset
- Removed the doubled spacing between entries in the references list

## [1.0.0] - 2023-11-21

### Added

- Released the bottled water data visualization.
