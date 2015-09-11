//  program:    Data14_time_varying_analysis.do
//  task:		Generate longitudinal data for A1c and BMI to compare the mediating effect of time dependent
//				covariates in a stepwise time-varying Cox model.
//  project: 	Incretins--Comparative mortality and CV outcomes (CPRD)
//  author:     JM \ Sep2015

//Start with Clinical long files
foreach file in Clinical001_2b Clinical002_2b Clinical003_2b Clinical004_2b Clinical005_2b Clinical006_2b Clinical007_2b Clinical008_2b Clinical009_2b Clinical010_2b Clinical011_2b Clinical012_2b Clinical013_2b {
use `file', clear
//WEIGHT
//gen continuous, restrict to reasonable values, eliminiate redundancy
gen weight =.
replace weight = data1 if enttype==13
label variable weight "Weight value (kg)"
replace weight =. if weight <= 20 | (weight >= 300 & weight <.) | (enttype==13 & data1==0)
tempvar dup_wt dup_mean_wt nr_mean_weight nr_weight
bysort patid enttype eventdate2: egen `nr_weight'=mean(weight) if weight<.
qui bysort patid enttype eventdate2: gen `dup_wt' = cond(_N==1,0,_n)
replace `nr_weight' =. if `dup_wt' >1 & `nr_weight'<.
//gen continuous mean_weight (from the restricted weight variable), eliminate redundancy
qui bysort patid enttype: egen `nr_mean_weight' = mean(`nr_weight') if `nr_weight'<.
qui bysort patid enttyp: gen `dup_mean_wt' = cond(_N==1, 0, _n)
replace `nr_mean_weight'=. if `dup_mean_wt'>1 & `nr_mean_weight'<.
//gen binary based on weight (NOT mean_weight)
gen weight_b = 0
replace weight_b = 1 if `nr_weight'<.
label variable weight_b "Weight (binary)"

//BMI
//gen continuous, restrict to reasonable values, eliminiate redundancy
gen bmi =.
replace bmi = data3 if enttype==13
label variable bmi "Body Mass Index (kg/m2)"
replace bmi =. if bmi <= 14 | (bmi >= 70 & bmi <.) | (enttype==13 & data3==0)
tempvar dup_bmi dup_mean_bmi nr_mean_bmi nr_bmi
bysort patid enttype eventdate2: egen `nr_bmi'=mean(bmi) if bmi<.
qui bysort patid enttype eventdate2: gen `dup_bmi' = cond(_N==1,0,_n)
replace `nr_bmi' =. if `dup_bmi' >1 & `nr_bmi'<.
//gen continuous mean_bmi (from the restricted bmi variable), eliminate redundancy
qui bysort patid enttype: egen `nr_mean_bmi' = mean(`nr_bmi') if `nr_bmi'<.
qui bysort patid enttyp: gen `dup_mean_bmi' = cond(_N==1, 0, _n)
replace `nr_mean_bmi'=. if `dup_mean_bmi'>1 & `nr_mean_bmi'<.
//gen binary based on bmi (NOT mean_bmi)
gen bmi_b = 0
replace bmi_b = 1 if `nr_bmi'<.
label variable bmi_b "BMI (binary)"
keep patid eventdate2 weight weight_b bmi bmi_b
//Save and append
if "`file'"=="Clinical001_2b" {
save BMI_Time_Varying, replace
}
else {
append using BMI_Time_Varying
save BMI_Time_Varying, replace
}
}
//merge long form of a1c and bmi
use LabCovariates, clear
keep patid hba1c nr_hba1c hba1c_b eventdate2
merge m:m patid using BMI_Time_Varying, keep(match master) nogen
save BMI_A1C_Time_Varying, replace
//Start with A1C and BMI long data?
do Data13_variable_generation
//drop if patients are excluded or if index prescription was before 01Jan2007
drop if exclude==1
drop if seconddate<17167

//merge in long form of lab covariates
drop weight weight_i weight_bin
merge 1:m patid using LabCovariates, keep(match master)
merge 1:m patid using BMI_Time_Varying, keep(match master) nogen
//drop unnecessary lab variables
capture drop constype consid medcode filenum totchol hdl ldl tg scr crcl albumin alt ast bilirubin hemoglobin nr_data2 nr_totchol nr_hdl nr_ldl nr_tg nr_scr nr_crcl nr_albumin nr_alt nr_ast nr_bilirubin nr_hemoglobin totchol_b hdl_b ldl_b tg_b scr_b crcl_b albumin_b alt_b ast_b bilirubin_b hemoglobin_b eltestdate2 testyr _merge
save Analytic_Dataset_Time_Varying, replace
compress
drop flu* pneumo* othervacc* ever* marital* regstat reggap internal toreason accept sex yob* pracid imd*

save Analytic_Dataset_Time_Varying, replace
//quietly generate data13 variables
quietly{
//Exclusion unification
gen exclude=1 if (gest_diab==1|pcos==1|preg==1|age_indexdate<=29|cohort_b==0|tx<=seconddate|deathdate2<indexdate|dod2<indexdate)
replace exclude=0 if exclude!=1
label var exclude "Bin ind for pcos, preg, gest_diab, or <30yo; excluded=1, not excluded=0)
tab exclude

quietly {
//Exposure variables
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
label define exposure 0 "SU" 1 "DPP4i" 2 "GLP1RA" 3 "INS" 4 "TZD" 5 "OTH" 6 "MET"
label value indextype exposure 
clonevar exposure=indextype
tabulate indextype, gen(indextype_)

gen indextype3=.
replace indextype3=0 if thirdadmrx=="SU"
replace indextype3=1 if thirdadmrx=="DPP"
replace indextype3=2 if thirdadmrx=="GLP"
replace indextype3=3 if thirdadmrx=="insulin"
replace indextype3=4 if thirdadmrx=="TZD"
replace indextype3=5 if thirdadmrx=="other"|thirdadmrx=="DPPGLP"|thirdadmrx=="DPPTZD"|thirdadmrx=="DPPinsulin"|thirdadmrx=="DPPother"|thirdadmrx=="GLPTZD"|thirdadmrx=="GLPinsulin"|thirdadmrx=="GLPother"|thirdadmrx=="SUDPP"|thirdadmrx=="SUGLP"|thirdadmrx=="SUTZD"|thirdadmrx=="SUinsulin"|thirdadmrx=="SUother"|thirdadmrx=="TZDother"|thirdadmrx=="insulinTZD"|thirdadmrx=="insulinother"
replace indextype3=6 if thirdadmrx=="metformin"
label value indextype3 exposure
tabulate indextype3, gen(indextype3_)

gen indextype4=.
replace indextype4=0 if fourthadmrx=="SU"
replace indextype4=1 if fourthadmrx=="DPP"
replace indextype4=2 if fourthadmrx=="GLP"
replace indextype4=3 if fourthadmrx=="insulin"
replace indextype4=4 if fourthadmrx=="TZD"
replace indextype4=5 if fourthadmrx=="other"|fourthadmrx=="DPPGLP"|fourthadmrx=="DPPTZD"|fourthadmrx=="DPPinsulin"|fourthadmrx=="DPPother"|fourthadmrx=="GLPTZD"|fourthadmrx=="GLPinsulin"|fourthadmrx=="GLPother"|fourthadmrx=="SUDPP"|fourthadmrx=="SUGLP"|fourthadmrx=="SUTZD"|fourthadmrx=="SUinsulin"|fourthadmrx=="SUother"|fourthadmrx=="TZDother"|fourthadmrx=="insulinTZD"|fourthadmrx=="insulinother"
replace indextype4=6 if fourthadmrx=="metformin"
label value indextype4 exposure
tabulate indextype4, gen(indextype4_)

gen indextype5=.
replace indextype5=0 if fifthadmrx=="SU"
replace indextype5=1 if fifthadmrx=="DPP"
replace indextype5=2 if fifthadmrx=="GLP"
replace indextype5=3 if fifthadmrx=="insulin"
replace indextype5=4 if fifthadmrx=="TZD"
replace indextype5=5 if fifthadmrx=="other"|fifthadmrx=="DPPGLP"|fifthadmrx=="DPPTZD"|fifthadmrx=="DPPinsulin"|fifthadmrx=="DPPother"|fifthadmrx=="GLPTZD"|fifthadmrx=="GLPinsulin"|fifthadmrx=="GLPother"|fifthadmrx=="SUDPP"|fifthadmrx=="SUGLP"|fifthadmrx=="SUTZD"|fifthadmrx=="SUinsulin"|fifthadmrx=="SUother"|fifthadmrx=="TZDother"|fifthadmrx=="insulinTZD"|fifthadmrx=="insulinother"
replace indextype5=6 if fifthadmrx=="metformin"
label value indextype5 exposure
tabulate indextype5, gen(indextype5_)

gen indextype6=.
replace indextype6=0 if sixthadmrx=="SU"
replace indextype6=1 if sixthadmrx=="DPP"
replace indextype6=2 if sixthadmrx=="GLP"
replace indextype6=3 if sixthadmrx=="insulin"
replace indextype6=4 if sixthadmrx=="TZD"
replace indextype6=5 if sixthadmrx=="other"|sixthadmrx=="DPPGLP"|sixthadmrx=="DPPTZD"|sixthadmrx=="DPPinsulin"|sixthadmrx=="DPPother"|sixthadmrx=="GLPTZD"|sixthadmrx=="GLPinsulin"|sixthadmrx=="GLPother"|sixthadmrx=="SUDPP"|sixthadmrx=="SUGLP"|sixthadmrx=="SUTZD"|sixthadmrx=="SUinsulin"|sixthadmrx=="SUother"|sixthadmrx=="TZDother"|sixthadmrx=="insulinTZD"|sixthadmrx=="insulinother"
replace indextype6=6 if sixthadmrx=="metformin"
label value indextype6 exposure
tabulate indextype6, gen(indextype6_)

gen indextype7=.
replace indextype7=0 if seventhadmrx=="SU"
replace indextype7=1 if seventhadmrx=="DPP"
replace indextype7=2 if seventhadmrx=="GLP"
replace indextype7=3 if seventhadmrx=="insulin"
replace indextype7=4 if seventhadmrx=="TZD"
replace indextype7=5 if seventhadmrx=="other"|seventhadmrx=="DPPGLP"|seventhadmrx=="DPPTZD"|seventhadmrx=="DPPinsulin"|seventhadmrx=="DPPother"|seventhadmrx=="GLPTZD"|seventhadmrx=="GLPinsulin"|seventhadmrx=="GLPother"|seventhadmrx=="SUDPP"|seventhadmrx=="SUGLP"|seventhadmrx=="SUTZD"|seventhadmrx=="SUinsulin"|seventhadmrx=="SUother"|seventhadmrx=="TZDother"|seventhadmrx=="insulinTZD"|seventhadmrx=="insulinother"
replace indextype7=6 if seventhadmrx=="metformin"
label value indextype7 exposure
tabulate indextype7, gen(indextype7_)

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
replace post_`admrx' = 1 if regexm(`next', "`admrx'")
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

//SOCIODEMOGRAPHICS//
//Age
generate age_cat = age_indexdate
summ age_indexdate
recode age_cat (min/29=0) (30/39=1) (40/49=2) (50/59=3) (60/69=4) (70/79=5) (80/89=6) (89/max=7)
label define age_cats 0 "under 30" 1 "30-39" 2 "40-49" 3 "50-59" 4 "60-69" 5 "70-79" 6 "80-89" 7 "90+"
label values age_cat age_cats
recode age_indexdate (min/65=0) (65/max=1), gen(age_65)

//COMORBIDITIES
//MI
gen mi_i =0
replace mi_i= 1 if prx_covvalue_g_ai6==1|prx_covvalue_ai6==1

//Stroke
gen stroke_i =0
replace stroke_i= 1 if prx_covvalue_g_ai7==1|prx_covvalue_ai7==1

//HF
gen hf_i =0
replace hf_i= 1 if prx_covvalue_g_ai8==1|prx_covvalue_ai8==1

//Arrhythmia
gen arr_i =0
replace arr_i= 1 if prx_covvalue_g_ai9==1|prx_covvalue_ai9==1

//Angina
gen ang_i =0
replace ang_i= 1 if prx_covvalue_g_ai10==1|prx_covvalue_ai10==1

//Revascularization
gen revasc_i =0
replace revasc_i= 1 if prx_covvalue_g_ai11==1|prx_covvalue_ai11==1

//HTN
gen htn_i =0
replace htn_i= 1 if prx_covvalue_g_ai12==1|prx_covvalue_ai12==1

//Atrial Fibrillation
gen afib_i =0
replace afib_i= 1 if prx_covvalue_g_ai13==1|prx_covvalue_ai13==1

//Peripheral Vascular Disease
gen pvd_i =0
replace pvd_i= 1 if prx_covvalue_g_ai14==1|prx_covvalue_i14==1

//History of CVD
gen cvd_i = 0
replace cvd_i=1 if (pvd_i==1|afib_i==1|revasc_i==1|ang_i==1|arr_i==1|hf_i==1|stroke_i==1|mi_i==1)

//Fill in hes cci
replace  prx_ccivalue_g_i2=1 if prx_ccivalue_g_i2==.
replace  prx_ccivalue_g_i2=3 if prx_ccivalue_g_i2==4
label define cci 1 "1" 2 "2" 3 "3+"
label value prx_ccivalue_g_i2 cci
tabulate prx_ccivalue_g_i2, gen(cci)

//PHYSIOLOGICS
//HbA1c
gen hba1c_i2 = prx_testvalue_i2275 if prx_testvalue_i2275>=2& prx_testvalue_i2275<=25
gen hba1c_cats_i2=round(hba1c_i2)
recode hba1c_cats_i2 (.=5) (min/7=0) (7/8=1) (8/9=2) (9/10=3) (10/max=4)
label define hba1c_cats 5 "Unknown" 0 "<7.0%" 1 "7.0-8.0%" 2 "8.0-9.0%" 3 "9.0-10.0%" 4 ">10%"
label values hba1c_cats_i2 hba1c_cats
tabulate hba1c_cats_i2, gen(a1ccat)
recode hba1c_i2 (min/8=0)(8/max=1), gen(hba1c_8)

//SBP
clonevar sbp = prx_covvalue_g_i3
gen sbp_i = 1 if (prx_cov_g_i_b3==1)
replace sbp_i=0 if sbp_i!=1
gen sbp_i_cats=prx_covvalue_g_i3
recode sbp_i_cats (min/120=0) (120/130=1) (130/140=2) (140/150=3) (150/160=4) (160/170=5) (170/180=6) (180/max=7) (.=8)
clonevar sbp_i_cats2 = prx_covvalue_g_i3
recode sbp_i_cats2 (min/120=0) (120/130=1) (130/140=2) (140/150=3) (150/160=4) (160/max=5) (.=8)
label define sbp 0 "<120" 1 "120 to 129" 2 "130 to 139" 3 "140 to 149" 4 "150 to 159" 5 "160+" 8 "missing"
label value sbp_i_cats2 sbp
tabulate sbp_i_cats2, gen(sbpcat)

//Total Cholesterol
summ prx_testvalue_i163 if exclude==0, detail
gen totchol_i = 1 if prx_test_i_b163==1
replace totchol_i=0 if totchol_i!=1

//High Density Lipoprotein
summ prx_testvalue_i175 if exclude==0, detail
gen hdl_i = 1 if prx_test_i_b175==1
replace hdl_i=0 if hdl_i!=1

//Low Density Lipoprotein 
summ prx_testvalue_i177 if exclude==0, detail
gen ldl_i = 1 if prx_test_i_b177==1
replace ldl_i=0 if ldl_i!=1

//Triglycerides
summ prx_testvalue_i202 if exclude==0, detail
gen tg_i = 1 if prx_test_i_b202==1
replace tg_i=0 if tg_i!=1

//Height
gen height_i = prx_covvalue_g_ai1_closest
gen heightsq_i = prx_covvalue_g_ai1_closest*prx_covvalue_g_ai1_closest
gen height_bin = 1 if height_i!=.
replace height_bin=0 if height_i==.
recode height_bin (0=1) (1=0) 

//Weight
gen weight_i = prx_covvalue_g_ai2_closest
gen weight_bin = 1 if weight_i!=.
replace weight_bin=0 if weight_i==.
recode weight_bin (0=1) (1=0) 
 
//BMI
//Using the height and weight closest to the indexdate to calculate bmi
gen bmi_calcd = weight_i/heightsq_i if weight_i!=.&heightsq_i!=.
gen bmi_calcd_cats=bmi_calcd
replace bmi_calcd = . if bmi_calcd<=14|bmi_calcd>70
recode bmi_calcd_cats (min/18.5=0) (18.5/25=1) (25/30=2) (30/35=3) (35/40=4) (40/max=5) (.=9)
label define bmi 0 "<18.5" 1 "18.5 to 24" 2 "25 to 29" 3 "30 to 34" 4 "35 to 40" 5 "40+" 9 "unknown"
label value bmi_calcd_cats bmi
//Using the closest (before or after) indexdate method to extract bmi from the weight enttype data3
gen bmi_i = prx_covvalue_g_ai17_closest
replace bmi_i=bmi_calcd if bmi_i==.
gen bmi_i_cats=bmi_i
recode bmi_i_cats (min/18.5=0) (18.5/25=1) (25/30=2) (30/35=3) (35/40=4) (40/max=5) (.=9)
label value bmi_i_cats bmi
tabulate bmi_i_cats, gen(bmicat)
recode bmi_i (min/30=0) (30/max=1), gen(bmi_30)

//MEDICATIONS//
gen ace_arb_renin_i=(acei_i==1|renini_i==1|angiotensin2recepant_i==1)
gen diuretics_all_i=(thiazdiur_i==1|loopdiur_i==1|potsparediur_aldos_i==1|potsparediur_other_i==1)
gen dmdur = (seconddate-firstadmrxdate)/365.25
label var dmdur "duration of treated diabetes"
recode dmdur (min/2=0) (2/5=1) (5/max=2), gen(dmdur_cat)
recode dmdur (min/2=0) (2/max=1), gen(dmdur_2)
label var dmdur_cat "0=<2yrs; 1=2to5yrs; 2=5+yrs"
label var dmdur_2 ">=2 yrs of treated diabetes" 

gen metoverlap = exposuretf6-seconddate
label var metoverlap "Metformin overlap duration"

gen heartmeds_i=(statin_i==1|calchan_i==1|betablock_i==1|anticoag_oral_i==1|antiplat_i==1|ace_arb_renin_i==1|diuretics_all_i==1)
label var heartmeds_i "History of heart medications before indexdate 1=yes, 0=no"
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
replace ckd_amdrd=5 if egfr_amdrd < 15 | prx_covvalue_g_i16==1 //note this includes marker for ESRD
replace ckd_amdrd=9 if ckd_amdrd==.
//create value labels for ckd 1-5
label define ckd_amdrd_labels 1 ">=90" 2 "60-89"  3 "30-59" 4 "15-29" 5 "<15" 9 "missing"
label values ckd_amdrd ckd_amdrd_labels
tabulate ckd_amdrd, gen(ckdcat)
recode egfr_amdrd (min/60=1) (60/max=0), gen(ckd_60)

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

//Outcomes, indicators and exit dates for survival analysis

//All-cause mortality
gen allcausemort = 1 if death_date!=.
label var allcausemort "All-cause mortality"
clonevar acm = allcausemort
egen acm_exit = rowmin(tod2 death_date lcd2)
egen acm_exit_o = rowmin(tod2 death_ons lcd2)
egen acm_exit_c = rowmin(tod2 deathdate2 lcd2)
format acm_exit %td
label var acm_exit "Exit date for all-cause mortality analysis"

//MACE
gen mace_i=1 if mi_i==1|stroke_i==1
label var mace_i "Indicator for first major cv event before indexdate (mi, stroke, cvdeath) 1=event, 0=no event"
egen mace_exit = rowmin(mace_date tod2 death_date lcd2)
format mace_exit %td
label var mace_exit "Exit date for major cardiovascular event (MI, stroke, or CV death)"

//Myocardial infarction
gen mi = myoinfarct_date_i!=.
label var mi "Indicator for first MI 1=event, 0=no event"
egen mi_exit = rowmin(myoinfarct_date_i tod2 death_date lcd2)
format mi_exit %td
label var mi_exit "Exit date for myocardial infarction"

//Stroke
gen stroke = stroke_date_i!=.
label var stroke "Indicator for first stroke after indexdate 1=event, 0=no event"
egen stroke_exit = rowmin(stroke_date_i tod2 death_date lcd2)
format stroke_exit %td
label var stroke_exit "Exit date for stroke"

//Stroke/TIA
gen stroketia= stroketia_date_i!=.
label var stroketia "Indicator for first stroke or TIA after indexdate 1=event, 0=no event"
egen stroketia_exit = rowmin(stroketia_date_i tod2 death_date lcd)
format stroketia_exit %td
label var stroketia_exit "Exit date for stroke/TIA"

gen mi_stroke_i=(mi_i==1 | stroke_i==1)
label var mi_stroke_i "MI or stroke prior to index"

gen mi_stroke = (mi==1|stroke==1) 
label var mi_stroke "Indicator for first MI or stroke after indexdate"

gen mi_stroketia = (mi==1|stroketia==1)
label var mi_stroketia "Indicator for first MI or stroke/TIA after indexdate"

//CV death
gen cvdeath = cvdeath_date_i!=.
label var cvdeath "Indicator for CV death after indexdate 1=event, o=no event"
egen cvdeath_exit = rowmin(tod2 death_date lcd2)
format cvdeath_exit %td
label var cvdeath_exit "Exit date for CV death"

//Heart Failure
gen heartfail = heartfail_date_i!=.
label var heartfail "Indicator for heart failure after indexdate 1=event, 0=no event"
clonevar hf = heartfail
egen hf_exit = rowmin(heartfail_date_i tod2 death_date lcd2)
format hf_exit %td
label var hf_exit "Exit date for heart failure"

//Cardiac Arrhythmia: use arrhythmia_g arrhythmia_g_date_i
gen arr = arrhythmia_date_i!=.
label var arr "Indicator for heart failure after indexdate 1=event, 0=no event"
egen arr_exit = rowmin(arrhythmia_date_i tod2 death_date lcd2)
format arr_exit %td
label var arr_exit "Exit date for cardiac arrhythmia"

//Unstable Angina: use angina_g angina_g_date_i
gen ang =angina_date_i!=.
label var ang "Indicator for unstable angina after indexdate 1=event, 0=no event"
egen ang_exit = rowmin(angina_date_i tod2 death_date lcd2)
format ang_exit %td
label var ang_exit "Exit date for unstable angina"

//Urgent revascularization: use revasc_g revasc_g_date_i
gen revasc = revasc_date_i!=.
label var revasc "Indicator for heart failure after indexdate 1=event, 0=no event"
egen revasc_exit = rowmin(revasc_date_i tod2 death_date lcd2)
format revasc_exit %td
label var revasc_exit "Exit date for urgent revascularization"

// Labeling

label var age_index "Age at index date"
label var age_cat "Age"
label var gender "Sex"
label var dmdur "Duration of treated diabetes"
label var prx_covvalue_g_i4 "Smoking Status"
label var prx_covvalue_g_i5 "Alcoholism"
label var bmi_i_cats "BMI"
label var physician_vis "No. of Physician Visits"
label var prx_ccivalue_g_i2 "Charlson Comorbidity Index"
label var ang_i "Angina"
label var arr_i "Arryhthmia"
label var afib_i "Atrial Fibrillation"
label var hf_i "Heart Failure"
label var htn_i "Hypertension"
label var mi_i "Myocardial Infarction"
label var pvd_i "Peripheral Vascular Disease"
label var stroke_i "Stroke"
label var revasc_i "Revascularization Procedure"
label var hba1c_i "HbA1c continuous"
label var hba1c_cats_i "HbA1c categories"
label var prx_covvalue_g_i3 "Systolic Blood Pressure"
label var sbp_i_cats2 "Systolic Blood Pressure categories"
label var ckd_amdrd "eGFR categories"
label var egfr_amdrd "eGFR"
label var unique_cov_drugs "No unique drugs"
label var statin_i "Statins"
label var calchan_i "Calcium Channel Blockers"
label var betablock_i "Beta-Blockers"
label var anticoag_oral_i "Anticoagulants"
label var antiplat_i "Antiplatelets"
label var ace_arb_renin_i "ACE/ARB/Renin"
label var diuretics_all_i "Diuretics"
label var unqrx "No unique antidiabetic agents"
}
}

//tidy labels
label var tx "Censor date calculated as first of lcd, tod"
label var cohort_b "Binary indicator; 1=metformin first only cohort; 0=not in cohort"
label var unqrx "Number of unique antidiabetic medications"

//Start at indexdate and get 3 or 6 month windows

//use stsplit method, re-integrate values 
stset acm_exit, fail(acm) id(patid) origin(seconddate) scale(365.25)

quietly {
// spit data to integrate time-varying covariates for diabetes meds.
stsplit adm3, after(thirddate) at(0)
gen su_post=(indextype3==0 & adm3!=-1)
gen dpp4i_post=(indextype3==1 & adm3!=-1)
gen glp1ra_post=(indextype3==2 & adm3!=-1)
gen ins_post=(indextype3==3  & adm3!=-1)
gen tzd_post=(indextype3==4 & adm3!=-1)
gen oth_post=(indextype3==5  & adm3!=-1)

stsplit adm4, after(fourthdate) at(0)
replace su_post=1 if indextype4==0 & adm4!=-1
replace dpp4i_post=1 if indextype4==1 & adm4!=-1
replace glp1ra_post=1 if indextype4==2 & adm4!=-1
replace ins_post=1 if indextype4==3 & adm4!=-1
replace tzd_post=1 if indextype4==4 & adm4!=-1
replace oth_post=1 if indextype4==5 & adm4!=-1

stsplit adm5, after(fifthdate) at(0) 
replace su_post=1 if indextype5==0 & adm5!=-1
replace dpp4i_post=1 if indextype5==1 & adm5!=-1
replace glp1ra_post=1 if indextype5==2 & adm5!=-1
replace ins_post=1 if indextype5==3 & adm5!=-1
replace tzd_post=1 if indextype5==4 & adm5!=-1
replace oth_post=1 if indextype5==5 & adm5!=-1

stsplit adm6, after(sixthdate) at(0)
replace su_post=1 if indextype6==0 & adm6!=-1
replace dpp4i_post=1 if indextype6==1 & adm6!=-1
replace glp1ra_post=1 if indextype6==2 & adm6!=-1
replace ins_post=1 if indextype6==3 & adm6!=-1
replace tzd_post=1 if indextype6==4 & adm6!=-1
replace oth_post=1 if indextype6==5 & adm6!=-1

stsplit adm7, after(seventhdate) at(0)
replace su_post=1 if indextype7==0 & adm7!=-1
replace dpp4i_post=1 if indextype7==1 & adm7!=-1
replace glp1ra_post=1 if indextype7==2 & adm7!=-1
replace ins_post=1 if indextype7==3 & adm7!=-1
replace tzd_post=1 if indextype7==4 & adm7!=-1
replace oth_post=1 if indextype7==5 & adm7!=-1

stsplit stop0, after(exposuretf0) at(0)
replace su_post=0 if su_post==1 & stop0!=-1

stsplit stop1, after(exposuretf1) at(0)
replace dpp4i_post=0 if dpp4i_post==1 & stop1!=-1

stsplit stop2, after(exposuretf2) at(0)
replace glp1ra_post=0 if glp1ra_post==1 & stop2!=-1

stsplit stop3, after(exposuretf3) at(0)
replace ins_post=0 if ins_post==1 & stop3!=-1

stsplit stop4, after(exposuretf4) at(0)
replace tzd_post=0 if tzd_post==1 & stop4!=-1

stsplit stop5, after(exposuretf5) at(0)
replace oth_post=0 if oth_post==1 & stop5!=-1
}

stsplit a1cband, at(hba1c_b) after(seconddate)
stsplit bmiband, at(bmifail) after(seconddate)
//Expand and populate to generate the number of time samples wanted

//Generate c variable

//stset

//Generate c*time variable

//COMPLETE CASE ANALYSIS

//stcox i.indextype `mvmodel' ctime

//MULTIPLE IMPUTATION ANALYSIS

//insert MI code

//Re-generate c*time variable

//stcox i.indextype `mvmodel_mi' ctime
