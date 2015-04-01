//  program:    Stat03_Model_Building.do
//  task:		Complete univariate and bivariate preliminary analyses on the covariates 
//				of interest and check correlation matrix for interactions between covariates
//  project: 	Incretins--Comparative mortality and CV outcomes (CPRD)
//  author:     JM \ Mar2015  
//				

clear all
capture log close
set more off
log using Stat03.smcl, replace
timer on 1

use Analytic_Dataset_Master

//Unify exclusion criteria into a binary indicator
gen exclude=1 if (gest_diab==1|pcos==1|preg==1|age_indexdate<=29|cohort_b==0|tx<=seconddate)
replace exclude=0 if exclude!=1
label var exclude "Bin ind for pcos, preg, gest_diab, or <30yo; excluded=1, not excluded=0)

drop if cohort_b!=1
drop if exclude!=0

//Generate a categorical variable to indicate the class of antidiabetic prescription at index
gen indextype=.
replace indextype=0 if secondadmrx=="SU"
replace indextype=1 if secondadmrx=="DPP"
replace indextype=2 if secondadmrx=="GLP"
replace indextype=3 if secondadmrx=="insulin"
replace indextype=4 if secondadmrx=="TZD"
replace indextype=5 if secondadmrx=="other"|secondadmrx=="DPPGLP"|secondadmrx=="DPPTZD"|secondadmrx=="DPPinsulin"|secondadmrx=="DPPother"|secondadmrx=="GLPTZD"|secondadmrx=="GLPinsulin"|secondadmrx=="GLPother"|secondadmrx=="SUDPP"|secondadmrx=="SUGLP"|secondadmrx=="SUTZD"|secondadmrx=="SUinsulin"|secondadmrx=="SUother"|secondadmrx=="TZDother"|secondadmrx=="insulinTZD"|secondadmrx=="insulinother"
replace indextype=6 if secondadmrx=="metformin"
label var indextype "Antidiabetic class at index (switch from or add to metformin)" 
drop if indextype==.

//abbreviated MDRD continuous variable
gen egfr_amdrd=. 
replace egfr_amdrd = 186.3*((prx_testvalue_i2165/88.4)^-1.154)*testage^-0.203 if sex==0& prx_testvalue_i2165!=.&testage!=.
//multiply by 0.742 for women **note there is a race factor usually included: if race==black (*1.21)
replace egfr_amdrd = (186.3*((prx_testvalue_i2165/88.4)^-1.154)*testage^-0.203)*0.742 if sex==1 &prx_testvalue_i2165!=.&testage!=.
label var egfr_amdrd "Estimated glomerular filtration rate- abbreviated MDRD method"
//CKD aMDRD categorical variable
gen ckd_amdrd= egfr_amdrd
recode ckd_amdrd (min/15=0) (15/30=1) (30/60=2) (60/90=3) (90/max=4) (.=5)
//create value labels for ckd 1-5
label define ckd_amdrd_labels 5 "Unknown" 4 ">=90" 3 "60-89"  2 "30-59" 1 "15-29" 0 "<15"
label values ckd_amdrd ckd_amdrd_labels

//MEDICATIONS//
gen ace_arb_renin_i=0
replace ace_arb_renin_i=1 if acei_i==1|renini_i==1|angiotensin2recepant_i
gen diuretics_all_i=0
replace diuretics_all_i=1 if (thiazdiur_i==1|loopdiur_i==1|potsparediur_aldos_i==1|potsparediur_other_i==1)

//Univariate Analysis
///////////////////////////////////////All Cause Mortality /////////////////////////////////////////
gen allcausemort = 0
replace allcausemort = 1 if deathdate2!=.
label var allcausemort "All-cause mortality"
//Generate exit date for all cause mortality
forval i=0/5{
egen acm_exit`i' = rowmin(exposuretf`i' tod2 deathdate2 lcd2) 
format acm_exit`i' %td
label var acm_exit`i' "Exit date for all-cause mortality for indextype=`i'"
}
egen acm_exit = rowmin(acm_exit0 acm_exit1 acm_exit2 acm_exit3 acm_exit4 acm_exit5)
drop acm_exit0-acm_exit5
format acm_exit %td
label var acm_exit "Exit date for all-cause mortality"
//Set
stset acm_exit, fail(allcausemort) id(patid) origin(seconddate) scale(365.35)
//Age
stcox age_indexdate, nohr
matrix a=r(table)
putexcel A1=("Covariate") B1=("HR") C1=("SE") D1=("p-value") E1=("LL") F1=("UL") A2=("Age") B2=(a[1,1]) C2=(a[2,1]) D2=(a[4,1]) E2=(a[5,1]) F2=(a[6,1]) using Univariate, sheet("ACM") modify
//HbA1c
stcox prx_testvalue_i275
matrix a=r(table)
putexcel A3=("HbA1c") B3=(a[1,1]) C3=(a[2,1]) D3=(a[4,1]) E3=(a[5,1]) F3=(a[6,1]) using Univariate, sheet("ACM") modify
//Number of hospital visits
stcox prx_servvalue2_h_i
matrix a=r(table)
putexcel A4=("Hospitalizations") B4=(a[1,1]) C4=(a[2,1]) D4=(a[4,1]) E4=(a[5,1]) F4=(a[6,1]) using Univariate, sheet("ACM") modify
//Total Cholesterol
stcox prx_testvalue_i2163
matrix a=r(table)
putexcel A5=("Total Cholesterol") B5=(a[1,1]) C5=(a[2,1]) D5=(a[4,1]) E5=(a[5,1]) F5=(a[6,1]) using Univariate, sheet("ACM") modify
//HDL
stcox prx_testvalue_i2175
matrix a=r(table)
putexcel A6=("HDL") B6=(a[1,1]) C6=(a[2,1]) D6=(a[4,1]) E6=(a[5,1]) F6=(a[6,1]) using Univariate, sheet("ACM") modify
//LDL
stcox prx_testvalue_i2177
matrix a=r(table)
putexcel A7=("LDL") B7=(a[1,1]) C7=(a[2,1]) D7=(a[4,1]) E7=(a[5,1]) F7=(a[6,1]) using Univariate, sheet("ACM") modify
//TG
stcox prx_testvalue_i2202
matrix a=r(table)
putexcel A8=("Triglycerides") B8=(a[1,1]) C8=(a[2,1]) D8=(a[4,1]) E8=(a[5,1]) F8=(a[6,1]) using Univariate, sheet("ACM") modify
//Systolic blood pressure
stcox prx_covvalue_g_i3
matrix a=r(table)
putexcel A9=("Systolic BP") B9=(a[1,1]) C9=(a[2,1]) D9=(a[4,1]) E9=(a[5,1]) F9=(a[6,1]) using Univariate, sheet("ACM") modify
//Unqrx
stcox unqrx
matrix a=r(table)
putexcel A10=("Unique ADM Rx") B10=(a[1,1]) C10=(a[2,1]) D10=(a[4,1]) E10=(a[5,1]) F10=(a[6,1]) using Univariate, sheet("ACM") modify
//Gender
stcox gender
matrix a=r(table)
putexcel A11=("Gender") B11=(a[1,1]) C11=(a[2,1]) D11=(a[4,1]) E11=(a[5,1]) F11=(a[6,1]) using Univariate, sheet("ACM") modify
//SES
recode imd2010_5 (1=0) (2=1) (3=2) (4=3) (5=4) (9=9)
stcox imd2010_5
matrix a=r(table)
putexcel A12=("SES") B12=(a[1,1]) C12=(a[2,1]) D12=(a[4,1]) E12=(a[5,1]) F12=(a[6,1]) using Univariate, sheet("ACM") modify
//Marital status
stcox marital
matrix a=r(table)
putexcel A13=("Marital Status") B13=(a[1,1]) C13=(a[2,1]) D13=(a[4,1]) E13=(a[5,1]) F13=(a[6,1]) using Univariate, sheet("ACM") modify
//Smoking Status
stcox prx_covvalue_g_i4
matrix a=r(table)
putexcel A14=("Smoking Status") B14=(a[1,1]) C14=(a[2,1]) D14=(a[4,1]) E14=(a[5,1]) F14=(a[6,1]) using Univariate, sheet("ACM") modify
//Alcohol Abuse Status
stcox prx_covvalue_g_i5
matrix a=r(table)
putexcel A15=("Alcohol Status") B15=(a[1,1]) C15=(a[2,1]) D15=(a[4,1]) E15=(a[5,1]) F15=(a[6,1]) using Univariate, sheet("ACM") modify
//Physician Visits
gen phys_vis=0
replace phys_vis=totservs_g_i if totservs_g_i!=.
stcox phys_vis
matrix a=r(table)
putexcel A16=("Physician Visits") B16=(a[1,1]) C16=(a[2,1]) D16=(a[4,1]) E16=(a[5,1]) F16=(a[6,1]) using Univariate, sheet("ACM") modify
//Charlson Comorbidity Score
stcox prx_ccivalue_g_i2
matrix a=r(table)
putexcel A17=("CCI") B17=(a[1,1]) C17=(a[2,1]) D17=(a[4,1]) E17=(a[5,1]) F17=(a[6,1]) using Univariate, sheet("ACM") modify
//MI
gen mi_i =0
replace mi_i= 1 if prx_covvalue_g_i6==1|prx_covvalue_i6==1
stcox mi_i
matrix a=r(table)
putexcel A18=("MI") B18=(a[1,1]) C18=(a[2,1]) D18=(a[4,1]) E18=(a[5,1]) F18=(a[6,1]) using Univariate, sheet("ACM") modify
cs allcausemort mi_i
putexcel G1=("RR") H1=("LL") I1=("UL") J1=("RD") K1=("LL") L1=("UL") M1=("p-val") G18=(r(rr)) H18=(r(lb_rr)) I18=(r(ub_rr)) J18=(r(rd)) K18=(r(lb_rd)) L18=(r(ub_rd)) M18=(r(p)) using Univariate, sheet("ACM") modify
//Stroke
gen stroke_i =0
replace stroke_i= 1 if prx_covvalue_g_i7==1|prx_covvalue_i7==1
stcox stroke_i
matrix a=r(table)
putexcel A19=("Stroke") B19=(a[1,1]) C19=(a[2,1]) D19=(a[4,1]) E19=(a[5,1]) F19=(a[6,1]) using Univariate, sheet("ACM") modify
cs allcausemort stroke_i
putexcel G19=(r(rr)) H19=(r(lb_rr)) I19=(r(ub_rr)) J19=(r(rd)) K19=(r(lb_rd)) L19=(r(ub_rd)) M19=(r(p)) using Univariate, sheet("ACM") modify
//HF
gen hf_i =0
replace hf_i= 1 if prx_covvalue_g_i8==1|prx_covvalue_i8==1
stcox hf_i
matrix a=r(table)
putexcel A20=("HF") B20=(a[1,1]) C20=(a[2,1]) D20=(a[4,1]) E20=(a[5,1]) F20=(a[6,1]) using Univariate, sheet("ACM") modify
cs allcausemort hf_i
putexcel G20=(r(rr)) H20=(r(lb_rr)) I20=(r(ub_rr)) J20=(r(rd)) K20=(r(lb_rd)) L20=(r(ub_rd)) M20=(r(p)) using Univariate, sheet("ACM") modify
//Arrhythmia
gen arr_i =0
replace arr_i= 1 if prx_covvalue_g_i9==1|prx_covvalue_i9==1
stcox arr_i
matrix a=r(table)
putexcel A21=("Arrhythmia") B21=(a[1,1]) C21=(a[2,1]) D21=(a[4,1]) E21=(a[5,1]) F21=(a[6,1]) using Univariate, sheet("ACM") modify
cs allcausemort arr_i
putexcel G21=(r(rr)) H21=(r(lb_rr)) I21=(r(ub_rr)) J21=(r(rd)) K21=(r(lb_rd)) L21=(r(ub_rd)) M21=(r(p)) using Univariate, sheet("ACM") modify
//Angina
gen ang_i =0
replace ang_i= 1 if prx_covvalue_g_i10==1|prx_covvalue_i10==1
stcox ang_i
matrix a=r(table)
putexcel A22=("Angina") B22=(a[1,1]) C22=(a[2,1]) D22=(a[4,1]) E22=(a[5,1]) F22=(a[6,1]) using Univariate, sheet("ACM") modify
cs allcausemort ang_i
putexcel G22=(r(rr)) H22=(r(lb_rr)) I22=(r(ub_rr)) J22=(r(rd)) K22=(r(lb_rd)) L22=(r(ub_rd)) M22=(r(p)) using Univariate, sheet("ACM") modify
//Revascularization
gen urg_revasc_i =0
replace urg_revasc_i= 1 if prx_covvalue_g_i11==1|prx_covvalue_i11==1
stcox urg_revasc_i
matrix a=r(table)
putexcel A23=("Urgent Revasc") B23=(a[1,1]) C23=(a[2,1]) D23=(a[4,1]) E23=(a[5,1]) F23=(a[6,1]) using Univariate, sheet("ACM") modify
cs allcausemort urg_revasc_i
putexcel G23=(r(rr)) H23=(r(lb_rr)) I23=(r(ub_rr)) J23=(r(rd)) K23=(r(lb_rd)) L23=(r(ub_rd)) M23=(r(p)) using Univariate, sheet("ACM") modify
//HTN
gen htn_i =0
replace htn_i= 1 if prx_covvalue_g_i12==1|prx_covvalue_i12==1
stcox htn_i
matrix a=r(table)
putexcel A24=("HTN") B24=(a[1,1]) C24=(a[2,1]) D24=(a[4,1]) E24=(a[5,1]) F24=(a[6,1]) using Univariate, sheet("ACM") modify
cs allcausemort htn_i
putexcel G24=(r(rr)) H24=(r(lb_rr)) I24=(r(ub_rr)) J24=(r(rd)) K24=(r(lb_rd)) L24=(r(ub_rd)) M24=(r(p)) using Univariate, sheet("ACM") modify
//Atrial Fibrillation
gen afib_i =0
replace afib_i= 1 if prx_covvalue_g_i13==1|prx_covvalue_i13==1
stcox afib_i
matrix a=r(table)
putexcel A25=("AFib") B25=(a[1,1]) C25=(a[2,1]) D25=(a[4,1]) E25=(a[5,1]) F25=(a[6,1]) using Univariate, sheet("ACM") modify
cs allcausemort afib_i
putexcel G25=(r(rr)) H25=(r(lb_rr)) I25=(r(ub_rr)) J25=(r(rd)) K25=(r(lb_rd)) L25=(r(ub_rd)) M25=(r(p)) using Univariate, sheet("ACM") modify
//Peripheral Vascular Disease
gen pvd_i =0
replace pvd_i= 1 if prx_covvalue_g_i14==1|prx_covvalue_i14==1
stcox pvd_i
matrix a=r(table)
putexcel A26=("PVD") B26=(a[1,1]) C26=(a[2,1]) D26=(a[4,1]) E26=(a[5,1]) F26=(a[6,1]) using Univariate, sheet("ACM") modify
cs allcausemort pvd_i
putexcel G26=(r(rr)) H26=(r(lb_rr)) I26=(r(ub_rr)) J26=(r(rd)) K26=(r(lb_rd)) L26=(r(ub_rd)) M26=(r(p)) using Univariate, sheet("ACM") modify
//CKD
stcox ckd_amdrd
matrix a=r(table)
putexcel A27=("CKDaMDRD") B27=(a[1,1]) C27=(a[2,1]) D27=(a[4,1]) E27=(a[5,1]) F27=(a[6,1]) using Univariate, sheet("ACM") modify
//MEDICATIONS
//Statins
stcox statin_i
matrix a=r(table)
putexcel A28=("Statins") B28=(a[1,1]) C28=(a[2,1]) D28=(a[4,1]) E28=(a[5,1]) F28=(a[6,1]) using Univariate, sheet("ACM") modify
cs allcausemort statin_i
putexcel G28=(r(rr)) H28=(r(lb_rr)) I28=(r(ub_rr)) J28=(r(rd)) K28=(r(lb_rd)) L28=(r(ub_rd)) M28=(r(p)) using Univariate, sheet("ACM") modify
//Calcium Channel Blockers
stcox calchan_i
matrix a=r(table)
putexcel A29=("CCBs") B29=(a[1,1]) C29=(a[2,1]) D29=(a[4,1]) E29=(a[5,1]) F29=(a[6,1]) using Univariate, sheet("ACM") modify
cs allcausemort calchan_i
putexcel G29=(r(rr)) H29=(r(lb_rr)) I29=(r(ub_rr)) J29=(r(rd)) K29=(r(lb_rd)) L29=(r(ub_rd)) M29=(r(p)) using Univariate, sheet("ACM") modify
//Beta Blockers
stcox betablock_i
matrix a=r(table)
putexcel A30=("BBs") B30=(a[1,1]) C30=(a[2,1]) D30=(a[4,1]) E30=(a[5,1]) F30=(a[6,1]) using Univariate, sheet("ACM") modify
cs allcausemort betablock_i
putexcel G30=(r(rr)) H30=(r(lb_rr)) I30=(r(ub_rr)) J30=(r(rd)) K30=(r(lb_rd)) L30=(r(ub_rd)) M30=(r(p)) using Univariate, sheet("ACM") modify
//Anticoagulants
stcox anticoag_oral_i
matrix a=r(table)
putexcel A31=("Anticoags") B31=(a[1,1]) C31=(a[2,1]) D31=(a[4,1]) E31=(a[5,1]) F31=(a[6,1]) using Univariate, sheet("ACM") modify
cs allcausemort anticoag_oral_i
putexcel G31=(r(rr)) H31=(r(lb_rr)) I31=(r(ub_rr)) J31=(r(rd)) K31=(r(lb_rd)) L31=(r(ub_rd)) M31=(r(p)) using Univariate, sheet("ACM") modify
//Antiplatelets
stcox antiplat_i
matrix a=r(table)
putexcel A32=("Antiplats") B32=(a[1,1]) C32=(a[2,1]) D32=(a[4,1]) E32=(a[5,1]) F32=(a[6,1]) using Univariate, sheet("ACM") modify
cs allcausemort antiplat_i
putexcel G32=(r(rr)) H32=(r(lb_rr)) I32=(r(ub_rr)) J32=(r(rd)) K32=(r(lb_rd)) L32=(r(ub_rd)) M32=(r(p)) using Univariate, sheet("ACM") modify
//Angio-Renin System Drugs
stcox ace_arb_renin_i
matrix a=r(table)
putexcel A33=("AngioRenins") B33=(a[1,1]) C33=(a[2,1]) D33=(a[4,1]) E33=(a[5,1]) F33=(a[6,1]) using Univariate, sheet("ACM") modify
cs allcausemort ace_arb_renin_i
putexcel G33=(r(rr)) H33=(r(lb_rr)) I33=(r(ub_rr)) J33=(r(rd)) K33=(r(lb_rd)) L33=(r(ub_rd)) M33=(r(p)) using Univariate, sheet("ACM") modify
//Diuretics
stcox diuretics_all_i
matrix a=r(table)
putexcel A34=("Diuretics") B34=(a[1,1]) C34=(a[2,1]) D34=(a[4,1]) E34=(a[5,1]) F34=(a[6,1]) using Univariate, sheet("ACM") modify
cs allcausemort diuretics_all_i
putexcel G34=(r(rr)) H34=(r(lb_rr)) I34=(r(ub_rr)) J34=(r(rd)) K34=(r(lb_rd)) L34=(r(ub_rd)) M34=(r(p)) using Univariate, sheet("ACM") modify
//Unqrx
stcox unqrxi
matrix a=r(table)
putexcel A35=("Unique Rx") B35=(a[1,1]) C35=(a[2,1]) D35=(a[4,1]) E35=(a[5,1]) F35=(a[6,1]) using Univariate, sheet("ACM") modify


//Multivariate analysis (ACM)
stset acm_exit, fail(allcausemort) id(patid) origin(seconddate) scale(365.35)
stcox age_indexdate i.imd2010_5 prx_testvalue_i275 prx_testvalue_i2163 prx_testvalue_i2175 prx_testvalue_i2202 prx_covvalue_g_i3 phys_vis prx_servvalue2_h_i unqrxi i.unqrx i.gender i.prx_covvalue_g_i4 i.prx_ccivalue_g_i2 i.mi_i i.stroke_i i.hf_i i.arr_i i.ang_i i.urg_revasc_i i.htn_i i.afib_i i.pvd_i i.ckd_amdrd i.statin_i i.calchan_i i.betablock_i i.anticoag_oral_i i.antiplat_i i.ace_arb_renin_i i.diuretics_all_i
matrix b=r(table)
matrix c=b'
matrix list c
matrix rownames c = Age 0SES 1SES 2SES 3SES 4SES 9SES HbA1c TotChol HDL TG sysBP DocVisits Hospitalizations unqrxi 2unqrx 3unqrx 4unqrx 5ungrx 6unqrx 7unqrx 1gender 2gender 0smoking 1smoking 2smoking 3smoking 1cci 2cci 3cci 4cci 0mi 1mi 0stroke 1stroke 0HF 1HF 0Arr 1Arr 0angina 1angina 0revasc 1revasc 0HTN 1HTN 0Afib 1Afib 0PVD 1PVD 0CKD 1CKD 2CKD 3CKD 4CKD 5CKD 0Statin 1Statin 0CCB 1CCB 0BB 1BB 0Anticoag 1Anticoag 0Antiplat 1Antiplat 0AngioRenin 1AngioRenin 0Diur 1Diur
local matrownames "Age 0SES 1SES 2SES 3SES 4SES 9SES HbA1c TotChol HDL TG sysBP DocVisits Hospitalizations unqrxi 2unqrx 3unqrx 4unqrx 5ungrx 6unqrx 7unqrx 1gender 2gender 0smoking 1smoking 2smoking 3smoking 1cci 2cci 3cci 4cci 0mi 1mi 0stroke 1stroke 0HF 1HF 0Arr 1Arr 0angina 1angina 0revasc 1revasc 0HTN 1HTN 0Afib 1Afib 0PVD 1PVD 0CKD 1CKD 2CKD 3CKD 4CKD 5CKD 0Statin 1Statin 0CCB 1CCB 0BB 1BB 0Anticoag 1Anticoag 0Antiplat 1Antiplat 0AngioRenin 1AngioRenin 0Diur 1Diur"
forval i=1/69{
local x=`i'+1
local rowname:word `i' of `matrownames'
putexcel A1=("Variable") B1=("HR") C1=("SE") D1=("p-value") E1=("LL") F1=("UL") A`x'=("`rowname'") B`x'=(c[`i',1]) C`x'=(c[`i',2]) D`x'=(c[`i',4]) E`x'=(c[`i',5]) F`x'=(c[`i',6])using Multivariate, sheet("ACM_full") modify
}

///////////////////////////////////////Major CV Event /////////////////////////////////////////
//Composite CV event
gen cvmajor = cvprim_comp_g_i 
label var cvmajor "Indicator for first major cv event (mi, stroke, cvdeath) 1=event, 0=no event"
//Total follow-up time
forval i=0/5{
egen cvmajor_exit`i' = rowmin(exposuretf`i' cvprim_comp_g_date_i lcd2)
format cvmajor_exit`i' %td
label var cvmajor_exit`i' "Exit date for major cardiovascular event (MI, stroke, or CV death) for indextype=`i'"
}
egen cvmajor_exit = rowmin(cvmajor_exit0 cvmajor_exit1 cvmajor_exit2 cvmajor_exit3 cvmajor_exit4 cvmajor_exit5)
drop cvmajor_exit0-cvmajor_exit5
format cvmajor_exit %td
label var cvmajor_exit "Exit date for major cardiovascular event (MI, stroke, or CV death)"
//Set
stset cvmajor_exit, fail(cvmajor) id(patid) origin(seconddate) scale(365.35)
//Age
stcox age_indexdate, nohr
matrix a=r(table)
putexcel A1=("Covariate") B1=("HR") C1=("SE") D1=("p-value") E1=("LL") F1=("UL") A2=("Age") B2=(a[1,1]) C2=(a[2,1]) D2=(a[4,1]) E2=(a[5,1]) F2=(a[6,1]) using Univariate, sheet("MCV") modify
//HbA1c
stcox prx_testvalue_i275
matrix a=r(table)
putexcel A3=("HbA1c") B3=(a[1,1]) C3=(a[2,1]) D3=(a[4,1]) E3=(a[5,1]) F3=(a[6,1]) using Univariate, sheet("MCV") modify
//Number of hospital visits
stcox prx_servvalue2_h_i
matrix a=r(table)
putexcel A4=("Hospitalizations") B4=(a[1,1]) C4=(a[2,1]) D4=(a[4,1]) E4=(a[5,1]) F4=(a[6,1]) using Univariate, sheet("MCV") modify
//Total Cholesterol
stcox prx_testvalue_i2163
matrix a=r(table)
putexcel A5=("Total Cholesterol") B5=(a[1,1]) C5=(a[2,1]) D5=(a[4,1]) E5=(a[5,1]) F5=(a[6,1]) using Univariate, sheet("MCV") modify
//HDL
stcox prx_testvalue_i2175
matrix a=r(table)
putexcel A6=("HDL") B6=(a[1,1]) C6=(a[2,1]) D6=(a[4,1]) E6=(a[5,1]) F6=(a[6,1]) using Univariate, sheet("MCV") modify
//LDL
stcox prx_testvalue_i2177
matrix a=r(table)
putexcel A7=("LDL") B7=(a[1,1]) C7=(a[2,1]) D7=(a[4,1]) E7=(a[5,1]) F7=(a[6,1]) using Univariate, sheet("MCV") modify
//TG
stcox prx_testvalue_i2202
matrix a=r(table)
putexcel A8=("Triglycerides") B8=(a[1,1]) C8=(a[2,1]) D8=(a[4,1]) E8=(a[5,1]) F8=(a[6,1]) using Univariate, sheet("MCV") modify
//Systolic blood pressure
stcox prx_covvalue_g_i3
matrix a=r(table)
putexcel A9=("Systolic BP") B9=(a[1,1]) C9=(a[2,1]) D9=(a[4,1]) E9=(a[5,1]) F9=(a[6,1]) using Univariate, sheet("MCV") modify
//Unqrx
stcox unqrx
matrix a=r(table)
putexcel A10=("Unique ADM Rx") B10=(a[1,1]) C10=(a[2,1]) D10=(a[4,1]) E10=(a[5,1]) F10=(a[6,1]) using Univariate, sheet("MCV") modify
//Gender
stcox gender
matrix a=r(table)
putexcel A11=("Gender") B11=(a[1,1]) C11=(a[2,1]) D11=(a[4,1]) E11=(a[5,1]) F11=(a[6,1]) using Univariate, sheet("MCV") modify
//SES
stcox imd2010_5
matrix a=r(table)
putexcel A12=("SES") B12=(a[1,1]) C12=(a[2,1]) D12=(a[4,1]) E12=(a[5,1]) F12=(a[6,1]) using Univariate, sheet("MCV") modify
//Marital status
stcox marital
matrix a=r(table)
putexcel A13=("Marital Status") B13=(a[1,1]) C13=(a[2,1]) D13=(a[4,1]) E13=(a[5,1]) F13=(a[6,1]) using Univariate, sheet("MCV") modify
//Smoking Status
stcox prx_covvalue_g_i4
matrix a=r(table)
putexcel A14=("Smoking Status") B14=(a[1,1]) C14=(a[2,1]) D14=(a[4,1]) E14=(a[5,1]) F14=(a[6,1]) using Univariate, sheet("MCV") modify
//Alcohol Abuse Status
stcox prx_covvalue_g_i5
matrix a=r(table)
putexcel A15=("Alcohol Status") B15=(a[1,1]) C15=(a[2,1]) D15=(a[4,1]) E15=(a[5,1]) F15=(a[6,1]) using Univariate, sheet("MCV") modify
//Physician Visits
stcox phys_vis
matrix a=r(table)
putexcel A16=("Physician Visits") B16=(a[1,1]) C16=(a[2,1]) D16=(a[4,1]) E16=(a[5,1]) F16=(a[6,1]) using Univariate, sheet("MCV") modify
//Charlson Comorbidity Score
stcox prx_ccivalue_g_i2
matrix a=r(table)
putexcel A17=("CCI") B17=(a[1,1]) C17=(a[2,1]) D17=(a[4,1]) E17=(a[5,1]) F17=(a[6,1]) using Univariate, sheet("MCV") modify
//MI
stcox mi_i
matrix a=r(table)
putexcel A18=("MI") B18=(a[1,1]) C18=(a[2,1]) D18=(a[4,1]) E18=(a[5,1]) F18=(a[6,1]) using Univariate, sheet("MCV") modify
cs allcausemort mi_i
putexcel G1=("RR") H1=("LL") I1=("UL") J1=("RD") K1=("LL") L1=("UL") M1=("p-val") G18=(r(rr)) H18=(r(lb_rr)) I18=(r(ub_rr)) J18=(r(rd)) K18=(r(lb_rd)) L18=(r(ub_rd)) M18=(r(p)) using Univariate, sheet("MCV") modify
//Stroke
stcox stroke_i
matrix a=r(table)
putexcel A19=("Stroke") B19=(a[1,1]) C19=(a[2,1]) D19=(a[4,1]) E19=(a[5,1]) F19=(a[6,1]) using Univariate, sheet("MCV") modify
cs allcausemort stroke_i
putexcel G19=(r(rr)) H19=(r(lb_rr)) I19=(r(ub_rr)) J19=(r(rd)) K19=(r(lb_rd)) L19=(r(ub_rd)) M19=(r(p)) using Univariate, sheet("MCV") modify
//HF
stcox hf_i
matrix a=r(table)
putexcel A20=("HF") B20=(a[1,1]) C20=(a[2,1]) D20=(a[4,1]) E20=(a[5,1]) F20=(a[6,1]) using Univariate, sheet("MCV") modify
cs allcausemort hf_i
putexcel G20=(r(rr)) H20=(r(lb_rr)) I20=(r(ub_rr)) J20=(r(rd)) K20=(r(lb_rd)) L20=(r(ub_rd)) M20=(r(p)) using Univariate, sheet("MCV") modify
//Arrhythmia
stcox arr_i
matrix a=r(table)
putexcel A21=("Arrhythmia") B21=(a[1,1]) C21=(a[2,1]) D21=(a[4,1]) E21=(a[5,1]) F21=(a[6,1]) using Univariate, sheet("MCV") modify
cs allcausemort arr_i
putexcel G21=(r(rr)) H21=(r(lb_rr)) I21=(r(ub_rr)) J21=(r(rd)) K21=(r(lb_rd)) L21=(r(ub_rd)) M21=(r(p)) using Univariate, sheet("MCV") modify
//Angina
stcox ang_i
matrix a=r(table)
putexcel A22=("Angina") B22=(a[1,1]) C22=(a[2,1]) D22=(a[4,1]) E22=(a[5,1]) F22=(a[6,1]) using Univariate, sheet("MCV") modify
cs allcausemort ang_i
putexcel G22=(r(rr)) H22=(r(lb_rr)) I22=(r(ub_rr)) J22=(r(rd)) K22=(r(lb_rd)) L22=(r(ub_rd)) M22=(r(p)) using Univariate, sheet("MCV") modify
//Revascularization
stcox urg_revasc_i
matrix a=r(table)
putexcel A23=("Urgent Revasc") B23=(a[1,1]) C23=(a[2,1]) D23=(a[4,1]) E23=(a[5,1]) F23=(a[6,1]) using Univariate, sheet("MCV") modify
cs allcausemort urg_revasc_i
putexcel G23=(r(rr)) H23=(r(lb_rr)) I23=(r(ub_rr)) J23=(r(rd)) K23=(r(lb_rd)) L23=(r(ub_rd)) M23=(r(p)) using Univariate, sheet("MCV") modify
//HTN
stcox htn_i
matrix a=r(table)
putexcel A24=("HTN") B24=(a[1,1]) C24=(a[2,1]) D24=(a[4,1]) E24=(a[5,1]) F24=(a[6,1]) using Univariate, sheet("MCV") modify
cs allcausemort htn_i
putexcel G24=(r(rr)) H24=(r(lb_rr)) I24=(r(ub_rr)) J24=(r(rd)) K24=(r(lb_rd)) L24=(r(ub_rd)) M24=(r(p)) using Univariate, sheet("MCV") modify
//Atrial Fibrillation
stcox afib_i
matrix a=r(table)
putexcel A25=("AFib") B25=(a[1,1]) C25=(a[2,1]) D25=(a[4,1]) E25=(a[5,1]) F25=(a[6,1]) using Univariate, sheet("MCV") modify
cs allcausemort afib_i
putexcel G25=(r(rr)) H25=(r(lb_rr)) I25=(r(ub_rr)) J25=(r(rd)) K25=(r(lb_rd)) L25=(r(ub_rd)) M25=(r(p)) using Univariate, sheet("MCV") modify
//Peripheral Vascular Disease
stcox pvd_i
matrix a=r(table)
putexcel A26=("PVD") B26=(a[1,1]) C26=(a[2,1]) D26=(a[4,1]) E26=(a[5,1]) F26=(a[6,1]) using Univariate, sheet("MCV") modify
cs allcausemort pvd_i
putexcel G26=(r(rr)) H26=(r(lb_rr)) I26=(r(ub_rr)) J26=(r(rd)) K26=(r(lb_rd)) L26=(r(ub_rd)) M26=(r(p)) using Univariate, sheet("MCV") modify
//CKD
stcox ckd_amdrd
matrix a=r(table)
putexcel A27=("CKDaMDRD") B27=(a[1,1]) C27=(a[2,1]) D27=(a[4,1]) E27=(a[5,1]) F27=(a[6,1]) using Univariate, sheet("MCV") modify
//MEDICATIONS
//Statins
stcox statin_i
matrix a=r(table)
putexcel A28=("Statins") B28=(a[1,1]) C28=(a[2,1]) D28=(a[4,1]) E28=(a[5,1]) F28=(a[6,1]) using Univariate, sheet("MCV") modify
cs allcausemort statin_i
putexcel G28=(r(rr)) H28=(r(lb_rr)) I28=(r(ub_rr)) J28=(r(rd)) K28=(r(lb_rd)) L28=(r(ub_rd)) M28=(r(p)) using Univariate, sheet("MCV") modify
//Calcium Channel Blockers
stcox calchan_i
matrix a=r(table)
putexcel A29=("CCBs") B29=(a[1,1]) C29=(a[2,1]) D29=(a[4,1]) E29=(a[5,1]) F29=(a[6,1]) using Univariate, sheet("MCV") modify
cs allcausemort calchan_i
putexcel G29=(r(rr)) H29=(r(lb_rr)) I29=(r(ub_rr)) J29=(r(rd)) K29=(r(lb_rd)) L29=(r(ub_rd)) M29=(r(p)) using Univariate, sheet("MCV") modify
//Beta Blockers
stcox betablock_i
matrix a=r(table)
putexcel A30=("BBs") B30=(a[1,1]) C30=(a[2,1]) D30=(a[4,1]) E30=(a[5,1]) F30=(a[6,1]) using Univariate, sheet("MCV") modify
cs allcausemort betablock_i
putexcel G30=(r(rr)) H30=(r(lb_rr)) I30=(r(ub_rr)) J30=(r(rd)) K30=(r(lb_rd)) L30=(r(ub_rd)) M30=(r(p)) using Univariate, sheet("MCV") modify
//Anticoagulants
stcox anticoag_oral_i
matrix a=r(table)
putexcel A31=("Anticoags") B31=(a[1,1]) C31=(a[2,1]) D31=(a[4,1]) E31=(a[5,1]) F31=(a[6,1]) using Univariate, sheet("MCV") modify
cs allcausemort anticoag_oral_i
putexcel G31=(r(rr)) H31=(r(lb_rr)) I31=(r(ub_rr)) J31=(r(rd)) K31=(r(lb_rd)) L31=(r(ub_rd)) M31=(r(p)) using Univariate, sheet("MCV") modify
//Antiplatelets
stcox antiplat_i
matrix a=r(table)
putexcel A32=("Antiplats") B32=(a[1,1]) C32=(a[2,1]) D32=(a[4,1]) E32=(a[5,1]) F32=(a[6,1]) using Univariate, sheet("MCV") modify
cs allcausemort antiplat_i
putexcel G32=(r(rr)) H32=(r(lb_rr)) I32=(r(ub_rr)) J32=(r(rd)) K32=(r(lb_rd)) L32=(r(ub_rd)) M32=(r(p)) using Univariate, sheet("MCV") modify
//Angio-Renin System Drugs
stcox ace_arb_renin_i
matrix a=r(table)
putexcel A33=("AngioRenins") B33=(a[1,1]) C33=(a[2,1]) D33=(a[4,1]) E33=(a[5,1]) F33=(a[6,1]) using Univariate, sheet("MCV") modify
cs allcausemort ace_arb_renin_i
putexcel G33=(r(rr)) H33=(r(lb_rr)) I33=(r(ub_rr)) J33=(r(rd)) K33=(r(lb_rd)) L33=(r(ub_rd)) M33=(r(p)) using Univariate, sheet("MCV") modify
//Diuretics
stcox diuretics_all_i
matrix a=r(table)
putexcel A34=("Diuretics") B34=(a[1,1]) C34=(a[2,1]) D34=(a[4,1]) E34=(a[5,1]) F34=(a[6,1]) using Univariate, sheet("MCV") modify
cs allcausemort diuretics_all_i
putexcel G34=(r(rr)) H34=(r(lb_rr)) I34=(r(ub_rr)) J34=(r(rd)) K34=(r(lb_rd)) L34=(r(ub_rd)) M34=(r(p)) using Univariate, sheet("MCV") modify
//Unqrx
stcox unqrxi
matrix a=r(table)
putexcel A35=("Unique Rx") B35=(a[1,1]) C35=(a[2,1]) D35=(a[4,1]) E35=(a[5,1]) F35=(a[6,1]) using Univariate, sheet("MCV") modify

//Multivariate analysis
stset cvmajor_exit, fail(cvmajor) id(patid) origin(seconddate) scale(365.35)
stcox age_indexdate i.imd2010_5 prx_testvalue_i275 prx_testvalue_i2163 prx_testvalue_i2175 prx_testvalue_i2202 prx_covvalue_g_i3 phys_vis prx_servvalue2_h_i unqrxi i.unqrx i.gender i.prx_covvalue_g_i4 i.prx_ccivalue_g_i2 i.mi_i i.stroke_i i.hf_i i.arr_i i.ang_i i.urg_revasc_i i.htn_i i.afib_i i.pvd_i i.ckd_amdrd i.statin_i i.calchan_i i.betablock_i i.anticoag_oral_i i.antiplat_i i.ace_arb_renin_i i.diuretics_all_i
matrix b=r(table)
matrix c=b'
matrix list c
matrix rownames c = Age 0SES 1SES 2SES 3SES 4SES 9SES HbA1c TotChol HDL TG sysBP DocVisits Hospitalizations unqrxi 2unqrx 3unqrx 4unqrx 5ungrx 6unqrx 7unqrx 1gender 2gender 0smoking 1smoking 2smoking 3smoking 1cci 2cci 3cci 4cci 0mi 1mi 0stroke 1stroke 0HF 1HF 0Arr 1Arr 0angina 1angina 0revasc 1revasc 0HTN 1HTN 0Afib 1Afib 0PVD 1PVD 0CKD 1CKD 2CKD 3CKD 4CKD 5CKD 0Statin 1Statin 0CCB 1CCB 0BB 1BB 0Anticoag 1Anticoag 0Antiplat 1Antiplat 0AngioRenin 1AngioRenin 0Diur 1Diur
local matrownames "Age 0SES 1SES 2SES 3SES 4SES 9SES HbA1c TotChol HDL TG sysBP DocVisits Hospitalizations unqrxi 2unqrx 3unqrx 4unqrx 5ungrx 6unqrx 7unqrx 1gender 2gender 0smoking 1smoking 2smoking 3smoking 1cci 2cci 3cci 4cci 0mi 1mi 0stroke 1stroke 0HF 1HF 0Arr 1Arr 0angina 1angina 0revasc 1revasc 0HTN 1HTN 0Afib 1Afib 0PVD 1PVD 0CKD 1CKD 2CKD 3CKD 4CKD 5CKD 0Statin 1Statin 0CCB 1CCB 0BB 1BB 0Anticoag 1Anticoag 0Antiplat 1Antiplat 0AngioRenin 1AngioRenin 0Diur 1Diur"
forval i=1/69{
local x=`i'+1
local rowname:word `i' of `matrownames'
putexcel A1=("Variable") B1=("HR") C1=("SE") D1=("p-value") E1=("LL") F1=("UL") A`x'=("`rowname'") B`x'=(c[`i',1]) C`x'=(c[`i',2]) D`x'=(c[`i',4]) E`x'=(c[`i',5]) F`x'=(c[`i',6])using Multivariate, sheet("MCV_full") modify
}

///////////////////////////////////CORRELATION MATRICES//////////////////////////////////////////
//get basic correlation information
correlate age_indexdate prx_testvalue_i275 prx_testvalue_i2163 prx_testvalue_i2175 totservs_g_i prx_servvalue2_h_i unqrx marital gender prx_covvalue_g_i4 prx_ccivalue_g_i prx_covvalue_g_i7 prx_covvalue_g_i8 prx_covvalue_g_i10 prx_covvalue_g_i13 prx_covvalue_g_i14
twoway (scatter prx_testvalue_i2163 age_indexdate, sort) (scatter prx_testvalue_i2175 age_indexdate, sort) (scatter unqrx age_indexdate, sort) (scatter marital age_indexdate, sort) (scatter prx_covvalue_g_i4 age_indexdate, sort) (scatter prx_covvalue_g_i13 age_indexdate, sort)
//set for CV Major and test possible interactions
stset cvmajor_exit, fail(cvmajor) id(patid) origin(seconddate) scale(365.35)

gen totchol_int=round(prx_testvalue_i2163)
gen hdl_int=round(prx_testvalue_i2175)
stcox age_indexdate totchol_int hdl_int unqrx prx_covvalue_g_i4 prx_covvalue_g_i13 c.age_indexdate#totchol_int, nohr
