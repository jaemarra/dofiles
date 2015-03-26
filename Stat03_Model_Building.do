//  program:    Stat03_Model_Building.do
//  task:		Complete univariate and bivariate preliminary analyses on the covariates 
//				of interest and check correlation matrix for interactions between covariates
//  project: 	Incretins--Comparative mortality and CV outcomes (CPRD)
//  author:     JM \ Mar2015  
//				

clear all
capture log close
set more off
log using Stat03.smcl, replace
timer on 1

use Analytic_Dataset_Master

//Unify exclusion criteria into a binary indicator
gen exclude=1 if (gest_diab==1|pcos==1|preg==1|age_indexdate<=29|cohort_b==0|tx<=seconddate)
replace exclude=0 if exclude!=1
label var exclude "Bin ind for pcos, preg, gest_diab, or <30yo; excluded=1, not excluded=0)

drop if cohort_b!=1
drop if exclude!=0

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

//Univariate Analysis
///////////////////////////////////////All Cause Mortality /////////////////////////////////////////
gen allcausemort = 0
replace allcausemort = 1 if deathdate2!=.
label var allcausemort "All-cause mortality"
//Generate exit date for all cause mortality
forval i=0/5{
egen acm_exit`i' = rowmin(exposuretf`i' tod2 deathdate2 lcd2) 
format acm_exit`i' %td
label var acm_exit`i' "Exit date for all-cause mortality for indextype=`i'"
}
egen acm_exit = rowmin(acm_exit0 acm_exit1 acm_exit2 acm_exit3 acm_exit4 acm_exit5)
drop acm_exit0-acm_exit5
format acm_exit %td
label var acm_exit "Exit date for all-cause mortality"
//Set
stset acm_exit, fail(allcausemort) id(patid) origin(seconddate) scale(365.35)
//Age
stcox age_indexdate, nohr
matrix a=r(table)
putexcel A1=("Covariate") B1=("HR") C1=("SE") D1=("p-value") E1=("LL") F1=("UL") A2=("Age") B2=(a[1,1]) C2=(a[2,1]) D2=(a[4,1]) E2=(a[5,1]) F2=(a[6,1]) using Univariate, sheet("ACM") modify
//HbA1c
stcox prx_testvalue_i275
matrix a=r(table)
putexcel A3=("HbA1c") B3=(a[1,1]) C3=(a[2,1]) D3=(a[4,1]) E3=(a[5,1]) F3=(a[6,1]) using Univariate, sheet("ACM") modify
//Number of hospital visits
stcox prx_servvalue2_h_i
matrix a=r(table)
putexcel A4=("Hospitalizations") B4=(a[1,1]) C4=(a[2,1]) D4=(a[4,1]) E4=(a[5,1]) F4=(a[6,1]) using Univariate, sheet("ACM") modify
//Total Cholesterol
stcox prx_testvalue_i2163
matrix a=r(table)
putexcel A5=("Total Cholesterol") B5=(a[1,1]) C5=(a[2,1]) D5=(a[4,1]) E5=(a[5,1]) F5=(a[6,1]) using Univariate, sheet("ACM") modify
//HDL
stcox prx_testvalue_i2175
matrix a=r(table)
putexcel A6=("HDL") B6=(a[1,1]) C6=(a[2,1]) D6=(a[4,1]) E6=(a[5,1]) F6=(a[6,1]) using Univariate, sheet("ACM") modify
//LDL
stcox prx_testvalue_i2177
matrix a=r(table)
putexcel A7=("LDL") B7=(a[1,1]) C7=(a[2,1]) D7=(a[4,1]) E7=(a[5,1]) F7=(a[6,1]) using Univariate, sheet("ACM") modify
//TG
stcox prx_testvalue_i2202
matrix a=r(table)
putexcel A8=("Triglycerides") B8=(a[1,1]) C8=(a[2,1]) D8=(a[4,1]) E8=(a[5,1]) F8=(a[6,1]) using Univariate, sheet("ACM") modify
//Systolic blood pressure
stcox prx_covvalue_g_i3
matrix a=r(table)
putexcel A9=("Systolic BP") B9=(a[1,1]) C9=(a[2,1]) D9=(a[4,1]) E9=(a[5,1]) F9=(a[6,1]) using Univariate, sheet("ACM") modify
//Unqrx
stcox unqrx
matrix a=r(table)
putexcel A10=("Unique ADM Rx") B10=(a[1,1]) C10=(a[2,1]) D10=(a[4,1]) E10=(a[5,1]) F10=(a[6,1]) using Univariate, sheet("ACM") modify
//Gender
stcox gender
matrix a=r(table)
putexcel A11=("Gender") B11=(a[1,1]) C11=(a[2,1]) D11=(a[4,1]) E11=(a[5,1]) F11=(a[6,1]) using Univariate, sheet("ACM") modify
//SES
stcox imd2010_5
matrix a=r(table)
putexcel A12=("SES") B12=(a[1,1]) C12=(a[2,1]) D12=(a[4,1]) E12=(a[5,1]) F12=(a[6,1]) using Univariate, sheet("ACM") modify
//Marital status
stcox marital
matrix a=r(table)
putexcel A13=("Marital Status") B13=(a[1,1]) C13=(a[2,1]) D13=(a[4,1]) E13=(a[5,1]) F13=(a[6,1]) using Univariate, sheet("ACM") modify
//Smoking Status
stcox prx_covvalue_g_i4
matrix a=r(table)
putexcel A14=("Smoking Status") B14=(a[1,1]) C14=(a[2,1]) D14=(a[4,1]) E14=(a[5,1]) F14=(a[6,1]) using Univariate, sheet("ACM") modify
//Alcohol Abuse Status
stcox prx_covvalue_g_i5
matrix a=r(table)
putexcel A15=("Alcohol Status") B15=(a[1,1]) C15=(a[2,1]) D15=(a[4,1]) E15=(a[5,1]) F15=(a[6,1]) using Univariate, sheet("ACM") modify
//Physician Visits
stcox totservs_g_i
matrix a=r(table)
putexcel A16=("Physician Visits") B16=(a[1,1]) C16=(a[2,1]) D16=(a[4,1]) E16=(a[5,1]) F16=(a[6,1]) using Univariate, sheet("ACM") modify
//Charlson Comorbidity Score
stcox prx_ccivalue_g_i
matrix a=r(table)
putexcel A17=("CCI") B17=(a[1,1]) C17=(a[2,1]) D17=(a[4,1]) E17=(a[5,1]) F17=(a[6,1]) using Univariate, sheet("ACM") modify
//MI
stcox prx_covvalue_g_i6
matrix a=r(table)
putexcel A18=("MI") B18=(a[1,1]) C18=(a[2,1]) D18=(a[4,1]) E18=(a[5,1]) F18=(a[6,1]) using Univariate, sheet("ACM") modify
cs allcausemort prx_covvalue_g_i6
putexcel G1=("RR") H1=("LL") I1=("UL") J1=("RD") K1=("LL") L1=("UL") M1=("p-val") G18=(r(rr)) H18=(r(lb_rr)) I18=(r(ub_rr)) J18=(r(rd)) K18=(r(lb_rd)) L18=(r(ub_rd)) M18=(r(p)) using Univariate, sheet("ACM") modify
//Stroke
stcox prx_covvalue_g_i7
matrix a=r(table)
putexcel A19=("Stroke") B19=(a[1,1]) C19=(a[2,1]) D19=(a[4,1]) E19=(a[5,1]) F19=(a[6,1]) using Univariate, sheet("ACM") modify
cs allcausemort prx_covvalue_g_i7
putexcel G19=(r(rr)) H19=(r(lb_rr)) I19=(r(ub_rr)) J19=(r(rd)) K19=(r(lb_rd)) L19=(r(ub_rd)) M19=(r(p)) using Univariate, sheet("ACM") modify
//HF
stcox prx_covvalue_g_i8
matrix a=r(table)
putexcel A20=("HF") B20=(a[1,1]) C20=(a[2,1]) D20=(a[4,1]) E20=(a[5,1]) F20=(a[6,1]) using Univariate, sheet("ACM") modify
cs allcausemort prx_covvalue_g_i7
putexcel G20=(r(rr)) H20=(r(lb_rr)) I20=(r(ub_rr)) J20=(r(rd)) K20=(r(lb_rd)) L20=(r(ub_rd)) M20=(r(p)) using Univariate, sheet("ACM") modify
//Arrhythmia
stcox prx_covvalue_g_i9
matrix a=r(table)
putexcel A21=("Arrhythmia") B21=(a[1,1]) C21=(a[2,1]) D21=(a[4,1]) E21=(a[5,1]) F21=(a[6,1]) using Univariate, sheet("ACM") modify
cs allcausemort prx_covvalue_g_i7
putexcel G21=(r(rr)) H21=(r(lb_rr)) I21=(r(ub_rr)) J21=(r(rd)) K21=(r(lb_rd)) L21=(r(ub_rd)) M21=(r(p)) using Univariate, sheet("ACM") modify
//Angina
stcox prx_covvalue_g_i10
matrix a=r(table)
putexcel A22=("Angina") B22=(a[1,1]) C22=(a[2,1]) D22=(a[4,1]) E22=(a[5,1]) F22=(a[6,1]) using Univariate, sheet("ACM") modify
cs allcausemort prx_covvalue_g_i7
putexcel G22=(r(rr)) H22=(r(lb_rr)) I22=(r(ub_rr)) J22=(r(rd)) K22=(r(lb_rd)) L22=(r(ub_rd)) M22=(r(p)) using Univariate, sheet("ACM") modify
//Revascularization
stcox prx_covvalue_g_i11
matrix a=r(table)
putexcel A23=("Urgent Revasc") B23=(a[1,1]) C23=(a[2,1]) D23=(a[4,1]) E23=(a[5,1]) F23=(a[6,1]) using Univariate, sheet("ACM") modify
cs allcausemort prx_covvalue_g_i7
putexcel G23=(r(rr)) H23=(r(lb_rr)) I23=(r(ub_rr)) J23=(r(rd)) K23=(r(lb_rd)) L23=(r(ub_rd)) M23=(r(p)) using Univariate, sheet("ACM") modify
//HTN
stcox prx_covvalue_g_i12
matrix a=r(table)
putexcel A24=("HTN") B24=(a[1,1]) C24=(a[2,1]) D24=(a[4,1]) E24=(a[5,1]) F24=(a[6,1]) using Univariate, sheet("ACM") modify
cs allcausemort prx_covvalue_g_i7
putexcel G24=(r(rr)) H24=(r(lb_rr)) I24=(r(ub_rr)) J24=(r(rd)) K24=(r(lb_rd)) L24=(r(ub_rd)) M24=(r(p)) using Univariate, sheet("ACM") modify
//Atrial Fibrillation
stcox prx_covvalue_g_i13
matrix a=r(table)
putexcel A25=("AFib") B25=(a[1,1]) C25=(a[2,1]) D25=(a[4,1]) E25=(a[5,1]) F25=(a[6,1]) using Univariate, sheet("ACM") modify
cs allcausemort prx_covvalue_g_i7
putexcel G25=(r(rr)) H25=(r(lb_rr)) I25=(r(ub_rr)) J25=(r(rd)) K25=(r(lb_rd)) L25=(r(ub_rd)) M25=(r(p)) using Univariate, sheet("ACM") modify
//Peripheral Vascular Disease
stcox prx_covvalue_g_i14
matrix a=r(table)
putexcel A26=("PVD") B26=(a[1,1]) C26=(a[2,1]) D26=(a[4,1]) E26=(a[5,1]) F26=(a[6,1]) using Univariate, sheet("ACM") modify
cs allcausemort prx_covvalue_g_i7
putexcel G26=(r(rr)) H26=(r(lb_rr)) I26=(r(ub_rr)) J26=(r(rd)) K26=(r(lb_rd)) L26=(r(ub_rd)) M26=(r(p)) using Univariate, sheet("ACM") modify

//Multivariate analysis
//16 in common with MCV
stcox age_indexdate prx_testvalue_i275 prx_testvalue_i2163 prx_testvalue_i2175 totservs_g_i prx_servvalue2_h_i i.unqrx i.marital i.gender i.prx_covvalue_g_i4 i.prx_ccivalue_g_i i.prx_covvalue_g_i7 i.prx_covvalue_g_i8 i.prx_covvalue_g_i10 i.prx_covvalue_g_i13 i.prx_covvalue_g_i14, nohr
matrix b=r(table)
matrix c=b'
matrix list c
matrix rownames c = Age HbA1c Totchol HDL DocVisits Hospitalizations 2unqrx 3unqrx 4unqrx 5ungrx 6unqrx 7unqrx 0marital 1marital 2marital 3marital 4marital 5marital 6marital 7marital 8marital 9marital 10marital 1gender 2gender 0smoking 1smoking 2smoking 3smoking 1cci 2cci 3cci 4cci 0stroke 1stroke 0HF 1HF 0angina 1angina 0Afib 1Afib 0PVD 1PVD
local matrownames "Age HbA1c Totchol HDL DocVisits Hospitalizations 2unqrx 3unqrx 4unqrx 5ungrx 6unqrx 7unqrx 0marital 1marital 2marital 3marital 4marital 5marital 6marital 7marital 8marital 9marital 10marital 1gender 2gender 0smoking 1smoking 2smoking 3smoking 1cci 2cci 3cci 4cci 0stroke 1stroke 0HF 1HF 0angina 1angina 0Afib 1Afib 0PVD 1PVD"
forval i=1/43{
local x=`i'+1
local rowname:word `i' of `matrownames'
putexcel A1=("Variable") B1=("p-value") A`x'=("`rowname'") B`x'=(c[`i',4])using Multivariate, sheet("ACM16") modify
}
//19 distinct variables for ACM
stcox age_indexdate prx_testvalue_i275 prx_testvalue_i2163 prx_testvalue_i2175 prx_testvalue_i2202 totservs_g_i prx_servvalue2_h_i i.unqrx i.marital i.gender i.prx_covvalue_g_i4 i.prx_ccivalue_g_i i.prx_covvalue_g_i6 i.prx_covvalue_g_i7 i.prx_covvalue_g_i8 i.prx_covvalue_g_i9 i.prx_covvalue_g_i10 i.prx_covvalue_g_i13 i.prx_covvalue_g_i14, nohr
matrix b=r(table)
matrix c=b'
matrix list c
matrix rownames c = Age HbA1c Totchol HDL TG DocVisits Hospitalizations 2unqrx 3unqrx 4unqrx 5ungrx 6unqrx 7unqrx 0marital 1marital 2marital 3marital 4marital 5marital 6marital 7marital 8marital 9marital 10marital 1gender 2gender 0smoking 1smoking 2smoking 3smoking 1cci 2cci 3cci 4cci 0MI 1MI 0stroke 1stroke 0HF 1HF 0arr 1arr 0angina 1angina 0Afib 1Afib 0PVD 1PVD
local matrownames "Age HbA1c Totchol HDL TG DocVisits Hospitalizations 2unqrx 3unqrx 4unqrx 5ungrx 6unqrx 7unqrx 0marital 1marital 2marital 3marital 4marital 5marital 6marital 7marital 8marital 9marital 10marital 1gender 2gender 0smoking 1smoking 2smoking 3smoking 1cci 2cci 3cci 4cci 0MI 1MI 0stroke 1stroke 0HF 1HF 0arr 1arr 0angina 1angina 0Afib 1Afib 0PVD 1PVD"
forval i=1/48{
local x=`i'+1
local rowname:word `i' of `matrownames'
putexcel A1=("Variable") B1=("p-value") A`x'=("`rowname'") B`x'=(c[`i',4])using Multivariate, sheet("ACM19") modify
}

///////////////////////////////////////Major CV Event /////////////////////////////////////////
//Composite CV event
gen cvmajor = cvprim_comp_g_i 
label var cvmajor "Indicator for first major cv event (mi, stroke, cvdeath) 1=event, 0=no event"
//Total follow-up time
forval i=0/5{
egen cvmajor_exit`i' = rowmin(exposuretf`i' cvprim_comp_g_date_i lcd2)
format cvmajor_exit`i' %td
label var cvmajor_exit`i' "Exit date for major cardiovascular event (MI, stroke, or CV death) for indextype=`i'"
}
egen cvmajor_exit = rowmin(cvmajor_exit0 cvmajor_exit1 cvmajor_exit2 cvmajor_exit3 cvmajor_exit4 cvmajor_exit5)
drop cvmajor_exit0-cvmajor_exit5
format cvmajor_exit %td
label var cvmajor_exit "Exit date for major cardiovascular event (MI, stroke, or CV death)"
//Set
stset cvmajor_exit, fail(cvmajor) id(patid) origin(seconddate) scale(365.35)
//Age
stcox age_indexdate, nohr
matrix a=r(table)
putexcel A1=("Covariate") B1=("HR") C1=("SE") D1=("p-value") E1=("LL") F1=("UL") A2=("Age") B2=(a[1,1]) C2=(a[2,1]) D2=(a[4,1]) E2=(a[5,1]) F2=(a[6,1]) using Univariate, sheet("MCV") modify
//HbA1c
stcox prx_testvalue_i275
matrix a=r(table)
putexcel A3=("HbA1c") B3=(a[1,1]) C3=(a[2,1]) D3=(a[4,1]) E3=(a[5,1]) F3=(a[6,1]) using Univariate, sheet("MCV") modify
//Number of hospital visits
stcox prx_servvalue2_h_i
matrix a=r(table)
putexcel A4=("Hospitalizations") B4=(a[1,1]) C4=(a[2,1]) D4=(a[4,1]) E4=(a[5,1]) F4=(a[6,1]) using Univariate, sheet("MCV") modify
//Total Cholesterol
stcox prx_testvalue_i2163
matrix a=r(table)
putexcel A5=("Total Cholesterol") B5=(a[1,1]) C5=(a[2,1]) D5=(a[4,1]) E5=(a[5,1]) F5=(a[6,1]) using Univariate, sheet("MCV") modify
//HDL
stcox prx_testvalue_i2175
matrix a=r(table)
putexcel A6=("HDL") B6=(a[1,1]) C6=(a[2,1]) D6=(a[4,1]) E6=(a[5,1]) F6=(a[6,1]) using Univariate, sheet("MCV") modify
//LDL
stcox prx_testvalue_i2177
matrix a=r(table)
putexcel A7=("LDL") B7=(a[1,1]) C7=(a[2,1]) D7=(a[4,1]) E7=(a[5,1]) F7=(a[6,1]) using Univariate, sheet("MCV") modify
//TG
stcox prx_testvalue_i2202
matrix a=r(table)
putexcel A8=("Triglycerides") B8=(a[1,1]) C8=(a[2,1]) D8=(a[4,1]) E8=(a[5,1]) F8=(a[6,1]) using Univariate, sheet("MCV") modify
//Systolic blood pressure
stcox prx_covvalue_g_i3
matrix a=r(table)
putexcel A9=("Systolic BP") B9=(a[1,1]) C9=(a[2,1]) D9=(a[4,1]) E9=(a[5,1]) F9=(a[6,1]) using Univariate, sheet("MCV") modify
//Unqrx
stcox unqrx
matrix a=r(table)
putexcel A10=("Unique ADM Rx") B10=(a[1,1]) C10=(a[2,1]) D10=(a[4,1]) E10=(a[5,1]) F10=(a[6,1]) using Univariate, sheet("MCV") modify
//Gender
stcox gender
matrix a=r(table)
putexcel A11=("Gender") B11=(a[1,1]) C11=(a[2,1]) D11=(a[4,1]) E11=(a[5,1]) F11=(a[6,1]) using Univariate, sheet("MCV") modify
//SES
stcox imd2010_5
matrix a=r(table)
putexcel A12=("SES") B12=(a[1,1]) C12=(a[2,1]) D12=(a[4,1]) E12=(a[5,1]) F12=(a[6,1]) using Univariate, sheet("MCV") modify
//Marital status
stcox marital
matrix a=r(table)
putexcel A13=("Marital Status") B13=(a[1,1]) C13=(a[2,1]) D13=(a[4,1]) E13=(a[5,1]) F13=(a[6,1]) using Univariate, sheet("MCV") modify
//Smoking Status
stcox prx_covvalue_g_i4
matrix a=r(table)
putexcel A14=("Smoking Status") B14=(a[1,1]) C14=(a[2,1]) D14=(a[4,1]) E14=(a[5,1]) F14=(a[6,1]) using Univariate, sheet("MCV") modify
//Alcohol Abuse Status
stcox prx_covvalue_g_i5
matrix a=r(table)
putexcel A15=("Alcohol Status") B15=(a[1,1]) C15=(a[2,1]) D15=(a[4,1]) E15=(a[5,1]) F15=(a[6,1]) using Univariate, sheet("MCV") modify
//Physician Visits
stcox totservs_g_i
matrix a=r(table)
putexcel A16=("Physician Visits") B16=(a[1,1]) C16=(a[2,1]) D16=(a[4,1]) E16=(a[5,1]) F16=(a[6,1]) using Univariate, sheet("MCV") modify
//Charlson Comorbidity Score
stcox prx_ccivalue_g_i
matrix a=r(table)
putexcel A17=("CCI") B17=(a[1,1]) C17=(a[2,1]) D17=(a[4,1]) E17=(a[5,1]) F17=(a[6,1]) using Univariate, sheet("MCV") modify
//MI
stcox prx_covvalue_g_i6
matrix a=r(table)
putexcel A18=("MI") B18=(a[1,1]) C18=(a[2,1]) D18=(a[4,1]) E18=(a[5,1]) F18=(a[6,1]) using Univariate, sheet("MCV") modify
cs allcausemort prx_covvalue_g_i6
putexcel G1=("RR") H1=("LL") I1=("UL") J1=("RD") K1=("LL") L1=("UL") M1=("p-val") G18=(r(rr)) H18=(r(lb_rr)) I18=(r(ub_rr)) J18=(r(rd)) K18=(r(lb_rd)) L18=(r(ub_rd)) M18=(r(p)) using Univariate, sheet("MCV") modify
//Stroke
stcox prx_covvalue_g_i7
matrix a=r(table)
putexcel A19=("Stroke") B19=(a[1,1]) C19=(a[2,1]) D19=(a[4,1]) E19=(a[5,1]) F19=(a[6,1]) using Univariate, sheet("MCV") modify
cs allcausemort prx_covvalue_g_i7
putexcel G19=(r(rr)) H19=(r(lb_rr)) I19=(r(ub_rr)) J19=(r(rd)) K19=(r(lb_rd)) L19=(r(ub_rd)) M19=(r(p)) using Univariate, sheet("MCV") modify
//HF
stcox prx_covvalue_g_i8
matrix a=r(table)
putexcel A20=("HF") B20=(a[1,1]) C20=(a[2,1]) D20=(a[4,1]) E20=(a[5,1]) F20=(a[6,1]) using Univariate, sheet("MCV") modify
cs allcausemort prx_covvalue_g_i7
putexcel G20=(r(rr)) H20=(r(lb_rr)) I20=(r(ub_rr)) J20=(r(rd)) K20=(r(lb_rd)) L20=(r(ub_rd)) M20=(r(p)) using Univariate, sheet("MCV") modify
//Arrhythmia
stcox prx_covvalue_g_i9
matrix a=r(table)
putexcel A21=("Arrhythmia") B21=(a[1,1]) C21=(a[2,1]) D21=(a[4,1]) E21=(a[5,1]) F21=(a[6,1]) using Univariate, sheet("MCV") modify
cs allcausemort prx_covvalue_g_i7
putexcel G21=(r(rr)) H21=(r(lb_rr)) I21=(r(ub_rr)) J21=(r(rd)) K21=(r(lb_rd)) L21=(r(ub_rd)) M21=(r(p)) using Univariate, sheet("MCV") modify
//Angina
stcox prx_covvalue_g_i10
matrix a=r(table)
putexcel A22=("Angina") B22=(a[1,1]) C22=(a[2,1]) D22=(a[4,1]) E22=(a[5,1]) F22=(a[6,1]) using Univariate, sheet("MCV") modify
cs allcausemort prx_covvalue_g_i7
putexcel G22=(r(rr)) H22=(r(lb_rr)) I22=(r(ub_rr)) J22=(r(rd)) K22=(r(lb_rd)) L22=(r(ub_rd)) M22=(r(p)) using Univariate, sheet("MCV") modify
//Revascularization
stcox prx_covvalue_g_i11
matrix a=r(table)
putexcel A23=("Urgent Revasc") B23=(a[1,1]) C23=(a[2,1]) D23=(a[4,1]) E23=(a[5,1]) F23=(a[6,1]) using Univariate, sheet("MCV") modify
cs allcausemort prx_covvalue_g_i7
putexcel G23=(r(rr)) H23=(r(lb_rr)) I23=(r(ub_rr)) J23=(r(rd)) K23=(r(lb_rd)) L23=(r(ub_rd)) M23=(r(p)) using Univariate, sheet("MCV") modify
//HTN
stcox prx_covvalue_g_i12
matrix a=r(table)
putexcel A24=("HTN") B24=(a[1,1]) C24=(a[2,1]) D24=(a[4,1]) E24=(a[5,1]) F24=(a[6,1]) using Univariate, sheet("MCV") modify
cs allcausemort prx_covvalue_g_i7
putexcel G24=(r(rr)) H24=(r(lb_rr)) I24=(r(ub_rr)) J24=(r(rd)) K24=(r(lb_rd)) L24=(r(ub_rd)) M24=(r(p)) using Univariate, sheet("MCV") modify
//Atrial Fibrillation
stcox prx_covvalue_g_i13
matrix a=r(table)
putexcel A25=("AFib") B25=(a[1,1]) C25=(a[2,1]) D25=(a[4,1]) E25=(a[5,1]) F25=(a[6,1]) using Univariate, sheet("MCV") modify
cs allcausemort prx_covvalue_g_i7
putexcel G25=(r(rr)) H25=(r(lb_rr)) I25=(r(ub_rr)) J25=(r(rd)) K25=(r(lb_rd)) L25=(r(ub_rd)) M25=(r(p)) using Univariate, sheet("MCV") modify
//Peripheral Vascular Disease
stcox prx_covvalue_g_i14
matrix a=r(table)
putexcel A26=("PVD") B26=(a[1,1]) C26=(a[2,1]) D26=(a[4,1]) E26=(a[5,1]) F26=(a[6,1]) using Univariate, sheet("MCV") modify
cs allcausemort prx_covvalue_g_i7
putexcel G26=(r(rr)) H26=(r(lb_rr)) I26=(r(ub_rr)) J26=(r(rd)) K26=(r(lb_rd)) L26=(r(ub_rd)) M26=(r(p)) using Univariate, sheet("MCV") modify

//Multivariate analysis
//16 in common with ACM and MCV
stcox age_indexdate prx_testvalue_i275 prx_testvalue_i2163 prx_testvalue_i2175 totservs_g_i prx_servvalue2_h_i i.unqrx i.marital i.gender i.prx_covvalue_g_i4 i.prx_ccivalue_g_i i.prx_covvalue_g_i7 i.prx_covvalue_g_i8 i.prx_covvalue_g_i10 i.prx_covvalue_g_i13 i.prx_covvalue_g_i14, nohr
matrix b=r(table)
matrix c=b'
matrix list c
matrix rownames c = Age HbA1c Totchol HDL DocVisits Hospitalizations 2unqrx 3unqrx 4unqrx 5ungrx 6unqrx 7unqrx 0marital 1marital 2marital 3marital 4marital 5marital 6marital 7marital 8marital 9marital 10marital 1gender 2gender 0smoking 1smoking 2smoking 3smoking 1cci 2cci 3cci 4cci 0stroke 1stroke 0HF 1HF 0angina 1angina 0Afib 1Afib 0PVD 1PVD
local matrownames "Age HbA1c Totchol HDL DocVisits Hospitalizations 2unqrx 3unqrx 4unqrx 5ungrx 6unqrx 7unqrx 0marital 1marital 2marital 3marital 4marital 5marital 6marital 7marital 8marital 9marital 10marital 1gender 2gender 0smoking 1smoking 2smoking 3smoking 1cci 2cci 3cci 4cci 0stroke 1stroke 0HF 1HF 0angina 1angina 0Afib 1Afib 0PVD 1PVD"
forval i=1/43{
local x=`i'+1
local rowname:word `i' of `matrownames'
putexcel A1=("Variable") B1=("p-value") A`x'=("`rowname'") B`x'=(c[`i',4])using Multivariate, sheet("MCV16") modify
}
//19 distinct variables for MCV
stcox age_indexdate prx_testvalue_i275 prx_testvalue_i2163 prx_testvalue_i2175 prx_covvalue_g_i3 totservs_g_i prx_servvalue2_h_i i.unqrx i.imd2010_5 i.marital i.gender i.prx_covvalue_g_i4 i.prx_covvalue_g_i5 i.prx_ccivalue_g_i i.prx_covvalue_g_i7 i.prx_covvalue_g_i8 i.prx_covvalue_g_i10 i.prx_covvalue_g_i13 i.prx_covvalue_g_i14, nohr
matrix b=r(table)
matrix c=b'
matrix list c
matrix rownames c = Age HbA1c Totchol HDL SysBP DocVisits Hospitalizations 2unqrx 3unqrx 4unqrx 5ungrx 6unqrx 7unqrx 1SES 2SES 3SES 4SES 5SES 9SES 0marital 1marital 2marital 3marital 4marital 5marital 6marital 7marital 8marital 9marital 10marital 1gender 2gender 0smoking 1smoking 2smoking 3smoking 0alc 1alc 2alc 3alc 1cci 2cci 3cci 4cci 0stroke 1stroke 0HF 1HF 0angina 1angina 0Afib 1Afib 0PVD 1PVD
local matrownames "Age HbA1c Totchol HDL SysBP DocVisits Hospitalizations 2unqrx 3unqrx 4unqrx 5ungrx 6unqrx 7unqrx 1SES 2SES 3SES 4SES 5SES 9SES 0marital 1marital 2marital 3marital 4marital 5marital 6marital 7marital 8marital 9marital 10marital 1gender 2gender 0smoking 1smoking 2smoking 3smoking 0alc 1alc 2alc 3alc 1cci 2cci 3cci 4cci 0stroke 1stroke 0HF 1HF 0angina 1angina 0Afib 1Afib 0PVD 1PVD"
forval i=1/54{
local x=`i'+1
local rowname:word `i' of `matrownames'
putexcel A1=("Variable") B1=("p-value") A`x'=("`rowname'") B`x'=(c[`i',4])using Multivariate, sheet("MCV19") modify
}

///////////////////////////////////CORRELATION MATRICES//////////////////////////////////////////
//get basic correlation information
correlate age_indexdate prx_testvalue_i275 prx_testvalue_i2163 prx_testvalue_i2175 totservs_g_i prx_servvalue2_h_i unqrx marital gender prx_covvalue_g_i4 prx_ccivalue_g_i prx_covvalue_g_i7 prx_covvalue_g_i8 prx_covvalue_g_i10 prx_covvalue_g_i13 prx_covvalue_g_i14
twoway (scatter prx_testvalue_i2163 age_indexdate, sort) (scatter prx_testvalue_i2175 age_indexdate, sort) (scatter unqrx age_indexdate, sort) (scatter marital age_indexdate, sort) (scatter prx_covvalue_g_i4 age_indexdate, sort) (scatter prx_covvalue_g_i13 age_indexdate, sort)
//set for CV Major and test possible interactions
stset cvmajor_exit, fail(cvmajor) id(patid) origin(seconddate) scale(365.35)

gen totchol_int=round(prx_testvalue_i2163)
gen hdl_int=round(prx_testvalue_i2175)
stcox age_indexdate totchol_int hdl_int unqrx prx_covvalue_g_i4 prx_covvalue_g_i13 c.age_indexdate#totchol_int, nohr
