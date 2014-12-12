//  program:    Data07_ses.do
//  task:		Import SES data (will be merged at later step)
//  project: 	Incretins--Comparative mortality and CV outcomes (CPRD)
//  author:     MA \ May2014 

clear all
capture log close
set more off

log using Data07.smcl, replace
timer on 1 

//Socioeconomic status

import delimited PatientSES_imd2010_13_100.txt
sort patid
merge m:1 patid using Dates, keep(match using) nogen
replace imd2010_5 = 9 if imd2010_5==.
label var imd2010_5 "1=least deprived, 5= most deprived, 9 = missing"
compress
save ses.dta, replace

////////////////////////////////////////////

timer off 1 
timer list 1

exit
log close
