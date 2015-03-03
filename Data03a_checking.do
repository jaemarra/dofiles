//  program:    Data03_checking.do
//  task:		Check .dta files generated in Data03_drug_exposures_a for data normality
//  project: 	Incretins--Comparative mortality and CV outcomes (CPRD)
//  author:     JM \ Jan2015


clear all
capture log close
set more off
ssc install mdesc
timer clear 1
timer on 1

//DATA_03_DRUG_EXPOSURES_A
//adm_drug_exposures
clear all
capture log close
log using linkage_eligibility.smcl
use linkage_eligibility.dta
compress
describe
codebook, compact
tab end
tab linked_b
log close

//adm_drug_exposures
clear all
capture log close
log using adm_drug_exposures.smcl
use adm_drug_exposures.dta
compress
codebook, compact
tab rxtype
log close

//Drug_Exposures_a
clear all
capture log close
log using Drug_Exposures_a.smcl
use Drug_Exposures_a.dta, clear
compress
describe
codebook, compact
//tabulate the individual exposure classes
tab firstadmrx
tab secondtadmrx
tab thirdadmrx
tab fourthadmrx
tab fifthadmrx
tab sixthadmrx
tab seventhadmrx
//Look at the distribution of total exposure
hist metformintotexp, frequency
graph save Graph Data_exposures_a_metformintotexp.gph
hist sulfonylureatotexp, frequency
graph save Graph Data_exposures_a_sulfonylureatotexp.gph
hist dpptotexp, frequency
graph save Graph Data_exposures_a_dpptotexp.gph
hist glptotexp, frequency
graph save Graph Data_exposures_a_glptotexp.gph
hist insulintotexp, frequency
graph save Graph Data_exposures_a_insulintotexp.gph
hist tzdtotexp, frequency
graph save Graph Data_exposures_a_tzdtotexp.gph
hist otherantidiabtotexp, frequency
graph save Graph Data_exposures_a_otherantidiabtotexp.gph
//Check that dates are ordered appropriately
assert indext0<=tx if indext0!=.&tx!=.
//Check that gaps are all positive and non-gaps are all negative
assert >=0 if exposure_b==0&duration!=.
//Check for start and end dates to follow the categories expected for HES/ONS/CPRD
tab start
tab end
log close

//Dates
clear all
capture log close
log using Dates.smcl
use Dates.dta
compress
describe
codebook, compact
mdesc
hist studyentrydate_cprd2, frequency
graph save Graph Dates_studyentrydate_cprd2.gph
hist cohortentrydate, frequency
graph save Graph Dates_cohortentrydate.gph
hist indexdate, frequency
graph save Graph Dates_indexdate.gph
log close

//Analytic_variables_a
clear all
capture log close
log using Analytic_variables_a.smcl
use Analytic_variables_a.dta, clear
compress
describe
codebook, compact
mdesc
//confirm the correct number of patid's are in each cohort and the only possible values are 0 and 1
tab cohort_b
//should eb 130230 unique patids
unique patid if cohort_b==1
tab unqrx
//confirm that ever6 (ever exposed to metformin) catures all patients with ANY exposure to metformin (>140k)
unique patid if ever6==1
hist tx
graph save Graph Analytic_variables_a_tx.gph
hist firstadmrxdate
graph save Graph Analytic_variables_a_firstadmrxdate.gph
hist seconddate
graph save Graph Analytic_variables_a_seconddate.gph
log close

//Drug_Exposures_a_wide
clear all
capture log close
log using Drug_Exposures_a_wide.smcl
use Drug_Exposures_a_wide.dta, clear
compress
describe
codebook, compact
//NOT SURE WHAT TO CHECK FOR THIS DATASET- ALL VARS CHECKED ABOVE AND THEN MERGED/RESHAPED
log close

timer off 1








