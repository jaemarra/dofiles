//  program:    Data09_fixedvariables.do
//  task:       Generate a variable to capture anytime height to avoid missingness in a fixed variables
//  project:    Incretins--Comparative mortality and CV outcomes (CPRD)
//  author:     MA \ May 2014 modified by JM \ Jan 2015

clear all
capture log close
set more off
set trace on
log using Data09a.log, replace
timer on 1

// #1 Use data files generated in Data02_Support
// Keep only if eventdate2 is before indexdate.
timer on 2
foreach file in Clinical001_2 Clinical002_2 Clinical003_2 Clinical004_2 Clinical005_2 Clinical006_2 Clinical007_2 Clinical008_2 Clinical009_2 Clinical010_2 Clinical011_2 Clinical012_2 Clinical013_2 {
use `file', clear
sort patid
merge m:1 patid using Dates, keep(match) nogen
sort patid
joinby patid adid using Additional, unmatched(master) _merge(Additional_merge)
merge m:1 patid using Patient, keep(match) nogen
compress
save `file'b.dta, replace
}
clear
timer off 2
timer list 2

//Use Clinical files merged with Dates, Additional, and Patient for all subsequent work
foreach file in Clinical001_2b Clinical002_2b Clinical003_2b Clinical004_2b Clinical005_2b Clinical006_2b Clinical007_2b Clinical008_2b Clinical009_2b Clinical010_2b Clinical011_2b Clinical012_2b Clinical013_2b {
use `file', clear
keep patid enttype eventdate2 indexdate data3 data1
sort patid
keep if enttype==13|enttype==14
//save and append
if "`file'"=="Clinical001_2b" {
save Clinical_Covariates_bmi, replace
}
else {
append using Clinical_Covariates_bmi
save Clinical_Covariates_bmi, replace
}
}
// #2 Generate variables (continuous and binary) for clinical covariates; restrict to appropriate ranges; assign covtype.
use Clinical_Covariates_bmi, clear
//BMI
//gen continuous
gen bmi=.
replace bmi=data3 if enttype==13
label variable bmi "BMI (kg/m^2)"
//restrict
replace bmi =. if bmi<15|bmi>70
//eliminate redundancy
bysort patid eventdate2: egen nr_bmi=mean(bmi) if bmi<.
tempvar dup_bmi
bysort patid eventdate2: gen `dup_bmi' = cond(_N==1,0,_n)
replace nr_bmi=. if `dup_bmi'>1 & nr_bmi<.
//generate date of interest
gen eltestdate2 = .
replace eltestdate2 = eventdate2 if nr_bmi<.&eventdate2<.
format eltestdate2 %td
replace eltestdate2=. if `dup_bmi'>1 & nr_bmi<.
drop `dup_bmi'
//pull out bmi dates of interest (last before and first after index)
bysort patid: egen prx_covdate_g_ai15_preindex = max(eltestdate2) if eltestdate2<indexdate
xfill prx_covdate_g_ai15_preindex, i(patid)
bysort patid: egen prx_covdate_g_ai15_postindex = min(eltestdate2) if eltestdate2>=indexdate
xfill prx_covdate_g_ai15_postindex, i(patid)
//generate any before index date
bysort patid: gen prx_covdate_g_ai15_any=.
bysort patid: replace prx_covdate_g_ai15_any=prx_covdate_g_ai15_preindex
format prx_covdate_g_ai15_preindex prx_covdate_g_ai15_postindex prx_covdate_g_ai15_any %td
//determine whether last before or first after is closest to the indexdate
gen before_closest = indexdate-prx_covdate_g_ai15_preindex
gen after_closest = prx_covdate_g_ai15_postindex-indexdate
gen closest=.
replace closest=after_closest if prx_covdate_g_ai15_postindex!=.
replace closest=before_closest if prx_covdate_g_ai15_preindex!=.
gen closest_b=.
//generate an indicator for the closest date to the index
replace closest_b=0 if closest==.
replace closest_b=1 if closest==before_closest&closest!=.
replace closest_b=2 if closest==after_closest&closest!=.
//pull out closest date to indexdate chosing the last before if it is equidistant compared to first after
gen prx_covdate_g_ai15_closest=.
replace prx_covdate_g_ai15_closest=prx_covdate_g_ai15_preindex if closest_b==1
replace prx_covdate_g_ai15_closest=prx_covdate_g_ai15_postindex if closest_b==2
drop before_closest after_closest
//pull out covariate value of interest
bysort patid: gen prx_covvalue_g_ai15_any = nr_bmi if prx_covdate_g_ai15_any==eltestdate2
gen prx_covvalue_g_ai15_closest =nr_bmi if prx_covdate_g_ai15_closest==eltestdate2
replace prx_covvalue_g_ai15_closest= prx_covvalue_g_ai15_any if indexdate==.
format prx_covdate_g_ai15_closest %td
drop prx_covdate_g_ai15_preindex prx_covdate_g_ai15_postindex closest closest_b eltestdate2 bmi nr_bmi
xfill prx_covdate_g_ai15_any, i(patid)
xfill prx_covdate_g_ai15_closest, i(patid)
xfill prx_covvalue_g_ai15_any, i(patid)
xfill prx_covvalue_g_ai15_closest, i(patid)

//HEIGHT
//gen continuous
gen height=.
replace height=data1 if enttype==14
label variable height "HEIGHT (m)"
//restrict
replace height =. if height<=1|(height >= 3 & height <.)|(enttype==14 & data1==0)
//eliminate redundancy
bysort patid eventdate2: egen nr_height=mean(height) if height<.
tempvar dup_height
bysort patid eventdate2: gen `dup_height' = cond(_N==1,0,_n)
replace nr_height=. if `dup_height'>1 & nr_height<.
//generate date of interest
gen eltestdate2 = .
replace eltestdate2 = eventdate2 if nr_height<.&eventdate2<.
format eltestdate2 %td
replace eltestdate2=. if `dup_height'>1 & nr_height<.
drop `dup_height'
//pull out bmi dates of interest (last before and first after index)
bysort patid: egen prx_covdate_g_ai1_preindex = max(eltestdate2) if eltestdate2<indexdate
xfill prx_covdate_g_ai1_preindex, i(patid)
bysort patid: egen prx_covdate_g_ai1_postindex = min(eltestdate2) if eltestdate2>=indexdate
xfill prx_covdate_g_ai1_postindex, i(patid)
//generate any before index date
bysort patid: gen prx_covdate_g_ai1_any=.
bysort patid: replace prx_covdate_g_ai1_any=prx_covdate_g_ai1_preindex
format prx_covdate_g_ai1_preindex prx_covdate_g_ai1_postindex prx_covdate_g_ai1_any %td
//determine whether last before or first after is closest to the indexdate
gen before_closest = indexdate-prx_covdate_g_ai1_preindex
gen after_closest = prx_covdate_g_ai1_postindex-indexdate
gen closest=.
replace closest=after_closest if prx_covdate_g_ai1_postindex!=.
replace closest=before_closest if prx_covdate_g_ai1_preindex!=.
gen closest_b=.
//generate an indicator for the closest date to the index
replace closest_b=0 if closest==.
replace closest_b=1 if closest==before_closest&closest!=.
replace closest_b=2 if closest==after_closest&closest!=.
//pull out closest date to indexdate chosing the last before if it is equidistant compared to first after
gen prx_covdate_g_ai1_closest=.
replace prx_covdate_g_ai1_closest=prx_covdate_g_ai1_preindex if closest_b==1
replace prx_covdate_g_ai1_closest=prx_covdate_g_ai1_postindex if closest_b==2
drop before_closest after_closest
//pull out covariate value of interest
bysort patid: gen prx_covvalue_g_ai1_any = nr_height if prx_covdate_g_ai1_any==eltestdate2
gen prx_covvalue_g_ai1_closest =nr_height if prx_covdate_g_ai1_closest==eltestdate2
replace prx_covvalue_g_ai1_closest= prx_covvalue_g_ai1_any if indexdate==.
format prx_covdate_g_ai1_closest %td
drop prx_covdate_g_ai1_preindex prx_covdate_g_ai1_postindex closest closest_b eltestdate2 height nr_height
xfill prx_covdate_g_ai1_any, i(patid)
xfill prx_covdate_g_ai1_closest, i(patid)
xfill prx_covvalue_g_ai1_any, i(patid)
xfill prx_covvalue_g_ai1_closest, i(patid)

//WEIGHT
//gen continuous
gen weight=.
replace weight=data1 if enttype==13
label variable weight "WEIGHT (kg)"
//restrict
replace weight =. if weight <= 20 | (weight >= 300 & weight <.)
//eliminate redundancy
bysort patid eventdate2: egen nr_weight=mean(weight) if weight<.
tempvar dup_weight
bysort patid eventdate2: gen `dup_weight' = cond(_N==1,0,_n)
replace nr_weight=. if `dup_weight'>1 & nr_weight<.
//generate date of interest
gen eltestdate2 = .
replace eltestdate2 = eventdate2 if nr_weight<.&eventdate2<.
format eltestdate2 %td
replace eltestdate2=. if `dup_weight'>1 & nr_weight<.
drop `dup_weight'
//pull out weight dates of interest (last before and first after index)
bysort patid: egen prx_covdate_g_ai2_preindex = max(eltestdate2) if eltestdate2<indexdate
xfill prx_covdate_g_ai2_preindex, i(patid)
bysort patid: egen prx_covdate_g_ai2_postindex = min(eltestdate2) if eltestdate2>=indexdate
xfill prx_covdate_g_ai2_postindex, i(patid)
//generate any before index date
bysort patid: gen prx_covdate_g_ai2_any=.
bysort patid: replace prx_covdate_g_ai2_any=prx_covdate_g_ai2_preindex
format prx_covdate_g_ai2_preindex prx_covdate_g_ai2_postindex prx_covdate_g_ai2_any %td
//determine whether last before or first after is closest to the indexdate
gen before_closest = indexdate-prx_covdate_g_ai2_preindex
gen after_closest = prx_covdate_g_ai2_postindex-indexdate
gen closest=.
replace closest=after_closest if prx_covdate_g_ai2_postindex!=.
replace closest=before_closest if prx_covdate_g_ai2_preindex!=.
gen closest_b=.
//generate an indicator for the closest date to the index
replace closest_b=0 if closest==.
replace closest_b=1 if closest==before_closest&closest!=.
replace closest_b=2 if closest==after_closest&closest!=.
//pull out closest date to indexdate chosing the last before if it is equidistant compared to first after
gen prx_covdate_g_ai2_closest=.
replace prx_covdate_g_ai2_closest=prx_covdate_g_ai2_preindex if closest_b==1
replace prx_covdate_g_ai2_closest=prx_covdate_g_ai2_postindex if closest_b==2
drop before_closest after_closest
//pull out covariate value of interest
bysort patid: gen prx_covvalue_g_ai2_any = nr_weight if prx_covdate_g_ai2_any==eltestdate2
gen prx_covvalue_g_ai2_closest =nr_weight if prx_covdate_g_ai2_closest==eltestdate2
replace prx_covvalue_g_ai2_closest= prx_covvalue_g_ai2_any if indexdate==.
format prx_covdate_g_ai2_closest %td
drop prx_covdate_g_ai2_preindex prx_covdate_g_ai2_postindex closest closest_b eltestdate2 weight nr_weight 
drop data1 data3 enttype eventdate2 indexdate
xfill prx_covdate_g_ai2_any, i(patid)
xfill prx_covdate_g_ai2_closest, i(patid)
xfill prx_covvalue_g_ai2_any, i(patid)
xfill prx_covvalue_g_ai2_closest, i(patid)

collapse (first) prx_covdate_g_ai15_any prx_covdate_g_ai15_closest prx_covvalue_g_ai15_any prx_covvalue_g_ai15_closest prx_covdate_g_ai1_any prx_covdate_g_ai1_closest prx_covvalue_g_ai1_any prx_covvalue_g_ai1_closest prx_covdate_g_ai2_any prx_covdate_g_ai2_closest prx_covvalue_g_ai2_any prx_covvalue_g_ai2_closest, by(patid)
save Fixed_variables, replace

clear
timer off 1
timer list 1
exit
log close
