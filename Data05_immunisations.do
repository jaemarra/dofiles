//  program:    Data05_immunisations.do
//  task:		Generate Immunisations dataset (flu, pneumo, other; in year prior to cohort entry date, index date and study entry date).
//  project: 	Incretins--Comparative mortality and CV outcomes (CPRD)
//  author:     MA \ May2014 Modified JM \ Nov2014


clear all
capture log close
set more off

log using Data05.smcl, replace
timer on 1

////// #1 Merge Dates with Immunisation using key variable patid.

use Immunisation
sort patid
merge m:1 patid using Dates, keep(match using) nogen

////// #2 Immunisation2- create binary variables for flu, pneumococcal and other vaccines in year prior to cohort entry date, index date and study entry date.

gen othervaccine_c = 0
replace othervaccine_c = 1 if inlist(immstype, 0,1,2,3,5,6,7,8,9,10,11,12,14,15,16,17,19,20,21,22,23,24,25,26,27,29,30,31,32,33,34,35,36,37,38,39,40,41,42,43,44,45,46,47,48,49,50,51,52,53,54,55,56,57,58,59,60,61,62,63,64,66,67,68,69,70,77,79,80,81,83,86,87,88) & immunisedate2>=cohortentrydate-365 & immunisedate2<cohortentrydate
label variable othervaccine_c "Other vaccine in year before cohort entry date: 0=no exp, 1=exp"

gen othervaccine_i = 0
replace othervaccine_i = 1 if inlist(immstype, 0,1,2,3,5,6,7,8,9,10,11,12,14,15,16,17,19,20,21,22,23,24,25,26,27,29,30,31,32,33,34,35,36,37,38,39,40,41,42,43,44,45,46,47,48,49,50,51,52,53,54,55,56,57,58,59,60,61,62,63,64,66,67,68,69,70,77,79,80,81,83,86,87,88) & immunisedate2>=indexdate-365 & immunisedate2<indexdate
label variable othervaccine_i "Other vaccine in year before index date: 0=no exp, 1=exp"

gen othervaccine_s = 0
replace othervaccine_s = 1 if inlist(immstype, 0,1,2,3,5,6,7,8,9,10,11,12,14,15,16,17,19,20,21,22,23,24,25,26,27,29,30,31,32,33,34,35,36,37,38,39,40,41,42,43,44,45,46,47,48,49,50,51,52,53,54,55,56,57,58,59,60,61,62,63,64,66,67,68,69,70,77,79,80,81,83,86,87,88) & immunisedate2>=studyentrydate_cprd2-365 & immunisedate2<studyentrydate_cprd2
label variable othervaccine_s "Other vaccine in year before study entry date: 0=no exp, 1=exp"

gen flu_c = 0
replace flu_c = 1 if inlist(immstype, 4,71,72,73,74,75,76,78,84,85,89) & immunisedate2>=cohortentrydate-365 & immunisedate2<cohortentrydate
label variable flu_c "Flu vaccine in year before cohort entry date: 0=no exp, 1=exp"

gen flu_i = 0
replace flu_i = 1 if inlist(immstype, 4,71,72,73,74,75,76,78,84,85,89) & immunisedate2>=indexdate-365 & immunisedate2<indexdate
label variable flu_i "Flu vaccine in year before index date: 0=no exp, 1=exp"

gen flu_s = 0
replace flu_s = 1 if inlist(immstype, 4,71,72,73,74,75,76,78,84,85,89) & immunisedate2>=studyentrydate_cprd2-365 & immunisedate2<studyentrydate_cprd2
label variable flu_s "Flu vaccine in year before study entry date: 0=no exp, 1=exp"

gen pneumo_c = 0
replace pneumo_c = 1 if inlist(immstype, 13,18,28,82) & immunisedate2>=cohortentry-365 & immunisedate2<cohortentrydate
label variable pneumo_c "Pneumo vaccine in year before cohort entry date: 0=no exp, 1=exp"

gen pneumo_i = 0
replace pneumo_i = 1 if inlist(immstype, 13,18,28,82) & immunisedate2>=indexdate-365 & immunisedate2<indexdate
label variable pneumo_i "Pneumo vaccine in year before index date: 0=no exp, 1=exp"

gen pneumo_s = 0
replace pneumo_s = 1 if inlist(immstype, 13,18,28,82) & immunisedate2>=studyentrydate_cprd2-365 & immunisedate2<studyentrydate_cprd2
label variable pneumo_s "Pneumo vaccine in year before study entry date: 0=no exp, 1=exp"

collapse (max) immunisedate2 indexdate cohortentrydate studyentrydate studyentrydate_cprd2 flu_c flu_i flu_s pneumo_c pneumo_i pneumo_s othervaccine_c othervaccine_i othervaccine_s , by(patid)
compress
save Immunisation2, replace 

////////////////////////////////////////////

timer off 1 
timer list 1

exit
log close

