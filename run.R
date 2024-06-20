install.packages("osmdata")
library(osmdata)
available_features()
toto <- available_tags("highway")


lyon_bb <- c(4.452209,45.402307,5.381927,46.095138)
# lyon_bb <- getbb("Métropole de Lyon, France")
# class(lyon_bb)
lyon_autoroutes <- lyon_bb %>%
  opq() %>%
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
  opq() %>%
  add_osm_feature(key = "aeroway", value = "aerodrome") %>%
  add_osm_feature(key = "aerodrome", value = "international") %>%
  osmdata_sf()



mapview::mapview(lyon_autoroutes$osm_lines)+
  mapview::mapview(lyon_trunk$osm_lines)+
  mapview::mapview(lyon_rail$osm_lines, color="red")+
  mapview::mapview(lyon_perrache$osm_points, col.regions="green")+
  mapview::mapview(lyon_partdieu$osm_points, col.regions="green")+
  mapview::mapview(lyon_airports$osm_polygons, col.regions="green")
