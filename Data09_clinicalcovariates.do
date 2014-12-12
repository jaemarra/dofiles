//  program:    Data09_clinicalcovariate.do
//  task:		Generate variables for clinical markers and comorbidities, NOT LAB covariates (see Data10 for those)
//  project: 	Incretins--Comparative mortality and CV outcomes (CPRD)
//  author:     MA \ May 2014 modified by JM \ November 2014

clear all
capture log close
set more off

log using Data09.log, replace

// #1 Use data files generated in Data08 (Outcome). 
// Keep only if eventdate2 is before indexdate.

foreach file in Clinical001_2 Clinical002_2 Clinical003_2 Clinical004_2 Clinical005_2 Clinical006_2 Clinical007_2 Clinical008_2
				Clinical009_2 Clinical010_2 Clinical011_2 Clinical012_2 Clinical013_2 {
use `file', clear
sort patid
merge m:1 patid using Dates, keep(match) nogen
keep if eventdate2>studyentrydate_cprd2
sort patid
joinby patid adid using Additional, unmatched(master) _merge(Additional_merge)
merge m:1 patid using Patient2, keep(match) nogen
compress
save `file'_merge_ClinCov.dta, replace
}

clear all
//only keep if prior to follow-up
keep if eventdate2<indexdate
drop sysinputclin staffid vmid mob famnum chsreg chsdate prescr capsup ses frd crd accept chsdate2

//generate covariate type
/* COVTYPE KEY: 1=ht, 2=wt, 3=sbp, 4=smoking, 5=alc abuse, 6=MI, 7=stroke, 8=HF, 9=arryth, 10=angina, 11=urgent revasc, 12=metal disorder, 13=HTN, 14=CAD
15=AFIB, 16=PVD, 17=neoplasm, 18=hyperlipidemia, 19=osteopor, 20=COPD, 21=cirrhosis, 22=REM, 23=chronic hepatitis, 24=HIV/AIDS, 25=Rheum Arth, 26=obseity, 
27=transplant, 28=hypoglycemia, 29=retinal photocoag, 30=minor amputation, 31 major amputation, 32 end stage renal failure */

gen covtype = .
gen nr_data = .

// #2 Generate variables (continuous and binary) for clinical covariates; restrict to appropriate ranges; assign covtype.
//HEIGHT
//gen continuous
gen height = .
replace height = ad_data1 if enttype==14
label variable height "Height value (m)"
//restrict
replace height =.a if height <= 1
replace height =.b if height >= 3 & height <.
replace height =.c if enttype==14 & ad_data1==0
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
replace weight = ad_data1 if enttype==13
label variable weight "Weight value (kg)"
replace weight =.a if weight <= 20
replace weight =.b if weight >= 300 & weight <.
replace weight =.c if enttype==13 & ad_data1==0
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
replace sys_bp = ad_data2 if enttype==1
label variable sys_bp "Systolic blood pressure value (mmHg)"
replace sys_bp =.a if sys_bp < 60
replace sys_bp =.b if sys_bp > 250 & sys_bp <.
replace sys_bp =.c if enttype==1 & ad_data1==0
bysort patid enttype eventdate2: egen nr_sys_bp=mean(sys_bp) if nr_sys_bp<.
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
replace smoking = ad_data1 if enttype==4
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
replace alcohol = ad_data1 if enttype==5
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
// readcode source: Delaney, BMC Cardiovascular Disorders, 2007 (Additional File 1)
// ICD-10 source: Quan, Med Care, 2005 (Table 1)
//CPRD_GOLD
gen myoinfarct_covar_g = 0
replace myoinfarct_covar_g = 1 if regexm(readcode, "323..00|G30X.00|G361.00|G361.00|G362.00|G362.00|4100N|4109TE|4109TM|4119N|14A4.00|3234|G304.00|G308.00|G30y200|G366.00|G366.00|4129MC|4140|G307.00|G34y100|G360.00|G360.00|G305.00|4109CR|4129N|G30..15|G300.00|G344.00|G38..00|4129RE|G302.00|G303.00|4109TL|3235|G301.00|G301000|G31y200|G5y1.00|322..00|322Z.00|G30..17|4149|14A3.00|G381.00|G306.00|G30..00|G30z.00|G32..12|G350.00|4100NA|4109CL|4109N|4109NA|4109NH|4129AM|4109NC|4129NS")
label variable myoinfarct_covar_g "Myocardial infarction (covar) (gold) 1=event 0=no event"
//HES
gen myoinfarct_covar_h = 0 
replace myoinfarct_covar_h = 1 if regexm(icd, "I21.?|I22.?|I25.2")
label variable myoinfarct_covar_h "Myocardial infarction (covar) (hes) 1=event 0=no event"
//ALL
gen myoinfarct_covar_all = 1 if myoinfarct_covar_g==1|myoinfarct_covar_h==1
label variable myoinfarct_covar_all "Myocardial infarction (covar) (all) 1=event 0=no event"
//generate covtype
replace covtype=6 if myoinfarct_covar_all==1

// Stroke
// readcode source: most from Lo Re, PDS, 2012 (Supplemental Appendix B) -- final 12 (OXMIS codes??) from unknown source
// ICD-10 source for cerebrovascular disease: Quan, Med Care, 2005 (Table 1), modified to include only hemmorage or infarction
//CPRD GOLD
gen stroke_covar_g = 0
replace stroke_covar_g = 1 if regexm(readcode, "G61..00|G61..11|G61..12|G610.00|G611.00|G612.00|G613.00|G614.00|G615.00|G616.00|G617.00|G618.00|G61X.00|G61X000|G61X100|G61z.00|G63..11|G631.12|G63y000|G64..11|G64..12|G64..13|G640.00|G640000|G64z.00|G64z200|G64z300|G66..00|G66..11|G66..12|G66..13|G667.00|G668.00|G6W..00|G6X..00|Gyu6200|Gyu6300|Gyu6400|Gyu6500|Gyu6600|Gyu6E00|Gyu6F00|Gyu6G00|G31y.00|4369b|1477|4310|4389|4309m|4380|8520m|4300|4309|4350|8520a|4319cr")
label variable stroke_covar_g "Stroke (covar) (gold) 1=event 0=noevent"
//HES
gen stroke_covar_h = 0
replace stroke_covar_h = 1 if regexm(icd, "G45.?|G46.?|H34.0|I60.?ÐI64.?")
label variable stroke_covar_h "Stroke (covar) (hes) 1=event 0=noevent"
//ALL
gen stroke_covar_all = 1 if stroke_covar_g==1|stroke_covar_h==1
label variable stroke_covar_all "Stroke (covar) (all) 1=event 0=noevent" 
//gen covtype
replace covtype=7 if stroke_covar_all ==1

// Heart failure
// readcode source: Tzoulaki, BMJ, 2009 (Supplemental Appendix Table 2)
// ICD-10 sourece: Gamble 2011 CircHF (Supplemental- Appendix 1)
//CPRD GOLD
gen heartfail_covar_g = 0
replace heartfail_covar_g = 1 if regexm(readcode, "G210100|G211100|G21z011|G21z100|G232.00|G234.00|G58..00|G58..11|G580.00|G580.11|G580.12|G580.13|G580.14|G580000|G580100|G580200|G580300|G581.00|G581.11|G581.12|G581.13|G581000|G582.00|G58z.00|G58z.12|G5yy900|G5yyA00")
label variable heartfail_covar_g "Heart failure (covar) (gold) 1=event 0=noevent"
//HES
gen heartfail_covar_h = 0
replace heartfail_covar_h = 1 if regexm(icd, "I50.?") 
label variable heartfail_covar_h "Heart failure (covar) (hes) 1=event 0=noevent"
//ALL
gen heartfail_covar_all = 1 if heartfail_covar_g==1|heartfail_covar_h==1
label variable heartfail_covar_all "Heart failure (covar) (all) 1=event 0=noevent"
//gen covtype
replace covtype=8 if heartfail_covar_all ==1

// Cardiac arrhythmia
// readcode source: Huerta, Epidemiology, 2005 (ArticlePlus) (this paper ID'd from Khan systematic review)
// ICD-10 source:
//CPRD GOLD
gen arrhythmia_covar_g = 0
replace arrhythmia_covar_g = 1 if regexm(readcode, "G57..00|G570.00|G570000|G570100|G570200|G570300|G570z00|G571.00|G57..11|G571.11|G572.00|G572000|G572100|G572z00|G573.00|G573000|G573100|G573200|G573z00|G574.00|G574000|G574011|G574100|G574z00|G576.00|G576000|G576011|G576100|G576.11|G576200|G576300|G576400|G576500|G576z00|G577.00|G57y.00|G57y.14|G57y500|G57y600|G57y700|G57y900|G57yA00|G57yz00|G57z.00|G5yy500|Gyu5A00|R050.00|R050.11|2426|2427|243..11|2432|24B8.00|327..00|328..00|328Z.00|3264|3272|3273|3274|3282|7936A00")
label variable arrhythmia_covar_g "Cardiac arrhythmia (covar) (gold) 1=event 0=noevent"
//HES
gen arrhythmia_covar_h = 0
//replace arrhythmia_covar_h = 1 if regexm(icd, "")
label variable arrhythmia_covar_h "Cardiac arrhythmia (covar) (hes) 1=event 0=noevent"

gen arrhythmia_covar_all = 1 if arrhythmia_covar_g==1|arrhythmia_covar_h==1
label variable arrhythmia_covar_all "Cardiac arrhythmia (covar) (all) 1=event 0=noevent"
//gen covtype
replace covtype=9 if arrhythmia_covar_all ==1

// Angina (part of coronary artery disease, coded below) **?? just use CAD?
// readcode source:
// ICD-10 source:
//CPRD GOLD
gen angina_covar_g = 0
replace angina_covar_g = 1 if regexm(readcode, "" ")
label variable angina_covar_g "Angina (covar) (gold) 1=event 0=noevent"
//HES
gen angina_covar_h = 0
replace angina_covar_h = 1 if regexm(icd, "" ")
label variable angina_covar_h "Angina (covar) (hes) 1=event 0=noevent"
//ALL
gen angina_covar_all = 1 if angina_covar_g==1|angina_covar_h==1
label variable angina_covar_all "Angina (covar) (all) 1=event 0=noevent"
//gen covtype
replace covtype=10 if angina_covar_all ==1

// CV procedures/urgent revascularization==CV procedures
// readcode source: Lo Re, PDS, 2012 (Supplemental Appendix B)
// ICD-10 source:
// OPCS source: 
//CPRD GOLD
gen revasc_covar_g = 0
replace revasc_covar_g = 1 if regexm(readcode, "792..00|792..11|7920|7920.11|7920000|7920100|7920200|7920300|7920y00|7920z00|7921|7921.11|7921000|7921100|7921200|7921300|7921y00|7921z00|7922|7922.11|7922000|7922100|7922200|7922300|7922y00|7922z00|7923|7923.11|7923000|7923100|7923200|7923300|7923y00|7923z00|7924|7924000|7924100|7924200|7924300|7924400|7924500|7924y00|7924z00|7925|7925.11|7925000|7925011|7925012|7925100|7925200|7925300|7925311|7925312|7925400|7925y00|7925z00|7926|7926000|7926100|7926200|7926300|7926y00|7926z00|7927|7927200|7927300|7927y00|7927z00|792B.00|792C.00|792C000|792Cy00|792Cz00|792D.00|792Dy00|792Dz00|792y.00|SP00300|7927000|7927100|7927400|7927500|7928|7928.11|7928000|7928100|7928200|7928300|7928y00|7928z00|7929|7929000|7929100|7929111|7929200|7929300|7929400|7929500|7929600|7929y00|7929z00|792A.00|792A000|792B000|792B100|792By00|792Bz00|792z.00|7A1A000|7A54000|7A6G100|SP01200|7A20.00|7A20000|7A20100|7A20200|7A20300|7A20311|7A20400|7A20500|7A20600|7A20700|7A20y00|7A20z00|7A22.00|7A22000|7A22100|7A22200|7A22300|7A22y00|7A22z00")
label variable revasc_covar_g "Urgent revascularization (covar)/CV procedure (gold) 1=event 0=noevent"
//HES
gen revasc_covar_h = 0
replace revasc_covar_h = 1 if regexm(icd, "")
label variable revasc_covar_h "Urgent revascularization (covar)/CV procedure (hes) 1=event 0=noevent"
//OPCS
gen revasc_covar_opcs = 0
replace revasc_covar_opcs = 1 if regexm(icd, "")
label variable revasc_covar_opcs "Urgent revascularization (covar)/CV procedure (opcs) 1=event 0=noevent"
//ALL
gen revasc_covar_all = 1 if revasc_covar_g==1|revasc_covar_h==1|revasc_covar_opcs==1
label variable revasc_covar_all "Urgent revascularization (covar)/CV procedure (all) 1=event 0=noevent"
//gen covtype
replace covtype=11 if revasc_covar_all ==1

// Mental disorders
// readcode source:
// ICD-10 source:
//CPRD GOLD
gen mentaldis_g = 0
replace mentaldis_g = 1 if regexm(readcode, " ")
label variable mentaldis_g "Mental Disorders (gold) 1=event 0=no event"
//HES
gen mentaldis_h = 0
replace mentaldis_h = 1 if regexm(icd, " ")
label variable mentaldis_h "Mental Disorders (hes) 1=event 0=no event"
//ALL
gen mentaldis_all = 1 if mentaldis_g==1|mentaldis_h==1
label variable mentaldis_all "Mental Disorders (all) 1=event 0=no event" 
//gen covtype
replace covtype=12 if mentaldis_all ==1

// Hypertension
// readcode source:
// ICD-10 source:
//CPRD GOLD
gen hypertension_g = 0
replace hypertension_g = 1 if regexm(readcode, " ")
label variable hypertension_g "Hypertension (gold) 1=event 0=no event"
//HES
gen hypertension_h = 0
replace hypertension_h = 1 if regexm(icd, " ")
label variable hypertension_h "Hypertension (hes) 1=event 0=no event"
//ALL
gen hypertension_all = 1 if hypertension_g==1|hypertension_h==1
label variable hypertension_all "Hypertension (all) 1=event 0=no event"
//gen covtype
replace covtype=13 if hypertension_all ==1

// Coronary artery disease
// readcode source:
// ICD-10 source:
//CPRD GOLD
gen cad_g = 0
replace cad_g = 1 if regexm(readcode, " ")
label variable cad_g "Coronary Artery Disease (gold) 1=event 0=no event"
//HES
gen cad_h = 0
replace cad_h = 1 if regexm(icd, " ")
label variable cad_h "Coronary Artery Disease (hes) 1=event 0=no event"
//ALL
gen cad_all = 1 if cad_g==1|cad_h==1
label variable cad_all "Coronary Artery Disease (all) 1=event 0=no event"
//gen covtype
replace covtype=14 if cad_all ==1

// Atrial fibrillation
// readcode source:
// ICD-10 source
//CPRD GOLD
gen afib_g = 0
replace afib_g = 1 if regexm(readcode, " ")
label variable afib_g "Atrial Fibrillation (gold) 1=event 0=no event"
//HES
gen afib_h = 0
replace afib_h = 1 if regexm(icd, " ")
label variable afib_h "Atrial Fibrillation (hes) 1=event 0=no event"
//ALL
gen afib_all = 1 if afib_g==1|afib_h==1
label variable afib_all "Atrial Fibrillation (all) 1=event 0=no event"
//gen covtype
replace covtype=15 if afib_all ==1

// Peripheral vascular disease
// readcode source:
// ICD-10 source:
//CPRD GOLD
gen pervascdis_g = 0
replace pervascdis_g = 1 if regexm(readcode, " ")
label variable pervascdis_g "Peripheral Vascular Disease (gold) 1=event 0=no event"
//HES
gen pervascdis_h = 0
replace pervascdis_h = 1 if regexm(icd, " ")
label variable pervascdis_h "Peripheral Vascular Disease (hes) 1=event 0=no event"
//ALL
gen pervascdis_all = 1 if pervascdis_g==1|pervascdis_h==1
label variable pervascdis_all "Peripheral Vascular Disease (all) 1=event 0=no event"
//gen covtype
replace covtype=16 if pervascdis_all ==1

// Neoplasms
// readcode source:
// ICD-10 source:
//CPRD GOLD
gen neoplasm_g = 0
replace neoplasm_g = 1 if regexm(readcode, " ")
label variable neoplasm_g "Neoplasm (gold) 1=event 0=no event"
//HES
gen neoplasm_h = 0
replace neoplasm_h = 1 if regexm(icd, " ")
label variable neoplasm_h "Neoplasm (hes) 1=event 0=no event"
//ALL
gen neoplasm_all = 1 if neoplasm_g==1|neoplasm_h==1
label variable neoplasm_all "Neoplasm (all) 1=event 0=no event"
//gen covtype
replace covtype=17 if neoplasm_all ==1

// Hyperlipidemia
// readcode source:
// ICD-10 source:
//CPRD GOLD
gen hyperlipid_g = 0
replace hyperlipid_g = 1 if regexm(readcode, " ")
label variable hyperlipid_g "Hyperlipidemia (gold) 1=event 0 =no event"
//HES
gen hyperlipid_h = 0
replace hyperlipid_h = 1 if regexm(icd, " ")
label variable hyperlipid_h "Hyperlipidemia (hes) 1=event 0 =no event"
//ALL
gen hyperlipid_all = 1 if hyperlipid_g==1|hyperlipid_h==1
label variable hyperlipid_all "Hyperlipidemia (all) 1=event 0 =no event"
//gen covtype
replace covtype=18 if hyperlipid_all ==1

// Osteoporosis
// readcode source:
// ICD-10 source:
//CPRD GOLD
gen osteoporosis_g = 0
replace osteoporosis_g = 1 if regexm(readcode, " ")
label variable osteoporosis_g "Osteoporosis (gold) 1=event 0=no event"
//HES
gen osteoporosis_h = 0
replace osteoporosis_h = 1 if regexm(icd, " ")
label variable osteoporosis_h "Osteoporosis (hes) 1=event 0=no event"
//ALL
gen osteoporosis_all = 1 if osteoporosis_g==1|osteoporosis_h==1
label variable osteoporosis_all "Osteoporosis (all) 1=event 0=no event"
//gen covtype
replace covtype=19 if osteoporosis_all ==1

// Chronic obstructive pulmonary disease
// readcode source:
// ICD-10 source:
//CPRD GOLD
gen copd_g = 0
replace copd_g = 1 if regexm(readcode, " ")
label variable copd_g "Chronic Obstructive Pulmonary Disease (gold) 1=event 0=no event"
//HES
gen copd_h = 0
replace copd_h = 1 if regexm(icd, " ")
label variable copd_h "Chronic Obstructive Pulmonary Disease (hes) 1=event 0=no event"
//ALL
gen copd_all = 1 if copd_g==1|copd_h==1
label variable copd_all "Chronic Obstructive Pulmonary Disease (all) 1=event 0=no event"
//gen covtype
replace covtype=20 if copd_all ==1

// Cirrhosis
// readcode source:
// ICD-10 source:
//CPRD GOLD
gen cirrhosis_g = 0
replace cirrhosis_g = 1 if regexm(readcode, " ")
label variable cirrhosis_g "Cirrhosis (gold) 1=event 0=no event"
//HES
gen cirrhosis_h = 0
replace cirrhosis_h = 1 if regexm(icd, " ")
label variable cirrhosis_h "Cirrhosis (hes) 1=event 0=no event"
//ALL
gen cirrhosis_all = 1 if cirrhosis_g==1|cirrhosis_h==1
label variable cirrhosis_all "Cirrhosis (all) 1=event 0=no event"
//gen covtype
replace covtype=21 if cirrhosis_all ==1

// Dementia
// readcode source:
// ICD-10 source:
//CPRD GOLD
gen dementia_g = 0
replace dementia_g = 1 if regexm(readcode, " ")
label variable dementia_g "Dementia (gold) 1=event 0=no event"
//HES
gen dementia_h = 0
replace dementia_h = 1 if regexm(icd, " ")
label variable dementia_h "Dementia (hes) 1=event 0=no event"
//ALL
gen dementia_all = 1 of dementia_g==1|dementia_h==1
label variable dementia_all "Dementia (all) 1=event 0=no event"
//gen covtype
replace covtype=22 if dementia_all ==1

// Chronic hepatitis
// readcode source:
// ICD-10 source:
//CPRD GOLD
gen chronic_hep_g = 0
replace chronic_hep_g = 1 if regexm(readcode, " ")
label variable chronic_hep_g "Chronic Hepatitis (gold) 1=event 0=no event"
//HES
gen chronic_hep_h = 0
replace chronic_hep_h = 1 if regexm(icd, " ")
label variable chronic_hep_h "Chronic Hepatitis (hes) 1=event 0=no event"
//ALL
gen chronic_hep_all = 1 if chronic_hep_g==1|chronic_hep_h==1
label variable chronic_hep_all "Chronic Hepatitis (all) 1=event 0=no event"
//gen covtype
replace covtype=23 if chronic_hep_all ==1

// HIV/AIDS
// readcode source:
// ICD-10 source:
//CPRD GOLD
gen hiv_aids_g = 0
replace hiv_aids_g = 1 if regexm(readcode, " ")
label variable hiv_aids_g "HIV/AIDS (gold) 1=event 0=no event"
//HES
gen hiv_aids_h = 0
replace hiv_aids_h = 1 if regexm(icd, " ")
label variable hiv_aids_h "HIV/AIDS (hes) 1=event 0=no event"
//ALL
gen hiv_aids_all = 1 if hiv_aids_g==1|hiv_aids_h==1
label variable hiv_aids_all "HIV/AIDS (all) 1=event 0=no event"
//gen covtype
replace covtype=24 if hiv_aids_all ==1

// Rheumatoid arthritis
// readcode source:
// ICD-10 source:
//CPRD GOLD
gen rheum_arthr_g = 0
replace rheum_arthr_g = 1 if regexm(readcode, " ")
label variable rheum_arthr_g "Rheumatoid Arthritis (gold) 1=event 0=no event"
//HES
gen rheum_arthr_h = 0
replace rheum_arthr_h = 1 if regexm(icd, " ")
label variable rheum_arthr_h "Rheumatoid Arthritis (hes) 1=event 0=no event"
//ALL
gen rheum_arthr_all = 1 if rheum_arthr_g==1|rheum_arthr_h==1
label variable rheum_arthr_all "Rheumatoid Arthritis (all) 1=event 0=no event"
//gen covtype
replace covtype=25 if rheum_arthr_all ==1

// Obesity
// readcode source:
// ICD-10 source:
//CPRD GOLD
gen obesity_g = 0
replace obesity_g = 1 if regexm(readcode, " ")
label variable obesity_g "Obesity (gold) 1=event 0=no event"
//HES
gen obesity_h = 0
replace obesity_h = 1 if regexm(icd, " ")
label variable obesity_h "Obesity (hes) 1=event 0=no event"
//ALL
gen obesity_all = 1 if obesity_g==1|obesity_h==1
label variable obesity_all "Obesity (all) 1=event 0=no event"
//gen covtype
replace covtype=26 if obesity_all ==1

// Organ transplant
// readcode source:
// ICD-10 source:
//CPRD GOLD
gen organtransplant_g = 0
replace organtransplant_g = 1 if regexm(readcode, " ")
label variable organtransplant_g "Organ Transplant (gold) 1=event 0=no event"
//HES
gen organtransplant_h = 0
replace organtransplant_h = 1 if regexm(icd, " ")
label variable organtransplant_h "Organ Transplant (hes) 1=event 0=no event"
//ALL
gen organtransplant_all = 1 if organtransplant_g==1|organtransplant_h==1
label variable organtransplant_all "Organ Transplant (all) 1=event 0=no event"
//gen covtype
replace covtype=27 if organtransplant_all ==1

// Hypoglycemia
// readcode source:
// ICD-10 source:
//CPRD GOLD
gen hypoglycemia_g = 0
replace hypoglycemia_g = 1 if regexm(readcode, " ")
label variable hypoglycemia_g "Hypoglycemia (gold) 1=event 0=no event"
//HES
gen hypoglycemia_h = 0
replace hypoglycemia_h = 1 if regexm(icd, " ")
label variable hypoglycemia_h "Hypoglycemia (hes) 1=event 0=no event"
//ALL
gen hypoglycemia_all = 1 if hypoglycemia_g==1|hypoglycemia_h==1
label variable hypoglycemia_all "Hypoglycemia (all) 1=event 0=no event"
//gen covtype
replace covtype=28 if hypoglycemia_all ==1

// Retinal photocoagulation
// readcode source:
// ICD-10 source:
//CPRD GOLD
gen retinalphoto_g = 0
replace retinalphoto_g = 1 if regexm(readcode, " ")
label variable retinalphoto_g "Retinal Photocoagulation (gold) 1=event 0=no event"
//HES
gen retinalphoto_h = 0
replace retinalphoto_h = 1 if regexm(icd, " ")
label variable retinalphoto_h "Retinal Photocoagulation (hes) 1=event 0=no event"
//ALL
gen retinalphoto_all = 1 if retinalphoto_g==1|retinalphoto_h==1
label variable retinalphoto_all "Retinal Photocoagulation (all) 1=event 0=no event"
//gen covtype
replace covtype=29 if retinalphoto_all ==1

// Minor amputation
// readcode source:
// ICD-10 source:
//CPRD GOLD
gen amput_minor_g = 0
replace amput_minor_g = 1 if regexm(readcode, " ")
label variable amput_minor_g "Minor Amputation (gold) 1=event 0=no event"
//HES
gen amput_minor_h = 0
replace amput_minor_h = 1 if regexm(icd, " ")
label variable amput_minor_h "Minor Amputation (hes) 1=event 0=no event"
//ALL
gen amput_minor_all = 1 if amput_minor_g==1|amput_minor_h==1
label variable amput_minor_all "Minor Amputation (all) 1=event 0=no event"
//gen covtype
replace covtype=30 if amput_minor_all ==1

// Major amputation
// readcode source:
// ICD-10 source:
//CPRD GOLD
gen amput_major_g = 0
replace amput_major_g = 1 if regexm(readcode, " ")
label variable amput_major_g "Major Amputation (gold) 1=event 0=no event"
//HES
gen amput_major_h = 0
replace amput_major_h = 1 if regexm(icd, " ")
label variable amput_major_h "Major Amputation (hes) 1=event 0=no event"
//ALL
gen amput_major_all = 1 if amput_major_g==1|amput_major_h==1
label variable amput_major_all "Major Amputation (all) 1=event 0=no event"
//gen covtype
replace covtype=31 if amput_major_all ==1

// End stage renal failure
// readcode source:
// ICD-10 source:
//CPRD GOLD
gen renalfailure_g = 0
replace renalfailure_g = 1 if regexm(readcode, " ")
label variable renalfailure_g "Renal Failure, end stage (gold) 1=event 0=no event"
//HES
gen renalfailure_h = 0
replace renalfailure_h = 1 if regexm(icd, " ")
label variable renalfailure_h "Renal Failure, end stage (hes) 1=event 0=no event"
//ALL
gen renalfailure_all = 1 if renalfailure_g==1|renalfailure_h==1
label variable renalfailure_all "Renal failure, end stage (all) 1=event 0=no event"
//gen covtype
replace covtype=32 if renalfailure_all ==1

//populate nr_data with co-morbidity binaries
foreach num of numlist 6/32{
replace nr_data=1 if covtype==`num'
}

//SAVE A DATA FILE WITH ALL VARIABLES
save covariatesv1dot2bin, replace

//Create a varibale for all eligible test dates (i.e. those with real, in-range nr_data)
gen eltestdate2 = . 
replace eltestdate2 = eventdate2 if nr_data <. & eventdate2 <.
format eltestdate2 %td

//Drop all duplicates for patients of the same enttype on the same day
quietly bysort patid enttype eltestdate2: gen dupa = cond(_N==1,0,_n)
drop if dupa>1

// #4 Code for exclusions (PCOS, pregnant)...must do before collapsing so that info isn't lost
gen pcos_b = 0 
replace pcos_ = 1 if regexm(readcode, "C164.00|C165.00")
label variable pcos_b "PCOS 1=has 0=does not have"
drop if pcos_b==1
//gestational diabetes
gen pregnant_b = 0
replace pregnant_b = 1 if ...
label pregnant_b "Pregnant 1=pregnant, 0=not pregnant"
drop if pregnant_b==1

////////////////////////////////////SPLIT FOR EACH WINDOW- INDEXDATE, COHORTENTRYDATE, STUDYENTRYDATE_CPRD/////////////////////////////
//INDEXDATE 
//pull out test date of interest
bysort patid covtype : egen prx_testdate_i = max(eltestdate2) if eltestdate2>=indexdate-365 & eltestdate2<indexdate
format prx_testdate_i %td
gen prx_test_i_b = 1 if !missing(prx_testdate_i)

//pull out test value of interest
bysort patid covtype : gen prx_testvalue_i = nr_data if prx_testdate_i==eltestdate2

//create counts
sort patid covtype eltestdate2
by patid covtype: generate int_num = _n
by patid: egen cov_num_un = count(covtype) if cov_num==1 

by patid: egen cov_num_un_i_temp = count(covtype) if cov_num==1 & eltestdate2>=indexdate-365 & eltestdate2<indexdate
by patid: egen cov_num_un_i = min(cov_num_un_s_temp)
drop cov_num_un_i_temp

//Create a new variable that numbers enttypes 1-12
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

save clincovariatesindexdatewide, replace
/*//COHORTENTRY DATE
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

//Create a new variable that numbers enttypes 1-12
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

save clincovariatescohortwide, replace

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

//Create a new variable that numbers enttypes 1-12
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

save clincovariatesstudywide, replace */

collapse (max) (min) /// FILL IN VARIABLES /// , by(patid)
compress
save Clinicalovariates.dta, replace

////////////////////////////////////////////

exit
log close

