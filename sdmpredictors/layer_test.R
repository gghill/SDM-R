# Bio-ORACLE explo

require(sdmpredictors)
require(leaflet)

library(sdmpredictors)

list_datasets()
layers_ver2 <- list_layers(datasets = "Bio-ORACLE", version = 2)
layers_ver1 <- list_layers(datasets = "Bio-ORACLE", version = 1)

SST_names <- c("BO2_tempmean_ss", "BO2_tempmin_ss", "BO2_tempmax_ss","BO2_temprange_ss")
layer_stats(SST_names)
SST <- load_layers(c("BO2_tempmean_ss", "BO2_tempmin_ss", "BO2_tempmax_ss","BO2_temprange_ss"))
SST_range <- load_layers("BO2_temprange_ss")
