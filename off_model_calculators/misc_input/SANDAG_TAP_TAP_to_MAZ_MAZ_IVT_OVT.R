
# Author: Vivek Kumar 
# Edited by Dora Wu @ 07-09-2018
# Editet by Arash Asadabadi @ 09-18-2018
# This script reads ct-ramp output individual trip file, transit skims, and walk skim,
# to calculate MAZ-to-MAZ transit travel time, including in-vehicle time and out-of-vehicle time.
# files required to run this script include:
# 1. ct-ramp output individual trip file
# 2. CUBE transit skims - transfer time, initial wait time, transfer wait time, and total in-vehicle time
# 3. walk time file
# 4. MAZ-TAZ match file
# modified by Arash : The script now reads .OMX files and convert them to data frames that can be written in the scritps
# This script can be run from command window as: 
# Rscript.exe --vanilla --verbose SANDAG_TAP_TAP_to_MAZ_MAZ_IVT_OVT.R > SANDAG_MAZTransitTime.log

# install packages from CRAN if required packages are not installed
list.of.packages <- c("data.table", "foreign", "tidyverse")
new.packages <- list.of.packages[!(list.of.packages %in% installed.packages()[,"Package"])]

if(length(new.packages)) install.packages(new.packages, repos="http://cran.us.r-project.org")

library(foreign)
library(data.table)
library(tidyverse)

Scenario=c("2016","2020","2025nb","2035nb","2035_D","2035_Fx","2035_E_minus_test2")
for (s in Scenario){
  
  # Update input file paths here!
  main_dir=paste0("T:/RTP/2019RP/rp19_scen/abm_runs_bod/",s,"/")  
  skim_transit_file   <- "output/transit_skims.omx"
  tripfile    <- "output/indivTripData_3.csv" 
  walktime_file <- "output/walkMgraTapEquivMinutes.csv"
  #mgra_taz_file    <- "mgra_taz.dbf" this is not being used in the script
  output_dir  <- paste0(dataDir,"output/")
  #--------------------------------------------------------------------------------------------------------------------
  
  #read files
  indiv_trip  <- fread(paste0(main_dir,tripfile), header = T, sep = ",")
  walktime    <- fread(paste0(main_dir,walktime_file), header = T, sep = ",")
  walk_time <- read_omx(paste0(main_dir,skim_transit_file) , "AM_ALLPEN_XFERWALK")
  transfer_wait_time <- read_omx(paste0(main_dir,skim_transit_file) , "AM_ALLPEN_XFERWAIT") 
  initial_wait_time <- read_omx(paste0(main_dir,skim_transit_file) , "AM_ALLPEN_FIRSTWAIT")
  IVT <- read_omx(paste0(main_dir,skim_transit_file) , "AM_ALLPEN_TOTALIVTT")
  # filter out non-work trips
  # aggregate individual trips by origin and destination MAZs
  ptrip_MAZ  <- indiv_trip %>% 
    filter(orig_purpose == "Home" & dest_purpose == "Work") %>% 
    group_by(orig_mgra, dest_mgra) %>% 
    summarise(count = n()) %>% 
    ungroup()
  
  #Reading the required TAP tp TAP skim files. OMX files are first converted to dataframes and being reshaped to previous version 
  #XFERTIME <- fread(paste0(dataDir, "transit_skims/walk_time.csv"),
  #                  col.names = c("OTAP", "DTAP", "XferTime"))
  r=dim(walk_time)
  XFERTIME<- data.frame(rep(1:r[1],each=r[1]), rep(1:r[1],r[1]) , c(t(walk_time)))
  colnames(XFERTIME) = c("OTAP", "DTAP", "XferTime")
  #XWAIT    <- fread(paste0(dataDir, "transit_skims/transfer_wait_time.csv"),
  #                  col.names = c("OTAP", "DTAP", "XwaitTime"))
  r=dim(transfer_wait_time)
  XWAIT <- data.frame(rep(1:r[1],each=r[1]), rep(1:r[1],r[1]) , c(t(transfer_wait_time)))
  colnames(XWAIT) = c("OTAP", "DTAP", "XwaitTime")
  
  #IWAIT    <- fread(paste0(dataDir, "transit_skims/initial_wait_time.csv"),
  #                  col.names = c("OTAP", "DTAP", "IwaitTime"))
  r=dim(initial_wait_time)
  IWAIT  <- data.frame(rep(1:r[1],each=r[1]), rep(1:r[1],r[1]) , c(t(initial_wait_time))) 
  colnames(IWAIT ) = c("OTAP", "DTAP", "IwaitTime")
  
  #IVT_sum  <- fread(paste0(dataDir, "transit_skims/IVT_sum.csv"),
  #                  col.names = c("OTAP", "DTAP", "IVT"))
  r=dim(IVT)
  IVT_sum  <- data.frame(rep(1:r[1],each=r[1]), rep(1:r[1],r[1]) , c(t(IVT)))
  colnames(IVT_sum ) = c("OTAP", "DTAP", "IVT")
  
  XFERTIME=data.table(XFERTIME)
  setkey(XFERTIME, OTAP, DTAP)
  XWAIT=data.table(XWAIT)
  setkey(data.table(XWAIT), OTAP, DTAP)
  IWAIT=data.table(IWAIT)
  setkey(IWAIT, OTAP, DTAP)
  IVT_sum=data.table(IVT_sum)
  setkey(IVT_sum, OTAP, DTAP)
  
  # merge skims into one dataset, and remove TAP pairs with no transit path
  TTime_TAP <- merge(XFERTIME, XWAIT, all = T)
  TTime_TAP <- merge(TTime_TAP, IWAIT, all = T)
  TTime_TAP <- merge(TTime_TAP, IVT_sum, all = T)
  
  
  TTime_TAP <- TTime_TAP %>% 
    mutate(OVT = XferTime + XwaitTime + IwaitTime,
           totTime = IVT + OVT) %>% 
    filter(totTime != 0) %>% 
    mutate(index = OTAP * 10000 + DTAP) %>% 
    select(OTAP, DTAP, index, IVT, OVT, totTime)  
  
  # reading boarding time from walk time file
  bdingTime <- walktime %>% 
    select(mgra, tap, boardingActual) %>% 
    rename(bding_tap = tap)
  
  # reading alighting time from walk time file    
  altingTime <- walktime %>% 
    select(mgra, tap, alightingActual) %>% 
    rename(alting_tap = tap)
  
  # calcualte MAZ-MAZ transit travel time
  # total transit time should be IVT + XFERTIME + IWAITTIME + XWAITTIME + boardingTime + alightingTime
  # one MAZ can connect to multiple TAPs, use the minimum travel time from TAP pairs
  maz_transitTime <- ptrip_MAZ %>% 
    left_join(bdingTime, by = c("orig_mgra" = "mgra")) %>% 
    left_join(altingTime, by = c("dest_mgra" = "mgra")) %>% 
    rename(OTAP = bding_tap, DTAP = alting_tap) %>% 
    mutate(boardingActual = ifelse(is.na(OTAP), 9999, boardingActual),
           OTAP = ifelse(is.na(OTAP), 0, OTAP),
           alightingActual = ifelse(is.na(DTAP), 9999, alightingActual),
           DTAP = ifelse(is.na(DTAP), 0, DTAP),
           index = OTAP * 10000 + DTAP,
           taptime = TTime_TAP$totTime[match(index, TTime_TAP$index)],
           taptime = ifelse(is.na(taptime), 9999, taptime),
           maztime = boardingActual + taptime + alightingActual) %>% 
    group_by(orig_mgra, dest_mgra) %>% 
    slice(which.min(maztime)) %>% 
    left_join(TTime_TAP, by = "index", all.x = T) %>%
    mutate(OVT = maztime - IVT,
           maztime = ifelse(is.na(IVT), NA, maztime)) %>% 
    select(orig_mgra, dest_mgra, count, maztime, IVT, OVT) %>% 
    rename(totTime = maztime)
  
  
  write.csv(maz_transitTime,paste0(output_dir, "MAZ_MAZ_TransitTime.csv"), row.names = F)
  
}
