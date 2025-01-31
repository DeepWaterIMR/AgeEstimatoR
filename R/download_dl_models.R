#' @title Download deep learning models for Greenland halibut age estimation
#' @description The function downloads the deep learning models required by the \code{\link{estimate_age}}.
#' @param data_storage_path Character defining the folder where the deep learning models should be downloaded.
#' @param download_path Character defining the URL or server folder where the deep learning models should be downloaded from. The default value indicates the currently recommended location.
#' @details The function downloads the pre-existing deep learning models required for Greenland halibut age estimation.
#' @return Returns a character file path to the folder containing the deep learning models. Can also be used in cases when the folder exists.
#' @author Mikko Vihtakari
#' @export

download_dl_models <- function(
    data_storage_path = "~/AgeEstimatoR large files",
    download_path = "https://owncloud.imr.no/index.php/s/9xDhXY5OZZzTI0P/download") {

  if(dir.exists(normalizePath(file.path(data_storage_path, "dl_models"), mustWork = FALSE))) {
    msg <- paste0("Deep learning models already exist in ", normalizePath(file.path(data_storage_path, "dl_models")), ". If you want to redownload them, delete the folder first.")
    message(paste(strwrap(msg), collapse= "\n"))
    return(normalizePath(file.path(data_storage_path, "dl_models")))
  }

  if(!dir.exists(normalizePath(data_storage_path, mustWork = FALSE))) {
    msg <- paste0("Setting up deep learning model download. The ", data_storage_path, " folder does not exist. Do you want to create it?.")
    message(paste(strwrap(msg), collapse= "\n"))
    ret.val <- utils::menu(c("Yes", "No"), "")
    if(ret.val != 1) {
      msg <- paste0("Data storage folder required to download the deep learning models.")
      stop(paste(strwrap(msg), collapse= "\n"))
    } else {
      dir.create(normalizePath(data_storage_path, mustWork = FALSE))
      msg <- paste0(data_storage_path, " created.")
      message(paste(strwrap(msg), collapse= "\n"))
    }
  }

  utils::download.file(
    url = download_path,
    destfile = file.path(normalizePath(data_storage_path, mustWork = TRUE),
                         "dl_models.zip")
  )

  utils::unzip(
    zipfile = file.path(normalizePath(data_storage_path, mustWork = TRUE),
                        "dl_models.zip"),
    exdir = normalizePath(data_storage_path, mustWork = TRUE)
  )

  unlink(file.path(normalizePath(data_storage_path, mustWork = TRUE),
                   "dl_models.zip"))

  message("Deep learning models downloaded to ", normalizePath(file.path(data_storage_path, "dl_models")))

  return(normalizePath(file.path(data_storage_path, "dl_models")))
}
