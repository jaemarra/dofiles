//  program:    Data_master.do
//  task:		Master List of .do Files
//  project: 	Incretins--Comparative mortality and CV outcomes (CPRD)
//  authors:     MA, JMG, JM

//	Run the following .do files, in order listed, to complete dataset management and cohort preparation. 

clear all
capture log close
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
						BaseCohort.dta
						Censor.dta
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
/* #3 Data03_drug_exposures_a:	use Therapy_0-49
								- prepare Therapy files and product.txt
								- generate variables indicating drug exposures to antidiabetic drugs				
								- encode categorical variable (rxtype)
								- Collapse exact duplicate prescriptions
								- generate OVERALL first antidiabetic prescription date
								- pull out first ever antidiabetic exposure type(s)
								- pull out second antidiabetic exposure type(s) and associated date
								- generate and apply censor dates
								- Pull out first, predicted, next, and last prescription dates WITHIN EACH CLASS
								- Generate gap variables between predicted and observed prescription dates WITHIN EACH CLASS										
								- Generate duration for EXPOSED intervals FOR EACH PRESCRIPTION
								- Generate duration for UNEXPOSED intervals
								- generate total exposure duration to each class of interest
								- generate variables for number of unique drugs and medication adherence
								- save Dates.dta dataset with patid, studyentrydate_cprd2, cohortentrydate, and indexdate
								- save analytic variables with concat first-seventhadmrx, first-seventdates, cohort_b, tx and from Data01_Import: linked_b lcd2 tod2 deathdate2 dod2
*/

do Data03_drug_exposures_a
/*	Files saved:	Therapy_0-49dm.dta (tempfiles only)
					adm_drug_exposures.dta (intermediate file primarily for data checking stage)
					Drug_Exposures_a.dta
					Dates.dta
					Analytic_variables.dta
					Drug_Exposures_a_wide.dta
*/

/* #3 Data03_drug_exposures_b:	use Therapy_0-49
								- prepare Therapy files and product.txt
								- generate variables indicating drug exposures to subclasses of antidiabetic drugs				
								- generate variables for number of unique drugs and medication adherence
*/
do Data03_drug_exposures_b
/*	Files saved:	drugexpb_0-49
					Drug_Exposures_b.dta
*/
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
/* #3 Data04_drug_covariates:	use Therapy_0-49
								- do Data04_drug_covariates_loop to call the actual do file and loop all Therapy files through
								- extract medication covariates of interest using gemscriptcodes
								- restrict to one year prior to the dates of interest		
								- generate variables for number of unique drugs and medication adherence
*/

do Data04_drug_covariates_loop
/* 	Files saved: 	drug_covariates_0-49
					Drug_Covariates
*/
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
/*	Files saved: 	Clinical001_2a - Clinical013_2a
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
#9 Data09_clinicalcovariates_a: 	a)	use Clinical001_2-013_2
										- merge m:1 with Dates
										- joinby Additional
										- merge m:1 with Patient2
										- generate Clinical2b files for use in Data09-Data11
										- generate covtype
										- generate variables for all clinical covariates of interest height, weight, sys_bp, smoking, alcohol
										- generate variables for outcome covariates: MI, stroke, HF, Arr, revasc, htn, afib, pvd, (removed hyperlipidemia)
										- generate cci (Charlson Comorbidity Index weight)
										- create feeder files for windows for all covariates except cci
										- create feeder files for windows for cci
										- create variable for eligible dates
										- pull out dates and associated covariates of interest, create counts, enumerate covtypes, keep obs relevant to window
										- rectangularize, fillin, drop unwanted, reshape, save
										- create weight covariate file for Data10-LabCovariates (conains patid and weight only)
*/
do Data09_clinicalcovariates_a
/*	Files saved:	Clinical00X_2b.dta (13 intermediate files)
					Clinical00X_2b_cov.dta (13 intermediate files)
					Clinical00X_2b_cov_i.dta (13 intermediate files)
					Clinical00X_2b_cov_s.dta (13 intermediate files)
					Clinical00X_2b_cov_c.dta (13 intermediate files)
					Clinical00X_2b_cov_cci_i.dta (13 intermediate files)
					Clinical00X_2b_cov_cci_s.dta (13 intermediate files)
					Clinical00X_2b_cov_cci_c.dta (13 intermediate files)
					Clinical00X_2b_cov_wt.dta (13 intermediate files)
					ClinicalCovariates_i.dta
					ClinicalCovariates_c.dta
					ClinicalCovariates_s.dta
					Clinical_cci_i.dta
					Clinical_cci_s.dta
					Clinical_cci_c.dta
					ClinicalCovariates_wt.dta
					
#9 Data09_clinicalcovariates_b: 	b)	use hes.dta (all hes files merged)
										- merge m:1 with Dates
										- generate covtype
										- generate variables for outcome covariates: MI, stroke, HF, Arr, revasc, htn, afib, pvd, (removed hyperlipidemia)
										- generate cci (Charlson Comorbidity Index weight)
										- create variable for eligible dates
										- pull out dates and associated covariates of interest, create counts, enumerate covtypes, keep obs relevant to window
										- rectangularize, fillin, drop unwanted, reshape, save 
*/
do Data09_clinicalcovariates_b

/*	Files saved:	hes_cov.dta (intermediate file)
					hesCovariates_i.dta
					hesCovariates_c.dta
					hesCovariates_s.dta
					hes_cci_i.dta
					hes_cci_c.dta
					hes_cci_s.dta

#9 Data09_clinicalcovariates_c: 	c)	use ClinicalCovariates_i
										- merge 1:1 patid using hesCovariates_i
										- merge 1:1 patid using Clinical_cci_i
										- merge 1:1 patid using hes_cci_i
										use ClinicalCovariates_c
										- merge 1:1 patid using hesCovariates_c
										- merge 1:1 patid using Clinical_cci_c
										- merge 1:1 patid using hes_cci_c
										use ClinicalCovariates_s
										- merge 1:1 patid using hesCovariates_s
										- merge 1:1 patid using Clinical_cci_s
										- merge 1:1 patid using hes_cci_s
*/
do Data09_clinicalcovariates_c

/*	Files saved:	ClinicalCovariates_merged_i.dta
					ClinicalCovariates_merged_c.dta
					ClinicalCovariates_merged_s.dta
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
#10 Data10_labcovariates:  			use Test001-014
									- merge m:1 with Dates
									- merge m:1 with Demographic
									- merge m:1 with ClinicalCovariates_wt
									- generate continuous lab variables
									- estimate eGFR
									- generate binary lab variables
									- create variable for eligible dates
									- pull out dates and associated covariates of interest, create counts, enumerate covtypes, keep obs relevant to window
									- rectangularize, fillin, drop unwanted, reshape, save
*/
do Data10_labcovariates
/*	Files saved: 	LabCovariates.dta (intermediate)
					LabCovariates_c.dta
					LabCovariates_s.dta
					LabCovariates_i.dta
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
#11 Data11_servicescovariates:	use Clinical001_2b-013_2b
									- generate servtype
									- generate variables for all service utilization covariates of interest: physician visits, hospital visits, days in hospital
									- create variable for eligible dates
									- pull out dates and associated covariates of interest, create counts, keep obs relevant to window
									- rectangularize, fillin, drop unwanted, reshape, save
*/
do Data11_servicescovariates_a
/*Files saved:		Clin_serv.dta (intermediate file)
					Clin_serv_s.dta
					Clin_serv_c.dta
					Clin_serv_i.dta
*/
do Data11_servicescovariates_b
/*Files saved:		hes_serv.dta (intermediate file)
					hes_serv_s.dta
					hes_serv_c.dta
					hes_serv_i.dta
*/
do Data11_servicescovariates_c
/*Files saved:	ServicesCovariates_s.dta
				ServicesCovariates_c.dta
				ServicesCovariates_i.dta
				
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
#00 Data00_exclusion:	use Clinical001_2-013_2
						- generate exclusion variables for pcos, pregnancy, and gestational diabetes using cprd clinical files
						use hes
						- generate exclusion variables for pcos, pregnancy, and gestational diabetes using hes data
						use hes_maternity
						- generate exclusion variable for pregnancy using hes_maternity data
						- merge all together and keep a maximum value of 1 for each indicator
*/					
do Data00_exclusion
/* Files saved:	Exclusion_cprd.dta
				Exclusion_hes.dta
				Exclusion_hes_mat.dta
				Exclusion_merged.dta
*/
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
// IN PROCESS #12 Data11_analytic_dataset --> Create main analytic cohort by merging 1) Exposure dataset, 2) Immunizations dataset, 		
//												  3) Demographic dataset, 4) SES dataset, 5) Outcome dataset, 6) Clinical covariate dataset
//												  7) Labcovariate dataset, and 8)Services covariate dataset
//				 							    -merge in exclusion variables (patients age <30 years of age on cohort entry, patients w PCOS, patients who are pregnant) 
//												-set datasignature at the end of this file
*/
do Data12_analytic_dataset
/* Files saved:	raw_dataset.dta
				Analytic_Dataset_s.dta
				Analytic_Dataset_c.dta
				Analytic_Dataset_i.dta
				Analytic_Dataset_Master.dta
*/
////////////////////////////////////////////
timer off 1
timer list 1

exit
log close

