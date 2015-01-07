//  program:    Data_master.do
//  task:		Master List of .do Files
//  project: 	Incretins--Comparative mortality and CV outcomes (CPRD)
//  authors:     MA \ May2014 \ jmg modified June 17, 2014 JM \ Jan2015

//	Run the following .do files, in order listed, to complete dataset management and cohort preparation. 

log using Data_master.smcl, replace
timer on 1
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
/* #1 Data01_import: 	----CPRD----
						+ PATIENTS (patients_13_100R)
						+ LINKAGE (linkage_eligibility, linkage_coverage) 
						+ PET_Patient001
						+ PET_Practice001
						+ PET_Consultation001-010
						+ PET_Clinical001-013
						+ PET_Additional001-002
						+ PET_Referral001
						+ PET_Immunisation001
						+ PET_Test001-014
						+ PET_Therapy001-017
						----ONS----
						+ death_patient_13_100R
						----HES----
						+ hes_patient_13_100R
						<OMIT hes_acp_13_100R>
						<OMIT hes_cc_13_100R>
						+ hes_diagnosis_epi_13_100R
						+ hes_diagnosis_hosp_13_100R
						+ hes_primary_diag_hosp_13_100R
						+ hes_episodes_13_100R
						+ hes_hospital_13_100R
						+ hes_maternity_13_100R
						+ hes_proedures_13_100R

For each imported file: 
1. drop missing, out of range, unacceptable patients
2. label all 'keep' variables and generate and label necessary new variables
3. define and assign value labels to categorical variables
4. drop irrelevant variables
5. restrict to patients with data available for at least one year prior to studyentrydate_cprd2
6. sort, merge with patid_date (and any other relevant files), optimize data storage (compress)
7. save					
*/

do Data01_import
/* Files saved:			patid_dates.dta
						Patient.dta
						Practice.dta
						BasePatidDate.dta
						Consultation.dta (appended Consultation001-010)
						Clinical.dta (appended Clinical001-013)
						Additional.dta (appended Additional001-002)
						Referral.dta
						Immunization.dta
						Test.dta (appended Test001-014)
						Therapy_0-99 (appended Thearpy001-017; group & cut into 100)
						death_patient_13_100.dta
						hes_patient.dta
						<OMIT hes_acp>
						<OMIT hes_cc>
						hes_diagnosis_epi.dta
						hes_diagnosis_hosp.dta
						hes_primary_diag_hosp.dta
						hes_episodes.dta
						hes_hospital.dta
						hes_maternity.dta
						hes_proedures.dta
*/

//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
/* #2 Data02_support:	+ bnfcodes	-->	rename bnfcode bnf_nom (actual BNF code)
									-->	rename bnf bnfcode (chapter and section)
						+ common_dosages
						+ medical
						+ packtype
						+ product	-->	rename bnfcode prod_bnfcode
									--> encode route, generate(nroute)
						+ scoremethod
						
For each file: import, label, rename, compress, save						
*/

do Data02_support
/*	Files saved:		Bnfcodes.dta
						commondosages.dta
						medical.dta
						packtype.dta
						product.dta
						scoremethod.dta
Merged files saved:		Therapy_0-99.dta (merged 1:1 Bnfcodes, 1:1 packtype, 1:1 product)
						Clinical001_2-0013_2.dta (merged 1:1 medical)
						hes (merged 1:1 BasePatidDate + joinby hes_hospital, hes_episodes, hes_diagnosis_epi, hes_diagnosis_hosp, hes_procedures, hes_maternity)
*/			

//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////		
/* #3 Data03_drugexposures:	use Therapy_0-99
							- generate variables indicating drug exposures for antidiabetic drugs				
							- generate cohortentrydate, indexdate and studyentrydate variables
							- generate duration, gap dates and stop dates										
							- generate variables indicating drug exposures for potential medication covariates
							- generate variables for number of unique drugs and medication adherence
*/

do Data03_drugexposures
//	Files saved:	Exposures.dta

//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
// #4 Data04_dates:	use Exposures.dta to keep dataset of patid, cohort entry date, index date, study entry date

do Data04_dates
// 	Files saved: 	Dates.dta  				

//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
/* #5 Data05_immunisations: - use Immunisation
							- merge 1:1 with Dates.dta
							- generate binary variables for flu, pneumo and other vaccines in year prior to cohortentrydate, indexdate, studyentrydate
							- collapse, optimize data storage, save
*/

do Data05_immunisations
/*	Files saved: 	Immunisation2.dta
*/

//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
// #6 Data06_demographics: 	- generate variables for patient demographics (age, sex, marital status)

do Data06_demographics
/*	Files saved: 	Demographic.dta
*/

//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
/* #7 Data07_ses: 	import PatientSES_imd2010_13_100 
					merge m:1 Dates
					label
					optimize data storage
					save
*/

do Data07_ses
/*	Files saved: 	ses.dta
*/

//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
/* #8 Data08_outcomes:	One .do file for each dataset-- 
						a) CPRD-GOLD
							use Clinical001_2-013_2
							- merge m:1 with Dates
							- joinby Additional
							- merge m:1 with Patient2
							- generate variables for PRIMARY OUTCOMES:	death_g (all-cause mortality)
																		myoinfarct_g (MI)
																		stroke_g (stroke not including TIA)
																		cvdeath_g (CV-cause mortality)
							- generate variables for SECONDARIES: 		heartfail_g (any heart failure)
																		arrhythmia_g (any caridac arrhythmia)
																		revasc_g (1st occurrence of hospitalization or death)
							- generate dates for primaries and secondaries
*/
do Data08_outcomes_a
/*	Files saved: 	Clinical001_2b - Clinical013_2b
					Outcomes_gold_Clinical001_2- Clinical013_2.dta
					Outcomes_gold.dta (appended Outcomes_gold_Clinical001_2-Clinical013_2)
					
						b) HES
							use hes.dta
							- merge m:1 with Dates
							- generate variables for PRIMARY OUTCOMES:	myoinfarct_h (MI)
																		stroke_h (stroke not including TIA)
																		cvdeath_h (CV-cause mortality)
							- generate variables for SECONDARIES: 		heartfail_h (any heart failure)
																		arrhythmia_h (any caridac arrhythmia)
																		angina_h
							- generate dates for primaries and secondaries
							use Procedures.dta
							- merge m:1 with Dates
							- generate revasc_opcs (1st occurrence of hospitalization or death)
							- generate dates for revasc_opcs
*/
do Data08_outcomes_b
/*	Files saved: 	Outcomes_hes.dta
					Outcomes_procedures. dta
					
						c) ONS
							use death_patient_2
							- merge m:1 with Dates
							- generate variables for PRIMARY OUTCOMES: 	death_ons (all cause mortality)
																		myoinfarct_o (MI)
																		stroke_o (stroke not including TIA)
																		cvdeath_o (CV-cause mortality)									
							- generate variables for SECONDARIES:		heartfail_o (any heart failure)
																		arrhythmia_o (any caridac arrhythmia)
																		angina_o 
							- generate dates for primaries and secondaries
*/
do Data08_outcomes_c
/*	Files saved:	Outcomes_ons.dta

						d) composite
									use Outcomes_gold
									- merge 1:1 Outcomes_hes
									- merge 1:1 Outcomes_procedures
									- merge 1:1 Outcomes_ons
									- generate variables for primary CV composite outcome and associated date from each source (GOLD, HES, ONS)
									- generate variables for first event after index date overall (one each for MI, stroke, cvdeath, heartfail, arrhythmia, angina, revasc)
									- generate variables for first event after studyentrydate_cprd2 overall (one each for MI, stroke, cvdeath, heartfail, arrhythmia, angina, revasc)
*/
do Data08_outcomes_d
/*	Files saved:	Outcomes. dta
*/

//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
/*
#9 Data09_clinicalcovariates: 	use Clinical001_2-013_2
									- merge m:1 with Dates
									- joinby Additional
									- merge m:1 with Patient2
									- generate covtype
									- generate variables for all clinical covariates of interest height, weight, sys_bp, smoking, alcohol
									- generate variables for outcome covariates: MI, stroke, HF, Arr, revasc, htn, afib, pvd, (removed hyperlipidemia)
									- generate charlindex (Charlson Comorbidity Index weight)
									- create variable for eligible dates
									- pull out dates and associated covariates of interest, create counts, enumerate covtypes, keep obs relevant to window
									- rectangularize, fillin, drop unwanted, reshape, save
*/
do Data09_clinicalcovariates	
/*	Files saved:	Clincovs_indexdate.dta
					Clincovs_cohortentrydate.dta
					Clincovs_studyentrydate_cprd2.dta
					Clincovs.dta
*/
					
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
/* #10 Data10_labcovariates:  	use Test001-014
									- merge m:1 with Dates
									- merge m:1 with Demographic
									- merge m:1 with Clincovs
									- generate continuous lab variables
									- estimate eGFR
									- generate binary lab variables
									- create variable for eligible dates
									- pull out dates and associated covariates of interest, create counts, enumerate covtypes, keep obs relevant to window
									- rectangularize, fillin, drop unwanted, reshape, save
*/
do Data10_labcovariates
/*	Files saved: 	Labcovs_indexdate.dta
					Labcovs_cohortentrydate.dta
					Labcovs_studyentrydate_cprd2.dta
					Labcovs.dta
*/

//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
/* #11 Data11_servicescovariates:	use Clinical001_2b-013_2b
									- generate servtype
									- generate variables for all service utilization covariates of interest: physician visits, hospital visits, days in hospital
									- create variable for eligible dates
									- pull out dates and associated covariates of interest, create counts, keep obs relevant to window
									- rectangularize, fillin, drop unwanted, reshape, save
*/
do Data11_servicescovariates
/*Files saved:		Servcovs_indexdate.dta
					Servcovs_cohortentrydate.dta
					Servcovs_studyentrydate_cprd2.dta
					Servcovs.dta
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
// IN PROCESS #11 Data11_analytic_dataset --> Create main analytic cohort by merging 1) Exposure dataset, 2) Immunizations dataset, 		
//												  3) Demographic dataset, 4) SES dataset, 5) Outcome dataset, 6) Labcovariate dataset, 
//												  7) Covariate dataset
//				 							    -apply exclusion criteria (patients age <30 years of age on cohort entry, patients w PCOS, patients who are pregnant) 
//												-set datasignature at the end of this file

do Data12_analytic_dataset

////////////////////////////////////////////
timer off 1
timer list 1

exit
log close

