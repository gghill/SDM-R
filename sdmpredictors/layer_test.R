# Bio-ORACLE explo

require(sdmpredictors)
require(leaflet)

library(httr)
set_config(config(ssl_verifypeer = 0L))
path <- getwd()

list_datasets()
layers_ver2 <- list_layers(datasets = "Bio-ORACLE", version = 2)
layers_ver1 <- list_layers(datasets = "Bio-ORACLE", version = 1)

SST_names <- c("BO2_tempmean_ss", "BO2_tempmin_ss", "BO2_tempmax_ss","BO2_temprange_ss")
layer_stats(SST_names)
SST <- load_layers(c("BO2_tempmean_ss", "BO2_tempmin_ss", "BO2_tempmax_ss","BO2_temprange_ss"))
SST_range <- download.file("https://bio-oracle.org/data/2.0/Present.Surface.Temperature.Mean.tif.zip",
                           "Present.Surface.Temperature.Mean.tif.zip")
# appears to be a Mojave specific CA certificate problem preventing progress
# on any of these layers
