//  program:    Data11_servicescovariates_b.do
//  task:		Generate variables for service covariates, NOT clinical or lab covariates (see Data09 and Data10 respectively for those)
//  project: 	Incretins--Comparative mortality and CV outcomes (CPRD)
//  author:     MA \ May2014 revised: JM \ Jan2015

clear all
capture log close
set more off
log using Data11b.txt, replace
timer on 1

// #1 Use data files generated in Data02 (Support)
// Keep only if eventdate2 is before indexdate.
use hes.dta
merge m:1 patid using Dates, keep(match) nogen
//restrict to broad window of interest
keep if admidate2<indexdate
//remove extraneous variables
keep patid studyentrydate_cprd2 pracid spno duration icd icd_primary opcs eventdate2 indexdate cohortentrydate admidate2 discharged2
////// #1 Generate binary variables coding for each Health Service. Code so 0=no interaction and 1=interaction. For each interaction: generate, replace, label

//servtype key: 1=physican visit, 2 = hospital visit, 3 = days in hospital, 4 = services while in hospital
gen servtype2 = .
gen servtype3 = .
gen servtype4 = .

//value (prx_servvalue_(s,c,i)) total (serv_total) and binary ( prx_serv_(s,c,i)_b) for each servtype
//Create a variable for all eligible utilization dates (i.e. those with real, non-missing data)
gen elgdate2 = . 
replace elgdate2 = eventdate2 if eventdate2 <.
format elgdate2 %td

save hes_serv, replace

////////////////////////////////////SPLIT FOR EACH WINDOW- INDEXDATE, COHORTENTRYDATE, STUDYENTRYDATE_CPRD/////////////////////////////
//STUDY ENTRY DATE
//RESTRICT TO WINDOW OF INTEREST
use hes_serv, clear

bysort patid: egen prx_servdate_h_s = max(elgdate2) if elgdate2>=studyentrydate_cprd2-365 & elgdate2<studyentrydate_cprd2
format prx_servdate_h_s %td
gen prx_serv_h_s_b = 1 if !missing(prx_servdate_h_s)

// Based on HES codes
//Hospital Visits 
//identify number of unique visits
bysort patid spno: gen temp_visit = cond(_N==1,0,_n)
//generate binary
gen prx_serv2_h_s_b = 0
replace prx_serv2_h_s_b = 1 if temp_visit==1
//Apply service type
replace servtype2=1 if prx_serv2_h_s_b==1
//total visits per patient
bysort patid: egen tot_visits_pptn = total(prx_serv2_h_s)
//replace nr_data with total visits per patid
gen prx_servvalue2_h_s=.
replace prx_servvalue2_h_s = tot_visits_pptn if servtype2==1

//Duration of Hospital Stays
//identify duration of unique visits from the identified visits above (servtype2)
gen hosp_duration = . 
replace hosp_duration = duration if prx_serv2_h_s_b==1
//generate binary
gen prx_serv3_h_s_b = 0
replace prx_serv3_h_s_b =1 if hosp_duration >0 & hosp_duration <.
//apply service type
replace servtype3=1 if prx_serv3_h_s_b==1
//generate total days in hospital
bysort patid: egen temp_duration = total(duration) if prx_serv2_h_s_b==1
bysort patid: egen tot_duration = max(temp_duration)
//populate nr_data with total days in hospital
gen prx_servvalue3_h_s=.
replace prx_servvalue3_h_s = tot_duration if servtype3==1

//Hospital Services
//identify unique services
gen prx_serv4_h_s_b = 0
bysort patid spno: gen temp_serv = cond(_N==1,0,_n)
replace prx_serv4_h_s_b = 1 if temp_serv >0
label variable prx_serv4_h_s_b "Hospital services numeric, 1 = 1 sevice per unique spno visit"
replace servtype4=1 if prx_serv4_h_s_b==1
//identify hospital services duplicates- TAKE NO ACTION
quietly bysort patid spno eventdate2 opcs: gen dupa = cond(_N==1,0,_n)
//count number of services per visit
bysort patid spno: egen serv_per_visit= max(temp_visit)
//total services per patient
replace serv_per_visit = . if prx_serv4_h_s_b == 0
bysort patid: egen tot_servs_pptn = total(serv_per_visit)
//average services per visit per patient
gen mean_servs =.
replace mean_servs = (tot_servs_pptn/tot_visits_pptn)
//replace nr_data with 
gen prx_servvalue4_h_s_b=.
replace prx_servvalue4_h_s_b = mean_servs if servtype4==1

bysort patid: egen temp_tot_4 = total(prx_serv4_h_s_b)
bysort patid: egen temp_tot_2 = total(prx_serv2_h_s_b)

gen totservs_h_s = .
replace totservs_h_s = temp_tot_4 + temp_tot_2

//only keep the observations relevant to the current window
drop if (prx_servvalue4_h_s >=. | prx_servvalue3_h_s >=. | prx_servvalue2_h_s >=.)

//Check for duplicates
bysort patid: gen dupck = cond(_N==1,0,_n)
drop if dupck>1

//Drop all fields that aren't wanted in the final dta file
keep patid totservs_h_s prx_serv*
label var totservs_h_s "Total services utilized in studyentry window: number of hospital visits/services (hes)"
label var prx_servvalue2_h_s "Number of hospital visits during studyentry window (hes)"
label var prx_servvalue3_h_s "Number of days spent in hospital during studyentry window (hes)"
label var prx_servvalue4_h_s "Mean number of hospital services used per visit in studyentry window (hes)"
label var prx_serv4_h_s_b "Bin ind hospital visits (studyentry window): 1=at least; 0=none (hes)"
label var prx_serv3_h_s_b "Bin ind hosp visit duration (studyentry window): 1=at least 1 day; 0=none (hes)"
label var prx_serv2_h_s_b "Bin ind hosp services (studyentry window): 1=at least 1 service; 0=none (hes)"

save hes_serv_h_s, replace
clear 

//COHORTENTRYDATE
//pull out dates of interest
use hes_serv, clear

bysort patid: egen prx_servdate_h_c = max(elgdate2) if elgdate2>=cohortentrydate-365 & elgdate2<cohortentrydate
format prx_servdate_h_c %td
gen prx_serv_h_c_b = 1 if !missing(prx_servdate_h_c)

// Based on HES codes
//Hospital Visits 
//identify number of unique visits
bysort patid spno: gen temp_visit = cond(_N==1,0,_n)
//generate binary
gen prx_serv2_h_c_b = 0
replace prx_serv2_h_c_b = 1 if temp_visit==1
//Apply service type
replace servtype2=1 if prx_serv2_h_c_b==1
//total visits per patient
bysort patid: egen tot_visits_pptn = total(prx_serv2_h_c)
//replace nr_data with total visits per patid
gen prx_servvalue2_h_c=.
replace prx_servvalue2_h_c = tot_visits_pptn if servtype2==1

//Duration of Hospital Stays
//identify duration of unique visits from the identified visits above (servtype2)
gen hosp_duration = . 
replace hosp_duration = duration if prx_serv2_h_c_b==1
//generate binary
gen prx_serv3_h_c_b = 0
replace prx_serv3_h_c_b =1 if hosp_duration >0 & hosp_duration <.
//apply service type
replace servtype3=1 if prx_serv3_h_c_b==1
//generate total days in hospital
bysort patid: egen temp_duration = total(duration) if prx_serv2_h_c_b==1
bysort patid: egen tot_duration = max(temp_duration)
//populate nr_data with total days in hospital
gen prx_servvalue3_h_c=.
replace prx_servvalue3_h_c = tot_duration if servtype3==1

//Hospital Services
//identify unique services
gen prx_serv4_h_c_b = 0
bysort patid spno: gen temp_serv = cond(_N==1,0,_n)
replace prx_serv4_h_c_b = 1 if temp_serv >0
label variable prx_serv4_h_c_b "Hospital services numeric, 1 = 1 sevice per unique spno visit"
replace servtype4=1 if prx_serv4_h_c_b==1
//identify hospital services duplicates- TAKE NO ACTION
quietly bysort patid spno eventdate2 opcs: gen dupa = cond(_N==1,0,_n)
//count number of services per visit
bysort patid spno: egen serv_per_visit= max(temp_visit)
//total services per patient
replace serv_per_visit = . if prx_serv4_h_c_b == 0
bysort patid: egen tot_servs_pptn = total(serv_per_visit)
//average services per visit per patient
gen mean_servs =.
replace mean_servs = (tot_servs_pptn/tot_visits_pptn)
//replace nr_data with 
gen prx_servvalue4_h_c_b=.
replace prx_servvalue4_h_c_b = mean_servs if servtype4==1

bysort patid: egen temp_tot_4 = total(prx_serv4_h_c_b)
bysort patid: egen temp_tot_2 = total(prx_serv2_h_c_b)

gen totservs_h_c = .
replace totservs_h_c = temp_tot_4 + temp_tot_2

//only keep the observations relevant to the current window
drop if (prx_servvalue4_h_c >=. | prx_servvalue3_h_c >=. | prx_servvalue2_h_c >=.)

//Check for duplicates
bysort patid: gen dupck = cond(_N==1,0,_n)
drop if dupck>1

//Drop all fields that aren't wanted in the final dta file
keep patid totservs_h_c prx_serv*
label var totservs_h_c "Total services utilized in cohortent window: number of hospital visits/services (hes)"
label var prx_servvalue2_h_c "Number of hospital visits during cohortent window (hes)"
label var prx_servvalue3_h_c "Number of days spent in hospital during cohortent window (hes)"
label var prx_servvalue4_h_c "Mean number of hospital services used per visit in cohortent window (hes)"
label var prx_serv4_h_c_b "Bin ind hospital visits (cohortent window): 1=at least; 0=none (hes)"
label var prx_serv3_h_c_b "Bin ind hosp visit duration (cohortent window): 1=at least 1 day; 0=none (hes)"
label var prx_serv2_h_c_b "Bin ind hosp services (cohortent window): 1=at least 1 service; 0=none (hes)"

save hes_serv_c, replace
clear

//INDEX DATE
//pull out dates of interest
use hes_serv, clear

bysort patid: egen prx_servdate_h_i = max(elgdate2) if elgdate2>=indexdate-365 & elgdate2<indexdate
format prx_servdate_h_i %td
gen prx_serv_h_i_b = 1 if !missing(prx_servdate_h_i)

// Based on HES codes
//Hospital Visits 
//identify number of unique visits
bysort patid spno: gen temp_visit = cond(_N==1,0,_n)
//generate binary
gen prx_serv2_i_b = 0
replace prx_serv2_h_i_b = 1 if temp_visit==1
//Apply service type
replace servtype2=1 if prx_serv2_h_i_b==1
//total visits per patient
bysort patid: egen tot_visits_pptn = total(prx_serv2_h_i)
//replace nr_data with total visits per patid
gen prx_servvalue2_h_i=.
replace prx_servvalue2_h_i = tot_visits_pptn if servtype2==1

//Duration of Hospital Stays
//identify duration of unique visits from the identified visits above (servtype2)
gen hosp_duration = . 
replace hosp_duration = duration if prx_serv2_h_i_b==1
//generate binary
gen prx_serv3_h_i_b = 0
replace prx_serv3_h_i_b =1 if (hosp_duration >0 & hosp_duration <.)
//apply service type
replace servtype3=1 if prx_serv3_h_i_b==1
//generate total days in hospital
bysort patid: egen temp_duration = total(duration) if prx_serv2_h_i_b==1
bysort patid: egen tot_duration = max(temp_duration)
//populate nr_data with total days in hospital
gen prx_servvalue3_h_i=.
replace prx_servvalue3_h_i = tot_duration if servtype3==1

//Hospital Services
//identify unique services
gen prx_serv4_h_i_b = 0
bysort patid spno: gen temp_serv = cond(_N==1,0,_n)
replace prx_serv4_h_i_b = 1 if temp_serv >0
label variable prx_serv4_h_i_b "Hospital services numeric, 1 = 1 sevice per unique spno visit"
replace servtype4=1 if prx_serv4_h_i_b==1
//identify hospital services duplicates- TAKE NO ACTION
quietly bysort patid spno eventdate2 opcs: gen dupa = cond(_N==1,0,_n)
//count number of services per visit
bysort patid spno: egen serv_per_visit= max(temp_visit)
//total services per patient
replace serv_per_visit = . if prx_serv4_h_i_b == 0
bysort patid: egen tot_servs_pptn = total(serv_per_visit)
//average services per visit per patient
gen mean_servs =.
replace mean_servs = (tot_servs_pptn/tot_visits_pptn)
//replace nr_data with 
gen prx_servvalue4_h_i_b=.
replace prx_servvalue4_h_i_b = mean_servs if servtype4==1

bysort patid: egen temp_tot_4 = total(prx_serv4_h_i_b)
bysort patid: egen temp_tot_2 = total(prx_serv2_h_i_b)

gen totservs_h_i = .
replace totservs_h_i = temp_tot_4 + temp_tot_2

//only keep the observations relevant to the current window
drop if (prx_servvalue4_h_i >=. | prx_servvalue3_h_i >=. | prx_servvalue2_h_i >=.)

//Check for duplicates
bysort patid: gen dupck = cond(_N==1,0,_n)
drop if dupck>1

//Drop all fields that aren't wanted in the final dta file
keep patid totservs_h_i prx_serv*
label var totservs_h_i "Total services utilized in index window: number of hospital visits/services (hes)"
label var prx_servvalue2_h_i "Number of hospital visits during index window (hes)"
label var prx_servvalue3_h_i "Number of days spent in hospital during index window (hes)"
label var prx_servvalue4_h_i "Mean number of hospital services used per visit in index window (hes)"
label var prx_serv4_h_i_b "Bin ind hospital visits (index window): 1=at least; 0=none (hes)"
label var prx_serv3_h_i_b "Bin ind hosp visit duration (index window): 1=at least 1 day; 0=none (hes)"
label var prx_serv2_h_i_b "Bin ind hosp services (index window): 1=at least 1 service; 0=none (hes)"

save hes_serv_i, replace
clear

timer off 1
timer list 1
exit
log close

