
# activities = strsplit(stop_times$Activity," ")

# upoffs = t(sapply(activities,clean_activities))
# upoffs = as.data.frame(upoffs)
# names(upoffs) = c("pickup_type","drop_off_type")



# trips = calendar[c("UID","trip_id")]
# names(trips) = c("service_id","trip_id")
#
# route_id = strsplit(trips$service_id,  " ")
# route_id = lapply(route_id, `[[`, 1)
# route_id = unlist(route_id)
# trips$route_id = route_id
# trips = trips[,c("route_id","service_id","trip_id")]



# routes = schedule[schedule$`STP indicator` != "C",]
# routes = routes[!duplicated(routes$`Train UID`),]
# routes = routes[,c("rowID","Train UID","Train Status","ATOC Code")]
# names(routes) = c("rowID","route_id","Train Status","agency_id")


# make the long names from the desitnation and time
# if(!silent){message(paste0(Sys.time()," Building long route names"))}
#
# routes = longnames(routes = routes, stop_times = stop_times)
# routes = routes[,c("route_id","agency_id","route_short_name","route_long_name","route_type","rowID")]
# head(routes)


