//  program:    Data06_demographics.do
//  task:		Generate variables indicating demographics
//  project: 	Incretins--Comparative mortality and CV outcomes (CPRD)
//  author:     MA \ May2014 

clear all
capture log close
set more off

log using Data06.smcl, replace
timer on 1

// #1 Merge Dates dataset with Patient.

use Patient
sort patid
merge m:1 patid using Dates, keep(match using) nogen
save Patient2.dta, replace

// #2 Generate variables for sex (binary) and age (at cohort entry date/index date/study entry date)
// Note that for sex, patients could be coded as data not entered, indeterminate or unknown as well as male or female, 
// however our population is restricted to patients who are gender male or female.


gen sex = .
replace sex = 0 if gender==1
replace sex = 1 if gender==2
label variable sex "0=male, 1=female"

gen birthyear = 0
replace birthyear = yob2
format birthyear %ty

gen yob_cohortentrydate = year(cohortentrydate)
gen yob_indexdate = year(indexdate)
gen yob_studyentrydate = year(studyentrydate)

gen age_cohortdate = yob_cohortentrydate-birthyear

gen age_indexdate = yob_indexdate-birthyear   

gen age_studyentrydate = yob_studyentrydate-birthyear    

// #3 Generate categorical variable for marital status: (1 = data not entered or unknown or missing, 2=single, 3=married, 4=widowed 
//					5= divorced or separated, 6= other (engaged, remarried, co-habiting, stable relationship, civil partnership)

gen maritalstatus =.
replace maritalstatus = 1 if marital==0|marital==6|marital==.
replace maritalstatus = 2 if marital==1
replace maritalstatus = 3 if marital==2
replace maritalstatus = 4 if marital==3
replace maritalstatus = 5 if marital==4|marital==5
replace maritalstatus = 6 if marital==7|marital==9|marital==8|marital==10|marital==11
label variable maritalstatus "Marital status: 1=data not entered/unknown, 2=single, 3=married, 4=widowed, 5=divorced or separated, 6=other(engaged,remarried,co-habiting,stable relationship, civil partnership)"

compress
save Demographic.dta, replace 

////////////////////////////////////////////

timer off 1 
timer list 1

exit
log close

