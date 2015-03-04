//  program:    Data08d_checking.do
//  task:		Check .dta files generated in Data08_outcomes_d for data normality
//  project: 	Incretins--Comparative mortality and CV outcomes (CPRD)
//  author:     JM \ Jan2015


clear all
capture log close
set more off
ssc install mdesc
timer clear 1
timer on 1

//DATA08_OUTCOMES_D
//Outcomes.dta
clear all
capture log close
log using Outcomes.smcl
use Outcomes.dta
compress
describe
codebook, compact
//all variables checked in previous checking.do files (Data08a-c)
log close

timer off 1
