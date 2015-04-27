//  program:    Stat_acm.do
//  task:		Statistical analysis for all-cause mortality
//  project: 	Incretins--Comparative mortality and CV outcomes (CPRD)
//  author:     JM \April2015  
//				

clear all
capture log close stat_acm
set more off
log using Stat_acm.smcl, name(stat_acm) replace
timer on 1

use Analytic_Dataset_Master
quietly do Data13_variable_generation.do

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

keep if exclude==0 // apply exclusion criteria
drop if seconddate<17167 // restrict to jan 1, 2007

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

// 2x2 tables with exposure and death, by baseline covariates

foreach var of varlist gender dmdur_cat prx_covvalue_g_i4 prx_covvalue_g_i5 bmi_i_cats hba1c_cats_i2 sbp_i_cats2 ///
	ckd_amdrd physician_vis2 unique_cov_drugs prx_ccivalue_g_i2 mi_i stroke_i hf_i arr_i ang_i revasc_i ///
	htn_i afib_i pvd_i statin_i calchan_i betablock_i anticoag_oral_i antiplat_i ace_arb_renin_i ///
	diuretics_all_i {

table indextype `var', contents(n acm mean acm) format(%6.2f) center col
	}
	
***COX PROPORTIONAL HAZARDS REGRESSION***

// update censor times for final exposure to second-line agent (indextype)

forval i=0/5 {
	replace acm_exit = exposuretf`i' if indextype==`i' & exposuretf`i'!=.
}

// declare survival analysis - final exposure as last exposure date 
stset acm_exit, fail(allcausemort) id(patid) origin(seconddate) scale(365.25)

/*
*test of linearity assumption between continuous variables and mortality
preserve
*age
tabstat age_index, stat(min p25 p50 p75 max) col(stat) save
matrix list r(StatTotal)
* midpoints 41.5 57.5 66.5 87.5

recode age_index (min/53=0) (53/62=1) (62/71=2) (71/max=3), gen(age_index_cat)
xi:stcox i.age_index_cat, nohr
*plot beta coeff. vs. midpoints via twoway (connected var2 var1)

clear 
input midpt coef
41.5 0
57.5 0.77242433
66.5 1.3821627
87.5 2.500502
end

twoway (connected coef midpt), saving(age_death, replace) 
graph export age_death.pdf, replace
*age meets linear assumption, therefore keep as continuous variable in model

restore
lowess acm age_index, saving(age_death_lowess, replace) 
graph export age_death_lowess.pdf, replace

preserve
*A1c
tabstat hba1c_i2, stat(min p25 p50 p75 max) col(stat) save
matrix list r(StatTotal)
* midpoints 5.1 8.3 8.95 16.95

recode hba1c_i2 (min/7.6=0) (7.6/8.29=1) (8.26/9.6=2) (9.6/max=3), gen(hba1c_i2_cat)
xi:stcox i.hba1c_i2_cat, nohr
*plot beta coeff. vs. midpoints via twoway (connected var2 var1)
clear 
input midpt coef
5.1 0
8.3 -0.6190842
8.95 -0.5559712
16.95 -0.4787484
end

twoway (connected coef midpt), saving(a1c_death, replace) 
graph export a1c_death.pdf, replace

* A1c is not linear ... therefore express as a categorical variable

restore
lowess acm hba1c_i2, saving(a1c_death_lowess, replace) 
graph export a1c_death_lowess.pdf, replace

preserve
*BMI
tabstat bmi_i, stat(min p25 p50 p75 max) col(stat) save
matrix list r(StatTotal)
* midpoints 21.4 29.6 33.6 60

recode bmi_i (min/21.4=0) (21.4/29.6=1) (29.6/33.6=2) (33.6/max=3), gen(bmi_i_cat)
xi:stcox i.bmi_i_cat, nohr
*plot beta coeff. vs. midpoints via twoway (connected var2 var1)
clear 
input midpt coef
21.4 0
29.6 0.77242433
33.6 1.3821627
60 2.500502
end

twoway (connected coef midpt), saving(bmi_death, replace) 
graph export bmi_death.pdf, replace

restore
lowess acm bmi_i, saving(bmi_death_lowess, replace) 
graph export bmi_death_lowess.pdf, replace

preserve
*SBP
tabstat prx_covvalue_g_ai3, stat(min p25 p50 p75 max) col(stat) save
matrix list r(StatTotal)
* midpoints 95.5 129.5 138 186.5

recode prx_covvalue_g_ai3 (min/95.5=0) (95.5/129.5=1) (129.5/138=2) (138/max=3), gen(sbp_i_cat)
xi:stcox i.sbp_i_cat, nohr
*plot beta coeff. vs. midpoints via twoway (connected var2 var1)
clear 
input midpt coef
95.5 0
129.5 0.77242433
138 1.3821627
186.5 2.500502
end

twoway (connected coef midpt), saving(sbp_death, replace) 
graph export sbp_death.pdf, replace

restore
lowess acm prx_covvalue_g_ai3, saving(sbp_death_lowess, replace) 
graph export sbp_death_lowess.pdf, replace
*/

// spit data to integrate time-varying covariates for diabetes meds.

stsplit adm3, after(thirddate) at(0)
*stsplit adm3, at(0(1)max) after(thirddate)
gen su_post=(indextype3==0 & adm3!=-1)
gen dpp4i_post=(indextype3==1 & adm3!=-1)
gen glp1ra_post=(indextype3==2 & adm3!=-1)
gen ins_post=(indextype3==3  & adm3!=-1)
gen tzd_post=(indextype3==4 & adm3!=-1)
gen oth_post=(indextype3==5  & adm3!=-1)

stsplit adm4, after(fourthdate) at(0)
*stsplit adm4, at(0(1)max) after(fourthdate)
replace su_post=1 if indextype4==0 & adm4!=-1
replace dpp4i_post=1 if indextype4==1 & adm4!=-1
replace glp1ra_post=1 if indextype4==2 & adm4!=-1
replace ins_post=1 if indextype4==3 & adm4!=-1
replace tzd_post=1 if indextype4==4 & adm4!=-1
replace oth_post=1 if indextype4==5 & adm4!=-1

stsplit adm5, after(fifthdate) at(0) 
*stsplit adm5, at(0(1)max) after(fifthdate)
replace su_post=1 if indextype5==0 & adm5!=-1
replace dpp4i_post=1 if indextype5==1 & adm5!=-1
replace glp1ra_post=1 if indextype5==2 & adm5!=-1
replace ins_post=1 if indextype5==3 & adm5!=-1
replace tzd_post=1 if indextype5==4 & adm5!=-1
replace oth_post=1 if indextype5==5 & adm5!=-1

stsplit adm6, after(sixthdate) at(0)
*stsplit adm6, at(0(1)max) after(sixthdate)
replace su_post=1 if indextype6==0 & adm6!=-1
replace dpp4i_post=1 if indextype6==1 & adm6!=-1
replace glp1ra_post=1 if indextype6==2 & adm6!=-1
replace ins_post=1 if indextype6==3 & adm6!=-1
replace tzd_post=1 if indextype6==4 & adm6!=-1
replace oth_post=1 if indextype6==5 & adm6!=-1

stsplit adm7, after(seventhdate) at(0)
*stsplit adm7, at(0(1)max) after(seventhdate)
replace su_post=1 if indextype7==0 & adm7!=-1
replace dpp4i_post=1 if indextype7==1 & adm7!=-1
replace glp1ra_post=1 if indextype7==2 & adm7!=-1
replace ins_post=1 if indextype7==3 & adm7!=-1
replace tzd_post=1 if indextype7==4 & adm7!=-1
replace oth_post=1 if indextype7==5 & adm7!=-1

stsplit stop0, after(exposuretf0) at(0)
*stsplit stop0, at(0(1)max) after(exposuretf0)
replace su_post=0 if su_post==1 & stop0!=-1

stsplit stop1, after(exposuretf1) at(0)
*stsplit stop1, at(0(1)max) after(exposuretf1)
replace dpp4i_post=0 if dpp4i_post==1 & stop1!=-1

stsplit stop2, after(exposuretf2) at(0)
*stsplit stop2, at(0(1)max) after(exposuretf2)
replace glp1ra_post=0 if glp1ra_post==1 & stop2!=-1

stsplit stop3, after(exposuretf3) at(0)
*stsplit stop3, at(0(1)max) after(exposuretf3)
replace ins_post=0 if ins_post==1 & stop3!=-1

stsplit stop4, after(exposuretf4) at(0)
*stsplit stop4, at(0(1)max) after(exposuretf4)
replace tzd_post=0 if tzd_post==1 & stop4!=-1

stsplit stop5, after(exposuretf5) at(0)
*stsplit stop5, at(0(1)max) after(exposuretf5)
replace oth_post=0 if oth_post==1 & stop5!=-1

//Generate person-years, incidence rate, and 95%CI as well as hazard ratio
label var indextype "Exposure"
stptime, by(indextype) per(1000)
stcox i.indextype, cformat(%6.2f) pformat(%5.3f) sformat(%6.2f) 
stcox indextype_2 indextype_3 indextype_4 indextype_5 indextype_6, cformat(%6.2f) pformat(%5.3f) sformat(%6.2f) 
 
stptime, title(person-years) per(1000)
putexcel A1= ("Indextype") B1=("Person-Time") C1=("Failures") D1=("Incidence Rate") E1=("Lower Bound") F1=("Upper Bound") G1=("Hazard Ratio") H1=("Lower Bound") I1=("Upper Bound") using table2, sheet("Unadjusted") modify
forval i=0/5{
local row=`i'+2
stptime if indextype==`i'
putexcel A`row'= ("`i'") B`row'=(r(ptime)) C`row'=(r(failures)) D`row'=(r(rate)*1000) E`row'=(r(lb)*1000) F`row'=(r(ub)*1000) using table2, sheet("Unadjusted") modify
}
forval i=1/5 {
local row=`i'+2
local matrow=`i'+1
stcox i.indextype 
matrix b=r(table)
matrix a= b'
putexcel G`row'=(a[`matrow',1]) H`row'=(a[`matrow',5]) I`row'=(a[`matrow',6]) using table2, sheet("Unadjusted") modify
}

//Multivariable analysis 
// note: missing indicator approach used
stcox i.indextype age_index gender dmdur, cformat(%6.2f) pformat(%5.3f) sformat(%6.2f) 
stcox i.indextype age_indexdate gender dmdur metoverlap ib1.hba1c_cats_i2 ib1.sbp_i_cats2 i.ckd_amdrd i.physician_vis2 i.unique_cov_drugs, cformat(%6.2f) pformat(%5.3f) sformat(%6.2f)  

stcox i.indextype age_indexdate gender dmdur metoverlap ib2.prx_covvalue_g_i4 ib2.prx_covvalue_g_i5 ib1.hba1c_cats_i2 ib1.sbp_i_cats2 i.ckd_amdrd i.physician_vis2 i.unique_cov_drugs i.prx_ccivalue_g_i2 mi_i stroke_i hf_i arr_i ang_i revasc_i htn_i afib_i pvd_i ib1.bmi_i_cats statin_i calchan_i betablock_i anticoag_oral_i antiplat_i ace_arb_renin_i diuretics_all_i *_post, cformat(%6.2f) pformat(%5.3f) sformat(%6.2f)  
stcox indextype_2 indextype_3 indextype_4 indextype_5 indextype_6 age_indexdate gender dmdur metoverlap ib2.prx_covvalue_g_i4 ib2.prx_covvalue_g_i5 ib1.hba1c_cats_i2 ib1.sbp_i_cats2 i.ckd_amdrd i.physician_vis2 i.unique_cov_drugs i.prx_ccivalue_g_i2 mi_i stroke_i hf_i arr_i ang_i revasc_i htn_i afib_i pvd_i ib1.bmi_i_cats statin_i calchan_i betablock_i anticoag_oral_i antiplat_i ace_arb_renin_i diuretics_all_i *_post, cformat(%6.2f) pformat(%5.3f) sformat(%6.2f)  
stcox indextype_2 indextype_3 indextype_4 indextype_5 indextype_6 age_indexdate gender dmdur metoverlap bmicat1 bmicat3 bmicat4 bmicat5 bmicat6 bmicat7 smokestatus1 smokestatus2 smokestatus4 drinkstatus1 drinkstatus2 drinkstatus4 a1ccat1 a1ccat3 a1ccat4 a1ccat5 a1ccat6 sbpcat1 sbpcat3 sbpcat4 sbpcat5 sbpcat6 sbpcat7 ckdcat2 ckdcat3 ckdcat4 ckdcat5 ckdcat6 mdvisits2 mdvisits3 mdvisits4 ndrugs2 ndrugs3 ndrugs4 ndrugs5 cci2 cci3 mi_i stroke_i hf_i arr_i ang_i revasc_i htn_i afib_i pvd_i statin_i calchan_i betablock_i anticoag_oral_i antiplat_i ace_arb_renin_i diuretics_all_i *_post, cformat(%6.2f) pformat(%5.3f) sformat(%6.2f)  

// change reference groups
stcox ib2.indextype age_indexdate gender dmdur metoverlap ib2.prx_covvalue_g_i4 ib2.prx_covvalue_g_i5 ib1.hba1c_cats_i2 ib1.sbp_i_cats2 i.ckd_amdrd i.physician_vis2 i.unique_cov_drugs i.prx_ccivalue_g_i2 mi_i stroke_i hf_i arr_i ang_i revasc_i htn_i afib_i pvd_i ib1.bmi_i_cats statin_i calchan_i betablock_i anticoag_oral_i antiplat_i ace_arb_renin_i diuretics_all_i *_post, cformat(%6.2f) pformat(%5.3f) sformat(%6.2f)  
stcox ib3.indextype age_indexdate gender dmdur metoverlap ib2.prx_covvalue_g_i4 ib2.prx_covvalue_g_i5 ib1.hba1c_cats_i2 ib1.sbp_i_cats2 i.ckd_amdrd i.physician_vis2 i.unique_cov_drugs i.prx_ccivalue_g_i2 mi_i stroke_i hf_i arr_i ang_i revasc_i htn_i afib_i pvd_i ib1.bmi_i_cats statin_i calchan_i betablock_i anticoag_oral_i antiplat_i ace_arb_renin_i diuretics_all_i *_post, cformat(%6.2f) pformat(%5.3f) sformat(%6.2f)  
stcox ib4.indextype age_indexdate gender dmdur metoverlap ib2.prx_covvalue_g_i4 ib2.prx_covvalue_g_i5 ib1.hba1c_cats_i2 ib1.sbp_i_cats2 i.ckd_amdrd i.physician_vis2 i.unique_cov_drugs i.prx_ccivalue_g_i2 mi_i stroke_i hf_i arr_i ang_i revasc_i htn_i afib_i pvd_i ib1.bmi_i_cats statin_i calchan_i betablock_i anticoag_oral_i antiplat_i ace_arb_renin_i diuretics_all_i *_post, cformat(%6.2f) pformat(%5.3f) sformat(%6.2f)  

stcox i.indextype age_indexdate gender dmdur metoverlap ib2.prx_covvalue_g_i4 ib2.prx_covvalue_g_i5 ib1.bmi_i_cats ib1.hba1c_cats_i2 ib1.sbp_i_cats2 i.ckd_amdrd i.physician_vis2 i.unique_cov_drugs i.prx_ccivalue_g_i2 mi_i stroke_i hf_i arr_i ang_i revasc_i htn_i afib_i pvd_i statin_i calchan_i betablock_i anticoag_oral_i antiplat_i ace_arb_renin_i diuretics_all_i *_post, cformat(%6.2f) pformat(%5.3f) sformat(%6.2f)  
matrix b=r(table)
matrix c=b'
matrix list c
*matrix rownames c = SU DPP4I GLP1RA INS TZD OTH Age Male su_post dpp4i_post glp1ra_post tzd_post oth_post diabetes_duration HbA1c_<7 HbA1c_7_8 HbA1c_8_9 HbA1c_9_10 HbA1c_>10 HbA1c_unknown SBP_<120 SBP_130_139  SBP_140_149 SBP_150_159 SBP_160+ SBP_missing eGFR_90+ eGFR_60_89 eGFR_30_59 eGFR_15_29 eGFR_unknown Physician_visits_0_12  Physician_visits_13_24 Physician_visits_24+ Physician_visits_unknown No_unique_drugs_0_5 No_unique_drugs_6_10 No_unique_drugs_11_15 No_unique_drugs_16_20 No_unique_drugs_>20 Non_Smoker Unknown Current Former CCI=1 CCI=2 CCI=3+ MI Stroke HF Arrythmia Angina Revascularization HTN AFIB PVD Statin CCB BB Anticoag Antiplat RAS Diuretics
local matrownames "SU DPP4I GLP1RA INS TZD OTH Age Male diabetes_duration Metformin_overlap Unknown Current Non_Smoker Former Unknown Current Non_Drinker Former BMI_<20 BMI_20_24 BMI_25_29 BMI_30_34 BMI_35_40 BMI_40+ Unknown HbA1c_<7 HbA1c_7_8 HbA1c_8_9 HbA1c_9_10 HbA1c_>10 HbA1c_unknown SBP_<120 SBP_120_129 SBP_130_139  SBP_140_149 SBP_150_159 SBP_160+ SBP_missing eGFR_90+ eGFR_60_89 eGFR_30_59 eGFR_15_29 eGFR_<15 eGFR_unknown Physician_visits_0_12 Physician_visits_13_24 Physician_visits_24+ Physician_visits_unknown No_unique_drugs_0_5 No_unique_drugs_6_10 No_unique_drugs_11_15 No_unique_drugs_16_20 No_unique_drugs_>20 CCI=1 CCI=2 CCI=3+ MI Stroke HF Arrythmia Angina Revascularization HTN AFIB PVD Statin CCB BB Anticoag Antiplat RAS Diuretics su_post dpp4i_post glp1ra_post ins_post tzd_post oth_post"
forval i=1/79{
local x=`i'+1
local rowname:word `i' of `matrownames'
putexcel A1=("Variable") B1=("HR") C1=("SE") D1=("p-value") E1=("LL") F1=("UL") A`x'=("`rowname'") B`x'=(c[`i',1]) C`x'=(c[`i',2]) D`x'=(c[`i',4]) E`x'=(c[`i',5]) F`x'=(c[`i',6])using table2, sheet("Adjusted") modify
}

// Multiple imputation

mi set mlong
mi register imputed bmi_i sbp
set seed 1979
mi impute mvn bmi_i sbp = acm age_index gender, add(10)
mi estimate, hr: stcox i.indextype age_index gender dmdur metoverlap bmi_i sbp

//KM and survival curves
sts graph, by(indextype) saving(kmplot, replace) 
graph export kmplot.pdf, replace

stcurve, survival at1(indextype=0) at2(indextype=1) at3(indextype=2) at4(indextype=3) at5(indextype=4) at6(indextype=5) saving(survplot, replace) 
graph export survplot.pdf, replace

//Testing PH Assumption
stphplot, by(indextype) saving(lnlnplot, replace)
graph export lnlnplot.pdf, replace

stcox indextype_2 indextype_3 indextype_4 indextype_5 indextype_6 age_indexdate gender dmdur metoverlap bmicat1 bmicat3 bmicat4 bmicat5 bmicat6 bmicat7 smokestatus1 smokestatus2 smokestatus4 drinkstatus1 drinkstatus2 drinkstatus4 a1ccat1 a1ccat3 a1ccat4 a1ccat5 a1ccat6 sbpcat1 sbpcat3 sbpcat4 sbpcat5 sbpcat6 sbpcat7 ckdcat2 ckdcat3 ckdcat4 ckdcat5 ckdcat6 mdvisits2 mdvisits3 mdvisits4 ndrugs2 ndrugs3 ndrugs4 ndrugs5 cci2 cci3 mi_i stroke_i hf_i arr_i ang_i revasc_i htn_i afib_i pvd_i statin_i calchan_i betablock_i anticoag_oral_i antiplat_i ace_arb_renin_i diuretics_all_i *_post, cformat(%6.2f) pformat(%5.3f) sformat(%6.2f)  nolog noshow
estat phtest, rank detail

/*
estat phtest, log plot(indextype_2) yline(0) saving(lnlnplot, replace) 
stphplot, strata(indextype_4) adjust(age_indexdate gender dmdur) nolntime
stcox indextype_4, nohr nolog noshow tvc(indextype_4) texp( ln(_t) )
stphplot if indextype==1 | indextype==0 | indextype==2, by(indextype)
stphplot, by(indextype)
stphplot if indextype==1 | indextype==0 | indextype==2, by(indextype) nolntime
stphplot if indextype==1 | indextype==0 | indextype==2, strata(indextype) adjust(age_indexdate gender dmdur metoverlap  i.prx_covvalue_g_i4 ib2.prx_covvalue_g_i5 ib1.hba1c_cats_i2 ib1.sbp_i_cats2 i.ckd_amdrd i.physician_vis2 i.unique_cov_drugs i.prx_ccivalue_g_i2 mi_i stroke_i hf_i arr_i ang_i revasc_i htn_i afib_i pvd_i ib1.bmi_i_cats statin_i calchan_i betablock_i anticoag_oral_i antiplat_i ace_arb_renin_i diuretics_all_i *_post) nolntime
stcoxkm, by(indextype_3)
stcoxkm if indextype==1 | indextype==0 | indextype==2, by(indextype)
*/

// Testing collinearity

collin indextype_2 indextype_3 indextype_4 indextype_5 indextype_6 age_indexdate gender dmdur metoverlap bmicat1 bmicat3 bmicat4 bmicat5 bmicat6 bmicat7 smokestatus1 smokestatus2 smokestatus4 drinkstatus1 drinkstatus2 drinkstatus4 a1ccat1 a1ccat3 a1ccat4 a1ccat5 a1ccat6 sbpcat1 sbpcat3 sbpcat4 sbpcat5 sbpcat6 sbpcat7 ckdcat2 ckdcat3 ckdcat4 ckdcat5 ckdcat6 mdvisits2 mdvisits3 mdvisits4 ndrugs2 ndrugs3 ndrugs4 ndrugs5 cci2 cci3 mi_i stroke_i hf_i arr_i ang_i revasc_i htn_i afib_i pvd_i statin_i calchan_i betablock_i anticoag_oral_i antiplat_i ace_arb_renin_i diuretics_all_i *_post

***SUBGROUP ANALYSIS / EFFECT MODIFIERS***

// Age

stcox i.indextype if age_65==0, cformat(%6.2f) pformat(%5.3f) sformat(%6.2f) nolog noshow
stcox i.indextype if age_65==1, cformat(%6.2f) pformat(%5.3f) sformat(%6.2f) nolog noshow
stcox i.indextype##i.age_65, cformat(%6.2f) pformat(%5.3f) sformat(%6.2f) nolog noshow
stcox i.indextype##c.age_index, cformat(%6.2f) pformat(%5.3f) sformat(%6.2f) nolog noshow

stcox i.indextype age_indexdate gender dmdur metoverlap ib2.prx_covvalue_g_i4 ib2.prx_covvalue_g_i5 ib1.hba1c_cats_i2 ib1.sbp_i_cats2 i.ckd_amdrd i.physician_vis2 i.unique_cov_drugs i.prx_ccivalue_g_i2 mi_i stroke_i hf_i arr_i ang_i revasc_i htn_i afib_i pvd_i ib1.bmi_i_cats statin_i calchan_i betablock_i anticoag_oral_i antiplat_i ace_arb_renin_i diuretics_all_i *_post if age_65==0, cformat(%6.2f) pformat(%5.3f) sformat(%6.2f)  
stcox i.indextype age_indexdate gender dmdur metoverlap ib2.prx_covvalue_g_i4 ib2.prx_covvalue_g_i5 ib1.hba1c_cats_i2 ib1.sbp_i_cats2 i.ckd_amdrd i.physician_vis2 i.unique_cov_drugs i.prx_ccivalue_g_i2 mi_i stroke_i hf_i arr_i ang_i revasc_i htn_i afib_i pvd_i ib1.bmi_i_cats statin_i calchan_i betablock_i anticoag_oral_i antiplat_i ace_arb_renin_i diuretics_all_i *_post if age_65==1, cformat(%6.2f) pformat(%5.3f) sformat(%6.2f)  
stcox i.indextype##i.age_65 gender dmdur metoverlap ib2.prx_covvalue_g_i4 ib2.prx_covvalue_g_i5 ib1.hba1c_cats_i2 ib1.sbp_i_cats2 i.ckd_amdrd i.physician_vis2 i.unique_cov_drugs i.prx_ccivalue_g_i2 mi_i stroke_i hf_i arr_i ang_i revasc_i htn_i afib_i pvd_i ib1.bmi_i_cats statin_i calchan_i betablock_i anticoag_oral_i antiplat_i ace_arb_renin_i diuretics_all_i *_post, cformat(%6.2f) pformat(%5.3f) sformat(%6.2f)  
stcox i.indextype##c.age_indexdate gender dmdur metoverlap ib2.prx_covvalue_g_i4 ib2.prx_covvalue_g_i5 ib1.hba1c_cats_i2 ib1.sbp_i_cats2 i.ckd_amdrd i.physician_vis2 i.unique_cov_drugs i.prx_ccivalue_g_i2 mi_i stroke_i hf_i arr_i ang_i revasc_i htn_i afib_i pvd_i ib1.bmi_i_cats statin_i calchan_i betablock_i anticoag_oral_i antiplat_i ace_arb_renin_i diuretics_all_i *_post, cformat(%6.2f) pformat(%5.3f) sformat(%6.2f)  

// Sex

stcox i.indextype if gender==0, cformat(%6.2f) pformat(%5.3f) sformat(%6.2f) nolog noshow
stcox i.indextype if gender==1, cformat(%6.2f) pformat(%5.3f) sformat(%6.2f) nolog noshow
stcox i.indextype##i.gender, cformat(%6.2f) pformat(%5.3f) sformat(%6.2f) nolog noshow

stcox i.indextype age_index dmdur metoverlap ib2.prx_covvalue_g_i4 ib2.prx_covvalue_g_i5 ib1.hba1c_cats_i2 ib1.sbp_i_cats2 i.ckd_amdrd i.physician_vis2 i.unique_cov_drugs i.prx_ccivalue_g_i2 mi_i stroke_i hf_i arr_i ang_i revasc_i htn_i afib_i pvd_i ib1.bmi_i_cats statin_i calchan_i betablock_i anticoag_oral_i antiplat_i ace_arb_renin_i diuretics_all_i *_post if gender==0, cformat(%6.2f) pformat(%5.3f) sformat(%6.2f)  
stcox i.indextype age_index dmdur  metoverlap ib2.prx_covvalue_g_i4 ib2.prx_covvalue_g_i5 ib1.hba1c_cats_i2 ib1.sbp_i_cats2 i.ckd_amdrd i.physician_vis2 i.unique_cov_drugs i.prx_ccivalue_g_i2 mi_i stroke_i hf_i arr_i ang_i revasc_i htn_i afib_i pvd_i ib1.bmi_i_cats statin_i calchan_i betablock_i anticoag_oral_i antiplat_i ace_arb_renin_i diuretics_all_i *_post if gender==1, cformat(%6.2f) pformat(%5.3f) sformat(%6.2f)  
stcox i.indextype##i.gender age_index dmdur metoverlap ib2.prx_covvalue_g_i4 ib2.prx_covvalue_g_i5 ib1.hba1c_cats_i2 ib1.sbp_i_cats2 i.ckd_amdrd i.physician_vis2 i.unique_cov_drugs i.prx_ccivalue_g_i2 mi_i stroke_i hf_i arr_i ang_i revasc_i htn_i afib_i pvd_i ib1.bmi_i_cats statin_i calchan_i betablock_i anticoag_oral_i antiplat_i ace_arb_renin_i diuretics_all_i *_post, cformat(%6.2f) pformat(%5.3f) sformat(%6.2f)  

// Duration of Metformin Monotherapy

stcox i.indextype if dmdur_2==0, cformat(%6.2f) pformat(%5.3f) sformat(%6.2f) nolog noshow
stcox i.indextype if dmdur_2==1, cformat(%6.2f) pformat(%5.3f) sformat(%6.2f) nolog noshow
stcox i.indextype##c.dmdur, cformat(%6.2f) pformat(%5.3f) sformat(%6.2f) nolog noshow

stcox i.indextype##c.dmdur age_indexdate gender metoverlap ib2.prx_covvalue_g_i4 ib2.prx_covvalue_g_i5 ib1.hba1c_cats_i2 ib1.sbp_i_cats2 i.ckd_amdrd i.physician_vis2 i.unique_cov_drugs i.prx_ccivalue_g_i2 mi_i stroke_i hf_i arr_i ang_i revasc_i htn_i afib_i pvd_i ib1.bmi_i_cats statin_i calchan_i betablock_i anticoag_oral_i antiplat_i ace_arb_renin_i diuretics_all_i *_post, cformat(%6.2f) pformat(%5.3f) sformat(%6.2f)  

// HbA1c
stcox i.indextype if hba1c_i2>8, cformat(%6.2f) pformat(%5.3f) sformat(%6.2f) nolog noshow
stcox i.indextype if hba1c_i2<=8, cformat(%6.2f) pformat(%5.3f) sformat(%6.2f) nolog noshow
stcox i.indextype##c.hba1c_i2, cformat(%6.2f) pformat(%5.3f) sformat(%6.2f) nolog noshow

stcox i.indextype##ib2.hba1c_cats_i2 age_indexdate gender dmdur metoverlap ib2.prx_covvalue_g_i4 ib2.prx_covvalue_g_i5 ib1.sbp_i_cats2 i.ckd_amdrd i.physician_vis2 i.unique_cov_drugs i.prx_ccivalue_g_i2 mi_i stroke_i hf_i arr_i ang_i revasc_i htn_i afib_i pvd_i ib1.bmi_i_cats statin_i calchan_i betablock_i anticoag_oral_i antiplat_i ace_arb_renin_i diuretics_all_i *_post, cformat(%6.2f) pformat(%5.3f) sformat(%6.2f)  
stcox i.indextype##c.hba1c_i age_indexdate gender dmdur  metoverlap ib2.prx_covvalue_g_i4 ib2.prx_covvalue_g_i5 ib1.sbp_i_cats2 i.ckd_amdrd i.physician_vis2 i.unique_cov_drugs i.prx_ccivalue_g_i2 mi_i stroke_i hf_i arr_i ang_i revasc_i htn_i afib_i pvd_i ib1.bmi_i_cats statin_i calchan_i betablock_i anticoag_oral_i antiplat_i ace_arb_renin_i diuretics_all_i *_post, cformat(%6.2f) pformat(%5.3f) sformat(%6.2f)  

// BMI
stcox i.indextype if bmi_30==0, cformat(%6.2f) pformat(%5.3f) sformat(%6.2f) nolog noshow
stcox i.indextype if bmi_30==1, cformat(%6.2f) pformat(%5.3f) sformat(%6.2f) nolog noshow
stcox i.indextype##i.bmi_30, cformat(%6.2f) pformat(%5.3f) sformat(%6.2f) nolog noshow

stcox i.indextype##ib1.bmi_i_cats age_indexdate gender dmdur metoverlap ib2.prx_covvalue_g_i4 ib2.prx_covvalue_g_i5 ib2.hba1c_cats_i2 ib1.sbp_i_cats2 i.ckd_amdrd i.physician_vis2 i.unique_cov_drugs i.prx_ccivalue_g_i2 mi_i stroke_i hf_i arr_i ang_i revasc_i htn_i afib_i pvd_i  statin_i calchan_i betablock_i anticoag_oral_i antiplat_i ace_arb_renin_i diuretics_all_i *_post, cformat(%6.2f) pformat(%5.3f) sformat(%6.2f)  
stcox i.indextype##c.bmi_i age_indexdate gender dmdur metoverlap ib2.prx_covvalue_g_i4 ib2.prx_covvalue_g_i5 ib2.hba1c_cats_i2 ib1.sbp_i_cats2 i.ckd_amdrd i.physician_vis2 i.unique_cov_drugs i.prx_ccivalue_g_i2 mi_i stroke_i hf_i arr_i ang_i revasc_i htn_i afib_i pvd_i  statin_i calchan_i betablock_i anticoag_oral_i antiplat_i ace_arb_renin_i diuretics_all_i *_post, cformat(%6.2f) pformat(%5.3f) sformat(%6.2f)  
stcox i.indextype##i.bmi_30 age_indexdate gender dmdur metoverlap ib2.prx_covvalue_g_i4 ib2.prx_covvalue_g_i5 ib2.hba1c_cats_i2 ib1.sbp_i_cats2 i.ckd_amdrd i.physician_vis2 i.unique_cov_drugs i.prx_ccivalue_g_i2 mi_i stroke_i hf_i arr_i ang_i revasc_i htn_i afib_i pvd_i  statin_i calchan_i betablock_i anticoag_oral_i antiplat_i ace_arb_renin_i diuretics_all_i *_post, cformat(%6.2f) pformat(%5.3f) sformat(%6.2f)  


// IMD
* too many missing values in CPRD cohort

// renal impairment

stcox i.indextype if ckd_60==0, cformat(%6.2f) pformat(%5.3f) sformat(%6.2f) nolog noshow
stcox i.indextype if ckd_60==1, cformat(%6.2f) pformat(%5.3f) sformat(%6.2f) nolog noshow
stcox i.indextype##i.ckd_60, cformat(%6.2f) pformat(%5.3f) sformat(%6.2f) nolog noshow

stcox i.indextype##i.ckd_60 age_indexdate gender dmdur metoverlap ib2.prx_covvalue_g_i4 ib2.prx_covvalue_g_i5 ib2.hba1c_cats_i2 ib1.sbp_i_cats2 i.physician_vis2 i.unique_cov_drugs i.prx_ccivalue_g_i2 mi_i stroke_i hf_i arr_i ang_i revasc_i htn_i afib_i pvd_i  statin_i calchan_i betablock_i anticoag_oral_i antiplat_i ace_arb_renin_i diuretics_all_i *_post, cformat(%6.2f) pformat(%5.3f) sformat(%6.2f)  
stcox i.indextype##c.egfr_amdrd age_indexdate gender dmdur metoverlap ib2.prx_covvalue_g_i4 ib2.prx_covvalue_g_i5 ib2.hba1c_cats_i2 ib1.sbp_i_cats2 i.physician_vis2 i.unique_cov_drugs i.prx_ccivalue_g_i2 mi_i stroke_i hf_i arr_i ang_i revasc_i htn_i afib_i pvd_i  statin_i calchan_i betablock_i anticoag_oral_i antiplat_i ace_arb_renin_i diuretics_all_i *_post, cformat(%6.2f) pformat(%5.3f) sformat(%6.2f)  

// heart failure

stcox i.indextype if hf_i==0, cformat(%6.2f) pformat(%5.3f) sformat(%6.2f) nolog noshow
stcox i.indextype if hf_i==1, cformat(%6.2f) pformat(%5.3f) sformat(%6.2f) nolog noshow
stcox i.indextype##i.hf_i, cformat(%6.2f) pformat(%5.3f) sformat(%6.2f) nolog noshow

stcox i.indextype##i.hf_i age_indexdate gender dmdur metoverlap ib2.prx_covvalue_g_i4 ib2.prx_covvalue_g_i5 ib2.hba1c_cats_i2 ib1.sbp_i_cats2 i.ckd_amdrd i.physician_vis2 i.unique_cov_drugs i.prx_ccivalue_g_i2 mi_i stroke_i arr_i ang_i revasc_i htn_i afib_i pvd_i  statin_i calchan_i betablock_i anticoag_oral_i antiplat_i ace_arb_renin_i diuretics_all_i *_post, cformat(%6.2f) pformat(%5.3f) sformat(%6.2f)  

// prior mi or stroke

stcox i.indextype if mi_stroke==0, cformat(%6.2f) pformat(%5.3f) sformat(%6.2f) nolog noshow
stcox i.indextype if mi_stroke==1, cformat(%6.2f) pformat(%5.3f) sformat(%6.2f) nolog noshow
stcox i.indextype##i.mi_stroke, cformat(%6.2f) pformat(%5.3f) sformat(%6.2f) nolog noshow

stcox i.indextype##i.mi_stroke age_indexdate gender dmdur metoverlap ib2.prx_covvalue_g_i4 ib2.prx_covvalue_g_i5 ib2.hba1c_cats_i2 ib1.sbp_i_cats2 i.ckd_amdrd i.physician_vis2 i.unique_cov_drugs i.prx_ccivalue_g_i2 hf_i arr_i ang_i revasc_i htn_i afib_i pvd_i  statin_i calchan_i betablock_i anticoag_oral_i antiplat_i ace_arb_renin_i diuretics_all_i *_post, cformat(%6.2f) pformat(%5.3f) sformat(%6.2f)  


***SENSITIVITY ANALYSIS***

// #1. CENSOR EXPSOURE AT FIRST GAP
use Analytic_Dataset_Master, clear
do Data13_variable_generation.do
keep if exclude==0 // apply exclusion criteria
drop if seconddate<17167 // restrict to jan 1, 2007

// update censor times for last continuous exposure to second-line agent (indextype)

forval i=0/5 {
	replace acm_exit = exposuret1`i' if indextype==`i' & exposuret1`i'!=.
}

// declare survival analysis - last continuous exposure as last exposure date 
stset acm_exit, fail(allcausemort) id(patid) origin(seconddate) scale(365.35)
// spit data to integrate time-varying covariates for diabetes meds.

stsplit adm3, after(thirddate) at(0)
*stsplit adm3, at(0(1)max) after(thirddate)
gen su_post=(indextype3==0 & adm3!=-1)
gen dpp4i_post=(indextype3==1 & adm3!=-1)
gen glp1ra_post=(indextype3==2 & adm3!=-1)
gen ins_post=(indextype3==3  & adm3!=-1)
gen tzd_post=(indextype3==4 & adm3!=-1)
gen oth_post=(indextype3==5  & adm3!=-1)

stsplit adm4, after(fourthdate) at(0)
*stsplit adm4, at(0(1)max) after(fourthdate)
replace su_post=1 if indextype4==0 & adm4!=-1
replace dpp4i_post=1 if indextype4==1 & adm4!=-1
replace glp1ra_post=1 if indextype4==2 & adm4!=-1
replace ins_post=1 if indextype4==3 & adm4!=-1
replace tzd_post=1 if indextype4==4 & adm4!=-1
replace oth_post=1 if indextype4==5 & adm4!=-1

stsplit adm5, after(fifthdate) at(0)
*stsplit adm5, at(0(1)max) after(fifthdate)
replace su_post=1 if indextype5==0 & adm5!=-1
replace dpp4i_post=1 if indextype5==1 & adm5!=-1
replace glp1ra_post=1 if indextype5==2 & adm5!=-1
replace ins_post=1 if indextype5==3 & adm5!=-1
replace tzd_post=1 if indextype5==4 & adm5!=-1
replace oth_post=1 if indextype5==5 & adm5!=-1

stsplit adm6, after(sixthdate) at(0)
*stsplit adm6, at(0(1)max) after(sixthdate)
replace su_post=1 if indextype6==0 & adm6!=-1
replace dpp4i_post=1 if indextype6==1 & adm6!=-1
replace glp1ra_post=1 if indextype6==2 & adm6!=-1
replace ins_post=1 if indextype6==3 & adm6!=-1
replace tzd_post=1 if indextype6==4 & adm6!=-1
replace oth_post=1 if indextype6==5 & adm6!=-1

stsplit adm7, after(seventhdate) at(0)
*stsplit adm7, at(0(1)max) after(seventhdate)
replace su_post=1 if indextype7==0 & adm7!=-1
replace dpp4i_post=1 if indextype7==1 & adm7!=-1
replace glp1ra_post=1 if indextype7==2 & adm7!=-1
replace ins_post=1 if indextype7==3 & adm7!=-1
replace tzd_post=1 if indextype7==4 & adm7!=-1
replace oth_post=1 if indextype7==5 & adm7!=-1

stsplit stop0, after(exposuretf0) at(0)
*stsplit stop0, at(0(1)max) after(exposuretf0)
replace su_post=0 if su_post==1 & stop0!=-1

stsplit stop1, after(exposuretf1) at(0)
*stsplit stop1, at(0(1)max) after(exposuretf1)
replace dpp4i_post=0 if dpp4i_post==1 & stop1!=-1

stsplit stop2, after(exposuretf2) at(0)
*stsplit stop2, at(0(1)max) after(exposuretf2)
replace glp1ra_post=0 if glp1ra_post==1 & stop2!=-1

stsplit stop3, after(exposuretf3) at(0)
*stsplit stop3, at(0(1)max) after(exposuretf3)
replace ins_post=0 if ins_post==1 & stop3!=-1

stsplit stop4, after(exposuretf4) at(0)
*stsplit stop4, at(0(1)max) after(exposuretf4)
replace tzd_post=0 if tzd_post==1 & stop4!=-1

stsplit stop5, after(exposuretf5) at(0)
*stsplit stop5, at(0(1)max) after(exposuretf5)
replace oth_post=0 if oth_post==1 & stop5!=-1

//Generate person-years, incidence rate, and 95%CI as well as hazard ratio
label var indextype "Exposure"
stptime, by(indextype) per(1000)
stcox i.indextype, cformat(%6.2f) pformat(%5.3f) sformat(%6.2f) 

stptime, title(person-years) per(1000)
putexcel A1= ("Indextype") B1=("Person-Time") C1=("Failures") D1=("Incidence Rate") E1=("Lower Bound") F1=("Upper Bound") G1=("Hazard Ratio") H1=("Lower Bound") I1=("Upper Bound") using table2, sheet("Unadjusted2") modify
forval i=0/5{
local row=`i'+2
stptime if indextype==`i'
putexcel A`row'= ("`i'") B`row'=(r(ptime)) C`row'=(r(failures)) D`row'=(r(rate)*1000) E`row'=(r(lb)*1000) F`row'=(r(ub)*1000) using table2, sheet("Unadjusted2") modify
}
forval i=1/5 {
local row=`i'+2
local matrow=`i'+1
stcox i.indextype 
matrix b=r(table)
matrix a= b'
putexcel G`row'=(a[`matrow',1]) H`row'=(a[`matrow',5]) I`row'=(a[`matrow',6]) using table2, sheet("Unadjusted2") modify
}

//Multivariable analysis 
stcox i.indextype age_indexdate gender dmdur metoverlap ib2.prx_covvalue_g_i4 ib2.prx_covvalue_g_i5 ib1.bmi_i_cats ib1.hba1c_cats_i2 ib1.sbp_i_cats2 i.ckd_amdrd i.physician_vis2 i.unique_cov_drugs i.prx_ccivalue_g_i2 mi_i stroke_i hf_i arr_i ang_i revasc_i htn_i afib_i pvd_i statin_i calchan_i betablock_i anticoag_oral_i antiplat_i ace_arb_renin_i diuretics_all_i *_post, cformat(%6.2f) pformat(%5.3f) sformat(%6.2f)  
matrix b=r(table)
matrix c=b'
matrix list c
*matrix rownames c = SU DPP4I GLP1RA INS TZD OTH Age Male su_post dpp4i_post glp1ra_post tzd_post oth_post diabetes_duration HbA1c_<7 HbA1c_7_8 HbA1c_8_9 HbA1c_9_10 HbA1c_>10 HbA1c_unknown SBP_<120 SBP_130_139  SBP_140_149 SBP_150_159 SBP_160+ SBP_missing eGFR_90+ eGFR_60_89 eGFR_30_59 eGFR_15_29 eGFR_unknown Physician_visits_0_12  Physician_visits_13_24 Physician_visits_24+ Physician_visits_unknown No_unique_drugs_0_5 No_unique_drugs_6_10 No_unique_drugs_11_15 No_unique_drugs_16_20 No_unique_drugs_>20 Non_Smoker Unknown Current Former CCI=1 CCI=2 CCI=3+ MI Stroke HF Arrythmia Angina Revascularization HTN AFIB PVD Statin CCB BB Anticoag Antiplat RAS Diuretics
local matrownames "SU DPP4I GLP1RA INS TZD OTH Age Male diabetes_duration Metformin_overlap Unknown Current Non_Smoker Former Unknown Current Non_Drinker Former BMI_<20 BMI_20_24 BMI_25_29 BMI_30_34 BMI_35_40 BMI_40+ Unknown HbA1c_<7 HbA1c_7_8 HbA1c_8_9 HbA1c_9_10 HbA1c_>10 HbA1c_unknown SBP_<120 SBP_120_129 SBP_130_139  SBP_140_149 SBP_150_159 SBP_160+ SBP_missing eGFR_90+ eGFR_60_89 eGFR_30_59 eGFR_15_29 eGFR_<15 eGFR_unknown Physician_visits_0_12 Physician_visits_13_24 Physician_visits_24+ Physician_visits_unknown No_unique_drugs_0_5 No_unique_drugs_6_10 No_unique_drugs_11_15 No_unique_drugs_16_20 No_unique_drugs_>20 CCI=1 CCI=2 CCI=3+ MI Stroke HF Arrythmia Angina Revascularization HTN AFIB PVD Statin CCB BB Anticoag Antiplat RAS Diuretics su_post dpp4i_post glp1ra_post ins_post tzd_post oth_post"
forval i=1/79{
local x=`i'+1
local rowname:word `i' of `matrownames'
putexcel A1=("Variable") B1=("HR") C1=("SE") D1=("p-value") E1=("LL") F1=("UL") A`x'=("`rowname'") B`x'=(c[`i',1]) C`x'=(c[`i',2]) D`x'=(c[`i',4]) E`x'=(c[`i',5]) F`x'=(c[`i',6])using table2, sheet("Adjusted2") modify
}

// Multiple imputation


// #2 Third-line therapy
use Analytic_Dataset_Master, clear
do Data13_variable_generation.do
keep if exclude==0 // apply exclusion criteria
drop if seconddate<17167 // restrict to jan 1, 2007

// update censor times for final exposure to third-line agent (indextype3)

forval i=0/5 {
	replace acm_exit = exposuretf`i' if indextype3==`i' & exposuretf`i'!=.
}

// declare survival analysis - final exposure as last exposure date 
stset acm_exit, fail(allcausemort) id(patid) origin(thirddate) scale(365.25)

// spit data to integrate time-varying covariates for diabetes meds.

stsplit adm4, at(0) after(fourthdate)
*stsplit adm4, at(0(1)max) after(fourthdate)
gen su_post=(indextype4==0 & adm4!=-1)
gen dpp4i_post=(indextype4==1 & adm4!=-1)
gen glp1ra_post=(indextype4==2 & adm4!=-1)
gen ins_post=(indextype4==3 & adm4!=-1)
gen tzd_post=(indextype4==4 & adm4!=-1)
gen oth_post=(indextype4==5 & adm4!=-1)

stsplit adm5, at(0) after(fifthdate)
*stsplit adm5, at(0(1)max) after(fifthdate)
replace su_post=1 if indextype5==0 & adm5!=-1
replace dpp4i_post=1 if indextype5==1 & adm5!=-1
replace glp1ra_post=1 if indextype5==2 & adm5!=-1
replace ins_post=1 if indextype5==3 & adm5!=-1
replace tzd_post=1 if indextype5==4 & adm5!=-1
replace oth_post=1 if indextype5==5 & adm5!=-1

stsplit adm6, at(0) after(sixthdate)
*stsplit adm6, at(0(1)max) after(sixthdate)
replace su_post=1 if indextype6==0 & adm6!=-1
replace dpp4i_post=1 if indextype6==1 & adm6!=-1
replace glp1ra_post=1 if indextype6==2 & adm6!=-1
replace ins_post=1 if indextype6==3 & adm6!=-1
replace tzd_post=1 if indextype6==4 & adm6!=-1
replace oth_post=1 if indextype6==5 & adm6!=-1

stsplit adm7, at(0) after(seventhdate)
*stsplit adm7, at(0(1)max) after(seventhdate)
replace su_post=1 if indextype7==0 & adm7!=-1
replace dpp4i_post=1 if indextype7==1 & adm7!=-1
replace glp1ra_post=1 if indextype7==2 & adm7!=-1
replace ins_post=1 if indextype7==3 & adm7!=-1
replace tzd_post=1 if indextype7==4 & adm7!=-1
replace oth_post=1 if indextype7==5 & adm7!=-1

stsplit stop0, after(exposuretf0) at(0)
*stsplit stop0, at(0(1)max) after(exposuretf0)
replace su_post=0 if su_post==1 & stop0!=-1

stsplit stop1, after(exposuretf1) at(0)
*stsplit stop1, at(0(1)max) after(exposuretf1)
replace dpp4i_post=0 if dpp4i_post==1 & stop1!=-1

stsplit stop2, after(exposuretf2) at(0)
*stsplit stop2, at(0(1)max) after(exposuretf2)
replace glp1ra_post=0 if glp1ra_post==1 & stop2!=-1

stsplit stop3, after(exposuretf3) at(0)
*stsplit stop3, at(0(1)max) after(exposuretf3)
replace ins_post=0 if ins_post==1 & stop3!=-1

stsplit stop4, after(exposuretf4) at(0)
*stsplit stop4, at(0(1)max) after(exposuretf4)
replace tzd_post=0 if tzd_post==1 & stop4!=-1

stsplit stop5, after(exposuretf5) at(0)
*stsplit stop5, at(0(1)max) after(exposuretf5)
replace oth_post=0 if oth_post==1 & stop5!=-1

//Generate person-years, incidence rate, and 95%CI as well as hazard ratio
label var indextype "Exposure"
stptime, by(indextype3) per(1000)
stcox i.indextype3, cformat(%6.2f) pformat(%5.3f) sformat(%6.2f) 

stptime, title(person-years) per(1000)
putexcel A1= ("Indextype") B1=("Person-Time") C1=("Failures") D1=("Incidence Rate") E1=("Lower Bound") F1=("Upper Bound") G1=("Hazard Ratio") H1=("Lower Bound") I1=("Upper Bound") using table2, sheet("Unadjusted3") modify
forval i=0/5{
local row=`i'+2
stptime if indextype3==`i'
putexcel A`row'= ("`i'") B`row'=(r(ptime)) C`row'=(r(failures)) D`row'=(r(rate)*1000) E`row'=(r(lb)*1000) F`row'=(r(ub)*1000) using table2, sheet("Unadjusted3") modify
}
forval i=1/5 {
local row=`i'+2
local matrow=`i'+1
stcox i.indextype3 
matrix b=r(table)
matrix a= b'
putexcel G`row'=(a[`matrow',1]) H`row'=(a[`matrow',5]) I`row'=(a[`matrow',6]) using table2, sheet("Unadjusted3") modify
}


//Multivariable analysis 
// note: missing indicator approach used

stcox i.indextype3 age_indexdate gender dmdur metoverlap ib2.prx_covvalue_g_i4 ib2.prx_covvalue_g_i5 ib1.bmi_i_cats ib1.hba1c_cats_i2 ib1.sbp_i_cats2 i.ckd_amdrd i.physician_vis2 i.unique_cov_drugs i.prx_ccivalue_g_i2 mi_i stroke_i hf_i arr_i ang_i revasc_i htn_i afib_i pvd_i statin_i calchan_i betablock_i anticoag_oral_i antiplat_i ace_arb_renin_i diuretics_all_i *_post, cformat(%6.2f) pformat(%5.3f) sformat(%6.2f)  
matrix b=r(table)
matrix c=b'
matrix list c
*matrix rownames c = SU DPP4I GLP1RA INS TZD OTH Age Male su_post dpp4i_post glp1ra_post tzd_post oth_post diabetes_duration HbA1c_<7 HbA1c_7_8 HbA1c_8_9 HbA1c_9_10 HbA1c_>10 HbA1c_unknown SBP_<120 SBP_130_139  SBP_140_149 SBP_150_159 SBP_160+ SBP_missing eGFR_90+ eGFR_60_89 eGFR_30_59 eGFR_15_29 eGFR_unknown Physician_visits_0_12  Physician_visits_13_24 Physician_visits_24+ Physician_visits_unknown No_unique_drugs_0_5 No_unique_drugs_6_10 No_unique_drugs_11_15 No_unique_drugs_16_20 No_unique_drugs_>20 Non_Smoker Unknown Current Former CCI=1 CCI=2 CCI=3+ MI Stroke HF Arrythmia Angina Revascularization HTN AFIB PVD Statin CCB BB Anticoag Antiplat RAS Diuretics
local matrownames "SU DPP4I GLP1RA INS TZD OTH Age Male diabetes_duration Metformin_overlap Unknown Current Non_Smoker Former Unknown Current Non_Drinker Former BMI_<20 BMI_20_24 BMI_25_29 BMI_30_34 BMI_35_40 BMI_40+ Unknown HbA1c_<7 HbA1c_7_8 HbA1c_8_9 HbA1c_9_10 HbA1c_>10 HbA1c_unknown SBP_<120 SBP_120_129 SBP_130_139  SBP_140_149 SBP_150_159 SBP_160+ SBP_missing eGFR_90+ eGFR_60_89 eGFR_30_59 eGFR_15_29 eGFR_<15 eGFR_unknown Physician_visits_0_12 Physician_visits_13_24 Physician_visits_24+ Physician_visits_unknown No_unique_drugs_0_5 No_unique_drugs_6_10 No_unique_drugs_11_15 No_unique_drugs_16_20 No_unique_drugs_>20 CCI=1 CCI=2 CCI=3+ MI Stroke HF Arrythmia Angina Revascularization HTN AFIB PVD Statin CCB BB Anticoag Antiplat RAS Diuretics su_post dpp4i_post glp1ra_post ins_post tzd_post oth_post"
forval i=1/79{
local x=`i'+1
local rowname:word `i' of `matrownames'
putexcel A1=("Variable") B1=("HR") C1=("SE") D1=("p-value") E1=("LL") F1=("UL") A`x'=("`rowname'") B`x'=(c[`i',1]) C`x'=(c[`i',2]) D`x'=(c[`i',4]) E`x'=(c[`i',5]) F`x'=(c[`i',6])using table2, sheet("Adjusted3") modify
}

// Multiple imputation


// #3 Fourth-line Therapy
use Analytic_Dataset_Master, clear
do Data13_variable_generation.do
keep if exclude==0 // apply exclusion criteria
drop if seconddate<17167 // restrict to jan 1, 2007

// update censor times for final exposure to fourth-line agent (indextype4)

forval i=0/5 {
	replace acm_exit = exposuretf`i' if indextype4==`i' & exposuretf`i'!=.
}

// declare survival analysis - final exposure as last exposure date 
stset acm_exit, fail(allcausemort) id(patid) origin(fourthdate) scale(365.25)

// spit data to integrate time-varying covariates for diabetes meds.

stsplit adm5, at(0) after(fifthdate)
*stsplit adm5, at(0(1)max) after(fifthdate)
gen su_post=(indextype5==0 & adm5!=-1)
gen dpp4i_post=(indextype5==1 & adm5!=-1)
gen glp1ra_post=(indextype5==2 & adm5!=-1)
gen ins_post=(indextype5==3 & adm5!=-1)
gen tzd_post=(indextype5==4 & adm5!=-1)
gen oth_post=(indextype5==5 & adm5!=-1)

stsplit adm6, at(0) after(sixthdate)
*stsplit adm6, at(0(1)max) after(sixthdate)
replace su_post=1 if indextype6==0 & adm6!=-1
replace dpp4i_post=1 if indextype6==1 & adm6!=-1
replace glp1ra_post=1 if indextype6==2 & adm6!=-1
replace ins_post=1 if indextype6==3 & adm6!=-1
replace tzd_post=1 if indextype6==4 & adm6!=-1
replace oth_post=1 if indextype6==5 & adm6!=-1

stsplit adm7, at(0) after(seventhdate)
*stsplit adm7, at(0(1)max) after(seventhdate)
replace su_post=1 if indextype7==0 & adm7!=-1
replace dpp4i_post=1 if indextype7==1 & adm7!=-1
replace glp1ra_post=1 if indextype7==2 & adm7!=-1
replace ins_post=1 if indextype7==3 & adm7!=-1
replace tzd_post=1 if indextype7==4 & adm7!=-1
replace oth_post=1 if indextype7==5 & adm7!=-1

stsplit stop0, after(exposuretf0) at(0)
*stsplit stop0, at(0(1)max) after(exposuretf0)
replace su_post=0 if su_post==1 & stop0!=-1

stsplit stop1, after(exposuretf1) at(0)
*stsplit stop1, at(0(1)max) after(exposuretf1)
replace dpp4i_post=0 if dpp4i_post==1 & stop1!=-1

stsplit stop2, after(exposuretf2) at(0)
*stsplit stop2, at(0(1)max) after(exposuretf2)
replace glp1ra_post=0 if glp1ra_post==1 & stop2!=-1

stsplit stop3, after(exposuretf3) at(0)
*stsplit stop3, at(0(1)max) after(exposuretf3)
replace ins_post=0 if ins_post==1 & stop3!=-1

stsplit stop4, after(exposuretf4) at(0)
*stsplit stop4, at(0(1)max) after(exposuretf4)
replace tzd_post=0 if tzd_post==1 & stop4!=-1

stsplit stop5, after(exposuretf5) at(0)
*stsplit stop5, at(0(1)max) after(exposuretf5)
replace oth_post=0 if oth_post==1 & stop5!=-1

//Generate person-years, incidence rate, and 95%CI as well as hazard ratio
label var indextype "Exposure"
stptime, by(indextype4) per(1000)
stcox i.indextype4, cformat(%6.2f) pformat(%5.3f) sformat(%6.2f) 

stptime, title(person-years) per(1000)
putexcel A1= ("Indextype") B1=("Person-Time") C1=("Failures") D1=("Incidence Rate") E1=("Lower Bound") F1=("Upper Bound") G1=("Hazard Ratio") H1=("Lower Bound") I1=("Upper Bound") using table2, sheet("Unadjusted4") modify
forval i=0/5{
local row=`i'+2
stptime if indextype4==`i'
putexcel A`row'= ("`i'") B`row'=(r(ptime)) C`row'=(r(failures)) D`row'=(r(rate)*1000) E`row'=(r(lb)*1000) F`row'=(r(ub)*1000) using table2, sheet("Unadjusted4") modify
}
forval i=1/5 {
local row=`i'+2
local matrow=`i'+1
stcox i.indextype4 
matrix b=r(table)
matrix a= b'
putexcel G`row'=(a[`matrow',1]) H`row'=(a[`matrow',5]) I`row'=(a[`matrow',6]) using table2, sheet("Unadjusted4") modify
}

//Multivariable analysis 
// note: missing indicator approach used

stcox i.indextype4 age_indexdate gender dmdur metoverlap ib2.prx_covvalue_g_i4 ib2.prx_covvalue_g_i5 ib1.bmi_i_cats ib1.hba1c_cats_i2 ib1.sbp_i_cats2 i.ckd_amdrd i.physician_vis2 i.unique_cov_drugs i.prx_ccivalue_g_i2 mi_i stroke_i hf_i arr_i ang_i revasc_i htn_i afib_i pvd_i statin_i calchan_i betablock_i anticoag_oral_i antiplat_i ace_arb_renin_i diuretics_all_i *_post, cformat(%6.2f) pformat(%5.3f) sformat(%6.2f)  
matrix b=r(table)
matrix c=b'
matrix list c
*matrix rownames c = SU DPP4I GLP1RA INS TZD OTH Age Male su_post dpp4i_post glp1ra_post tzd_post oth_post diabetes_duration HbA1c_<7 HbA1c_7_8 HbA1c_8_9 HbA1c_9_10 HbA1c_>10 HbA1c_unknown SBP_<120 SBP_130_139  SBP_140_149 SBP_150_159 SBP_160+ SBP_missing eGFR_90+ eGFR_60_89 eGFR_30_59 eGFR_15_29 eGFR_unknown Physician_visits_0_12  Physician_visits_13_24 Physician_visits_24+ Physician_visits_unknown No_unique_drugs_0_5 No_unique_drugs_6_10 No_unique_drugs_11_15 No_unique_drugs_16_20 No_unique_drugs_>20 Non_Smoker Unknown Current Former CCI=1 CCI=2 CCI=3+ MI Stroke HF Arrythmia Angina Revascularization HTN AFIB PVD Statin CCB BB Anticoag Antiplat RAS Diuretics
local matrownames "SU DPP4I GLP1RA INS TZD OTH Age Male diabetes_duration Metformin_overlap Unknown Current Non_Smoker Former Unknown Current Non_Drinker Former BMI_<20 BMI_20_24 BMI_25_29 BMI_30_34 BMI_35_40 BMI_40+ Unknown HbA1c_<7 HbA1c_7_8 HbA1c_8_9 HbA1c_9_10 HbA1c_>10 HbA1c_unknown SBP_<120 SBP_120_129 SBP_130_139  SBP_140_149 SBP_150_159 SBP_160+ SBP_missing eGFR_90+ eGFR_60_89 eGFR_30_59 eGFR_15_29 eGFR_<15 eGFR_unknown Physician_visits_0_12 Physician_visits_13_24 Physician_visits_24+ Physician_visits_unknown No_unique_drugs_0_5 No_unique_drugs_6_10 No_unique_drugs_11_15 No_unique_drugs_16_20 No_unique_drugs_>20 CCI=1 CCI=2 CCI=3+ MI Stroke HF Arrythmia Angina Revascularization HTN AFIB PVD Statin CCB BB Anticoag Antiplat RAS Diuretics su_post dpp4i_post glp1ra_post ins_post tzd_post oth_post"
forval i=1/79{
local x=`i'+1
local rowname:word `i' of `matrownames'
putexcel A1=("Variable") B1=("HR") C1=("SE") D1=("p-value") E1=("LL") F1=("UL") A`x'=("`rowname'") B`x'=(c[`i',1]) C`x'=(c[`i',2]) D`x'=(c[`i',4]) E`x'=(c[`i',5]) F`x'=(c[`i',6])using table2, sheet("Adjusted4") modify
}

// Multiple imputation

// # 4 Any exposure after metformin monotherapy
use Analytic_Dataset_Master, clear
do Data13_variable_generation.do
keep if exclude==0 // apply exclusion criteria
drop if seconddate<17167 // restrict to jan 1, 2007

// declare survival analysis - final exposure as last exposure date 
stset acm_exit, fail(allcausemort) id(patid) origin(seconddate) scale(365.25)

// spit data to integrate time-varying covariates for diabetes meds.

stsplit adm3, at(0) after(thirddate)
*stsplit adm3, at(0(1)max) after(thirddate)
gen su_post=regexm(thirdadmrx, "SU") & adm3!=-1
gen dpp4i_post=regexm(thirdadmrx, "DPP") & adm3!=-1
gen glp1ra_post=regexm(thirdadmrx, "GLP") & adm3!=-1
gen ins_post=regexm(thirdadmrx, "insulin") & adm3!=-1
gen tzd_post=regexm(thirdadmrx, "TZD") & adm3!=-1
gen oth_post=regexm(thirdadmrx, "other") & adm3!=-1

stsplit adm4, at(0) after(fourthdate)
*stsplit adm4, at(0(1)max) after(fourthdate)
replace su_post=1 if regexm(fourthadmrx, "SU") & adm4!=-1
replace dpp4i_post= 1 if regexm(fourthadmrx, "DPP") & adm4!=-1
replace glp1ra_post=1 if regexm(fourthadmrx, "GLP") & adm4!=-1
replace ins_post=1 if regexm(fourthadmrx, "insulin") & adm4!=-1
replace tzd_post=1 if regexm(fourthadmrx, "TZD") & adm4!=-1
replace oth_post=1 if regexm(fourthadmrx, "other") & adm4!=-1

stsplit adm5, at(0) after(fifthdate)
*stsplit adm5, at(0(1)max) after(fifthdate)
replace su_post=1 if regexm(fifthadmrx, "SU") & adm5!=-1
replace dpp4i_post= 1 if regexm(fifthadmrx, "DPP") & adm5!=-1
replace glp1ra_post=1 if regexm(fifthadmrx, "GLP") & adm5!=-1
replace ins_post=1 if regexm(fifthadmrx, "insulin") & adm5!=-1
replace tzd_post=1 if regexm(fifthadmrx, "TZD") & adm5!=-1
replace oth_post=1 if regexm(fifthadmrx, "other") & adm5!=-1

stsplit adm6, at(0) after(sixthdate)
*stsplit adm6, at(0(1)max) after(sixthdate)
replace su_post=1 if regexm(sixthadmrx, "SU") & adm6!=-1
replace dpp4i_post= 1 if regexm(sixthadmrx, "DPP") & adm6!=-1
replace glp1ra_post=1 if regexm(sixthadmrx, "GLP") & adm6!=-1
replace ins_post=1 if regexm(sixthadmrx, "insulin") & adm6!=-1
replace tzd_post=1 if regexm(sixthadmrx, "TZD") & adm6!=-1
replace oth_post=1 if regexm(sixthadmrx, "other") & adm6!=-1

stsplit adm7, at(0) after(seventhdate)
*stsplit adm7, at(0(1)max) after(seventhdate)
replace su_post=1 if regexm(seventhadmrx, "SU") & adm7!=-1
replace dpp4i_post= 1 if regexm(seventhadmrx, "DPP") & adm7!=-1
replace glp1ra_post=1 if regexm(seventhadmrx, "GLP") & adm7!=-1
replace ins_post=1 if regexm(seventhadmrx, "insulin") & adm7!=-1
replace tzd_post=1 if regexm(seventhadmrx, "TZD") & adm7!=-1
replace oth_post=1 if regexm(seventhadmrx, "other") & adm7!=-1

replace su_post=1 if regexm(secondadmrx, "SU")
replace dpp4i_post=1 if regexm(secondadmrx, "DPP")
replace glp1ra_post=1 if regexm(secondadmrx, "GLP")
replace ins_post=1 if regexm(secondadmrx, "insulin")
replace tzd_post=1 if regexm(secondadmrx, "TZD") 
replace oth_post=1 if regexm(secondadmrx, "other")

//Generate person-years, incidence rate, and 95%CI as well as hazard ratios

foreach var in "su" "dpp4i" "glp1ra" "ins" "tzd" "oth" {
	stptime, by(`var'_post) per(1000)
	stcox `var'_post, cformat(%6.2f) pformat(%5.3f) sformat(%6.2f)
	}
	
stcox *_post age_indexdate gender dmdur metoverlap ib2.prx_covvalue_g_i4 ib2.prx_covvalue_g_i5 ib1.hba1c_cats_i2 ib1.sbp_i_cats2 i.ckd_amdrd i.physician_vis2 i.unique_cov_drugs i.prx_ccivalue_g_i2 i.mi_i i.stroke_i i.hf_i i.arr_i i.ang_i i.revasc_i i.htn_i i.afib_i i.pvd_i ib1.bmi_i_cats i.ckd_amdrd i.statin_i i.calchan_i i.betablock_i i.anticoag_oral_i i.antiplat_i i.ace_arb_renin_i i.diuretics_all_i, cformat(%6.2f) pformat(%5.3f) sformat(%6.2f)  

// any use [time-varying]

stsplit stop0, at(0(1)max) after(exposuretf0)
replace su_post=0 if su_post==1 & stop0!=-1

stsplit stop1, at(0(1)max) after(exposuretf1)
replace dpp4i_post=0 if dpp4i_post==1 & stop1!=-1

stsplit stop2, at(0(1)max) after(exposuretf2)
replace glp1ra_post=0 if glp1ra_post==1 & stop2!=-1

stsplit stop3, at(0(1)max) after(exposuretf3)
replace ins_post=0 if ins_post==1 & stop3!=-1

stsplit stop4, at(0(1)max) after(exposuretf4)
replace tzd_post=0 if tzd_post==1 & stop4!=-1

stsplit stop5, at(0(1)max) after(exposuretf5)
replace oth_post=0 if oth_post==1 & stop5!=-1

//Generate person-years, incidence rate, and 95%CI as well as hazard ratios

foreach var in "su" "dpp4i" "glp1ra" "ins" "tzd" "oth" {
	stptime, by(`var'_post) per(1000)
	stcox `var'_post, cformat(%6.2f) pformat(%5.3f) sformat(%6.2f)
	}
	
stcox *_post age_indexdate gender dmdur metoverlap ib2.prx_covvalue_g_i4 ib2.prx_covvalue_g_i5 ib1.hba1c_cats_i2 ib1.sbp_i_cats2 i.ckd_amdrd i.physician_vis2 i.unique_cov_drugs i.prx_ccivalue_g_i2 i.mi_i i.stroke_i i.hf_i i.arr_i i.ang_i i.revasc_i i.htn_i i.afib_i i.pvd_i ib1.bmi_i_cats i.ckd_amdrd i.statin_i i.calchan_i i.betablock_i i.anticoag_oral_i i.antiplat_i i.ace_arb_renin_i i.diuretics_all_i, cformat(%6.2f) pformat(%5.3f) sformat(%6.2f)  

// Multiple imputation

/*
replace su_post=0 if regexm(secondadmrx, "SU")
replace su_post=0 if regexm(thirdadmrx, "SU")
replace su_post=0 if regexm(fourthadmrx, "SU")
replace su_post=0 if regexm(fifthadmrx, "SU")
replace su_post=0 if regexm(sixthadmrx, "SU")
replace su_post=0 if regexm(seventhadmrx, "SU")
*/

timer off 1
log close stat_acm
