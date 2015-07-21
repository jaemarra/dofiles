//  program:    Stat_angina_tables.do
//  task:		Statistical analysis for all-cause mortality
//  project: 	Incretins--Comparative mortality and CV outcomes (CPRD)
//  author:     JM \ July 2015  
//				

clear all
capture log close Stat_angina
set more off
log using Stat_angina.smcl, name(Stat_angina_tables) replace
timer on 1

use Analytic_Dataset_Master.dta, clear
quietly do Data13_variable_generation.do
//apply exclusion criteria
keep if exclude==0
//restrict to jan 1, 2007
drop if seconddate<17167
clonevar angina = ang
save angina, replace

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

//Create table1 

table1, by(indextype) vars(age_indexdate contn \ age_cat cat \ gender cat \ imd2010_5 cat \ dmdur contn \ metoverlap contn \ prx_covvalue_g_i4 cat \ prx_covvalue_g_i5 cat \ bmi_i_cats cat \ physician_vis2 cat \ ang_i bin \ arr_i bin \ afib_i bin \ hf_i bin \ htn_i bin \ mi_i bin \ pvd_i bin \ stroke_i bin \ revasc_i bin \ prx_ccivalue_g_i2 cat \ hba1c_i contn \ hba1c_cats_i cat \ prx_covvalue_g_i3 contn \ sbp_i_cats2 cat \ egfr_amdrd contn \ ckd_amdrd cat \ unique_cov_drugs cat \ unqrx2 cat \ statin_i bin \ calchan_i bin \ betablock_i bin \ anticoag_oral_i bin \ antiplat_i bin \ ace_arb_renin_i bin \ diuretics_all_i bin) onecol format(%9.2g) saving(table1_angina.xls, replace)
table1 if linked_b==1, by(indextype) vars(age_indexdate contn \ age_cat cat \ gender cat \ imd2010_5 cat \ dmdur contn \ metoverlap contn \ prx_covvalue_g_i4 cat \ prx_covvalue_g_i5 cat \ bmi_i_cats cat \ physician_vis2 cat \ ang_i bin \ arr_i bin \ afib_i bin \ hf_i bin \ htn_i bin \ mi_i bin \ pvd_i bin \ stroke_i bin \ revasc_i bin \ prx_ccivalue_g_i2 cat \ hba1c_i contn \ hba1c_cats_i cat \ prx_covvalue_g_i3 contn \ sbp_i_cats2 cat \ egfr_amdrd contn \ ckd_amdrd cat \ unique_cov_drugs cat \ unqrx2 cat \ statin_i bin \ calchan_i bin \ betablock_i bin \ anticoag_oral_i bin \ antiplat_i bin \ ace_arb_renin_i bin \ diuretics_all_i bin) onecol format(%9.2g) saving(table1_linked_angina.xls, replace)

// 2x2 tables with exposure and outcome (death)
label var indextype "2nd-line Agent"
tab indextype angina, row
label var indextype3 "3rd-line Agent"
tab indextype3 angina, row
label var indextype4 "4th-line Agent"
tab indextype4 angina, row
tab indextype5 angina, row
tab indextype6 angina, row
tab indextype7 angina, row

//2x2 tables for each covariate to determine if events are too low to include any of them
foreach var of varlist age_65 gender dmdur_cat ckd_amdrd unique_cov_drugs prx_ccivalue_g_i2 mi_i stroke_i hf_i arr_i ang_i revasc_i htn_i afib_i pvd_i statin_i calchan_i betablock_i anticoag_oral_i antiplat_i ace_arb_renin_i diuretics_all_i bmi_i_cats sbp_i_cats2 hba1c_cats_i2 prx_covvalue_g_i4 {
tab indextype `var', row
}

// 2x2 tables with exposure and death, by baseline covariates
foreach var of varlist gender dmdur_cat prx_covvalue_g_i4 prx_covvalue_g_i5 bmi_i_cats hba1c_cats_i2 sbp_i_cats2 ///
	ckd_amdrd physician_vis2 unique_cov_drugs prx_ccivalue_g_i2 mi_i stroke_i hf_i arr_i ang_i revasc_i ///
	htn_i afib_i pvd_i statin_i calchan_i betablock_i anticoag_oral_i antiplat_i ace_arb_renin_i ///
	diuretics_all_i {
table indextype `var', contents(n angina mean angina) format(%6.2f) center col
	}

//COMPLETE CASE APPROACH
use Stat_angina_cc, clear
//UNADJ TABLES
putexcel A1= ("Indextype") B1=("Person-Time") C1=("Failures") D1=("Incidence Rate") E1=("Lower Bound") F1=("Upper Bound") G1=("Hazard Ratio") H1=("Lower Bound") I1=("Upper Bound") using table2_angina, sheet("Unadj Comp Case") modify
forval i=0/5{
 local row=`i'+2
 stptime if indextype==`i', per(1000)
 putexcel A`row'= ("`i'") B`row'=(r(ptime)) C`row'=(r(failures)) D`row'=(r(rate)*1000) E`row'=(r(lb)*1000) F`row'=(r(ub)*1000) using table2_angina, sheet("Unadj Comp Case") modify
}

forval i=1/5 {
 local row=`i'+2
 local matrow=`i'+1
 stcox i.indextype 
 matrix b=r(table)
 matrix a= b'
 putexcel G`row'=(a[`matrow',1]) H`row'=(a[`matrow',5]) I`row'=(a[`matrow',6]) using table2_angina, sheet("Unadj Comp Case") modify
}
//ADJUSTED TABLES
stcox i.indextype, cformat(%6.2f) pformat(%5.3f) sformat(%6.2f)  
matrix b=r(table)
matrix c=b'
matrix list c
forval i=1/76{
 local x=`i'+2
 local rowname:word `i' of `matrownames'
 putexcel A1=("Variable") B1=("HR") C1=("SE") D1=("p-value") E1=("LL") F1=("UL") A`x'=("`rowname'") B`x'=(c[`i',1]) C`x'=(c[`i',2]) D`x'=(c[`i',4]) E`x'=(c[`i',5]) F`x'=(c[`i',6])using table2_angina, sheet("Adj Comp Case Ref0") modify
}
stcox indextype_2 indextype_3 indextype_4 indextype_5 indextype_6 `mvmodel', cformat(%6.2f) pformat(%5.3f) sformat(%6.2f)  
matrix b=r(table)
matrix c=b'
matrix list c
forval i=1/75{
 local x=`i'+2
 local rowname:word `i' of `matrownames'
 putexcel A1=("Variable") B1=("HR") C1=("SE") D1=("p-value") E1=("LL") F1=("UL") A`x'=("`rowname'") B`x'=(c[`i',1]) C`x'=(c[`i',2]) D`x'=(c[`i',4]) E`x'=(c[`i',5]) F`x'=(c[`i',6])using table2_angina, sheet("Adj Comp Case Ref0Sep") modify
}

**********************************************************Change reference groups**********************************************************
use Stat_angina_cc, clear
//DPP
stcox ib1.indextype `mvmodel', cformat(%6.2f) pformat(%5.3f) sformat(%6.2f) 
matrix b=r(table)
matrix c=b'
matrix list c
forval i=1/76{
 local x=`i'+1
 local rowname:word `i' of `matrownames'
 putexcel A1=("Variable") B1=("HR") C1=("SE") D1=("p-value") E1=("LL") F1=("UL") A`x'=("`rowname'") B`x'=(c[`i',1]) C`x'=(c[`i',2]) D`x'=(c[`i',4]) E`x'=(c[`i',5]) F`x'=(c[`i',6])using table2_angina, sheet("Adj Comp Case Ref1") modify
}
//GLP
stcox ib2.indextype `mvmodel', cformat(%6.2f) pformat(%5.3f) sformat(%6.2f) 
matrix b=r(table)
matrix c=b'
matrix list c
forval i=1/76{
 local x=`i'+1
 local rowname:word `i' of `matrownames'
 putexcel A1=("Variable") B1=("HR") C1=("SE") D1=("p-value") E1=("LL") F1=("UL") A`x'=("`rowname'") B`x'=(c[`i',1]) C`x'=(c[`i',2]) D`x'=(c[`i',4]) E`x'=(c[`i',5]) F`x'=(c[`i',6])using table2_angina, sheet("Adj Comp Case Ref2") modify
}
//INS
stcox ib3.indextype `mvmodel', cformat(%6.2f) pformat(%5.3f) sformat(%6.2f)
matrix b=r(table)
matrix c=b'
matrix list c
forval i=1/76{
 local x=`i'+1
 local rowname:word `i' of `matrownames'
 putexcel A1=("Variable") B1=("HR") C1=("SE") D1=("p-value") E1=("LL") F1=("UL") A`x'=("`rowname'") B`x'=(c[`i',1]) C`x'=(c[`i',2]) D`x'=(c[`i',4]) E`x'=(c[`i',5]) F`x'=(c[`i',6])using table2_angina, sheet("Adj Comp Case Ref3") modify
} 
//TZD
stcox ib4.indextype `mvmodel', cformat(%6.2f) pformat(%5.3f) sformat(%6.2f)
matrix b=r(table)
matrix c=b'
matrix list c
forval i=1/76{
 local x=`i'+1
 local rowname:word `i' of `matrownames'
 putexcel A1=("Variable") B1=("HR") C1=("SE") D1=("p-value") E1=("LL") F1=("UL") A`x'=("`rowname'") B`x'=(c[`i',1]) C`x'=(c[`i',2]) D`x'=(c[`i',4]) E`x'=(c[`i',5]) F`x'=(c[`i',6])using table2_angina, sheet("Adj Comp Case Ref4") modify
} 
//**************************************************************************************************************************************************//
//MULTIPLE IMPUTATION APPROACH
use Stat_angina_mi, clear

//UNADJUSTED
putexcel A1= ("Indextype") B1=("Person-Time") C1=("Failures") D1=("Incidence Rate") E1=("Lower Bound") F1=("Upper Bound") G1=("Hazard Ratio") H1=("Lower Bound") I1=("Upper Bound") using table2_angina, sheet("Unadj Comp Case") modify
forval i=0/5{
 local row=`i'+2
 mi xeq 1: stptime if indextype==`i', per(1000)
 putexcel A`row'= ("`i'") B`row'=(r(ptime)) C`row'=(r(failures)) D`row'=(r(rate)*1000) E`row'=(r(lb)*1000) F`row'=(r(ub)*1000) using table2_angina, sheet("Unadj Comp Case") modify
}

forval i=1/5 {
 local row=`i'+2
 local matrow=`i'+1
 mi estimate, hr: stcox i.indextype 
 matrix b=r(table)
 matrix a= b'
 putexcel G`row'=(a[`matrow',1]) H`row'=(a[`matrow',5]) I`row'=(a[`matrow',6]) using table2_angina, sheet("Unadj Comp Case") modify
}

//ADJUSTED
//fit the model separately on each of the 20 imputed datasets and combine results
mi estimate, hr: stcox i.indextype `mvmodel_mi'
matrix b=r(table)
matrix c=b'
matrix list c
forval i=1/78{
 local x=`i'+2
 local rowname:word `i' of `matrownames_mi'
 putexcel A1=("Variable") B1=("HR") C1=("SE") D1=("p-value") E1=("LL") F1=("UL") A`x'=("`rowname'") B`x'=(c[`i',1]) C`x'=(c[`i',2]) D`x'=(c[`i',4]) E`x'=(c[`i',5]) F`x'=(c[`i',6])using table2_angina, sheet("Adj MI Ref0") modify
} 

********************************************Change reference groups using multiple imputation method********************************************
//DPP
mi estimate, hr: stcox ib1.indextype `mvmodel_mi', cformat(%6.2f) pformat(%5.3f) sformat(%6.2f)
matrix b=r(table)
matrix c=b'
matrix list c
forval i=1/78{
 local x=`i'+2
 local rowname:word `i' of `matrownames_mi'
 putexcel A1=("Variable") B1=("HR") C1=("SE") D1=("p-value") E1=("LL") F1=("UL") A`x'=("`rowname'") B`x'=(c[`i',1]) C`x'=(c[`i',2]) D`x'=(c[`i',4]) E`x'=(c[`i',5]) F`x'=(c[`i',6])using table2_angina, sheet("Adj MI Ref1") modify
}

//GLP
mi estimate, hr: stcox ib2.indextype `mvmodel_mi', cformat(%6.2f) pformat(%5.3f) sformat(%6.2f)
matrix b=r(table)
matrix c=b'
matrix list c
forval i=1/78{
 local x=`i'+2
 local rowname:word `i' of `matrownames_mi'
 putexcel A1=("Variable") B1=("HR") C1=("SE") D1=("p-value") E1=("LL") F1=("UL") A`x'=("`rowname'") B`x'=(c[`i',1]) C`x'=(c[`i',2]) D`x'=(c[`i',4]) E`x'=(c[`i',5]) F`x'=(c[`i',6])using table2_angina, sheet("Adj MI Ref2") modify
}

//Insulin
mi estimate, hr: stcox ib3.indextype `mvmodel_mi', cformat(%6.2f) pformat(%5.3f) sformat(%6.2f)
matrix b=r(table)
matrix c=b'
matrix list c
forval i=1/78{
 local x=`i'+2
 local rowname:word `i' of `matrownames_mi'
 putexcel A1=("Variable") B1=("HR") C1=("SE") D1=("p-value") E1=("LL") F1=("UL") A`x'=("`rowname'") B`x'=(c[`i',1]) C`x'=(c[`i',2]) D`x'=(c[`i',4]) E`x'=(c[`i',5]) F`x'=(c[`i',6])using table2_angina, sheet("Adj MI Ref3") modify
}

//TZD
mi estimate, hr: stcox ib4.indextype `mvmodel_mi', cformat(%6.2f) pformat(%5.3f) sformat(%6.2f)
matrix b=r(table)
matrix c=b'
matrix list c
forval i=1/78{
 local x=`i'+2
 local rowname:word `i' of `matrownames_mi'
 putexcel A1=("Variable") B1=("HR") C1=("SE") D1=("p-value") E1=("LL") F1=("UL") A`x'=("`rowname'") B`x'=(c[`i',1]) C`x'=(c[`i',2]) D`x'=(c[`i',4]) E`x'=(c[`i',5]) F`x'=(c[`i',6])using table2_angina, sheet("Adj MI Ref4") modify
}

*******************************************************SENSITIVITY ANALYSIS*******************************************************
// #1. CENSOR EXPSOURE AT FIRST GAP FOR THE FIRST SWITCH/ADD AGENT (INDEXTYPE)
use Stat_angina_mi_index, clear

//Unadjusted MI 
putexcel A1= ("Indextype") B1=("Person-Time") C1=("Failures") D1=("Incidence Rate") E1=("Lower Bound") F1=("Upper Bound") G1=("Hazard Ratio") H1=("Lower Bound") I1=("Upper Bound") using table2_angina, sheet("Unadj MI Gap1") modify
forval i=0/5{
 local row=`i'+2
 mi xeq 1: stptime if indextype==`i', per(1000)
 putexcel A`row'= ("`i'") B`row'=(r(ptime)) C`row'=(r(failures)) D`row'=(r(rate)*1000) E`row'=(r(lb)*1000) F`row'=(r(ub)*1000) using table2_angina, sheet("Unadj MI Gap1") modify
}

forval i=1/5 {
 local row=`i'+2
 local matrow=`i'+1
 mi estimate, hr: stcox i.indextype 
 matrix b=r(table)
 matrix a= b'
 putexcel G`row'=(a[`matrow',1]) H`row'=(a[`matrow',5]) I`row'=(a[`matrow',6]) using table2_angina, sheet("Unadj MI Gap1") modify
}

//Adjusted MI
mi estimate, hr: stcox i.indextype `mvmodel_mi2', cformat(%6.2f) pformat(%5.3f) sformat(%6.2f)  
matrix b=r(table)
matrix c=b'
matrix list c
forval i=1/79{
 local x=`i'+1
 local rowname:word `i' of `matrownames_mi2'
 putexcel A1=("Variable") B1=("HR") C1=("SE") D1=("p-value") E1=("LL") F1=("UL") A`x'=("`rowname'") B`x'=(c[`i',1]) C`x'=(c[`i',2]) D`x'=(c[`i',4]) E`x'=(c[`i',5]) F`x'=(c[`i',6])using table2_angina, sheet("Adj MI Gap1") modify
}

//********************************************************************************************************************************//
//#2. CENSOR EXPSOURE AT INDEXTYPE3
use Stat_angina_mi_index3, clear
//UNADJUSTED 
putexcel A1= ("Indextype") B1=("Person-Time") C1=("Failures") D1=("Incidence Rate") E1=("Lower Bound") F1=("Upper Bound") G1=("Hazard Ratio") H1=("Lower Bound") I1=("Upper Bound") using table2_angina, sheet("Unadj MI Agent3") modify
forval i=0/5{
local row=`i'+2
mi xeq 1: stptime if indextype==`i', per(1000)
putexcel A`row'= ("`i'") B`row'=(r(ptime)) C`row'=(r(failures)) D`row'=(r(rate)*1000) E`row'=(r(lb)*1000) F`row'=(r(ub)*1000) using table2_angina, sheet("Unadj MI Agent3") modify
}

forval i=1/5 {
 local row=`i'+2
 local matrow=`i'+1
 mi estimate, hr: stcox i.indextype
 matrix b=r(table)
 matrix a= b'
 putexcel G`row'=(a[`matrow',1]) H`row'=(a[`matrow',5]) I`row'=(a[`matrow',6]) using table2_angina, sheet("Unadj MI Agent3") modify
}

//ADJUSTED 
mi estimate, hr: stcox i.indextype `mvmodel_mi2', cformat(%6.2f) pformat(%5.3f) sformat(%6.2f)  
matrix b=r(table)
matrix c=b'
matrix list c
forval i=1/79{
 local x=`i'+1
 local rowname:word `i' of `matrownames_mi2'
 putexcel A1=("Variable") B1=("HR") C1=("SE") D1=("p-value") E1=("LL") F1=("UL") A`x'=("`rowname'") B`x'=(c[`i',1]) C`x'=(c[`i',2]) D`x'=(c[`i',4]) E`x'=(c[`i',5]) F`x'=(c[`i',6])using table2_angina, sheet("Adj MI Agent3") modify
}
//********************************************************************************************************************************//
//#3 ANY EXPOSURE AFTER METFORMIN
use Stat_angina_mi_any

//UNADJUSTED 
putexcel A1= ("Indextype") B1=("Person-Time") C1=("Failures") D1=("Incidence Rate") E1=("Lower Bound") F1=("Upper Bound") G1=("Hazard Ratio") H1=("Lower Bound") I1=("Upper Bound") using table2_angina, sheet("Unadj MI Any Aft") modify
forval i=0/5{
local row=`i'+2
mi xeq 1: stptime if indextype==`i', per(1000)
putexcel A`row'= ("`i'") B`row'=(r(ptime)) C`row'=(r(failures)) D`row'=(r(rate)*1000) E`row'=(r(lb)*1000) F`row'=(r(ub)*1000) using table2_angina, sheet("Unadj MI Any Aft") modify
}

forval i=1/5 {
 local row=`i'+2
 local matrow=`i'+1
 mi estimate, hr: stcox i.indextype
 matrix b=r(table)
 matrix a= b'
 putexcel G`row'=(a[`matrow',1]) H`row'=(a[`matrow',5]) I`row'=(a[`matrow',6]) using table2_angina, sheet("Unadj MI Any Aft ") modify
}

//ADJUSTED 
mi estimate, hr: stcox i.indextype `mvmodel_mi2', cformat(%6.2f) pformat(%5.3f) sformat(%6.2f)  
matrix b=r(table)
matrix c=b'
matrix list c
forval i=1/79{
 local x=`i'+1
 local rowname:word `i' of `matrownames_mi2'
 putexcel A1=("Variable") B1=("HR") C1=("SE") D1=("p-value") E1=("LL") F1=("UL") A`x'=("`rowname'") B`x'=(c[`i',1]) C`x'=(c[`i',2]) D`x'=(c[`i',4]) E`x'=(c[`i',5]) F`x'=(c[`i',6])using table2_angina, sheet("Adj MI Any Aft") modify
}

timer off 1
log close Stat_angina_tables
