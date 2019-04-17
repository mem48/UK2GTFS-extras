find_structures <- function(file){
  xml = xml2::read_xml(file)
  #Top level
  internal_check(xml, file,
                 c("StopPoints","RouteSections","Routes","JourneyPatternSections",
                        "Operators","Services","VehicleJourneys"))
  # Second Level
  StopPoints = xml2::xml_child(xml,"d1:StopPoints")
  internal_check(StopPoints, file, c("AnnotatedStopPointRef"))
  Routes <- xml2::xml_child(xml,"d1:Routes")
  internal_check(Routes, file, c("Route"))
  JourneyPatternSections <- xml2::xml_child(xml,"d1:JourneyPatternSections")
  internal_check(JourneyPatternSections, file, c("JourneyPatternSection"))
  Operators <- xml2::xml_child(xml,"d1:Operators")
  internal_check(Operators, file, c("Operator"))
  RouteSections = xml2::xml_child(xml,"d1:RouteSections")
  internal_check(RouteSections, file, c("RouteSection"))
  Services <- xml2::xml_child(xml,"d1:Services")
  internal_check(Services, file, c("Service"))
  VehicleJourneys = xml2::xml_child(xml,"d1:VehicleJourneys")
  internal_check(VehicleJourneys, file, c("VehicleJourney"))

  # Third Level
  internal_check_step1(StopPoints, file, c("StopPointRef", "CommonName", "Indicator", "LocalityName", "LocalityQualifier"))
  internal_check_step1(Routes, file, c("PrivateCode","Description", "RouteSectionRef"))
  internal_check_step1(JourneyPatternSections, file, c("JourneyPatternTimingLink"))
  internal_check_step1(Operators, file, c("NationalOperatorCode", "OperatorCode", "OperatorShortName", "OperatorNameOnLicence", "TradingName","LicenceNumber", "LicenceClassification"))
  internal_check_step1(RouteSections, file, c("RouteLink"))
  internal_check_step1(Services, file, c("PrivateCode", "OperatingProfile","ServiceCode", "Lines", "OperatingPeriod", "RegisteredOperatorRef", "StopRequirements", "Mode", "Description", "StandardService"))
  internal_check_step1(VehicleJourneys, file, c("PrivateCode","OperatingProfile","VehicleJourneyCode",
                                                "ServiceRef","LineRef","JourneyPatternRef","DepartureTime",
                                                "Note","VehicleJourneyTimingLink","Operational"))
  # Fouth Level
  jps_check(JourneyPatternSections, file)



}



find_structures2 <- function(file){
  xml = xml2::read_xml(file)

  # Top Level
  xml = xml2::xml_children(xml)
  internal_check2(xml, file, c("StopPoints","RouteSections","Routes","JourneyPatternSections",
                              "Operators","Services","VehicleJourneys","ServicedOrganisations"))
  # Second Level
  xml = xml2::xml_children(xml)
  internal_check2(xml, file, names_check = c("AnnotatedStopPointRef", "RouteSection", "Route",
                                             "JourneyPatternSection", "Operator", "Service", "VehicleJourney",
                                             "ServicedOrganisation"))
  # Third Level
  xml = xml2::xml_children(xml)
  internal_check2(xml, file, names_check = c("StopPointRef", "CommonName", "Indicator", "LocalityName",
                                             "LocalityQualifier", "RouteLink", "PrivateCode", "Description",
                                             "RouteSectionRef", "JourneyPatternTimingLink", "NationalOperatorCode",
                                             "OperatorCode", "OperatorShortName", "OperatorNameOnLicence",
                                             "TradingName", "LicenceNumber", "LicenceClassification", "ServiceCode",
                                             "Lines", "OperatingPeriod", "OperatingProfile", "RegisteredOperatorRef",
                                             "StopRequirements", "Mode", "StandardService", "Operational",
                                             "VehicleJourneyCode", "ServiceRef", "LineRef", "JourneyPatternRef",
                                             "DepartureTime", "VehicleJourneyTimingLink","Note", "VehicleJourneyRef",
                                             "OrganisationCode", "Name", "WorkingDays", "Holidays", "OperatorRef",
                                             "Direction","StartDeadRun","EndDeadRun"))

  # Forth Level
  xml = xml2::xml_children(xml)
  internal_check2(xml, file, names_check = c("From", "To", "Direction", "RouteLinkRef", "RunTime", "Line", "StartDate",
                                             "EndDate", "RegularDayType", "NoNewStopsRequired", "Origin", "Destination",
                                             "JourneyPattern", "VehicleType", "BankHolidayOperation", "JourneyPatternTimingLinkRef",
                                             "SpecialDaysOperation", "NoteCode", "NoteText", "Distance", "DateRange",
                                             "ServicedOrganisationDayType","ShortWorking"))

  # Fith Level
  xml = xml2::xml_children(xml)
  internal_check2(xml, file, names_check = c("StopPointRef", "Activity", "TimingStatus", "WaitTime", "LineName", "DaysOfWeek",
                                             "Operational", "RouteRef", "JourneyPatternSectionRefs", "VehicleTypeCode",
                                             "Description", "DaysOfNonOperation", "HolidaysOnly", "DaysOfOperation","Direction",
                                             "StartDate", "EndDate", "DestinationDisplay","JourneyPatternTimingLinkRef"))

  # Sixth Level
  xml = xml2::xml_children(xml)
  internal_check2(xml, file, names_check = c("MondayToSunday", "VehicleType", "MondayToFriday", "AllBankHolidays",
                                             "Saturday", "Sunday", "ChristmasDay", "BoxingDay", "NewYearsDay",
                                             "SpringBank", "LateSummerBankHolidayNotScotland", "MondayToSaturday",
                                             "Monday","Tuesday", "Wednesday", "Thursday","Friday","Saturday","Sunday",
                                             "DateRange", "Weekend","GoodFriday", "HolidayMondays","WorkingDays",
                                             "MayDay", "EasterMonday","Christmas","Holidays"))
  # Seventh Level
  xml = xml2::xml_children(xml)
  internal_check2(xml, file, names_check = c("VehicleTypeCode", "Description","StartDate", "EndDate",
                                             "ServicedOrganisationRef","Note"))

  # Eigth Level
  xml = xml2::xml_children(xml)
  if(xml2::xml_length(xml) != 0){
    stop(paste0("In ",file," more than 7 layers"))
  }


}

dir = "E:/OneDrive - University of Leeds/Routing/TransitExchangeData/data_20180515"
files = list.files(dir, full.names = T, recursive = T, pattern = ".xml")
length(8000:length(files)) / 100 * 39

foo <- pbapply::pblapply(files[1:length(files)], find_structures2)


internal_check <- function(xml, file, names_check){
  names1 <- xml2::xml_name(xml2::xml_children(xml))
  if(!all(names1 %in% names_check)){
    names_new <- unique(names1[!names1 %in% names_check])
    stop(paste0('In ',xml2::xml_name(xml),': "',paste(names_new, collapse = '", "'),'" are unknown, file = ',file ))
  }
}

internal_check2 <- function(xml, file, names_check, name_parent = "", level = 1){
  names1 <- unique(xml2::xml_name(xml))
  if(!all(names1 %in% names_check)){
    names_new <- unique(names1[!names1 %in% names_check])
    stop('In ',name_parent," ",level,' "',paste0(paste(names_new, collapse = '", "'),'" are unknown, file = ',file ))
  }
}


internal_check_step1 <- function(xml, file, names_check){
  for(i in seq(1, xml2::xml_length(xml))){
    child = xml2::xml_child(xml, i)
    internal_check(child, file, names_check)
  }
}

jps_check <- function(JourneyPatternSections, file){
  JourneyPatternTimingLink <- xml2::xml_children(JourneyPatternSections)
  internal_check(JourneyPatternTimingLink, file, c("JourneyPatternSection","JourneyPatternTimingLink"))
  for(i in seq(1, sum(xml2::xml_length(JourneyPatternTimingLink)))){
    child <- xml2::xml_child(JourneyPatternTimingLink, i)
    internal_check(child, file, c("From", "To", "RouteLinkRef", "RunTime"))
    From <- xml2::xml_child(child, "d1:From")
    internal_check(From, file, c("Activity", "StopPointRef", "TimingStatus"))
    To <- xml2::xml_child(child, "d1:From")
    internal_check(To, file, c("Activity", "StopPointRef", "TimingStatus"))
  }
}






sv_check <- function(Services){

}


find_structures_top <- function(file){
  xml = xml2::read_xml(file)
  #Top level
  internal_check(xml, file,
                 c("StopPoints","RouteSections","Routes","JourneyPatternSections",
                   "Operators","Services","VehicleJourneys","ServicedOrganisations"))
  # Second Level
  StopPoints = xml2::xml_child(xml,"d1:StopPoints")
  internal_check(StopPoints, file, c("AnnotatedStopPointRef"))
  Routes <- xml2::xml_child(xml,"d1:Routes")
  internal_check(Routes, file, c("Route"))
  JourneyPatternSections <- xml2::xml_child(xml,"d1:JourneyPatternSections")
  internal_check(JourneyPatternSections, file, c("JourneyPatternSection"))
  Operators <- xml2::xml_child(xml,"d1:Operators")
  internal_check(Operators, file, c("Operator"))
  RouteSections = xml2::xml_child(xml,"d1:RouteSections")
  internal_check(RouteSections, file, c("RouteSection"))
  Services <- xml2::xml_child(xml,"d1:Services")
  internal_check(Services, file, c("Service"))
  VehicleJourneys = xml2::xml_child(xml,"d1:VehicleJourneys")
  internal_check(VehicleJourneys, file, c("VehicleJourney"))
}




find_structures3 <- function(file){
  xml = xml2::read_xml(file)

  # Second Level
  StopPoints = xml2::xml_child(xml,"d1:StopPoints")
  Routes <- xml2::xml_child(xml,"d1:Routes")
  JourneyPatternSections <- xml2::xml_child(xml,"d1:JourneyPatternSections")
  Operators <- xml2::xml_child(xml,"d1:Operators")
  RouteSections = xml2::xml_child(xml,"d1:RouteSections")
  Services <- xml2::xml_child(xml,"d1:Services")
  VehicleJourneys <- xml2::xml_child(xml,"d1:VehicleJourneys")
  ServicedOrganisations <- xml2::xml_child(xml,"d1:ServicedOrganisations")

  find_structures_recersive(StopPoints,
                            file = file,
                            names1 = "AnnotatedStopPointRef",
                            names2 = c("StopPointRef", "CommonName", "Indicator", "LocalityName", "LocalityQualifier"),
                            names3 = "",
                            names4 = "",
                            names5 = "",
                            names6 = "",
                            names7 = "",
                            name_parent = "StopPoints")

  find_structures_recersive(Routes,
                            file = file,
                            names1 = "Route",
                            names2 = c("PrivateCode", "Description", "RouteSectionRef"),
                            names3 = "",
                            names4 = "",
                            names5 = "",
                            names6 = "",
                            names7 = "",
                            name_parent = "Routes")

  find_structures_recersive(JourneyPatternSections,
                            file = file,
                            names1 = "JourneyPatternSection",
                            names2 = "JourneyPatternTimingLink",
                            names3 = c("From", "To", "RouteLinkRef", "RunTime"),
                            names4 = c("Activity", "StopPointRef", "TimingStatus", "WaitTime"),
                            names5 = "",
                            names6 = "",
                            names7 = "",
                            name_parent = "JourneyPatternSections")

  find_structures_recersive(RouteSections,
                            file = file,
                            names1 = "RouteSection",
                            names2 = c("RouteLink"),
                            names3 = c("From", "To", "Direction"),
                            names4 = "StopPointRef",
                            names5 = "",
                            names6 = "",
                            names7 = "",
                            name_parent = "RouteSections")

  find_structures_recersive(Services,
                            file = file,
                            names1 = "Service",
                            names2 = c("ServiceCode", "PrivateCode", "Lines", "OperatingPeriod",
                                       "OperatingProfile", "RegisteredOperatorRef", "StopRequirements",
                                       "Mode", "Description", "StandardService"),
                            names3 = c("Line", "StartDate", "EndDate", "RegularDayType",
                                       "NoNewStopsRequired", "Origin", "Destination", "JourneyPattern",
                                       "BankHolidayOperation"),
                            names4 = c("LineName", "DaysOfWeek", "Direction", "Operational", "RouteRef",
                                       "JourneyPatternSectionRefs", "DaysOfNonOperation"),
                            names5 = c("MondayToSunday", "VehicleType", "MondayToSaturday",
                                       "MondayToFriday", "LateSummerBankHolidayNotScotland", "SpringBank",
                                       "GoodFriday", "MayDay", "EasterMonday","Christmas",
                                       "Monday","Tuesday", "Wednesday", "Thursday","Friday","Saturday","Sunday",
                                       "AllBankHolidays", "Weekend"),
                            names6 = c("VehicleTypeCode", "Description"),
                            names7 = "",
                            name_parent = "Services")

  find_structures_recersive(VehicleJourneys,
                            file = file,
                            names1 = "VehicleJourney",
                            names2 = c("PrivateCode", "Operational", "OperatingProfile", "VehicleJourneyCode",
                                       "ServiceRef", "LineRef", "JourneyPatternRef", "DepartureTime",
                                       "VehicleJourneyTimingLink","Note"),
                            names3 = c("VehicleType", "RegularDayType", "BankHolidayOperation",
                                       "JourneyPatternTimingLinkRef", "From", "To", "SpecialDaysOperation",
                                       "NoteCode", "NoteText"),
                            names4 = c("VehicleTypeCode", "Description", "DaysOfWeek", "DaysOfNonOperation", "HolidaysOnly", "DaysOfOperation"),
                            names5 = c("MondayToFriday", "AllBankHolidays",
                                       "Monday","Tuesday", "Wednesday", "Thursday","Friday","Saturday","Sunday",
                                       "ChristmasDay", "BoxingDay", "NewYearsDay", "SpringBank", "LateSummerBankHolidayNotScotland",
                                       "DateRange"),
                            names6 = c("StartDate", "EndDate"),
                            names7 = "",
                            name_parent = "VehicleJourneys")

  find_structures_recersive(ServicedOrganisations,
                            file = file,
                            names1 = "",
                            names2 = "",
                            names3 = "",
                            names4 = "",
                            names5 = "",
                            names6 = "",
                            names7 = "",
                            name_parent = "ServicedOrganisations")




}

foo <- pbapply::pblapply(files, find_structures3)
#dir = "E:/OneDrive - University of Leeds/Routing/TransitExchangeData/data_20180515"
#files = list.files(dir, full.names = T, recursive = T, pattern = ".xml")
#foo <- pbapply::pblapply(files[1:10], find_structures3)


find_structures_recersive <- function(xml, file, names1, names2, names3, names4, names5, names6, names7, name_parent){

  # Top Level
  xml = xml2::xml_children(xml)
  internal_check2(xml, file, names1, name_parent, level = 1)

  xml = xml2::xml_children(xml)
  internal_check2(xml, file, names2, name_parent, level = 2)

  xml = xml2::xml_children(xml)
  internal_check2(xml, file, names3, name_parent, level = 3)

  xml = xml2::xml_children(xml)
  internal_check2(xml, file, names4, name_parent, level = 4)

  xml = xml2::xml_children(xml)
  internal_check2(xml, file, names5, name_parent, level = 5)

  xml = xml2::xml_children(xml)
  internal_check2(xml, file, names6, name_parent, level = 6)

  xml = xml2::xml_children(xml)
  internal_check2(xml, file, names7, name_parent, level = 7)

  # Eigth Level
  xml = xml2::xml_children(xml)
  if(xml2::xml_length(xml) != 0){
    stop(paste0("In ",file," more than 7 layers"))
  }


}






