//  program:    Stat_hf_tables.do
//  task:		Statistical analysis for all-cause mortality
//  project: 	Incretins--Comparative mortality and CV outcomes (CPRD)
//  author:     JM \ July 2015  
//				

clear all
capture log close Stat_hf_tables
set more off
log using Stat_hf_tables.smcl, name(Stat_hf_tables) replace
timer on 1

use hf, clear

//Create macros
//mvmodel includes: demo, comorb2, meds and clin
local mvmodel = "age_indexdate gender ib2.smokestatus ib1.hba1c_cats_i2 i.ckd_amdrd bmi_i sbp i.physician_vis2 i.prx_ccivalue_g_i2 cvd_i dmdur metoverlap i.unique_cov_drugs statin_i calchan_i betablock_i anticoag_oral_i antiplat_i ace_arb_renin_i diuretics_all_i su_post dpp4i_post glp1ra_post ins_post tzd_post oth_post"
local matrownames "SU DPP4I GLP1RA INS TZD OTH Age Male Unknown Current Non_Smoker Former HbA1c_<7 HbA1c_7_8 HbA1c_8_9 HbA1c_9_10 HbA1c_>10 HbA1c_unknown eGFR_90+ eGFR_60_89 eGFR_30_59 eGFR_15_29 eGFR_<15 eGFR_unknown BMI SBP PhysVis_12 PhysVis_24 PhysVis_24plus CCI=1 CCI=2 CCI=3+ CVD diabetes_duration Metformin_overlap No_unique_drugs_0_5 No_unique_drugs_6_10 No_unique_drugs_>10 Statin CCB BB Anticoag Antiplat RAS Diuretics su_post dpp4i_post glp1ra_post ins_post tzd_post oth_post"
//mvmodel_mi includes: demoMI, comorb2 meds2, clinMI (only differences between mvmodel and mvmodel_mi are the imputed variables and removal of *_post for collinearity)
local mvmodel_mi = "age_indexdate gender ib2.smokestatus_clone ib1.hba1c_cats_i2_clone i.ckd_amdrd bmi_i sbp i.physician_vis2 i.prx_ccivalue_g_i2 cvd_i dmdur metoverlap i.unique_cov_drugs statin_i calchan_i betablock_i anticoag_oral_i antiplat_i ace_arb_renin_i diuretics_all_i su_post dpp4i_post glp1ra_post ins_post tzd_post oth_post"
local matrownames_mi "SU DPP4I GLP1RA INS TZD OTH Age Male Current Non_Smoker Former HbA1c_<7 HbA1c_7_8 HbA1c_8_9 HbA1c_9_10 HbA1c_>10 eGFR_90+ eGFR_60_89 eGFR_30_59 eGFR_15_29 eGFR_<15 eGFR_unknown BMI SBP PhysVis_12 PhysVis_24 PhysVis_24plus CCI=1 CCI=2 CCI=3+ CVD diabetes_duration Metformin_overlap No_unique_drugs_0_5 No_unique_drugs_6_10 No_unique_drugs_>10 Statin CCB BB Anticoag Antiplat RAS Diuretics su_post dpp4i_post glp1ra_post ins_post tzd_post oth_post"


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

//SENSITIVITY ANALYSIS
//#1 Censor at first gap
use Stat_hf_mi_index, clear

//Unadjusted first gap multiple imputation
mi xeq: stptime, title(person-years) per(1000)
mi estimate, hr: stcox i.indextype, cformat(%6.2f) pformat(%5.3f) sformat(%6.2f) 
putexcel A1= ("Indextype") B1=("Person-Time") C1=("Failures") D1=("Incidence Rate") E1=("Lower Bound") F1=("Upper Bound") G1=("Hazard Ratio") H1=("Lower Bound") I1=("Upper Bound") using table2_hf, sheet("Unadj MI Gap1") modify
forval i=0/5{
local row=`i'+2
mi xeq 1: stptime if indextype==`i'
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

//Fully adjusted first gap multiple imputation
mi estimate, hr: stcox i.indextype `mvmodel_mi', cformat(%6.2f) pformat(%5.3f) sformat(%6.2f)  
matrix b=r(table)
matrix c=b'
matrix list c
forval i=1/45{
local x=`i'+1
local rowname:word `i' of `matrownames_mi'
putexcel A1=("Variable") B1=("HR") C1=("SE") D1=("p-value") E1=("LL") F1=("UL") A`x'=("`rowname'") B`x'=(c[`i',1]) C`x'=(c[`i',2]) D`x'=(c[`i',4]) E`x'=(c[`i',5]) F`x'=(c[`i',6])using table2_hf, sheet("Adj MI Gap1") modify
}

//#2 Censor at first switch/add AFTER indexdate
use Stat_hf_mi_index3, clear
//Unadjusted at indextype3 multiple imputation
mi estimate, hr: stcox i.indextype, cformat(%6.2f) pformat(%5.3f) sformat(%6.2f) 
mi xeq 1: stptime, title(person-years) per(1000)
putexcel A1= ("Indextype") B1=("Person-Time") C1=("Failures") D1=("Incidence Rate") E1=("Lower Bound") F1=("Upper Bound") G1=("Hazard Ratio") H1=("Lower Bound") I1=("Upper Bound") using table2_hf, sheet("Unadj MI Agent3") modify
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

//Multivariable analysis at indextype3 multiple impuatation
mi estimate, hr: stcox i.indextype `mvmodel_mi', cformat(%6.2f) pformat(%5.3f) sformat(%6.2f)  
matrix b=r(table)
matrix c=b'
matrix list c
forval i=1/45{
local x=`i'+1
local rowname:word `i' of `matrownames_mi'
putexcel A1=("Variable") B1=("HR") C1=("SE") D1=("p-value") E1=("LL") F1=("UL") A`x'=("`rowname'") B`x'=(c[`i',1]) C`x'=(c[`i',2]) D`x'=(c[`i',4]) E`x'=(c[`i',5]) F`x'=(c[`i',6])using table2_hf, sheet("Adj MI Agent3") modify
}

//#3 Any exposure after metformin
use Stat_hf_mi_any, clear 
//Unadjusted any after metformin multiple imputation
mi estimate, hr: stcox i.indextype, cformat(%6.2f) pformat(%5.3f) sformat(%6.2f) 
mi xeq 1: stptime, title(person-years) per(1000)
putexcel A1= ("Indextype") B1=("Person-Time") C1=("Failures") D1=("Incidence Rate") E1=("Lower Bound") F1=("Upper Bound") G1=("Hazard Ratio") H1=("Lower Bound") I1=("Upper Bound") using table2_hf, sheet("Unadj MI Any Aft") modify
forval i=0/5{
local row=`i'+2
mi xeq: stptime if indextype==`i'
putexcel A`row'= ("`i'") B`row'=(r(ptime)) C`row'=(r(failures)) D`row'=(r(rate)*1000) E`row'=(r(lb)*1000) F`row'=(r(ub)*1000) using table2_hf, sheet("Unadj MI Any Aft") modify
}
forval i=1/5 {
local row=`i'+2
local matrow=`i'+1
mi estimate, hr: stcox i.indextype
matrix b=r(table)
matrix a= b'
putexcel G`row'=(a[`matrow',1]) H`row'=(a[`matrow',5]) I`row'=(a[`matrow',6]) using table2_hf, sheet("Unadj MI Any Aft") modify
}
//Adjusted any after metformin multiple imputation
mi estimate, hr: stcox i.indextype `mvmodel_mi', cformat(%6.2f) pformat(%5.3f) sformat(%6.2f)
matrix b=r(table)
matrix c=b'
matrix list c
forval i=1/45{
local x=`i'+1
local rowname:word `i' of `matrownames_mi'
putexcel A1=("Variable") B1=("HR") C1=("SE") D1=("p-value") E1=("LL") F1=("UL") A`x'=("`rowname'") B`x'=(c[`i',1]) C`x'=(c[`i',2]) D`x'=(c[`i',4]) E`x'=(c[`i',5]) F`x'=(c[`i',6])using table2_hf, sheet("Adj MI Any Aft") modify
}

timer off 1
log close Stat_hf_tables



