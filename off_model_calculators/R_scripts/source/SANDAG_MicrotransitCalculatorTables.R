# Dora Wu @ WSP USA Inc 07-06-2018
# edited by Arash Asadabadi @ WSP USA Inc 09-18-2018
# convert Rosella's SAS script to generate tables for MicroTransit GHG calculator
# files required to run this script include:
# 1. ct-ramp output individual trip file
# 2. distance skim file
# 3. ct-ramp output work location file
# 4. "MicrotransitAreaFlags.csv" file that contains TAZ, MSA, FRED flags, CHARIOT flags for each MGRA
# This script can be run from command window as: 
# Rscript.exe --vanilla --verbose SANDAG_MicrotransitCalculatorTables.R > SANDAG_Microtansit.log
# install packages from CRAN if required packages are not installed
# rm(list = ls(all.names=TRUE))
# list.of.packages <- c("data.table", "bit64", "tidyverse")
# new.packages <- list.of.packages[!(list.of.packages %in% installed.packages()[,"Package"])]
# 
# 
# if(length(new.packages)) install.packages(new.packages, repos="http://cran.us.r-project.org")
# devtools::install_github("gregmacfarlane/omxr")
# library(omxr)
# library(foreign)
# library(data.table)
# library(tidyverse)

#Scenario=c("2035_E_minus_bu")
#for (s in Scenario){
  # ----------------------------------------------------------------------
  # set working directory, data directory and input file names here
  #main_dir=paste0("T:/RTP/2019RP/rp19_scen/abm_runs_bod/",s,"/")
  #dataDir      <- "T:/RTP/2019RP/rp19_scen/abm_runs_bod/r scripts off-model/"  # where input files are
  tripFile     <- "output/indivTripData_3.csv"               # ct-ramp output individual trip file 
  tripFile2    <- "report/indivtrips.csv"               # ct-ramp output individual trip file in report 
  flagFile     <- "MicrotransitAreaFlags.csv"         # file contain MAZ and corresponding MSA and FRED area flags
  workLocFile  <- "output/wsLocResults_3.csv"            # ct-ramp output work location file
  #output_dir   <- paste0(dataDir,"output/")

  # -----------------------------------------------------------------------
  
  # read in files
  itripClasses <- c(rep("integer", 6), rep("character", 3),
                    rep("integer", 15)) 
  YEAR         <- as.numeric(substr(s,1,4))
  itrip        <- fread(paste0(main_dir, tripFile), colClasses = itripClasses, nrows = -1)
  itrip2       <- fread(paste0(main_dir, tripFile2), nrows = -1)
  
  #itrip <- read.csv(paste0(dataDir, tripFile), nrows = 2000)
  #itrip2 <- read.csv(paste0(dataDir, tripFile2), nrows = 2000)
  
  MTAflags <- read.csv(paste0(dataDir, flagFile), header = T, stringsAsFactors = F)
  MTAflags_colName <- c("mgra", "msa", "TAZ", "nevshuttle_flag", "chariot_flag",
                        "year_nevshuttle", "year_chariot")
  colnames(MTAflags) <- MTAflags_colName
  MTAflags <- MTAflags %>%
    mutate(nevshuttle_flag    = ifelse(year_nevshuttle > YEAR, 0, nevshuttle_flag),
           chariot_flag = ifelse(year_chariot > YEAR, 0, chariot_flag))
  distance= itrip2%>%
    select(ORIG_MGRA,DEST_MGRA,TRIP_DIST)%>%
    rename(orig_mgra=`ORIG_MGRA`,dest_mgra=`DEST_MGRA`,Dist =`TRIP_DIST`)%>%
    distinct(orig_mgra,dest_mgra, .keep_all = TRUE)
  #distance <- fread(paste0(dataDir, skimFile), colClasses = c("integer", "integer", "numeric"),
  #col.names = c("OTAZ", "DTAZ", "Dist"), nrows = -1)
  workLoc <- fread(paste0(main_dir, workLocFile),
                   colClasses = c(rep("integer", 12), "numeric", "numeric",
                                  "integer", "numeric", "numeric"), nrows = -1)
  
  # create chariot data summary
  #chariot <- workLoc %>% 
   # mutate(home_msa   = MTAflags$msa[match(HomeMGRA, MTAflags$mgra)],
   #        emp_center = MTAflags$chariot_flag[match(WorkLocation, MTAflags$mgra)]) %>% 
   # group_by(home_msa, emp_center) %>% 
   # summarise(workers = n()) %>% 
   #ungroup() %>% 
   # mutate(year = YEAR) %>% 
   # select(year, home_msa, emp_center, workers)
  
  # attach trip distance to trip file, and only count trips 2 miles or shorter
  #itrip <- itrip %>% 
  #    mutate(OTAZ = MTAflags$TAZ[match(orig_mgra, MTAflags$mgra)],
  #           DTAZ = MTAflags$TAZ[match(dest_mgra, MTAflags$mgra)]) 
  
  #itrip <- setDT(itrip)           
  #setkey(itrip, OTAZ, DTAZ)     
  #setkey(distance, OTAZ, DTAZ)    
  
  #itrip <- merge(itrip, distance, all.x = T)
  colnames(MTAflags) <- c(paste0("orig_", MTAflags_colName))
  
  itrip <- itrip %>% 
    left_join(distance, by = c("orig_mgra"="orig_mgra", "dest_mgra"="dest_mgra"))%>%
    filter(Dist <= 2) %>% 
    left_join(MTAflags, by = "orig_mgra")
  
  colnames(MTAflags) <- c(paste0("dest_", MTAflags_colName))
  
  
  itrip <- itrip %>% 
    left_join(MTAflags, by = "dest_mgra")
  #caculate the average distance for auto trips <=2 miles with destination in MGRAs with Nev flag=1 
  average_Dist= mean(filter(itrip,trip_mode <= 6,dest_nevshuttle_flag==1)$Dist)
  # create auto trip summary    
  vtrip <- itrip %>%
    filter(trip_mode <= 6) %>% 
    group_by(orig_msa, orig_nevshuttle_flag, dest_msa, dest_nevshuttle_flag) %>% 
    summarise(auto_trips = n())
  
  # create person trip summary and merge with auto trip summmary    
  ptrip <- itrip %>% 
    group_by(orig_msa, orig_nevshuttle_flag, dest_msa, dest_nevshuttle_flag) %>% 
    summarise(person_trips = n()) %>% 
    left_join(vtrip, by = c("orig_msa", "orig_nevshuttle_flag",
                            "dest_msa", "dest_nevshuttle_flag")) %>% 
    mutate(year = YEAR) %>%
    select(year, orig_msa, orig_nevshuttle_flag, dest_msa, dest_nevshuttle_flag, 
           person_trips, auto_trips)
  
  # write summary tables out!    
  write.csv(ptrip, paste0(output_dir,paste0("Microtransit/Model Data NEV Shuttle_",s,"_",as.character(Sys.Date()) ,".csv")), row.names = F)
  #write.csv(chariot, paste0(output_dir,"Model Data CHARIOT.csv"), row.names = F)
  #####
#}

