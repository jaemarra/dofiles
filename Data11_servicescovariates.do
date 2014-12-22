//  program:    Data10_covariates.do
//  task:		Generate variables for covariates, clinical comorbidities, NOT lab covariates (see Data09 for those)
//  project: 	Incretins--Comparative mortality and CV outcomes (CPRD)
//  author:     MA \ May2014 revised: JM \ Nov2014

clear all
capture log close
set more off

log using Data11.log, replace

// #1 Use data files generated in Data08. 
// Keep only if eventdate2 is before indexdate.

foreach file in Clinical001_2b Clinical002_2b Clinical003_2b Clinical004_2b Clinical005_2b Clinical006_2b Clinical007_2b Clinical008_2b Clinical009_2b Clinical010_2b Clinical011_2b Clinical012_2b Clinical013_2b {

use `file', clear
keep if eventdate2<indexdate
drop sysinputclin staffid vmid mob famnum chsreg chsdate prescr capsup ses frd crd accept chsdate2

////// #1 Generate binary variables coding for each Health Service. Code so 0=no interaction and 1=interaction. For each interaction: generate, replace, label

//servtype key: 1=physican visit, 2 = hospital visit, 3 = days in hospital
gen servtype = .
gen nr_data = .

// Based on HES codes
//Physician Visits 
gen physician_visit = .
replace physician_visit = 1 if constype== 1 | constype== 3 | constype== 6 | constype== 7 | constype== 8 | constype== 11 | constype== 14 | constype== 15 | constype== 30 | constype== 31 | constype== 34 | constype== 37 | constype== 38 | constype== 39 | constype== 40 | constype== 49 | constype== 50 | constype== 53
label physician_visit "Physician visits"
//remove duplicates
quietly bysort patid eventdate2: gen dupa = cond(_N==1,0,_n)
drop if dupa>1
//create counts
sort patid eventdate2
by patid: generate visit_num = _n
by patid: generate visit_tot = _N
label variable visit_tot "Total number of physician visits"
//generate binary variable
gen physician_visit_b = 0
replace physician_visit_b = 1 if physician_visit>0 & physician_visit <.
label variable physician_visit_b "Physician visits (binary) 0= no visit, 1= at least 1 visit"
replace servtype=1 if physician_visit == 1
replace nr_data = visit_tot if servtype==1

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

//Create a varibale for all eligible utilization dates (i.e. those with real, non-missing data)
gen elgdate2 = . 
replace elgdate2 = eventdate2 if eventdate2 <. & nr_data <.
format elgdate2 %td

/*Drop all duplicates for patients of the same constype on the same day
quietly bysort patid servtype elgdate2: gen dupa = cond(_N==1,0,_n)
drop if dupa>1*/

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

by patid: egen serv_num_un_s_temp = count(servtype) if serv_num==1 & elgdate2>=studyentrydate_cprd-365 & elgdate2<studyentrydate_cprd
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

save Servcovs_studyentrydate_cprd2, replace
/*collapse (max) (min) /// FILL IN VARIABLES /// , by(patid)
compress
save Servcovs.dta, replace*/

////////////////////////////////////////////

exit
log close

