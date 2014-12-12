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

foreach file in Clinical001_2 Clinical002_2 Clinical003_2 Clinical004_2 Clinical005_2 Clinical006_2 Clinical007_2 Clinical008_2 Clinical009_2 Clinical010_2 Clinical011_2 Clinical012_2 Clinical013_2 {

use `file', clear
sort patid
merge m:1 patid using Dates, keep(match) nogen
sort patid
keep if eventdate2>studyentrydate_cprd2
sort patid 
joinby patid pt_gen_hesid using hes, keep(match) nogen
sort patid
joinby patid adid using Additional, unmatched(master) _merge(Additional_merge)
merge m:1 patid using Patient2, keep(match) nogen
compress
save `file'_merge_ServCov.dta, replace
}
keep if eventdate2<indexdate
drop sysinputclin staffid vmid mob famnum chsreg chsdate prescr capsup ses frd crd accept chsdate2
cd /Desktop/incretin/
save servcovariatesv1dot1.dta, replace

////// #1 Generate binary variables coding for each Health Service. Code so 0=no interaction and 1=interaction. For each interaction: generate, replace, label
// Based on HES codes

//Number Of Physician Visits 
gen physician_visits = .
//WHICH ONES TO USE????
replace physician_visits = 1 if constype== 1 | constype== 3
//create counts
sort patid enttype elgdate2
by patid enttype: generate int_num = _n
by patid: egen visit_num_un = count(physician_visits) if visit_num==1 
label variable physician_visits "Total number of physician visits"

gen physician_visits_b = 0
replace physician_visits_b = 1 if physician visits <.
label variable physician_visits_b "Physician visits (binary)"

//Number Of Hospital Visits 
gen hosp_visits = .
replace hosp_visits = spno
label variable hosp_visits "Unique hospital visit ID"
//remove duplicates
quietly bysort patid spno: gen dupa = cond(_N==1,0,_n)
drop if dupa>1

gen hosp_visits_b = 0
replace hosp_visits_b = 1 if hosp_visits <.
label variable hosp_visits_b "Hospital visits (binary)"

//Duration of Hospital Stays
/* gen hosp_stay = .
format hosp_stay %td
gen hosp_stay_start = .
format hosp_stay_start %td
gen hosp_stay_end = .
format hosp_stay_end %td
replace hosp_stay_start = admidate
replace hosp_stay_end = discharge
replace hosp_stay = discharge - admidate*/
gen hosp_duration = duration

//Create a varibale for all eligible hospitalization dates (i.e. those with real, in-range nr_data2)
gen elgdate2 = . 
replace elgdate2 = eventdate2 if eventdate2 <. & 
format elgdate2 %td

//Drop all duplicates for patients of the same enttype on the same day
quietly bysort patid enttype elgdate2: gen dupa = cond(_N==1,0,_n)
drop if dupa>1

// #4 Code for exclusions (PCOS, pregnant)...must do before collapsing so that info isn't lost
gen pcos = 0 
replace pcos = 1 if regexm(readcode, "C164.00|C165.00")
label variable pcos "PCOS 1=have 0=not have"

//gen pregnant_b = 0
//replace pregnant_b = 1 if ...
//label pregnant_b "Pregnant 1=pregnant, 0=not"

//pull out dates of interest
bysort patid enttype : egen prx_testdate_s = max(elgdate2) if elgdate2>=studyentrydate_cprd2-365 & eltestdate2<studyentrydate_cprd2
format prx_testdate_s %td
gen prx_test_s_b = 1 if !missing(prx_testdate_s)

//pull out test value of interest
bysort patid enttype : gen prx_testvalue_s = nr_data2 if prx_testdate_s==elgdate2

//create counts
sort patid enttype elgdate2
by patid enttype: generate int_num = _n
by patid: egen lab_num_un = count(enttype) if lab_num==1 

by patid: egen lab_num_un_s_temp = count(enttype) if lab_num==1 & elgdate2>=studyentrydate_cprd-365 & elgdate2<studyentrydate_cprd
by patid: egen lab_num_un_s = min(lab_num_un_s_temp)
drop lab_num_un_s_temp

//Create a new variable that numbers enttypes 1-12
tostring enttype, generate(labtype)
encode labtype, generate(labtest)
label drop labtest

//only keep the observations relevant to the current window
drop if prx_testvalue_s >=.

/*Check for duplicates again- no duplicates found then continue
quietly bysort patid labtest: gen dupck = cond(_N==1,0,_n)
drop if dupck>1*/

//Rectangularize data
fillin patid labtest

//Fillin the total number of labs in the window of interest
bysort patid: egen totlabs = total(lab_num)

//Drop all fields that aren't wanted in the final dta file
keep patid totlabs labtest prx_testvalue_s prx_test_s_b

//Reshape
reshape wide prx_testvalue_s prx_test_s_b, i(patid) j(labtest)

save servicescovariateswindowdotwide, replace
collapse (max) (min) /// FILL IN VARIABLES /// , by(patid)
compress
save Covariates.dta, replace

////////////////////////////////////////////

exit
log close

