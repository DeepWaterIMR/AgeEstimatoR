#' @title Estimate age from standardized otolith images using deep learning
#' @description Estimates age from standardized otolith images (see \code{\link{standardize_images}}) using deep learning algorithms developed for Greenland halibut by Martinsen et al. (2022).
#' @param image_path Character defining the file path to the standardized images from \code{\link{standardize_images}}.
#' @param output_path Character defining the file path to the model output containing file name without extension. If \code{NULL}, the data are not saved to a file, but returned as a data frame instead.
#' @param model_path Character defining the file path to the deep learning models by Martinsen et al. (2022). If the specified folder does not exist, the \code{\link{download_dl_models}} function is used to download the models.
#' @inheritParams setup_python
#' @return Saves a jpg image in \code{output_path}. The file name is similar to the original images except the addition of \code{prefix} and \code{postfix}.
#' @author Iver Martinsen, Mikko Vihtakari, Alf Harbitz, Tine Nilsen (Institute of Marine Research, Norway)
#' @export

# Debug params:
# image_path = file.path(system.file("extdata", package = "AgeEstimatoR"), "example_images", "standardized"); output_path = "data/ml_age_estimates.csv"; model_path = "~/AgeEstimatoR large files/dl_models"; venv_path = "./python_virtualenv"
estimate_age <- function(image_path, model_path = "~/AgeEstimatoR large files/dl_models", output_path = NULL, venv_path = "~/AgeEstimatoR large files/python_virtualenv") {

  # Check paths
  ## Images

  if(!exists("image_path")) {
    stop("image_path missing. Provide file path to standardized images using the image_path argument.")
  } else {
    image_path <- normalizePath(image_path, mustWork = TRUE)
  }

  ## Model data

  if(!any(dir(normalizePath(model_path, mustWork = FALSE)) %in% paste0("model", 1:10))) {
    model_path <- normalizePath(gsub("/dl_models", "", model_path), mustWork = FALSE)
    msg <- paste0("Did not find the required deep learning models from the specified path. Do you want to download them to ", model_path, " now?")
    message(paste(strwrap(msg), collapse= "\n"))
    ret.val <- utils::menu(c("Yes", "No"), "")
    if(ret.val != 1) {
      msg <- paste0("The deep learning models are required to run the age estimation.")
      stop(paste(strwrap(msg), collapse= "\n"))
    } else {
      model_path <- download_dl_models(model_path)
    }
  } else {
    model_path <- normalizePath(model_path, mustWork = TRUE)
  }

  # Virtual environment

  setup_python(venv_path)

  # if(!reticulate::virtualenv_exists(venv_path)) {
  suppressWarnings(
    reticulate::use_virtualenv(venv_path, required = TRUE)
  )
  # }

  # Run the function
  reticulate::source_python(system.file("python", "dl_age_estimator.py", package = "AgeEstimatoR"))

  dl_age_estimator(path_to_images = image_path,
                   path_to_models = model_path,
                   path_to_output = output_path
  )
}

