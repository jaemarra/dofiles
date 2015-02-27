//  program:    Data04_loop.do
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
	do Data04_drug_covariates.do
	save drug_covariates_`i'.dta, replace
	}
use drug_covariates_0, clear 
forval i=1/49 {		
	append using drug_covariates_`i'
	}
save Drug_Covariates.dta, replace


//Generate window datasets
use Drug_Covariates.dta, clear
keep patid h2recep_c ppi_c cortico_gi_c ///
				thiazdiur_c loopdiur_c potsparediur_aldos_c potsparediur_other_c antiarrhythmic_c betablock_c acei_c angiotensin2recepant_c renini_c ///
				ras_c nitrates_c calchan_c anticoag_oral_c antiplat_c statin_c fibrates_c ezetimibe_c bileacidseq_c lipidreg_c bronchodil_c ///
				cortico_inh_c leukotri_c antihist_c hyp_anx_c psychoses_c antidepress_c antiobes_c opioid1_c antiepilep_c antipark_dop_c penicillin_c ///
				ceph_carb_betalac_c tetracyc_c aminoglyc_c macrolide_c clinda_c otherantibiot_c sulfo_trimeth_c antituberc_c antileprotic_c ///
				metro_tinidazole_c quinolone_c uti_drugs_c antibacterial_c antifungal_c antiviral_c antiprotoz_c anthelmintic_c thyroidhorm_c ///
				cortico_endocr_c estro_hrt_c bisphos_c cytotoxic_c antiprolif_c otherimmunosuppress_c antilymph_mab_c otherimmunomodul_c ///
				immunosuppress_all_c iron_oral_c iron_parenteral_c potassium_oral_c multivit_c nsaid_c antigout_c antirheum_c benzo_c opioid2_c ///
				opioid_c cortico_oral_c unqrxc
collapse (max) h2recep_c ppi_c cortico_gi_c ///
				thiazdiur_c loopdiur_c potsparediur_aldos_c potsparediur_other_c antiarrhythmic_c betablock_c acei_c angiotensin2recepant_c renini_c ///
				ras_c nitrates_c calchan_c anticoag_oral_c antiplat_c statin_c fibrates_c ezetimibe_c bileacidseq_c lipidreg_c bronchodil_c ///
				cortico_inh_c leukotri_c antihist_c hyp_anx_c psychoses_c antidepress_c antiobes_c opioid1_c antiepilep_c antipark_dop_c penicillin_c ///
				ceph_carb_betalac_c tetracyc_c aminoglyc_c macrolide_c clinda_c otherantibiot_c sulfo_trimeth_c antituberc_c antileprotic_c ///
				metro_tinidazole_c quinolone_c uti_drugs_c antibacterial_c antifungal_c antiviral_c antiprotoz_c anthelmintic_c thyroidhorm_c ///
				cortico_endocr_c estro_hrt_c bisphos_c cytotoxic_c antiprolif_c otherimmunosuppress_c antilymph_mab_c otherimmunomodul_c ///
				immunosuppress_all_c iron_oral_c iron_parenteral_c potassium_oral_c multivit_c nsaid_c antigout_c antirheum_c benzo_c opioid2_c ///
				opioid_c cortico_oral_c unqrxc, by(patid)
save Drug_Covariates_c.dta, replace
clear
//Generate indexdate window
use Drug_Covariates.dta
keep patid h2recep_i ppi_i cortico_gi_i thiazdiur_i loopdiur_i potsparediur_aldos_i potsparediur_other_i antiarrhythmic_i ///
				betablock_i acei_i angiotensin2recepant_i renini_i ras_i nitrates_i calchan_i anticoag_oral_i antiplat_i statin_i fibrates_i ezetimibe_i ///
				bileacidseq_i lipidreg_i bronchodil_i cortico_inh_i leukotri_i antihist_i hyp_anx_i psychoses_i antidepress_i antiobes_i opioid1_i ///
				antiepilep_i antipark_dop_i penicillin_i ceph_carb_betalac_i tetracyc_i aminoglyc_i macrolide_i clinda_i otherantibiot_i sulfo_trimeth_i ///
				antituberc_i antileprotic_i metro_tinidazole_i quinolone_i uti_drugs_i antibacterial_i antifungal_i antiviral_i antiprotoz_i ///
				anthelmintic_i thyroidhorm_i cortico_endocr_i estro_hrt_i bisphos_i cytotoxic_i antiprolif_i otherimmunosuppress_i antilymph_mab_i ///
				otherimmunomodul_i immunosuppress_all_i iron_oral_i iron_parenteral_i potassium_oral_i multivit_i nsaid_i antigout_i antirheum_i benzo_i ///
				opioid2_i opioid_i cortico_oral_i unqrxi
collapse (max) h2recep_i ppi_i cortico_gi_i thiazdiur_i loopdiur_i potsparediur_aldos_i potsparediur_other_i antiarrhythmic_i ///
				betablock_i acei_i angiotensin2recepant_i renini_i ras_i nitrates_i calchan_i anticoag_oral_i antiplat_i statin_i fibrates_i ezetimibe_i ///
				bileacidseq_i lipidreg_i bronchodil_i cortico_inh_i leukotri_i antihist_i hyp_anx_i psychoses_i antidepress_i antiobes_i opioid1_i ///
				antiepilep_i antipark_dop_i penicillin_i ceph_carb_betalac_i tetracyc_i aminoglyc_i macrolide_i clinda_i otherantibiot_i sulfo_trimeth_i ///
				antituberc_i antileprotic_i metro_tinidazole_i quinolone_i uti_drugs_i antibacterial_i antifungal_i antiviral_i antiprotoz_i ///
				anthelmintic_i thyroidhorm_i cortico_endocr_i estro_hrt_i bisphos_i cytotoxic_i antiprolif_i otherimmunosuppress_i antilymph_mab_i ///
				otherimmunomodul_i immunosuppress_all_i iron_oral_i iron_parenteral_i potassium_oral_i multivit_i nsaid_i antigout_i antirheum_i benzo_i ///
				opioid2_i opioid_i cortico_oral_i unqrxi, by(patid)	
save Drug_Covariates_i.dta, replace
clear
//Generate studyentrydate window
use Drug_Covariates.dta
keep patid h2recep_s ppi_s cortico_gi_s thiazdiur_s loopdiur_s potsparediur_aldos_s potsparediur_other_s ///
				antiarrhythmic_s betablock_s acei_s angiotensin2recepant_s renini_s ras_s nitrates_s calchan_s anticoag_oral_s antiplat_s statin_s ///
				fibrates_s ezetimibe_s bileacidseq_s lipidreg_s bronchodil_s cortico_inh_s leukotri_s antihist_s hyp_anx_s psychoses_s antidepress_s ///
				antiobes_s opioid1_s antiepilep_s antipark_dop_s penicillin_s ceph_carb_betalac_s tetracyc_s aminoglyc_s macrolide_s clinda_s ///
				otherantibiot_s sulfo_trimeth_s antituberc_s antileprotic_s metro_tinidazole_s quinolone_s uti_drugs_s antibacterial_s antifungal_s ///
				antiviral_s antiprotoz_s anthelmintic_s thyroidhorm_s cortico_endocr_s estro_hrt_s bisphos_s cytotoxic_s antiprolif_s ///
				otherimmunosuppress_s antilymph_mab_s otherimmunomodul_s immunosuppress_all_s iron_oral_s iron_parenteral_s potassium_oral_s multivit_s ///
				nsaid_s antigout_s antirheum_s benzo_s opioid2_s opioid_s cortico_oral_s unqrxs
collapse (max) h2recep_s ppi_s cortico_gi_s thiazdiur_s loopdiur_s potsparediur_aldos_s potsparediur_other_s ///
				antiarrhythmic_s betablock_s acei_s angiotensin2recepant_s renini_s ras_s nitrates_s calchan_s anticoag_oral_s antiplat_s statin_s ///
				fibrates_s ezetimibe_s bileacidseq_s lipidreg_s bronchodil_s cortico_inh_s leukotri_s antihist_s hyp_anx_s psychoses_s antidepress_s ///
				antiobes_s opioid1_s antiepilep_s antipark_dop_s penicillin_s ceph_carb_betalac_s tetracyc_s aminoglyc_s macrolide_s clinda_s ///
				otherantibiot_s sulfo_trimeth_s antituberc_s antileprotic_s metro_tinidazole_s quinolone_s uti_drugs_s antibacterial_s antifungal_s ///
				antiviral_s antiprotoz_s anthelmintic_s thyroidhorm_s cortico_endocr_s estro_hrt_s bisphos_s cytotoxic_s antiprolif_s ///
				otherimmunosuppress_s antilymph_mab_s otherimmunomodul_s immunosuppress_all_s iron_oral_s iron_parenteral_s potassium_oral_s multivit_s ///
				nsaid_s antigout_s antirheum_s benzo_s opioid2_s opioid_s cortico_oral_s unqrxs, by(patid)
save Drug_Covariates_s.dta, replace
clear

timer off 1
timer list 1

exit
log close
