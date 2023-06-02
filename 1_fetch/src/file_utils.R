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