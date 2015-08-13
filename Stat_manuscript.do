//  program:    Stat_manuscript.do
//  task:		Manuscript numbers generation
//  project: 	Incretins--Comparative mortality and CV outcomes (CPRD)
//  author:     JM \ July 2015  

use Analytic_Dataset_Master
do Data13_variable_generation
keep if exclude==0&seconddate>17167

//Create macros
//mvmodel includes: demo, comorb2, meds and clin
local mvmodel = "age_indexdate gender ib2.smokestatus ib1.hba1c_cats_i2 i.ckd_amdrd bmi_i sbp i.physician_vis2 i.prx_ccivalue_g_i2 cvd_i dmdur metoverlap i.unique_cov_drugs statin_i calchan_i betablock_i anticoag_oral_i antiplat_i ace_arb_renin_i diuretics_all_i su_post dpp4i_post glp1ra_post ins_post tzd_post oth_post"
local matrownames "SU DPP4I GLP1RA INS TZD OTH Age Male Unknown Current Non_Smoker Former HbA1c_<7 HbA1c_7_8 HbA1c_8_9 HbA1c_9_10 HbA1c_>10 HbA1c_unknown eGFR_90+ eGFR_60_89 eGFR_30_59 eGFR_15_29 eGFR_<15 eGFR_unknown BMI SBP PhysVis_12 PhysVis_24 PhysVis_24plus CCI=1 CCI=2 CCI=3+ CVD diabetes_duration Metformin_overlap No_unique_drugs_0_5 No_unique_drugs_6_10 No_unique_drugs_11_15 No_unique_drugs_16_20 No_unique_drugs_>20 Statin CCB BB Anticoag Antiplat RAS Diuretics su_post dpp4i_post glp1ra_post ins_post tzd_post oth_post"
//mvmodel_mi includes: demoMI, comorb2 meds2, clinMI (only differences between mvmodel and mvmodel_mi are the imputed variables and removal of *_post for collinearity)
local mvmodel_mi = "age_indexdate gender ib2.smokestatus_clone ib1.hba1c_cats_i2_clone i.ckd_amdrd bmi_i sbp i.physician_vis2 i.prx_ccivalue_g_i2 cvd_i dmdur metoverlap i.unique_cov_drugs statin_i calchan_i betablock_i anticoag_oral_i antiplat_i ace_arb_renin_i diuretics_all_i"
local matrownames_mi "SU DPP4I GLP1RA INS TZD OTH Age Male Unknown Current Non_Smoker Former HbA1c_<7 HbA1c_7_8 HbA1c_8_9 HbA1c_9_10 HbA1c_>10 HbA1c_unknown eGFR_90+ eGFR_60_89 eGFR_30_59 eGFR_15_29 eGFR_<15 eGFR_unknown BMI SBP PhysVis_12 PhysVis_24 PhysVis_24plus CCI=1 CCI=2 CCI=3+ CVD diabetes_duration Metformin_overlap No_unique_drugs_0_5 No_unique_drugs_6_10 No_unique_drugs_11_15 No_unique_drugs_16_20 No_unique_drugs_>20 Statin CCB BB Anticoag Antiplat RAS Diuretics"

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
//TABLE 1: BASELINE CHARACTERISTICS (from table1.xlsx)
//FIGURE 1: PATIENT FLOW (from draw.io)
//SUPPLEMENT TABLE S1: LINKED BASELINE CHARACTERISTICS (from table1_linked.xlsx)
//SUPPLEMENT FIGURE S1: LINKED PATIENT FLOW (from draw.io)

//ACM WRITTEN SECTION NUMBERS
use acm, clear
//Numbers for flow diagrams
tab firstadmrx
tab gest_diab
tab pcos
tab preg
count if age_indexdate<30
tab cohort_b
count if tx<=seconddate
count if seconddate<17167
count if seconddate>=17167 & cohort_b==1 & exclude==0

//Create table1 
table1, by(indextype) vars(age_indexdate contn \ age_cat cat \ gender cat \ imd2010_5 cat \ dmdur contn \ metoverlap contn \ prx_covvalue_g_i4 cat \ prx_covvalue_g_i5 cat \ bmi_i_cats cat \ physician_vis2 cat \ ang_i bin \ arr_i bin \ afib_i bin \ hf_i bin \ htn_i bin \ mi_i bin \ pvd_i bin \ stroke_i bin \ revasc_i bin \ prx_ccivalue_g_i2 cat \ hba1c_i contn \ hba1c_cats_i cat \ prx_covvalue_g_i3 contn \ sbp_i_cats2 cat \ egfr_amdrd contn \ ckd_amdrd cat \ unique_cov_drugs cat \ unqrx2 cat \ statin_i bin \ calchan_i bin \ betablock_i bin \ anticoag_oral_i bin \ antiplat_i bin \ ace_arb_renin_i bin \ diuretics_all_i bin) onecol format(%9.2g) saving(table1.xls, replace)
table1 if linked_b==1, by(indextype) vars(age_indexdate contn \ age_cat cat \ gender cat \ imd2010_5 cat \ dmdur contn \ metoverlap contn \ prx_covvalue_g_i4 cat \ prx_covvalue_g_i5 cat \ bmi_i_cats cat \ physician_vis2 cat \ ang_i bin \ arr_i bin \ afib_i bin \ hf_i bin \ htn_i bin \ mi_i bin \ pvd_i bin \ stroke_i bin \ revasc_i bin \ prx_ccivalue_g_i2 cat \ hba1c_i contn \ hba1c_cats_i cat \ prx_covvalue_g_i3 contn \ sbp_i_cats2 cat \ egfr_amdrd contn \ ckd_amdrd cat \ unique_cov_drugs cat \ unqrx2 cat \ statin_i bin \ calchan_i bin \ betablock_i bin \ anticoag_oral_i bin \ antiplat_i bin \ ace_arb_renin_i bin \ diuretics_all_i bin) onecol format(%9.2g) saving(table1_linked.xls, replace)

// 2x2 tables with exposure and outcome (death)
label var indextype "2nd-line Agent"
tab indextype acm, row

label var indextype3 "3rd-line Agent"
tab indextype3 acm, row

label var indextype4 "4th-line Agent"
tab indextype4 acm, row
tab indextype5 acm, row
tab indextype6 acm, row
tab indextype7 acm, row

//2x2 tables for each covariate to determine if events are too low to include any of them
foreach var of varlist age_65 gender dmdur_cat ckd_amdrd unique_cov_drugs prx_ccivalue_g_i2 mi_i stroke_i hf_i arr_i ang_i revasc_i htn_i afib_i pvd_i statin_i calchan_i betablock_i anticoag_oral_i antiplat_i ace_arb_renin_i diuretics_all_i bmi_i_cats sbp_i_cats2 hba1c_cats_i2 prx_covvalue_g_i4 {
tab indextype `var', row
}
// 2x2 tables with exposure and death, by baseline covariates
foreach var of varlist gender dmdur_cat prx_covvalue_g_i4 prx_covvalue_g_i5 bmi_i_cats hba1c_cats_i2 sbp_i_cats2 ///
	ckd_amdrd physician_vis2 unique_cov_drugs prx_ccivalue_g_i2 mi_i stroke_i hf_i arr_i ang_i revasc_i ///
	htn_i afib_i pvd_i statin_i calchan_i betablock_i anticoag_oral_i antiplat_i ace_arb_renin_i ///
	diuretics_all_i {

table indextype `var', contents(n acm mean acm) format(%6.2f) center col
	}
	
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

//OVERALL OUTCOMES
//FIGURE 2A: CPRD BASE POPULATION MAIN FINDINGS- ALL OUTCOMES FOR DPP VS SU
//ACM
use Stat_acm_mi
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
//FIGURE 2B: LINKED ONLY POPULATION MAIN FINDINGS- ALL OUTCOMES FOR DPP VS SU  
//MACE
use Stat_mace_mi
keep if linked_b==1
mi xeq 1: stptime, by(indextype) per(1000)
mi estimate, hr: stcox i.indextype
mi estimate, hr: stcox i.indextype `mvmodel_mi'
//CVDEATH
use Stat_cvdeath_mi
keep if linked_b==1
mi xeq 1: stptime, by(indextype) per(1000)
mi estimate, hr: stcox i.indextype
mi estimate, hr: stcox i.indextype `mvmodel_mi'
//MI
use Stat_myoinf_mi
if linked_b==1
mi xeq 1: stptime, by(indextype) per(1000)
mi estimate, hr: stcox i.indextype
mi estimate, hr: stcox i.indextype `mvmodel_mi'
//STROKE
use Stat_stroke_mi
if linked_b==1
mi xeq 1: stptime, by(indextype) per(1000)
mi estimate, hr: stcox i.indextype
mi estimate, hr: stcox i.indextype `mvmodel_mi'
/*
To generate Figures 2A and 2B
use alloutcomes, clear
capture label drop outcomes
label define outcomes 1 "{bf}ACM" 2 "{bf}Angina" 3 "{bf}Arrhythmia" 4 "{bf}Heart Failure" 5 "{bf}Myocardial Infarction" 6 "{bf}Urgent Revascularization" 7 "{bf}Stroke" 8 "{bf}MACE" 9 "{bf}CV Death" 10 "{bf}Myocardial {bf}Infarction" 11 "{bf}Stroke"
capture rename outcome Outcome
label values Outcome outcomes
capture label drop adjustments
label define adjustments 0 "Unadjusted" 1 "Adjusted"
capture rename adj Model
label values Model adjustments
label var Model "{bf}Outcome"
label var fail "{bf}Event"
label var nofail "{bf}No {bf}Event"
metan hr ll ul, force by(Outcome) nowt nobox nooverall null(1) scheme(s1mono) xlabel(0, 1, 2, 3) lcols(Model) effect("Hazard Ratio")
metan hr ll ul if Outcome<=7, force by(Outcome) nowt nobox nooverall nosubgroup null(1) astext(45) scheme(s1mono) xlabel(0, 0.25, 0.5, 0.75, 1.25) lcols(Model) effect("{bf}Hazard {bf}Ratio") saving(Figure2A, asis replace)
metan hr ll ul if Outcome>7, force by(Outcome) nowt nobox nooverall nosubgroup null(1) astext(60) scheme(s1mono) xlabel(0, 0.25, 0.5, 0.75, 1.25) lcols(Model) effect("{bf}Hazard {bf}Ratio") saving(Figure2B, asis replace)
*/

//Generate Table 2: ACM FINDINGS FOR EACH CLASS OF ANTIDIABETIC AGENT
putexcel A1= ("Indextype") B1=("Person-Time") C1=("Failures") D1=("Incidence Rate") E1=("Lower Bound") F1=("Upper Bound") using manuscript_tables, sheet("Table2") modify
forval i=0/5{
local row=`i'+2
mi xeq 1: stptime if indextype==`i', per(1000)
putexcel A`row'= ("`i'") B`row'=(r(ptime)) C`row'=(r(failures)) D`row'=(r(rate)*1000) E`row'=(r(lb)*1000) F`row'=(r(ub)*1000) using manuscript_tables, sheet("Table2") modify
}
mi xeq 1: stptime, per(1000)
putexcel A8= ("total") B8=(r(ptime)) C8=(r(failures)) D8=(r(rate)*1000) E8=(r(lb)*1000) F8=(r(ub)*1000) using manuscript_tables, sheet("Table2") modify

mi estimate, hr: stcox i.indextype `mvmodel_mi'
matrix b=r(table)
matrix c=b'
matrix list c
forval i=1/43{
local x=`i'+9
local rowname:word `i' of `matrownames_mi'
putexcel A9=("Variable") B9=("HR") C9=("SE") D9=("p-value") E9=("LL") F9=("UL") A`x'=("`rowname'") B`x'=(c[`i',1]) C`x'=(c[`i',2]) D`x'=(c[`i',4]) E`x'=(c[`i',5]) F`x'=(c[`i',6]) using manuscript_tables, sheet("Table2") modify
}

//SUPPLEMENT TABLE S2: DPP SUBCLASS RATES
//Generate additional incidence data for subclasses of DPP
use Stat_acm_mi, clear
gen dpptype = .
replace dpptype = 1 if indextype==1&alogliptin==1
replace dpptype = 2 if indextype==1&linagliptin==1
replace dpptype = 3 if indextype==1&sitagliptin==1
replace dpptype = 4 if indextype==1&saxagliptin==1
replace dpptype = 5 if indextype==1&vildagliptin==1
mi xeq 2: stptime, by(dpptype) per(1000)

//SUPPLEMENT FIGURE S3: UNADJUSTED AND ADJUSTED COX PROPORTIONAL HAZARDS REGRESSION ANALYSIS
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
metan hr ll ul, force by(model) nowt nobox nooverall null(1) xlabel(0.25, 0.5, .75, 1.25) astext(70) scheme(s1mono) lcols(Models) effect("Hazard Ratio") saving(MainModelComparison, asis replace)
metan hr ll ul, force by(model) nowt nobox nooverall nosubgroup null(1) xlabel(0.25, 0.5, .75, 1.25) astext(70) scheme(s1mono) lcols(Models) effect("Hazard Ratio") saving(MainModelComparison, asis replace)
*/

//SUPPLEMENT TABLE S3: ACM FOR DPP and GLP VS SU ACROSS VARYING RANGES
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

//SUPPLEMENT FIGURE S2: ACM HRs ACROSS ALL CLASSES (UNADJ VS ADJ)
/*
use ACMoverall, clear
capture label drop classes
capture label drop adjusted
label define classes 0 "{bf}SU" 1 "{bf}DPP4i" 2 "{bf}GLP-1RA" 3 "{bf}Insulin" 4 "{bf}Thiazolidinedione" 5 "{bf}Other {bf}antidiabetic"
label values class classes
label define adjusted 0 "Unadjusted" 1 "Adjusted"
label values adj adjusted
label var class "{bf}Class"
label var fail "{bf}Events"
label var nofail "{bf}No {bf}Events"
label var adj "{bf}Antidiabetic {bf}Class"
metan hr ll ul, force by(class) nowt nobox nooverall null(1) xlabel(0, 0.25, 0.5, 0.75) astext(70) scheme(s1mono) lcols(fail nofail) effect("Hazard Ratio")
metan hr ll ul, force by(class) nowt nobox nooverall nosubgroup null(1) xlabel(0, 2, 3, 4, 5) astext(55) scheme(s1mono) lcols(adj) rcols(fail nofail) effect("Hazard Ratio") saving(ACMoverall, asis replace)
*/

//SUPPLEMENT FIGURE S4: ACM FINDINGS FOR DPP VS ALL REFERENTS
/*
use ACMvariedRefs, clear
capture label drop referents
capture label drop adjusted
label define referents 0 "{bf}SU" 1 "{bf}DPP4i" 2 "{bf}GLP-1RA" 3 "{bf}Insulin" 4 "{bf}Thiazolidinedione" 5 "{bf}Other {bf}antidiabetic"
label values referents referents
label define adjusted 0 "Unadjusted" 1 "Adjusted"
label values adj adjusted
label var referents "{bf}Referent"
label var adj "{bf}Antidiabetic {bf}Class"
metan hr ll ul, force by(referents) nowt nobox nooverall null(1) xlabel(0, 0.25, 0.5, 0.75) astext(70) scheme(s1mono) effect("Hazard Ratio")
metan hr ll ul, force by(referents) nowt nobox nooverall nosubgroup null(1) xlabel(0, 2, 3, 4, 5, 6, 7, 8) astext(45) scheme(s1mono) lcols(adj) effect("Hazard Ratio") saving(ACMvariedRefs, asis replace)
*/

//SUPPLEMENT FIGURE S7: MACE FINDINGS FOR DPP VS ALL REFERENTS
/*
use MACEvariedRefs, clear
capture label drop referents
capture label drop adjusted
label define referents 0 "{bf}SU" 1 "{bf}DPP4i" 2 "{bf}GLP-1RA" 3 "{bf}Insulin" 4 "{bf}Thiazolidinedione" 5 "{bf}Other {bf}antidiabetic"
label values referents referents
label define adjusted 0 "Unadjusted" 1 "Adjusted"
label values adj adjusted
label var referents "{bf}Referent"
label var adj "{bf}Antidiabetic {bf}Class"
metan hr ll ul, force by(referents) nowt nobox nooverall null(1) xlabel(0, 0.25, 0.5, 0.75) astext(70) scheme(s1mono) effect("Hazard Ratio")
metan hr ll ul, force by(referents) nowt nobox nooverall nosubgroup null(1) xlabel(0, 2, 3) astext(45) scheme(s1mono) lcols(adj) effect("Hazard Ratio") saving(MACEvariedRefs, asis replace)
*/


//SUPPLEMENT FIGURE S9: OVERALL MAIN FINDINGS BY AGENT
/*
use OveralFindings, clear
capture label drop agents
capture label drop outcomes
label define agents 0 "{bf}SU" 1 "{bf}DPP4i" 2 "{bf}GLP-1RA" 3 "{bf}Insulin" 4 "{bf}Thiazolidinedione" 5 "{bf}Other {bf}antidiabetic"
label define outcomes 1 "ACM" 2 "MACE"  3 "CV Death" 4 "Angina" 5 "Arrhythmia" 6 "Heart Failure" 7 "Myocardial Infarction"  8 "Stroke" 9 "Urgent Revascularization"
label values agent agents
label values outcome outcomes
metan hr ll ul, force by(agent) nowt nobox nooverall null(1) xlabel(0, 0.25, 0.5, 0.75) astext(70) scheme(s1mono) effect("Hazard Ratio")
metan hr ll ul, force by(agent) nowt nobox nooverall nosubgroup null(1) xlabel(0, 2, 3, 4, 5) astext(25) scheme(s1mono) lcols(outcome) rcols(p) effect("Hazard Ratio") saving(OverallFindingsAgent, asis replace)

//SUPPLEMENT FIGURE S10: BY OUTCOME
capture label drop agents
capture label drop outcomes
label define agents 0 "SU" 1 "DPP4i" 2 "GLP-1RA" 3 "Insulin" 4 "Thiazolidinedione" 5 "Other antidiabetic"
label define outcomes 1 "{bf}ACM" 2 "{bf}MACE"  3 "{bf}CV {bf}Death" 4 "{bf}Angina" 5 "{bf}Arrhythmia" 6 "{bf}Heart {bf}Failure" 7 "{bf}Myocardial {bf}Infarction"  8 "{bf}Stroke" 9 "{bf}Urgent {bf}Revascularization"
label values agent agents
label values outcome outcomes
label var agent "{bf}Outcome"
label var outcome "{bf}Outcome"
label var p "{bf}P-value"
metan hr ll ul, force by(outcome) nowt nobox nooverall null(1) xlabel(0, 0.25, 0.5, 0.75) astext(70) scheme(s1mono) effect("Hazard Ratio")
metan hr ll ul, force by(outcome) nowt nobox nooverall nosubgroup null(1) xlabel(0, 2, 3, 4, 5) astext(25) scheme(s1mono) lcols(agent) rcols(p) effect("Hazard Ratio") saving(OverallFindingsOutcome, asis replace)
metan hr ll ul if outcome==2, force by(outcome) nowt nobox nooverall nosubgroup null(1) xlabel(0, 0.5, 1.5, 2, 2.5) astext(70) scheme(s1mono) lcols(agent) rcols(p) effect("Hazard Ratio") saving(OverallFindingsOutcome, asis replace)
*/


//MACE WRITTEN SECTION NUMBERS: 
// 2x2 tables with exposure and outcome (MACE)
label var indextype "2nd-line Agent"
tab indextype mace, row
label var indextype3 "3rd-line Agent"
tab indextype3 mace, row
label var indextype4 "4th-line Agent"
tab indextype4 mace, row
tab indextype5 mace, row
tab indextype6 mace, row
tab indextype7 mace, row

//2x2 tables for each covariate to determine if events are too low to include any of them
foreach var of varlist age_65 gender dmdur_cat ckd_amdrd unique_cov_drugs prx_ccivalue_g_i2 mi_i stroke_i hf_i arr_i ang_i revasc_i htn_i afib_i pvd_i statin_i calchan_i betablock_i anticoag_oral_i antiplat_i ace_arb_renin_i diuretics_all_i bmi_i_cats sbp_i_cats2 hba1c_cats_i2 prx_covvalue_g_i4 {
tab indextype `var', row
}

// 2x2 tables with exposure and death, by baseline covariates
foreach var of varlist gender dmdur_cat prx_covvalue_g_i4 prx_covvalue_g_i5 bmi_i_cats hba1c_cats_i2 sbp_i_cats2 ///
	ckd_amdrd physician_vis2 unique_cov_drugs prx_ccivalue_g_i2 mi_i stroke_i hf_i arr_i ang_i revasc_i ///
	htn_i afib_i pvd_i statin_i calchan_i betablock_i anticoag_oral_i antiplat_i ace_arb_renin_i ///
	diuretics_all_i {
table indextype `var', contents(n mace mean mace) format(%6.2f) center col
	}

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

//SUPPLEMENT FIGURE S6: MACE MODEL ROBUSTNESS: UNADJUSTED AND ADJUSTED COX PROPORTIONAL HAZARDS REGRESSION ANALYSIS
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
metan hr ll ul, force by(model) nowt nobox nooverall null(1) xlabel(0, 0.25, 0.5, 0.75) astext(70) scheme(s1mono) lcols(Models) effect("Hazard Ratio") saving(MainModelComparison, asis replace)
metan hr ll ul, force by(model) nowt nobox nooverall nosubgroup null(1) xlabel(0, 0.25, 0.5, 0.75, 1.25) astext(70) scheme(s1mono) lcols(Models) effect("Hazard Ratio") saving(MainModelComparison, asis replace)
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

//SUPPLEMENT TABLE S4: MACE FINDINGS FOR DPP and  GLP VS SU ACROSS VARYING RANGES

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


