//  program:    Data12_analytic_dataset.do
//  task:		Prepare analytic dataset by merging all generated files and applying exclusion criteria
//  project: 	Incretins--Comparative mortality and CV outcomes (CPRD)
//  author:     MA \ May2014 JM \ Dec2014


clear all
capture log close
set more off

log using Data12.smcl, replace
timer on 1

// #1 Merge all files.

// 1) Exposure dataset, 2) Immunizations dataset, 3) Demographic dataset, 4) SES dataset, 5) Outcome dataset (already one file containing ///
// 4 + procedures + all cause hosp), 6) Labcovariate dataset,  7) Clinical covariate dataset (already one file containing 3 + proc) 8) Services covariate 9) 

use Exposure.dta
joinby patid using Immunisation2
merge m:1 patid using Demographic, keep(match master)
merge m:1 patid using ses, keep(match master)
joinby patid using Outcomes
joinby patid using Clincovs
joinby patid using Labcovs
joinby patid using Servcovs
save Analytic_Dataset, replace

// #2 Exclude patients with PCOS and pregnancy and <30 years old on cohort entry
** code for exclusion, once down to one observation line per patid:
drop if pcos==1|pregnant==1

** may need to change this line for secondary analysis when using studyentry and not cohort/index
drop if age_cohortdate<30


// #3 Data signature



////////////////////////////////////////////

timer off 1 
timer list 1

exit
log close
