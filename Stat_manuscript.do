//  program:    Stat_manuscript.do
//  task:		Manuscript numbers generation
//  project: 	Incretins--Comparative mortality and CV outcomes (CPRD)
//  author:     JM \ July 2015  

use Analytic_Dataset_Master
do Data13_variable_generation
keep if exclude==0&seconddate>17167

//Create macros
//mvmodel includes: demo, comorb2, meds and clin
local mvmodel = "age_indexdate gender ib2.smokestatus ib1.hba1c_cats_i2 i.ckd_amdrd bmi_i sbp i.physician_vis2 i.prx_ccivalue_g_i2 cvd_i dmdur metoverlap i.unique_cov_drugs statin_i calchan_i betablock_i anticoag_oral_i antiplat_i ace_arb_renin_i diuretics_all_i su_post dpp4i_post glp1ra_post ins_post tzd_post oth_post"
local matrownames "SU DPP4I GLP1RA INS TZD OTH Age Male Unknown Current Non_Smoker Former HbA1c_<7 HbA1c_7_8 HbA1c_8_9 HbA1c_9_10 HbA1c_>10 HbA1c_unknown eGFR_90+ eGFR_60_89 eGFR_30_59 eGFR_15_29 eGFR_<15 eGFR_unknown BMI SBP PhysVis_12 PhysVis_24 PhysVis_24plus CCI=1 CCI=2 CCI=3+ CVD diabetes_duration Metformin_overlap No_unique_drugs_0_5 No_unique_drugs_6_10 No_unique_drugs_11_15 No_unique_drugs_16_20 No_unique_drugs_>20 Statin CCB BB Anticoag Antiplat RAS Diuretics su_post dpp4i_post glp1ra_post ins_post tzd_post oth_post"
//mvmodel_mi includes: demoMI, comorb2 meds2, clinMI (only differences between mvmodel and mvmodel_mi are the imputed variables and removal of *_post for collinearity)
local mvmodel_mi = "age_indexdate gender ib2.smokestatus_clone ib1.hba1c_cats_i2_clone i.ckd_amdrd bmi_i sbp i.physician_vis2 i.prx_ccivalue_g_i2 cvd_i dmdur metoverlap i.unique_cov_drugs statin_i calchan_i betablock_i anticoag_oral_i antiplat_i ace_arb_renin_i diuretics_all_i"
local matrownames_mi "SU DPP4I GLP1RA INS TZD OTH Age Male Unknown Current Non_Smoker Former HbA1c_<7 HbA1c_7_8 HbA1c_8_9 HbA1c_9_10 HbA1c_>10 HbA1c_unknown eGFR_90+ eGFR_60_89 eGFR_30_59 eGFR_15_29 eGFR_<15 eGFR_unknown BMI SBP PhysVis_12 PhysVis_24 PhysVis_24plus CCI=1 CCI=2 CCI=3+ CVD diabetes_duration Metformin_overlap No_unique_drugs_0_5 No_unique_drugs_6_10 No_unique_drugs_11_15 No_unique_drugs_16_20 No_unique_drugs_>20 Statin CCB BB Anticoag Antiplat RAS Diuretics"

//ABSTRACT RESULTS
unique patid 
tab indextype
gen fup =.
replace fup=tx-indexdate
label var fup "Follow-up time from indexdate to censor date"
summ fup, detail
summ age_indexdate 
summ gender 
summ hba1c_i2
unique patid if death_date!=. 
unique patid if mace==1
unique patid if myoinfarct_date_i!=.
unique patid if stroke_date_i!=.
unique patid if cvdeath_date_i!=.
unique patid if linked_b==1 //cvdeath has to be divided only by linked population (n)
//get duration of metformin monotherapy prior to index switch/add
gen metmono=.
replace metmono=indexdate-cohortentrydate
summ metmono, detail
label var metmono "Duration of metformin monotherpy prior to index swtich/add"
//get the history of...
//cvd
unique patid if cvd_i==1
//egfr<60
unique patid if ckd_amdrd==3|ckd_amdrd==4|ckd_amdrd==5
//BMI
summ bmi_i
//hba1c
summ hba1c_i2
//get history for DPP vs SU
summ age_indexdate if indextype==1
summ age_indexdate if indextype==0
summ metmono if indextype==1
summ metmono if indextype==0
unique patid if bmi_i>=30&indextype==1
unique patid if bmi_i>=30&indextype==0
summ hba1c_i2 if indextype==1
summ hba1c_i2 if indextype==0
//get the linked numbers
unique patid if linked_b==1
tab indextype if linked_b==1
unique patid if linked_b==1&acm==1
unique patid if linked_b==1&mace==1

//RESULTS SECTION 
//FIGURE 1: PATIENT FLOW (from draw.io)
//SUPPLEMENT FIGURE S1: LINKED PATIENT FLOW (from draw.io)

//ACM WRITTEN SECTION NUMBERS
use acm, clear
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

//2x2 tables for each covariate to determine if events are too low to include any of them
foreach var of varlist age_65 gender dmdur_cat ckd_amdrd unique_cov_drugs prx_ccivalue_g_i2 mi_i stroke_i hf_i arr_i ang_i revasc_i htn_i afib_i pvd_i statin_i calchan_i betablock_i anticoag_oral_i antiplat_i ace_arb_renin_i diuretics_all_i bmi_i_cats sbp_i_cats2 hba1c_cats_i2 prx_covvalue_g_i4 {
tab indextype `var', row
}
// 2x2 tables with exposure and death, by baseline covariates
foreach var of varlist gender dmdur_cat prx_covvalue_g_i4 prx_covvalue_g_i5 bmi_i_cats hba1c_cats_i2 sbp_i_cats2 ///
	ckd_amdrd physician_vis2 unique_cov_drugs prx_ccivalue_g_i2 mi_i stroke_i hf_i arr_i ang_i revasc_i ///
	htn_i afib_i pvd_i statin_i calchan_i betablock_i anticoag_oral_i antiplat_i ace_arb_renin_i ///
	diuretics_all_i {

table indextype `var', contents(n acm mean acm) format(%6.2f) center col
	}
	
//TABLE 1: BASELINE CHARACTERISTICS (from table1.xlsx)
use Stat_acm_cc, clear
table1, by(indextype) vars(age_indexdate contn \ age_cat cat \ gender cat \ imd2010_5 cat \ dmdur contn \ metoverlap contn \ prx_covvalue_g_i4 cat \ prx_covvalue_g_i5 cat \ bmi_i_cats cat \ physician_vis2 cat \ ang_i bin \ arr_i bin \ afib_i bin \ hf_i bin \ htn_i bin \ mi_i bin \ pvd_i bin \ stroke_i bin \ revasc_i bin \ prx_ccivalue_g_i2 cat \ hba1c_i contn \ hba1c_cats_i cat \ prx_covvalue_g_i3 contn \ sbp_i_cats2 cat \ egfr_amdrd contn \ ckd_amdrd cat \ unique_cov_drugs cat \ unqrx2 cat \ statin_i bin \ calchan_i bin \ betablock_i bin \ anticoag_oral_i bin \ antiplat_i bin \ ace_arb_renin_i bin \ diuretics_all_i bin) onecol format(%9.2g) saving(manuscript_tables.xlsx, sheet(Table1) sheetmodify)
//SUPPLEMENT TABLE S1: LINKED BASELINE CHARACTERISTICS (from table1_linked.xlsx)
use Stat_acm_cc, clear
table1 if linked_b==1, by(indextype) vars(age_indexdate contn \ age_cat cat \ gender cat \ imd2010_5 cat \ dmdur contn \ metoverlap contn \ prx_covvalue_g_i4 cat \ prx_covvalue_g_i5 cat \ bmi_i_cats cat \ physician_vis2 cat \ ang_i bin \ arr_i bin \ afib_i bin \ hf_i bin \ htn_i bin \ mi_i bin \ pvd_i bin \ stroke_i bin \ revasc_i bin \ prx_ccivalue_g_i2 cat \ hba1c_i contn \ hba1c_cats_i cat \ prx_covvalue_g_i3 contn \ sbp_i_cats2 cat \ egfr_amdrd contn \ ckd_amdrd cat \ unique_cov_drugs cat \ unqrx2 cat \ statin_i bin \ calchan_i bin \ betablock_i bin \ anticoag_oral_i bin \ antiplat_i bin \ ace_arb_renin_i bin \ diuretics_all_i bin) onecol format(%9.2g) saving(manuscript_tables.xlsx, sheet(TableS1) sheetmodify)

//ACM WRITTEN SECTION NUMBERS: For SMRs, IRs, person-time, HRs and CIs either use table2_acm.xlsx (Unadj MI Ref0 tab)
//OR:
use Stat_acm_mi, clear
by indextype, sort : stir acm
//mortality rates:
mi xeq 1: stptime, by(indextype) per(1000)
//get the adjusted hr:
mi estimate, hr: stcox i.indextype `mvmodel_mi'
//Either use table2_acm.xlsx (Adj MI Ref2, Adj MI Ref3, and Adj MI Ref4 tabs)
//OR to manually change the reference groups:
use Stat_acm_mi, clear
mi estimate, hr: stcox ib2.indextype `mvmodel_mi' //GLP
mi estimate, hr: stcox ib3.indextype `mvmodel_mi' //INS
mi estimate, hr: stcox ib4.indextype `mvmodel_mi' //TZD

//OVERALL OUTCOMES
//FIGURE 2A: CPRD BASE POPULATION MAIN FINDINGS- ALL OUTCOMES FOR DPP VS SU
//ACM
use Stat_acm_mi
quietly{
mi xeq 1: stptime, by(indextype) per(1000)
putexcel A1= ("ACM") B1=("Person-Time") C1=("Failures") D1=("Incidence Rate") E1=("Lower Bound") F1=("Upper Bound") using Figure2A, sheet("ACM") modify
forval i=1/2{
local row=`i'+1
mi xeq 1: stptime if indextype==`i', per(1000)
putexcel A`row'= ("`i'") B`row'=(r(ptime)) C`row'=(r(failures)) D`row'=(r(rate)*1000) E`row'=(r(lb)*1000) F`row'=(r(ub)*1000) using Figure2A, sheet("ACM") modify
}
mi xeq 1: stptime, per(1000)
putexcel A4= ("total") B4=(r(ptime)) C4=(r(failures)) D4=(r(rate)*1000) E4=(r(lb)*1000) F4=(r(ub)*1000) using Figure2A, sheet("ACM") modify
//Unadjusted
putexcel A6=("Variable") B6=("uHR") C6=("SE") D6=("p-value") E6=("LL") F6=("UL") using Figure2A, sheet("ACM") modify
mi estimate, hr: stcox i.indextype
forval i=1/2{
local x=`i'+6
local matrow=`i'+6
mi estimate, hr: stcox i.indextype 
matrix b=r(table)
matrix a= b'
local y=`i'+1
local rowname:word `y' of `matrownames_mi'
putexcel A`y'=("`rowname'") A`y'=("`rowname'") B`x'=(a[`y',1]) C`x'=(a[`y',2]) D`x'=(a[`y',4]) E`x'=(a[`y',5]) F`x'=(a[`y',6]) using Figure2A, sheet("ACM") modify
}

//Adjusted
mi estimate, hr: stcox i.indextype `mvmodel_mi'
matrix b=r(table)
matrix c=b'
matrix list c
forval i=1/2{
local y=`i'+1
local x=`y'+9
local rowname:word `y' of `matrownames_mi'
putexcel A10=("Variable") B10=("aHR") C10=("SE") D10=("p-value") E10=("LL") F6=("UL") A`x'=("`rowname'") B`x'=(c[`y',1]) C`x'=(c[`y',2]) D`x'=(c[`y',4]) E`x'=(c[`y',5]) F`x'=(c[`y',6]) using Figure2A, sheet("ACM") modify
}
putexcel A2= ("DPP-4i") A3= ("GLP-1RA") using Figure2A, sheet("ACM") modify
putexcel A7= ("DPP-4i") A8= ("GLP-1RA") using Figure2A, sheet("ACM") modify
putexcel A11= ("DPP-4i") A12= ("GLP-1RA") using Figure2A, sheet("ACM") modify
putexcel G6=("Adjusted") G7=(0) G8=(0) G11=(1) G12=(1) using Figure2A, sheet("ACM") modify
putexcel H6=("Treatment") H7=(1) H8=(2) H11=(1) H12=(2) using Figure2A, sheet("ACM") modify
putexcel I6=("Outcome") I7=(1) I8=(1) I11=(1) I12=(1) using Figure2A, sheet("ACM") modify
clear
import excel using Figure2A, sheet("ACM") cellrange(B6:I11) firstrow
drop if Treatment!=1
rename uHR HR
destring HR, gen(hr)
drop HR
destring SE, gen(se)
drop SE
destring pvalue, gen(pval)
drop pvalue
destring LL, gen(ll)
drop LL
capture rename UL ul
export excel using Figure2A.xlsx, sheet("Combined") cell(A1) firstrow(variables) sheetmod
}

//ANGINA
use Stat_angina_mi, clear
quietly {
mi xeq 1: stptime, by(indextype) per(1000)
putexcel A1= ("Angina") B1=("Person-Time") C1=("Failures") D1=("Incidence Rate") E1=("Lower Bound") F1=("Upper Bound") using Figure2A, sheet("Angina") modify
forval i=1/2{
local row=`i'+1
mi xeq 1: stptime if indextype==`i', per(1000)
putexcel A`row'= ("`i'") B`row'=(r(ptime)) C`row'=(r(failures)) D`row'=(r(rate)*1000) E`row'=(r(lb)*1000) F`row'=(r(ub)*1000) using Figure2A, sheet("Angina") modify
}
mi xeq 1: stptime, per(1000)
qui putexcel A4= ("total") B4=(r(ptime)) C4=(r(failures)) D4=(r(rate)*1000) E4=(r(lb)*1000) F4=(r(ub)*1000) using Figure2A, sheet("Angina") modify
//Unadjusted
putexcel A6=("Variable") B6=("uHR") C6=("SE") D6=("p-value") E6=("LL") F6=("UL") using Figure2A, sheet("Angina") modify
mi estimate, hr: stcox i.indextype
forval i=1/2{
local x=`i'+6
local matrow=`i'+6
mi estimate, hr: stcox i.indextype 
matrix b=r(table)
matrix a= b'
local y=`i'+1
local rowname:word `y' of `matrownames_mi'
putexcel A`y'=("`rowname'") A`y'=("`rowname'") B`x'=(a[`y',1]) C`x'=(a[`y',2]) D`x'=(a[`y',4]) E`x'=(a[`y',5]) F`x'=(a[`y',6]) using Figure2A, sheet("Angina") modify
}
//Adjusted
mi estimate, hr: stcox i.indextype `mvmodel_mi'
matrix b=r(table)
matrix c=b'
matrix list c
forval i=1/2{
local y=`i'+1
local x=`y'+9
local rowname:word `y' of `matrownames_mi'
putexcel A10=("Variable") B10=("aHR") C10=("SE") D10=("p-value") E10=("LL") F6=("UL") A`x'=("`rowname'") B`x'=(c[`y',1]) C`x'=(c[`y',2]) D`x'=(c[`y',4]) E`x'=(c[`y',5]) F`x'=(c[`y',6]) using Figure2A, sheet("Angina") modify
}
putexcel A2= ("DPP-4i") A3= ("GLP-1RA") using Figure2A, sheet("Angina") modify
putexcel A7= ("DPP-4i") A8= ("GLP-1RA") using Figure2A, sheet("Angina") modify
putexcel A11= ("DPP-4i") A12= ("GLP-1RA") using Figure2A, sheet("Angina") modify
putexcel G6=("Adjusted") G7=(0) G8=(0) G11=(1) G12=(1) using Figure2A, sheet("Angina") modify
putexcel H6=("Treatment") H7=(1) H8=(2) H11=(1) H12=(2) using Figure2A, sheet("Angina") modify
putexcel I6=("Outcome") I7=(2) I8=(2) I11=(2) I12=(2) using Figure2A, sheet("Angina") modify
clear
import excel using Figure2A, sheet("Angina") cellrange(B6:I11) firstrow
drop if Treatment!=1
rename uHR HR
destring HR, gen(hr)
drop HR
destring SE, gen(se)
drop SE
destring pvalue, gen(pval)
drop pvalue
destring LL, gen(ll)
drop LL
capture rename UL ul
export excel using Figure2A.xlsx, sheet("Combined") cell(A4) firstrow(variables) sheetmod
}
//ARRHYTHMIA
use Stat_arrhyth_mi, clear
quietly {
mi xeq 1: stptime, by(indextype) per(1000)
putexcel A1= ("Arrhythmia") B1=("Person-Time") C1=("Failures") D1=("Incidence Rate") E1=("Lower Bound") F1=("Upper Bound") using Figure2A, sheet("Arrhyth") modify
forval i=1/2{
local row=`i'+1
mi xeq 1: stptime if indextype==`i', per(1000)
putexcel A`row'= ("`i'") B`row'=(r(ptime)) C`row'=(r(failures)) D`row'=(r(rate)*1000) E`row'=(r(lb)*1000) F`row'=(r(ub)*1000) using Figure2A, sheet("Arrhyth") modify
}
mi xeq 1: stptime, per(1000)
putexcel A4= ("total") B4=(r(ptime)) C4=(r(failures)) D4=(r(rate)*1000) E4=(r(lb)*1000) F4=(r(ub)*1000) using Figure2A, sheet("Arrhyth") modify
//Unadjusted
putexcel A6=("Variable") B6=("uHR") C6=("SE") D6=("p-value") E6=("LL") F6=("UL") using Figure2A, sheet("Arrhyth") modify
mi estimate, hr: stcox i.indextype
forval i=1/2{
local x=`i'+6
local matrow=`i'+6
mi estimate, hr: stcox i.indextype 
matrix b=r(table)
matrix a= b'
local y=`i'+1
local rowname:word `y' of `matrownames_mi'
putexcel A`y'=("`rowname'") A`y'=("`rowname'") B`x'=(a[`y',1]) C`x'=(a[`y',2]) D`x'=(a[`y',4]) E`x'=(a[`y',5]) F`x'=(a[`y',6]) using Figure2A, sheet("Arrhyth") modify
}
//Adjusted
mi estimate, hr: stcox i.indextype `mvmodel_mi'
matrix b=r(table)
matrix c=b'
matrix list c
forval i=1/2{
local y=`i'+1
local x=`y'+9
local rowname:word `y' of `matrownames_mi'
putexcel A10=("Variable") B10=("aHR") C10=("SE") D10=("p-value") E10=("LL") F6=("UL") A`x'=("`rowname'") B`x'=(c[`y',1]) C`x'=(c[`y',2]) D`x'=(c[`y',4]) E`x'=(c[`y',5]) F`x'=(c[`y',6]) using Figure2A, sheet("Arrhyth") modify
}
putexcel A2= ("DPP-4i") A3= ("GLP-1RA") using Figure2A, sheet("Arrhyth") modify
putexcel A7= ("DPP-4i") A8= ("GLP-1RA") using Figure2A, sheet("Arrhyth") modify
putexcel A11= ("DPP-4i") A12= ("GLP-1RA") using Figure2A, sheet("Arrhyth") modify
putexcel G6=("Adjusted") G7=(0) G8=(0) G11=(1) G12=(1) using Figure2A, sheet("Arrhyth") modify
putexcel H6=("Treatment") H7=(1) H8=(2) H11=(1) H12=(2) using Figure2A, sheet("Arrhyth") modify
putexcel I6=("Outcome") I7=(3) I8=(3) I11=(3) I12=(3) using Figure2A, sheet("Arrhyth") modify
clear
import excel using Figure2A, sheet("Arrhyth") cellrange(B6:I11) firstrow
drop if Treatment!=1
rename uHR HR
destring HR, gen(hr)
drop HR
destring SE, gen(se)
drop SE
destring pvalue, gen(pval)
drop pvalue
destring LL, gen(ll)
drop LL
capture rename UL ul
export excel using Figure2A.xlsx, sheet("Combined") cell(A7) firstrow(variables) sheetmod
}
//HF
use Stat_hf_mi, clear
quietly {
mi xeq 1: stptime, by(indextype) per(1000)
putexcel A1= ("Heart Failure") B1=("Person-Time") C1=("Failures") D1=("Incidence Rate") E1=("Lower Bound") F1=("Upper Bound") using Figure2A, sheet("HF") modify
forval i=1/2{
local row=`i'+1
mi xeq 1: stptime if indextype==`i', per(1000)
putexcel A`row'= ("`i'") B`row'=(r(ptime)) C`row'=(r(failures)) D`row'=(r(rate)*1000) E`row'=(r(lb)*1000) F`row'=(r(ub)*1000) using Figure2A, sheet("HF") modify
}
mi xeq 1: stptime, per(1000)
putexcel A4= ("total") B4=(r(ptime)) C4=(r(failures)) D4=(r(rate)*1000) E4=(r(lb)*1000) F4=(r(ub)*1000) using Figure2A, sheet("HF") modify
//Unadjusted
putexcel A6=("Variable") B6=("uHR") C6=("SE") D6=("p-value") E6=("LL") F6=("UL") using Figure2A, sheet("HF") modify
mi estimate, hr: stcox i.indextype
forval i=1/2{
local x=`i'+6
local matrow=`i'+6
mi estimate, hr: stcox i.indextype 
matrix b=r(table)
matrix a= b'
local y=`i'+1
local rowname:word `y' of `matrownames_mi'
putexcel A`y'=("`rowname'") A`y'=("`rowname'") B`x'=(a[`y',1]) C`x'=(a[`y',2]) D`x'=(a[`y',4]) E`x'=(a[`y',5]) F`x'=(a[`y',6]) using Figure2A, sheet("HF") modify
}
//Adjusted
mi estimate, hr: stcox i.indextype `mvmodel_mi'
matrix b=r(table)
matrix c=b'
matrix list c
forval i=1/2{
local y=`i'+1
local x=`y'+9
local rowname:word `y' of `matrownames_mi'
putexcel A10=("Variable") B10=("aHR") C10=("SE") D10=("p-value") E10=("LL") F6=("UL") A`x'=("`rowname'") B`x'=(c[`y',1]) C`x'=(c[`y',2]) D`x'=(c[`y',4]) E`x'=(c[`y',5]) F`x'=(c[`y',6]) using Figure2A, sheet("HF") modify
}
putexcel A2= ("DPP-4i") A3= ("GLP-1RA") using Figure2A, sheet("HF") modify
putexcel A7= ("DPP-4i") A8= ("GLP-1RA") using Figure2A, sheet("HF") modify
putexcel A11= ("DPP-4i") A12= ("GLP-1RA") using Figure2A, sheet("HF") modify
putexcel G6=("Adjusted") G7=(0) G8=(0) G11=(1) G12=(1) using Figure2A, sheet("HF") modify
putexcel H6=("Treatment") H7=(1) H8=(2) H11=(1) H12=(2) using Figure2A, sheet("HF") modify
putexcel I6=("Outcome") I7=(4) I8=(4) I11=(4) I12=(4) using Figure2A, sheet("HF") modify
clear
import excel using Figure2A, sheet("HF") cellrange(B6:I11) firstrow
drop if Treatment!=1
rename uHR HR
destring HR, gen(hr)
drop HR
destring SE, gen(se)
drop SE
destring pvalue, gen(pval)
drop pvalue
destring LL, gen(ll)
drop LL
capture rename UL ul
export excel using Figure2A.xlsx, sheet("Combined") cell(A10) firstrow(variables) sheetmod
}
//MI
use Stat_myoinf_mi, clear
quietly {
mi xeq 1: stptime, by(indextype) per(1000)
putexcel A1= ("Myocaridial Infarction") B1=("Person-Time") C1=("Failures") D1=("Incidence Rate") E1=("Lower Bound") F1=("Upper Bound") using Figure2A, sheet("Myoinf") modify
forval i=1/2{
local row=`i'+1
mi xeq 1: stptime if indextype==`i', per(1000)
putexcel A`row'= ("`i'") B`row'=(r(ptime)) C`row'=(r(failures)) D`row'=(r(rate)*1000) E`row'=(r(lb)*1000) F`row'=(r(ub)*1000) using Figure2A, sheet("Myoinf") modify
}
mi xeq 1: stptime, per(1000)
putexcel A4= ("total") B4=(r(ptime)) C4=(r(failures)) D4=(r(rate)*1000) E4=(r(lb)*1000) F4=(r(ub)*1000) using Figure2A, sheet("Myoinf") modify
//Unadjusted
putexcel A6=("Variable") B6=("uHR") C6=("SE") D6=("p-value") E6=("LL") F6=("UL") using Figure2A, sheet("Myoinf") modify
mi estimate, hr: stcox i.indextype
forval i=1/2{
local x=`i'+6
local matrow=`i'+6
mi estimate, hr: stcox i.indextype 
matrix b=r(table)
matrix a= b'
local y=`i'+1
local rowname:word `y' of `matrownames_mi'
putexcel A`y'=("`rowname'") A`y'=("`rowname'") B`x'=(a[`y',1]) C`x'=(a[`y',2]) D`x'=(a[`y',4]) E`x'=(a[`y',5]) F`x'=(a[`y',6]) using Figure2A, sheet("Myoinf") modify
}
//Adjusted
mi estimate, hr: stcox i.indextype `mvmodel_mi'
matrix b=r(table)
matrix c=b'
matrix list c
forval i=1/2{
local y=`i'+1
local x=`y'+9
local rowname:word `y' of `matrownames_mi'
putexcel A10=("Variable") B10=("aHR") C10=("SE") D10=("p-value") E10=("LL") F6=("UL") A`x'=("`rowname'") B`x'=(c[`y',1]) C`x'=(c[`y',2]) D`x'=(c[`y',4]) E`x'=(c[`y',5]) F`x'=(c[`y',6]) using Figure2A, sheet("Myoinf") modify
}
putexcel A2= ("DPP-4i") A3= ("GLP-1RA") using Figure2A, sheet("Myoinf") modify
putexcel A7= ("DPP-4i") A8= ("GLP-1RA") using Figure2A, sheet("Myoinf") modify
putexcel A11= ("DPP-4i") A12= ("GLP-1RA") using Figure2A, sheet("Myoinf") modify
putexcel G6=("Adjusted") G7=(0) G8=(0) G11=(1) G12=(1) using Figure2A, sheet("Myoinf") modify
putexcel H6=("Treatment") H7=(1) H8=(2) H11=(1) H12=(2) using Figure2A, sheet("Myoinf") modify
putexcel I6=("Outcome") I7=(5) I8=(5) I11=(5) I12=(5) using Figure2A, sheet("Myoinf") modify
clear
import excel using Figure2A, sheet("Myoinf") cellrange(B6:I11) firstrow
drop if Treatment!=1
rename uHR HR
destring HR, gen(hr)
drop HR
destring SE, gen(se)
drop SE
destring pvalue, gen(pval)
drop pvalue
destring LL, gen(ll)
drop LL
capture rename UL ul
export excel using Figure2A.xlsx, sheet("Combined") cell(A13) firstrow(variables) sheetmod
}
//REVASC
use Stat_revasc_mi, clear
quietly {
mi xeq 1: stptime, by(indextype) per(1000)
putexcel A1= ("Urgent Revascularization") B1=("Person-Time") C1=("Failures") D1=("Incidence Rate") E1=("Lower Bound") F1=("Upper Bound") using Figure2A, sheet("Revasc") modify
forval i=1/2{
local row=`i'+1
mi xeq 1: stptime if indextype==`i', per(1000)
putexcel A`row'= ("`i'") B`row'=(r(ptime)) C`row'=(r(failures)) D`row'=(r(rate)*1000) E`row'=(r(lb)*1000) F`row'=(r(ub)*1000) using Figure2A, sheet("Revasc") modify
}
mi xeq 1: stptime, per(1000)
putexcel A4= ("total") B4=(r(ptime)) C4=(r(failures)) D4=(r(rate)*1000) E4=(r(lb)*1000) F4=(r(ub)*1000) using Figure2A, sheet("Revasc") modify
//Unadjusted
putexcel A6=("Variable") B6=("uHR") C6=("SE") D6=("p-value") E6=("LL") F6=("UL") using Figure2A, sheet("Revasc") modify
mi estimate, hr: stcox i.indextype
forval i=1/2{
local x=`i'+6
local matrow=`i'+6
mi estimate, hr: stcox i.indextype 
matrix b=r(table)
matrix a= b'
local y=`i'+1
local rowname:word `y' of `matrownames_mi'
putexcel A`y'=("`rowname'") A`y'=("`rowname'") B`x'=(a[`y',1]) C`x'=(a[`y',2]) D`x'=(a[`y',4]) E`x'=(a[`y',5]) F`x'=(a[`y',6]) using Figure2A, sheet("Revasc") modify
}
//Adjusted
mi estimate, hr: stcox i.indextype `mvmodel_mi'
matrix b=r(table)
matrix c=b'
matrix list c
forval i=1/2{
local y=`i'+1
local x=`y'+9
local rowname:word `y' of `matrownames_mi'
putexcel A10=("Variable") B10=("aHR") C10=("SE") D10=("p-value") E10=("LL") F6=("UL") A`x'=("`rowname'") B`x'=(c[`y',1]) C`x'=(c[`y',2]) D`x'=(c[`y',4]) E`x'=(c[`y',5]) F`x'=(c[`y',6]) using Figure2A, sheet("Revasc") modify
}
putexcel A2= ("DPP-4i") A3= ("GLP-1RA") using Figure2A, sheet("Revasc") modify
putexcel A7= ("DPP-4i") A8= ("GLP-1RA") using Figure2A, sheet("Revasc") modify
putexcel A11= ("DPP-4i") A12= ("GLP-1RA") using Figure2A, sheet("Revasc") modify
putexcel G6=("Adjusted") G7=(0) G8=(0) G11=(1) G12=(1) using Figure2A, sheet("Revasc") modify
putexcel H6=("Treatment") H7=(1) H8=(2) H11=(1) H12=(2) using Figure2A, sheet("Revasc") modify
putexcel I6=("Outcome") I7=(6) I8=(6) I11=(6) I12=(6) using Figure2A, sheet("Revasc") modify
clear
import excel using Figure2A, sheet("Revasc") cellrange(B6:I11) firstrow
drop if Treatment!=1
rename uHR HR
destring HR, gen(hr)
drop HR
destring SE, gen(se)
drop SE
destring pvalue, gen(pval)
drop pvalue
destring LL, gen(ll)
drop LL
capture rename UL ul
export excel using Figure2A.xlsx, sheet("Combined") cell(A16) firstrow(variables) sheetmod
}
//STROKE
use Stat_stroke_mi, clear
quietly {
mi xeq 1: stptime, by(indextype) per(1000)
putexcel A1= ("Stroke") B1=("Person-Time") C1=("Failures") D1=("Incidence Rate") E1=("Lower Bound") F1=("Upper Bound") using Figure2A, sheet("Stroke") modify
forval i=1/2{
local row=`i'+1
mi xeq 1: stptime if indextype==`i', per(1000)
putexcel A`row'= ("`i'") B`row'=(r(ptime)) C`row'=(r(failures)) D`row'=(r(rate)*1000) E`row'=(r(lb)*1000) F`row'=(r(ub)*1000) using Figure2A, sheet("Stroke") modify
}
mi xeq 1: stptime, per(1000)
putexcel A4= ("total") B4=(r(ptime)) C4=(r(failures)) D4=(r(rate)*1000) E4=(r(lb)*1000) F4=(r(ub)*1000) using Figure2A, sheet("Stroke") modify
//Unadjusted
putexcel A6=("Variable") B6=("uHR") C6=("SE") D6=("p-value") E6=("LL") F6=("UL") using Figure2A, sheet("Stroke") modify
mi estimate, hr: stcox i.indextype
forval i=1/2{
local x=`i'+6
local matrow=`i'+6
mi estimate, hr: stcox i.indextype 
matrix b=r(table)
matrix a= b'
local y=`i'+1
local rowname:word `y' of `matrownames_mi'
putexcel A`y'=("`rowname'") A`y'=("`rowname'") B`x'=(a[`y',1]) C`x'=(a[`y',2]) D`x'=(a[`y',4]) E`x'=(a[`y',5]) F`x'=(a[`y',6]) using Figure2A, sheet("Stroke") modify
}
//Adjusted
mi estimate, hr: stcox i.indextype `mvmodel_mi'
matrix b=r(table)
matrix c=b'
matrix list c
forval i=1/2{
local y=`i'+1
local x=`y'+9
local rowname:word `y' of `matrownames_mi'
putexcel A10=("Variable") B10=("aHR") C10=("SE") D10=("p-value") E10=("LL") F6=("UL") A`x'=("`rowname'") B`x'=(c[`y',1]) C`x'=(c[`y',2]) D`x'=(c[`y',4]) E`x'=(c[`y',5]) F`x'=(c[`y',6]) using Figure2A, sheet("Stroke") modify
}
putexcel A2= ("DPP-4i") A3= ("GLP-1RA") using Figure2A, sheet("Stroke") modify
putexcel A7= ("DPP-4i") A8= ("GLP-1RA") using Figure2A, sheet("Stroke") modify
putexcel A11= ("DPP-4i") A12= ("GLP-1RA") using Figure2A, sheet("Stroke") modify
putexcel G6=("Adjusted") G7=(0) G8=(0) G11=(1) G12=(1) using Figure2A, sheet("Stroke") modify
putexcel H6=("Treatment") H7=(1) H8=(2) H11=(1) H12=(2) using Figure2A, sheet("Stroke") modify
putexcel I6=("Outcome") I7=(7) I8=(7) I11=(7) I12=(7) using Figure2A, sheet("Stroke") modify
clear
import excel using Figure2A, sheet("Stroke") cellrange(B6:I11) firstrow
drop if Treatment!=1
rename uHR HR
destring HR, gen(hr)
drop HR
destring SE, gen(se)
drop SE
destring pvalue, gen(pval)
drop pvalue
destring LL, gen(ll)
drop LL
capture rename UL ul
export excel using Figure2A.xlsx, sheet("Combined") cell(A19) firstrow(variables) sheetmod
}


//generate dta needed for Figure2A
quietly{
clear
import excel using Figure2A, sheet("Combined") cellrange(A1:H21) firstrow
drop if Treatment!="1"
drop Treatment
destring hr, gen(HR)
drop hr
destring se, gen(SE)
drop se
destring pval, gen(pvalue)
drop pval
destring ll, gen(LL)
drop ll
destring ul, gen(UL)
drop ul
destring Adjusted, gen(adj)
drop Adjusted
destring Outcome, gen(outcome)
drop Outcome
save Figure2A, replace
//generate Figure 2A
use Figure2A, clear
capture label drop outcomes
label define outcomes 1 "{bf}ACM" 2 "{bf}Angina" 3 "{bf}Arrhythmia" 4 "{bf}Heart Failure" 5 "{bf}Myocardial Infarction" 6 "{bf}Urgent Revascularization" 7 "{bf}Stroke" 8 "{bf}MACE" 9 "{bf}CV Death" 10 "{bf}Myocardial {bf}Infarction" 11 "{bf}Stroke"
capture rename outcome Outcome
label values Outcome outcomes
capture label drop adjustments
label define adjustments 0 "Unadjusted" 1 "Adjusted"
capture rename adj Model
label values Model adjustments
label var Model "{bf}Outcome"
metan HR LL UL, force by(Outcome) nowt nobox nooverall null(1) scheme(s1mono) xlabel(0, 1, 2, 3) lcols(Model) effect("Hazard Ratio")
}
//generate Figure2A
metan HR LL UL, force by(Outcome) nowt nobox nooverall nosubgroup null(1) astext(45) scheme(s1mono) xlabel(0, 0.25, 0.5, 0.75, 1.25) lcols(Model) effect("{bf}Hazard {bf}Ratio") saving(Figure2A, asis replace)
graph export Figure2A.png, replace

//FIGURE 2B: LINKED ONLY POPULATION MAIN FINDINGS- ALL OUTCOMES FOR DPP VS SU  
//MACE
use Stat_mace_mi, clear
keep if linked_b==1
quietly {
mi xeq 1: stptime, by(indextype) per(1000)
putexcel A1= ("MACE") B1=("Person-Time") C1=("Failures") D1=("Incidence Rate") E1=("Lower Bound") F1=("Upper Bound") using Figure2B, sheet("MACE") modify
forval i=1/2{
local row=`i'+1
mi xeq 1: stptime if indextype==`i', per(1000)
putexcel A`row'= ("`i'") B`row'=(r(ptime)) C`row'=(r(failures)) D`row'=(r(rate)*1000) E`row'=(r(lb)*1000) F`row'=(r(ub)*1000) using Figure2B, sheet("MACE") modify
}
mi xeq 1: stptime, per(1000)
putexcel A4= ("total") B4=(r(ptime)) C4=(r(failures)) D4=(r(rate)*1000) E4=(r(lb)*1000) F4=(r(ub)*1000) using Figure2B, sheet("MACE") modify
//Unadjusted
putexcel A6=("Variable") B6=("uHR") C6=("SE") D6=("p-value") E6=("LL") F6=("UL") using Figure2B, sheet("MACE") modify
mi estimate, hr: stcox i.indextype
forval i=1/2{
local x=`i'+6
local matrow=`i'+6
mi estimate, hr: stcox i.indextype 
matrix b=r(table)
matrix a= b'
local y=`i'+1
local rowname:word `y' of `matrownames_mi'
putexcel A`y'=("`rowname'") A`y'=("`rowname'") B`x'=(a[`y',1]) C`x'=(a[`y',2]) D`x'=(a[`y',4]) E`x'=(a[`y',5]) F`x'=(a[`y',6]) using Figure2B, sheet("MACE") modify
}
//Adjusted
mi estimate, hr: stcox i.indextype `mvmodel_mi'
matrix b=r(table)
matrix c=b'
matrix list c
forval i=1/2{
local y=`i'+1
local x=`y'+9
local rowname:word `y' of `matrownames_mi'
putexcel A10=("Variable") B10=("aHR") C10=("SE") D10=("p-value") E10=("LL") F6=("UL") A`x'=("`rowname'") B`x'=(c[`y',1]) C`x'=(c[`y',2]) D`x'=(c[`y',4]) E`x'=(c[`y',5]) F`x'=(c[`y',6]) using Figure2B, sheet("MACE") modify
}
putexcel A2= ("DPP-4i") A3= ("GLP-1RA") using Figure2B, sheet("MACE") modify
putexcel A7= ("DPP-4i") A8= ("GLP-1RA") using Figure2B, sheet("MACE") modify
putexcel A11= ("DPP-4i") A12= ("GLP-1RA") using Figure2B, sheet("MACE") modify
putexcel G6=("Adjusted") G7=(0) G8=(0) G11=(1) G12=(1) using Figure2B, sheet("MACE") modify
putexcel H6=("Treatment") H7=(1) H8=(2) H11=(1) H12=(2) using Figure2B, sheet("MACE") modify
putexcel I6=("Outcome") I7=(1) I8=(1) I11=(1) I12=(1) using Figure2B, sheet("MACE") modify
clear
import excel using Figure2B, sheet("MACE") cellrange(B6:I11) firstrow
drop if Treatment!=1
rename uHR HR
destring HR, gen(hr)
drop HR
destring SE, gen(se)
drop SE
destring pvalue, gen(pval)
drop pvalue
destring LL, gen(ll)
drop LL
capture rename UL ul
export excel using Figure2B.xlsx, sheet("Combined") cell(A1) firstrow(variables) sheetmod
}
//CVDEATH
use Stat_cvdeath_mi, clear
keep if linked_b==1
quietly {
mi xeq 1: stptime, by(indextype) per(1000)
putexcel A1= ("CV Death") B1=("Person-Time") C1=("Failures") D1=("Incidence Rate") E1=("Lower Bound") F1=("Upper Bound") using Figure2B, sheet("CVDeath") modify
forval i=1/2{
local row=`i'+1
mi xeq 1: stptime if indextype==`i', per(1000)
putexcel A`row'= ("`i'") B`row'=(r(ptime)) C`row'=(r(failures)) D`row'=(r(rate)*1000) E`row'=(r(lb)*1000) F`row'=(r(ub)*1000) using Figure2B, sheet("CVDeath") modify
}
mi xeq 1: stptime, per(1000)
putexcel A4= ("total") B4=(r(ptime)) C4=(r(failures)) D4=(r(rate)*1000) E4=(r(lb)*1000) F4=(r(ub)*1000) using Figure2B, sheet("CVDeath") modify
//Unadjusted
putexcel A6=("Variable") B6=("uHR") C6=("SE") D6=("p-value") E6=("LL") F6=("UL") using Figure2B, sheet("CVDeath") modify
mi estimate, hr: stcox i.indextype
forval i=1/2{
local x=`i'+6
local matrow=`i'+6
mi estimate, hr: stcox i.indextype 
matrix b=r(table)
matrix a= b'
local y=`i'+1
local rowname:word `y' of `matrownames_mi'
putexcel A`y'=("`rowname'") A`y'=("`rowname'") B`x'=(a[`y',1]) C`x'=(a[`y',2]) D`x'=(a[`y',4]) E`x'=(a[`y',5]) F`x'=(a[`y',6]) using Figure2B, sheet("CVDeath") modify
}
//Adjusted
mi estimate, hr: stcox i.indextype `mvmodel_mi'
matrix b=r(table)
matrix c=b'
matrix list c
forval i=1/2{
local y=`i'+1
local x=`y'+9
local rowname:word `y' of `matrownames_mi'
putexcel A10=("Variable") B10=("aHR") C10=("SE") D10=("p-value") E10=("LL") F6=("UL") A`x'=("`rowname'") B`x'=(c[`y',1]) C`x'=(c[`y',2]) D`x'=(c[`y',4]) E`x'=(c[`y',5]) F`x'=(c[`y',6]) using Figure2B, sheet("CVDeath") modify
}
putexcel A2= ("DPP-4i") A3= ("GLP-1RA") using Figure2B, sheet("CVDeath") modify
putexcel A7= ("DPP-4i") A8= ("GLP-1RA") using Figure2B, sheet("CVDeath") modify
putexcel A11= ("DPP-4i") A12= ("GLP-1RA") using Figure2B, sheet("CVDeath") modify
putexcel G6=("Adjusted") G7=(0) G8=(0) G11=(1) G12=(1) using Figure2B, sheet("CVDeath") modify
putexcel H6=("Treatment") H7=(1) H8=(2) H11=(1) H12=(2) using Figure2B, sheet("CVDeath") modify
putexcel I6=("Outcome") I7=(2) I8=(2) I11=(2) I12=(2) using Figure2B, sheet("CVDeath") modify
clear
import excel using Figure2B, sheet("CVDeath") cellrange(B6:I11) firstrow
drop if Treatment!=1
rename uHR HR
destring HR, gen(hr)
drop HR
destring SE, gen(se)
drop SE
destring pvalue, gen(pval)
drop pvalue
destring LL, gen(ll)
drop LL
capture rename UL ul
export excel using Figure2B.xlsx, sheet("Combined") cell(A4) firstrow(variables) sheetmod
}
//MI
use Stat_myoinf_mi, clear
keep if linked_b==1
quietly {
mi xeq 1: stptime, by(indextype) per(1000)
putexcel A1= ("Myocardial Infarction, linked") B1=("Person-Time") C1=("Failures") D1=("Incidence Rate") E1=("Lower Bound") F1=("Upper Bound") using Figure2B, sheet("Myoinf") modify
forval i=1/2{
local row=`i'+1
mi xeq 1: stptime if indextype==`i', per(1000)
putexcel A`row'= ("`i'") B`row'=(r(ptime)) C`row'=(r(failures)) D`row'=(r(rate)*1000) E`row'=(r(lb)*1000) F`row'=(r(ub)*1000) using Figure2B, sheet("Myoinf") modify
}
mi xeq 1: stptime, per(1000)
putexcel A4= ("total") B4=(r(ptime)) C4=(r(failures)) D4=(r(rate)*1000) E4=(r(lb)*1000) F4=(r(ub)*1000) using Figure2B, sheet("Myoinf") modify
//Unadjusted
putexcel A6=("Variable") B6=("uHR") C6=("SE") D6=("p-value") E6=("LL") F6=("UL") using Figure2B, sheet("Myoinf") modify
mi estimate, hr: stcox i.indextype
forval i=1/2{
local x=`i'+6
local matrow=`i'+6
mi estimate, hr: stcox i.indextype 
matrix b=r(table)
matrix a= b'
local y=`i'+1
local rowname:word `y' of `matrownames_mi'
putexcel A`y'=("`rowname'") A`y'=("`rowname'") B`x'=(a[`y',1]) C`x'=(a[`y',2]) D`x'=(a[`y',4]) E`x'=(a[`y',5]) F`x'=(a[`y',6]) using Figure2B, sheet("Myoinf") modify
}
//Adjusted
mi estimate, hr: stcox i.indextype `mvmodel_mi'
matrix b=r(table)
matrix c=b'
matrix list c
forval i=1/2{
local y=`i'+1
local x=`y'+9
local rowname:word `y' of `matrownames_mi'
putexcel A10=("Variable") B10=("aHR") C10=("SE") D10=("p-value") E10=("LL") F6=("UL") A`x'=("`rowname'") B`x'=(c[`y',1]) C`x'=(c[`y',2]) D`x'=(c[`y',4]) E`x'=(c[`y',5]) F`x'=(c[`y',6]) using Figure2B, sheet("Myoinf") modify
}
putexcel A2= ("DPP-4i") A3= ("GLP-1RA") using Figure2B, sheet("Myoinf") modify
putexcel A7= ("DPP-4i") A8= ("GLP-1RA") using Figure2B, sheet("Myoinf") modify
putexcel A11= ("DPP-4i") A12= ("GLP-1RA") using Figure2B, sheet("Myoinf") modify
putexcel G6=("Adjusted") G7=(0) G8=(0) G11=(1) G12=(1) using Figure2B, sheet("Myoinf") modify
putexcel H6=("Treatment") H7=(1) H8=(2) H11=(1) H12=(2) using Figure2B, sheet("Myoinf") modify
putexcel I6=("Outcome") I7=(3) I8=(3) I11=(3) I12=(3) using Figure2B, sheet("Myoinf") modify
clear
import excel using Figure2B, sheet("Myoinf") cellrange(B6:I11) firstrow
drop if Treatment!=1
rename uHR HR
destring HR, gen(hr)
drop HR
destring SE, gen(se)
drop SE
destring pvalue, gen(pval)
drop pvalue
destring LL, gen(ll)
drop LL
capture rename UL ul
export excel using Figure2B.xlsx, sheet("Combined") cell(A7) firstrow(variables) sheetmod
}
//STROKE
use Stat_stroke_mi, clear
keep if linked_b==1
quietly {
mi xeq 1: stptime, by(indextype) per(1000)
putexcel A1= ("Stroke, linked") B1=("Person-Time") C1=("Failures") D1=("Incidence Rate") E1=("Lower Bound") F1=("Upper Bound") using Figure2B, sheet("Stroke") modify
forval i=1/2{
local row=`i'+1
mi xeq 1: stptime if indextype==`i', per(1000)
putexcel A`row'= ("`i'") B`row'=(r(ptime)) C`row'=(r(failures)) D`row'=(r(rate)*1000) E`row'=(r(lb)*1000) F`row'=(r(ub)*1000) using Figure2B, sheet("Stroke") modify
}
mi xeq 1: stptime, per(1000)
putexcel A4= ("total") B4=(r(ptime)) C4=(r(failures)) D4=(r(rate)*1000) E4=(r(lb)*1000) F4=(r(ub)*1000) using Figure2B, sheet("Stroke") modify
//Unadjusted
putexcel A6=("Variable") B6=("uHR") C6=("SE") D6=("p-value") E6=("LL") F6=("UL") using Figure2B, sheet("Stroke") modify
mi estimate, hr: stcox i.indextype
forval i=1/2{
local x=`i'+6
local matrow=`i'+6
mi estimate, hr: stcox i.indextype 
matrix b=r(table)
matrix a= b'
local y=`i'+1
local rowname:word `y' of `matrownames_mi'
putexcel A`y'=("`rowname'") A`y'=("`rowname'") B`x'=(a[`y',1]) C`x'=(a[`y',2]) D`x'=(a[`y',4]) E`x'=(a[`y',5]) F`x'=(a[`y',6]) using Figure2B, sheet("Stroke") modify
}
//Adjusted
mi estimate, hr: stcox i.indextype `mvmodel_mi'
matrix b=r(table)
matrix c=b'
matrix list c
forval i=1/2{
local y=`i'+1
local x=`y'+9
local rowname:word `y' of `matrownames_mi'
putexcel A10=("Variable") B10=("aHR") C10=("SE") D10=("p-value") E10=("LL") F6=("UL") A`x'=("`rowname'") B`x'=(c[`y',1]) C`x'=(c[`y',2]) D`x'=(c[`y',4]) E`x'=(c[`y',5]) F`x'=(c[`y',6]) using Figure2B, sheet("Stroke") modify
}
putexcel A2= ("DPP-4i") A3= ("GLP-1RA") using Figure2B, sheet("Stroke") modify
putexcel A7= ("DPP-4i") A8= ("GLP-1RA") using Figure2B, sheet("Stroke") modify
putexcel A11= ("DPP-4i") A12= ("GLP-1RA") using Figure2B, sheet("Stroke") modify
putexcel G6=("Adjusted") G7=(0) G8=(0) G11=(1) G12=(1) using Figure2B, sheet("Stroke") modify
putexcel H6=("Treatment") H7=(1) H8=(2) H11=(1) H12=(2) using Figure2B, sheet("Stroke") modify
putexcel I6=("Outcome") I7=(4) I8=(4) I11=(4) I12=(4) using Figure2B, sheet("Stroke") modify
clear
import excel using Figure2B, sheet("Stroke") cellrange(B6:I11) firstrow
drop if Treatment!=1
rename uHR HR
destring HR, gen(hr)
drop HR
destring SE, gen(se)
drop SE
destring pvalue, gen(pval)
drop pvalue
destring LL, gen(ll)
drop LL
capture rename UL ul
export excel using Figure2B.xlsx, sheet("Combined") cell(A10) firstrow(variables) sheetmod
}
//generate dta needed for Figure2B
quietly{
clear
import excel using Figure2B, sheet("Combined") cellrange(A1:H12) firstrow
drop if Treatment!="1"
drop Treatment
destring hr, gen(HR)
drop hr
destring se, gen(SE)
drop se
destring pval, gen(pvalue)
drop pval
destring ll, gen(LL)
drop ll
destring ul, gen(UL)
drop ul
destring Adjusted, gen(adj)
drop Adjusted
destring Outcome, gen(outcome)
drop Outcome
save Figure2A, replace
//generate Figure 2A
use Figure2A, clear
capture label drop outcomes
label define outcomes 1 "{bf}MACE" 2 "{bf}CV Death" 3 "{bf}Myocardial {bf}Infarction" 4 "{bf}Stroke"
capture rename outcome Outcome
label values Outcome outcomes
capture label drop adjustments
label define adjustments 0 "Unadjusted" 1 "Adjusted"
capture rename adj Model
label values Model adjustments
label var Model "{bf}Outcome"
metan HR LL UL, force by(Outcome) nowt nobox nooverall null(1) scheme(s1mono) xlabel(0, 1, 2, 3) lcols(Model) effect("Hazard Ratio")
}
//generate Figure2B
metan HR LL UL, force by(Outcome) nowt nobox nooverall nosubgroup null(1) astext(45) scheme(s1mono) xlabel(0, 0.25, 0.5, 0.75, 1.25) lcols(Model) effect("{bf}Hazard {bf}Ratio") saving(Figure2A, asis replace)
graph export Figure2B.png, replace

//SUPPLEMENT FIGURE S2: ACM FINDINGS FOR ALL CLASSES (UNADJ VS ADJ)
use Stat_acm_mi, clear
//IR
mi xeq 1: stptime, by(indextype) per(1000)
quietly {
putexcel A1= ("ACM") B1=("Person-Time") C1=("Failures") D1=("Incidence Rate") E1=("Lower Bound") F1=("Upper Bound") G10=("Event") H10=("No Event") using FigureS2, modify
forval i=0/5{
local row=`i'+2
mi xeq 1: stptime if indextype==`i', per(1000)
putexcel A`row'= ("`i'") B`row'=(r(ptime)) C`row'=(r(failures)) D`row'=(r(rate)*1000) E`row'=(r(lb)*1000) F`row'=(r(ub)*1000) using FigureS2, modify
}
mi xeq 1: stptime, per(1000)
putexcel A8= ("total") B8=(r(ptime)) C8=(r(failures)) D8=(r(rate)*1000) E8=(r(lb)*1000) F8=(r(ub)*1000) using FigureS2, modify
}
//Unadjusted
mi estimate, hr: stcox i.indextype 
qui{
putexcel A10=("Variable") B10=("uHR") C10=("SE") D10=("p-value") E10=("LL") F10=("UL") using FigureS2, modify
forval i=1/5{
local x=`i'+10
mi estimate, hr: stcox i.indextype 
matrix b=r(table)
matrix a= b'
local y=`i'+1
local rowname:word `y' of `matrownames_mi'
putexcel A`y'=("`rowname'") A`y'=("`rowname'") B`x'=(a[`y',1]) C`x'=(a[`y',2]) D`x'=(a[`y',4]) E`x'=(a[`y',5]) F`x'=(a[`y',6]) using FigureS2,modify
//Number of events and non events
forval i=1/5{
local row=`i'+10
mi xeq 1: stptime if indextype==`i', per(1000)
putexcel G`row'=(r(failures)) using FigureS2, modify
unique patid if indextype==`i'
putexcel H`row'=(r(sum)) using FigureS2, modify
}
}
}
//Adjusted
mi estimate, hr: stcox i.indextype `mvmodel_mi'
qui{
matrix b=r(table)
matrix c=b'
matrix list c
forval i=1/5{
local x=`i'+17
local y=`i'+1
putexcel A17=("Variable") B17=("aHR") C17=("SE") D17=("p-value") E17=("LL") F17=("UL") B`x'=(c[`y',1]) C`x'=(c[`y',2]) D`x'=(c[`y',4]) E`x'=(c[`y',5]) F`x'=(c[`y',6]) using FigureS2, modify
}
putexcel A2= ("0") using Figure2, modify
putexcel A3= ("1") A11= ("1") A18=("1") using FigureS2, modify
putexcel A4= ("2") A12= ("2") A19=("2") using FigureS2, modify
putexcel A5= ("3") A13= ("3") A20=("3") using FigureS2, modify
putexcel A6= ("4") A14= ("4") A21=("4") using FigureS2, modify
putexcel A7= ("5") A15= ("5") A22=("5") using FigureS2, modify
}
//generate dat file needed for FigureS2
quietly{
clear
import excel using FigureS2, cellrange(A10:H22) firstrow
rename Event fail
gen nofail=NoEvent-fail
drop NoEvent
drop if Variable=="Variable"|Variable==""
destring Variable, gen(class)
drop Variable
gen adj=0
replace adj=1 if fail==.
destring uHR, gen(hr)
drop uHR
destring SE, gen(se)
drop SE
destring pvalue, gen(pval)
drop pvalue
destring LL, gen(ll)
drop LL
destring UL, gen(ul)
drop UL
save FigureS2, replace
capture label drop classes
capture label drop adjusted
label define classes 0 "{bf}SU" 1 "{bf}DPP4i" 2 "{bf}GLP-1RA" 3 "{bf}Insulin" 4 "{bf}Thiazolidinedione" 5 "{bf}Other {bf}antidiabetic"
label values class classes
label define adjusted 0 "Unadjusted" 1 "Adjusted"
label values adj adjusted
label var class "{bf}Class"
label var fail "{bf}Events"
label var nofail "{bf}No {bf}Events"
label var adj "{bf}Antidiabetic {bf}Class"
metan hr ll ul, force by(class) nowt nobox nooverall null(1) xlabel(0, 0.25, 0.5, 0.75) astext(70) scheme(s1mono) lcols(fail nofail) effect("Hazard Ratio")
}
//generate FigureS2
metan hr ll ul, force by(class) nowt nobox nooverall nosubgroup null(1) xlabel(0, 2, 3, 4, 5) astext(55) scheme(s1mono) lcols(adj) rcols(fail nofail) effect("{bf}Hazard {bf}Ratio") saving(FigureS2, asis replace)

//SUPPLEMENT TABLE S2: DPP SUBCLASS RATES
//Generate additional incidence data for subclasses of DPP
use Stat_acm_mi, clear
quietly {
gen dpptype = .
replace dpptype = 1 if indextype==1&alogliptin==1
replace dpptype = 2 if indextype==1&linagliptin==1
replace dpptype = 3 if indextype==1&sitagliptin==1
replace dpptype = 4 if indextype==1&saxagliptin==1
replace dpptype = 5 if indextype==1&vildagliptin==1
putexcel A1= ("DPP Subclass") B1=("Person-Time") C1=("Failures") D1=("Incidence Rate") E1=("Lower Bound") F1=("Upper Bound") using manuscript_tables, sheet("TableS2") modify
forval i=2/5{
local row=`i'+1
mi xeq 1: stptime if dpptype==`i', per(1000)
putexcel A`row'= ("`i'") B`row'=(r(ptime)) C`row'=(r(failures)) D`row'=(r(rate)*1000) E`row'=(r(lb)*1000) F`row'=(r(ub)*1000) using manuscript_tables, sheet("TableS2") modify
}
mi xeq 2: stptime, by(dpptype) per(1000)
putexcel A8= ("total") B8=(r(ptime)) C8=(r(failures)) D8=(r(rate)*1000) E8=(r(lb)*1000) F8=(r(ub)*1000) using manuscript_tables, sheet("TableS2") modify
putexcel A2=("Alogliptin") A3=("Linagliptin") A4=("Sitagliptin") A5=("Saxagliptin") A6=("Vildagliptin") using manuscript_tables, sheet("TableS2") modify
putexcel B2= ("No observations") using manuscript_tables, sheet("TableS2") modify
}

//SUPPLEMENT FIGURE S3: UNADJUSTED AND ADJUSTED COX PROPORTIONAL HAZARDS REGRESSION ANALYSIS
use Stat_acm_mi, clear
// 1. Unadjusted model
mi estimate, hr: stcox i.indextype, cformat(%6.2f) pformat(%5.3f) sformat(%6.2f)
qui {
matrix b=r(table)
matrix c=b'
matrix list c
local i=2
local x=`i'
putexcel A1 = ("DPP-4i vs SU") A`x'=("Unadjusted") B1=("HR") C1=("SE") D1=("p-value") E1=("LL") F1=("UL") B`x'=(c[`i',1]) C`x'=(c[`i',2]) D`x'=(c[`i',4]) E`x'=(c[`i',5]) F`x'=(c[`i',6]) using FigureS3, modify
}
// 2. + age, gender
mi estimate, hr: stcox i.indextype age_index gender, cformat(%6.2f) pformat(%5.3f) sformat(%6.2f)  
qui{
matrix b=r(table)
matrix c=b'
matrix list c
local i=2
local x=`i'+1
putexcel A`x'=("Adjusted for age and gender") B1=("HR") C1=("SE") D1=("p-value") E1=("LL") F1=("UL") B`x'=(c[`i',1]) C`x'=(c[`i',2]) D`x'=(c[`i',4]) E`x'=(c[`i',5]) F`x'=(c[`i',6]) using FigureS3, modify
}
// 3. + dmdur, metoverlap, hba1c
mi estimate, hr: stcox i.indextype age_indexdate gender dmdur metoverlap ib1.hba1c_cats_i2, cformat(%6.2f) pformat(%5.3f) sformat(%6.2f) 
qui{
matrix b=r(table)
matrix c=b'
matrix list c
local i=2
local x=`i'+2
putexcel A`x'=("Plus dmdur, metoverlap, and A1C") B1=("HR") C1=("SE") D1=("p-value") E1=("LL") F1=("UL") B`x'=(c[`i',1]) C`x'=(c[`i',2]) D`x'=(c[`i',4]) E`x'=(c[`i',5]) F`x'=(c[`i',6]) using FigureS3, modify
}
// 4. + bmi, ckd, unique drugs, physician visits, cci
mi estimate, hr: stcox i.indextype age_indexdate gender dmdur metoverlap ib1.hba1c_cats_i2 ib1.sbp_i_cats2 i.ckd_amdrd i.unique_cov_drugs i.physician_vis2 i.prx_ccivalue_g_i2, cformat(%6.2f) pformat(%5.3f) sformat(%6.2f)  
qui{
matrix b=r(table)
matrix c=b'
matrix list c
local i=2
local x=`i'+3
putexcel A`x'=("Plus BMI, CKD, unqrx, visits, CCI") B1=("HR") C1=("SE") D1=("p-value") E1=("LL") F1=("UL") B`x'=(c[`i',1]) C`x'=(c[`i',2]) D`x'=(c[`i',4]) E`x'=(c[`i',5]) F`x'=(c[`i',6]) using FigureS3, modify
}
// 5. Test out full multivariate model (mvmodel) all covariates included
mi estimate, hr: stcox i.indextype `mvmodel_mi', cformat(%6.2f) pformat(%5.3f) sformat(%6.2f) 
qui{
matrix b=r(table)
matrix c=b'
matrix list c
local i=2
local x=`i'+4
putexcel A`x'=("Fully Adjusted") B1=("HR") C1=("SE") D1=("p-value") E1=("LL") F1=("UL") B`x'=(c[`i',1]) C`x'=(c[`i',2]) D`x'=(c[`i',4]) E`x'=(c[`i',5]) F`x'=(c[`i',6]) using FigureS3, modify
}
// 6. Propensity score model plus age and gender
use Stat_acm_mi_pscore, clear
qui{
mi estimate, hr: stcox i.indextype ib5.decile age_indexdate gender, cformat(%6.2f) pformat(%5.3f) sformat(%6.2f) 
matrix b=r(table)
matrix c=b'
matrix list c
local i=2
local x=`i'+5
putexcel A`x'=("Propensity Score") B1=("HR") C1=("SE") D1=("p-value") E1=("LL") F1=("UL") B`x'=(c[`i',1]) C`x'=(c[`i',2]) D`x'=(c[`i',4]) E`x'=(c[`i',5]) F`x'=(c[`i',6]) using FigureS3, modify
}
//generate dat file needed for figure
quietly{
clear
import excel using FigureS3, cellrange(A1:F7) firstrow
drop DPP4ivsSU
gen model=_n
gen Covariates=_n-1
capture lable drop models
capture label drop modelcats
label define modelcats 1 "Unadjusted" 2 "Adjusted for age" 3 "Adjusted for previous" 4 "Adjusted for previous + SBP," 5 "Adjusted for" 6 "Propensity score adjusted"
label values model modelcats
capture label drop covariates
label define covariates 0 "no Covariates" 1 "and gender" 2 "+ met mono, met overlap, A1c" 3 "CKD, unique Rx, CCI, visits" 4 "all covariates" 5 "for age, gender, decile"
label values Covariates covariates
capture rename Covariates Models
label var Models "{bf}Models"
metan HR LL UL, force by(model) nowt nobox nooverall null(1) xlabel(0.25, 0.5, .75, 1.25) astext(70) scheme(s1mono) lcols(Models) effect("Hazard Ratio") saving(MainModelComparison, asis replace)
}
//generate FigureS3
metan HR LL UL, force by(model) nowt nobox nooverall nosubgroup null(1) xlabel(0.25, 0.5, .75) astext(70) scheme(s1mono) lcols(Models) effect("{bf}Hazard {bf}Ratio") saving(FigureS3, asis replace)
graph export FigureS3.png, replace

//SUPPLEMENT TABLE S3: ACM FOR DPP and GLP VS SU ACROSS VARYING RANGES
//secondline OR use table2_acm.xlsx (Unadj MI and Adj MI Ref0 tabs)
use Stat_acm_mi, clear
//IR 
quietly {
putexcel A1= ("Indextype") B1=("Person-Time") C1=("Failures") D1=("Incidence Rate") E1=("Lower Bound") F1=("Upper Bound") using manuscript_tables, sheet("TableS3") modify
forval i=1/2{
local row=`i'+1
mi xeq 1: stptime if indextype==`i', per(1000)
putexcel A`row'= ("`i'") B`row'=(r(ptime)) C`row'=(r(failures)) D`row'=(r(rate)*1000) E`row'=(r(lb)*1000) F`row'=(r(ub)*1000) using manuscript_tables, sheet("TableS3") modify
}
}
//putexcel A2=("DPP-4i") A3= ("GLP-1RA") using manuscript_tables, sheet("TableS3") modify
//Unadj
mi estimate, hr: stcox i.indextype
qui{
matrix b=r(table)
matrix c=b'
matrix list c
forval i=2/3{
local x=`i'
local rowname:word `i' of `matrownames_mi'
putexcel G`i'=("Unadj secondline") G1=("Model") H1=("HR") I1=("SE") J1=("p-value") K1=("LL") L1=("UL") A`x'=("`rowname'") H`x'=(c[`i',1]) I`x'=(c[`i',2]) J`x'=(c[`i',4]) K`x'=(c[`i',5]) L`x'=(c[`i',6]) using manuscript_tables, sheet("TableS3") modify
}
}
//Adj
mi estimate, hr: stcox i.indextype `mvmodel_mi'
qui{
matrix b=r(table)
matrix c=b'
matrix list c
forval i=2/3{
local x=`i'+2
local rowname:word `i' of `matrownames_mi'
putexcel G`x'=("Adj secondline") H1=("HR") I1=("SE") J1=("p-value") K1=("LL") L1=("UL") F`x'=("`rowname'") H`x'=(c[`i',1]) I`x'=(c[`i',2]) J`x'=(c[`i',4]) K`x'=(c[`i',5]) L`x'=(c[`i',6]) using manuscript_tables, sheet("TableS3") modify
}
}
//second line, first gap
use Stat_acm_mi_index, clear
//IR 
mi xeq 1: stptime, by(indextype) per(1000)
quietly {
forval i=1/2{
local row=`i'+6
mi xeq 1: stptime if indextype==`i', per(1000)
putexcel A`row'= ("`i'") B`row'=(r(ptime)) C`row'=(r(failures)) D`row'=(r(rate)*1000) E`row'=(r(lb)*1000) F`row'=(r(ub)*1000) using manuscript_tables, sheet("TableS3") modify
}
}
//Unadj
mi estimate, hr: stcox i.indextype
qui{
matrix b=r(table)
matrix c=b'
matrix list c
forval i=2/3{
local x=`i'+5
local rowname:word `i' of `matrownames_mi'
putexcel G`x'=("Unadj secondline, first gap") G1=("Model") H1=("HR") I1=("SE") J1=("p-value") K1=("LL") L1=("UL") A`x'=("`rowname'") H`x'=(c[`i',1]) I`x'=(c[`i',2]) J`x'=(c[`i',4]) K`x'=(c[`i',5]) L`x'=(c[`i',6]) using manuscript_tables, sheet("TableS3") modify
}
}
//Adj
mi estimate, hr: stcox i.indextype `mvmodel_mi'
qui{
matrix b=r(table)
matrix c=b'
matrix list c
forval i=2/3{
local x=`i'+7
local rowname:word `i' of `matrownames_mi'
putexcel G`x'=("Adj secondline, first gap") H1=("HR") I1=("SE") J1=("p-value") K1=("LL") L1=("UL") F`x'=("`rowname'") H`x'=(c[`i',1]) I`x'=(c[`i',2]) J`x'=(c[`i',4]) K`x'=(c[`i',5]) L`x'=(c[`i',6]) using manuscript_tables, sheet("TableS3") modify
}
}
//thirdline
use Stat_acm_mi_index3, clear
//IR 
mi xeq 1: stptime, by(indextype) per(1000)
quietly {
forval i=1/2{
local row=`i'+11
mi xeq 1: stptime if indextype==`i', per(1000)
putexcel A`row'= ("`i'") B`row'=(r(ptime)) C`row'=(r(failures)) D`row'=(r(rate)*1000) E`row'=(r(lb)*1000) F`row'=(r(ub)*1000) using manuscript_tables, sheet("TableS3") modify
}
}
//Unadj
mi estimate, hr: stcox i.indextype
qui{
matrix b=r(table)
matrix c=b'
matrix list c
forval i=2/3{
local x=`i'+10
local rowname:word `i' of `matrownames_mi'
putexcel G`x'=("Unadj thirdline") G1=("Model") H1=("HR") I1=("SE") J1=("p-value") K1=("LL") L1=("UL") A`x'=("`rowname'") H`x'=(c[`i',1]) I`x'=(c[`i',2]) J`x'=(c[`i',4]) K`x'=(c[`i',5]) L`x'=(c[`i',6]) using manuscript_tables, sheet("TableS3") modify
}
}
//Adj
mi estimate, hr: stcox i.indextype `mvmodel_mi'
qui{
matrix b=r(table)
matrix c=b'
matrix list c
forval i=2/3{
local x=`i'+12
local rowname:word `i' of `matrownames_mi'
putexcel G`x'=("Adj thirdline") H1=("HR") I1=("SE") J1=("p-value") K1=("LL") L1=("UL") F`x'=("`rowname'") H`x'=(c[`i',1]) I`x'=(c[`i',2]) J`x'=(c[`i',4]) K`x'=(c[`i',5]) L`x'=(c[`i',6]) using manuscript_tables, sheet("TableS3") modify
}
}
//any after monotherapy 
use Stat_acm_mi_any, clear
//IR 
mi xeq 1: stptime, by(indextype) per(1000)
quietly {
forval i=1/2{
local row=`i'+16
mi xeq 1: stptime if indextype==`i', per(1000)
putexcel A`row'= ("`i'") B`row'=(r(ptime)) C`row'=(r(failures)) D`row'=(r(rate)*1000) E`row'=(r(lb)*1000) F`row'=(r(ub)*1000) using manuscript_tables, sheet("TableS3") modify
}
}
//Unadj
mi estimate, hr: stcox i.indextype
qui{
matrix b=r(table)
matrix c=b'
matrix list c
forval i=2/3{
local x=`i'+15
local rowname:word `i' of `matrownames_mi'
putexcel G`x'=("Unadj any after") G1=("Model") H1=("HR") I1=("SE") J1=("p-value") K1=("LL") L1=("UL") A`x'=("`rowname'") H`x'=(c[`i',1]) I`x'=(c[`i',2]) J`x'=(c[`i',4]) K`x'=(c[`i',5]) L`x'=(c[`i',6]) using manuscript_tables, sheet("TableS3") modify
}
}
//Adj
mi estimate, hr: stcox i.indextype `mvmodel_mi'
qui{
matrix b=r(table)
matrix c=b'
matrix list c
forval i=2/3{
local x=`i'+17
local rowname:word `i' of `matrownames_mi'
putexcel G`x'=("Adj any after") H1=("HR") I1=("SE") J1=("p-value") K1=("LL") L1=("UL") F`x'=("`rowname'") H`x'=(c[`i',1]) I`x'=(c[`i',2]) J`x'=(c[`i',4]) K`x'=(c[`i',5]) L`x'=(c[`i',6]) using manuscript_tables, sheet("TableS3") modify
}
}
//secondline last exposure CPRD ONLY
use Stat_acm_mi, clear
keep if linked_b!=1
//IR 
quietly {
putexcel A1= ("Indextype") B1=("Person-Time") C1=("Failures") D1=("Incidence Rate") E1=("Lower Bound") F1=("Upper Bound") using manuscript_tables, sheet("TableS3") modify
forval i=1/2{
local row=`i'+21
mi xeq 1: stptime if indextype==`i', per(1000)
putexcel A`row'= ("`i'") B`row'=(r(ptime)) C`row'=(r(failures)) D`row'=(r(rate)*1000) E`row'=(r(lb)*1000) F`row'=(r(ub)*1000) using manuscript_tables, sheet("TableS3") modify
}
}
//putexcel A2=("DPP-4i") A3= ("GLP-1RA") using manuscript_tables, sheet("TableS3") modify
//Unadj
mi estimate, hr: stcox i.indextype
qui{
matrix b=r(table)
matrix c=b'
matrix list c
forval i=2/3{
local x=`i'+20
local rowname:word `i' of `matrownames_mi'
putexcel G`x'=("Unadj secondline CPRD") G1=("Model") H1=("HR") I1=("SE") J1=("p-value") K1=("LL") L1=("UL") A`x'=("`rowname'") H`x'=(c[`i',1]) I`x'=(c[`i',2]) J`x'=(c[`i',4]) K`x'=(c[`i',5]) L`x'=(c[`i',6]) using manuscript_tables, sheet("TableS3") modify
}
}
//Adj
mi estimate, hr: stcox i.indextype `mvmodel_mi'
qui{
matrix b=r(table)
matrix c=b'
matrix list c
forval i=2/3{
local x=`i'+22
local rowname:word `i' of `matrownames_mi'
putexcel G`x'=("Adj secondline CPRD") H1=("HR") I1=("SE") J1=("p-value") K1=("LL") L1=("UL") F`x'=("`rowname'") H`x'=(c[`i',1]) I`x'=(c[`i',2]) J`x'=(c[`i',4]) K`x'=(c[`i',5]) L`x'=(c[`i',6]) using manuscript_tables, sheet("TableS3") modify
}
}
//secondline, last exposure HES ONLY
use Stat_acm_mi, clear
keep if linked_b==1
//IR 
quietly {
putexcel A1= ("Indextype") B1=("Person-Time") C1=("Failures") D1=("Incidence Rate") E1=("Lower Bound") F1=("Upper Bound") using manuscript_tables, sheet("TableS3") modify
forval i=1/2{
local row=`i'+26
mi xeq 1: stptime if indextype==`i', per(1000)
putexcel A`row'= ("`i'") B`row'=(r(ptime)) C`row'=(r(failures)) D`row'=(r(rate)*1000) E`row'=(r(lb)*1000) F`row'=(r(ub)*1000) using manuscript_tables, sheet("TableS3") modify
}
}
//putexcel A2=("DPP-4i") A3= ("GLP-1RA") using manuscript_tables, sheet("TableS3") modify
//Unadj
mi estimate, hr: stcox i.indextype
qui{
matrix b=r(table)
matrix c=b'
matrix list c
forval i=2/3{
local x=`i'+25
local rowname:word `i' of `matrownames_mi'
putexcel G`x'=("Unadj secondline HES") G1=("Model") H1=("HR") I1=("SE") J1=("p-value") K1=("LL") L1=("UL") A`x'=("`rowname'") H`x'=(c[`i',1]) I`x'=(c[`i',2]) J`x'=(c[`i',4]) K`x'=(c[`i',5]) L`x'=(c[`i',6]) using manuscript_tables, sheet("TableS3") modify
}
}
//Adj
mi estimate, hr: stcox i.indextype `mvmodel_mi'
qui{
matrix b=r(table)
matrix c=b'
matrix list c
forval i=2/3{
local x=`i'+27
local rowname:word `i' of `matrownames_mi'
putexcel G`x'=("Adj secondline HES") H1=("HR") I1=("SE") J1=("p-value") K1=("LL") L1=("UL") F`x'=("`rowname'") H`x'=(c[`i',1]) I`x'=(c[`i',2]) J`x'=(c[`i',4]) K`x'=(c[`i',5]) L`x'=(c[`i',6]) using manuscript_tables, sheet("TableS3") modify
}
}
//SUPPLEMENT FIGURE S4: ACM FINDINGS FOR DPP VS ALL REFERENTS
use Stat_acm_mi, clear
//REFERENT: SU
//Unadj
mi estimate, hr: stcox i.indextype
qui {
matrix b=r(table)
matrix c=b'
matrix list c
local i=2
local x=`i'
local rowname:word `i' of `matrownames_mi'
putexcel A`x'=("Unadj DPP vs SU") A1=("Model") B1=("HR") C1=("SE") D1=("p-value") E1=("LL") F1=("UL") B`x'=(c[`i',1]) C`x'=(c[`i',2]) D`x'=(c[`i',4]) E`x'=(c[`i',5]) F`x'=(c[`i',6]) using FigureS4, modify
}
//Adj
mi estimate, hr: stcox i.indextype `mvmodel_mi'
qui{
matrix b=r(table)
matrix c=b'
matrix list c
local i=2
local x=`i'+1
local rowname:word `i' of `matrownames_mi'
putexcel A`x'=("Adj DPP vs SU") B1=("HR") C1=("SE") D1=("p-value") E1=("LL") F1=("UL") B`x'=(c[`i',1]) C`x'=(c[`i',2]) D`x'=(c[`i',4]) E`x'=(c[`i',5]) F`x'=(c[`i',6]) using FigureS4, modify
}
//REFERENT: GLP
//Unadj
mi estimate, hr: stcox ib2.indextype
qui {
matrix b=r(table)
matrix c=b'
matrix list c
local i=2
local x=`i'+2
local rowname:word `i' of `matrownames_mi'
putexcel A`x'=("Unadj DPP vs GLP") A1=("Model") B1=("HR") C1=("SE") D1=("p-value") E1=("LL") F1=("UL") B`x'=(c[`i',1]) C`x'=(c[`i',2]) D`x'=(c[`i',4]) E`x'=(c[`i',5]) F`x'=(c[`i',6]) using FigureS4, modify
}
//Adj
mi estimate, hr: stcox ib2.indextype `mvmodel_mi'
qui{
matrix b=r(table)
matrix c=b'
matrix list c
local i=2
local x=`i'+3
local rowname:word `i' of `matrownames_mi'
putexcel A`x'=("Adj DPP vs GLP") B1=("HR") C1=("SE") D1=("p-value") E1=("LL") F1=("UL") B`x'=(c[`i',1]) C`x'=(c[`i',2]) D`x'=(c[`i',4]) E`x'=(c[`i',5]) F`x'=(c[`i',6]) using FigureS4, modify
}
//REFERENT: INSULIN
//Unadj
mi estimate, hr: stcox ib3.indextype
qui{
matrix b=r(table)
matrix c=b'
matrix list c
local i=2
local x=`i'+4
local rowname:word `i' of `matrownames_mi'
putexcel A`x'=("Unadj DPP vs INS") A1=("Model") B1=("HR") C1=("SE") D1=("p-value") E1=("LL") F1=("UL") B`x'=(c[`i',1]) C`x'=(c[`i',2]) D`x'=(c[`i',4]) E`x'=(c[`i',5]) F`x'=(c[`i',6]) using FigureS4, modify
}
//Adj
mi estimate, hr: stcox ib3.indextype `mvmodel_mi'
qui{
matrix b=r(table)
matrix c=b'
matrix list c
local i=2
local x=`i'+5
local rowname:word `i' of `matrownames_mi'
putexcel A`x'=("Adj DPP vs INS") B1=("HR") C1=("SE") D1=("p-value") E1=("LL") F1=("UL") B`x'=(c[`i',1]) C`x'=(c[`i',2]) D`x'=(c[`i',4]) E`x'=(c[`i',5]) F`x'=(c[`i',6]) using FigureS4, modify
}
//REFERENT: TZD
//Unadj
mi estimate, hr: stcox ib4.indextype
qui{
matrix b=r(table)
matrix c=b'
matrix list c
local i=2
local x=`i'+6
local rowname:word `i' of `matrownames_mi'
putexcel A`x'=("Unadj DPP vs TZD") A1=("Model") B1=("HR") C1=("SE") D1=("p-value") E1=("LL") F1=("UL") B`x'=(c[`i',1]) C`x'=(c[`i',2]) D`x'=(c[`i',4]) E`x'=(c[`i',5]) F`x'=(c[`i',6]) using FigureS4, modify
}
//Adj
mi estimate, hr: stcox ib4.indextype `mvmodel_mi'
qui{
matrix b=r(table)
matrix c=b'
matrix list c
local i=2
local x=`i'+7
local rowname:word `i' of `matrownames_mi'
putexcel A`x'=("Adj DPP vs TZD") B1=("HR") C1=("SE") D1=("p-value") E1=("LL") F1=("UL") B`x'=(c[`i',1]) C`x'=(c[`i',2]) D`x'=(c[`i',4]) E`x'=(c[`i',5]) F`x'=(c[`i',6]) using FigureS4, modify
}
//REFERENT: OTH
//Unadj
mi estimate, hr: stcox ib5.indextype
qui{
matrix b=r(table)
matrix c=b'
matrix list c
local i=2
local x=`i'+8
local rowname:word `i' of `matrownames_mi'
putexcel A`x'=("Unadj DPP vs OTH") A1=("Model") B1=("HR") C1=("SE") D1=("p-value") E1=("LL") F1=("UL") B`x'=(c[`i',1]) C`x'=(c[`i',2]) D`x'=(c[`i',4]) E`x'=(c[`i',5]) F`x'=(c[`i',6]) using FigureS4, modify
}
//Adj
mi estimate, hr: stcox ib5.indextype `mvmodel_mi'
qui{
matrix b=r(table)
matrix c=b'
matrix list c
local i=2
local x=`i'+9
local rowname:word `i' of `matrownames_mi'
putexcel A`x'=("Adj DPP vs OTH") B1=("HR") C1=("SE") D1=("p-value") E1=("LL") F1=("UL") B`x'=(c[`i',1]) C`x'=(c[`i',2]) D`x'=(c[`i',4]) E`x'=(c[`i',5]) F`x'=(c[`i',6]) using FigureS4, modify
}
//generate dat file needed for FigureS4
quietly{
clear
import excel using FigureS4, cellrange(A1:F11) firstrow
gen adj=0
gen counts=_n
gen referents=0 if counts<3&counts>0
replace referents=2 if counts<5&counts>2
replace referents=3 if counts<7&counts>4
replace referents=4 if counts<9&counts>6
replace referents=5 if counts<11&counts>8
replace adj=1 if counts==2|counts==4|counts==6|counts==8|counts==10
drop counts
save FigureS4, replace
capture label drop referents
capture label drop adjusted
label define referents 0 "{bf}SU" 1 "{bf}DPP4i" 2 "{bf}GLP-1RA" 3 "{bf}Insulin" 4 "{bf}Thiazolidinedione" 5 "{bf}Other {bf}antidiabetic"
label values referents referents
label define adjusted 0 "Unadjusted" 1 "Adjusted"
label values adj adjusted
label var referents "{bf}Referent"
label var adj "{bf}Antidiabetic {bf}Class"
metan HR LL UL, force by(referents) nowt nobox nooverall null(1) xlabel(0, 0.25, 0.5, 0.75) astext(70) scheme(s1mono) effect("Hazard Ratio")
}
//generate FigureS4
metan HR LL UL, force by(referents) nowt nobox nooverall nosubgroup null(1) xlabel(0, 2, 3, 4, 5, 6, 7, 8) astext(45) scheme(s1mono) lcols(adj) effect("{bf}Hazard {bf}Ratio") saving(FigureS4, asis replace)
graph export FigureS4.png, replace

//TABLE 2: ACM FINDINGS FOR EACH CLASS OF ANTIDIABETIC AGENT
use Stat_acm_mi, clear
//IR 
mi xeq 1: stptime, by(indextype) per(1000)
quietly {
forval i=0/5{
local row=`i'+2
mi xeq 1: stptime if indextype==`i', per(1000)
putexcel A`row'= ("`i'") B`row'=(r(ptime)) C`row'=(r(failures)) D`row'=(r(rate)*1000) E`row'=(r(lb)*1000) F`row'=(r(ub)*1000) using manuscript_tables, sheet("Table2") modify
}
putexcel A1= ("Indextype") B1=("Person-Time") C1=("Failures") D1=("Incidence Rate") E1=("Lower Bound") F1=("Upper Bound") using manuscript_tables, sheet("Table2") modify
mi xeq 1: stptime, per(1000)
putexcel A8= ("total") B8=(r(ptime)) C8=(r(failures)) D8=(r(rate)*1000) E8=(r(lb)*1000) F8=(r(ub)*1000) using manuscript_tables, sheet("Table2") modify
putexcel A2= ("SU") A3= ("DPP4I") A4= ("GLP1RA") A5= ("INS") A6= ("TZD") A7= ("OTH") using manuscript_tables, sheet("Table2") modify
}
//Unadjusted
mi estimate, hr: stcox i.indextype
qui{
matrix b=r(table)
matrix c=b'
matrix list c
forval i=2/6{
local x=`i'+9
local rowname:word `i' of `matrownames_mi'
putexcel A10=("Indextype") B10=("uHR") C10=("SE") D10=("p-value") E10=("LL") F10=("UL") A`x'=("`rowname'") B`x'=(c[`i',1]) C`x'=(c[`i',2]) D`x'=(c[`i',4]) E`x'=(c[`i',5]) F`x'=(c[`i',6]) using manuscript_tables, sheet("Table2") modify
}
}
//Adjusted
mi estimate, hr: stcox i.indextype `mvmodel_mi'
quietly{
matrix b=r(table)
matrix c=b'
matrix list c
forval i=2/6{
local x=`i'+16
local rowname:word `i' of `matrownames_mi'
putexcel A17=("Indextype") B17=("aHR") C17=("SE") D17=("p-value") E17=("LL") F17=("UL") A`x'=("`rowname'") B`x'=(c[`i',1]) C`x'=(c[`i',2]) D`x'=(c[`i',4]) E`x'=(c[`i',5]) F`x'=(c[`i',6]) using manuscript_tables, sheet("Table2") modify
}
}

//SUPPLEMENT FIGURE S5: ACM FOR DPP and GLP VS SU ACROSS VARYING RANGES
//secondline OR use table2_acm.xlsx (Unadj MI and Adj MI Ref0 tabs)
use Stat_acm_mi, clear
//IR
mi xeq 1: stptime, by(indextype) per(1000)
quietly {
putexcel A1= ("Indextype") B1=("Person-Time") C1=("Failures") D1=("Incidence Rate") E1=("Lower Bound") F1=("Upper Bound") using FigureS5, modify
forval i=1/2{
local row=`i'+1
mi xeq 1: stptime if indextype==`i', per(1000)
putexcel A`row'= ("`i'") B`row'=(r(ptime)) C`row'=(r(failures)) D`row'=(r(rate)*1000) E`row'=(r(lb)*1000) F`row'=(r(ub)*1000) using FigureS5, modify
}
}
//Unadj
mi estimate, hr: stcox i.indextype
quietly {
matrix b=r(table)
matrix c=b'
matrix list c
forval i=2/3{
local x=`i'
local rowname:word `i' of `matrownames_mi'
putexcel G`i'=("Unadj secondline") G1=("Model") H1=("HR") I1=("SE") J1=("p-value") K1=("LL") L1=("UL") A`x'=("`rowname'") H`x'=(c[`i',1]) I`x'=(c[`i',2]) J`x'=(c[`i',4]) K`x'=(c[`i',5]) L`x'=(c[`i',6]) using FigureS5, modify
}
}
//Adj
mi estimate, hr: stcox i.indextype `mvmodel_mi'
quietly {
matrix b=r(table)
matrix c=b'
matrix list c
forval i=2/3{
local x=`i'+2
local rowname:word `i' of `matrownames_mi'
putexcel G`x'=("Adj secondline") H1=("HR") I1=("SE") J1=("p-value") K1=("LL") L1=("UL") F`x'=("`rowname'") H`x'=(c[`i',1]) I`x'=(c[`i',2]) J`x'=(c[`i',4]) K`x'=(c[`i',5]) L`x'=(c[`i',6]) using FigureS5, modify
}
}
//second line, first gap
use Stat_acm_mi_index, clear
//IR 
mi xeq 1: stptime, by(indextype) per(1000)
quietly {
forval i=1/2{
local row=`i'+6
mi xeq 1: stptime if indextype==`i', per(1000)
putexcel A`row'= ("`i'") B`row'=(r(ptime)) C`row'=(r(failures)) D`row'=(r(rate)*1000) E`row'=(r(lb)*1000) F`row'=(r(ub)*1000) using FigureS5, modify
}
}
//Unadj
mi estimate, hr: stcox i.indextype
quietly {
matrix b=r(table)
matrix c=b'
matrix list c
forval i=2/3{
local x=`i'+5
local rowname:word `i' of `matrownames_mi'
putexcel G`x'=("Unadj secondline, first gap") G1=("Model") H1=("HR") I1=("SE") J1=("p-value") K1=("LL") L1=("UL") A`x'=("`rowname'") H`x'=(c[`i',1]) I`x'=(c[`i',2]) J`x'=(c[`i',4]) K`x'=(c[`i',5]) L`x'=(c[`i',6]) using FigureS5, modify
}
}
//Adj
mi estimate, hr: stcox i.indextype `mvmodel_mi'
quietly {
matrix b=r(table)
matrix c=b'
matrix list c
forval i=2/3{
local x=`i'+7
local rowname:word `i' of `matrownames_mi'
putexcel G`x'=("Adj secondline, first gap") H1=("HR") I1=("SE") J1=("p-value") K1=("LL") L1=("UL") F`x'=("`rowname'") H`x'=(c[`i',1]) I`x'=(c[`i',2]) J`x'=(c[`i',4]) K`x'=(c[`i',5]) L`x'=(c[`i',6]) using FigureS5, modify
}
}
//thirdline
use Stat_acm_mi_index3, clear
//IR 
mi xeq 1: stptime, by(indextype) per(1000)
quietly {
forval i=1/2{
local row=`i'+11
mi xeq 1: stptime if indextype==`i', per(1000)
putexcel A`row'= ("`i'") B`row'=(r(ptime)) C`row'=(r(failures)) D`row'=(r(rate)*1000) E`row'=(r(lb)*1000) F`row'=(r(ub)*1000) using FigureS5, modify
}
}
//Unadj
mi estimate, hr: stcox i.indextype
quietly {
matrix b=r(table)
matrix c=b'
matrix list c
forval i=2/3{
local x=`i'+10
local rowname:word `i' of `matrownames_mi'
putexcel G`x'=("Unadj thirdline") G1=("Model") H1=("HR") I1=("SE") J1=("p-value") K1=("LL") L1=("UL") A`x'=("`rowname'") H`x'=(c[`i',1]) I`x'=(c[`i',2]) J`x'=(c[`i',4]) K`x'=(c[`i',5]) L`x'=(c[`i',6]) using FigureS5, modify
}
}
//Adj
mi estimate, hr: stcox i.indextype `mvmodel_mi'
quietly {
matrix b=r(table)
matrix c=b'
matrix list c
forval i=2/3{
local x=`i'+12
local rowname:word `i' of `matrownames_mi'
putexcel G`x'=("Adj thirdline") H1=("HR") I1=("SE") J1=("p-value") K1=("LL") L1=("UL") F`x'=("`rowname'") H`x'=(c[`i',1]) I`x'=(c[`i',2]) J`x'=(c[`i',4]) K`x'=(c[`i',5]) L`x'=(c[`i',6]) using FigureS5, modify
}
}
//any after monotherapy 
use Stat_acm_mi_any, clear
//IR 
mi xeq 1: stptime, by(indextype) per(1000)
quietly {
forval i=1/2{
local row=`i'+16
mi xeq 1: stptime if indextype==`i', per(1000)
putexcel A`row'= ("`i'") B`row'=(r(ptime)) C`row'=(r(failures)) D`row'=(r(rate)*1000) E`row'=(r(lb)*1000) F`row'=(r(ub)*1000) using FigureS5, modify
}
}
//Unadj
mi estimate, hr: stcox i.indextype
quietly {
matrix b=r(table)
matrix c=b'
matrix list c
forval i=2/3{
local x=`i'+15
local rowname:word `i' of `matrownames_mi'
putexcel G`x'=("Unadj any after") G1=("Model") H1=("HR") I1=("SE") J1=("p-value") K1=("LL") L1=("UL") A`x'=("`rowname'") H`x'=(c[`i',1]) I`x'=(c[`i',2]) J`x'=(c[`i',4]) K`x'=(c[`i',5]) L`x'=(c[`i',6]) using FigureS5, modify
}
}
//Adj
mi estimate, hr: stcox i.indextype `mvmodel_mi'
quietly {
matrix b=r(table)
matrix c=b'
matrix list c
forval i=2/3{
local x=`i'+17
local rowname:word `i' of `matrownames_mi'
putexcel G`x'=("Adj any after") H1=("HR") I1=("SE") J1=("p-value") K1=("LL") L1=("UL") F`x'=("`rowname'") H`x'=(c[`i',1]) I`x'=(c[`i',2]) J`x'=(c[`i',4]) K`x'=(c[`i',5]) L`x'=(c[`i',6]) using FigureS5, modify
}
}
//Secondline CPRD ONLY
use Stat_acm_mi, clear
keep if linked_b!=1
//IR
mi xeq 1: stptime, by(indextype) per(1000)
quietly {
putexcel A1= ("Indextype") B1=("Person-Time") C1=("Failures") D1=("Incidence Rate") E1=("Lower Bound") F1=("Upper Bound") using FigureS5, modify
forval i=1/2{
local row=`i'+21
mi xeq 1: stptime if indextype==`i', per(1000)
putexcel A`row'= ("`i'") B`row'=(r(ptime)) C`row'=(r(failures)) D`row'=(r(rate)*1000) E`row'=(r(lb)*1000) F`row'=(r(ub)*1000) using FigureS5, modify
}
}
//Unadj
mi estimate, hr: stcox i.indextype
quietly {
matrix b=r(table)
matrix c=b'
matrix list c
forval i=2/3{
local x=`i'+20
local rowname:word `i' of `matrownames_mi'
putexcel G`i'=("Unadj secondline CPRD") G1=("Model") H1=("HR") I1=("SE") J1=("p-value") K1=("LL") L1=("UL") A`x'=("`rowname'") H`x'=(c[`i',1]) I`x'=(c[`i',2]) J`x'=(c[`i',4]) K`x'=(c[`i',5]) L`x'=(c[`i',6]) using FigureS5, modify
}
}
//Adj
mi estimate, hr: stcox i.indextype `mvmodel_mi'
quietly {
matrix b=r(table)
matrix c=b'
matrix list c
forval i=2/3{
local x=`i'+22
local rowname:word `i' of `matrownames_mi'
putexcel G`x'=("Adj secondline CPRD") H1=("HR") I1=("SE") J1=("p-value") K1=("LL") L1=("UL") F`x'=("`rowname'") H`x'=(c[`i',1]) I`x'=(c[`i',2]) J`x'=(c[`i',4]) K`x'=(c[`i',5]) L`x'=(c[`i',6]) using FigureS5, modify
}
}
//Secondline HES only
use Stat_acm_mi, clear
keep if linked_b==1
//IR
mi xeq 1: stptime, by(indextype) per(1000)
quietly {
putexcel A1= ("Indextype") B1=("Person-Time") C1=("Failures") D1=("Incidence Rate") E1=("Lower Bound") F1=("Upper Bound") using FigureS5, modify
forval i=1/2{
local row=`i'+26
mi xeq 1: stptime if indextype==`i', per(1000)
putexcel A`row'= ("`i'") B`row'=(r(ptime)) C`row'=(r(failures)) D`row'=(r(rate)*1000) E`row'=(r(lb)*1000) F`row'=(r(ub)*1000) using FigureS5, modify
}
}
//Unadj
mi estimate, hr: stcox i.indextype
quietly {
matrix b=r(table)
matrix c=b'
matrix list c
forval i=2/3{
local x=`i'+25
local rowname:word `i' of `matrownames_mi'
putexcel G`i'=("Unadj secondline HES") G1=("Model") H1=("HR") I1=("SE") J1=("p-value") K1=("LL") L1=("UL") A`x'=("`rowname'") H`x'=(c[`i',1]) I`x'=(c[`i',2]) J`x'=(c[`i',4]) K`x'=(c[`i',5]) L`x'=(c[`i',6]) using FigureS5, modify
}
}
//Adj
mi estimate, hr: stcox i.indextype `mvmodel_mi'
quietly {
matrix b=r(table)
matrix c=b'
matrix list c
forval i=2/3{
local x=`i'+27
local rowname:word `i' of `matrownames_mi'
putexcel G`x'=("Adj secondline HES") H1=("HR") I1=("SE") J1=("p-value") K1=("LL") L1=("UL") F`x'=("`rowname'") H`x'=(c[`i',1]) I`x'=(c[`i',2]) J`x'=(c[`i',4]) K`x'=(c[`i',5]) L`x'=(c[`i',6]) using FigureS5, modify
}
}

//generate dat file needed for FigureS5
quietly{
clear
import excel using FigureS5, cellrange(G1:L30) firstrow
drop if HR==.
gen counts=_n
gen trt=.
gen adj=.
forval i=1(2)23{
replace trt=1 if counts==`i'
}
forval i=2(2)24{
replace trt=2 if counts==`i'
}
forval i=1(4)24{
replace adj=0 if counts==`i'
}
forval i=2(4)24{
replace adj=0 if counts==`i'
}
forval i=3(4)24{
replace adj=1 if counts==`i'
}
forval i=4(4)24{
replace adj=1 if counts==`i'
}
drop Model
gen Model=.
forval i=1/4{
replace Model=1 if counts==`i'
}
forval i=5/8{
replace Model=2 if counts==`i'
}
forval i=9/12{
replace Model=3 if counts==`i'
}
forval i=13/16{
replace Model=4 if counts==`i'
}
forval i=17/20{
replace Model=5 if counts==`i'
}
forval i=21/24{
replace Model=6 if counts==`i'
}
save FigureS5, replace
capture label drop treatments
capture label drop adjusted
capture label drop models
label define treatments 1 "{bf}DPP4i" 2 "{bf}GLP-1RA"
label define adjusted 0 "Unadjusted" 1 "Adjusted"
label define models 1 "Second line, last exposure" 2 "Second line, first gap" 3 "Second line, third agent" 4 "Any line, after metformin" 5 "Second line, last exposure CPRD" 6 "Second line, last exposure HES"
label values adj adjusted
label values trt treatments
label values Model models
label var Model "{bf}Range"
label var adj "{bf}Antidiabetic {bf}Class"
drop if SE==.
metan HR LL UL, force by(Model) nowt nobox nooverall null(1) xlabel(0, 0.25, 0.5, 0.75) astext(70) scheme(s1mono) effect("Hazard Ratio")
}
//generate FigureS5
metan HR LL UL if adj==1, force by(trt) nowt nobox nooverall nosubgroup null(1) xlabel(0, 2, 3, 4, 5, 6, 7) astext(65) scheme(s1mono) lcols(Model) effect("{bf}Hazard {bf}Ratio") saving(FigureS5, asis replace)
graph export FigureS5.png, replace

****************************************************************************************************************************************
//MACE WRITTEN SECTION NUMBERS: 
// 2x2 tables with exposure and outcome (MACE)
use mace, clear
keep if linked_b==1
label var indextype "2nd-line Agent"
tab indextype mace, row
label var indextype3 "3rd-line Agent"
tab indextype3 mace, row
label var indextype4 "4th-line Agent"
tab indextype4 mace, row
tab indextype5 mace, row
tab indextype6 mace, row
tab indextype7 mace, row

//2x2 tables for each covariate to determine if events are too low to include any of them
foreach var of varlist age_65 gender dmdur_cat ckd_amdrd unique_cov_drugs prx_ccivalue_g_i2 mi_i stroke_i hf_i arr_i ang_i revasc_i htn_i afib_i pvd_i statin_i calchan_i betablock_i anticoag_oral_i antiplat_i ace_arb_renin_i diuretics_all_i bmi_i_cats sbp_i_cats2 hba1c_cats_i2 prx_covvalue_g_i4 {
tab indextype `var', row
}

// 2x2 tables with exposure and death, by baseline covariates
foreach var of varlist gender dmdur_cat prx_covvalue_g_i4 prx_covvalue_g_i5 bmi_i_cats hba1c_cats_i2 sbp_i_cats2 ///
	ckd_amdrd physician_vis2 unique_cov_drugs prx_ccivalue_g_i2 mi_i stroke_i hf_i arr_i ang_i revasc_i ///
	htn_i afib_i pvd_i statin_i calchan_i betablock_i anticoag_oral_i antiplat_i ace_arb_renin_i ///
	diuretics_all_i {
table indextype `var', contents(n mace mean mace) format(%6.2f) center col
	}

//get duration of metformin monotherapy prior to index switch/add
//to get the linked numbers
use mace, clear
keep if linked_b==1
tab indextype
tab mace
//For SMRs, IRs, person-time, HRs and CIs either use table2_mace.xlsx (Unadj MI Ref0 tab)
//OR:
//to get the incidence rates
use Stat_mace_mi, clear
keep if linked_b==1
by indextype, sort : stir mace
//mortality rates
mi xeq 1: stptime, by(indextype) per(1000)

//Use table2_mace.xlsx (Adj MI Ref0 tab)get the adjusted hr OR:
use Stat_mace_mi, clear
keep if linked_b==1
mi estimate, hr: stcox i.indextype `mvmodel_mi'
//Either use table2_mace.xlsx (Adj MI Ref2, Adj MI Ref3, and Adj MI Ref4 tabs)
//OR to manually change the reference groups:
mi estimate, hr: stcox ib1.indextype `mvmodel_mi' //DPP
mi estimate, hr: stcox ib2.indextype `mvmodel_mi' //GLP
mi estimate, hr: stcox ib3.indextype `mvmodel_mi' //INS
mi estimate, hr: stcox ib4.indextype `mvmodel_mi' //TZD

//TABLE 3: MACE FINDINGS FOR EACH CLASS OF ANTIDIABETIC AGENT
use Stat_mace_mi, clear
//IR
mi xeq 1: stptime, by(indextype) per(1000)
quietly {
putexcel A1= ("Indextype") B1=("Person-Time") C1=("Failures") D1=("Incidence Rate") E1=("Lower Bound") F1=("Upper Bound") using manuscript_tables, sheet("Table3") modify
forval i=0/5{
local row=`i'+2
mi xeq 1: stptime if indextype==`i', per(1000)
putexcel A`row'= ("`i'") B`row'=(r(ptime)) C`row'=(r(failures)) D`row'=(r(rate)*1000) E`row'=(r(lb)*1000) F`row'=(r(ub)*1000) using manuscript_tables, sheet("Table3") modify
}
mi xeq 1: stptime, per(1000)
putexcel A8= ("total") B8=(r(ptime)) C8=(r(failures)) D8=(r(rate)*1000) E8=(r(lb)*1000) F8=(r(ub)*1000) using manuscript_tables, sheet("Table3") modify
putexcel A2= ("SU") A3= ("DPP4I") A4= ("GLP1RA") A5= ("INS") A6= ("TZD") A7= ("OTH") using manuscript_tables, sheet("Table3") modify
}
//Unadjusted
mi estimate, hr: stcox i.indextype
qui{
matrix b=r(table)
matrix c=b'
matrix list c
forval i=2/6{
local x=`i'+9
local rowname:word `i' of `matrownames_mi'
putexcel A10=("Indextype") B10=("uHR") C10=("SE") D10=("p-value") E10=("LL") F10=("UL") A`x'=("`rowname'") B`x'=(c[`i',1]) C`x'=(c[`i',2]) D`x'=(c[`i',4]) E`x'=(c[`i',5]) F`x'=(c[`i',6]) using manuscript_tables, sheet("Table3") modify
}
}
//Adjusted
mi estimate, hr: stcox i.indextype `mvmodel_mi'
qui{
matrix b=r(table)
matrix c=b'
matrix list c
forval i=2/6{
local x=`i'+16
local rowname:word `i' of `matrownames_mi'
putexcel A17=("Indextype") B17=("aHR") C17=("SE") D17=("p-value") E17=("LL") F17=("UL") A`x'=("`rowname'") B`x'=(c[`i',1]) C`x'=(c[`i',2]) D`x'=(c[`i',4]) E`x'=(c[`i',5]) F`x'=(c[`i',6]) using manuscript_tables, sheet("Table3") modify
}
}

//SUPPLEMENT FIGURE S6: MACE MODEL ROBUSTNESS: UNADJUSTED AND ADJUSTED COX PROPORTIONAL HAZARDS REGRESSION ANALYSIS
use Stat_mace_mi, clear
keep if linked_b==1
// 1. Unadjusted model
mi estimate, hr: stcox i.indextype, cformat(%6.2f) pformat(%5.3f) sformat(%6.2f)
quietly{
matrix b=r(table)
matrix c=b'
matrix list c
local i=2
local x=`i'
putexcel A1 = ("DPP-4i vs SU") A`x'=("Unadjusted") B1=("HR") C1=("SE") D1=("p-value") E1=("LL") F1=("UL") B`x'=(c[`i',1]) C`x'=(c[`i',2]) D`x'=(c[`i',4]) E`x'=(c[`i',5]) F`x'=(c[`i',6]) using FigureS6, modify
}
// 2. + age, gender
mi estimate, hr: stcox i.indextype age_index gender, cformat(%6.2f) pformat(%5.3f) sformat(%6.2f)  
quietly{
matrix b=r(table)
matrix c=b'
matrix list c
local i=2
local x=`i'+1
putexcel A`x'=("Adjusted for age and gender") B1=("HR") C1=("SE") D1=("p-value") E1=("LL") F1=("UL") B`x'=(c[`i',1]) C`x'=(c[`i',2]) D`x'=(c[`i',4]) E`x'=(c[`i',5]) F`x'=(c[`i',6]) using FigureS6, modify
}
// 3. + dmdur, metoverlap, hba1c
mi estimate, hr: stcox i.indextype age_indexdate gender dmdur metoverlap ib1.hba1c_cats_i2, cformat(%6.2f) pformat(%5.3f) sformat(%6.2f) 
quietly{
matrix b=r(table)
matrix c=b'
matrix list c
local i=2
local x=`i'+2
putexcel A`x'=("Plus dmdur, metoverlap, and A1C") B1=("HR") C1=("SE") D1=("p-value") E1=("LL") F1=("UL") B`x'=(c[`i',1]) C`x'=(c[`i',2]) D`x'=(c[`i',4]) E`x'=(c[`i',5]) F`x'=(c[`i',6]) using FigureS6, modify
}
// 4. + bmi, ckd, unique drugs, physician visits, cci
mi estimate, hr: stcox i.indextype age_indexdate gender dmdur metoverlap ib1.hba1c_cats_i2 ib1.sbp_i_cats2 i.ckd_amdrd i.unique_cov_drugs i.physician_vis2 i.prx_ccivalue_g_i2, cformat(%6.2f) pformat(%5.3f) sformat(%6.2f)  
quietly{
matrix b=r(table)
matrix c=b'
matrix list c
local i=2
local x=`i'+3
putexcel A`x'=("Plus BMI, CKD, unqrx, visits, CCI") B1=("HR") C1=("SE") D1=("p-value") E1=("LL") F1=("UL") B`x'=(c[`i',1]) C`x'=(c[`i',2]) D`x'=(c[`i',4]) E`x'=(c[`i',5]) F`x'=(c[`i',6]) using FigureS6, modify
}
// 5. Test out full multivariate model (mvmodel) all covariates included
mi estimate, hr: stcox i.indextype `mvmodel_mi', cformat(%6.2f) pformat(%5.3f) sformat(%6.2f) 
quietly{
matrix b=r(table)
matrix c=b'
matrix list c
local i=2
local x=`i'+4
putexcel A`x'=("Fully Adjusted") B1=("HR") C1=("SE") D1=("p-value") E1=("LL") F1=("UL") B`x'=(c[`i',1]) C`x'=(c[`i',2]) D`x'=(c[`i',4]) E`x'=(c[`i',5]) F`x'=(c[`i',6]) using FigureS6, modify
}
// 6. Propensity score model plus age and gender
use Stat_mace_mi_pscore, clear
mi estimate, hr: stcox i.indextype ib5.decile age_indexdate gender, cformat(%6.2f) pformat(%5.3f) sformat(%6.2f) 
quietly{
matrix b=r(table)
matrix c=b'
matrix list c
local i=2
local x=`i'+5
putexcel A`x'=("Propensity Score") B1=("HR") C1=("SE") D1=("p-value") E1=("LL") F1=("UL") B`x'=(c[`i',1]) C`x'=(c[`i',2]) D`x'=(c[`i',4]) E`x'=(c[`i',5]) F`x'=(c[`i',6]) using FigureS6, modify
}
//generate dat file needed for figure
quietly{
clear
import excel using FigureS6, cellrange(A1:F7) firstrow
drop DPP4ivsSU
gen model=_n
gen Covariates=_n-1
capture lable drop models
capture label drop modelcats
label define modelcats 1 "Unadjusted" 2 "Adjusted for age" 3 "Adjusted for previous" 4 "Adjusted for previous + SBP," 5 "Adjusted for" 6 "Propensity score adjusted"
label values model modelcats
capture label drop covariates
label define covariates 0 "no Covariates" 1 "and gender" 2 "+ met mono, met overlap, A1c" 3 "CKD, unique Rx, CCI, visits" 4 "all covariates" 5 "for age, gender, decile"
label values Covariates covariates
capture rename Covariates Models
label var Models "{bf}Models"
metan HR LL UL, force by(model) nowt nobox nooverall null(1) xlabel(0.25, 0.5, .75, 1.25) astext(70) scheme(s1mono) lcols(Models) effect("Hazard Ratio")
}
//generate FigureS6
metan HR LL UL, force by(model) nowt nobox nooverall nosubgroup null(1) xlabel(0.25, 0.5, .75) astext(70) scheme(s1mono) lcols(Models) effect("{bf}Hazard {bf}Ratio") saving(FigureS6, asis replace)
graph export FigureS6.png, replace

//SUPPLEMENT FIGURE S7: MACE FINDINGS FOR DPP VS ALL REFERENTS
use Stat_mace_mi, clear
//REFERENT: SU
//Unadj
mi estimate, hr: stcox i.indextype
qui{
matrix b=r(table)
matrix c=b'
matrix list c
local i=2
local x=`i'
local rowname:word `i' of `matrownames_mi'
putexcel A`x'=("Unadj DPP vs SU") A1=("Model") B1=("HR") C1=("SE") D1=("p-value") E1=("LL") F1=("UL") B`x'=(c[`i',1]) C`x'=(c[`i',2]) D`x'=(c[`i',4]) E`x'=(c[`i',5]) F`x'=(c[`i',6]) using FigureS7, modify
}
//Adj
mi estimate, hr: stcox i.indextype `mvmodel_mi'
qui {
matrix b=r(table)
matrix c=b'
matrix list c
local i=2
local x=`i'+1
local rowname:word `i' of `matrownames_mi'
putexcel A`x'=("Adj DPP vs SU") B1=("HR") C1=("SE") D1=("p-value") E1=("LL") F1=("UL") B`x'=(c[`i',1]) C`x'=(c[`i',2]) D`x'=(c[`i',4]) E`x'=(c[`i',5]) F`x'=(c[`i',6]) using FigureS7, modify
}
//REFERENT: GLP
//Unadj
mi estimate, hr: stcox ib2.indextype
qui {
matrix b=r(table)
matrix c=b'
matrix list c
local i=2
local x=`i'+2
local rowname:word `i' of `matrownames_mi'
putexcel A`x'=("Unadj DPP vs GLP") A1=("Model") B1=("HR") C1=("SE") D1=("p-value") E1=("LL") F1=("UL") B`x'=(c[`i',1]) C`x'=(c[`i',2]) D`x'=(c[`i',4]) E`x'=(c[`i',5]) F`x'=(c[`i',6]) using FigureS7, modify
}
//Adj
mi estimate, hr: stcox ib2.indextype `mvmodel_mi'
qui {
matrix b=r(table)
matrix c=b'
matrix list c
local i=2
local x=`i'+3
local rowname:word `i' of `matrownames_mi'
putexcel A`x'=("Adj DPP vs GLP") B1=("HR") C1=("SE") D1=("p-value") E1=("LL") F1=("UL") B`x'=(c[`i',1]) C`x'=(c[`i',2]) D`x'=(c[`i',4]) E`x'=(c[`i',5]) F`x'=(c[`i',6]) using FigureS7, modify
}
//REFERENT: INSULIN
//Unadj
mi estimate, hr: stcox ib3.indextype
qui {
matrix b=r(table)
matrix c=b'
matrix list c
local i=2
local x=`i'+4
local rowname:word `i' of `matrownames_mi'
putexcel A`x'=("Unadj DPP vs INS") A1=("Model") B1=("HR") C1=("SE") D1=("p-value") E1=("LL") F1=("UL") B`x'=(c[`i',1]) C`x'=(c[`i',2]) D`x'=(c[`i',4]) E`x'=(c[`i',5]) F`x'=(c[`i',6]) using FigureS7, modify
}
//Adj
mi estimate, hr: stcox ib3.indextype `mvmodel_mi'
qui {
matrix b=r(table)
matrix c=b'
matrix list c
local i=2
local x=`i'+5
local rowname:word `i' of `matrownames_mi'
putexcel A`x'=("Adj DPP vs INS") B1=("HR") C1=("SE") D1=("p-value") E1=("LL") F1=("UL") B`x'=(c[`i',1]) C`x'=(c[`i',2]) D`x'=(c[`i',4]) E`x'=(c[`i',5]) F`x'=(c[`i',6]) using FigureS7, modify
}
//REFERENT: TZD
//Unadj
mi estimate, hr: stcox ib4.indextype
qui {
matrix b=r(table)
matrix c=b'
matrix list c
local i=2
local x=`i'+6
local rowname:word `i' of `matrownames_mi'
putexcel A`x'=("Unadj DPP vs TZD") A1=("Model") B1=("HR") C1=("SE") D1=("p-value") E1=("LL") F1=("UL") B`x'=(c[`i',1]) C`x'=(c[`i',2]) D`x'=(c[`i',4]) E`x'=(c[`i',5]) F`x'=(c[`i',6]) using FigureS7, modify
}
//Adj
mi estimate, hr: stcox ib4.indextype `mvmodel_mi'
qui {
matrix b=r(table)
matrix c=b'
matrix list c
local i=2
local x=`i'+7
local rowname:word `i' of `matrownames_mi'
putexcel A`x'=("Adj DPP vs TZD") B1=("HR") C1=("SE") D1=("p-value") E1=("LL") F1=("UL") B`x'=(c[`i',1]) C`x'=(c[`i',2]) D`x'=(c[`i',4]) E`x'=(c[`i',5]) F`x'=(c[`i',6]) using FigureS7, modify
}
//REFERENT: OTH
//Unadj
mi estimate, hr: stcox ib5.indextype
qui {
matrix b=r(table)
matrix c=b'
matrix list c
local i=2
local x=`i'+8
local rowname:word `i' of `matrownames_mi'
putexcel A`x'=("Unadj DPP vs OTH") A1=("Model") B1=("HR") C1=("SE") D1=("p-value") E1=("LL") F1=("UL") B`x'=(c[`i',1]) C`x'=(c[`i',2]) D`x'=(c[`i',4]) E`x'=(c[`i',5]) F`x'=(c[`i',6]) using FigureS7, modify
}
//Adj
mi estimate, hr: stcox ib5.indextype `mvmodel_mi'
qui {
matrix b=r(table)
matrix c=b'
matrix list c
local i=2
local x=`i'+9
local rowname:word `i' of `matrownames_mi'
putexcel A`x'=("Adj DPP vs OTH") B1=("HR") C1=("SE") D1=("p-value") E1=("LL") F1=("UL") B`x'=(c[`i',1]) C`x'=(c[`i',2]) D`x'=(c[`i',4]) E`x'=(c[`i',5]) F`x'=(c[`i',6]) using FigureS7, modify
}
//generate dat file needed for FigureS7
quietly{
clear
import excel using FigureS7, cellrange(A1:F11) firstrow
gen adj=0
gen counts=_n
gen referents=0 if counts<3&counts>0
replace referents=2 if counts<5&counts>2
replace referents=3 if counts<7&counts>4
replace referents=4 if counts<9&counts>6
replace referents=5 if counts<11&counts>8
replace adj=1 if counts==2|counts==4|counts==6|counts==8|counts==10
drop counts
drop Model
save FigureS7, replace
capture label drop referents
capture label drop adjusted
label define referents 0 "{bf}SU" 1 "{bf}DPP4i" 2 "{bf}GLP-1RA" 3 "{bf}Insulin" 4 "{bf}Thiazolidinedione" 5 "{bf}Other {bf}antidiabetic"
label values referents referents
label define adjusted 0 "Unadjusted" 1 "Adjusted"
label values adj adjusted
label var referents "{bf}Referent"
label var adj "{bf}Antidiabetic {bf}Class"
metan HR LL UL, force by(referents) nowt nobox nooverall null(1) xlabel(0, 0.25, 0.5, 0.75) astext(70) scheme(s1mono) effect("Hazard Ratio")
}
//generate FigureS7
metan HR LL UL, force by(referents) nowt nobox nooverall nosubgroup null(1) xlabel(0, 2, 3) astext(65) scheme(s1mono) lcols(adj) effect("{bf}Hazard {bf}Ratio") saving(FigureS7, asis replace)
graph export FigureS7.png, replace

//SUPPLEMENT TABLE S4: MACE FINDINGS FOR DPP AND GLP VS SU ACROSS VARYING RANGES
//secondline OR use table2_acm.xlsx (Unadj MI and Adj MI Ref0 tabs)
use Stat_mace_mi, clear
//IR 
mi xeq 1: stptime, by(indextype) per(1000)
quietly {
putexcel A1= ("Indextype") B1=("Person-Time") C1=("Failures") D1=("Incidence Rate") E1=("Lower Bound") F1=("Upper Bound") using manuscript_tables, sheet("TableS4") modify
forval i=1/2{
local row=`i'+1
mi xeq 1: stptime if indextype==`i', per(1000)
putexcel A`row'= ("`i'") B`row'=(r(ptime)) C`row'=(r(failures)) D`row'=(r(rate)*1000) E`row'=(r(lb)*1000) F`row'=(r(ub)*1000) using manuscript_tables, sheet("TableS4") modify
}
}
//Unadj
mi estimate, hr: stcox i.indextype
qui{

matrix b=r(table)
matrix c=b'
matrix list c
forval i=2/3{
local x=`i'
local rowname:word `i' of `matrownames_mi'
putexcel G`i'=("Unadj secondline") G1=("Model") H1=("HR") I1=("SE") J1=("p-value") K1=("LL") L1=("UL") A`x'=("`rowname'") H`x'=(c[`i',1]) I`x'=(c[`i',2]) J`x'=(c[`i',4]) K`x'=(c[`i',5]) L`x'=(c[`i',6]) using manuscript_tables, sheet("TableS4") modify
}
}
//Adj
mi estimate, hr: stcox i.indextype `mvmodel_mi'
qui{
matrix b=r(table)
matrix c=b'
matrix list c
forval i=2/3{
local x=`i'+2
local rowname:word `i' of `matrownames_mi'
putexcel G`x'=("Adj secondline") H1=("HR") I1=("SE") J1=("p-value") K1=("LL") L1=("UL") F`x'=("`rowname'") H`x'=(c[`i',1]) I`x'=(c[`i',2]) J`x'=(c[`i',4]) K`x'=(c[`i',5]) L`x'=(c[`i',6]) using manuscript_tables, sheet("TableS4") modify
}
}
//second line, first gap
use Stat_mace_mi_index, clear
//IR 
mi xeq 1: stptime, by(indextype) per(1000)
quietly {
forval i=1/2{
local row=`i'+6
mi xeq 1: stptime if indextype==`i', per(1000)
putexcel A`row'= ("`i'") B`row'=(r(ptime)) C`row'=(r(failures)) D`row'=(r(rate)*1000) E`row'=(r(lb)*1000) F`row'=(r(ub)*1000) using manuscript_tables, sheet("TableS4") modify
}
}
//Unadj
mi estimate, hr: stcox i.indextype
qui {
matrix b=r(table)
matrix c=b'
matrix list c
forval i=2/3{
local x=`i'+5
local rowname:word `i' of `matrownames_mi'
putexcel G`x'=("Unadj secondline, first gap") G1=("Model") H1=("HR") I1=("SE") J1=("p-value") K1=("LL") L1=("UL") A`x'=("`rowname'") H`x'=(c[`i',1]) I`x'=(c[`i',2]) J`x'=(c[`i',4]) K`x'=(c[`i',5]) L`x'=(c[`i',6]) using manuscript_tables, sheet("TableS4") modify
}
}
//Adj
mi estimate, hr: stcox i.indextype `mvmodel_mi'
qui{
matrix b=r(table)
matrix c=b'
matrix list c
forval i=2/3{
local x=`i'+7
local rowname:word `i' of `matrownames_mi'
putexcel G`x'=("Adj secondline, first gap") H1=("HR") I1=("SE") J1=("p-value") K1=("LL") L1=("UL") F`x'=("`rowname'") H`x'=(c[`i',1]) I`x'=(c[`i',2]) J`x'=(c[`i',4]) K`x'=(c[`i',5]) L`x'=(c[`i',6]) using manuscript_tables, sheet("TableS4") modify
}
}
//thirdline
use Stat_mace_mi_index3, clear
//IR 
mi xeq 1: stptime, by(indextype) per(1000)
quietly {
forval i=1/2{
local row=`i'+11
mi xeq 1: stptime if indextype==`i', per(1000)
putexcel A`row'= ("`i'") B`row'=(r(ptime)) C`row'=(r(failures)) D`row'=(r(rate)*1000) E`row'=(r(lb)*1000) F`row'=(r(ub)*1000) using manuscript_tables, sheet("TableS4") modify
}
}
//Unadj
mi estimate, hr: stcox i.indextype
qui{
matrix b=r(table)
matrix c=b'
matrix list c
forval i=2/3{
local x=`i'+10
local rowname:word `i' of `matrownames_mi'
putexcel G`x'=("Unadj thirdline") G1=("Model") H1=("HR") I1=("SE") J1=("p-value") K1=("LL") L1=("UL") A`x'=("`rowname'") H`x'=(c[`i',1]) I`x'=(c[`i',2]) J`x'=(c[`i',4]) K`x'=(c[`i',5]) L`x'=(c[`i',6]) using manuscript_tables, sheet("TableS4") modify
}
}
//Adj
mi estimate, hr: stcox i.indextype `mvmodel_mi'
qui{
matrix b=r(table)
matrix c=b'
matrix list c
forval i=2/3{
local x=`i'+12
local rowname:word `i' of `matrownames_mi'
putexcel G`x'=("Adj thirdline") H1=("HR") I1=("SE") J1=("p-value") K1=("LL") L1=("UL") F`x'=("`rowname'") H`x'=(c[`i',1]) I`x'=(c[`i',2]) J`x'=(c[`i',4]) K`x'=(c[`i',5]) L`x'=(c[`i',6]) using manuscript_tables, sheet("TableS4") modify
}
}
//any after monotherapy 
use Stat_mace_mi_any, clear
//IR 
mi xeq 1: stptime, by(indextype) per(1000)
quietly {
forval i=1/2{
local row=`i'+16
mi xeq 1: stptime if indextype==`i', per(1000)
putexcel A`row'= ("`i'") B`row'=(r(ptime)) C`row'=(r(failures)) D`row'=(r(rate)*1000) E`row'=(r(lb)*1000) F`row'=(r(ub)*1000) using manuscript_tables, sheet("TableS4") modify
}
}
//Unadj
mi estimate, hr: stcox i.indextype
qui {
matrix b=r(table)
matrix c=b'
matrix list c
forval i=2/3{
local x=`i'+15
local rowname:word `i' of `matrownames_mi'
putexcel G`x'=("Unadj any after") G1=("Model") H1=("HR") I1=("SE") J1=("p-value") K1=("LL") L1=("UL") A`x'=("`rowname'") H`x'=(c[`i',1]) I`x'=(c[`i',2]) J`x'=(c[`i',4]) K`x'=(c[`i',5]) L`x'=(c[`i',6]) using manuscript_tables, sheet("TableS4") modify
}
}
//Adj
mi estimate, hr: stcox i.indextype `mvmodel_mi'
qui{
matrix b=r(table)
matrix c=b'
matrix list c
forval i=2/3{
local x=`i'+17
local rowname:word `i' of `matrownames_mi'
putexcel G`x'=("Adj any after") H1=("HR") I1=("SE") J1=("p-value") K1=("LL") L1=("UL") F`x'=("`rowname'") H`x'=(c[`i',1]) I`x'=(c[`i',2]) J`x'=(c[`i',4]) K`x'=(c[`i',5]) L`x'=(c[`i',6]) using manuscript_tables, sheet("TableS4") modify
}
}

//SUPPLEMENT FIGURE S8: MACE FINDINGS FOR DPP AND GLP VS SU ACROSS VARYING RANGES
//secondline OR use table2_acm.xlsx (Unadj MI and Adj MI Ref0 tabs)
use Stat_mace_mi, clear
//IR 
mi xeq 1: stptime, by(indextype) per(1000)
quietly {
putexcel A1= ("Indextype") B1=("Person-Time") C1=("Failures") D1=("Incidence Rate") E1=("Lower Bound") F1=("Upper Bound") using FigureS8, modify
forval i=1/2{
local row=`i'+1
mi xeq 1: stptime if indextype==`i', per(1000)
putexcel A`row'= ("`i'") B`row'=(r(ptime)) C`row'=(r(failures)) D`row'=(r(rate)*1000) E`row'=(r(lb)*1000) F`row'=(r(ub)*1000) using FigureS8, modify
}
}
//Unadj
mi estimate, hr: stcox i.indextype
qui{

matrix b=r(table)
matrix c=b'
matrix list c
forval i=2/3{
local x=`i'
local rowname:word `i' of `matrownames_mi'
putexcel G`i'=("Unadj secondline") G1=("Model") H1=("HR") I1=("SE") J1=("p-value") K1=("LL") L1=("UL") A`x'=("`rowname'") H`x'=(c[`i',1]) I`x'=(c[`i',2]) J`x'=(c[`i',4]) K`x'=(c[`i',5]) L`x'=(c[`i',6]) using FigureS8, modify
}
}
//Adj
mi estimate, hr: stcox i.indextype `mvmodel_mi'
qui{
matrix b=r(table)
matrix c=b'
matrix list c
forval i=2/3{
local x=`i'+2
local rowname:word `i' of `matrownames_mi'
putexcel G`x'=("Adj secondline") H1=("HR") I1=("SE") J1=("p-value") K1=("LL") L1=("UL") F`x'=("`rowname'") H`x'=(c[`i',1]) I`x'=(c[`i',2]) J`x'=(c[`i',4]) K`x'=(c[`i',5]) L`x'=(c[`i',6]) using FigureS8, modify
}
}
//second line, first gap
use Stat_mace_mi_index, clear
//IR 
mi xeq 1: stptime, by(indextype) per(1000)
quietly {
forval i=1/2{
local row=`i'+6
mi xeq 1: stptime if indextype==`i', per(1000)
putexcel A`row'= ("`i'") B`row'=(r(ptime)) C`row'=(r(failures)) D`row'=(r(rate)*1000) E`row'=(r(lb)*1000) F`row'=(r(ub)*1000) using FigureS8, modify
}
}
//Unadj
mi estimate, hr: stcox i.indextype
qui {
matrix b=r(table)
matrix c=b'
matrix list c
forval i=2/3{
local x=`i'+5
local rowname:word `i' of `matrownames_mi'
putexcel G`x'=("Unadj secondline, first gap") G1=("Model") H1=("HR") I1=("SE") J1=("p-value") K1=("LL") L1=("UL") A`x'=("`rowname'") H`x'=(c[`i',1]) I`x'=(c[`i',2]) J`x'=(c[`i',4]) K`x'=(c[`i',5]) L`x'=(c[`i',6]) using FigureS8, modify
}
}
//Adj
mi estimate, hr: stcox i.indextype `mvmodel_mi'
qui{
matrix b=r(table)
matrix c=b'
matrix list c
forval i=2/3{
local x=`i'+7
local rowname:word `i' of `matrownames_mi'
putexcel G`x'=("Adj secondline, first gap") H1=("HR") I1=("SE") J1=("p-value") K1=("LL") L1=("UL") F`x'=("`rowname'") H`x'=(c[`i',1]) I`x'=(c[`i',2]) J`x'=(c[`i',4]) K`x'=(c[`i',5]) L`x'=(c[`i',6]) using FigureS8, modify
}
}
//thirdline
use Stat_mace_mi_index3, clear
//IR 
mi xeq 1: stptime, by(indextype) per(1000)
quietly {
forval i=1/2{
local row=`i'+11
mi xeq 1: stptime if indextype==`i', per(1000)
putexcel A`row'= ("`i'") B`row'=(r(ptime)) C`row'=(r(failures)) D`row'=(r(rate)*1000) E`row'=(r(lb)*1000) F`row'=(r(ub)*1000) using FigureS8, modify
}
}
//Unadj
mi estimate, hr: stcox i.indextype
qui{
matrix b=r(table)
matrix c=b'
matrix list c
forval i=2/3{
local x=`i'+10
local rowname:word `i' of `matrownames_mi'
putexcel G`x'=("Unadj thirdline") G1=("Model") H1=("HR") I1=("SE") J1=("p-value") K1=("LL") L1=("UL") A`x'=("`rowname'") H`x'=(c[`i',1]) I`x'=(c[`i',2]) J`x'=(c[`i',4]) K`x'=(c[`i',5]) L`x'=(c[`i',6]) using FigureS8, modify
}
}
//Adj
mi estimate, hr: stcox i.indextype `mvmodel_mi'
qui{
matrix b=r(table)
matrix c=b'
matrix list c
forval i=2/3{
local x=`i'+12
local rowname:word `i' of `matrownames_mi'
putexcel G`x'=("Adj thirdline") H1=("HR") I1=("SE") J1=("p-value") K1=("LL") L1=("UL") F`x'=("`rowname'") H`x'=(c[`i',1]) I`x'=(c[`i',2]) J`x'=(c[`i',4]) K`x'=(c[`i',5]) L`x'=(c[`i',6]) using FigureS8, modify
}
}
//any after monotherapy 
use Stat_mace_mi_any, clear
//IR 
mi xeq 1: stptime, by(indextype) per(1000)
quietly {
forval i=1/2{
local row=`i'+16
mi xeq 1: stptime if indextype==`i', per(1000)
putexcel A`row'= ("`i'") B`row'=(r(ptime)) C`row'=(r(failures)) D`row'=(r(rate)*1000) E`row'=(r(lb)*1000) F`row'=(r(ub)*1000) using FigureS8, modify
}
}
//Unadj
mi estimate, hr: stcox i.indextype
qui {
matrix b=r(table)
matrix c=b'
matrix list c
forval i=2/3{
local x=`i'+15
local rowname:word `i' of `matrownames_mi'
putexcel G`x'=("Unadj any after") G1=("Model") H1=("HR") I1=("SE") J1=("p-value") K1=("LL") L1=("UL") A`x'=("`rowname'") H`x'=(c[`i',1]) I`x'=(c[`i',2]) J`x'=(c[`i',4]) K`x'=(c[`i',5]) L`x'=(c[`i',6]) using FigureS8, modify
}
}
//Adj
mi estimate, hr: stcox i.indextype `mvmodel_mi'
qui{
matrix b=r(table)
matrix c=b'
matrix list c
forval i=2/3{
local x=`i'+17
local rowname:word `i' of `matrownames_mi'
putexcel G`x'=("Adj any after") H1=("HR") I1=("SE") J1=("p-value") K1=("LL") L1=("UL") F`x'=("`rowname'") H`x'=(c[`i',1]) I`x'=(c[`i',2]) J`x'=(c[`i',4]) K`x'=(c[`i',5]) L`x'=(c[`i',6]) using FigureS8, modify
}
}
//generate dat file needed for FigureS8
quietly{
clear
import excel using FigureS5, cellrange(G1:L20) firstrow
drop if HR==.
gen counts=_n
gen trt=.
gen adj=.
forval i=1(2)16{
replace trt=1 if counts==`i'
}
forval i=2(2)16{
replace trt=2 if counts==`i'
}
forval i=1(4)16{
replace adj=0 if counts==`i'
}
forval i=2(4)16{
replace adj=0 if counts==`i'
}
forval i=3(4)16{
replace adj=1 if counts==`i'
}
forval i=4(4)16{
replace adj=1 if counts==`i'
}
drop Model
gen Model=.
forval i=1/4{
replace Model=1 if counts==`i'
}
forval i=5/8{
replace Model=2 if counts==`i'
}
forval i=9/12{
replace Model=3 if counts==`i'
}
forval i=13/16{
replace Model=4 if counts==`i'
}
save FigureS8, replace
capture label drop treatments
capture label drop adjusted
capture label drop models
label define treatments 1 "{bf}DPP4i" 2 "{bf}GLP-1RA"
label define adjusted 0 "Unadjusted" 1 "Adjusted"
label define models 1 "Second line, last exposure" 2 "Second line, first gap" 3 "Second line, third agent" 4 "Any line, after metformin"
label values adj adjusted
label values trt treatments
label values Model models
label var Model "{bf}Range"
label var adj "{bf}Antidiabetic {bf}Class"
drop if SE==.
metan HR LL UL, force by(Model) nowt nobox nooverall null(1) xlabel(0, 0.25, 0.5, 0.75) astext(70) scheme(s1mono) effect("Hazard Ratio")
}
//generate FigureS8
metan HR LL UL if adj==1, force by(trt) nowt nobox nooverall nosubgroup null(1) xlabel(0, 2, 3, 4, 5, 6, 7) astext(65) scheme(s1mono) lcols(Model) effect("{bf}Hazard {bf}Ratio") saving(FigureS8, asis replace)
graph export FigureS8.png, replace

//FIGURE 3: ACM SUBGROUP ANALYSIS
use Stat_acm_mi, clear
//mvmodel_mi includes: demoMI, comorb2 meds2, clinMI (only differences between mvmodel and mvmodel_mi are the imputed variables and removal of *_post for collinearity)
local mvmodel_mi = "age_indexdate gender ib2.smokestatus_clone ib1.hba1c_cats_i2_clone i.ckd_amdrd bmi_i sbp i.physician_vis2 i.prx_ccivalue_g_i2 cvd_i dmdur metoverlap i.unique_cov_drugs statin_i calchan_i betablock_i anticoag_oral_i antiplat_i ace_arb_renin_i diuretics_all_i"
local matrownames_mi "SU DPP4I GLP1RA INS TZD OTH Age Male Unknown Current Non_Smoker Former HbA1c_<7 HbA1c_7_8 HbA1c_8_9 HbA1c_9_10 HbA1c_>10 HbA1c_unknown eGFR_90+ eGFR_60_89 eGFR_30_59 eGFR_15_29 eGFR_<15 eGFR_unknown BMI SBP PhysVis_12 PhysVis_24 PhysVis_24plus CCI=1 CCI=2 CCI=3+ CVD diabetes_duration Metformin_overlap No_unique_drugs_0_5 No_unique_drugs_6_10 No_unique_drugs_11_15 No_unique_drugs_16_20 No_unique_drugs_>20 Statin CCB BB Anticoag Antiplat RAS Diuretics"
////////////////////////////////////////////////////////////////////////AGE/////////////////////////////////////////////////////////////////
//estimate for age>=65==0
mi estimate, hr post: stcox indextype_2##ib1.age_65 indextype_3 indextype_4 indextype_5 indextype_6 indextype_7 `mvmodel_mi', cformat(%6.2f) pformat(%5.3f) sformat(%6.2f) nolog
qui{
matrix b=r(table)
matrix c=b'
matrix list c
local i=1
local y=`i'+1
local x=`i'+1
local rowname:word `y' of `matrownames_mi'
putexcel A1=("Subgroup") B1=("aHR") C1=("SE") D1=("p-value") E1=("LL") F1=("UL") A`x'=("Age>65==0") B`x'=(c[`y',1]) C`x'=(c[`y',2]) D`x'=(c[`y',4]) E`x'=(c[`y',5]) F`x'=(c[`y',6]) using Figure3, modify
}
//Number of failures for DPP if age>=65==0
quietly {
putexcel G1=("nDPP") H1=("NDPP") using Figure3, modify
local i=1
local x=`i'+1
mi xeq 1: stptime if indextype==1&age_65==0, by(indextype) per(1000)
putexcel G`x'=(r(failures)) using Figure3, modify
unique patid if indextype==1&age_65==0
putexcel H`x'=(r(sum)) using Figure3, modify
}
//Number of failures for SU if age>=65==0
quietly {
putexcel I1=("nSU") J1=("NSU") using Figure3, modify
local i=1
local x=`i'+1
mi xeq 1: stptime if indextype==0&age_65==0, by(indextype) per(1000)
putexcel I`x'=(r(failures)) using Figure3, modify
unique patid if indextype==0&age_65==0
putexcel J`x'=(r(sum)) using Figure3, modify
}
//estimate for age>=65==1
mi estimate, hr post: stcox indextype_2##i.age_65 indextype_3 indextype_4 indextype_5 indextype_6 indextype_7 `mvmodel_mi', cformat(%6.2f) pformat(%5.3f) sformat(%6.2f) nolog
qui{
matrix b=r(table)
matrix c=b'
matrix list c
local i=1
local y=`i'+1
local x=`i'+2
local rowname:word `y' of `matrownames_mi'
putexcel A`x'=("Age>65==1") B`x'=(c[`y',1]) C`x'=(c[`y',2]) D`x'=(c[`y',4]) E`x'=(c[`y',5]) F`x'=(c[`y',6]) using Figure3, modify
}

//Number of failures for DPP if age>=65==1
quietly {
local i=1
local x=`i'+2
mi xeq 1: stptime if indextype==1&age_65==1, by(indextype) per(1000)
putexcel G`x'=(r(failures)) using Figure3, modify
unique patid if indextype==1&age_65==1
putexcel H`x'=(r(sum)) using Figure3, modify
}
//Number of failures for SU if age>=65==1
quietly {
local i=1
local x=`i'+2
mi xeq 1: stptime if indextype==0&age_65==1, by(indextype) per(1000)
putexcel I`x'=(r(failures)) using Figure3, modify
unique patid if indextype==0&age_65==1
putexcel J`x'=(r(sum)) using Figure3, modify
}

////////////////////////////////////////////////////////////////////////GENDER/////////////////////////////////////////////////////////////
//estimate for gender==0
mi estimate, hr post: stcox indextype_2##ib1.gender indextype_3 indextype_4 indextype_5 indextype_6 indextype_7 `mvmodel_mi', cformat(%6.2f) pformat(%5.3f) sformat(%6.2f) nolog
qui{
matrix b=r(table)
matrix c=b'
matrix list c
local i=1
local y=`i'+1
local x=`i'+3
putexcel A`x'=("Gender==0") B`x'=(c[`y',1]) C`x'=(c[`y',2]) D`x'=(c[`y',4]) E`x'=(c[`y',5]) F`x'=(c[`y',6]) using Figure3, modify
}
//Number of failures for DPP if gender==0
quietly {
local i=1
local x=`i'+3
mi xeq 1: stptime if indextype==1&gender==0, by(indextype) per(1000)
putexcel G`x'=(r(failures)) using Figure3, modify
unique patid if indextype==1&gender==0
putexcel H`x'=(r(sum)) using Figure3, modify
}
//Number of failures for SU if gender==0
quietly {
local i=1
local x=`i'+3
mi xeq 1: stptime if indextype==0&gender==0, by(indextype) per(1000)
putexcel I`x'=(r(failures)) using Figure3, modify
unique patid if indextype==0&gender==0
putexcel J`x'=(r(sum)) using Figure3, modify
}

//estimate for gender==1
mi estimate, hr post: stcox indextype_2##i.gender indextype_3 indextype_4 indextype_5 indextype_6 indextype_7 `mvmodel_mi', cformat(%6.2f) pformat(%5.3f) sformat(%6.2f) nolog
qui{
matrix b=r(table)
matrix c=b'
matrix list c
local i=1
local y=`i'+1
local x=`i'+4
local rowname:word `y' of `matrownames_mi'
putexcel A`x'=("Gender==1") B`x'=(c[`y',1]) C`x'=(c[`y',2]) D`x'=(c[`y',4]) E`x'=(c[`y',5]) F`x'=(c[`y',6]) using Figure3, modify
}
//Number of failures for DPP if gender==1
quietly {
local i=1
local x=`i'+4
mi xeq 1: stptime if indextype==1&gender==1, by(indextype) per(1000)
putexcel G`x'=(r(failures)) using Figure3, modify
unique patid if indextype==1&gender==1
putexcel H`x'=(r(sum)) using Figure3, modify
}
//Number of failures for SU if gender==1
quietly {
local i=1
local x=`i'+4
mi xeq 1: stptime if indextype==0&gender==1, by(indextype) per(1000)
putexcel I`x'=(r(failures)) using Figure3, modify
unique patid if indextype==0&gender==1
putexcel J`x'=(r(sum)) using Figure3, modify
}
////////////////////////////////////////////////////////////////////////DMDUR/////////////////////////////////////////////////////////////
//estimate for dmdur_2==0
mi estimate, hr post: stcox indextype_2##ib1.dmdur_2 indextype_3 indextype_4 indextype_5 indextype_6 indextype_7 `mvmodel_mi', cformat(%6.2f) pformat(%5.3f) sformat(%6.2f) nolog
qui{
matrix b=r(table)
matrix c=b'
matrix list c
local i=1
local y=`i'+1
local x=`i'+5
putexcel A`x'=("DMdur2==0") B`x'=(c[`y',1]) C`x'=(c[`y',2]) D`x'=(c[`y',4]) E`x'=(c[`y',5]) F`x'=(c[`y',6]) using Figure3, modify
}
//Number of failures for DPP if dmdur_2==0
quietly {
local i=1
local x=`i'+5
mi xeq 1: stptime if indextype==1&dmdur_2==0, by(indextype) per(1000)
putexcel G`x'=(r(failures)) using Figure3, modify
unique patid if indextype==1&dmdur_2==0
putexcel H`x'=(r(sum)) using Figure3, modify
}
//Number of failures for SU if dmdur_2==0
quietly {
local i=1
local x=`i'+5
mi xeq 1: stptime if indextype==0&dmdur_2==0, by(indextype) per(1000)
putexcel I`x'=(r(failures)) using Figure3, modify
unique patid if indextype==0&dmdur_2==0
putexcel J`x'=(r(sum)) using Figure3, modify
}

//estimate for dmdur_2==1
mi estimate, hr post: stcox indextype_2##i.dmdur_2 indextype_3 indextype_4 indextype_5 indextype_6 indextype_7 `mvmodel_mi', cformat(%6.2f) pformat(%5.3f) sformat(%6.2f) nolog
qui{
matrix b=r(table)
matrix c=b'
matrix list c
local i=1
local y=`i'+1
local x=`i'+6
putexcel A`x'=("DMdur2==1") B`x'=(c[`y',1]) C`x'=(c[`y',2]) D`x'=(c[`y',4]) E`x'=(c[`y',5]) F`x'=(c[`y',6]) using Figure3, modify
}
//Number of failures for DPP if dmdur_2==1
quietly {
local i=1
local x=`i'+6
mi xeq 1: stptime if indextype==1&dmdur_2==1, by(indextype) per(1000)
putexcel G`x'=(r(failures)) using Figure3, modify
unique patid if indextype==1&dmdur_2==1
putexcel H`x'=(r(sum)) using Figure3, modify
}
//Number of failures for SU if dmdur_2==1
quietly {
local i=1
local x=`i'+6
mi xeq 1: stptime if indextype==0&dmdur_2==1, by(indextype) per(1000)
putexcel I`x'=(r(failures)) using Figure3, modify
unique patid if indextype==0&dmdur_2==1
putexcel J`x'=(r(sum)) using Figure3, modify
}
////////////////////////////////////////////////////////////////////////HbA1C///////////////////////////////////////////////////////////////
//estimate for hba1c_8==0
mi estimate, hr post: stcox indextype_2##ib1.hba1c_8 indextype_3 indextype_4 indextype_5 indextype_6 indextype_7 `mvmodel_mi', cformat(%6.2f) pformat(%5.3f) sformat(%6.2f) nolog
qui{
matrix b=r(table)
matrix c=b'
matrix list c
local i=1
local y=`i'+1
local x=`i'+7
putexcel A`x'=("A1C8==0") B`x'=(c[`y',1]) C`x'=(c[`y',2]) D`x'=(c[`y',4]) E`x'=(c[`y',5]) F`x'=(c[`y',6]) using Figure3, modify
}
//Number of failures for DPP if hba1c_8==0
quietly {
local i=1
local x=`i'+7
mi xeq 1: stptime if indextype==1&hba1c_8==0, by(indextype) per(1000)
putexcel G`x'=(r(failures)) using Figure3, modify
unique patid if indextype==1&hba1c_8==0
putexcel H`x'=(r(sum)) using Figure3, modify
}
//Number of failures for SU if hba1c_8==0
quietly {
local i=1
local x=`i'+7
mi xeq 1: stptime if indextype==0&hba1c_8==0, by(indextype) per(1000)
putexcel I`x'=(r(failures)) using Figure3, modify
unique patid if indextype==0&hba1c_8==0
putexcel J`x'=(r(sum)) using Figure3, modify
}

//estimate for hba1c_8==1
mi estimate, hr post: stcox indextype_2##i.hba1c_8 indextype_3 indextype_4 indextype_5 indextype_6 indextype_7 `mvmodel_mi', cformat(%6.2f) pformat(%5.3f) sformat(%6.2f) nolog
qui{
matrix b=r(table)
matrix c=b'
matrix list c
local i=1
local y=`i'+1
local x=`i'+8
putexcel A`x'=("A1C8==1") B`x'=(c[`y',1]) C`x'=(c[`y',2]) D`x'=(c[`y',4]) E`x'=(c[`y',5]) F`x'=(c[`y',6]) using Figure3, modify
}
//Number of failures for DPP if hba1c_8==1
quietly {
local i=1
local x=`i'+8
mi xeq 1: stptime if indextype==1&hba1c_8==1, by(indextype) per(1000)
putexcel G`x'=(r(failures)) using Figure3, modify
unique patid if indextype==1&hba1c_8==1
putexcel H`x'=(r(sum)) using Figure3, modify
}
//Number of failures for SU if hba1c_8==1
quietly {
local i=1
local x=`i'+8
mi xeq 1: stptime if indextype==0&hba1c_8==1, by(indextype) per(1000)
putexcel I`x'=(r(failures)) using Figure3, modify
unique patid if indextype==0&hba1c_8==1
putexcel J`x'=(r(sum)) using Figure3, modify
}
////////////////////////////////////////////////////////////////////////BMI/////////////////////////////////////////////////////////////////
//estimate for bmi_30==0
mi estimate, hr post: stcox indextype_2##ib1.bmi_30 indextype_3 indextype_4 indextype_5 indextype_6 indextype_7 `mvmodel_mi', cformat(%6.2f) pformat(%5.3f) sformat(%6.2f) nolog
qui{
matrix b=r(table)
matrix c=b'
matrix list c
local i=1
local y=`i'+1
local x=`i'+9
putexcel A`x'=("BMI30==0") B`x'=(c[`y',1]) C`x'=(c[`y',2]) D`x'=(c[`y',4]) E`x'=(c[`y',5]) F`x'=(c[`y',6]) using Figure3, modify
}
//Number of failures for DPP if bmi_30==0
quietly {
local i=1
local x=`i'+9
mi xeq 1: stptime if indextype==1&bmi_30==0, by(indextype) per(1000)
putexcel G`x'=(r(failures)) using Figure3, modify
unique patid if indextype==1&bmi_30==0
putexcel H`x'=(r(sum)) using Figure3, modify
}
//Number of failures for SU if bmi_30==0
quietly {
local i=1
local x=`i'+9
mi xeq 1: stptime if indextype==0&bmi_30==0, by(indextype) per(1000)
putexcel I`x'=(r(failures)) using Figure3, modify
unique patid if indextype==0&bmi_30==0
putexcel J`x'=(r(sum)) using Figure3, modify
}

//estimate for bmi_30==1
mi estimate, hr post: stcox indextype_2##i.bmi_30 indextype_3 indextype_4 indextype_5 indextype_6 indextype_7 `mvmodel_mi', cformat(%6.2f) pformat(%5.3f) sformat(%6.2f) nolog
qui{
matrix b=r(table)
matrix c=b'
matrix list c
local i=1
local y=`i'+1
local x=`i'+10
putexcel A`x'=("BMI30==1") B`x'=(c[`y',1]) C`x'=(c[`y',2]) D`x'=(c[`y',4]) E`x'=(c[`y',5]) F`x'=(c[`y',6]) using Figure3, modify
}
//Number of failures for DPP if bmi_30==1
quietly {
local i=1
local x=`i'+10
mi xeq 1: stptime if indextype==1&bmi_30==1, by(indextype) per(1000)
putexcel G`x'=(r(failures)) using Figure3, modify
unique patid if indextype==1&bmi_30==1
putexcel H`x'=(r(sum)) using Figure3, modify
}
//Number of failures for SU if bmi_30==1
quietly {
local i=1
local x=`i'+10
mi xeq 1: stptime if indextype==0&bmi_30==1, by(indextype) per(1000)
putexcel I`x'=(r(failures)) using Figure3, modify
unique patid if indextype==0&bmi_30==1
putexcel J`x'=(r(sum)) using Figure3, modify
}
////////////////////////////////////////////////////////////////////////CKD/////////////////////////////////////////////////////////////////
//estimate for ckd_60==0
mi estimate, hr post: stcox indextype_2##ib1.ckd_60 indextype_3 indextype_4 indextype_5 indextype_6 indextype_7 `mvmodel_mi', cformat(%6.2f) pformat(%5.3f) sformat(%6.2f) nolog
qui{
matrix b=r(table)
matrix c=b'
matrix list c
local i=1
local y=`i'+1
local x=`i'+11
putexcel A`x'=("CKD60==0") B`x'=(c[`y',1]) C`x'=(c[`y',2]) D`x'=(c[`y',4]) E`x'=(c[`y',5]) F`x'=(c[`y',6]) using Figure3, modify
}
//Number of failures for DPP if ckd_60==0
quietly {
local i=1
local x=`i'+11
mi xeq 1: stptime if indextype==1&ckd_60==0, by(indextype) per(1000)
putexcel G`x'=(r(failures)) using Figure3, modify
unique patid if indextype==1&ckd_60==0
putexcel H`x'=(r(sum)) using Figure3, modify
}
//Number of failures for SU if ckd_60==0
quietly {
local i=1
local x=`i'+11
mi xeq 1: stptime if indextype==0&ckd_60==0, by(indextype) per(1000)
putexcel I`x'=(r(failures)) using Figure3, modify
unique patid if indextype==0&ckd_60==0
putexcel J`x'=(r(sum)) using Figure3, modify
}

//estimate for ckd_60==1
mi estimate, hr post: stcox indextype_2##i.ckd_60 indextype_3 indextype_4 indextype_5 indextype_6 indextype_7 `mvmodel_mi', cformat(%6.2f) pformat(%5.3f) sformat(%6.2f) nolog
qui{
matrix b=r(table)
matrix c=b'
matrix list c
local i=1
local y=`i'+1
local x=`i'+12
putexcel A`x'=("CKD60==1") B`x'=(c[`y',1]) C`x'=(c[`y',2]) D`x'=(c[`y',4]) E`x'=(c[`y',5]) F`x'=(c[`y',6]) using Figure3, modify
}
//Number of failures for DPP if ckd_60==1
quietly {
local i=1
local x=`i'+12
mi xeq 1: stptime if indextype==1&ckd_60==1, by(indextype) per(1000)
putexcel G`x'=(r(failures)) using Figure3, modify
unique patid if indextype==1&ckd_60==1
putexcel H`x'=(r(sum)) using Figure3, modify
}
//Number of failures for SU if ckd_60==1
quietly {
local i=1
local x=`i'+12
mi xeq 1: stptime if indextype==0&ckd_60==1, by(indextype) per(1000)
putexcel I`x'=(r(failures)) using Figure3, modify
unique patid if indextype==0&ckd_60==1
putexcel J`x'=(r(sum)) using Figure3, modify
}
////////////////////////////////////////////////////////////////////////HF/////////////////////////////////////////////////////////////////
//estimate for hf_i==0
mi estimate, hr post: stcox indextype_2##ib1.hf_i indextype_3 indextype_4 indextype_5 indextype_6 indextype_7 `mvmodel_mi', cformat(%6.2f) pformat(%5.3f) sformat(%6.2f) nolog
qui{
matrix b=r(table)
matrix c=b'
matrix list c
local i=1
local y=`i'+1
local x=`i'+13
putexcel A`x'=("HF==0") B`x'=(c[`y',1]) C`x'=(c[`y',2]) D`x'=(c[`y',4]) E`x'=(c[`y',5]) F`x'=(c[`y',6]) using Figure3, modify
}
//Number of failures for DPP if hf_i==0
quietly {
local i=1
local x=`i'+13
mi xeq 1: stptime if indextype==1&hf_i==0, by(indextype) per(1000)
putexcel G`x'=(r(failures)) using Figure3, modify
unique patid if indextype==1&hf_i==0
putexcel H`x'=(r(sum)) using Figure3, modify
}
//Number of failures for SU if hf_i==0
quietly {
local i=1
local x=`i'+13
mi xeq 1: stptime if indextype==0&hf_i==0, by(indextype) per(1000)
putexcel I`x'=(r(failures)) using Figure3, modify
unique patid if indextype==0&hf_i==0
putexcel J`x'=(r(sum)) using Figure3, modify
}

//estimate for hf_i==1
mi estimate, hr post: stcox indextype_2##i.hf_i indextype_3 indextype_4 indextype_5 indextype_6 indextype_7 `mvmodel_mi', cformat(%6.2f) pformat(%5.3f) sformat(%6.2f) nolog
qui{
matrix b=r(table)
matrix c=b'
matrix list c
local i=1
local y=`i'+1
local x=`i'+14
putexcel A`x'=("HF==1") B`x'=(c[`y',1]) C`x'=(c[`y',2]) D`x'=(c[`y',4]) E`x'=(c[`y',5]) F`x'=(c[`y',6]) using Figure3, modify
}
//Number of failures for DPP if hf_i==1
quietly {
local i=1
local x=`i'+14
mi xeq 1: stptime if indextype==1&hf_i==1, by(indextype) per(1000)
putexcel G`x'=(r(failures)) using Figure3, modify
unique patid if indextype==1&hf_i==1
putexcel H`x'=(r(sum)) using Figure3, modify
}
//Number of failures for SU if hf_i==1
quietly {
local i=1
local x=`i'+14
mi xeq 1: stptime if indextype==0&hf_i==1, by(indextype) per(1000)
putexcel I`x'=(r(failures)) using Figure3, modify
unique patid if indextype==0&hf_i==1
putexcel J`x'=(r(sum)) using Figure3, modify
}
////////////////////////////////////////////////////////////////////////MISTROKE////////////////////////////////////////////////////////////
//estimate for mi_stroke==0
mi estimate, hr post: stcox indextype_2##ib1.mi_stroke indextype_3 indextype_4 indextype_5 indextype_6 indextype_7 `mvmodel_mi', cformat(%6.2f) pformat(%5.3f) sformat(%6.2f) nolog
qui{
matrix b=r(table)
matrix c=b'
matrix list c
local i=1
local y=`i'+1
local x=`i'+15
putexcel A`x'=("MISTROKE==0") B`x'=(c[`y',1]) C`x'=(c[`y',2]) D`x'=(c[`y',4]) E`x'=(c[`y',5]) F`x'=(c[`y',6]) using Figure3, modify
}
//Number of failures for DPP if mi_stroke==0
quietly {
local i=1
local x=`i'+15
mi xeq 1: stptime if indextype==1&mi_stroke==0, by(indextype) per(1000)
putexcel G`x'=(r(failures)) using Figure3, modify
unique patid if indextype==1&mi_stroke==0
putexcel H`x'=(r(sum)) using Figure3, modify
}
//Number of failures for SU if mi_stroke==0
quietly {
local i=1
local x=`i'+15
mi xeq 1: stptime if indextype==0&mi_stroke==0, by(indextype) per(1000)
putexcel I`x'=(r(failures)) using Figure3, modify
unique patid if indextype==0&mi_stroke==0
putexcel J`x'=(r(sum)) using Figure3, modify
}

//estimate for mi_stroke==1
mi estimate, hr post: stcox indextype_2##i.mi_stroke indextype_3 indextype_4 indextype_5 indextype_6 indextype_7 `mvmodel_mi', cformat(%6.2f) pformat(%5.3f) sformat(%6.2f) nolog
qui{
matrix b=r(table)
matrix c=b'
matrix list c
local i=1
local y=`i'+1
local x=`i'+16
putexcel A`x'=("MISTROKE==1") B`x'=(c[`y',1]) C`x'=(c[`y',2]) D`x'=(c[`y',4]) E`x'=(c[`y',5]) F`x'=(c[`y',6]) using Figure3, modify
}
//Number of failures for DPP if mi_stroke==1
quietly {
local i=1
local x=`i'+16
mi xeq 1: stptime if indextype==1&mi_stroke==1, by(indextype) per(1000)
putexcel G`x'=(r(failures)) using Figure3, modify
unique patid if indextype==1&mi_stroke==1
putexcel H`x'=(r(sum)) using Figure3, modify
}
//Number of failures for SU if mi_stroke==1
quietly {
local i=1
local x=`i'+16
mi xeq 1: stptime if indextype==0&mi_stroke==1, by(indextype) per(1000)
putexcel I`x'=(r(failures)) using Figure3, modify
unique patid if indextype==0&mi_stroke==1
putexcel J`x'=(r(sum)) using Figure3, modify
}
//generate columns needed for final figures
qui{
forval l=2(2)16{
local val=`l'-2
putexcel L`l'=("`val'") using Figure3, modify
}
forval l=3(2)17{
local val=`l'-2
putexcel L`l'=("`val'") using Figure3, modify
}
forval k=2(2)16{
local subgroup=`k'/2
putexcel K`k'=("`subgroup'") using Figure3, modify
}
forval k=3(2)17{
local subgroup=(`k'-1)/2
putexcel K`k'=("`subgroup'") using Figure3, modify
}
putexcel K1=("subgrp") L1=("subgrp_val") using Figure3, modify
clear
import excel using Figure3, cellrange(B1:L17) firstrow
destring subgrp_val, generate(Subgroup)
destring subgrp, generate(subgroup)
drop subgrp_val
drop subgrp
save Figure3, replace
//Generate Forest Plots
use Figure3, clear
//Label variables for subgroup graphs
label define subgroups 1 "{bf}Age" 2 "{bf}Gender" 3 "{bf}Metformin {bf}monotherapy" 4 "{bf}A1c" 5 "{bf}BMI" 6 "{bf}Renal {bf}insufficiency" 7 "{bf}History {bf}of {bf}HF" 8 "{bf}History {bf}of {bf}MI/Stroke"
label values subgroup subgroups
label define subvals 1 "Less than 65" 0 "65 or older" 3 "Female" 2 "Male" 5 "Less than 2 years" 4 "2 or more years" 7 "Less than 8" 6 "8 or greater" 9 "Less than 30" 8 "30 or greater" 11 "EGFR 60 or greater" 10 "EGFR less than 60" 13 "Negative history" 12 "Positive history" 15 "Negative history" 14 "Positive history"
label values Subgroup subvals
label var nDPP "{bf}DPP4I {bf}Failures {bf}(n)"
label var NDPP "{bf}DPP4I {bf}Total {bf}(N)"
label var nSU "{bf}SU {bf}Failures {bf}(n)"
label var NSU "{bf}SU {bf}Total {bf}(N)"
label var Subgroup "{bf}Subgroups"
metan aHR LL UL, force by(subgroup) nowt nobox nooverall null(1) xlabel(0.2, 1.8) lcols(Subgroup) effect("Hazard Ratio") saving(ACM_subgrp, asis replace)
}
metan aHR LL UL, force by(subgroup) nowt nobox nooverall nosubgroup null(1) scheme(s1mono) astext(65) xlabel(0, .5, 1.5, 2, 2.5) lcols(Subgroup) rcols(nDPP NDPP nSU NSU) effect("Hazard Ratio") saving(Figure3, asis replace)
graph export Figure3.png, replace

//FIGURE 4: ACM SUBGROUP ANALYSIS
////////////////////////////////////////////////////////////////////////AGE/////////////////////////////////////////////////////////////////
use stat_mace_mi, clear
//mvmodel_mi includes: demoMI, comorb2 meds2, clinMI (only differences between mvmodel and mvmodel_mi are the imputed variables and removal of *_post for collinearity)
local mvmodel_mi = "age_indexdate gender ib2.smokestatus_clone ib1.hba1c_cats_i2_clone i.ckd_amdrd bmi_i sbp i.physician_vis2 i.prx_ccivalue_g_i2 cvd_i dmdur metoverlap i.unique_cov_drugs statin_i calchan_i betablock_i anticoag_oral_i antiplat_i ace_arb_renin_i diuretics_all_i"
local matrownames_mi "SU DPP4I GLP1RA INS TZD OTH Age Male Unknown Current Non_Smoker Former HbA1c_<7 HbA1c_7_8 HbA1c_8_9 HbA1c_9_10 HbA1c_>10 HbA1c_unknown eGFR_90+ eGFR_60_89 eGFR_30_59 eGFR_15_29 eGFR_<15 eGFR_unknown BMI SBP PhysVis_12 PhysVis_24 PhysVis_24plus CCI=1 CCI=2 CCI=3+ CVD diabetes_duration Metformin_overlap No_unique_drugs_0_5 No_unique_drugs_6_10 No_unique_drugs_11_15 No_unique_drugs_16_20 No_unique_drugs_>20 Statin CCB BB Anticoag Antiplat RAS Diuretics"
//estimate for age>=65==0
mi estimate, hr post: stcox indextype_2##ib1.age_65 indextype_3 indextype_4 indextype_5 indextype_6 indextype_7 `mvmodel_mi', cformat(%6.2f) pformat(%5.3f) sformat(%6.2f) nolog
qui{
matrix b=r(table)
matrix c=b'
matrix list c
local i=1
local y=`i'+1
local x=`i'+1
local rowname:word `y' of `matrownames_mi'
putexcel A1=("Subgroup") B1=("aHR") C1=("SE") D1=("p-value") E1=("LL") F1=("UL") A`x'=("Age>65==0") B`x'=(c[`y',1]) C`x'=(c[`y',2]) D`x'=(c[`y',4]) E`x'=(c[`y',5]) F`x'=(c[`y',6]) using Figure4, modify
}
//Number of failures for DPP if age>=65==0
quietly {
putexcel G1=("nDPP") H1=("NDPP") using Figure4, modify
local i=1
local x=`i'+1
mi xeq 1: stptime if indextype==1&age_65==0, by(indextype) per(1000)
putexcel G`x'=(r(failures)) using Figure4, modify
unique patid if indextype==1&age_65==0
putexcel H`x'=(r(sum)) using Figure4, modify
}
//Number of failures for SU if age>=65==0
quietly {
putexcel I1=("nSU") J1=("NSU") using Figure4, modify
local i=1
local x=`i'+1
mi xeq 1: stptime if indextype==0&age_65==0, by(indextype) per(1000)
putexcel I`x'=(r(failures)) using Figure4, modify
unique patid if indextype==0&age_65==0
putexcel J`x'=(r(sum)) using Figure4, modify
}
//estimate for age>=65==1
mi estimate, hr post: stcox indextype_2##i.age_65 indextype_3 indextype_4 indextype_5 indextype_6 indextype_7 `mvmodel_mi', cformat(%6.2f) pformat(%5.3f) sformat(%6.2f) nolog
qui{
matrix b=r(table)
matrix c=b'
matrix list c
local i=1
local y=`i'+1
local x=`i'+2
local rowname:word `y' of `matrownames_mi'
putexcel A`x'=("Age>65==1") B`x'=(c[`y',1]) C`x'=(c[`y',2]) D`x'=(c[`y',4]) E`x'=(c[`y',5]) F`x'=(c[`y',6]) using Figure4, modify
}

//Number of failures for DPP if age>=65==1
quietly {
local i=1
local x=`i'+2
mi xeq 1: stptime if indextype==1&age_65==1, by(indextype) per(1000)
putexcel G`x'=(r(failures)) using Figure4, modify
unique patid if indextype==1&age_65==1
putexcel H`x'=(r(sum)) using Figure4, modify
}
//Number of failures for SU if age>=65==1
quietly {
local i=1
local x=`i'+2
mi xeq 1: stptime if indextype==0&age_65==1, by(indextype) per(1000)
putexcel I`x'=(r(failures)) using Figure4, modify
unique patid if indextype==0&age_65==1
putexcel J`x'=(r(sum)) using Figure4, modify
}

////////////////////////////////////////////////////////////////////////GENDER/////////////////////////////////////////////////////////////
//estimate for gender==0
mi estimate, hr post: stcox indextype_2##ib1.gender indextype_3 indextype_4 indextype_5 indextype_6 indextype_7 `mvmodel_mi', cformat(%6.2f) pformat(%5.3f) sformat(%6.2f) nolog
qui{
matrix b=r(table)
matrix c=b'
matrix list c
local i=1
local y=`i'+1
local x=`i'+3
putexcel A`x'=("Gender==0") B`x'=(c[`y',1]) C`x'=(c[`y',2]) D`x'=(c[`y',4]) E`x'=(c[`y',5]) F`x'=(c[`y',6]) using Figure4, modify
}
//Number of failures for DPP if gender==0
quietly {
local i=1
local x=`i'+3
mi xeq 1: stptime if indextype==1&gender==0, by(indextype) per(1000)
putexcel G`x'=(r(failures)) using Figure4, modify
unique patid if indextype==1&gender==0
putexcel H`x'=(r(sum)) using Figure4, modify
}
//Number of failures for SU if gender==0
quietly {
local i=1
local x=`i'+3
mi xeq 1: stptime if indextype==0&gender==0, by(indextype) per(1000)
putexcel I`x'=(r(failures)) using Figure4, modify
unique patid if indextype==0&gender==0
putexcel J`x'=(r(sum)) using Figure4, modify
}

//estimate for gender==1
mi estimate, hr post: stcox indextype_2##i.gender indextype_3 indextype_4 indextype_5 indextype_6 indextype_7 `mvmodel_mi', cformat(%6.2f) pformat(%5.3f) sformat(%6.2f) nolog
qui{
matrix b=r(table)
matrix c=b'
matrix list c
local i=1
local y=`i'+1
local x=`i'+4
local rowname:word `y' of `matrownames_mi'
putexcel A`x'=("Gender==1") B`x'=(c[`y',1]) C`x'=(c[`y',2]) D`x'=(c[`y',4]) E`x'=(c[`y',5]) F`x'=(c[`y',6]) using Figure4, modify
}
//Number of failures for DPP if gender==1
quietly {
local i=1
local x=`i'+4
mi xeq 1: stptime if indextype==1&gender==1, by(indextype) per(1000)
putexcel G`x'=(r(failures)) using Figure4, modify
unique patid if indextype==1&gender==1
putexcel H`x'=(r(sum)) using Figure4, modify
}
//Number of failures for SU if gender==1
quietly {
local i=1
local x=`i'+4
mi xeq 1: stptime if indextype==0&gender==1, by(indextype) per(1000)
putexcel I`x'=(r(failures)) using Figure4, modify
unique patid if indextype==0&gender==1
putexcel J`x'=(r(sum)) using Figure4, modify
}
////////////////////////////////////////////////////////////////////////DMDUR/////////////////////////////////////////////////////////////
//estimate for dmdur_2==0
mi estimate, hr post: stcox indextype_2##ib1.dmdur_2 indextype_3 indextype_4 indextype_5 indextype_6 indextype_7 `mvmodel_mi', cformat(%6.2f) pformat(%5.3f) sformat(%6.2f) nolog
qui{
matrix b=r(table)
matrix c=b'
matrix list c
local i=1
local y=`i'+1
local x=`i'+5
putexcel A`x'=("DMdur2==0") B`x'=(c[`y',1]) C`x'=(c[`y',2]) D`x'=(c[`y',4]) E`x'=(c[`y',5]) F`x'=(c[`y',6]) using Figure4, modify
}
//Number of failures for DPP if dmdur_2==0
quietly {
local i=1
local x=`i'+5
mi xeq 1: stptime if indextype==1&dmdur_2==0, by(indextype) per(1000)
putexcel G`x'=(r(failures)) using Figure4, modify
unique patid if indextype==1&dmdur_2==0
putexcel H`x'=(r(sum)) using Figure4, modify
}
//Number of failures for SU if dmdur_2==0
quietly {
local i=1
local x=`i'+5
mi xeq 1: stptime if indextype==0&dmdur_2==0, by(indextype) per(1000)
putexcel I`x'=(r(failures)) using Figure4, modify
unique patid if indextype==0&dmdur_2==0
putexcel J`x'=(r(sum)) using Figure4, modify
}

//estimate for dmdur_2==1
mi estimate, hr post: stcox indextype_2##i.dmdur_2 indextype_3 indextype_4 indextype_5 indextype_6 indextype_7 `mvmodel_mi', cformat(%6.2f) pformat(%5.3f) sformat(%6.2f) nolog
qui{
matrix b=r(table)
matrix c=b'
matrix list c
local i=1
local y=`i'+1
local x=`i'+6
putexcel A`x'=("DMdur2==1") B`x'=(c[`y',1]) C`x'=(c[`y',2]) D`x'=(c[`y',4]) E`x'=(c[`y',5]) F`x'=(c[`y',6]) using Figure4, modify
}
//Number of failures for DPP if dmdur_2==1
quietly {
local i=1
local x=`i'+6
mi xeq 1: stptime if indextype==1&dmdur_2==1, by(indextype) per(1000)
putexcel G`x'=(r(failures)) using Figure4, modify
unique patid if indextype==1&dmdur_2==1
putexcel H`x'=(r(sum)) using Figure4, modify
}
//Number of failures for SU if dmdur_2==1
quietly {
local i=1
local x=`i'+6
mi xeq 1: stptime if indextype==0&dmdur_2==1, by(indextype) per(1000)
putexcel I`x'=(r(failures)) using Figure4, modify
unique patid if indextype==0&dmdur_2==1
putexcel J`x'=(r(sum)) using Figure4, modify
}
////////////////////////////////////////////////////////////////////////HbA1C///////////////////////////////////////////////////////////////
//estimate for hba1c_8==0
mi estimate, hr post: stcox indextype_2##ib1.hba1c_8 indextype_3 indextype_4 indextype_5 indextype_6 indextype_7 `mvmodel_mi', cformat(%6.2f) pformat(%5.3f) sformat(%6.2f) nolog
qui{
matrix b=r(table)
matrix c=b'
matrix list c
local i=1
local y=`i'+1
local x=`i'+7
putexcel A`x'=("A1C8==0") B`x'=(c[`y',1]) C`x'=(c[`y',2]) D`x'=(c[`y',4]) E`x'=(c[`y',5]) F`x'=(c[`y',6]) using Figure4, modify
}
//Number of failures for DPP if hba1c_8==0
quietly {
local i=1
local x=`i'+7
mi xeq 1: stptime if indextype==1&hba1c_8==0, by(indextype) per(1000)
putexcel G`x'=(r(failures)) using Figure4, modify
unique patid if indextype==1&hba1c_8==0
putexcel H`x'=(r(sum)) using Figure4, modify
}
//Number of failures for SU if hba1c_8==0
quietly {
local i=1
local x=`i'+7
mi xeq 1: stptime if indextype==0&hba1c_8==0, by(indextype) per(1000)
putexcel I`x'=(r(failures)) using Figure4, modify
unique patid if indextype==0&hba1c_8==0
putexcel J`x'=(r(sum)) using Figure4, modify
}

//estimate for hba1c_8==1
mi estimate, hr post: stcox indextype_2##i.hba1c_8 indextype_3 indextype_4 indextype_5 indextype_6 indextype_7 `mvmodel_mi', cformat(%6.2f) pformat(%5.3f) sformat(%6.2f) nolog
qui{
matrix b=r(table)
matrix c=b'
matrix list c
local i=1
local y=`i'+1
local x=`i'+8
putexcel A`x'=("A1C8==1") B`x'=(c[`y',1]) C`x'=(c[`y',2]) D`x'=(c[`y',4]) E`x'=(c[`y',5]) F`x'=(c[`y',6]) using Figure4, modify
}
//Number of failures for DPP if hba1c_8==1
quietly {
local i=1
local x=`i'+8
mi xeq 1: stptime if indextype==1&hba1c_8==1, by(indextype) per(1000)
putexcel G`x'=(r(failures)) using Figure4, modify
unique patid if indextype==1&hba1c_8==1
putexcel H`x'=(r(sum)) using Figure4, modify
}
//Number of failures for SU if hba1c_8==1
quietly {
local i=1
local x=`i'+8
mi xeq 1: stptime if indextype==0&hba1c_8==1, by(indextype) per(1000)
putexcel I`x'=(r(failures)) using Figure4, modify
unique patid if indextype==0&hba1c_8==1
putexcel J`x'=(r(sum)) using Figure4, modify
}
////////////////////////////////////////////////////////////////////////BMI/////////////////////////////////////////////////////////////////
//estimate for bmi_30==0
mi estimate, hr post: stcox indextype_2##ib1.bmi_30 indextype_3 indextype_4 indextype_5 indextype_6 indextype_7 `mvmodel_mi', cformat(%6.2f) pformat(%5.3f) sformat(%6.2f) nolog
qui{
matrix b=r(table)
matrix c=b'
matrix list c
local i=1
local y=`i'+1
local x=`i'+9
putexcel A`x'=("BMI30==0") B`x'=(c[`y',1]) C`x'=(c[`y',2]) D`x'=(c[`y',4]) E`x'=(c[`y',5]) F`x'=(c[`y',6]) using Figure4, modify
}
//Number of failures for DPP if bmi_30==0
quietly {
local i=1
local x=`i'+9
mi xeq 1: stptime if indextype==1&bmi_30==0, by(indextype) per(1000)
putexcel G`x'=(r(failures)) using Figure4, modify
unique patid if indextype==1&bmi_30==0
putexcel H`x'=(r(sum)) using Figure4, modify
}
//Number of failures for SU if bmi_30==0
quietly {
local i=1
local x=`i'+9
mi xeq 1: stptime if indextype==0&bmi_30==0, by(indextype) per(1000)
putexcel I`x'=(r(failures)) using Figure4, modify
unique patid if indextype==0&bmi_30==0
putexcel J`x'=(r(sum)) using Figure4, modify
}

//estimate for bmi_30==1
mi estimate, hr post: stcox indextype_2##i.bmi_30 indextype_3 indextype_4 indextype_5 indextype_6 indextype_7 `mvmodel_mi', cformat(%6.2f) pformat(%5.3f) sformat(%6.2f) nolog
qui{
matrix b=r(table)
matrix c=b'
matrix list c
local i=1
local y=`i'+1
local x=`i'+10
putexcel A`x'=("BMI30==1") B`x'=(c[`y',1]) C`x'=(c[`y',2]) D`x'=(c[`y',4]) E`x'=(c[`y',5]) F`x'=(c[`y',6]) using Figure4, modify
}
//Number of failures for DPP if bmi_30==1
quietly {
local i=1
local x=`i'+10
mi xeq 1: stptime if indextype==1&bmi_30==1, by(indextype) per(1000)
putexcel G`x'=(r(failures)) using Figure4, modify
unique patid if indextype==1&bmi_30==1
putexcel H`x'=(r(sum)) using Figure4, modify
}
//Number of failures for SU if bmi_30==1
quietly {
local i=1
local x=`i'+10
mi xeq 1: stptime if indextype==0&bmi_30==1, by(indextype) per(1000)
putexcel I`x'=(r(failures)) using Figure4, modify
unique patid if indextype==0&bmi_30==1
putexcel J`x'=(r(sum)) using Figure4, modify
}
////////////////////////////////////////////////////////////////////////CKD/////////////////////////////////////////////////////////////////
//estimate for ckd_60==0
mi estimate, hr post: stcox indextype_2##ib1.ckd_60 indextype_3 indextype_4 indextype_5 indextype_6 indextype_7 `mvmodel_mi', cformat(%6.2f) pformat(%5.3f) sformat(%6.2f) nolog
qui{
matrix b=r(table)
matrix c=b'
matrix list c
local i=1
local y=`i'+1
local x=`i'+11
putexcel A`x'=("CKD60==0") B`x'=(c[`y',1]) C`x'=(c[`y',2]) D`x'=(c[`y',4]) E`x'=(c[`y',5]) F`x'=(c[`y',6]) using Figure4, modify
}
//Number of failures for DPP if ckd_60==0
quietly {
local i=1
local x=`i'+11
mi xeq 1: stptime if indextype==1&ckd_60==0, by(indextype) per(1000)
putexcel G`x'=(r(failures)) using Figure4, modify
unique patid if indextype==1&ckd_60==0
putexcel H`x'=(r(sum)) using Figure4, modify
}
//Number of failures for SU if ckd_60==0
quietly {
local i=1
local x=`i'+11
mi xeq 1: stptime if indextype==0&ckd_60==0, by(indextype) per(1000)
putexcel I`x'=(r(failures)) using Figure4, modify
unique patid if indextype==0&ckd_60==0
putexcel J`x'=(r(sum)) using Figure4, modify
}

//estimate for ckd_60==1
mi estimate, hr post: stcox indextype_2##i.ckd_60 indextype_3 indextype_4 indextype_5 indextype_6 indextype_7 `mvmodel_mi', cformat(%6.2f) pformat(%5.3f) sformat(%6.2f) nolog
qui{
matrix b=r(table)
matrix c=b'
matrix list c
local i=1
local y=`i'+1
local x=`i'+12
putexcel A`x'=("CKD60==1") B`x'=(c[`y',1]) C`x'=(c[`y',2]) D`x'=(c[`y',4]) E`x'=(c[`y',5]) F`x'=(c[`y',6]) using Figure4, modify
}
//Number of failures for DPP if ckd_60==1
quietly {
local i=1
local x=`i'+12
mi xeq 1: stptime if indextype==1&ckd_60==1, by(indextype) per(1000)
putexcel G`x'=(r(failures)) using Figure4, modify
unique patid if indextype==1&ckd_60==1
putexcel H`x'=(r(sum)) using Figure4, modify
}
//Number of failures for SU if ckd_60==1
quietly {
local i=1
local x=`i'+12
mi xeq 1: stptime if indextype==0&ckd_60==1, by(indextype) per(1000)
putexcel I`x'=(r(failures)) using Figure4, modify
unique patid if indextype==0&ckd_60==1
putexcel J`x'=(r(sum)) using Figure4, modify
}
////////////////////////////////////////////////////////////////////////HF/////////////////////////////////////////////////////////////////
//estimate for hf_i==0
mi estimate, hr post: stcox indextype_2##ib1.hf_i indextype_3 indextype_4 indextype_5 indextype_6 indextype_7 `mvmodel_mi', cformat(%6.2f) pformat(%5.3f) sformat(%6.2f) nolog
qui{
matrix b=r(table)
matrix c=b'
matrix list c
local i=1
local y=`i'+1
local x=`i'+13
putexcel A`x'=("HF==0") B`x'=(c[`y',1]) C`x'=(c[`y',2]) D`x'=(c[`y',4]) E`x'=(c[`y',5]) F`x'=(c[`y',6]) using Figure4, modify
}
//Number of failures for DPP if hf_i==0
quietly {
local i=1
local x=`i'+13
mi xeq 1: stptime if indextype==1&hf_i==0, by(indextype) per(1000)
putexcel G`x'=(r(failures)) using Figure4, modify
unique patid if indextype==1&hf_i==0
putexcel H`x'=(r(sum)) using Figure4, modify
}
//Number of failures for SU if hf_i==0
quietly {
local i=1
local x=`i'+13
mi xeq 1: stptime if indextype==0&hf_i==0, by(indextype) per(1000)
putexcel I`x'=(r(failures)) using Figure4, modify
unique patid if indextype==0&hf_i==0
putexcel J`x'=(r(sum)) using Figure4, modify
}

//estimate for hf_i==1
mi estimate, hr post: stcox indextype_2##i.hf_i indextype_3 indextype_4 indextype_5 indextype_6 indextype_7 `mvmodel_mi', cformat(%6.2f) pformat(%5.3f) sformat(%6.2f) nolog
qui{
matrix b=r(table)
matrix c=b'
matrix list c
local i=1
local y=`i'+1
local x=`i'+14
putexcel A`x'=("HF==1") B`x'=(c[`y',1]) C`x'=(c[`y',2]) D`x'=(c[`y',4]) E`x'=(c[`y',5]) F`x'=(c[`y',6]) using Figure4, modify
}
//Number of failures for DPP if hf_i==1
quietly {
local i=1
local x=`i'+14
mi xeq 1: stptime if indextype==1&hf_i==1, by(indextype) per(1000)
putexcel G`x'=(r(failures)) using Figure4, modify
unique patid if indextype==1&hf_i==1
putexcel H`x'=(r(sum)) using Figure4, modify
}
//Number of failures for SU if hf_i==1
quietly {
local i=1
local x=`i'+14
mi xeq 1: stptime if indextype==0&hf_i==1, by(indextype) per(1000)
putexcel I`x'=(r(failures)) using Figure4, modify
unique patid if indextype==0&hf_i==1
putexcel J`x'=(r(sum)) using Figure4, modify
}
////////////////////////////////////////////////////////////////////////MISTROKE////////////////////////////////////////////////////////////
//estimate for mi_stroke==0
mi estimate, hr post: stcox indextype_2##ib1.mi_stroke indextype_3 indextype_4 indextype_5 indextype_6 indextype_7 `mvmodel_mi', cformat(%6.2f) pformat(%5.3f) sformat(%6.2f) nolog
qui{
matrix b=r(table)
matrix c=b'
matrix list c
local i=1
local y=`i'+1
local x=`i'+15
putexcel A`x'=("MISTROKE==0") B`x'=(c[`y',1]) C`x'=(c[`y',2]) D`x'=(c[`y',4]) E`x'=(c[`y',5]) F`x'=(c[`y',6]) using Figure4, modify
}
//Number of failures for DPP if mi_stroke==0
quietly {
local i=1
local x=`i'+15
mi xeq 1: stptime if indextype==1&mi_stroke==0, by(indextype) per(1000)
putexcel G`x'=(r(failures)) using Figure4, modify
unique patid if indextype==1&mi_stroke==0
putexcel H`x'=(r(sum)) using Figure4, modify
}
//Number of failures for SU if mi_stroke==0
quietly {
local i=1
local x=`i'+15
mi xeq 1: stptime if indextype==0&mi_stroke==0, by(indextype) per(1000)
putexcel I`x'=(r(failures)) using Figure4, modify
unique patid if indextype==0&mi_stroke==0
putexcel J`x'=(r(sum)) using Figure4, modify
}

//estimate for mi_stroke==1
mi estimate, hr post: stcox indextype_2##i.mi_stroke indextype_3 indextype_4 indextype_5 indextype_6 indextype_7 `mvmodel_mi', cformat(%6.2f) pformat(%5.3f) sformat(%6.2f) nolog
qui{
matrix b=r(table)
matrix c=b'
matrix list c
local i=1
local y=`i'+1
local x=`i'+16
putexcel A`x'=("MISTROKE==1") B`x'=(c[`y',1]) C`x'=(c[`y',2]) D`x'=(c[`y',4]) E`x'=(c[`y',5]) F`x'=(c[`y',6]) using Figure4, modify
}
//Number of failures for DPP if mi_stroke==1
quietly {
local i=1
local x=`i'+16
mi xeq 1: stptime if indextype==1&mi_stroke==1, by(indextype) per(1000)
putexcel G`x'=(r(failures)) using Figure4, modify
unique patid if indextype==1&mi_stroke==1
putexcel H`x'=(r(sum)) using Figure4, modify
}
//Number of failures for SU if mi_stroke==1
quietly {
local i=1
local x=`i'+16
mi xeq 1: stptime if indextype==0&mi_stroke==1, by(indextype) per(1000)
putexcel I`x'=(r(failures)) using Figure4, modify
unique patid if indextype==0&mi_stroke==1
putexcel J`x'=(r(sum)) using Figure4, modify
}
//generate columns needed for final figures
qui{
forval l=2(2)16{
local val=`l'-2
putexcel L`l'=("`val'") using Figure4, modify
}
forval l=3(2)17{
local val=`l'-2
putexcel L`l'=("`val'") using Figure4, modify
}
forval k=2(2)16{
local subgroup=`k'/2
putexcel K`k'=("`subgroup'") using Figure4, modify
}
forval k=3(2)17{
local subgroup=(`k'-1)/2
putexcel K`k'=("`subgroup'") using Figure4, modify
}
putexcel K1=("subgrp") L1=("subgrp_val") using Figure4, modify
clear
import excel using Figure4, cellrange(B1:L17) firstrow
destring subgrp_val, generate(Subgroup)
destring subgrp, generate(subgroup)
drop subgrp_val
drop subgrp
save Figure4, replace
//Generate Forest Plots
use Figure4, clear
//Label variables for subgroup graphs
label define subgroups 1 "{bf}Age" 2 "{bf}Gender" 3 "{bf}Metformin {bf}monotherapy" 4 "{bf}A1c" 5 "{bf}BMI" 6 "{bf}Renal {bf}insufficiency" 7 "{bf}History {bf}of {bf}HF" 8 "{bf}History {bf}of {bf}MI/Stroke"
label values subgroup subgroups
label define subvals 1 "Less than 65" 0 "65 or older" 3 "Female" 2 "Male" 5 "Less than 2 years" 4 "2 or more years" 7 "Less than 8" 6 "8 or greater" 9 "Less than 30" 8 "30 or greater" 11 "EGFR 60 or greater" 10 "EGFR less than 60" 13 "Negative history" 12 "Positive history" 15 "Negative history" 14 "Positive history"
label values Subgroup subvals
label var nDPP "{bf}DPP4I {bf}Failures {bf}(n)"
label var NDPP "{bf}DPP4I {bf}Total {bf}(N)"
label var nSU "{bf}SU {bf}Failures {bf}(n)"
label var NSU "{bf}SU {bf}Total {bf}(N)"
label var Subgroup "{bf}Subgroups"
metan aHR LL UL, force by(subgroup) nowt nobox nooverall null(1) xlabel(0.2, 1.8) lcols(Subgroup) effect("Hazard Ratio")
}
metan aHR LL UL, force by(subgroup) nowt nobox nooverall nosubgroup null(1) scheme(s1mono) astext(65) xlabel(0, .5, 1.5, 2) lcols(Subgroup) rcols(nDPP NDPP nSU NSU) effect("Hazard Ratio") saving(Figure4, asis replace)
graph export Figure4.png, replace

//SUPPLEMENT FIGURE S9: OVERALL MAIN FINDINGS BY AGENT
//LOOP TO GENERATE OUTCOMES BY AGENT
qui{
local agents = "DPP4I GLP1RA INS TZD OTH"
forval i=1/5{
local agent:word `i' of `agents'
local y=`i'+1
//ACM
use Stat_acm_mi, clear
mi estimate, hr: stcox i.indextype `mvmodel_mi'
matrix b=r(table)
matrix c=b'
matrix list c
putexcel A1=("Outcome") B1=("HR") C1=("SE") D1=("p-value") E1=("LL") F1=("UL") A2=("ACM") B2=(c[`y',1]) C2=(c[`y',2]) D2=(c[`y',4]) E2=(c[`y',5]) F2=(c[`y',6]) using FigureS9, sheet("`agent'") modify

//MACE
use Stat_mace_mi, clear
mi estimate, hr: stcox i.indextype `mvmodel_mi'
matrix b=r(table)
matrix c=b'
matrix list c
putexcel A3=("MACE") B3=(c[`y',1]) C3=(c[`y',2]) D3=(c[`y',4]) E3=(c[`y',5]) F3=(c[`y',6]) using FigureS9, sheet("`agent'") modify

//CV Death
use Stat_cvdeath_mi, clear
mi estimate, hr: stcox i.indextype `mvmodel_mi'
matrix b=r(table)
matrix c=b'
matrix list c
putexcel A4=("CVDEATH") B4=(c[`y',1]) C4=(c[`y',2]) D4=(c[`y',4]) E4=(c[`y',5]) F4=(c[`y',6]) using FigureS9, sheet("`agent'") modify

//Angina
use Stat_angina_mi, clear
mi estimate, hr: stcox i.indextype `mvmodel_mi'
matrix b=r(table)
matrix c=b'
matrix list c
putexcel A5=("Angina") B5=(c[`y',1]) C5=(c[`y',2]) D5=(c[`y',4]) E5=(c[`y',5]) F5=(c[`y',6]) using FigureS9, sheet("`agent'") modify

//Arrhythmia
use Stat_arrhyth_mi, clear
mi estimate, hr: stcox i.indextype `mvmodel_mi'
matrix b=r(table)
matrix c=b'
matrix list c
putexcel A6=("Arrhythmia") B6=(c[`y',1]) C6=(c[`y',2]) D6=(c[`y',4]) E6=(c[`y',5]) F6=(c[`y',6]) using FigureS9, sheet("`agent'") modify

//HF
use Stat_hf_mi, clear
mi estimate, hr: stcox i.indextype `mvmodel_mi'
matrix b=r(table)
matrix c=b'
matrix list c
putexcel A7=("HF") B7=(c[`y',1]) C7=(c[`y',2]) D7=(c[`y',4]) E7=(c[`y',5]) F7=(c[`y',6]) using FigureS9, sheet("`agent'") modify

//MI
use Stat_myoinf_mi, clear
mi estimate, hr: stcox i.indextype `mvmodel_mi'
matrix b=r(table)
matrix c=b'
matrix list c
putexcel A8=("MI") B8=(c[`y',1]) C8=(c[`y',2]) D8=(c[`y',4]) E8=(c[`y',5]) F8=(c[`y',6]) using FigureS9, sheet("`agent'") modify

//Stroke
use Stat_stroke_mi, clear
mi estimate, hr: stcox i.indextype `mvmodel_mi'
matrix b=r(table)
matrix c=b'
matrix list c
putexcel A9=("Stroke") B9=(c[`y',1]) C9=(c[`y',2]) D9=(c[`y',4]) E9=(c[`y',5]) F9=(c[`y',6]) using FigureS9, sheet("`agent'") modify

//Revasc
use Stat_revasc_mi, clear
mi estimate, hr: stcox i.indextype `mvmodel_mi'
matrix b=r(table)
matrix c=b'
matrix list c
putexcel A10=("Revasc") B10=(c[`y',1]) C10=(c[`y',2]) D10=(c[`y',4]) E10=(c[`y',5]) F10=(c[`y',6]) using FigureS9, sheet("`agent'") modify
}
}
//generate the .dat file needed to create FigureS9
quietly{
clear
import excel using FigureS9, sheet("DPP4I") cellrange(A1:F10) firstrow
export excel using FigureS9.xlsx, sheet("Combined") cell(A1) firstrow(variables) sheetmod
clear
import excel using FigureS9, sheet("GLP1RA") cellrange(A1:F10) firstrow
export excel using FigureS9.xlsx, sheet("Combined") cell(A11) sheetmod
clear
import excel using FigureS9, sheet("INS") cellrange(A1:F10) firstrow
export excel using FigureS9.xlsx, sheet("Combined") cell(A21) sheetmod
clear
import excel using FigureS9, sheet("TZD") cellrange(A1:F10) firstrow
export excel using FigureS9.xlsx, sheet("Combined") cell(A31) sheetmod
clear
import excel using FigureS9, sheet("OTH") cellrange(A1:F10) firstrow
export excel using FigureS9.xlsx, sheet("Combined") cell(A41) sheetmod
clear 
import excel using FigureS9, sheet("Combined") cellrange(A1:F49) firstrow
drop if HR==.
gen counts=_n
gen agent=.
replace agent=1 if counts<=9
replace agent=2 if counts>=10&counts<=18
replace agent=3 if counts>=19&counts<=27
replace agent=4 if counts>=28&counts<=36
replace agent=5 if counts>=37&counts<=45
drop counts
local outlist "ACM MACE CVDEATH Angina Arrhythmia HF MI Stroke Revasc"
gen outcome=.
forval i=1/9 {
local outnum:word `i' of `outlist'
replace outcome=`i' if Outcome=="`outnum'"
}
drop Outcome
rename outcome Outcome
capture label drop agents
capture label drop outcomes
label define agents 1 "{bf}DPP4i" 2 "{bf}GLP-1RA" 3 "{bf}Insulin" 4 "{bf}Thiazolidinedione" 5 "{bf}Other {bf}antidiabetic"
label define outcomes 1 "ACM" 2 "MACE"  3 "CV Death" 4 "Angina" 5 "Arrhythmia" 6 "Heart Failure" 7 "Myocardial Infarction"  8 "Stroke" 9 "Urgent Revascularization"
label values agent agents
label values Outcome outcomes
label var Outcome "{bf}Outcome"
label var agent "{bf}Agent"
drop if SE==.
metan HR LL UL, force by(agent) nowt nobox nooverall null(1) xlabel(0, 0.25, 0.5, 0.75) astext(70) scheme(s1mono) effect("Hazard Ratio")
}
//generate FigureS9
metan HR LL UL, force by(agent) nowt nobox nooverall nosubgroup null(1) xlabel(0, 2, 3, 4, 5) astext(25) scheme(s1mono) lcols(Outcome) rcols(p) effect("{bf}Hazard {bf}Ratio") saving(FigureS9, asis replace)
graph export FigureS9.png, replace

//SUPPLEMENT FIGURE S10: OVERALL MAIN FINDINGS BY OUTCOME
//SUBSECTIONS TO GENERATE OUTCOMES ACROSS ALL AGENTS
//ACM
use Stat_acm_mi, clear
mi estimate, hr: stcox i.indextype `mvmodel_mi'
qui{
matrix b=r(table)
matrix c=b'
matrix list c
forval i=1/5{
local x=`i'+1
local rowname:word `x' of `matrownames_mi'
putexcel A1=("Agent") B1=("aHR") C1=("SE") D1=("p-value") E1=("LL") F1=("UL") A`x'=("`rowname'") B`x'=(c[`x',1]) C`x'=(c[`x',2]) D`x'=(c[`x',4]) E`x'=(c[`x',5]) F`x'=(c[`x',6]) using FigureS10, sheet("ACM") modify
}
}
//MACE
use Stat_mace_mi, clear
mi estimate, hr: stcox i.indextype `mvmodel_mi'
qui{
matrix b=r(table)
matrix c=b'
matrix list c
forval i=1/5{
local x=`i'+1
local rowname:word `x' of `matrownames_mi'
putexcel A1=("Agent") B1=("aHR") C1=("SE") D1=("p-value") E1=("LL") F1=("UL") A`x'=("`rowname'") B`x'=(c[`x',1]) C`x'=(c[`x',2]) D`x'=(c[`x',4]) E`x'=(c[`x',5]) F`x'=(c[`x',6]) using FigureS10, sheet("MACE") modify
}
}
//CV Death
use Stat_cvdeath_mi, clear
mi estimate, hr: stcox i.indextype `mvmodel_mi'
qui{
matrix b=r(table)
matrix c=b'
matrix list c
forval i=1/5{
local x=`i'+1
local rowname:word `x' of `matrownames_mi'
putexcel A1=("Agent") B1=("aHR") C1=("SE") D1=("p-value") E1=("LL") F1=("UL") A`x'=("`rowname'") B`x'=(c[`x',1]) C`x'=(c[`x',2]) D`x'=(c[`x',4]) E`x'=(c[`x',5]) F`x'=(c[`x',6]) using FigureS10, sheet("CVDEATH") modify
}
}
//Angina
use Stat_angina_mi, clear
mi estimate, hr: stcox i.indextype `mvmodel_mi'
qui{
matrix b=r(table)
matrix c=b'
matrix list c
forval i=1/5{
local x=`i'+1
local rowname:word `x' of `matrownames_mi'
putexcel A1=("Agent") B1=("aHR") C1=("SE") D1=("p-value") E1=("LL") F1=("UL") A`x'=("`rowname'") B`x'=(c[`x',1]) C`x'=(c[`x',2]) D`x'=(c[`x',4]) E`x'=(c[`x',5]) F`x'=(c[`x',6]) using FigureS10, sheet("Angina") modify
}
}
//Arrhythmia
use Stat_arrhyth_mi, clear
mi estimate, hr: stcox i.indextype `mvmodel_mi'
qui{
matrix b=r(table)
matrix c=b'
matrix list c
forval i=1/5{
local x=`i'+1
local rowname:word `x' of `matrownames_mi'
putexcel A1=("Agent") B1=("aHR") C1=("SE") D1=("p-value") E1=("LL") F1=("UL") A`x'=("`rowname'") B`x'=(c[`x',1]) C`x'=(c[`x',2]) D`x'=(c[`x',4]) E`x'=(c[`x',5]) F`x'=(c[`x',6]) using FigureS10, sheet("Arrhyth") modify
}
}
//HF
use Stat_hf_mi, clear
mi estimate, hr: stcox i.indextype `mvmodel_mi'
qui{
matrix b=r(table)
matrix c=b'
matrix list c
forval i=1/5{
local x=`i'+1
local rowname:word `x' of `matrownames_mi'
putexcel A1=("Agent") B1=("aHR") C1=("SE") D1=("p-value") E1=("LL") F1=("UL") A`x'=("`rowname'") B`x'=(c[`x',1]) C`x'=(c[`x',2]) D`x'=(c[`x',4]) E`x'=(c[`x',5]) F`x'=(c[`x',6]) using FigureS10, sheet("HF") modify
}
}
//MI
use Stat_myoinf_mi, clear
mi estimate, hr: stcox i.indextype `mvmodel_mi'
qui{
matrix b=r(table)
matrix c=b'
matrix list c
forval i=1/5{
local x=`i'+1
local rowname:word `x' of `matrownames_mi'
putexcel A1=("Agent") B1=("aHR") C1=("SE") D1=("p-value") E1=("LL") F1=("UL") A`x'=("`rowname'") B`x'=(c[`x',1]) C`x'=(c[`x',2]) D`x'=(c[`x',4]) E`x'=(c[`x',5]) F`x'=(c[`x',6]) using FigureS10, sheet("MI") modify
}
}
//Stroke
use Stat_stroke_mi, clear
mi estimate, hr: stcox i.indextype `mvmodel_mi'
qui{
matrix b=r(table)
matrix c=b'
matrix list c
forval i=1/5{
local x=`i'+1
local rowname:word `x' of `matrownames_mi'
putexcel A1=("Agent") B1=("aHR") C1=("SE") D1=("p-value") E1=("LL") F1=("UL") A`x'=("`rowname'") B`x'=(c[`x',1]) C`x'=(c[`x',2]) D`x'=(c[`x',4]) E`x'=(c[`x',5]) F`x'=(c[`x',6]) using FigureS10, sheet("Stroke") modify
}
}
//Revasc
use Stat_revasc_mi, clear
mi estimate, hr: stcox i.indextype `mvmodel_mi'
qui{
matrix b=r(table)
matrix c=b'
matrix list c
forval i=1/5{
local x=`i'+1
local rowname:word `x' of `matrownames_mi'
putexcel A1=("Agent") B1=("aHR") C1=("SE") D1=("p-value") E1=("LL") F1=("UL") A`x'=("`rowname'") B`x'=(c[`x',1]) C`x'=(c[`x',2]) D`x'=(c[`x',4]) E`x'=(c[`x',5]) F`x'=(c[`x',6]) using FigureS10, sheet("Revasc") modify
}
}
//generate the .dat file needed to create FigureS10
quietly{
clear
import excel using FigureS9, sheet("Combined") cellrange(A1:F49) firstrow
drop if HR==.
gen counts=_n
gen agent=.
replace agent=1 if counts<=9
replace agent=2 if counts>=10&counts<=18
replace agent=3 if counts>=19&counts<=27
replace agent=4 if counts>=28&counts<=36
replace agent=5 if counts>=37&counts<=45
gen Outcomes=.
replace Outcomes=1 if Outcome=="ACM"
replace Outcomes=2 if Outcome=="MACE"
replace Outcomes=3 if Outcome=="CVDEATH"
replace Outcomes=4 if Outcome=="Angina"
replace Outcomes=5 if Outcome=="Arrhythmia"
replace Outcomes=6 if Outcome=="HF"
replace Outcomes=7 if Outcome=="MI"
replace Outcomes=8 if Outcome=="Stroke"
replace Outcomes=9 if Outcome=="Revasc"
drop Outcome
rename Outcomes Outcome
drop counts
capture label drop agents
capture label drop outcomes
label define agents 1 "DPP4I" 2 "GLP-1RA" 3 "INS" 4 "TZD" 5 "OTH"
label define outcomes 1 "{bf}ACM" 2 "{bf}MACE"  3 "{bf}CV {bf}Death" 4 "{bf}Angina" 5 "{bf}Arrhythmia" 6 "{bf}Heart {bf}Failure" 7 "{bf}Myocardial {bf}Infarction"  8 "{bf}Stroke" 9 "{bf}Urgent {bf}Revascularization"
label values agent agents
label values Outcome outcomes
label var Outcome "{bf}Outcome"
label var agent "{bf}Agent"
drop if SE==.
metan HR LL UL, force by(Outcome) nowt nobox nooverall null(1) xlabel(0, 0.25, 0.5, 0.75) astext(70) scheme(s1mono) effect("Hazard Ratio")
}
//generate FigureS10
metan HR LL UL, force by(Outcome) nowt nobox nooverall nosubgroup null(1) xlabel(0, 2, 3, 4, 5) astext(25) scheme(s1mono) lcols(agent) rcols(p) effect("{bf}Hazard {bf}Ratio") saving(FigureS10, asis replace)
graph export FigureS10.png, replace

