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

This sheet will also require the following inputs for each model year/scenario:
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

This sheet will also require the following inputs for each model year/scenario:
* Scenario name
* Total Population
* Adult Population
* Total Population density (MGRA population / MGRA total area)
* Total Employment
* College student enrollment
* MSA_ID
* Carshare flag
* University flag
* Military base flag

# CBTP

# Electric Vehicles
Have not received a draft version for review.

# Microtransit

# Pooled Rides

# Vanpool

##Vanpool r script is fine
##Microtransit r script does not produce everything