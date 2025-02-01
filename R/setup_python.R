#' @title Set up Python virtual environment and download required modules
#' @description The function sets up Python and TensorFlow as required by the \code{\link{estimate_age}}.
#' @param venv_path Character defining path to the Python virtual environment containing the TensorFlow package. If the virtual environment does not exist, it will be created and required packages downloaded.
#' @details The function locates the Python and TensorFlow installation in the python_virtualenv folder. If the folder does not exist, the function creates the folder with a Python virtual environment where these packages will be installed. The folder takes 1.43 Gb of file space.
#' @author Mikko Vihtakari
#' @export

setup_python <- function(venv_path = "~/AgeEstimatoR large files/python_virtualenv") {

  if(!reticulate::virtualenv_exists(venv_path)) {

    msg <- paste0("Python virtual environment to run TensorFlow was not detected. Do you want to download the required Python installation? They take 1.43 Gb of file space, and are required for age estimation. You can delete the ", venv_path,  " folder if you do not need age estimation any longer.")

    message(paste(strwrap(msg), collapse= "\n"))
    ret.val <- utils::menu(c("Yes", "No"), "")

    if(ret.val != 1) {
      msg <- paste0("Age estimation requires Python 3.10 and a specific version of TensorFlow. Run the function again when ready to install.")
      stop(paste(strwrap(msg), collapse= "\n"))

    } else {

      msg <- paste0("Downloading and installing Python 3.10, TensorFlow and associated packages (size: 1.43 Gb). This will take time...")
      message(paste(strwrap(msg), collapse= "\n"))

      ## Backup solution in case the reticulate alternative does not work
      # system(paste("python3.10 -m venv", venv_path))
      # system(paste0("source ", venv_path, "/bin/activate"))
      # req_path <- system.file("python", "requirements.txt", package = "AgeEstimatoR")
      # system(paste("pip install --ignore-installed -r ", req_path))

      # This alternative did not work for some reason:
      reticulate::virtualenv_install(
        envname = venv_path,
        python = "3.10",
        python_version = "3.10",
        ignore_installed = TRUE,
        requirements = system.file("python", "requirements.txt", package = "AgeEstimatoR")
      )

      msg <- paste0("Python and TensorFlow successfully installed into the ", venv_path, " folder. You can delete that folder when you will not need age estimation any longer.")
      message(paste(strwrap(msg), collapse= "\n"))
    }
  } else {
    message("Python and TensorFlow found from the ", venv_path, " folder.")
  }
}
