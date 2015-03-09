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
				//tidy labelling 
local x "c"			
label variable ppi_`x' "Proton pump inhibitor exposure: 0=no exp, 1=exp"
label variable h2recep_`x' "H2 receptor antagonist exposure: 0=no exp, 1=exp"
label variable cortico_gi_`x' "Corticosteroid (GI) exposure:0=no exp, 1=exp"
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
label variable fibrates_`x' "fibrates exposure: 0=no exp, 1=exp"
label variable ezetimibe_`x' "ezetimibe exposure: 0=no exp, 1=exp"
label variable bileacidseq_`x' "Bile acid sequestrants exposure: 0=no exp, 1=exp"
label variable bronchodil_`x' "Bronchodilator exposure:0=no exp, 1=exp"
label variable cortico_inh_`x' "Inhaled corticosteroid exposure:0=no exp, 1=exp"
label variable leukotri_`x' "Leukotriene receptor antagonist exposure:0=no exp, 1=exp"
label variable antihist_`x' "Antihistamine exposure:0=no exp, 1=exp"
label variable hyp_anx_`x' "Hypnotic/Anxiolytic exposure:0=no exp, 1=exp"
label variable psychoses_`x' "Drugs used in psychoses and related disorders exposure:0=no exp, 1=exp"
label variable antidepress_`x' "Antidepressant exposure:0=no exp, 1=exp"
label variable antiobes_`x' "Antiobesity drug exposure:0=no exp, 1=exp"
label variable opioid1_`x' "Opioid analgesic (CNS) exposure:0=no exp, 1=exp"
label variable antiepilep_`x' "Antiepileptic exposure:0=no exp, 1=exp"
label variable penicillin_`x' "Penicillin exposure: 0=no exp, 1=exp"
label variable ceph_carb_betalac_`x' "Cephalosporins, carbapenems and other beta-lactams exposure: 0=no exp, 1=exp"
label variable tetracyc_`x' "Tetracycline exposure: 0=no exp, 1=exp"
label variable aminoglyc_`x' "Aminoglycoside exposure: 0=no exp, 1=exp"
label variable macrolide_`x' "Macrolide exposure: 0=no exp, 1=exp"
label variable clinda_`x' "Clindamycin exposure: 0=no exp, 1=exp"
label variable otherantibiot_`x' "Other antibiotic exposure: 0=no exp, 1=exp"
label variable sulfo_trimeth_`x' "Sulfonamides and trimethoprim exposure: 0=no exp, 1=exp"
label variable antituberc_`x' "Antituberculosis drug exposure: 0=no exp, 1=exp"
label variable antileprotic_`x' "Antileprotic drug exposure: 0=no exp, 1=exp"
label variable metro_tinidazole_`x' "Metronidazole and tinidazole exposure: 0=no exp, 1=exp"
label variable quinolone_`x' "Quinolone exposure: 0=no exp, 1=exp"
label variable uti_drugs_`x' "UTI drug exposure: 0=no exp, 1=exp"
label variable antifungal_`x' "Antifungal exposure:0=no exp, 1=exp"
label variable antiviral_`x' "Antiviral exposure:0=no exp, 1=exp"
label variable antiprotoz_`x' "Antiprotozoal exposure:0=no exp, 1=exp"
label variable anthelmintic_`x' "Anthelmintic exposure:0=no exp, 1=exp"
label variable thyroidhorm_`x' "Thyroid hormone exposure: 0=no exp, 1=exp"
label variable cortico_endocr_`x' "Corticosteroid (endocrine) exposure:0=no exp, 1=exp"
label variable estro_hrt_`x' "Estrogen and HRT exposure: 0=no exp, 1=exp"
label variable bisphos_`x' "Bisphosphonate drug exposure: 0=no exp, 1=exp"
label variable cytotoxic_`x' "Cytotoxic drug exposure:0=no exp, 1=exp"
label variable antilymph_mab_`x' "Antilymphocyte monoclonal antibody exposure:0=no exp, 1=exp"
label variable otherimmunomodul_`x' "Other immunomodulating drug exposure:0=no exp, 1=exp"
label variable iron_oral_`x' "Oral iron exposure: 0=no exp, 1=exp"
label variable iron_parenteral_`x' "Parenteral iron exposure: 0=no exp, 1=exp"
label variable potassium_oral_`x' "Oral potassium exposure: 0=no exp, 1=exp"
label variable multivit_`x' "Multivitamin exposure: 0=no exp, 1=exp"
label variable nsaid_`x' "NSAID exposure: 0=no exp, 1=exp"
label variable cortico_inject_`x' "Corticosteroid (local inj) exposure:0=no exp, 1=exp"
label variable antigout_`x' "Antigout drug exposure: 0=no exp, 1=exp"
label variable antirheum_`x' "Antirheumatic drug exposure: 0=no exp, 1=exp"
label variable benzo_`i' "Benzodiazepine exposure: 0=no exp, 1=exp" 
label variable opioid2`x' "Opioid analgesic (anaes) exposure: 0=no exp, 1=exp"
label variable opioid`x' "any opioid exposure: 0=no exp, 1=exp"
label variable cortico_oral`x' "any oral corticosteroid exposure: 0=no exp, 1=exp"
label variable antipark_dop`x' "Antiparkison's dopaminergic drug exposure:0=no exp, 1=exp"
label variable antibacterial`x' "Antibacterial drug exposure: 0=no exp, 1=exp"
label variable antiprolif`x' "Antiproliferative immunosuppresant exposure:0=no exp, 1=exp"
label variable otherimmunosuppress`x' "Corticosteroids and other immunosuppresant exposure:0=no exp, 1=exp"
label variable immunosuppress_all`x' "Any immunosuppressant drug exposure:0=no exp, 1=exp"

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

local x "i"			
label variable ppi_`x' "Proton pump inhibitor exposure: 0=no exp, 1=exp"
label variable h2recep_`x' "H2 receptor antagonist exposure: 0=no exp, 1=exp"
label variable cortico_gi_`x' "Corticosteroid (GI) exposure:0=no exp, 1=exp"
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
label variable fibrates_`x' "fibrates exposure: 0=no exp, 1=exp"
label variable ezetimibe_`x' "ezetimibe exposure: 0=no exp, 1=exp"
label variable bileacidseq_`x' "Bile acid sequestrants exposure: 0=no exp, 1=exp"
label variable bronchodil_`x' "Bronchodilator exposure:0=no exp, 1=exp"
label variable cortico_inh_`x' "Inhaled corticosteroid exposure:0=no exp, 1=exp"
label variable leukotri_`x' "Leukotriene receptor antagonist exposure:0=no exp, 1=exp"
label variable antihist_`x' "Antihistamine exposure:0=no exp, 1=exp"
label variable hyp_anx_`x' "Hypnotic/Anxiolytic exposure:0=no exp, 1=exp"
label variable psychoses_`x' "Drugs used in psychoses and related disorders exposure:0=no exp, 1=exp"
label variable antidepress_`x' "Antidepressant exposure:0=no exp, 1=exp"
label variable antiobes_`x' "Antiobesity drug exposure:0=no exp, 1=exp"
label variable opioid1_`x' "Opioid analgesic (CNS) exposure:0=no exp, 1=exp"
label variable antiepilep_`x' "Antiepileptic exposure:0=no exp, 1=exp"
label variable penicillin_`x' "Penicillin exposure: 0=no exp, 1=exp"
label variable ceph_carb_betalac_`x' "Cephalosporins, carbapenems and other beta-lactams exposure: 0=no exp, 1=exp"
label variable tetracyc_`x' "Tetracycline exposure: 0=no exp, 1=exp"
label variable aminoglyc_`x' "Aminoglycoside exposure: 0=no exp, 1=exp"
label variable macrolide_`x' "Macrolide exposure: 0=no exp, 1=exp"
label variable clinda_`x' "Clindamycin exposure: 0=no exp, 1=exp"
label variable otherantibiot_`x' "Other antibiotic exposure: 0=no exp, 1=exp"
label variable sulfo_trimeth_`x' "Sulfonamides and trimethoprim exposure: 0=no exp, 1=exp"
label variable antituberc_`x' "Antituberculosis drug exposure: 0=no exp, 1=exp"
label variable antileprotic_`x' "Antileprotic drug exposure: 0=no exp, 1=exp"
label variable metro_tinidazole_`x' "Metronidazole and tinidazole exposure: 0=no exp, 1=exp"
label variable quinolone_`x' "Quinolone exposure: 0=no exp, 1=exp"
label variable uti_drugs_`x' "UTI drug exposure: 0=no exp, 1=exp"
label variable antifungal_`x' "Antifungal exposure:0=no exp, 1=exp"
label variable antiviral_`x' "Antiviral exposure:0=no exp, 1=exp"
label variable antiprotoz_`x' "Antiprotozoal exposure:0=no exp, 1=exp"
label variable anthelmintic_`x' "Anthelmintic exposure:0=no exp, 1=exp"
label variable thyroidhorm_`x' "Thyroid hormone exposure: 0=no exp, 1=exp"
label variable cortico_endocr_`x' "Corticosteroid (endocrine) exposure:0=no exp, 1=exp"
label variable estro_hrt_`x' "Estrogen and HRT exposure: 0=no exp, 1=exp"
label variable bisphos_`x' "Bisphosphonate drug exposure: 0=no exp, 1=exp"
label variable cytotoxic_`x' "Cytotoxic drug exposure:0=no exp, 1=exp"
label variable antilymph_mab_`x' "Antilymphocyte monoclonal antibody exposure:0=no exp, 1=exp"
label variable otherimmunomodul_`x' "Other immunomodulating drug exposure:0=no exp, 1=exp"
label variable iron_oral_`x' "Oral iron exposure: 0=no exp, 1=exp"
label variable iron_parenteral_`x' "Parenteral iron exposure: 0=no exp, 1=exp"
label variable potassium_oral_`x' "Oral potassium exposure: 0=no exp, 1=exp"
label variable multivit_`x' "Multivitamin exposure: 0=no exp, 1=exp"
label variable nsaid_`x' "NSAID exposure: 0=no exp, 1=exp"
label variable cortico_inject_`x' "Corticosteroid (local inj) exposure:0=no exp, 1=exp"
label variable antigout_`x' "Antigout drug exposure: 0=no exp, 1=exp"
label variable antirheum_`x' "Antirheumatic drug exposure: 0=no exp, 1=exp"
label variable benzo_`i' "Benzodiazepine exposure: 0=no exp, 1=exp" 
label variable opioid2`x' "Opioid analgesic (anaes) exposure: 0=no exp, 1=exp"
label variable opioid`x' "any opioid exposure: 0=no exp, 1=exp"
label variable cortico_oral`x' "any oral corticosteroid exposure: 0=no exp, 1=exp"
label variable antipark_dop`x' "Antiparkison's dopaminergic drug exposure:0=no exp, 1=exp"
label variable antibacterial`x' "Antibacterial drug exposure: 0=no exp, 1=exp"
label variable antiprolif`x' "Antiproliferative immunosuppresant exposure:0=no exp, 1=exp"
label variable otherimmunosuppress`x' "Corticosteroids and other immunosuppresant exposure:0=no exp, 1=exp"
label variable immunosuppress_all`x' "Any immunosuppressant drug exposure:0=no exp, 1=exp"

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
local x "s"			
label variable ppi_`x' "Proton pump inhibitor exposure: 0=no exp, 1=exp"
label variable h2recep_`x' "H2 receptor antagonist exposure: 0=no exp, 1=exp"
label variable cortico_gi_`x' "Corticosteroid (GI) exposure:0=no exp, 1=exp"
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
label variable fibrates_`x' "fibrates exposure: 0=no exp, 1=exp"
label variable ezetimibe_`x' "ezetimibe exposure: 0=no exp, 1=exp"
label variable bileacidseq_`x' "Bile acid sequestrants exposure: 0=no exp, 1=exp"
label variable bronchodil_`x' "Bronchodilator exposure:0=no exp, 1=exp"
label variable cortico_inh_`x' "Inhaled corticosteroid exposure:0=no exp, 1=exp"
label variable leukotri_`x' "Leukotriene receptor antagonist exposure:0=no exp, 1=exp"
label variable antihist_`x' "Antihistamine exposure:0=no exp, 1=exp"
label variable hyp_anx_`x' "Hypnotic/Anxiolytic exposure:0=no exp, 1=exp"
label variable psychoses_`x' "Drugs used in psychoses and related disorders exposure:0=no exp, 1=exp"
label variable antidepress_`x' "Antidepressant exposure:0=no exp, 1=exp"
label variable antiobes_`x' "Antiobesity drug exposure:0=no exp, 1=exp"
label variable opioid1_`x' "Opioid analgesic (CNS) exposure:0=no exp, 1=exp"
label variable antiepilep_`x' "Antiepileptic exposure:0=no exp, 1=exp"
label variable penicillin_`x' "Penicillin exposure: 0=no exp, 1=exp"
label variable ceph_carb_betalac_`x' "Cephalosporins, carbapenems and other beta-lactams exposure: 0=no exp, 1=exp"
label variable tetracyc_`x' "Tetracycline exposure: 0=no exp, 1=exp"
label variable aminoglyc_`x' "Aminoglycoside exposure: 0=no exp, 1=exp"
label variable macrolide_`x' "Macrolide exposure: 0=no exp, 1=exp"
label variable clinda_`x' "Clindamycin exposure: 0=no exp, 1=exp"
label variable otherantibiot_`x' "Other antibiotic exposure: 0=no exp, 1=exp"
label variable sulfo_trimeth_`x' "Sulfonamides and trimethoprim exposure: 0=no exp, 1=exp"
label variable antituberc_`x' "Antituberculosis drug exposure: 0=no exp, 1=exp"
label variable antileprotic_`x' "Antileprotic drug exposure: 0=no exp, 1=exp"
label variable metro_tinidazole_`x' "Metronidazole and tinidazole exposure: 0=no exp, 1=exp"
label variable quinolone_`x' "Quinolone exposure: 0=no exp, 1=exp"
label variable uti_drugs_`x' "UTI drug exposure: 0=no exp, 1=exp"
label variable antifungal_`x' "Antifungal exposure:0=no exp, 1=exp"
label variable antiviral_`x' "Antiviral exposure:0=no exp, 1=exp"
label variable antiprotoz_`x' "Antiprotozoal exposure:0=no exp, 1=exp"
label variable anthelmintic_`x' "Anthelmintic exposure:0=no exp, 1=exp"
label variable thyroidhorm_`x' "Thyroid hormone exposure: 0=no exp, 1=exp"
label variable cortico_endocr_`x' "Corticosteroid (endocrine) exposure:0=no exp, 1=exp"
label variable estro_hrt_`x' "Estrogen and HRT exposure: 0=no exp, 1=exp"
label variable bisphos_`x' "Bisphosphonate drug exposure: 0=no exp, 1=exp"
label variable cytotoxic_`x' "Cytotoxic drug exposure:0=no exp, 1=exp"
label variable antilymph_mab_`x' "Antilymphocyte monoclonal antibody exposure:0=no exp, 1=exp"
label variable otherimmunomodul_`x' "Other immunomodulating drug exposure:0=no exp, 1=exp"
label variable iron_oral_`x' "Oral iron exposure: 0=no exp, 1=exp"
label variable iron_parenteral_`x' "Parenteral iron exposure: 0=no exp, 1=exp"
label variable potassium_oral_`x' "Oral potassium exposure: 0=no exp, 1=exp"
label variable multivit_`x' "Multivitamin exposure: 0=no exp, 1=exp"
label variable nsaid_`x' "NSAID exposure: 0=no exp, 1=exp"
label variable cortico_inject_`x' "Corticosteroid (local inj) exposure:0=no exp, 1=exp"
label variable antigout_`x' "Antigout drug exposure: 0=no exp, 1=exp"
label variable antirheum_`x' "Antirheumatic drug exposure: 0=no exp, 1=exp"
label variable benzo_`i' "Benzodiazepine exposure: 0=no exp, 1=exp" 
label variable opioid2`x' "Opioid analgesic (anaes) exposure: 0=no exp, 1=exp"
label variable opioid`x' "any opioid exposure: 0=no exp, 1=exp"
label variable cortico_oral`x' "any oral corticosteroid exposure: 0=no exp, 1=exp"
label variable antipark_dop`x' "Antiparkison's dopaminergic drug exposure:0=no exp, 1=exp"
label variable antibacterial`x' "Antibacterial drug exposure: 0=no exp, 1=exp"
label variable antiprolif`x' "Antiproliferative immunosuppresant exposure:0=no exp, 1=exp"
label variable otherimmunosuppress`x' "Corticosteroids and other immunosuppresant exposure:0=no exp, 1=exp"
label variable immunosuppress_all`x' "Any immunosuppressant drug exposure:0=no exp, 1=exp"
save Drug_Covariates_s.dta, replace
clear

timer off 1
timer list 1

exit
log close
