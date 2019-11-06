# Find a bug with vehicle Journeys

code <- list.files("../UK2GTFS/R", full.names = T)
for(i in code){source(i)}

#Find Files
dir = "E:/Users/earmmor/OneDrive - University of Leeds/Routing/TransitExchangeData/data_20180515"
#dir = "E:/OneDrive - University of Leeds/Routing/TransitExchangeData/data_20180515/L/"
files = list.files(dir, full.names = T, recursive = T, pattern = ".xml")
#file = "E:/OneDrive - University of Leeds/Routing/TransitExchangeData/data_20180515/SW/swe_43-n1-_-y10-1.xml"
#file = files[381]
run_debug = T
full_import = F

for(j in 1100:length(files)){
  message(j)
  file = files[j]
  xml <- xml2::read_xml(file)
  vehiclejourneys <- xml2::xml_child(xml, "d1:VehicleJourneys")
  OperatingProfile <- xml2::xml_find_all(vehiclejourneys, ".//d1:OperatingProfile")
  if(sum(xml2::xml_length(OperatingProfile)) > 0){
    foo <- import_OperatingProfile(OperatingProfile)

  }

}

find_structures_operatingprofile <- function(file){
  xml = xml2::read_xml(file)

  # Top Level
  vehiclejourneys <- xml2::xml_child(xml, "d1:VehicleJourneys")
  OperatingProfile <- xml2::xml_find_all(vehiclejourneys, ".//d1:OperatingProfile")

  # Second Level
  xml = xml2::xml_children(OperatingProfile)
  internal_check2(xml, file, names_check = c("RegularDayType", "ServicedOrganisationDayType", "BankHolidayOperation","SpecialDaysOperation"))
  # Third Level
  xml = xml2::xml_children(xml)
  internal_check2(xml, file, names_check = c("DaysOfWeek", "DaysOfOperation", "DaysOfNonOperation","HolidaysOnly"))

  # Forth Level
  xml = xml2::xml_children(xml)
  internal_check2(xml, file, names_check = c("MondayToFriday", "WorkingDays", "ChristmasDay", "BoxingDay", "NewYearsDay",
                                             "Saturday", "AllBankHolidays", "Monday", "DateRange", "Friday","GoodFriday", "HolidayMondays",
                                             "Thursday","Tuesday","Wednesday","Sunday", "MondayToSaturday", "MondayToSunday",
                                             "LateSummerBankHolidayNotScotland", "SpringBank", "Weekend", "Christmas",
                                             "MayDay","EasterMonday","Holidays"))

  # Fith Level
  xml = xml2::xml_children(xml)
  internal_check2(xml, file, names_check = c("ServicedOrganisationRef",
                                             "StartDate", "EndDate","Note"))

  # Sixth Level
  xml = xml2::xml_children(xml)
  internal_check2(xml, file, names_check = c())
  # Seventh Level
  xml = xml2::xml_children(xml)
  internal_check2(xml, file, names_check = c())

  # Eigth Level
  xml = xml2::xml_children(xml)
  if(xml2::xml_length(xml) != 0){
    stop(paste0("In ",file," more than 7 layers"))
  }


}

foo <- pbapply::pblapply(files[8000:length(files)], find_structures_operatingprofile)
