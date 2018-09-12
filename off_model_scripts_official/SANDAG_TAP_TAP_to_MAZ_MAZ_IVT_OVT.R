
# Author: Vivek Kumar 
# Edited by Dora Wu @ 07-09-2018
# This script reads ct-ramp output individual trip file, transit skims, and walk skim,
# to calculate MAZ-to-MAZ transit travel time, including in-vehicle time and out-of-vehicle time.
# files required to run this script include:
# 1. ct-ramp output individual trip file
# 2. CUBE transit skims - transfer time, initial wait time, transfer wait time, and total in-vehicle time
# 3. walk time file
# 4. MAZ-TAZ match file
# This script can be run from command window as: 
# Rscript.exe --vanilla --verbose SANDAG_TAP_TAP_to_MAZ_MAZ_IVT_OVT.R > SANDAG_MAZTransitTime.log

# install packages from CRAN if required packages are not installed
list.of.packages <- c("data.table", "foreign", "tidyverse")
new.packages <- list.of.packages[!(list.of.packages %in% installed.packages()[,"Package"])]

if(length(new.packages)) install.packages(new.packages, repos="http://cran.us.r-project.org")

library(foreign)
library(data.table)
library(tidyverse)
PrjDir  <- "C:/Work/SANDAG"             # working directory, where outputs will be written to
dataDir <- "Z:/transit_related_SANDAG/" # where input files are 

setwd(PrjDir)

#--------------------------------------------------------------------------------------------------------------------
# Update input file paths here!
indiv_trip  <- fread(paste0(dataDir, "indivTripData_3.csv"), header = T, sep = ",")
walktime    <- fread(paste0(dataDir, "walkMgraTapEquivMinutes.csv"), header = T, sep = ",")
mgra_taz    <- read.dbf(paste0(dataDir, "mgra_taz.dbf"), as.is = F)
#--------------------------------------------------------------------------------------------------------------------

# filter out non-work trips
# aggregate individual trips by origin and destination MAZs
ptrip_MAZ  <- indiv_trip %>% 
    filter(orig_purpose == "Home" & "dest_purpose" == "Work") %>% 
    group_by(orig_mgra, dest_mgra) %>% 
    summarise(count = n()) %>% 
    ungroup()


#Reading the required TAP tp TAP skim files 
XFERTIME <- fread(paste0(dataDir, "transit_skims/walk_time.csv"),
                  col.names = c("OTAP", "DTAP", "XferTime"))
XWAIT    <- fread(paste0(dataDir, "transit_skims/transfer_wait_time.csv"),
                  col.names = c("OTAP", "DTAP", "XwaitTime"))
IWAIT    <- fread(paste0(dataDir, "transit_skims/initial_wait_time.csv"),
                  col.names = c("OTAP", "DTAP", "IwaitTime"))
IVT_sum  <- fread(paste0(dataDir, "transit_skims/IVT_sum.csv"),
                  col.names = c("OTAP", "DTAP", "IVT"))

setkey(XFERTIME, OTAP, DTAP)
setkey(XWAIT, OTAP, DTAP)
setkey(IWAIT, OTAP, DTAP)
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


write.csv(maz_transitTime, "MAZ_MAZ_TransitTime.csv", row.names = F)


