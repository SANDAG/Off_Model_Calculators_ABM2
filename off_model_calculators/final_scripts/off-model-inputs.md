# Off Model Calculator Work Flow
This document describes the work flow required to run each of the off model 
calculators prepared by SANDAG's TDM and planning staff.

Each of these off model calculators will need to be run for every 2035 build 
scenario. (The sheet names will need to be updated, since each sheet can only hold
a single scenario for each model year.) There are 7 off model calculators:
* Bikeshare
* Carshare
* Community Based Transportation Programs (CBTP)
* Electric Vehicles
*	Microtransit
* Pooled Rides
* Vanpool
	* SANDAG ABM Transit Mode Share (binomial logit substitute)

# Bikeshare
This sheet will require the confirmation of the following values from SANDAG 
planning staff:
* Main Sheet
	* Car Substitution rates (for regular bikes and ebikes)
	* Average bike trip distances (for regular bikes and ebikes)
* Bikeshare Demand
	* Bikes / 1,000 population per MSA
	* Confirmation of 50% ebike mode share
* Bikeway Miles
	* 2050 Bikeway miles estimate
* Model Data (by year, scenario and mgra)
	* Total population
	* MSA_ID
	* Bikeshare flag
* Emission Factors
	* Use of 2014 EMFAC Values from 14.0.0
	* 2050 EMFAC values if any data is to be generated

# Carshare
This sheet will require the confirmation of the following values from SANDAG
planning staff:
* Main Sheet
	* Percent membership in one-way carsharing
	* Daily VMT reduction per round-trip/one-way carsharing member
* Carshare Demand
	* Threshold for urban vs. suburban population density (D5)
	* Percent of urban/suburban/college employees/college students/military population 
		expected to become carshare members.
* Model Data (by year, scenario, and mgra)
	* Total population
	* Adult population
	* Total population density (MGRA population / MGRA total area)
	* Total employment
	* College student enrollment
	* MSA_ID
	* Carshare flag
	* University flag
	* Military base flag
* Emission Factors
	* Use of 2014 EMFAC Values from 14.0.0
	* 2050 EMFAC values if any data is to be generated

# CBTP
This sheet will require the confirmation of the following values from SANDAG 
planning staff:

* Main Sheet
	* Average daily one-way driving trips per household
	* Average number of years for which behavior change persists
	* Average one-way trip length for driving trips
* Community-Based Coverage Areas
	* Use of Community-Based Coverage Areas and Regional Growth Forecast (14.1.1)
* Model Data (by year, scenario and mgra)
	* Total population
* Emission Factors
	* Use of 2014 EMFAC Values from 14.0.0
	* 2050 EMFAC values if any data is to be generated
	
# Electric Vehicles
Have not reviewed draft.

# Microtransit
!Need to add mode choice logic from excel sheet into R script!
This sheet will require the confirmation of the following values from SANDAG 
planning staff:

* Main Sheet
	* Average distance of auto trips 2 miles long or shrter, urban core market (by year)
	* Commuter shuttle mode share model parameters (IVT, IVT/OVT, VOT definition, Cost coefficient, microtransit constant)
*NEV Shuttle Demand
	* NEV shuttle auto substitution rate of 33%
* Model Data NEV Shuttle (by year, orig_msa, dest_msa; from R script?)
	* orig_nevshuttle_flag
	* dest_nevshuttle_flag
	* person_trips
	* auto_trips
* Model Data CB Shuttle (by orig_msa, dest_msa, year; from R script?)
	* Home to Work Person Trips to Employment Centers
	* Home to Work Drive Alone Trips to Employment Centers											
	* Home to Work Drive Alone Trips to Employment Centers, with no or poor fixed-route transit service											
	* Commuter Shuttle Trips, Unsubsidized											
	* Average Trip Distance, Full Fare 											
* Model Data (by year, scenario and mgra)
	* nevshuttle_flag
	* cbshuttle_flag
	* Total Employment
	*	Total population
* Microtransit Coverage (by mgra)
	* msa
	* taz
	* mgra_acreage
	* negshuttle_flag
	* cbshuttle_flag
	* op_negshuttle_flag
	* op_cbshuttle_flag	
* Emission Factors
	* Use of 2014 EMFAC Values from 14.0.0
	* 2050 EMFAC values if any data is to be generated


# Pooled Rides – For each scenario year:
This sheet will require the confirmation of the following values from SANDAG 
planning staff:

* Main Sheet
	* Auto Operating costs in 2010 $ from ABM 14.0.0
	* Model parameters (IVT, VOT definition, cost coefficient, Pooled Ride ASCs (work, nonwork; 0, 1, 2 cars), )
* Pooling Demand Subsidy & ML (by year, origin msa, destination msa, period, mode, purpose, number of autos)
	* Trips (need all years, currently have 2020, but it's probably not the right run)
* Model Skims Data (by year, origin msa, destination msa, period)
	*	avg_datime	
	* avg_srtime	
	* avg_distance
* Population and Employment (by year and mgra)
	* Total employment
	* Total population
* Emission Factors
	* Use of 2014 EMFAC Values from 14.0.0
	* 2050 EMFAC values if any data is to be generated

# Vanpool
This sheet will require the confirmation of the following values from SANDAG 
planning staff:

* Main Sheet
	* Assumed vanpool growth rate due to a subsidy increase (by year, van type)
* Vanpool Demand FOR ML (Non-Mil), ML (mil), Subsidy
	* Average one-way weekday travel time (2016)
	* Average travel time savings (by origin msa, destination msa, by year)
	* Marginal disutility of time coefficient
* Employment Forecast SANDAG (by year)
	* scenario_id	
	*msa_modeling_1	
	* name	
	* emp_ag	
	* emp_const_non_bldg_prod	
	* emp_const_non_bldg_office	
	* emp_utilities_prod	
	* emp_utilities_office	
	* emp_const_bldg_prod	
	* emp_const_bldg_office	
	* emp_mfg_prod	
	* emp_mfg_office	
	* emp_whsle_whs	
	* emp_trans	
	* emp_retail	
	* emp_prof_bus_svcs	
	* emp_prof_bus_svcs_bldg_maint	
	* emp_pvt_ed_k12	
	* emp_pvt_ed_post_k12_oth	
	* emp_health	
	* emp_personal_svcs_office	
	* emp_amusement	emp_hotel	
	* emp_restaurant_bar	
	* emp_personal_svcs_retail	
	* emp_religious	emp_pvt_hh	
	* emp_state_local_gov_ent	
	* emp_fed_non_mil	emp_fed_mil	
	* emp_state_local_gov_blue	
	* emp_state_local_gov_white	
	* emp_public_ed	
	* emp_own_occ_dwell_mgmt	
	* emp_total
* Population Forecast (by year, mgra)
	* Total households
	* Total population	
* Emission Factors
	* Use of 2014 EMFAC Values from 14.0.0
	* 2050 EMFAC values if any data is to be generated	