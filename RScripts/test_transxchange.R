# Load Functions
code <- list.files("../UK2GTFS/R", full.names = T)
for(i in code){source(i)}

#Find Files
dir = "E:/Users/earmmor/OneDrive - University of Leeds/Routing/TransitExchangeData/data_20180515/NW/"
dir = "E:/OneDrive - University of Leeds/Routing/TransitExchangeData/data_20180515/NW/"
files = list.files(dir, full.names = T, recursive = T, pattern = ".xml")
#file = "E:/OneDrive - University of Leeds/Routing/TransitExchangeData/data_20180515/SW/swe_43-n1-_-y10-1.xml"
#file = files[381]
run_debug = T
full_import = F
naptan = get_naptan()
cal = get_bank_holidays()


x = 1
res_single <- transxchange_import(file = files[x], run_debug = run_debug, full_import = full_import)
gtfs_single <- transxchange_export(obj = res_single, run_debug = T, cal = cal, naptan = naptan)
write_gtfs(gtfs = gtfs_single, folder = "../UK2GTFS-extras/export/", name = gsub(".xml","",strsplit(files[x], "/")[[1]][7]))


y = 1:length(files)
y = 1:100


res_batch  <- pbapply::pblapply(files[y], transxchange_import, run_debug = run_debug, full_import = full_import)
gtfs_batch <- pbapply::pblapply(res_batch, transxchange_export, run_debug = T, cal = cal, naptan = naptan)
# foo = lapply(gtfs_batch, gtfs_validate_internal)
gtfs_merged <- gtfs_merge(gtfs_batch)
gtfs_compressed <- gtfs_compress(gtfs_merged)
gtfs_splited <- gtfs_split(gtfs_compressed, n_split = 2)

write_gtfs(gtfs = gtfs_splited[[1]], folder = "../UK2GTFS-extras/export/", name = "L_part1")
write_gtfs(gtfs = gtfs_splited[[2]], folder = "../UK2GTFS-extras/export/", name = "L_part2")

# Loop over each region
dir <- c("EA","EM","NE","NW","S","SE","SW","W","Y","L","NCSD")
code <- list.files("../UK2GTFS/R", full.names = T)
for(i in code){source(i)}
run_debug = T
full_import = F
naptan = get_naptan()
cal = get_bank_holidays()
for(i in 1:length(dir)){

  if(file.exists(paste0("../UK2GTFS-extras/export/",dir[i],".zip"))){
    message(paste0("Skip ",dir[i]))
  }else{
    message(dir[i])
    path = "E:/Users/earmmor/OneDrive - University of Leeds/Routing/TransitExchangeData/data_20180515/"
    files = list.files(paste0(path,"/",dir[i]), full.names = T, recursive = T, pattern = ".xml")
    res_batch  = pbapply::pblapply(files, transxchange_import, run_debug = run_debug, full_import = full_import)
    gtfs_batch = pbapply::pblapply(res_batch, transxchange_export, run_debug = T, cal = cal, naptan = naptan)
    gtfs_merged <- gtfs_merge(gtfs_batch)
    write_gtfs(gtfs = gtfs_merged, folder = "../UK2GTFS-extras/export/", name = dir[i])
  }

}
# Worked: EA, EM, SE
# Fail, NE, NW, S, SW, W
