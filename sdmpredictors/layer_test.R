# Bio-ORACLE explo
# based primarily on: https://bio-oracle.org/code.php

# SETUP ----
require(sdmpredictors)
require(leaflet)
require(raster)
library(httr)
require(ggplot2)
require(dplyr)
require(tidyverse)
options(timeout = max(300, getOption("timeout")))
options(sdmpredictors_datadir="BioOracle_R/sdmpredictors")

# Look at datasets ----
list_datasets()
layers_ver2 <- list_layers(datasets = "Bio-ORACLE", version = 2)
layers_ver1 <- list_layers(datasets = "Bio-ORACLE", version = 1)

## Extract layers of interest ----
SST_names <- c("BO2_tempmean_ss", "BO2_tempmin_ss", "BO2_tempmax_ss","BO2_temprange_ss")
layer_stats(SST_names)
SST <- load_layers(c("BO2_tempmean_ss", "BO2_tempmin_ss", "BO2_tempmax_ss","BO2_temprange_ss"))

## Plot some temperature layers in the NE Atlantic ----
ne.atl.ext <- extent(-100,45,30.75,72.5)
temp_crop <- crop(SST,ne.atl.ext) # can crop multiple rasters aka raster stack at once

my.colors = colorRampPalette(c("#5E85B8","#EDF0C0","#C13127"))
plot(temp_crop, col = my.colors(1000), axes = FALSE, box = FALSE)

# Look at surface layers ----
layers_ver2
surface <- c("BO2_chlomean_bdmin","BO2_curvelmean_bdmin","BO2_tempmean_bdmin")
surf_layers <- load_layers(surface)

## Read in some test sites with name, lat, long ----
# Use leaflet to plot and mark on a map
my_sites <- read.delim("sdmpredictors/test_sites.txt")
m <- leaflet()
m <- addTiles(m)
m <- addMarkers(m,
                lng = my_sites$Long, 
                lat = my_sites$Lat, 
                popup = my_sites$Name)
m
# Attempt to plot rasters based around my sites
# extent units are lat/long so can use min-max to set range, but not square
my_sites_ext <- extent(min(my_sites$Long)-10,
                       max(my_sites$Long)+10,
                           min(my_sites$Lat)-10,
                           max(my_sites$Lat)+10)
# surf layers = layer stack, need to crop to area of interest
surf_crop <- crop(surf_layers,my_sites_ext)
# stack may not be as useful as previously thought, will usually manipulate one
# at a time anyway
for (i in surf_crop@data@names) { # janky for loop to plot one layer at a time
  plot(surf_crop[[i]], col = my.colors(1000), box=FALSE)
  title(main = paste(i))
  text(x=my_sites$Long,y=my_sites$Lat,labels = paste(my_sites$Name))
  Sys.sleep(3)
}
plot(surf_crop, col = my.colors(1000), box=FALSE)
text(x=my_sites$Long,y=my_sites$Lat,labels = paste(my_sites$Name)) # doesn't label each

# next steps: labels on each, redo with ggplot
# Current velocity explo ----
# goal: identify areas with current between 10 and 100 cms and plot with ggplot2
surf_vel_max <- load_layers(c("BO2_curvelmax_bdmin","BO2_curvelmin_bdmin"))
surf_vel_crop <- crop(surf_vel_max, )
plot(surf_vel_max[[1]])
# Need to convert m/s to cm/s (multiply by 100)
vel_max <- as.data.frame(surf_vel_max[[1]],xy=TRUE)
vel_min <- as.data.frame(surf_vel_max[[2]],xy=TRUE)
names(vel_min) <- c("x","y","Minimum Surface Current v")
ggplot(data = vel_min) +
  geom_raster(mapping=aes(x=x, y=y, fill=(`Minimum Surface Current v`)*100)) +
  scale_fill_gradientn(colours= rev(terrain.colors(10)), name='Minimum Surface current velocity') +
  theme(axis.line=element_blank(),
        axis.text.x=element_blank(),
        axis.text.y=element_blank(),
        axis.ticks=element_blank(),
        axis.title.x=element_blank(),
        axis.title.y=element_blank(),
        #legend.position="none",
        panel.background=element_blank(),
        panel.border=element_blank(),
        panel.grid.major=element_blank(),
        panel.grid.minor=element_blank(),
        plot.background=element_blank())

# attempt to color just based on min max range
vel_comb <- cbind(vel_min,vel_max$BO2_curvelmax_bdmin)
names(vel_comb) <- c("x","y","Minimum Surface Current v","Maximum Surface Current v")

names(vel_comb)

vel_comb_mut <- mutate(vel_comb,
                       threshold = ifelse(100 > vel_comb$`Minimum Surface Current v`*100 & vel_comb$`Minimum Surface Current v`*100 > 10 & 10 < vel_comb$`Maximum Surface Current v`*100 & vel_comb$`Maximum Surface Current v`*100 < 100,
                                          (vel_comb$`Minimum Surface Current v`*100+vel_comb$`Maximum Surface Current v`*100)/2,0)
)

ggplot(data = vel_comb_mut) +
  geom_raster(mapping=aes(x=x, y=y, fill=(threshold))) +
  scale_fill_gradientn(colours= my.colors(10), name='10 < Surface current velocity < 100') +
  theme(axis.line=element_blank(),
        axis.text.x=element_blank(),
        axis.text.y=element_blank(),
        axis.ticks=element_blank(),
        axis.title.x=element_blank(),
        axis.title.y=element_blank(),
        #legend.position="none",
        panel.background=element_blank(),
        panel.border=element_blank(),
        panel.grid.major=element_blank(),
        panel.grid.minor=element_blank(),
        plot.background=element_blank())
