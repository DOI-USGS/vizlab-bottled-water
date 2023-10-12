#' @title open high-resolution spatial zipfile
#' @description unzip a zipfile containing spatial data and return the 
#' shapefile within the unzipped folder
#' @param out_file the name for the output shapefile
#' @param in_zip ther zipfile to be unzipped
#' @param tmp_dir the temporary directory where the zipfile will
#' be unzipped
#' @return the filepath of the shapefile
open_highres_spatial_zip <- function(out_file, in_zip, tmp_dir) {
  if(!dir.exists(tmp_dir)) dir.create(tmp_dir)
  
  # Unzip the file
  files_tmp <- unzip(in_zip, exdir = tmp_dir)
  
  # Copy to the out location and name based on what was passed in to `out_file`
  current_name_pattern <- unique(tools::file_path_sans_ext(tools::file_path_sans_ext(files_tmp)))
  out_name_pattern <- tools::file_path_sans_ext(out_file)
  files_out <- gsub(current_name_pattern, out_name_pattern, files_tmp)
  file.copy(files_tmp, files_out)
  
  # Find and return the specific `.shp` file from the unzipped folder
  files_out_shp <- files_out[grepl(".shp", files_out)]
  return(files_out_shp)
}

#' @title write to csv
#' @description write data to csv
#' @param data dataframe to be written to csv
#' @param outfile filepath to which csv should be written
#' @return the filepath of the saved csv
write_to_csv <- function(data, outfile) {
  readr::write_csv(data, outfile)
  return(outfile)
}

#' @title download file from url
#' @description download file from url
#' @param url url for file to be downloaded
#' @param outfile filepath where file should be saved
#' @return filepath of saved downloaded file, or, if downloaded failed, error
#' message
#' 
download_file_from_url <- function(url, outfile) {
  download_code <- download.file(destfile = outfile, url)
  if (download_code == 0) {
    return(outfile) }
  else {
    stop('file download failed')
  }
}

#' @title write to geojson
#' @description write data to geojson
#' @param data_sf sf dataframe to be written to geojson
#' @param cols_to_keep columns from dataframe to write
#' @param outfile filepath to which geojson should be written
#' @return the filepath of the saved geojson
write_to_geojson <- function(data_sf, cols_to_keep = NULL, outfile) {
  if (file.exists(outfile)) unlink(outfile)
  
  if (!is.null(cols_to_keep)) {
    data_sf <- dplyr::select(data_sf, !!cols_to_keep)
  }
  
  data_sf %>%
    st_transform(crs = 4326) %>%
    st_write(outfile, append = FALSE)
  
  return(outfile)
}

#' @title convert to topojson
#' @description convert geojson to topojson with specified precision
#' @param geojson geojson to be converted to topojson
#' @param outfile filepath to which topojson should be written
#' @param precision precision to which all coordinates should be rounded
#' @return the filepath of the saved topojson
convert_to_topojson <- function(geojson, outfile, precision) {
  
  # Simplify w/ mapshaper cli
  system(sprintf('mapshaper %s -o  %s precision=%s format=topojson', 
                 geojson, outfile, precision))
  
  return(outfile)
}

#' @title export to topojson
#' @description write geojson then convert to topojson with specified precision
#' @param data_sf sf dataframe to be exported to topojson
#' @param cols_to_keep columns from dataframe to write
#' @param tmp_dir temporary directory to which to write intermediate geojson
#' @param outfile filepath to which topojson should be written
#' @param precision precision to which all coordinates should be rounded
#' @return the filepath of the saved topojson
export_to_topojson <- function(data_sf, cols_to_keep, tmp_dir, outfile, precision) {
  # first write to geojson
  tmp_geojson_filename <- file.path(tmp_dir,
                            paste0(tools::file_path_sans_ext(basename(outfile)),
                                   '.geojson'))
  
  tmp_geojson <- write_to_geojson(data_sf = data_sf, cols_to_keep = cols_to_keep, 
                                  outfile = tmp_geojson_filename)
  
  # then convert to topojson, w/ reduced precision
  convert_to_topojson(geojson = tmp_geojson, outfile = outfile, 
                      precision = precision)
}