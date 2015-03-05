//  program:    Data11c_checking.do
//  task:		Check .dta files generated in Data11_servicescovariates_c for data normality
//  project: 	Incretins--Comparative mortality and CV outcomes (CPRD)
//  author:     JM \ Jan2015


clear all
capture log close
set more off

timer clear 1
timer on 1

//DATA11_SERVICESCOVARIATES_C
//ServicesCovariates_merged_i
clear all
capture log close
log using ServicesCovariates_merged_i.smcl
use ServicesCovariates_merged_i.dta
compress
describe
mdesc
codebook, compact
log close

//ServicesCovariates_merged_c
clear all
capture log close
log using ServicesCovariates_merged_c.smcl
use ServicesCovariates_merged_c.dta
compress
describe
mdesc
codebook, compact
log close

//ServicesCovariates_merged_s
clear all
capture log close
log using ServicesCovariates_merged_s.smcl
use ServicesCovariates_merged_s.dta, clear
compress
describe
codebook, compact
mdesc
log close

timer off 1


