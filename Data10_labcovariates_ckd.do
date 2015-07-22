//  program:    Data10_labcovariates_ckd.do
//  task:		Generate long form file indicating SERUM CREATININE levels in CPRD dataset
//  project: 	Incretins--Comparative mortality and CV outcomes (CPRD)
//  author:     JM \ Jun2015


clear all
capture log close
set more off

log using Data10ckd.smcl, replace

timer clear 1
timer on 1

//Start with the base drug exposures file in long form
use LabCovariates

//merge in analytic variables
merge m:1 patid using Analytic_variables_a, gen(flag)

//tidy labels
label var tx "Censor date calculated as first of lcd, tod"
label var cohort_b "Binary indicator; 1=metformin first only cohort; 0=not in cohort"
label var unqrx "Number of unique antidiabetic medications"

//merge in exclusion variables (pcos, preg, gestational diabetes) to allow restriction to primary cohort if desired
merge m:1 patid using Exclusion_merged, gen(flag2)

//generate a marker for history of serum creatinine testing
gen ever_sc=1 if enttype==165
replace ever_sc=0 if ever_sc==.
bysort patid: egen sc_history=max(ever_sc) 
drop ever_sc

//drop all patids with no history of serum creatinine measurement
drop if sc_history==0

save LabCovariates_ckd, replace

timer off 1
log close
