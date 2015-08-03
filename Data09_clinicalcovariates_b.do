//  program:    Data09_clinicalcovariate_b.do
//  task:		Generate variables for clinical markers and comorbidities, NOT LAB covariates (see Data10 for those)
//  project: 	Incretins--Comparative mortality and CV outcomes (CPRD)
//  author:     MA \ May 2014 modified by JM \ Jan 2015

clear all
capture log close
set more off
set trace on
log using Data09b.log, replace
timer on 1

// #1 Use merged hes files generated in Data02_Support
// Keep only if eventdate2 is before indexdate, drop all non-essential variables for efficiency
use hes.dta
merge m:1 patid using Dates, keep(match using) nogen
keep if eventdate2<indexdate
merge m:1 patid using Patient, keep(match using) nogen
keep patid studyentrydate_cprd2 cohortentrydate indexdate pracid spno duration icd icd_primary opcs eventdate2

//generate covariate type
gen covtype =.
label variable covtype "Covariate type"
label define covtypes 1 "HT" 2 "WT" 3 "SBP" 4 "smoking status" 5 "alcohol abuse" 6 "MI" 7 "Stroke" 8 "Heart Failure" 9 "Arrhytmia" 10 "Angina" 11 "urgent revasc" 12 "Hypertension" 13 "AFib" 14 "PVD"
label values covtype covtypes
gen nr_data = .
label var nr_data "Non-redundant data for each covariate"

//Generate binary variables coding for each COMORBIDITY. Code so 0=no event and 1=event. 
//For each event: generate, replace, label

// HES COVARIATES OF INTEREST
// Myocardial infarction
// ICD-10 source: MODIFIED JULY 2015: Quan, Med Care, 2005 (Table 1) + a few from CDC/NCHS
gen myoinfarct_covar_h = 0 
replace myoinfarct_covar_h = 1 if regexm(icd, "I21.?|I22.?|I25.2")
label variable myoinfarct_covar_h "Myocardial infarction (covar) (hes) 1=event 0=no event"
//populate covtype
replace covtype=6 if myoinfarct_covar_h==1

// Stroke
// ICD-10 source for cerebrovascular disease: Quan, Med Care, 2005 (Table 1), modified to include only hemmorage or infarction -- CPRD Diagnostic Codes.xlsx
gen stroke_covar_h = 0
replace stroke_covar_h = 1 if regexm(icd, "H34.1| I60.?| I61.?| I63.?|I64.?")
label variable stroke_covar_h "Stroke (covar) (hes) 1=event 0=noevent"
//populate covtype
replace covtype=7 if stroke_covar_h ==1

// Heart failure
// ICD-10 sourece: Gamble 2011 CircHF (Supplemental- Appendix 1) CPRD Diagnostic Codes.xlsx
gen heartfail_covar_h = 0
replace heartfail_covar_h = 1 if regexm(icd, "I50.?") 
label variable heartfail_covar_h "Heart failure (covar) (hes) 1=event 0=noevent"
//populate covtype
replace covtype=8 if heartfail_covar_h ==1

// Cardiac arrhythmia
// ICD-10 source: CPRD Diagnostic Codes.xlsx
gen arrhythmia_covar_h = 0
replace arrhythmia_covar_h = 1 if regexm(icd, "I44.1|I44.2|I44.3|I45.6|I45.9|I46.X|I47.X|I48.X|I49.X|R00.0|R00.1|R00.8|T82.1|Z45.0|Z95.0")
label variable arrhythmia_covar_h "Cardiac arrhythmia (covar) (hes) 1=event 0=noevent"
//populate covtype
replace covtype=9 if arrhythmia_covar_h ==1

// Angina (part of coronary artery disease, coded below) **?? just use CAD?
// ICD-10 source: CPRD Diagnostic Codes.xlsx
gen angina_covar_h = 0
replace angina_covar_h = 1 if regexm(icd, "I20.?")
label variable angina_covar_h "Angina (covar) (hes) 1=event 0=noevent"
//populate covtype
replace covtype=10 if angina_covar_h ==1

// CV procedures/urgent revascularization==CV procedures
// ICD-10 source: CPRD Diagnostic Codes.xlsx
// OPCS source: CPRD Diagnostic Codes.xlsx
gen revasc_covar_h = 0
replace revasc_covar_h = 1 if regexm(icd, "K40|K401|K402|K403|K404|K408|K409|K41|K411|K412|K413|K414|K418|K419|K42|K421|K422|K423|K424|K428|K429|K43|K431|K432|K433|K434|K438|K439|K44|K441|K442|K448|K449|K45|K451|K452|K453|K454|K455|K456|K458|K459|K46|K461|K462|K463|K464|K465|K468|K469|K47|K471|K472|K473|K474|K475|K478|K479|K48|K481|K482|K483|K484|K488|K489|K49|K491|K492|K493|K494|K498|K499|K50|K501|K502|K503|K504|K508|K509")
label variable revasc_covar_h "Urgent revascularization (covar)/CV procedure (hes) 1=event 0=noevent"
//OPCS
gen revasc_covar_opcs = 0
replace revasc_covar_opcs = 1 if regexm(icd, "K40|K401|K402|K403|K404|K408|K409|K41|K411|K412|K413|K414|K418|K419|K42|K421|K422|K423|K424|K428|K429|K43|K431|K432|K433|K434|K438|K439|K44|K441|K442|K448|K449|K45|K451|K452|K453|K454|K455|K456|K458|K459|K46|K461|K462|K463|K464|K465|K468|K469|K47|K471|K472|K473|K474|K475|K478|K479|K48|K481|K482|K483|K484|K488|K489|K49|K491|K492|K493|K494|K498|K499|K50|K501|K502|K503|K504|K508|K509")
label variable revasc_covar_opcs "Urgent revascularization (covar)/CV procedure (opcs) 1=event 0=noevent"
//ALL
gen revasc_covar_either = 1 if revasc_covar_h==1|revasc_covar_opcs==1
label variable revasc_covar_either "Urgent revascularization (covar)/CV procedure (all) 1=event 0=noevent"
//populate covtype
replace covtype=11 if revasc_covar_either ==1

// Hypertension
// ICD-10 source:
gen hypertension_h = 0
replace hypertension_h = 1 if regexm(icd, "I11.?|I12.?|I13.?|I15.?")
label variable hypertension_h "Hypertension (hes) 1=event 0=no event"
//gen covtype
replace covtype=12 if hypertension_h ==1

// Atrial fibrillation
// ICD-10 source
gen afib_h = 0
replace afib_h = 1 if regexm(icd, "I48.?")
label variable afib_h "Atrial Fibrillation (hes) 1=event 0=no event"
//gen covtype
replace covtype=13 if afib_h ==1

// Peripheral vascular disease
// ICD-10 source:
//CPRD GOLD
gen pervascdis_h = 0
replace pervascdis_h = 1 if regexm(icd, "I70.x|I71.x|I73.1|I73.8|I73.9|I77.1|I79.0|I79.2|K55.1|K55.8|K55.9|Z95.8|Z95.9")
label variable pervascdis_h "Peripheral Vascular Disease (hes) 1=event 0=no event"
//gen covtype
replace covtype=14 if pervascdis_h ==1

//Hypoglycemia
gen hypo_g = 0
replace hypo_g=1 if regexm(icd, "E15.?|E16.?")
label var hypo_g "Hypoglycemia (gold) 1=event 0=no event"
replace covtype = 15 if hypo_g==1

//End Stage Renal Disease
gen esrd_g = 0
replace esrd_g = 1 if regexm(icd, "T81.502?|T81.512?|T81.592?|T81.522?|T81.532?|T86.19?|T86.10?|T86.11?|T86.12?|T86.13?|T86.9?|E09.22|E09.29|E08.22|E08.29|E10.22|E10.29|E11.22|E11.29|E13.22|E13.29|Z94.0|Z49.0|Z49.01|T82.|Z99.2|N18.6|Z98.85|R88.0|T82.?|E870.2|E871.2|E874.2|Y83.0")
label var esrd_g "End stage renal disease (gold) 1=event 0=no event"
replace covtype = 16 if esrd_g==1

forval i=6/16 {
replace nr_data=1 if covtype==`i'
}

//Create a varibale for all eligible test dates (i.e. those with real, in-range nr_data)
gen eltestdate2 = . 
replace eltestdate2 = eventdate2 if nr_data <. & eventdate2 <.
format eltestdate2 %td

//Drop all duplicates for patients of the same covtype on the same day
tempvar dupa cov_num_un_i_temp cov_num_un_c_temp cov_num_un_s_temp
quietly bysort patid covtype eltestdate2: gen `dupa' = cond(_N==1,0,_n)
drop if `dupa'>1

save hes_cov, replace
clear
////////////////////////////////////SPLIT FOR EACH WINDOW- INDEXDATE, COHORTENTRYDATE, STUDYENTRYDATE_CPRD/////////////////////////////
//INDEXDATE 
use hes_cov, clear
//pull out covariate date of interest
bysort patid covtype : egen prx_covdate_i = max(eltestdate2) if eltestdate2>=indexdate-365 & eltestdate2<indexdate
format prx_covdate_i %td
gen prx_cov_i_b = 1 if !missing(prx_covdate_i)
//pull out covariate value of interest
bysort patid covtype : gen prx_covvalue_i = nr_data if prx_covdate_i==eltestdate2

//create counts
sort patid covtype eltestdate2
by patid covtype: generate cov_num = _n
by patid: egen cov_num_un = count(covtype) if cov_num==1
by patid: egen `cov_num_un_i_temp' = count(covtype) if cov_num==1 & eltestdate2>=indexdate-365 & eltestdate2<indexdate
by patid: egen cov_num_un_i = min(`cov_num_un_i_temp')

//only keep the observations relevant to the current window
drop if prx_covvalue_i >=.

//duplicates report
duplicates report patid covtype

//Rectangularize data
fillin patid covtype

//Fillin the total number of labs in the window of interest
bysort patid: egen totcovs = total(cov_num_un_i)

//Drop all fields that aren't wanted in the final dta file
keep patid totcovs covtype prx_covvalue_i prx_cov_i_b

//Reshape
reshape wide prx_covvalue_i prx_cov_i_b, i(patid) j(covtype)

//Label
label var totcovs "Number of total clinical covariates with information (HES_i)"
label variable prx_covvalue_i6 "Myocardial infarction (covar) (hes) 1=event 0=no event"
label variable prx_cov_i_b6 "Myocardial infarction (covar) (hes) 1=information 0=no information"
label variable prx_covvalue_i7 "Stroke (covar) (hes) 1=event 0=no event"
label variable prx_cov_i_b7 "Stroke (covar) (hes) 1=information 0=no information"
label variable prx_covvalue_i8 "Heart failure (covar) (hes) 1=event 0=no event"
label variable prx_cov_i_b8 "Heart failure (covar) (hes) 1=information 0=no information"
label variable prx_covvalue_i9 "Cardiac arrhythmia (covar) (hes) 1=event 0=no event"
label variable prx_cov_i_b9 "Cardiac arrhythmia (covar) (hes) 1=information 0=no information"
label variable prx_covvalue_i10 "Angina (covar) (hes) 1=event 0=no event"
label variable prx_cov_i_b10 "Angina (covar) (hes) 1=information 0=no information"
label variable prx_covvalue_i11 "Urgent revascularization (procedure) (hes) 1=event 0=no event"
label variable prx_cov_i_b11 "Urgent revascularization (procedure) (hes) 1=information 0=no information"
label variable prx_covvalue_i12 "Hypertension (covar) (hes) 1=event 0=no event"
label variable prx_cov_i_b12 "Hypertension (covar) (hes) 1=information 0=no information"
label variable prx_covvalue_i13 "Atrial Fibrillation (covar) (hes) 1=event 0=no event"
label variable prx_cov_i_b13 "Atrial Fibrillation (covar) (hes) 1=information 0=no information"
label variable prx_covvalue_i14 "Peripheral Vascular Disease (covar) (hes) 1=event 0=no event"
label variable prx_cov_i_b14 "Peripheral Vascular Disease (covar) (hes) 1=information 0=no information"
label variable prx_covvalue_i15 "Hypoglycemia (covar) (hes) 1=event 0=no event"
label variable prx_cov_i_b15 "Hypoglycemia (covar) (hes) 1=information 0=no information"
label variable prx_covvalue_i16 "End Stage Renal Disease (covar) (hes) 1=event 0=no event"
label variable prx_cov_i_b16 "End Stage Renal Disease (covar) (hes) 1=information 0=no information"

save hesCovariates_i, replace

clear

//INDEXDATE  - anytime
use hes_cov, clear
//pull out covariate date of interest
bysort patid covtype : egen prx_covdate_ai = max(eltestdate2) if eltestdate2<indexdate
format prx_covdate_ai %td
gen prx_cov_ai_b = 1 if !missing(prx_covdate_ai)
//pull out covariate value of interest
bysort patid covtype : gen prx_covvalue_ai = nr_data if prx_covdate_ai==eltestdate2

//create counts
sort patid covtype eltestdate2
by patid covtype: generate cov_num = _n
by patid: egen cov_num_un = count(covtype) if cov_num==1
by patid: egen `cov_num_un_i_temp' = count(covtype) if cov_num==1 & eltestdate2<indexdate
by patid: egen cov_num_un_ai = min(`cov_num_un_i_temp')

//only keep the observations relevant to the current window
drop if prx_covvalue_ai >=.

//duplicates report
duplicates report patid covtype

//Rectangularize data
fillin patid covtype

//Fillin the total number of labs in the window of interest
bysort patid: egen totcovs = total(cov_num_un_ai)

//Drop all fields that aren't wanted in the final dta file
keep patid totcovs covtype prx_covvalue_ai prx_cov_ai_b

//Reshape
reshape wide prx_covvalue_ai prx_cov_ai_b, i(patid) j(covtype)

//Label
label var totcovs "Number of total clinical covariates with information (HES_i)"
label variable prx_covvalue_ai6 "Myocardial infarction (covar) (hes) 1=event 0=no event"
label variable prx_cov_ai_b6 "Myocardial infarction (covar) (hes) 1=information 0=no information"
label variable prx_covvalue_ai7 "Stroke (covar) (hes) 1=event 0=no event"
label variable prx_cov_ai_b7 "Stroke (covar) (hes) 1=information 0=no information"
label variable prx_covvalue_ai8 "Heart failure (covar) (hes) 1=event 0=no event"
label variable prx_cov_ai_b8 "Heart failure (covar) (hes) 1=information 0=no information"
label variable prx_covvalue_ai9 "Cardiac arrhythmia (covar) (hes) 1=event 0=no event"
label variable prx_cov_ai_b9 "Cardiac arrhythmia (covar) (hes) 1=information 0=no information"
label variable prx_covvalue_ai10 "Angina (covar) (hes) 1=event 0=no event"
label variable prx_cov_ai_b10 "Angina (covar) (hes) 1=information 0=no information"
label variable prx_covvalue_ai11 "Urgent revascularization (procedure) (hes) 1=event 0=no event"
label variable prx_cov_ai_b11 "Urgent revascularization (procedure) (hes) 1=information 0=no information"
label variable prx_covvalue_ai12 "Hypertension (covar) (hes) 1=event 0=no event"
label variable prx_cov_ai_b12 "Hypertension (covar) (hes) 1=information 0=no information"
label variable prx_covvalue_ai13 "Atrial Fibrillation (covar) (hes) 1=event 0=no event"
label variable prx_cov_ai_b13 "Atrial Fibrillation (covar) (hes) 1=information 0=no information"
label variable prx_covvalue_ai14 "Peripheral Vascular Disease (covar) (hes) 1=event 0=no event"
label variable prx_cov_ai_b14 "Peripheral Vascular Disease (covar) (hes) 1=information 0=no information"
label variable prx_covvalue_ai15 "Hypoglycemia (covar) (hes) 1=event 0=no event"
label variable prx_cov_ai_b15 "Hypoglycemia (covar) (hes) 1=information 0=no information"
label variable prx_covvalue_ai16 "End Stage Renal Disease (covar) (hes) 1=event 0=no event"
label variable prx_cov_ai_b16 "End Stage Renal Disease (covar) (hes) 1=information 0=no information"
save hesCovariates_ai, replace

clear

//COHORTENTRY DATE
use hes_cov
//pull out covariate date of interest
bysort patid covtype : egen prx_covdate_c = max(eltestdate2) if eltestdate2>=cohortentrydate-365 & eltestdate2<cohortentrydate
format prx_covdate_c %td
gen prx_cov_c_b = 1 if !missing(prx_covdate_c)
//pull out covariate value of interest
bysort patid covtype: gen prx_covvalue_c = nr_data if prx_covdate_c==eltestdate2

//create counts
sort patid covtype eltestdate2
by patid covtype: generate cov_num = _n
by patid: egen cov_num_un = count(covtype) if cov_num==1
by patid: egen `cov_num_un_c_temp' = count(covtype) if cov_num==1 & eltestdate2>=cohortentrydate-365 & eltestdate2<cohortentrydate
by patid: egen cov_num_un_c = min(`cov_num_un_c_temp')

//only keep the observations relevant to the current window
drop if prx_covvalue_c >=.

//duplicates report
duplicates report patid covtype

//Rectangularize data
fillin patid covtype

//Fillin the total number of labs in the window of interest
bysort patid: egen totcovs = total(cov_num_un_c)

//Drop all fields that aren't wanted in the final dta file
keep patid totcovs covtype prx_covvalue_c prx_cov_c_b

//Reshape
reshape wide prx_covvalue_c prx_cov_c_b, i(patid) j(covtype)

//Label
label var totcovs "Number of total clinical covariates with information (HES_c)"
label variable prx_covvalue_c6 "Myocardial infarction (covar) (hes) 1=event 0=no event"
label variable prx_cov_c_b6 "Myocardial infarction (covar) (hes) 1=information 0=no information"
label variable prx_covvalue_c7 "Stroke (covar) (hes) 1=event 0=no event"
label variable prx_cov_c_b7 "Stroke (covar) (hes) 1=information 0=no information"
label variable prx_covvalue_c8 "Heart failure (covar) (hes) 1=event 0=no event"
label variable prx_cov_c_b8 "Heart failure (covar) (hes) 1=information 0=no information"
label variable prx_covvalue_c9 "Cardiac arrhythmia (covar) (hes) 1=event 0=no event"
label variable prx_cov_c_b9 "Cardiac arrhythmia (covar) (hes) 1=information 0=no information"
label variable prx_covvalue_c10 "Angina (covar) (hes) 1=event 0=no event"
label variable prx_cov_c_b10 "Angina (covar) (hes) 1=information 0=no information"
label variable prx_covvalue_c11 "Urgent revascularization (procedure) (hes) 1=event 0=no event"
label variable prx_cov_c_b11 "Urgent revascularization (procedure) (hes) 1=information 0=no information"
label variable prx_covvalue_c12 "Hypertension (covar) (hes) 1=event 0=no event"
label variable prx_cov_c_b12 "Hypertension (covar) (hes) 1=information 0=no information"
label variable prx_covvalue_c13 "Atrial Fibrillation (covar) (hes) 1=event 0=no event"
label variable prx_cov_c_b13 "Atrial Fibrillation (covar) (hes) 1=information 0=no information"
label variable prx_covvalue_c14 "Peripheral Vascular Disease (covar) (hes) 1=event 0=no event"
label variable prx_cov_c_b14 "Peripheral Vascular Disease (covar) (hes) 1=information 0=no information"
label variable prx_covvalue_c15 "Hypoglycemia (covar) (hes) 1=event 0=no event"
label variable prx_cov_c_b15 "Hypoglycemia (covar) (hes) 1=information 0=no information"
label variable prx_covvalue_c16 "End Stage Renal Disease (covar) (hes) 1=event 0=no event"
label variable prx_cov_c_b16 "End Stage Renal Disease (covar) (hes) 1=information 0=no information"
save hesCovariates_c, replace
clear

//STUDYENTRYDATE_CPRD
use hes_cov
//pull out covariate date of interest
bysort patid covtype : egen prx_covdate_s = max(eltestdate2) if eltestdate2>=studyentrydate_cprd2-365 & eltestdate2<studyentrydate_cprd2
format prx_covdate_s %td
gen prx_cov_s_b = 1 if !missing(prx_covdate_s)
//pull out covariate value of interest
bysort patid covtype : gen prx_covvalue_s = nr_data if prx_covdate_s==eltestdate2

//create counts
sort patid covtype eltestdate2
by patid covtype: generate cov_num = _n
by patid: egen cov_num_un = count(covtype) if cov_num==1
by patid: egen cov_num_un_s_temp = count(covtype) if cov_num==1 & eltestdate2>=studyentrydate_cprd2-365 & eltestdate2<studyentrydate_cprd2
by patid: egen cov_num_un_s = min(cov_num_un_s_temp)

//only keep the observations relevant to the current window
drop if prx_covvalue_s >=.

//duplicates report
duplicates report patid covtype

//Rectangularize data
fillin patid covtype

//Fillin the total number of labs in the window of interest
bysort patid: egen totcovs = total(cov_num_un_s)

//Drop all fields that aren't wanted in the final dta file
keep patid totcovs covtype prx_covvalue_s prx_cov_s_b

//Reshape
reshape wide prx_covvalue_s prx_cov_s_b, i(patid) j(covtype)

//Label
label var totcovs "Number of total clinical covariates with information (HES_s)"
label variable prx_covvalue_s6 "Myocardial infarction (covar) (hes) 1=event 0=no event"
label variable prx_cov_s_b6 "Myocardial infarction (covar) (hes) 1=information 0=no information"
label variable prx_covvalue_s7 "Stroke (covar) (hes) 1=event 0=no event"
label variable prx_cov_s_b7 "Stroke (covar) (hes) 1=information 0=no information"
label variable prx_covvalue_s8 "Heart failure (covar) (hes) 1=event 0=no event"
label variable prx_cov_s_b8 "Heart failure (covar) (hes) 1=information 0=no information"
label variable prx_covvalue_s9 "Cardiac arrhythmia (covar) (hes) 1=event 0=no event"
label variable prx_cov_s_b9 "Cardiac arrhythmia (covar) (hes) 1=information 0=no information"
label variable prx_covvalue_s10 "Angina (covar) (hes) 1=event 0=no event"
label variable prx_cov_s_b10 "Angina (covar) (hes) 1=information 0=no information"
label variable prx_covvalue_s11 "Urgent revascularization (procedure) (hes) 1=event 0=no event"
label variable prx_cov_s_b11 "Urgent revascularization (procedure) (hes) 1=information 0=no information"
label variable prx_covvalue_s12 "Hypertension (covar) (hes) 1=event 0=no event"
label variable prx_cov_s_b12 "Hypertension (covar) (hes) 1=information 0=no information"
label variable prx_covvalue_s13 "Atrial Fibrillation (covar) (hes) 1=event 0=no event"
label variable prx_cov_s_b13 "Atrial Fibrillation (covar) (hes) 1=information 0=no information"
label variable prx_covvalue_s14 "Peripheral Vascular Disease (covar) (hes) 1=event 0=no event"
label variable prx_cov_s_b14 "Peripheral Vascular Disease (covar) (hes) 1=information 0=no information"
label variable prx_covvalue_s15 "Hypoglycemia (covar) (hes) 1=event 0=no event"
label variable prx_cov_s_b15 "Hypoglycemia (covar) (hes) 1=information 0=no information"
label variable prx_covvalue_s16 "End Stage Renal Disease (covar) (hes) 1=event 0=no event"
label variable prx_cov_s_b16 "End Stage Renal Disease (covar) (hes) 1=information 0=no information"
save hesCovariates_s, replace
clear

////////////////////////////////////CREATE CHARLSON WINDOWS/////////////////////////////
//INDEXDATE
use hes_cov, clear
keep patid icd icd_primary eventdate2 indexdate
drop if eventdate2>=indexdate-365 & eventdate2<indexdate
// Charlson Comorbidity Index
// Source: Khan et al 2010
//HES ICD10
charlsonreadadd icd icd_primary, icd(10) idvar(patid) assign0
gen cci_h = 0
replace cci_h = 1 if wcharlsum==1
replace cci_h = 2 if wcharlsum==2
replace cci_h = 3 if wcharlsum==3
replace cci_h = 4 if wcharlsum>= 4 & wcharlsum <.
drop ynch* weightch* charlindex smchindx
gen cci_h_b=0
replace cci_h_b = 1 if cci_h >=1 & cci_h <.
rename cci_h_b prx_cci_h_i_b
rename cci_h prx_ccivalue_h_i 
label variable prx_ccivalue_h_i "Charlson Comrbidity Index (hes) 1=1; 2=2, 3=3, 4>=4"
label var prx_cci_h_i_b "Charlson Comrbidity Index (hes) 1=event 0 =no event"
label var wcharlsum "Weighted Charlson score, note diabetes set to==1"
keep patid prx_ccivalue_h_i prx_cci_h_i_b wcharlsum
save hes_cci_i, replace
clear

//COHORTENTRYDATE
use hes_cov, clear
keep patid icd icd_primary eventdate2 cohortentrydate
drop if eventdate2>=cohortentrydate-365 & eventdate2<cohortentrydate
// Charlson Comorbidity Index
// Source: Khan et al 2010
//HES ICD10
charlsonreadadd icd icd_primary, icd(10) idvar(patid) assign0
gen cci_h = 0
replace cci_h = 1 if wcharlsum==1
replace cci_h = 2 if wcharlsum==2
replace cci_h = 3 if wcharlsum==3
replace cci_h = 4 if wcharlsum>= 4 & wcharlsum <.
drop ynch* weightch* charlindex smchindx
gen cci_h_b=0
replace cci_h_b = 1 if cci_h >=1 & cci_h <.
rename cci_h_b prx_cci_h_c_b
rename cci_h prx_ccivalue_h_c 
label variable prx_ccivalue_h_c "Charlson Comrbidity Index (hes) 1=1; 2=2, 3=3, 4>=4"
label var prx_cci_h_c_b "Charlson Comrbidity Index (hes) 1=event 0 =no event"
label var wcharlsum "Weighted Charlson score, note diabetes set to==1"
keep patid prx_ccivalue_h_c prx_cci_h_c_b wcharlsum
save hes_cci_c, replace
clear

//STUDENTRYDATE_CPRD2
use hes_cov, clear
keep patid icd icd_primary eventdate2 studyentrydate_cprd2
drop if eventdate2>=studyentrydate_cprd2-365 & eventdate2<studyentrydate_cprd2
// Charlson Comorbidity Index
// Source: Khan et al 2010
//HES ICD10
charlsonreadadd icd icd_primary, icd(10) idvar(patid) assign0
gen cci_h = 0
replace cci_h = 1 if wcharlsum==1
replace cci_h = 2 if wcharlsum==2
replace cci_h = 3 if wcharlsum==3
replace cci_h = 4 if wcharlsum>= 4 & wcharlsum <.
drop ynch* weightch* charlindex smchindx
gen cci_h_b=0
replace cci_h_b = 1 if cci_h >=1 & cci_h <.
rename cci_h_b prx_cci_h_s_b
rename cci_h prx_ccivalue_h_s 
label variable prx_ccivalue_h_s "Charlson Comrbidity Index (hes) 1=1; 2=2, 3=3, 4>=4"
label var prx_cci_h_s_b "Charlson Comrbidity Index (hes) 1=event 0 =no event"
label var wcharlsum "Weighted Charlson score, note diabetes set to==1"
keep patid prx_ccivalue_h_s prx_cci_h_s_b wcharlsum
save hes_cci_s, replace
clear

timer off 1
timer list 1
exit
log close

