//  program:    Stat02_Primary_Outcomes.do
//  task:		Statistical analyses of Analytic_Dataset_Master.dta to compare primary outcomes between classes of antidiabetics
//				Identify cohort, extract outcomes by indextype.
//  project: 	Incretins--Comparative mortality and CV outcomes (CPRD)
//  author:     JM \ Mar2015  
//				

clear all
capture log close
set more off
log using Stat02L.smcl, replace
timer on 1

use Analytic_Dataset_Master

//Unify exclusion criteria into a binary indicator
gen exclude=1 if (gest_diab==1|pcos==1|preg==1|age_indexdate<=29|cohort_b==0|tx<=seconddate)
replace exclude=0 if exclude!=1
label var exclude "Bin ind for pcos, preg, gest_diab, or <30yo; excluded=1, not excluded=0)

drop if cohort_b!=1
drop if exclude!=0
drop if linked_b!=1
//Generate a categorical variable to indicate the class of antidiabetic prescription at index
gen indextype=.
replace indextype=0 if secondadmrx=="SU"
replace indextype=1 if secondadmrx=="DPP"
replace indextype=2 if secondadmrx=="GLP"
replace indextype=3 if secondadmrx=="insulin"
replace indextype=4 if secondadmrx=="TZD"
replace indextype=5 if secondadmrx=="other"|secondadmrx=="DPPGLP"|secondadmrx=="DPPTZD"|secondadmrx=="DPPinsulin"|secondadmrx=="DPPother"|secondadmrx=="GLPTZD"|secondadmrx=="GLPinsulin"|secondadmrx=="GLPother"|secondadmrx=="SUDPP"|secondadmrx=="SUGLP"|secondadmrx=="SUTZD"|secondadmrx=="SUinsulin"|secondadmrx=="SUother"|secondadmrx=="TZDother"|secondadmrx=="insulinTZD"|secondadmrx=="insulinother"
replace indextype=6 if secondadmrx=="metformin"
label var indextype "Antidiabetic class at index (switch from or add to metformin)" 
drop if indextype==.

//Using full CPRD Cohort
//recode cvprim_comp_g_i (0=1) (1=0) (MARCH172015 dataset or earlier only)
//All-cause mortality
gen allcausemortb = 0
replace allcausemortb = 1 if deathdate2!=.|dod2!=.
label var allcausemortb "All-cause mortality linked"
//Generate exit date for all cause mortality
forval i=0/5{
egen acm_exit`i' = rowmin(exposuretf`i' tod2 deathdate2 dod2 lcd2) 
format acm_exit`i' %td
label var acm_exit`i' "Exit date for all-cause mortality for indextype=`i' for linked patients"
}
egen acm_exitb = rowmin(acm_exit0 acm_exit1 acm_exit2 acm_exit3 acm_exit4 acm_exit5)
drop acm_exit0-acm_exit5
format acm_exitb %td
label var acm_exitb "Exit date for all-cause mortality for linked patients"
//Generate person-years, incidence rate, and 95%CI as well as hazard ratio
stset acm_exitb, fail(allcausemortb) id(patid) origin(seconddate) scale(365.35)
stptime, title(person-years)
putexcel A1= ("Indextype") B1=("Person-Time") C1=("Failures") D1=("Incidence Rate") E1=("Lower Bound") F1=("Upper Bound") G1=("Hazard Ratio") H1=("Lower Bound") I1=("Upper Bound") using Primary_Outcomes_Linked, sheet("ACM") modify
forval i=0/5{
local row=`i'+2
stptime if indextype==`i'
putexcel A`row'= ("`i'") B`row'=(r(ptime)) C`row'=(r(failures)) D`row'=(r(rate)) E`row'=(r(lb)) F`row'=(r(ub)) using Primary_Outcomes_Linked, sheet("ACM") modify
}
forval i=1/5 {
local row=`i'+2
local matrow=`i'+1
stcox i.indextype
matrix b=r(table)
matrix a= b'
putexcel G`row'=(a[`matrow',1]) H`row'=(a[`matrow',5]) I`row'=(a[`matrow',6]) using Primary_Outcomes_Linked, sheet("ACM") modify
}
//Composite CV event
gen cvmajorb = cvprim_comp_g_i|cvprim_comp_h_i==1|cvprim_comp_o_i==1 
label var cvmajorb "Indicator for first major cv event (mi, stroke, cvdeath) 1=event, 0=no event"
//Total follow-up time
forval i=0/5{
egen cvmajor_exit`i' = rowmin(exposuretf`i' cvprim_comp_g_date_i cvprim_comp_h_date_i cvprim_comp_o_date_i lcd2)
format cvmajor_exit`i' %td
label var cvmajor_exit`i' "Exit date for major cardiovascular event (MI, stroke, or CV death) for indextype=`i'"
}
egen cvmajor_exitb = rowmin(cvmajor_exit0 cvmajor_exit1 cvmajor_exit2 cvmajor_exit3 cvmajor_exit4 cvmajor_exit5)
drop cvmajor_exit0-cvmajor_exit5
format cvmajor_exitb %td
label var cvmajor_exitb "Exit date for major cardiovascular event for linked patients"
//Generate person-years, incidence rate, and 95%CI as well as hazard ratio
stset cvmajor_exitb, fail(cvmajorb) id(patid) origin(seconddate) scale(365.35)
stptime, title(person-years)
putexcel A1= ("Indextype") B1=("Person-Time") C1=("Failures") D1=("Incidence Rate") E1=("Lower Bound") F1=("Upper Bound") G1=("Hazard Ratio") H1=("Lower Bound") I1=("Upper Bound") using Primary_Outcomes_Linked, sheet("MajorCV") modify
forval i=0/5{
local row=`i'+2
stptime if indextype==`i'
putexcel A`row'= ("`i'") B`row'=(r(ptime)) C`row'=(r(failures)) D`row'=(r(rate)) E`row'=(r(lb)) F`row'=(r(ub)) using Primary_Outcomes_Linked, sheet("MajorCV") modify
}
forval i=1/5 {
local row=`i'+2
local matrow=`i'+1
stcox i.indextype
matrix b=r(table)
matrix a= b'
putexcel G`row'=(a[`matrow',1]) H`row'=(a[`matrow',5]) I`row'=(a[`matrow',6]) using Primary_Outcomes_Linked, sheet("MajorCV") modify
}
//MI: use myoinfarct_g
gen myoib = 1 if myoinfarct_g==1|myoinfarct_h==1|myoinfarct_o==1
label var myoib "Indicator for first MI 1=event, 0=no event for linked patients"
//Total follow-up time
forval i=0/5{
egen mi_exit`i' = rowmin(exposuretf`i' myoinfarct_g_date_i myoinfarct_h_date_i myoinfarct_o_date_i lcd2)
format mi_exit`i' %td
label var mi_exit`i' "Exit date for myocardial infarction for indextype=`i' for linked patients"
}
egen mi_exitb = rowmin(mi_exit0 mi_exit1 mi_exit2 mi_exit3 mi_exit4 mi_exit5)
drop mi_exit0-mi_exit5
format mi_exitb %td
label var mi_exitb "Exit date for myocardial infarction for linked patients"
//Generate person-years, incidence rate, and 95%CI as well as hazard ratio
stset mi_exitb, fail(myoib) id(patid) origin(seconddate) scale(365.35)
stptime, title(person-years)
putexcel A1= ("Indextype") B1=("Person-Time") C1=("Failures") D1=("Incidence Rate") E1=("Lower Bound") F1=("Upper Bound") G1=("Hazard Ratio") H1=("Lower Bound") I1=("Upper Bound") using Primary_Outcomes_Linked, sheet("MI") modify
forval i=0/5{
local row=`i'+2
stptime if indextype==`i'
putexcel A`row'= ("`i'") B`row'=(r(ptime)) C`row'=(r(failures)) D`row'=(r(rate)) E`row'=(r(lb)) F`row'=(r(ub)) using Primary_Outcomes_Linked, sheet("MI") modify
}
forval i=1/5 {
local row=`i'+2
local matrow=`i'+1
stcox i.indextype
matrix b=r(table)
matrix a= b'
putexcel G`row'=(a[`matrow',1]) H`row'=(a[`matrow',5]) I`row'=(a[`matrow',6]) using Primary_Outcomes_Linked, sheet("MI") modify
}
//Stroke: use stroke_g
gen strokeb = 1 if stroke_g==1|stroke_h==1|stroke_o==1
label var strokeb "Indicator for first stroke after indexdate 1=event, 0=no event for linked patients"
//Total follow-up time
forval i=0/5{
egen stroke_exit`i' = rowmin(exposuretf`i' stroke_g_date_i stroke_h_date_i stroke_o_date_i lcd2) 
format stroke_exit`i' %td
label var stroke_exit`i' "Exit date for stroke for indextype=`i' for linked patients"
}
egen stroke_exitb = rowmin(stroke_exit0 stroke_exit1 stroke_exit2 stroke_exit3 stroke_exit4 stroke_exit5)
drop stroke_exit0-stroke_exit5
format stroke_exitb %td
label var stroke_exitb "Exit date for stroke for linked patients"
//Generate person-years, incidence rate, and 95%CI as well as hazard ratio
stset stroke_exitb, fail(strokeb) id(patid) origin(seconddate) scale(365.35)
stptime, title(person-years)
putexcel A1= ("Indextype") B1=("Person-Time") C1=("Failures") D1=("Incidence Rate") E1=("Lower Bound") F1=("Upper Bound") G1=("Hazard Ratio") H1=("Lower Bound") I1=("Upper Bound") using Primary_Outcomes_Linked, sheet("Stroke") modify
forval i=0/5{
local row=`i'+2
stptime if indextype==`i'
putexcel A`row'= ("`i'") B`row'=(r(ptime)) C`row'=(r(failures)) D`row'=(r(rate)) E`row'=(r(lb)) F`row'=(r(ub)) using Primary_Outcomes_Linked, sheet("Stroke") modify
}
forval i=1/5 {
local row=`i'+2
local matrow=`i'+1
stcox i.indextype
matrix b=r(table)
matrix a= b'
putexcel G`row'=(a[`matrow',1]) H`row'=(a[`matrow',5]) I`row'=(a[`matrow',6]) using Primary_Outcomes_Linked, sheet("Stroke") modify
}
//Death: use cvdeath_g
gen cvdeathb = 1 if cvdeath_g==1|cvdeath_h==1|cvdeath_o==1
label var cvdeathb "Indicator for cvdeath after indexdate 1=event, 0=no event for linked patients"
//Total follow-up time
forval i=0/5{
egen cvdeath_exit`i' = rowmin(exposuretf`i' cvdeath_g_date_i cvdeath_h_date_i cvdeath_o_date_i lcd2) 
format cvdeath_exit`i' %td
label var cvdeath_exit`i' "Exit date for cardiovascular death for indextype=`i'"
}
egen cvdeath_exitb = rowmin(cvdeath_exit0 cvdeath_exit1 cvdeath_exit2 cvdeath_exit3 cvdeath_exit4 cvdeath_exit5)
drop cvdeath_exit0-cvdeath_exit5
format cvdeath_exitb %td
label var cvdeath_exitb "Exit date for myocardial infarction for linked patients"
//Generate person-years, incidence rate, and 95%CI as well as hazard ratio
stset cvdeath_exitb, fail(cvdeathb) id(patid) origin(seconddate) scale(365.35)
stptime, title(person-years)
putexcel A1= ("Indextype") B1=("Person-Time") C1=("Failures") D1=("Incidence Rate") E1=("Lower Bound") F1=("Upper Bound") G1=("Hazard Ratio") H1=("Lower Bound") I1=("Upper Bound") using Primary_Outcomes_Linked, sheet("CVdeath") modify
forval i=0/5{
local row=`i'+2
stptime if indextype==`i'
putexcel A`row'= ("`i'") B`row'=(r(ptime)) C`row'=(r(failures)) D`row'=(r(rate)) E`row'=(r(lb)) F`row'=(r(ub)) using Primary_Outcomes_Linked, sheet("CVdeath") modify
}
forval i=1/5 {
local row=`i'+2
local matrow=`i'+1
stcox i.indextype
matrix b=r(table)
matrix a= b'
putexcel G`row'=(a[`matrow',1]) H`row'=(a[`matrow',5]) I`row'=(a[`matrow',6]) using Primary_Outcomes_Linked, sheet("CVdeath") modify
}
//Heart Failure: use heartfail_g heartfail_g_date_i
gen heartfailb =1 if heartfail_g==1|heartfail_h==1|heartfail_o==1
label var heartfailb "Indicator for heart failure after indexdate for linked patients"
//Total follow-up time
forval i=0/5{
egen hf_exit`i' = rowmin(exposuretf`i' heartfail_g_date_i heartfail_h_date_i heartfail_o_date_i lcd2) 
format hf_exit`i' %td
label var hf_exit`i' "Exit date for heart failure for indextype=`i'"
}
egen hf_exitb = rowmin(hf_exit0 hf_exit1 hf_exit2 hf_exit3 hf_exit4 hf_exit5)
drop hf_exit0-hf_exit5
format hf_exitb %td
label var hf_exitb "Exit date for heart failure for linked patients"
//Generate person-years, incidence rate, and 95%CI as well as hazard ratio
stset hf_exitb, fail(heartfailb) id(patid) origin(seconddate) scale(365.35)
stptime, title(person-years)
putexcel A1= ("Indextype") B1=("Person-Time") C1=("Failures") D1=("Incidence Rate") E1=("Lower Bound") F1=("Upper Bound") G1=("Hazard Ratio") H1=("Lower Bound") I1=("Upper Bound") using Primary_Outcomes_Linked, sheet("HF") modify
forval i=0/5{
local row=`i'+2
stptime if indextype==`i'
putexcel A`row'= ("`i'") B`row'=(r(ptime)) C`row'=(r(failures)) D`row'=(r(rate)) E`row'=(r(lb)) F`row'=(r(ub)) using Primary_Outcomes_Linked, sheet("HF") modify
}
forval i=1/5 {
local row=`i'+2
local matrow=`i'+1
stcox i.indextype
matrix b=r(table)
matrix a= b'
putexcel G`row'=(a[`matrow',1]) H`row'=(a[`matrow',5]) I`row'=(a[`matrow',6]) using Primary_Outcomes_Linked, sheet("HF") modify
}
//Cardiac Arrhythmia: use arrhythmia_g arrhythmia_g_date_i
gen arrb = 1 if arrhythmia_g==1|arrhythmia_h==1|arrhythmia_o==1
label var arrb "Indicator for arrhythmia after indexdate 1=event, 0=no event for linked patients"
//Total follow-up time
forval i=0/5{
egen arr_exit`i' = rowmin(exposuretf`i' arrhythmia_g_date_i arrhythmia_h_date_i arrhythmia_o_date_i lcd2) 
format arr_exit`i' %td
label var arr_exit`i' "Exit date for cardiac arrhythmia for indextype=`i'"
}
egen arr_exitb = rowmin(arr_exit0 arr_exit1 arr_exit2 arr_exit3 arr_exit4 arr_exit5)
drop arr_exit0-arr_exit5
format arr_exitb %td
label var arr_exitb "Exit date for cardiac arrhythmia for linked patients"
//Generate person-years, incidence rate, and 95%CI as well as hazard ratio
stset arr_exitb, fail(arrb) id(patid) origin(seconddate) scale(365.35)
stptime, title(person-years)
putexcel A1= ("Indextype") B1=("Person-Time") C1=("Failures") D1=("Incidence Rate") E1=("Lower Bound") F1=("Upper Bound") G1=("Hazard Ratio") H1=("Lower Bound") I1=("Upper Bound") using Primary_Outcomes_Linked, sheet("Arr") modify
forval i=0/5{
local row=`i'+2
stptime if indextype==`i'
putexcel A`row'= ("`i'") B`row'=(r(ptime)) C`row'=(r(failures)) D`row'=(r(rate)) E`row'=(r(lb)) F`row'=(r(ub)) using Primary_Outcomes_Linked, sheet("Arr") modify
}
forval i=1/5 {
local row=`i'+2
local matrow=`i'+1
stcox i.indextype
matrix b=r(table)
matrix a= b'
putexcel G`row'=(a[`matrow',1]) H`row'=(a[`matrow',5]) I`row'=(a[`matrow',6]) using Primary_Outcomes_Linked, sheet("Arr") modify
}
//Unstable Angina: use angina_g angina_g_date_i
gen angb =1 if angina_g==1|angina_h==1|angina_o==1
label var angb "Indicator for unstable angina after indexdate for linked patients"
//Total follow-up time
forval i=0/5{
egen ang_exit`i' = rowmin(exposuretf`i' angina_g_date_i angina_h_date_i angina_o_date_i lcd2) 
format ang_exit`i' %td
label var ang_exit`i' "Exit date for unstable angina for indextype=`i'"
}
egen ang_exitb = rowmin(ang_exit0 ang_exit1 ang_exit2 ang_exit3 ang_exit4 ang_exit5)
drop ang_exit0-ang_exit5
format ang_exitb %td
label var ang_exitb "Exit date for unstable angina for linked patients"
//Generate person-years, incidence rate, and 95%CI as well as hazard ratio
stset ang_exitb, fail(angb) id(patid) origin(seconddate) scale(365.35)
stptime, title(person-years)
forval i=0/5{
local row=`i'+2
stptime if indextype==`i'
putexcel A1= ("Indextype") B1=("Person-Time") C1=("Failures") D1=("Incidence Rate") E1=("Lower Bound") F1=("Upper Bound") G1=("Hazard Ratio") H1=("Lower Bound") I1=("Upper Bound") using Primary_Outcomes_Linked, sheet("Angina") modify
}
forval i=0/5{
local row=`i'+2
stptime if indextype==`i'
putexcel A`row'= ("`i'") B`row'=(r(ptime)) C`row'=(r(failures)) D`row'=(r(rate)) E`row'=(r(lb)) F`row'=(r(ub)) using Primary_Outcomes_Linked, sheet("Angina") modify
}
forval i=1/5 {
local row=`i'+2
local matrow=`i'+1
stcox i.indextype
matrix b=r(table)
matrix a= b'
putexcel G`row'=(a[`matrow',1]) H`row'=(a[`matrow',5]) I`row'=(a[`matrow',6]) using Primary_Outcomes_Linked, sheet("Angina") modify
}
//Urgent revascularization: use revasc_g revasc_g_date_i
gen revascb = 1 if revasc_g==1|revasc_opcs==1
label var revascb "Indicator for heart failure after indexdate for linked patients"
//Total follow-up time
forval i=0/5{
egen revasc_exit`i' = rowmin(exposuretf`i' revasc_g_date_i revasc_date_i lcd2) 
format revasc_exit`i' %td
label var revasc_exit`i' "Exit date for urgent revascularization for indextype=`i'"
}
egen revasc_exitb = rowmin(revasc_exit0 revasc_exit1 revasc_exit2 revasc_exit3 revasc_exit4 revasc_exit5)
drop revasc_exit0-revasc_exit5
format revasc_exitb %td
label var revasc_exitb "Exit date for urgent revascularization for linked patients"
//Generate person-years, incidence rate, and 95%CI as well as hazard ratio
stset revasc_exitb, fail(revascb) id(patid) origin(seconddate) scale(365.35)
stptime, title(person-years)
putexcel A1= ("Indextype") B1=("Person-Time") C1=("Failures") D1=("Incidence Rate") E1=("Lower Bound") F1=("Upper Bound") G1=("Hazard Ratio") H1=("Lower Bound") I1=("Upper Bound") using Primary_Outcomes_Linked, sheet("Revasc") modify
forval i=0/5{
local row=`i'+2
stptime if indextype==`i'
putexcel A`row'= ("`i'") B`row'=(r(ptime)) C`row'=(r(failures)) D`row'=(r(rate)) E`row'=(r(lb)) F`row'=(r(ub)) using Primary_Outcomes_Linked, sheet("Revasc") modify
}
forval i=1/5 {
local row=`i'+2
local matrow=`i'+1
stcox i.indextype
matrix b=r(table)
matrix a= b'
putexcel G`row'=(a[`matrow',1]) H`row'=(a[`matrow',5]) I`row'=(a[`matrow',6]) using Primary_Outcomes_Linked, sheet("Revasc") modify
}
