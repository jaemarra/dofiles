//  program:    Stat_acm_diagnostics.do
//  task:		Statistical analysis for all-cause mortality
//  project: 	Incretins--Comparative mortality and CV outcomes (CPRD)
//  author:     JM \ June 2015  
//				

clear all
capture log close Stat_acm_diagnostics
set more off
log using Stat_diagnostics.smcl, name(Stat_acm_diagnostics) replace
timer on 1

capture ssc install table1
capture net install collin.pkg

use Analytic_Dataset_Master.dta, clear
quietly do Data13_variable_generation.do

//apply exclusion criteria
keep if exclude==0
//restrict to jan 1, 2007
drop if seconddate<17167

//Create macros
local demo = "age_indexdate gender ib2.prx_covvalue_g_i4 ib2.prx_covvalue_g_i5"
local demo2= "age_indexdate gender"
local comorb = "i.prx_ccivalue_g_i2 mi_i stroke_i hf_i arr_i ang_i revasc_i htn_i afib_i pvd_i"
local comorb2 ="i.prx_ccivalue_g_i2 hf_i arr_i ang_i revasc_i htn_i afib_i pvd_i"
local meds = "i.unique_cov_drugs dmdur metoverlap statin_i calchan_i betablock_i anticoag_oral_i antiplat_i ace_arb_renin_i diuretics_all_i post_*"
local meds2 = "i.unique_cov_drugs dmdur metoverlap statin_i calchan_i betablock_i anticoag_oral_i antiplat_i ace_arb_renin_i diuretics_all_i"
local meds3 = "i.unique_cov_drugs dmdur statin_i calchan_i betablock_i anticoag_oral_i antiplat_i ace_arb_renin_i diuretics_all_i"
local clin = "ib1.hba1c_cats_i2 ib1.sbp_i_cats2 i.ckd_amdrd i.physician_vis2 ib1.bmi_i_cats"
local clin2 = "ib1.hba1c_cats_i2 i.ckd_amdrd"
local clin3 = "i.ckd_amdrd"
local covariate = "`demo' `comorb' `meds' `clin'"
local mvmodel = "age_indexdate gender dmdur metoverlap ib2.prx_covvalue_g_i4 ib1.hba1c_cats_i2 i.ckd_amdrd i.unique_cov_drugs i.prx_ccivalue_g_i2 cvd_i statin_i calchan_i betablock_i anticoag_oral_i antiplat_i ace_arb_renin_i diuretics_all_i su_post dpp4i_post glp1ra_post ins_post tzd_post bmi_i sbp i.physician_vis2"
local matrownames "SU DPP4I GLP1RA INS TZD OTH Age Male diabetes_duration Metformin_overlap Unknown Current Non_Smoker Former Unknown HbA1c_<7 HbA1c_7_8 HbA1c_8_9 HbA1c_9_10 HbA1c_>10 HbA1c_unknown eGFR_90+ eGFR_60_89 eGFR_30_59 eGFR_15_29 eGFR_<15 eGFR_unknown No_unique_drugs_0_5 No_unique_drugs_6_10 No_unique_drugs_>10 CCI=1 CCI=2 CCI=3+ CVD Statin CCB BB Anticoag Antiplat RAS Diuretics su_post dpp4i_post glp1ra_post ins_post tzd_post BMI SBP PhysVis_12 PhysVis_24 PhysVis_24plus"
local mvmodel_mi = "age_indexdate gender dmdur metoverlap i.ckd_amdrd i.unique_cov_drugs i.prx_ccivalue_g_i2 cvd_i statin_i calchan_i betablock_i anticoag_oral_i antiplat_i ace_arb_renin_i diuretics_all_i su_post dpp4i_post glp1ra_post ins_post tzd_post oth_post bmi_i sbp ib1.hba1c_cats_i2_clone ib2.prx_covvalue_g_i4_clone i.physician_vis2"
local matrownames_mi "SU DPP4I GLP1RA INS TZD OTH Age Male diabetes_duration Metformin_overlap eGFR_90+ eGFR_60_89 eGFR_30_59 eGFR_15_29 eGFR_<15 eGFR_unknown No_unique_drugs_0_5 No_unique_drugs_6_10 No_unique_drugs_11_15 No_unique_drugs_16_20 No_unique_drugs_>20 CCI=1 CCI=2 CCI=3+ CVD Statin CCB BB Anticoag Antiplat RAS Diuretics su_post dpp4i_post glp1ra_post ins_post tzd_post oth_post BMI SBP HbA1c_<7 HbA1c_7_8 HbA1c_8_9 HbA1c_9_10 HbA1c_>10 HbA1c_unknown Unknown Current Non_Smoker Former PhysVis_12 PhysVis_24 PhysVis_24plus"
local mvmodel_nofac = "age_indexdate gender prx_covvalue_g_i4 hba1c_cats_i2 prx_ccivalue_g_i2"
	
*******************************************************COX PROPORTIONAL HAZARDS REGRESSION*******************************************************
// update censor times for final exposure to second-line agent (indextype)
foreach x in 
forval i=0/5 {
	replace acm_exit = exposuretf`i' if indextype==`i' & exposuretf`i'!=.
}

replace acm=0 if acm_exit<death_date

// declare survival analysis - final exposure as last exposure date 
stset acm_exit, fail(acm) id(patid) origin(seconddate) scale(365.25)

//COMPLETE CASE ANALYSIS
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

//CRUDE RATES
tab indextype acm, row
//Generate person-years, incidence rate, and 95%CI as well as hazard ratio
label var indextype "Exposure"
stptime, by(indextype) per(1000)
**********************************************************MODEL DIAGNOSTICS SECTION*********************************************
**********************************************************Tesing the PH Assumption*************************************************
//generate the log log plot for PH assumption 
stphplot, by(indextype) saving(lnlnplot, replace)
graph export lnlnplot.pdf, replace

//non-zero slope for time-dependent covariates
stcox indextype_2 indextype_3 indextype_4 indextype_5 indextype_6 `mvmodel', cformat(%6.2f) pformat(%5.3f) sformat(%6.2f)  nolog noshow
estat phtest, rank detail
stcox i.indextype `mvmodel', schoenfeld(sch*) scaledsch(sca*)
stphtest, detail
***********************************************************Testing collinearity******************************************************
collin indextype_2 indextype_3 indextype_4 indextype_5 indextype_6 age_indexdate gender dmdur metoverlap bmicat1 bmicat3 bmicat4 bmicat5 bmicat6 bmicat7 smokestatus1 smokestatus2 smokestatus4 drinkstatus1 drinkstatus2 drinkstatus4 a1ccat1 a1ccat3 a1ccat4 a1ccat5 a1ccat6 sbpcat1 sbpcat3 sbpcat4 sbpcat5 sbpcat6 sbpcat7 ckdcat2 ckdcat3 ckdcat4 ckdcat5 ckdcat6 mdvisits2 mdvisits3 ndrugs2 ndrugs3 cci2 cci3 mi_i stroke_i hf_i arr_i ang_i revasc_i htn_i afib_i pvd_i statin_i calchan_i betablock_i anticoag_oral_i antiplat_i ace_arb_renin_i diuretics_all_i *_post
************************************************************Goodness of Fit Tests*************************************************
stcox i.indextype `mvmodel', cformat(%6.2f) pformat(%5.3f) sformat(%6.2f) efron nolog noshow estimate
//cox-snell cumulative hazard slope should ~=1
predict cs, csnell
stset cs, fail(acm) 
sts gen H=na
line H cs cs, sort ytitle("Goodness of Fit") legend(cols(1))
**********************************************************Concordance*************************************************
quietely stcox indextype_2 indextype_3 indextype_4 indextype_5 indextype_6 `mvmodel', cformat(%6.2f) pformat(%5.3f) sformat(%6.2f) efron nolog noshow estimate
estat concordance

**********************************************************Functional Form Tests*************************************************
stcox i.indextype `mvmodel', cformat(%6.2f) pformat(%5.3f) sformat(%6.2f) efron nolog noshow estimate
predict mg, mgale
lowess mg `age_indexdate' //can repeat this for any non-factor variable you like
linktest, efron nolog estimate
**********************************************************Influential Outliers Tests*************************************************
stcox i.indextype `mvmodel', cformat(%6.2f) pformat(%5.3f) sformat(%6.2f)
predict dfb
scatter dfb _t, yline(0) mlabel(patid) msymbol(i)

stcox i.indextype `mvmodel', cformat(%6.2f) pformat(%5.3f) sformat(%6.2f) efron nolog noshow estimate
predict ld, ldisplace
scatter ld _t, yline(0) mlabel(patid) msymbol(i)

stcox i.indextype `mvmodel', cformat(%6.2f) pformat(%5.3f) sformat(%6.2f) efron nolog noshow estimate
predict lm, lmax
scatter lm _t, yline(0) mlabel(patid) msymbol(i)

timer off 1
log close Stat_acm_diagnostics
