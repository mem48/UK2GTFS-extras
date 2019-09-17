# read in files

master <- read.csv("../mem48/UK2GTFS-extras/data/missing_naptan.csv", stringsAsFactors = FALSE)

fmt1 <- read.csv("../mem48/UK2GTFS-extras/data/fixmytransport_missing_stops.csv",
                 stringsAsFactors = FALSE,
                 sep = "\t")
fmt2 <- read.csv("../mem48/UK2GTFS-extras/data/fixmytransport_missing_stops_regional.csv",
                 stringsAsFactors = FALSE,
                 sep = "\t")
fmt3 <- read.csv("../mem48/UK2GTFS-extras/data/fixmytransport_unmapped_stops.csv",
                 stringsAsFactors = FALSE,
                 sep = "\t")


summary(master$stop_id %in% fmt3$ATCO.code)

naptan <- UK2GTFS::get_naptan()

summary(master$stop_id %in% naptan$stop_id)
summary(fmt3$ATCO.code %in% naptan$stop_id)


new <- fmt3[!fmt3$ATCO.code %in% naptan$stop_id,]
names(new) <- c("stop_id","stop_name","Easting","Northing","Locality.ID")
new$Locality.ID <- NULL

library(sf)
new_noccords <- new[new$Easting == -1, ]
new_coords <- st_as_sf(new[new$Easting != -1, ], coords = c("Easting","Northing"), crs = 27700)
new_coords <- st_transform(new_coords, 4326)
new_coords <- new_coords[!new_coords$stop_id %in% c("900014685","AIMZEE"),]
new_coords <- cbind(new_coords, st_coordinates(new_coords))
new_coords <- st_drop_geometry(new_coords)
names(new_coords) <- c("stop_id","stop_name", "stop_lon","stop_lat")
new_coords$stop_code <- NA
new_coords <- new_coords[names(master)]
summary(new_coords$stop_id %in% master$stop_id)
new_coords <- new_coords[!new_coords$stop_id %in% master$stop_id,]
res <- rbind(master, new_coords)

write.csv(res, "../mem48/UK2GTFS-extras/data/missing_naptan.csv", row.names = FALSE, na = "")
