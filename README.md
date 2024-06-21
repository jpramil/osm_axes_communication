# osm_axes_communication

Extract major roads, rails and transport hubs from OSM using R package `osmdata`

## Find OSM objects using `osmdata` : 

```r
available_features()
available_tags("highway")
```

## Results

Gpkg files exported in `s3/jpramil/BDTopo` folder.

![Preview of the map](https://jpramil.github.io/osm_axes_communication/docs/map.html)