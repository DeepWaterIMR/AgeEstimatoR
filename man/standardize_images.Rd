% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/standardize_image.R
\name{standardize_images}
\alias{standardize_images}
\title{A wrapper to standardize multiple otolith images for age estimation by deep learning}
\usage{
standardize_images(input_path, output_path, images = NULL, ...)
}
\arguments{
\item{input_path}{Character defining the file path to input images.}

\item{output_path}{Character defining the file path where the processed images should be saved.}

\item{images}{If \code{NULL}, processes all images in \code{input_path}. If an integer vector, processes images in the alphabetic order within the directory.}

\item{...}{Arguments passed to \code{\link{standardize_image}}.}
}
\value{
Saves multiple jpg images in \code{output_path}. The file names are similar to the original images except the addition of \code{prefix} and \code{postfix}.
}
\description{
A wrapper function for \code{\link{standardize_image}} allowing standardization of all images within a folder
}
