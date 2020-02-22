
#nrow(cal)
#nrow(naptan)



# TO balance progress bars interleave files
#seq_mid <- floor(length(files) / 2)
#seq_up <- seq(1, seq_mid)
#seq_down <- seq(length(files), seq_mid + 1)
#files = files[c(rbind(seq_up, seq_down))]


# cl <- parallel::makeCluster(ncores)
# # parallel::clusterExport(
# #   cl = cl,
# #   varlist = c("files", "cal", "naptan"),
# #   envir = environment()
# # )
# parallel::clusterEvalQ(cl, {
#   library(UK2GTFS)
# })
# pbapply::pboptions(use_lb = FALSE)
# res_all <- pbapply::pblapply(files,
#                              transxchange_import,
#                              run_debug = TRUE,
#                              full_import = FALSE,
#                              cl = cl
# )

# cl <- parallel::makeCluster(ncores)
# # parallel::clusterExport(
# #   cl = cl,
# #   varlist = c("files", "cal", "naptan"),
# #   envir = environment()
# # )
# parallel::clusterEvalQ(cl, {
#   library(UK2GTFS)
# })
# gtfs_all <- pbapply::pblapply(res_all,
#   transxchange_export,
#   run_debug = TRUE,
#   cal = cal,
#   naptan = naptan,
#   cl = cl
# )
# parallel::stopCluster(cl)


# gtfs_all <- foreach::foreach(i = 1:length(res_all), .options.snow = opts) foreach::`%dopar%` {
#   transxchange_export(res_all[[i]], cal = cal, naptan = naptan)
# }
# boot <- foreach::foreach(i = 1:length(res_all) .options.snow = opts)
# gtfs_all <- foreach::`%dopar%`(boot, transxchange_export(i))