//  program:    Data08_outcomes_c.do
//  task:		Generate variables for clinical events (outcomes of interest) using ONS (other .do files for CPRD, HES and composite)
//  project: 	Incretins--Comparative mortality and CV outcomes (CPRD)
//  author:     MA \ May2014 Modified JM \ Jan2015

clear all
capture log close
set more off

log using Data08c.smcl, replace 
timer on 1

// #1 Merge Dates dataset with ONS

use death_patient_2, clear
merge m:1 patid using Dates, keep(match using) nogen
keep if dod>studyentrydate_cprd2
sort patid
compress

// #2 Generate binary variables coding for each OUTCOME clinical event. 
// Code so 0=no event and 1=event. For each event: generate, replace, label
// Code binary variable for each source of outcome info (CPRD GOLD "_g", ONS "_o", HES "_h", combo "_all")

//PRIMARY OUTCOMES
//All-cause mortality
gen death_ons = (dod!=.)
label var death_ons "Indicator for death, ONS"

// Myocardial Infarction
// ICD-10 source: Quan, Med Care, 2005 (Table 1)
gen myoinfarct_o = 0 
local micodes="(I21.?)"
replace myoinfarct_o = 1 if regexm(cause, "`micodes'")
forval i=1/15 {
replace myoinfarct_o = 1 if regexm(cause`i', "`micodes'")
}
label variable myoinfarct_o "MI (ons) 1=event 0=no event"

// Stroke
// ICD-10 codes for cerebrovascular disease: Quan, Med Care, 2005 (Table 1), modified to include only hemmorage or infarction
gen stroke_o = 0
local strokecodes= "(H34.1| I60.?| I61.?| I63.?|I64.?)"
replace stroke_o = 1 if regexm(cause, "`strokecodes'")
forval i=1/15 {
replace stroke_o = 1 if regexm(cause`i', "`strokecodes'")
}
label variable stroke_o "Stroke (ons) 1=event 0=no event"

// CV death
// ICD-10 source: Lo Re, PDS, 2012 (Supplemental Appendix C)-- 2 removed as they had exclusions with them
gen cvdeath_o = 0
local cvdeathcodes= "(I11.0|I21.?|I22.?|I23.?|I24.?|I25.?|I26.?|I40.?|I42.?|I44.?|I45.?|I46.?|I46.1|I47.?|I48.?|I49.?|I50.?|I60.?|I61.?|I62.?|I63.?|I64.?|I65.?|I66.?|I67.0|I67.6|I67.7|I69.?|I70.0|I81|I82.0|I82.3|I82.4x|I82.60|I82.62|I82.A1x|I82.B1x|I82.C1x|I82.890|I82.90)"
replace cvdeath_o = 1 if regexm(cause, "`cvdeathcodes'")
forval i=1/15 {
replace cvdeath_o = 1 if regexm(cause`i', "`cvdeathcodes'")
}
label variable cvdeath_o  "CV Death (ons) 1=event 0=no event"
// Heart failure 
// ICD-10 code source: Gamble 2011 CircHF (Supplemental- Appendix 1)
gen heartfail_o = 0
local hfcodes= "(I50.?)"
replace heartfail_o = 1 if regexm(cause, "`hfcodes'")
forval i=1/15 {
replace heartfail_o = 1 if regexm(cause`i', "`hfcodes'")
}
label variable heartfail_o "Hosp or death due to heart failure (ons) 1=event 0=no event"

// cardiac arrhythmia 
// ICD-10 code source:
gen arrhythmia_o = 0
local arrcodes = "(I44.1|I44.2|I44.3|I45.6|I45.9|I46.?|I47.?|I48.?|I49.?|R00.0|R00.1|R00.8|T82.1|Z45.0|Z95.0)"
replace arrhythmia_o = 1 if regexm(cause, "`arrcodes'")
forval i=1/15	{
replace arrhythmia_o = 1 if regexm(cause`i', "`arrcodes'")
}
label variable arrhythmia_o "Hosp or death due to cardiac arrhythmia (ons) 1=event 0=no event"

// unstable angina (first occurance of hospitalization or death)
// ICD-10 code source:
gen angina_o = 0
local angcodes = "(I20.0)"
replace angina_o = 1 if regexm(cause, "`angcodes'") 
forval i=1/15 	{
replace angina_o = 1 if regexm(cause`i', "`angcodes'")
 }
label variable angina_o "Hosp or death due to unstable angina (ons) 1=event 0=no event"

// #4 Generate dates for events after indexdate and studyentrydate
sort patid dod
local outcome myoinfarct_o stroke_o cvdeath_o heartfail_o arrhythmia_o angina_o 
				
		foreach x of local outcome {
		by patid: egen `x'_date_temp_i = min(dod) if `x'==1 & dod>indexdate 
		format `x'_date_temp_i %td
		by patid: egen `x'_date_i = min(`x'_date_temp_i)
		format `x'_date_i %td
		drop `x'_date_temp_i
		label var `x'_date_i "Earliest date of death recorded for events after index date"
		}

		foreach y of local outcome {
		by patid: egen `y'_date_temp_s = min(dod) if `y'==1 & dod>studyentrydate_cprd2 
		format `y'_date_temp_s %td
		by patid: egen `y'_date_s = min(`y'_date_temp_s)
		format `y'_date_s %td
		drop `y'_date_temp_s
		label var `y'_date_i "Earliest date of death recorded for events after study entry date"
		}
collapse (min) cohortentrydate indexdate studyentrydate death_ons myoinfarct_o_date_i stroke_o_date_i cvdeath_o_date_i heartfail_o_date_i arrhythmia_o_date_i angina_o_date_i  myoinfarct_o_date_s stroke_o_date_s cvdeath_o_date_s heartfail_o_date_s arrhythmia_o_date_s angina_o_date_s  (min) myoinfarct_o stroke_o cvdeath_o heartfail_o arrhythmia_o angina_o dod, by(patid)
compress
save Outcomes_ons.dta, replace

////////////////////////////////////////////

timer off 1 
timer list 1

exit
log close
