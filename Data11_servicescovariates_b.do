//  program:    Data11_servicescovariates_b.do
//  task:		Generate variables for service covariates, NOT clinical or lab covariates (see Data09 and Data10 respectively for those)
//  project: 	Incretins--Comparative mortality and CV outcomes (CPRD)
//  author:     MA \ May2014 revised: JM \ Jan2015

clear all
capture log close
set more off

log using Data11b.log, replace

// #1 Use data files generated in Data02 (Support)
// Keep only if eventdate2 is before indexdate.
use hes.dta
keep if eventdate2<indexdate
keep patid studyentrydate_cprd2 pracid spno duration icd icd_primary opcs eventdate2 indexdate cohortentrydate
////// #1 Generate binary variables coding for each Health Service. Code so 0=no interaction and 1=interaction. For each interaction: generate, replace, label

//servtype key: 1=physican visit, 2 = hospital visit, 3 = days in hospital
gen servtype = .
gen nr_data = .

// Based on HES codes
//Hospital Visits 
gen hosp_visit = .
replace hosp_visit = spno
label variable hosp_visit "Unique hospital visit ID"
//remove duplicates
quietly bysort patid spno: gen dupa = cond(_N==1,0,_n)
drop if dupa>1
//create counts
sort patid eventdate2
by patid: generate hospvisit_num = _n
by patid: generate hospvisit_tot = _N
//generate binary variable
gen hosp_visit_b = 0
replace hosp_visit_b = 1 if hosp_visit>0 & hosp_visit <.
label variable hosp_visit_b "Hospital visits (binary) 0 = no visit, 1 = at least 1 visit"
replace servtype=2 if hosp_visit_b==1
replace nr_data = visit_tot if servtype==2

//Duration of Hospital Stays
gen hosp_duration = . 
replace hosp_duration = duration
by patid: generate hospdays_tot = _N
gen hosp_duration_b = 0
replace hosp_duration_b =1 if hosp_duration >0 & hosp_duration <.
replace servtype=3 if hosp_duration_b==1
replace nr_data = hospdays_tot if servtype=3

//Create a variable for all eligible utilization dates (i.e. those with real, non-missing data)
gen elgdate2 = . 
replace elgdate2 = eventdate2 if eventdate2 <. & nr_data <.
format elgdate2 %td

/*Drop all duplicates for patients of the same constype on the same day
quietly bysort patid servtype elgdate2: gen dupa = cond(_N==1,0,_n)
drop if dupa>1*/
save hes_serv, replace

////////////////////////////////////SPLIT FOR EACH WINDOW- INDEXDATE, COHORTENTRYDATE, STUDYENTRYDATE_CPRD/////////////////////////////
//STUDY ENTRY DATE
//pull out dates of interest
bysort patid: egen prx_servdate_s = max(elgdate2) if elgdate2>=studyentrydate_cprd2-365 & elgdate2<studyentrydate_cprd2
format prx_servdate_s %td
gen prx_serv_s_b = 1 if !missing(prx_servdate_s)

//pull out test value of interest
bysort patid: gen prx_servvalue_s = nr_data if prx_testdate_s==elgdate2

//create counts
sort patid servtype elgdate2
by patid servtype: generate serv_num = _n
by patid: egen serv_num_un = count(servtype) if serv_num==1 

by patid: egen serv_num_un_s_temp = count(servtype) if serv_num==1 & elgdate2>=studyentrydate_cprd2-365 & elgdate2<studyentrydate_cprd2
by patid: egen serv_num_un_s = min(serv_num_un_s_temp)
drop serv_num_un_s_temp

//only keep the observations relevant to the current window
drop if prx_servvalue_s >=.

/*Check for duplicates again- no duplicates found then continue
quietly bysort patid servtype: gen dupck = cond(_N==1,0,_n)
drop if dupck>1*/

//Rectangularize data
fillin patid servtype

//Fillin the total number of labs in the window of interest
bysort patid: egen totserv = total(serv_num)

//Drop all fields that aren't wanted in the final dta file
keep patid totserv servtype prx_servvalue_s prx_serv_s_b

//Reshape
reshape wide prx_servvalue_s prx_serv_s_b, i(patid) j(servtype)

save hes_serv_s, replace
clear 

//COHORTENTRYDATE
//pull out dates of interest
use hes_serv
bysort patid: egen prx_servdate_c = max(elgdate2) if elgdate2>=cohortentrydate-365 & elgdate2<cohortentrydate
format prx_servdate_c %td
gen prx_serv_c_b = 1 if !missing(prx_servdate_c)

//pull out test value of interest
bysort patid: gen prx_servvalue_c = nr_data if prx_testdate_c==elgdate2

//create counts
sort patid servtype elgdate2
by patid servtype: generate serv_num = _n
by patid: egen serv_num_un = count(servtype) if serv_num==1 

by patid: egen serv_num_un_c_temp = count(servtype) if serv_num==1 & elgdate2>=cohortentrydate-365 & elgdate2<cohortentrydate
by patid: egen serv_num_un_c = min(serv_num_un_c_temp)
drop serv_num_un_c_temp

//only keep the observations relevant to the current window
drop if prx_servvalue_c >=.

/*Check for duplicates again- no duplicates found then continue
quietly bysort patid servtype: gen dupck = cond(_N==1,0,_n)
drop if dupck>1*/

//Rectangularize data
fillin patid servtype

//Fillin the total number of labs in the window of interest
bysort patid: egen totserv = total(serv_num)

//Drop all fields that aren't wanted in the final dta file
keep patid totserv servtype prx_servvalue_c prx_serv_c_b

//Reshape
reshape wide prx_servvalue_c prx_serv_c_b, i(patid) j(servtype)

save hes_serv_c, replace
clear

//INDEX DATE
//pull out dates of interest
use hes_serv
bysort patid: egen prx_servdate_i = max(elgdate2) if elgdate2>=indexdate-365 & elgdate2<indexdate
format prx_servdate_i %td
gen prx_serv_i_b = 1 if !missing(prx_servdate_i)

//pull out test value of interest
bysort patid: gen prx_servvalue_i = nr_data if prx_testdate_i==elgdate2

//create counts
sort patid servtype elgdate2
by patid servtype: generate serv_num = _n
by patid: egen serv_num_un = count(servtype) if serv_num==1 

by patid: egen serv_num_un_i_temp = count(servtype) if serv_num==1 & elgdate2>=indexdate-365 & elgdate2<indexdate
by patid: egen serv_num_un_i = min(serv_num_un_i_temp)
drop serv_num_un_i_temp

//only keep the observations relevant to the current window
drop if prx_servvalue_i >=.

/*Check for duplicates again- no duplicates found then continue
quietly bysort patid servtype: gen dupck = cond(_N==1,0,_n)
drop if dupck>1*/

//Rectangularize data
fillin patid servtype

//Fillin the total number of labs in the window of interest
bysort patid: egen totserv = total(serv_num)

//Drop all fields that aren't wanted in the final dta file
keep patid totserv servtype prx_servvalue_i prx_serv_i_b

//Reshape
reshape wide prx_servvalue_i prx_serv_i_b, i(patid) j(servtype)

save hes_serv_i, replace
clear
exit
log close

