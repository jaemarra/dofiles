//  program:    Data10_labcovariates_ckd.do
//  task:		Generate long form file indicating SERUM CREATININE levels in CPRD dataset
//  project: 	Incretins--Comparative mortality and CV outcomes (CPRD)
//  author:     JM \ Jun2015


clear all
capture log close
set more off

log using Data10ckd.smcl, replace

timer clear 1
timer on 1

//Start with the base drug exposures file in long form
use LabCovariates
bysort patid enttype: egen prx_testdate_i2 = max(eltestdate2) if eltestdate2<=indexdate
format prx_testdate_i2 %td
gen prx_test_i2_b = 1 if !missing(prx_testdate_i2)

//pull out lab value of interest
bysort patid enttype : gen prx_testvalue_i2 = nr_data2 if prx_testdate_i2==eltestdate2
drop if prx_testvalue_i2==.

//Check for duplicates again- no duplicates found then continue
bysort patid enttype: gen dupa = cond(_N==1,0,_n)
drop if dupa>1
drop dupa

//create counts
sort patid enttype eltestdate2
by patid enttype: generate lab_num = _n
by patid: egen lab_num_un = count(enttype) if lab_num==1 
by patid: egen lab_num_un_i_temp = count(enttype) if lab_num==1 & eltestdate2<=indexdate
by patid: egen lab_num_un_i = min(lab_num_un_i_temp)
drop lab_num_un_i_temp

//merge in analytic variables
merge m:1 patid using Analytic_variables_a, gen(flag)

//tidy labels
label var tx "Censor date calculated as first of lcd, tod"
label var cohort_b "Binary indicator; 1=metformin first only cohort; 0=not in cohort"
label var unqrx "Number of unique antidiabetic medications"

//merge in exclusion variables (pcos, preg, gestational diabetes)
merge m:1 patid using Exclusion_merged, gen(flag2)

//generate cohort of interest
drop if exclude==1
drop if seconddate<17167

//generate indextype
gen indextype=.
replace indextype=0 if secondadmrx=="SU"
replace indextype=1 if secondadmrx=="DPP"
replace indextype=2 if secondadmrx=="GLP"
replace indextype=3 if secondadmrx=="insulin"
replace indextype=4 if secondadmrx=="TZD"
replace indextype=5 if secondadmrx=="other"|secondadmrx=="DPPGLP"|secondadmrx=="DPPTZD"|secondadmrx=="DPPinsulin"|secondadmrx=="DPPother"|secondadmrx=="GLPTZD"|secondadmrx=="GLPinsulin"|secondadmrx=="GLPother"|secondadmrx=="SUDPP"|secondadmrx=="SUGLP"|secondadmrx=="SUTZD"|secondadmrx=="SUinsulin"|secondadmrx=="SUother"|secondadmrx=="TZDother"|secondadmrx=="insulinTZD"|secondadmrx=="insulinother"
replace indextype=6 if secondadmrx=="metformin"
label var indextype "Antidiabetic class at index (switch from or add to metformin)" 
label define exposure 0 "SU" 1 "DPP4i" 2 "GLP1RA" 3 "INS" 4 "TZD" 5 "OTH" 6 "MET"
label value indextype exposure 

//keep insulin users only
keep if indextype==3

//remove all non-insulin prescriptions
keep if insulin==1

//drop extraneous variables- anything you want me to drop here??

save LabCovariates_ckd, replace

timer off 1
log close
