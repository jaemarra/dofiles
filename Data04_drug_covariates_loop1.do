//  program:    Data04_loop.do
//  task:		Generate a loop through all Therapy files for Data04_drug_covariates
//  project: 	Incretins--Comparative mortality and CV outcomes (CPRD)
//  author:     JM \ Feb2015

clear all
capture log close
set more off

log using Data04.txt, replace
timer clear 1
timer on 1

forval i=0/9 {
	use Therapy_`i', clear
	do Data04_drug_covariates.do
	save drug_covariates_`i'.dta, replace
	}

timer off 1
timer list 1

exit
log close
