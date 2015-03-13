//  program:    Data09_clinicalcovariate_a.do
//  task:        Generate variables for clinical markers and comorbidities, NOT LAB covariates (see Data10 for those)
//  project:     Incretins--Comparative mortality and CV outcomes (CPRD)
//  author:     MA \ May 2014 modified by JM \ Jan 2015

clear all
capture log close
set more off
set trace on
log using Data09a.log, replace
timer on 1

// #1 Use data files generated in Data02_Support
// Keep only if eventdate2 is before indexdate.
timer on 2
foreach file in Clinical001_2 Clinical002_2 Clinical003_2 Clinical004_2 Clinical005_2 Clinical006_2 Clinical007_2 Clinical008_2 Clinical009_2 Clinical010_2 Clinical011_2 Clinical012_2 Clinical013_2 {
use `file', clear
sort patid
merge m:1 patid using Dates, keep(match) nogen
keep if eventdate2>studyentrydate_cprd2-365
sort patid
joinby patid adid using Additional, unmatched(master) _merge(Additional_merge)
merge m:1 patid using Patient, keep(match) nogen
compress
save `file'b.dta, replace
}
clear
timer off 2
timer list 2

//Use Clinical files merged with Dates, Additional, and Patient for all subsequent work
foreach file in Clinical001_2b Clinical002_2b Clinical003_2b Clinical004_2b Clinical005_2b Clinical006_2b Clinical007_2b Clinical008_2b Clinical009_2b Clinical010_2b Clinical011_2b Clinical012_2b Clinical013_2b {
use `file', clear
keep patid enttype eventdate2 studyentrydate_cprd2 readcode cohortentrydate indexdate data1 data2
sort patid
//only keep if prior to follow-up
keep if eventdate2<indexdate
//generate covariate type
gen covtype =.
label variable covtype "Covariate type"
label define covtypes 1 "HT" 2 "WT" 3 "SBP" 4 "smoking status" 5 "alcohol abuse" 6 "MI" 7 "Stroke" 8 "Heart Failure" 9 "Arrhytmia" 10 "Angina" 11 "urgent revasc" 12 "Hypertension" 13 "AFib" 14 "PVD"
label values covtype covtypes
//generate nr_data
gen nr_data =.
label var nr_data "Non-redundant data for each covariate"

// #2 Generate variables (continuous and binary) for clinical covariates; restrict to appropriate ranges; assign covtype.
//HEIGHT
//gen continuous
gen height =.
replace height =   data1 if enttype==14
label variable height "Height (m)"
//restrict
replace height =. if height<=1|(height >= 3 & height <.)|(enttype==14 & data1==0)
//eliminate redundancy
bysort patid enttype: egen nr_height=mean(height) if height<.
tempvar dup_ht
qui bysort patid enttype: gen `dup_ht' = cond(_N==1,0,_n)
replace nr_height =. if `dup_ht'>1 & nr_height<.
//gen binary
gen height_b = 0
replace height_b = 1 if nr_height<.
label variable height_b "Height (binary)"
//assign covtype and nr_data
replace covtype = 1 if nr_height <.
replace nr_data = nr_height if covtype==1

//WEIGHT
//gen continuous, restrict to reasonable values, eliminiate redundancy
gen weight =.
replace weight = data1 if enttype==13
label variable weight "Weight value (kg)"
replace weight =. if weight <= 20 | (weight >= 300 & weight <.) | (enttype==13 & data1==0)
tempvar dup_wt dup_mean_wt nr_mean_weight nr_weight
bysort patid enttype eventdate2: egen `nr_weight'=mean(weight) if weight<.
qui bysort patid enttype eventdate2: gen `dup_wt' = cond(_N==1,0,_n)
replace `nr_weight' =. if `dup_wt' >1 & `nr_weight'<.
//gen continuous mean_weight (from the restricted weight variable), eliminate redundancy
qui bysort patid enttype: egen `nr_mean_weight' = mean(`nr_weight') if `nr_weight'<.
qui bysort patid enttyp: gen `dup_mean_wt' = cond(_N==1, 0, _n)
replace `nr_mean_weight'=. if `dup_mean_wt'>1 & `nr_mean_weight'<.
//gen binary based on weight (NOT mean_weight)
gen weight_b = 0
replace weight_b = 1 if `nr_weight'<.
label variable weight_b "Weight (binary)"
//assign covtype
replace covtype = 2 if `nr_weight' <.
replace nr_data = `nr_weight' if covtype==2

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
replace alcohol =   data1 if enttype==5
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
// readcode source: Delaney, BMC Cardiovascular Disorders, 2007 (Additional File 1) --CPRD Diagnostic Codes.xlsx
// ICD-10 source: Quan, Med Care, 2005 (Table 1) --CPRD Diagnostic Codes.xlsx
//CPRD_GOLD
gen myoinfarct_covar_g = 0
replace myoinfarct_covar_g = 1 if regexm(readcode, "323..00|G30X.00|G361.00|G361.00|G362.00|G362.00|4100N|4109TE|4109TM|4119N|14A4.00|3234|G304.00|G308.00|G30y200|G366.00|G366.00|4129MC|4140|G307.00|G34y100|G360.00|G360.00|G305.00|4109CR|4129N|G30..15|G300.00|G344.00|G38..00|4129RE|G302.00|G303.00|4109TL|3235|G301.00|G301000|G31y200|G5y1.00|322..00|322Z.00|G30..17|4149|14A3.00|G381.00|G306.00|G30..00|G30z.00|G32..12|G350.00|4100NA|4109CL|4109N|4109NA|4109NH|4129AM|4109NC|4129NS")
label variable myoinfarct_covar_g "Myocardial infarction (covar) (gold) 1=event 0=no event"
//generate covtype
replace covtype=6 if myoinfarct_covar_g==1

// Stroke
// readcode source: most from Lo Re, PDS, 2012 (Supplemental Appendix B) -- final 12 (OXMIS codes??) from unknown source -- CPRD Diagnostic Codes.xlsx
// ICD-10 source for cerebrovascular disease: Quan, Med Care, 2005 (Table 1), modified to include only hemmorage or infarction -- CPRD Diagnostic Codes.xlsx
//CPRD GOLD
gen stroke_covar_g = 0
replace stroke_covar_g = 1 if regexm(readcode, "I11.0|I21.?|I22.?|I23.?|I24.?|I25.?|I26.?|I40.?|I42.?|I44.?|I45.?|I46.?|I46.1|I47.?|I48.?|I49.?|I50.?|I60.?|I61.?|I62.?|I63.?|I64.?|I65.?|I66.?|I67.0|I67.6|I67.7|I69.?|I70.0|I81|I82.0|I82.3|I82.4x|I82.60|I82.62|I82.A1x|I82.B1x|I82.C1x|I82.890|I82.90")
label variable stroke_covar_g "Stroke (covar) (gold) 1=event 0=noevent"
//gen covtype
replace covtype=7 if stroke_covar_g ==1

// Heart failure
// readcode source: Tzoulaki, BMJ, 2009 (Supplemental Appendix Table 2) CPRD Diagnostic Codes.xlsx
// ICD-10 sourece: Gamble 2011 CircHF (Supplemental- Appendix 1) CPRD Diagnostic Codes.xlsx
//CPRD GOLD
gen heartfail_covar_g = 0
replace heartfail_covar_g = 1 if regexm(readcode, "G580.00|G58..00|G58z.00|8HBE.00|662T.00|662W.00|1O1..00|9Or..00|9Or3.00|662p.00|9Or4.00|9Or0.00|8CL3.00|67D4.00|679X.00|G580400|9Or5.00|9Or2.00|9Or1.00")
label variable heartfail_covar_g "Heart failure (covar) (gold) 1=event 0=noevent"
//gen covtype
replace covtype=8 if heartfail_covar_g ==1

// Cardiac arrhythmia
// readcode source: Huerta, Epidemiology, 2005 (ArticlePlus) CPRD Diagnostic Codes.xlsx
// ICD-10 source: CPRD Diagnostic Codes.xlsx
//CPRD GOLD
gen arrhythmia_covar_g = 0
replace arrhythmia_covar_g = 1 if regexm(readcode, "4279EA|4272D|G575.00|SP11000|G575000|G575z00|G574011,7L1H.13|K3093|328|328Z.00|3283|3282|2241|G571.00|G57yA00|4279AC|G575100|4279E|G574000|G574.00|G574z00|4279GL|G574100|G571.11|4279HV")
label variable arrhythmia_covar_g "Cardiac arrhythmia (covar) (gold) 1=event 0=noevent"
//gen covtype
replace covtype=9 if arrhythmia_covar_g ==1

// Angina (part of coronary artery disease, coded below) **?? just use CAD?
// readcode source: CPRD Diagnostic Codes.xlsx
// ICD-10 source: CPRD Diagnostic Codes.xlsx
//CPRD GOLD
gen angina_covar_g = 0
replace angina_covar_g = 1 if regexm(readcode, ("G33..00|662K000|662K.00|G311.13|12C..14|14A5.00|G311100|12C2.13|388F.00|12C3.13|G33zz00|1226.11|G33z300|G33z.00|G311.11|G33z700|662K300|388E.00|12CL.00|G311400|12CM.00|G330.00|662K100|662K200|A740.00|662Kz00|G311200|12CG.00|12CH.00|12CE.00|AA1..00|12CF.00|G311.14|G331.00|ZR3P.11|G33z600|J083300|G330000|G33z500|ZR37.00|G311300|G331.11|14AJ.00|J421.11|8B27.00|ZR3P.00|AA1z.00|G330z00|J08zD00|3889|A340000|Gyu3000|ZRB1.00"))
label variable angina_covar_g "Angina (covar) (gold) 1=event 0=noevent"
//gen covtype
replace covtype=10 if angina_covar_g ==1

// CV procedures/urgent revascularization==CV procedures
// readcode source: Lo Re, PDS, 2012 (Supplemental Appendix B)
// ICD-10 source: CPRD Diagnostic Codes.xlsx
// OPCS source: CPRD Diagnostic Codes.xlsx
//CPRD GOLD
gen revasc_covar_g = 0
replace revasc_covar_g = 1 if regexm(readcode, "792..00|792..11|7920.00|7920.11|7920000|7920100|7920200|7920300|7920y00|7920z00|7921.00|7921.11|7921000|7921100|7921200|7921300|7921y00|7921z00|7922.00|7922.11|7922000|7922100|7922200|7922300|7922y00|7922z00|7923.00|7923.11|7923000|7923100|7923200|7923300|7923y00|7923z00|7924.00|7924000|7924100|7924200|7924300|7924400|7924500|7924y00|7924z00|7925.00|7925.11|7925000|7925011|7925012|7925100|7925200|7925300|7925311|7925312|7925400|7925y00|7925z00|7926.00|7926000|7926100|7926200|7926300|7926y00|7926z00|7927.00|7927200|7927300|7927y00|7927z00|792b.00|792c.00|792c000|792Cy00|792Cz00|792d.00|792Dy00|792Dz00|792y.00|Sp00300|7927000|7927100|7927400|7927500|7928.00|7928.11|7928000|7928100|7928200|7928300|7928y00|7928z00|7929.00|7929000|7929100|7929111|7929200|7929300|7929400|7929500|7929600|7929y00|7929z00|792a.00|792a000|792b000|792b100|792By00|792Bz00|792z.00|7a1a000|7a54000|7a6g100|Sp01200|7a20.00|7a20000|7a20100|7a20200|7a20300|7a20311|7a20400|7a20500|7a20600|7a20700|7a20y00|7a20z00|7a22.00|7a22000|7a22100|7a22200|7a22300|7a22y00|7a22z00")
label variable revasc_covar_g "Urgent revascularization (covar)/CV procedure (gold) 1=event 0=noevent"
//gen covtype
replace covtype=11 if revasc_covar_g ==1

// Hypertension
// readcode source:
// ICD-10 source:
//CPRD GOLD
gen hypertension_g = 0
replace hypertension_g = 1 if regexm(readcode, "6627|6628|6629|6146200|1JD..00|662..12|662b.00|662c.00|662d.00|662F.00|662G.00|662O.00|662P.00|7Q01.00|7Q01000|7Q01100|7Q01200|7Q01300|8B26.00|8BL0.00|8CR4.00|8HT5.00|8I3N.00|9N03.00|9N1y200|9OI..00|9OI..11|9OI1.00|9OI2.00|9OIA.00|9OIA.11|F282.00|F404200|F421300|F450400|G2...00|G2...11|G20..00|G20..11|G200.00|G201.00|G202.00|G203.00|G20z.00|G20z.11|G21..00|G210.00|G210000|G210100|G211.00|G211000|G211100|G21z.00|G21z000|G21z011|G21z100|G21zz00|G22..00|G220.00|G221.00|G222.00|G22z.00|G22z.11|G23..00|G230.00|G231.00|G232.00|G233.00|G23z.00|G24..00|G240.00|G240000|G240z00|G241.00|G241000|G241z00|G244.00|G24z.00|G24z000|G24z100|G24zz00|G2y..00|G2z..00|G410.00|G41y000|G672.00|G672.11|G8y3.00|Gyu2.00|Gyu2100|J623.00|SLC6.00|SLC6z00|TJC7.00|TJC7z00|U60C511|U60C51A")
label variable hypertension_g "Hypertension (gold) 1=event 0=no event"
//gen covtype
replace covtype=12 if hypertension_g ==1

// Atrial fibrillation
// readcode source:
// ICD-10 source
//CPRD GOLD
gen afib_g = 0
replace afib_g = 1 if regexm(readcode, "3274|G576300|7936900|G573100|14AR.00|793M100|3273|G573000|G573.00|G573200|662S.00|14AN.00|3272|G570000|9Os..00|6A9..00|9hF1.00|G573z00|9Os0.00|9hF..00|G573500|7936A00|9Os1.00|G573300|9Os2.00|G573400|9Os3.00|9Os4.00")
label variable afib_g "Atrial Fibrillation (gold) 1=event 0=no event"
//gen covtype
replace covtype=13 if afib_g ==1

// Peripheral vascular disease
// readcode source:
// ICD-10 source:
//CPRD GOLD
gen pervascdis_g = 0
replace pervascdis_g = 1 if regexm(readcode, "G73zz00|G73z.00|G73..00|G73yz00|7A4B000|7A48z00|7A44000|7A48.14|7A12100|7A48.00|7A4B100|7A48.15|G76z000|7A48000|7A48200|G74y300|7A12300|7A41.00|7A47.16|7A48y00|7A28000|7A41100|G73y.00|7A47.14|7A48600|7A47.00|7A48C00|7A26000|7A48D00|7A48300|7A28100|7A41300|7A48400|7A26700|7A48700|7A41y00|7A26100|7A48.12|7A41z00|7A48.16|7A28C00|7A48.11|7A48500|7A41900|7A41B00|7A47y00|7A47z00|7A47C00|7A41C00|7A47D00|7A41200|7A12000|7A47.13|7A48100|7A41600|7A48800|7A47.15|7A54000|G70..00|G700.00|7A1A000|7A48A00|P76z.00|SP12z00|7A6H400|7A56200|Gyu7400|G73z000|G73z011|16I..00|G73..12")
label variable pervascdis_g "Peripheral Vascular Disease (gold) 1=event 0=no event"
//gen covtype
replace covtype=14 if pervascdis_g ==1

//populate nr_data with co-morbidity binaries
foreach num of numlist 6/14{
replace nr_data=1 if covtype==`num'
}

//Create a varibale for all eligible test dates (i.e. those with real, in-range nr_data)
gen eltestdate2 = .
replace eltestdate2 = eventdate2 if nr_data <. & eventdate2 <.
format eltestdate2 %td

//Drop all duplicates for patients of the same covtype on the same day
bysort patid covtype eltestdate2: gen dupa = cond(_N==1,0,_n)
drop if dupa>1
drop dupa

save `file'_cov, replace
}
clear

////////////////////////////////////SPLIT FOR EACH WINDOW- INDEXDATE, COHORTENTRYDATE, STUDYENTRYDATE_CPRD/////////////////////////////
//INDEXDATE
foreach file in Clinical001_2b_cov Clinical002_2b_cov Clinical003_2b_cov Clinical004_2b_cov Clinical005_2b_cov Clinical006_2b_cov Clinical007_2b_cov Clinical008_2b_cov Clinical009_2b_cov Clinical010_2b_cov Clinical011_2b_cov Clinical012_2b_cov Clinical013_2b_cov {
use `file', clear
//pull out covariate date of interest
bysort patid covtype : egen prx_covdate_g_i = max(eltestdate2) if eltestdate2>=indexdate-365 & eltestdate2<indexdate
format prx_covdate_g_i %td
gen prx_cov_g_i_b = 1 if !missing(prx_covdate_g_i)
//pull out covariate value of interest
bysort patid covtype : gen prx_covvalue_g_i = nr_data if prx_covdate_g_i==eltestdate2

//create counts
tempvar cov_num_un_i_temp
sort patid covtype eltestdate2
by patid covtype: generate cov_num = _n
label var cov_num "Number of each type of covtpe per patid (_n)"
by patid: egen cov_num_un = count(covtype) if cov_num==1
by patid: egen `cov_num_un_i_temp' = count(covtype) if cov_num==1 & eltestdate2>=indexdate-365 & eltestdate2<indexdate
by patid: egen cov_num_un_i = min(`cov_num_un_i_temp')
label var cov_num_un_i "Identifies most recent entry for each covtype in the index window"

//only keep the observations relevant to the current window
drop if prx_covvalue_g_i >=.

//Check for duplicates again- no duplicates found then continue
bysort patid covtype: gen dupa = cond(_N==1,0,_n)
drop if dupa>1
drop dupa

//Rectangularize data
fillin patid covtype

//Fillin the total number of labs in the window of interest
bysort patid: egen totcovs_g_i = total(cov_num_un_i)

//Drop all fields that aren't wanted in the final dta file
keep patid totcovs_g_i covtype prx_covvalue_g_i prx_cov_g_i_b

//Reshape
reshape wide prx_covvalue_g_i prx_cov_g_i_b, i(patid) j(covtype)

//Label and replace missing values with "0" for covvalues
forval i = 4/14	{
replace prx_covvalue_g_i`i' = 0 if prx_covvalue_g_i`i'==.
}
local x=0
local names "Height Weight BP-systolic Status-smoking Status-alcohol MI Stroke HF Arrhythmia Angina Revascularization-urgent Hypertension AFibrillation PVD"
forval i=1/14{
local x=`x'+1
local next:word `x' of `names'
label var prx_covvalue_g_i`i' "Most recent covariate value for: `next' (index window)"
label var prx_cov_g_i_b`i' "Bin indicator for `next' (index window): 1=covariate; 0=not covariate"
}
label var totcovs_g_i "Number of total clinical covariates (index window) (gold)"

//Save and append
if "`file'"=="Clinical001_2b_cov" {
save Clinical_Covariates_i, replace
}
else {
append using Clinical_Covariates_i
save Clinical_Covariates_i, replace
}
}
clear

//COHORTENTRY DATE
foreach file in Clinical001_2b_cov Clinical002_2b_cov Clinical003_2b_cov Clinical004_2b_cov Clinical005_2b_cov Clinical006_2b_cov Clinical007_2b_cov Clinical008_2b_cov Clinical009_2b_cov Clinical010_2b_cov Clinical011_2b_cov Clinical012_2b_cov Clinical013_2b_cov {
use `file', clear
//pull out covariate date of interest
bysort patid covtype : egen prx_covdate_g_c = max(eltestdate2) if eltestdate2>=cohortentrydate-365 & eltestdate2<cohortentrydate
format prx_covdate_g_c %td
gen prx_cov_g_c_b = 1 if !missing(prx_covdate_g_c)
//pull out covariate value of interest
bysort patid covtype: gen prx_covvalue_g_c = nr_data if prx_covdate_g_c==eltestdate2

//create counts
tempvar cov_num_un_c_temp
sort patid covtype eltestdate2
by patid covtype: generate cov_num = _n
label var cov_num "Number of each type of covtpe per patid (_n)"
by patid: egen cov_num_un = count(covtype) if cov_num==1
by patid: egen `cov_num_un_c_temp' = count(covtype) if cov_num==1 & eltestdate2>=cohortentrydate-365 & eltestdate2<cohortentrydate
by patid: egen cov_num_un_c = min(`cov_num_un_c_temp')
label var cov_num_un_c "Identifies most recent entry for each covtype in the cohort entry window"

//only keep the observations relevant to the current window
drop if prx_covvalue_g_c >=.

//Check for duplicates again- no duplicates found then continue
bysort patid covtype: gen dupa = cond(_N==1,0,_n)
drop if dupa>1
drop dupa

//Rectangularize data
fillin patid covtype

//Fillin the total number of labs in the window of interest
capture bysort patid: egen totcovs_g_c = total(cov_num_un_c)

//Drop all fields that aren't wanted in the final dta file
keep patid totcovs_g_c covtype prx_covvalue_g_c prx_cov_g_c_b

//Reshape
reshape wide prx_covvalue_g_c prx_cov_g_c_b, i(patid) j(covtype)

//Label and replace missing values with "0" for covvalues
forval i = 4/14	{
replace prx_covvalue_g_c`i' = 0 if prx_covvalue_g_c`i'==.
}
local x=0
local names "Height Weight BP-systolic Status-smoking Status-alcohol MI Stroke HF Arrhythmia Angina Revascularization-urgent Hypertension AFibrillation PVD"
forval i=1/14{
local x=`x'+1
local next:word `x' of `names'
label var prx_covvalue_g_c`i' "Most recent covariate value for: `next' (cohortent window)"
label var prx_cov_g_c_b`i' "Bin indicator for `next' (cohortent window): 1=covariate; 0=not covariate"
}
label var totcovs_g_c "Number of total clinical covariates (cohortent window) (gold)"
//Save and append
if "`file'"=="Clinical001_2b_cov" {
save Clinical_Covariates_c, replace
}
else {
append using Clinical_Covariates_c
save Clinical_Covariates_c, replace
}
}
clear

//STUDYENTRYDATE_CPRD
foreach file in Clinical001_2b_cov Clinical002_2b_cov Clinical003_2b_cov Clinical004_2b_cov Clinical005_2b_cov Clinical006_2b_cov Clinical007_2b_cov Clinical008_2b_cov Clinical009_2b_cov Clinical010_2b_cov Clinical011_2b_cov Clinical012_2b_cov Clinical013_2b_cov {
use `file', clear
//pull out covariate date of interest
bysort patid covtype : egen prx_covdate_g_s = max(eltestdate2) if eltestdate2>=studyentrydate_cprd2-365 & eltestdate2<studyentrydate_cprd2
format prx_covdate_g_s %td
gen prx_cov_g_s_b = 1 if !missing(prx_covdate_g_s)
//pull out covariate value of interest
bysort patid covtype : gen prx_covvalue_g_s = nr_data if prx_covdate_g_s==eltestdate2

//create counts
tempvar cov_num_un_s_temp
sort patid covtype eltestdate2
by patid covtype: generate cov_num = _n
label var cov_num "Number of each type of covtpe per patid (_n)"
by patid: egen cov_num_un = count(covtype) if cov_num==1
by patid: egen `cov_num_un_s_temp' = count(covtype) if cov_num==1 & eltestdate2>=studyentrydate_cprd2-365 & eltestdate2<studyentrydate_cprd2
by patid: egen cov_num_un_s = min(`cov_num_un_s_temp')
label var cov_num_un_s "Identifies most recent entry for each covtype in the study entry window"

//only keep the observations relevant to the current window
drop if prx_covvalue_g_s >=.

//Check for duplicates again- no duplicates found then continue
bysort patid covtype: gen dupa = cond(_N==1,0,_n)
drop if dupa>1
drop dupa

//Rectangularize data
fillin patid covtype

//Fillin the total number of labs in the window of interest
bysort patid: egen totcovs_g_s = total(cov_num_un_s)

//Drop all fields that aren't wanted in the final dta file
keep patid totcovs_g_s covtype prx_covvalue_g_s prx_cov_g_s_b

//Reshape
reshape wide prx_covvalue_g_s prx_cov_g_s_b, i(patid) j(covtype)

//Label and replace missing values with "0" for covvalues
forval i = 4/14	{
replace prx_covvalue_g_s`i' = 0 if prx_covvalue_g_s`i'==.
}
local x=0
local names "Height Weight BP-systolic Status-smoking Status-alcohol MI Stroke HF Arrhythmia Angina Revascularization-urgent Hypertension AFibrillation PVD"
forval i=1/14{
local x=`x'+1
local next:word `x' of `names'
label var prx_covvalue_g_s`i' "Most recent covariate value for: `next' (studyentry window)"
label var prx_cov_g_s_b`i' "Bin indicator for `next' (studyentry window): 1=covariate; 0=not covariate"
}
label var totcovs_g_s "Number of total clinical covariates (studyentry window) (gold)"

//Save and append
if "`file'"=="Clinical001_2b_cov" {
save Clinical_Covariates_s, replace
}
else {
append using Clinical_Covariates_s
save Clinical_Covariates_s, replace
}
}
clear

////////////////////////////////////CHARLSON ONLY WINDOWS- INDEXDATE, COHORTENTRYDATE, STUDYENTRYDATE_CPRD/////////////////////////////
//INDEXDATE

foreach file in Clinical001_2b_cov Clinical002_2b_cov Clinical003_2b_cov Clinical004_2b_cov Clinical005_2b_cov Clinical006_2b_cov Clinical007_2b_cov Clinical008_2b_cov Clinical009_2b_cov Clinical010_2b_cov Clinical011_2b_cov Clinical012_2b_cov Clinical013_2b_cov {
use `file', clear
keep patid readcode indexdate eventdate2
drop if eventdate2>=indexdate-365 & eventdate2<indexdate
//Save as one appended file to merge back in with other clinical covariates in Data09_c
if "`file'"=="Clinical001_2b_cov" {
save Clinical_cci_i, replace
}
else {
append using Clinical_cci_i
save Clinical_cci_i, replace
}
}

use Clinical_cci_i, clear

// Charlson Comorbidity Index
// Source: Khan et al 2010
//CPRD GOLD

charlsonreadadd readcode, icd(00) idvar(patid) assign0
gen cci_g = 0
replace cci_g = 1 if wcharlsum == 1
replace cci_g = 2 if wcharlsum == 2
replace cci_g = 3 if wcharlsum == 3
replace cci_g = 4 if wcharlsum >= 4 & wcharlsum <.
capture drop ynch* weightch* charlindex smchindx
generate cci_g_b = 0
replace cci_g_b=1 if cci_g >=1 &cci_g!=.
rename cci_g_b prx_cci_g_i_b
rename cci_g prx_ccivalue_g_i
label variable prx_ccivalue_g_i "Charlson Comrbidity Index (index window)(gold) 1=1, 2=2, 3=3, 4>=4"
label var prx_cci_g_i_b "Charlson Comrbidity Index (index window) (gold) 1=event 0 =no event"
label var wcharlsum "Weighted Charlson score, (index window) note diabetes set to==1"
keep patid prx_ccivalue_g_i prx_cci_g_i_b wcharlsum
merge 1:1 patid using uts, keep (match using) nogen
replace prx_ccivalue_g_i = 1 if prx_ccivalue_g_i==.
replace prx_cci_g_i_b = 0 if prx_cci_g_i_b==.
drop uts2
save Clinical_cci_i, replace

//COHORTENTRYDATE
foreach file in Clinical001_2b_cov Clinical002_2b_cov Clinical003_2b_cov Clinical004_2b_cov Clinical005_2b_cov Clinical006_2b_cov Clinical007_2b_cov Clinical008_2b_cov Clinical009_2b_cov Clinical010_2b_cov Clinical011_2b_cov Clinical012_2b_cov Clinical013_2b_cov {
use `file', clear
keep patid readcode cohortentrydate eventdate2
drop if eventdate2>=cohortentrydate-365 & eventdate2<cohortentrydate
//Save as one appended file to merge back in with other clinical covariates in Data09_c
if "`file'"=="Clinical001_2b_cov" {
save Clinical_cci_c, replace
}
else {
append using Clinical_cci_c
save Clinical_cci_c, replace
}
}
use Clinical_cci_c, clear

// Charlson Comorbidity Index
// Source: Khan et al a2010
//CPRD GOLD

charlsonreadadd readcode, icd(00) idvar(patid) assign0
gen cci_g = 0
replace cci_g = 1 if wcharlsum == 1
replace cci_g = 2 if wcharlsum == 2
replace cci_g = 3 if wcharlsum == 3
replace cci_g = 4 if wcharlsum >= 4 & wcharlsum <.
capture drop ynch* weightch* charlindex smchindx
generate cci_g_b = 0
replace cci_g_b=1 if cci_g >=1 &cci_g!=.
rename cci_g_b prx_cci_g_c_b
rename cci_g prx_ccivalue_g_c
label var prx_ccivalue_g_c "Charlson Comrbidity Index (cohortent window) (gold) 1=1, 2=2, 3=3, 4>=4"
label var prx_cci_g_c_b "Charlson Comrbidity Index (cohortent window) (gold) 1=event 0 =no event"
label var wcharlsum "Weighted Charlson score, (cohortent window) note diabetes set to==1"
keep patid prx_ccivalue_g_c prx_cci_g_c_b wcharlsum

save Clinical_cci_c, replace


//STUDENTRYDATE_CPRD2
foreach file in Clinical001_2b_cov Clinical002_2b_cov Clinical003_2b_cov Clinical004_2b_cov Clinical005_2b_cov Clinical006_2b_cov Clinical007_2b_cov Clinical008_2b_cov Clinical009_2b_cov Clinical010_2b_cov Clinical011_2b_cov Clinical012_2b_cov Clinical013_2b_cov {
use `file', clear
keep patid readcode eltestdate2 studyentrydate_cprd2 eventdate2
drop if eventdate2>=studyentrydate_cprd2-365 & eventdate2<studyentrydate_cprd2
//Save as one appended file to merge back in with other clinical covariates in Data09_c
if "`file'"=="Clinical001_2b_cov" {
save Clinical_cci_s, replace
}
else {
append using Clinical_cci_s
save Clinical_cci_s, replace
}
}
use Clinical_cci_s
// Charlson Comorbidity Index
// Source: Khan et al 2010
//CPRD GOLD

charlsonreadadd readcode, icd(00) idvar(patid) assign0
gen cci_g = 0
replace cci_g = 1 if wcharlsum == 1
replace cci_g = 2 if wcharlsum == 2
replace cci_g = 3 if wcharlsum == 3
replace cci_g = 4 if wcharlsum >= 4 & wcharlsum <.
capture drop ynch* weightch* charlindex smchindx
generate cci_g_b = 0
replace cci_g_b=1 if cci_g >=1 & cci_g!=.
rename cci_g_b prx_cci_g_s_b
rename cci_g prx_ccivalue_g_s
label variable prx_ccivalue_g_s "Charlson Comrbidity Index (studyentry window) (gold) 1=1, 2=2, 3=3, 4>=4"
label var prx_cci_g_s_b "Charlson Comrbidity Index (studyentry window) (gold) 1=event 0 =no event"
label var wcharlsum "Weighted Charlson score, (studyentry window) note diabetes set to==1"
keep patid prx_ccivalue_g_s prx_cci_g_s_b wcharlsum
save Clinical_cci_s, replace

//INDEXDATE2

foreach file in Clinical001_2b_cov Clinical002_2b_cov Clinical003_2b_cov Clinical004_2b_cov Clinical005_2b_cov Clinical006_2b_cov Clinical007_2b_cov Clinical008_2b_cov Clinical009_2b_cov Clinical010_2b_cov Clinical011_2b_cov Clinical012_2b_cov Clinical013_2b_cov {
use `file', clear
keep patid readcode indexdate eventdate2
drop if eventdate2>=indexdate
//Save as one appended file to merge back in with other clinical covariates in Data09_c
if "`file'"=="Clinical001_2b_cov" {
save Clinical_cci_i2, replace
}
else {
append using Clinical_cci_i2
save Clinical_cci_i2, replace
}
}

use Clinical_cci_i2, clear

// Charlson Comorbidity Index
// Source: Khan et al 2010
//CPRD GOLD

charlsonreadadd readcode, icd(00) idvar(patid) assign0
gen cci_g = 0
replace cci_g = 1 if wcharlsum == 1
replace cci_g = 2 if wcharlsum == 2
replace cci_g = 3 if wcharlsum == 3
replace cci_g = 4 if wcharlsum >= 4 & wcharlsum <.
capture drop ynch* weightch* charlindex smchindx
generate cci_g_b = 0
replace cci_g_b=1 if cci_g >=1 &cci_g!=.
rename cci_g_b prx_cci_g_i2_b
rename cci_g prx_ccivalue_g_i2
label variable prx_ccivalue_g_i2 "Charlson Comrbidity Index (index window)(gold) 1=1, 2=2, 3=3, 4>=4"
label var prx_cci_g_i2_b "Charlson Comrbidity Index (index window) (gold) 1=event 0 =no event"
label var wcharlsum "Weighted Charlson score, (index window) note diabetes set to==1"
keep patid prx_ccivalue_g_i2 prx_cci_g_i2_b wcharlsum
merge 1:1 patid using uts, keep (match using) nogen
replace prx_ccivalue_g_i2 = 1 if prx_ccivalue_g_i2==.
replace prx_cci_g_i2_b = 0 if prx_cci_g_i2_b==.
drop uts2
save Clinical_cci_i2, replace

////////////////////////////////////CREATE CLINICAL COVARIATE WEIGHT FILE FOR DATA_10_LABCOVARIATES.DO TO CALL/////////////////////////////

foreach file in Clinical001_2b_cov Clinical002_2b_cov Clinical003_2b_cov Clinical004_2b_cov Clinical005_2b_cov Clinical006_2b_cov Clinical007_2b_cov Clinical008_2b_cov Clinical009_2b_cov Clinical010_2b_cov Clinical011_2b_cov Clinical012_2b_cov Clinical013_2b_cov {
use `file', clear
keep patid weight eltestdate2
bysort patid: egen prx_date = max(eltestdate2)
label var prx_date "Most proximal date"
format prx_date %td
bysort patid: gen prx_weight = weight if eltestdate2==prx_date
keep patid prx_weight
label var prx_weight "Most recent mean weight"
bysort patid: gen dupa = cond(_N==1,0,_n)
drop if dupa>1
drop dupa
rename prx_weight weight
if "`file'"=="Clinical001_2b_cov" {
save ClinicalCovariates_wt, replace
}
else {
append using ClinicalCovariates_wt
save ClinicalCovariates_wt, replace
}
}
foreach file in Clinical001_2b_cov Clinical002_2b_cov Clinical003_2b_cov Clinical004_2b_cov Clinical005_2b_cov Clinical006_2b_cov Clinical007_2b_cov Clinical008_2b_cov Clinical009_2b_cov Clinical010_2b_cov Clinical011_2b_cov Clinical012_2b_cov Clinical013_2b_cov {
erase `file'.dta
}
clear
timer off 1
timer list 1
exit
log close
