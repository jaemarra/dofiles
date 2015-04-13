//  program:    Stat_acm.do
//  task:		Statistical analysis for all-cause mortality
//  project: 	Incretins--Comparative mortality and CV outcomes (CPRD)
//  author:     JM \April2015  
//				

clear all
capture log close
set more off
log using Stat_acm.smcl, replace
timer on 1

use Analytic_Dataset_Master
do Data13_variable_generation.do

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

keep if exclude==0


//Create table1 

table1, by(indextype) vars(age_indexdate contn \ age_cat cat \ gender cat \ imd2010_5 cat \ dmdur contn \ prx_covvalue_g_i4 cat \ prx_covvalue_g_i5 cat \ bmi_i_cats cat \ physician_vis2 cat \ ang_i bin \ arr_i bin \ afib_i bin \ hf_i bin \ htn_i bin \ mi_i bin \ pvd_i bin \ stroke_i bin \ revasc_i bin \ prx_ccivalue_g_i2 cat \ hba1c_i contn \ hba1c_cats_i cat \ prx_covvalue_g_i3 contn \ sbp_i_cats2 cat \ egfr_amdrd contn \ ckd_amdrd cat \ unique_cov_drugs cat \ unqrx2 cat \ statin_i bin \ calchan_i bin \ betablock_i bin \ anticoag_oral_i bin \ antiplat_i bin \ ace_arb_renin_i bin \ diuretics_all_i bin) onecol format(%9.2g) saving(table1.xls, replace)
table1 if seconddate>=17167, by(indextype) vars(age_indexdate contn \ age_cat cat \ gender cat \ imd2010_5 cat \ dmdur contn \ prx_covvalue_g_i4 cat \ prx_covvalue_g_i5 cat \ bmi_i_cats cat \ physician_vis2 cat \ ang_i bin \ arr_i bin \ afib_i bin \ hf_i bin \ htn_i bin \ mi_i bin \ pvd_i bin \ stroke_i bin \ revasc_i bin \ prx_ccivalue_g_i2 cat \ hba1c_i contn \ hba1c_cats_i cat \ prx_covvalue_g_i3 contn \ sbp_i_cats2 cat \ egfr_amdrd contn \ ckd_amdrd cat \ unique_cov_drugs cat \ unqrx2 cat \ statin_i bin \ calchan_i bin \ betablock_i bin \ anticoag_oral_i bin \ antiplat_i bin \ ace_arb_renin_i bin \ diuretics_all_i bin) onecol format(%9.2g) saving(table1b.xls, replace)

// 2x2 tables with exposure and outcomes

label var indextype "Second-line Agent"
tab indextype acm, row

label var indextype3 "Third-line Agent"
tab indextype3 acm, row

label var indextype3 "Fourth-line Agent"
tab indextype4 acm, row

//restrict to January 1, 2007
tab indextype acm if seconddate>=17167, row
tab indextype3 acm if seconddate>=17167, row
tab indextype4 acm if seconddate>=17167, row
tab indextype5 acm if seconddate>=17167, row
tab indextype6 acm if seconddate>=17167, row
tab indextype7 acm if seconddate>=17167, row

***COX PROPORTIONAL HAZARDS REGRESSION***

// update censor times for final exposure to second-line agent (indextype)

forval i=0/5 {
	replace acm_exit = exposuretf`i' if indextype==`i' & exposuretf`i'!=.
}

// declare survival analysis - final exposure as last exposure date 
stset acm_exit, fail(allcausemort) id(patid) origin(seconddate) scale(365.25)

// spit data to integrate time-varying covariates for diabetes meds.
stsplit adm3, at(0(1)max) after(thirddate)
gen su_post=(indextype3==0 & adm3!=-1)
gen dpp4i_post=(indextype3==1 & adm3!=-1)
gen glp1ra_post=(indextype3==2 & adm3!=-1)
gen ins_post=(indextype3==3  & adm3!=-1)
gen tzd_post=(indextype3==4 & adm3!=-1)
gen oth_post=(indextype3==5  & adm3!=-1)

stsplit adm4, at(0(1)max) after(fourthdate)
replace su_post=1 if indextype4==0 & adm4!=-1
replace dpp4i_post=1 if indextype4==1 & adm4!=-1
replace glp1ra_post=1 if indextype4==2 & adm4!=-1
replace ins_post=1 if indextype4==3 & adm4!=-1
replace tzd_post=1 if indextype4==4 & adm4!=-1
replace oth_post=1 if indextype4==5 & adm4!=-1

stsplit adm5, at(0(1)max) after(fifthdate)
replace su_post=1 if indextype5==0 & adm5!=-1
replace dpp4i_post=1 if indextype5==1 & adm5!=-1
replace glp1ra_post=1 if indextype5==2 & adm5!=-1
replace ins_post=1 if indextype5==3 & adm5!=-1
replace tzd_post=1 if indextype5==4 & adm5!=-1
replace oth_post=1 if indextype5==5 & adm5!=-1

stsplit adm6, at(0(1)max) after(sixthdate)
replace su_post=1 if indextype6==0 & adm6!=-1
replace dpp4i_post=1 if indextype6==1 & adm6!=-1
replace glp1ra_post=1 if indextype6==2 & adm6!=-1
replace ins_post=1 if indextype6==3 & adm6!=-1
replace tzd_post=1 if indextype6==4 & adm6!=-1
replace oth_post=1 if indextype6==5 & adm6!=-1

stsplit adm7, at(0(1)max) after(seventhdate)
replace su_post=1 if indextype7==0 & adm7!=-1
replace dpp4i_post=1 if indextype7==1 & adm7!=-1
replace glp1ra_post=1 if indextype7==2 & adm7!=-1
replace ins_post=1 if indextype7==3 & adm7!=-1
replace tzd_post=1 if indextype7==4 & adm7!=-1
replace oth_post=1 if indextype7==5 & adm7!=-1

//Generate person-years, incidence rate, and 95%CI as well as hazard ratio
label var indextype "Exposure"
stptime, by(indextype) per(1000)
stcox i.indextype, cformat(%6.2f) pformat(%5.3f) sformat(%6.2f) 

*sts graph, by(indextype) 
*sts graph if seconddate>=17167, by(indextype) 
*stcurve, survival at1(indextype=0) at2(indextype=1) at3(indextype=2) at4(indextype=3) at5(indextype=4) at6(indextype=5)

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

// restrict to jan 1, 2007

stptime if seconddate>=17167, by(indextype) per(1000)
stcox i.indextype if seconddate>=17167, cformat(%6.2f) pformat(%5.3f) sformat(%6.2f) 

stptime if seconddate>=17167, by(indextype) per(1000)
putexcel A1= ("Indextype") B1=("Person-Time") C1=("Failures") D1=("Incidence Rate") E1=("Lower Bound") F1=("Upper Bound") G1=("Hazard Ratio") H1=("Lower Bound") I1=("Upper Bound") using table2b, sheet("Unadjusted") modify
forval i=0/5{
local row=`i'+2
stptime if indextype==`i'
putexcel A`row'= ("`i'") B`row'=(r(ptime)) C`row'=(r(failures)) D`row'=(r(rate)*1000) E`row'=(r(lb)*1000) F`row'=(r(ub)*1000) using table2b, sheet("Unadjusted") modify
}
forval i=1/5 {
local row=`i'+2
local matrow=`i'+1
stcox i.indextype if seconddate>=17167
matrix b=r(table)
matrix a= b'
putexcel G`row'=(a[`matrow',1]) H`row'=(a[`matrow',5]) I`row'=(a[`matrow',6]) using table2b, sheet("Unadjusted") modify
}


//Multivariable analysis 
// note: missing indicator approach used
*stcox i.indextype age_index gender, cformat(%6.2f) pformat(%5.3f) sformat(%6.2f) 
*stcox i.indextype age_index gender *_post, cformat(%6.2f) pformat(%5.3f) sformat(%6.2f) 
*stcox i.indextype age_index gender *_post dmdur, cformat(%6.2f) pformat(%5.3f) sformat(%6.2f)  
*stcox ib1.hba1c_cats_i2

stcox i.indextype age_indexdate gender dmdur ib2.prx_covvalue_g_i4 ib2.prx_covvalue_g_i5 ib1.hba1c_cats_i2 ib1.sbp_i_cats2 i.ckd_amdrd i.physician_vis2 i.unique_cov_drugs i.prx_ccivalue_g_i2 mi_i stroke_i hf_i arr_i ang_i revasc_i htn_i afib_i pvd_i statin_i calchan_i betablock_i anticoag_oral_i antiplat_i ace_arb_renin_i diuretics_all_i *_post, cformat(%6.2f) pformat(%5.3f) sformat(%6.2f)  

*stphplot if indextype==1 | indextype==0 | indextype==2, by(indextype)
*stphplot if seconddate>=17167 & (indextype==1 | indextype==0 | indextype==2), by(indextype)
*estat phtest


stcox i.indextype age_indexdate gender dmdur ib2.prx_covvalue_g_i4 ib2.prx_covvalue_g_i5 ib1.hba1c_cats_i2 ib1.sbp_i_cats2 i.ckd_amdrd i.physician_vis2 i.unique_cov_drugs i.prx_ccivalue_g_i2 mi_i stroke_i hf_i arr_i ang_i revasc_i htn_i afib_i pvd_i statin_i calchan_i betablock_i anticoag_oral_i antiplat_i ace_arb_renin_i diuretics_all_i *_post, cformat(%6.2f) pformat(%5.3f) sformat(%6.2f)  
matrix b=r(table)
matrix c=b'
matrix list c
*matrix rownames c = SU DPP4I GLP1RA INS TZD OTH Age Male su_post dpp4i_post glp1ra_post tzd_post oth_post diabetes_duration HbA1c_<7 HbA1c_7_8 HbA1c_8_9 HbA1c_9_10 HbA1c_>10 HbA1c_unknown SBP_<120 SBP_130_139  SBP_140_149 SBP_150_159 SBP_160+ SBP_missing eGFR_90+ eGFR_60_89 eGFR_30_59 eGFR_15_29 eGFR_unknown Physician_visits_0_12  Physician_visits_13_24 Physician_visits_24+ Physician_visits_unknown No_unique_drugs_0_5 No_unique_drugs_6_10 No_unique_drugs_11_15 No_unique_drugs_16_20 No_unique_drugs_>20 Non_Smoker Unknown Current Former CCI=1 CCI=2 CCI=3+ MI Stroke HF Arrythmia Angina Revascularization HTN AFIB PVD Statin CCB BB Anticoag Antiplat RAS Diuretics
local matrownames "SU DPP4I GLP1RA INS TZD OTH Age Male diabetes_duration Unknown Current Non_Drinker Former Unknown Current Non_Smoker Former HbA1c_<7 HbA1c_7_8 HbA1c_8_9 HbA1c_9_10 HbA1c_>10 HbA1c_unknown SBP_<120 SBP_120_129 SBP_130_139  SBP_140_149 SBP_150_159 SBP_160+ SBP_missing eGFR_90+ eGFR_60_89 eGFR_30_59 eGFR_15_29 eGFR_<15 eGFR_unknown Physician_visits_0_12 Physician_visits_13_24 Physician_visits_24+ Physician_visits_unknown No_unique_drugs_0_5 No_unique_drugs_6_10 No_unique_drugs_11_15 No_unique_drugs_16_20 No_unique_drugs_>20 CCI=1 CCI=2 CCI=3+ MI Stroke HF Arrythmia Angina Revascularization HTN AFIB PVD Statin CCB BB Anticoag Antiplat RAS Diuretics su_post dpp4i_post glp1ra_post ins_post tzd_post oth_post"
forval i=1/69{
local x=`i'+1
local rowname:word `i' of `matrownames'
putexcel A1=("Variable") B1=("HR") C1=("SE") D1=("p-value") E1=("LL") F1=("UL") A`x'=("`rowname'") B`x'=(c[`i',1]) C`x'=(c[`i',2]) D`x'=(c[`i',4]) E`x'=(c[`i',5]) F`x'=(c[`i',6])using table2, sheet("Adjusted") modify
}


// restrict to jan 1, 2007

stcox i.indextype age_indexdate gender dmdur ib2.prx_covvalue_g_i4 ib2.prx_covvalue_g_i5 ib1.hba1c_cats_i2 ib1.sbp_i_cats2 i.ckd_amdrd i.physician_vis2 i.unique_cov_drugs i.prx_ccivalue_g_i2 mi_i stroke_i hf_i arr_i ang_i revasc_i htn_i afib_i pvd_i statin_i calchan_i betablock_i anticoag_oral_i antiplat_i ace_arb_renin_i diuretics_all_i *_post if seconddate>=17167, cformat(%6.2f) pformat(%5.3f) sformat(%6.2f)  
matrix b=r(table)
matrix c=b'
matrix list c
*matrix rownames c = SU DPP4I GLP1RA INS TZD OTH Age Male su_post dpp4i_post glp1ra_post tzd_post oth_post diabetes_duration HbA1c_<7 HbA1c_7_8 HbA1c_8_9 HbA1c_9_10 HbA1c_>10 HbA1c_unknown SBP_<120 SBP_130_139  SBP_140_149 SBP_150_159 SBP_160+ SBP_missing eGFR_90+ eGFR_60_89 eGFR_30_59 eGFR_15_29 eGFR_unknown Physician_visits_0_12  Physician_visits_13_24 Physician_visits_24+ Physician_visits_unknown No_unique_drugs_0_5 No_unique_drugs_6_10 No_unique_drugs_11_15 No_unique_drugs_16_20 No_unique_drugs_>20 Non_Smoker Unknown Current Former CCI=1 CCI=2 CCI=3+ MI Stroke HF Arrythmia Angina Revascularization HTN AFIB PVD Statin CCB BB Anticoag Antiplat RAS Diuretics
local matrownames "SU DPP4I GLP1RA INS TZD OTH Age Male diabetes_duration Unknown Current Non_Drinker Former Unknown Current Non_Smoker Former HbA1c_<7 HbA1c_7_8 HbA1c_8_9 HbA1c_9_10 HbA1c_>10 HbA1c_unknown SBP_<120 SBP_120_129 SBP_130_139  SBP_140_149 SBP_150_159 SBP_160+ SBP_missing eGFR_90+ eGFR_60_89 eGFR_30_59 eGFR_15_29 eGFR_<15 eGFR_unknown Physician_visits_0_12 Physician_visits_13_24 Physician_visits_24+ Physician_visits_unknown No_unique_drugs_0_5 No_unique_drugs_6_10 No_unique_drugs_11_15 No_unique_drugs_16_20 No_unique_drugs_>20 CCI=1 CCI=2 CCI=3+ MI Stroke HF Arrythmia Angina Revascularization HTN AFIB PVD Statin CCB BB Anticoag Antiplat RAS Diuretics su_post dpp4i_post glp1ra_post ins_post tzd_post oth_post"
forval i=1/69{
local x=`i'+1
local rowname:word `i' of `matrownames'
putexcel A1=("Variable") B1=("HR") C1=("SE") D1=("p-value") E1=("LL") F1=("UL") A`x'=("`rowname'") B`x'=(c[`i',1]) C`x'=(c[`i',2]) D`x'=(c[`i',4]) E`x'=(c[`i',5]) F`x'=(c[`i',6])using table2b, sheet("Adjusted") modify
}


***SENSITIVITY ANALYSIS***

// #1. CENSOR EXPSOURE AT FIRST GAP
use Analytic_Dataset_Master, clear
do Data13_variable_generation.do
keep if exclude==0

// update censor times for last continuous exposure to second-line agent (indextype)

forval i=0/5 {
	replace acm_exit = exposuret1`i' if indextype==`i' & exposuret1`i'!=.
}

// declare survival analysis - last continuous exposure as last exposure date 
stset acm_exit2, fail(allcausemort) id(patid) origin(seconddate) scale(365.35)
// spit data to integrate time-varying covariates for diabetes meds.

stsplit adm3, at(0(1)max) after(thirddate)
gen su_post=(indextype3==0 & adm3!=-1)
gen dpp4i_post=(indextype3==1 & adm3!=-1)
gen glp1ra_post=(indextype3==2 & adm3!=-1)
gen ins_post=(indextype3==3  & adm3!=-1)
gen tzd_post=(indextype3==4 & adm3!=-1)
gen oth_post=(indextype3==5  & adm3!=-1)

stsplit adm4, at(0(1)max) after(fourthdate)
replace su_post=1 if indextype4==0 & adm4!=-1
replace dpp4i_post=1 if indextype4==1 & adm4!=-1
replace glp1ra_post=1 if indextype4==2 & adm4!=-1
replace ins_post=1 if indextype4==3 & adm4!=-1
replace tzd_post=1 if indextype4==4 & adm4!=-1
replace oth_post=1 if indextype4==5 & adm4!=-1

stsplit adm5, at(0(1)max) after(fifthdate)
replace su_post=1 if indextype5==0 & adm5!=-1
replace dpp4i_post=1 if indextype5==1 & adm5!=-1
replace glp1ra_post=1 if indextype5==2 & adm5!=-1
replace ins_post=1 if indextype5==3 & adm5!=-1
replace tzd_post=1 if indextype5==4 & adm5!=-1
replace oth_post=1 if indextype5==5 & adm5!=-1

stsplit adm6, at(0(1)max) after(sixthdate)
replace su_post=1 if indextype6==0 & adm6!=-1
replace dpp4i_post=1 if indextype6==1 & adm6!=-1
replace glp1ra_post=1 if indextype6==2 & adm6!=-1
replace ins_post=1 if indextype6==3 & adm6!=-1
replace tzd_post=1 if indextype6==4 & adm6!=-1
replace oth_post=1 if indextype6==5 & adm6!=-1

stsplit adm7, at(0(1)max) after(seventhdate)
replace su_post=1 if indextype7==0 & adm7!=-1
replace dpp4i_post=1 if indextype7==1 & adm7!=-1
replace glp1ra_post=1 if indextype7==2 & adm7!=-1
replace ins_post=1 if indextype7==3 & adm7!=-1
replace tzd_post=1 if indextype7==4 & adm7!=-1
replace oth_post=1 if indextype7==5 & adm7!=-1

//Generate person-years, incidence rate, and 95%CI as well as hazard ratio
label var indextype "Exposure"
stptime, by(indextype) per(1000)
stcox i.indextype, cformat(%6.2f) pformat(%5.3f) sformat(%6.2f) 

*sts graph, by(indextype) 
*sts graph if seconddate>=17167, by(indextype) 
*stcurve, survival at1(indextype=0) at2(indextype=1) at3(indextype=2) at4(indextype=3) at5(indextype=4) at6(indextype=5)

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

// restrict to jan 1, 2007

stptime if seconddate>=17167, by(indextype) per(1000)
stcox i.indextype if seconddate>=17167, cformat(%6.2f) pformat(%5.3f) sformat(%6.2f) 

stptime if seconddate>=17167, by(indextype) per(1000)
putexcel A1= ("Indextype") B1=("Person-Time") C1=("Failures") D1=("Incidence Rate") E1=("Lower Bound") F1=("Upper Bound") G1=("Hazard Ratio") H1=("Lower Bound") I1=("Upper Bound") using table2b, sheet("Unadjusted2") modify
forval i=0/5{
local row=`i'+2
stptime if indextype==`i'
putexcel A`row'= ("`i'") B`row'=(r(ptime)) C`row'=(r(failures)) D`row'=(r(rate)*1000) E`row'=(r(lb)*1000) F`row'=(r(ub)*1000) using table2b, sheet("Unadjusted2") modify
}
forval i=1/5 {
local row=`i'+2
local matrow=`i'+1
stcox i.indextype if seconddate>=17167
matrix b=r(table)
matrix a= b'
putexcel G`row'=(a[`matrow',1]) H`row'=(a[`matrow',5]) I`row'=(a[`matrow',6]) using table2b, sheet("Unadjusted2") modify
}


//Multivariable analysis 
stcox i.indextype age_indexdate gender dmdur ib2.prx_covvalue_g_i4 ib2.prx_covvalue_g_i5 ib1.hba1c_cats_i2 ib1.sbp_i_cats2 i.ckd_amdrd i.physician_vis2 i.unique_cov_drugs i.prx_ccivalue_g_i2 i.mi_i i.stroke_i i.hf_i i.arr_i i.ang_i i.revasc_i i.htn_i i.afib_i i.pvd_i i.ckd_amdrd i.statin_i i.calchan_i i.betablock_i i.anticoag_oral_i i.antiplat_i i.ace_arb_renin_i i.diuretics_all_i *_post, cformat(%6.2f) pformat(%5.3f) sformat(%6.2f)  
matrix b=r(table)
matrix c=b'
matrix list c
*matrix rownames c = SU DPP4I GLP1RA INS TZD OTH Age Male su_post dpp4i_post glp1ra_post tzd_post oth_post diabetes_duration HbA1c_<7 HbA1c_7_8 HbA1c_8_9 HbA1c_9_10 HbA1c_>10 HbA1c_unknown SBP_<120 SBP_130_139  SBP_140_149 SBP_150_159 SBP_160+ SBP_missing eGFR_90+ eGFR_60_89 eGFR_30_59 eGFR_15_29 eGFR_unknown Physician_visits_0_12  Physician_visits_13_24 Physician_visits_24+ Physician_visits_unknown No_unique_drugs_0_5 No_unique_drugs_6_10 No_unique_drugs_11_15 No_unique_drugs_16_20 No_unique_drugs_>20 Non_Smoker Unknown Current Former CCI=1 CCI=2 CCI=3+ MI Stroke HF Arrythmia Angina Revascularization HTN AFIB PVD Statin CCB BB Anticoag Antiplat RAS Diuretics
local matrownames "SU DPP4I GLP1RA INS TZD OTH Age Male diabetes_duration Unknown Current Non_Drinker Former Unknown Current Non_Smoker Former HbA1c_<7 HbA1c_7_8 HbA1c_8_9 HbA1c_9_10 HbA1c_>10 HbA1c_unknown SBP_<120 SBP_120_129 SBP_130_139  SBP_140_149 SBP_150_159 SBP_160+ SBP_missing eGFR_90+ eGFR_60_89 eGFR_30_59 eGFR_15_29 eGFR_<15 eGFR_unknown Physician_visits_0_12 Physician_visits_13_24 Physician_visits_24+ Physician_visits_unknown No_unique_drugs_0_5 No_unique_drugs_6_10 No_unique_drugs_11_15 No_unique_drugs_16_20 No_unique_drugs_>20 CCI=1 CCI=2 CCI=3+ MI Stroke HF Arrythmia Angina Revascularization HTN AFIB PVD Statin CCB BB Anticoag Antiplat RAS Diuretics su_post dpp4i_post glp1ra_post ins_post tzd_post oth_post"
forval i=1/69{
local x=`i'+1
local rowname:word `i' of `matrownames'
putexcel A1=("Variable") B1=("HR") C1=("SE") D1=("p-value") E1=("LL") F1=("UL") A`x'=("`rowname'") B`x'=(c[`i',1]) C`x'=(c[`i',2]) D`x'=(c[`i',4]) E`x'=(c[`i',5]) F`x'=(c[`i',6])using table2, sheet("Adjusted2") modify
}

// restrict to jan 1, 2007

stcox i.indextype age_indexdate gender dmdur ib2.prx_covvalue_g_i4 ib2.prx_covvalue_g_i5 ib1.hba1c_cats_i2 ib1.sbp_i_cats2 i.ckd_amdrd i.physician_vis2 i.unique_cov_drugs i.prx_ccivalue_g_i2 mi_i stroke_i hf_i arr_i ang_i revasc_i htn_i afib_i pvd_i statin_i calchan_i betablock_i anticoag_oral_i antiplat_i ace_arb_renin_i diuretics_all_i *_post if seconddate>=17167, cformat(%6.2f) pformat(%5.3f) sformat(%6.2f)  
matrix b=r(table)
matrix c=b'
matrix list c
*matrix rownames c = SU DPP4I GLP1RA INS TZD OTH Age Male su_post dpp4i_post glp1ra_post tzd_post oth_post diabetes_duration HbA1c_<7 HbA1c_7_8 HbA1c_8_9 HbA1c_9_10 HbA1c_>10 HbA1c_unknown SBP_<120 SBP_130_139  SBP_140_149 SBP_150_159 SBP_160+ SBP_missing eGFR_90+ eGFR_60_89 eGFR_30_59 eGFR_15_29 eGFR_unknown Physician_visits_0_12  Physician_visits_13_24 Physician_visits_24+ Physician_visits_unknown No_unique_drugs_0_5 No_unique_drugs_6_10 No_unique_drugs_11_15 No_unique_drugs_16_20 No_unique_drugs_>20 Non_Smoker Unknown Current Former CCI=1 CCI=2 CCI=3+ MI Stroke HF Arrythmia Angina Revascularization HTN AFIB PVD Statin CCB BB Anticoag Antiplat RAS Diuretics
local matrownames "SU DPP4I GLP1RA INS TZD OTH Age Male diabetes_duration Unknown Current Non_Drinker Former Unknown Current Non_Smoker Former HbA1c_<7 HbA1c_7_8 HbA1c_8_9 HbA1c_9_10 HbA1c_>10 HbA1c_unknown SBP_<120 SBP_120_129 SBP_130_139  SBP_140_149 SBP_150_159 SBP_160+ SBP_missing eGFR_90+ eGFR_60_89 eGFR_30_59 eGFR_15_29 eGFR_<15 eGFR_unknown Physician_visits_0_12 Physician_visits_13_24 Physician_visits_24+ Physician_visits_unknown No_unique_drugs_0_5 No_unique_drugs_6_10 No_unique_drugs_11_15 No_unique_drugs_16_20 No_unique_drugs_>20 CCI=1 CCI=2 CCI=3+ MI Stroke HF Arrythmia Angina Revascularization HTN AFIB PVD Statin CCB BB Anticoag Antiplat RAS Diuretics su_post dpp4i_post glp1ra_post ins_post tzd_post oth_post"
forval i=1/69{
local x=`i'+1
local rowname:word `i' of `matrownames'
putexcel A1=("Variable") B1=("HR") C1=("SE") D1=("p-value") E1=("LL") F1=("UL") A`x'=("`rowname'") B`x'=(c[`i',1]) C`x'=(c[`i',2]) D`x'=(c[`i',4]) E`x'=(c[`i',5]) F`x'=(c[`i',6])using table2b, sheet("Adjusted2") modify
}

// #2 Third-line therapy
use Analytic_Dataset_Master, clear
do Data13_variable_generation.do
keep if exclude==0

// update censor times for final exposure to second-line agent (indextype)

forval i=0/5 {
	replace acm_exit = exposuretf`i' if indextype3==`i' & exposuretf`i'!=.
}

// declare survival analysis - final exposure as last exposure date 
stset acm_exit, fail(allcausemort) id(patid) origin(thirddate) scale(365.25)

// spit data to integrate time-varying covariates for diabetes meds.

stsplit adm4, at(0(1)max) after(fourthdate)
replace su_post=1 if indextype4==0 & adm4!=-1
replace dpp4i_post=1 if indextype4==1 & adm4!=-1
replace glp1ra_post=1 if indextype4==2 & adm4!=-1
replace ins_post=1 if indextype4==3 & adm4!=-1
replace tzd_post=1 if indextype4==4 & adm4!=-1
replace oth_post=1 if indextype4==5 & adm4!=-1

stsplit adm5, at(0(1)max) after(fifthdate)
replace su_post=1 if indextype5==0 & adm5!=-1
replace dpp4i_post=1 if indextype5==1 & adm5!=-1
replace glp1ra_post=1 if indextype5==2 & adm5!=-1
replace ins_post=1 if indextype5==3 & adm5!=-1
replace tzd_post=1 if indextype5==4 & adm5!=-1
replace oth_post=1 if indextype5==5 & adm5!=-1

stsplit adm6, at(0(1)max) after(sixthdate)
replace su_post=1 if indextype6==0 & adm6!=-1
replace dpp4i_post=1 if indextype6==1 & adm6!=-1
replace glp1ra_post=1 if indextype6==2 & adm6!=-1
replace ins_post=1 if indextype6==3 & adm6!=-1
replace tzd_post=1 if indextype6==4 & adm6!=-1
replace oth_post=1 if indextype6==5 & adm6!=-1

stsplit adm7, at(0(1)max) after(seventhdate)
replace su_post=1 if indextype7==0 & adm7!=-1
replace dpp4i_post=1 if indextype7==1 & adm7!=-1
replace glp1ra_post=1 if indextype7==2 & adm7!=-1
replace ins_post=1 if indextype7==3 & adm7!=-1
replace tzd_post=1 if indextype7==4 & adm7!=-1
replace oth_post=1 if indextype7==5 & adm7!=-1

//Generate person-years, incidence rate, and 95%CI as well as hazard ratio
label var indextype "Exposure"
stptime, by(indextype) per(1000)
stcox i.indextype, cformat(%6.2f) pformat(%5.3f) sformat(%6.2f) 

*sts graph, by(indextype) 
*sts graph if seconddate>=17167, by(indextype) 
*stcurve, survival at1(indextype=0) at2(indextype=1) at3(indextype=2) at4(indextype=3) at5(indextype=4) at6(indextype=5)

stptime, title(person-years) per(1000)
putexcel A1= ("Indextype") B1=("Person-Time") C1=("Failures") D1=("Incidence Rate") E1=("Lower Bound") F1=("Upper Bound") G1=("Hazard Ratio") H1=("Lower Bound") I1=("Upper Bound") using table2, sheet("Unadjusted3") modify
forval i=0/5{
local row=`i'+2
stptime if indextype==`i'
putexcel A`row'= ("`i'") B`row'=(r(ptime)) C`row'=(r(failures)) D`row'=(r(rate)*1000) E`row'=(r(lb)*1000) F`row'=(r(ub)*1000) using table2, sheet("Unadjusted3") modify
}
forval i=1/5 {
local row=`i'+2
local matrow=`i'+1
stcox i.indextype 
matrix b=r(table)
matrix a= b'
putexcel G`row'=(a[`matrow',1]) H`row'=(a[`matrow',5]) I`row'=(a[`matrow',6]) using table2, sheet("Unadjusted3") modify
}

// restrict to jan 1, 2007

stptime if seconddate>=17167, by(indextype) per(1000)
stcox i.indextype if seconddate>=17167, cformat(%6.2f) pformat(%5.3f) sformat(%6.2f) 

stptime if seconddate>=17167, by(indextype) per(1000)
putexcel A1= ("Indextype") B1=("Person-Time") C1=("Failures") D1=("Incidence Rate") E1=("Lower Bound") F1=("Upper Bound") G1=("Hazard Ratio") H1=("Lower Bound") I1=("Upper Bound") using table2b, sheet("Unadjusted3") modify
forval i=0/5{
local row=`i'+2
stptime if indextype==`i'
putexcel A`row'= ("`i'") B`row'=(r(ptime)) C`row'=(r(failures)) D`row'=(r(rate)*1000) E`row'=(r(lb)*1000) F`row'=(r(ub)*1000) using table2b, sheet("Unadjusted3") modify
}
forval i=1/5 {
local row=`i'+2
local matrow=`i'+1
stcox i.indextype if seconddate>=17167
matrix b=r(table)
matrix a= b'
putexcel G`row'=(a[`matrow',1]) H`row'=(a[`matrow',5]) I`row'=(a[`matrow',6]) using table2b, sheet("Unadjusted3") modify
}


//Multivariable analysis 
// note: missing indicator approach used
*stcox i.indextype age_index gender, cformat(%6.2f) pformat(%5.3f) sformat(%6.2f) 
*stcox i.indextype age_index gender *_post, cformat(%6.2f) pformat(%5.3f) sformat(%6.2f) 
*stcox i.indextype age_index gender *_post dmdur, cformat(%6.2f) pformat(%5.3f) sformat(%6.2f)  
*stcox ib1.hba1c_cats_i2

stcox i.indextype age_indexdate gender dmdur ib2.prx_covvalue_g_i4 ib2.prx_covvalue_g_i5 ib1.hba1c_cats_i2 ib1.sbp_i_cats2 i.ckd_amdrd i.physician_vis2 i.unique_cov_drugs i.prx_ccivalue_g_i2 mi_i stroke_i hf_i arr_i ang_i revasc_i htn_i afib_i pvd_i statin_i calchan_i betablock_i anticoag_oral_i antiplat_i ace_arb_renin_i diuretics_all_i *_post indextype, cformat(%6.2f) pformat(%5.3f) sformat(%6.2f)  

*stphplot if indextype==1 | indextype==0 | indextype==2, by(indextype)
*stphplot if seconddate>=17167 & (indextype==1 | indextype==0 | indextype==2), by(indextype)
*estat phtest


stcox i.indextype age_indexdate gender dmdur ib2.prx_covvalue_g_i4 ib2.prx_covvalue_g_i5 ib1.hba1c_cats_i2 ib1.sbp_i_cats2 i.ckd_amdrd i.physician_vis2 i.unique_cov_drugs i.prx_ccivalue_g_i2 mi_i stroke_i hf_i arr_i ang_i revasc_i htn_i afib_i pvd_i statin_i calchan_i betablock_i anticoag_oral_i antiplat_i ace_arb_renin_i diuretics_all_i *_post, cformat(%6.2f) pformat(%5.3f) sformat(%6.2f)  
matrix b=r(table)
matrix c=b'
matrix list c
*matrix rownames c = SU DPP4I GLP1RA INS TZD OTH Age Male su_post dpp4i_post glp1ra_post tzd_post oth_post diabetes_duration HbA1c_<7 HbA1c_7_8 HbA1c_8_9 HbA1c_9_10 HbA1c_>10 HbA1c_unknown SBP_<120 SBP_130_139  SBP_140_149 SBP_150_159 SBP_160+ SBP_missing eGFR_90+ eGFR_60_89 eGFR_30_59 eGFR_15_29 eGFR_unknown Physician_visits_0_12  Physician_visits_13_24 Physician_visits_24+ Physician_visits_unknown No_unique_drugs_0_5 No_unique_drugs_6_10 No_unique_drugs_11_15 No_unique_drugs_16_20 No_unique_drugs_>20 Non_Smoker Unknown Current Former CCI=1 CCI=2 CCI=3+ MI Stroke HF Arrythmia Angina Revascularization HTN AFIB PVD Statin CCB BB Anticoag Antiplat RAS Diuretics
local matrownames "SU DPP4I GLP1RA INS TZD OTH Age Male diabetes_duration Unknown Current Non_Drinker Former Unknown Current Non_Smoker Former HbA1c_<7 HbA1c_7_8 HbA1c_8_9 HbA1c_9_10 HbA1c_>10 HbA1c_unknown SBP_<120 SBP_120_129 SBP_130_139  SBP_140_149 SBP_150_159 SBP_160+ SBP_missing eGFR_90+ eGFR_60_89 eGFR_30_59 eGFR_15_29 eGFR_<15 eGFR_unknown Physician_visits_0_12 Physician_visits_13_24 Physician_visits_24+ Physician_visits_unknown No_unique_drugs_0_5 No_unique_drugs_6_10 No_unique_drugs_11_15 No_unique_drugs_16_20 No_unique_drugs_>20 CCI=1 CCI=2 CCI=3+ MI Stroke HF Arrythmia Angina Revascularization HTN AFIB PVD Statin CCB BB Anticoag Antiplat RAS Diuretics su_post dpp4i_post glp1ra_post ins_post tzd_post oth_post"
forval i=1/69{
local x=`i'+1
local rowname:word `i' of `matrownames'
putexcel A1=("Variable") B1=("HR") C1=("SE") D1=("p-value") E1=("LL") F1=("UL") A`x'=("`rowname'") B`x'=(c[`i',1]) C`x'=(c[`i',2]) D`x'=(c[`i',4]) E`x'=(c[`i',5]) F`x'=(c[`i',6])using table2, sheet("Adjusted3") modify
}


// restrict to jan 1, 2007

stcox i.indextype age_indexdate gender dmdur ib2.prx_covvalue_g_i4 ib2.prx_covvalue_g_i5 ib1.hba1c_cats_i2 ib1.sbp_i_cats2 i.ckd_amdrd i.physician_vis2 i.unique_cov_drugs i.prx_ccivalue_g_i2 mi_i stroke_i hf_i arr_i ang_i revasc_i htn_i afib_i pvd_i statin_i calchan_i betablock_i anticoag_oral_i antiplat_i ace_arb_renin_i diuretics_all_i *_post if seconddate>=17167, cformat(%6.2f) pformat(%5.3f) sformat(%6.2f)  
matrix b=r(table)
matrix c=b'
matrix list c
*matrix rownames c = SU DPP4I GLP1RA INS TZD OTH Age Male su_post dpp4i_post glp1ra_post tzd_post oth_post diabetes_duration HbA1c_<7 HbA1c_7_8 HbA1c_8_9 HbA1c_9_10 HbA1c_>10 HbA1c_unknown SBP_<120 SBP_130_139  SBP_140_149 SBP_150_159 SBP_160+ SBP_missing eGFR_90+ eGFR_60_89 eGFR_30_59 eGFR_15_29 eGFR_unknown Physician_visits_0_12  Physician_visits_13_24 Physician_visits_24+ Physician_visits_unknown No_unique_drugs_0_5 No_unique_drugs_6_10 No_unique_drugs_11_15 No_unique_drugs_16_20 No_unique_drugs_>20 Non_Smoker Unknown Current Former CCI=1 CCI=2 CCI=3+ MI Stroke HF Arrythmia Angina Revascularization HTN AFIB PVD Statin CCB BB Anticoag Antiplat RAS Diuretics
local matrownames "SU DPP4I GLP1RA INS TZD OTH Age Male diabetes_duration Unknown Current Non_Drinker Former Unknown Current Non_Smoker Former HbA1c_<7 HbA1c_7_8 HbA1c_8_9 HbA1c_9_10 HbA1c_>10 HbA1c_unknown SBP_<120 SBP_120_129 SBP_130_139  SBP_140_149 SBP_150_159 SBP_160+ SBP_missing eGFR_90+ eGFR_60_89 eGFR_30_59 eGFR_15_29 eGFR_<15 eGFR_unknown Physician_visits_0_12 Physician_visits_13_24 Physician_visits_24+ Physician_visits_unknown No_unique_drugs_0_5 No_unique_drugs_6_10 No_unique_drugs_11_15 No_unique_drugs_16_20 No_unique_drugs_>20 CCI=1 CCI=2 CCI=3+ MI Stroke HF Arrythmia Angina Revascularization HTN AFIB PVD Statin CCB BB Anticoag Antiplat RAS Diuretics su_post dpp4i_post glp1ra_post ins_post tzd_post oth_post"
forval i=1/69{
local x=`i'+1
local rowname:word `i' of `matrownames'
putexcel A1=("Variable") B1=("HR") C1=("SE") D1=("p-value") E1=("LL") F1=("UL") A`x'=("`rowname'") B`x'=(c[`i',1]) C`x'=(c[`i',2]) D`x'=(c[`i',4]) E`x'=(c[`i',5]) F`x'=(c[`i',6])using table2b, sheet("Adjusted3") modify
}


// # 3 Any exposure after metformin monotherapy

use Analytic_Dataset_Master, clear
do Data13_variable_generation.do
drop if gest_diab==1|pcos==1|preg==1|age_indexdate<=29
replace ever1=0 if ever1==.
replace ever2=0 if ever2==.

//Create table1 
//Sociodemographics
label var age_index "Age at index date"
label var age_cat "Age"
label var gender "Sex"
label var maritalstatus "Marital Status"
label var imd2010_5 "Measure of Deprivation"
label var dmdur "Duration of treated diabetes"
label var prx_covvalue_g_i4 "Alcoholism"
label var prx_covvalue_g_i5 "Smoking Status"
label var bmi_i_cats "BMI"
label var physician_vis "No. of Physician Visits"
label var prx_ccivalue_g_i2 "Charlson Comorbidity Index"
label var ang_i "Angina"
label var arr_i "Arryhthmia"
label var afib_i "Atrial Fibrillation"
label var hf_i "Heart Failure"
label var htn_i "Hypertension"
label var mi_i "Myocardial Infarction"
label var pvd_i "Peripheral Vascular Disease"
label var stroke_i "Stroke"
label var revasc_i "Revascularization Procedure"
label var hba1c_i "HbA1c continuous"
label var hba1c_cats_i "HbA1c categories"
label var prx_covvalue_g_i3 "Systolic Blood Pressure"
label var sbp_i_cats2 "Systolic Blood Pressure categories"
label var ckd_amdrd "eGFR categories"
label var egfr_amdrd "eGFR"
label var unique_cov_drugs "No unique drugs"
label var statin_i "Statins"
label var calchan_i "Calcium Channel Blockers"
label var betablock_i "Beta-Blockers"
label var anticoag_oral_i "Anticoagulants"
label var antiplat_i "Antiplatelets"
label var ace_arb_renin_i "ACE/ARB/Renin"
label var diuretics_all_i "Diuretics"
label var unqrx "No unique antidiabetic agents"
label var ever1 "Ever Use of DPP4i"
label var ever2 "Ever Use of GLP1RA"



table1, by(ever1) vars(age_indexdate contn \ age_cat cat \ gender cat \ imd2010_5 cat \ dmdur contn \ prx_covvalue_g_i4 cat \ prx_covvalue_g_i5 cat \ bmi_i_cats cat \ physician_vis2 cat \ ang_i bin \ arr_i bin \ afib_i bin \ hf_i bin \ htn_i bin \ mi_i bin \ pvd_i bin \ stroke_i bin \ revasc_i bin \ prx_ccivalue_g_i2 cat \ hba1c_i contn \ hba1c_cats_i cat \ prx_covvalue_g_i3 contn \ sbp_i_cats2 cat \ egfr_amdrd contn \ ckd_amdrd cat \ unique_cov_drugs cat \ unqrx2 cat \ statin_i bin \ calchan_i bin \ betablock_i bin \ anticoag_oral_i bin \ antiplat_i bin \ ace_arb_renin_i bin \ diuretics_all_i bin) onecol format(%9.2g) saving(table1c.xls, replace)
table1 if seconddate>=17167, by(ever1) vars(age_indexdate contn \ age_cat cat \ gender cat \ imd2010_5 cat \ dmdur contn \ prx_covvalue_g_i4 cat \ prx_covvalue_g_i5 cat \ bmi_i_cats cat \ physician_vis2 cat \ ang_i bin \ arr_i bin \ afib_i bin \ hf_i bin \ htn_i bin \ mi_i bin \ pvd_i bin \ stroke_i bin \ revasc_i bin \ prx_ccivalue_g_i2 cat \ hba1c_i contn \ hba1c_cats_i cat \ prx_covvalue_g_i3 contn \ sbp_i_cats2 cat \ egfr_amdrd contn \ ckd_amdrd cat \ unique_cov_drugs cat \ unqrx2 cat \ statin_i bin \ calchan_i bin \ betablock_i bin \ anticoag_oral_i bin \ antiplat_i bin \ ace_arb_renin_i bin \ diuretics_all_i bin) onecol format(%9.2g) saving(table1d.xls, replace)
table1, by(ever2) vars(age_indexdate contn \ age_cat cat \ gender cat \ imd2010_5 cat \ dmdur contn \ prx_covvalue_g_i4 cat \ prx_covvalue_g_i5 cat \ bmi_i_cats cat \ physician_vis2 cat \ ang_i bin \ arr_i bin \ afib_i bin \ hf_i bin \ htn_i bin \ mi_i bin \ pvd_i bin \ stroke_i bin \ revasc_i bin \ prx_ccivalue_g_i2 cat \ hba1c_i contn \ hba1c_cats_i cat \ prx_covvalue_g_i3 contn \ sbp_i_cats2 cat \ egfr_amdrd contn \ ckd_amdrd cat \ unique_cov_drugs cat \ unqrx2 cat \ statin_i bin \ calchan_i bin \ betablock_i bin \ anticoag_oral_i bin \ antiplat_i bin \ ace_arb_renin_i bin \ diuretics_all_i bin) onecol format(%9.2g) saving(table1e.xls, replace)
table1 if seconddate>=17167, by(ever2) vars(age_indexdate contn \ age_cat cat \ gender cat \ imd2010_5 cat \ dmdur contn \ prx_covvalue_g_i4 cat \ prx_covvalue_g_i5 cat \ bmi_i_cats cat \ physician_vis2 cat \ ang_i bin \ arr_i bin \ afib_i bin \ hf_i bin \ htn_i bin \ mi_i bin \ pvd_i bin \ stroke_i bin \ revasc_i bin \ prx_ccivalue_g_i2 cat \ hba1c_i contn \ hba1c_cats_i cat \ prx_covvalue_g_i3 contn \ sbp_i_cats2 cat \ egfr_amdrd contn \ ckd_amdrd cat \ unique_cov_drugs cat \ unqrx2 cat \ statin_i bin \ calchan_i bin \ betablock_i bin \ anticoag_oral_i bin \ antiplat_i bin \ ace_arb_renin_i bin \ diuretics_all_i bin) onecol format(%9.2g) saving(table1f.xls, replace)

// 2x2 tables with exposure and outcomes

tab ever1 acm, row
tab ever1 acm if seconddate>=17167, row

tab ever2 acm, row
tab ever2 acm if seconddate>=17167, row

// declare survival analysis - final exposure as last exposure date 
stset acm_exit, fail(allcausemort) id(patid) origin(firstadmrxdate) scale(365.25)

/*
// spit data to integrate time-varying covariates for diabetes meds.
stsplit adm3, at(0(1)max) after(thirddate)
gen su_post=(indextype3==0 & adm3!=-1)
gen dpp4i_post=(indextype3==1 & adm3!=-1)
gen glp1ra_post=(indextype3==2 & adm3!=-1)
gen ins_post=(indextype3==3  & adm3!=-1)
gen tzd_post=(indextype3==4 & adm3!=-1)
gen oth_post=(indextype3==5  & adm3!=-1)

stsplit adm4, at(0(1)max) after(fourthdate)
replace su_post=1 if indextype4==0 & adm4!=-1
replace dpp4i_post=1 if indextype4==1 & adm4!=-1
replace glp1ra_post=1 if indextype4==2 & adm4!=-1
replace ins_post=1 if indextype4==3 & adm4!=-1
replace tzd_post=1 if indextype4==4 & adm4!=-1
replace oth_post=1 if indextype4==5 & adm4!=-1

stsplit adm5, at(0(1)max) after(fifthdate)
replace su_post=1 if indextype5==0 & adm5!=-1
replace dpp4i_post=1 if indextype5==1 & adm5!=-1
replace glp1ra_post=1 if indextype5==2 & adm5!=-1
replace ins_post=1 if indextype5==3 & adm5!=-1
replace tzd_post=1 if indextype5==4 & adm5!=-1
replace oth_post=1 if indextype5==5 & adm5!=-1

stsplit adm6, at(0(1)max) after(sixthdate)
replace su_post=1 if indextype6==0 & adm6!=-1
replace dpp4i_post=1 if indextype6==1 & adm6!=-1
replace glp1ra_post=1 if indextype6==2 & adm6!=-1
replace ins_post=1 if indextype6==3 & adm6!=-1
replace tzd_post=1 if indextype6==4 & adm6!=-1
replace oth_post=1 if indextype6==5 & adm6!=-1

stsplit adm7, at(0(1)max) after(seventhdate)
replace su_post=1 if indextype7==0 & adm7!=-1
replace dpp4i_post=1 if indextype7==1 & adm7!=-1
replace glp1ra_post=1 if indextype7==2 & adm7!=-1
replace ins_post=1 if indextype7==3 & adm7!=-1
replace tzd_post=1 if indextype7==4 & adm7!=-1
replace oth_post=1 if indextype7==5 & adm7!=-1

//Generate person-years, incidence rate, and 95%CI as well as hazard ratio
label var indextype "Exposure"
stptime, by(indextype) per(1000)
stcox i.indextype, cformat(%6.2f) pformat(%5.3f) sformat(%6.2f) 

*sts graph, by(indextype) 
*sts graph if seconddate>=17167, by(indextype) 
*stcurve, survival at1(indextype=0) at2(indextype=1) at3(indextype=2) at4(indextype=3) at5(indextype=4) at6(indextype=5)

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

// restrict to jan 1, 2007

stptime if seconddate>=17167, by(indextype) per(1000)
stcox i.indextype if seconddate>=17167, cformat(%6.2f) pformat(%5.3f) sformat(%6.2f) 

stptime if seconddate>=17167, by(indextype) per(1000)
putexcel A1= ("Indextype") B1=("Person-Time") C1=("Failures") D1=("Incidence Rate") E1=("Lower Bound") F1=("Upper Bound") G1=("Hazard Ratio") H1=("Lower Bound") I1=("Upper Bound") using table2b, sheet("Unadjusted") modify
forval i=0/5{
local row=`i'+2
stptime if indextype==`i'
putexcel A`row'= ("`i'") B`row'=(r(ptime)) C`row'=(r(failures)) D`row'=(r(rate)*1000) E`row'=(r(lb)*1000) F`row'=(r(ub)*1000) using table2b, sheet("Unadjusted") modify
}
forval i=1/5 {
local row=`i'+2
local matrow=`i'+1
stcox i.indextype if seconddate>=17167
matrix b=r(table)
matrix a= b'
putexcel G`row'=(a[`matrow',1]) H`row'=(a[`matrow',5]) I`row'=(a[`matrow',6]) using table2b, sheet("Unadjusted") modify
}


//Multivariable analysis 
*stcox i.indextype age_index gender, cformat(%6.2f) pformat(%5.3f) sformat(%6.2f) 
*stcox i.indextype age_index gender *_post, cformat(%6.2f) pformat(%5.3f) sformat(%6.2f) 
*stcox i.indextype age_index gender *_post dmdur, cformat(%6.2f) pformat(%5.3f) sformat(%6.2f)  
*stcox ib1.hba1c_cats_i2

stcox i.indextype age_indexdate gender dmdur ib2.prx_covvalue_g_i4 ib2.prx_covvalue_g_i5 ib1.hba1c_cats_i2 ib1.sbp_i_cats2 i.ckd_amdrd i.physician_vis2 i.unique_cov_drugs i.prx_ccivalue_g_i2 i.mi_i i.stroke_i i.hf_i i.arr_i i.ang_i i.revasc_i i.htn_i i.afib_i i.pvd_i i.ckd_amdrd i.statin_i i.calchan_i i.betablock_i i.anticoag_oral_i i.antiplat_i i.ace_arb_renin_i i.diuretics_all_i *_post, cformat(%6.2f) pformat(%5.3f) sformat(%6.2f)  

*stphplot if indextype==1 | indextype==0 | indextype==2, by(indextype)
*stphplot if seconddate>=17167 & (indextype==1 | indextype==0 | indextype==2), by(indextype)
*estat phtest


stcox i.indextype age_indexdate gender dmdur ib2.prx_covvalue_g_i4 ib2.prx_covvalue_g_i5 ib1.hba1c_cats_i2 ib1.sbp_i_cats2 i.ckd_amdrd i.physician_vis2 i.unique_cov_drugs i.prx_ccivalue_g_i2 mi_i stroke_i hf_i arr_i ang_i revasc_i htn_i afib_i pvd_i ckd_amdrd statin_i calchan_i betablock_i anticoag_oral_i antiplat_i ace_arb_renin_i diuretics_all_i *_post, cformat(%6.2f) pformat(%5.3f) sformat(%6.2f)  
matrix b=r(table)
matrix c=b'
matrix list c
*matrix rownames c = SU DPP4I GLP1RA INS TZD OTH Age Male su_post dpp4i_post glp1ra_post tzd_post oth_post diabetes_duration HbA1c_<7 HbA1c_7_8 HbA1c_8_9 HbA1c_9_10 HbA1c_>10 HbA1c_unknown SBP_<120 SBP_130_139  SBP_140_149 SBP_150_159 SBP_160+ SBP_missing eGFR_90+ eGFR_60_89 eGFR_30_59 eGFR_15_29 eGFR_unknown Physician_visits_0_12  Physician_visits_13_24 Physician_visits_24+ Physician_visits_unknown No_unique_drugs_0_5 No_unique_drugs_6_10 No_unique_drugs_11_15 No_unique_drugs_16_20 No_unique_drugs_>20 Non_Smoker Unknown Current Former CCI=1 CCI=2 CCI=3+ MI Stroke HF Arrythmia Angina Revascularization HTN AFIB PVD Statin CCB BB Anticoag Antiplat RAS Diuretics
local matrownames "SU DPP4I GLP1RA INS TZD OTH Age Male diabetes_duration Unknown Current Non_Drinker Former Unknown Current Non_Smoker Former HbA1c_<7 HbA1c_7_8 HbA1c_8_9 HbA1c_9_10 HbA1c_>10 HbA1c_unknown SBP_<120 SBP_120_129 SBP_130_139  SBP_140_149 SBP_150_159 SBP_160+ SBP_missing eGFR_90+ eGFR_60_89 eGFR_30_59 eGFR_15_29 eGFR_<15 eGFR_unknown Physician_visits_0_12 Physician_visits_13_24 Physician_visits_24+ Physician_visits_unknown No_unique_drugs_0_5 No_unique_drugs_6_10 No_unique_drugs_11_15 No_unique_drugs_16_20 No_unique_drugs_>20 CCI=1 CCI=2 CCI=3+ MI Stroke HF Arrythmia Angina Revascularization HTN AFIB PVD Statin CCB BB Anticoag Antiplat RAS Diuretics su_post dpp4i_post glp1ra_post ins_post tzd_post oth_post"
forval i=1/69{
local x=`i'+1
local rowname:word `i' of `matrownames'
putexcel A1=("Variable") B1=("HR") C1=("SE") D1=("p-value") E1=("LL") F1=("UL") A`x'=("`rowname'") B`x'=(c[`i',1]) C`x'=(c[`i',2]) D`x'=(c[`i',4]) E`x'=(c[`i',5]) F`x'=(c[`i',6])using table2, sheet("Adjusted") modify
}


// restrict to jan 1, 2007

stcox i.indextype age_indexdate gender dmdur ib2.prx_covvalue_g_i4 ib2.prx_covvalue_g_i5 ib1.hba1c_cats_i2 ib1.sbp_i_cats2 i.ckd_amdrd i.physician_vis2 i.unique_cov_drugs i.prx_ccivalue_g_i2 i.mi_i i.stroke_i i.hf_i i.arr_i i.ang_i i.revasc_i i.htn_i i.afib_i i.pvd_i i.ckd_amdrd i.statin_i i.calchan_i i.betablock_i i.anticoag_oral_i i.antiplat_i i.ace_arb_renin_i i.diuretics_all_i *_post if seconddate>=17167, cformat(%6.2f) pformat(%5.3f) sformat(%6.2f)  
matrix b=r(table)
matrix c=b'
matrix list c
*matrix rownames c = SU DPP4I GLP1RA INS TZD OTH Age Male su_post dpp4i_post glp1ra_post tzd_post oth_post diabetes_duration HbA1c_<7 HbA1c_7_8 HbA1c_8_9 HbA1c_9_10 HbA1c_>10 HbA1c_unknown SBP_<120 SBP_130_139  SBP_140_149 SBP_150_159 SBP_160+ SBP_missing eGFR_90+ eGFR_60_89 eGFR_30_59 eGFR_15_29 eGFR_unknown Physician_visits_0_12  Physician_visits_13_24 Physician_visits_24+ Physician_visits_unknown No_unique_drugs_0_5 No_unique_drugs_6_10 No_unique_drugs_11_15 No_unique_drugs_16_20 No_unique_drugs_>20 Non_Smoker Unknown Current Former CCI=1 CCI=2 CCI=3+ MI Stroke HF Arrythmia Angina Revascularization HTN AFIB PVD Statin CCB BB Anticoag Antiplat RAS Diuretics
local matrownames "SU DPP4I GLP1RA INS TZD OTH Age Male diabetes_duration Unknown Current Non_Drinker Former Unknown Current Non_Smoker Former HbA1c_<7 HbA1c_7_8 HbA1c_8_9 HbA1c_9_10 HbA1c_>10 HbA1c_unknown SBP_<120 SBP_120_129 SBP_130_139  SBP_140_149 SBP_150_159 SBP_160+ SBP_missing eGFR_90+ eGFR_60_89 eGFR_30_59 eGFR_15_29 eGFR_<15 eGFR_unknown Physician_visits_0_12 Physician_visits_13_24 Physician_visits_24+ Physician_visits_unknown No_unique_drugs_0_5 No_unique_drugs_6_10 No_unique_drugs_11_15 No_unique_drugs_16_20 No_unique_drugs_>20 CCI=1 CCI=2 CCI=3+ MI Stroke HF Arrythmia Angina Revascularization HTN AFIB PVD Statin CCB BB Anticoag Antiplat RAS Diuretics su_post dpp4i_post glp1ra_post ins_post tzd_post oth_post"
forval i=1/69{
local x=`i'+1
local rowname:word `i' of `matrownames'
putexcel A1=("Variable") B1=("HR") C1=("SE") D1=("p-value") E1=("LL") F1=("UL") A`x'=("`rowname'") B`x'=(c[`i',1]) C`x'=(c[`i',2]) D`x'=(c[`i',4]) E`x'=(c[`i',5]) F`x'=(c[`i',6])using table2b, sheet("Adjusted") modify
}

timer off 1
log close
