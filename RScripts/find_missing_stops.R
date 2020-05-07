library(UK2GTFS)
files <- list.files("C:/Users/malco/OneDrive - University of Leeds/Data/UK2GTFS/GTFS/gtfs_20201102", full.names = TRUE,
                    pattern = "zip")
stops <- list()
for(i in 1:length(files)){
  gtfs <- gtfs_read(files[i])
  stops[[i]] <- gtfs$stops
  rm(gtfs)
}

stops <- dplyr::bind_rows(stops)
stops <- stops[is.na(stops$stop_lon),]

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
