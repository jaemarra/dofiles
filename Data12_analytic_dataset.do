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
merge 1:1 patid using Immunisation2, keep(match master) nogen
merge 1:1 patid using Demographic, keep(match master) nogen
merge 1:1 patid using ses, keep(match master) nogen
merge 1:1 patid using Outcomes, keep(match master) nogen
save raw_dataset, replace

//Generate 3 datasets for studyentry, cohortentry and indexdate windows
//STUDYENTRYDATE
use raw_dataset, clear
merge 1:1 patid using ClinicalCovariates_merged_s.dta, keep (match master) nogen
merge 1:1 patid using LabCovariates_s.dta, keep (match master) nogen
merge 1:1 patid using ServicesCovariates_s.dta, keep (match master) nogen
drop if age_cohortdate<30
//drop if pcos==1|pregnant==1|gest_diab==1
datasignature set, reset
save Analytic_Dataset_s, replace
clear

//COHORTENTRYDATE
use raw_dataset, clear
merge 1:1 patid using ClinicalCovariates_merged_c.dta, keep (match master) nogen
merge 1:1 patid using LabCovariates_c.dta, keep (match master) nogen
merge 1:1 patid using ServicesCovariates_c.dta, keep (match master) nogen
drop if age_cohortdate<30
//drop if pcos==1|pregnant==1|gest_diab==1
datasignature set, reset
save Analytic_Dataset_c, replace
clear

//INDEXDATE
use raw_dataset, clear
merge 1:1 patid using ClinicalCovariates_merged_i.dta, keep (match master) nogen
merge 1:1 patid using LabCovariates_i.dta, keep (match master) nogen
merge 1:1 patid using ServicesCovariates_i.dta, keep (match master) nogen
drop if age_cohortdate<30
//drop if pcos==1|pregnant==1|gest_diab==1
datasignature set, reset
save Analytic_Dataset_i, replace

timer off 1 
timer list 1

exit
log close
