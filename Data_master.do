//  program:    Data_master.do
//  task:		Master List of .do Files
//  project: 	Incretins--Comparative mortality and CV outcomes (CPRD)
//  authors:     MA \ May2014 \ jmg modified June 17, 2014 JM \ Dec2014

//	status:		IN PROGRESS (17JUNE2014)

//	Run the following .do files, in order listed, to complete dataset management and cohort preparation. 

log using Data_master.smcl, replace
timer on 1

/* #1 Data01_import: 	----CPRD----
						  PATIENTS (patients_13_100R)
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
do Data01_import

/* Creates:				patid_dates
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
// #2 Data02_support --> SUPPORT FILES- imports .txt files, changes variable names/labels and dates as needed, saves as .dta files
//										-merge support files with data files
//										-merge bnfcodes, packtype, product into Therapy 
//										-merge medical into Clinical 							

do Data02_support


// #3 Data03_drugexposures --> generate variables indicating drug exposures for antidiabetic drugs				
//							 -generate cohortentrydate, indexdate and studyentrydate variables
//							 -generate duration, gap dates and stop dates										
//							 -generate variables indicating drug exposures for potential medication covariates
//							 -generate variables for number of unique drugs and medication adherence


do Data03_drugexposures


// #4 Data04_dates --> generate dataset of patid, cohort entry date, index date, study entry date


do Data04_dates  				


// #5 Data05_immunisations --> generate dataset of vaccine records for patients
//							  -generate variables for flu, pneumo and other vaccines in year prior to cohortentrydate, indexdate, studyentrydate

do Data05_immunisations


// #6 Data06_demographics --> generate variables for patient demographics (age, sex, marital status)

do Data06_demographics


// #7 Data07_ses --> import SES data 

do Data07_ses


// #8 Data08_outcomes --> One .do file for each dataset-- CPRD-GOLD [a], HES [b], ONS [c], composite [d])
//									-generate indicator and date variables indicating clinical events (for each data source) 
//									-generate variables of first event from each source


do Data08_outcomes_a
do Data08_outcomes_b
do Data08_outcomes_c
do Data08_outcomes_d

// #9 Data09_clinicalcovariates --> generate variables indicating lab test results and dates 				
//							 			 -generate variable indicating number of unique lab tests  	

do Data09_clinicalcovariates	


// #10 Data10_labcovariates --> One .do file for each dataset-- CPRD-GOLD [a], HES [b], composite [c])
//									   -generate variables indicating comorbidities	and other covariates (ht, wt, smoking, alcohol, etc)
		
do Data10_labcovariates

// #11 Data11_servicescovariates --> One .do file for each dataset-- CPRD-GOLD [a], HES [b], composite [c])
//									   -generate variables indicating comorbidities	and other covariates (ht, wt, smoking, alcohol, etc)
do Data11_servicescovariates

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

