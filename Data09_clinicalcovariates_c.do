//  program:    Data09_clinicalcovariates_c.do
//  task:       Merge CPRD and HES covariate data together with charlson comorbidity score data in each of three windows
//  project:    Incretins--Comparative mortality and CV outcomes (CPRD)
//  author:     JM \ Jan 2015

clear all
capture log close
set more off
set trace on
log using Data09c.log, replace
timer on 1

//INDEXDATE: merge Clinical covariate file with HES covariate file and Charlson Comorbidity Index file 
use ClinicalCovariates_i
merge 1:1 patid using hesCovariates_i, keep(match master) nogen
merge 1:1 patid using Clinical_cci_i, keep(match master) nogen
merge 1:1 patid using hes_cci_i, keep(match master) nogen
save ClinicalCovariates_merged_i
clear

//COHORTENRYDATE: merge Clinical covariate file with HES covariate file and Charlson Comorbidity Index file 										
use ClinicalCovariates_c
merge 1:1 patid using hesCovariates_c, keep(match master) nogen
merge 1:1 patid using Clinical_cci_c, keep(match master) nogen
merge 1:1 patid using hes_cci_c, keep(match master) nogen
save ClinicalCovariates_merged_c
clear

//STUDYENTRYDATE: merge Clinical covariate file with HES covariate file and Charlson Comorbidity Index file 
use ClinicalCovariates_s
merge 1:1 patid using hesCovariates_s, keep(match master) nogen
merge 1:1 patid using Clinical_cci_s, keep(match master) nogen
merge 1:1 patid using hes_cci_s, keep(match master) nogen
save ClinicalCovariates_merged_s
clear

timer off 1
timer list 1
exit
log close
