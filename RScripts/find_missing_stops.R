library(UK2GTFS)
files <- list.files("E:/OneDrive - University of Leeds/Data/UK2GTFS/GTFS/gtfs_20201102", full.names = TRUE,
                    pattern = "zip")
stops <- list()
stop_times <- list()
for(i in 1:length(files)){
  gtfs <- gtfs_read(files[i])
  stops[[i]] <- gtfs$stops
  stop_times[[i]] <- gtfs$stop_times
  rm(gtfs)
}

stops <- dplyr::bind_rows(stops)
stop_times2 <- dplyr::bind_rows(stop_times[c(1:2,4:10)])
stop_times3 <- stop_times[[3]]
stop_times2$trip_id <- as.character(stop_times2$trip_id)
stop_times <- rbind(stop_times2, stop_times3)
rm(stop_times2, stop_times3)

stops_missing <- stops[is.na(stops$stop_lon),]
trip_missing <- unique(stop_times$trip_id[stop_times$stop_id %in% stops_missing$stop_id])
stop_times <- stop_times[stop_times$trip_id %in% trip_missing,]


stops_geopunk <- function(stop_id){
  url = paste0("https://www.geopunk.co.uk/bus-stop/",stop_id)
  req <- xml2::read_html(url)
  tab = rvest::html_table(req)
  if(length(tab) == 0){
    message(paste0("No data for ",stop_id))
  } else {
    tab = tab[sapply(tab, nrow) %in%  c(10,11,12,13,14)]
    tab = tab[[1]]
    #nodes = html_nodes(req, xpath = "//html//body//div[1]//div[2]//div//div[1]//div[1]//div[3]//h1")
    #nodes = html_nodes(req, xpath = "//html//body//div[1]//div[1]//div//div[1]//div[1]//div[2]//h1")
    nodes = rvest::html_nodes(req, xpath = "//html//body//main//div//div[1]//div//div[1]//div//div//h1")
    
    txt = rvest::html_text(nodes)
    txt = strsplit(txt,"  ")[[1]][1]
    
    res = c(stop_id, txt, tab$X2[tab$X1 == "Bus Stop NaptanCode:"], tab$X2[tab$X1 == "Bus Stop Longitude:"], tab$X2[tab$X1 == "Bus Stop Latitude:"])
    names(res) = c("stop_id","stop_name","stop_code","stop_lon","stop_lat")
    return(res)
  }
}

new_stops = lapply(stops$stop_id, stops_geopunk)
new_stops = new_stops[lengths(new_stops) > 0]
new_stops = data.frame(matrix(unlist(new_stops), ncol = 5, byrow = TRUE))
names(new_stops) = c("stop_id","stop_name","stop_code","stop_lon","stop_lat")

stops_still_missing <- stops[!stops$stop_id %in% new_stops$stop_id,]

stops_bustimes <- function(stop_id){
  url = paste0("https://bustimes.org/stops/",stop_id)
  req <- try(xml2::read_html(url))
  if("try-error" %in% class(req)){
    message(paste0("No data for ",stop_id))
  } else {
    nm <- rvest::html_text(rvest::html_nodes(req, xpath = "//html//body//main//h1"))
    url <- rvest::html_nodes(req, xpath = "//html//body//main//ul//li[1]//a")
    url <- xml2::xml_attrs(url[1])
    url <- url[[1]]
    url <- strsplit(url,"/")[[1]]
    url <- url[c(length(url), length(url) - 1)]
    url <- as.numeric(url)

    res = c(stop_id, stringr::str_to_title(nm), "", url[1], url[2])
    names(res) = c("stop_id","stop_name","stop_code","stop_lon","stop_lat")
    return(res)
    
  }

}

new_stops2 <- lapply(stops_still_missing$stop_id, stops_bustimes)
new_stops2 = new_stops2[lengths(new_stops2) > 0]
new_stops2 = data.frame(matrix(unlist(new_stops2), ncol = 5, byrow = TRUE))
names(new_stops2) = c("stop_id","stop_name","stop_code","stop_lon","stop_lat")

new_stops_fin <- rbind(new_stops, new_stops2)

naptan_missing <- UK2GTFS::naptan_missing

naptan_missing <- rbind(naptan_missing, new_stops_fin)
naptan_missing <- naptan_missing[naptan_missing$stop_id != "4.1E+11",]
if(all(!duplicated(naptan_missing$stop_id))){
  usethis::use_data(naptan_missing, overwrite = TRUE)
}

naptan_missing_dup <- naptan_missing[naptan_missing$stop_id %in% naptan_missing$stop_id[duplicated(naptan_missing$stop_id)],]

stops_map_missing <- function(stps, stpts, stops_all){
  stpts <- stpts[,c("trip_id","stop_id","stop_sequence")]
  stpts$missing <- stpts$stop_id %in% stps$stop_id
  miss_id <- seq_len(nrow(stpts))[stpts$missing]
  miss_id <- unique(c(miss_id,miss_id-1,miss_id+1))
  miss_id <- miss_id[order(miss_id)]
  stpts <- stpts[miss_id,]
  stpts_miss <- stpts[seq(2,nrow(stpts)-1,3),]
  stpts_m1 <- stpts[seq(1,nrow(stpts)-2,3),]
  stpts_p1 <- stpts[seq(3,nrow(stpts),3),]
  stpts_miss <- stpts_miss[,1:2]
  names(stpts_miss) = c("trip_id","missing_stop_id")
  stpts_miss$stop_before <- stpts_m1$stop_id
  stpts_miss$stop_after <- stpts_p1$stop_id
  stops_all = stops_all[stops_all$stop_id %in% stpts$stop_id,]
  stops_all = stops_all[,c("stop_id", "stop_lon" , "stop_lat")]
  names(stops_all) = c("stop_id", "before_lon" , "before_lat")
  stpts_miss <- dplyr::left_join(stpts_miss, stops_all, by = c("stop_before" = "stop_id"))
  names(stops_all) = c("stop_id", "after_lon" , "after_lat")
  stpts_miss <- dplyr::left_join(stpts_miss, stops_all, by = c("stop_after" = "stop_id"))
  stpts_miss$trip_id <- NULL
  # Fialing as stops after are missing
  stpts_miss <- unique(stpts_miss)
  geometry <- lapply(1:nrow(stpts_miss), function(x){
    sub <- stpts_miss[x,c("before_lon", "before_lat", "after_lon", "after_lat")]
    sub <- as.numeric(sub)
    sub <- matrix(sub, ncol = 2, byrow = TRUE)
    sub <- sf::st_linestring(sub)
  })
  stpts_miss$geometry <- sf::st_as_sfc(geometry, crs = 4326)
  
}
