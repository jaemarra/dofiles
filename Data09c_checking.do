//  program:    Data09c_checking.do
//  task:		Check .dta files generated in Data09_clinicalcovariates_c for data normality
//  project: 	Incretins--Comparative mortality and CV outcomes (CPRD)
//  author:     JM \ Jan2015


clear all
capture log close
set more off

timer clear 1
timer on 1

//DATA09_CLINICALCOVARITES_C
//NOTE: All of these files are merged files that were previously checked (Data09a_checking.do and Data09b_checking.do)
//ClinicalCovariates_merged_i
clear all
capture log close
log using ClinicalCovariates_merged_i.smcl
use ClinicalCovariates_merged_i.dta
compress
describe
mdesc
codebook, compact
log close

//ClinicalCovariates_merged_c
clear all
capture log close
log using ClinicalCovariates_merged_c.smcl
use ClinicalCovariates_merged_c.dta
compress
describe
mdesc
codebook, compact
log close

//ClinicalCovariates_merged_s
clear all
capture log close
log using ClinicalCovariates_merged_s.smcl
use ClinicalCovariates_merged_s.dta, clear
compress
describe
codebook, compact
mdesc
log close

timer off 1


