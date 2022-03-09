# Bio-ORACLE explo
# based primarily on: https://bio-oracle.org/code.php

require(sdmpredictors)
require(leaflet)
require(raster)
library(httr)
options(timeout = max(300, getOption("timeout")))
options(sdmpredictors_datadir="BioOracle_R/sdmpredictors")

list_datasets()
layers_ver2 <- list_layers(datasets = "Bio-ORACLE", version = 2)
layers_ver1 <- list_layers(datasets = "Bio-ORACLE", version = 1)

SST_names <- c("BO2_tempmean_ss", "BO2_tempmin_ss", "BO2_tempmax_ss","BO2_temprange_ss")
layer_stats(SST_names)
SST <- load_layers(c("BO2_tempmean_ss", "BO2_tempmin_ss", "BO2_tempmax_ss","BO2_temprange_ss"))

ne.atl.ext <- extent(-100,45,30.75,72.5)
temp_crop <- crop(SST,ne.atl.ext) # can crop multiple rasters aka raster stack at once

my.colors = colorRampPalette(c("#5E85B8","#EDF0C0","#C13127"))
plot(temp_crop, col = my.colors(1000), axes = FALSE, box = FALSE)

# download some environmental layers
layers_ver2
surface <- c("BO2_chlomean_bdmin","BO2_curvelmean_bdmin","BO2_tempmean_bdmin")
surf_layers <- load_layers(surface)

my_sites <- read.delim("sdmpredictors/test_sites.txt")
m <- leaflet()
m <- addTiles(m)
m <- addMarkers(m,
                lng = my_sites$Long, 
                lat = my_sites$Lat, 
                popup = my_sites$Name)
m
my_sites_ext <- extent(min(my_sites$Long)-10,
                       max(my_sites$Long)+10,
                           min(my_sites$Lat)-10,
                           max(my_sites$Lat)+10)
surf_crop <- crop(surf_layers,my_sites_ext)
for (i in surf_crop@data@names) {
  plot(surf_crop[[i]], col = my.colors(1000), box=FALSE)
  title(main = paste(i))
  text(x=my_sites$Long,y=my_sites$Lat,labels = paste(my_sites$Name))
  Sys.sleep(3)
}
plot(surf_crop[[2]], col = my.colors(1000), box=FALSE)
text(x=my_sites$Long,y=my_sites$Lat,labels = paste(my_sites$Name))
# next steps: labels on each, redo with ggplot
