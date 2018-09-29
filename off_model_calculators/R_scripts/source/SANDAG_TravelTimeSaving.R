# Author: Yinan Zheng @ WSP USA Inc 
# edited by Dora Wu 07-16-2018
# editet by Arash Asadabadi @ 09-18-2018
## This script is used for calculating managed lane travel time savings in SANDAG compared to general purpose lane (driving alone). 
## The time savings vary by trip origin and destination, and by plan year. 
## The time savings of Military vanpools are paired to specific military bases to not overestimate the elasticity of demand.


# files required to run this script include:
# 1. ct-ramp output individual trip file
# 2. distance skim file
# 3. ct-ramp output work location file
# 4. "MicrotransitAreaFlags.csv" file that contains TAZ, MSA, FRED flags, CHARIOT flags for each MGRA
# modified by Arash : The script now reads .OMX files and convert them to data frames that can be written in the scritps
# This script can be run from command window as: 
# Rscript.exe --vanilla --verbose SANDAG_MicrotransitCalculatorTables.R > SANDAG_Microtansit.log
#rm(list = ls(all.names=TRUE))

# install packages from CRAN if required packages are not installed
# list.of.packages <- c("data.table", "bit64", "tidyverse","devtools")
# new.packages <- list.of.packages[!(list.of.packages %in% installed.packages()[,"Package"])]
# 
# if(length(new.packages)) install.packages(new.packages, repos='http://cran.us.r-project.org')
# devtools::install_github("gregmacfarlane/omxr")
# library(omxr)
# library(tidyverse)
# library(data.table)

#args = commandArgs(trailingOnly = TRUE)
#Scenario=args
# Scenario=c("2035_D","2035_Fx","2035_E_minus_bu")
#Scenario=c("2035_F")
# for (s in Scenario){
# Update input file paths here!
# main_dir     <- paste0("T:/RTP/2019RP/rp19_scen/abm_runs_bod/",s,"/")  
# dataDir      <- "T:/RTP/2019RP/rp19_scen/abm_runs_bod/r scripts off-model/"
skim_file    <- "output/traffic_skims_AM.omx"
TAZ_MSA_file <- "TAZ_MSA.csv"
# output_dir   <- paste0(dataDir,"output/")

### Input Data
TAZ_MSA <- fread(paste0(dataDir,TAZ_MSA_file)) ## TAZ-MSA lookup table
mb      <- c("4341","4392","4047","2200","2279","2159","143") ## MSAs of the Military Bases in SANDAG (Miramar, Coronado, Naval Base San Diego, Pendleton)
YEAR    <- as.numeric(substr(s,1,4))
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

#####converting omx traffic skims to the old version
#list_omx(AM_skim_file)
skim_DA <- read_omx(paste0(main_dir,skim_file),"AM_SOVGPM_TIME")
skim_SV <- read_omx(paste0(main_dir,skim_file),"AM_HOV2TOLLM_TIME")
r       <- dim(skim_DA)
DA      <- data.frame(orig= rep(1:r[1],each=r[1]), dest= rep(1:r[1],r[1]) , ttime= c(t(skim_DA))) 
SV      <- data.frame(orig= rep(1:r[1],each=r[1]), dest= rep(1:r[1],r[1]) , ttime= c(t(skim_SV)))

### Calculation Starts
#for (year in yearlist) {
  
  # Read in travel time skims
#  DA <- fread(paste("STM_", year, ".csv", sep = "")) ## SOV time skims from SANDAG Model
#  SV <- fread(paste("HTM_", year, ".csv", sep = "")) ## HOV time skims from SANDAG Model

  
  # Get MSA for each origin and destination TAZ with the lookup table
  DA_MSA <- data_MSA(DA)
  SV_MSA <- data_MSA(SV)
  
  # Get the average travel time for each MSA pair
  DA_group <- data_group(DA_MSA)
  SV_group <- data_group(SV_MSA) 
  rownames(SV_group)=c(0:9)
  SV_group[,1]=NULL
  rownames(DA_group)=c(0:9)
  DA_group[,1]=NULL
  ## For MSAs that are outside of the SANDAG region: 
  ## Imperial MSA has the same travel time savings as East County; 
  ## San Bernardino has the same travel time savings as Riverside;
  ## Los Angeles has the same travel time savings as Orange
  ## For Military Bases
  SV_group[,"10"]=SV_group[,7]
  SV_group[,"11"]=SV_group[,8]
  SV_group["10",]=SV_group[7,]
  SV_group["11",]=SV_group[8,]
  DA_group[,"10"]=DA_group[,7]
  DA_group[,"11"]=DA_group[,8]
  DA_group["10",]=DA_group[7,]
  DA_group["11",]=DA_group[8,]
  SV_group[8:12,8:12]=NA
  DA_group[8:12,8:12]=NA
  
  MB_DA_group <- DA_MSA%>%
    filter(dest %in% mb)%>%
    data_group()%>%
    mutate("2"=0,"3"=0,"5"=0,"6"=0,"7"=0,"8"=0,"9"=0,"10"=0,"11"=0)%>%
    select(as.character(0:11))
  MB_SV_group <- SV_MSA%>%
    filter(dest %in% mb)%>%
    data_group()%>%
    mutate("2"=0,"3"=0,"5"=0,"6"=0,"7"=0,"8"=0,"9"=0,"10"=0,"11"=0)%>%
    select(as.character(0:11))
  
  rownames(MB_DA_group)=c(0:9)
  MB_DA_group[,1]=NULL
  MB_DA_group["10",]= MB_DA_group[7,]
  MB_DA_group["11",]= MB_DA_group[8,]  
  MB_DA_group[8:12,8:12]=NA

  rownames( MB_SV_group)=c(0:9)
  MB_SV_group[,1]=NULL
  MB_SV_group["10",]=MB_SV_group[7,]
  MB_SV_group["11",]=MB_SV_group[8,]
  MB_SV_group[8:12,8:12]=NA
  # Caculate the travel time savings of SV relative to DA
  assign(paste0("ttsaving", YEAR ), SV_group - DA_group)
  ## For Military Bases
  assign(paste0("MB_ttsaving", YEAR), MB_SV_group - MB_DA_group)

  write.csv( assign(paste0("ttsaving", YEAR ), SV_group - DA_group), paste0(output_dir,"Vanpool/ttsaving_", s,"_", as.character(Sys.Date()),".csv" ), row.names = T)
  write.csv( assign(paste0("MB_ttsaving", YEAR), MB_SV_group - MB_DA_group), paste0(output_dir,"Vanpool/MB_ttsaving_", s, "_", as.character(Sys.Date()),".csv"), row.names = T)
 
#}
  # }
  

