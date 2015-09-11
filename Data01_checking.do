//  program:    Data01_checking.do
//  task:		Check .dta files generated in Data01_imports for data normality
//  project: 	Incretins--Comparative mortality and CV outcomes (CPRD)
//  author:     JM \ Jan2015


clear all
capture log close
set more off
ssc install mdesc
timer clear 1
timer on 1

//DATA01_IMPORT
//linkage_eligibility
clear all
capture log close
log using linkage_eligibility.smcl
use linkage_eligibility.dta
compress
describe
codebook, compact
tab end
tab linked_b
log close

//patid_date
clear all
capture log close
log using patid_date.smcl
use patid_date.dta
compress
codebook, compact
hist studyentrydate, frequency
graph save Graph patid_date_studyentrydate.gph
log close

//Patient
clear all
capture log close
log using Patient.smcl
use Patient.dta, clear
compress
describe
codebook, compact
tab marital
tab regstat
hist yob2, frequency
graph save Graph Patient_yob2.gph
hist tod2, frequency
graph save Graph Patient_tod2.gph
hist deathdate2, frequency
graph save Graph Patient_deathdate2.gph
log close

//Practice
clear all
capture log close
log using Practice.smcl
use Practice.dta
compress
describe
codebook, compact
hist lcd
graph save Graph Practice_lcd.gph
hist uts
graph save Graph Practice_uts.gph
log close

//BaseCohort / BasePatidDate / Censor (all from same dataset just keeping different variables)
clear all
capture log close
log using BaseCohort.smcl
use BaseCohort.dta, clear
compress
describe
codebook, compact
mdesc
tab gender
tab marital
tab regstat
hist reggap
graph save Graph Base_reggap.gph
hist deathdate2
graph save Graph Base_deathdate2.gph
hist tod2
graph save Graph Base_tod2.gph
hist yob
graph save Graph Base_yob.gph
log close

//Consultation ********LOTS OF MISSING EVENTDATES???********
clear all
capture log close
log using Consultation.smcl
use Consultation.dta, clear
compress
describe
codebook, compact
tab 
log close

//Clinical ********LOTS OF MISSING EVENTDATES???********
clear all
capture log close
log using Clinical.smcl
use Clinical.dta, clear
compress
describe
codebook, compact
mdesc
hist eventdate2
graph save Graph Clinical_eventdate2.gph
grubbs eventdate2
log close

//Additional
clear all
capture log close
log using Additional.smcl
use Additional.dta, clear
compress
describe
codebook, compact
mdesc adid patid enttype
log close

//Referral
clear all
capture log close
log using Referral.smcl
use Referral.dta, clear
compress
describe
codebook, compact
hist eventdate2
graph save Graph Referral_eventdate2.gph
log close

//Immunisation
clear all
capture log close
log using Immunisation.smcl
use Immunisation.dta, clear
compress
describe
codebook, compact
mdesc patid
mdesc immstype
tab immstype_name
hist eventdate2
graph save Graph Immunisation_eventdate2.gph
log close

//Test
clear all
capture log close
log using Test.smcl
use Test.dta, clear
compress
describe
codebook, compact
mdesc patid
mdesc enttype
hist eventdate2
graph save Graph Test_eventdate2.gph
hist studyentrydate_cprd2
graph save Graph Test_studyentrydate_cprd2.gph
log close

//Therapy
clear all
capture log close
log using Therapy.smcl
use Therapy.dta, clear
compress
describe
codebook, compact
mdesc patid
mdesc gemscriptcode
hist rxdate2
graph save Graph Therapy_rxdate2.gph
hist studyentrydate_cprd2
graph save Graph Therapy_studyentrydate.gph
log close
timer off 1

//death_patient_2
clear all
capture log close
log using death_patient_2.smcl
use death_patient_2.dta, clear
compress
describe
codebook, compact
summ dod2, detail
tab death_matchrank
hist dod2
graph save Graph death_patient_2_dod2.gph
log close
log close
timer off 1

//Analytic_variables
clear all
capture log close
log using Analytic_variables.smcl
use Analytic_variables.dta, clear
compress
describe
codebook, compact
log close
timer off 1

//hes_patient
clear all
capture log close
log using hes_patient.smcl
use hes_patient.dta, clear
compress
describe
codebook, compact
log close
timer off 1

//hes_diagnosis_epi
clear all
capture log close
log using hes_diagnosis_epi.smcl
use hes_diagnosis_epi.dta, clear
compress
describe
codebook, compact
log close
timer off 1

//hes_diagnosis_hosp
clear all
capture log close
log using hes_diagnosis_hosp.smcl
use hes_diagnosis_hosp.dta, clear
compress
describe
codebook, compact
log close
timer off 1

//hes_primary_diag_hosp
clear all
capture log close
log using hes_primary_diag_hosp.smcl
use hes_primary_diag_hosp.dta, clear
compress
describe
codebook, compact
log close
timer off 1

//hes_episodes
clear all
capture log close
log using hes_episodes.smcl
use hes_episodes.dta, clear
compress
describe
codebook, compact
log close
timer off 1

//hes_hospital
clear all
capture log close
log using hes_hospital.smcl
use hes_hospital.dta, clear
compress
describe
codebook, compact
log close
timer off 1

//hes_maternity
clear all
capture log close
log using hes_maternity.smcl
use hes_maternity.dta, clear
compress
describe
codebook, compact
log close
timer off 1

//hes_procedures
clear all
capture log close
log using hes_procedures.smcl
use hes_procedures.dta, clear
compress
describe
codebook, compact
assert discharged2>admidate2
log close
timer off 1








