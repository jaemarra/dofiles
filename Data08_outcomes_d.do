//  program:    Data08_outcomes_d.do
//  task:		Combine various outcome files that have been generated
//  project: 	Incretins--Comparative mortality and CV outcomes (CPRD)
//  author:     MA \ May2014 \ jmg modified June2014 Modified JM \ Nov 2014

clear all
capture log close
set more off

log using Data08d.smcl, replace
timer on 1

// #1 Merge all outcome files: gold, hes, procedures, ons.

use Outcomes_gold, clear
merge 1:1 patid using Outcomes_hes, keep(match master) nogen
merge 1:1 patid using Outcomes_procedures, keep(match master) nogen 
merge 1:1 patid using Outcomes_ons, keep(match master) nogen

// #2 Merge all-cause hospitalization in also

// for two steps below, see Data08_outcomes.do. A lot of this code is written in there (before we decided to break it into
// separate files), so should be able to copy and paste lots into here.

// #3 Make variables of composites from different sources (ie CPRD, HES, ONS for each variable):

//All-cause mortality
gen death_date = min(deathdate2, dod2)
label variable death_date "Date of death, first of death date in CPRD and ONS"

//MACE
gen mace_date = min(myoinfarct_o_date_i, stroketia_o_date_i, cvdeath_o_date_i, myoinfarct_h_date_i, stroketia_h_date_i, myoinfarct_g_date_i, stroketia_g_date_i)
label variable mace_date "Date of first primary CV composite outcome (cprd+hes+ons) after index date"
gen mace = (mace_date!=.)
label variable mace "CV composite primary outcome (cprd+hes+ons) after index: 1=event 0=no event"

//Secondary endpoints

gen myoinfarct_date_i = min(myoinfarct_g_date_i, myoinfarct_h_date_i, myoinfarct_o_date_i)
label variable myoinfarct_date_i "Date of first MI (all) after index date"

gen myoinfarct_date_s = min(myoinfarct_g_date_s, myoinfarct_h_date_s, myoinfarct_o_date_s)
label variable myoinfarct_date_s "Date of first MI (all) after study entry"

gen stroke_date_i = min(stroke_g_date_i, stroke_h_date_i, stroke_o_date_i)
label variable stroke_date_i "Date of first stroke (all) after index date"

gen stroke_date_s = min(stroke_g_date_s, stroke_h_date_s, stroke_o_date_s)
label variable stroke_date_s "Date of first stroke (all) after study entry"

gen stroketia_date_i = min(stroketia_g_date_i, stroketia_h_date_i, stroketia_o_date_i)
label variable stroketia_date_i "Date of first stroke+tia (all) after index date"

gen stroketia_date_s = min(stroketia_g_date_s, stroketia_h_date_s, stroketia_o_date_s)
label variable stroketia_date_s "Date of first stroke+tia (all) after study entry"

gen cvdeath_date_i = cvdeath_o_date_i
label variable cvdeath_date_i "Date of cv death (all) after index date"

gen cvdeath_date_s = cvdeath_o_date_s
label variable cvdeath_date_s "Date of cv death (all) after study entry"

gen heartfail_date_i = min(heartfail_g_date_i, heartfail_h_date_i, heartfail_o_date_i)
label variable heartfail_date_i "Date of first HF (all) after index date"

gen heartfail_date_s = min(heartfail_g_date_s, heartfail_h_date_s, heartfail_o_date_s)
label variable heartfail_date_s "Date of first HF (all) after study entry"

gen arrhythmia_date_i = min(arrhythmia_g_date_i, arrhythmia_h_date_i, arrhythmia_o_date_i)
label variable arrhythmia_date_i "Date of first arrhythmia (all) after index date"

gen arrhythmia_date_s = min(arrhythmia_g_date_s, arrhythmia_h_date_s, arrhythmia_o_date_s)
label variable arrhythmia_date_s "Date of first arrhythmia (all) after study entry"

gen angina_date_i = min(angina_g_date_i, angina_h_date_i, angina_o_date_i)
label variable angina_date_i "Date of first unstable angina (all) after index date"

gen angina_date_s = min(angina_g_date_s, angina_h_date_s, angina_o_date_s)
label variable angina_date_s "Date of first unstable angina (all) after study entry"

gen revasc_date_i = min(revasc_g_date_i, proc_date_i)
label variable revasc_date_i "Date of first revasc (all) after index date"

gen revasc_date_s = min(revasc_g_date_s, proc_date_s)
label variable revasc_date_s "Date of first revasc (all) after study entry"

compress
save Outcomes.dta, replace 

////////////////////////////////////////////

timer off 1 
timer list 1

exit
log close
