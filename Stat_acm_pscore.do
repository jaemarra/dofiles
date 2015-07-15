//  program:    Stat_acm_pscore.do
//  task:		Propensity score analysis for all-cause mortality
//  project: 	Incretins--Comparative mortality and CV outcomes (CPRD)
//  author:     JM \ June 2015  
//				

clear all
capture log close stat_acm_ps
set more off
log using Stat_acm_ps.smcl, name(stat_acm_ps) replace
timer on 1

capture ssc install psmatch2
capture ssc install psmatch
capture net install pscore

use Analytic_Dataset_Master.dta, clear
quietly do Data13_variable_generation.do

//apply exclusion criteria
keep if exclude==0
//restrict to jan 1, 2007
drop if seconddate<17167

//Create macros
tab ckd_amdrd, gen(ckd_dum)
tab unique_cov_drugs, gen(unq_dum)
tab prx_ccivalue_g_i2, gen(cci_dum)
tab hba1c_cats_i2, gen(a1c_dum)
tab prx_covvalue_g_i4, gen(smk_dum)
tab physician_vis2, gen(vis_dum)

local mvmodel_ps = "dmdur metoverlap ckd_dum* unq_dum* cci_dum* a1c_dum* smk_dum* vis_dum* cvd_i statin_i calchan_i betablock_i anticoag_oral_i antiplat_i ace_arb_renin_i diuretics_all_i bmi_i sbp"
// update censor times for final exposure to second-line agent (indextype)
forval i=0/5 {
	replace acm_exit = exposuretf`i' if indextype==`i' & exposuretf`i'!=.
}

replace acm=0 if acm_exit<death_date

// declare survival analysis - final exposure as last exposure date 
stset acm_exit, fail(acm) id(patid) origin(seconddate) scale(365.25)

//put data in mlong form such that complete rows are omitted and only incomplete and imputed rows are shown
mi set mlong
save acm_mlong, replace
clonevar hba1c_cats_i2_clone = hba1c_cats_i2
replace hba1c_cats_i2_clone=. if hba1c_cats_i2==5
clonevar prx_covvalue_g_i4_clone = prx_covvalue_g_i4
replace prx_covvalue_g_i4_clone=. if prx_covvalue_g_i4==0
//inform mi which variables contain missing values for which we want to timpute (bmi_i and sbp)
mi register imputed bmi_i sbp prx_covvalue_g_i4_clone hba1c_cats_i2_clone
//describe and learn about the missing values in the data
mi describe 
mi misstable summarize
mi misstable nested
//set the seed so that results are reproducible
set seed 1979
//impute (20 iterations) for each missing value in the registered variables
mi impute chained (regress) bmi_i sbp (mlogit) prx_covvalue_g_i4_clone hba1c_cats_i2_clone = acm `demo2' `comorb2' `meds3' `clin3', add(20)
//verify that all missing values are filled in
mi describe
//look at summary statistics in each of the imputation datasets
mi xeq: summarize
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
save Stat_acm_mi_pscore, replace

gen trt =.
replace trt=0 if indextype==0
replace trt=1 if indextype==1
//generate a PS
pscore trt `mvmodel_ps', pscore(ps_single) blockid(ps_block) detail
//generate a cstat
_pctile ps_single, p(10(10)90)
return list
gen decile = 10 if ps_single < .
qui forval i = 9(-1)1 {
         replace decile = `i' if ps_single <= r(r`i')
 }
tabstat ps_single, by(decile) s(n sum mean)
//twoway overlay graph of kernel density or histogram 
kdensity ps_single if trt==0, nograph gen(x ps_0)
kdensity ps_single if trt==1, nograph gen(x2 ps_1)
label var ps_1 "Treated with DPP4i"
label var ps_0 "Not treated with DPP4i"
line ps_0 ps_1 x
//trim non-overlapping by nearest neighbor matching (always and never treated are removed but not applicable in cohort)
qui psmatch2 trt, outcome(acm) pscore(ps_single) neighbor(1)
//Check to make sure PS are balanced
psgraph, treated(trt) pscore(ps_single)
//Evaluate standardized differences in matched sample
pstest `mvmodel_ps', treated(trt) both
//Graph standardized differences in matched sample
pstest `mvmodel_ps', treated(trt) both graph
//Now you can adjust by deciles of the PS in a multivariable model
//Fit the model separately on each of the 20 imputed datasets and combine results
mi estimate, hr: stcox i.indextype ib5.decile age_indexdate gender
mi estimate, hr: stcox trt ib5.decile age_indexdate gender

timer off 1
log close stat_acm_ps
