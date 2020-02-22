load("data/rail.rda")
library(sf)
library(tmap)
rail_heavy <- rail[rail$type == "rail",]
rail_heavy2 <- sf::st_transform(rail_heavy, 27700)
rail_heavy2 <- sf::st_simplify(rail_heavy2, 10, preserveTopology = TRUE)
as.numeric(object.size(rail_heavy2)) / as.numeric(object.size(rail_heavy))
qtm(rail_heavy[1:500,], lines.col = "red") + qtm(rail_heavy2[1:500,], lines.col = "blue")


geom <- st_combine(rail_heavy2)
geom <- st_line_merge(geom)
geom <- st_cast(geom, "LINESTRING")
as.numeric(object.size(geom)) / as.numeric(object.size(rail_heavy2$geometry))
qtm(geom)
rail_heavy3 <- data.frame(id = seq(1, length(geom)),
                          geometry = geom)
rail_heavy3 <- st_as_sf(rail_heavy3, crs = 27700)
rail_heavy3$length <- as.numeric(st_length(rail_heavy3))
hist(rail_heavy3$length)
qtm(rail_heavy3[rail_heavy3$length < 100,], lines.lwd = 3)
rail_heavy4 <- st_simplify(rail_heavy3, 10, preserveTopology = TRUE)
as.numeric(object.size(rail_heavy4$geometry)) / as.numeric(object.size(rail_heavy3$geometry))
as.numeric(object.size(rail_heavy4$geometry)) / as.numeric(object.size(rail_heavy$geometry))
write_sf(st_transform(rail_heavy4, 4326), "data/rail_heavy.gpkg")

rail_heavy5 <- st_combine(rail_heavy$geometry)
rail_heavy5 <- st_line_merge(rail_heavy5)
rail_heavy5 <- st_cast(rail_heavy5, "LINESTRING")
as.numeric(object.size(rail_heavy5)) / as.numeric(object.size(rail_heavy$geometry))
rail_heavy5 <- data.frame(id = seq(1, length(rail_heavy5)),
                          geometry = rail_heavy5)
rail_heavy5 <- st_as_sf(rail_heavy5, crs = 4326)
rail_heavy5 <- st_transform(rail_heavy5, 27700)
write_sf(st_transform(rail_heavy5, 4326), "data/rail_heavy.gpkg")
rail_heavy <- st_transform(rail_heavy5, 4326)
usethis::use_data(rail_heavy)
# check station provimits
rail_points <- st_cast(rail_heavy5, "POINT")
rail_points <- st_coordinates(rail_points)
load("./data/tiplocs.rda")
write_sf(tiplocs,"data/tiplocs.gpkg")
tl <- st_transform(tiplocs, 27700)


tl <- cbind(tl, st_coordinates(tl))
tl <- st_drop_geometry(tl)

near <- RANN::nn2(data = rail_points[,c("X","Y")], query = tl[,c("X","Y")], k = 1)
tl$dist <- as.numeric(near$nn.dists)

tl_far <- tl[tl$dist > 100,]
tl_far <- st_as_sf(tl_far, coords = c("X","Y"), crs = 27700)
qtm(tl_far)

timetables <- readRDS("vignettes/ATOC_timetables.Rds")
stops <- timetables$stops
stops <- st_as_sf(stops, coords = c("stop_lon","stop_lat"), crs = 4326)
stops <- st_transform(stops, 27700)
stops <- cbind(stops, st_coordinates(stops))
stops <- st_drop_geometry(stops)

near <- RANN::nn2(data = rail_points[,c("X","Y")], query = stops[,c("X","Y")], k = 1)
stops$dist <- as.numeric(near$nn.dists)

stops_far <- stops[stops$dist > 100 & stops$dist < 10000,]
stops_far <- st_as_sf(stops_far, coords = c("X","Y"), crs = 27700)
qtm(stops_far)
