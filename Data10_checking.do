//  program:    Data10_checking.do
//  task:		Check .dta files generated in Data10_labcovariates for data normality
//  project: 	Incretins--Comparative mortality and CV outcomes (CPRD)
//  author:     JM \ Jan2015


clear all
capture log close
set more off

timer clear 1
timer on 1

//DATA10_LABCOVARIATES
//LabCovariates
clear all
capture log close
log using LabCovariates.smcl
use LabCovariates.dta
compress
describe
mdesc
codebook, compact
tab ckd_ce
tab ckd_amdrd
tab ckd_mcg
tab ckd_cg
hist nr_hba1c, frequency
save graph Graph hba1c_labcovariates.gph
hist nr_totchol, frequency
save graph Graph totchol_labcovariates.gph
hist nr_hdl, frequency
save graph Graph hdl_labcovariates.gph
hist nr_ldl, frequency
save graph Graph ldl_labcovariates.gph
hist nr_tg, frequency
save graph Graph tg_labcovariates.gph
hist nr_scr, frequency
save graph Graph scr_labcovariates.gph
hist nr_crcl, frequency
save graph Graph crcl_labcovariates.gph
hist nr_albumin, frequency
save graph Graph albumin_labcovariates.gph
hist nr_alt, frequency
save graph Graph alt_labcovariates.gph
hist nr_ast, frequency
save graph Graph ast_labcovariates.gph
hist nr_bilirubin, frequency
save graph Graph bilirubin_labcovariates.gph
hist nr_hemoglobin, frequency
save graph Graph hemoglobin_labcovariates.gph
hist egfr_amdrd, frequency
save graph Graph egfr_amdrd_labcovariates.gph
hist egfr_mcg, frequency
save graph Graph egfr_mcg_labcovariates.gph
log close

//LabCovariates_i
clear all
capture log close
log using LabCovariates_i.smcl
use LabCovariates_i.dta
compress
describe
mdesc
codebook, compact
log close

//LabCovariates_c
clear all
capture log close
log using LabCovariates_c.smcl
use LabCovariates_c.dta, clear
compress
describe
codebook, compact
mdesc
log close

//LabCovariates_s
clear all
capture log close
log using LabCovariates_s.smcl
use LabCovariates_s.dta
compress
describe
codebook, compact
log close

timer off 1


