//  program:    Data04_dates.do
//  task:		Generate Dates dataset (cohort entry, index, study entry). 
//  project: 	Incretins--Comparative mortality and CV outcomes (CPRD)
//  author:     MA \ May2014 Modified JM \ Nov2014


clear all 
capture log close
set more off

log using Data04.smcl, replace
timer on 1

// #1- Generate dataset of patient id, cohort entry date, index date, and study entry date.

use Exposures.dta
keep patid cohortentrydate indexdate studyentrydate studyentrydate_cprd2 maincohort metcohort
unique patid
sort patid
compress
save Dates.dta, replace

////////////////////////////////////////////

timer off 1 
timer list 1

exit
log close
