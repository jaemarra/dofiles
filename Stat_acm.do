//  program:    Stat_acm.do
//  task:		Statistical analysis for all-cause mortality
//  project: 	Incretins--Comparative mortality and CV outcomes (CPRD)
//  author:     JM \ April 2015  
//				

clear all
capture log close Stat_acm
set more off
log using Stat_acm.smcl, name(Stat_acm) replace
timer on 1

capture ssc install table1
capture net install collin.pkg

use Analytic_Dataset_Master.dta, clear
quietly do Data13_variable_generation.do
//apply exclusion criteria
keep if exclude==0
//restrict to jan 1, 2007
drop if seconddate<17167
//remove missing values from ACM variable
replace acm=0 if acm==.
save acm, replace

//COMPLETE CASE APPROACH
// update censor times for final exposure to second-line agent (indextype)
clonevar acm_exit_clone=acm_exit
forval i=0/5 {
	replace acm_exit_clone = exposuretf`i' if indextype==`i' & exposuretf`i'!=.
}
replace acm = 0 if acm_exit_clone<death_date

// declare survival analysis - final exposure as last exposure date 
stset acm_exit_clone, fail(acm) id(patid) origin(seconddate) scale(365.25)

quietly {
// spit data to integrate time-varying covariates for diabetes meds.
gen su_post=0
gen dpp4i_post=0
gen glp1ra_post=0
gen ins_post=0
gen tzd_post=0
gen oth_post=0

stsplit adm3, after(thirddate) at(0)
replace su_post=(indextype3==0 & adm3!=-1)
replace dpp4i_post=(indextype3==1 & adm3!=-1)
replace glp1ra_post=(indextype3==2 & adm3!=-1)
replace ins_post=(indextype3==3  & adm3!=-1)
replace tzd_post=(indextype3==4 & adm3!=-1)
replace oth_post=(indextype3==5  & adm3!=-1)

stsplit adm4, after(fourthdate) at(0)
replace su_post=1 if indextype4==0 & adm4!=-1
replace dpp4i_post=1 if indextype4==1 & adm4!=-1
replace glp1ra_post=1 if indextype4==2 & adm4!=-1
replace ins_post=1 if indextype4==3 & adm4!=-1
replace tzd_post=1 if indextype4==4 & adm4!=-1
replace oth_post=1 if indextype4==5 & adm4!=-1

stsplit adm5, after(fifthdate) at(0) 
replace su_post=1 if indextype5==0 & adm5!=-1
replace dpp4i_post=1 if indextype5==1 & adm5!=-1
replace glp1ra_post=1 if indextype5==2 & adm5!=-1
replace ins_post=1 if indextype5==3 & adm5!=-1
replace tzd_post=1 if indextype5==4 & adm5!=-1
replace oth_post=1 if indextype5==5 & adm5!=-1

stsplit adm6, after(sixthdate) at(0)
replace su_post=1 if indextype6==0 & adm6!=-1
replace dpp4i_post=1 if indextype6==1 & adm6!=-1
replace glp1ra_post=1 if indextype6==2 & adm6!=-1
replace ins_post=1 if indextype6==3 & adm6!=-1
replace tzd_post=1 if indextype6==4 & adm6!=-1
replace oth_post=1 if indextype6==5 & adm6!=-1

stsplit adm7, after(seventhdate) at(0)
replace su_post=1 if indextype7==0 & adm7!=-1
replace dpp4i_post=1 if indextype7==1 & adm7!=-1
replace glp1ra_post=1 if indextype7==2 & adm7!=-1
replace ins_post=1 if indextype7==3 & adm7!=-1
replace tzd_post=1 if indextype7==4 & adm7!=-1
replace oth_post=1 if indextype7==5 & adm7!=-1

stsplit stop0, after(exposuretf0) at(0)
replace su_post=0 if su_post==1 & stop0!=-1

stsplit stop1, after(exposuretf1) at(0)
replace dpp4i_post=0 if dpp4i_post==1 & stop1!=-1

stsplit stop2, after(exposuretf2) at(0)
replace glp1ra_post=0 if glp1ra_post==1 & stop2!=-1

stsplit stop3, after(exposuretf3) at(0)
replace ins_post=0 if ins_post==1 & stop3!=-1

stsplit stop4, after(exposuretf4) at(0)
replace tzd_post=0 if tzd_post==1 & stop4!=-1

stsplit stop5, after(exposuretf5) at(0)
replace oth_post=0 if oth_post==1 & stop5!=-1
}

save Stat_acm_cc, replace

//Generate person-years, incidence rate, and 95%CI as well as unadjusted hazard ratio
stptime, by(indextype) per(1000)
stcox i.indextype, cformat(%6.2f) pformat(%5.3f) sformat(%6.2f) 

//MULTIPLE IMPUTATION APPROACH
use acm, clear

quietly {
//Create macros
//all demographic covariates
local demo = "age_indexdate gender ib2.smokestatus"
//all demographic covariates included in model (not including those being imputed)
local demo2= "age_indexdate gender"
//all demographic covariates included in model post-imputation
local demoMI= "age_indexdate gender ib2.smokestatus_clone"
//all comorbidity history covariates included in model (not including those being imputed)
local comorb = "i.prx_ccivalue_g_i2 mi_i stroke_i hf_i arr_i ang_i revasc_i htn_i afib_i pvd_i"
//all comorbidity history covariates included in model (not including those being imputed); individual CV comorbidities simplified to cvd_i
local comorb2 ="i.prx_ccivalue_g_i2 cvd_i"
//all medication history covariates
local meds = "i.unique_cov_drugs dmdur metoverlap statin_i calchan_i betablock_i anticoag_oral_i antiplat_i ace_arb_renin_i diuretics_all_i post_*"
//all medication history covariates included in model (not including those being imputed); post_* are always dropped for collinearity
local meds2 = "i.unique_cov_drugs dmdur metoverlap statin_i calchan_i betablock_i anticoag_oral_i antiplat_i ace_arb_renin_i diuretics_all_i"
//all clinical covariates
local clin = "ib1.hba1c_cats_i2 sbp i.ckd_amdrd i.physician_vis2 bmi_i"
//all clinical covariates included in model (not including those being imputed)
local clin2 = "i.ckd_amdrd i.physician_vis2"
//all clinical covariates included in model post-imputation
local clinMI = "ib1.hba1c_cats_i2_clone sbp i.ckd_amdrd i.physician_vis2 bmi_i"

// update censor times for final exposure to second-line agent (indextype)
clonevar acm_exit_clone=acm_exit
forval i=0/5 {
	replace acm_exit_clone = exposuretf`i' if indextype==`i' & exposuretf`i'!=.
}
replace acm=0 if acm_exit_clone<death_date

//generate variable necessary for use in later analyses with cprd and hes only
egen acm_exit_g = rowmin(tod2 deathdate2 lcd2)
egen acm_exit_h = rowmin(tod2 dod2 lcd2)
}

// declare survival analysis - final exposure as last exposure date 
stset acm_exit_clone, fail(acm) id(patid) origin(seconddate) scale(365.25)

quietly {
//put data in mlong form such that complete rows are omitted and only incomplete and imputed rows are shown
mi set mlong
save acm_mlong, replace
clonevar hba1c_cats_i2_clone = hba1c_cats_i2
replace hba1c_cats_i2_clone=. if hba1c_cats_i2==5
clonevar smokestatus_clone = smokestatus
replace smokestatus_clone=. if smokestatus==0
//inform mi which variables contain missing values for which we want to timpute (bmi_i and sbp)
mi register imputed bmi_i sbp smokestatus_clone hba1c_cats_i2_clone
//describe and learn about the missing values in the data
mi describe 
mi misstable summarize
mi misstable nested
//set the seed so that results are reproducible
set seed 1979
//impute (20 iterations) for each missing value in the registered variables
mi impute chained (regress) bmi_i sbp (mlogit) smokestatus_clone hba1c_cats_i2_clone = acm `demo2' `comorb2' `meds2' `clin2', add(20)
//verify that all missing values are filled in
//mi describe
//look at summary statistics in each of the imputation datasets
//mi xeq: summarize
// spit data to integrate time-varying covariates for diabetes meds.
gen su_post=0
gen dpp4i_post=0
gen glp1ra_post=0
gen ins_post=0
gen tzd_post=0
gen oth_post=0

mi stsplit adm3, after(thirddate) at(0)
replace su_post=(indextype3==0 & adm3!=-1)
replace dpp4i_post=(indextype3==1 & adm3!=-1)
replace glp1ra_post=(indextype3==2 & adm3!=-1)
replace ins_post=(indextype3==3  & adm3!=-1)
replace tzd_post=(indextype3==4 & adm3!=-1)
replace oth_post=(indextype3==5  & adm3!=-1)

mi stsplit adm4, after(fourthdate) at(0)
replace su_post=1 if indextype4==0 & adm4!=-1
replace dpp4i_post=1 if indextype4==1 & adm4!=-1
replace glp1ra_post=1 if indextype4==2 & adm4!=-1
replace ins_post=1 if indextype4==3 & adm4!=-1
replace tzd_post=1 if indextype4==4 & adm4!=-1
replace oth_post=1 if indextype4==5 & adm4!=-1

mi stsplit adm5, after(fifthdate) at(0) 
replace su_post=1 if indextype5==0 & adm5!=-1
replace dpp4i_post=1 if indextype5==1 & adm5!=-1
replace glp1ra_post=1 if indextype5==2 & adm5!=-1
replace ins_post=1 if indextype5==3 & adm5!=-1
replace tzd_post=1 if indextype5==4 & adm5!=-1
replace oth_post=1 if indextype5==5 & adm5!=-1

mi stsplit adm6, after(sixthdate) at(0)
replace su_post=1 if indextype6==0 & adm6!=-1
replace dpp4i_post=1 if indextype6==1 & adm6!=-1
replace glp1ra_post=1 if indextype6==2 & adm6!=-1
replace ins_post=1 if indextype6==3 & adm6!=-1
replace tzd_post=1 if indextype6==4 & adm6!=-1
replace oth_post=1 if indextype6==5 & adm6!=-1

mi stsplit adm7, after(seventhdate) at(0)
replace su_post=1 if indextype7==0 & adm7!=-1
replace dpp4i_post=1 if indextype7==1 & adm7!=-1
replace glp1ra_post=1 if indextype7==2 & adm7!=-1
replace ins_post=1 if indextype7==3 & adm7!=-1
replace tzd_post=1 if indextype7==4 & adm7!=-1
replace oth_post=1 if indextype7==5 & adm7!=-1

mi stsplit stop0, after(exposuretf0) at(0)
replace su_post=0 if su_post==1 & stop0!=-1

mi stsplit stop1, after(exposuretf1) at(0)
replace dpp4i_post=0 if dpp4i_post==1 & stop1!=-1

mi stsplit stop2, after(exposuretf2) at(0)
replace glp1ra_post=0 if glp1ra_post==1 & stop2!=-1

mi stsplit stop3, after(exposuretf3) at(0)
replace ins_post=0 if ins_post==1 & stop3!=-1

mi stsplit stop4, after(exposuretf4) at(0)
replace tzd_post=0 if tzd_post==1 & stop4!=-1

mi stsplit stop5, after(exposuretf5) at(0)
replace oth_post=0 if oth_post==1 & stop5!=-1
}

save Stat_acm_mi, replace

//Generate person-years, incidence rate, and 95%CI as well as unadjusted hazard ratio
mi xeq: stptime, by(indextype) per(1000)
mi estimate, hr: stcox i.indextype, cformat(%6.2f) pformat(%5.3f) sformat(%6.2f) 

*******************************************************SENSITIVITY ANALYSIS*******************************************************
//#1 MULTIPLE IMPUTATION APPROACH AT AGENT 3
use acm, clear
quietly {
//Create macros
//all demographic covariates
local demo = "age_indexdate gender ib2.smokestatus"
//all demographic covariates included in model (not including those being imputed)
local demo2= "age_indexdate gender"
//all demographic covariates included in model post-imputation
local demoMI= "age_indexdate gender ib2.smokestatus_clone"
//all comorbidity history covariates included in model (not including those being imputed)
local comorb = "i.prx_ccivalue_g_i2 mi_i stroke_i hf_i arr_i ang_i revasc_i htn_i afib_i pvd_i"
//all comorbidity history covariates included in model (not including those being imputed); individual CV comorbidities simplified to cvd_i
local comorb2 ="i.prx_ccivalue_g_i2 cvd_i"
//all medication history covariates
local meds = "i.unique_cov_drugs dmdur metoverlap statin_i calchan_i betablock_i anticoag_oral_i antiplat_i ace_arb_renin_i diuretics_all_i post_*"
//all medication history covariates included in model (not including those being imputed); post_* are always dropped for collinearity
local meds2 = "i.unique_cov_drugs dmdur metoverlap statin_i calchan_i betablock_i anticoag_oral_i antiplat_i ace_arb_renin_i diuretics_all_i"
//all clinical covariates
local clin = "ib1.hba1c_cats_i2 sbp i.ckd_amdrd i.physician_vis2 bmi_i"
//all clinical covariates included in model (not including those being imputed)
local clin2 = "i.ckd_amdrd i.physician_vis2"
//all clinical covariates included in model post-imputation
local clinMI = "ib1.hba1c_cats_i2_clone sbp i.ckd_amdrd i.physician_vis2 bmi_i"
}
// update censor times for final exposure to third-line agent (indextype3)
clonevar acm_exit_clone=acm_exit
gen exposure_exit=.
forval i=0/5 {
 replace exposure_exit = exposuretf`i' if indextype3==`i' & exposuretf`i'!=.
}
replace acm=0 if exposure_exit<acm_exit_clone
replace acm_exit_clone=exposure_exit if exposure_exit<acm_exit_clone

// declare survival analysis - final exposure as last exposure date 
stset acm_exit_clone, fail(acm) id(patid) origin(thirddate) scale(365.25)

quietly {
//put data in mlong form such that complete rows are omitted and only incomplete and imputed rows are shown
mi set mlong
clonevar hba1c_cats_i2_clone = hba1c_cats_i2
replace hba1c_cats_i2_clone=. if hba1c_cats_i2==5
clonevar smokestatus_clone = smokestatus
replace smokestatus_clone=. if smokestatus==0
//inform mi which variables contain missing values for which we want to timpute (bmi_i and sbp)
mi register imputed bmi_i sbp smokestatus_clone hba1c_cats_i2_clone
//set the seed so that results are reproducible
set seed 1979
//impute (20 iterations) for each missing value in the registered variables
mi impute chained (regress) bmi_i sbp (mlogit) smokestatus_clone hba1c_cats_i2_clone = acm `demo2' `comorb2' `meds2' `clin2', add(20)
// spit data to integrate time-varying covariates for diabetes meds.
gen su_post=0
gen dpp4i_post=0
gen glp1ra_post=0
gen ins_post=0
gen tzd_post=0
gen oth_post=0

mi stsplit adm4, after(fourthdate) at(0)
replace su_post=1 if indextype4==0 & adm4!=-1
replace dpp4i_post=1 if indextype4==1 & adm4!=-1
replace glp1ra_post=1 if indextype4==2 & adm4!=-1
replace ins_post=1 if indextype4==3 & adm4!=-1
replace tzd_post=1 if indextype4==4 & adm4!=-1
replace oth_post=1 if indextype4==5 & adm4!=-1

mi stsplit adm5, after(fifthdate) at(0) 
replace su_post=1 if indextype5==0 & adm5!=-1
replace dpp4i_post=1 if indextype5==1 & adm5!=-1
replace glp1ra_post=1 if indextype5==2 & adm5!=-1
replace ins_post=1 if indextype5==3 & adm5!=-1
replace tzd_post=1 if indextype5==4 & adm5!=-1
replace oth_post=1 if indextype5==5 & adm5!=-1

mi stsplit adm6, after(sixthdate) at(0)
replace su_post=1 if indextype6==0 & adm6!=-1
replace dpp4i_post=1 if indextype6==1 & adm6!=-1
replace glp1ra_post=1 if indextype6==2 & adm6!=-1
replace ins_post=1 if indextype6==3 & adm6!=-1
replace tzd_post=1 if indextype6==4 & adm6!=-1
replace oth_post=1 if indextype6==5 & adm6!=-1

mi stsplit adm7, after(seventhdate) at(0)
replace su_post=1 if indextype7==0 & adm7!=-1
replace dpp4i_post=1 if indextype7==1 & adm7!=-1
replace glp1ra_post=1 if indextype7==2 & adm7!=-1
replace ins_post=1 if indextype7==3 & adm7!=-1
replace tzd_post=1 if indextype7==4 & adm7!=-1
replace oth_post=1 if indextype7==5 & adm7!=-1

mi stsplit stop0, after(exposuretf0) at(0)
replace su_post=0 if su_post==1 & stop0!=-1

mi stsplit stop1, after(exposuretf1) at(0)
replace dpp4i_post=0 if dpp4i_post==1 & stop1!=-1

mi stsplit stop2, after(exposuretf2) at(0)
replace glp1ra_post=0 if glp1ra_post==1 & stop2!=-1

mi stsplit stop3, after(exposuretf3) at(0)
replace ins_post=0 if ins_post==1 & stop3!=-1

mi stsplit stop4, after(exposuretf4) at(0)
replace tzd_post=0 if tzd_post==1 & stop4!=-1

mi stsplit stop5, after(exposuretf5) at(0)
replace oth_post=0 if oth_post==1 & stop5!=-1
}
save Stat_hf_mi3, replace

//Generate person-years, incidence rate, and 95%CI as well as hazard ratio
mi xeq: stptime, by(indextype) per(1000)
mi estimate, hr: stcox i.indextype, cformat(%6.2f) pformat(%5.3f) sformat(%6.2f)

// #2. CENSOR EXPSOURE AT FIRST GAP FOR THE FIRST SWITCH/ADD AGENT (INDEXTYPE)
use acm, clear
quietly {
//Create macros
//all demographic covariates
local demo = "age_indexdate gender ib2.smokestatus"
//all demographic covariates included in model (not including those being imputed)
local demo2= "age_indexdate gender"
//all demographic covariates included in model post-imputation
local demoMI= "age_indexdate gender ib2.smokestatus_clone"
//all comorbidity history covariates included in model (not including those being imputed)
local comorb = "i.prx_ccivalue_g_i2 mi_i stroke_i hf_i arr_i ang_i revasc_i htn_i afib_i pvd_i"
//all comorbidity history covariates included in model (not including those being imputed); individual CV comorbidities simplified to cvd_i
local comorb2 ="i.prx_ccivalue_g_i2 cvd_i"
//all medication history covariates
local meds = "i.unique_cov_drugs dmdur metoverlap statin_i calchan_i betablock_i anticoag_oral_i antiplat_i ace_arb_renin_i diuretics_all_i post_*"
//all medication history covariates included in model (not including those being imputed); post_* are always dropped for collinearity
local meds2 = "i.unique_cov_drugs dmdur metoverlap statin_i calchan_i betablock_i anticoag_oral_i antiplat_i ace_arb_renin_i diuretics_all_i"
//all clinical covariates
local clin = "ib1.hba1c_cats_i2 sbp i.ckd_amdrd i.physician_vis2 bmi_i"
//all clinical covariates included in model (not including those being imputed)
local clin2 = "i.ckd_amdrd i.physician_vis2"
//all clinical covariates included in model post-imputation
local clinMI = "ib1.hba1c_cats_i2_clone sbp i.ckd_amdrd i.physician_vis2 bmi_i"
}

//update censor times for last continuous exposure to second-line agent (indextype)
clonevar acm_exit_clone=acm_exit
forval i=0/5 {
	replace acm_exit_clone = exposuret1`i' if indextype==`i' & exposuret1`i'!=.
}
replace acm=0 if acm_exit_clone<death_date

//declare survival analysis - last continuous exposure as last exposure date 
stset acm_exit_clone, fail(acm) id(patid) origin(seconddate) scale(365.25)

quietly {
// Multiple imputation
//put data in mlong form such that complete rows are omitted and only incomplete and imputed rows are shown
mi set mlong
save acm_mlong, replace
clonevar hba1c_cats_i2_clone = hba1c_cats_i2
replace hba1c_cats_i2_clone=. if hba1c_cats_i2==5
clonevar smokestatus_clone = smokestatus
replace smokestatus_clone=. if smokestatus==0
//inform mi which variables contain missing values for which we want to impute (bmi_i and sbp)
mi register imputed bmi_i sbp hba1c_cats_i2_clone smokestatus_clone
//set the seed so that results are reproducible
set seed 1979
//impute (20 iterations) for each missing value in the registered variables
mi impute chained (regress) bmi_i sbp (mlogit) smokestatus_clone hba1c_cats_i2_clone = acm `demo2' `comorb2' `meds2' `clin2', add(20)

//spit data to integrate time-varying covariates for diabetes meds.
gen su_post=0
gen dpp4i_post=0
gen glp1ra_post=0
gen ins_post=0
gen tzd_post=0
gen oth_post=0

mi stsplit adm3, after(thirddate) at(0)
replace su_post=(indextype3==0 & adm3!=-1)
replace dpp4i_post=(indextype3==1 & adm3!=-1)
replace glp1ra_post=(indextype3==2 & adm3!=-1)
replace ins_post=(indextype3==3  & adm3!=-1)
replace tzd_post=(indextype3==4 & adm3!=-1)
replace oth_post=(indextype3==5  & adm3!=-1)

mi stsplit adm4, after(fourthdate) at(0)
replace su_post=1 if indextype4==0 & adm4!=-1
replace dpp4i_post=1 if indextype4==1 & adm4!=-1
replace glp1ra_post=1 if indextype4==2 & adm4!=-1
replace ins_post=1 if indextype4==3 & adm4!=-1
replace tzd_post=1 if indextype4==4 & adm4!=-1
replace oth_post=1 if indextype4==5 & adm4!=-1

mi stsplit adm5, after(fifthdate) at(0)
replace su_post=1 if indextype5==0 & adm5!=-1
replace dpp4i_post=1 if indextype5==1 & adm5!=-1
replace glp1ra_post=1 if indextype5==2 & adm5!=-1
replace ins_post=1 if indextype5==3 & adm5!=-1
replace tzd_post=1 if indextype5==4 & adm5!=-1
replace oth_post=1 if indextype5==5 & adm5!=-1

mi stsplit adm6, after(sixthdate) at(0)
replace su_post=1 if indextype6==0 & adm6!=-1
replace dpp4i_post=1 if indextype6==1 & adm6!=-1
replace glp1ra_post=1 if indextype6==2 & adm6!=-1
replace ins_post=1 if indextype6==3 & adm6!=-1
replace tzd_post=1 if indextype6==4 & adm6!=-1
replace oth_post=1 if indextype6==5 & adm6!=-1

mi stsplit adm7, after(seventhdate) at(0)
replace su_post=1 if indextype7==0 & adm7!=-1
replace dpp4i_post=1 if indextype7==1 & adm7!=-1
replace glp1ra_post=1 if indextype7==2 & adm7!=-1
replace ins_post=1 if indextype7==3 & adm7!=-1
replace tzd_post=1 if indextype7==4 & adm7!=-1
replace oth_post=1 if indextype7==5 & adm7!=-1

mi stsplit stop0, after(exposuretf0) at(0)
replace su_post=0 if su_post==1 & stop0!=-1

mi stsplit stop1, after(exposuretf1) at(0)
replace dpp4i_post=0 if dpp4i_post==1 & stop1!=-1

mi stsplit stop2, after(exposuretf2) at(0)
replace glp1ra_post=0 if glp1ra_post==1 & stop2!=-1

mi stsplit stop3, after(exposuretf3) at(0)
replace ins_post=0 if ins_post==1 & stop3!=-1

mi stsplit stop4, after(exposuretf4) at(0)
replace tzd_post=0 if tzd_post==1 & stop4!=-1

mi stsplit stop5, after(exposuretf5) at(0)
replace oth_post=0 if oth_post==1 & stop5!=-1
}
save Stat_acm_mi_index, replace

//Generate person-years, incidence rate, and 95%CI as well as unadjusted hazard ratio
mi xeq: stptime, by(indextype) per(1000)
mi estimate, hr: stcox i.indextype, cformat(%6.2f) pformat(%5.3f) sformat(%6.2f)  

//********************************************************************************************************************************//
//#3. CENSOR EXPSOURE AT INDEXTYPE3
use acm, clear

quietly {
//Create macros
//all demographic covariates
local demo = "age_indexdate gender ib2.smokestatus"
//all demographic covariates included in model (not including those being imputed)
local demo2= "age_indexdate gender"
//all demographic covariates included in model post-imputation
local demoMI= "age_indexdate gender ib2.smokestatus_clone"
//all comorbidity history covariates included in model (not including those being imputed)
local comorb = "i.prx_ccivalue_g_i2 mi_i stroke_i hf_i arr_i ang_i revasc_i htn_i afib_i pvd_i"
//all comorbidity history covariates included in model (not including those being imputed); individual CV comorbidities simplified to cvd_i
local comorb2 ="i.prx_ccivalue_g_i2 cvd_i"
//all medication history covariates
local meds = "i.unique_cov_drugs dmdur metoverlap statin_i calchan_i betablock_i anticoag_oral_i antiplat_i ace_arb_renin_i diuretics_all_i post_*"
//all medication history covariates included in model (not including those being imputed); post_* are always dropped for collinearity
local meds2 = "i.unique_cov_drugs dmdur metoverlap statin_i calchan_i betablock_i anticoag_oral_i antiplat_i ace_arb_renin_i diuretics_all_i"
//all clinical covariates
local clin = "ib1.hba1c_cats_i2 sbp i.ckd_amdrd i.physician_vis2 bmi_i"
//all clinical covariates included in model (not including those being imputed)
local clin2 = "i.ckd_amdrd i.physician_vis2"
//all clinical covariates included in model post-imputation
local clinMI = "ib1.hba1c_cats_i2_clone sbp i.ckd_amdrd i.physician_vis2 bmi_i"
}

//update censor times for single agent exposure to a thirddate
gen censor2=.
gen censor3=.
clonevar acm_exit_clone=acm_exit

forval i=0/5 {
	replace censor2 = exposuretf`i' if indextype==`i' & exposuretf`i'!=.
	replace censor3 = exposuret0`i' if indextype3==`i' & exposuret0`i'!=.
}
egen censordate = rowmin(censor2 censor3)
replace acm_exit_clone = censordate if censordate!=.

//reset acm to zero patient is censored before the death event
replace acm=0 if acm_exit_clone<death_date

// declare survival analysis for single agent exposure to thirddate
stset acm_exit_clone, fail(acm) id(patid) origin(seconddate) scale(365.25)

quietly {
// Multiple imputation
//put data in mlong form such that complete rows are omitted and only incomplete and imputed rows are shown
mi set mlong
save acm_mlong, replace
clonevar hba1c_cats_i2_clone = hba1c_cats_i2
replace hba1c_cats_i2_clone=. if hba1c_cats_i2==5
clonevar smokestatus_clone = smokestatus
replace smokestatus_clone=. if smokestatus==0
//inform mi which variables contain missing values for which we want to timpute (bmi_i and sbp)
mi register imputed bmi_i sbp smokestatus_clone hba1c_cats_i2
//set the seed so that results are reproducible
set seed 1979
//impute (20 iterations) for each missing value in the registered variables
mi impute chained (regress) bmi_i sbp (mlogit) hba1c_cats_i2 smokestatus_clone = acm `demo2' `comorb2' `meds2' `clin2', add(20)
}

save Stat_acm_mi_index3, replace

//Generate person-years, incidence rate, and 95%CI as well as unadjusted hazard ratio
mi xeq: stptime, title(person-years) per(1000)
mi estimate, hr: stcox i.indextype, cformat(%6.2f) pformat(%5.3f) sformat(%6.2f) 

//********************************************************************************************************************************//
//#4 ANY EXPOSURE AFTER METFORMIN
use acm, clear

quietly {
//generate macros
//Create macros
//all demographic covariates
local demo = "age_indexdate gender ib2.smokestatus"
//all demographic covariates included in model (not including those being imputed)
local demo2= "age_indexdate gender"
//all demographic covariates included in model post-imputation
local demoMI= "age_indexdate gender ib2.smokestatus_clone"
//all comorbidity history covariates included in model (not including those being imputed)
local comorb = "i.prx_ccivalue_g_i2 mi_i stroke_i hf_i arr_i ang_i revasc_i htn_i afib_i pvd_i"
//all comorbidity history covariates included in model (not including those being imputed); individual CV comorbidities simplified to cvd_i
local comorb2 ="i.prx_ccivalue_g_i2 cvd_i"
//all medication history covariates
local meds = "i.unique_cov_drugs dmdur metoverlap statin_i calchan_i betablock_i anticoag_oral_i antiplat_i ace_arb_renin_i diuretics_all_i post_*"
//all medication history covariates included in model (not including those being imputed); post_* are always dropped for collinearity
local meds2 = "i.unique_cov_drugs dmdur metoverlap statin_i calchan_i betablock_i anticoag_oral_i antiplat_i ace_arb_renin_i diuretics_all_i"
//all clinical covariates
local clin = "ib1.hba1c_cats_i2 sbp i.ckd_amdrd i.physician_vis2 bmi_i"
//all clinical covariates included in model (not including those being imputed)
local clin2 = "i.ckd_amdrd i.physician_vis2"
//all clinical covariates included in model post-imputation
local clinMI = "ib1.hba1c_cats_i2_clone sbp i.ckd_amdrd i.physician_vis2 bmi_i"
}

//declare data as survival dataset
stset acm_exit, fail(acm) id(patid) origin(seconddate) scale(365.25)

quietly {
// Multiple imputation
//put data in mlong form such that complete rows are omitted and only incomplete and imputed rows are shown
mi set mlong
save acm_mlong, replace
clonevar hba1c_cats_i2_clone = hba1c_cats_i2
replace hba1c_cats_i2_clone=. if hba1c_cats_i2==5
clonevar smokestatus_clone = smokestatus
replace smokestatus_clone=. if smokestatus==0
//inform mi which variables contain missing values for which we want to timpute (bmi_i and sbp)
mi register imputed bmi_i sbp smokestatus_clone hba1c_cats_i2_clone
//set the seed so that results are reproducible
set seed 1979
//impute (20 iterations) for each missing value in the registered variables
mi impute chained (regress) bmi_i sbp (mlogit) smokestatus_clone hba1c_cats_i2_clone = acm `demo2' `comorb2' `meds2' `clin2', add(20)
//fit the model separately on each of the 20 imputed datasets and combine results
}

save Stat_acm_mi_any, replace

//Generate person-years, incidence rate, and 95%CI as well as unadjusted hazard ratio
mi xeq: stptime, title(person-years) per(1000)
mi estimate, hr: stcox i.indextype, cformat(%6.2f) pformat(%5.3f) sformat(%6.2f) 

timer off 1
log close Stat_acm
