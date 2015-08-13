//  program:    Stat_hf_tables.do
//  task:		Statistical analysis for all-cause mortality
//  project: 	Incretins--Comparative mortality and CV outcomes (CPRD)
//  author:     JM \ July 2015  
//				

clear all
capture log close Stat_hf
set more off
log using Stat_hf.smcl, name(Stat_hf) replace
timer on 1

use hf, clear

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

//Create table1 
table1, by(indextype) vars(age_indexdate contn \ age_cat cat \ gender cat \ imd2010_5 cat \ dmdur contn \ metoverlap contn \ prx_covvalue_g_i4 cat \ prx_covvalue_g_i5 cat \ bmi_i_cats cat \ physician_vis2 cat \ ang_i bin \ arr_i bin \ afib_i bin \ hf_i bin \ htn_i bin \ mi_i bin \ pvd_i bin \ stroke_i bin \ revasc_i bin \ prx_ccivalue_g_i2 cat \ hba1c_i contn \ hba1c_cats_i cat \ prx_covvalue_g_i3 contn \ sbp_i_cats2 cat \ egfr_amdrd contn \ ckd_amdrd cat \ unique_cov_drugs cat \ unqrx2 cat \ statin_i bin \ calchan_i bin \ betablock_i bin \ anticoag_oral_i bin \ antiplat_i bin \ ace_arb_renin_i bin \ diuretics_all_i bin) onecol format(%9.2g) saving(table1_hf.xls, replace)
table1 if linked_b==1, by(indextype) vars(age_indexdate contn \ age_cat cat \ gender cat \ imd2010_5 cat \ dmdur contn \ metoverlap contn \ prx_covvalue_g_i4 cat \ prx_covvalue_g_i5 cat \ bmi_i_cats cat \ physician_vis2 cat \ ang_i bin \ arr_i bin \ afib_i bin \ hf_i bin \ htn_i bin \ mi_i bin \ pvd_i bin \ stroke_i bin \ revasc_i bin \ prx_ccivalue_g_i2 cat \ hba1c_i contn \ hba1c_cats_i cat \ prx_covvalue_g_i3 contn \ sbp_i_cats2 cat \ egfr_amdrd contn \ ckd_amdrd cat \ unique_cov_drugs cat \ unqrx2 cat \ statin_i bin \ calchan_i bin \ betablock_i bin \ anticoag_oral_i bin \ antiplat_i bin \ ace_arb_renin_i bin \ diuretics_all_i bin) onecol format(%9.2g) saving(table1_linked_hf.xls, replace)

// 2x2 tables with exposure and outcome (death)
label var indextype "2nd-line Agent"
tab indextype hf, row
label var indextype3 "3rd-line Agent"
tab indextype3 hf, row
label var indextype4 "4th-line Agent"
tab indextype4 hf, row
tab indextype5 hf, row
tab indextype6 hf, row
tab indextype7 hf, row

//2x2 tables for each covariate to determine if events are too low to include any of them
foreach var of varlist age_65 gender dmdur_cat ckd_amdrd unique_cov_drugs prx_ccivalue_g_i2 mi_i stroke_i hf_i arr_i ang_i revasc_i htn_i afib_i pvd_i statin_i calchan_i betablock_i anticoag_oral_i antiplat_i ace_arb_renin_i diuretics_all_i bmi_i_cats sbp_i_cats2 hba1c_cats_i2 prx_covvalue_g_i4 {
tab indextype `var', row
}

// 2x2 tables with exposure and death, by baseline covariates
foreach var of varlist gender dmdur_cat prx_covvalue_g_i4 prx_covvalue_g_i5 bmi_i_cats hba1c_cats_i2 sbp_i_cats2 ///
	ckd_amdrd physician_vis2 unique_cov_drugs prx_ccivalue_g_i2 mi_i stroke_i hf_i arr_i ang_i revasc_i ///
	htn_i afib_i pvd_i statin_i calchan_i betablock_i anticoag_oral_i antiplat_i ace_arb_renin_i ///
	diuretics_all_i {
table indextype `var', contents(n hf mean hf) format(%6.2f) center col
	}

*******************************************************COX PROPORTIONAL HAZARDS REGRESSION*******************************************************
//COMPLETE CASE APPROACH
use Stat_hf_cc, clear

//Generate person-years, incidence rate, and 95%CI as well as hazard ratio
stptime, by(indextype) per(1000)
stcox i.indextype, cformat(%6.2f) pformat(%5.3f) sformat(%6.2f) 
stcox indextype_2 indextype_3 indextype_4 indextype_5 indextype_6, cformat(%6.2f) pformat(%5.3f) sformat(%6.2f) 

//Incidence, CC
putexcel A1= ("Indextype") B1=("Person-Time") C1=("Failures") D1=("Incidence Rate") E1=("Lower Bound") F1=("Upper Bound") G1=("Hazard Ratio") H1=("Lower Bound") I1=("Upper Bound") using table2_hf, sheet("Unadj Comp Case") modify
forval i=0/5{
 local row=`i'+2
 stptime if indextype==`i', per(1000)
 putexcel A`row'= ("`i'") B`row'=(r(ptime)) C`row'=(r(failures)) D`row'=(r(rate)*1000) E`row'=(r(lb)*1000) F`row'=(r(ub)*1000) using table2_hf, sheet("Unadj Comp Case") modify
}
//Unadjusted, CC
forval i=1/5 {
 local row=`i'+2
 local matrow=`i'+1
 stcox i.indextype 
 matrix b=r(table)
 matrix a= b'
 putexcel G`row'=(a[`matrow',1]) H`row'=(a[`matrow',5]) I`row'=(a[`matrow',6]) using table2_hf, sheet("Unadj Comp Case") modify
}
//Adjusted, CC
matrix b=r(table)
matrix c=b'
matrix list c
forval i=1/76{
 local x=`i'+2
 local rowname:word `i' of `matrownames'
 putexcel A1=("Variable") B1=("HR") C1=("SE") D1=("p-value") E1=("LL") F1=("UL") A`x'=("`rowname'") B`x'=(c[`i',1]) C`x'=(c[`i',2]) D`x'=(c[`i',4]) E`x'=(c[`i',5]) F`x'=(c[`i',6])using table2_hf, sheet("Adj Comp Case Ref0") modify
}
//Adjusted, CC, separated
stcox indextype_2 indextype_3 indextype_4 indextype_5 indextype_6 `mvmodel', cformat(%6.2f) pformat(%5.3f) sformat(%6.2f)  
matrix b=r(table)
matrix c=b'
matrix list c
forval i=1/75{
 local x=`i'+2
 local rowname:word `i' of `matrownames'
 putexcel A1=("Variable") B1=("HR") C1=("SE") D1=("p-value") E1=("LL") F1=("UL") A`x'=("`rowname'") B`x'=(c[`i',1]) C`x'=(c[`i',2]) D`x'=(c[`i',4]) E`x'=(c[`i',5]) F`x'=(c[`i',6])using table2_hf, sheet("Adj Comp Case Ref0Sep") modify
}
**********************************************************Change reference groups**********************************************************
//Adjusted, CC, Ref DPP
stcox ib1.indextype `mvmodel', cformat(%6.2f) pformat(%5.3f) sformat(%6.2f) 
matrix b=r(table)
matrix c=b'
matrix list c
forval i=1/76{
 local x=`i'+1
 local rowname:word `i' of `matrownames'
 putexcel A1=("Variable") B1=("HR") C1=("SE") D1=("p-value") E1=("LL") F1=("UL") A`x'=("`rowname'") B`x'=(c[`i',1]) C`x'=(c[`i',2]) D`x'=(c[`i',4]) E`x'=(c[`i',5]) F`x'=(c[`i',6])using table2_hf, sheet("Adj Comp Case Ref1") modify
}
//Adjusted, CC, Ref GLP
stcox ib2.indextype `mvmodel', cformat(%6.2f) pformat(%5.3f) sformat(%6.2f) 
matrix b=r(table)
matrix c=b'
matrix list c
forval i=1/76{
 local x=`i'+1
 local rowname:word `i' of `matrownames'
 putexcel A1=("Variable") B1=("HR") C1=("SE") D1=("p-value") E1=("LL") F1=("UL") A`x'=("`rowname'") B`x'=(c[`i',1]) C`x'=(c[`i',2]) D`x'=(c[`i',4]) E`x'=(c[`i',5]) F`x'=(c[`i',6])using table2_hf, sheet("Adj Comp Case Ref2") modify
}
//Adjusted, CC, Ref INS
stcox ib3.indextype `mvmodel', cformat(%6.2f) pformat(%5.3f) sformat(%6.2f)
matrix b=r(table)
matrix c=b'
matrix list c
forval i=1/76{
 local x=`i'+1
 local rowname:word `i' of `matrownames'
 putexcel A1=("Variable") B1=("HR") C1=("SE") D1=("p-value") E1=("LL") F1=("UL") A`x'=("`rowname'") B`x'=(c[`i',1]) C`x'=(c[`i',2]) D`x'=(c[`i',4]) E`x'=(c[`i',5]) F`x'=(c[`i',6])using table2_hf, sheet("Adj Comp Case Ref3") modify
} 
//Adjusted, CC, Ref TZD
stcox ib4.indextype `mvmodel', cformat(%6.2f) pformat(%5.3f) sformat(%6.2f)
matrix b=r(table)
matrix c=b'
matrix list c
forval i=1/76{
 local x=`i'+1
 local rowname:word `i' of `matrownames'
 putexcel A1=("Variable") B1=("HR") C1=("SE") D1=("p-value") E1=("LL") F1=("UL") A`x'=("`rowname'") B`x'=(c[`i',1]) C`x'=(c[`i',2]) D`x'=(c[`i',4]) E`x'=(c[`i',5]) F`x'=(c[`i',6])using table2_hf, sheet("Adj Comp Case Ref4") modify
} 

//MULTIPLE IMPUTATION APPROACH
use Stat_hf_mi, clear

//Incidence, MI
putexcel A1= ("Indextype") B1=("Person-Time") C1=("Failures") D1=("Incidence Rate") E1=("Lower Bound") F1=("Upper Bound") G1=("Hazard Ratio") H1=("Lower Bound") I1=("Upper Bound") using table2_hf, sheet("Unadj MI") modify
forval i=0/5{
 local row=`i'+2
 stptime if indextype==`i', per(1000)
 putexcel A`row'= ("`i'") B`row'=(r(ptime)) C`row'=(r(failures)) D`row'=(r(rate)*1000) E`row'=(r(lb)*1000) F`row'=(r(ub)*1000) using table2_hf, sheet("Unadj MI") modify
}
//Unadjusted, MI
forval i=1/5 {
 local row=`i'+2
 local matrow=`i'+1
 stcox i.indextype 
 matrix b=r(table)
 matrix a= b'
 putexcel G`row'=(a[`matrow',1]) H`row'=(a[`matrow',5]) I`row'=(a[`matrow',6]) using table2_hf, sheet("Unadj MI") modify
}
//Adjusted, MI
matrix b=r(table)
matrix c=b'
matrix list c
forval i=1/76{
 local x=`i'+2
 local rowname:word `i' of `matrownames'
 putexcel A1=("Variable") B1=("HR") C1=("SE") D1=("p-value") E1=("LL") F1=("UL") A`x'=("`rowname'") B`x'=(c[`i',1]) C`x'=(c[`i',2]) D`x'=(c[`i',4]) E`x'=(c[`i',5]) F`x'=(c[`i',6])using table2_hf, sheet("Adj MI Ref0") modify
}
//Adjusted, MI, separated
stcox indextype_2 indextype_3 indextype_4 indextype_5 indextype_6 `mvmodel', cformat(%6.2f) pformat(%5.3f) sformat(%6.2f)  
matrix b=r(table)
matrix c=b'
matrix list c
forval i=1/75{
 local x=`i'+2
 local rowname:word `i' of `matrownames'
 putexcel A1=("Variable") B1=("HR") C1=("SE") D1=("p-value") E1=("LL") F1=("UL") A`x'=("`rowname'") B`x'=(c[`i',1]) C`x'=(c[`i',2]) D`x'=(c[`i',4]) E`x'=(c[`i',5]) F`x'=(c[`i',6])using table2_hf, sheet("Adj MI Ref0Sep") modify
}
//Adjusted, MI
mi estimate, hr: stcox i.indextype `mvmodel_mi'
matrix b=r(table)
matrix c=b'
matrix list c
forval i=1/78{
 local x=`i'+2
 local rowname:word `i' of `matrownames_mi'
 putexcel A1=("Variable") B1=("HR") C1=("SE") D1=("p-value") E1=("LL") F1=("UL") A`x'=("`rowname'") B`x'=(c[`i',1]) C`x'=(c[`i',2]) D`x'=(c[`i',4]) E`x'=(c[`i',5]) F`x'=(c[`i',6])using table2_hf, sheet("Adj MI Ref0") modify
} 
********************************************Change reference groups using multiple imputation method********************************************
//Adjusted, MI, Ref DPP
mi estimate, hr: stcox ib1.indextype `mvmodel_mi', cformat(%6.2f) pformat(%5.3f) sformat(%6.2f)
matrix b=r(table)
matrix c=b'
matrix list c
forval i=1/78{
 local x=`i'+2
 local rowname:word `i' of `matrownames_mi'
 putexcel A1=("Variable") B1=("HR") C1=("SE") D1=("p-value") E1=("LL") F1=("UL") A`x'=("`rowname'") B`x'=(c[`i',1]) C`x'=(c[`i',2]) D`x'=(c[`i',4]) E`x'=(c[`i',5]) F`x'=(c[`i',6])using table2_hf, sheet("Adj MI Ref1") modify
}

//Adjusted, MI, Ref GLP
mi estimate, hr: stcox ib2.indextype `mvmodel_mi', cformat(%6.2f) pformat(%5.3f) sformat(%6.2f)
matrix b=r(table)
matrix c=b'
matrix list c
forval i=1/78{
 local x=`i'+2
 local rowname:word `i' of `matrownames_mi'
 putexcel A1=("Variable") B1=("HR") C1=("SE") D1=("p-value") E1=("LL") F1=("UL") A`x'=("`rowname'") B`x'=(c[`i',1]) C`x'=(c[`i',2]) D`x'=(c[`i',4]) E`x'=(c[`i',5]) F`x'=(c[`i',6])using table2_hf, sheet("Adj MI Ref2") modify
}

//Adjusted, MI, Ref Insulin
mi estimate, hr: stcox ib3.indextype `mvmodel_mi', cformat(%6.2f) pformat(%5.3f) sformat(%6.2f)
matrix b=r(table)
matrix c=b'
matrix list c
forval i=1/78{
 local x=`i'+2
 local rowname:word `i' of `matrownames_mi'
 putexcel A1=("Variable") B1=("HR") C1=("SE") D1=("p-value") E1=("LL") F1=("UL") A`x'=("`rowname'") B`x'=(c[`i',1]) C`x'=(c[`i',2]) D`x'=(c[`i',4]) E`x'=(c[`i',5]) F`x'=(c[`i',6])using table2_hf, sheet("Adj MI Ref3") modify
}

//Adjusted, MI, Ref TZD
mi estimate, hr: stcox ib4.indextype `mvmodel_mi', cformat(%6.2f) pformat(%5.3f) sformat(%6.2f)
matrix b=r(table)
matrix c=b'
matrix list c
forval i=1/78{
 local x=`i'+2
 local rowname:word `i' of `matrownames_mi'
 putexcel A1=("Variable") B1=("HR") C1=("SE") D1=("p-value") E1=("LL") F1=("UL") A`x'=("`rowname'") B`x'=(c[`i',1]) C`x'=(c[`i',2]) D`x'=(c[`i',4]) E`x'=(c[`i',5]) F`x'=(c[`i',6])using table2_hf, sheet("Adj MI Ref4") modify
}
********************************************Re-analyze for CPRD only******************************************** 
use Stat_hf_mi, clear
keep if linked_b!=1
egen hf_exit_g = rowmin(tod2 deathdate2 lcd2)
mi stset hf_exit_g, fail(hf) id(patid) origin(seconddate) scale(365.25)
mi estimate, hr: stcox i.indextype `mvmodel_mi', cformat(%6.2f) pformat(%5.3f) sformat(%6.2f)  
matrix b=r(table)
matrix c=b'
matrix list c
forval i=1/76{
 local x=`i'+1
 local rowname:word `i' of `matrownames_mi'
 putexcel A1=("Variable") B1=("HR") C1=("SE") D1=("p-value") E1=("LL") F1=("UL") A`x'=("`rowname'") B`x'=(c[`i',1]) C`x'=(c[`i',2]) D`x'=(c[`i',4]) E`x'=(c[`i',5]) F`x'=(c[`i',6])using table2_hf, sheet("Adj CPRD Only MI") modify
}
********************************************Re-analyze if HES linked********************************************
use Stat_hf_mi, clear
keep if linked_b==1
egen hf_exit_g = rowmin(tod2 deathdate2 dod2 lcd2)
mi stset hf_exit_g, fail(hf) id(patid) origin(seconddate) scale(365.25)
mi estimate, hr: stcox i.indextype `mvmodel_mi', cformat(%6.2f) pformat(%5.3f) sformat(%6.2f)  
matrix b=r(table)
matrix c=b'
matrix list c
forval i=1/79{
 local x=`i'+1
 local rowname:word `i' of `matrownames_mi'
 putexcel A1=("Variable") B1=("HR") C1=("SE") D1=("p-value") E1=("LL") F1=("UL") A`x'=("`rowname'") B`x'=(c[`i',1]) C`x'=(c[`i',2]) D`x'=(c[`i',4]) E`x'=(c[`i',5]) F`x'=(c[`i',6])using table2_hf, sheet("Adj HES Only MI") modify
}

*******************************************************SENSITIVITY ANALYSIS*******************************************************

// #1a. CENSOR EXPSOURE AT FIRST GAP FOR THE FIRST SWITCH/ADD AGENT (INDEXTYPE)
use hf, clear
 
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

//update censor times for last continuous exposure to second-line agent (indextype)
 forval i=0/5 {
 replace hf_exit = exposuret1`i' if indextype==`i' & exposuret1`i'!=.
}
replace hf=0 if hf_exit<death_date

//declare survival analysis - last continuous exposure as last exposure date 
stset hf_exit, fail(hf) id(patid) origin(seconddate) scale(365.25)

// Multiple imputation
//put data in mlong form such that complete rows are omitted and only incomplete and imputed rows are shown
mi set mlong
clonevar hba1c_cats_i2_clone = hba1c_cats_i2
replace hba1c_cats_i2_clone=. if hba1c_cats_i2==5
clonevar prx_covvalue_g_i4_clone = prx_covvalue_g_i4
replace prx_covvalue_g_i4_clone=. if prx_covvalue_g_i4==0
//inform mi which variables contain missing values for which we want to impute (bmi_i and sbp)
mi register imputed bmi_i sbp hba1c_cats_i2_clone prx_covvalue_g_i4_clone
//set the seed so that results are reproducible
set seed 1979
//impute (20 iterations) for each missing value in the registered variables
mi impute chained (regress) bmi_i sbp (mlogit) prx_covvalue_g_i4_clone hba1c_cats_i2_clone = hf `demo2' `comorb2' `meds3' `clin3', add(5) force

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

save Stat_hf_mi_index, replace

mi xeq: stptime, by(indextype) per(1000)

//fit the model separately on each of the 20 imputed datasets and combine results
mi estimate, hr: stcox i.indextype `mvmodel_mi'

//Unadjusted MI
mi xeq: stptime, title(person-years) per(1000)
mi estimate, hr: stcox i.indextype, cformat(%6.2f) pformat(%5.3f) sformat(%6.2f) 
putexcel A1= ("Indextype") B1=("Person-Time") C1=("Failures") D1=("Incidence Rate") E1=("Lower Bound") F1=("Upper Bound") G1=("Hazard Ratio") H1=("Lower Bound") I1=("Upper Bound") using table2_hf, sheet("Unadj MI Gap1") modify
forval i=0/5{
 local row=`i'+2
 mi xeq: stptime if indextype==`i'
 putexcel A`row'= ("`i'") B`row'=(r(ptime)) C`row'=(r(failures)) D`row'=(r(rate)*1000) E`row'=(r(lb)*1000) F`row'=(r(ub)*1000) using table2_hf, sheet("Unadj MI Gap1") modify
}

forval i=1/5 {
 local row=`i'+2
 local matrow=`i'+1
 mi estimate, hr: stcox i.indextype 
 matrix b=r(table)
 matrix a= b'
 putexcel G`row'=(a[`matrow',1]) H`row'=(a[`matrow',5]) I`row'=(a[`matrow',6]) using table2_hf, sheet("Unadj MI Gap1") modify
}

//Multivariable analysis MI
mi estimate, hr: stcox i.indextype `mvmodel_mi2', cformat(%6.2f) pformat(%5.3f) sformat(%6.2f)  
matrix b=r(table)
matrix c=b'
matrix list c
forval i=1/79{
 local x=`i'+1
 local rowname:word `i' of `matrownames_mi2'
 putexcel A1=("Variable") B1=("HR") C1=("SE") D1=("p-value") E1=("LL") F1=("UL") A`x'=("`rowname'") B`x'=(c[`i',1]) C`x'=(c[`i',2]) D`x'=(c[`i',4]) E`x'=(c[`i',5]) F`x'=(c[`i',6])using table2_hf, sheet("Adj MI Gap1") modify
}

//********************************************************************************************************************************//

//#2a. CENSOR EXPSOURE AT INDEXTYPE3
use hf, clear

//generate macros
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
local mvmodel_mi2 = "age_indexdate gender dmdur metoverlap i.ckd_amdrd i.unique_cov_drugs i.prx_ccivalue_g_i2 cvd_i statin_i calchan_i betablock_i anticoag_oral_i antiplat_i ace_arb_renin_i diuretics_all_i bmi_i sbp ib1.hba1c_cats_i2_clone ib2.prx_covvalue_g_i4_clone i.physician_vis2"
local matrownames_mi2 "SU DPP4I GLP1RA INS TZD OTH Age Male diabetes_duration Metformin_overlap eGFR_90+ eGFR_60_89 eGFR_30_59 eGFR_15_29 eGFR_<15 eGFR_unknown No_unique_drugs_0_5 No_unique_drugs_6_10 No_unique_drugs_11_15 No_unique_drugs_16_20 No_unique_drugs_>20 CCI=1 CCI=2 CCI=3+ CVD Statin CCB BB Anticoag Antiplat RAS Diuretics BMI SBP HbA1c_<7 HbA1c_7_8 HbA1c_8_9 HbA1c_9_10 HbA1c_>10 HbA1c_unknown Unknown Current Non_Smoker Former PhysVis_12 PhysVis_24 PhysVis_24plus"

//update censor times for single agent exposure to a thirddate

forval i=0/5 {
 gen censor2 = exposuretf`i' if indextype==`i' & exposuretf`i'!=.
 gen censor3 = exposuret0`i' if indextype3==`i' & exposuret0`i'!=.
 egen censordate = rowmin(censor2 censor3)
 replace hf_exit = censordate
 drop censor2 censor3 censordate
}

//reset hf to zero patient is censored before the death event
replace hf=0 if hf_exit<death_date

// declare survival analysis for single agent exposure to thirddate
stset hf_exit, fail(hf) id(patid) origin(seconddate) scale(365.25)

// Multiple imputation
//put data in mlong form such that complete rows are omitted and only incomplete and imputed rows are shown
mi set mlong
save hf_mlong, replace
clonevar hba1c_cats_i2_clone = hba1c_cats_i2
replace hba1c_cats_i2_clone=. if hba1c_cats_i2==5
clonevar prx_covvalue_g_i4_clone = prx_covvalue_g_i4
replace prx_covvalue_g_i4_clone=. if prx_covvalue_g_i4==0
//inform mi which variables contain missing values for which we want to timpute (bmi_i and sbp)
mi register imputed bmi_i sbp prx_covvalue_g_i4_clone hba1c_cats_i2_clone
//set the seed so that results are reproducible
set seed 1979
//impute (20 iterations) for each missing value in the registered variables
mi impute chained (regress) bmi_i sbp (mlogit) hba1c_cats_i2_clone prx_covvalue_g_i4_clone = hf `demo2' `comorb2' `meds3' `clin3', add(20) noisily
//Generate hazard ratios
mi estimate, hr: stcox i.indextype, cformat(%6.2f) pformat(%5.3f) sformat(%6.2f) 

save Stat_hf_mi_index3, replace

mi xeq: stptime, title(person-years) per(1000)
putexcel A1= ("Indextype") B1=("Person-Time") C1=("Failures") D1=("Incidence Rate") E1=("Lower Bound") F1=("Upper Bound") G1=("Hazard Ratio") H1=("Lower Bound") I1=("Upper Bound") using table2_hf, sheet("Unadj Agent3") modify
forval i=0/5{
local row=`i'+2
mi xeq: stptime if indextype==`i'
putexcel A`row'= ("`i'") B`row'=(r(ptime)) C`row'=(r(failures)) D`row'=(r(rate)*1000) E`row'=(r(lb)*1000) F`row'=(r(ub)*1000) using table2_hf, sheet("Unadj MI Agent3") modify
}

forval i=1/5 {
 local row=`i'+2
 local matrow=`i'+1
 mi estimate, hr: stcox i.indextype
 matrix b=r(table)
 matrix a= b'
 putexcel G`row'=(a[`matrow',1]) H`row'=(a[`matrow',5]) I`row'=(a[`matrow',6]) using table2_hf, sheet("Unadj MI Agent3") modify
}

//Multivariable analysis
mi estimate, hr: stcox i.indextype `mvmodel_mi2', cformat(%6.2f) pformat(%5.3f) sformat(%6.2f)  
matrix b=r(table)
matrix c=b'
matrix list c
forval i=1/79{
 local x=`i'+1
 local rowname:word `i' of `matrownames_mi2'
 putexcel A1=("Variable") B1=("HR") C1=("SE") D1=("p-value") E1=("LL") F1=("UL") A`x'=("`rowname'") B`x'=(c[`i',1]) C`x'=(c[`i',2]) D`x'=(c[`i',4]) E`x'=(c[`i',5]) F`x'=(c[`i',6])using table2_hf, sheet("Adj MI Agent3") modify
}

/*

Sensitivity Analyses Plots

use SensitivityGraphs, clear

capture label drop subgroupcats

label define subgroupcats 1 "DPP" 2 "GLP1RA" 3 "Insulin" 4 "TZD" 5 "Other"

capture rename subgroup Subgroup

label values Subgroup subgroupcats

capture label drop periodcats

label define periodcats 1 "Index to last" 2 "Index to last continuous" 3 "Index to switch/add" 4 "Index or later exposure" 

capture rename period Period

label values Period periodcats

metan hr ll ul, force by(Subgroup) nowt nobox nooverall nosubgroup null(1) scheme(s1mono) xlabel(0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10) lcols(Period) effect("Hazard Ratio") saving(SensGrph, asis replace)

*/

//********************************************************************************************************************************//

//#3 ANY EXPOSURE AFTER METFORMIN
use hf, clear

//generate macros
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

//declare data as survival dataset
stset hf_exit, fail(hf) id(patid) origin(seconddate)

// Multiple imputation
//put data in mlong form such that complete rows are omitted and only incomplete and imputed rows are shown
mi set mlong
save hf_mlong, replace
clonevar hba1c_cats_i2_clone = hba1c_cats_i2
replace hba1c_cats_i2_clone=. if hba1c_cats_i2==5
clonevar prx_covvalue_g_i4_clone = prx_covvalue_g_i4
replace prx_covvalue_g_i4_clone=. if prx_covvalue_g_i4==0
//inform mi which variables contain missing values for which we want to timpute (bmi_i and sbp)
mi register imputed bmi_i sbp prx_covvalue_g_i4_clone hba1c_cats_i2_clone
//set the seed so that results are reproducible
set seed 1979
//impute (20 iterations) for each missing value in the registered variables
mi impute chained (regress) bmi_i sbp (mlogit) prx_covvalue_g_i4_clone hba1c_cats_i2_clone = hf `demo2' `comorb2' `meds3' `clin3', add(20)
//fit the model separately on each of the 20 imputed datasets and combine results
mi estimate, hr: stcox i.indextype `mvmodel_mi2'

matrix b=r(table)
matrix c=b'
matrix list c
forval i=1/78{
 local x=`i'+2
 local rowname:word `i' of `matrownames_mi2'
 putexcel A1=("Variable") B1=("HR") C1=("SE") D1=("p-value") E1=("LL") F1=("UL") A`x'=("`rowname'") B`x'=(c[`i',1]) C`x'=(c[`i',2]) D`x'=(c[`i',4]) E`x'=(c[`i',5]) F`x'=(c[`i',6])using table2_hf, sheet("Adj MI Any Aft") modify
}

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

mi estimate, hr: stcox i.indextype, cformat(%6.2f) pformat(%5.3f) sformat(%6.2f) 

save Stat_hf_mi_any, replace

timer off 1
log close Stat_hf



