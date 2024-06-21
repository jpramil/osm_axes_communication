library(osmdata)
library(leaflet)

# Define Lyon bbox (enjoy http://bboxfinder.com/#45.402307,4.452209,46.095138,5.381927)
lyon_bb <- c(4.452209, 45.402307, 5.381927, 46.095138)

# Extract spatial objects
lyon_autoroutes <- lyon_bb %>%
  opq(timeout = 60) %>%
  add_osm_feature(key = "highway", value = "motorway") %>%
  osmdata_sf()

lyon_trunk <- lyon_bb %>%
  opq() %>%
  add_osm_feature(key = "highway", value = "trunk") %>%
  osmdata_sf()

lyon_perrache <- lyon_bb %>%
  opq() %>%
  add_osm_feature(key = "railway", value = "station") %>%
  add_osm_feature(key = 'operator', value = 'SNCF') %>% 
  add_osm_feature(key = 'name', value = 'Lyon-Perrache') %>%
  osmdata_sf()

lyon_partdieu <- lyon_bb %>%
  opq() %>%
  add_osm_feature(key = "railway", value = "station") %>%
  add_osm_feature(key = 'operator', value = 'SNCF') %>% 
  add_osm_feature(key = 'name', value = 'Lyon Part-Dieu') %>%
  osmdata_sf()

lyon_rail <- lyon_bb %>%
  opq(timeout = 60) %>%
  add_osm_feature(key = "railway", value = "rail") %>%
  add_osm_feature(key = 'highspeed', value = 'yes') %>% 
  osmdata_sf()

lyon_airports <- lyon_bb %>%
  opq(timeout = 60) %>%
  add_osm_feature(key = "aeroway", value = "aerodrome") %>%
  add_osm_feature(key = "aerodrome", value = "international") %>%
  osmdata_sf()


# Plot spatial objects ---------------------------------------------------------
m <- leaflet() %>%
  addTiles()

# Ajouter les couches des autoroutes
m <- m %>%
  addPolylines(data = lyon_autoroutes$osm_lines, color = "blue", group = "Autoroutes") %>%
  addPolylines(data = lyon_trunk$osm_lines, color = "orange", group = "Routes principales") %>%
  addPolylines(data = lyon_rail$osm_lines, color = "red", group = "Lignes ferroviaires") %>%
  addCircleMarkers(data = lyon_perrache$osm_points, color = "green", group = "Gare Perrache") %>%
  addCircleMarkers(data = lyon_partdieu$osm_points, color = "green", group = "Gare Part-Dieu") %>%
  addPolygons(data = lyon_airports$osm_polygons, color = "purple", group = "Aéroports")

# Ajouter des contrôles de couches pour permettre l'activation/désactivation des couches
m <- m %>%
  addLayersControl(
    overlayGroups = c("Autoroutes", "Routes principales", "Lignes ferroviaires", "Gare Perrache", "Gare Part-Dieu", "Aéroports"),
    options = layersControlOptions(collapsed = FALSE)
  )


# Exports -----------------------------------------------------------------------

if (!dir.exists("docs")) {
  dir.create("docs")
}

output_file <- "docs/lyon_map.html"
htmlwidgets::saveWidget(m, file = output_file, selfcontained = TRUE)

# Exporter les objets spatiaux dans un seul fichier GeoPackage

BUCKET_OUT = "jpramil"

aws.s3::s3write_using(
  lyon_autoroutes$osm_lines,
  FUN = sf::st_write,
  delete_dsn = TRUE,
  object = "BDTopo/lyon_autoroutes.gpkg",
  bucket = BUCKET_OUT,
  opts = list("region" = "")
)

aws.s3::s3write_using(
  x = lyon_trunk$osm_lines,
  FUN = sf::st_write,
  delete_dsn = TRUE,
  object = "BDTopo/lyon_trunk.gpkg",
  bucket = BUCKET_OUT,
  opts = list("region" = "")
)

aws.s3::s3write_using(
  x = lyon_rail$osm_lines,
  FUN = sf::st_write,
  delete_dsn = TRUE,
  object = "BDTopo/lyon_rail.gpkg",
  bucket = BUCKET_OUT,
  opts = list("region" = "")
)

aws.s3::s3write_using(
  x = lyon_perrache$osm_points,
  FUN = sf::st_write,
  delete_dsn = TRUE,
  object = "BDTopo/lyon_perrache.gpkg",
  bucket = BUCKET_OUT,
  opts = list("region" = "")
)

aws.s3::s3write_using(
  x = lyon_partdieu$osm_points,
  FUN = sf::st_write,
  delete_dsn = TRUE,
  object = "BDTopo/lyon_partdieu.gpkg",
  bucket = BUCKET_OUT,
  opts = list("region" = "")
)

aws.s3::s3write_using(
  x = lyon_airports$osm_polygons,
  FUN = sf::st_write,
  delete_dsn = TRUE,
  object = "BDTopo/lyon_airports.gpkg",
  bucket = BUCKET_OUT,
  opts = list("region" = "")
)


# # Import again : 
# 
# BUCKET <- "jpramil"
# sf_lyon_axes_transports <- 
#   aws.s3::s3read_using(
#     FUN = sf::st_read,
#     object = "BDTopo/lyon_perrache.gpkg",
#     bucket = BUCKET,
#     opts = list("region" = "")
#   )
# 






