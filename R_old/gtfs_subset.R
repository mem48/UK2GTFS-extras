# stops_inc <- stops_inc[stops_inc$stop_lon > bbox[1], ]
# stops_inc <- stops_inc[stops_inc$stop_lon < bbox[3], ]
# stops_inc <- stops_inc[stops_inc$stop_lat > bbox[2], ]
# stops_inc <- stops_inc[stops_inc$stop_lat < bbox[4], ]
# stops2 <- sf::st_as_sf(stops_inc, coords = c("stop_lon","stop_lat"), crs = 4326)
# qtm(stops2)

#tripids <- unique(stop_times$trip_id[stop_times$stop_id %in% stops_inc$stop_id])
#gtfs <- gtfs_split_ids(gtfs, tripids)
#gtfs <- gtfs$true