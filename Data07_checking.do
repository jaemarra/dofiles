//  program:    Data07_checking.do
//  task:		Check .dta files generated in Data07_ses for data normality
//  project: 	Incretins--Comparative mortality and CV outcomes (CPRD)
//  author:     JM \ Jan2015


clear all
capture log close
set more off
timer clear 1
timer on 1

//DATA07_SES
//ses.dta
clear all
capture log close
log using ses.smcl
use ses.dta
compress
describe
codebook, compact

timer off 1








