# x <- strsplit(x,"M")
# mins <- grepl("M",x)
# secs <- grepl("S",x)


# help_times2 <- function(x_sub){
#   if(length(x_sub) == 2){
#     if(!grepl("S",x_sub[2])){stop("Unknwown Time Structure")}
#     time <- (as.integer(x_sub[1]) * 60) +  as.integer(gsub("S","",x_sub[2]))
#   }else if(length(x_sub) == 1){
#     if(grepl("S",x_sub)){
#       time <- as.integer(gsub("S","",x_sub))
#     }else if(is.na(x_sub)){
#       time <- 0
#     }else{
#       time <- (as.integer(x_sub) * 60)
#     }
#   }else{
#     stop("Terrible error")
#   }
# }

# help_times <- function(x_sub, min_sub, secs_sub){
#   if(min_sub & secs_sub){
#     # Mins and Seconds
#     message("Mins and Secs")
#     stop()
#   }else if(min_sub & !secs_sub){
#     # Mins only
#     time <- as.numeric(gsub("M","",x_sub)) * 60
#   }else if(!min_sub & secs_sub){
#     # Secs only
#     time <- as.numeric(gsub("S","",x_sub))
#   }else if(!min_sub & !secs_sub){
#     # Neither, due to NAs
#     time <- 0
#   }else{
#     message("Terrible error")
#     stop()
#   }
#   #time <- unname(time)
#   return(time)
# }
# times <- unname(mapply(help_times, x_sub = x, min_sub = mins, secs_sub = secs, SIMPLIFY = T))