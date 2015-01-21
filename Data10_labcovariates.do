//  program:    Data10_labCovariates.do
//  task:		Generate variables for lab test covariates (based on Test file)
//  project: 	Incretins--Comparative mortality and CV outcomes (CPRD)
//  author:     MA - May2014 \ modified by JM & JMG Jan 2015

clear all
capture log close
set more off
set trace on
log using Data10.smcl, replace
timer on 1

////// #1 Append all Test Files, Merge Test with Dates, drop un-needed variables

clear all
timer on 2
use Test001
append using Test002 Test003 Test004 Test005 Test006 Test007 Test008 Test009 Test010 Test011 Test012 Test013 Test014, gen(filenum) nolabel
sort patid
merge m:1 patid using Dates, keep(match using) nogen
merge m:1 patid using Demographic, keep(match using) nogen
merge m:1 patid using ClinicalCovariates_wt, keep(match using) nogen			
timer off 2
timer list 2

////// #2 Code for variables of physiological values from lab tests. 
// Within a year prior to studyentrydate, cohortentrydate, indexdate. If more than one within year, value closest to date of interest.

keep if inlist(enttype, 275,163,175,177,202,165,166,152,155,156,158,173)   // need to add other enttype's if adding other labs
save Test, replace
***//CHECK DATA2 FOR REASONABLE VALUE RANGE, DISTRIBUTION, AND UNITS//***
//check for units used in each labtest & distribution
foreach i of num 275,163,175,177,202,165,166,152,155,156,158,173 {
tabulate data3 if enttype==`i'
summarize data2 if enttype==`i'
histogram data2 if enttype==`i', saving(gr`i', replace)
}
***//CREATE CONTINUOUS VARS FOR EACH TEST'S DATA2 WITH ONE UNIT OF MEASUREMENT//***
//HbA1c
gen hba1c = .
//populate with observations reported in percent glycated
replace hba1c = data2 if enttype==275 & data3==1
//confirm that IU is the same as % (pre-IFCC U)
replace hba1c = data2 if enttype==275 & data3==61
//populate with mg/dL converted to percent glycated
replace hba1c= (((data2)+46.7)/28.7) if enttype==275 & data3==82
//populate with mmol/L converted to percent glycated
replace hba1c = (((data2*18)+46.7)/28.7) if enttype==275 & data3==96
//populate with mmol/mol converted to percent glycated
replace hba1c = ((data2*0.09148)+2.152) if enttype==275 & data3==97
//populate with mmol converted to percent glycated
//replace hba1c = ((data2*0.09148)+2.152) if enttype==275 & data3==156
//populate with umol/mol converted to percent glycated
replace hba1c = ((data2*0.09148)+2.152)*1000 if enttype==275 & data3==180
//populate with mmol/mmol converted to percent glycated
replace hba1c = ((data2*0.09148)+2.152)/1000 if enttype==275 & data3==187
//populate with mmol/molHb converted to percent glycated
replace hba1c = ((data2*0.09148)+2.152) if enttype==275 & data3==205
//populate with percent Hb
replace hba1c = data2 if enttype==275 & data3==215
//NORMAL RANGES FROM: www.ccpe-cfpc.com/en/pdf_files/drug_lists/normal_values.pdf
//normal range of hba1c is 4-6% OR <5.7% (normal); 5.7-6.4 (pre-diabetes); >=6.5 (diabetes), 
label variable hba1c "HbA1c value (%)"

// TC
gen totchol = .
//populate with observations reported in % converted to mmol/L (N=16)
//replace totchol = data2 if enttype==163 & data3==1 
//populate with observations reported in mg/dL converted to mmol/L (N=14)
replace totchol = (data2*0.0259) if enttype==163 & data3==82
//populate with observations reported in mmol/L (N=1.2M)
replace totchol = data2 if enttype==163 & data3==96
//populate with observations reported in "ratio" converted to mmol/L (N=155)
//replace totchol = data2 if enttype==163 & data3==151
//NOTE: the observations reported as ratios appear to be redundant reports on same day as data3==96 (mmol/L)
//normal range of total cholesterol is <=5 mmol/L (optimal); 5.18-6.19 mmol/L (boderline); >=6.2 (high risk)
label variable totchol "Total serum cholesterol (mmol/L)"

//HDL
gen hdl = .
//populate with observations reported in mmol/L
replace hdl = data2 if enttype==175 & data3==96
//populate with mg/dL converted to mmol/L NOTE: (n=0 in sample data)
replace hdl = (data2*0.0259) if enttype==175 & data3==82
//populate with pmol/L converted to mmol/L NOTE: (n=0 in sample data)
replace hdl = (data2/1000/1000/1000) if enttype==175 & data3==120
//what do we want to do about HDL with units reported as percent or as "1" N=11 and N=10, respectively??
//normal range of HDL is 1-1.5 mmol/L <1 (greater ri2sk of heart disease); >=1.55 (lower risk of HD)
label variable hdl "HDL value (mmol/L)"

//LDL
gen ldl = .
//populate with observations reported as mmol/L
replace ldl = data2 if enttype==177 & data3==96
//populate with observations in nmol/L converted to mmol/L
replace ldl = (data2*1000) if enttype==177 &data3==110
//populate with observations reported in mg/dL converted to mmol/L NOTE: (n=0 in sample data)
replace ldl = (data2*0.0259) if enttype==177 & data3==82
//populate with observations reported in umol/L converted to mmol/L NOTE: (n=0 in sample data)
replace ldl = (data2/1000) if enttype==177 & data3==142
//normal range of ldl is <2.6 mmol/L (optimal); 2.6-3.3 (near optimal); 3.4-4.1 (boderline); 4.1-4.9 (high) >=5 (very high)
label variable ldl "LDL value (mmol/L)"

//TG
gen tg = .
//populate with observations reported in mmol/L
replace tg = data2 if enttype==202 & data3==96
//populate with mg/dL converted to mmol/L
replace tg = (data2*0.0113) if enttype==202 & data3==82
//normal range of triglycerides is <2.2 mmol/L
label variable tg "Triglycerides value (mmol/L)"

//SCR
gen scr = .
//populate with all serum cretinine observations reported in umol/L
replace scr = data2 if enttype==165 & data3==142
//populated with mg/dL converted to umol/L (N=13)
replace scr = (data2*88.4) if enttype==165 & data3==82
//populated with mg/mmol converted to umol/L (N=16)
//replace scr = (data2*cf) if enttype==165 & data3==86
//populate with mmol/L converted to umol/L (N=3669)
replace scr = (data2*1000) if enttype==165 & data3==96
//populate with mol/L converted to umol/L (N=9760)
replace scr = (data2*1000)*1000 if enttype==165 & data3==99
//populate with nmol/L converted to umol/L (N=2)
replace scr = (data2/1000) if enttype==165 & data3==110
//populate with pmol/L converted to umol/L (N=4)
replace scr = (data2/1000)/1000 if enttype==165 & data3==120
//what do we want to do about serum creatinine reported as /mL (N=25); microU/L (N=349); mmol (N=19)
//normal range of serum creatinine is 50-90 umol/L (women) and 70-120 umol/L (men)
label variable scr "Serum creatinine value (umol/L)"

//CRCL
gen crcl = .
//populate with observations reported in mL/min
replace crcl = data2 if enttype==166 & data3==90 //(N=1350)
//populate with L/min converted to mL/min
replace crcl = (data2*1000) if enttype==166 & data3==71 //(N=865)
//populate with /mL converted to mL/min
//replace crcl = (data2*cf) if enttype==166 & data3==21 (N=35)
//normal range of creatinine clearance is 75-125 mL/min
label variable crcl "Creatinine clearance value (mL/min)"

//ALBUMIN
gen albumin = .
//populate with observations reported in g/L
replace albumin = data2 if enttype==152 & data3==57
//populate with observations reported in mg/L converted to g/L (N=203)
replace albumin = data2/1000 if enttype==152 & data3==83
//populate with observations reported in mg/mmol creatinine = ACR!!!! (N=30)
//replace albumin = data2*cf if enttype==152 & data3==57
//normal range of albumin is 35-50 g/L
label variable albumin "Albumin value (g/L)"

//ALT
gen alt = .
//populate with IU/L
replace alt = data2 if enttype==155 & data3==61 //(N=541449)
//populate with observations reported in % converted to IU/L (N=77)
//replace alt = data2*cf if enttype==155 & data3==1 
//populate with observations reported in IU/d converted to IU/L (N=29)
//replace alt = data2*cf if enttype==155 & data3==60
//populate with observations reported in mmol converted to IU/L (N=441)
//replace alt = data2*cf if enttype==155 & data3==138
//populate with observations reported in per uL converted to IU/L (N=774)
//replace alt = data2*cf if enttype==155 & data3==164
//populate with U/L
replace alt = data2 if enttype==155 & data3==127 //(N=538996)
//normal range for ALT is 3-56 U/L
label variable alt "Alanine aminotransferase (IU/L)"

//AST
gen ast = .
//populate with IU/L
replace ast = data2 if enttype==156 & data3==61
//populate with U/L
replace ast = data2 if enttype==156 & data3==127
//normal range of AST is 0-35 U/L
label variable ast "Aspartate aminotransferase (IU/L)"

//BILIRUBIN
gen bilirubin = .
//populate with umol/L
replace bilirubin = data2 if enttype==158 & data3==142 //(N=1216118)
//populate with mmol/L converted to umol/L
replace bilirubin = (data2*1000) if enttype==158 & data3==96 //(N=1824)
//populate wiht mol/L converted to umol/L
replace bilirubin = (data2*1000)*1000 if enttype==158 & data3==99 //(N=5283)
//populate with mg/dL converted to ummol/L
replace bilirubin = (data2*17.1) if enttype==158 & data3==82 //(N=2)
//what should we do about observations reported in microU/L (N=183); mmol (N=11); m (N=74)??
//normal range of total bilirubin = 5-33 umol/L
label variable bilirubin "Bilirubin (umol/L)"

//HEMOGLOBIN
gen hemoglobin = .
//populate with g/dL
replace hemoglobin = data2 if enttype==173 & data3==56 //(N=804124)
//convert g/L to g/dL
replace hemoglobin = (data2/10) if enttype==173 & data3==57 //(N=147719)
//convert mmol/mol to g/dL
replace hemoglobin = (data2*1.57894) if enttype==173 & data3==97 //(N=981)
//convert mmol/L to g/dL
replace hemoglobin = (data2/0.6206) if enttype==173 & data3==96 //(N=981)
//what should we do about % (n=63) ??
//normal range is 12-15.5 g/dL (women) 13.5-18.5 g/dL (men); 
label variable hemoglobin "Hemoglobin (g/dL)"

***//RESTRICT CONTINUOUS VARS TO ACCEPTABLE RANGE OF VALS & GEN NONREDUNDANT CONTINUOUS VARS//***
//.a "too low" and .b "too high" and .c "missing units" and recombine all non-redundant labs into one variable nr_data2
gen testdate2= .
label var testdate2 "Eventdate2"
replace testdate2=eventdate2
format testdate2 %td
sort patid enttype testdate2
gen nr_data2 = .
label var nr_data2 "Non-redundant data for each enttype"

//HBA1C
replace hba1c =.a if hba1c <= 2
replace hba1c =.b if hba1c >= 25 & hba1c <.
replace hba1c =.c if enttype==275 & data3==0
by patid enttype testdate2: egen nr_hba1c=mean(hba1c) if hba1c<.
replace nr_data2 = nr_hba1c if enttype==275

//TOTCHOL
replace totchol =.a if totchol <= 0.5
replace totchol =.b if totchol >= 12 & totchol <.
replace totchol =.c if enttype==163 & data3==0
by patid enttype testdate2: egen nr_totchol=mean(totchol) if totchol<.
replace nr_data2 = nr_totchol if enttype==163

//HDL
replace hdl =.a if hdl <= 0.25
replace hdl =.b if hdl >= 10 & hdl <.
replace hdl =.c if enttype==175 & data3==0
by patid enttype testdate2: egen nr_hdl=mean(hdl) if hdl<.
replace nr_data2 = nr_hdl if enttype==175

//LDL
replace ldl =.a if ldl <= 0.25
replace ldl =.b if ldl >= 10 & ldl <.
replace ldl =.c if enttype==177 & data3==0
by patid enttype testdate2: egen nr_ldl=mean(ldl) if ldl<.
replace nr_data2 = nr_ldl if enttype==177

//TG
replace tg =.a if tg <= 0.25
replace tg =.b if tg >= 20 & tg <.
replace tg =.c if enttype==202 & data3==0
by patid enttype testdate2: egen nr_tg=mean(tg) if tg<.
replace nr_data2 = nr_tg if enttype==202

//SCR
replace scr =.a if scr <= 26.5
replace scr =.b if scr >= 265 & scr <.
replace scr =.c if enttype==165 & data3==0
by patid enttype testdate2: egen nr_scr=mean(scr) if scr<.
replace nr_data2 = nr_scr if enttype==165

//CRCL
replace crcl =.a if crcl <= 40
replace crcl =.b if crcl >= 420 & crcl <.
replace crcl =.c if enttype==166 & data3==0 //(N=2013)
by patid enttype testdate2: egen nr_crcl=mean(crcl) if crcl<.
replace nr_data2 = nr_crcl if enttype==166

//ALBUMIN
replace albumin =.a if albumin <= 10
replace albumin =.b if albumin >= 120 & albumin <.
replace albumin =.c if enttype==152 & data3==0
by patid enttype testdate2: egen nr_albumin=mean(albumin) if albumin<.
replace nr_data2 = nr_albumin if enttype==152

//ALT
replace alt =.a if alt <= 1
replace alt =.b if alt >= 140 & alt <.
replace alt =.c if enttype==155 & data3==0 //(N=31,633)
by patid enttype testdate2: egen nr_alt=mean(alt) if alt<.
replace nr_data2 = nr_alt if enttype==155

//AST
replace ast =.a if ast <= 0
replace ast =.b if ast >= 120 & ast <.
replace ast =.c if enttype==156 & data3==0
by patid enttype testdate2: egen nr_ast=mean(ast) if ast<.
replace nr_data2 = nr_ast if enttype==156

//BILIRUBIN
replace bilirubin =.a if bilirubin <= 0.5
replace bilirubin =.b if bilirubin >= 40 & bilirubin <.
replace bilirubin =.c if enttype==158 & data3==0 //(N=60218)
by patid enttype testdate2: egen nr_bilirubin=mean(bilirubin) if bilirubin<.
replace nr_data2 = nr_bilirubin if enttype==158

//HEMOGLOBIN
replace hemoglobin =.a if hemoglobin <= 5
replace hemoglobin =.b if hemoglobin >= 25 & hemoglobin <.
replace hemoglobin =.c if enttype==173 & data3==0 //(N=21184)
by patid enttype testdate2: egen nr_hemoglobin=mean(hemoglobin) if hemoglobin<.
replace nr_data2 = nr_hemoglobin if enttype==173

***//ESTIMATE GLOMERULAR FILTRATION RATE//***
//ref for CG and MDRD formulas: http://cjhp-online.ca/index.php/cjhp/article/viewFile/31/30
//Cockcroft-Galt continuous variable in SI units (umol/L, years, kg)
gen testyr = year(testdate2)
gen testage = testyr-birthyear

//USING 90 (MEAN) IN PLACE OF WEIGHT VARIABLE WHERE WEIGHT IS MISSING!!! CHANGE???
gen egfr_cg =.
replace weight = 90 if weight ==.
replace egfr_cg = ((140-testage)*weight*1.2)/nr_scr if sex==0
//multiply by 0.85 for women
replace egfr_cg = (((140-testage)*weight*1.2)/nr_scr)*0.85 if sex==1
label var egfr_cg "Estimated glomerular filtration rate- Cockcroft-Galt method"

//modified CG continuous variable in SI units (umol/L, years)
gen egfr_mcg =.
replace egfr_mcg = ((140-testage)*90)/nr_scr
label var egfr_mcg "Estimated glomerular filtration rate- modified Cockcroft-Galt method"

//abbreviated MDRD continuous variable
gen egfr_amdrd=. 
replace egfr_amdrd = 186.3*((nr_scr/88.4)^-1.154)*testage^-0.203 if sex==0
//multiply by 0.742 for women **note there is a race factor usually included: if race==black (*1.21)
replace egfr_amdrd = (186.3*((nr_scr/88.4)^-1.154)*testage^-0.203)*0.742 if sex==1
label var egfr_amdrd "Estimated glomerular filtration rate- abbreviated MDRD method"

//ref for CKD-EPI formulas: http://www.biomedcentral.com/1471-2318/13/113/table/T1
//CKD-EPI continuous variable
gen egfr_ce=.
//populate with CKD-EPI estimate for males with scr<=80
replace egfr_ce = (141*((nr_scr/88.4/0.7)^-0.411)*(0.993^testage)) if nr_scr<=80 & sex==0
//populate with CKD-EPI estimate for males with scr>80
replace egfr_ce = (141*((nr_scr/88.4/0.7)^-1.209)*(0.993^testage)) if nr_scr>80 & sex==0
//populate with CKD-EPI estimate for females with scr<=62
replace egfr_ce = (144*((nr_scr/88.4/0.7)^-0.329)*(0.993^testage)) if nr_scr<=62 & sex==1
//populate with CKD-EPI estimate for females with scr>62
replace egfr_ce = (144*((nr_scr/88.4/0.7)^-1.209)*(0.993^testage)) if nr_scr>62 & sex==1
label var egfr_ce "Estimated glomerular filtration rate- CKD-EPI method"

***//CREATE CATEGORICAL VARIABLES//***
//CKD (GFR ³90; 89.9-60; 59.9-30; 29.9-15; <15 or dialysis)
// generate the categorical variable for the Cockcroft-Galt eGFR
gen ckd_cg= .
replace ckd_cg=1 if egfr_cg < .  & egfr_cg >= 90
replace ckd_cg=2 if egfr_cg < 90 & egfr_cg >= 60
replace ckd_cg=3 if egfr_cg < 60 & egfr_cg >= 30
replace ckd_cg=4 if egfr_cg < 30 & egfr_cg >= 15
replace ckd_cg=5 if egfr_cg < 15 //do we have a marker for dialysis???
label var ckd_cg "Chronic kidney disease categories using CG eGFR"
//create value labels for ckd 1-5
label define ckd_cg_labels 1 ">=90" 2 "60-89"  3 "30-59" 4 "15-29" 5 "<15"
label values ckd_cg ckd_cg_labels

// generate the categorical variable for the modified Cockcroft-Galt eGFR
gen ckd_mcg= .
replace ckd_mcg=1 if egfr_mcg < .  & egfr_mcg >= 90
replace ckd_mcg=2 if egfr_mcg < 90 & egfr_mcg >= 60
replace ckd_mcg=3 if egfr_mcg < 60 & egfr_mcg >= 30
replace ckd_mcg=4 if egfr_mcg < 30 & egfr_mcg >= 15
replace ckd_mcg=5 if egfr_mcg < 15 //do we have a marker for dialysis???
label var ckd_mcg "Chronic kidney disease categories using mCG eGFR"
//create value labels for ckd 1-5
label define ckd_mcg_labels 1 ">=90" 2 "60-89"  3 "30-59" 4 "15-29" 5 "<15"
label values ckd_mcg ckd_mcg_labels

// generate the categorical variable for the abbreviated MDRD eGFR
gen ckd_amdrd= .
replace ckd_amdrd=1 if egfr_amdrd < .  & egfr_amdrd >= 90
replace ckd_amdrd=2 if egfr_amdrd < 90 & egfr_amdrd >= 60
replace ckd_amdrd=3 if egfr_amdrd < 60 & egfr_amdrd >= 30
replace ckd_amdrd=4 if egfr_amdrd < 30 & egfr_amdrd >= 15
replace ckd_amdrd=5 if egfr_amdrd < 15 //do we have a marker for dialysis???
//create value labels for ckd 1-5
label define ckd_amdrd_labels 1 ">=90" 2 "60-89"  3 "30-59" 4 "15-29" 5 "<15"
label values ckd_amdrd ckd_amdrd_labels

// generate the categorical variable for the CKD-EPI eGFR
gen ckd_ce= .
replace ckd_ce=1 if egfr_ce < .  & egfr_ce >= 90
replace ckd_ce=2 if egfr_ce < 90 & egfr_ce >= 60
replace ckd_ce=3 if egfr_ce < 60 & egfr_ce >= 30
replace ckd_ce=4 if egfr_ce < 30 & egfr_ce >= 15
replace ckd_ce=5 if egfr_ce < 15 //do we have a marker for dialysis???
//create value labels for ckd 1-5
label define ckd_ce_labels 1 ">=90" 2 "60-89"  3 "30-59" 4 "15-29" 5 "<15"
label values ckd_ce ckd_ce_labels

***//CHECK NEW CONTINUOUS AND CATEGORICAL VARS FOR DISTRIBUTION
/*foreach var of varlist egfr_cg egfr_ mcg egfr_amdrd egfr_ce ckd_cg ckd_mcg ckd_amdrd ckd_ce nr*{
summ `var', detail
histogram `var', saving(gr`var', replace)
}*/

***//GENERATE BINARIES//***
//hba1c
gen hba1c_b = 0
replace hba1c_b = 1 if nr_hba1c < .
label variable hba1c_b "HbA1c (binary)"
//totchol
gen totchol_b = 0
replace totchol_b = 1 if nr_totchol < .
label variable totchol_b "Total cholesterol (binary)"
//hdl
gen hdl_b = 0
replace hdl_b = 1 if nr_hdl < .
label variable hdl_b "HDL (binary)"
//ldl
gen ldl_b = 0
replace ldl_b = 1 if nr_ldl < .
label variable ldl_b "LDL (binary)"
//tg
gen tg_b = 0
replace tg_b = 1 if nr_tg < .
label variable tg_b "TG (binary)"
//scr
gen scr_b = 0
replace scr_b =1 if nr_scr < .
label variable scr_b "Serum creatinine (binary)"
//crcl
gen crcl_b = 0
replace crcl_b =1 if nr_crcl < .
label variable crcl_b "Creatinine clearance (binary)"
//albumin
gen albumin_b = 0
replace albumin_b = 1 if nr_albumin < .
label variable albumin_b "Albumin (binary)"
//alt
gen alt_b = 0
replace alt_b = 1 if nr_alt < .
label variable alt_b "Alanine aminotransferase (binary)"
//ast
gen ast_b = 0
replace ast_b = 1 if nr_ast < .
label variable ast_b "Aspartate aminotransferase (binary)"
//bilirubin
gen bilirubin_b = 0
replace bilirubin_b = 1 if nr_bilirubin < .
label variable bilirubin_b "Bilirubin (binary)"
//hemoglobin
gen hemoglobin_b = 0
replace hemoglobin_b = 1 if nr_hemoglobin < .
label variable hemoglobin_b "Hemoglobin (binary)"

//Create a varibale for all eligible test dates (i.e. those with real, in-range nr_data2)
gen eltestdate2 = . 
replace eltestdate2 = testdate2 if nr_data2<. & testdate2 <.
format eltestdate2 %td
label var eltstdate2 "Eventdate2 restricted to dates with eligible, non-redundant data"

//Drop all duplicates in nr_data2
quietly bysort patid enttype eltestdate2: gen dupa = cond(_N==1,0,_n)
drop if dupa>1
drop dupa

save LabCovariates, replace
clear
////////////////////////////////////SPLIT FOR EACH WINDOW- INDEXDATE, COHORTENTRYDATE, STUDYENTRYDATE_CPRD/////////////////////////////
//INDEXDATE
//pull out testdate of interest
use LabCovariates
bysort patid enttype: egen prx_testdate_i = max(eltestdate2) if eltestdate2>=indexdate-365 & eltestdate2<indexdate
format prx_testdate_i %td
gen prx_test_i_b = 1 if !missing(prx_testdate_i)

//pull out lab value of interest
bysort patid enttype : gen prx_testvalue_i = nr_data2 if prx_testdate_i==eltestdate2

//create counts
sort patid enttype eltestdate2
by patid enttype: generate lab_num = _n
by patid: egen lab_num_un = count(enttype) if lab_num==1 

by patid: egen lab_num_un_i_temp = count(enttype) if lab_num==1 & eltestdate2>=indexdate-365 & eltestdate2<indexdate
by patid: egen lab_num_un_i = min(lab_num_un_i_temp)
drop lab_num_un_i_temp

//Create a new variable that numbers enttypes 1-12
tostring enttype, generate(labtype)
encode labtype, generate(labtest)
label drop labtest

//only keep the observations relevant to the current window
drop if prx_testvalue_i >=.

//Check for duplicates again- no duplicates found then continue
bysort patid labtest: gen dupck = cond(_N==1,0,_n)
drop if dupck>1

//Rectangularize data
fillin patid labtest

//Fillin the total number of labs in the window of interest
bysort patid: egen totlabs = total(lab_num)

//Drop all fields that aren't wanted in the final dta file
keep patid totlabs labtest prx_testvalue_i prx_test_i_b

//Reshape
reshape wide prx_testvalue_i prx_test_i_b, i(patid) j(labtest)
label var prx_testvalue_i "Value of most proximal, eligible lab test"
label var prx_test_i_b "Lab test binary; 1=test, 0=no test"

//Save
save LabCovariates_i.dta, replace
clear

//COHORTENTRYDATE
use LabCovariates
bysort patid enttype : egen prx_testdate_c = max(eltestdate2) if eltestdate2>=cohortentrydate-365 & eltestdate2<cohortentrydate
format prx_testdate_c %td
gen prx_test_c_b = 1 if !missing(prx_testdate_c)

//pull out lab value of interest
bysort patid enttype : gen prx_testvalue_c = nr_data2 if prx_testdate_c==eltestdate2

//create counts
sort patid enttype eltestdate2
by patid enttype: generate lab_num = _n
by patid: egen lab_num_un = count(enttype) if lab_num==1 

by patid: egen lab_num_un_c_temp = count(enttype) if lab_num==1 & eltestdate2>=cohortentrydate-365 & eltestdate2<cohortentrydate
by patid: egen lab_num_un_c = min(lab_num_un_c_temp)
drop lab_num_un_c_temp

//Create a new variable that numbers enttypes 1-12
tostring enttype, generate(labtype)
encode labtype, generate(labtest)
label drop labtest

//only keep the observations relevant to the current window
drop if prx_testvalue_c >=.

//Check for duplicates again- no duplicates found then continue
bysort patid labtest: gen dupck = cond(_N==1,0,_n)
drop if dupck>1

//Rectangularize data
fillin patid labtest

//Fillin the total number of labs in the window of interest
bysort patid: egen totlabs = total(lab_num)

//Drop all fields that aren't wanted in the final dta file
keep patid totlabs labtest prx_testvalue_c prx_test_c_b

//Reshape
reshape wide prx_testvalue_c prx_test_c_b, i(patid) j(labtest)
label var prx_testvalue_c "Value of most proximal, eligible lab test"
label var prx_test_c_b "Lab test binary; 1=test, 0=no test"

//Save
save LabCovariates_c, replace
clear

//STUDYENTRYDATE_CPRD
use LabCovariates
bysort patid enttype : egen prx_testdate_s = max(eltestdate2) if eltestdate2>=studyentrydate_cprd2-365 & eltestdate2<studyentrydate_cprd2
format prx_testdate_s %td
gen prx_test_s_b = 1 if !missing(prx_testdate_s)

//pull out lab value of interest
bysort patid enttype : gen prx_testvalue_s = nr_data2 if prx_testdate_s==eltestdate2

//create counts
sort patid enttype eltestdate2
by patid enttype: generate lab_num = _n
by patid: egen lab_num_un = count(enttype) if lab_num==1 

by patid: egen lab_num_un_s_temp = count(enttype) if lab_num==1 & eltestdate2>=studyentrydate_cprd-365 & eltestdate2<studyentrydate_cprd
by patid: egen lab_num_un_s = min(lab_num_un_s_temp)
drop lab_num_un_s_temp

//Create a new variable that numbers enttypes 1-12
tostring enttype, generate(labtype)
encode labtype, generate(labtest)
label drop labtest

//only keep the observations relevant to the current window
drop if prx_testvalue_s >=.

//Check for duplicates again- no duplicates found then continue
bysort patid labtest: gen dupck = cond(_N==1,0,_n)
drop if dupck>1

//Rectangularize data
fillin patid labtest

//Fillin the total number of labs in the window of interest
bysort patid: egen totlabs = total(lab_num)

//Drop all fields that aren't wanted in the final dta file
keep patid totlabs labtest prx_testvalue_s prx_test_s_b

//Reshape
reshape wide prx_testvalue_s prx_test_s_b, i(patid) j(labtest)
label var prx_testvalue_s "Value of most proximal, eligible lab test"
label var prx_test_s_b "Lab test binary; 1= eligible test, 0=no eligible test"

save LabCovariates_s, replace
clear
/////////////////////////////////////////ALTERNATE ENDING ////////////////////////////////////////////
//want one obs per person that shows their values for each lab 	
/*collapse (max) cohortentrydate indexdate studyentrydate studyentrydate_cprd2 maincohort metcohort prx_test_i_b prx_test_c_b prx_test_s_b prx_testvalue_i ///
			prx_testdate_i prx_testvalue_c prx_testdate_c prx_testvalue_s prx_testdate_s lab_num_un lab_num_un_c lab_num_un_i lab_num_un_s hba1c totchol hdl ///
			ldl tg scr crcl albumin alt ast bilirubin hemoglobin uma hba1c_b totchol_b hdl_b ldl_b tg_b scr_b crcl_b ///
			albumin_b alt_b ast_b bilirubin_b hemoglobin_b uma_b, by(patid enttype)	
			
foreach var of varlist hba1c totchol hdl ldl tg scr crcl albumin alt ast bilirubin hemoglobin uma{
by patid: egen `var'2 = min(`var')
	}
	
collapse (max) cohortentrydate indexdate studyentrydate studyentrydate_cprd2 maincohort metcohort prx_test_i_b prx_test_c_b prx_test_s_b prx_testvalue_i ///
			prx_testdate_i prx_testvalue_c prx_testdate_c prx_testvalue_s prx_testdate_s lab_num_un lab_num_un_c lab_num_un_i lab_num_un_s hba1c2 totchol2 hdl2 ///
			ldl2 tg2 scr2 crcl_2 albumin2 alt2 ast2 bilirubin2 hemoglobin2 uma2 hba1c_b totchol_b hdl_b ldl_b tg_b scr_b crcl_b ///
			albumin_b alt_b ast_b bilirubin_b hemoglobin_b uma_b, by(patid)	
compress

save LabCovs.dta, replace

//////////////////////////////////////////////////////////////////////////////////////////////////////
*/

timer off 1 
timer list 1
exit
log close
