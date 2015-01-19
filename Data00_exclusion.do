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

//Exclusion bsed on pregnancy, pcos, and gestational diabetes markers.

foreach file in Clinical001_2 Clinical002_2 Clinical003_2 Clinical004_2 Clinical005_2 Clinical006_2 Clinical007_2 Clinical008_2 ///
				Clinical009_2 Clinical010_2 Clinical011_2 Clinical012_2 Clinical013_2 {
use `file', clear
keep patid readcode
sort patid
//generate exclusion variables
gen pcos_g = .
gen gest_diab_g = .
gen preg_g = .

//populate variables with binary code 1=pregnancy-related marker, 0=no pregnancy-related marker"
//PCOS
replace pcos_g = 1 if regexm(readcode, "C164.00 | C165.00")
label var pcos "PCOS: 1=presence of PCOS, 0=no PCOS diagnostic code"
//GD
replace gest_diab_g = 1 if regexm(readcode, "L180811 | L180900")
label var gest_diab "Gestational Diabetes: 1=presence of GD, 0=no GD diagnostic code"
//Preg
replace preg_g = 1 if regexm(readcode, "62...00 | 62B..00 | 465.00 | Y60 | Y60 AA | 62...12 | L 134 | 4654.00 | L 134P | 62N..00 | 62...11")
label var preg "Pregnancy: 1=presence of pregnancy, 0=no pregnancy-related diagnostic code"

if "`file'" == "Clinical001_2" {
save Exclusion_a, replace
}
else {
append using Exclusion_a
save Exclusion_a, replace
}
}

import hes

compress
save Exclusion.dta, replace

timer off 1 
timer list 1

exit
log close
