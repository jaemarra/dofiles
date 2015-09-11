//  program:    Data08_checking.do
//  task:		Check .dta files generated in Data08_outcomes_a for data normality
//  project: 	Incretins--Comparative mortality and CV outcomes (CPRD)
//  author:     JM \ Jan2015


clear all
capture log close
set more off
ssc install mdesc
timer clear 1
timer on 1

//DATA08_OUTCOMES_A
//Outcomes_gold.dta
clear all
capture log close
log using Outcomes_gold.smcl
use Outcomes_gold.dta
compress
describe
codebook, compact
tab death_g
tab myoinfarct_g 
tab stroke_g
tab cvdeath_g
hist cvdeath_g_date_i, frequency
graph save Graph Outcomes_a_cvdeath_g_date_i.gph
hist deathdate2, frequency
graph save Graph Outcomes_a_deathdate.gph
log close
