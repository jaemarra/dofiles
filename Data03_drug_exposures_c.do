//  program:    Data03_drug_exposures_c.do
//  task:		Generate long form file indicating INSULIN exposures in CPRD dataset
//  project: 	Incretins--Comparative mortality and CV outcomes (CPRD)
//  author:     JM \ Jun2015


clear all
capture log close
set more off

log using Data03_c.smcl, replace

timer clear 1
timer on 1

forval i=0/49 {
use Therapy_`i'dm, clear
keep patid rxdate2 gemscriptcode qty ndd issueseq

// Short-acting insulins (could include intermediate- and long-acting because of use of word "insulin"...but could miss some without it)
local shortinscodes = "(04841007|82381020|49835020|49830020|58583020|55081020|58584020|79661020|05798007|04837007|58580020|55087020|74874020|03712007|49847020|52197020|49944020|54941020|55080020|74960020|79670020|03713007|79669020|79667020|79664020|50442020|04153007|79674020|79671020|70111020|74957020|79673020|79666020|59680020|67848020|51331020|59681020|59679020|63811020|03710007|55084020|52542020|49843020|50163020|79676020|55179020|82387020|82442020|79663020|56543020|82033020|79190020|79182020|79677020|78521020|76207020|83429020|50497020|81577020|87908020|87906020|90297020|90209020|90337020|90339020|90295020|90658020|90311020|90199020|90191020|90427020|90333020|90331020|90335020|52830020|04835007|04836007|05797007|03311007|54128020|54127020|06862007|79706020|03212007|04834007|79702020|69694020|63796020|03717007|06860007|03310007|04831007|03935007|59685020|49940020|00023007|80932020|63802020|57900020|85937020|79708020|84665020|82035020|76875020|83427020|80950020|87904020|90265020|90654020|90271020|90277020|90319020|90227020|90195020|90329020|90313020|90213020|70082020|03953007|03715007|59676020|03451007|63781020|03716007|69774020|79705020|79704020|80959020|80960020|80952020|59684020|78930020|63840020|03704007|03705007|57909020|51532020|80944020|80948020|79678020|90477020|63790020|57906020|03955007|84620020|80954020|84628020|80930020|90321020|90479020|90343020|90323020|90305020|90325020|90469020|90459020|89726020|90275020|90307020|03714007|63825020|03923007|63818020|80931020|80958020|90273020|90263020|90652020|90451020|90435020|90465020|90185020|03708007|78679020|63808020|03707007|80946020|70102020|90181020|90287020|90203020|90219020|05522007|54038020|63793020|63834020|57903020|74965020|79710020|90309020|06532007|80956020|90455020|90463020|90757020|03709007|63805020|89723020|90215020|!3474903|!3498103|90289020|90207020|02399007|02397007|79680020|!3473801|!3471801|90443020|80966020|90205020|90183020|74963020|80965020|80962020|90225020|78682020|90385020|90387020|!3480103|70187020|!3477701|79711020|!3477601|!3522501|80963020|!8504807|00021007|84932020|90187020|02401007|90293020|90467020|90283020|90189020|90255020|!3510610|63828020|00022007|90291020|90441020|03204007|70202020|02400007|90257020|!3474503|90259020|90447020|90197020|90193020|90267020|90303020|90449020|70184020|80928020|86843020|02398007|82443020|90437020|90445020|90177020|90279020|70049020|!3474502|90233020|90341020|90433020|90315020|89720020|90461020|!3510609|03205007|90285020|86928020|91628020|54131020|63843020|90429020|90247020|!3510611|90243020|90317020|03207007|96775020|90723020|96777020|90725020|!8505221|76722020|76723020|55079020|50501020|55090020|90241020|93242020|90281020|90660020|90439020|90457020|90755020|90251020|90719020|90721020|90179020|63831020|93946020|93948020|55761020|95966020|95964020|95962020|90239020|53971020|63837020|97822020|90249020|98797020|97820020|98795020|79955020|90253020|99132020|99330020|99839020|00353021|54156020|50689020|12559020|10359020|10331020|12583020|12557020|12634020|12588020|06430020|12564020|39935020|36452020|80971020|47932020|47930020|12614020|06427020|17903020|47929020|47927020|47928020|09797020|12566020|10356020|06405020|47931020|99328020|06412020|06425020|12590020|12632020)"
gen insulins_short = 0
replace insulins_short = 1 if regexm(gemscriptcode, "`shortinscodes'")
label variable insulins_short " (bnfgrouping) Short-acting insulins exposure: 0=no exp, 1=exp"

// Intermediate- and long-acting insulins
local longinscodes = "(49835020|55081020|79661020|58580020|55087020|74874020|03712007|49944020|54941020|55080020|74960020|79669020|79671020|70111020|74957020|79673020|79666020|51331020|59681020|59679020|52542020|49843020|50163020|79676020|82442020|79663020|56543020|79190020|78521020|76207020|83429020|87908020|87906020|90297020|90337020|90339020|90295020|90427020|90333020|90331020|90335020|52830020|54128020|54127020|79702020|69694020|63796020|49940020|80932020|63802020|57900020|84665020|82035020|76875020|83427020|87904020|90265020|90654020|90271020|90277020|90319020|90329020|90213020|70082020|59676020|69774020|79705020|79704020|80959020|80960020|80952020|59684020|63840020|51532020|63790020|57906020|80954020|84628020|80930020|90321020|90479020|90323020|90325020|90459020|90275020|63825020|80931020|80958020|90273020|90263020|90652020|90435020|78679020|70102020|90219020|54038020|63793020|57903020|74965020|79710020|80956020|90455020|90757020|63805020|90215020|79680020|90443020|80966020|74963020|80965020|80962020|78682020|!3480103|70187020|79711020|90283020|90255020|90441020|02400007|90257020|90259020|90267020|70184020|80928020|82443020|90279020|70049020|90433020|90315020|90461020|86928020|63843020|90429020|90247020|90243020|90317020|76722020|55079020|50501020|55090020|90241020|93242020|90281020|90660020|90457020|90755020|93946020|55761020|95964020|95962020|53971020|97822020|98797020|97820020|98795020|79955020|99132020|99330020|99839020|50689020|10359020|10331020|12634020|06430020|80971020|47932020|47930020|12614020|17903020|47929020|47927020|47928020|12566020|10356020|47931020|12590020|12632020|49835020|55081020|79661020|58580020|55087020|74874020|03712007|49944020|54941020|55080020|74960020|79669020|79671020|70111020|74957020|79673020|79666020|51331020|59681020|59679020|52542020|49843020|50163020|79676020|82442020|79663020|56543020|79190020|78521020|76207020|83429020|87908020|87906020|90297020|90337020|90339020|90295020|90427020|90333020|90331020|90335020|52830020|54128020|54127020|79702020|69694020|63796020|49940020|80932020|63802020|57900020|84665020|82035020|76875020|83427020)"
gen insulins_intlong = 0
replace insulins_intlong = 1 if regexm(gemscriptcode, "`longinscodes'") 
label variable insulins_intlong " (bnfgrouping) Intermediate- and long-acting insulins exposure: 0=no exp, 1=exp"

// Any insulin (incl 2 above groups)
gen insulin = 0
replace insulin = 1 if insulins_short==1|insulins_intlong==1
label variable insulin "Any insulin exposure: 0=no exposure, 1=exp"

// Generate the rxtype category
gen rxtype=.
replace rxtype=3 if inlist(insulin, 1)
label var rxtype "Antidiabetic prescription type: 0=SU, 1=DPP, 2=GLP, 3=insulin, 4=tzd, 5=other, 6=met, 99=combo"
label define rxtypelabels 0 "SU" 1 "DPP" 2 "GLP" 3 "insulin" 4 "TZD" 5 "other" 6 "metformin" 7 "mdcombo" 8 "mtcombo" 99 "combination"
label values rxtype rxtypelabels

//drop all irrelevant prescriptions
drop if rxtype==.

//Collapse exact duplicate prescriptions assuming that they were used over time but obtained on one day
//check for exact duplicates and collapse over date, type, and amt while summing qty
bysort patid rxdate2 gemscriptcode ndd qty issueseq: gen multiplicity= cond(_N==1,0,_n)
bysort patid rxdate2 gemscriptcode ndd qty issueseq: egen qtysum=sum(qty)if multiplicity>0
replace qty=qtysum if multiplicity==1
drop if multiplicity>1
drop qtysum
label var multiplicity "Indicates whether prescription was collapsed due to multiplicity 1=yes, 0=no"

//Generate insulin category
gen instype=0
lab var instype "Insulin type: 0=other, 1=rapid, 2=regular, 3=NPH/lente/ultralente, 4=long"
//Populate local macros with gemscriptcodes of interest 
//RAPID
local aspart = "(55179020|79182020|50497020|81577020|78930020|90287020|90289020|90285020|00353021|12559020|12557020|12564020|39935020)"
replace instype= 1 if regexm(gemscriptcode, "`aspart'")
local lispro = "(82381020|82387020|90311020|90313020|90305020|90307020|90309020|90303020|95966020|06427020|06412020)"
replace instype= 1 if regexm(gemscriptcode, "`lispro'")
local glulisine = "(90343020|89726020|89723020|90385020|90387020|90341020|89720020|91628020|93948020)"
replace instype= 1 if regexm(gemscriptcode, "`glulisine'")

//REGULAR
local human = "(04841007|49830020|58583020|58584020|79661020|04837007|49847020|03713007|55084020|56543020|90191020|03311007|03212007|00023007|79708020|03704007|80944020|80948020|03955007|90185020|80946020|90181020|63834020|06532007|03709007|!3474903|02397007|!3471801|90183020|84932020|90187020|90189020|70202020|!3474503|86843020|90177020|!3474502|96775020|90723020|96777020|90725020|90719020|90721020|90179020|54156020|06430020|36452020|09797020|06405020|06425020)"
replace instype= 2 if regexm(gemscriptcode, "`human'")
local porcine = "(52197020|49944020|67848020|85937020|84620020|90451020|!8504807|90447020|90449020|90445020|54131020|63831020)"
replace instype= 2 if regexm(gemscriptcode, "`porcine'")
local bovine = "(63781020|90465020|05522007|57909020|90469020|54038020|90463020|90467020|63828020|54038020)"
replace instype= 2 if regexm(gemscriptcode, "`bovine'")

//NPH (+LENTE)
local humiso = "(55081020|79661020|03712007|49944020|55080020|49843020|56543020|79190020|04836007|54128020|54127020|06862007|79702020|06860007|82035020|80950020|90265020|90654020|90277020|03716007|80952020|80954020|90479020|90275020|90273020|90263020|90652020|03708007|03707007|70102020|00021007|02401007|90283020|03204007|02400007|90267020|90279020|63843020|55079020|90281020|55761020|98797020|12614020|99328020|55081020|79661020|03712007|55080020|49843020|56543020|79190020|54128020|54127020|79702020|82035020|90265020|90654020|90277020|80952020|80954020|90479020|90275020|90273020|90263020|90652020|70102020|90283020|02400007|90267020|90279020|63843020|55079020|90281020|55761020|98797020|99839020|50689020|06430020|12614020)"
replace instype= 3 if regexm(gemscriptcode, "`humiso'")
local poriso = "(49944020|63811020|90427020|84628020|90435020|!3480103|90433020|90429020)"
replace instype= 3 if regexm(gemscriptcode, "`poriso'")
local boviso = "(57900020|57906020|90459020|63808020|90455020|90461020|90457020|50689020)"
replace instype= 3 if regexm(gemscriptcode, "`boviso'")
local humlente = "(04835007|!3522501|!3510610|02398007|!3510611|53971020|53971020)"
replace instype= 3 if regexm(gemscriptcode, "`humlente'")
local porlente = "(04831007|03935007|51532020|51532020)"
replace instype= 3 if regexm(gemscriptcode, "`porlente'")
local bovlente = "(03705007|03714007|03923007|57903020|02399007|!3510609|57903020)"
replace instype= 3 if regexm(gemscriptcode, "`bovlente'")
local ultra = "(54941020|03710007|52830020|03310007|63802020|63805020)"
replace instype= 3 if regexm(gemscriptcode, "`ultra'")
local bovultra = "(57900020|63825020)"
replace instype= 3 if regexm(gemscriptcode, "`bovultra'")

//LONG
local glargine = "(78521020|76207020|90337020|90339020|90333020|90331020|90335020|90271020|90329020|93946020|10359020|10331020|10356020|78521020|76207020|90337020|90339020|90333020|90331020|90335020|90271020|90329020|90323020|90325020|93946020|10359020|10331020|10356020|78521020|76207020|90337020|90339020|90333020|90331020|90335020)"
replace instype= 4 if regexm(gemscriptcode, "`glargine'")
local detemir = "(87908020|87906020|87904020|90323020|90325020|93242020|17903020|87908020|87906020|87904020|93242020|17903020|87908020|87906020)"
replace instype= 4 if regexm(gemscriptcode, "`detemir'")
local degludec = "(47932020|47930020|47929020|47927020|47928020|47931020|47932020|47930020|47929020|47927020|47928020|47931020)"
replace instype= 4 if regexm(gemscriptcode, "`degludec'")

//drop unnecessary variables
drop gemscriptcode
save drugexpc`i', replace
}
use drugexpc0, clear 
forval i=1/49 {
	append using drugexpc`i'
	}
save Drug_Exp_C.dta, replace

//merge in analytic variables
merge m:1 patid using Analytic_variables_a, gen(flag)

//merge in supplemental common dosage information
merge m:1 textid using commondosages, gen(flagsuppl)

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
gen exclude=1 if (gest_diab==1|pcos==1|preg==1|age_indexdate<=29|cohort_b==0|tx<=seconddate|deathdate2<indexdate|dod2<indexdate)
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

//remove all non-insulin prescriptions
keep if insulin==1

//keep index insulin users only
keep if indextype==3

//tidy up
drop flag* multiplicity *admrx ever* thirddate fourthdate fifthdate sixthdate seventhdate unqrx linked_practice hes_e tod2 lcd2 death_e lsoa_e cprd_e start_o start_h start_g end_h end_o pcos gest_diab preg marital regstat reggap internal toreason accept frd2 crd2 yob2 yob_indexdate exclude
//Generate intensity (quintiles of dose)
//several options for calculating- what do you want me to  put in here??

//drop extraneous variables- anything you want me to drop here??

//save long form file
save Drug_Exposures_c, replace

timer off 1
log close
