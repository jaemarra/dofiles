//  program:    Data08_outcomes_b.do
//  task:		Generate variables for clinical events (outcomes of interest) using HES (other .do files for CPRD, ONS and composite)
//  project: 	Incretins--Comparative mortality and CV outcomes (CPRD)
//  author:     MA \ May2014 \ jmg modified June2014 Modified JM \ Jan2015

clear all
capture log close
set more off
log using Data08b.smcl, replace
timer on 1

// #1 Merge Dates dataset with HES, drop if eventdates were prior to study entry date
use hes, clear
merge m:1 patid using Dates, keep(match using) nogen
keep if epistart2>studyentrydate_cprd2
sort patid
compress

////// #2 Composite of major CV-related morbidity and mortality (non-fatal/fatal MI, non-fatal/fatal stroke, CV death)
// Code binary variable for each source of outcome info (CPRD GOLD "_g", ONS "_o", HES "_h", combo "_all")
// Code so 0=no event and 1=event. For each event: generate, replace, label

//PRIMARY OUTCOMES
// Myocardial Infarction
// ICD-10 source: Quan, Med Care, 2005 (Table 1)
gen myoinfarct_h = 0 
replace myoinfarct_h = 1 if regexm(icd, "I21.?")
label variable myoinfarct_h "MI (hes) 1=event 0=no event"

// Stroke
// ICD-10 codes for cerebrovascular disease: Quan, Med Care, 2005 (Table 1), modified to include only hemmorage or infarction
gen stroke_h = 0
replace stroke_h = 1 if regexm(icd, "H34.1| I60.?| I61.?| I63.?|I64.?")
label variable stroke_h  "Stroke (hes) 1=event 0=no event"

// CV death
// ICD-10 source: Lo Re, PDS, 2012 (Supplemental Appendix C)-- 2 removed as they had exclusions with them
gen cvdeath_h = 0
replace cvdeath_h = 1 if regexm(icd, "I11.0|I21.?|I22.?|I23.?|I24.?|I25.?|I26.?|I40.?|I42.?|I44.?|I45.?|I46.?|I46.1|I47.?|I48.?|I49.?|I50.?|I60.?|I61.?|I62.?|I63.?|I64.?|I65.?|I66.?|I67.0|I67.6|I67.7|I69.?|I70.0|I81|I82.0|I82.3|I82.4x|I82.60|I82.62|I82.A1x|I82.B1x|I82.C1x|I82.890|I82.90")
label variable cvdeath_h  "CV Death (hes) 1=event 0=no event"

////// #2c Secondary outcomes: myocardial infarction, stroke, heart failure, cardiac arrhythmia, unstable angina, or urgent revascularization)
// Code binary variable for each source of outcome info (CPRD GOLD "_g", ONS "_o", HES "_h", combo "_all")

//SECONDARY OUTCOMES
// Heart failure 
// ICD-10 code source: Gamble 2011 CircHF (Supplemental- Appendix 1)
gen heartfail_h = 0
replace heartfail_h = 1 if regexm(icd, "I50.?")
label variable heartfail_h "Heart failure (hes) 1=event 0=no event"

// cardiac arrhythmia 
// ICD-10 code source:
gen arrhythmia_h = 0
replace arrhythmia_h = 1 if regexm(icd, "I44.1|I44.2|I44.3|I45.6|I45.9|I46.?|I47.?|I48.?|I49.?|R00.0|R00.1|R00.8|T82.1|Z45.0|Z95.0") 
label variable arrhythmia_h "Cardiac arrhythmia (hes) 1=event 0=no event"

// unstable angina 
// ICD-10 code source:
gen angina_h = 0
replace angina_h = 1 if regexm(icd, "I20.0") 
label variable angina_h "Unstable angina (hes) 1=event 0=no event"

// #3 Generate dates for events after indexdate and studyentrydate
sort patid epistart2
local outcome myoinfarct_h stroke_h cvdeath_h heartfail_h arrhythmia_h angina_h  
				
		foreach x of local outcome {
		by patid: egen `x'_date_temp_i = min(epistart2) if `x'==1 & epistart2>indexdate 
		format `x'_date_temp_i %td
		by patid: egen `x'_date_i = min(`x'_date_temp_i)
		format `x'_date_i %td
		drop `x'_date_temp_i
		label var `x'_date_i "Earliest date of episode recorded for events after index date"
		}

		foreach y of local outcome {
		by patid: egen `y'_date_temp_s = min(epistart2) if `y'==1 & epistart2>studyentrydate_cprd2 
		format `y'_date_temp_s %td
		by patid: egen `y'_date_s = min(`y'_date_temp_s)
		format `y'_date_s %td
		drop `y'_date_temp_s
		label var `y'_date_i "Earliest date of episode recorded for events after study entry date"
		}

collapse (max) cohortentrydate indexdate studyentrydate myoinfarct_h stroke_h cvdeath_h heartfail_h arrhythmia_h angina_h myoinfarct_h_date_i stroke_h_date_i cvdeath_h_date_i heartfail_h_date_i arrhythmia_h_date_i angina_h_date_i myoinfarct_h_date_s stroke_h_date_s cvdeath_h_date_s heartfail_h_date_s arrhythmia_h_date_s angina_h_date_s, by(patid)
compress
save Outcomes_hes.dta, replace

// #4 Procedures
use hes_procedures.dta, clear
merge m:1 patid using Dates, keep(match using) nogen
keep if eventdate2>studyentrydate_cprd2
sort patid
compress

gen revasc_opcs = 0
local revascodes = "(K40|K401|K402|K403|K404|K408|K409|K41|K411|K412|K413|K414|K418|K419|K42|K421|K422|K423|K424|K428|K429|K43|K431|K432|K433|K434|K438|K439|K44|K441|K442|K448|K449|K45|K451|K452|K453|K454|K455|K456|K458|K459|K46|K461|K462|K463|K464|K465|K468|K469|K47|K471|K472|K473|K474|K475|K478|K479|K48|K481|K482|K483|K484|K488|K489|K49|K491|K492|K493|K494|K498|K499|K50|K501|K502|K503|K504|K508|K509)"
replace revasc_opcs = 1 if regexm(opcs, "`revascodes'")
label variable revasc_opcs "Revascularization (OPCS codes) 1=event 0=no event"

sort patid eventdate2
by patid: egen proc_date_temp_i = min(eventdate2) if eventdate2>indexdate 
format proc_date_temp_i %td
by patid: egen proc_date_i = min(proc_date_temp_i)
format proc_date_i %td
drop proc_date_temp_i

by patid: egen proc_date_temp_s = min(eventdate2) if eventdate2>studyentrydate_cprd2 
format proc_date_temp_s %td
by patid: egen proc_date_s = min(proc_date_temp_s)
format proc_date_s %td
drop proc_date_temp_s

collapse (max) cohortentrydate indexdate studyentrydate revasc_opcs proc_date_i proc_date_s, by(patid)
compress
save Outcomes_procedures.dta, replace

////////////////////////////////////////////

timer off 1 
timer list 1

exit
log close
