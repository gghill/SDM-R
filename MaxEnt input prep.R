## MaxEnt Testing
# Setup ----
require(maxent)
library(wallace)
run_wallace() # shiny app for interactive selection of data
# instead let's see if we can make a script for data prep for
# input directly into MaxEnt
library(sf)
library(raster)
library(rgdal)
library(tidyverse)
library(rgeos)
library(scales)
library(fasterize)
# set up projection parameter for use throughout script
projection <- "+proj=longlat +ellps=WGS84 +datum=WGS84 +no_defs"
ext <- extent(-100,45,30.75,72.5)
# load layers and crop to chosen extent
SST <- load_layers(c("BO2_tempmean_ss", "BO2_tempmin_ss", "BO2_tempmax_ss","BO2_temprange_ss"))
temp_crop <- crop(SST,ext)
surface <- c("BO2_chlomean_bdmin","BO2_curvelmean_bdmin","BO2_tempmean_bdmin")
surf_layers <- load_layers(surface)
surf_crop <- crop(surf_layers,ext)
# Preparing data as input to MaxEnt ----
## resampling ----
# need to select one variable to resample the others to
# picking the highest resolution will take longer, but can yield
# better results
?resample
temp_resampled <-as.list(NULL)
target <- temp_crop[[1]]
for (i in 1:length(temp_crop@data@names)) {
  r <- resample(temp_crop[[i]], target)
  temp_resampled <- append(temp_resampled,r)
}
names(temp_resampled) <- temp_crop@data@names
temp_resampled
# do the same for the other surface layers
surf_resampled <-as.list(NULL)
for (i in 1:length(surf_crop@data@names)) {
  r <- resample(surf_crop[[i]], target)
  surf_resampled <- append(surf_resampled,r)
}
names(surf_resampled) <- surf_crop@data@names
surf_resampled

## extend to make sure shared extent is equal after resampling ----
temp_rextend <- as.list(NULL)
for (i in temp_resampled) {
  r <- extend(i, ext, value = NA)
  temp_rextend <- append(temp_rextend,r)
}
names(temp_rextend) <- temp_crop@data@names
temp_rextend

surf_rextend <- as.list(NULL)
for (i in surf_resampled) {
  r <- extend(i, ext, value = NA)
  surf_rextend <- append(surf_rextend,r)
}
names(surf_rextend) <- surf_crop@data@names
surf_rextend

## write out files into .asc format for input into MaxEnt GUI
setwd('./MaxEnt')
extend_raster_list <- list(temp_rextend, surf_rextend)
names(extend_raster_list) <- c('temp', 'surf')
for (i in extend_raster_list) {
  for (k in i) {
    n <- names(k)
    writeRaster(k, 
                filename=paste0(n,'.asc'), 
                format='ascii', 
                overwrite=TRUE)
  }
}


