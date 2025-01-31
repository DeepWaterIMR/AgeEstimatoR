
<!-- README.md is generated from README.Rmd. Please edit that file -->

# AgeEstimatoR

**Estimate age from otolith pictures using Deep Learning. R package
version 0.0.1** <!-- badges: start --> <!-- badges: end -->

This is an early draft of an R package to standardize fish otolith
photographs and use Deep Learning (DL or ML) models to estimate the age
from the standardized photographs. The package currently works only for
Greenland halibut and uses the models developed by [Martinsen et
al. (2022)](https://doi.org/10.1371/journal.pone.0277244) but may be
extended for other species and models in the future. The age estimation
uses Python and the TensorFlow platform for machine learning. Note that
the DL age estimation method was developed only for **right otoliths of
Greenland halibut**.

Note that running the age estimation function (`estimate_age`) downloads
Python and TensorFlow into a virtual environment together with DL models
for Greenland halibut. These **take \>2.2 gigabytes of file space** in
total.

## Installation

You can install AgeEstimatoR using the remotes or devtools packages:

``` r
remotes::install_github("DeepWaterIMR/AgeEstimatoR")
```

## Example

``` r
library(AgeEstimatoR)
```

### Image standardization

Standardize images ready for age estimation:

``` r
standardize_images(
  input_path = file.path(system.file("extdata", package = "AgeEstimatoR"), 
                         "example_images", "input"),
  output_path = "inst/extdata/example_images/standardized/",
  adj = 1.1, fillparam = 3
)
```

The function brings up a plot screen where you’ll need to mark the
corners of the **right** otolith for cropping. To do the marking, click
the photograph twice until you see a line:

Next, the resulting cropped photo will be displayed (left without
filtering, right with filtering). You will no be asked whether you are
satisfied with the result on the right. If you answer 2 (no), the
function will ask new adjustment factor and fill parameter () and you
will get a new shot in cropping the photo. If you answer 1 (yes), the
function will jump to the next photo.

### Age estimation

It is important to understand how the `estimate_age` function **can
clutter your computer full of Python installations if used wrong**: The
age estimation requires Python 3.10, TensorFlow and very specific
versions of Python modules. Consequently, the `estimate_age()` function
downloads complete Python 3.10, TensorFlow and required modules into a
virtual environment folder called `python_virtualenv` by default in the
project root. The folder takes 1.43 GB of file space and clutter your
computer if using AgeEstimatoR in multiple projects. You can use the
`venv_path` to define the path to the virtual environment once you have
downloaded it once.

Use the `data_path` argument to save the results directly into a file.

``` r
x <- estimate_age(
  image_path = file.path(system.file("extdata", package = "AgeEstimatoR"), 
                         "example_images", "standardized")
  )
```

## Things that remain to be solved

- Is the machine learning script (`inst/python/dl_age_estimator.py`)
  correct?
  - Is the order of sexes in the output correct?
- File size of standardized photographs is only 10-20 KB. Is this a
  problem?
- Automatic otolith recognition to skip that otolith marking phase
- More plotting functions. Especially one that binds all standardized
  otolith images together.
