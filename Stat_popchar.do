//  program:    Stat_popchar.do
//  task:		Create outputs for study population characteristics
//  project: 	Incretins--Comparative mortality and CV outcomes (CPRD)
//  author:     JM \ June 2015  
//				

clear all
capture log close stat_popchar
set more off
log using Stat_popchar.smcl, name(stat_popchar) replace
timer on 1

capture ssc install table1
capture net install collin.pkg

use Analytic_Dataset_Master.dta, clear
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
//apply exclusion criteria
keep if exclude==0
//restrict to jan 1, 2007
drop if seconddate<17167

//Create baseline characteristics tables for full cohort and linked cohort
table1, by(indextype) vars(age_indexdate contn \ age_cat cat \ gender cat \ imd2010_5 cat \ dmdur contn \ metoverlap contn \ prx_covvalue_g_i4 cat \ prx_covvalue_g_i5 cat \ bmi_i_cats cat \ physician_vis2 cat \ ang_i bin \ arr_i bin \ afib_i bin \ hf_i bin \ htn_i bin \ mi_i bin \ pvd_i bin \ stroke_i bin \ revasc_i bin \ prx_ccivalue_g_i2 cat \ hba1c_i contn \ hba1c_cats_i cat \ prx_covvalue_g_i3 contn \ sbp_i_cats2 cat \ egfr_amdrd contn \ ckd_amdrd cat \ unique_cov_drugs cat \ unqrx2 cat \ statin_i bin \ calchan_i bin \ betablock_i bin \ anticoag_oral_i bin \ antiplat_i bin \ ace_arb_renin_i bin \ diuretics_all_i bin) onecol format(%9.2g) saving(table1.xls, replace)
table1 if linked_b==1, by(indextype) vars(age_indexdate contn \ age_cat cat \ gender cat \ imd2010_5 cat \ dmdur contn \ metoverlap contn \ prx_covvalue_g_i4 cat \ prx_covvalue_g_i5 cat \ bmi_i_cats cat \ physician_vis2 cat \ ang_i bin \ arr_i bin \ afib_i bin \ hf_i bin \ htn_i bin \ mi_i bin \ pvd_i bin \ stroke_i bin \ revasc_i bin \ prx_ccivalue_g_i2 cat \ hba1c_i contn \ hba1c_cats_i cat \ prx_covvalue_g_i3 contn \ sbp_i_cats2 cat \ egfr_amdrd contn \ ckd_amdrd cat \ unique_cov_drugs cat \ unqrx2 cat \ statin_i bin \ calchan_i bin \ betablock_i bin \ anticoag_oral_i bin \ antiplat_i bin \ ace_arb_renin_i bin \ diuretics_all_i bin) onecol format(%9.2g) saving(table1_linked.xls, replace)

//crude numbers of outcome events
table1, vars(acm cat \ mace cat \ mi cat \ stroke cat \ cvdeath_o cat \ hf cat \ ang cat \ arr cat \ revasc cat)
table1 if linked_b==1, vars(acm cat \ mace cat \ mi cat \ stroke cat \ cvdeath_o cat \ hf cat \ ang cat \ arr cat \ revasc cat)

table1, by(indextype) vars(acm cat \ mace cat \ mi cat \ stroke cat \ cvdeath_o cat \ hf cat \ ang cat \ arr cat \ revasc cat)
table1 if linked_b==1, by(indextype) vars(acm cat \ mace cat \ mi cat \ stroke cat \ cvdeath_o cat \ hf cat \ ang cat \ arr cat \ revasc cat)

table1, by(indextype3) vars(acm cat \ mace cat \ mi cat \ stroke cat \ cvdeath_o cat \ hf cat \ ang cat \ arr cat \ revasc cat)
table1 if linked_b==1, by(indextype3) vars(acm cat \ mace cat \ mi cat \ stroke cat \ cvdeath_o cat \ hf cat \ ang cat \ arr cat \ revasc cat)

replace ever0=0 if ever0==.
table1, by(ever0) vars(acm cat \ mace cat \ mi cat \ stroke cat \ cvdeath_o cat \ hf cat \ ang cat \ arr cat \ revasc cat)
table1 if linked_b==1, by(ever0) vars(acm cat \ mace cat \ mi cat \ stroke cat \ cvdeath_o cat \ hf cat \ ang cat \ arr cat \ revasc cat)

replace ever1=0 if ever1==.
table1, by(ever1) vars(acm cat \ mace cat \ mi cat \ stroke cat \ cvdeath_o cat \ hf cat \ ang cat \ arr cat \ revasc cat)
table1 if linked_b==1, by(ever1) vars(acm cat \ mace cat \ mi cat \ stroke cat \ cvdeath_o cat \ hf cat \ ang cat \ arr cat \ revasc cat)

replace ever2=0 if ever2==.
table1, by(ever2) vars(acm cat \ mace cat \ mi cat \ stroke cat \ cvdeath_o cat \ hf cat \ ang cat \ arr cat \ revasc cat)
table1 if linked_b==1, by(ever2) vars(acm cat \ mace cat \ mi cat \ stroke cat \ cvdeath_o cat \ hf cat \ ang cat \ arr cat \ revasc cat)

replace ever3=0 if ever3==.
table1, by(ever3) vars(acm cat \ mace cat \ mi cat \ stroke cat \ cvdeath_o cat \ hf cat \ ang cat \ arr cat \ revasc cat)
table1 if linked_b==1, by(ever3) vars(acm cat \ mace cat \ mi cat \ stroke cat \ cvdeath_o cat \ hf cat \ ang cat \ arr cat \ revasc cat)

replace ever4=0 if ever4==.
table1, by(ever4) vars(acm cat \ mace cat \ mi cat \ stroke cat \ cvdeath_o cat \ hf cat \ ang cat \ arr cat \ revasc cat)
table1 if linked_b==1, by(ever4) vars(acm cat \ mace cat \ mi cat \ stroke cat \ cvdeath_o cat \ hf cat \ ang cat \ arr cat \ revasc cat)

replace ever5=0 if ever5==.
table1, by(ever5) vars(acm cat \ mace cat \ mi cat \ stroke cat \ cvdeath_o cat \ hf cat \ ang cat \ arr cat \ revasc cat)
table1 if linked_b==1, by(ever5) vars(acm cat \ mace cat \ mi cat \ stroke cat \ cvdeath_o cat \ hf cat \ ang cat \ arr cat \ revasc cat)

replace ever6=0 if ever6==.
table1, by(ever6) vars(acm cat \ mace cat \ mi cat \ stroke cat \ cvdeath_o cat \ hf cat \ ang cat \ arr cat \ revasc cat)
table1 if linked_b==1, by(ever6) vars(acm cat \ mace cat \ mi cat \ stroke cat \ cvdeath_o cat \ hf cat \ ang cat \ arr cat \ revasc cat)

//2x2 tables for each covariate to determine if events are too low to include any of them
foreach var of varlist age_65 gender dmdur_cat ckd_amdrd unique_cov_drugs prx_ccivalue_g_i2 mi_i stroke_i hf_i arr_i ang_i revasc_i htn_i afib_i pvd_i statin_i calchan_i betablock_i anticoag_oral_i antiplat_i ace_arb_renin_i diuretics_all_i bmi_i_cats sbp_i_cats2 hba1c_cats_i2 prx_covvalue_g_i4 {
tab indextype `var', row
}

	

timer off 1
log close Stat_popchar
