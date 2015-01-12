//  program:    Data09_clinicalcovariate_b.do
//  task:		Generate variables for clinical markers and comorbidities, NOT LAB covariates (see Data10 for those)
//  project: 	Incretins--Comparative mortality and CV outcomes (CPRD)
//  author:     MA \ May 2014 modified by JM \ Jan 2015

clear all
capture log close
set more off

log using Data09b.log, replace

// #1 Use data files generated in Data08 (Outcome). 
// Keep only if eventdate2 is before indexdate.

use hes.dta
//only keep if prior to follow-up
keep if eventdate2<indexdate

//generate covariate type
/* COVTYPE KEY: 1=ht, 2=wt, 3=sbp, 4=smoking, 5=alc abuse, 6=MI, 7=stroke, 8=HF, 9=arryth, 10=angina, 11=urgent revasc, 12=HTN,
13=AFIB, 14=PVD 15=CCI*/
gen covtype = .
gen nr_data = .

// #2 Generate variables (continuous and binary) for clinical covariates; restrict to appropriate ranges; assign covtype.
//HEIGHT
//gen continuous
gen height = .
replace height =   data1 if enttype==14
label variable height "Height value (m)"
//restrict
replace height =.a if height <= 1
replace height =.b if height >= 3 & height <.
replace height =.c if enttype==14 & data1==0
//eliminate redundancy
bysort patid enttype: egen nr_height=mean(height) if height<.
qui bysort patid enttype:  gen dup_ht = cond(_N==1,0,_n)
replace nr_height = .d if dup_ht >1 & nr_height<.
drop dup_ht
//gen binary
gen height_b = 0
replace height_b = 1 if nr_height<.
label variable height_b "Height (binary)"
//assign covtype and nr_data
replace covtype = 1 if nr_height <.
replace nr_data = nr_height if covtype==1

//WEIGHT
//gen continuous, restrict to reasonable values, eliminiate redundancy
gen weight = .
replace weight =   data1 if enttype==13
label variable weight "Weight value (kg)"
replace weight =.a if weight <= 20
replace weight =.b if weight >= 300 & weight <.
replace weight =.c if enttype==13 &   data1==0
bysort patid enttype eventdate2: egen nr_weight=mean(weight) if weight<.
qui bysort patid enttype eventdate2: gen dup_wt = cond(_N==1,0,_n)
replace nr_weight = .d if dup_wt>1 & nr_weight<.
drop dup_wt
//gen continuous mean_weight (from the restricted weight variable), eliminate redundancy
qui bysort patid enttype: egen nr_mean_weight = mean(nr_weight) if nr_weight<.
qui bysort patid enttyp: gen dup_mean_wt = cond(_N==1, 0, _n)
replace nr_mean_weight = . if dup_mean_wt>1 & nr_mean_weight<.
drop dup_mean_wt
//gen binary based on weight (NOT mean_weight)
gen weight_b = 0
replace weight_b = 1 if nr_weight<.
label variable weight_b "Weight (binary)"
//assign covtype
replace covtype = 2 if nr_weight <.
replace nr_data = nr_weight if covtype==2

//SYSTOLIC BLOOD PRESSURE
//gen continuous, restrict to reasonable values, eliminiate redundancy
gen sys_bp = .
replace sys_bp =   data2 if enttype==1
label variable sys_bp "Systolic blood pressure value (mmHg)"
replace sys_bp =.a if sys_bp < 60
replace sys_bp =.b if sys_bp > 250 & sys_bp <.
replace sys_bp =.c if enttype==1 &   data1==0
bysort patid enttype eventdate2: egen nr_sys_bp=mean(sys_bp) if sys_bp<.
bysort patid enttype eventdate2: gen dup_bp= cond(_N==1,0,_n)
replace nr_sys_bp=. if dup_bp>1 & nr_sys_bp<.
drop dup_bp
//gen continuous mean_bp (form restricted nr_sys_bp), eliminate redundancy
qui bysort patid enttype: egen nr_mean_sys_bp= mean(nr_sys_bp) if nr_sys_bp <.
qui bysort patid enttyp: gen dup_mean_bp= cond(_N==1, 0, _n)
replace nr_mean_sys_bp =. if dup_mean_bp>1
drop dup_mean_bp
//gen binary
gen sys_bp_b = 0
replace sys_bp_b = 1 if nr_sys_bp <.
label variable sys_bp_b "Systolic BP (binary)"
//assign covtype
replace covtype = 3 if nr_sys_bp <.
replace nr_data = nr_sys_bp if covtype==3

//SMOKING STATUS [Never, Former, Current, Unknown--data not entered or missing] 
//gen categorical, restrict to reasonable values, eliminiate redundancy
gen smoking =.
replace smoking =   data1 if enttype==4
replace smoking = 0 if smoking==. & enttype==4
label variable smoking "Smoking 0=unknown 1=yes 2=no 3=former"
replace smoking =.b if smoking>4  & smoking <.
qui bysort patid enttype eventdate2: egen nr_smoking=max(smoking) if smoking<.
qui bysort patid enttype eventdate2: gen dup_smk= cond(_N==1,0,_n)
replace nr_smoking=. if dup_smk>1 & nr_smoking<.
drop dup_smk
//gen binary
gen smoking_b = 0
replace smoking_b = 1 if nr_smoking <.
label variable smoking_b "Smoking (binary)"
//assign covtype
replace covtype=4 if nr_smoking >= 0 & nr_smoking <.
replace nr_data = nr_smoking if covtype==4

//Alcohol Abuse [Never, Former, Current, Unknown--data not entered or missing]
//gen categorical, restrict to reasonable values, eliminiate redundancy
gen alcohol = .
replace alcohol = data1 if enttype==5
replace alcohol = 0 if alcohol==.& enttype==5
label variable alcohol "Alcohol 0=unknown 1=yes 2=no 3=former"
replace alcohol =.b if alcohol>3  & alcohol <.
by patid enttype eventdate2: egen nr_alcohol=max(alcohol) if alcohol<.
bysort patid enttype eventdate2: gen dup_alc= cond(_N==1,0,_n)
replace nr_alcohol=. if dup_alc>1 & nr_alcohol<.
drop dup_alc
//gen binary
gen alcohol_b = 0
replace alcohol_b = 1 if nr_alcohol <.
label variable alcohol_b "Alcohol (binary)"
//assign covtype
replace covtype=5 if nr_alcohol >= 0 & alcohol <.
replace nr_data = nr_alcohol if covtype==5

////// #3 Generate binary variables coding for each COMORBIDITY. Code so 0=no event and 1=event. For each event: generate, replace, label
// Based on readcode and icd variables

// Myocardial infarction
// ICD-10 source: Quan, Med Care, 2005 (Table 1) --CPRD Diagnostic Codes.xlsx

//HES
gen myoinfarct_covar_h = 0 
replace myoinfarct_covar_h = 1 if regexm(icd, "I21.?|I22.?|I25.2")
label variable myoinfarct_covar_h "Myocardial infarction (covar) (hes) 1=event 0=no event"
//generate covtype
replace covtype=6 if myoinfarct_covar_h==1

// Stroke
// ICD-10 source for cerebrovascular disease: Quan, Med Care, 2005 (Table 1), modified to include only hemmorage or infarction -- CPRD Diagnostic Codes.xlsx
//HES
gen stroke_covar_h = 0
replace stroke_covar_h = 1 if regexm(icd, "H34.1| I60.?| I61.?| I63.?|I64.?")
label variable stroke_covar_h "Stroke (covar) (hes) 1=event 0=noevent"
//gen covtype
replace covtype=7 if stroke_covar_h ==1

// Heart failure
// ICD-10 sourece: Gamble 2011 CircHF (Supplemental- Appendix 1) CPRD Diagnostic Codes.xlsx
//HES
gen heartfail_covar_h = 0
replace heartfail_covar_h = 1 if regexm(icd, "I50.?") 
label variable heartfail_covar_h "Heart failure (covar) (hes) 1=event 0=noevent"
//gen covtype
replace covtype=8 if heartfail_covar_h ==1

// Cardiac arrhythmia
// ICD-10 source: CPRD Diagnostic Codes.xlsx
//HES
gen arrhythmia_covar_h = 0
replace arrhythmia_covar_h = 1 if regexm(icd, "I44.1|I44.2|I44.3|I45.6|I45.9|I46.X|I47.X|I48.X|I49.X|R00.0|R00.1|R00.8|T82.1|Z45.0|Z95.0|")
label variable arrhythmia_covar_h "Cardiac arrhythmia (covar) (hes) 1=event 0=noevent"
//gen covtype
replace covtype=9 if arrhythmia_covar_h ==1

// Angina (part of coronary artery disease, coded below) **?? just use CAD?
// ICD-10 source: CPRD Diagnostic Codes.xlsx
//HES
gen angina_covar_h = 0
replace angina_covar_h = 1 if regexm(icd, "I20.?")
label variable angina_covar_h "Angina (covar) (hes) 1=event 0=noevent"
//gen covtype
replace covtype=10 if angina_covar_h ==1

// CV procedures/urgent revascularization==CV procedures
// ICD-10 source: CPRD Diagnostic Codes.xlsx
// OPCS source: CPRD Diagnostic Codes.xlsx
//HES
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
//gen covtype
replace covtype=11 if revasc_covar_either ==1

// Hypertension
// ICD-10 source:
//HES
gen hypertension_h = 0
replace hypertension_h = 1 if regexm(icd, "I11.?|I12.?|I13.?|I15.?")
label variable hypertension_h "Hypertension (hes) 1=event 0=no event"
//gen covtype
replace covtype=12 if hypertension_h ==1

// Atrial fibrillation
// ICD-10 source
//HES
gen afib_h = 0
replace afib_h = 1 if regexm(icd, "I48.?")
label variable afib_h "Atrial Fibrillation (hes) 1=event 0=no event"
//gen covtype
replace covtype=13 if afib_h ==1

// Peripheral vascular disease
// ICD-10 source:
//CPRD GOLD
//HES
gen pervascdis_h = 0
replace pervascdis_h = 1 if regexm(icd, "I70.x|I71.x|I73.1|I73.8|I73.9|I77.1|I79.0|I79.2|K55.1|K55.8|K55.9|Z95.8|Z95.9")
label variable pervascdis_h "Peripheral Vascular Disease (hes) 1=event 0=no event"
//gen covtype
replace covtype=14 if pervascdis_h ==1

/ Charlson Comorbidity Index
// Source: Khan et al 2010
//HES ICD10
charlsonreadadd icd, icd(10)
gen cci_h = 0
replace cci_h = 1 if wcharlsum == 1
replace cci_h = 2 if wcharlsum == 2
replace cci_h = 3 if wcharlsum == 3
replace cci_h = 4 if wcharlsum >= 4 & wcharlsum <.
label variable cci_h "Charlson Comrbidity Index (hes) 1=1; 2=2, 3=3, 4>=4"
drop ynch* weightch* wcharlsum charlindex smchindx
//gen covtype
replace covtype=15 if cci_h >=0 & cci_h <.
replace nr_data = cci_h if covtype==15

//populate nr_data with co-morbidity binaries
foreach num of numlist 6/14{
replace nr_data=1 if covtype==`num'
}

//Create a varibale for all eligible test dates (i.e. those with real, in-range nr_data)
gen eltestdate2 = . 
replace eltestdate2 = eventdate2 if nr_data <. & eventdate2 <.
format eltestdate2 %td

//Drop all duplicates for patients of the same covtype on the same day
quietly bysort patid covtype eltestdate2: gen dupa = cond(_N==1,0,_n)
drop if dupa>1

save hes_cov, replace
clear
////////////////////////////////////SPLIT FOR EACH WINDOW- INDEXDATE, COHORTENTRYDATE, STUDYENTRYDATE_CPRD/////////////////////////////
//INDEXDATE 
use hes_cov
//pull out test date of interest
bysort patid covtype : egen prx_testdate_i = max(eltestdate2) if eltestdate2>=indexdate-365 & eltestdate2<indexdate
format prx_testdate_i %td
gen prx_test_i_b = 1 if !missing(prx_testdate_i)

//pull out test value of interest
bysort patid covtype : gen prx_testvalue_i = nr_data if prx_testdate_i==eltestdate2

//create counts
sort patid covtype eltestdate2
by patid covtype: generate cov_num = _n
by patid: egen cov_num_un = count(covtype) if cov_num==1 

by patid: egen cov_num_un_i_temp = count(covtype) if cov_num==1 & eltestdate2>=indexdate-365 & eltestdate2<indexdate
by patid: egen cov_num_un_i = min(cov_num_un_i_temp)
drop cov_num_un_i_temp

//Create a new variable that enumerates covtypes
tostring covtype, generate(covariatetype)
encode covariatetype, generate(clincov)
label drop clincov

//only keep the observations relevant to the current window
drop if prx_testvalue_i >=.

/*Check for duplicates again- no duplicates found then continue
quietly bysort patid clincov: gen dupck = cond(_N==1,0,_n)
drop if dupck>1*/

//Rectangularize data
fillin patid clincov

//Fillin the total number of labs in the window of interest
bysort patid: egen totcovs = total(cov_num)

//Drop all fields that aren't wanted in the final dta file
keep patid totcovs clincov prx_testvalue_i prx_test_i_b

//Reshape
reshape wide prx_testvalue_i prx_test_i_b, i(patid) j(clincov)

save hes_cov_i, replace

//COHORTENTRY DATE
//pull out test date of interest
bysort patid covtype : egen prx_testdate_c = max(eltestdate2) if eltestdate2>=cohortentrydate-365 & eltestdate2<cohortentrydate
format prx_testdate_c %td
gen prx_test_c_b = 1 if !missing(prx_testdate_c)

//pull out test value of interest
bysort patid covtype : gen prx_testvalue_c = nr_data if prx_testdate_c==eltestdate2

//create counts
sort patid covtype eltestdate2
by patid covtype: generate int_num = _n
by patid: egen cov_num_un = count(covtype) if cov_num==1 

by patid: egen cov_num_un_c_temp = count(covtype) if cov_num==1 & eltestdate2>=cohortentrydate-365 & eltestdate2<cohortentrydate
by patid: egen cov_num_un_c = min(cov_num_un_c_temp)
drop cov_num_un_c_temp

//Create a new variable that numbers covtypes 1-15
tostring covtype, generate(covariatetype)
encode covariatetype, generate(clincov)
label drop clincov

//only keep the observations relevant to the current window
drop if prx_testvalue_c >=.

/*Check for duplicates again- no duplicates found then continue
quietly bysort patid clincov: gen dupck = cond(_N==1,0,_n)
drop if dupck>1*/

//Rectangularize data
fillin patid clincov

//Fillin the total number of labs in the window of interest
bysort patid: egen totcovs = total(cov_num)

//Drop all fields that aren't wanted in the final dta file
keep patid totcovs clincov prx_testvalue_c prx_test_c_b

//Reshape
reshape wide prx_testvalue_c prx_test_c_b, i(patid) j(clincov)

save Clincovs_cohortentrydate, replace

//STUDYENTRYDATE_CPRD
//pull out test date of interest
bysort patid covtype : egen prx_testdate_s = max(eltestdate2) if eltestdate2>=studyentrydate_cprd2-365 & eltestdate2<studyentrydate_cprd2
format prx_testdate_s %td
gen prx_test_s_b = 1 if !missing(prx_testdate_s)

//pull out test value of interest
bysort patid covtype : gen prx_testvalue_s = nr_data if prx_testdate_s==eltestdate2

//create counts
sort patid covtype eltestdate2
by patid covtype: generate int_num = _n
by patid: egen cov_num_un = count(covtype) if cov_num==1 

by patid: egen cov_num_un_s_temp = count(covtype) if cov_num==1 & eltestdate2>=studyentrydate_cprd2-365 & eltestdate2<studyentrydate_cprd2
by patid: egen cov_num_un_s = min(cov_num_un_s_temp)
drop cov_num_un_s_temp

//Create a new variable that numbers covtypes 1-15
tostring covtype, generate(covariatetype)
encode covariatetype, generate(clincov)
label drop clincov

//only keep the observations relevant to the current window
drop if prx_testvalue_s >=.

/*Check for duplicates again- no duplicates found then continue
quietly bysort patid clincov: gen dupck = cond(_N==1,0,_n)
drop if dupck>1*/

//Rectangularize data
fillin patid clincov

//Fillin the total number of labs in the window of interest
bysort patid: egen totcovs = total(cov_num)

//Drop all fields that aren't wanted in the final dta file
keep patid totcovs clincov prx_testvalue_s prx_test_s_b

//Reshape
reshape wide prx_testvalue_s prx_test_s_b, i(patid) j(clincov)

save Clincovs_studyentrydate_cprd2, replace 

}
exit
log close

