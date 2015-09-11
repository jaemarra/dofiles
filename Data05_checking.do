//  program:    Data05_checking.do
//  task:		Check .dta files generated in Data05_immunisations for data normality
//  project: 	Incretins--Comparative mortality and CV outcomes (CPRD)
//  author:     JM \ Jan2015


clear all
capture log close
set more off

timer clear 1
timer on 1

//DATA05_IMMUNISATIONS
//Immunisation2.dta
clear all
capture log close
log using Immunisation2.smcl
use Immunisation2.dta
compress
describe
mdesc
codebook, compact
log close

timer off 1


