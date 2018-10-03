# Arash Asadabadi @ WSP USA Inc 09-18-2018
# This script calls the other scirps for generating the inputs for calculators
#rm(list = ls(all.names=TRUE))

args = commandArgs(trailingOnly = TRUE)
properties_file <- args[1]
#properties_file <- "T:/RTP/2019RP/rp19_scen/abm_runs_bod/r scripts off-model/source/test.properties"

list.of.packages <- c("data.table", "foreign", "tidyverse","properties")
new.packages <- list.of.packages[!(list.of.packages %in% installed.packages()[,"Package"])]

if(length(new.packages)) install.packages(new.packages, repos="http://cran.us.r-project.org")
devtools::install_github("gregmacfarlane/omxr")
library(omxr)
library(foreign)
library(data.table)
library(tidyverse)
library(properties)
library(bit64)

properties                   <- read.properties(properties_file)
poolerdrides_calculator      <- as.logical(as.numeric(trimws(properties$`pooledrides.calculator`)))
travel_time_savings          <- as.logical(as.numeric(trimws(properties$`travel.time.savings`)))
travel_times_2016            <- as.logical(as.numeric(trimws(properties$`travel.times.2016`)))
micrtotransit_calculator_NEV <- as.logical(as.numeric(trimws(properties$`micrtotransit.calculator.NEV`)))
micrtotransit_calculator_CB  <- as.logical(as.numeric(trimws(properties$`micrtotransit.calculator.CB`)))
main_dir                     <- trimws(properties$`main.dir`)
source_dir                   <- trimws(properties$`source.dir`)
dataDir                      <- trimws(properties$`data.dir`)
output_dir                   <- paste0(main_dir,"output/")                                                                         

# run travel times 2016 out of the loop just for one time                                                                        
if (travel_times_2016 ) {
  print("SANDAG_TravelTime2016.R is running")
  source(paste0(source_dir,"SANDAG_TravelTime2016.R"))
}


Scenario= str_split(trimws(properties$`scenarios`), ",")
for (s in Scenario[[1]]) {
                main_dir <- paste0(trimws(properties$`scenario.dir`),s,"/")  

                
                if (poolerdrides_calculator ) {
                  print(paste0("PooledrideCalculatorTables.R is running for ",s))
                  source(paste0(source_dir,"SANDAG_PooledrideCalculatorTables.R"))
                }
                if (travel_time_savings ){
                  print(paste0("SANDAG_TravelTimeSaving.R is running for ",s))
                  source(paste0(source_dir,"SANDAG_TravelTimeSaving.R"))
                }
                if (micrtotransit_calculator_NEV ){
                  print(paste0("SANDAG_MicrotransitCalculatorTables.R is running for ",s))
                  source(paste0(source_dir,"SANDAG_MicrotransitCalculatorTables.R"))
                  print(paste0("the average distance for auto trips <=2 miles with destination in MGRAs with Nev flag=1 is ",as.character(average_Dist)))
                }
                if (micrtotransit_calculator_CB ) {
                  print(paste0("SANDAG_TAP_TAP_to_MAZ_MAZ_IVT_OVT.R is running for ",s))
                  source(paste0(source_dir,"SANDAG_TAP_TAP_to_MAZ_MAZ_IVT_OVT.R"))
      }
                                                                                                         
} 
