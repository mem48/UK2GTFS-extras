
# if(ncores == 1){
#   res = lapply(1:length_todo, makeCalendar.inner)
# }else{
#   CL <- parallel::makeCluster(ncores) #make clusert and set number of core
#   parallel::clusterExport(cl = CL, varlist=c("calendar", "UIDs"), envir = environment())
#   parallel::clusterExport(cl = CL, c('splitDates'), envir = environment() )
#   parallel::clusterEvalQ(cl = CL, {library(dplyr)})
#   res = parallel::parLapply(cl = CL,1:length_todo,makeCalendar.inner)
#   parallel::stopCluster(CL)
# }




# if(ncores == 1){
#   keep = sapply(seq(1,nrow(res.calendar)),checkrows)
# }else{
#   CL <- parallel::makeCluster(ncores) #make clusert and set number of core
#   parallel::clusterExport(cl = CL, varlist=c("res.calendar"), envir = environment())
#   parallel::clusterExport(cl = CL, c('checkrows'), envir = environment() )
#   parallel::clusterEvalQ(cl = CL, {library(dplyr)})
#   keep = parallel::parSapply(cl = CL,X = seq(1,nrow(res.calendar)), FUN = checkrows)
#   parallel::stopCluster(CL)
# }





#' Duplicate stop_times
#'
#' @details
#' Function that duplicates top times for trips that have been split into multiple trips
#'
#' @param calendar calendar data.frame
#' @param stop_times stop_times data.frame
#' @param ncores number of processes for parallel processing (default = 1)
#' @noRd
#'
duplicate.stop_times <- function(calendar, stop_times, ncores = 1) {
  # calendar.nodup = calendar[!duplicated(calendar$rowID),]
  # calendar.dup = calendar[duplicated(calendar$rowID),]
  # rowID.unique = as.data.frame(table(calendar.dup$rowID))
  # rowID.unique$Var1 = as.integer(as.character(rowID.unique$Var1))
  #
  # duplicate.stop_times.int = function(i){
  #   stop_times.tmp = stop_times[stop_times$schedule.rowID == rowID.unique$Var1[i],]
  #   reps = rowID.unique$Freq[i]
  #   index =rep(seq(1,reps),nrow(stop_times.tmp))
  #   index = index[order(index)]
  #   stop_times.tmp = stop_times.tmp[rep(seq(1,nrow(stop_times.tmp)), reps),]
  #   stop_times.tmp$index = index
  #   return(stop_times.tmp)
  # }
  #
  # if(ncores == 1){
  #   stop_times.dup = lapply(1:length(rowID.unique$Var1),duplicate.stop_times.int)
  # }else{
  #   CL <- parallel::makeCluster(ncores) #make clusert and set number of core
  #   parallel::clusterExport(cl = CL, varlist=c("rowID.unique", "calendar.dup","stop_times"), envir = environment())
  #   #parallel::clusterEvalQ(cl = CL, {library(dplyr)})
  #   stop_times.dup = parallel::parLapply(cl = CL,1:length(rowID.unique$Var1),duplicate.stop_times.int)
  #   parallel::stopCluster(CL)
  # }
  #
  # stop_times.dup = dplyr::bind_rows(stop_times.dup)
  #
  # #Join on the nonduplicated trip_ids
  # trip.ids.nodup = calendar.nodup[,c("rowID","trip_id")]
  # stop_times = dplyr::left_join(stop_times,trip.ids.nodup, by = c("schedule.rowID" = "rowID"))
  # stop_times = stop_times[!is.na(stop_times$trip_id),] #when routes are cancled their stop times are left without valid trip_ids
  #
  # #join on the duplicated trip_ids
  # calendar2 =  dplyr::group_by(calendar, rowID)
  # calendar2 =  dplyr::mutate(calendar2,Index=1:n())
  #
  # stop_times.dup$index2 = as.integer(stop_times.dup$index + 1)
  # trip.ids.dup = calendar2[,c("rowID","trip_id","Index")]
  # trip.ids.dup = as.data.frame(trip.ids.dup)
  # stop_times.dup = dplyr::left_join(stop_times.dup,trip.ids.dup, by = c("schedule.rowID" = "rowID", "index2" = "Index"))
  # stop_times.dup = stop_times.dup[,c("departure_time", "stop_id","rowID","arrival_time","schedule.rowID","trip_id")]
  #
  # #stop_times.dup = stop_times.dup[order(stop_times.dup$rowID),]
  #
  # stop_times.comb = rbind(stop_times, stop_times.dup)
  #
  # return(stop_times.comb)
}

#' Check for valid day of the week
#' @param from date
#' @param to date
#' Returns the days of the week that are between two dates
#'
#' Check for valid day of the week
#' @param from date
#' @param to date
#' Returns the days of the week that are between two dates
#'
# valid_days <- function(from, to, duration, monday,tuesday, wednesday,
#                        thursday, friday, saturday, sunday){
#   if(duration >= 7){
#     message("skipped")
#     return(TRUE)
#   }else{
#     days.valid <- tolower(weekdays(seq.POSIXt(from = from,
#                                               to = to,
#                                               by = "DSTday")))
#     message(paste0("did "), length(days.valid), "of ", class(days.valid))
#     days.valid <- unique(days)
#
#     days.opp <- c("monday","tuesday", "wednesday","thursday", "friday", "saturday", "sunday")
#     days.opp <- days.opp[c(monday,tuesday, wednesday,thursday, friday, saturday, sunday)]
#
#     if(any(days.valid %in% days.opp)){
#       return(TRUE)
#     }else{
#       return(FALSE)
#     }
#   }
# }


#' Clean Stops
#'
#' @details
#' Some TIPLOCS have the same physical location, and some are unused this function cleans that up
#'
#' @param stop_times stop_times data.frame
#' @param stops stops data.frame
#' @noRd
#'
cleanstops <- function(stop_times, stops) {
  
}


#' Clean Activities
#' @param x character activities
#' @details
#' Change Activities code to pickup and drop_off
#' https://wiki.openraildata.com//index.php?title=Activity_codes
#'
#' @noRd
#'
clean_activities <- function(x) {
  if ("T" %in% x) {
    return(c(0, 0))
  } else if ("U" %in% x) {
    return(c(0, 1))
  } else if ("TF" %in% x) {
    return(c(1, 0))
  } else if ("D" %in% x) {
    return(c(1, 0))
  } else if ("TFN" %in% x) {
    return(c(1, 0))
  } else if ("TFT" %in% x) {
    return(c(1, 0))
  } else if ("TFRM" %in% x) {
    return(c(1, 0))
  } else if ("TFD" %in% x) {
    return(c(1, 0))
  } else if ("TF-D" %in% x) {
    return(c(1, 0))
  } else if ("TFTW" %in% x) {
    return(c(1, 0))
  } else if ("TFX" %in% x) {
    return(c(1, 0))
  } else if ("TF-U" %in% x) {
    return(c(1, 0))
  } else if ("TFS" %in% x) {
    return(c(1, 1))
  } else if ("TFR" %in% x) {
    return(c(1, 0))
  } else if ("TFU" %in% x) {
    return(c(0, 0))
  } else {
    message(paste0("Unknown ", paste(x, " ")))
  }
}
