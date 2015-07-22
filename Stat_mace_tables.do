//  program:    Stat_mace_tables.do
//  task:		Statistical analysis for all-cause mortality
//  project: 	Incretins--Comparative mortality and CV outcomes (CPRD)
//  author:     JM \ June 2015  
//				

clear all
capture log close Stat_mace_tables
set more off
log using Stat_mace.smcl, name(Stat_mace_tables) replace
timer on 1

//Complete Case 
use Stat_mace_cc, clear
//Unadjusted complete case
//Generate person-years, incidence rate, and 95%CI as well as hazard ratio
label var indextype "Exposure"
stptime, by(indextype) per(1000)
stcox i.indextype, cformat(%6.2f) pformat(%5.3f) sformat(%6.2f) nolog
stcox indextype_2 indextype_3 indextype_4 indextype_5 indextype_6, cformat(%6.2f) pformat(%5.3f) sformat(%6.2f) nolog

stptime, title(person-years) per(1000)
putexcel A1= ("Indextype") B1=("Person-Time") C1=("Failures") D1=("Incidence Rate") E1=("Lower Bound") F1=("Upper Bound") G1=("Hazard Ratio") H1=("Lower Bound") I1=("Upper Bound") using table2_mace, sheet("Unadj Comp Case") modify
forval i=0/5{
 local row=`i'+2
 stptime if indextype==`i'
 putexcel A`row'= ("`i'") B`row'=(r(ptime)) C`row'=(r(failures)) D`row'=(r(rate)*1000) E`row'=(r(lb)*1000) F`row'=(r(ub)*1000) using table2_mace, sheet("Unadj Comp Case") modify
}

forval i=1/5 {
 local row=`i'+2
 local matrow=`i'+1
 stcox i.indextype 
 matrix b=r(table)
 matrix a= b'
 putexcel G`row'=(a[`matrow',1]) H`row'=(a[`matrow',5]) I`row'=(a[`matrow',6]) using table2_mace, sheet("Unadj Comp Case") modify
}
//Fully adjusted complete case
matrix b=r(table)
matrix c=b'
matrix list c
forval i=1/76{
 local x=`i'+2
 local rowname:word `i' of `matrownames'
 putexcel A1=("Variable") B1=("HR") C1=("SE") D1=("p-value") E1=("LL") F1=("UL") A`x'=("`rowname'") B`x'=(c[`i',1]) C`x'=(c[`i',2]) D`x'=(c[`i',4]) E`x'=(c[`i',5]) F`x'=(c[`i',6])using table2_mace, sheet("Adj Comp Case Ref0") modify
}
stcox indextype_2 indextype_3 indextype_4 indextype_5 indextype_6 `mvmodel', cformat(%6.2f) pformat(%5.3f) sformat(%6.2f)  
matrix b=r(table)
matrix c=b'
matrix list c
forval i=1/75{
 local x=`i'+2
 local rowname:word `i' of `matrownames'
 putexcel A1=("Variable") B1=("HR") C1=("SE") D1=("p-value") E1=("LL") F1=("UL") A`x'=("`rowname'") B`x'=(c[`i',1]) C`x'=(c[`i',2]) D`x'=(c[`i',4]) E`x'=(c[`i',5]) F`x'=(c[`i',6])using table2_mace, sheet("Adj Comp Case Ref0Sep") modify
}

//Change reference groups
use Stat_mace_cc, clear
//DPP
stcox ib1.indextype `mvmodel', cformat(%6.2f) pformat(%5.3f) sformat(%6.2f) nolog
matrix b=r(table)
matrix c=b'
matrix list c
forval i=1/76{
 local x=`i'+1
 local rowname:word `i' of `matrownames'
 putexcel A1=("Variable") B1=("HR") C1=("SE") D1=("p-value") E1=("LL") F1=("UL") A`x'=("`rowname'") B`x'=(c[`i',1]) C`x'=(c[`i',2]) D`x'=(c[`i',4]) E`x'=(c[`i',5]) F`x'=(c[`i',6])using table2_mace, sheet("Adj Comp Case Ref1") modify
}
//GLP
stcox ib2.indextype `mvmodel', cformat(%6.2f) pformat(%5.3f) sformat(%6.2f) nolog
matrix b=r(table)
matrix c=b'
matrix list c
forval i=1/76{
 local x=`i'+1
 local rowname:word `i' of `matrownames'
 putexcel A1=("Variable") B1=("HR") C1=("SE") D1=("p-value") E1=("LL") F1=("UL") A`x'=("`rowname'") B`x'=(c[`i',1]) C`x'=(c[`i',2]) D`x'=(c[`i',4]) E`x'=(c[`i',5]) F`x'=(c[`i',6])using table2_mace, sheet("Adj Comp Case Ref2") modify
}
//INSULIN
stcox ib3.indextype `mvmodel', cformat(%6.2f) pformat(%5.3f) sformat(%6.2f) nolog
matrix b=r(table)
matrix c=b'
matrix list c
forval i=1/76{
 local x=`i'+1
 local rowname:word `i' of `matrownames'
 putexcel A1=("Variable") B1=("HR") C1=("SE") D1=("p-value") E1=("LL") F1=("UL") A`x'=("`rowname'") B`x'=(c[`i',1]) C`x'=(c[`i',2]) D`x'=(c[`i',4]) E`x'=(c[`i',5]) F`x'=(c[`i',6])using table2_mace, sheet("Adj Comp Case Ref3") modify
} 
//TZD
stcox ib4.indextype `mvmodel', cformat(%6.2f) pformat(%5.3f) sformat(%6.2f) nolog
matrix b=r(table)
matrix c=b'
matrix list c
forval i=1/76{
 local x=`i'+1
 local rowname:word `i' of `matrownames'
 putexcel A1=("Variable") B1=("HR") C1=("SE") D1=("p-value") E1=("LL") F1=("UL") A`x'=("`rowname'") B`x'=(c[`i',1]) C`x'=(c[`i',2]) D`x'=(c[`i',4]) E`x'=(c[`i',5]) F`x'=(c[`i',6])using table2_mace, sheet("Adj Comp Case Ref4") modify
} 

//MULTIPLE IMPUTATION
use Stat_mace_mi, clear

//Generate person-years, incidence rate, and 95%CI as well as hazard ratio
mi xeq: stptime, by(indextype) per(1000) 
//check that i.indextype and the separated indextypes yield the same results
mi estimate, hr: stcox i.indextype, cformat(%6.2f) pformat(%5.3f) sformat(%6.2f)  nolog
//Generate person-years, incidence rate, and 95%CI as well as hazard ratio
mi xeq: stptime, by(indextype) per(1000) 
putexcel A1= ("Indextype") B1=("Person-Time") C1=("Failures") D1=("Incidence Rate") E1=("Lower Bound") F1=("Upper Bound") G1=("Hazard Ratio") H1=("Lower Bound") I1=("Upper Bound") using table2_mace, sheet("Unadj Comp Case") modify
forval i=0/5{
 local row=`i'+2
 mi xeq 1: stptime if indextype==`i'
 putexcel A`row'= ("`i'") B`row'=(r(ptime)) C`row'=(r(failures)) D`row'=(r(rate)*1000) E`row'=(r(lb)*1000) F`row'=(r(ub)*1000) using table2_mace, sheet("Unadj MI") modify
}

forval i=1/5 {
 local row=`i'+2
 local matrow=`i'+1
 mi estimate, hr: stcox i.indextype 
 matrix b=r(table)
 matrix a= b'
 putexcel G`row'=(a[`matrow',1]) H`row'=(a[`matrow',5]) I`row'=(a[`matrow',6]) using table2_mace, sheet("Unadj MI") modify
}
//Fully adjusted multiple imputation
mi estimate, hr: stcox i.indextype `mvmodel_mi'
matrix b=r(table)
matrix c=b'
matrix list c
forval i=1/76{
 local x=`i'+2
 local rowname:word `i' of `matrownames'
 putexcel A1=("Variable") B1=("HR") C1=("SE") D1=("p-value") E1=("LL") F1=("UL") A`x'=("`rowname'") B`x'=(c[`i',1]) C`x'=(c[`i',2]) D`x'=(c[`i',4]) E`x'=(c[`i',5]) F`x'=(c[`i',6])using table2_mace, sheet("Adj MI Ref0") modify
}

//Change reference groups multiple imputation
//DPP
mi estimate, hr: stcox ib1.indextype `mvmodel_mi', cformat(%6.2f) pformat(%5.3f) sformat(%6.2f)
quietly {
matrix b=r(table)
matrix c=b'
matrix list c
forval i=1/78{
 local x=`i'+2
 local rowname:word `i' of `matrownames_mi'
 putexcel A1=("Variable") B1=("HR") C1=("SE") D1=("p-value") E1=("LL") F1=("UL") A`x'=("`rowname'") B`x'=(c[`i',1]) C`x'=(c[`i',2]) D`x'=(c[`i',4]) E`x'=(c[`i',5]) F`x'=(c[`i',6])using table2_mace, sheet("Adj MI Ref1") modify
}
}
//GLP
mi estimate, hr: stcox ib2.indextype `mvmodel_mi', cformat(%6.2f) pformat(%5.3f) sformat(%6.2f)
quietly {
matrix b=r(table)
matrix c=b'
matrix list c
forval i=1/78{
 local x=`i'+2
 local rowname:word `i' of `matrownames_mi'
 putexcel A1=("Variable") B1=("HR") C1=("SE") D1=("p-value") E1=("LL") F1=("UL") A`x'=("`rowname'") B`x'=(c[`i',1]) C`x'=(c[`i',2]) D`x'=(c[`i',4]) E`x'=(c[`i',5]) F`x'=(c[`i',6])using table2_mace, sheet("Adj MI Ref2") modify
}
}
//Insulin
mi estimate, hr: stcox ib3.indextype `mvmodel_mi', cformat(%6.2f) pformat(%5.3f) sformat(%6.2f)
quietly {
matrix b=r(table)
matrix c=b'
matrix list c
forval i=1/78{
 local x=`i'+2
 local rowname:word `i' of `matrownames_mi'
 putexcel A1=("Variable") B1=("HR") C1=("SE") D1=("p-value") E1=("LL") F1=("UL") A`x'=("`rowname'") B`x'=(c[`i',1]) C`x'=(c[`i',2]) D`x'=(c[`i',4]) E`x'=(c[`i',5]) F`x'=(c[`i',6])using table2_mace, sheet("Adj MI Ref3") modify
}
}
//TZD
mi estimate, hr: stcox ib4.indextype `mvmodel_mi', cformat(%6.2f) pformat(%5.3f) sformat(%6.2f)
quietly {
matrix b=r(table)
matrix c=b'
matrix list c
forval i=1/78{
 local x=`i'+2
 local rowname:word `i' of `matrownames_mi'
 putexcel A1=("Variable") B1=("HR") C1=("SE") D1=("p-value") E1=("LL") F1=("UL") A`x'=("`rowname'") B`x'=(c[`i',1]) C`x'=(c[`i',2]) D`x'=(c[`i',4]) E`x'=(c[`i',5]) F`x'=(c[`i',6])using table2_mace, sheet("Adj MI Ref4") modify
}
}
/*//Fully adjusted SU reference, CPRD only multiple imputation
use Stat_mace_mi, clear
keep if linked_b!=1
egen mace_exit_g = rowmin(tod2 deathdate2 lcd2 myoinfarct_date_i stroke_date_i)
mi stset mace_exit_g, fail(mace) id(patid) origin(seconddate) scale(365.25)
mi estimate, hr: stcox i.indextype `mvmodel_mi', cformat(%6.2f) pformat(%5.3f) sformat(%6.2f)  
matrix b=r(table)
matrix c=b'
matrix list c
forval i=1/76 {
 local x=`i'+1
 local rowname:word `i' of `matrownames_mi'
 putexcel A1=("Variable") B1=("HR") C1=("SE") D1=("p-value") E1=("LL") F1=("UL") A`x'=("`rowname'") B`x'=(c[`i',1]) C`x'=(c[`i',2]) D`x'=(c[`i',4]) E`x'=(c[`i',5]) F`x'=(c[`i',6])using table2_mace, sheet("Adj CPRD Only MI") modify
}*/

//Fully adjusted SU reference, HES only multiple imputation
use Stat_mace_mi, clear
keep if linked_b==1
capture drop mace_exit_h
egen mace_exit_h = rowmin(tod2 dod2 deathdate2 lcd2 myoinfarct_date_i stroke_date_i)
mi stset mace_exit_h, fail(mace) id(patid) origin(seconddate) scale(365.25)
mi estimate, hr: stcox i.indextype `mvmodel_mi', cformat(%6.2f) pformat(%5.3f) sformat(%6.2f)  
matrix b=r(table)
matrix c=b'
matrix list c
forval i=1/79{
 local x=`i'+1
 local rowname:word `i' of `matrownames_mi'
 putexcel A1=("Variable") B1=("HR") C1=("SE") D1=("p-value") E1=("LL") F1=("UL") A`x'=("`rowname'") B`x'=(c[`i',1]) C`x'=(c[`i',2]) D`x'=(c[`i',4]) E`x'=(c[`i',5]) F`x'=(c[`i',6])using table2_mace, sheet("Adj HES Only MI") modify
}
//SENSITIVITY ANALYSIS
// #1. CENSOR EXPSOURE AT FIRST GAP FOR THE FIRST SWITCH/ADD AGENT (INDEXTYPE)
use Stat_mace_mi_index, clear

//Unadjusted at first gap multiple imputation
putexcel A1= ("Indextype") B1=("Person-Time") C1=("Failures") D1=("Incidence Rate") E1=("Lower Bound") F1=("Upper Bound") G1=("Hazard Ratio") H1=("Lower Bound") I1=("Upper Bound") using table2_mace, sheet("Unadj MI Gap1") modify
forval i=0/5{
 local row=`i'+2
 mi xeq 1: stptime if indextype==`i'
 putexcel A`row'= ("`i'") B`row'=(r(ptime)) C`row'=(r(failures)) D`row'=(r(rate)*1000) E`row'=(r(lb)*1000) F`row'=(r(ub)*1000) using table2_mace, sheet("Unadj MI Gap1") modify
}
forval i=1/5 {
 local row=`i'+2
 local matrow=`i'+1
 mi estimate, hr: stcox i.indextype 
 matrix b=r(table)
 matrix a= b'
 putexcel G`row'=(a[`matrow',1]) H`row'=(a[`matrow',5]) I`row'=(a[`matrow',6]) using table2_mace, sheet("Unadj MI Gap1") modify
}

//Fully adjusted at first gap multiple imputation
mi estimate, hr: stcox i.indextype `mvmodel_mi2', cformat(%6.2f) pformat(%5.3f) sformat(%6.2f)  
matrix b=r(table)
matrix c=b'
matrix list c
forval i=1/79{
 local x=`i'+1
 local rowname:word `i' of `matrownames_mi2'
 putexcel A1=("Variable") B1=("HR") C1=("SE") D1=("p-value") E1=("LL") F1=("UL") A`x'=("`rowname'") B`x'=(c[`i',1]) C`x'=(c[`i',2]) D`x'=(c[`i',4]) E`x'=(c[`i',5]) F`x'=(c[`i',6])using table2_mace, sheet("Adj MI Gap1") modify
}

//#2. CENSOR EXPSOURE AT INDEXTYPE3
use Stat_mace_mi_index3, clear
//Unadjusted at indextype3, multiple imputation
putexcel A1= ("Indextype") B1=("Person-Time") C1=("Failures") D1=("Incidence Rate") E1=("Lower Bound") F1=("Upper Bound") G1=("Hazard Ratio") H1=("Lower Bound") I1=("Upper Bound") using table2_mace, sheet("Unadj Agent3") modify
forval i=0/5{
local row=`i'+2
mi xeq 1: stptime if indextype==`i'
putexcel A`row'= ("`i'") B`row'=(r(ptime)) C`row'=(r(failures)) D`row'=(r(rate)*1000) E`row'=(r(lb)*1000) F`row'=(r(ub)*1000) using table2_mace, sheet("Unadj MI Agent3") modify
}
forval i=1/5 {
 local row=`i'+2
 local matrow=`i'+1
 mi estimate, hr: stcox i.indextype
 matrix b=r(table)
 matrix a= b'
 putexcel G`row'=(a[`matrow',1]) H`row'=(a[`matrow',5]) I`row'=(a[`matrow',6]) using table2_mace, sheet("Unadj MI Agent3") modify
}

//Fully adjusted at indextype3 multiple imputation
mi estimate, hr: stcox i.indextype `mvmodel_mi2', cformat(%6.2f) pformat(%5.3f) sformat(%6.2f)  
matrix b=r(table)
matrix c=b'
matrix list c
forval i=1/79{
 local x=`i'+1
 local rowname:word `i' of `matrownames_mi2'
 putexcel A1=("Variable") B1=("HR") C1=("SE") D1=("p-value") E1=("LL") F1=("UL") A`x'=("`rowname'") B`x'=(c[`i',1]) C`x'=(c[`i',2]) D`x'=(c[`i',4]) E`x'=(c[`i',5]) F`x'=(c[`i',6])using table2_mace, sheet("Adj MI Agent3") modify
}

//#3 ANY EXPOSURE AFTER METFORMIN
use Stat_mace_mi_any, clear
//Unadjusted any after metformin monotherapy multiple imputation
putexcel A1= ("Indextype") B1=("Person-Time") C1=("Failures") D1=("Incidence Rate") E1=("Lower Bound") F1=("Upper Bound") G1=("Hazard Ratio") H1=("Lower Bound") I1=("Upper Bound") using table2_mace, sheet("Unadj MI Any Aft") modify
forval i=0/5{
local row=`i'+2
mi xeq 1: stptime if indextype==`i'
putexcel A`row'= ("`i'") B`row'=(r(ptime)) C`row'=(r(failures)) D`row'=(r(rate)*1000) E`row'=(r(lb)*1000) F`row'=(r(ub)*1000) using table2_mace, sheet("Unadj MI Any Aft") modify
}
forval i=1/5 {
 local row=`i'+2
 local matrow=`i'+1
 mi estimate, hr: stcox i.indextype
 matrix b=r(table)
 matrix a= b'
 putexcel G`row'=(a[`matrow',1]) H`row'=(a[`matrow',5]) I`row'=(a[`matrow',6]) using table2_mace, sheet("Unadj MI Any Aft") modify
}

//Adjusted any after metformin multiple imputation
mi estimate, hr: stcox i.indextype `mvmodel_mi2', cformat(%6.2f) pformat(%5.3f) sformat(%6.2f)
matrix b=r(table)
matrix c=b'
matrix list c
forval i=1/78{
local x=`i'+2
local rowname:word `i' of `matrownames_mi2'
putexcel A1=("Variable") B1=("HR") C1=("SE") D1=("p-value") E1=("LL") F1=("UL") A`x'=("`rowname'") B`x'=(c[`i',1]) C`x'=(c[`i',2]) D`x'=(c[`i',4]) E`x'=(c[`i',5]) F`x'=(c[`i',6])using table2_mace, sheet("Adj MI Any Aft") modify
}

timer off 1
log close Stat_mace


