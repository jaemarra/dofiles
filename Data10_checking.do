//  program:    Data09a_checking.do
//  task:		Check .dta files generated in Data09_clinicalcovariates_a for data normality
//  project: 	Incretins--Comparative mortality and CV outcomes (CPRD)
//  author:     JM \ Jan2015


clear all
capture log close
set more off

timer clear 1
timer on 1

//DATA09_CLINICALCOVARITES_A
//Clinical_Covariates_i
clear all
capture log close
log using Clinical_Covariates_i.smcl
use Clinical_Covariates_i.dta
compress
describe
mdesc
codebook, compact
log close

//Clinical_Covariates_c
clear all
capture log close
log using Clinical_Covariates_c.smcl
use Clinical_Covariates_c.dta
compress
describe
mdesc
codebook, compact
log close

//Clinical_Covariates_s
clear all
capture log close
log using Clinical_Covariates_s.smcl
use Clinical_Covariates_s.dta, clear
compress
describe
codebook, compact
mdesc
log close

//Clinical_cci_i
clear all
capture log close
log using Clinical_cci_i.smcl
use Clinical_cci_i.dta
compress
describe
codebook, compact
log close

//Clinical_cci_c
clear all
capture log close
log using Clinical_cci_c.smcl
use Clinical_cci_c.dta, clear
compress
describe
codebook, compact
mdesc
log close

//Clinical_cci_s
clear all
capture log close
log using Clinical_cci_s.smcl
use Clinical_cci_s.dta, clear
compress
describe
codebook, compact
mdesc
log close

//ClinicalCovariates_wt
clear all
capture log close
log using ClinicalCovariates_wt.smcl
use ClinicalCovariates_wt.dta, clear
compress
describe
codebook, compact
mdesc
log close

timer off 1


