/  program:     Stat01_Baseline_Characteristics.do
//  task:		Statistical analyses of Analytic_Dataset_Master.dta USING YEAR BEFORE INDEX WINDOW
//				Identify patients for exclusion, apply exclusion, and extract cohort characterisitics.
//  project: 	Incretins--Comparative mortality and CV outcomes (CPRD)
//  author:     JM \ Mar2015  
//				

clear all
capture log close
set more off
log using Data01.smcl, replace
timer on 1

//SOCIODEMOGRAPHICS//
//Exclusion unification
gen exclude=1 if (gest_diab==1|pcos==1|preg==1|age_indexdate<=29|cohort_b==0)
replace exclude=0 if exclude!=1
label var exclude "Bin ind for pcos, preg, gest_diab, <30yo, or uts; excluded=1, not excluded=0)
tab exclude

//Age
generate age_cat = age_indexdate
summ age_indexdate
recode age_cat (min/29=0) (30/39=1) (40/49=2) (50/59=3) (60/69=4) (70/79=5) (80/89=6) (89/max=7)
label define age_cats 0 "under 30" 1 "30-39" 2 "40-49" 3 "50-59" 4 "60-69" 5 "70-79" 6 "80-89" 7 "90+"
label values age_cat age_cats
tab age_cat if exclude==0

//Gender
tab gender if exclude==0

//Marital status 
label define maritalstatus_cats 1 "Unknown" 2 "Single" 3 "Married" 4 "Widowed" 5 "Divorced or separated" 6 "Other (engaged, remarried, cohabitation, civil parnership)"
label values maritalstatus maritalstatus_cats
tab maritalstatus if exclude==0

//Socioeconomic status
label define ses_cats 1 "1=Least Deprived" 5 "5=Most Deprived" 9 "Unknown"
label values imd2010_5 ses_cats
tab imd2010_5 if exclude==0

//Smoking status
label define smoking_cats 0 "Unknown" 1 "Current" 2 "Non" 3 "Former"
label values prx_covvalue_g_i4 smoking_cats
tab prx_covvalue_g_i4 if exclude==0

//Alcohol abuse
label define alcohol_cats 0 "Unknown" 1 "Current" 2 "Non" 3 "Former"
label values prx_covvalue_g_i5 alcohol_cats
tab prx_covvalue_g_i5 if exclude==0

//HEALTH SERVICES UTILIZATON
//Physician Visits
gen physician_vis=totservs_g_i
recode physician_vis (0=0)(1/12=1) (13/24=2) (25/36=3) (37/48=4) (49/max=5) (.=6)
label define visits_cats 0 "None" 1 "One per month or less" 2 "Two per month" 3 "Three per month" 4 "Four per month" 5 "One or more per week" 6 "Unknown"
label values physician_vis visits_cats
tab physician_vis if exclude==0

//Number of hospitalizations
gen hospitalizations=prx_servvalue2_h_i
recode hospitalizations (0=0) (1=1) (2=2) (3=3) (4=4) (5=5) (6/12=6) (13/max=7) (.=8)
label define hosp_cats 0 "None" 1 "One" 2 "Two" 3 "Three" 4 "Four" 5 "Five" 6 "Six to Twelve" 7 "More than Twelve" 8 "Unknown"
label values hospitalizations hosp_cats
tab hospitalizations if exclude==0

//Hospital Services
gen hosp_services = totservs_h_i
recode hosp_services (min/100=0) (101/200=1) (201/300=2) (301/400=3) (401/500=4) (501/600=5) (601/700=6) (701/800=7) (801/900=8) (901/1000=9) (1001/max=10) (.=11)
label define hosp_services_cats 0 "0-100" 1 "101-200" 2 "201-300" 3 "301-400" 4 "401-500" 5 "501-600" 6 "601-700" 7 "701-800" 8 "801-900" 9 "901-1000" 10 "More than 1000" 11 "Unknown"
label values hosp_services hosp_services_cats
tab hosp_services if exclude==0

//Duration of Hospital Stay
gen hosp_days = prx_servvalue3_h_i
recode hosp_days (min/7=0) (8/14=1) (15/21=2) (22/28=3) (29/35=4) (36/42=5) (43/49=6) (50/56=7) (57/63=8) (64/70=9) (71/max=10) (.=11)
label define hosp_days_cats 0 "Up to 1 week" 1 "2 weeks" 2 "3 weeks" 3 "4 weeks" 4 "5 weeks" 5 "6 weeks" 6 "7 weeks" 7 "8 weeks" 8 "9 weeks" 9 "10 weeks" 10 "More than 10 weeks" 11 "unknown"
label values hosp_days hosp_days_cats
tab hosp_days if exclude==0

//MEDICATIONS
//Number of unique drug classes
gen unique_cov_drugs = unqrxi
recode unique_cov_drugs (.=0) (0/5=1) (6/10=2) (11/15=3) (16/20=4) (21/max=5)
label define unique_cov_drugs_cats 0 "Unknown" 1 "0-5" 2 "6-10" 3 "11-15" 4 "16-20" 5 "More than 20"
label values unique_cov_drugs unique_cov_drugs_cats
tab unique_cov_drugs if exclude==0

//Number of unique antidiabetic drug classes
label define unqrx_cats 0 "None" 1 "One" 2 "Two" 3 "Three" 4 "Four" 5 "Five" 6 "Six" 7 "More than six"
label values unqrx unqrx_cats
tab unqrx if exclude==0

//COMORBIDITIES
//Angina comorbidity
gen angina_com_i = 1 if (prx_cov_g_i_b10==1|prx_cov_i_b10==1)
replace angina_com_i=0 if angina_com_i!=1
tab angina_com_i if exclude==0

//Arrhtyhmia
gen arrhyth_com_i = 1 if (prx_cov_g_i_b9==1|prx_cov_i_b9==1)
replace arrhyth_com_i=0 if arrhyth_com_i!=1
tab arrhyth_com_i if exclude==0

//Atrial Fibrillation
gen afib_com_i = 1 if (prx_cov_g_i_b13==1|prx_cov_i_b13==1)
replace afib_com_i=0 if afib_com_i!=1
tab afib_com_i if exclude==0

//Heart Failure
gen heartfail_com_i = 1 if (prx_cov_g_i_b8==1|prx_cov_i_b8==1)
replace heartfail_com_i=0 if heartfail_com_i!=1
tab heartfail_com_i if exclude==0

//Hypertension
gen htn_com_i = 1 if (prx_cov_g_i_b12==1|prx_cov_i_b12==1)
replace htn_com_i=0 if htn_com_i!=1
tab htn_com_i if exclude==0

//Myocardial Infarction
gen myoinf_com_i = 1 if (prx_cov_g_i_b6==1|prx_cov_i_b6==1)
replace myoinf_com_i=0 if myoinf_com_i!=1
tab myoinf_com_i if exclude==0

//Peripheral Vascular Disease
gen pvd_com_i = 1 if (prx_cov_g_i_b14==1|prx_cov_i_b14==1)
replace pvd_com_i=0 if pvd_com_i!=1
tab pvd_com_i if exclude==0

//Stroke
gen stroke_com_i = 1 if (prx_cov_g_i_b7==1|prx_cov_i_b7==1)
replace stroke_com_i=0 if stroke_com_i!=1
tab stroke_com_i if exclude==0

//Urgent Revascularization
gen revasc_com_i = 1 if (prx_cov_g_i_b11==1|prx_cov_i_b11==1)
replace revasc_com_i=0 if revasc_com_i!=1
tab revasc_com_i if exclude==0

//PHYSIOLOGICS
//HbA1c
gen hba1c_i = prx_testvalue_i275
tab hba1c_i if exclude==0
gen hba1c_cats_i=round(hba1c)
recode hba1c_cats_i (.=0) (min/7=1) (7/8=2) (8/9=3) (9/10=4) (10/max=5)
label define hba1c_cats 0 "Unknown" 1 "<7.0%" 2 "7.0-8.0%" 3 "8.0-9.0%" 4 "9.0-10.0%" 5 ">10%"
label values hba1c_cats_i hba1c_cats
tab hba1c_cats_i if exclude==0

//SBP
tab prx_covvalue_g_i3 if exclude==0
gen sbp_i = 1 if (prx_cov_g_i_b3==1)
replace sbp_i=0 if sbp_i!=1
tab sbp_i if exclude==0

//Total Cholesterol
summ prx_testvalue_i163 if exclude==0, detail
gen totchol_i = 1 if prx_test_i_b163==1
replace totchol_i=0 if totchol_i!=1
tab totchol_i

//High Density Lipoprotein
summ prx_testvalue_i175 if exclude==0, detail
gen hdl_i = 1 if prx_test_i_b175==1
replace hdl_i=0 if hdl_i!=1
tab hdl_i if exclude==0

//Low Density Lipoprotein 
summ prx_testvalue_i177 if exclude==0, detail
gen ldl_i = 1 if prx_test_i_b177==1
replace ldl_i=0 if ldl_i!=1
tab ldl_i if exclude==0

//Triglycerides
summ prx_testvalue_i202 if exclude==0, detail
gen tg_i = 1 if prx_test_i_b202==1
replace tg_i=0 if tg_i!=1
tab tg_i if exclude==0

//PREPARE FOR TABLE
//Gen indextype
gen indextype=.
replace indextype=0 if secondadmrx=="SU"
replace indextype=1 if secondadmrx=="DPP"
replace indextype=2 if secondadmrx=="GLP"
replace indextype=3 if secondadmrx=="insulin"
replace indextype=4 if secondadmrx=="TZD"
replace indextype=5 if secondadmrx=="other"
replace indextype=6 if secondadmrx=="metformin"

//Create table1
table1 if exclude==0, by(indextype) vars(age_indexdate contn \ age_cat cat \ gender contn \ maritalstatus contn \ maritalstatus cat \ imd2010_5 cat \ prx_covvalue_g_i4 cat \ prx_covvalue_g_i5 cat) onecol saving(sociodemographics.xls, replace)
table1 if exclude==0, by(indextype) vars(physician_vis contn \ hospitalizations contn \ hosp_services contn \ hosp_days contn) pdp(3) saving(healthservices.xls, replace)
table1 if exclude==0, by(indextype) vars(physician_vis cat \ hospitalizations cat \ hosp_services cat \ hosp_days cat) onecol saving(healthservicescats.xls, replace)
table1 if exclude==0, by(indextype) vars(angina_com_i bin \ arrhyth_com_i bin \ afib_com_i bin \ heartfail_com_i bin \ htn_com_i bin \ myoinf_com_i bin \ pvd_com_i bin \ stroke_com_i bin \ revasc_com_i bin) pdp(3) onecol saving(comorbidities.xls, replace)
table1 if exclude==0, by(indextype) vars(hba1c_i contn \ prx_covvalue_g_i3 contn \ prx_testvalue_i163 contn \ prx_testvalue_i175 contn \ prx_testvalue_i177 contn \ prx_testvalue_i202 contn) pdp(3) onecol saving(physiologics.xls, replace)
table1 if exclude==0, by(indextype) vars(hba1c_cats_i cat \ sbp_i cat \ totchol_i cat \ hdl_i cat \ ldl_i cat \ tg_i cat) pdp(3) onecol saving(physiologicscats.xls, replace)
table1 if exclude==0, by(indextype) vars(unique_cov_drugs cat \ unqrx cat) onecol saving(medications.xls, replace)
