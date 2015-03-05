//  program:    Data11_servicescovariates_c.do
//  task:       Merge CPRD and HES services covariates data together in each of three windows
//  project:    Incretins--Comparative mortality and CV outcomes (CPRD)
//  author:     JM \ Jan 2015

clear all
capture log close
set more off
set trace on
log using Data11c.txt, replace
timer clear 1
timer on 1

//INDEXDATE: merge Clinical covariate file with HES covariate file and Charlson Comorbidity Index file 
use Clin_serv_i
merge 1:1 patid using hes_serv_i
save ServicesCovariates_merged_i, replace
clear

//COHORTENRYDATE: merge Clinical covariate file with HES covariate file and Charlson Comorbidity Index file 										
use Clin_serv_c.dta
merge 1:1 patid using hes_serv_c
save ServicesCovariates_merged_c, replace
clear

//STUDYENTRYDATE: merge Clinical covariate file with HES covariate file and Charlson Comorbidity Index file 
use Clin_serv_s.dta
merge 1:1 patid using hes_serv_s
save ServicesCovariates_merged_s, replace
clear

timer off 1
timer list 1
exit
log close
