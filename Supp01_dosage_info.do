//  program:    Supp01_dosage_info.do
//  task:		Generate a data file conatining patid and prescription info only
//  project: 	Incretins--Comparative mortality and CV outcomes (CPRD)
//  author:     JM \ Jun2015


foreach file in Therapy001 Therapy002 Therapy003 Therapy004 Therapy005 Therapy006 Therapy007 Therapy008 ///
		Therapy009 Therapy010 Therapy011 Therapy012 Therapy013 Therapy014 Therapy015 Therapy016 Therapy017  {
clear 
import delimited PET_`file'.txt
label variable patid "Patient identifier"
//create and label date variable to change from string to numerical format
gen rxdate2=date(eventdate, "DMY")
format rxdate2 %td
drop eventdate
label variable rxdate2 "Prescription date"
//continue to label variables
drop consid
drop prodcode
drop bnfcode
label variable qty "Total quantity for prescribed product"
label variable ndd "Numeric daily dose"
label variable numdays "Number of treatment days prescribed"
label variable numpacks "Number of individual product packs prescribed"
label variable packtype "Pack size or type of prescribed product"
label variable issueseq "Issue sequence number, 0=no repeat"
destring textid, gen(textid2) force
drop textid
rename textid2 textid
label var textid "Linkage to common dosages information"
//drop irrelevant variables
capture drop sysdate staffid bnfchapter
//sort, merge with patients (patid, studyentrydate_cprd2), optimze data storage
sort patid
merge m:1 patid using BasePatidDate, keep(match) nogen
//restrict to 1 year prior to studyentrydate_cprd2
drop if rxdate2<studyentrydate_cprd2-365
save `file'.dta, replace
//Consolidate into one therapy file
if "`file'"=="Therapy001"	{
save TherapyRx, replace
}
else	{
append using TherapyRx
save TherapyRx, replace
}
}
merge m:1 textid using commondosages, keep(match master) nogen
save Dosage_Info, replace
