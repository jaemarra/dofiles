//  program:    Data_checking.do
//  task:		Generate variables indicating drug exposures in CPRD Dataset, using individual Therapy files
//  project: 	Incretins--Comparative mortality and CV outcomes (CPRD)
//  author:     JM \ Jan2015


clear all
capture log close
set more off
ssc install grubbs
//use grubbs to identify outliers if there appear to be outliers in initial data checks
//grubbs varlist, generage(newvar) log
timer clear 1
timer on 1

//DATA01_IMPORT
//linkage_eligibility
log using linkage_eligibility.smcl
use linkage_eligibility.dta
compress
describe
codebook, compact
tab end
tab linked_b
log close

//patid_date
log using patid_date.smcl
use patid_date.dta
compress
codebook, compact
hist studyentrydate, frequency
save graph patid_date_studyentrydate,gph
log close

//Patient
log using Patient.smcl
use Patient.dta, clear
compress
describe
codebook, compact
tab marital
tab regstat
hist yob2, frequency
graph save Patient_yob2.gph
hist tod2, frequency
graph save Patient_tod2.gph
hist deathdate2, frequency
graph save Patient_deathdate2.gph
log close

foreach var of varlist {
tabulate
summarize
histogram, saving(gr`var', replace)
grubbs `var' level(99)
}

timer off 1
