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
// readcode source: Herrett, BMJ 2013, (Supplement file of MI READ codes); 
gen myoinfarct_g = 0 
replace myoinfarct_g = 1 if regexm(readcode, "323..00|3233.00|3234.00|3235.00|3236.00|323Z.00|889A.00|G30..00|G30..11|G30..12|G30..13|G30..14|G30..15|G30..16|G30..17|G300.00|G301.00|G301000|G301100|G301z00|G302.00|G303.00|G304.00|G305.00|G306.00|G307.00|G307000|G307100|G308.00|G309.00|G30A.00|G30B.00|G30X.00|G30X000|G30y.00|G30y000|G30y100|G30y200|G30yz00|G30z.00|G310.11|G31y100|G35..00|G350.00|G351.00|G353.00|G35X.00|G36..00|G360.00|G361.00|G362.00|G363.00|G364.00|G365.00|G366.00|G38..00|G380.00|G381.00|G384.00|G38z.00|G501.00|Gyu3400")

// Stroke
// readcode source: Khan, BMC Family Practice 2010,  (Supplemental Excel File);
gen stroke_g = 0
replace stroke_g = 1 if regexm(readcode, "G6z..00|G62z.00|G613.00|G6...00|G67..00|G61X100|8520M|G63z.00|G60X.00|G606.00|S628.00|4380|G63..12|7004300|G67y.00|4319CE|Gyu6600|4309M|G63..00|G61z.00|G671.00|4389|F11x200|G677400|G60..00|Gyu6.00|4310|G61..11|G63y.00|G623.00|S621.00|G6y..00|Gyu6700|G618.00|Gyu6500|1477|G603.00|G604.00|Gyu6200|G602.00|G61X000|G61X.00|G671z00|G641000|Gyu6F00|G617.00|4319CR|S627.00|G60z.00|8520A|S62..12|G633.00|G61..12|G600.00|G601.00|G61..00|G605.00|Gyu6100|S620.00|4300|Gyu6000|4309|G66..11|G660.00|G661.00|G66..00|G667.00|G66..13|G663.00|G664.00|G668.00|G66..12|14A7.00|G662.00|14A7.12|G64..13|4369B")

// Stroke plus TIA
// readcode source: Khan, BMC Family Practice 2010,  (Supplemental Excel File);
gen stroketia_g = 0
replace stroketia_g = 1 if regexm(readcode, "G6z..00|G62z.00|G613.00|G6...00|G67..00|G61X100|8520M|G63z.00|G60X.00|G606.00|S628.00|4380|G65z.00|G63..12|7004300|G67y.00|4319CE|Gyu6600|G68W.00|4309M|G63..00|G65zz00|G61z.00|G671.00|4389|G65y.00|F11x200|G677400|G60..00|Gyu6.00|4310|G61..11|G63y.00|G623.00|S621.00|G6y..00|G65..00|Gyu6700|G618.00|Gyu6500|1477|Gyu6D00|G603.00|G604.00|G681.00|Gyu6200|G602.00|G67z.00|G61X000|G61X.00|G671z00|G641000|Gyu6F00|G617.00|G680.00|4319CR|S627.00|G60z.00|8520A|4350|S62..12|G633.00|G61..12|G600.00|G601.00|G61..00|G605.00|G68..00|Gyu6100|S620.00|4300|Gyu6000|4309|G66..11|G660.00|662M.00|G669.00|G661.00|G66..00|G667.00|G66..13|G666.00|G663.00|G664.00|G665.00|G668.00|G66..12|14A7.00|G662.00|14A7.12|G64..13|4369B")

// Components of composite plus other CV endpoints of interest - myocardial infarction, stroke, heart failure, cardiac arrhythmia, unstable angina, or urgent revascularization)
// Code binary variable for each source of outcome info (CPRD GOLD "_g", ONS "_o", HES "_h", combo "_all")

//SECONDARY OUTCOMES
// Heart failure 
// readcode source: Khan, BMC Family Practice, 2010 (Supplemental document); 
gen heartfail_g = 0
replace heartfail_g = 1 if regexm(readcode, "4271B|G58z.12|G580200|G232.00|4271H|4271|G58z.11|662W.00|7824FM|G554000|G580300|G580.12|8B29.00|4270C|G580.11|G582.00|14AM.00|G581000|SP11111|G580100|8CL3.00|425 CC|4271A|G581.00|4270|G58..00|7824AC|G580.00|14A6.00|7824BW|G58..11|1O1..00|402 C|G580000|4270R|8H2S.00|4270CC|G58z.00|4270D|7824FH")

// cardiac arrhythmia
// readcode source: Huerta, Epidemiology, 2005 (ArticlePlus) (this paper ID'd from Khan systematic review)
gen arrhythmia_g = 0
replace arrhythmia_g = 1 if regexm(readcode, "G57..00|G570.00|G570000|G570100|G570200|G570300|G570z00|G571.00|G57..11|G571.11|G572.00|G572000|G572100|G572z00|G573.00|G573000|G573100|G573200|G573z00|G574.00|G574000|G574011|G574100|G574z00|G576.00|G576000|G576011|G576100|G576.11|G576200|G576300|G576400|G576500|G576z00|G577.00|G57y.00|G57y.14|G57y500|G57y600|G57y700|G57y900|G57yA00|G57yz00|G57z.00|G5yy500|Gyu5A00|R050.00|R050.11|2426|2427|243..11|2432|24B8.00|327..00|328..00|328Z.00|3264|3272|3273|3274|3282|7936A00|4279AA|4279AC|4279EA|4279F|4279FC|4279FN|4279FR|4279GB|4279GR|4279HF|4279HL|4279HR|4279HT|4279JR|4279NR|4279RM|4279RN|4279WP|429 HK|4279DF|7822|7822F|7822R|4279CD|4279DC|4279JP|4279NE|4272D|G575.00|SP11000|G575000|G575z00|7L1H.13|K3093|328|3283|2241|G575100|4279E|4279GL|4279HV")

// unstable angina (first occurance of hospitalization or death)
// readcode source: Medical Browser Serach minus all codes for family history and symptom scores
gen angina_g = 0
replace angina_g = 1 if regexm(readcode, "G33..00|662K000|662K.00|G311.13|G311100|G33zz00|G33z300|G33z.00|G311.11|G33z700|662K300|388E.00|G311400|G330.00|662K100|662K200|662Kz00|G311200|AA1..00|G311.14|G331.00|G33z600|J083300|G330000|G33z500|ZR37.00|G311300|G331.11|J421.11|8B27.00|AA1z.00|G330z00|J08zD00|A340000|Gyu3000|F311100")

// urgent revascularization (first occurance of hospitalization or death)==CV procedures
// readcode source: Lo Re, PDS, 2012 (Supplemental Appendix B)
gen revasc_g = 0
replace revasc_g = 1 if regexm(readcode, "792..00|792..11|7920.00|7920.11|7920000|7920100|7920200|7920300|7920y00|7920z00|7921.00|7921.11|7921000|7921100|7921200|7921300|7921y00|7921z00|7922.00|7922.11|7922000|7922100|7922200|7922300|7922y00|7922z00|7923.00|7923.11|7923000|7923100|7923200|7923300|7923y00|7923z00|7924.00|7924000|7924100|7924200|7924300|7924400|7924500|7924y00|7924z00|7925.00|7925.11|7925000|7925011|7925012|7925100|7925200|7925300|7925311|7925312|7925400|7925y00|7925z00|7926.00|7926000|7926100|7926200|7926300|7926y00|7926z00|7927.00|7927200|7927300|7927y00|7927z00|792b.00|792c.00|792c000|792Cy00|792Cz00|792d.00|792Dy00|792Dz00|792y.00|Sp00300|7927000|7927100|7927400|7927500|7928.00|7928.11|7928000|7928100|7928200|7928300|7928y00|7928z00|7929.00|7929000|7929100|7929111|7929200|7929300|7929400|7929500|7929600|7929y00|7929z00|792a.00|792a000|792b000|792b100|792By00|792Bz00|792z.00|7a1a000|7a54000|7a6g100|Sp01200|7a20.00|7a20000|7a20100|7a20200|7a20300|7a20311|7a20400|7a20500|7a20600|7a20700|7a20y00|7a20z00|7a22.00|7a22000|7a22100|7a22200|7a22300|7a22y00|7a22z00")

// #3 Generate dates for events after indexdate and studyentrydate
sort patid eventdate2
local outcome myoinfarct_g stroke_g stroketia_g heartfail_g arrhythmia_g angina_g revasc_g 

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

collapse (min) cohortentrydate indexdate studyentrydate deathdate2 myoinfarct_g_date_i stroketia_g_date_i stroke_g_date_i heartfail_g_date_i arrhythmia_g_date_i angina_g_date_i revasc_g_date_i myoinfarct_g_date_s stroke_g_date_s stroketia_g_date_s heartfail_g_date_s arrhythmia_g_date_s angina_g_date_s revasc_g_date_s (max) death_g myoinfarct_g stroke_g stroketia_g heartfail_g arrhythmia_g angina_g revasc_g, by(patid)
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
collapse (min) cohortentrydate indexdate studyentrydate deathdate2 myoinfarct_g_date_i stroke_g_date_i stroketia_g_date_i heartfail_g_date_i arrhythmia_g_date_i angina_g_date_i revasc_g_date_i myoinfarct_g_date_s stroke_g_date_s stroketia_g_date_s heartfail_g_date_s arrhythmia_g_date_s angina_g_date_s revasc_g_date_s (max) death_g myoinfarct_g stroke_g stroketia_g heartfail_g arrhythmia_g angina_g revasc_g, by(patid)
compress
local outcome myoinfarct_g stroke_g stroketia_g heartfail_g arrhythmia_g angina_g revasc_g 

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
label var stroketia_g "Stroke plus TIA (gold) 1=event 0=no event"
label variable myoinfarct_g "MI (gold) 1=event 0=no event"
label var death_g "Indicator for death using CPRD algorithm"
save Outcomes_gold.dta, replace

////////////////////////////////////////////
timer off 1 
timer list 1

exit
log close
