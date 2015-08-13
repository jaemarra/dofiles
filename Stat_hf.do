//  program:    Stat_hf.do
//  task:		Statistical analysis for all-cause mortality
//  project: 	Incretins--Comparative mortality and CV outcomes (CPRD)
//  author:     JM \ April 2015  
//				

clear all
capture log close Stat_hf
set more off
log using Stat_hf.smcl, name(Stat_hf) replace
timer on 1

use Analytic_Dataset_Master.dta, clear
quietly do Data13_variable_generation.do
//apply exclusion criteria
keep if exclude==0
//restrict to jan 1, 2007
drop if seconddate<17167
save hf, replace

*******************************************************COX PROPORTIONAL HAZARDS REGRESSION*******************************************************
//COMPLETE CASE APPROACH
use hf, clear
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

// update censor times for final exposure to second-line agent (indextype)
gen exposure_exit=.
forval i=0/5 {
	replace exposure_exit = exposuretf`i' if indextype==`i' & exposuretf`i'!=.
}

replace hf=0 if exposure_exit<hf_exit
replace hf_exit=exposure_exit if exposure_exit<hf_exit

// declare survival analysis - final exposure as last exposure date 
stset hf_exit, fail(hf) id(patid) origin(seconddate) scale(365.25)

quietly {
// spit data to integrate time-varying covariates for diabetes meds.
stsplit adm3, after(thirddate) at(0)
gen su_post=(indextype3==0 & adm3!=-1)
gen dpp4i_post=(indextype3==1 & adm3!=-1)
gen glp1ra_post=(indextype3==2 & adm3!=-1)
gen ins_post=(indextype3==3  & adm3!=-1)
gen tzd_post=(indextype3==4 & adm3!=-1)
gen oth_post=(indextype3==5  & adm3!=-1)

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

save Stat_hf_cc, replace

//Generate person-years, incidence rate, and 95%CI as well as hazard ratio
stptime, by(indextype) per(1000)
stcox i.indextype, cformat(%6.2f) pformat(%5.3f) sformat(%6.2f) 

//MULTIPLE IMPUTATION APPROACH
use hf, clear
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
// update censor times for final exposure to second-line agent (indextype)
gen exposure_exit=.
forval i=0/5 {
 replace exposure_exit = exposuretf`i' if indextype==`i' & exposuretf`i'!=.
}
replace hf=0 if exposure_exit<hf_exit
replace hf_exit=exposure_exit if exposure_exit<hf_exit

// declare survival analysis - final exposure as last exposure date 
stset hf_exit, fail(hf) id(patid) origin(seconddate) scale(365.25)

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
mi impute chained (regress) bmi_i sbp (mlogit) smokestatus_clone hba1c_cats_i2_clone = hf `demo2' `comorb2' `meds2' `clin2', add(20)
// spit data to integrate time-varying covariates for diabetes meds.
mi stsplit adm3, after(thirddate) at(0)
gen su_post=(indextype3==0 & adm3!=-1)
gen dpp4i_post=(indextype3==1 & adm3!=-1)
gen glp1ra_post=(indextype3==2 & adm3!=-1)
gen ins_post=(indextype3==3  & adm3!=-1)
gen tzd_post=(indextype3==4 & adm3!=-1)
gen oth_post=(indextype3==5  & adm3!=-1)

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
save Stat_hf_mi, replace

//Generate person-years, incidence rate, and 95%CI as well as hazard ratio
mi xeq: stptime, by(indextype) per(1000)
mi estimate, hr: stcox i.indextype, cformat(%6.2f) pformat(%5.3f) sformat(%6.2f) 

*******************************************************SENSITIVITY ANALYSIS*******************************************************
// #1a. CENSOR EXPSOURE AT FIRST GAP FOR THE FIRST SWITCH/ADD AGENT (INDEXTYPE)
use hf, clear
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
gen exposure_exit=.
forval i=0/5 {
 replace exposure_exit = exposuret1`i' if indextype==`i' & exposuret1`i'!=.
}
replace hf=0 if exposure_exit<hf_exit
replace hf_exit=exposure_exit if exposure_exit<hf_exit

//declare survival analysis - last continuous exposure as last exposure date 
stset hf_exit, fail(hf) id(patid) origin(seconddate) scale(365.25)
quietly {
// Multiple imputation
//put data in mlong form such that complete rows are omitted and only incomplete and imputed rows are shown
mi set mlong
clonevar hba1c_cats_i2_clone = hba1c_cats_i2
replace hba1c_cats_i2_clone=. if hba1c_cats_i2==5
clonevar smokestatus_clone = smokestatus
replace smokestatus_clone=. if smokestatus==0
//inform mi which variables contain missing values for which we want to impute (bmi_i and sbp)
mi register imputed bmi_i sbp hba1c_cats_i2_clone smokestatus_clone
//set the seed so that results are reproducible
set seed 1979
//impute (20 iterations) for each missing value in the registered variables
mi impute chained (regress) bmi_i sbp (mlogit) smokestatus_clone hba1c_cats_i2_clone = hf `demo2' `comorb2' `meds2' `clin2', add(20)

//spit data to integrate time-varying covariates for diabetes meds.
mi stsplit adm3, after(thirddate) at(0)
gen su_post=(indextype3==0 & adm3!=-1)
gen dpp4i_post=(indextype3==1 & adm3!=-1)
gen glp1ra_post=(indextype3==2 & adm3!=-1)
gen ins_post=(indextype3==3  & adm3!=-1)
gen tzd_post=(indextype3==4 & adm3!=-1)
gen oth_post=(indextype3==5  & adm3!=-1)

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
save Stat_hf_mi_index, replace

//Generate person-years, incidence rate, and 95%CI as well as hazard ratio
mi xeq: stptime, by(indextype) per(1000)
mi estimate, hr: stcox i.indextype

//********************************************************************************************************************************//
//#2a. CENSOR EXPSOURE AT INDEXTYPE3
use hf, clear
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
gen exposure_exit=.
gen censor2=.
gen censor3=.
forval i=0/5 {
 replace censor2 = exposuretf`i' if indextype==`i' & exposuretf`i'!=.
 replace censor3 = exposuret0`i' if indextype3==`i' & exposuret0`i'!=.
}
egen censordate = rowmin(censor2 censor3)
replace exposure_exit = censordate
drop censor2 censor3 censordate

//reset hf to zero patient is censored before the death event
replace hf=0 if exposure_exit<hf_exit
replace hf_exit=exposure_exit if exposure_exit<hf_exit

// declare survival analysis for single agent exposure to thirddate
stset hf_exit, fail(hf) id(patid) origin(seconddate) scale(365.25)

quietly {
// Multiple imputation
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
mi impute chained (regress) bmi_i sbp (mlogit) hba1c_cats_i2_clone smokestatus_clone = hf `demo2' `comorb2' `meds2' `clin2', add(20)
//Generate hazard ratios
mi estimate, hr: stcox i.indextype, cformat(%6.2f) pformat(%5.3f) sformat(%6.2f) 

// spit data to integrate time-varying covariates for diabetes meds.
mi stsplit adm3, at(0) after(thirddate)
gen su_post=regexm(thirdadmrx, "SU") & adm3!=-1
gen dpp4i_post=regexm(thirdadmrx, "DPP") & adm3!=-1
gen glp1ra_post=regexm(thirdadmrx, "GLP") & adm3!=-1
gen ins_post=regexm(thirdadmrx, "insulin") & adm3!=-1
gen tzd_post=regexm(thirdadmrx, "TZD") & adm3!=-1
gen oth_post=regexm(thirdadmrx, "other") & adm3!=-1

mi stsplit adm4, at(0) after(fourthdate)
replace su_post=1 if regexm(fourthadmrx, "SU") & adm4!=-1
replace dpp4i_post= 1 if regexm(fourthadmrx, "DPP") & adm4!=-1
replace glp1ra_post=1 if regexm(fourthadmrx, "GLP") & adm4!=-1
replace ins_post=1 if regexm(fourthadmrx, "insulin") & adm4!=-1
replace tzd_post=1 if regexm(fourthadmrx, "TZD") & adm4!=-1
replace oth_post=1 if regexm(fourthadmrx, "other") & adm4!=-1

mi stsplit adm5, at(0) after(fifthdate)
replace su_post=1 if regexm(fifthadmrx, "SU") & adm5!=-1
replace dpp4i_post= 1 if regexm(fifthadmrx, "DPP") & adm5!=-1
replace glp1ra_post=1 if regexm(fifthadmrx, "GLP") & adm5!=-1
replace ins_post=1 if regexm(fifthadmrx, "insulin") & adm5!=-1
replace tzd_post=1 if regexm(fifthadmrx, "TZD") & adm5!=-1
replace oth_post=1 if regexm(fifthadmrx, "other") & adm5!=-1

mi stsplit adm6, at(0) after(sixthdate)
replace su_post=1 if regexm(sixthadmrx, "SU") & adm6!=-1
replace dpp4i_post= 1 if regexm(sixthadmrx, "DPP") & adm6!=-1
replace glp1ra_post=1 if regexm(sixthadmrx, "GLP") & adm6!=-1
replace ins_post=1 if regexm(sixthadmrx, "insulin") & adm6!=-1
replace tzd_post=1 if regexm(sixthadmrx, "TZD") & adm6!=-1
replace oth_post=1 if regexm(sixthadmrx, "other") & adm6!=-1

mi stsplit adm7, at(0) after(seventhdate)
replace su_post=1 if regexm(seventhadmrx, "SU") & adm7!=-1
replace dpp4i_post= 1 if regexm(seventhadmrx, "DPP") & adm7!=-1
replace glp1ra_post=1 if regexm(seventhadmrx, "GLP") & adm7!=-1
replace ins_post=1 if regexm(seventhadmrx, "insulin") & adm7!=-1
replace tzd_post=1 if regexm(seventhadmrx, "TZD") & adm7!=-1
replace oth_post=1 if regexm(seventhadmrx, "other") & adm7!=-1

replace su_post=1 if regexm(secondadmrx, "SU")
replace dpp4i_post=1 if regexm(secondadmrx, "DPP")
replace glp1ra_post=1 if regexm(secondadmrx, "GLP")
replace ins_post=1 if regexm(secondadmrx, "insulin")
replace tzd_post=1 if regexm(secondadmrx, "TZD") 
replace oth_post=1 if regexm(secondadmrx, "other")

//split patient observations into individual rows at the end of every exposure: time-varying
mi stsplit stop0, at(0) after(exposuretf0)
replace su_post=0 if su_post==1 & stop0!=-1

mi stsplit stop1, at(0) after(exposuretf1)
replace dpp4i_post=0 if dpp4i_post==1 & stop1!=-1

mi stsplit stop2, at(0) after(exposuretf2)
replace glp1ra_post=0 if glp1ra_post==1 & stop2!=-1

mi stsplit stop3, at(0) after(exposuretf3)
replace ins_post=0 if ins_post==1 & stop3!=-1

mi stsplit stop4, at(0) after(exposuretf4)
replace tzd_post=0 if tzd_post==1 & stop4!=-1

mi stsplit stop5, at(0) after(exposuretf5)
replace oth_post=0 if oth_post==1 & stop5!=-1
}
save Stat_hf_mi_index3, replace

//Generate person-years, incidence rate, and 95%CI as well as hazard ratio
mi xeq: stptime, by(indextype) title(person-years) per(1000)
mi estimate, hr: stcox i.indextype

//********************************************************************************************************************************//
//#3 ANY EXPOSURE AFTER METFORMIN
use hf, clear
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
//declare data as survival dataset
stset hf_exit, fail(hf) id(patid) origin(seconddate)

quietly {
// Multiple imputation
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
mi impute chained (regress) bmi_i sbp (mlogit) smokestatus_clone hba1c_cats_i2_clone = hf `demo2' `comorb2' `meds2' `clin2', add(20)

// spit data to integrate time-varying covariates for diabetes meds.
mi stsplit adm3, at(0) after(thirddate)
gen su_post=regexm(thirdadmrx, "SU") & adm3!=-1
gen dpp4i_post=regexm(thirdadmrx, "DPP") & adm3!=-1
gen glp1ra_post=regexm(thirdadmrx, "GLP") & adm3!=-1
gen ins_post=regexm(thirdadmrx, "insulin") & adm3!=-1
gen tzd_post=regexm(thirdadmrx, "TZD") & adm3!=-1
gen oth_post=regexm(thirdadmrx, "other") & adm3!=-1

mi stsplit adm4, at(0) after(fourthdate)
replace su_post=1 if regexm(fourthadmrx, "SU") & adm4!=-1
replace dpp4i_post= 1 if regexm(fourthadmrx, "DPP") & adm4!=-1
replace glp1ra_post=1 if regexm(fourthadmrx, "GLP") & adm4!=-1
replace ins_post=1 if regexm(fourthadmrx, "insulin") & adm4!=-1
replace tzd_post=1 if regexm(fourthadmrx, "TZD") & adm4!=-1
replace oth_post=1 if regexm(fourthadmrx, "other") & adm4!=-1

mi stsplit adm5, at(0) after(fifthdate)
replace su_post=1 if regexm(fifthadmrx, "SU") & adm5!=-1
replace dpp4i_post= 1 if regexm(fifthadmrx, "DPP") & adm5!=-1
replace glp1ra_post=1 if regexm(fifthadmrx, "GLP") & adm5!=-1
replace ins_post=1 if regexm(fifthadmrx, "insulin") & adm5!=-1
replace tzd_post=1 if regexm(fifthadmrx, "TZD") & adm5!=-1
replace oth_post=1 if regexm(fifthadmrx, "other") & adm5!=-1

mi stsplit adm6, at(0) after(sixthdate)
replace su_post=1 if regexm(sixthadmrx, "SU") & adm6!=-1
replace dpp4i_post= 1 if regexm(sixthadmrx, "DPP") & adm6!=-1
replace glp1ra_post=1 if regexm(sixthadmrx, "GLP") & adm6!=-1
replace ins_post=1 if regexm(sixthadmrx, "insulin") & adm6!=-1
replace tzd_post=1 if regexm(sixthadmrx, "TZD") & adm6!=-1
replace oth_post=1 if regexm(sixthadmrx, "other") & adm6!=-1

mi stsplit adm7, at(0) after(seventhdate)
replace su_post=1 if regexm(seventhadmrx, "SU") & adm7!=-1
replace dpp4i_post= 1 if regexm(seventhadmrx, "DPP") & adm7!=-1
replace glp1ra_post=1 if regexm(seventhadmrx, "GLP") & adm7!=-1
replace ins_post=1 if regexm(seventhadmrx, "insulin") & adm7!=-1
replace tzd_post=1 if regexm(seventhadmrx, "TZD") & adm7!=-1
replace oth_post=1 if regexm(seventhadmrx, "other") & adm7!=-1

replace su_post=1 if regexm(secondadmrx, "SU")
replace dpp4i_post=1 if regexm(secondadmrx, "DPP")
replace glp1ra_post=1 if regexm(secondadmrx, "GLP")
replace ins_post=1 if regexm(secondadmrx, "insulin")
replace tzd_post=1 if regexm(secondadmrx, "TZD") 
replace oth_post=1 if regexm(secondadmrx, "other")

//split patient observations into individual rows at the end of every exposure: time-varying
mi stsplit stop0, at(0) after(exposuretf0)
replace su_post=0 if su_post==1 & stop0!=-1

mi stsplit stop1, at(0) after(exposuretf1)
replace dpp4i_post=0 if dpp4i_post==1 & stop1!=-1

mi stsplit stop2, at(0) after(exposuretf2)
replace glp1ra_post=0 if glp1ra_post==1 & stop2!=-1

mi stsplit stop3, at(0) after(exposuretf3)
replace ins_post=0 if ins_post==1 & stop3!=-1

mi stsplit stop4, at(0) after(exposuretf4)
replace tzd_post=0 if tzd_post==1 & stop4!=-1

mi stsplit stop5, at(0) after(exposuretf5)
replace oth_post=0 if oth_post==1 & stop5!=-1
}
save Stat_hf_mi_any, replace

//Generate person-years, incidence rate, and 95%CI as well as hazard ratio
mi xeq: stptime, by(indextype) title(person-years) per(1000)
mi estimate, hr: stcox i.indextype, cformat(%6.2f) pformat(%5.3f) sformat(%6.2f) 

timer off 1
log close Stat_hf
