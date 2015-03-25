//  program:     Stat01_Baseline_Characteristics.do
//  task:		Statistical analyses of Analytic_Dataset_Master.dta USING YEAR BEFORE INDEX WINDOW
//				Identify patients for exclusion, apply exclusion, and extract cohort characterisitics.
//  project: 	Incretins--Comparative mortality and CV outcomes (CPRD)
//  author:     JM \ Mar2015  
//				

clear all
capture log close
set more off
log using Stat01.smcl, replace
timer on 1

use Analytic_Dataset_Master

//SOCIODEMOGRAPHICS//
//Exclusion unification
gen exclude=1 if (gest_diab==1|pcos==1|preg==1|age_indexdate<=29|cohort_b==0|tx<=seconddate)
replace exclude=0 if exclude!=1
label var exclude "Bin ind for pcos, preg, gest_diab, or <30yo; excluded=1, not excluded=0)
tab exclude

//Age
generate age_cat = age_indexdate
summ age_indexdate
recode age_cat (min/29=0) (30/39=1) (40/49=2) (50/59=3) (60/69=4) (70/79=5) (80/89=6) (89/max=7)
label define age_cats 0 "under 30" 1 "30-39" 2 "40-49" 3 "50-59" 4 "60-69" 5 "70-79" 6 "80-89" 7 "90+"
label values age_cat age_cats
tab age_cat if exclude==0

//Gender
recode gender (1=0) (2=1)
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

//Number of hospitalizations ONLY FOR LINKED
gen hospitalizations=prx_servvalue2_h_i
recode hospitalizations (0=0) (1=1) (2=2) (3=3) (4=4) (5=5) (6/12=6) (13/max=7) (.=8)
label define hosp_cats 0 "None" 1 "One" 2 "Two" 3 "Three" 4 "Four" 5 "Five" 6 "Six to Twelve" 7 "More than Twelve" 8 "Unknown"
label values hospitalizations hosp_cats
tab hospitalizations if exclude==0

//Hospital Services ONLY FOR LINKED
gen hosp_services = totservs_h_i
recode hosp_services (min/100=0) (101/200=1) (201/300=2) (301/400=3) (401/500=4) (501/600=5) (601/700=6) (701/800=7) (801/900=8) (901/1000=9) (1001/max=10) (.=11)
label define hosp_services_cats 0 "0-100" 1 "101-200" 2 "201-300" 3 "301-400" 4 "401-500" 5 "501-600" 6 "601-700" 7 "701-800" 8 "801-900" 9 "901-1000" 10 "More than 1000" 11 "Unknown"
label values hosp_services hosp_services_cats
tab hosp_services if exclude==0

//Duration of Hospital Stay ONLY FOR LINKED
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

//Fill in hes cci
replace  prx_ccivalue_h_i=1 if prx_ccivalue_h_i==.

//PHYSIOLOGICS
//HbA1c
gen hba1c_i2 = prx_testvalue_i2275 if prx_testvalue_i2275>=2& prx_testvalue_i2275<=25
tab hba1c_i2 if exclude==0
gen hba1c_cats_i2=round(hba1c_i2)
recode hba1c_cats_i2 (.=0) (min/7=1) (7/8=2) (8/9=3) (9/10=4) (10/max=5)
label define hba1c_cats 0 "Unknown" 1 "<7.0%" 2 "7.0-8.0%" 3 "8.0-9.0%" 4 "9.0-10.0%" 5 ">10%"
label values hba1c_cats_i2 hba1c_cats
tab hba1c_cats_i2 if exclude==0

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

//Height
gen height_i = prx_covvalue_g_i1
gen heightsq_i = prx_covvalue_g_i1*prx_covvalue_g_i1
gen height_bin = 1 if height_i!=.
replace height_bin=0 if height_i==.
recode height_bin (0=1) (1=0) 

//Weight
gen weight_i = prx_covvalue_g_i2
gen weight_bin = 1 if weight_i!=.
replace weight_bin=0 if weight_i==.
recode weight_bin (0=1) (1=0) 
 
//BMI
gen bmi_i = weight_i/heightsq_i if weight_i!=.&heightsq_i!=.

//MEDICATIONS//
gen ace_arb_renin_i=1 if (acei_i==1|renini_i==1|angiotensin2recepant_i)
gen diuretics_all_i=1 if (thiazdiur_i==1|loopdiur_i==1|potsparediur_aldos_i==1|potsparediur_other_i==1)


***ESTIMATE GLOMERULAR FILTRATION RATE***
//Serum Creatinine
gen scr_i = prx_testvalue_i2165
recode scr_i (.=0) (min/65=1) (66/79=2) (80/94=3) (95/max=4)
label define scr_i_cats 0 "Unknown" 1 "<65umol/L" 2 "66-79umol/L" 3 "80-94umol/L" 4 ">95umol/L"
label values scr_i scr_i_cats
//ref for CG and MDRD formulas: http://cjhp-online.ca/index.php/cjhp/article/viewFile/31/30
//Cockcroft-Galt continuous variable in SI units (umol/L, years, kg)
gen egfr_cg =.
//replace weight = 90 if weight ==.
replace egfr_cg = ((140-testage)*weight_i*1.2)/prx_testvalue_i2165 if sex==0 &prx_testvalue_i2165!=.&weight_i!=.&testage!=.
//multiply by 0.85 for women
replace egfr_cg = (((140-testage)*weight_i*1.2)/prx_testvalue_i2165)*0.85 if sex==1 &prx_testvalue_i2165!=.&weight_i!=.&testage!=.
label var egfr_cg "Estimated glomerular filtration rate- Cockcroft-Galt method"

//modified CG continuous variable in SI units (umol/L, years)
gen egfr_mcg =.
replace egfr_mcg = ((140-testage)*weight_i)/prx_testvalue_i2165 if prx_testvalue_i2165!=.&weight_i!=.&testage!=.
label var egfr_mcg "Estimated glomerular filtration rate- modified Cockcroft-Galt method"

//abbreviated MDRD continuous variable
gen egfr_amdrd=. 
replace egfr_amdrd = 186.3*((prx_testvalue_i2165/88.4)^-1.154)*testage^-0.203 if sex==0& prx_testvalue_i2165!=.&testage!=.
//multiply by 0.742 for women **note there is a race factor usually included: if race==black (*1.21)
replace egfr_amdrd = (186.3*((prx_testvalue_i2165/88.4)^-1.154)*testage^-0.203)*0.742 if sex==1 &prx_testvalue_i2165!=.&testage!=.
label var egfr_amdrd "Estimated glomerular filtration rate- abbreviated MDRD method"

//ref for CKD-EPI formulas: http://www.biomedcentral.com/1471-2318/13/113/table/T1
//CKD-EPI continuous variable
gen egfr_ce=.
//populate with CKD-EPI estimate for males with scr<=80
replace egfr_ce = (141*((prx_testvalue_i2165/88.4/0.7)^-0.411)*(0.993^testage)) if prx_testvalue_i2165<=80 & sex==0 & prx_testvalue_i2165!=.&testage!=.
//populate with CKD-EPI estimate for males with scr>80
replace egfr_ce = (141*((prx_testvalue_i2165/88.4/0.7)^-1.209)*(0.993^testage)) if prx_testvalue_i2165>80 & sex==0 & prx_testvalue_i2165!=.&testage!=.
//populate with CKD-EPI estimate for females with scr<=62
replace egfr_ce = (144*((prx_testvalue_i2165/88.4/0.7)^-0.329)*(0.993^testage)) if prx_testvalue_i2165<=62 & sex==1 & prx_testvalue_i2165!=.&testage!=.
//populate with CKD-EPI estimate for females with scr>62
replace egfr_ce = (144*((prx_testvalue_i2165/88.4/0.7)^-1.209)*(0.993^testage)) if prx_testvalue_i2165>62 & sex==1 & prx_testvalue_i2165!=.&testage!=.
label var egfr_ce "Estimated glomerular filtration rate- CKD-EPI method"

***CREATE CATEGORICAL VARIABLES***
//CKD (GFR ³90; 89.9-60; 59.9-30; 29.9-15; <15 or dialysis)
// generate the categorical variable for the Cockcroft-Galt eGFR
gen ckd_cg= .
replace ckd_cg=1 if egfr_cg < .  & egfr_cg >= 90
replace ckd_cg=2 if egfr_cg < 90 & egfr_cg >= 60
replace ckd_cg=3 if egfr_cg < 60 & egfr_cg >= 30
replace ckd_cg=4 if egfr_cg < 30 & egfr_cg >= 15
replace ckd_cg=5 if egfr_cg < 15 //do we have a marker for dialysis???
label var ckd_cg "Chronic kidney disease categories using CG eGFR"
//create value labels for ckd 1-5
label define ckd_cg_labels 1 ">=90" 2 "60-89"  3 "30-59" 4 "15-29" 5 "<15"
label values ckd_cg ckd_cg_labels

// generate the categorical variable for the modified Cockcroft-Galt eGFR
gen ckd_mcg= .
replace ckd_mcg=1 if egfr_mcg < .  & egfr_mcg >= 90
replace ckd_mcg=2 if egfr_mcg < 90 & egfr_mcg >= 60
replace ckd_mcg=3 if egfr_mcg < 60 & egfr_mcg >= 30
replace ckd_mcg=4 if egfr_mcg < 30 & egfr_mcg >= 15
replace ckd_mcg=5 if egfr_mcg < 15 //do we have a marker for dialysis???
label var ckd_mcg "Chronic kidney disease categories using mCG eGFR"
//create value labels for ckd 1-5
label define ckd_mcg_labels 1 ">=90" 2 "60-89"  3 "30-59" 4 "15-29" 5 "<15"
label values ckd_mcg ckd_mcg_labels

// generate the categorical variable for the abbreviated MDRD eGFR
gen ckd_amdrd= .
replace ckd_amdrd=1 if egfr_amdrd < .  & egfr_amdrd >= 90
replace ckd_amdrd=2 if egfr_amdrd < 90 & egfr_amdrd >= 60
replace ckd_amdrd=3 if egfr_amdrd < 60 & egfr_amdrd >= 30
replace ckd_amdrd=4 if egfr_amdrd < 30 & egfr_amdrd >= 15
replace ckd_amdrd=5 if egfr_amdrd < 15 //do we have a marker for dialysis???
//create value labels for ckd 1-5
label define ckd_amdrd_labels 1 ">=90" 2 "60-89"  3 "30-59" 4 "15-29" 5 "<15"
label values ckd_amdrd ckd_amdrd_labels

// generate the categorical variable for the CKD-EPI eGFR
gen ckd_ce= .
replace ckd_ce=1 if egfr_ce < .  & egfr_ce >= 90
replace ckd_ce=2 if egfr_ce < 90 & egfr_ce >= 60
replace ckd_ce=3 if egfr_ce < 60 & egfr_ce >= 30
replace ckd_ce=4 if egfr_ce < 30 & egfr_ce >= 15
replace ckd_ce=5 if egfr_ce < 15 //do we have a marker for dialysis???
//create value labels for ckd 1-5
label define ckd_ce_labels 1 ">=90" 2 "60-89"  3 "30-59" 4 "15-29" 5 "<15"
label values ckd_ce ckd_ce_labels

//Create post-index exposure numbers for cohort schematic
local names "SU DPP GLP insulin TZD other metformin"
local a=0
forval i=0/6{
local a=`a'+1
local admrx:word `a' of `names'

gen post_`admrx'=0
local rxorder "thirdadmrx fourthadmrx fifthadmrx sixthadmrx seventhadmrx"
local x=0
forval i=0/4{
local x=`x'+1
local next:word `x' of `rxorder'
replace postindex_`admrx' = 1 if regexm(`next', "`admrx'")
}
}
//Create individual order of exposure numbers for each indextype
local alist "third fourth fifth sixth seventh"
local orderlist "thirdadmrx fourthadmrx fifthadmrx sixthadmrx seventhadmrx"
local admrx "SU DPP GLP insulin TZD other metformin"
local c=0
forval i=0/6{
local c =`c'+1
local nextrx:word `c' of `admrx'
local b=0
forval i= 0/4 {
local b= `b'+1
local next1:word `b' of `alist'
local nextadmrx1:word `b' of `orderlist'
gen `next1'_`nextrx' = 0
replace `next1'_`nextrx' = 1 if regexm(`nextadmrx1', "`nextrx'")
tab `next1'_`nextrx' if cohort_b==1&exclude==0
drop `next1'_`nextrx' 
}
}

//PREPARE FOR TABLE
//Gen indextype
gen indextype=.
replace indextype=0 if secondadmrx=="SU"
replace indextype=1 if secondadmrx=="DPP"
replace indextype=2 if secondadmrx=="GLP"
replace indextype=3 if secondadmrx=="insulin"
replace indextype=4 if secondadmrx=="TZD"
replace indextype=5 if secondadmrx=="other"|secondadmrx=="DPPGLP"|secondadmrx=="DPPTZD"|secondadmrx=="DPPinsulin"|secondadmrx=="DPPother"|secondadmrx=="GLPTZD"|secondadmrx=="GLPinsulin"|secondadmrx=="GLPother"|secondadmrx=="SUDPP"|secondadmrx=="SUGLP"|secondadmrx=="SUTZD"|secondadmrx=="SUinsulin"|secondadmrx=="SUother"|secondadmrx=="TZDother"|secondadmrx=="insulinTZD"|secondadmrx=="insulinother"
replace indextype=6 if secondadmrx=="metformin"
label var indextype "Antidiabetic class at index (switch from or add to metformin)" 

//Create table1 for entire base cohort if not excluded
table1 if exclude==0&cohort_b==1, by(indextype) vars(age_cat cat \ gender bin \ maritalstatus cat \ imd2010_5 cat \ prx_covvalue_g_i4 cat \ prx_covvalue_g_i5 cat \ weight_bin bin \ height_bin bin) format(%f9.2) onecol saving(sociodemographics.xls, replace)
table1 if exclude==0&cohort_b==1, by(indextype) vars(age_indexdate contn \ height_i contn \ weight_i contn \ bmi_i contn \ physician_vis contn) saving(healthservices.xls, replace)
table1 if exclude==0&cohort_b==1, by(indextype) vars(physician_vis cat) onecol format(%f9.2) saving(healthservicescats.xls, replace)
table1 if exclude==0&cohort_b==1, by(indextype) vars(angina_com_i bin \ arrhyth_com_i bin \ afib_com_i bin \ heartfail_com_i bin \ htn_com_i bin \ myoinf_com_i bin \ pvd_com_i bin \ stroke_com_i bin \ revasc_com_i bin \ prx_ccivalue_g_i2 cat \ prx_ccivalue_g_i cat \ prx_ccivalue_h_i cat) onecol format(%f9.2) saving(comorbidities.xls, replace)
table1 if exclude==0&cohort_b==1, by(indextype) vars(hba1c_i contn \ prx_covvalue_g_i3 contn \ prx_testvalue_i163 contn \ prx_testvalue_i175 contn \ prx_testvalue_i177 contn \ prx_testvalue_i202 contn \ scr_i contn) onecol saving(physiologics.xls, replace)
table1 if exclude==0&cohort_b==1, by(indextype) vars(scr_i cat \ hba1c_cats_i cat \ sbp_i cat \ totchol_i cat \ hdl_i cat \ ldl_i cat \ tg_i cat) format(%f9.2) onecol saving(physiologicscats.xls, replace)
table1 if exclude==0&cohort_b==1, by(indextype) vars(unique_cov_drugs cat \ unqrx cat \ statin_i bin \ calchan_i bin \ betablock_i bin \ anticoag_oral_i bin \ antiplat_i bin \ ace_arb_renin_i bin \ diuretics_all_i bin) onecol format(%f9.2) saving(medications.xls, replace)
table1 if exclude==0&cohort_b==1, by(indextype) vars(ckd_cg cat \ ckd_mcg cat \ ckd_amdrd cat \ ckd_ce cat) onecol format(%f9.2) saving(ckd.xls, replace)
table1 if exclude==0&cohort_b==1, by(indextype) vars(egfr_cg contn \ egfr_mcg contn \ egfr_amdrd contn \ egfr_ce contn) onecol saving(egfr.xls, replace)

//Create table1 for entire base cohort if not excluded AND LINKED TO HES AND ONS
table1 if exclude==0&cohort_b==1&linked_b==1, by(indextype) vars(age_cat cat \ gender bin \ maritalstatus cat \ imd2010_5 cat \ prx_covvalue_g_i4 cat \ prx_covvalue_g_i5 cat \ weight_bin bin \ height_bin bin) format(%f9.2) onecol saving(sociodemographics_linked.xls, replace)
table1 if exclude==0&cohort_b==1&linked_b==1, by(indextype) vars(age_indexdate contn \ height_i contn \ weight_i contn \ bmi_i contn \ physician_vis contn \ hospitalizations contn \ hosp_services contn \ hosp_days contn) saving(healthservices_linked.xls, replace)
table1 if exclude==0&cohort_b==1&linked_b==1, by(indextype) vars(physician_vis cat \ hospitalizations cat \ hosp_services cat \ hosp_days cat) onecol format(%f9.2) saving(healthservicescats_linked.xls, replace)
table1 if exclude==0&cohort_b==1&linked_b==1, by(indextype) vars(angina_com_i bin \ arrhyth_com_i bin \ afib_com_i bin \ heartfail_com_i bin \ htn_com_i bin \ myoinf_com_i bin \ pvd_com_i bin \ stroke_com_i bin \ revasc_com_i bin \ prx_ccivalue_g_i2 cat \ prx_ccivalue_g_i cat) onecol format(%f9.2) saving(comorbidities_linked.xls, replace)
table1 if exclude==0&cohort_b==1&linked_b==1, by(indextype) vars(hba1c_i contn \ prx_covvalue_g_i3 contn \ prx_testvalue_i163 contn \ prx_testvalue_i175 contn \ prx_testvalue_i177 contn \ prx_testvalue_i202 contn \ scr_i contn) onecol saving(physiologics_linked.xls, replace)
table1 if exclude==0&cohort_b==1&linked_b==1, by(indextype) vars(scr_i cat \ hba1c_cats_i cat \ sbp_i cat \ totchol_i cat \ hdl_i cat \ ldl_i cat \ tg_i cat) format(%f9.2) onecol saving(physiologicscats_linked.xls, replace)
table1 if exclude==0&cohort_b==1&linked_b==1, by(indextype) vars(unique_cov_drugs cat \ unqrx cat \ statin_i bin \ calchan_i bin \ betablock_i bin \ anticoag_oral_i bin \ antiplat_i bin \ ace_arb_renin_i bin \ diuretics_all_i bin) onecol format(%f9.2) saving(medications_linked.xls, replace)
table1 if exclude==0&cohort_b==1&linked_b==1, by(indextype) vars(ckd_cg cat \ ckd_mcg cat \ ckd_amdrd cat \ ckd_ce cat) onecol format(%f9.2) saving(ckd_linked.xls, replace)
table1 if exclude==0&cohort_b==1&linked_b==1, by(indextype) vars(egfr_cg contn \ egfr_mcg contn \ egfr_amdrd contn \ egfr_ce contn) onecol saving(egfr_linked.xls, replace)


/*Create table1 by ever exposed if in cohort and not excluded
forval i=0/5 {
table1 if exclude==0&cohort_b==1&ever`i'==1, vars(age_indexdate contn \ age_cat cat \ gender bin \ maritalstatus cat \ imd2010_5 cat \ prx_covvalue_g_i4 cat \ prx_covvalue_g_i5 cat) format(%f9.2) onecol saving(sociodemographics`i'.xls, replace)
table1 if exclude==0&cohort_b==1&ever`i'==1, vars(physician_vis contn \ hospitalizations contn \ hosp_services contn \ hosp_days contn) saving(healthservices`i'.xls, replace)
table1 if exclude==0&cohort_b==1&ever`i'==1, vars(physician_vis cat \ hospitalizations cat \ hosp_services cat \ hosp_days cat) onecol format(%f9.2) saving(healthservicescats`i'.xls, replace)
table1 if exclude==0&cohort_b==1&ever`i'==1, vars(angina_com_i bin \ arrhyth_com_i bin \ afib_com_i bin \ heartfail_com_i bin \ htn_com_i bin \ myoinf_com_i bin \ pvd_com_i bin \ stroke_com_i bin \ revasc_com_i bin) onecol format(%f9.2) saving(comorbidities`i'.xls, replace)
table1 if exclude==0&cohort_b==1&ever`i'==1, vars(hba1c_i contn \ prx_covvalue_g_i3 contn \ prx_testvalue_i163 contn \ prx_testvalue_i175 contn \ prx_testvalue_i177 contn \ prx_testvalue_i202 contn) saving(physiologics`i'.xls, replace)
table1 if exclude==0&cohort_b==1&ever`i'==1, vars(hba1c_cats_i cat \ sbp_i cat \ totchol_i cat \ hdl_i cat \ ldl_i cat \ tg_i cat) format(%f9.2) onecol saving(physiologicscats`i'.xls, replace)
table1 if exclude==0&cohort_b==1&ever`i'==1, vars(unique_cov_drugs cat \ unqrx cat \ ever0 bin \ ever1 bin ever2 bin ever3 bin \ ) onecol format(%f9.2) saving(medications`i'.xls, replace)
table1 if exclude==0&cohort_b==1&ever`i'==1, vars(ckd_cg cat \ ckd_mcg cat \ ckd_amdrd cat \ ckd_ce cat) saving(ckd`i'.xls, replace)
table1 if exclude==0&cohort_b==1&ever`i'==1, vars(egfr_cg contn \ egfr_mcg contn \ egfr_amdrd contn \ egfr_ce contn) saving(egfr`i'.xls, replace)
}
*/


//Prepare for analysis
gen censored =0
replace censored= 1 if exposuretf0==tx|exposuretf1==tx|exposuretf2==tx|exposuretf3==tx|exposuretf4==tx|exposuretf5==tx|exposuretf6==tx
//Hazard Function
gen firstdeath = dod2 if dod2<=deathdate2
replace firstdeath= deathdate2 if deathdate<dod2
gen acm=.
replace acm=firstdeath-studyentrydate_cprd2 if firstdeath!=.
stset acm, failure(censored)
sts graph, na
//Univariate Analyses
sts test unqrx, logrank
sts graph, by(unqrx)
sts test hba1c_cats_i2, logrank
sts graph, by(hba1c_cats_i2)
sts test age_indexdate, logrank
stcox age_indexdate, nohr
//Model Building
stcox age_indexdate prx_testvalue_i275 i.unqrx i.gender i.imd2010_5 i.maritalstatus i.prx_covvalue_g_i4 i.prx_covvalue_g_i5 totservs_g_i, nohr
forval i=6/14{
replace prx_cov_g_i_b`i' = 0 if prx_cov_g_i_b`i'==.
}
stcox i.prx_cov_g_i_b6 i.prx_cov_g_i_b7 i.prx_cov_g_i_b8 i.prx_cov_g_i_b9 i.prx_cov_g_i_b10 i.prx_cov_g_i_b11 i.prx_cov_g_i_b12 i.prx_cov_g_i_b13 i.prx_cov_g_i_b14, nohr
stcox prx_testvalue_i175 prx_testvalue_i177 prx_testvalue_i163 prx_testvalue_i175  prx_testvalue_i202 prx_covvalue_g_i3 egfr_cg i.ckd_cg , nohr
//Final Model
stcox age_indexdate unqrx i.gender prx_testvalue_i275 prx_covvalue_g_i4 totservs_g_i totservs_h_i prx_ccivalue_g_i prx_testvalue_i175 prx_testvalue_i177 prx_testvalue_i163 prx_testvalue_i175  prx_testvalue_i202 prx_covvalue_g_i3 egfr_cg i.prx_cov_g_i_b6 i.prx_cov_g_i_b7 i.prx_cov_g_i_b10 i.prx_cov_g_i_b11 i.prx_cov_g_i_b12 i.prx_cov_g_i_b14, nohr
//Interactions

log close
timer off 1

