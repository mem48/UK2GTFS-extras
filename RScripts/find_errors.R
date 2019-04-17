# Find GTFS Validation Errors:

gtfs_list = gtfs_all

for(i in 1:length(gtfs_list)){
  routes <- gtfs_list[[i]]$routes
  if("744SIM" %in% routes$agency_id){
    stop(paste0("Found in ",i))
  }

}

agency <- gtfs_list[[i]]$agency

for(i in 1:length(gtfs_batch)){
  stops <- gtfs_list[[i]]$stops
  if("The Highwayman" %in% stops$stop_name){
    message(paste0("Found in ",i))
  }

}

for(i in 1:length(gtfs_batch)){
  stops <- gtfs_list[[i]]$stops
  if("2900W0913" %in% stops$stop_id){
    message(paste0("Found in ",i))
  }

}


stop_times <- gtfs_list[[i]]$stop_times
notes_all = lapply(res_batch, function(x){x$VehicleJourneys_notes})
notes_all <- dplyr::bind_rows(notes_all)

for(i in 1:length(res_batch)){
  VehicleJourneys_notes <- res_batch[[i]]$VehicleJourneys_notes
  # Check Notes
  notecodes_flex <- "DRT1"
  notecodes_school <- c("SchO","LRC","LRO")
  if(nrow(VehicleJourneys_notes) > 0){
    if(!all(VehicleJourneys_notes$NoteCode %in% c(notecodes_flex, notecodes_school))){
      notecodes_unknown <- unique(VehicleJourneys_notes$NoteCode)
      notecodes_unknown <- notecodes_unknown[!notecodes_unknown %in% c(notecodes_flex, notecodes_school)]
      stop("In ",i," unknown Note Type", notecodes_unknown)
    }
  }

}

# Speed checks
stops <- gtfs_merged$stops
stop_times <-  gtfs_merged$stop_times


speed <- dplyr::left_join(stop_times, stops, by = "stop_id")
#speed <- speed[,c("departure_time","stop_sequence","stop_lon","stop_lat")]
speed$stop_lon <- as.numeric(speed$stop_lon)
speed$stop_lat <- as.numeric(speed$stop_lat)
speed$stop_sequence <- as.numeric(speed$stop_sequence)

speed$departure_time <- lubridate::hms(speed$departure_time)
travel_time <- speed$departure_time[seq(2,length(speed$departure_time))] -
  speed$departure_time[seq(1,length(speed$departure_time)-1)]
travel_time <-  c(0, as.numeric(travel_time))
travel_time[travel_time == 0] <- 20
speed$travel_time <- travel_time

from <- matrix(c(speed$stop_lon[seq(1,length(speed$stop_lon)-1)],
                 speed$stop_lat[seq(1,length(speed$stop_lon)-1)]),
               ncol = 2)

to <- matrix(c(speed$stop_lon[seq(2,length(speed$stop_lon))],
               speed$stop_lat[seq(2,length(speed$stop_lon))]),
             ncol = 2)

colnames(from) <- c("X","Y")
colnames(to) <- c("X","Y")
# points <- matrix(c(speed$stop_lon,
#                    speed$stop_lat),
#                  ncol = 2)

#speed$distance  <- c(0,geodist::geodist(points, sequential = TRUE))
speed$distance <- c(0,geodist::geodist(from, to, paired  = TRUE))
#speed$distance3 <- geodist::geodist(points, sequential = TRUE, pad = TRUE)


speed$speed <- round(speed$distance / speed$travel_time, 0)
speed$speed <- ifelse(speed$stop_sequence > c(0,speed$stop_sequence[seq(1,length(speed$departure_time)-1)]),
                      speed$speed ,NA)
speed$speed[1] <- NA
speed <- speed[!is.na(speed$speed),]
speed <- speed[speed$speed > 30,]
if(nrow(speed) > 0){
  message(nrow(speed)," too fast trips" )
  message(nrow(speed[speed$speed > 100,])," crazy fast trips" )
}

vj_timings <- function(file){
  xml = xml2::read_xml(file)
  VehicleJourneys = xml2::xml_child(xml,"d1:VehicleJourneys")
  for(i in seq(1, xml2::xml_length(VehicleJourneys))){
    child = xml2::xml_child(VehicleJourneys, i)
    names = xml2::xml_name(xml2::xml_children(child))
    if(!all(names %in% c("PrivateCode","OperatingProfile","VehicleJourneyCode",
                         "ServiceRef","LineRef","JourneyPatternRef","DepartureTime",
                         "Note","VehicleJourneyTimingLink","Operational"))){
      stop(paste0("Child ",i," file = ",file))
    }
  }

}

foo = pbapply::pblapply(files, vj_timings)


vj_ServicedOrganisationDayType <- function(file){
  xml = xml2::read_xml(file)
  VehicleJourneys = xml2::xml_child(xml,"d1:VehicleJourneys")
  res <- list()
  for(i in seq(1, xml2::xml_length(VehicleJourneys))){
    child = xml2::xml_child(VehicleJourneys, i)
    op <- xml2::xml_child(child, "d1:OperatingProfile")
    names = xml2::xml_name(xml2::xml_children(op))
    if(!all(names %in% c("RegularDayType","SpecialDaysOperation"))){
      message(paste0("Child ",i," file = ",file))
      op <- xml2::as_list(op)
      res[[i]] <- op
    }
  }
  return(res)

}

foo = pbapply::pblapply(files[1:100], vj_ServicedOrganisationDayType)
foo = foo[lengths(foo) > 0]
head(foo)
foo[[1]]


vj_ServicedOrganisationDayType2 <- function(file){
  xml = xml2::read_xml(file)
  VehicleJourneys = xml2::xml_child(xml,"d1:VehicleJourneys")
  res <- list()
  for(i in seq(1, xml2::xml_length(VehicleJourneys))){
    child = xml2::xml_child(VehicleJourneys, i)
    op <- xml2::xml_child(child, "d1:OperatingProfile")
    names = xml2::xml_name(xml2::xml_children(op))
    if(!all(names %in% c("RegularDayType","SpecialDaysOperation"))){
      #message(paste0("Child ",i," file = ",file))
      op <- xml2::as_list(op)
      op$RegularDayType <- NULL
      op$SpecialDaysOperation <- NULL
      res[[i]] <- op
    }
  }
  return(res)

}


foo = pbapply::pblapply(files, vj_ServicedOrganisationDayType2)
foo = foo[lengths(foo) > 0]
foo2 = unlist(foo, recursive = F)
foo2 = foo2[lengths(foo2) > 0]
#foo2[[1]]
#head(foo2)
#foo[[1]]

foo3 <- unique(foo2)
foo4 <- unlist(foo3)

