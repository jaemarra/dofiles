//  program:    Data01_import_v4.do
//  task:		Data management of CPRD Data
//				for each data file, import .txt file, re-label variables, change date formats and save as .dta files. Summary_log does not need to be done.
//  project: 	Incretins--Comparative mortality and CV outcomes (CPRD)
//  author:     MA \ May2014 (some codes from Cindy's original coding. See sample dataset .do files for more info on what came from her)  
//				Modified: JM \ Nov 2014

clear all
capture log close
set more off

log using Data01.smcl, replace
timer on 1

////// #1 CPRD-GOLD
// patid and indexdate 
// There is a CPRD file that contains only patid and their indexdate...this is our studyentrydate.
// Use this file to merge with other CPRD data files and drop observations that are >365 days before this date.

/*************************LINKAGE*************************/
//Linkage Eligibility + Coverage: patid, pracid, linked_patient, hes_e, death_e, cprd_e, lsoa_e, start, end
import delimited "13_100_linkage_eligibility.txt"
drop if patid==.
gen cprd_e = .
replace cprd_e = 1 if patientinbuild==1
//generate variables start and end from linkage_coverage.txt (latest start date, earliest end date)
gen startdate =  "01jan1998" if death_e==1
replace startdate = "01apr1998" if hes_e==1
replace startdate = "01jan2001" if cprd_e ==1 
gen start = date(startdate, "DMY")
format start %td
gen enddate = "31mar2012" if cprd_e ==1
replace enddate = "31mar2012" if hes_e==1
replace enddate = "10jan2012" if death_e==1
gen end = date(enddate, "DMY")
format end %td
//drop irrelevant variables
drop startdate enddate patientinbuild acceptable_patient
save linkage_eligibility.dta, replace
clear

/*************************CPRD*************************/
//Case File: patid, studyentrydate_cprd2
import delimited patients_13_100R.txt
//create and label variables
rename indexdate studyentrydate_cprd
label variable studyentrydate_cprd "Study Entry Date (CPRD index date)"
gen studyentrydate_cprd2=date(studyentrydate_cprd, "DMY")
format studyentrydate_cprd2 %td
drop studyentrydate_cprd
label variable studyentrydate_cprd2 "Study Entry Date (CPRD index date)"
//sort and optimize data storage
sort patid
compress
//restrict to patients with non-missing studyentrydate_cprd2
drop if studyentrydate_cprd2 >=.
save patid_date.dta, replace 
clear

//Patient: patid, gender, yob2, marital, frd2, crd2, tod2, toreason, deathdate2, accept, studyentrydate_cprd2
import delimited PET_Patient001.txt
//label variables
label variable patid "Patient identifier"
label variable gender "Gender, 1=male 2=female"
label variable marital "Marital status"
//put yob into HRF
gen yob2 = yob+1800
label variable yob2 "Year of birth"
drop yob
//create and label date variable to change from string to numerical format
gen frd2=date(frd, "DMY")
format frd2 %td
drop frd
label variable frd2 "First registration date"
//create and label date variable to change from string to numerical format
gen crd2=date(crd, "DMY")
format crd2 %td
drop crd
label variable crd2 "Current registration date"
//continue to label variables
label variable regstat "Registration status (transferred out periods)"
label variable reggap "Registration gaps"
label variable internal "Number of internal transfer out periods"
//create and label date variable to change from string to numerical format
generate tod2=date(tod, "DMY")
format tod2 %td
drop tod
label variable tod2 "Transfer out date"
//continue to label variables
label variable toreason "Transfer out reason, 1=death"
//create and label date variable to change from string to numerical format
gen deathdate2=date(deathdate, "DMY")
format deathdate2 %td
drop deathdate
label variable deathdate2 "Date of death"
//continue to label variables
label variable accept "Acceptable patient flag, 1=acceptable 0=unacceptable"
//define and assign value labels to categorical variables 
label define gendervalue 0 "Data not entered" 1 "male"  2 "female" 3 "indeterminate" 4 "unknown"
label values gender gendervalue
label define maritalvalue 0 "Data Not Entered" 1 "Single" 2 "Married" 3 "Widowed" 4 "Divorced" 5 "Separated" 6 "Unknown" 7 "Engaged" 8 "Co-habiting"  9 "Remarried" 10 "Stable relationship" 11 "Civil Partnership"
label values marital maritalvalue
label define regstatvalue 0 "Continuous registration" 1 "one transferred out period" 2 "two transferred out period" 3 "three transferred out period" 5 "five transferred out period"  99 "temporary records"
label values regstat regstatvalue
label define acceptvalue 0 "Unacceptable" 1 "acceptable"
label values accept acceptvalue
//drop irrelevant variables (mob and ses are populated only with 0)
drop vmid famnum chsreg chsdate prescr capsup mob ses
//sort, merge Patient with patid_date (patid, studyentrydate_cprd2), optimize data storage
sort patid
merge 1:1 patid using patid_date.dta
drop _merge
compress
save Patient.dta, replace 
clear 

//Practice: pracid, lcd, uts 
import delimited PET_Practice001.txt
//label variables
label variable pracid "Practice identifier"
//create and label date variable to change from string to numerical format
gen lcd2=date(lcd, "DMY")
format lcd2 %td
drop lcd
label variable lcd2 "LCD in numerical format"
//create and label date variable to change from string to numerical format
gen uts2=date(uts, "DMY")
format uts2 %td
drop uts
label variable uts2 "UTS in numerical format"
//drop irrelevant variables
drop region
//sort, NOT MERGED (NO PATID), optimize data storage
sort pracid
compress
save Practice.dta, replace 
clear

//BaseCohort: patid, gender, yob, marital, crd2, tod2, toreason, deathdate2, studyentrydate_cprd2, pracid
use Patient
//restrict Patients to only include patients that are acceptable
drop if accept==0 | accept>=.
//no longer need accept variable
drop accept
//restrict Patients to only include patients that have gender male or female
drop if gender==0 | gender>=3
//restrict Patients to only include Patients that have data at least 1 year prior to studyentrydate_cprd2
drop if frd2>studyentrydate_cprd2-365
//no longer need frd2 variable
drop frd2
//restrict cohort to patients at least 18 years of age at time of first diabetic prescription (same year as studyentrydate)
gen studyentrydate_year_cprd2 = year(studyentrydate_cprd2)
gen age = studyentrydate_year_cprd2 - yob2
drop if age < 18
drop age
drop studyentrydate_year_cprd2
//restrict cohort to patients whose first ever diabetic prescription is after 31dec2012
drop if studyentrydate_cprd2 > date("31dec2012", "YMD")
//sort, merge with linkage_eligibility
sort patid
merge m:1 patid using linkage_eligibility
compress
//drop irrelevant variables
drop _merge linked_practice 
//sort, merge with Practice, compress
sort pracid
merge m:1 pracid using Practice
drop _merge
compress
//restrict to patients registered at an up to standard practice at least 1 year prior to entry date
drop if uts >= studyentrydate_cprd2-365
save BaseCohort.dta, replace
//create abbreviated BaseCohort with ONLY patid, studyentrydate_cprd2, and pracid
keep patid pracid studyentrydate_cprd2
save BasePatidDate.dta, replace
clear

//Consultation: patid, eventdate2, constype, consid, studyentrydate_cprd2
foreach file in Consultation001 Consultation002 Consultation003 Consultation004 Consultation005 Consultation006 Consultation007 Consultation008 Consultation009 Consultation010 {
clear 
import delimited PET_`file'.txt
//create labels for variables
label variable patid "Patient identifier"
label variable eventdate "Consultation date"
//create and label new date variable to change from string to numerical format
gen eventdate2=date(eventdate, "DMY")
format eventdate2 %td
drop eventdate
//continue creating labels for variables
label variable eventdate2 "Consultation date"
label variable constype "Consultation type"
label variable consid "Consultation identifier"
//drop irrelevant variables
drop sysdate staffid duration
//sort, merge patients (patid, studyentrydate_cprd2) with Consultation, and optimize data storage
sort patid
merge m:1 patid using BasePatidDate, keep(match) nogen
compress
//restrict Consultation to only include data one year prior to studyentrydate_cprd2
drop if eventdate2<studyentrydate_cprd2-365
save `file'.dta, replace
}

//create one Consultation file
use Consultation001, clear
append using Consultation002
append using Consultation003
append using Consultation004
append using Consultation005
append using Consultation006
append using Consultation007
append using Consultation008
append using Consultation009
append using Consultation010
save Consultation, replace
clear 

//Clinical: patid, eventdate2, constype, consid, medcode, episode, enttype, adid, studyentrydate_cprd2
foreach file in Clinical001 Clinical002 Clinical003 Clinical004 Clinical005 ///
		Clinical006 Clinical007 Clinical008 Clinical009 Clinical010 Clinical011 Clinical012 Clinical013 {
clear
import delimited PET_`file'.txt
//label variables
label variable patid "Patient identifier"
label variable eventdate "Event date"
//create and label new date variable to change from string to numerical format
gen eventdate2=date(eventdate, "DMY")
format eventdate2 %td
drop eventdate
label variable eventdate2 "eventdate"
//continue creating labels for variables
label variable constype "Consultation type"
//Assign value label
label define constypevalue 0 "Missing" 1 "Symptom" 2 "Examination" 3 "Diagnosis" 4 "Intervention" 5 "Management" 6 "Administration" 7 "Presenting complaint" 
label values constype constypevalue
//continue creating labels for variables
label variable consid "Consultation identifier"
label variable medcode "Medical code"
label variable episode "Episode type for a specific clinical event"
//Assign value label
label define episodevalue 0 "Data not entered" 1 "First ever" 2 "New event" 3 "Continuing" 4 "Other"
label values episode episodevalue
label variable enttype "Entity type"
label variable adid "Additional details identifier"
//drop irrelevant variables
drop sysdate staffid textid
//sort, merge patients (patid, studyentrydate_cprd2) with Clinical, optimize data storage
sort patid
merge m:1 patid using BasePatidDate, keep(match) nogen
compress
//restrict Clinical to only include data one year prior to studyentrydate_cprd2
drop if eventdate2<studyentrydate_cprd2-365
save `file'.dta, replace
}
clear

use Clinical001
append using Clinical002
append using Clinical003
append using Clinical004
append using Clinical005
append using Clinical006
append using Clinical007
append using Clinical008
append using Clinical009
append using Clinical010
append using Clinical011
append using Clinical012
append using Clinical013
save Clinical, replace
clear

//Additional: patid, enttype, data1, data2, data3, data4, data5, data6, data7, studyentrydate_cprd2
foreach file in Additional001 Additional002 {
clear 
import delimited PET_`file'.txt
//label variables
label variable patid "Patient identifier"
label variable enttype "Entity type"
label variable adid "Additional details identifier"
label variable data1 "Depends on entity type"
label variable data2 "Depends on entity type"
label variable data3 "Depends on entity type"
label variable data4 "Depends on entity type"
label variable data5 "Depends on entity type"
label variable data6 "Depends on entity type"
label variable data7 "Depends on entity type"
save `file'.dta, replace
}
clear 
use Additional001
append using Additional002
save Additional.dta, replace
clear 

//Referral: patid eventdate2, constype, consid, medcode, nhsspec, fhsaspec, studyentrydate_cprd2
import delimited PET_Referral001.txt
//label variables
label variable patid "Patient identifier"
//create and label date variable to change from string to numerical format
gen eventdate2=date(eventdate, "DMY")
format eventdate2 %td
drop eventdate
label variable eventdate2 "Referral date"
//continue to label variables
label variable constype "Consultation type"
label variable consid "Consultation identifier"
label variable medcode "Medical code"
label variable nhsspec "NHS referral speciality"
label variable fhsaspec "FHSA referral speciality"
//define and assign value labels to categorical variables 
label define constypevalue 0 "Missing" 1 "Symptom" 2 "Examination" 3 "Diagnosis" 4 "Intervention" 5 "Management" 6 "Administration" 7 "Presenting complaint"
label values constype ref_constypevalue
label define fhsaspecvalue 0 "No data entered" 1 "General surgical" 2 "General medical" 3 "Orthopaedic" 4 "Rheumatology"  5 "Ear, nose and throat" 6 "Gynaecology" 7 "Obstetrics" 8 "Paediatrics" 9 "Ophthalmology" 10 "Psychiatry" 11 "Geriatrics" 12 "Dermatology" 13 "Neurology" 14 "Genito-Urinary" 15 "X-Ray" 16 "Pathology" 17 "Other" 18 "Non-referral report"
label values fhsaspec fhsaspecvalue
//drop irrelevant variables
drop sysdate staffid textid source inpatient attendance urgency
//sort, merge with patients (patid, studyentrydate_cprd2), optimze data storage
sort patid
merge m:1 patid using BasePatidDate, keep(match) nogen
compress
//restrict to 1 year prior to studyentrydate_cprd2
drop if eventdate2<studyentrydate_cprd2-365
save Referral.dta, replace 
clear 

//Immunisation: patid, eventdate2, constype, consid, medcode, immstype, compound, studyentrydate_cprd2
import delimited PET_Immunisation001.txt
label variable patid "Patient identifier"
//create and label new date variable to change from string to numerical format
gen eventdate2=date(eventdate, "DMY")
format eventdate2 %td
drop eventdate
label variable constype "Consultation type"
label variable consid "Consultation identifier"
label variable medcode "Medical code"
label variable immstype "Immunisation type"
label variable compound "Immunisation compound"
//assign value labels to applicable variables
label define constypevalue 0 "Missing" 1 "Symptom" 2 "Examination" 3 "Diagnosis" 4 "Intervention" 5 "Management" 6 "Administration" 7 "Presenting complaint"
label values constype constypevalue
label define compoundvalue 0 "Data not entered" 1 "DT" 2 "MMR" 3 "DTP" 4 "TD" 5 "TP" 6 "MR" 7 "HIBDTP" 8 "DP" 9 "HEPABTWIN" 10 "HEPATYP" 11 "DTAPIPVHIB" 12 "DTAPIPV" 13 "DTIPV" 14 "HEPATYP2" 15 "HIBMENC" 16 "HEPABAMBRIX" 17 "HEPABAMBPA" 18 "DTAP" 19 "POLIO" 20 "TETANUS" 21 "MENC" 22 "PERTUSSIS" 23 "MUMPS" 24 "TYPTYPHERIX" 25 "HIB" 26 "RUBELLA" 27 "HEPATITIS_B"
label values compound compoundvalue
//generate variable to show which vaccine was given (immstype variable is numeric; use IMT lookup for vaccine names)
tostring immstype, gen(immstype_name)
foreach num of numlist 1/3, 5/12, 14/17, 19/27, 29/70, 77, 80/81, 83, 86/88 {
if immstype==`num' {
replace immstype_name = "Other vaccine" 
}
}
replace immstype_name = "No Data Entered" if immstype==0
replace immstype_name = "flu" if immstype==4
replace immstype_name = "pneumococ" if immstype==13
replace immstype_name = "pneumoconj" if immstype==18
replace immstype_name = "pneumopoly" if immstype==28
replace immstype_name = "pflugen" if immstype==71
replace immstype_name = "pflugsk" if immstype==72
replace immstype_name = "pflugsko" if immstype==73
replace immstype_name = "pflugs" if immstype==74
replace immstype_name = "pflubaxo" if immstype==75
replace immstype_name = "pflubax" if immstype==76
replace immstype_name = "pflugeno" if immstype==78
replace immstype_name = "pneumoconj13" if immstype==82
replace immstype_name = "flusohp" if immstype==84
replace immstype_name = "flusin" if immstype==89
replace immstype_name = "Missing" if immstype==.
replace immstype_name = "Incorrect Data Entered" if immstype>=90 & immstype<.
//drop irrelevant variables
drop sysdate staffid textid stage status source reason method batch
//sort, merge patients (patid, studyentrydate_cprd2) with Immunization, and optimize data storage
sort patid
merge m:1 patid using BasePatidDate, keep(match) nogen
compress
//restrict Immunization to only include data one year prior to studyentrydate_cprd2
drop if eventdate2<studyentrydate_cprd2-365
save Immunisation.dta, replace 
clear 

//Test: patid, eventdate2, constype, consid, medcode, enttype, data1, data2, data3, data4, data5, data6, data7, data8, studyentrydate_cprd2
foreach file in Test001 Test002 Test003 Test004 Test005 Test006 Test007 Test008 Test009 Test010 ///
		Test011 Test012 Test013 Test014  {
clear 
import delimited PET_`file'.txt
//label variables
label variable patid "Patient identifier"
//create and label date variable to change from string to numerical format
gen eventdate2=date(eventdate, "DMY")
format eventdate2 %td
drop eventdate
label variable eventdate2 "Test date"
//continue to label variables
label variable constype "Consultation type"
label variable consid "Consultation identifier"
label variable medcode "Medical code"
label variable enttype "Test entity type"
//define and assign value labels to categorical variables 
label define constypevalue 0 "Missing" 1 "Symptom" 2 "Examination" 3 "Diagnosis" 4 "Intervention" 5 "Management" 6 "Administration" 7 "Presenting complaint"
label values constype constypevalue
//drop irrelevant variables
drop sysdate staffid textid
//sort, merge with patients (patid, studyentrydate_cprd2), optimze data storage
sort patid
merge m:1 patid using BasePatidDate, keep(match) nogen
compress
//restrict to one year prior to studyentrydate_cprd2
drop if eventdate2<studyentrydate_cprd2-365
save `file'.dta, replace
}
clear
use Test001
append using Test002
append using Test003
append using Test004
append using Test005
append using Test006
append using Test007
append using Test008
append using Test009
append using Test010
append using Test011
append using Test012
append using Test013
append using Test014
save Test, replace
clear   

//Therapy: patid, eventdate2, consid, prodcode, bnfcode, qty, ndd, numdays, numpacks, packtype, issueseq, studyentrydate_cprd2
foreach file in Therapy001 Therapy002 Therapy003 Therapy004 Therapy005 Therapy006 Therapy007 Therapy008 ///
		Therapy009 Therapy010 Therapy011 Therapy012 Therapy013 Therapy014 Therapy015 Therapy016 Therapy017  {
clear 
import delimited PET_`file'.txt
label variable patid "Patient identifier"
//create and label date variable to change from string to numerical format
gen rxdate2=date(eventdate, "DMY")
format rxdate2 %td
drop eventdate
label variable rxdate2 "Prescription date"
//continue to label variables
label variable consid "Consultation identifier"
label variable prodcode "Product (treatment) code"
rename bnfcode bnf_nom
label variable bnf_nom "Coded value for the actual BNF code of product"
label variable qty "Total quantity for prescribed product"
label variable ndd "Numeric daily dose"
label variable numdays "Number of treatment days prescribed"
label variable numpacks "Number of individual product packs prescribed"
label variable packtype "Pack size or type of prescribed product"
label variable issueseq "Issue sequence number, 0=no repeat"
//drop irrelevant variables
drop sysdate staffid textid
//sort, merge with patients (patid, studyentrydate_cprd2), optimze data storage
sort patid
merge m:1 patid using BasePatidDate, keep(match) nogen
compress
//restrict to 1 year prior to studyentrydate_cprd2
drop if rxdate2<studyentrydate_cprd2-365
save `file'.dta, replace
}
clear
//create one file for therapy
use Therapy001
append using Therapy002
append using Therapy003
append using Therapy004
append using Therapy005
append using Therapy006
append using Therapy007
append using Therapy008
append using Therapy009
append using Therapy010
append using Therapy011
append using Therapy012
append using Therapy013
append using Therapy014
append using Therapy015
append using Therapy016
append using Therapy017
egen group_cut=cut(patid), group(100)
save Therapy.dta, replace 
//break into groups of 100
	forval i=0/99   {         
		use Therapy if group_cut==`i', clear
		save Therapy_`i', replace
		}
clear		

/*************************ONS*************************/
import delimited death_patient_13_100.txt
gen dod2=date(dod, "DMY")
format dod2 %td
drop dod
label var dod "ONS date of death"
sort patid dod
duplicates drop patid, force
//drop cod's for neonatal patients
drop cause_neonatal1-cause_neonatal8
compress
save death_patient_2, replace
clear 

/*************************HES*************************/
// 1. Patient: patid, pracid, gen_HESid
import delimited hes_patient13_100.txt
label variable pracid "The encrypted unique identifier given to a practice in CPRD GOLD"
label variable gen_hesid "A generated unique identifier assigned to a patient in the HES data. An individual that has contributed data to more than one GOLD practice has the same gen_HESid"
//drop irrelevant variables
drop ethnos n_patid_hes
//sort, merge with , optimize data storage
sort patid
compress
//restrict by
save hes_patient.dta, replace 
clear 

// ACP (augmented care periods) not utilized

// CC (critical care periods) not utilized

// Diagnosis by episode
import delimited hes_diagnosis_epi13_100.txt
//label variables
label variable spno "Number uniquely identifying a hospitalisation"
label variable epikey "Episode key uniquely identifying an episode of care"
label variable epistart "Start date of episode of care"
label variable epiend "Date of end of episode"
label variable icd "ICD10 diagnosis code in XXX or XXX.X format"
label variable icdx "5th/6th characters of the ICD code (if available)"
label variable d_order "Ordering of diagnosis code in episode, within range 1-20"
//create and label date variables
gen epistart2=date(epistart, "DMY")
format epistart2 %td
drop epistart
label variable epistart2 "Date of start of episode"
gen epiend2=date(epiend, "DMY")
format epiend2 %td
drop epiend
label variable epiend2 "Date of end of episode"
//sort, merge with patid_date, optimize
sort patid
merge m:1 patid using BasePatidDate, keep(match) nogen
compress
//restrict to episodes within 1 year prior to studyentrydate_cprd2
drop if epistart2<studyentrydate_cprd2-365
save hes_diagnosis_epi.dta, replace 
clear 

// Diagnosis by hospitalization
import delimited hes_diagnosis_hosp13_100.txt
//label variables
label variable spno "Spell number uniquely identifying a hospitalisation"
label variable admidate "Date of admission"
label variable discharged "Date of discharge"
label variable icd "ICD10 diagnosis code in XXX or XXX.X format"
label variable icdx "5th/6th characters of the ICD code (if available)"
//create and label date variables
gen admidate2=date(admidate, "DMY")
format admidate2 %td
drop admidate
label variable admidate2 "Date of admission"
gen discharged2=date(discharged, "DMY")
format discharged2 %td
drop discharged
label variable discharged2 "Date of discharge"
//sort, merge with patid_date, optimize
sort patid
merge m:1 patid using BasePatidDate, keep(match) nogen
compress
//restrict to episodes within 1 year prior to studyentrydate_cprd2
drop if admidate2<studyentrydate_cprd2-365
save hes_diagnosis_hosp.dta, replace 
clear 

// Primary diagnoses across a hospitalization
import delimited hes_primary_diag_hosp13_100.txt
//label variables
label variable spno "Spell number uniquely identifying a hospitalisation"
label variable admidate "Date of admission"
label variable discharged "Date of discharge"
label variable icd_primary "Primary ICD10 diagnosis code in XXX or XXX.X format"
label variable icdx "5th/6th characters of the ICD code (if available)"
//create and label date variables
gen admidate2=date(admidate, "DMY")
format admidate2 %td
drop admidate
label variable admidate2 "Date of admission"
gen discharged2=date(discharged, "DMY")
format discharged2 %td
drop discharged
label variable  discharged2 "Date of discharge"
//sort, merge with patid_date, optimize
sort patid
merge m:1 patid using BasePatidDate, keep(match) nogen
compress
//restrict to episodes within 1 year prior to studyentrydate_cprd2
drop if admidate2<studyentrydate_cprd2-365
save hes_primary_diag_hosp.dta, replace 
clear 

// Episodes
import delimited hes_episodes13_100.txt
//label variables
label variable spno "Spell number uniquely identifying a hospitalisation"
label variable epikey "Episode key uniquely identifying an episode of care"
label variable admidate "Date of admission"
label variable epistart "Date of start of episode"
label variable epiend "Date of end of episode"
label variable discharged "Date of discharge"
label variable epitype "Type of episode (general, delivery, birth, psychiatric etc.)"
//create and label date variables
gen admidate2=date(admidate, "DMY")
format admidate2 %td
drop admidate
label variable admidate2 "Date of admission"
gen epistart2=date(epistart, "DMY")
format epistart2 %td
drop epistart
label variable epistart2 "Date of start of episode"
gen epiend2=date(epiend, "DMY")
format epiend2 %td
drop epiend
label variable epiend2 "Date of end of episode"
gen discharged2=date(discharged, "DMY")
format discharged2 %td
drop discharged
label variable discharged2 "Date of discharge"
//drop irrelevant variables
drop eorder epidur admimeth admisorc disdest dismeth mainspef tretspef pconsult intmanig classpat firstreg
//sort, merge, and optimize data storage
sort patid
merge m:1 patid using BasePatidDate, keep(match) nogen
//restrict to episodes within 1 year prior to studyentrydate_cprd2
drop if admidate2<studyentrydate_cprd2-365
compress
save hes_episodes.dta, replace 
clear 

// Hospital
import delimited hes_hospital13_100.txt
//label variables
label variable spno "Spell number uniquely identifying a hospitalisation"
label variable admidate "Date of admission"
label variable discharged "Date of discharge"
label variable duration "Duration of hospitalisation spell in days"
//create and label date variables
gen admidate2=date(admidate, "DMY")
format admidate2 %td
drop admidate
label variable admidate2 "Date of admission"
gen discharged2=date(discharged, "DMY")
format discharged2 %td
drop discharged
label variable discharged2 "Date of discharge"
gen elecdate2=date(elecdate, "DMY")
format elecdate2 %td
drop elecdate
label variable elecdate2 "Date of decision to admit patient"
//drop irrelevant variables
drop admimeth admisorc disdest dismeth elecdate elecdur
//sort, merge, and optimize data storage
sort patid
merge m:1 patid using BasePatidDate, keep(match) nogen
compress
//restrict to episodes within 1 year prior to studyentrydate_cprd2
drop if admidate2<studyentrydate_cprd2-365
save hes_hospital.dta, replace 
clear 

// Maternity (did not originally include, but added in for completeness)
import delimited hes_maternity13_100.txt
//label variables
label variable spno "Spell number uniquely identifying a hospitalisation"
label variable epikey "Episode key uniquely identifying an episode of care"
label variable epistart "Date of start of episode"
label variable epiend "Date of end of episode"
label variable epidur "Duration of episode in days"
label variable anasdate "First antenatal assessment date"
label variable anagest "Gestation period in weeks at the date of the first antenatal assessment (calculated from anadate, gestat and the dobbaby)"
label variable gestat "Length of gestation - number of completed weeks of gestation"
label variable numpreg "Number of previous pregnancies that resulted in a registrable birth (live or still born)"
label variable matage "Mother's age at delivery"
//create and label date variables
gen epistart2=date(epistart, "DMY")
format epistart2 %td
drop epistart
label variable epistart2 "Date of start of episode"
gen epiend2=date(epiend, "DMY")
format epiend2 %td
drop epiend
label variable epiend2 "Date of end of episode"
gen anasdate2=date(anasdate, "DMY")
format anasdate2 %td
drop anasdate
label variable anasdate2 "First antenatal assessment date"
//drop irrelevant variables
drop eorder numbaby numtailb matordr neocare wellbaby birordr birstat biresus sexbaby birweit delmeth delonset delinten delplac delchang delprean delposan delstat neodur antedur postdur
//sort, merge, and optimize data storage
sort patid
merge m:1 patid using BasePatidDate, keep(match) nogen
compress
//restrict to pregnancies within 1 year prior to studyentrydate_cprd2
drop if epistart<studyentrydate_cprd2-365
save hes_maternity.dta, replace 
clear 

// Procedures
import delimited hes_procedures_epi13_100.txt
label variable spno "Spell number uniquely identifying a hospitalisation"
label variable epikey "Episode key uniquely identifying an episode of care"
label variable admidate "Date of admission"
label variable discharged "Date of discharge"
label variable opcs "An OPCS 4 procedure code"
//create and label date variables
gen admidate2=date(admidate, "DMY")
format admidate2 %td
drop admidate
label variable admidate2 "Date of admission"
gen discharged2=date(discharged, "DMY")
format discharged2 %td
drop discharged
label variable discharged2 "Date of discharge"
gen eventdate2=date(evdate, "DMY")
format eventdate2 %td
drop evdate
label variable eventdate2 "Date of operation/procedure"
//drop irrelevant variables
drop epistart epiend p_order
//sort, merge, and optimize storage
sort patid
merge m:1 patid using BasePatidDate, keep(match) nogen
compress
//restrict to procedures within 1 year prior to studyentrydate_cprd2
drop if admidate2<studyentrydate_cprd2-365
save hes_procedures.dta, replace 
clear 

////////////////////////////////////////////
timer off 1 
timer list 1
exit
log close
