//  program:    Data00_exclusion.do
//  task:		Import clinical and hes patients and mark for exclusion based on pregnancy-related markers
//  project: 	Incretins--Comparative mortality and CV outcomes (CPRD)
//  author:     JM \ Jan2015

clear all
capture log close
set more off
set trace on
log using Data00.smcl, replace
timer on 1 

//Exclusion bsed on pregnancy, pcos, and gestational diabetes markers

//CPRD
foreach file in Clinical001_2 Clinical002_2 Clinical003_2 Clinical004_2 Clinical005_2 Clinical006_2 Clinical007_2 Clinical008_2 ///
				Clinical009_2 Clinical010_2 Clinical011_2 Clinical012_2 Clinical013_2 {
use `file', clear
keep patid readcode
sort patid
//generate exclusion variables
gen pcos = .
gen gest_diab = .
gen preg = .
//populate variables with binary code 1=pregnancy-related marker, 0=no pregnancy-related marker"
replace pcos = 1 if regexm(readcode, "C164.00 | C165.00")
replace gest_diab = 1 if regexm(readcode, "L180811 | L180900")
replace preg = 1 if regexm(readcode, "62...00 | 62B..00 | 465.00 | Y60 | Y60 AA | 62...12 | L 134 | 4654.00 | L 134P | 62N..00 | 62...11")
//append outcomes into one file
if "`file'" == "Clinical001_2" {
save Exclusion_cprd, replace
}
else {
append using Exclusion_a
save Exclusion_cprd, replace
}
}
//collapse to one per patid and label
bysort patid: egen pcos_g = max(pcos)
drop pcos
label var pcos_g "PCOS CPRD: 1=presence of PCOS, 0=no PCOS diagnostic code"
bysort patid: egen gest_diab_g = max(gest_diab)
drop gest_diab
label var gest_diab_g "Gestational Diabetes CPRD: 1=presence of GD, 0=no GD diagnostic code"
bysort patid: egen preg_g = max(preg)
drop preg
label var preg_g "Pregnancy CPRD: 1=presence of pregnancy, 0=no pregnancy-related diagnostic code"

//check for duplicates
bysort patid: gen dupck = cond(_N==1,0,_n)
drop if dupck>1
save Exclusion_cprd, replace

//HES
import hes, clear
sort patid

//generate exclusion variables
gen pcos = .
gen gest_diab = .
gen preg = .

//populate variables with binary code 1=pregnancy-related marker, 0=no pregnancy-related marker"
replace pcos = 1 if regexm(icd, "E28 | E28.2") 
replace pcos = 1 if regexm(icd_primary, "E28 | E28.2")
replace gest_diab = 1 if regexm(icd, "024.429 | 024.424 | 024.419 | 024.424")
replace gest_diab = 1 if regexm(icd_primary, "024.429 | 024.424 | 024.419 | 024.424")
replace preg = 1 if regexm(icd, "Z35 | Z37 | Z38 | Z32.1 | Z33 | Z34.0 | Z34.8 | Z34.9")
replace preg = 1 if regexm(icd_primary, "Z35 | Z37 | Z38 | Z32.1 | Z33 | Z34.0 | Z34.8 | Z34.9")

//collapse to one per patid and label
bysort patid: egen pcos_h = max(pcos)
drop pcos
label var pcos_h "PCOS HES: 1=presence of PCOS, 0=no PCOS diagnostic code"
bysort patid: egen gest_diab_h = max(gest_diab)
drop gest_diab
label var gest_diab_h "Gestational Diabetes HES: 1=presence of GD, 0=no GD diagnostic code"
bysort patid: egen preg_h = max(preg)
drop preg
label var preg_h "Pregnancy HES: 1=presence of pregnancy, 0=no pregnancy-related diagnostic code"

//check for duplicates
bysort patid: gen dupck = cond(_N==1,0,_n)
drop if dupck>1

save Exclusion_hes, replace


//merge
clear all
use Exclusion_cprd
merge 1:1 patid using Exclusion_hes
save Exclusion_merged, replace
timer off 1 
timer list 1

exit
log close
