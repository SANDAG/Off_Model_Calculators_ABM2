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
* Car Substitution rates (for regular bikes and ebikes)
* Average bike trip distances (for regular bikes and ebikes)
* Bikes / 1,000 population per MSA
* Bike lane supply (miles)
	* Latest mileage input is RP2019_BikeLaneMileageInputs_forMarisa.xlsx. These 
	have not been entered because the bikeshare file is currently with the client 
	and off the git path.
* Number of ebikes in bikeshare
* Use of 2014 EMFAC values (from ABM 14.0.0)

This sheet will also require the following inputs for each MGRA in each model year/scenario:
* Scenario name
* Total population
* MSA_ID
* Bikeshare flag	

# Carshare
This sheet will require the confirmation of the following values from SANDAG
planning staff:
* Percent membership in one-way carsharing
* Daily VMT reduction per round-trip/one-way carsharing member
* Threshold for urban vs. suburban population density
* Percent of urban/suburban/college employees/college students/military population 
expected to become carshare members.
* Use of 2014 EMFAC values (from ABM 14.0.0)

This sheet will also require the following inputs for each MGRA in each model 
year/scenario:
* Scenario name
* Total population
* Adult population
* Total population density (MGRA population / MGRA total area)
* Total employment
* College student enrollment
* MSA_ID
* Carshare flag
* University flag
* Military base flag

# CBTP
This sheet will require the confirmation of the following values from SANDAG 
planning staff:
* Use of 2014 EMFAC values (from ABM 14.0.0)
* Use of Community-Based Coverage Areas and Regional Growth Forecast (14.1.1)
* Average daily one-way driving trips per household
* Average number of years for which behavior change persists
* Average one-way trip length ofr driving trips

This sheet will also require the following inputs for each MGRA in each model 
year/scenario:
* Total population (for each MGRA)

# Electric Vehicles
Have not received a draft version for review.

# Microtransit
!Need to add mode choice logic from excel sheet into R script!
This sheet will require the confirmation of the following values from SANDAG 
planning staff:
* Use of 2014 EMFAC values (from ABM 14.0.0)
* Microtransit coverage assumptions are still valid
* Average distance of auto trips < 2 mi

This sheet will also require the following inputs for each model year/scenario:
*	Disaggregate trip list (indivTripData_3.csv)
	* need to ensure it can be summarised for "Model Data CB Shuttle" sheet, i.e.
	* HBW Person trips to employment centers
	* HBW drive alone trips to employment centers
	* HBW drive alone trips with poor/no transit service
	* Commuter shuttle trips, unsubsidized
	* Average trip distance, full fare
*	TAP to TAP Commuter rail transit skim, AM Peak, (total in-vehicle time (mf1036), first wait time (mf1027), transfer wait time (mf1028), fare (mf1030), transfer walk time(mf1033))
*	MGRA to TAP walk connectors (walkMgraTapEquivMinutes.csv)
*	TAZ-to-TAZ travel time, drive alone toll by medium VOT [STM_2016.CSV], AM Peak (mf461)
*	TAZ-to-TAZ travel distance, drive alone toll by medium VOT [dist_2016.CSV], AM Peak (mf462)
*	Total employment by MGRA
*	Total population by MGRA
* Total person trips OD table by MSA (with NEV shuttle flags)
* Total auto trips OD table by MSA (with NEV shuttle flags)

# Pooled Rides – For each scenario year:
*	Disaggregate trip list (indivTripData_3.csv)
*	Auto ownership model result (aoResults.csv)
*	TAZ-to-TAZ travel time, Drive alone toll by medium VOT [STM_2016.CSV], AM Peak (mf461) and Midday (mf587)
*	TAZ-to-TAZ travel time, Shared-ride 2P HOV toll by medium VOT [HTM_2016.CSV], AM Peak (mf473) and Midday (mf594)
*	TAZ-to-TAZ travel distance, Drive alone toll by medium VOT [dist_2016.CSV], AM Peak (mf462) and Midday (mf588)

# Vanpool
Confirmation from planning staff:
*	Average vanpool occupancy
*	SANDAG least cost subsidy (by year and van size)
*	List of Vanpool ODs
*	Average value of time for work trips and marginal disutility of time
*	Coordinates of zip code centroids and external gateways
* Use of 2014 EMFAC values (from ABM 14.0.0)

Model inputs for each MSA OD by year (from Ying):
*	Average one-way weekday travel time for non-military
*	Average one-way weekday travel time for military 
*	Travel times AM Peak and Midday periods medium VOT - For each scenario year: 
	*	TAZ-to-TAZ travel time, Drive alone toll [STM_2016.CSV] (mf461, mf587)
	*	TAZ-to-TAZ travel time, Shared-ride 2P HOV toll [HTM_2016.CSV] (mf473, mf594)
*	Daily work trips with one-way distance > 50 mi

Model inputs for each MGRA (from Ying):
*	Total population

Model inputs for each MSA (from Ying):
*	For each scenario year and MSA, jobs by industry category (SANDAG ABM classification) (really only need emp-fed_non_mil, emp_fed_mil, and emp_total
SCAG county total employment forecast
