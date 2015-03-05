//  program:    Data12_checking.do
//  task:		Check .dta files generated in Data12_anallytic_dataset for data normality
//  project: 	Incretins--Comparative mortality and CV outcomes (CPRD)
//  author:     JM \ Jan2015


clear all
capture log close
set more off

timer clear 1
timer on 1

//DATA12_ANALYTIC_DATASET
//raw_dataset
clear all
capture log close
log using raw_dataset.smcl
use raw_dataset.dta
compress
describe
mdesc
codebook, compact
log close

//Analytic_Dataset_s
clear all
capture log close
log using Analytic_Dataset_s.smcl
use Analytic_Dataset_s.dta
compress
describe
mdesc
codebook, compact
log close

//Analytic_Dataset_c
clear all
capture log close
log using Analytic_Dataset_c.smcl
use Analytic_Dataset_c.dta, clear
compress
describe
codebook, compact
mdesc
log close

//Analytic_Dataset_i
clear all
capture log close
log using Analytic_Dataset_i.smcl
use Analytic_Dataset_i.dta
compress
describe
codebook, compact
log close

//Analytic_Dataset_Master
clear all
capture log close
log using Analytic_Dataset_Master.smcl
use Analytic_Dataset_Master.dta
compress
describe
codebook, compact
log close

timer off 1


