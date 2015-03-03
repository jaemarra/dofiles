//  program:    Data00_checking.do
//  task:		Check .dta files generated in Data00_exclusion.do for data normality
//  project: 	Incretins--Comparative mortality and CV outcomes (CPRD)
//  author:     JM \ Jan2015


clear all
capture log close
set more off

timer clear 1
timer on 1

//DATA00_EXCLUSION
//Exclusion_cprd
clear all
capture log close
log using Exclusion_cprd.smcl
use Exclusion_cprd.dta
compress
describe
mdesc
codebook, compact
log close

//Exclusion_hes
clear all
capture log close
log using Exclusion_hes.smcl
use Exclusion_hes.dta
compress
codebook, compact
log close

//Exclusion_hes_mat
clear all
capture log close
log using Exclusion_hes_mat.smcl
use Exclusion_hes_mat.dta, clear
compress
describe
codebook, compact
mdesc
log close

//Exclusion_merged
clear all
capture log close
log using Exclusion_merged.smcl
use Exclusion_merged.dta
compress
describe
mdesc
codebook, compact
log close

timer off 1










