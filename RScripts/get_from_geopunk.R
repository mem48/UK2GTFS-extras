stops <- read.csv("E:/Users/earmmor/GitHub/mem48/UK2GTFS-extras/export/W/stops.txt", stringsAsFactors = FALSE)
stops <- stops[is.na(stops$stop_lat),]

library(UK2GTFS)
library(rvest)

naptan_missing = naptan_missing

summary(stops$stop_id %in% naptan_missing$stop_id)

naptan2 = rbind(naptan_missing, stops)
write.csv(naptan2, "../../mem48/UK2GTFS-extras/data/missing_naptan.csv", row.names = FALSE)

naptan3 = read.csv("../../mem48/UK2GTFS-extras/data/missing_naptan.csv", stringsAsFactors = FALSE)

for(i in 125:132){
  url = paste0("https://www.geopunk.co.uk/bus-stop/",naptan3$stop_id[i])
  req <- read_html(url)
  tab = html_table(req)
  tab = tab[sapply(tab, nrow) %in%  c(10,11,12,13,14)]
  tab = tab[[1]]
  #nodes = html_nodes(req, xpath = "//html//body//div[1]//div[2]//div//div[1]//div[1]//div[3]//h1")
  nodes = html_nodes(req, xpath = "//html//body//div[1]//div[1]//div//div[1]//div[1]//div[2]//h1")
  txt = html_text(nodes)
  txt = strsplit(txt,"  ")[[1]][1]

  naptan3$stop_name[i] <- txt
  naptan3$stop_code[i] <- tab$X2[tab$X1 == "Bus Stop NaptanCode:"]
  naptan3$stop_lon[i] <- tab$X2[tab$X1 == "Bus Stop Longitude:"]
  naptan3$stop_lat[i] <- tab$X2[tab$X1 == "Bus Stop Latitude:"]


}

write.csv(naptan3, "../../mem48/UK2GTFS-extras/data/missing_naptan.csv", row.names = FALSE)
naptan_missing = naptan3

usethis::use_data(naptan_missing, overwrite = TRUE)
