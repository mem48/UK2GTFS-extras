
# if (class(ServicedOrganisations) == "data.frame") {
#
#   # Split those with dates and those with service organisations
#   VehicleJourneys_exclude_date <- VehicleJourneys_exclude[is.na(VehicleJourneys_exclude$ServicedOrganisationRef), ]
#   VehicleJourneys_exclude_date <- VehicleJourneys_exclude_date[, c("VehicleJourneyCode", "StartDate", "EndDate")]
#
#   VehicleJourneys_exclude_so <- VehicleJourneys_exclude[!is.na(VehicleJourneys_exclude$ServicedOrganisationRef), ]
#   if (nrow(VehicleJourneys_exclude_so) > 0) {
#     if (all(is.na(VehicleJourneys_exclude_so$StartDate))) {
#       VehicleJourneys_exclude_so$StartDate <- NULL
#     }
#     if (all(is.na(VehicleJourneys_exclude_so$EndDate))) {
#       VehicleJourneys_exclude_so$EndDate <- NULL
#     }
#
#     VehicleJourneys_exclude_so <- dplyr::left_join(VehicleJourneys_exclude_so, ServicedOrganisations, by = c("ServicedOrganisationRef" = "OrganisationCode"))
#     VehicleJourneys_exclude_so <- VehicleJourneys_exclude_so[, c("VehicleJourneyCode", "StartDate", "EndDate")]
#   }
#
#   if (nrow(VehicleJourneys_exclude_date) > 0) {
#     if (nrow(VehicleJourneys_exclude_so) > 0) {
#       VehicleJourneys_exclude <- rbind(VehicleJourneys_exclude_so, VehicleJourneys_exclude_date)
#     } else {
#       VehicleJourneys_exclude <- VehicleJourneys_exclude_date
#     }
#   } else {
#     VehicleJourneys_exclude <- VehicleJourneys_exclude_so
#   }
# }


# if (class(ServicedOrganisations) == "data.frame") {
#
#   # Split those with dates and those with service organisations
#   VehicleJourneys_include_date <- VehicleJourneys_include[is.na(VehicleJourneys_include$ServicedOrganisationRef), ]
#   VehicleJourneys_include_date <- VehicleJourneys_include_date[, c("VehicleJourneyCode", "StartDate", "EndDate")]
#
#   VehicleJourneys_include_so <- VehicleJourneys_include[!is.na(VehicleJourneys_include$ServicedOrganisationRef), ]
#   if (nrow(VehicleJourneys_include_so) > 0) {
#     if (all(is.na(VehicleJourneys_include_so$StartDate))) {
#       VehicleJourneys_include_so$StartDate <- NULL
#     }
#     if (all(is.na(VehicleJourneys_include_so$EndDate))) {
#       VehicleJourneys_include_so$EndDate <- NULL
#     }
#     VehicleJourneys_include_so <- dplyr::left_join(VehicleJourneys_include_so, ServicedOrganisations, by = c("ServicedOrganisationRef" = "OrganisationCode"))
#     VehicleJourneys_include_so <- VehicleJourneys_include_so[, c("VehicleJourneyCode", "StartDate", "EndDate")]
#   }
#
#   if (nrow(VehicleJourneys_include_date) > 0) {
#     if (nrow(VehicleJourneys_include_so) > 0) {
#       VehicleJourneys_include <- rbind(VehicleJourneys_include_so, VehicleJourneys_include_date)
#     } else {
#       VehicleJourneys_include <- VehicleJourneys_include_date
#     }
#   } else {
#     VehicleJourneys_include <- VehicleJourneys_include_so
#   }
# } 



# if (class(ServicedOrganisations) == "data.frame") {
#   vj_sub <- VehicleJourneys[, c("VehicleJourneyCode", "ServicedDaysOfOperation", "ServicedDaysOfNonOperation")]
#   vj_sub <- vj_sub[(!is.na(vj_sub$ServicedDaysOfOperation)) | (!is.na(vj_sub$ServicedDaysOfNonOperation)), ]
#   if (!all(is.na(vj_sub$ServicedDaysOfOperation))) {
#     stop("Complex serviced operations")
#   }
#   if (nrow(vj_sub) > 0) {
#     ServicedOrganisations_exe <- dplyr::left_join(ServicedOrganisations, vj_sub, by = c("OrganisationCode" = "ServicedDaysOfNonOperation"))
#     names(ServicedOrganisations_exe) <- c("VehicleJourneyCode", "StartDate", "EndDate")
#     VehicleJourneys_exclude <- rbind(VehicleJourneys_exclude, ServicedOrganisations_exe)
#   }
# }



# calendar$service_id <- gsub("[[:punct:]]","",calendar$service_id)
# calendar_dates$service_id <- gsub("[[:punct:]]","",calendar_dates$service_id)


# trips$trip_id <- seq(1L:nrow(trips))
# trips$route_id <- as.integer(as.factor(trips$route_id))
# #trips$service_id <- as.integer(as.factor(trips$service_id))
#
#
# join_trips   <- trips[,c("trip_id","trip_id")]
# join_routes  <- trips[,c("route_id","route_id")]
# join_service <- trips[,c("service_id","service_id")]
#
# trips <- trips[,c("route_id","service_id","trip_id")]
#
# routes <- dplyr::left_join(routes, join_routes, by = "route_id")
# routes <- routes[,c("route_id","agency_id","route_short_name", "route_long_name","route_desc","route_type")]
#
# calendar <- dplyr::left_join(calendar, join_service, by = "service_id")
# calendar <- calendar[,c("service_id", "start_date", "end_date","monday","tuesday","wednesday","thursday","friday","saturday","sunday")]
#
# calendar_dates <- dplyr::left_join(calendar_dates, join_service, by = "service_id")
# calendar_dates <- calendar_dates[,c("service_id","date","exception_type")]

