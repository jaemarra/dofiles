//  program:    Data08b_checking.do
//  task:		Check .dta files generated in Data08_outcomes_b for data normality
//  project: 	Incretins--Comparative mortality and CV outcomes (CPRD)
//  author:     JM \ Jan2015


clear all
capture log close
set more off
ssc install mdesc
timer clear 1
timer on 1

//DATA08_OUTCOMES_B
//Outcomes_hes
clear all
capture log close
log using Outcomes_hes.smcl
use Outcomes_hes.dta
compress
describe
codebook, compact
tab cvdeath_h
tab myoinfarct_h
hist cvdeath_h_date_i, frequency
graph save Graph Outcomes_b_cvdeath_h_date_i.gph
hist myoinfarct_h_date_i, frequency
graph save Graph Outcomes_b_myoinfarct_h_date_i.gph
log close

//Outcomes_procedures
clear all
capture log close
log using Outcomes_procedures.smcl
use Outcomes_procedures.dta
compress
codebook, compact
tab revasc_opcs
hist proc_date_i, frequency
graph save Graph Outcomes_b_proc_date_i.gph
log close

timer off 1








