# readin in files

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
