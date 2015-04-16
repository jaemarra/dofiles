//  program:    Data08_outcomes_a.do
//  task:		Generate variables for clinical events (outcomes of interest) using CPRD-GOLD (other .do files for HES, ONS and composite)
//  project: 	Incretins--Comparative mortality and CV outcomes (CPRD)
//  author:     MA \ May2014 \ jmg modified June2014 Modified JM \ Nov 2014

clear all
capture log close
set more off

log using Data08a.smcl, replace
timer on 1

// #1 Merge Dates dataset with Clinical and Additional

foreach file in Clinical001_2 Clinical002_2 Clinical003_2 Clinical004_2 Clinical005_2 Clinical006_2 Clinical007_2 Clinical008_2 ///
				Clinical009_2 Clinical010_2 Clinical011_2 Clinical012_2 Clinical013_2 {
use `file', clear
sort patid
merge m:1 patid using Dates, keep(match using) nogen
keep if eventdate2>studyentrydate_cprd2
sort patid
joinby patid adid using Additional, unmatched(master) _merge(Additional_merge)
merge m:1 patid using Patient, keep(match using) nogen
compress
save `file'a.dta, replace
}
clear

// #2 Generate binary variables coding for each OUTCOME clinical event. 
// Code so 0=no event and 1=event. For each event: generate, replace, label
// Based on readcode variable, source of readcodes identified for each outcome/source.

//PRIMARY OUTCOMES
////// #2a All-cause mortality
foreach file in Clinical001_2a Clinical002_2a Clinical003_2a Clinical004_2a Clinical005_2a Clinical006_2a Clinical007_2a Clinical008_2a ///
				Clinical009_2a Clinical010_2a Clinical011_2a Clinical012_2a Clinical013_2a {

use `file', clear
gen death_g = (deathdate2!=.)

////// #2b Composite of major CV-related morbidity and mortality (non-fatal/fatal MI, non-fatal/fatal stroke, CV death)
// Code binary variable for each source of outcome info (CPRD GOLD "_g", ONS "_o", HES "_h", combo "_all")

// Myocardial Infarction
// readcode source: Delaney, BMC Cardiovascular Disorders, 2007 (Additional File 1); 
gen myoinfarct_g = 0 
replace myoinfarct_g = 1 if regexm(readcode, "323..00|G30X.00|G361.00|G361.00|G362.00|G362.00|4100N|4109TE|4109TM|4119N|14A4.00|3234|G304.00|G308.00|G30y200|G366.00|G366.00|4129MC|4140|G307.00|G34y100|G360.00|G360.00|G305.00|4109CR|4129N|G30..15|G300.00|G344.00|G38..00|4129RE|G302.00|G303.00|4109TL|3235|G301.00|G301000|G31y200|G5y1.00|322..00|322Z.00|G30..17|4149|14A3.00|G381.00|G306.00|G30..00|G30z.00|G32..12|G350.00|4100NA|4109CL|4109N|4109NA|4109NH|4129AM|4109NC|4129NS")

// Stroke
// readcode source: most from Lo Re, PDS, 2012 (Supplemental Appendix B) -- final 12 (OXMIS codes??) from unknown source; 
gen stroke_g = 0
replace stroke_g = 1 if regexm(readcode, "G61..00|G61..11|G61..12|G610.00|G611.00|G612.00|G613.00|G614.00|G615.00|G616.00|G617.00|G618.00|G61X.00|G61X000|G61X100|G61z.00|G63..11|G631.12|G63y000|G64..11|G64..12|G64..13|G640.00|G640000|G64z.00|G64z200|G64z300|G66..00|G66..11|G66..12|G66..13|G667.00|G668.00|G6W..00|G6X..00|Gyu6200|Gyu6300|Gyu6400|Gyu6500|Gyu6600|Gyu6E00|Gyu6F00|Gyu6G00|G31y.00")

// Components of composite plus other CV endpoints of interest - myocardial infarction, stroke, heart failure, cardiac arrhythmia, unstable angina, or urgent revascularization)
// Code binary variable for each source of outcome info (CPRD GOLD "_g", ONS "_o", HES "_h", combo "_all")

//SECONDARY OUTCOMES
// Heart failure 
// readcode source: Tzoulaki, BMJ, 2009 (Supplemental Appendix Table 2); 
gen heartfail_g = 0
replace heartfail_g = 1 if regexm(readcode, "G580.00|G58..00|G58z.00|8HBE.00|662T.00|662W.00|1O1..00|9Or..00|9Or3.00|662p.00|9Or4.00|9Or0.00|8CL3.00|67D4.00|679X.00|G580400|9Or5.00|9Or2.00|9Or1.00")

// cardiac arrhythmia
// readcode source: Huerta, Epidemiology, 2005 (ArticlePlus) (this paper ID'd from Khan systematic review)
gen arrhythmia_g = 0
replace arrhythmia_g = 1 if regexm(readcode, "4279EA|4272D|G575.00|SP11000|G575000|G575z00|G574011,7L1H.13|K3093|328|328Z.00|3283|3282|2241|G571.00|G57yA00|4279AC|G575100|4279E|G574000|G574.00|G574z00|4279GL|G574100|G571.11|4279HV")

// unstable angina (first occurance of hospitalization or death)
// readcode source:
gen angina_g = 0
replace angina_g = 1 if regexm(readcode, "G311.13|G311100")

// urgent revascularization (first occurance of hospitalization or death)==CV procedures
// readcode source: Lo Re, PDS, 2012 (Supplemental Appendix B)
gen revasc_g = 0
replace revasc_g = 1 if regexm(readcode, "792..00|792..11|7920.00|7920.11|7920000|7920100|7920200|7920300|7920y00|7920z00|7921.00|7921.11|7921000|7921100|7921200|7921300|7921y00|7921z00|7922.00|7922.11|7922000|7922100|7922200|7922300|7922y00|7922z00|7923.00|7923.11|7923000|7923100|7923200|7923300|7923y00|7923z00|7924.00|7924000|7924100|7924200|7924300|7924400|7924500|7924y00|7924z00|7925.00|7925.11|7925000|7925011|7925012|7925100|7925200|7925300|7925311|7925312|7925400|7925y00|7925z00|7926.00|7926000|7926100|7926200|7926300|7926y00|7926z00|7927.00|7927200|7927300|7927y00|7927z00|792b.00|792c.00|792c000|792Cy00|792Cz00|792d.00|792Dy00|792Dz00|792y.00|Sp00300|7927000|7927100|7927400|7927500|7928.00|7928.11|7928000|7928100|7928200|7928300|7928y00|7928z00|7929.00|7929000|7929100|7929111|7929200|7929300|7929400|7929500|7929600|7929y00|7929z00|792a.00|792a000|792b000|792b100|792By00|792Bz00|792z.00|7a1a000|7a54000|7a6g100|Sp01200|7a20.00|7a20000|7a20100|7a20200|7a20300|7a20311|7a20400|7a20500|7a20600|7a20700|7a20y00|7a20z00|7a22.00|7a22000|7a22100|7a22200|7a22300|7a22y00|7a22z00")

// #3 Generate dates for events after indexdate and studyentrydate
sort patid eventdate2
local outcome myoinfarct_g stroke_g heartfail_g arrhythmia_g angina_g revasc_g 

		foreach x of local outcome {
		by patid: egen `x'_date_temp_i = min(eventdate2) if `x'==1 & eventdate2>indexdate 
		format `x'_date_temp_i %td
		by patid: egen `x'_date_i = min(`x'_date_temp_i)
		format `x'_date_i %td
		drop `x'_date_temp_i
		label var `x'_date_i "Earliest date of episode recorded for events after index date"
		}

		foreach y of local outcome {
		by patid: egen `y'_date_temp_s = min(eventdate2) if `y'==1 & eventdate2>studyentrydate_cprd2 
		format `y'_date_temp_s %td
		by patid: egen `y'_date_s = min(`y'_date_temp_s)
		format `y'_date_s %td
		drop `y'_date_temp_s
		label var `y'_date_s "Earliest date of episode recorded for events after study entry date"
		}

collapse (min) cohortentrydate indexdate studyentrydate deathdate2 myoinfarct_g_date_i stroke_g_date_i heartfail_g_date_i arrhythmia_g_date_i angina_g_date_i revasc_g_date_i myoinfarct_g_date_s stroke_g_date_s heartfail_g_date_s arrhythmia_g_date_s angina_g_date_s revasc_g_date_s (max) death_g myoinfarct_g stroke_g heartfail_g arrhythmia_g angina_g revasc_g, by(patid)
compress
save Outcomes_gold_`file', replace
}

use Outcomes_gold_Clinical001_2a, clear 
save Outcomes_gold.dta, replace
foreach file in Outcomes_gold_Clinical002_2a Outcomes_gold_Clinical003_2a Outcomes_gold_Clinical004_2a Outcomes_gold_Clinical005_2a Outcomes_gold_Clinical006_2a Outcomes_gold_Clinical007_2a Outcomes_gold_Clinical008_2a ///
				Outcomes_gold_Clinical009_2a Outcomes_gold_Clinical010_2a Outcomes_gold_Clinical011_2a Outcomes_gold_Clinical012_2a Outcomes_gold_Clinical013_2a {
				use Outcomes_gold.dta, clear
				append using `file'
				save Outcomes_gold.dta, replace
				erase `file'.dta
}
use Outcomes_gold.dta
collapse (min) cohortentrydate indexdate studyentrydate deathdate2 myoinfarct_g_date_i stroke_g_date_i heartfail_g_date_i arrhythmia_g_date_i angina_g_date_i revasc_g_date_i myoinfarct_g_date_s stroke_g_date_s heartfail_g_date_s arrhythmia_g_date_s angina_g_date_s revasc_g_date_s (max) death_g myoinfarct_g stroke_g heartfail_g arrhythmia_g angina_g revasc_g, by(patid)
compress
local outcome myoinfarct_g stroke_g heartfail_g arrhythmia_g angina_g revasc_g 

foreach x of local outcome {
label var `x'_date_i "Earliest date of episode recorded for events after index date"
		}
foreach y of local outcome {
label var `y'_date_s "Earliest date of episode recorded for events after study entry date"
}

label variable revasc_g "Revascularization (gold) 1=event 0=no event"
label variable angina_g "Unstable angina (gold) 1=event 0=no event"
label variable arrhythmia_g "Cardiac arrhythmia (gold) 1=event 0=no event"
label variable heartfail_g "Heart failure (gold) 1=event 0=no event"
label variable stroke_g  "Stroke (gold) 1=event 0=no event"
label variable myoinfarct_g "MI (gold) 1=event 0=no event"
label var death_g "Indicator for death using CPRD algorithm"
save Outcomes_gold.dta, replace

////////////////////////////////////////////
timer off 1 
timer list 1

exit
log close
