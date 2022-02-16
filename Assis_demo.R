
# Load packages
library(ggplot2)
library(raster)
library(rnaturalearth)
library(sf)
library(geosphere)
library(rgeos)

# Setting the working directory
setwd("jorgeassis dataVisualization master Projects-seaSurfaceOxygen_Data")

# Choose an equal area  projection
projection <- CRS("+proj=robin +over")

# Generate a bounding box for the map
bb <- sf::st_union(sf::st_make_grid(
  st_bbox(c(xmin = -180,
            xmax = 180,
            ymax = 90,
            ymin = -90), crs = st_crs(4326)), n = 100))
bb <- st_transform(bb, projection)

# Read oxygen layer
oxygenLayer <- raster("Data/DissolvedMolecularOxygen.tif")
oxygenLayer <- projectRaster(oxygenLayer, crs = projection)
oxygenLayer <- mask(oxygenLayer, as(bb, "Spatial"))
oxygenLayer <- as.data.frame(oxygenLayer,xy=TRUE,na.rm=T)
colnames(oxygenLayer) <- c("Lon","Lat","Val")

# Read the shapefile depicting global landmasses
worldMap <- shapefile("Data/LandMass Polygon.shp")
worldMap <- spTransform(worldMap, CRSobj = projection)
worldMap <- gBuffer(worldMap, byid=TRUE, width=0.001)
worldMap <- crop(worldMap, as(bb, "Spatial"))

## -----------------

theme_map <- 
  theme(
    text = element_text(family = "Helvetica", color = "#22211d"),
    axis.text.x = element_blank(),
    axis.text.y = element_blank(),
    axis.ticks = element_blank(),
    axis.title.x = element_blank(),
    axis.title.y = element_blank(),
    panel.grid.major = element_line(color = "black", size = 0.1),
    panel.grid.minor = element_blank(),
    plot.background = element_rect(fill = "#FFFFFF", color = NA),
    panel.background = element_rect(fill = "#FFFFFF", color = NA),
    panel.border = element_blank(),
    legend.background = element_rect(fill = "#FFFFFF", color = NA),
    legend.position="bottom", 
    legend.box = "horizontal",
    legend.margin=margin(0,0,0,0),
    legend.box.margin=margin(-10,-10,-10,-10),
    legend.key.height= unit(0.25, 'cm'),
    legend.key.width= unit(0.75, 'cm') )

## -----------------

# Continuous
myColors <- c("#6FBBE8","#A1ECD8","#F6F9AB","#FCB46D","#B21414")
myColors <- c("#6FBBE8","#A1ECD8","#F6F9AB","#FCB46D","#B21414","#D278E4","#9914B3")

plot <- ggplot() +
  geom_tile(data = oxygenLayer, aes(x=Lon,y=Lat,fill=Val)) +
  scale_fill_gradientn(guide = guide_legend(title="Sea surface dissolved oxygen [mmol.m3]", direction = "horizontal", title.position = "top", title.hjust = 0.5), colours=myColors, na.value='transparent') +
  geom_polygon(data = worldMap, aes(x = long, y = lat, group = group), fill="#CACACA", colour = "#CACACA" , size=0.25 ) +
  geom_sf(data = bb,fill=NA, colour = "white" , linetype='solid', size=2 ) +
  theme_map
plot
