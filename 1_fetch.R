prism::prism_set_dl_dir("1_fetch/tmp")

source('1_fetch/src/file_utils.R')
source('2_process/src/spatial_utils.R')

p1_targets <- list(
  # set proj for CONUS
  tar_target(p1_proj,
             '+proj=aea +lat_0=23 +lon_0=-96 +lat_1=29.5 +lat_2=45.5 +x_0=0 +y_0=0 +ellps=GRS80 +towgs84=0,0,0,0,0,0,0 +units=m +no_defs +type=crs'
  ),
  
  ##### U.S./State data, for joining #####
  tar_target(p1_state_info,
             bind_rows(
               tibble(
                 state_name = state.name,
                 state_abbr = state.abb
               ),
               tibble(
                 state_name = c('District of Columbia','Guam','Puerto Rico','Virgin Islands'),
                 state_abbr = c('DC', 'GU', 'PR', 'VI')
               ))),
  
  # U.S. polgyon, for clipping
  tar_target(p1_ne_countries_zip,
             download_file_from_url(url = "https://www.naturalearthdata.com/http//www.naturalearthdata.com/download/10m/cultural/ne_10m_admin_0_countries_lakes.zip",
                                    outfile = '1_fetch/out/ne_countries.zip'),
             format = 'file'),
  
  tar_target(p1_ne_countries_shp,
             open_highres_spatial_zip('1_fetch/out/ne_countries.shp', p1_ne_countries_zip, '1_fetch/tmp'),
             format = 'file'),
  
  tar_target(p1_us_poly_sf,
             st_read(p1_ne_countries_shp) %>%
               filter(ADMIN=='United States of America')),
  
  ## U.S. states, for mapping
  tar_target(p1_nws_states_zip,
             download_file_from_url(url = "https://www.weather.gov/source/gis/Shapefiles/County/s_22mr22.zip",
                                    outfile = '1_fetch/out/nws_states.zip'),
             format = 'file'),
  
  tar_target(p1_nws_states_shp,
             open_highres_spatial_zip('1_fetch/out/nws_states.shp', p1_nws_states_zip, '1_fetch/tmp')),
  ##### Inventory data #####
  tar_target(p1_sb_id,
             '649d8a39d34ef77fcb03f8a6'),
  
  ###### Water use data ######
  tar_target(p1_water_use_txt,
             download_from_sb(sb_id = p1_sb_id,
                              filename = 'WBinventory_WaterUse.txt',
                              dest_dir = '1_fetch/out'),
             format = 'file'),
  
  ###### Facility inventory ######
  tar_target(p1_inventory_txt,
             download_from_sb(sb_id = p1_sb_id,
                              filename = 'WBinventory_FacilityList.txt',
                              dest_dir = '1_fetch/out'),
             format='file'),
  
  ##### Regional data #####
  ###### Regional spatial data ######
  tar_target(p1_region_info,
             tibble(
               region = c('florida', 'texas', 'great lakes', 'valley and ridge', 
                          'new england', 'california'),
               full_name = c('Santa Fe River Basin, Florida','Trinity River Basin, Texas',
                             'Great Lakes region, upper Midwest U.S.',
                             'Valley and Ridge physiographic province, eastern U.S.',
                             'Saco River Basin, New Hampshire and Maine',
                             'East Twin/Strawberry Creek Watersheds, California')
             )),
  
  # Regional shapefiles were sent in zip file w/ nested directories of spatial data for each region
  # This is a lengthy series of steps to unzip and load the data programmatically, which I'm
  # retaining for now in case I'm sent an updated zip file, as these boundaries may shift
  tar_target(p1_spatial_zip, 
             '1_fetch/in/RegionalStudySites.zip',
             format = 'file'),
  
  tar_target(p1_spatial_unzip, 
             {
               exdir <- sprintf("1_fetch/out/%s",file_path_sans_ext(basename(p1_spatial_zip)))
               utils::unzip(zipfile = p1_spatial_zip,
                            exdir = exdir, overwrite = TRUE)
               return(exdir)
             },
             format = 'file'),
  
  tar_target(p1_spatial_dirs,
             list.dirs(p1_spatial_unzip, recursive=FALSE),
             format = 'file'),
  
  # find shapefiles within each sub-directory
  tar_target(p1_spatial_shps,
             purrr::map_df(p1_spatial_dirs, function(dir) {
               tibble(
                   dir_filepath = list.files(dir, recursive=TRUE) %>% str_subset('.shp$'),
                   full_filepath = file.path(dir, dir_filepath),
                   filename = basename(dir_filepath),
                   file_hash = md5sum(full_filepath)) %>%
                 mutate(dir = dir,
                        region = basename(dir),
                        .before = 1)
             })
  ),

  # Florida region
  tar_target(p1_florida_region_sf,
             p1_spatial_shps %>%
               filter(region == 'Florida') %>% 
               pull(full_filepath) %>%
               st_read() %>%
               mutate(region = 'florida')
  ),
  
  # Texas region
  tar_target(p1_texas_region_sf,
             p1_spatial_shps %>% 
               filter(region == 'TexasTrinity') %>% 
               pull(full_filepath) %>%
               st_read() %>%
               mutate(region = 'texas') %>%
               filter(basin_name == 'Trinity')
  ),
  
  # Great Lakes region
  # clip to U.S. boundary (w/ lakes)
  # and merge into single polygon
  tar_target(p1_great_lakes_region_sf,
             p1_spatial_shps %>% 
               filter(region == 'GreatLakes' & grepl('basin', filename)) %>% 
               pull(full_filepath) %>%
               st_read() %>%
               st_transform(st_crs(p1_us_poly_sf)) %>%
               st_intersection(p1_us_poly_sf) %>%
               st_union() %>%
               st_sf() %>% 
               mutate(region = 'great lakes')),
  
  # Valley and Ridge region
  tar_target(p1_valley_ridge_region_sf,
             p1_spatial_shps %>% 
               filter(region == 'ValleyRidge' & grepl('Dissolve', filename)) %>% 
               pull(full_filepath) %>%
               st_read() %>%
               mutate(region = 'valley and ridge')),
  
  # New England region
  tar_target(p1_new_england_region_sf,
             p1_spatial_shps %>% 
               filter(region == 'SacoNewEngland' & grepl('regional', filename)) %>% 
               pull(full_filepath) %>%
               st_read() %>%
               mutate(region = 'new england')),
  
  # CA region
  tar_target(p1_california_region_sf,
             p1_spatial_shps %>%
               filter(region == 'StrawberryCali' & grepl('boundary', filename)) %>%
               pull(full_filepath) %>%
               st_read() %>%
               mutate(region = 'california')),
  
  # Alternate CA study area - not using for now
  # # CA region
  # tar_target(p1_ca_HUC10_shp,
  #            file.path('1_fetch/in/HUC10', list.files('1_fetch/in/HUC10', recursive=TRUE) %>% str_subset('.shp$')),
  #            format = 'file'),
  # tar_target(p1_california_region_sf,
  #            p1_ca_HUC10_shp %>% 
  #              st_read() %>% 
  #              st_union() %>%
  #              st_sf() %>%
  #              mutate(region = 'california')),
  
  # Combine regional data into single projected sf object
  # for use in national/conus maps
  tar_target(p1_regions_sf,
             {
               reproject_and_combine_spatial_data(p1_florida_region_sf, p1_texas_region_sf, 
                                                  p1_great_lakes_region_sf, p1_valley_ridge_region_sf, 
                                                  p1_new_england_region_sf, p1_california_region_sf,
                                                  proj = p1_proj) %>%
                 # group for targets mapping
                 group_by(region) %>%
                 tar_group()
             },
             iteration = 'group'),  
  
  # Retain list of raw spatial data, with original projections
  # for use in region-specific maps
  tar_target(p1_regions_sf_unique_proj,
             list(p1_california_region_sf, p1_florida_region_sf, p1_great_lakes_region_sf,
                  p1_new_england_region_sf, p1_texas_region_sf, p1_valley_ridge_region_sf)),
  
  ###### Regional attribute data ######
  
  # 2020 population
  # Download global gridded population data from: https://sedac.ciesin.columbia.edu/data/set/gpw-v4-population-count-rev11/data-download
  # need to create account and log in, and I selected 2020, tif, 30 second resolution
  # unzip folder into 1_fetch/in
  tar_target(p1_population_tif,
             '1_fetch/in/gpw-v4-population-count-rev11_2020_30_sec_tif/gpw_v4_population_count_rev11_2020_30_sec.tif',
             format = 'file'),
  
  # Koppen climate classifications
  # http://www.gloh2o.org/koppen/ - need to download zipfile and place in 1_fetch/in
  tar_target(p1_climate_zip,
             '1_fetch/in/Beck_KG_V1.zip',
             format = 'file'),
  
  tar_target(p1_climate_unzip, 
             {
               exdir <- sprintf("1_fetch/out/%s",file_path_sans_ext(basename(p1_climate_zip)))
               utils::unzip(zipfile = p1_climate_zip,
                            exdir = exdir, overwrite = TRUE)
               return(exdir)
             },
             format = 'file'),
  
  tar_target(p1_climate_files,
             file.path(p1_climate_unzip, list.files(p1_climate_unzip, recursive=FALSE)),
             format = 'file'),
  
  tar_target(p1_climate_tif,
             p1_climate_files[grepl('present_0p083', p1_climate_files)],
             format = 'file'),
  
  tar_target(p1_climate_legend_txt,
             p1_climate_files[grepl('legend', p1_climate_files)],
             format = 'file'),
  
  # Manually define based on contents of p1_climate_legend_txt b/c too wonky to parse easily
  tar_target(p1_climate_legend,
             tibble(
               value = c(8, 14, 25, 26, 27, 0),
               climate = c('Temperate, dry summer, hot summer',
                           'Temperate, no dry season, hot summer',
                           'Cold, no dry season, hot summer',
                           'Cold, no dry season, warm summer',
                           'Cold, no dry season, cold summer',
                           'NA')
             )),
  
  # PRISM precip - 30-year normals
  tar_target(p1_PRISM_4km_dir, 
             {
               dest_dir <- prism_get_dl_dir()
               resolution <- "4km"
               get_prism_normals(type = "ppt", resolution = resolution, annual = TRUE, keepZip = FALSE)
               data_dirs <- list.dirs(dest_dir, recursive=FALSE)
               data_dir <- data_dirs[grepl(resolution, data_dirs)]
               return(data_dir)
             },
             format = 'file'),
  
  # NLCD - imperviousness
  # https://search.r-project.org/CRAN/refmans/FedData/html/get_nlcd.html
  tar_target(p1_NLCD,
             {
               template <- p1_regions_sf %>% st_transform(epsg=4326)
               NLCD <- get_nlcd(
                 template = template,
                 label = template$region,
                 year = 2019,
                 dataset = 'impervious',
                 extraction.dir = '1_fetch/out/NLCD',
                 force.redo = TRUE)
             },
             pattern = map(p1_regions_sf)),

  # Hydrology
  tar_target(p1_hydro_gdb_dir,
             {
               tar_path <- '1_fetch/tmp/hydro.tar'
               if (!file.exists(tar_path)) GET('https://prd-tnm.s3.amazonaws.com/StagedProducts/Small-scale/data/Hydrography/hydrusm010g.gdb_nt00897.tar.gz',
                   write_disk(tar_path))
               gdb_dir <- '1_fetch/out/hydro_gdb'
               if (!dir.exists(gdb_dir)) dir.create(gdb_dir)
               if (length(list.files(gdb_dir)) == 0) untar(tar_path, exdir=gdb_dir)
               return(gdb_dir)
             },
             format='file'),
  
  tar_target(p1_hydro_gdb,
             list.dirs(p1_hydro_gdb_dir, recursive=FALSE),
             format='file')

)