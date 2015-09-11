//  program:    Data04_drug_covariates_loop.do
//  task:		Generate a loop through all Therapy files for Data04_drug_covariates
//  project: 	Incretins--Comparative mortality and CV outcomes (CPRD)
//  author:     JM \ Feb2015

clear all
capture log close
set more off

log using Data04.txt, replace
timer clear 1
timer on 1

forval i=0/49 {
	use Therapy_`i', clear
	do Data04_drug_covariates_short.do
	save drug_covariates_`i'.dta, replace
	}
use drug_covariates_0, clear 
forval i=1/49 {		
	append using drug_covariates_`i'
	}
save Drug_Covariates.dta, replace


//Generate window datasets

//Generate indexdate window
use Drug_Covariates.dta
keep patid thiazdiur_i loopdiur_i potsparediur_aldos_i potsparediur_other_i antiarrhythmic_i ///
				betablock_i acei_i angiotensin2recepant_i renini_i ras_i nitrates_i calchan_i anticoag_oral_i antiplat_i statin_i unqrxi
				
collapse (max)  thiazdiur_i loopdiur_i potsparediur_aldos_i potsparediur_other_i antiarrhythmic_i ///
				betablock_i acei_i angiotensin2recepant_i renini_i ras_i nitrates_i calchan_i anticoag_oral_i antiplat_i statin_i unqrxi, by(patid)	


local x="i"			

label variable thiazdiur_`x' "thiazide and related diuretic exposure: 0=no exp, 1=exp"
label variable loopdiur_`x' "loop diuretic exposure: 0=no exp, 1=exp"
label variable potsparediur_aldos_`x' "Potassium-sparing diuretic and aldosterone antagonist exposure: 0=no exp, 1=exp"
label variable potsparediur_other_`x' "Potassium-sparing diuretic with other diuretic exposure: 0=no exp, 1=exp"
label variable antiarrhythmic_`x' "antiarrhythmic exposure: 0=no exp, 1=exp"
label variable betablock_`x' "beta-blocker exposure: 0=no exp, 1=exp"
label variable acei_`x' "ACE inhibitor exposure: 0=no exp, 1=exp"
label variable angiotensin2recepant_`x' "Angiotensin II receptor antagonist exposure: 0=no exp, 1=exp"
label variable renini_`x' "Renin inhibitor exposure: 0=no exp, 1=exp"
label variable nitrates_`x' "nitrates exposure: 0=no exp, 1=exp"
label variable calchan_`x' "calcium channel blocker exposure: 0=no exp, 1=exp"
label variable anticoag_oral_`x' "Oral anticoagulant exposure: 0=no exp, 1=exp"
label variable antiplat_`x' "antiplatelet exposure: 0=no exp, 1=exp"
label variable statin_`x' "statin exposure: 0=no exp, 1=exp"

save Drug_Covariates_i.dta, replace
clear
//Generate studyentrydate window
use Drug_Covariates.dta
keep patid      thiazdiur_s loopdiur_s potsparediur_aldos_s potsparediur_other_s ///
				antiarrhythmic_s betablock_s acei_s angiotensin2recepant_s renini_s ras_s nitrates_s calchan_s anticoag_oral_s antiplat_s statin_s unqrxs

collapse (max) thiazdiur_s loopdiur_s potsparediur_aldos_s potsparediur_other_s ///
				antiarrhythmic_s betablock_s acei_s angiotensin2recepant_s renini_s ras_s nitrates_s calchan_s anticoag_oral_s antiplat_s statin_s unqrxs, by(patid)
				
local x="s"			
label variable thiazdiur_`x' "thiazide and related diuretic exposure: 0=no exp, 1=exp"
label variable loopdiur_`x' "loop diuretic exposure: 0=no exp, 1=exp"
label variable potsparediur_aldos_`x' "Potassium-sparing diuretic and aldosterone antagonist exposure: 0=no exp, 1=exp"
label variable potsparediur_other_`x' "Potassium-sparing diuretic with other diuretic exposure: 0=no exp, 1=exp"
label variable antiarrhythmic_`x' "antiarrhythmic exposure: 0=no exp, 1=exp"
label variable betablock_`x' "beta-blocker exposure: 0=no exp, 1=exp"
label variable acei_`x' "ACE inhibitor exposure: 0=no exp, 1=exp"
label variable angiotensin2recepant_`x' "Angiotensin II receptor antagonist exposure: 0=no exp, 1=exp"
label variable renini_`x' "Renin inhibitor exposure: 0=no exp, 1=exp"
label variable nitrates_`x' "nitrates exposure: 0=no exp, 1=exp"
label variable calchan_`x' "calcium channel blocker exposure: 0=no exp, 1=exp"
label variable anticoag_oral_`x' "Oral anticoagulant exposure: 0=no exp, 1=exp"
label variable antiplat_`x' "antiplatelet exposure: 0=no exp, 1=exp"
label variable statin_`x' "statin exposure: 0=no exp, 1=exp"

save Drug_Covariates_s.dta, replace
clear

timer off 1
timer list 1

exit
log close
