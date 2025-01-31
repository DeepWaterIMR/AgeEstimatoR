#' @title Standardize a single otolith image for age estimation by deep learning
#' @description Standardizes otolith images ready for age estimation using the \code{\link{estimate_age}} function. Creates a 256 X 256 X 3 right otolith image with manual framing.
#' @param imno Integer giving the otolith number, i.e. the file serial number in \code{list.files(input_path)}.
#' @param adj Numeric defining the intensity threshold.
#' @param fillparam Integer defining the morphological filter size used to fill holes within the otolith contour. Must be an odd number.
#' @param input_path Character defining the file path to input images.
#' @param output_path Character defining the file path where the processed images should be saved.
#' @param prefix Character or function defining the prefix for the image file. Modifications here might mess up the \code{\link{estimate_age}} function.
#' @param postfix Character or function defining the postfix for the image file. Must contain file extension, which defines the file format.
#' @param adjust_param Logical indicating whether the function should ask for new threshold (\code{adj}) and fill (\code{fillparam}) parameters when the user is not satisfied with the image quality.
#' @return Saves a jpg image in \code{output_path}. The file name is similar to the original images except the addition of \code{prefix} and \code{postfix}.
#' @author Tine Nilsen, Mikko Vihtakari, Kristin Windsland, Alf Harbitz (Institute of Marine Research, Norway)
#' @export

# Debugging parameters:
# imno = 1; adj = 1.35; fillparam = 15; input_path = file.path(system.file("extdata", package = "AgeEstimatoR"), "example_images", "input"); output_path = "inst/extdata/example_images/standardized/"; prefix = sprintf("%d_", imno); postfix = ".jpg"; adjust_param = TRUE

standardize_image <- function(
    imno, input_path, output_path,
    adj = 1.2, fillparam = 9,
    prefix = sprintf("%d_", imno),
    postfix = ".jpg",
    adjust_param = TRUE
    ) {

  if(!dir.exists(input_path)) {
    stop(input_path, " does not exist. Check the file path")
  }

  if(!dir.exists(output_path)) {
    ret.val <- utils::menu(
      choices = c("Yes", "No"),
      title = paste(output_path, "does not exist. Do you want to create the folder?")
    )

    if(ret.val != 1) {
      msg <- paste0(output_path, " does not exist. Check the file path or create the folder.")
      stop(paste(strwrap(msg), collapse= "\n"))
    } else {
      dir.create(output_path)
      msg <- paste0("Folder ", output_path, " created")
      message(paste(strwrap(msg), collapse= "\n"))
    }
  }

  # Function to ask whether the user is satisfied with the image

  imagetest <- function() {

    # ntest <- readline(prompt = "Image ok? (1, y, yes, or enter = yes, anything else = no): ") # this does not work for some reason
    # if(ntest == "" | ntest == 1 | ntest == "y" | ntest == "yes") ntest <- 1
    ntest <- utils::menu(choices = c("Yes", "No"), title = "Image ok?")

    if(ntest == 1) {
      listn <- list(ntest, adj, fillparam)
    } else {
      if(adjust_param) {
        cat("Adjustment factor (adj) = ", adj)
        n0 <- readline(prompt = "New threshold adjustment: ")
        adj <- as.numeric(n0)
        cat("Fill parameter (fillparam) = ",fillparam)
        n1 <- readline(prompt = "New fill parameter: ")
        fillparam <- as.numeric(n1)
      }

      listn <- list(0, adj, fillparam)
    }

    return(listn)
  }


  # Definitions
  ok <- 0 # ok = 1 when standard image looks ok
  scales <- 256
  message(sprintf("Image nr %d",imno))

  nashort <- normalizePath(list.files(input_path, full.names = TRUE)[imno]) # converts filename to character
  naname <- list.files(input_path)[imno]

  while (ok == 0) {

    im <- suppressWarnings(raster::stack(nashort))

    if(suppressWarnings(max(raster::values(im))>256)) {
      suppressWarnings({im <- im/256})
    }

    siz <- dim(im)# im size, siz(1) = #rows, siz(2) = #columns

    ## Plot
    graphics::par(bg = 'black',mfrow=c(1,1))

    suppressWarnings(raster::plotRGB(im))
    message("Press the picture twice to define the corners of the otolith photo. These corners will be used for cropping.")

    xxyy <- graphics::locator(2, type = "o") # reads upper left and lower right corners
    xx <- round(xxyy$x)
    yy <- round(xxyy$y)
    newdim <- raster::extent(xx[1],xx[2],yy[2],yy[1])
    im <- suppressWarnings(raster::crop(im, newdim))

    # Separate the individual raster layers
    rgbs <- raster::as.list(im)
    imr <- rgbs[[1]] # red component of im
    img <- rgbs[[2]] # green component of im
    imb <- rgbs[[3]] # blue component of im
    siz <- dim(im)

    #Isolate the blue component of image, convert to binary set of pixels using imager::threshold. Without further specification, imager::threshold will automatically choose the threshold value using a k-means clustering method. The output imbw is an image with 4 dimensions Width, Height, Depth, Colour channels.

    #  adj = mean(getValues(imb))/256+0.6
    #  print(adj)

    imbw <- 1 - imager::threshold(imager::as.cimg(imb), adjust = adj)
    imbw <- imager::fill(imbw,fillparam)

    #Check if grayscale image has black background in all corners

    #corners<-c(imbw[1,1],imbw[1,dim(imbw)[2]],imbw[dim(imbw)[1],1],imbw[dim(imbw)[1],dim(imbw)[2]])
    #if(any(corners!=0)){
    #print("you should check the background in the four corners")}

    jw <- which(imbw == 1)# indices to white pixels in bw image

    rows <- ((jw-1) %% siz[1]) + 1
    cols <- floor((jw-1) / siz[1]) + 1

    # finds indices to black pixels in bw image:
    a <- seq(1,(siz[1]*siz[2]))
    b <- jw
    jb <- setdiff(union(a,b), intersect(a,b))

    #The background color for the red-, green- and blue-component images is now changed to black color, by replacing all indices [jb] to value 0 (zero indicates black color in raster layer format)
    # Allocate 0's to all background pixels for red, green and blue comp.

    imr[jb] <- 0 # allocates 0 to background red-pixels
    img[jb] <- 0 # allocates 0 to background green-pixels
    imb[jb] <- 0 # allocates 0 to background blue-pixels

    #Finally, the red- green and blue component raster layers are bricked together to obtain the complete three-layer raster.


    #Here is the new image with otolith in color, and black background.

    imrc <- imager::autocrop(imager::as.cimg(imr))
    imgc <- imager::autocrop(imager::as.cimg(img))
    imbc <- imager::autocrop(imager::as.cimg(imb))

    nr<-max(dim(imrc)[1:2])
    cr<-min(dim(imrc)[1:2])


    sizbox = dim(imrc)  # extends box so that otolith extension fills 90 % of image extension
    lsiz = ceiling(max(sizbox)*1.1)      # in some cases the extension might be in the x-direction

    imr <- raster::raster(lidaRtRee::cimg2Raster(imrc))
    img <- raster::raster(lidaRtRee::cimg2Raster(imgc))
    imb <- raster::raster(lidaRtRee::cimg2Raster(imbc))

    dlx1 <- floor((lsiz-cr)/2)# number of extension pixels to the left of otolith
    dlx2 <- lsiz-cr-dlx1# number of extension pixels to the right of otolith
    dly1 <- floor((lsiz-nr)/2)# number of extension pixels above otolith
    dly2 <- lsiz-nr-dly1# number of extension pixels below otolith


    imrc2 <- imager::pad(imrc,dlx1,pos=-1,"x")
    imrc2 <- imager::pad(imrc2,dlx2,pos=1,"x")
    imrc2 <- imager::pad(imrc2,dly1,pos=-1,"y")
    imrc2 <- imager::pad(imrc2,dly2,pos=1,"y")

    imgc2 <- imager::pad(imgc,dlx1,pos=-1,"x")
    imgc2 <- imager::pad(imgc2,dlx2,pos=1,"x")
    imgc2 <- imager::pad(imgc2,dly1,pos=-1,"y")
    imgc2 <- imager::pad(imgc2,dly2,pos=1,"y")

    imbc2 <- imager::pad(imbc,dlx1,pos=-1,"x")
    imbc2 <- imager::pad(imbc2,dlx2,pos=1,"x")
    imbc2 <- imager::pad(imbc2,dly1,pos=-1,"y")
    imbc2 <- imager::pad(imbc2,dly2,pos=1,"y")

    imrc3 <- imager::resize(imrc2,scales,scales)
    imgc3 <- imager::resize(imgc2,scales,scales)
    imbc3 <- imager::resize(imbc2,scales,scales)

    imr <- raster::raster(lidaRtRee::cimg2Raster(imrc3))
    img <- raster::raster(lidaRtRee::cimg2Raster(imgc3))
    imb <- raster::raster(lidaRtRee::cimg2Raster(imbc3))

    imnew <- raster::brick(imr,img,imb)


    graphics::par(bg = 'black',mfrow=c(1,2))
    raster::plotRGB(im)
    raster::plotRGB(imnew)

    # Ask the used whether they are satisfied with the image
    okout <- imagetest()

    ok <- okout[[1]]

    if (ok == 0) {
      adj <- okout[[2]]
      fillparam <- okout[[3]]
    }
  }

  output_file <- file.path(
    output_path,
    paste0(prefix, tools::file_path_sans_ext(naname), postfix)
  )

  if(grepl("jpg|jpeg", postfix)) {
  grDevices::jpeg(file = output_file, w = scales, h = scales, bg = "black")
  raster::plotRGB(imnew)
  grDevices::dev.off()
  } else {
    stop("Other devices than .jpg have not been implemented")
  }
  message(output_file, " created")
}

#' @title A wrapper to standardize multiple otolith images for age estimation by deep learning
#' @description A wrapper function for \code{\link{standardize_image}} allowing standardization of all images within a folder
#' @param images If \code{NULL}, processes all images in \code{input_path}. If an integer vector, processes images in the alphabetic order within the directory.
#' @param ... Arguments passed to \code{\link{standardize_image}}.
#' @inheritParams standardize_image
#' @return Saves multiple jpg images in \code{output_path}. The file names are similar to the original images except the addition of \code{prefix} and \code{postfix}.
#' @export

standardize_images <- function(input_path, output_path, images = NULL, ...) {

  if(is.null(images)) {
    images <- 1:length(list.files(input_path))
  }

  for (imno in images) {
    standardize_image(imno, input_path = input_path, output_path = output_path, ...)
  }
}

