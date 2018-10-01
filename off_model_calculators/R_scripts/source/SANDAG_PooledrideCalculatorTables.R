# Arash Asadabadi @ WSP USA Inc 09-18-2018
# convert Rosella's SAS script to generate tables for Pooled Rides GHG calculator
# files required to run this script include:
# 1. ct-ramp output individual trip file
# 2. distance travl time skims for DA and SR
# 3. SANDAG ABM auto ownership model output
# 4. mgra_taz_msa_xwalk.csv which Indicates the TAZ and MSA that corresponds to each MGRA
# install packages from CRAN if required packages are not installed
#rm(list = ls(all.names=TRUE))
# list.of.packages <- c("data.table", "bit64", "tidyverse")
# new.packages <- list.of.packages[!(list.of.packages %in% installed.packages()[,"Package"])]
# 
# if(length(new.packages)) install.packages(new.packages, repos='http://cran.us.r-project.org')
# 
# library(data.table)
# library(bit64)
# library(tidyverse)
# library(omxr)

#Scenario=c("2035_E_minus_bu")
#for (s in Scenario){

# ----------------------------------------------------------------------

# set working directory, data directory and input file names here

#main_dir       <- paste0("T:/RTP/2019RP/rp19_scen/abm_runs_bod/",s,"/")
#dataDir        <- "T:/RTP/2019RP/rp19_scen/abm_runs_bod/r scripts off-model/"  # where input files are
tripfile       <- "output/indivTripData_3.csv"               # ct-ramp output individual trip file 
ownership_file <- "output/aoResults.csv"
mapping_file   <- "mgra_taz_msa_xwalk.csv "
#output_dir     <- paste0(dataDir,"output/")
#read files
indiv_trip     <- fread(paste0(main_dir,tripfile), header = T, sep = ",")
ownership      <- fread(paste0(main_dir,ownership_file), header = T, sep = ",")
mapping        <- fread(paste0(dataDir,mapping_file), header = T, sep = ",")
YEAR= as.numeric(substr(s,1,4))

# merging mgra_TAZ_MSA mapping and auto ownership to the trip file 

mapping_orig <- mapping %>%
  rename(orig_mgra = mgra, orig_TAZ = taz, orig_MSA = msa)
mapping_dest <- mapping %>%
  rename(dest_mgra = mgra, dest_TAZ = taz, dest_MSA = msa)
indiv_trip_temp <- indiv_trip %>%
  mutate(period=ifelse(between(stop_period,1,3),"EA",ifelse(between(stop_period,4,9),"AM",ifelse(between(stop_period,10,22),"MD",ifelse(between(stop_period,23,29),"PM","NT"))))) %>%
  left_join(mapping_orig, by = "orig_mgra") %>%
  left_join(mapping_dest, by = "dest_mgra") %>%
  left_join(ownership, c("hh_id" = "HHID"))

# preparing the trip summary

trip_summary <- indiv_trip_temp %>%
  mutate( mode=ifelse(between(trip_mode,1,2),"DA",ifelse(between(trip_mode,3,6),"SR",ifelse(between(trip_mode,7,8),"NM","TRN"))),
          purpose=ifelse((tour_purpose=="Work"|tour_purpose=="school"),tour_purpose,"Other"), nautos= AO) %>% 
  group_by(orig_MSA,dest_MSA,period,mode,purpose,nautos)%>%
  summarise(trips=n())%>%
  mutate(year=YEAR)%>%
  select(year,orig_MSA,dest_MSA,period,mode,purpose,nautos,trips)%>%
  rename("orig_msa"=orig_MSA,"dest_msa"=dest_MSA)
  
# preparing the skim summary  
# reading and reshaping skims 

time_period <- c("AM", "MD", "PM", "EV", "EA")
for (t in time_period){
skim_file <- paste0("output/traffic_skims_",t,".omx")
DA_distance <- read_omx(paste0(main_dir,skim_file) , paste0(t,"_SOVGPM_DIST")) 
DA_time     <- read_omx(paste0(main_dir,skim_file) , paste0(t,"_SOVGPM_TIME"))
SR_time     <- read_omx(paste0(main_dir,skim_file) , paste0(t,"_HOV2TOLLM_TIME"))

r=dim(DA_distance)
DA_distance_reshaped <- data.frame(OTAZ = rep(1:r[1],each=r[1]), DTAZ = rep(1:r[1],r[1]) , Distance=c(t(DA_distance)))

r=dim(DA_time)
DA_Time_reshaped <- data.frame(OTAZ = rep(1:r[1],each=r[1]), DTAZ = rep(1:r[1],r[1]) , Travel_time_DA=c(t(DA_time)))

r=dim(SR_time)
SR_Time_reshaped <- data.frame(OTAZ = rep(1:r[1],each=r[1]), DTAZ = rep(1:r[1],r[1]), Travel_time_SR= c(t(SR_time)))

assign(paste0("All_skims_",t), 
       DA_distance_reshaped %>% 
       left_join(DA_Time_reshaped, by=c("OTAZ"="OTAZ","DTAZ"="DTAZ")) %>%
       left_join(SR_Time_reshaped, by=c("OTAZ"="OTAZ","DTAZ"="DTAZ"))) %>%
       mutate(Travel_time_SR=ifelse(Travel_time_SR>Travel_time_DA,Travel_time_DA,Travel_time_SR))
}

# partition to time periods

indiv_trip_AM <- indiv_trip_temp%>%
  filter(period=="AM") %>%
  select(period,orig_mgra,orig_MSA,orig_TAZ,dest_mgra,dest_MSA,dest_TAZ)%>%
  left_join(All_skims_AM, by=c("orig_TAZ"="OTAZ","dest_TAZ"="DTAZ"))
indiv_trip_PM <- indiv_trip_temp%>%
  filter(period=="PM") %>%
  select(period,orig_mgra,orig_MSA,orig_TAZ,dest_mgra,dest_MSA,dest_TAZ)%>%
  left_join(All_skims_PM, by=c("orig_TAZ"="OTAZ","dest_TAZ"="DTAZ"))
indiv_trip_MD <- indiv_trip_temp%>%
  filter(period=="MD")%>%
  select(period,orig_mgra,orig_MSA,orig_TAZ,dest_mgra,dest_MSA,dest_TAZ)%>%
  left_join(All_skims_MD, by=c("orig_TAZ"="OTAZ","dest_TAZ"="DTAZ"))
indiv_trip_EV <- indiv_trip_temp%>%
  filter(period=="NT")%>%
  select(period,orig_mgra,orig_MSA,orig_TAZ,dest_mgra,dest_MSA,dest_TAZ)%>%
  left_join(All_skims_EV, by=c("orig_TAZ"="OTAZ","dest_TAZ"="DTAZ"))
indiv_trip_EA <- indiv_trip_temp%>%
  filter(period=="EA")%>%
  select(period,orig_mgra,orig_MSA,orig_TAZ,dest_mgra,dest_MSA,dest_TAZ)%>%
  left_join(All_skims_EA, by=c("orig_TAZ"="OTAZ","dest_TAZ"="DTAZ"))

skim_summary_temp=do.call("rbind", list(indiv_trip_AM,indiv_trip_EA,indiv_trip_PM,indiv_trip_MD,indiv_trip_EV))
skim_summary <- skim_summary_temp %>%
  group_by(orig_MSA,dest_MSA,period) %>%
  summarise(avg_datime=mean(Travel_time_DA), avg_srtime=mean(Travel_time_SR), avg_distance=mean(Distance)) %>%
  mutate(year=YEAR)%>%
  select(year,orig_MSA,dest_MSA,period,avg_datime,avg_srtime,avg_distance)%>%
  rename("orig_msa"=orig_MSA,"dest_msa"=dest_MSA)


# write summary tables out!    
write.csv(trip_summary, paste0(output_dir,"PooledRide/pooledride_trips_", s,"_", as.character(Sys.Date()),".csv" ), row.names = F)
write.csv(skim_summary, paste0(output_dir,"PooledRide/pooledride_times_", s,"_", as.character(Sys.Date()),".csv" ), row.names = F)
#}