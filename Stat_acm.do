//  program:    Stat_acm.do
//  task:		Statistical analysis for all-cause mortality
//  project: 	Incretins--Comparative mortality and CV outcomes (CPRD)
//  author:     JM \ April 2015  
//				

clear all
capture log close stat_acm
set more off
log using Stat_acm.smcl, name(stat_acm) replace
timer on 1

use Analytic_Dataset_Master
quietly do Data13_variable_generation.do

//Numbers for flow diagrams
tab firstadmrx
tab gest_diab
tab pcos
tab preg
count if age_indexdate<30
tab cohort_b
count if tx<=seconddate
count if seconddate<17167
count if seconddate>=17167 & cohort_b==1 & exclude==0
//apply exclusion criteria
keep if exclude==0
//restrict to jan 1, 2007
drop if seconddate<17167

//Create macros
local demo = "age_indexdate gender ib2.prx_covvalue_g_i4 ib2.prx_covvalue_g_i5"
local comorb = "i.prx_ccivalue_g_i2 mi_i stroke_i hf_i arr_i ang_i revasc_i htn_i afib_i pvd_i"
local meds = "i.unique_cov_drugs dmdur metoverlap statin_i calchan_i betablock_i anticoag_oral_i antiplat_i ace_arb_renin_i diuretics_all_i post_*"
local meds2 = "i.unique_cov_drugs dmdur metoverlap statin_i calchan_i betablock_i anticoag_oral_i antiplat_i ace_arb_renin_i diuretics_all_i"
local meds3 = "i.unique_cov_drugs dmdur statin_i calchan_i betablock_i anticoag_oral_i antiplat_i ace_arb_renin_i diuretics_all_i"
local clin = "ib1.hba1c_cats_i2 ib1.sbp_i_cats2 i.ckd_amdrd i.physician_vis2 ib1.bmi_i_cats"
local clin2 = "ib1.hba1c_cats_i2 i.ckd_amdrd"
local covariate = "`demo' `comorb' `meds' `clin'"
local mvmodel = "age_indexdate gender dmdur metoverlap ib2.prx_covvalue_g_i4 ib2.prx_covvalue_g_i5 ib1.bmi_i_cats ib1.hba1c_cats_i2 ib1.sbp_i_cats2 i.ckd_amdrd i.physician_vis2 i.unique_cov_drugs i.prx_ccivalue_g_i2 mi_i stroke_i hf_i arr_i ang_i revasc_i htn_i afib_i pvd_i statin_i calchan_i betablock_i anticoag_oral_i antiplat_i ace_arb_renin_i diuretics_all_i *_post"

//Create table1 
table1, by(indextype) vars(age_indexdate contn \ age_cat cat \ gender cat \ imd2010_5 cat \ dmdur contn \ metoverlap contn \ prx_covvalue_g_i4 cat \ prx_covvalue_g_i5 cat \ bmi_i_cats cat \ physician_vis2 cat \ ang_i bin \ arr_i bin \ afib_i bin \ hf_i bin \ htn_i bin \ mi_i bin \ pvd_i bin \ stroke_i bin \ revasc_i bin \ prx_ccivalue_g_i2 cat \ hba1c_i contn \ hba1c_cats_i cat \ prx_covvalue_g_i3 contn \ sbp_i_cats2 cat \ egfr_amdrd contn \ ckd_amdrd cat \ unique_cov_drugs cat \ unqrx2 cat \ statin_i bin \ calchan_i bin \ betablock_i bin \ anticoag_oral_i bin \ antiplat_i bin \ ace_arb_renin_i bin \ diuretics_all_i bin) onecol format(%9.2g) saving(table1.xls, replace)
table1 if linked_b==1, by(indextype) vars(age_indexdate contn \ age_cat cat \ gender cat \ imd2010_5 cat \ dmdur contn \ metoverlap contn \ prx_covvalue_g_i4 cat \ prx_covvalue_g_i5 cat \ bmi_i_cats cat \ physician_vis2 cat \ ang_i bin \ arr_i bin \ afib_i bin \ hf_i bin \ htn_i bin \ mi_i bin \ pvd_i bin \ stroke_i bin \ revasc_i bin \ prx_ccivalue_g_i2 cat \ hba1c_i contn \ hba1c_cats_i cat \ prx_covvalue_g_i3 contn \ sbp_i_cats2 cat \ egfr_amdrd contn \ ckd_amdrd cat \ unique_cov_drugs cat \ unqrx2 cat \ statin_i bin \ calchan_i bin \ betablock_i bin \ anticoag_oral_i bin \ antiplat_i bin \ ace_arb_renin_i bin \ diuretics_all_i bin) onecol format(%9.2g) saving(table1_linked.xls, replace)

// 2x2 tables with exposure and outcome (death)
label var indextype "2nd-line Agent"
tab indextype acm, row

label var indextype3 "3rd-line Agent"
tab indextype3 acm, row

label var indextype4 "4th-line Agent"
tab indextype4 acm, row
tab indextype5 acm, row
tab indextype6 acm, row
tab indextype7 acm, row

// 2x2 tables with exposure and death, by baseline covariates
foreach var of varlist gender dmdur_cat prx_covvalue_g_i4 prx_covvalue_g_i5 bmi_i_cats hba1c_cats_i2 sbp_i_cats2 ///
	ckd_amdrd physician_vis2 unique_cov_drugs prx_ccivalue_g_i2 mi_i stroke_i hf_i arr_i ang_i revasc_i ///
	htn_i afib_i pvd_i statin_i calchan_i betablock_i anticoag_oral_i antiplat_i ace_arb_renin_i ///
	diuretics_all_i {

table indextype `var', contents(n acm mean acm) format(%6.2f) center col
	}
	
***COX PROPORTIONAL HAZARDS REGRESSION***
// update censor times for final exposure to second-line agent (indextype)
forval i=0/5 {
	replace acm_exit = exposuretf`i' if indextype==`i' & exposuretf`i'!=.
}

// declare survival analysis - final exposure as last exposure date 
stset acm_exit, fail(allcausemort) id(patid) origin(seconddate) scale(365.25)

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

//Generate person-years, incidence rate, and 95%CI as well as hazard ratio
label var indextype "Exposure"
stptime, by(indextype) per(1000)
stcox i.indextype, cformat(%6.2f) pformat(%5.3f) sformat(%6.2f) 
stcox indextype_2 indextype_3 indextype_4 indextype_5 indextype_6, cformat(%6.2f) pformat(%5.3f) sformat(%6.2f) 
 
stptime, title(person-years) per(1000)
putexcel A1= ("Indextype") B1=("Person-Time") C1=("Failures") D1=("Incidence Rate") E1=("Lower Bound") F1=("Upper Bound") G1=("Hazard Ratio") H1=("Lower Bound") I1=("Upper Bound") using table2, sheet("Unadjusted") modify
forval i=0/5{
local row=`i'+2
stptime if indextype==`i'
putexcel A`row'= ("`i'") B`row'=(r(ptime)) C`row'=(r(failures)) D`row'=(r(rate)*1000) E`row'=(r(lb)*1000) F`row'=(r(ub)*1000) using table2, sheet("Unadjusted") modify
}
forval i=1/5 {
local row=`i'+2
local matrow=`i'+1
stcox i.indextype 
matrix b=r(table)
matrix a= b'
putexcel G`row'=(a[`matrow',1]) H`row'=(a[`matrow',5]) I`row'=(a[`matrow',6]) using table2, sheet("Unadjusted") modify
}

//Multivariable analysis 
// note: missing indicator approach used
stcox i.indextype age_index gender dmdur, cformat(%6.2f) pformat(%5.3f) sformat(%6.2f) 
stcox i.indextype age_indexdate gender dmdur metoverlap ib1.hba1c_cats_i2 ib1.sbp_i_cats2 i.ckd_amdrd i.physician_vis2 i.unique_cov_drugs, cformat(%6.2f) pformat(%5.3f) sformat(%6.2f)  
stcox i.indextype `covariate', cformat(%6.2f) pformat(%5.3f) sformat(%6.2f)  
stcox indextype_2 indextype_3 indextype_4 indextype_5 indextype_6 `covariate', cformat(%6.2f) pformat(%5.3f) sformat(%6.2f)  
stcox indextype_2 indextype_3 indextype_4 indextype_5 indextype_6 `covariate', cformat(%6.2f) pformat(%5.3f) sformat(%6.2f)  

// change reference groups
stcox ib2.indextype `covariate', cformat(%6.2f) pformat(%5.3f) sformat(%6.2f)  
stcox ib3.indextype `covariate', cformat(%6.2f) pformat(%5.3f) sformat(%6.2f)  
stcox ib4.indextype `covariate', cformat(%6.2f) pformat(%5.3f) sformat(%6.2f)  
stcox i.indextype `mvmodel', cformat(%6.2f) pformat(%5.3f) sformat(%6.2f)  
matrix b=r(table)
matrix c=b'
matrix list c
local matrownames "SU DPP4I GLP1RA INS TZD OTH Age Male diabetes_duration Metformin_overlap Unknown Current Non_Smoker Former Unknown Current Non_Drinker Former BMI_<20 BMI_20_24 BMI_25_29 BMI_30_34 BMI_35_40 BMI_40+ Unknown HbA1c_<7 HbA1c_7_8 HbA1c_8_9 HbA1c_9_10 HbA1c_>10 HbA1c_unknown SBP_<120 SBP_120_129 SBP_130_139  SBP_140_149 SBP_150_159 SBP_160+ SBP_missing eGFR_90+ eGFR_60_89 eGFR_30_59 eGFR_15_29 eGFR_<15 eGFR_unknown Physician_visits_0_12 Physician_visits_13_24 Physician_visits_24+ Physician_visits_unknown No_unique_drugs_0_5 No_unique_drugs_6_10 No_unique_drugs_11_15 No_unique_drugs_16_20 No_unique_drugs_>20 CCI=1 CCI=2 CCI=3+ MI Stroke HF Arrythmia Angina Revascularization HTN AFIB PVD Statin CCB BB Anticoag Antiplat RAS Diuretics su_post dpp4i_post glp1ra_post ins_post tzd_post oth_post"
forval i=1/79{
local x=`i'+1
local rowname:word `i' of `matrownames'
putexcel A1=("Variable") B1=("HR") C1=("SE") D1=("p-value") E1=("LL") F1=("UL") A`x'=("`rowname'") B`x'=(c[`i',1]) C`x'=(c[`i',2]) D`x'=(c[`i',4]) E`x'=(c[`i',5]) F`x'=(c[`i',6])using table2, sheet("Adjusted") modify
}

// Multiple imputation
//put data in mlong form such that complete rows are omitted and only incomplete and imputed rows are shown
mi set mlong
save acm_mlong, replace
//inform mi which variables contain missing values for which we want to timpute (bmi_i and sbp)
mi register imputed bmi_i sbp
//describe and learn about the missing values in the data
mi describe 
mi misstable summarize
mi misstable nested
//set the seed so that results are reproducible
set seed 1979
//impute (10 iterations) for each missing value in the registered variables
mi impute mvn bmi_i sbp = acm `demo' `comorb' `meds3' `clin2', add(20) by(indextype)
//verify that all missing values are filled in
mi describe
//look at summary statistics in each of the imputation datasets
mi xeq: summarize
//fit the model separately on each of the 10 imputed datasets and combine results
mi estimate, hr: stcox i.indextype `covariate' bmi_i sbp
mi describe

//KM and survival curves
sts graph, by(indextype) saving(kmplot, replace) 
graph export kmplot.pdf, replace

stcurve, survival at1(indextype=0) at2(indextype=1) at3(indextype=2) at4(indextype=3) at5(indextype=4) at6(indextype=5) saving(survplot, replace) 
graph export survplot.pdf, replace

//Testing PH Assumption
stphplot, by(indextype) saving(lnlnplot, replace)
graph export lnlnplot.pdf, replace

stcox indextype_2 indextype_3 indextype_4 indextype_5 indextype_6 `covariate', cformat(%6.2f) pformat(%5.3f) sformat(%6.2f)  nolog noshow
estat phtest, rank detail

stcox i.indextype `covariate', schoenfeld(sch*) scaledsch(sca*)
stphtest, detail
//repeat this test for each variable of interest
 stphtest, plot(age_indexdate) msym(oh)

// Testing collinearity

collin indextype_2 indextype_3 indextype_4 indextype_5 indextype_6 age_indexdate gender dmdur metoverlap bmicat1 bmicat3 bmicat4 bmicat5 bmicat6 bmicat7 smokestatus1 smokestatus2 smokestatus4 drinkstatus1 drinkstatus2 drinkstatus4 a1ccat1 a1ccat3 a1ccat4 a1ccat5 a1ccat6 sbpcat1 sbpcat3 sbpcat4 sbpcat5 sbpcat6 sbpcat7 ckdcat2 ckdcat3 ckdcat4 ckdcat5 ckdcat6 mdvisits2 mdvisits3 mdvisits4 ndrugs2 ndrugs3 ndrugs4 ndrugs5 cci2 cci3 mi_i stroke_i hf_i arr_i ang_i revasc_i htn_i afib_i pvd_i statin_i calchan_i betablock_i anticoag_oral_i antiplat_i ace_arb_renin_i diuretics_all_i *_post

***SUBGROUP ANALYSIS / EFFECT MODIFIERS***
//ipdover, over(age_65) over(indextype_1) hr forest(nonull nooverall boxscale(0) xlabel(0.2(0.5)2, force)) : lincom 1.indextype + 1.indextype#0.age_65

//AGE- Generate the linear combination hr and ci (DPP and GLP only)
//Unadjusted
stcox i.indextype if age_65==0, cformat(%6.2f) pformat(%5.3f) sformat(%6.2f) nolog noshow
stcox i.indextype if age_65==1, cformat(%6.2f) pformat(%5.3f) sformat(%6.2f) nolog noshow
stcox i.indextype##i.age_65, cformat(%6.2f) pformat(%5.3f) sformat(%6.2f) nolog noshow
lincom 1.indextype+1.indextype#0.age_65, hr
lincom 1.indextype + 1.indextype#1.age_65, hr
lincom 2.indextype+2.indextype#0.age_65, hr
lincom 2.indextype + 2.indextype#1.age_65, hr
//Adjusted
stcox i.indextype `covariate' if age_65==0, cformat(%6.2f) pformat(%5.3f) sformat(%6.2f)  
stcox i.indextype `covariate' if age_65==1, cformat(%6.2f) pformat(%5.3f) sformat(%6.2f)  
stcox i.indextype##i.age_65 `covariate', cformat(%6.2f) pformat(%5.3f) sformat(%6.2f)  
lincom 1.indextype + 1.indextype#0.age_65, hr
lincom 1.indextype + 1.indextype#1.age_65, hr
lincom 2.indextype + 2.indextype#0.age_65, hr
lincom 2.indextype + 2.indextype#1.age_65, hr

//GENDER- Generate the linear combination hr and ci (DPP and GLP only
//Unadjusted
stcox i.indextype if gender==0, cformat(%6.2f) pformat(%5.3f) sformat(%6.2f) nolog noshow
stcox i.indextype if gender==1, cformat(%6.2f) pformat(%5.3f) sformat(%6.2f) nolog noshow
stcox i.indextype##i.gender, cformat(%6.2f) pformat(%5.3f) sformat(%6.2f) nolog noshow
lincom 1.indextype+1.indextype#0.gender, hr
lincom 1.indextype + 1.indextype#1.gender, hr
lincom 2.indextype+2.indextype#0.gender, hr
lincom 2.indextype + 2.indextype#1.gender, hr
//Adjusted
stcox i.indextype `covariate' if gender==0, cformat(%6.2f) pformat(%5.3f) sformat(%6.2f)  
stcox i.indextype `covariate' if gender==1, cformat(%6.2f) pformat(%5.3f) sformat(%6.2f)  
stcox i.indextype##i.gender `covariate', cformat(%6.2f) pformat(%5.3f) sformat(%6.2f)  
lincom 1.indextype+1.indextype#0.gender, hr
lincom 1.indextype + 1.indextype#1.gender, hr
lincom 2.indextype+2.indextype#0.gender, hr
lincom 2.indextype + 2.indextype#1.gender, hr

// Duration of Metformin Monotherapy- Generate the linear combination hr and ci (DPP and GLP only)
//Unadjusted
stcox i.indextype if dmdur_2==0, cformat(%6.2f) pformat(%5.3f) sformat(%6.2f) nolog noshow
stcox i.indextype if dmdur_2==1, cformat(%6.2f) pformat(%5.3f) sformat(%6.2f) nolog noshow
stcox i.indextype##i.dmdur_2, cformat(%6.2f) pformat(%5.3f) sformat(%6.2f) nolog noshow
lincom 1.indextype+1.indextype#0.dmdur_2, hr
lincom 1.indextype + 1.indextype#1.dmdur_2, hr
lincom 2.indextype+2.indextype#0.dmdur_2, hr
lincom 2.indextype + 2.indextype#1.dmdur_2, hr
//Adjusted 
stcox i.indextype `covariate' if dmdur_2==0, cformat(%6.2f) pformat(%5.3f) sformat(%6.2f) nolog noshow
stcox i.indextype `covariate' if dmdur_2==1, cformat(%6.2f) pformat(%5.3f) sformat(%6.2f) nolog noshow
stcox i.indextype##i.dmdur_2 `covariate', cformat(%6.2f) pformat(%5.3f) sformat(%6.2f) 
lincom 1.indextype+1.indextype#0.dmdur_2, hr
lincom 1.indextype + 1.indextype#1.dmdur_2, hr
lincom 2.indextype+2.indextype#0.dmdur_2, hr
lincom 2.indextype + 2.indextype#1.dmdur_2, hr

// HbA1c- Generate the linear combination hr and ci (DPP and GLP only)
//Unadjusted
stcox i.indextype if hba1c_8==0, cformat(%6.2f) pformat(%5.3f) sformat(%6.2f) nolog noshow
stcox i.indextype if hba1c_8==1, cformat(%6.2f) pformat(%5.3f) sformat(%6.2f) nolog noshow
stcox i.indextype##i.hba1c_8, cformat(%6.2f) pformat(%5.3f) sformat(%6.2f) nolog noshow
lincom 1.indextype+1.indextype#0.hba1c_8, hr
lincom 1.indextype + 1.indextype#1.hba1c_8, hr
lincom 2.indextype+2.indextype#0.hba1c_8, hr
lincom 2.indextype + 2.indextype#1.hba1c_8, hr
//Adjusted
stcox i.indextype `covariate' if hba1c_8==0, cformat(%6.2f) pformat(%5.3f) sformat(%6.2f)  
stcox i.indextype `covariate' if hba1c_8==1, cformat(%6.2f) pformat(%5.3f) sformat(%6.2f)  
stcox i.indextype##i.hba1c_8 `covariate', cformat(%6.2f) pformat(%5.3f) sformat(%6.2f)  
lincom 1.indextype+1.indextype#0.hba1c_8, hr
lincom 1.indextype + 1.indextype#1.hba1c_8, hr
lincom 2.indextype+2.indextype#0.hba1c_8, hr
lincom 2.indextype + 2.indextype#1.hba1c_8, hr

// BMI- Generate the linear combination hr and ci (DPP and GLP only)
//Unadjusted
stcox i.indextype if bmi_30==0, cformat(%6.2f) pformat(%5.3f) sformat(%6.2f) nolog noshow
stcox i.indextype if bmi_30==1, cformat(%6.2f) pformat(%5.3f) sformat(%6.2f) nolog noshow
stcox i.indextype##i.bmi_30, cformat(%6.2f) pformat(%5.3f) sformat(%6.2f) nolog noshow
lincom 1.indextype+1.indextype#0.bmi_30, hr
lincom 1.indextype + 1.indextype#1.bmi_30, hr
lincom 2.indextype+2.indextype#0.bmi_30, hr
lincom 2.indextype + 2.indextype#1.bmi_30, hr
//Adjusted
stcox i.indextype `covariate' if bmi_30==0, cformat(%6.2f) pformat(%5.3f) sformat(%6.2f)  
stcox i.indextype `covariate' if bmi_30==1, cformat(%6.2f) pformat(%5.3f) sformat(%6.2f)  
stcox i.indextype##i.bmi_30 `covariate', cformat(%6.2f) pformat(%5.3f) sformat(%6.2f)  
lincom 1.indextype+1.indextype#0.bmi_30, hr
lincom 1.indextype + 1.indextype#1.bmi_30, hr
lincom 2.indextype+2.indextype#0.bmi_30, hr
lincom 2.indextype + 2.indextype#1.bmi_30, hr

// IMD
* too many missing values in CPRD cohort

// renal impairment- Generate the linear combination hr and ci (DPP and GLP only
//Unadjusted
stcox i.indextype if ckd_60==0, cformat(%6.2f) pformat(%5.3f) sformat(%6.2f) nolog noshow
stcox i.indextype if ckd_60==1, cformat(%6.2f) pformat(%5.3f) sformat(%6.2f) nolog noshow
stcox i.indextype##i.ckd_60, cformat(%6.2f) pformat(%5.3f) sformat(%6.2f) nolog noshow
lincom 1.indextype+1.indextype#0.ckd_60, hr
lincom 1.indextype + 1.indextype#1.ckd_60, hr
lincom 2.indextype+2.indextype#0.ckd_60, hr
lincom 2.indextype + 2.indextype#1.ckd_60, hr
//Adjusted
stcox i.indextype `covariate' if ckd_60==0, cformat(%6.2f) pformat(%5.3f) sformat(%6.2f)  
stcox i.indextype `covariate' if ckd_60==1, cformat(%6.2f) pformat(%5.3f) sformat(%6.2f)  
stcox i.indextype##i.ckd_60 `covariate', cformat(%6.2f) pformat(%5.3f) sformat(%6.2f)  
lincom 1.indextype+1.indextype#0.ckd_60, hr
lincom 1.indextype + 1.indextype#1.ckd_60, hr
lincom 2.indextype+2.indextype#0.ckd_60, hr
lincom 2.indextype + 2.indextype#1.ckd_60, hr

// heart failure- Generate the linear combination hr and ci (DPP and GLP only)
//Unadjusted
stcox i.indextype if hf_i==0, cformat(%6.2f) pformat(%5.3f) sformat(%6.2f) nolog noshow
stcox i.indextype if hf_i==1, cformat(%6.2f) pformat(%5.3f) sformat(%6.2f) nolog noshow
stcox i.indextype##i.hf_i, cformat(%6.2f) pformat(%5.3f) sformat(%6.2f) nolog noshow
lincom 1.indextype+1.indextype#0.hf_i, hr
lincom 1.indextype + 1.indextype#1.hf_i, hr
lincom 2.indextype+2.indextype#0.hf_i, hr
lincom 2.indextype + 2.indextype#1.hf_i, hr
//Adjusted
stcox i.indextype `covariate' if hf_i==0, cformat(%6.2f) pformat(%5.3f) sformat(%6.2f)  
stcox i.indextype `covariate' if hf_i==1, cformat(%6.2f) pformat(%5.3f) sformat(%6.2f)  
stcox i.indextype##i.hf_i `covariate', cformat(%6.2f) pformat(%5.3f) sformat(%6.2f)  
lincom 1.indextype+1.indextype#0.hf_i, hr
lincom 1.indextype + 1.indextype#1.hf_i, hr
lincom 2.indextype+2.indextype#0.hf_i, hr
lincom 2.indextype + 2.indextype#1.hf_i, hr

//prior mi or stroke- Generate the linear combination hr and ci (DPP and GLP only)
//Unadjusted
stcox i.indextype if mi_stroke==0, cformat(%6.2f) pformat(%5.3f) sformat(%6.2f) nolog noshow
stcox i.indextype if mi_stroke==1, cformat(%6.2f) pformat(%5.3f) sformat(%6.2f) nolog noshow
stcox i.indextype##i.mi_stroke, cformat(%6.2f) pformat(%5.3f) sformat(%6.2f) nolog noshow
lincom 1.indextype+1.indextype#0.mi_stroke, hr
lincom 1.indextype + 1.indextype#1.mi_stroke, hr
lincom 2.indextype+2.indextype#0.mi_stroke, hr
lincom 2.indextype + 2.indextype#1.mi_stroke, hr
//Adjusted
stcox i.indextype `covariate' if mi_stroke==0, cformat(%6.2f) pformat(%5.3f) sformat(%6.2f) nolog noshow
stcox i.indextype `covariate' if mi_stroke==1, cformat(%6.2f) pformat(%5.3f) sformat(%6.2f) nolog noshow
stcox i.indextype##i.mi_stroke `covariate', cformat(%6.2f) pformat(%5.3f) sformat(%6.2f)  
lincom 1.indextype+1.indextype#0.mi_stroke, hr
lincom 1.indextype + 1.indextype#1.mi_stroke, hr
lincom 2.indextype+2.indextype#0.mi_stroke, hr
lincom 2.indextype + 2.indextype#1.mi_stroke, hr

//Label variables for subgroup graphs
label define subgroups 1 "Age" 2 "Gender" 3 "Duration of metformin monotherapy" 4 "HbA1c" 5 "BMI" 6 "Renal insufficiency" 7 "History of HF" 8 "History of MI/stroke"
label values subgroup subgroups
label define subvals 0 "Less than 65" 1 "65 or older" 2 "Female" 3 "Male" 4 "Less than 2 years" 5 "2 or more years" 6 "Less than 8" 7 "8 or greater" 8 "Less than 30" 9 "30 or greater" 10 "EGFR 60 or greater" 11 "EGFR less than 60" 12 "Negative history" 13 "Positive history"
label values subval subvals
rename subval Subgroup
//Generate Forest Plots
metan hr ll ul if adj==0 & trt==1, force by(subgroup) nowt nobox nooverall nosubgroup lcols(Subgroup) effect("Hazard Ratio") title(Unadjusted Cox Model Subgroup Analysis for Index Exposure to DPP4i, size(small))
metan hr ll ul if adj==1 & trt==1, force by(subgroup) nowt nobox nooverall nosubgroup lcols(Subgroup) effect("Hazard Ratio") title(Adjusted Cox Model Subgroup Analysis for Index Exposure to DPP4i, size(small))
metan hr ll ul if adj==0 & trt==2, force by(subgroup) nowt nobox nooverall nosubgroup lcols(Subgroup) effect("Hazard Ratio") title(Unadjusted Cox Model Subgroup Analysis for Index Exposure to GLP1RA, size(small))
metan hr ll ul if adj==1 & trt==2, force by(subgroup) nowt nobox nooverall nosubgroup lcols(Subgroup) effect("Hazard Ratio") title(Adjusted Cox Model Subgroup Analysis for Index Exposure to GLP1RA, size(small))

***SENSITIVITY ANALYSIS***

// #1. CENSOR EXPSOURE AT FIRST GAP
use Analytic_Dataset_Master, clear
do Data13_variable_generation.do
//apply exclusion criteria
keep if exclude==0
//restrict to jan 1, 2007
drop if seconddate<17167 

//update censor times for last continuous exposure to second-line agent (indextype)
forval i=0/5 {
	replace acm_exit = exposuret1`i' if indextype==`i' & exposuret1`i'!=.
}

//declare survival analysis - last continuous exposure as last exposure date 
stset acm_exit, fail(allcausemort) id(patid) origin(seconddate) scale(365.35)

//spit data to integrate time-varying covariates for diabetes meds.
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

//Generate person-years, incidence rate, and 95%CI as well as hazard ratio
label var indextype "Exposure"
stptime, by(indextype) per(1000)
stcox i.indextype, cformat(%6.2f) pformat(%5.3f) sformat(%6.2f) 

stptime, title(person-years) per(1000)
putexcel A1= ("Indextype") B1=("Person-Time") C1=("Failures") D1=("Incidence Rate") E1=("Lower Bound") F1=("Upper Bound") G1=("Hazard Ratio") H1=("Lower Bound") I1=("Upper Bound") using table2, sheet("Unadjusted2") modify
forval i=0/5{
local row=`i'+2
stptime if indextype==`i'
putexcel A`row'= ("`i'") B`row'=(r(ptime)) C`row'=(r(failures)) D`row'=(r(rate)*1000) E`row'=(r(lb)*1000) F`row'=(r(ub)*1000) using table2, sheet("Unadjusted2") modify
}
forval i=1/5 {
local row=`i'+2
local matrow=`i'+1
stcox i.indextype 
matrix b=r(table)
matrix a= b'
putexcel G`row'=(a[`matrow',1]) H`row'=(a[`matrow',5]) I`row'=(a[`matrow',6]) using table2, sheet("Unadjusted2") modify
}

//Multivariable analysis 
stcox i.indextype `mvmodel', cformat(%6.2f) pformat(%5.3f) sformat(%6.2f)  
matrix b=r(table)
matrix c=b'
matrix list c
local matrownames "SU DPP4I GLP1RA INS TZD OTH Age Male diabetes_duration Metformin_overlap Unknown Current Non_Smoker Former Unknown Current Non_Drinker Former BMI_<20 BMI_20_24 BMI_25_29 BMI_30_34 BMI_35_40 BMI_40+ Unknown HbA1c_<7 HbA1c_7_8 HbA1c_8_9 HbA1c_9_10 HbA1c_>10 HbA1c_unknown SBP_<120 SBP_120_129 SBP_130_139  SBP_140_149 SBP_150_159 SBP_160+ SBP_missing eGFR_90+ eGFR_60_89 eGFR_30_59 eGFR_15_29 eGFR_<15 eGFR_unknown Physician_visits_0_12 Physician_visits_13_24 Physician_visits_24+ Physician_visits_unknown No_unique_drugs_0_5 No_unique_drugs_6_10 No_unique_drugs_11_15 No_unique_drugs_16_20 No_unique_drugs_>20 CCI=1 CCI=2 CCI=3+ MI Stroke HF Arrythmia Angina Revascularization HTN AFIB PVD Statin CCB BB Anticoag Antiplat RAS Diuretics su_post dpp4i_post glp1ra_post ins_post tzd_post oth_post"
forval i=1/79{
local x=`i'+1
local rowname:word `i' of `matrownames'
putexcel A1=("Variable") B1=("HR") C1=("SE") D1=("p-value") E1=("LL") F1=("UL") A`x'=("`rowname'") B`x'=(c[`i',1]) C`x'=(c[`i',2]) D`x'=(c[`i',4]) E`x'=(c[`i',5]) F`x'=(c[`i',6])using table2, sheet("Adjusted2") modify
}

// Multiple imputation
//put data in mlong form such that complete rows are omitted and only incomplete and imputed rows are shown
mi set mlong
save acm_mlong, replace
//inform mi which variables contain missing values for which we want to timpute (bmi_i and sbp)
mi register imputed bmi_i sbp
//set the seed so that results are reproducible
set seed 1979
//impute (10 iterations) for each missing value in the registered variables
mi impute mvn bmi_i sbp = acm `demo' `comorb' `meds3' `clin2', add(20) by(indextype)
//fit the model separately on each of the 10 imputed datasets and combine results
mi estimate, hr: stcox i.indextype `covariate' bmi_i sbp


// #2. CENSOR EXPSOURE AT EXPOSURE TO THIRD AGENT
use Analytic_Dataset_Master, clear
do Data13_variable_generation.do
//apply exclusion criteria
keep if exclude==0 
//restrict to jan 1, 2007
drop if seconddate<17167 

//update censor times for single agent exposure to a thirddate
forval i=0/5 {
	replace acm_exit = exposuret0`i' if indextype3==`i' & exposuret0`i'!=.
}

// declare survival analysis for single agent exposure to a thirddate
stset acm_exit, fail(acm) id(patid) origin(thirddate) scale(365.35)

//Generate person-years, incidence rate, and 95%CI as well as hazard ratio
label var indextype "Exposure"
stptime, by(indextype) per(1000)
stcox i.indextype, cformat(%6.2f) pformat(%5.3f) sformat(%6.2f) 

stptime, title(person-years) per(1000)
putexcel A1= ("Indextype") B1=("Person-Time") C1=("Failures") D1=("Incidence Rate") E1=("Lower Bound") F1=("Upper Bound") G1=("Hazard Ratio") H1=("Lower Bound") I1=("Upper Bound") using table2, sheet("SensAnalysis3") modify
forval i=0/5{
local row=`i'+2
stptime if indextype==`i'
putexcel A`row'= ("`i'") B`row'=(r(ptime)) C`row'=(r(failures)) D`row'=(r(rate)*1000) E`row'=(r(lb)*1000) F`row'=(r(ub)*1000) using table2, sheet("SensAnalysis3") modify
}
forval i=1/5 {
local row=`i'+2
local matrow=`i'+1
stcox i.indextype 
matrix b=r(table)
matrix a= b'
putexcel G`row'=(a[`matrow',1]) H`row'=(a[`matrow',5]) I`row'=(a[`matrow',6]) using table2, sheet("SensAnalysis3") modify
}

//Multivariable analysis 
stcox i.indextype `mvmodel', cformat(%6.2f) pformat(%5.3f) sformat(%6.2f)  
matrix b=r(table)
matrix c=b'
matrix list c
*matrix rownames c = SU DPP4I GLP1RA INS TZD OTH Age Male su_post dpp4i_post glp1ra_post tzd_post oth_post diabetes_duration HbA1c_<7 HbA1c_7_8 HbA1c_8_9 HbA1c_9_10 HbA1c_>10 HbA1c_unknown SBP_<120 SBP_130_139  SBP_140_149 SBP_150_159 SBP_160+ SBP_missing eGFR_90+ eGFR_60_89 eGFR_30_59 eGFR_15_29 eGFR_unknown Physician_visits_0_12  Physician_visits_13_24 Physician_visits_24+ Physician_visits_unknown No_unique_drugs_0_5 No_unique_drugs_6_10 No_unique_drugs_11_15 No_unique_drugs_16_20 No_unique_drugs_>20 Non_Smoker Unknown Current Former CCI=1 CCI=2 CCI=3+ MI Stroke HF Arrythmia Angina Revascularization HTN AFIB PVD Statin CCB BB Anticoag Antiplat RAS Diuretics
local matrownames "SU DPP4I GLP1RA INS TZD OTH Age Male diabetes_duration Metformin_overlap Unknown Current Non_Smoker Former Unknown Current Non_Drinker Former BMI_<20 BMI_20_24 BMI_25_29 BMI_30_34 BMI_35_40 BMI_40+ Unknown HbA1c_<7 HbA1c_7_8 HbA1c_8_9 HbA1c_9_10 HbA1c_>10 HbA1c_unknown SBP_<120 SBP_120_129 SBP_130_139  SBP_140_149 SBP_150_159 SBP_160+ SBP_missing eGFR_90+ eGFR_60_89 eGFR_30_59 eGFR_15_29 eGFR_<15 eGFR_unknown Physician_visits_0_12 Physician_visits_13_24 Physician_visits_24+ Physician_visits_unknown No_unique_drugs_0_5 No_unique_drugs_6_10 No_unique_drugs_11_15 No_unique_drugs_16_20 No_unique_drugs_>20 CCI=1 CCI=2 CCI=3+ MI Stroke HF Arrythmia Angina Revascularization HTN AFIB PVD Statin CCB BB Anticoag Antiplat RAS Diuretics su_post dpp4i_post glp1ra_post ins_post tzd_post oth_post"
forval i=1/79{
local x=`i'+1
local rowname:word `i' of `matrownames'
putexcel A1=("Variable") B1=("HR") C1=("SE") D1=("p-value") E1=("LL") F1=("UL") A`x'=("`rowname'") B`x'=(c[`i',1]) C`x'=(c[`i',2]) D`x'=(c[`i',4]) E`x'=(c[`i',5]) F`x'=(c[`i',6])using table2, sheet("SensAnalysis3") modify
}

// Multiple imputation
//put data in mlong form such that complete rows are omitted and only incomplete and imputed rows are shown
mi set mlong
save acm_mlong, replace
//inform mi which variables contain missing values for which we want to timpute (bmi_i and sbp)
mi register imputed bmi_i sbp
//set the seed so that results are reproducible
set seed 1979
//impute (10 iterations) for each missing value in the registered variables
mi impute mvn bmi_i sbp = acm `demo' `comorb' `meds3' `clin2', add(20) by(indextype)
//fit the model separately on each of the 10 imputed datasets and combine results
mi estimate, hr: stcox i.indextype `covariate' bmi_i sbp
// #3 Fourth-line Therapy
use Analytic_Dataset_Master, clear
do Data13_variable_generation.do
//apply exclusion criteria
keep if exclude==0 
//restrict to jan 1, 2007
drop if seconddate<17167 

// update censor times for final exposure to fourth-line agent (indextype4)

forval i=0/5 {
	replace acm_exit = exposuretf`i' if indextype4==`i' & exposuretf`i'!=.
}

// declare survival analysis - final exposure as last exposure date 
stset acm_exit, fail(allcausemort) id(patid) origin(fourthdate) scale(365.25)

//Generate person-years, incidence rate, and 95%CI as well as hazard ratio
label var indextype "Exposure"
stptime, by(indextype4) per(1000)
stcox i.indextype4, cformat(%6.2f) pformat(%5.3f) sformat(%6.2f) 

stptime, title(person-years) per(1000)
putexcel A1= ("Indextype") B1=("Person-Time") C1=("Failures") D1=("Incidence Rate") E1=("Lower Bound") F1=("Upper Bound") G1=("Hazard Ratio") H1=("Lower Bound") I1=("Upper Bound") using table2, sheet("Unadjusted4") modify
forval i=0/5{
local row=`i'+2
stptime if indextype4==`i'
putexcel A`row'= ("`i'") B`row'=(r(ptime)) C`row'=(r(failures)) D`row'=(r(rate)*1000) E`row'=(r(lb)*1000) F`row'=(r(ub)*1000) using table2, sheet("Unadjusted4") modify
}
forval i=1/5 {
local row=`i'+2
local matrow=`i'+1
stcox i.indextype4 
matrix b=r(table)
matrix a= b'
putexcel G`row'=(a[`matrow',1]) H`row'=(a[`matrow',5]) I`row'=(a[`matrow',6]) using table2, sheet("Unadjusted4") modify
}

//Multivariable analysis 
// note: missing indicator approach used
stcox i.indextype4 `mvmodel', cformat(%6.2f) pformat(%5.3f) sformat(%6.2f)  
matrix b=r(table)
matrix c=b'
matrix list c
*matrix rownames c = SU DPP4I GLP1RA INS TZD OTH Age Male su_post dpp4i_post glp1ra_post tzd_post oth_post diabetes_duration HbA1c_<7 HbA1c_7_8 HbA1c_8_9 HbA1c_9_10 HbA1c_>10 HbA1c_unknown SBP_<120 SBP_130_139  SBP_140_149 SBP_150_159 SBP_160+ SBP_missing eGFR_90+ eGFR_60_89 eGFR_30_59 eGFR_15_29 eGFR_unknown Physician_visits_0_12  Physician_visits_13_24 Physician_visits_24+ Physician_visits_unknown No_unique_drugs_0_5 No_unique_drugs_6_10 No_unique_drugs_11_15 No_unique_drugs_16_20 No_unique_drugs_>20 Non_Smoker Unknown Current Former CCI=1 CCI=2 CCI=3+ MI Stroke HF Arrythmia Angina Revascularization HTN AFIB PVD Statin CCB BB Anticoag Antiplat RAS Diuretics
local matrownames "SU DPP4I GLP1RA INS TZD OTH Age Male diabetes_duration Metformin_overlap Unknown Current Non_Smoker Former Unknown Current Non_Drinker Former BMI_<20 BMI_20_24 BMI_25_29 BMI_30_34 BMI_35_40 BMI_40+ Unknown HbA1c_<7 HbA1c_7_8 HbA1c_8_9 HbA1c_9_10 HbA1c_>10 HbA1c_unknown SBP_<120 SBP_120_129 SBP_130_139  SBP_140_149 SBP_150_159 SBP_160+ SBP_missing eGFR_90+ eGFR_60_89 eGFR_30_59 eGFR_15_29 eGFR_<15 eGFR_unknown Physician_visits_0_12 Physician_visits_13_24 Physician_visits_24+ Physician_visits_unknown No_unique_drugs_0_5 No_unique_drugs_6_10 No_unique_drugs_11_15 No_unique_drugs_16_20 No_unique_drugs_>20 CCI=1 CCI=2 CCI=3+ MI Stroke HF Arrythmia Angina Revascularization HTN AFIB PVD Statin CCB BB Anticoag Antiplat RAS Diuretics su_post dpp4i_post glp1ra_post ins_post tzd_post oth_post"
forval i=1/79{
local x=`i'+1
local rowname:word `i' of `matrownames'
putexcel A1=("Variable") B1=("HR") C1=("SE") D1=("p-value") E1=("LL") F1=("UL") A`x'=("`rowname'") B`x'=(c[`i',1]) C`x'=(c[`i',2]) D`x'=(c[`i',4]) E`x'=(c[`i',5]) F`x'=(c[`i',6])using table2, sheet("Adjusted4") modify
}

// Multiple imputation
//put data in mlong form such that complete rows are omitted and only incomplete and imputed rows are shown
mi set mlong
save acm_mlong, replace
//inform mi which variables contain missing values for which we want to timpute (bmi_i and sbp)
mi register imputed bmi_i sbp
//set the seed so that results are reproducible
set seed 1979
//impute (10 iterations) for each missing value in the registered variables
mi impute mvn bmi_i sbp = acm `demo' `comorb' `meds3' `clin2', add(20) by(indextype)
//fit the model separately on each of the 10 imputed datasets and combine results
mi estimate, hr: stcox i.indextype `covariate' bmi_i sbp

// # 4 Any exposure after metformin monotherapy
use Analytic_Dataset_Master, clear
do Data13_variable_generation.do
//apply exclusion criteria
keep if exclude==0
//restrict to jan 1, 2007
drop if seconddate<17167 

// declare survival analysis - final exposure as last exposure date 
stset acm_exit, fail(allcausemort) id(patid) origin(seconddate) scale(365.25)

// spit data to integrate time-varying covariates for diabetes meds.
stsplit adm3, at(0) after(thirddate)
gen su_post=regexm(thirdadmrx, "SU") & adm3!=-1
gen dpp4i_post=regexm(thirdadmrx, "DPP") & adm3!=-1
gen glp1ra_post=regexm(thirdadmrx, "GLP") & adm3!=-1
gen ins_post=regexm(thirdadmrx, "insulin") & adm3!=-1
gen tzd_post=regexm(thirdadmrx, "TZD") & adm3!=-1
gen oth_post=regexm(thirdadmrx, "other") & adm3!=-1

stsplit adm4, at(0) after(fourthdate)
replace su_post=1 if regexm(fourthadmrx, "SU") & adm4!=-1
replace dpp4i_post= 1 if regexm(fourthadmrx, "DPP") & adm4!=-1
replace glp1ra_post=1 if regexm(fourthadmrx, "GLP") & adm4!=-1
replace ins_post=1 if regexm(fourthadmrx, "insulin") & adm4!=-1
replace tzd_post=1 if regexm(fourthadmrx, "TZD") & adm4!=-1
replace oth_post=1 if regexm(fourthadmrx, "other") & adm4!=-1

stsplit adm5, at(0) after(fifthdate)
replace su_post=1 if regexm(fifthadmrx, "SU") & adm5!=-1
replace dpp4i_post= 1 if regexm(fifthadmrx, "DPP") & adm5!=-1
replace glp1ra_post=1 if regexm(fifthadmrx, "GLP") & adm5!=-1
replace ins_post=1 if regexm(fifthadmrx, "insulin") & adm5!=-1
replace tzd_post=1 if regexm(fifthadmrx, "TZD") & adm5!=-1
replace oth_post=1 if regexm(fifthadmrx, "other") & adm5!=-1

stsplit adm6, at(0) after(sixthdate)
replace su_post=1 if regexm(sixthadmrx, "SU") & adm6!=-1
replace dpp4i_post= 1 if regexm(sixthadmrx, "DPP") & adm6!=-1
replace glp1ra_post=1 if regexm(sixthadmrx, "GLP") & adm6!=-1
replace ins_post=1 if regexm(sixthadmrx, "insulin") & adm6!=-1
replace tzd_post=1 if regexm(sixthadmrx, "TZD") & adm6!=-1
replace oth_post=1 if regexm(sixthadmrx, "other") & adm6!=-1

stsplit adm7, at(0) after(seventhdate)
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

//Generate person-years, incidence rate, and 95%CI as well as hazard ratios
foreach var in "su" "dpp4i" "glp1ra" "ins" "tzd" "oth" {
	stptime, by(`var'_post) per(1000)
	stcox `var'_post, cformat(%6.2f) pformat(%5.3f) sformat(%6.2f)
	}
	
stcox `covariate', cformat(%6.2f) pformat(%5.3f) sformat(%6.2f)  

// any use [time-varying]
stsplit stop0, at(0(1)max) after(exposuretf0)
replace su_post=0 if su_post==1 & stop0!=-1

stsplit stop1, at(0(1)max) after(exposuretf1)
replace dpp4i_post=0 if dpp4i_post==1 & stop1!=-1

stsplit stop2, at(0(1)max) after(exposuretf2)
replace glp1ra_post=0 if glp1ra_post==1 & stop2!=-1

stsplit stop3, at(0(1)max) after(exposuretf3)
replace ins_post=0 if ins_post==1 & stop3!=-1

stsplit stop4, at(0(1)max) after(exposuretf4)
replace tzd_post=0 if tzd_post==1 & stop4!=-1

stsplit stop5, at(0(1)max) after(exposuretf5)
replace oth_post=0 if oth_post==1 & stop5!=-1

//Generate person-years, incidence rate, and 95%CI as well as hazard ratios
foreach var in "su" "dpp4i" "glp1ra" "ins" "tzd" "oth" {
	stptime, by(`var'_post) per(1000)
	stcox `var'_post, cformat(%6.2f) pformat(%5.3f) sformat(%6.2f)
	}
	
stcox i.indextype `mvmodel', cformat(%6.2f) pformat(%5.3f) sformat(%6.2f)  
matrix b=r(table)
matrix c=b'
matrix list c
*matrix rownames c = SU DPP4I GLP1RA INS TZD OTH Age Male su_post dpp4i_post glp1ra_post tzd_post oth_post diabetes_duration HbA1c_<7 HbA1c_7_8 HbA1c_8_9 HbA1c_9_10 HbA1c_>10 HbA1c_unknown SBP_<120 SBP_130_139  SBP_140_149 SBP_150_159 SBP_160+ SBP_missing eGFR_90+ eGFR_60_89 eGFR_30_59 eGFR_15_29 eGFR_unknown Physician_visits_0_12  Physician_visits_13_24 Physician_visits_24+ Physician_visits_unknown No_unique_drugs_0_5 No_unique_drugs_6_10 No_unique_drugs_11_15 No_unique_drugs_16_20 No_unique_drugs_>20 Non_Smoker Unknown Current Former CCI=1 CCI=2 CCI=3+ MI Stroke HF Arrythmia Angina Revascularization HTN AFIB PVD Statin CCB BB Anticoag Antiplat RAS Diuretics
local matrownames "SU DPP4I GLP1RA INS TZD OTH Age Male diabetes_duration Metformin_overlap Unknown Current Non_Smoker Former Unknown Current Non_Drinker Former BMI_<20 BMI_20_24 BMI_25_29 BMI_30_34 BMI_35_40 BMI_40+ Unknown HbA1c_<7 HbA1c_7_8 HbA1c_8_9 HbA1c_9_10 HbA1c_>10 HbA1c_unknown SBP_<120 SBP_120_129 SBP_130_139  SBP_140_149 SBP_150_159 SBP_160+ SBP_missing eGFR_90+ eGFR_60_89 eGFR_30_59 eGFR_15_29 eGFR_<15 eGFR_unknown Physician_visits_0_12 Physician_visits_13_24 Physician_visits_24+ Physician_visits_unknown No_unique_drugs_0_5 No_unique_drugs_6_10 No_unique_drugs_11_15 No_unique_drugs_16_20 No_unique_drugs_>20 CCI=1 CCI=2 CCI=3+ MI Stroke HF Arrythmia Angina Revascularization HTN AFIB PVD Statin CCB BB Anticoag Antiplat RAS Diuretics su_post dpp4i_post glp1ra_post ins_post tzd_post oth_post"
forval i=1/79{
local x=`i'+1
local rowname:word `i' of `matrownames'
putexcel A1=("Variable") B1=("HR") C1=("SE") D1=("p-value") E1=("LL") F1=("UL") A`x'=("`rowname'") B`x'=(c[`i',1]) C`x'=(c[`i',2]) D`x'=(c[`i',4]) E`x'=(c[`i',5]) F`x'=(c[`i',6])using table2, sheet("Adjusted4") modify
}

// Multiple imputation
//put data in mlong form such that complete rows are omitted and only incomplete and imputed rows are shown
mi set mlong
save acm_mlong, replace
//inform mi which variables contain missing values for which we want to timpute (bmi_i and sbp)
mi register imputed bmi_i sbp
//set the seed so that results are reproducible
set seed 1979
//impute (10 iterations) for each missing value in the registered variables
mi impute mvn bmi_i sbp = acm `demo' `comorb' `meds3' `clin2', add(20) by(indextype)
//fit the model separately on each of the 10 imputed datasets and combine results
mi estimate, hr: stcox i.indextype `covariate' bmi_i sbp

timer off 1
log close stat_acm
