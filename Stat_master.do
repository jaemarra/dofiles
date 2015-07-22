//  program:    Stat_master.do
//  task:		Master List of all Stat.do Files
//  project: 	Incretins--Comparative mortality and CV outcomes (CPRD)
//  authors:    JM \ July 2015

//	Run the following Stat.do files, in order listed, to complete statistical analysis. 

clear all
capture log close
log using Stat_master.smcl, replace
timer on 1
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
/* #1 ACM: 				Generates all datasets required for downstream analyses of ACM
						a) acm.dta:					use Analytic_Dataset_Master.dta
													do Data13_variable_generation.do
													restrict to eligible population
													restrict to 2007 or later
						b) Stat_acm_cc: 			use acm.dta
													apply complete case approach
													split
						c) Stat_acm_mi: 			use acm.dta
													apply multiple imputation approach
													split
						d) Stat_acm_mi_index: 		use acm.dta
													stset to exit at first gap after index
													apply multiple imputation approach
													split
						e) Stat_acm_mi_index3: 		use acm.dta
													steset to exit at first switch or add AFTER index
													apply multiple imputation approach
													split
						f) Stat_acm_mi_any:			use acm.dta
													stset to use any exposure after metformin monotherapy
													apply multiple imputation approach

*/

do Stat_acm.do
/* Files saved:			acm.dta
						Stat_acm_cc.dta
						Stat_acm_mi.dta
						Stat_acm_mi_index.dta
						Stat_acm_mi_index3.dta
						Stat_acm_mi_any.dta
*/

/*
#1a ACM diagnostics: 	Generates all diagnostics for CC and MI models
						i) Stat_acm_diagnostics:		run diagnostics on complete case model
						
						ii) Stat_mi_acm_diagnostics:	run diagnostics on multiple imputation models
*/
do Stat_acm_diagnostics.do
do Stat_acm_mi_diagnostics.do
/*
#1b ACM tables			Generates all data in excel table format (table_acm) with the following tabs:
						Unadj Comp Case
						Adj Comp Case Ref0
						Adj Comp Case Ref0Sep
						Adj Comp Case Ref1
						Adj Comp Case Ref2
						Adj Comp Case Ref3
						Adj Comp Case Ref4
						Unadj MI
						Adj MI Ref0
						Adj MI Ref1
						Adj MI Ref2
						Adj MI Ref3
						Adj MI Ref4
						Adj CPRD Only MI
						Adj HES Only MI
						Unadj MI Gap1
						Adj MI Gap1
						Unadj MI Agent3
						Adj MI Agent3
						Unadj MI Any Aft
						Adj MI Any Aft
						
*/
do Stat_acm_tables.do
/*
Files saved: 			table_acm.xlsx
*/
/*
#1c ACM subgroup analyses
*/
do Stat_acm_subgroup.do
/*
Files saved: 			SubgroupAnalysis2.dta
						SubgroupAnalysis_anyafter.dta
*/
/*
#1d ACM propensity score
*/
do Stat_acm_pscore.do
/*
Files saved: 			none
*/
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
/* #2 MACE: 			Generates all datasets required for downstream analyses of MACE
						a) mace.dta:					use Analytic_Dataset_Master.dta
														do Data13_variable_generation.do
														restrict to eligible population
														restrict to 2007 or later
														restrict further to linked only population (due to cvdeath)
						b) Stat_mace_cc: 				use mace.dta
														apply complete case approach
														split
						c) Stat_mace_mi: 				use mace.dta
														apply multiple imputation approach
														split
						d) Stat_mace_mi_index: 			use mace.dta
														stset to exit at first gap after index
														apply multiple imputation approach
														split
						e) Stat_mace_mi_index3: 		use mace.dta
														steset to exit at first switch or add AFTER index
														apply multiple imputation approach
														split
						f) Stat_mace_mi_any:			use mace.dta
														stset to use any exposure after metformin monotherapy
														apply multiple imputation approach
						g) Stat_mace_diagnostics: 		run diagnostics on complete case model
						
						h) Stat_mace_mi_diagnostics:	run diagnostics on multiple imputation models
*/

do Stat_mace.do
/* Files saved:			mace.dta
						Stat_mace_cc.dta
						Stat_mace_mi.dta
						Stat_mace_mi_index.dta
						Stat_mace_mi_index3.dta
						Stat_mace_mi_any.dta
*/
/*
#2a MACE diagnostics: 	Generates all diagnostics for CC and MI models
						i) Stat_mace_diagnostics:		run diagnostics on complete case model
						
						ii) Stat_mi_mace_diagnostics:	run diagnostics on multiple imputation models
*/
do Stat_mace_diagnostics.do
do Stat_mace_mi_diagnostics.do
/*
#2b MACE tables			Generates all data in excel table format (table_mace) with the following tabs:
						Unadj Comp Case
						Adj Comp Case Ref0
						Adj Comp Case Ref0Sep
						Adj Comp Case Ref1
						Adj Comp Case Ref2
						Adj Comp Case Ref3
						Adj Comp Case Ref4
						Unadj MI
						Adj MI Ref0
						Adj MI Ref1
						Adj MI Ref2
						Adj MI Ref3
						Adj MI Ref4
						Adj CPRD Only MI
						Adj HES Only MI
						Unadj MI Gap1
						Adj MI Gap1
						Unadj MI Agent3
						Adj MI Agent3
						Unadj MI Any Aft
						Adj MI Any Aft
						
*/
do Stat_mace_tables.do
/*
Files saved: 			table_mace.xlsx
*/
/*
#2c MACE subgroup analyses
*/
do Stat_mace_subgroup.do
/*
Files saved: 			SubgroupAnalysisMace.dta
*/
/*
#2d MACE propensity score
*/
do Stat_mace_pscore.do
/*
Files saved: 			none
*/			
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////		
/* #3 Angina: 			Generates all datasets required for downstream analyses of Angina
						a) angina.dta:			use Analytic_Dataset_Master.dta
												do Data13_variable_generation.do
												restrict to eligible population
												restrict to 2007 or later
						b) Stat_angina_cc: 		use angina.dta
												apply complete case approach
												split
						c) Stat_angina_mi: 		use angina.dta
												apply multiple imputation approach
												split
						d) Stat_angina_mi_index: 	use angina.dta
												stset to exit at first gap after index
												apply multiple imputation approach
												split
						e) Stat_angina_mi_index3: use angina.dta
												steset to exit at first switch or add AFTER index
												apply multiple imputation approach
												split
						f) Stat_angina_mi_any:	use angina.dta
												stset to use any exposure after metformin monotherapy
												apply multiple imputation approach	
*/

do Stat_angina.do
/* Files saved:			angina.dta
						Stat_angina_cc.dta
						Stat_angina_mi.dta
						Stat_angina_mi_index.dta
						Stat_angina_mi_index3.dta
						Stat_angina_mi_any.dta
*/
/*
#3a Angina diagnostics: Generates all diagnostics for CC and MI models
						i) Stat_angina_diagnostics:		run diagnostics on complete case model
						
						ii) Stat_mi_angina_diagnostics:	run diagnostics on multiple imputation models
*/
do Stat_angina_diagnostics.do
do Stat_angina_mi_diagnostics.do
/*
#3b Angina tables		Generates all data in excel table format (table_angina) with the following tabs:
						Unadj Comp Case
						Adj Comp Case Ref0
						Adj Comp Case Ref0Sep
						Adj Comp Case Ref1
						Adj Comp Case Ref2
						Adj Comp Case Ref3
						Adj Comp Case Ref4
						Unadj MI
						Adj MI Ref0
						Adj MI Ref1
						Adj MI Ref2
						Adj MI Ref3
						Adj MI Ref4
						
*/
do Stat_angina_tables.do
/*
Files saved: 			table_angina.xlsx
*/
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
/* #4 Arrhythmia: 		Generates all datasets required for downstream analyses of Angina
						a) arrhyth.dta:				use Analytic_Dataset_Master.dta
													do Data13_variable_generation.do
													restrict to eligible population
													restrict to 2007 or later
						b) Stat_arrhyth_cc: 		use arrhyth.dta
													apply complete case approach
													split
						c) Stat_arrhyth_mi: 		use arrhyth.dta
													apply multiple imputation approach
													split
						d) Stat_arrhyth_mi_index: 	use arrhyth.dta
													stset to exit at first gap after index
													apply multiple imputation approach
													split
						e) Stat_arrhyth_mi_index3: 	use arrhyth.dta
													steset to exit at first switch or add AFTER index
													apply multiple imputation approach
													split
						f) Stat_arrhyth_mi_any:		use arrhyth.dta
													stset to use any exposure after metformin monotherapy
													apply multiple imputation approach	
*/

do Stat_arhhyth.do
/* Files saved:			arrhyth.dta
						Stat_arrhyth_cc.dta
						Stat_arrhyth_mi.dta
						Stat_arrhyth_mi_index.dta
						Stat_arrhyth_mi_index3.dta
						Stat_arrhyth_mi_any.dta
*/
/*
#4a Arrhythmia diagnostics: Generates all diagnostics for CC and MI models
							i) Stat_arrhyth_diagnostics:		run diagnostics on complete case model
						
							ii) Stat_mi_arrhyth_diagnostics:	run diagnostics on multiple imputation models
*/
do Stat_arhhyth_diagnostics.do
do Stat_arhhyth_mi_diagnostics.do
/*
#4b Arrhythmia tables	Generates all data in excel table format (table_arrhyth) with the following tabs:
						Unadj Comp Case
						Adj Comp Case Ref0
						Adj Comp Case Ref0Sep
						Adj Comp Case Ref1
						Adj Comp Case Ref2
						Adj Comp Case Ref3
						Adj Comp Case Ref4
						Unadj MI
						Adj MI Ref0
						Adj MI Ref1
						Adj MI Ref2
						Adj MI Ref3
						Adj MI Ref4
						
*/
do Stat_arhhyth_tables.do
/*
Files saved: 			table_arhhyth.xlsx
*/
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
/* #5 HF: 				Generates all datasets required for downstream analyses of HF
						a) HF.dta:					use Analytic_Dataset_Master.dta
													do Data13_variable_generation.do
													restrict to eligible population
													restrict to 2007 or later
						b) Stat_HF_cc: 				use HF.dta
													apply complete case approach
													split
						c) Stat_HF_mi: 				use HF.dta
													apply multiple imputation approach
													split
						d) Stat_HF_mi_index: 		use HF.dta
													stset to exit at first gap after index
													apply multiple imputation approach
													split
						e) Stat_HF_mi_index3: 		use HF.dta
													steset to exit at first switch or add AFTER index
													apply multiple imputation approach
													split
						f) Stat_HF_mi_any:			use HF.dta
													stset to use any exposure after metformin monotherapy
													apply multiple imputation approach	
*/

do Stat_HF.do
/* Files saved:			HF.dta
						Stat_HF_cc.dta
						Stat_HF_mi.dta
						Stat_HF_mi_index.dta
						Stat_HF_mi_index3.dta
						Stat_HF_mi_any.dta
*/
/*
#5a HF diagnostics: 	Generates all diagnostics for CC and MI models
						i) Stat_HF_diagnostics:		run diagnostics on complete case model
						
						ii) Stat_HF_mi_diagnostics:	run diagnostics on multiple imputation models
*/
do Stat_HF_diagnostics.do
do Stat_HF_mi_diagnostics.do
/*
#5b HF tables			Generates all data in excel table format (table_HF) with the following tabs:
						Unadj Comp Case
						Adj Comp Case Ref0
						Adj Comp Case Ref0Sep
						Adj Comp Case Ref1
						Adj Comp Case Ref2
						Adj Comp Case Ref3
						Adj Comp Case Ref4
						Unadj MI
						Adj MI Ref0
						Adj MI Ref1
						Adj MI Ref2
						Adj MI Ref3
						Adj MI Ref4
						
*/
do Stat_HF_tables.do
/*
Files saved: 			table_HF.xlsx
*/
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
/* #6 MI: 				Generates all datasets required for downstream analyses of MI
						a) MI.dta:				use Analytic_Dataset_Master.dta
													do Data13_variable_generation.do
													restrict to eligible population
													restrict to 2007 or later
						b) Stat_MI_cc: 			use MI.dta
													apply complete case approach
													split
						c) Stat_MI_mi: 			use MI.dta
													apply multiple imputation approach
													split
						d) Stat_MI_mi_index: 	use MI.dta
													stset to exit at first gap after index
													apply multiple imputation approach
													split
						e) Stat_MI_mi_index3: 	use MI.dta
													steset to exit at first switch or add AFTER index
													apply multiple imputation approach
													split
						f) Stat_MI_mi_any:		use MI.dta
													stset to use any exposure after metformin monotherapy
													apply multiple imputation approach	
*/

do Stat_MI.do
/* Files saved:			MI.dta
						Stat_MI_cc.dta
						Stat_MI_mi.dta
						Stat_MI_mi_index.dta
						Stat_MI_mi_index3.dta
						Stat_MI_mi_any.dta
*/
/*
#6a MI diagnostics: 	Generates all diagnostics for CC and MI models
						i) Stat_MI_diagnostics:		run diagnostics on complete case model
						
						ii) Stat_MI_mi_diagnostics:	run diagnostics on multiple imputation models
*/
do Stat_MI_diagnostics.do
do Stat_MI_mi_diagnostics.do
/*
#6b MI tables:			Generates all data in excel table format (table_MI) with the following tabs:
						Unadj Comp Case
						Adj Comp Case Ref0
						Adj Comp Case Ref0Sep
						Adj Comp Case Ref1
						Adj Comp Case Ref2
						Adj Comp Case Ref3
						Adj Comp Case Ref4
						Unadj MI
						Adj MI Ref0
						Adj MI Ref1
						Adj MI Ref2
						Adj MI Ref3
						Adj MI Ref4
						
*/
do Stat_MI_tables.do
/*
Files saved: 			table_MI.xlsx
*/
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
/* #7 Revasc: 			Generates all datasets required for downstream analyses of Revasc
						a) revasc.dta:				use Analytic_Dataset_Master.dta
													do Data13_variable_generation.do
													restrict to eligible population
													restrict to 2007 or later
						b) Stat_revasc_cc: 			use revasc.dta
													apply complete case approach
													split
						c) Stat_revasc_mi: 			use revasc.dta
													apply multiple imputation approach
													split
						d) Stat_revasc_mi_index: 	use revasc.dta
													stset to exit at first gap after index
													apply multiple imputation approach
													split
						e) Stat_revasc_mi_index3: 	use revasc.dta
													steset to exit at first switch or add AFTER index
													apply multiple imputation approach
													split
						f) Stat_revasc_mi_any:		use revasc.dta
													stset to use any exposure after metformin monotherapy
													apply multiple imputation approach	
*/

do Stat_revasc.do
/* Files saved:			revasc.dta
						Stat_revasc_cc.dta
						Stat_revasc_mi.dta
						Stat_revasc_mi_index.dta
						Stat_revasc_mi_index3.dta
						Stat_revasc_mi_any.dta
*/
/*
#7a Revasc diagnostics: Generates all diagnostics for CC and MI models
						i) Stat_revasc_diagnostics:		run diagnostics on complete case model
						
						ii) Stat_revasc_mi_diagnostics:	run diagnostics on multiple imputation models
*/
do Stat_revasc_diagnostics.do
do Stat_revasc_mi_diagnostics.do
/*
#7b Revasc tables		Generates all data in excel table format (table_revasc) with the following tabs:
						Unadj Comp Case
						Adj Comp Case Ref0
						Adj Comp Case Ref0Sep
						Adj Comp Case Ref1
						Adj Comp Case Ref2
						Adj Comp Case Ref3
						Adj Comp Case Ref4
						Unadj MI
						Adj MI Ref0
						Adj MI Ref1
						Adj MI Ref2
						Adj MI Ref3
						Adj MI Ref4
						
*/
do Stat_revasc_tables.do
/*
Files saved: 			table_revasc.xlsx
*/
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
/* #8 Stroke: 			Generates all datasets required for downstream analyses of Stroke
						a) stroke.dta:				use Analytic_Dataset_Master.dta
													do Data13_variable_generation.do
													restrict to eligible population
													restrict to 2007 or later
						b) Stat_stroke_cc: 			use stroke.dta
													apply complete case approach
													split
						c) Stat_stroke_mi: 			use stroke.dta
													apply multiple imputation approach
													split
						d) Stat_stroke_mi_index: 	use stroke.dta
													stset to exit at first gap after index
													apply multiple imputation approach
													split
						e) Stat_stroke_mi_index3: 	use stroke.dta
													steset to exit at first switch or add AFTER index
													apply multiple imputation approach
													split
						f) Stat_stroke_mi_any:		use stroke.dta
													stset to use any exposure after metformin monotherapy
													apply multiple imputation approach	
*/

do Stat_stroke.do
/* Files saved:			stroke.dta
						Stat_stroke_cc.dta
						Stat_stroke_mi.dta
						Stat_stroke_mi_index.dta
						Stat_stroke_mi_index3.dta
						Stat_stroke_mi_any.dta
*/
/*
#8a Stroke diagnostics: Generates all diagnostics for CC and MI models
						i) Stat_stroke_diagnostics:		run diagnostics on complete case model
						
						ii) Stat_stroke_mi_diagnostics:	run diagnostics on multiple imputation models
*/
do Stat_stroke_diagnostics.do
do Stat_stroke_mi_diagnostics.do
/*
#8b Stroke tables		Generates all data in excel table format (table_stroke) with the following tabs:
						Unadj Comp Case
						Adj Comp Case Ref0
						Adj Comp Case Ref0Sep
						Adj Comp Case Ref1
						Adj Comp Case Ref2
						Adj Comp Case Ref3
						Adj Comp Case Ref4
						Unadj MI
						Adj MI Ref0
						Adj MI Ref1
						Adj MI Ref2
						Adj MI Ref3
						Adj MI Ref4
						
*/
do Stat_stroke_tables.do
/*
Files saved: 			table_stroke.xlsx
*/
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
/* #9 CV Death: 		Generates all datasets required for downstream analyses of CV Death
						a) cvdeath.dta:				use Analytic_Dataset_Master.dta
													do Data13_variable_generation.do
													restrict to eligible population
													restrict to 2007 or later
						b) Stat_cvdeath_cc: 		use cvdeath.dta
													apply complete case approach
													split
						c) Stat_cvdeath_mi: 		use cvdeath.dta
													apply multiple imputation approach
													split
						d) Stat_cvdeath_mi_index: 	use cvdeath.dta
													stset to exit at first gap after index
													apply multiple imputation approach
													split
						e) Stat_cvdeath_mi_index3: 	use cvdeath.dta
													steset to exit at first switch or add AFTER index
													apply multiple imputation approach
													split
						f) Stat_cvdeath_mi_any:		use cvdeath.dta
													stset to use any exposure after metformin monotherapy
													apply multiple imputation approach	
*/

do Stat_cvdeath.do
/* Files saved:			cvdeath.dta
						Stat_cvdeath_cc.dta
						Stat_cvdeath_mi.dta
						Stat_cvdeath_mi_index.dta
						Stat_cvdeath_mi_index3.dta
						Stat_cvdeath_mi_any.dta
*/
/*
#9a CV Death diagnostics: Generates all diagnostics for CC and MI models
							i) Stat_cvdeath_diagnostics:		run diagnostics on complete case model
						
							ii) Stat_cvdeath_mi_diagnostics:	run diagnostics on multiple imputation models
*/
do Stat_cvdeath_diagnostics.do
do Stat_cvdeath_mi_diagnostics.do
/*
#9b CV Death tables	Generates all data in excel table format (table_cvdeath) with the following tabs:
							Unadj Comp Case
							Adj Comp Case Ref0
							Adj Comp Case Ref0Sep
							Adj Comp Case Ref1
							Adj Comp Case Ref2
							Adj Comp Case Ref3
							Adj Comp Case Ref4
							Unadj MI
							Adj MI Ref0
							Adj MI Ref1
							Adj MI Ref2
							Adj MI Ref3
							Adj MI Ref4
						
*/
do Stat_cvdeath_tables.do
/*
Files saved: 			table_cvdeath.xlsx
*/
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
/*	#10 Manuscript: 	Generates all data and synthesizes tables, figures, and out puts required for the final manuscript
*/
do Stat_manuscript
/*
Files saved: 			Stat_manuscript.smcl
*/
////////////////////////////////////////////
timer off 1
timer list 1

exit
log close

