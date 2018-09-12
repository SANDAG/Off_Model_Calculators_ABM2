# Author: Yinan Zheng @ WSP USA Inc 
# edited by Dora Wu 07-16-2018
#
## This script is used for calculating managed lane travel time savings in SANDAG compared to general purpose lane (driving alone). 
## The time savings vary by trip origin and destination, and by plan year. 
## The time savings of Military vanpools are paired to specific military bases to not overestimate the elasticity of demand.


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

library(tidyverse)
library(data.table)

# ------------------- 
dataDir <- "C:\\Projects\\SANDAG\\MicroTransit\\"


### Input Data
TAZ_MSA <- fread("TAZ_MSA.csv") ## TAZ-MSA lookup table
mb <- c("4341","4392","4047","2200","2279","2159","143") ## MSAs of the Military Bases in SANDAG (Miramar, Coronado, Naval Base San Diego, Pendleton)
yearlist <- c(2016,2020,2025,2035,2050)  ## Modeled year


### Built-in Functions
# Get MSA for each origin and destination TAZ with the lookup table
data_MSA <- function (data) {
  data_MSA <- data%>%
    left_join(TAZ_MSA, by = c("orig" = "TAZ_SR13"))%>%
    left_join(TAZ_MSA, by = c("dest" = "TAZ_SR13"), suffix = c(".orig", ".dest"))%>%
    ## For MSAs that are outside of the SANDAG region: 
    ## Imperial MSA has the same travel time savings as East County; 
    ## San Bernardino has the same travel time savings as Riverside;
    ## Los Angeles has the same travel time savings as Orange.
    mutate(MSA.orig = ifelse(orig == 10, 7, ifelse(orig == 12, 8, ifelse(orig == 6, 9, MSA.orig))),  
           MSA.dest = ifelse(dest == 10, 7, ifelse(dest == 12, 8, ifelse(dest == 6, 9, MSA.dest))))%>%
    filter(!is.na(MSA.orig) & !is.na(MSA.dest))
  return(data_MSA)
}

# Get the average travel time for each MSA pair
data_group <- function (data_MSA) {
  data_group <- data_MSA%>%
    group_by(MSA.orig, MSA.dest)%>%
    summarise(avg_tt = mean(ttime))%>%
    spread(MSA.dest, avg_tt)
  return(data_group)
}


### Calculation Starts
for (year in yearlist) {
  
  # Read in travel time skims
  DA <- fread(paste("STM_", year, ".csv", sep = "")) ## SOV time skims from SANDAG Model
  SV <- fread(paste("HTM_", year, ".csv", sep = "")) ## HOV time skims from SANDAG Model
  names(DA)<- c("orig", "dest", "ttime")
  names(SV) <- c("orig", "dest", "ttime")
  
  # Get MSA for each origin and destination TAZ with the lookup table
  DA_MSA <- data_MSA(DA)
  SV_MSA <- data_MSA(SV)
  
  # Get the average travel time for each MSA pair
  DA_group <- data_group(DA_MSA)
  SV_group <- data_group(SV_MSA)
  ## For Military Bases
  MB_DA_group <- DA_MSA%>%
    filter(dest %in% mb)%>%
    data_group()
  MB_SV_group <- SV_MSA%>%
    filter(dest %in% mb)%>%
    data_group()
  
  # Caculate the travel time savings of SV relative to DA
  assign(paste("ttsaving", year, sep = "_"), SV_group - DA_group)
  ## For Military Bases
  assign(paste("MB_ttsaving", year, sep = "_"), MB_SV_group - MB_DA_group)

}

