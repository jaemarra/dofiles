//  program:    Data12_analytic_dataset.do
//  task:		Prepare analytic dataset by merging all generated files and applying exclusion criteria
//  project: 	Incretins--Comparative mortality and CV outcomes (CPRD)
//  author:     MA \ May2014 JM \ J


clear all
capture log close
set more off
set trace on
log using Data12.smcl, replace
timer on 1

// #1 Merge all files.

// 1) Exposure dataset, 2) Immunizations dataset, 3) Demographic dataset, 4) SES dataset, 5) Outcome dataset (already one file containing ///
// 4 + procedures + all cause hosp), 6) ClinicalCovariate dataset,  7) LabCovariate dataset ) 8) ServicesCovariate dataset 

use Exposures.dta
merge 1:1 patid using Immunisation2, nogen
merge 1:1 patid using Demographic, nogen
merge 1:1 patid using ses, nogen
merge 1:1 patid using Outcomes, nogen
merge 1:1 patid using Exclusion_merged, nogen
save raw_dataset, replace

//Generate 3 datasets for studyentry, cohortentry and indexdate windows
//STUDYENTRYDATE
use raw_dataset, clear
merge 1:1 patid using ClinicalCovariates_merged_s, nogen
merge 1:1 patid using LabCovariates_s, nogen
merge 1:1 patid using ServicesCovariates_merged_s, nogen
drop if age_cohortdate<30
drop if pcos==1|preg==1|gest_diab==1
datasignature set, reset
save Analytic_Dataset_s, replace
clear

//COHORTENTRYDATE
use raw_dataset, clear
merge 1:1 patid using ClinicalCovariates_merged_c, nogen
merge 1:1 patid using LabCovariates_c, nogen
merge 1:1 patid using ServicesCovariates_merged_c, nogen
drop if age_cohortdate<30
drop if pcos==1|preg==1|gest_diab==1
datasignature set, reset
save Analytic_Dataset_c, replace
clear

//INDEXDATE
use raw_dataset, clear
merge 1:1 patid using ClinicalCovariates_merged_i, nogen
merge 1:1 patid using LabCovariates_i, nogen
merge 1:1 patid using ServicesCovariates_merged_i.dta, nogen
drop if age_cohortdate<30
drop if pcos==1|preg==1|gest_diab==1
datasignature set, reset
save Analytic_Dataset_i, replace

timer off 1 
timer list 1

exit
log close
