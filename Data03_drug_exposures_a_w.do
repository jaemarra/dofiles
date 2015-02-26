//  program:    Data03_drug_exposures_a_wide.do
//  task:		Convert drug exposures data from long to wide
//  project: 	Incretins--Comparative mortality and CV outcomes (CPRD)
//  author:     JM \ Jan2015

use Drug_Exposures_a

fillin patid rxtype

gen exposuret0 = .
replace exposuret0 = metformint0 if rxtype==6
replace exposuret0 = sulfonylureat0 if rxtype==0
replace exposuret0 = dppt0 if rxtype==1
replace exposuret0 = glpt0 if rxtype==2
replace exposuret0 = insulint0 if rxtype==3
replace exposuret0 = tzdt0 if rxtype==4
replace exposuret0 = otherantidiabt0 if rxtype==5
label var exposuret0 "First exposure to class (rxdate2)"

//bysort patid: egen postindex= rowmin(metformint0 sulfonylureat0 dppt0 glpt0 insulint0 tzdt0 otherantidiabt0)

gen exposuretx = .
replace exposuretx = last if rxtype==6
replace exposuretx = last if rxtype==0
replace exposuretx = last if rxtype==1
replace exposuretx = last if rxtype==2
replace exposuretx = last if rxtype==3
replace exposuretx = last if rxtype==4
replace exposuretx = last if rxtype==5
label var exposuretx "Earliest of last date of exposure to class (rxdate2+predfactor) or censor"

gen exposuregap = .
replace exposuregap = metformingdur if rxtype==6
replace exposuregap = sulfonylureagdur if rxtype==0
replace exposuregap = dppgdur if rxtype==1
replace exposuregap = glpgdur if rxtype==2
replace exposuregap = insulingdur if rxtype==3
replace exposuregap = tzdgdur if rxtype==4
replace exposuregap = otherantidiabgdur if rxtype==5
replace exposuregap = 0 if exposuregap==.
label var exposuregap "Total number of UNexposed days in class treatment history"

gen exposure = .
replace exposure = (exposuretx-exposuret0)-exposuregap
label var exposure "Total exposure to class (in days)"

format exposuret0 exposuretx exposure %td
 
keep patid rxtype exposuret0 exposuretx exposure cohort_b 
collapse (first) exposuret0 exposuretx exposure cohort_b ,by(patid rxtype)
reshape wide exposuret0 exposuretx exposure cohort_b, i(patid) j(rxtype)
merge 1:1 patid using Analytic_variables, keep(match master) nogen
save Drug_Exposures_A_W.dta, replace

restore
