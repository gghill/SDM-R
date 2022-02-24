# Bio-ORACLE explo

require(sdmpredictors)
require(leaflet)
library(httr)
options(timeout = max(300, getOption("timeout")))
options(sdmpredictors_datadir="/sdmpredictors")

list_datasets()
layers_ver2 <- list_layers(datasets = "Bio-ORACLE", version = 2)
layers_ver1 <- list_layers(datasets = "Bio-ORACLE", version = 1)

SST_names <- c("BO2_tempmean_ss", "BO2_tempmin_ss", "BO2_tempmax_ss","BO2_temprange_ss")
layer_stats(SST_names)
SST <- load_layers(c("BO2_tempmean_ss", "BO2_tempmin_ss", "BO2_tempmax_ss","BO2_temprange_ss"))
# appears to be a Mojave specific CA certificate problem preventing progress
# on any of these layers
