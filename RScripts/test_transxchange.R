# Load Functions
code <- list.files("../UK2GTFS/R", full.names = T)
for(i in code){source(i)}

#Find Files
dir = "E:/OneDrive - University of Leeds/Routing/TransitExchangeData/data_20180515/SW/"
files = list.files(dir, full.names = T, recursive = T, pattern = ".xml")
#file = "E:/OneDrive - University of Leeds/Routing/TransitExchangeData/data_20180515/SW/swe_43-n1-_-y10-1.xml"
#file = files[381]
run_debug = T
full_import = F
naptan = get_naptan()
cal = get_bank_holidays()


x = 206
res_single = transxchange_import(file = files[x], run_debug = run_debug, full_import = full_import)
gtfs_single = transxchange_export(obj = res_single, run_debug = T, cal = cal, naptan = naptan)
write_gtfs(gtfs = gtfs_single, folder = "../mem48/UK2GTFS-extras/export", name = gsub(".xml","",strsplit(files[x], "/")[[1]][7]))


y = 1:length(files)
y = 200:300
res_batch  = pbapply::pblapply(files[y], transxchange_import, run_debug = run_debug, full_import = full_import)
gtfs_batch = pbapply::pblapply(res_batch, transxchange_export, run_debug = T, cal = cal, naptan = naptan)
foo = lapply(gtfs_batch, gtfs_validate_internal)
gtfs_merged <- gtfs_merge(gtfs_batch)
write_gtfs(gtfs = gtfs_merged, folder = "extras", name = "EA_nobook")


res_all  = pbapply::pblapply(files, transxchange_import, run_debug = run_debug, full_import = full_import)
gtfs_all = pbapply::pblapply(res_all, transxchange_export, run_debug = T, cal = cal, naptan = naptan)
gtfs_merged <- gtfs_merge(gtfs_all)

# Find the problem fast routes and split
fast_trips <- gtfs_fast_trips(gtfs_merged)
gtfs_spl <- gtfs_split(gtfs_merged, fast_trips)

gtfs_normal <- gtfs_spl[["false"]]
gtfs_fast <- gtfs_spl[["true"]]


write_gtfs(gtfs = gtfs_normal, folder = "extras", name = "EA_normal")
write_gtfs(gtfs = gtfs_fast, folder = "extras", name = "EA_fast")

saveRDS(res_single, "example_import.Rds")

res_batch <- list()
for(y in 1:length(files)){
  res_batch[[y]] <- try(transxchange_import(files[y], run_debug = run_debug, full_import = full_import))
}
table(sapply(res_batch,class))
gtfs_batch <- list()
for(y in 1:length(files)){
  if(y %% 100 == 0){
    message(y)
  }
  gtfs_batch[[y]] <- try(transxchange_export(res_batch[[y]], run_debug = T, cal = cal, naptan = naptan))
}
table(sapply(gtfs_batch,class))

gtfs_batch2 <- gtfs_batch[sapply(gtfs_batch,class) == "list"]
gtfs_merged <- gtfs_merge(gtfs_batch2)
write_gtfs(gtfs = gtfs_merged, folder = "../mem48/UK2GTFS-extras/export/", name = "SE_skip")
