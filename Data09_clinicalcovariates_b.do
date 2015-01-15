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

// #1 Use merged hes files generated in Data02_Support. 
// Keep only if eventdate2 is before indexdate, drop all non-essential variables for efficiency
use hes.dta
merge m:1 patid using Dates, keep(match) nogen
keep if eventdate2<indexdate
keep patid studyentrydate_cprd2 cohortentrydate indexdate pracid spno duration icd icd_primary opcs eventdate2

//generate covariate type
/* COVTYPE KEY: 1=ht, 2=wt, 3=sbp, 4=smoking, 5=alc abuse, 6=MI, 7=stroke, 8=HF, 9=arryth, 10=angina, 11=urgent revasc, 12=HTN,
13=AFIB, 14=PVD 15=CCI*/
gen covtype = .
gen nr_data = .

//Generate binary variables coding for each COMORBIDITY. Code so 0=no event and 1=event. 
//For each event: generate, replace, label

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

// Charlson Comorbidity Index
// Source: Khan et al 2010
//HES ICD10
charlsonreadadd icd icd_primary, icd(10)
gen cci_h = 0
replace cci_h = 1 if charlindex
replace cci_h = 2 if charlindex
replace cci_h = 3 if charlindex
replace cci_h = 4 if charlindex >= 4 & charlindex <.
label variable cci_h "Charlson Comrbidity Index (hes) 1=1; 2=2, 3=3, 4>=4"
drop ynch* weightch* wcharlsum charlindex smchindx
gen cci_h_b = 1 if cci_h >=1 & cci_h <.


foreach num of numlist 6/14 {
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
use hes_cov, clear
//pull out covariate date of interest
bysort patid covtype : egen prx_covdate_i = max(eltestdate2) if eltestdate2>=indexdate-365 & eltestdate2<indexdate
format prx_covdate_i %td
gen prx_cov_i_b = 1 if !missing(prx_covdate_i)
//pull out covariate value of interest
bysort patid covtype : gen prx_covvalue_i = nr_data if prx_covdate_i==eltestdate2
//pull out cci date and value of interest
bysort patid: egen prx_ccidate_i = max(eltestdate2) if eltestdate2>=indexdate-365 & eltestdate2<indexdate
format prx_ccidate_i %td
bysort patid: gen prx_ccivalue_i = cci_h if prx_ccidate_i==eltestdate2
quietly bysort patid prx_ccivalue_i: gen dupck = cond(_N==1,0,_n)
replace prx_ccivalue_i=. if dupck>1
drop dupck

//create counts
sort patid covtype eltestdate2
by patid covtype: generate cov_num = _n
by patid: egen cov_num_un = count(covtype) if cov_num==1
by patid: egen cov_num_un_i_temp = count(covtype) if cov_num==1 & eltestdate2>=indexdate-365 & eltestdate2<indexdate
by patid: egen cov_num_un_i = min(cov_num_un_i_temp)
drop cov_num_un_i_temp

//Create a new variable that numbers covtypes 1-15
tostring covtype, generate(covariatetype)
encode covariatetype, generate(clincov)
label drop clincov

//only keep the observations relevant to the current window
drop if prx_covvalue_i >=.

//Check for duplicates again- no duplicates found then continue
quietly bysort patid clincov: gen dupck = cond(_N==1,0,_n)
drop if dupck>1
drop dupck

//Rectangularize data
fillin patid clincov

//Fillin the total number of labs in the window of interest
bysort patid: egen totcovs = total(cov_num_un_i)

//Drop all fields that aren't wanted in the final dta file
keep patid totcovs clincov prx_covvalue_i prx_cov_i_b

//Reshape
reshape wide prx_covvalue_i prx_cov_i_b, i(patid) j(clincov)

save hesCovariates_i, replace
clear

//COHORTENTRY DATE
use hes_cov
//pull out covariate date of interest
bysort patid covtype : egen prx_covdate_c = max(eltestdate2) if eltestdate2>=cohortentrydate-365 & eltestdate2<cohortentrydate
format prx_covdate_c %td
gen prx_cov_c_b = 1 if !missing(prx_covdate_c)
//pull out covariate value of interest
bysort patid covtype: gen prx_covvalue_c = nr_data if prx_covdate_c==eltestdate2
//pull out cci date and value of interest
bysort patid: egen prx_ccidate_c = max(eltestdate2) if eltestdate2>=cohortentrydate-365 & eltestdate2<cohortentrydate
format prx_ccidate_c %td
bysort patid: gen prx_ccivalue_c = cci_h if prx_ccidate_c==eltestdate2
quietly bysort patid prx_ccivalue_c: gen dupck = cond(_N==1,0,_n)
replace prx_ccivalue_c=. if dupck>1
drop dupck

//create counts
sort patid covtype eltestdate2
by patid covtype: generate cov_num = _n
by patid: egen cov_num_un = count(covtype) if cov_num==1
by patid: egen cov_num_un_c_temp = count(covtype) if cov_num==1 & eltestdate2>=cohortentrydate-365 & eltestdate2<cohortentrydate
by patid: egen cov_num_un_c = min(cov_num_un_c_temp)
drop cov_num_un_c_temp

//Create a new variable that numbers covtypes 1-15
tostring covtype, generate(covariatetype)
encode covariatetype, generate(clincov)
label drop clincov

//only keep the observations relevant to the current window
drop if prx_covvalue_c >=.

//Check for duplicates again- no duplicates found then continue
quietly bysort patid clincov: gen dupck = cond(_N==1,0,_n)
drop if dupck>1

//Rectangularize data
fillin patid clincov

//Fillin the total number of labs in the window of interest
bysort patid: egen totcovs = total(cov_num_un_c)

//Drop all fields that aren't wanted in the final dta file
keep patid totcovs clincov prx_covvalue_c prx_cov_c_b

//Reshape
reshape wide prx_covvalue_c prx_cov_c_b, i(patid) j(clincov)

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
//pull out cci date and value of interest
bysort patid: egen prx_ccidate_s = max(eltestdate2) if eltestdate2>=studyentrydate_cprd2-365 & eltestdate2<studyentrydate_cprd2
format prx_ccidate_s %td
bysort patid: gen prx_ccivalue_s = cci_h if prx_ccidate_s==eltestdate2
quietly bysort patid prx_ccivalue_s: gen dupck = cond(_N==1,0,_n)
replace prx_ccivalue_s=. if dupck>1
drop dupck

//create counts
sort patid covtype eltestdate2
by patid covtype: generate cov_num = _n
by patid: egen cov_num_un = count(covtype) if cov_num==1
by patid: egen cov_num_un_s_temp = count(covtype) if cov_num==1 & eltestdate2>=studyentrydate_cprd2-365 & eltestdate2<studyentrydate_cprd2
by patid: egen cov_num_un_s = min(cov_num_un_s_temp)
drop cov_num_un_s_temp

//Create a new variable that numbers covtypes 1-15
tostring covtype, generate(covariatetype)
encode covariatetype, generate(clincov)
label drop clincov

//only keep the observations relevant to the current window
drop if prx_covvalue_s >=.

//Check for duplicates again- no duplicates found then continue
quietly bysort patid clincov: gen dupck = cond(_N==1,0,_n)
drop if dupck>1

//Rectangularize data
fillin patid clincov

//Fillin the total number of labs in the window of interest
bysort patid: egen totcovs = total(cov_num_un_s)

//Drop all fields that aren't wanted in the final dta file
keep patid totcovs clincov prx_covvalue_s prx_cov_s_b

//Reshape
reshape wide prx_covvalue_s prx_cov_s_b, i(patid) j(clincov)

save hesCovariates_s, replace
clear

////////////////////////////////////CREATE CHARLSON WINDOWS/////////////////////////////
//INDEXDATE
use hes_cov, clear
keep patid cci_h cci_h_b eventdate2 indexdate
drop if eventdate2>=indexdate-365 & eventdate2<indexdate
bysort patid: egen cci = max(cci_h)
drop cci_h eventdate2 indexdate
rename cci cci_h
bysort patid: gen dupa = cond(_N==1,0,_n)
drop if dupa>1
keep patid cci_h cci_h_b
save hes_cci_s, replace
clear

//COHORTENTRYDATE
use hes_cov, clear
keep patid cci_h cci_h_b eventdate2 cohortentrydate
drop if eventdate2>=cohortentrydate-365 & eventdate2<cohortentrydate
bysort patid: egen cci = max(cci_h)
drop cci_h eventdate2 cohortentrydate
rename cci cci_h
bysort patid: gen dupa = cond(_N==1,0,_n)
drop if dupa>1
keep patid cci_h cci_h_b
save hes_cci_s, replace
clear

//STUDENTRYDATE_CPRD2
use hes_cov, clear
keep patid cci_h cci_h_b eventdate2 studyentrydate_cprd2
drop if eventdate2>=studyentrydate_cprd2-365 & eventdate2<studyentrydate_cprd2
bysort patid: egen cci = max(cci_h)
drop cci_h eventdate2 studyentrydate_cprd2
rename cci cci_h
bysort patid: gen dupa = cond(_N==1,0,_n)
drop if dupa>1
keep patid cci_h cci_h_b
save hes_cci_s, replace
clear

timer off 1
timer list 1
exit
log close

