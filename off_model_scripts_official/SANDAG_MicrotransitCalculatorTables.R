# Dora Wu @ WSP USA Inc 07-06-2018
# convert Rosella's SAS script to generate tables for MicroTransit GHG calculator
# files required to run this script include:
# 1. ct-ramp output individual trip file
# 2. distance skim file
# 3. ct-ramp output work location file
# 4. "MicrotransitAreaFlags.csv" file that contains TAZ, MSA, FRED flags, CHARIOT flags for each MGRA
# This script can be run from command window as: 
# Rscript.exe --vanilla --verbose SANDAG_MicrotransitCalculatorTables.R > SANDAG_Microtansit.log

# install packages from CRAN if required packages are not installed
list.of.packages <- c("data.table", "bit64", "tidyverse")
new.packages <- list.of.packages[!(list.of.packages %in% installed.packages()[,"Package"])]

if(length(new.packages)) install.packages(new.packages, repos='http://cran.us.r-project.org')

library(data.table)
library(bit64)
library(tidyverse)

# ----------------------------------------------------------------------
# set working directory, data directory and input file names here
setwd("G:\\Projects\\SANDA")  # set working direction, where outputs will be written to
dataDir     <- "Z:\\transit_related_SANDAG\\"  # where input files are
tripFile    <- "indivTripData_3.csv"               # ct-ramp output individual trip file 
flagFile    <- "MicrotransitAreaFlags.csv"         # file contain MAZ and corresponding MSA and FRED area flags
skimFile    <- "dant_distance.csv"                 # skim file that contains TAZ-to-TAZ distance
workLocFile <- "..\\wsLocResults_3.csv"            # ct-ramp output work location file

# set analysis year
YEAR = 2016
# -----------------------------------------------------------------------

# read in files
itripClasses <- c(rep("integer", 6), rep("character", 3),
                  rep("integer", 8))
itrip <- fread(paste0(dataDir, tripFile), colClasses = itripClasses, nrows = -1)

MTAflags <- read.csv(paste0(dataDir, flagFile), header = T, stringsAsFactors = F)
MTAflags_colName <- c("mgra", "msa", "TAZ", "fred_flag", "chariot_flag",
                      "year_fred", "year_chariot")
colnames(MTAflags) <- MTAflags_colName
MTAflags <- MTAflags %>%
    mutate(fred_flag    = ifelse(year_fred > 2016, 0, fred_flag),
           chariot_flag = ifelse(year_chariot > 2016, 0, chariot_flag))

distance <- fread(paste0(dataDir, skimFile), colClasses = c("integer", "integer", "numeric"),
                  col.names = c("OTAZ", "DTAZ", "Dist"), nrows = -1)
workLoc <- fread(paste0(dataDir, workLocFile),
                 colClasses = c(rep("integer", 12), "numeric", "numeric",
                                "integer", "numeric", "numeric"), nrows = -1)

# create chariot data summary
chariot <- workLoc %>% 
    mutate(home_msa   = MTAflags$msa[match(HomeMGRA, MTAflags$mgra)],
           emp_center = MTAflags$chariot_flag[match(WorkLocation, MTAflags$mgra)]) %>% 
    group_by(home_msa, emp_center) %>% 
    summarise(workers = n()) %>% 
    ungroup() %>% 
    mutate(year = YEAR) %>% 
    select(year, home_msa, emp_center, workers)

# attach trip distance to trip file, and only count trips 2 miles or shorter
itrip <- itrip %>% 
    mutate(OTAZ = MTAflags$TAZ[match(orig_mgra, MTAflags$mgra)],
           DTAZ = MTAflags$TAZ[match(dest_mgra, MTAflags$mgra)]) 
           
itrip <- setDT(itrip)           
setkey(itrip, OTAZ, DTAZ)     
setkey(distance, OTAZ, DTAZ)    

itrip <- merge(itrip, distance, all.x = T)
colnames(MTAflags) <- c(paste0("orig_", MTAflags_colName))

itrip <- itrip %>% 
    filter(Dist <= 2) %>% 
    left_join(MTAflags, by = "orig_mgra")

colnames(MTAflags) <- c(paste0("dest_", MTAflags_colName))

itrip <- itrip %>% 
    left_join(MTAflags, by = "dest_mgra")

# create auto trip summary    
vtrip <- itrip %>% 
    filter(trip_mode <= 8) %>% 
    group_by(orig_msa, orig_fred_flag, dest_msa, dest_fred_flag) %>% 
    summarise(auto_trips = n())

# create person trip summary and merge with auto trip summmary    
ptrip <- itrip %>% 
    group_by(orig_msa, orig_fred_flag, dest_msa, dest_fred_flag) %>% 
    summarise(person_trips = n()) %>% 
    left_join(vtrip, by = c("orig_msa", "orig_fred_flag",
                            "dest_msa", "dest_fred_flag")) %>% 
    mutate(year = YEAR) %>%
    select(year, orig_msa, orig_fred_flag, dest_msa, dest_fred_flag, 
           person_trips, auto_trips)

# write summary tables out!    
write.csv(ptrip, "Model Data FRED.csv", row.names = F)
write.csv(chariot, "Model Data CHARIOT.csv", row.names = F)




