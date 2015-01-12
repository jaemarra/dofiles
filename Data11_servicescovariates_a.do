//  program:    Data11_covariates_a.do
//  task:		Generate variables for service covariates, NOT clinical or lab covariates (see Data09 and Data10 respectively for those)
//  project: 	Incretins--Comparative mortality and CV outcomes (CPRD)
//  author:     MA \ May2014 revised: JM \ Jan2015

clear all
capture log close
set more off

log using Data11a.log, replace

// #1 Use data files generated in Data02 (Support)
// Keep only if eventdate2 is before indexdate.

foreach file in Clinical001_2b Clinical002_2b Clinical003_2b Clinical004_2b Clinical005_2b Clinical006_2b Clinical007_2b Clinical008_2b Clinical009_2b Clinical010_2b Clinical011_2b Clinical012_2b Clinical013_2b {

use `file', clear
keep if eventdate2<indexdate
keep patid eventdate2 constype studyentrydate_cprd2 cohortentrydate pracid
////// #1 Generate binary variables coding for each Health Service. Code so 0=no interaction and 1=interaction. For each interaction: generate, replace, label

//servtype key: 1=physican visit, 2 = hospital visit, 3 = days in hospital
gen servtype = .
gen nr_data = .

// Based on CPRD codes
//Physician Visits 
gen physician_visit = .
replace physician_visit = 1 if constype== 1 | constype== 3 | constype== 6 | constype== 7 | constype== 8 | constype== 11 | constype== 14 | constype== 15 | constype== 30 | constype== 31 | constype== 34 | constype== 37 | constype== 38 | constype== 39 | constype== 40 | constype== 49 | constype== 50 | constype== 53
label var physician_visit "Physician visits"
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

//Create a variable for all eligible utilization dates (i.e. those with real, non-missing data)
gen elgdate2 = . 
replace elgdate2 = eventdate2 if eventdate2 <. & nr_data <.
format elgdate2 %td

/*Drop all duplicates for patients of the same constype on the same day
quietly bysort patid servtype elgdate2: gen dupa = cond(_N==1,0,_n)
drop if dupa>1*/
save Clin_serv, replace

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

save Clin_serv_s, replace
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

save Clin_serv_c, replace
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

save Clin_serv_i, replace
clear
exit
log close

