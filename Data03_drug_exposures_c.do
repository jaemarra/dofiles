//  program:    Data03_drug_exposures_c.do
//  task:		Generate long form file indicating INSULIN exposures in CPRD dataset
//  project: 	Incretins--Comparative mortality and CV outcomes (CPRD)
//  author:     JM \ Jun2015


clear all
capture log close
set more off

log using Data03c.smcl, replace

timer clear 1
timer on 1

//Start with the base drug exposures file in long form
use adm_drug_exposures, clear

//merge in analytic variables
merge m:1 patid using Analytic_variables_a, gen(flag)

//tidy labels
label var tx "Censor date calculated as first of lcd, tod"
label var cohort_b "Binary indicator; 1=metformin first only cohort; 0=not in cohort"
label var unqrx "Number of unique antidiabetic medications"

//merge in exclusion variables (pcos, preg, gestational diabetes)
merge m:1 patid using Exclusion_merged, gen(flag2)

//merge in dates and Patient file to get the age at indexdate
merge m:1 patid using Dates, nogen
merge m:1 patid using Patient, nogen

//generate age at indexdate variable
gen birthyear = 0
replace birthyear = yob2
format birthyear %ty
gen yob_indexdate = year(indexdate)
gen age_indexdate = yob_indexdate-birthyear      

//generate the same exclusion pattern used in Data13 dofile
gen exclude=1 if (gest_diab==1|pcos==1|preg==1|age_indexdate<=29|cohort_b==0|tx<=seconddate)
replace exclude=0 if exclude!=1
label var exclude "Bin ind for pcos, preg, gest_diab, or <30yo; excluded=1, not excluded=0)
tab exclude

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

//save long form file
save Drug_Exposures_c, replace

timer off 1
log close
