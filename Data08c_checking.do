//  program:    Data08c_checking.do
//  task:		Check .dta files generated in Data08_outcomes_c for data normality
//  project: 	Incretins--Comparative mortality and CV outcomes (CPRD)
//  author:     JM \ Jan2015


clear all
capture log close
set more off
ssc install mdesc
timer clear 1
timer on 1

//DATA08_OUTCOMES_C
//Outcomes_ons
clear all
capture log close
log using Outcomes_ons.smcl
use Outcomes_ons.dta
compress
describe
codebook, compact
tab death_ons
tab cvdeath_o
tab myoinfarct_o
hist myoinfarct_o_date_i, frequency
graph save Graph Outcomes_c_myoinfarct_o_date_i.gph
hist  cvdeath_o_date_i, frequency
graph save Graph Outcomes_c_ cvdeath_o_date_i.gph
log close

timer off 1
