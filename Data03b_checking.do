//  program:    Data03b_checking.do
//  task:		Check .dta files generated in Data03_drug_exposures_b for data normality
//  project: 	Incretins--Comparative mortality and CV outcomes (CPRD)
//  author:     JM \ Jan2015


clear all
capture log close
set more off
ssc install mdesc
timer clear 1
timer on 1

//DATA_03_DRUG_EXPOSURES_B
//Drug_Exposures_B
clear all
capture log close
log using Drug_Exposures_B.smcl
use Drug_Exposures_B.dta
compress
describe
codebook, compact
log close

timer off 1








