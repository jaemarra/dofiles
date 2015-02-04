//  program:    Data02_support_v4.do
//  task:		Data management of CPRD Data
//				for six support files, import .txt file, re-label variables, change date formats and save as .dta files. Merge support files with data files.
//  project: 	Incretins--Comparative mortality and CV outcomes (CPRD)
//  author:     MA \ May2014 (some codes from Cindy's original coding. See sample dataset .do files) Modified: JM \ Nov2014

clear all
capture log close
set more off

log using Data02.smcl, replace
timer on 1

// #1 Import/label/date/save support files

//BNF codes: bnf_nom, bnfcode
import delimited bnfcodes.txt
//bnfcode formerly bnf_nom
rename bnfcode bnf_nom
label variable bnf_nom "Secondary code for the actual BNF code of product"
rename bnf bnfcode
label variable bnfcode "Chapter and section for the product (nn.nn.nn.nn: nnnnnnnn)"
sort bnfcode
compress
save Bnfcodes.dta, replace
clear all 

//Common Dosages: daily_dose, dose_number, dose_unit, dose)frequency, dose_interval, choice_of_dose, dose_max_average, change_dose, dose_duration
import delimited common_dosages.txt
label variable textid "Identifier that allows freetext information (dosage) on therapy events"
label variable text "Anonymised textual dose associated with the therapy textid"
label variable daily_dose "Numerical equivalent of the given textual dose given in a per day format"
label variable dose_number "Amount per dose"
label variable dose_unit "Unit per dose"
label variable dose_frequency "Dose frequency per day"
label variable dose_interval "Days of Rx (1 every 2 weeks = 14, 4 in one day = 0.25)"
label variable choice_of_dose "Indicates if there is a choice the user can make as to how much they can take"
label variable dose_max_average "If dose was averaged, value = 2, if maximum was taken, value = 1, otherwise 0"
label variable change_dose "If an option between 2 parts of the dose was available, indicates the part used"
label variable dose_duration "If specified, the number of days the prescription is for"
encode dose_unit, generate (ndose_unit)
label variable ndose_unit "Unit of each dose in numerical format"
compress
save commondosages.dta, replace
clear all 

//Medical
import delimited medical.txt
label variable medcode "CPRD unique code for medical term"
label variable readcode "Read Code"
label variable desc "Description of the medical term"
sort medcode
compress
save medical.dta, replace
clear all 

//Pack Type

import delimited packtype.txt
label variable packtype "Coded value associated with the pack size or type of the prescribed product"
label variable packtype_desc "Pack size or type of the prescribed product"
sort packtype
compress
save packtype.dta, replace
clear all 

//Product
import delimited product.txt
label variable prodcode "CPRD unique code for treatment"
//label variable gemscriptcode "Gemscript product code"   
label variable productname "Product name"
label variable drugsubstance "Drug substance"
label variable strength "Strength of the product"
label variable formulation "Form of the product"
label variable route "Route of administration of the product"
rename bnfcode prod_bnfcode
label variable prod_bnfcode "British National Formulary (BNF) code"
label variable bnfchapter "British National Formulary (BNF) chapter"
//generate new variable "nroute" in numerical format for variable "route" in string format 
encode route, generate (nroute)
label variable nroute "Variable route in numerical format"
sort prodcode
compress
save product.dta, replace
clear all 

//Score Method
import delimited scoremethod.txt
label variable code "Coded value associated with the scoring methodology used"
label variable scoringmethod "Scoring methodology"
sort code
compress
save scoremethod.dta, replace
clear all 

// #2 Merge support files into data files.
// Before any merging, MUST ensure that variable names and value labels are UNIQUE.
// Merge product, bnfcodes, packtype (support info) into Therapy. m:1 merging used, Therapy is master dataset.
// A) Merge bnfcodes into Therapy using key variable bnf_nom. Drop observations that do not contain patient information but only bnf_nom information and drop variable "_merge" before doing any further merges
// B) Merge packtype into therapy_bnf using key variable packtype
// C) Merge product into therapy_bnf_packtype using key variable prodcode

		forval i=0/49   {         
		use Therapy_`i', clear
		sort bnf_nom
		merge m:1 bnf_nom using Bnfcodes, keep(match master) nogen
		sort packtype
		merge m:1 packtype using packtype, keep(match master) nogen
		sort prodcode
		merge m:1 prodcode using product, keep(match master) nogen
		drop bnfchapter formulation strength consid
		compress
		save Therapy_`i'.dta, replace
		}
		
		//Merge medical into Clinical using key variable medcode
foreach file in Clinical001 Clinical002 Clinical003 Clinical004 Clinical005 ///
		Clinical006 Clinical007 Clinical008 Clinical009 Clinical010 Clinical011 Clinical012 Clinical013 {
		clear all
		use `file'
		sort medcode
		merge m:1 medcode using medical, keep(match master) nogen
		compress
		save `file'_2.dta, replace
		}
		
// #3 Merge HES files together.
clear all
use BasePatidDate
merge 1:1 patid using hes_patient, keep(match master)
rename _merge hes_patient_merge
joinby patid using hes_hospital, unmatched(both) _merge(hes_hospital_merge)
joinby patid spno using hes_episodes, unmatched(both) _merge(hes_episodes_merge)
joinby patid spno epikey using hes_diagnosis_epi, unmatched(both) _merge(hes_diagnosis_epi_merge)
joinby patid spno using hes_diagnosis_hosp
joinby patid spno using hes_primary_diag_hosp, unmatched(both) _merge(hes_primary_diag_hosp_merge)
joinby patid spno epikey using hes_procedures, unmatched(both) _merge(hes_procedures_merge)
joinby patid spno epikey using hes_maternity, unmatched(both) _merge(hes_maternity_merge)
save hes.dta, replace
		
////////////////////////////////////////////
timer off 1
timer list 1

exit
log close

