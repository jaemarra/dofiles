//  program:    Stat_mace_subgroup.do
//  task:		Statistical analysis for all-cause mortality
//  project: 	Incretins--Comparative mortality and CV outcomes (CPRD)
//  author:     JM \ July 2015  
//

clear all
capture log close Stat_mace
set more off
log using Stat_mace.smcl, name(Stat_mace_subgroup) replace

*************************************************SUBGROUP ANALYSES / EFFECT MODIFIERS*************************************************
use Stat_mace_mi, clear
//repeat for any after analyses
//use Stat_mace_mi_any, clear
//AGE- Generate the linear combination hr and ci (DPP only)
//Unadjusted
mi estimate, hr: stcox i.indextype if age_65==0, cformat(%6.2f) pformat(%5.3f) sformat(%6.2f) nolog noshow
mi estimate, hr: stcox i.indextype if age_65==1, cformat(%6.2f) pformat(%5.3f) sformat(%6.2f) nolog noshow
mi estimate, hr post: stcox indextype_2##i.age_65 indextype_3 indextype_4 indextype_5 indextype_6 indextype_7, cformat(%6.2f) pformat(%5.3f) sformat(%6.2f) nolog noshow
lincom 1.indextype_2+1.indextype_2#0.age_65, hr
lincom 1.indextype_2+1.indextype_2#1.age_65, hr
mi xeq 2: stptime if indextype==0&age_65==0
mi xeq 2: stptime if indextype==0&age_65==1
mi xeq 2: stptime if indextype==1&age_65==0
mi xeq 2: stptime if indextype==1&age_65==1
//Adjusted
mi estimate, hr: stcox i.indextype `mvmodel_mi' if age_65==0, cformat(%6.2f) pformat(%5.3f) sformat(%6.2f)  
mi estimate, hr: stcox i.indextype `mvmodel_mi' if age_65==1, cformat(%6.2f) pformat(%5.3f) sformat(%6.2f)  
mi estimate, hr post: stcox indextype_2##i.age_65 indextype_3 indextype_4 indextype_5 indextype_6 indextype_7 `mvmodel_mi', cformat(%6.2f) pformat(%5.3f) sformat(%6.2f)
lincom 1.indextype_2+1.indextype_2#0.age_65, hr
lincom 1.indextype_2+1.indextype_2#1.age_65, hr
mi xeq 2: stptime if indextype==0&age_65==0
mi xeq 2: stptime if indextype==0&age_65==1
mi xeq 2: stptime if indextype==1&age_65==0
mi xeq 2: stptime if indextype==1&age_65==1

//GENDER- Generate the linear combination hr and ci (DPP and GLP only
//Unadjusted
mi estimate, hr: stcox i.indextype if gender==0, cformat(%6.2f) pformat(%5.3f) sformat(%6.2f) nolog noshow
mi estimate, hr: stcox i.indextype if gender==1, cformat(%6.2f) pformat(%5.3f) sformat(%6.2f) nolog noshow
mi estimate, hr post: stcox indextype_2##i.gender indextype_3 indextype_4 indextype_5 indextype_6 indextype_7, cformat(%6.2f) pformat(%5.3f) sformat(%6.2f) nolog noshow
lincom 1.indextype_2+1.indextype_2#0.gender, hr
lincom 1.indextype_2+1.indextype_2#1.gender, hr
mi xeq 2: stptime if indextype==0&gender==0
mi xeq 2: stptime if indextype==0&gender==1
mi xeq 2: stptime if indextype==1&gender==0
mi xeq 2: stptime if indextype==1&gender==1
//Adjusted
mi estimate, hr: stcox i.indextype `mvmodel_mi' if gender==0, cformat(%6.2f) pformat(%5.3f) sformat(%6.2f)  
mi estimate, hr: stcox i.indextype `mvmodel_mi' if gender==1, cformat(%6.2f) pformat(%5.3f) sformat(%6.2f)  
mi estimate, hr post: stcox indextype_2##i.gender indextype_3 indextype_4 indextype_5 indextype_6 indextype_7 `mvmodel_mi', cformat(%6.2f) pformat(%5.3f) sformat(%6.2f)  
lincom 1.indextype_2+1.indextype_2#0.gender, hr
lincom 1.indextype_2+1.indextype_2#1.gender, hr
mi xeq 2: stptime if indextype==0&gender==0
mi xeq 2: stptime if indextype==0&gender==1
mi xeq 2: stptime if indextype==1&gender==0
mi xeq 2: stptime if indextype==1&gender==1

// Duration of Metformin Monotherapy- Generate the linear combination hr and ci (DPP and GLP only)
//Unadjusted
mi estimate, hr: stcox i.indextype if dmdur_2==0, cformat(%6.2f) pformat(%5.3f) sformat(%6.2f) nolog noshow
mi estimate, hr: stcox i.indextype if dmdur_2==1, cformat(%6.2f) pformat(%5.3f) sformat(%6.2f) nolog noshow
mi estimate, hr post: stcox indextype_2##i.dmdur_2 indextype_3 indextype_4 indextype_5 indextype_6 indextype_7, cformat(%6.2f) pformat(%5.3f) sformat(%6.2f) nolog noshow
lincom 1.indextype_2+1.indextype_2#0.dmdur_2, hr
lincom 1.indextype_2+1.indextype_2#1.dmdur_2, hr
mi xeq 2: stptime if indextype==0&dmdur_2==0
mi xeq 2: stptime if indextype==0&dmdur_2==1
mi xeq 2: stptime if indextype==1&dmdur_2==0
mi xeq 2: stptime if indextype==1&dmdur_2==1
//Adjusted 
mi estimate, hr: stcox i.indextype `mvmodel_mi' if dmdur_2==0, cformat(%6.2f) pformat(%5.3f) sformat(%6.2f) nolog noshow
mi estimate, hr: stcox i.indextype `mvmodel_mi' if dmdur_2==1, cformat(%6.2f) pformat(%5.3f) sformat(%6.2f) nolog noshow
mi estimate, hr post: stcox indextype_2##i.dmdur_2 indextype_3 indextype_4 indextype_5 indextype_6 indextype_7 `mvmodel_mi', cformat(%6.2f) pformat(%5.3f) sformat(%6.2f) 
lincom 1.indextype_2+1.indextype_2#0.dmdur_2, hr
lincom 1.indextype_2+1.indextype_2#1.dmdur_2, hr
mi xeq 2: stptime if indextype==0&dmdur_2==0
mi xeq 2: stptime if indextype==0&dmdur_2==1
mi xeq 2: stptime if indextype==1&dmdur_2==0
mi xeq 2: stptime if indextype==1&dmdur_2==1

// HbA1c- Generate the linear combination hr and ci (DPP and GLP only)
//Unadjusted
mi estimate, hr: stcox i.indextype if hba1c_8==0, cformat(%6.2f) pformat(%5.3f) sformat(%6.2f) nolog noshow
mi estimate, hr: stcox i.indextype if hba1c_8==1, cformat(%6.2f) pformat(%5.3f) sformat(%6.2f) nolog noshow
mi estimate, hr post: stcox indextype_2##i.hba1c_8 indextype_3 indextype_4 indextype_5 indextype_6 indextype_7, cformat(%6.2f) pformat(%5.3f) sformat(%6.2f) nolog noshow
lincom 1.indextype_2+1.indextype_2#0.hba1c_8, hr
lincom 1.indextype_2+1.indextype_2#1.hba1c_8, hr
mi xeq 2: stptime if indextype==0&hba1c_8==0
mi xeq 2: stptime if indextype==0&hba1c_8==1
mi xeq 2: stptime if indextype==1&hba1c_8==0
mi xeq 2: stptime if indextype==1&hba1c_8==1
//Adjusted
mi estimate, hr: stcox i.indextype `mvmodel_mi' if hba1c_8==0, cformat(%6.2f) pformat(%5.3f) sformat(%6.2f)  
mi estimate, hr: stcox i.indextype `mvmodel_mi' if hba1c_8==1, cformat(%6.2f) pformat(%5.3f) sformat(%6.2f)  
mi estimate, hr post: stcox indextype_2##i.hba1c_8 indextype_3 indextype_4 indextype_5 indextype_6 indextype_7 `mvmodel_mi', cformat(%6.2f) pformat(%5.3f) sformat(%6.2f)  
lincom 1.indextype_2+1.indextype_2#0.hba1c_8, hr
lincom 1.indextype_2+1.indextype_2#1.hba1c_8, hr
mi xeq 2: stptime if indextype==0&hba1c_8==0
mi xeq 2: stptime if indextype==0&hba1c_8==1
mi xeq 2: stptime if indextype==1&hba1c_8==0
mi xeq 2: stptime if indextype==1&hba1c_8==1

// BMI- Generate the linear combination hr and ci (DPP and GLP only)
//Unadjusted
mi estimate, hr: stcox i.indextype if bmi_30==0, cformat(%6.2f) pformat(%5.3f) sformat(%6.2f) nolog noshow
mi estimate, hr: stcox i.indextype if bmi_30==1, cformat(%6.2f) pformat(%5.3f) sformat(%6.2f) nolog noshow
mi estimate, hr post: stcox indextype_2##i.bmi_30 indextype_3 indextype_4 indextype_5 indextype_6 indextype_7, cformat(%6.2f) pformat(%5.3f) sformat(%6.2f) nolog noshow
lincom 1.indextype_2+1.indextype_2#0.bmi_30, hr
lincom 1.indextype_2+1.indextype_2#1.bmi_30, hr
mi xeq 2: stptime if indextype==0&bmi_30==0
mi xeq 2: stptime if indextype==0&bmi_30==1
mi xeq 2: stptime if indextype==1&bmi_30==0
mi xeq 2: stptime if indextype==1&bmi_30==1
//Adjusted
mi estimate, hr: stcox i.indextype `mvmodel_mi' if bmi_30==0, cformat(%6.2f) pformat(%5.3f) sformat(%6.2f)  
mi estimate, hr: stcox i.indextype `mvmodel_mi' if bmi_30==1, cformat(%6.2f) pformat(%5.3f) sformat(%6.2f)  
mi estimate, hr post: stcox indextype_2##i.bmi_30 indextype_3 indextype_4 indextype_5 indextype_6 indextype_7 `mvmodel_mi', cformat(%6.2f) pformat(%5.3f) sformat(%6.2f)  
lincom 1.indextype_2+1.indextype_2#0.bmi_30, hr
lincom 1.indextype_2+1.indextype_2#1.bmi_30, hr
mi xeq 2: stptime if indextype==0&bmi_30==0
mi xeq 2: stptime if indextype==0&bmi_30==1
mi xeq 2: stptime if indextype==1&bmi_30==0
mi xeq 2: stptime if indextype==1&bmi_30==1

// IMD
* too many missing values in CPRD cohort

// renal impairment- Generate the linear combination hr and ci (DPP and GLP only
//Unadjusted
mi estimate, hr: stcox i.indextype if ckd_60==0, cformat(%6.2f) pformat(%5.3f) sformat(%6.2f) nolog noshow
mi estimate, hr: stcox i.indextype if ckd_60==1, cformat(%6.2f) pformat(%5.3f) sformat(%6.2f) nolog noshow
mi estimate, hr post: stcox indextype_2##i.ckd_60 indextype_3 indextype_4 indextype_5 indextype_6 indextype_7, cformat(%6.2f) pformat(%5.3f) sformat(%6.2f) nolog noshow
lincom 1.indextype_2+1.indextype_2#0.ckd_60, hr
lincom 1.indextype_2+1.indextype_2#1.ckd_60, hr
mi xeq 2: stptime if indextype==0&ckd_60==0
mi xeq 2: stptime if indextype==0&ckd_60==1
mi xeq 2: stptime if indextype==1&ckd_60==0
mi xeq 2: stptime if indextype==1&ckd_60==1
//Adjusted
mi estimate, hr: stcox i.indextype `mvmodel_mi' if ckd_60==0, cformat(%6.2f) pformat(%5.3f) sformat(%6.2f)  
mi estimate, hr: stcox i.indextype `mvmodel_mi' if ckd_60==1, cformat(%6.2f) pformat(%5.3f) sformat(%6.2f)  
mi estimate, hr post: stcox indextype_2##i.ckd_60 indextype_3 indextype_4 indextype_5 indextype_6 indextype_7 `mvmodel_mi', cformat(%6.2f) pformat(%5.3f) sformat(%6.2f)  
lincom 1.indextype_2+1.indextype_2#0.ckd_60, hr
lincom 1.indextype_2+1.indextype_2#1.ckd_60, hr
mi xeq 2: stptime if indextype==0&ckd_60==0
mi xeq 2: stptime if indextype==0&ckd_60==1
mi xeq 2: stptime if indextype==1&ckd_60==0
mi xeq 2: stptime if indextype==1&ckd_60==1

// heart failure- Generate the linear combination hr and ci (DPP and GLP only)
//Unadjusted
mi estimate, hr: stcox i.indextype if hf_i==0, cformat(%6.2f) pformat(%5.3f) sformat(%6.2f) nolog noshow
mi estimate, hr: stcox i.indextype if hf_i==1, cformat(%6.2f) pformat(%5.3f) sformat(%6.2f) nolog noshow
mi estimate, hr post: stcox indextype_2##i.hf_i indextype_3 indextype_4 indextype_5 indextype_6 indextype_7, cformat(%6.2f) pformat(%5.3f) sformat(%6.2f) nolog noshow
lincom 1.indextype_2+1.indextype_2#0.hf_i, hr
lincom 1.indextype_2+1.indextype_2#1.hf_i, hr
mi xeq 2: stptime if indextype==0&hf_i==0
mi xeq 2: stptime if indextype==0&hf_i==1
mi xeq 2: stptime if indextype==1&hf_i==0
mi xeq 2: stptime if indextype==1&hf_i==1
//Adjusted
mi estimate, hr: stcox i.indextype `mvmodel_mi' if hf_i==0, cformat(%6.2f) pformat(%5.3f) sformat(%6.2f)  
mi estimate, hr: stcox i.indextype `mvmodel_mi' if hf_i==1, cformat(%6.2f) pformat(%5.3f) sformat(%6.2f)  
mi estimate, hr post: stcox indextype_2##i.hf_i indextype_3 indextype_4 indextype_5 indextype_6 indextype_7 `mvmodel_mi', cformat(%6.2f) pformat(%5.3f) sformat(%6.2f)  
lincom 1.indextype_2+1.indextype_2#0.hf_i, hr
lincom 1.indextype_2+1.indextype_2#1.hf_i, hr
mi xeq 2: stptime if indextype==0&hf_i==0
mi xeq 2: stptime if indextype==0&hf_i==1
mi xeq 2: stptime if indextype==1&hf_i==0
mi xeq 2: stptime if indextype==1&hf_i==1

//prior mi or stroke- Generate the linear combination hr and ci (DPP and GLP only)
//Unadjusted
mi estimate, hr: stcox i.indextype if mi_stroke==0, cformat(%6.2f) pformat(%5.3f) sformat(%6.2f) nolog noshow
mi estimate, hr: stcox i.indextype if mi_stroke==1, cformat(%6.2f) pformat(%5.3f) sformat(%6.2f) nolog noshow
mi estimate, hr post: stcox  indextype_2##i.mi_stroke indextype_3 indextype_4 indextype_5 indextype_6 indextype_7, cformat(%6.2f) pformat(%5.3f) sformat(%6.2f) nolog noshow
lincom 1.indextype_2+1.indextype_2#0.mi_stroke, hr
lincom 1.indextype_2+1.indextype_2#1.mi_stroke, hr
mi xeq 2: stptime if indextype==0&mi_stroke==0
mi xeq 2: stptime if indextype==0&mi_stroke==1
mi xeq 2: stptime if indextype==1&mi_stroke==0
mi xeq 2: stptime if indextype==1&mi_stroke==1
//Adjusted
mi estimate, hr: stcox i.indextype `mvmodel_mi' if mi_stroke==0, cformat(%6.2f) pformat(%5.3f) sformat(%6.2f) nolog noshow
mi estimate, hr: stcox i.indextype `mvmodel_mi' if mi_stroke==1, cformat(%6.2f) pformat(%5.3f) sformat(%6.2f) nolog noshow
mi estimate, hr post: stcox indextype_2##i.mi_stroke indextype_3 indextype_4 indextype_5 indextype_6 indextype_7 `mvmodel_mi', cformat(%6.2f) pformat(%5.3f) sformat(%6.2f)  
lincom 1.indextype_2+1.indextype_2#0.mi_stroke, hr
lincom 1.indextype_2+1.indextype_2#1.mi_stroke, hr
mi xeq 2: stptime if indextype==0&mi_stroke==0
mi xeq 2: stptime if indextype==0&mi_stroke==1
mi xeq 2: stptime if indextype==1&mi_stroke==0
mi xeq 2: stptime if indextype==1&mi_stroke==1

/*
//Generate Forest Plots


use SubgroupDPPMACEmain, clear
OR 
use SubgroupDPPMACEany, clear
capture label drop subgroups
label define subgroups 1 "{bf}Age" 2 "{bf}Gender" 3 "{bf}Duration of metformin monotherapy" 4 "{bf}HbA1c" 5 "{bf}BMI" 6 "{bf}Renal insufficiency" 7 "{bf}History of HF" 8 "{bf}History of MI/stroke"
label values subgroup subgroups
label define subvals 0 "Less than 65" 1 "65 or older" 2 "Female" 3 "Male" 4 "Less than 2 years" 5 "2 or more years" 6 "Less than 8" 7 "8 or greater" 8 "Less than 30" 9 "30 or greater" 10 "EGFR 60 or greater" 11 "EGFR less than 60" 12 "Negative history" 13 "Positive history"
label values sub_val subvals
rename sub_val Subgroup
label var Subgroup "{bf}Subgroup"
label var fail "{bf}Events"

FOR MACE MAIN
metan hr ll ul if adjusted==1, force by(subgroup) nowt nobox nooverall null(1) xlabel(0, .5, 1.5) lcols(Subgroup) effect("Hazard Ratio") title(Unadjusted Cox Model Subgroup Analysis for Index Exposure to DPP4i, size(small))
metan hr ll ul if adjusted==0, force by(subgroup) nowt nobox nooverall nosubgroup null(1) scheme(s1mono) xlabel(0, .5, 1.5, 2) lcols(Subgroup) effect("Hazard Ratio") saving(SubgroupACMmainUnadj, asis replace)
metan hr ll ul if adjusted==1, force by(subgroup) nowt nobox nooverall nosubgroup null(1) scheme(s1mono) xlabel(0, .5, 1.5, 2) lcols(Subgroup) effect("Hazard Ratio") saving(SubgroupACMmainAdj, asis replace)

FOR MACE ANY
metan hr ll ul if adjusted==1, force by(subgroup) nowt nobox nooverall nosubgroup null(1) scheme(s1mono) xlabel(0, .5, 1.5, 2) lcols(Subgroup) rcols(fail) effect("Hazard Ratio") saving(SubgroupACMmainAdj, asis replace)

*/

timer off 1
log close Stat_mace_subgroup
