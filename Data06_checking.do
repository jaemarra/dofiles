//  program:    Data06_checking.do
//  task:		Check .dta files generated in Data06_Demographic for data normality
//  project: 	Incretins--Comparative mortality and CV outcomes (CPRD)
//  author:     JM \ Jan2015


clear all
capture log close
set more off

timer clear 1
timer on 1

//DATA06_DEMOGRAPHIC
//Demographic.dta
clear all
capture log close
log using Demographic.smcl
use Demographic.dta
compress
describe
mdesc
codebook, compact
tab maritalstatus
tab sex
hist birthyear, frequency
graph save Graph Demographic_birthyear.gph
hist age_cohortdate, frequency
graph save Graph Demographic_birthyear.gph
hist age_indexdate, frequency
graph save Graph Demographic_age_i.gph
hist age_studyentrydate, frequency
graph save Graph Demographic_age_s.gph
log close

timer off 1


