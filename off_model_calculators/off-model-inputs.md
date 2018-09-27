# Off Model Calculator Work Flow
This document describes the work flow required to run each of the off model 
calculators prepared by SANDAG's TDM and planning staff.

Per the file "Draft Scenario off model.xlsx", build scenarios will only appear 
in 2035 and/or 2050. 2016, 2020, and 2025 will remain in the calculators, but only
no-build model scenarios will be performed. 2016, 2020, and 2025 will remain as hard-
coded dates within the excel sheets, but cells referring to 2035 and 2050 model 
runs will be responsive to the scenario name.

Each of these off model calculators will need to be run for every 2035 [and 2050] build 
scenario. (The sheet names will need to be updated, since each sheet can only hold
a single scenario for each model year.) 

# Folder Structure
The off model calculators are stored in a 
[WSP github repo](https://github.com/wsp-sag/client_sandag_rtp_2019). They are 
found in the "off_model_calculators" folder. There are 6 subfolders.

* finalized_excel - contains calculators whose formulas, logic, and references 
have been vetted by SANDAG staff. These calculators are ready for application 
by SANDAG staff or consultants. Staff should carefully follow the work flow to 
update the necessary model inputs before saving the individual model scenarios 
into finalized_scenarios. (Files should be named "GHG Calculator [Type])
* finalized_scenarios - contains calculators whose formulas, logic, references, 
and model inputs have been vetted by SANDAG staff. These excel files represent 
the end stage of the calculators and the outputs are ready for export to other 
work flows. Only a single copy of each scenario should be stored at any given 
time. QAQC checks should be stored in qaqc_scenarios.
* in_progress_excel - contains calculators whose formulas, logic, and references 
are under review by SANDAG staff or consultants. These calculators are NOT ready 
for application. Staff should continue to review the calculators until they are 
complete.
* misc_input - memorializes inputs and directions from SANDAG staff used to 
develop various calculators. Records of critical inputs and model decisions 
that are not updated every model run (e.g. an email on the value of time 
methodology) should be stored here.
* qaqc_scenarios - contains calculators used to QAQC the results of scenario 
files in finalized_scenarios. Multiple copies of a single scenario are 
permissible
* sandag_inputs - memorializes inputs and directions from SANDAG staff used to 
finalize various scenarios. Records of critical inputs and model decisions 
that are potentially updated every model run (e.g. average trip length or 
population by MGRA) should be stored here.


# Work Flow

There are two overarching stages to the work on the off-model calculators. 
First, the calculators have been (and still are) under iterative development by 
both SANDAG staff and WSP. When a calculator is being worked on, it should be 
stored in the in_progress_excel file. Because excel files are binary and 
github is not able to perform a diff on versions, it is recommended that a 
single staff member be designated as a clearinghouse responsible for inserting 
all updates. Key decisions regarding model structure, references, or static 
inputs should be documented in misc_input as they are made. When a calculator 
has been finalized by SANDAG staff, it should be moved to finalized_excel. Once 
a file has been placed in finalized_excel application staff should assume that 
all formulas, logic, and references have been approved and that the scenario 
development task consists of the mechanical importation of inputs specified 
below in the Calculator Inputs section.

Second, once a calculator has been placed in finalized_excel, staff should 
carefully update model inputs using files placed in sandag_inputs as explained 
in Calculator Inputs. The scenario is designated by updating cell B7 in all 
worksheets (the "2035 Scenario Name"). The file should be saved in 
qaqc_scenarios using the following scheme 
"GHG Calculator [CalcName] SCENARIO [ScenarioName] [MyName] [MMDDYY]" (e.g. 
"GHG Calculator Bikeshare SCENARIO 2035E JHelsel 092418.xslx"). The work should 
be QAQCed by having another staff member independently start with the calculator 
in finalized_excel, update relevant inputs, and save their copy of the scenario 
in qaqc_scenarios. Once the outputs have been verified, a single copy of the 
scenario (stripped of the analyst's name) should be moved to finalized_scenarios.

# Calculator Inputs
There are 7 off model calculators:
* Bikeshare
* Carshare
* Community Based Travel Plan (CBTP)
* Electric Vehicle Programs
*	Microtransit
	* SANDAG ABM Transit Mode Share (binomial logit logic; this sheet will be 
	turned into code, but currently requires manual intervention) 
* Pooled Rides
* Vanpool

## Bikeshare
This sheet will require the confirmation of the following values from SANDAG 
planning and modeling staff:
* Bikeway Miles
	* Bikeway miles estimate (by year, scenario and MSA) [RP2019_BikeLaneMileageInputs_ForMarisa.xlsx]
* Model Data (by year, scenario and mgra) [pop_by_mgra_sr14_preliminary.xlsx]
	* Total population
	* MSA_ID
	* Bikeshare flag
* Emission Factors (by year, scenario) [EMFAC_SB375CO2_emissionFactors.xlsx]
	* Confirm use of 2014 EMFAC or 2017 EMFAC values from ABM 14.0.0
	* Updated EMFAC values 

## Carshare
This sheet will require the confirmation of the following values from SANDAG
planning and modeling staff:
* Model Data (by year, scenario, and mgra) [pop_by_mgra_sr14_preliminary.xlsx]
	* Total population
	* Adult population
	* Total population density (MGRA population / MGRA total area)
	* Total employment(to derive military employment and college employment)
	* College student enrollment
	* MSA
	* Carshare_flag
	* Univ_flag
	* MLB_flag
* Emission Factors (by year, scenario) [EMFAC_SB375CO2_emissionFactors.xlsx]
	* Confirm use of 2014 EMFAC or 2017 EMFAC values from ABM 14.0.0
	* Updated EMFAC values 

## CBTP
This sheet will require the confirmation of the following values from SANDAG 
planning and modeling staff:

* Main Sheet
	* Average daily one-way driving trips per household 
	[avg_vtrip_rates_length_CBTP_off_model_calc.xlsx]
	* Average one-way trip length for driving trips 
	[avg_vtrip_rates_length_CBTP_off_model_calc.xlsx]
	* Total Regional Population [pop_by_mgra_sr14_preliminary.xlsx]
* Community-Based Coverage Areas
    * Total households by year by community
* Emission Factors (by year, scenario) [EMFAC_SB375CO2_emissionFactors.xlsx]
	* Confirm use of 2014 EMFAC or 2017 EMFAC values from ABM 14.0.0
	* Updated EMFAC values
	
## Electric Vehicle Programs
Have not reviewed draft.

## Microtransit
!Need to add mode choice logic from excel sheet into R script!
Calculator impacts contingent on a SANDAG policy that subsidizes or incentivizes use of the service. 
Confirm level of investment with SANDAG Planning and Modeling Staff.
This sheet will require the confirmation of the following values from SANDAG 
planning and modeling staff:

* Main Sheet
	* Average distance of auto trips 2 miles long or shorter, urban core market (by year)
	* Value of time definition [use the median income]
* Model Data NEV Shuttle (by year, orig_msa, dest_msa, orig_nevshuttle_flag, dest_nevshuttle_flag)       
	* person_trips
	* auto_trips    	
	These are generated by "SANDAG_MicrotransitCalculatorTables.R"
* Model Data CB Shuttle (by orig_msa, dest_msa, year; This one comes from 
"SANDAG ABM Transit Mode Share_MM-DD_YYYY.xlsx")
  These inputs can be found using the instructions below for 
  "SANDAG ABM Transit Mode Share_MM-DD_YYYY.xslx"
	* Home to Work Person Trips to Employment Centers
	* Home to Work Drive Alone Trips to Employment Centers											
	* Home to Work Drive Alone Trips to Employment Centers, with no or poor fixed-route transit service											
	* Commuter Shuttle Trips, Full Fare											
	* Average Trip Distance, Full Fare 	
	* Commuter Shuttle Trips, Subsidized Fare											
	* Average Trip Distance, Subsidized Fare 	
* Model Data (by year, scenario and mgra)
	* Total Employment
	* Total population
* Emission Factors
	* Confirm use of 2014 EMFAC or 2017 EMFAC values from ABM 14.0.0
	* 2050 EMFAC values if any data is to be generated
	
### SANDAG ABM Transit Mode Share_MM-DD-YYYY.xlsx

This excel sheet is a binomial logit calculator to determine whether 
1) travelers are eligible to use Microtransit
2) eligible travelers choose to use Microtransit.

The calculator has 5 tabs, 3 of which are manipulated by the end user:
* HtWTrips - Columns A-L should be replaced by "HtWTrips_[Scenario Name].csv"
 (created by SANDAG)
* Microtransit - Cell D3 (Transit fare (cents)) controls whether the output on 
SummaryTables is "Full Fare" or "Subsidized". For Full Fare, the fare should be 
set to the fare set on row 16 of the Microtransit calculator (e.g. 337). For 
Subsidized, the fare should be set to 0.
* SummaryTables - This tab contains the outputs that should be exported to the 
Microtransit Calculator. The headers of the first three tables match the 
Microtransit Calculator Model Data CB Shuttle tab headers. The last two 
(Micro-Transit and Average Micro-Transit Trip Distance) can be exported when 
the appropriate fare assumption is supplied in the Microtransit tab.


## Pooled Rides
Calculator impacts contingent on a SANDAG policy that subsidizes or incentivizes use of the service. 
Confirm level of investment with SANDAG Planning and Modeling Staff.
This sheet will require the confirmation of the following values from SANDAG 
planning and modeling staff:

* Main Sheet
	* App-enabled ridehare modeshare, by auto ownership and by work and non-work
    * Proportion that use a pooled option, by auto ownership and by work and non-work
    * Pooled ride cost per mile (cents/mile) by work and non-work
	* Drive alone operating cost in 2010 $ by year
	* Total Regional Population (by year) [pop_by_mgra_sr14_preliminary.xlsx]
* Model Trip Data [pooledride_trips_2035_E_minus_bu_2018-09-24.csv]
	* Trips (by year, origin msa, destination msa, period, mode, purpose, number of autos) : This is generated by 
	"SANDAG_PooledrideCalculatorTables.R" script
* Model Skims Data (by year, origin msa, destination msa, period) [pooledride_times_2035_E_minus_bu_2018-09-24.csv]
	* avg_datime	
	* avg_srtime	
	* avg_distance
	These are generated by "SANDAG_PooledrideCalculatorTables.R" script
* Emission Factors
	* Confirm use of 2014 EMFAC or 2017 EMFAC values from ABM 14.0.0
	* Updated EMFAC values

## Vanpool
Calculator impacts contingent on a SANDAG policy that subsidizes or incentivizes use of the service. 
Confirm level of investment with SANDAG Planning and Modeling Staff.
This sheet will require the confirmation of the following values from SANDAG 
planning and modeling staff:

* Main Sheet
	* Total Regional Population by year [pop_by_mgra_sr14_preliminary.xlsx]
* Vanpool Demand FOR ML (Non-Mil), ML (mil)
	* Average one-way weekday travel time (2016) 
	* Average travel time savings (by origin msa, destination msa, by year)
	These  files are produced by "SANDAG_TravelTimeSaving.R" script for both military and non-military 
* Employment Forecast SANDAG (by year) [emp_msa_preliminarySR14.xlsx]
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
	* emp_fed_non_mil	
	* emp_fed_mil	
	* emp_state_local_gov_blue	
	* emp_state_local_gov_white	
	* emp_public_ed	
	* emp_own_occ_dwell_mgmt	
	* emp_total
* Emission Factors
	* Confirm use of 2014 EMFAC or 2017 EMFAC values from ABM 14.0.0
	* Updated EMFAC values
