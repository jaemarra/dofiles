//  program:    Data12_analytic_dataset.do
//  task:		Prepare analytic dataset by merging all generated files and applying exclusion criteria
//  project: 	Incretins--Comparative mortality and CV outcomes (CPRD)
//  author:     MA \ May2014 JM \ J


clear all
capture log close
set more off
set trace on
log using Data12.txt, replace
timer on 1

// #1 Merge all files.

// 1) Exposure dataset, 2) Immunizations dataset, 3) Demographic dataset, 4) SES dataset, 5) Outcome dataset (already one file containing ///
// 4 + procedures + all cause hosp), 6) ClinicalCovariate dataset,  7) LabCovariate dataset ) 8) ServicesCovariate dataset 

use Drug_Exposures_a_wide.dta
merge 1:1 patid using Drug_Exposures_B, nogen
merge 1:1 patid using Immunisation2, nogen
merge 1:1 patid using Demographic, nogen
merge 1:1 patid using ses, nogen
merge 1:1 patid using Outcomes, nogen
merge 1:1 patid using Exclusion_merged, nogen
merge 1:1 patid using Censor, nognen
save raw_dataset, replace

//Generate 3 datasets for studyentry, cohortentry and indexdate windows
//STUDYENTRYDATE
use raw_dataset, clear
merge 1:1 patid using Drug_Covariates_s, nogen
merge 1:1 patid using ClinicalCovariates_merged_s, nogen
merge 1:1 patid using LabCovariates_s, nogen
merge 1:1 patid using ServicesCovariates_merged_s, nogen
datasignature set, reset
save Analytic_Dataset_s, replace
clear

//COHORTENTRYDATE
use raw_dataset, clear
merge 1:1 patid using Drug_Covariates_c, nogen
merge 1:1 patid using ClinicalCovariates_merged_c, nogen
merge 1:1 patid using LabCovariates_c, nogen
merge 1:1 patid using ServicesCovariates_merged_c, nogen
datasignature set, reset
save Analytic_Dataset_c, replace
clear

//INDEXDATE
use raw_dataset, clear
merge 1:1 patid using Drug_Covariates_i, nogen
merge 1:1 patid using ClinicalCovariates_merged_i, nogen
merge 1:1 patid using LabCovariates_i, nogen
merge 1:1 patid using ServicesCovariates_merged_i.dta, nogen
datasignature set, reset
save Analytic_Dataset_i, replace
clear

//TRY MERGING EVERTHING TOGETHER FOR ONE MASTER ANALYIC DATASET!!!!!!!!!!!!
use Analytic_Dataset_s, clear
merge 1:1 patid using Analytic_Dataset_c, generate(cohort_ind)
merge 1:1 patid using Analytic_Dataset_i, generate(index_ind)
//drop if cohort_b==0
//35049 patids dropped
//drop if age_cohortdate<30
//5572 observations dropped
//drop if pcos==1|preg==1|gest_diab==1
//6840 observations dropped
datasignature set, reset
save Analytic_Dataset_Master, replace
clear

timer off 1 
timer list 1

exit
log close
