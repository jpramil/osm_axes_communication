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
  opq() %>%
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

if (!dir.exists("output")) {
  dir.create("output")
}

output_file <- "output/lyon_map.html"
htmlwidgets::saveWidget(m, file = output_file, selfcontained = TRUE)

# Exporter les objets spatiaux dans le fichier GeoPackage

BUCKET_OUT = "<mon_bucket>"
FILE_KEY_OUT_S3 = "mon_dossier/BPE_ENS.csv"

aws.s3::s3write_using(
  lyon_autoroutes$osm_lines,
  FUN = sf::st_write,
  object = FILE_KEY_OUT_S3,
  bucket = BUCKET_OUT,
  opts = list("region" = "")
)

output_gpkg <- "output/lyon_axes_transports.gpkg"
sf::st_write(lyon_autoroutes$osm_lines, dsn = output_gpkg, layer = "autoroutes", driver = "GPKG",delete_dsn = TRUE)
sf::st_write(lyon_trunk$osm_lines, dsn = output_gpkg, layer = "trunk", driver = "GPKG", append = TRUE)
sf::st_write(lyon_rail$osm_lines, dsn = output_gpkg, layer = "rail", driver = "GPKG", append = TRUE)
sf::st_write(lyon_perrache$osm_points, dsn = output_gpkg, layer = "gare_perrache", driver = "GPKG", append = TRUE)
sf::st_write(lyon_partdieu$osm_points, dsn = output_gpkg, layer = "gare_partdieu", driver = "GPKG", append = TRUE)
sf::st_write(lyon_airports$osm_polygons, dsn = output_gpkg, layer = "airports", driver = "GPKG", append = TRUE)

bucket_name <- "jpramil"
output_file <- "BDTopo/lyon_axes_transports.gpkg"
aws.s3::put_object(file = output_gpkg, bucket = bucket_name)
