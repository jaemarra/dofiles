//  program:    Data11_covariates_a.do
//  task:		Generate variables for service covariates, NOT clinical or lab covariates (see Data09 and Data10 respectively for those)
//  project: 	Incretins--Comparative mortality and CV outcomes (CPRD)
//  author:     MA \ May2014 revised: JM \ Jan2015

clear all
capture log close
set more off
set trace on
log using Data11a.txt, replace
timer on 1

// #1 Use data files generated in Data02 (Support)
// Keep only if eventdate2 is before indexdate.

foreach file in Clinical001_2b Clinical002_2b Clinical003_2b Clinical004_2b Clinical005_2b Clinical006_2b Clinical007_2b Clinical008_2b Clinical009_2b Clinical010_2b Clinical011_2b Clinical012_2b Clinical013_2b {

use `file', clear
keep if eventdate2<indexdate
keep patid eventdate2 constype studyentrydate_cprd2 cohortentrydate indexdate pracid
////// #1 Generate binary variables coding for each Health Service. Code so 0=no interaction and 1=interaction. For each interaction: generate, replace, label

//servtype key: 1=physican visit, 2 = hospital visit, 3 = days in hospital
gen servtype = .
label variable servtype "Type of health services utilized"
label define servicetypes 1 "Physician visit" 2 "Hospital visit" 3 "Duration of hospital stay (days)" 4 "Number of services in hospital stay"
label values servtype servicetypes
gen nr_data = .
label var nr_data "Non-redundant data for services"

// Based on CPRD codes
//Physician Visits 
gen physician_visit = .
replace physician_visit = 1 if constype== 1 | constype== 3 | constype== 6 | constype== 7 | constype== 8 | constype== 11 | constype== 14 | constype== 15 | constype== 30 | constype== 31 | constype== 34 | constype== 37 | constype== 38 | constype== 39 | constype== 40 | constype== 49 | constype== 50 | constype== 53
label var physician_visit "Physician visits"
//generate binary variable
gen physician_visit_b = 0
replace physician_visit_b = 1 if physician_visit==1
label var physician_visit_b "Physician visits (binary) 0= no visit, 1= at least 1 visit"
replace servtype=1 if physician_visit == 1
replace nr_data = constype if servtype==1

//Create a variable for all eligible utilization dates (i.e. those with real, non-missing data)
gen elgdate2 = . 
replace elgdate2 = eventdate2 if eventdate2 <. & nr_data <.
format elgdate2 %td
label var elgdate2 "Eligible date with non-redundant data"

//Drop all duplicates for patients of the same constype on the same day
tempvar dupa
quietly bysort patid servtype elgdate2: gen `dupa' = cond(_N==1,0,_n)
drop if `dupa'>1

if "`file'"=="Clinical001_2b"	{
save Clin_serv, replace
}
else	{
append using Clin_serv
save Clin_serv, replace
}
}
clear

////////////////////////////////////SPLIT FOR EACH WINDOW- INDEXDATE, COHORTENTRYDATE, STUDYENTRYDATE_CPRD/////////////////////////////
//STUDYENTRY DATE
use Clin_serv
keep if elgdate2>=studyentrydate_cprd2-365 & elgdate2<studyentrydate_cprd2
//pull out covariate date of interest
bysort patid servtype : egen prx_covdate_g_s = max(elgdate2) if elgdate2>=studyentrydate_cprd2-365 & elgdate2<studyentrydate_cprd2
format prx_covdate_g_s %td
gen prx_cov_g_s_b = 1 if !missing(prx_covdate_g_s)
//pull out type of doctor visit
bysort patid: gen prx_servvalue_g_s = nr_data

//CREATE COUNTS
//serv_num_un = ennumerates all doctor visits of each type per patient
bysort patid prx_servvalue_g_s: generate serv_num_un = _n
//serv_total_un = max(serv_num_un) = total doctor visits of each type per patient
bysort patid prx_servvalue_g_s:egen serv_total_un = max(serv_num_un)
//serv_num = ennumerates all doctor visits per patient
bysort patid: gen serv_num = _n
//serv_total = max(serv_num) = grand total of doctor visits in window of interest
bysort patid: egen serv_total_g_s = max(serv_num)

//Pull most recent date of a doctor appointment
bysort patid: egen prx_type_servdate_g_s= max(elgdate)
format prx_type_servdate_g_s %td
keep if elgdate2==prx_type_servdate_g_s
bysort patid: gen dupck= cond(_N==1, 0, _n)
drop if dupck>1

//Rectangularize data
fillin patid prx_servvalue_g_s

//Generate binary
gen prx_serv_g_s_b = 0
replace prx_serv_g_s_b = 1 if !missing(prx_type_servdate_g_s)
replace servtype=1

// IF WE WANT TO RESHAPE, collapse down to one observation for each patid
bysort patid: egen prx_servdate_g_s = max(prx_type_servdate_g_s)
format prx_servdate_g_s %td
keep if elgdate2==prx_servdate_g_s
bysort patid: gen dupck2= cond(_N==1, 0, _n)
drop if dupck2>1

//Drop all fields that aren't wanted in the final dta file
keep patid serv_total_g_s prx_servvalue_g_s prx_serv_g_s_b

//collapse (max) serv_total_g_i prx_servvalue_g_i prx_serv_g_i_b, by(patid)
rename serv_total_g_s totservs_g_s
rename prx_servvalue_g_s prx_servvalue1_g_s
rename prx_serv_g_s_b prx_serv1_g_s_b
label var prx_servvalue1_g_s "Most recent constype for physician visits in studyentrydate window (gold)"
label var totservs_g_s "Total number of physician visits in studyentrydate window (gold)"
label var prx_serv1_g_s_b "Binary indicator: 1=have information; 0:no information (gold)"
save Clin_serv_s, replace
clear

//COHORTENTRYDATE
//pull out dates of interest
use Clin_serv
keep if elgdate2>=cohortentrydate-365 & elgdate2<cohortentrydate

//pull out type of doctor visit
bysort patid: gen prx_servvalue_g_c = nr_data

//check for duplicates-NO ACTION
bysort patid prx_servvalue_g_c elgdate2: gen dupck= cond(_N==1, 0, _n)

//CREATE COUNTS
//serv_num_un = ennumerates all doctor visits of each type per patient
bysort patid prx_servvalue_g_c: generate serv_num_un = _n
//serv_total_un = max(serv_num_un) = total doctor visits of each type per patient
bysort patid prx_servvalue_g_c:egen serv_total_un = max(serv_num_un)
//serv_num = ennumerates all doctor visits per patient
bysort patid: gen serv_num = _n
//serv_total = max(serv_num) = grand total of doctor visits in window of interest
bysort patid: egen serv_total_g_c = max(serv_num)

//Pull most recent date of each type 
bysort patid prx_servvalue_g_c: egen prx_type_servdate_g_c= max(elgdate)
format prx_type_servdate_g_c %td
keep if elgdate2==prx_type_servdate_g_c
drop if dupck>1

//Rectangularize data
fillin patid prx_servvalue_g_c

//Generate binary
gen prx_serv_g_c_b = 0
replace prx_serv_g_c_b = 1 if !missing(prx_type_servdate_g_c)
replace servtype=1

// IF WE WANT TO RESHAPE, collapse down to one observation for each patid
bysort patid: egen prx_servdate_g_c = max(prx_type_servdate_g_c)
format prx_servdate_g_c %td
keep if elgdate2==prx_servdate_g_c
bysort patid: gen dupck2= cond(_N==1, 0, _n)
drop if dupck2>1

//Drop all fields that aren't wanted in the final dta file
keep patid serv_total_g_c prx_servvalue_g_c prx_serv_g_c_b

//Reshape
//reshape wide prx_servvalue_g_c serv_total_g prx_serv_g_c_b, i(patid) j(servtype)
rename serv_total_g_c totservs_g_c
rename prx_servvalue_g_c prx_servvalue1_g_c
rename prx_serv_g_c_b prx_serv1_g_c_b
label var prx_servvalue1_g_c "Most recent constype for physician visits in studyentrydate window (gold)"
label var totservs_g_c "Total number of physician visits in studyentrydate window (gold)"
label var prx_serv1_g_c_b "Binary indicator: 1=have information; 0:no information (gold)"
save Clin_serv_c, replace
clear

//INDEX DATE
//use file generated above
use Clin_serv
keep if elgdate2>=indexdate-365 & elgdate2<indexdate

//pull out type of doctor visit
bysort patid: gen prx_servvalue_g_i = nr_data

//check for duplicates-NO ACTION
bysort patid prx_servvalue_g_i elgdate2: gen dupck= cond(_N==1, 0, _n)

//CREATE COUNTS
//serv_num_un = ennumerates all doctor visits of each type per patient
bysort patid prx_servvalue_g_i: generate serv_num_un = _n
//serv_total_un = max(serv_num_un) = total doctor visits of each type per patient
bysort patid prx_servvalue_g_i:egen serv_total_un = max(serv_num_un)
//serv_num = ennumerates all doctor visits per patient
bysort patid: gen serv_num = _n
//serv_total = max(serv_num) = grand total of doctor visits in window of interest
bysort patid: egen serv_total_g_i = max(serv_num)

//Pull most recent date of each type 
bysort patid prx_servvalue_g_i: egen prx_type_servdate_g_i= max(elgdate)
format prx_type_servdate_g_i %td
keep if elgdate2==prx_type_servdate_g_i
drop if dupck>1

//Rectangularize data
fillin patid prx_servvalue_g_i

//Generate binary
gen prx_serv_g_i_b = 0
replace prx_serv_g_i_b = 1 if !missing(prx_type_servdate_g_i)
replace servtype=1

// IF WE WANT TO RESHAPE, collapse down to one observation for each patid
bysort patid: egen prx_servdate_g_i = max(prx_type_servdate_g_i)
format prx_servdate_g_i %td
keep if elgdate2==prx_servdate_g_i
bysort patid: gen dupck2= cond(_N==1, 0, _n)
drop if dupck2>1

//Drop all fields that aren't wanted in the final dta file
keep patid serv_total_g_i prx_servvalue_g_i prx_serv_g_i_b
//collapse (max) serv_total_g_i prx_servvalue_g_i prx_serv_g_i_b, by(patid)
rename serv_total_g_i totservs_g_i
rename prx_servvalue_g_i prx_servvalue1_g_i
rename prx_serv_g_i_b prx_serv1_g_i_b
label var prx_servvalue1_g_i "Most recent constype for physician visits in studyentrydate window (gold)"
label var totservs_g_i "Total number of physician visits in studyentrydate window (gold)"
label var prx_serv1_g_i_b "Binary indicator: 1=have information; 0:no information (gold)"
save Clin_serv_i, replace


clear

timer off 1
timer list 1
exit
log close

