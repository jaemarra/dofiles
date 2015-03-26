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
putexcel A1=("Covariate") B1=("p-value") A2=("Age") B2=(a[4,1]) using Univariate, sheet("ACM") modify
//HbA1c
stcox prx_testvalue_i275
matrix a=r(table)
putexcel A3=("HbA1c") B3=(a[4,1]) using Univariate, sheet("ACM") modify
//Number of hospital visits
stcox prx_servvalue2_h_i
matrix a=r(table)
putexcel A4=("Hospitalizations") B4=(a[4,1]) using Univariate, sheet("ACM") modify
//Total Cholesterol
stcox prx_testvalue_i2163
matrix a=r(table)
putexcel A5=("Total Cholesterol") B5=(a[4,1]) using Univariate, sheet("ACM") modify
//HDL
stcox prx_testvalue_i2175
matrix a=r(table)
putexcel A6=("HDL") B6=(a[4,1]) using Univariate, sheet("ACM") modify
//LDL
stcox prx_testvalue_i2177
matrix a=r(table)
putexcel A7=("LDL") B7=(a[4,1]) using Univariate, sheet("ACM") modify
//TG
stcox prx_testvalue_i2202
matrix a=r(table)
putexcel A8=("Triglycerides") B8=(a[4,1]) using Univariate, sheet("ACM") modify
//Systolic blood pressure
stcox prx_covvalue_g_i3
matrix a=r(table)
putexcel A9=("Systolic BP") B9=(a[4,1]) using Univariate, sheet("ACM") modify
//Unqrx
stcox unqrx
matrix a=r(table)
putexcel A10=("Unique ADM Rx") B10=(a[4,1]) using Univariate, sheet("ACM") modify
//Gender
stcox gender
matrix a=r(table)
putexcel A11=("Gender") B11=(a[4,1]) using Univariate, sheet("ACM") modify
//SES
stcox imd2010_5
matrix a=r(table)
putexcel A12=("SES") B12=(a[4,1]) using Univariate, sheet("ACM") modify
//Marital status
stcox marital
matrix a=r(table)
putexcel A13=("Marital Status") B13=(a[4,1]) using Univariate, sheet("ACM") modify
//Smoking Status
stcox prx_covvalue_g_i4
matrix a=r(table)
putexcel A14=("Smoking Status") B14=(a[4,1]) using Univariate, sheet("ACM") modify
//Alcohol Abuse Status
stcox prx_covvalue_g_i5
matrix a=r(table)
putexcel A15=("Alcohol Status") B15=(a[4,1]) using Univariate, sheet("ACM") modify
//Physician Visits
stcox totservs_g_i
matrix a=r(table)
putexcel A16=("Physician Visits") B16=(a[4,1]) using Univariate, sheet("ACM") modify
//Charlson Comorbidity Score
stcox prx_ccivalue_g_i
matrix a=r(table)
putexcel A17=("CCI") B17=(a[4,1]) using Univariate, sheet("ACM") modify
//MI
stcox prx_covvalue_g_i6
matrix a=r(table)
putexcel A18=("MI") B18=(a[4,1]) using Univariate, sheet("ACM") modify
//Stroke
stcox prx_covvalue_g_i7
matrix a=r(table)
putexcel A19=("Stroke") B19=(a[4,1]) using Univariate, sheet("ACM") modify
//HF
stcox prx_covvalue_g_i8
matrix a=r(table)
putexcel A20=("HF") B20=(a[4,1]) using Univariate, sheet("ACM") modify
//Arrhythmia
stcox prx_covvalue_g_i9
matrix a=r(table)
putexcel A21=("Arrhythmia") B21=(a[4,1]) using Univariate, sheet("ACM") modify
//Angina
stcox prx_covvalue_g_i10
matrix a=r(table)
putexcel A22=("Angina") B22=(a[4,1]) using Univariate, sheet("ACM") modify
//Revascularization
stcox prx_covvalue_g_i11
matrix a=r(table)
putexcel A23=("Urgent Revasc") B23=(a[4,1]) using Univariate, sheet("ACM") modify
//HTN
stcox prx_covvalue_g_i12
matrix a=r(table)
putexcel A24=("HTN") B24=(a[4,1]) using Univariate, sheet("ACM") modify
//Atrial Fibrillation
stcox prx_covvalue_g_i13
matrix a=r(table)
putexcel A25=("AFib") B25=(a[4,1]) using Univariate, sheet("ACM") modify
//Peripheral Vascular Disease
stcox prx_covvalue_g_i14
matrix a=r(table)
putexcel A26=("PVD") B26=(a[4,1]) using Univariate, sheet("ACM") modify

//Multivariate analysis
stcox age_indexdate prx_testvalue_i275 prx_testvalue_i2163 prx_testvalue_i2175 totservs_g_i prx_servvalue2_h_i i.unqrx i.marital i.gender i.prx_covvalue_g_i4 i.prx_ccivalue_g_i i.prx_covvalue_g_i7 i.prx_covvalue_g_i8 i.prx_covvalue_g_i10 i.prx_covvalue_g_i13 i.prx_covvalue_g_i14, nohr
matrix b=r(table)
matrix c=b'
matrix list c
matrix rownames c = Age HbA1c Totchol HDL DocVisits Hospitalizations 2unqrx 3unqrx 4unqrx 5ungrx 6unqrx 7unqrx 0marital 1marital 2marital 3marital 4marital 5marital 6marital 7marital 8marital 9marital 10marital 1gender 2gender 0smoking 1smoking 2smoking 3smoking 1cci 2cci 3cci 4cci 0stroke 1stroke 0HF 1HF 0angina 1angina 0Afib 1Afib 0PVD 1PVD
local matrownames "Age HbA1c Totchol HDL DocVisits Hospitalizations 2unqrx 3unqrx 4unqrx 5ungrx 6unqrx 7unqrx 0marital 1marital 2marital 3marital 4marital 5marital 6marital 7marital 8marital 9marital 10marital 1gender 2gender 0smoking 1smoking 2smoking 3smoking 1cci 2cci 3cci 4cci 0stroke 1stroke 0HF 1HF 0angina 1angina 0Afib 1Afib 0PVD 1PVD"
forval i=1/43{
local x=`i'+1
local rowname:word `i' of `matrownames'
putexcel A1=("Variable") B1=("p-value") A`x'=("`rowname'") B`x'=(c[`i',4])using Multivariate, sheet("ACM") modify
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
putexcel A1=("Covariate") B1=("p-value") A2=("Age") B2=(a[4,1]) using Univariate, sheet("MCV") modify
//HbA1c
stcox prx_testvalue_i275
matrix a=r(table)
putexcel A3=("HbA1c") B3=(a[4,1]) using Univariate, sheet("MCV") modify
//Number of hospital visits
stcox prx_servvalue2_h_i
matrix a=r(table)
putexcel A4=("Hospitalizations") B4=(a[4,1]) using Univariate, sheet("MCV") modify
//Total Cholesterol
stcox prx_testvalue_i2163
matrix a=r(table)
putexcel A5=("Total Cholesterol") B5=(a[4,1]) using Univariate, sheet("MCV") modify
//HDL
stcox prx_testvalue_i2175
matrix a=r(table)
putexcel A6=("HDL") B6=(a[4,1]) using Univariate, sheet("MCV") modify
//LDL
stcox prx_testvalue_i2177
matrix a=r(table)
putexcel A7=("LDL") B7=(a[4,1]) using Univariate, sheet("MCV") modify
//TG
stcox prx_testvalue_i2202
matrix a=r(table)
putexcel A8=("Triglycerides") B8=(a[4,1]) using Univariate, sheet("MCV") modify
//Systolic blood pressure
stcox prx_covvalue_g_i3
matrix a=r(table)
putexcel A9=("Systolic BP") B9=(a[4,1]) using Univariate, sheet("MCV") modify
//Unqrx
stcox unqrx
matrix a=r(table)
putexcel A10=("Unique ADM Rx") B10=(a[4,1]) using Univariate, sheet("MCV") modify
//Gender
stcox gender
matrix a=r(table)
putexcel A11=("Gender") B11=(a[4,1]) using Univariate, sheet("MCV") modify
//SES
stcox imd2010_5
matrix a=r(table)
putexcel A12=("SES") B12=(a[4,1]) using Univariate, sheet("MCV") modify
//Marital status
stcox marital
matrix a=r(table)
putexcel A13=("Marital Status") B13=(a[4,1]) using Univariate, sheet("MCV") modify
//Smoking Status
stcox prx_covvalue_g_i4
matrix a=r(table)
putexcel A14=("Smoking Status") B14=(a[4,1]) using Univariate, sheet("MCV") modify
//Alcohol Abuse Status
stcox prx_covvalue_g_i5
matrix a=r(table)
putexcel A15=("Alcohol Status") B15=(a[4,1]) using Univariate, sheet("MCV") modify
//Physician Visits
stcox totservs_g_i
matrix a=r(table)
putexcel A16=("Physician Visits") B16=(a[4,1]) using Univariate, sheet("MCV") modify
//Charlson Comorbidity Score
stcox prx_ccivalue_g_i
matrix a=r(table)
putexcel A17=("CCI") B17=(a[4,1]) using Univariate, sheet("MCV") modify
//MI
stcox prx_covvalue_g_i6
matrix a=r(table)
putexcel A18=("MI") B18=(a[4,1]) using Univariate, sheet("MCV") modify
//Stroke
stcox prx_covvalue_g_i7
matrix a=r(table)
putexcel A19=("Stroke") B19=(a[4,1]) using Univariate, sheet("MCV") modify
//HF
stcox prx_covvalue_g_i8
matrix a=r(table)
putexcel A20=("HF") B20=(a[4,1]) using Univariate, sheet("MCV") modify
//Arrhythmia
stcox prx_covvalue_g_i9
matrix a=r(table)
putexcel A21=("Arrhythmia") B21=(a[4,1]) using Univariate, sheet("MCV") modify
//Angina
stcox prx_covvalue_g_i10
matrix a=r(table)
putexcel A22=("Angina") B22=(a[4,1]) using Univariate, sheet("MCV") modify
//Revascularization
stcox prx_covvalue_g_i11
matrix a=r(table)
putexcel A23=("Urgent Revasc") B23=(a[4,1]) using Univariate, sheet("MCV") modify
//HTN
stcox prx_covvalue_g_i12
matrix a=r(table)
putexcel A24=("HTN") B24=(a[4,1]) using Univariate, sheet("MCV") modify
//Atrial Fibrillation
stcox prx_covvalue_g_i13
matrix a=r(table)
putexcel A25=("AFib") B25=(a[4,1]) using Univariate, sheet("MCV") modify
//Peripheral Vascular Disease
stcox prx_covvalue_g_i14
matrix a=r(table)
putexcel A26=("PVD") B26=(a[4,1]) using Univariate, sheet("MCV") modify

//Multivariate analysis
stcox age_indexdate prx_testvalue_i275 prx_testvalue_i2163 prx_testvalue_i2175 totservs_g_i prx_servvalue2_h_i i.unqrx i.marital i.gender i.prx_covvalue_g_i4 i.prx_ccivalue_g_i i.prx_covvalue_g_i7 i.prx_covvalue_g_i8 i.prx_covvalue_g_i10 i.prx_covvalue_g_i13 i.prx_covvalue_g_i14, nohr
matrix b=r(table)
matrix c=b'
matrix list c
matrix rownames c = Age HbA1c Totchol HDL DocVisits Hospitalizations 2unqrx 3unqrx 4unqrx 5ungrx 6unqrx 7unqrx 0marital 1marital 2marital 3marital 4marital 5marital 6marital 7marital 8marital 9marital 10marital 1gender 2gender 0smoking 1smoking 2smoking 3smoking 1cci 2cci 3cci 4cci 0stroke 1stroke 0HF 1HF 0angina 1angina 0Afib 1Afib 0PVD 1PVD
local matrownames "Age HbA1c Totchol HDL DocVisits Hospitalizations 2unqrx 3unqrx 4unqrx 5ungrx 6unqrx 7unqrx 0marital 1marital 2marital 3marital 4marital 5marital 6marital 7marital 8marital 9marital 10marital 1gender 2gender 0smoking 1smoking 2smoking 3smoking 1cci 2cci 3cci 4cci 0stroke 1stroke 0HF 1HF 0angina 1angina 0Afib 1Afib 0PVD 1PVD"
forval i=1/43{
local x=`i'+1
local rowname:word `i' of `matrownames'
putexcel A1=("Variable") B1=("p-value") A`x'=("`rowname'") B`x'=(c[`i',4])using Multivariate, sheet("MCV") modify
}
