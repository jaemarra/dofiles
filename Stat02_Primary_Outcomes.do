//  program:    Stat02_Primary_Outcomes.do
//  task:		Statistical analyses of Analytic_Dataset_Master.dta to compare primary outcomes between classes of antidiabetics
//				Identify cohort, extract outcomes by indextype.
//  project: 	Incretins--Comparative mortality and CV outcomes (CPRD)
//  author:     JM \ Mar2015  
//				

clear all
capture log close
set more off
log using Data02.smcl, replace
timer on 1

use Analytic_Dataset_Master

//Unify exclusion criteria into a binary indicator
gen exclude=1 if (gest_diab==1|pcos==1|preg==1|age_indexdate<=29|cohort_b==0)
replace exclude=0 if exclude!=1
label var exclude "Bin ind for pcos, preg, gest_diab, or <30yo; excluded=1, not excluded=0)

drop if cohort_b!=1
drop if exclude!=0
drop if indextype!=.

//Generate a categorical variable to indicate the class of antidiabetic prescription at index
gen indextype=.
replace indextype=0 if secondadmrx=="SU"
replace indextype=1 if secondadmrx=="DPP"
replace indextype=2 if secondadmrx=="GLP"
replace indextype=3 if secondadmrx=="insulin"
replace indextype=4 if secondadmrx=="TZD"
replace indextype=5 if secondadmrx=="other"|secondadmrx=="DPPGLP"|secondadmrx=="DPPTZD"|secondadmrx=="DPPinsulin"|secondadmrx=="DPPother"|secondadmrx=="GLPTZD"|secondadmrx=="GLPinsulin"|secondadmrx=="GLPother"|secondadmrx=="SUDPP"|secondadmrx=="SUGLP"|secondadmrx=="SUTZD"|secondadmrx=="SUinsulin"|secondadmrx=="SUother"|secondadmrx=="TZDother"|secondadmrx=="insulinTZD"|secondadmrx=="insulinother"
replace indextype=6 if secondadmrx=="metformin"
label var indextype "Antidiabetic class at index (switch from or add to metformin)" 

//Using full CPRD Cohort
//recode cvprim_comp_g_i (0=1) (1=0) (MARCH172015 dataset or earlier only)
//All-cause mortality
gen allcausemort = 0
replace allcausemort = 1 if deathdate2!=.
label var allcausemort "All-cause mortality"
//Generate exit date for all cause mortality
forval i=0/5{
egen acm_exit`i' = rowmin(exposuretf`i' tod2 deathdate2 lcd2) 
format acm_exit`i' %td
label var acm_exit`i' "Exit date for acm follow-up for indextype=`i'"
}
egen acm_exit = rowmin(acm_exit0 acm_exit1 acm_exit2 acm_exit3 acm_exit4 acm_exit5)
format acm_exit %td
label var acm_exit "End of exposure to indextype prescription"
//Generate follow-up time for all-cause mortality
forval i=0/5{
gen acm_fup`i' = (acm_exit`i'-exposuret0`i') if exposuret0`i'!=.
replace acm_fup`i'=1 if exposuret0`i'==tx
label var acm_fup`i' "Follow up (in days) for all cause mortality outcome for indextype=`i'"
}
//Generate person-years, incidence rate, and 95%CI as well as hazard ratio
forval i=0/5{
stset acm_exit  if cohort_b==1&exclude==0, fail(allcausemort) id(patid) origin(seconddate) scale(365.35)
stptime, title(person-years), if cohort_b==1&exclude==0&indextype==`i'
stcox indextype
}

//Composite CV event
gen cvmajor = cvprim_comp_g_i 
label var cvmajor "Indicator for first major cv event (mi, stroke, cvdeath) 1=event, 0=no event"
//Total follow-up time
forval i=0/6{
egen cvmajor_exit`i' = rowmin(exposuretf`i' cvprim_comp_g_date_i lcd2) if indextype==`i'&exposuretf`i'!=.&cvprim_comp_g_date_i!=.
format cvmajor_exit`i' %td
label var cvmajor_exit`i' "Exit date for cvmajor follow-up for indextype=`i'"
}
forval i=0/6{
gen cvmajor_fup`i' = (cvmajor_exit`i'-exposuret0`i') if exposuret0`i'!=.
replace cvmajor_fup`i'=1 if exposuret0`i'==tx
label var cvmajor_fup`i' "Follow up (in days) for cvmajor outcome for indextype=`i'"
}
//Generate person-years, incidence rate, and 95%CI as well as hazard ratio
forval i=0/5{
stset cvmajor_fup`i', fail(cvmajor) id(patid), if cohort_b==1&exclude==0&indextype==`i'
stptime, title(person-years), if cohort_b==1&exclude==0&indextype==`i'
stcox, estimate
}
//MI: use myoinfarct_g
gen myoinf = myoinfarct_g
label var myoinf "Indicator for first MI 1=event, 0=no event"
//Total follow-up time
forval i=0/6{
egen mi_exit`i' = rowmin(exposuretf`i' cvprim_comp_g_date_i lcd2) if indextype==`i'&exposuretf`i'!=.&cvprim_comp_g_date_i!=.
format mi_exit`i' %td
label var mi_exit`i' "Exit date for cvmajor follow-up for indextype=`i'"
}
forval i=0/6{
gen mi_fup`i' = (mi_exit`i'-exposuret0`i') if exposuret0`i'!=.
replace mi_fup`i'=1 if exposuret0`i'==tx
label var mi_fup`i' "Follow up (in days) for mi outcome for indextype=`i'"
}
//Generate person-years, incidence rate, and 95%CI as well as hazard ratio
forval i=0/5{
stset mi_fup`i', fail(myoinf) id(patid), if cohort_b==1&exclude==0&indextype==`i'
stptime, title(person-years), if cohort_b==1&exclude==0&indextype==`i'
stcox, estimate
}

//Stroke: use stroke_g
//Total follow-up time 

//Death: use cvdeath_g
//Total follow-up time

//Number of events

//Incidence rate (IR)

//Upper limit for IR

//Lower limit for IR

//Crude Hazard Ratio (CHR)

//Upper limit for CHR

//Lower limit for CHR

//Using full HES-ONS LINKED ONLY
//All-cause mortality
gen allcausemort_gho=0 
replace allcausemort_gho = 1 if deathdate2!=.|dod2!=.
label var allcausemort_gho "All-cause mortality"
//Composite CV event
gen cvmajor_gho= 0
replace cvmajor_gho=1 if cvprim_comp_g_i|cvprim_h_i==1|cvprim_o_i==1
label var cvmajor_gho "Indicator for first major cv event (mi, stroke, cvdeath) 1=event, 0=no event"
//MI
gen myoinfarct_gho=0
replace myoinfarct_gho=1 if myoinfarct_g==1|myoinfarct_h==1|myoinfarct_o==1
//Stroke
gen stroke_gho = 0
replace stroke_gho=1 if stroke_g==1|stroke_h==1|stroke_o==1
//Death
gen cvdeath_gho=0
replace cvdeath_gho=1 if cvdeath_g==1|cvdeath_h==1|cvdeath_o==1
//Total follow-up time

//Number of events

//Incidence rate (IR)

//Upper limit for IR

//Lower limit for IR

//Crude Hazard Ratio (CHR)

//Upper limit for CHR

//Lower limit for CHR


//Generate tabs for each indextype for table 2
table1 if exclude==0&cohort_b==1, by(indextype) vars(allcausemort bin \ gender bin \ maritalstatus cat \ imd2010_5 cat \ prx_covvalue_g_i4 cat \ prx_covvalue_g_i5 cat \ weight_bin bin \ height_bin bin) format(%f9.2) onecol saving(sociodemographics.xls, replace)
