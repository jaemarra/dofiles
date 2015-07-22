//  program:    Stat_manuscript.do
//  task:		Manuscript numbers generation
//  project: 	Incretins--Comparative mortality and CV outcomes (CPRD)
//  author:     JM \ July 2015  

use Analytic_Dataset_Master
do Data13_variable_generation
keep if exclude==0&seconddate>17167

//ABSTRACT RESULTS
unique patid 
tab indextype
gen fup =.
replace fup=tx-indexdate
label var fup "Follow-up time from indexdate to censor date"
summ fup, detail
summ age_indexdate 
summ gender 
summ hba1c_i2
unique patid if death_date!=. 
unique patid if mace==1
unique patid if myoinfarct_date_i!=.
unique patid if stroke_date_i!=.
unique patid if cvdeath_date_i!=.
unique patid if linked_b==1 //cvdeath has to be divided only by linked population (n)
//get duration of metformin monotherapy prior to index switch/add
gen metmono=.
replace metmono=indexdate-cohortentrydate
summ metmono, detail
label var metmono "Duration of metformin monotherpy prior to index swtich/add"
//get the history of...
//cvd
unique patid if cvd_i==1
//egfr<60
unique patid if ckd_amdrd==3|ckd_amdrd==4|ckd_amdrd==5
//BMI
summ bmi_i
//hba1c
summ hba1c_i2
//get the history for DPP vs SU
summ age_indexdate if indextype==1
summ age_indexdate if indextype==0
summ metmono if indextype==1
summ metmono if indextype==0
unique patid if bmi_i>=30&indextype==1
unique patid if bmi_i>=30&indextype==0
summ hba1c_i2 if indextype==1
summ hba1c_i2 if indextype==0
//get linked data
tab indextype if linked_b==1
//to get the linked numbers
unique patid if linked_b==1
tab indextype if linked_b==1
unique patid if linked_b==1&acm==1
unique patid if linked_b==1&mace==1

//RESULTS SECTION 

//FIGURE 1: PATIENT FLOW (from draw.io)
//FIGURE S1: LINKED PATIENT FLOW (from draw.io)
//TABLE 1: BASELINE CHARACTERISTICS (from table1.xlsx)
//TABLE S1: LINKED BASELINE CHARACTERISTICS (from table1_linked.xlsx)

//ACM WRITTEN SECTION NUMBERS: For SMRs, IRs, person-time, HRs and CIs either use table2_acm.xlsx (Unadj MI Ref0 tab)
//OR:
use Stat_acm_mi, clear
by indextype, sort : stir acm
//mortality rates:
mi xeq 1: stptime, by(indextype) per(1000)
//get the adjusted hr:
mi estimate, hr: stcox i.indextype `mvmodel_mi'
//Either use table2_acm.xlsx (Adj MI Ref2, Adj MI Ref3, and Adj MI Ref4 tabs)
//OR to manually change the reference groups:
use Stat_acm_mi, clear
mi estimate, hr: stcox ib2.indextype `mvmodel_mi' //GLP
mi estimate, hr: stcox ib3.indextype `mvmodel_mi' //INS
mi estimate, hr: stcox ib4.indextype `mvmodel_mi' //TZD

//TABLE 2: DPP SUBCLASS RATES
//Generate additional incidence data for subclasses of DPP
use Stat_acm_mi, clear
gen dpptype = .
replace dpptype = 1 if indextype==1&alogliptin==1
replace dpptype = 2 if indextype==1&linagliptin==1
replace dpptype = 3 if indextype==1&sitagliptin==1
replace dpptype = 4 if indextype==1&saxagliptin==1
replace dpptype = 5 if indextype==1&vildagliptin==1
mi xeq 2: stptime, by(dpptype) per(1000)

//FIGURE 2: UNADJUSTED AND ADJUSTED COX PROPORTIONAL HAZARDS REGRESSION ANALYSIS
use Stat_acm_cc, clear
// note: complete case analysis (BMI and SBP have missing values; therefore total N is reduced if BMI and SBP in model)
// note: missing indicators used for discrete variables with missing values (smoking status, A1C, eGFR)
// 1. Unadjusted model
stcox i.indextype, cformat(%6.2f) pformat(%5.3f) sformat(%6.2f) 
// 2. + age, gender
stcox i.indextype age_index gender, cformat(%6.2f) pformat(%5.3f) sformat(%6.2f)  
// 2. + dmdur, metoverlap, hba1c
stcox i.indextype age_indexdate gender dmdur metoverlap ib1.hba1c_cats_i2, cformat(%6.2f) pformat(%5.3f) sformat(%6.2f)  
// 3. + bmi, ckd, unique drugs, physician visits, cci
stcox i.indextype age_indexdate gender dmdur metoverlap ib1.hba1c_cats_i2 ib1.sbp_i_cats2 i.ckd_amdrd i.unique_cov_drugs i.physician_vis2 i.prx_ccivalue_g_i2, cformat(%6.2f) pformat(%5.3f) sformat(%6.2f)  
// 4. Test out full multivariate model (mvmodel) all covariates included
stcox i.indextype `mvmodel', cformat(%6.2f) pformat(%5.3f) sformat(%6.2f)  
/* ONLY FOR GENERATING FOREST PLOT
use MainModels, clear
capture lable drop models
capture label drop modelcats
capture rename Models Covariates
label define modelcats 1 "Unadjusted" 2 "Adjusted for age" 3 "Adjusted for previous" 4 "Adjusted for previous + SBP," 5 "Adjusted for" 6 "Propensity score adjusted"
label values model modelcats
capture label drop covariates
label define covariates 0 "no Covariates" 1 "and gender" 2 "+ met mono, met overlap, A1c" 3 "CKD, unique Rx, CCI, visits" 4 "all covariates" 5 "for age, gender, decile"
label values Covariates covariates
capture rename Covariates Models
metan hr ll ul, force by(model) nowt nobox nooverall nosubgroup null(1) xlabel(0.25, 0.5, .75, 1.25) astext(70) scheme(s1mono) lcols(Models) effect("Hazard Ratio") saving(MainModelComparison, asis replace)
*/

//TABLE 3: ACM IN GLP VS SU AT VARIOUS PERIODS OF USE FOLLOWING MONOTHERAPY
//note: TABLE S3 can be generated at the same time looking at DPP41 rows instead of GLP1RA
//secondline OR use table2_acm.xlsx (Unadj MI and Adj MI Ref0 tabs)
use Stat_acm_mi
mi xeq 1: stptime, by(indextype) per(1000)
mi estimate, hr: stcox i.indextype
mi estimate, hr: stcox i.indextype `mvmodel_mi'
//second line, first gap OR use table2_acm.xlsx (Unadj MI Gap1 and Adj MI Gap1 tabs)
use Stat_acm_mi_index
mi xeq 1: stptime, by(indextype) per(1000)
mi estimate, hr: stcox i.indextype
mi estimate, hr: stcox i.indextype `mvmodel_mi'
//thirdline OR use table2_acm.xlsx (Unadj MI Agent3 and Adj MI Agent3 tabs)
use Stat_acm_mi_index3
local mvmodel_mi = "age_indexdate gender dmdur metoverlap i.ckd_amdrd i.unique_cov_drugs i.prx_ccivalue_g_i2 cvd_i statin_i calchan_i betablock_i anticoag_oral_i antiplat_i ace_arb_renin_i diuretics_all_i bmi_i sbp ib1.hba1c_cats_i2_clone ib2.prx_covvalue_g_i4_clone i.physician_vis2"
mi xeq 1: stptime, by(indextype) per(1000)
mi estimate, hr: stcox i.indextype
mi estimate, hr: stcox i.indextype `mvmodel_mi'
//any after monotherapy OR use table2_acm.xlsx (Unadj MI Any Aft and Adj MI Any Aft tabs)
use Stat_acm_mi_any
mi xeq 1: stptime, by(indextype) per(1000)
mi estimate, hr: stcox i.indextype
mi estimate, hr: stcox i.indextype `mvmodel_mi'

//FIGURE S2A, S2B, and S2B: UNADJUSTED and ADJUSTED HR AT DIFF EXPOSURE PERIODS FOR DPP4i VS GLP1RA.
/*
Comparative Plots
use DPPvsGLP_acm, clear
capture label drop agents
label define agents 1 "GLP1RA" 2 "DPP4i"
capture rename agent Agent
label values Agent agents
capture label drop periodcats
label define periodcats 1 "Index to last continuous" 2 "Index to last continuous, adj" 3 "Index to last" 4 "Index to last, adj" 5 "Index to switch/add" 6 "Index to switch/add, adj" 7 "Any exposure after metformin" 8 "Any exposure after metformin, adj" 
capture rename period Period
label values Period periodcats
metan hr ll ul, force by(Agent) nowt nobox nooverall nosubgroup null(1) scheme(s1mono) astext(70) xlabel(0, 1, 2, 3) lcols(Period) effect("Hazard Ratio") saving(DPPvsGLP_acm, asis replace)
*/

//FIGURE NOT INCLUDED BUT AVAILABLE: COMPARISON OF ACM AND MACE FOR DPP USERS AT VARIABLE DEFINED PERIODS OF EXPOSURE.
/*
Sensitivity Analyses Plots
use SensitivityGraphs, clear
capture label drop subgroupcats
label define subgroupcats 1 "ACM" 2 "MACE"
capture rename subgroup Subgroup
label values Subgroup subgroupcats
capture label drop periodcats
label define periodcats 1 "Index to last" 2 "Index to last continuous" 3 "Index to switch/add" 4 "Index or later exposure" 
capture rename period Period
label values Period periodcats
metan hr ll ul, force by(Subgroup) nowt nobox nooverall nosubgroup null(1) scheme(s1mono) xlabel(0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10) lcols(Period) effect("Hazard Ratio") saving(SensGrph, asis replace)
*/

//MACE WRITTEN SECTION NUMBERS: 
//get duration of metformin monotherapy prior to index switch/add
//to get the linked numbers
use Analytic_Dataset_Master
do Data13_variable_generation
keep if linked_b==1
tab indextype
tab mace
//For SMRs, IRs, person-time, HRs and CIs either use table2_mace.xlsx (Unadj MI Ref0 tab)
//OR:
//to get the incidence rates
use Stat_mace_mi, clear
keep if linked_b==1
by indextype, sort : stir mace
//mortality rates
mi xeq 1: stptime, by(indextype) per(1000)

//FIGURE 3: UNADJUSTED AND ADJUSTED COX PROPORTIONAL HAZARDS REGRESSION ANALYSIS
// note: complete case approach used
use Stat_mace_cc, clear
keep if linked_b==1
// 1. Unadjusted model
stcox i.indextype, cformat(%6.2f) pformat(%5.3f) sformat(%6.2f) nolog
// 2. + age, gender
stcox i.indextype age_index gender, cformat(%6.2f) pformat(%5.3f) sformat(%6.2f)  nolog
// 2. + dmdur, metoverlap, hba1c
stcox i.indextype age_indexdate gender dmdur metoverlap ib1.hba1c_cats_i2, cformat(%6.2f) pformat(%5.3f) sformat(%6.2f)  nolog
// 3. + bmi, ckd, unique drugs, physician visits, cci
stcox i.indextype age_indexdate gender dmdur metoverlap ib1.hba1c_cats_i2 ib1.sbp_i_cats2 i.ckd_amdrd i.unique_cov_drugs i.physician_vis2 i.prx_ccivalue_g_i2, cformat(%6.2f) pformat(%5.3f) sformat(%6.2f)  nolog
// 4. Test out full multivariate model (mvmodel) all covariates included
stcox i.indextype `mvmodel', cformat(%6.2f) pformat(%5.3f) sformat(%6.2f)  nolog
/* ONLY FOR GENERATING FOREST PLOT
use MainModelsMace, clear
capture lable drop models
capture label drop modelcats
capture rename covariates Covariates
label define modelcats 1 "Unadjusted" 2 "Adjusted for age" 3 "Adjusted for previous" 4 "Adjusted for previous + SBP," 5 "Adjusted for" 6 "Propensity score adjusted"
label values model modelcats
capture label drop covariates
label define covariates 0 "no Covariates" 1 "and gender" 2 "+ met mono, met overlap, A1c" 3 "CKD, unique Rx, CCI, visits" 4 "all covariates" 5 "for age, gender, decile"
label values Covariates covariates
capture rename Covariates Models
metan hr ll ul, force by(model) nowt nobox nooverall nosubgroup null(1) xlabel(0, 0.25, 0.5, 0.75) astext(70) scheme(s1mono) lcols(Models) effect("Hazard Ratio") saving(MainModelComparison, asis replace)
*/

//MACE WRITTEN NUMBERS CONT'D: 
//Use table2_mace.xlsx (Adj MI Ref0 tab)get the adjusted hr OR:
use Stat_acm_mi, clear
keep if linked_b==1
mi estimate, hr: stcox i.indextype `mvmodel_mi'
//Either use table2_mace.xlsx (Adj MI Ref2, Adj MI Ref3, and Adj MI Ref4 tabs)
//OR to manually change the reference groups:
mi estimate, hr: stcox ib1.indextype `mvmodel_mi' //DPP
mi estimate, hr: stcox ib2.indextype `mvmodel_mi' //GLP
mi estimate, hr: stcox ib3.indextype `mvmodel_mi' //INS
mi estimate, hr: stcox ib4.indextype `mvmodel_mi' //TZD

//TABLE 4: MACE IN GLP VS SU AT VARIOUS PERIODS OF USE FOLLOWING MONOTHERAPY
//note: TABLE S4 can be generated at the same time looking at DPP41 rows instead of GLP1RA
//secondline OR use table2_acm.xlsx (Unadj MI and Adj MI Ref0 tabs)
use Stat_mace_mi
keep if linked_b==1
mi xeq 1: stptime, by(indextype) per(1000)
mi estimate, hr: stcox i.indextype
mi estimate, hr: stcox i.indextype `mvmodel_mi'
//second line, first gap OR use table2_acm.xlsx (Unadj MI Gap1 and Adj MI Gap1 tabs)
use Stat_mace_mi_index
keep if linked_b==1
mi xeq 1: stptime, by(indextype) per(1000)
mi estimate, hr: stcox i.indextype
mi estimate, hr: stcox i.indextype `mvmodel_mi'
//thirdline OR use table2_acm.xlsx (Unadj MI Agent3 and Adj MI Agent3 tabs)
use Stat_mace_mi_index3
keep if linked_b==1
local mvmodel_mi = "age_indexdate gender dmdur metoverlap i.ckd_amdrd i.unique_cov_drugs i.prx_ccivalue_g_i2 cvd_i statin_i calchan_i betablock_i anticoag_oral_i antiplat_i ace_arb_renin_i diuretics_all_i bmi_i sbp ib1.hba1c_cats_i2_clone ib2.prx_covvalue_g_i4_clone i.physician_vis2"
mi xeq 1: stptime, by(indextype) per(1000)
mi estimate, hr: stcox i.indextype
mi estimate, hr: stcox i.indextype `mvmodel_mi'
//any after monotherapy OR use table2_acm.xlsx (Unadj MI Any Aft and Adj MI Any Aft tabs)
use Stat_mace_mi_any
keep if linked_b==1
mi xeq 1: stptime, by(indextype) per(1000)
mi estimate, hr: stcox i.indextype
mi estimate, hr: stcox i.indextype `mvmodel_mi'

/*
Sensitivity Analyses Plots
use SensitivityGraphs, clear
capture label drop subgroupcats
label define subgroupcats 1 "DPP" 2 "GLP1RA" 3 "Insulin" 4 "TZD" 5 "Other"
capture rename subgroup Subgroup
label values Subgroup subgroupcats
capture label drop periodcats
label define periodcats 1 "Index to last" 2 "Index to last continuous" 3 "Index to switch/add" 4 "Index or later exposure" 
capture rename period Period
label values Period periodcats
metan hr ll ul, force by(Subgroup) nowt nobox nooverall nosubgroup null(1) scheme(s1mono) xlabel(0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10) lcols(Period) effect("Hazard Ratio") saving(SensGrph, asis replace)
*/

//SECONDARY OUTCOMES
//FIGURE 4: Results of primary and secondary outcomes for second line users of DPP4i versus SU.  
//ACM
use Stat_acm_mi
mi xeq 1: stptime, by(indextype) per(1000)
mi estimate, hr: stcox i.indextype
mi estimate, hr: stcox i.indextype `mvmodel_mi'
//MACE
use Stat_mace_mi
keep if linked_b==1
mi xeq 1: stptime, by(indextype) per(1000)
mi estimate, hr: stcox i.indextype
mi estimate, hr: stcox i.indextype `mvmodel_mi'
//ANGINA
use Stat_angina_mi
mi xeq 1: stptime, by(indextype) per(1000)
mi estimate, hr: stcox i.indextype
mi estimate, hr: stcox i.indextype `mvmodel_mi'
//ARRHYTHMIA
use Stat_arrhyth_mi
mi xeq 1: stptime, by(indextype) per(1000)
mi estimate, hr: stcox i.indextype
mi estimate, hr: stcox i.indextype `mvmodel_mi'
//HF
use Stat_hf_mi
mi xeq 1: stptime, by(indextype) per(1000)
mi estimate, hr: stcox i.indextype
mi estimate, hr: stcox i.indextype `mvmodel_mi'
//MI
use Stat_myoinf_mi
mi xeq 1: stptime, by(indextype) per(1000)
mi estimate, hr: stcox i.indextype
mi estimate, hr: stcox i.indextype `mvmodel_mi'
//REVASC
use Stat_revasc_mi
mi xeq 1: stptime, by(indextype) per(1000)
mi estimate, hr: stcox i.indextype
mi estimate, hr: stcox i.indextype `mvmodel_mi'
//STROKE
use Stat_stroke_mi
mi xeq 1: stptime, by(indextype) per(1000)
mi estimate, hr: stcox i.indextype
mi estimate, hr: stcox i.indextype `mvmodel_mi'
//CVDEATH
use Stat_cvdeath_mi
keep if linked_b==1
mi xeq 1: stptime, by(indextype) per(1000)
mi estimate, hr: stcox i.indextype
mi estimate, hr: stcox i.indextype `mvmodel_mi'
/*
Comparative Plots
use alloutcomes, clear
capture label drop outcomes
label define outcomes 1 "ACM" 2 "MACE" 3 "Angina" 4 "Arrhythmia" 5 "Heart Failure" 6 "Myocardial Infarction" 7 "Urgent Revasc" 8 "Stroke" 9 "CV Death"
capture rename outcome Outcome
label values Outcome outcomes
capture label drop adjustments
label define adjustments 0 "Unadjusted" 1 "Adjusted"
capture rename adj Model
label values Model adjustments
metan hr ll ul, force by(Outcome) nowt nobox nooverall nosubgroup null(1) scheme(s1mono) xlabel(0, 1, 2, 3) lcols(Model) effect("Hazard Ratio") saving(alloutcomes, asis replace)*/
