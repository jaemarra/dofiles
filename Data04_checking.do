//  program:    Data04_checking.do
//  task:		Check .dta files generated in Data0_drug_covariates for data normality
//  project: 	Incretins--Comparative mortality and CV outcomes (CPRD)
//  author:     JM \ Jan2015


clear all
capture log close
set more off

timer clear 1
timer on 1

//DATA04_DRUG COVARIATES
//Drug_Covariates.dta
clear all
capture log close
log using Drug_Covariates.smcl
use Drug_Covariates.dta
compress
describe
mdesc
codebook, compact
log close

timer off 1


