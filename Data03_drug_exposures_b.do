//  program:    Data03_drug_exposures_b.do
//  task:		Generate variables indicating drug exposures in CPRD Dataset, using individual Therapy files
//  project: 	Incretins--Comparative mortality and CV outcomes (CPRD)
//  author:     MA \ May2014 Modified JM \ Jan2015

capture log close
set more off

log using Data03b.txt, replace
timer clear 1
timer on 1

forval i=0/49 {
	timer clear 2
	timer on 2
	use Therapy_`i', clear	 
////// #1 make labels case-consistent
// create new variable "productname_1" as the lowercase version of "productname"
generate productname_1=lower(productname)
label variable productname_1 "productname in lower case"
// create new variable "drugsubstance_1" as the lowercase version of "drugsubstance"
generate drugsubstance_1=lower(drugsubstance)
label variable drugsubstance_1 "drugsubstance in lower case"
keep patid gemscriptcode
////// #3 Generate indicator variables for each insulin and incretin agent.

//exenatide
local exencodes="(93411020|93407020|93413020|93405020|00071021|00074021)"
gen exenatide = 0
replace exenatide = 1 if regexm(gemscriptcode, "`exencodes'") 
label variable exenatide "Exenatide exposure: 0=no exp, 1=exp"

//liraglutide
local liracodes="(97165020|97163020)"
gen liraglutide = 0 
replace liraglutide = 1 if regexm(gemscriptcode, "`liracodes'")      
label variable liraglutide "Liraglutide exposure: 0=no exp, 1=exp"

//lixisenatide
local lixicodes="(47959020|47955020|47957020|47956020|47960020|47958020)"
gen lixisenatide = 0 
replace lixisenatide = 1 if regexm(gemscriptcode, "`lixicodes'")      
label variable lixisenatide "Lixisenatide exposure: 0=no exp, 1=exp"

//GLP-1 combo
gen glp_combo = 0
replace glp_combo = 1 if exenatide==1|liraglutide==1|lixisenatide==1
label variable glp_combo "GLP-1 RA exposure combination of ind agents: 0=no exp, 1=exp"

//alogliptin not available in the UK: no codes found
//local alocodes="()"
gen alogliptin = 0 
//replace alogliptin = 1 if regexm(gemscriptcode, "`alocodes'")     
//label variable alogliptin "Alogliptin exposure: 0=no exp, 1=exp"

//linagliptin
local linacodes="(00361021|00363021|45093020|45092020|45094020|45095020)"
gen linagliptin = 0 
replace linagliptin = 1 if regexm(gemscriptcode, "`linacodes'")      
label variable linagliptin "Linagliptin exposure: 0=no exp, 1=exp"

//sitagliptin
local sitacodes="(93519020|93521020|95970020|98591020|40627020|40625020|40628020|40626020)"
gen sitagliptin = 0 
replace sitagliptin = 1 if regexm(gemscriptcode, "`sitacodes'")      
label variable sitagliptin "Sitagliptin exposure: 0=no exp, 1=exp"

//saxagliptin
local saxacodes="(97586020|97590020|99663020|99665020|46992020|46994020|46993020)"
gen saxagliptin = 0 
replace saxagliptin = 1 if regexm(gemscriptcode, "`saxacodes'")
label variable saxagliptin "Saxagliptin exposure: 0=no exp, 1=exp"

//vildagliptin
local vildacodes="(94757020|94104020|94759020|94763020|94109020|94761020)"
gen vildagliptin = 0 
replace vildagliptin = 1 if regexm(gemscriptcode, "`vildacodes'")     
label variable vildagliptin "Vildagliptin exposure: 0=no exp, 1=exp"

//DPP-4 combo
gen dpp_combo = 0
replace dpp_combo = 1 if alogliptin==1|linagliptin==1|sitagliptin==1|saxagliptin==1|vildagliptin==1
label variable dpp_combo "DPP-4 Inhibitor exposure combination of ind agents: 0=no exp, 1=exp"

//insulin (sub-category)
local inssubcodes="(04841007|82381020|49835020|49830020|58583020|55081020|58584020|79661020|05798007|04837007|58580020|55087020|74874020|03712007|49847020|52197020|49944020|54941020|55080020|74960020|79670020|03713007|79669020|79667020|79664020|50442020|04153007|79674020|79671020|70111020|74957020|79673020|79666020|59680020|67848020|51331020|59681020|59679020|63811020|03710007|55084020|52542020|49843020|50163020|79676020|55179020|80649020|81314020|82387020|82442020|79663020|56543020|80653020|80663020|82033020|79190020|79182020|79677020|78521020|76207020|83429020|80651020|88021020|50497020|81577020|88216020|88212020|84438020|80667020|88019020|87908020|87906020|84439020|88828020|90297020|90209020|90337020|90339020|90295020|90658020|90311020|90199020|90191020|90427020|90333020|90331020|90335020|52830020|04835007|04836007|05797007|03311007|54128020|54127020|06862007|79706020|03212007|04834007|79702020|69694020|63796020|03717007|06860007|03310007|04831007|03935007|59685020|49940020|00023007|80932020|63802020|57900020|85937020|79708020|84665020|82035020|76875020|83427020|80950020|87904020|90265020|90654020|90271020|90277020|90319020|90227020|90195020|90329020|90313020|90213020|70082020|03953007|03715007|59676020|03451007|63781020|03716007|69774020|79705020|79704020|80959020|80960020|80952020|59684020|78930020|82196020|63840020|03704007|03705007|57909020|51532020|80944020|80948020|79678020|80664020|86387020|90477020|63790020|57906020|03955007|84620020|80954020|84628020|80930020|84674020|90321020|90479020|90343020|90323020|90305020|90325020|90469020|90459020|89726020|90275020|90307020|03714007|63825020|03923007|63818020|80931020|80958020|90273020|90263020|90652020|90451020|90435020|90465020|90185020|03708007|78679020|83171020|63808020|03707007|80946020|83173020|84675020|70102020|90181020|90287020|90203020|90219020|05522007|54038020|63793020|63834020|86389020|57903020|74965020|79710020|90309020|06532007|80956020|90455020|90463020|90757020|03709007|63805020|89723020|90215020|!3474903|!3498103|90289020|90207020|02399007|02397007|79680020|!3473801|!3471801|90443020|80966020|90205020|90183020|74963020|80965020|80962020|90225020|78682020|90385020|90387020|!3480103|70187020|!3477701|79711020|!3477601|!3522501|80963020|!8504807|00021007|84932020|90187020|02401007|90293020|90467020|90283020|90189020|90255020|!3510610|63828020|00022007|90291020|90441020|03204007|70202020|02400007|90257020|!3474503|90259020|90447020|90197020|90193020|90267020|90303020|90449020|70184020|80928020|86843020|02398007|82443020|90437020|90445020|90177020|90279020|70049020|!3474502|90233020|90341020|90433020|90315020|89720020|90461020|!3510609|03205007|90285020|86928020|91628020|54131020|63843020|90429020|90247020|!3510611|90243020|90317020|03207007|96775020|90723020|96777020|90725020|!8505221|76722020|76723020|55079020|50501020|55090020|99756020|99846020|90241020|93242020|90281020|90660020|90439020|96779020|90457020|90755020|90251020|90719020|90721020|90179020|63831020|93946020|93948020|01735021|55761020|02997021|02998021|95966020|95964020|95962020|05081021|90239020|53971020|63837020|97822020|90249020|09333021|09326021|98797020|97820020|98795020|79955020|90253020|99132020|99330020|99839020|00353021|54156020|72169020|50689020|13928021|13929021|14442021|12559020|14443021|10359020|10331020|12583020|12692020|12696020|12557020|33102020|29293020|12634020|12588020|06430020|12564020|13476020|39935020|36452020|80971020|12693020|47932020|47930020|12614020|06427020|17903020|47929020|47927020|47928020|09797020|15741021|12566020|10356020|06405020|15739021|47931020|15743021|99328020|15740021|15742021|15744021|06412020|06425020|12590020|12632020)"
gen ins_sub = 0
replace ins_sub = 1 if regexm(gemscriptcode, "`inssubcodes'")
label variable ins_sub "Insulin (sub-category) exposure: 0=no exp, 1=exp"

//insulin aspart
local insapartcodes="(49830020|58583020|49847020|52197020|55179020|79182020|83429020|50497020|81577020|90297020|90295020|90311020|90191020|85937020|83427020|90313020|63781020|78930020|57909020|80944020|80948020|84620020|90343020|90305020|90469020|89726020|90307020|90451020|90465020|90185020|80946020|90181020|90287020|63834020|90309020|90463020|89723020|90289020|90183020|90385020|90387020|84932020|90187020|90293020|90467020|90189020|63828020|90291020|70202020|90447020|90303020|90449020|86843020|90445020|90177020|90341020|89720020|90285020|91628020|54131020|90179020|63831020|93948020|95966020|63837020|00353021|54156020|12559020|12557020|12564020|39935020|06427020|12566020|06412020|06425020)"
gen aspart = 0
replace aspart = 1 if regexm(gemscriptcode, "`insapartcodes'")
label variable aspart "Insulin aspart exposure: 0=no exp, 1=exp"

//insulin glulisine
local insglucodes="(49830020|58583020|49847020|52197020|55179020|79182020|50497020|81577020|90311020|90191020|85937020|90313020|63781020|57909020|80944020|80948020|84620020|90343020|90305020|90469020|89726020|90307020|90451020|90465020|90185020|80946020|90181020|90287020|63834020|90309020|90463020|89723020|90289020|90183020|90385020|90387020|84932020|90187020|90467020|90189020|63828020|70202020|90447020|90303020|90449020|86843020|90445020|90177020|90341020|89720020|90285020|91628020|54131020|90179020|63831020|93948020|95966020|63837020|00353021|54156020|12559020|12557020|12564020|39935020|06427020|06412020|06425020)"
gen glulisine = 0
replace glulisine = 1 if regexm(gemscriptcode, "`insglucodes'")
label variable glulisine "Insulin glulisine exposure: 0=no exp, 1=exp"

//insulin lispro
local insliscodes="(82381020|49830020|58583020|49847020|52197020|52542020|55179020|82387020|82442020|79182020|50497020|81577020|90311020|90191020|85937020|76875020|90319020|90313020|63781020|57909020|80944020|80948020|84620020|90321020|90343020|90305020|90469020|89726020|90307020|90451020|90465020|90185020|80946020|90181020|90287020|63834020|90309020|90463020|90757020|89723020|90289020|90183020|90385020|90387020|84932020|90187020|90467020|90189020|63828020|70202020|90447020|90303020|90449020|86843020|82443020|90445020|90177020|90341020|90315020|89720020|90285020|91628020|54131020|90317020|!8505221|90660020|90755020|90179020|63831020|93948020|95966020|95964020|95962020|63837020|97822020|97820020|00353021|54156020|12559020|12557020|12634020|12564020|39935020|06427020|06412020|06425020|12632020)"
gen lispro = 0
replace lispro = 1 if regexm(gemscriptcode, "`insliscodes'")
label variable lispro "Insulin lispro exposure: 0=no exp, 1=exp"

//insulin degludec
local insdeglucodes="(55081020|79661020|58580020|55087020|74874020|55080020|74960020|79669020|79671020|70111020|74957020|79673020|79666020|51331020|59681020|59679020|52542020|49843020|50163020|79676020|82442020|79663020|56543020|79190020|78521020|76207020|83429020|87908020|87906020|90337020|90339020|90427020|90333020|90331020|90335020|54128020|54127020|79702020|69694020|63796020|49940020|80932020|63802020|57900020|82035020|76875020|83427020|87904020|90265020|90654020|90271020|90277020|90319020|90329020|70082020|69774020|79705020|79704020|80959020|80960020|80952020|59684020|63840020|51532020|63790020|57906020|80954020|80930020|90321020|90479020|90323020|90325020|90459020|90275020|63825020|80931020|80958020|90273020|90263020|90652020|90435020|78679020|70102020|54038020|63793020|57903020|74965020|79710020|90455020|90757020|79680020|80966020|74963020|80965020|80962020|78682020|70187020|79711020|90283020|90267020|70184020|80928020|82443020|90279020|70049020|90433020|90315020|90461020|86928020|63843020|90429020|90317020|76722020|55079020|50501020|55090020|93242020|90281020|90660020|90457020|90755020|93946020|55761020|95964020|95962020|53971020|97822020|98797020|97820020|79955020|99839020|50689020|10359020|10331020|12634020|06430020|80971020|47932020|47930020|12614020|17903020|47929020|47927020|47928020|47931020|12632020)"
gen degludec = 0
replace degludec = 1 if regexm(gemscriptcode, "`insdeglucodes'")
label variable degludec "Insulin degludec exposure: 0=no exp, 1=exp"

//insulin detemir
local insdetcodes="(55081020|79661020|58580020|55087020|74874020|55080020|74960020|79669020|79671020|70111020|74957020|79673020|79666020|51331020|59681020|59679020|52542020|49843020|50163020|79676020|82442020|79663020|56543020|79190020|78521020|76207020|83429020|87908020|87906020|90337020|90339020|90427020|90333020|90331020|90335020|54128020|54127020|79702020|69694020|63796020|49940020|80932020|63802020|57900020|82035020|76875020|83427020|87904020|90265020|90654020|90271020|90277020|90319020|90329020|70082020|69774020|79705020|79704020|80959020|80960020|80952020|59684020|63840020|51532020|63790020|57906020|80954020|80930020|90321020|90479020|90323020|90325020|90459020|90275020|63825020|80931020|80958020|90273020|90263020|90652020|90435020|78679020|70102020|54038020|63793020|57903020|74965020|79710020|90455020|90757020|79680020|80966020|74963020|80965020|80962020|78682020|70187020|79711020|90283020|90267020|70184020|80928020|82443020|90279020|70049020|90433020|90315020|90461020|86928020|63843020|90429020|90317020|76722020|55079020|50501020|55090020|93242020|90281020|90660020|90457020|90755020|93946020|55761020|95964020|95962020|53971020|97822020|98797020|97820020|79955020|99839020|50689020|10359020|10331020|12634020|06430020|80971020|47932020|47930020|12614020|17903020|47929020|47927020|47928020|47931020|12632020)"
gen detemir = 0
replace detemir = 1 if regexm(gemscriptcode, "`insdetcodes'")
label variable detemir "Insulin detemir exposure: 0=no exp, 1=exp"

//insulin glargine
local insglargcodes="(55081020|79661020|58580020|55087020|74874020|55080020|74960020|79669020|79671020|70111020|74957020|79673020|79666020|51331020|59681020|59679020|52542020|49843020|50163020|79676020|82442020|79663020|56543020|79190020|78521020|76207020|83429020|87908020|87906020|90337020|90339020|90427020|90333020|90331020|90335020|54128020|54127020|79702020|69694020|63796020|49940020|80932020|63802020|57900020|82035020|76875020|83427020|87904020|90265020|90654020|90271020|90277020|90319020|90329020|70082020|69774020|79705020|79704020|80959020|80960020|80952020|59684020|63840020|51532020|63790020|57906020|80954020|80930020|90321020|90479020|90323020|90325020|90459020|90275020|63825020|80931020|80958020|90273020|90263020|90652020|90435020|78679020|70102020|54038020|63793020|57903020|74965020|79710020|90455020|90757020|79680020|80966020|74963020|80965020|80962020|78682020|70187020|79711020|90283020|90267020|70184020|80928020|82443020|90279020|70049020|90433020|90315020|90461020|86928020|63843020|90429020|90317020|76722020|55079020|50501020|55090020|93242020|90281020|90660020|90457020|90755020|93946020|55761020|95964020|95962020|53971020|97822020|98797020|97820020|79955020|99839020|50689020|10359020|10331020|12634020|06430020|80971020|47932020|47930020|12614020|17903020|47929020|47927020|47928020|10356020|47931020|12632020)"
gen glargine = 0
replace glargine = 1 if regexm(gemscriptcode, "`insglargcodes'")
label variable glargine "Insulin glargine exposure: 0=no exp, 1=exp"

//insulin zinc suspension
local inszinccodes="(49835020|55081020|79661020|58580020|55087020|74874020|54941020|55080020|74960020|79669020|79671020|70111020|74957020|79673020|79666020|51331020|59681020|59679020|52542020|49843020|50163020|79676020|82442020|79663020|56543020|79190020|78521020|76207020|83429020|87908020|87906020|90337020|90339020|90427020|90333020|90331020|90335020|52830020|54128020|54127020|79702020|69694020|63796020|49940020|80932020|63802020|57900020|82035020|76875020|83427020|87904020|90265020|90654020|90271020|90277020|90319020|90329020|70082020|59676020|69774020|79705020|79704020|80959020|80960020|80952020|59684020|63840020|51532020|63790020|57906020|80954020|80930020|90321020|90479020|90323020|90325020|90459020|90275020|63825020|80931020|80958020|90273020|90263020|90652020|90435020|78679020|70102020|54038020|63793020|57903020|74965020|79710020|80956020|90455020|90757020|63805020|79680020|80966020|74963020|80965020|80962020|78682020|70187020|79711020|90283020|90267020|70184020|80928020|82443020|90279020|70049020|90433020|90315020|90461020|86928020|63843020|90429020|90317020|76722020|55079020|50501020|55090020|93242020|90281020|90660020|90457020|90755020|93946020|55761020|95964020|95962020|53971020|97822020|98797020|97820020|79955020|99839020|50689020|10359020|10331020|12634020|06430020|80971020|47932020|47930020|12614020|17903020|47929020|47927020|47928020|47931020|12632020)"
gen ins_zinc = 0
replace ins_zinc = 1 if regexm(gemscriptcode, "`inszinccodes'")
label variable ins_zinc "Insulin zinc suspension exposure: 0=no exp, 1=exp"

//isophane insulin
local isoinscodes="(55081020|79661020|58580020|55087020|74874020|03712007|49944020|55080020|74960020|79669020|79671020|70111020|74957020|79673020|79666020|51331020|59681020|59679020|52542020|49843020|50163020|79676020|82442020|79663020|56543020|79190020|78521020|76207020|83429020|87908020|87906020|90337020|90339020|90427020|90333020|90331020|90335020|54128020|54127020|79702020|69694020|63796020|49940020|80932020|63802020|57900020|82035020|76875020|83427020|87904020|90265020|90654020|90271020|90277020|90319020|90329020|70082020|69774020|79705020|79704020|80959020|80960020|80952020|59684020|63840020|51532020|63790020|57906020|80954020|84628020|80930020|90321020|90479020|90323020|90325020|90459020|90275020|63825020|80931020|80958020|90273020|90263020|90652020|90435020|78679020|70102020|54038020|63793020|57903020|74965020|79710020|90455020|90757020|79680020|80966020|74963020|80965020|80962020|78682020|!3480103|70187020|79711020|90283020|02400007|90267020|70184020|80928020|82443020|90279020|70049020|90433020|90315020|90461020|86928020|63843020|90429020|90317020|76722020|55079020|50501020|55090020|93242020|90281020|90660020|90457020|90755020|93946020|55761020|95964020|95962020|53971020|97822020|98797020|97820020|79955020|99839020|50689020|10359020|10331020|12634020|06430020|80971020|47932020|47930020|12614020|17903020|47929020|47927020|47928020|47931020|12632020)"
gen isophane_ins = 0
replace isophane_ins = 1 if regexm(gemscriptcode, "`isoinscodes'")
label variable isophane_ins "Isophane insulin exposure: 0=no exp, 1=exp"

//protamine zinc insulin
local protzinccodes="(55081020|79661020|58580020|55087020|74874020|55080020|74960020|79669020|79671020|70111020|74957020|79673020|79666020|51331020|59681020|59679020|52542020|49843020|50163020|79676020|82442020|79663020|56543020|79190020|78521020|76207020|83429020|87908020|87906020|90337020|90339020|90427020|90333020|90331020|90335020|54128020|54127020|79702020|69694020|63796020|49940020|80932020|63802020|57900020|82035020|76875020|83427020|87904020|90265020|90654020|90271020|90277020|90319020|90329020|70082020|69774020|79705020|79704020|80959020|80960020|80952020|59684020|63840020|51532020|63790020|57906020|80954020|80930020|90321020|90479020|90323020|90325020|90459020|90275020|63825020|80931020|80958020|90273020|90263020|90652020|90435020|78679020|70102020|54038020|63793020|57903020|74965020|79710020|90455020|90757020|79680020|80966020|74963020|80965020|80962020|78682020|70187020|79711020|90283020|90267020|70184020|80928020|82443020|90279020|70049020|90433020|90315020|90461020|86928020|63843020|90429020|90317020|76722020|55079020|50501020|55090020|93242020|90281020|90660020|90457020|90755020|93946020|55761020|95964020|95962020|53971020|97822020|98797020|97820020|79955020|99839020|50689020|10359020|10331020|12634020|06430020|80971020|47932020|47930020|12614020|17903020|47929020|47927020|47928020|47931020|12632020)"
gen protamine_zinc_ins = 0
replace protamine_zinc_ins = 1 if regexm(gemscriptcode, "`protzinccodes'")
label variable protamine_zinc_ins "Protamine zinc insulin exposure: 0=no exp, 1=exp"

//biphasic insulin aspart
local biaspartcodes="(55081020|79661020|58580020|55087020|74874020|55080020|74960020|79669020|79671020|70111020|74957020|79673020|79666020|51331020|59681020|59679020|52542020|49843020|50163020|79676020|82442020|79663020|56543020|79190020|78521020|76207020|83429020|87908020|87906020|90297020|90337020|90339020|90295020|90427020|90333020|90331020|90335020|54128020|54127020|79702020|69694020|63796020|49940020|80932020|63802020|57900020|82035020|76875020|83427020|87904020|90265020|90654020|90271020|90277020|90319020|90329020|70082020|69774020|79705020|79704020|80959020|80960020|80952020|59684020|63840020|51532020|63790020|57906020|80954020|80930020|90321020|90479020|90323020|90325020|90459020|90275020|63825020|80931020|80958020|90273020|90263020|90652020|90435020|78679020|70102020|54038020|63793020|57903020|74965020|79710020|90455020|90757020|79680020|80966020|74963020|80965020|80962020|78682020|70187020|79711020|90283020|90267020|70184020|80928020|82443020|90279020|70049020|90433020|90315020|90461020|86928020|63843020|90429020|90317020|76722020|55079020|50501020|55090020|93242020|90281020|90660020|90457020|90755020|93946020|55761020|95964020|95962020|53971020|97822020|98797020|97820020|79955020|99839020|50689020|10359020|10331020|12634020|06430020|80971020|47932020|47930020|12614020|17903020|47929020|47927020|47928020|12566020|47931020|12632020)"
gen aspart_biphasic = 0
replace aspart_biphasic = 1 if regexm(gemscriptcode, "`biaspartcodes'")
label variable aspart_biphasic "Biphasic insulin aspart exposure: 0=no exp, 1=exp"

//biphasic insulin lispro
local biliscodes="(55081020|79661020|58580020|55087020|74874020|55080020|74960020|79669020|79671020|70111020|74957020|79673020|79666020|51331020|59681020|59679020|52542020|49843020|50163020|79676020|82442020|79663020|56543020|79190020|78521020|76207020|83429020|87908020|87906020|90337020|90339020|90427020|90333020|90331020|90335020|54128020|54127020|79702020|69694020|63796020|49940020|80932020|63802020|57900020|82035020|76875020|83427020|87904020|90265020|90654020|90271020|90277020|90319020|90329020|70082020|69774020|79705020|79704020|80959020|80960020|80952020|59684020|63840020|51532020|63790020|57906020|80954020|80930020|90321020|90479020|90323020|90325020|90459020|90275020|63825020|80931020|80958020|90273020|90263020|90652020|90435020|78679020|70102020|54038020|63793020|57903020|74965020|79710020|90455020|90757020|79680020|80966020|74963020|80965020|80962020|78682020|70187020|79711020|90283020|90267020|70184020|80928020|82443020|90279020|70049020|90433020|90315020|90461020|86928020|63843020|90429020|90317020|76722020|55079020|50501020|55090020|93242020|90281020|90660020|90457020|90755020|93946020|55761020|95964020|95962020|53971020|97822020|98797020|97820020|79955020|99839020|50689020|10359020|10331020|12634020|06430020|80971020|47932020|47930020|12614020|17903020|47929020|47927020|47928020|47931020|12632020)"
gen lispro_biphasic = 0
replace lispro_biphasic = 1 if regexm(gemscriptcode, "`biliscodes'")
label variable lispro_biphasic "Biphasic insulin lispro exposure: 0=no exp, 1=exp"

//biphasic isophane insulin
local biisocodes="(55081020|79661020|58580020|55087020|74874020|55080020|74960020|79669020|79671020|70111020|74957020|79673020|79666020|51331020|59681020|59679020|52542020|49843020|50163020|79676020|82442020|79663020|56543020|79190020|78521020|76207020|83429020|87908020|87906020|90337020|90339020|90427020|90333020|90331020|90335020|54128020|54127020|79702020|69694020|63796020|49940020|80932020|63802020|57900020|84665020|82035020|76875020|83427020|87904020|90265020|90654020|90271020|90277020|90319020|90329020|90213020|70082020|69774020|79705020|79704020|80959020|80960020|80952020|59684020|63840020|51532020|63790020|57906020|80954020|80930020|90321020|90479020|90323020|90325020|90459020|90275020|63825020|80931020|80958020|90273020|90263020|90652020|90435020|78679020|70102020|90219020|54038020|63793020|57903020|74965020|79710020|90455020|90757020|90215020|79680020|90443020|80966020|74963020|80965020|80962020|78682020|70187020|79711020|90283020|90255020|90441020|90257020|90259020|90267020|70184020|80928020|82443020|90279020|70049020|90433020|90315020|90461020|86928020|63843020|90429020|90247020|90243020|90317020|76722020|55079020|50501020|55090020|90241020|93242020|90281020|90660020|90457020|90755020|93946020|55761020|95964020|95962020|53971020|97822020|98797020|97820020|98795020|79955020|99132020|99330020|99839020|50689020|10359020|10331020|12634020|06430020|80971020|47932020|47930020|12614020|17903020|47929020|47927020|47928020|47931020|12590020|12632020)"
gen isophane_biphasic = 0
replace isophane_biphasic = 1 if regexm(gemscriptcode, "`biisocodes'")
label variable isophane_biphasic "Biphasic isophane insulin exposure: 0=no exp, 1=exp"

//Categories, as per JMG:
//insulin rapid-acting
gen insulin_rapid = 0
replace insulin_rapid = 1 if aspart==1|glulisine==1|lispro==1
label variable insulin_rapid "Rapid-acting Insulin exposure (aspart, glulisine, lispro): 0=no exp, 1=exp"

//insulin regular
gen insulin_regular = 0
replace insulin_regular = 1 if ins_sub==1
label variable insulin_regular "Regular Insulin exposure: 0=no exp, 1=exp"

//insulin intermediate/long acting
gen insulin_int_long = 0
replace insulin_int_long = 1 if ins_zinc==1|isophane_ins==1|protamine_zinc_ins==1
label variable insulin_int_long "Intermediate/Long Acting Insulin exposure: 0=no exp, 1=exp"

//insulin ultra-long
gen insulin_ultralong = 0
replace insulin_ultralong = 1 if degludec==1|detemir==1|glargine==1
label variable insulin_ultralong "Ultra-long Insulin exposure: 0=no exp, 1=exp"

//insulin pre-mixed
gen insulin_premixed = 0
replace insulin_premixed = 1 if aspart_biphasic==1|lispro_biphasic==1|isophane_biphasic==1
label variable insulin_premixed "Pre-mixed Insulin exposure: 0=no exp, 1=exp"

//Insulin combo of ind. agents above
gen insulin_combo = 0
replace insulin_combo = 1 if ins_sub==1|aspart==1|glulisine==1|lispro==1|degludec==1|detemir==1|glargine==1|ins_zinc==1|isophane_ins==1|protamine_zinc_ins==1|aspart_biphasic==1|lispro_biphasic==1|isophane_biphasic==1
label variable insulin_combo "Insulin exposure combination of ind agents: 0=no exp, 1=exp"

//Set local macros for the unique drug exposures
local rxlist = "exenatide liraglutide lixisenatide glp_combo alogliptin linagliptin sitagliptin saxagliptin vildagliptin dpp_combo ins_sub aspart glulisine lispro degludec detemir glargine ins_zinc isophane_ins protamine_zinc_ins aspart_biphasic lispro_biphasic isophane_biphasic insulin_rapid insulin_regular insulin_int_long insulin_ultralong insulin_premixed insulin_combo "

//Generate the variable for totals
egen unqrx= anycount(`rxlist'), values(1)
label var unqrx "Total number of unique drugs"

macro drop _all
save drugexpb`i'
timer off 2
timer list 2
}


use drugexpb0, clear 
forval i=1/49 {		
	append using drugexpb`i'
	}
save Drug_Exposures_B.dta, replace
drop gemscriptcode
collapse (max) exenatide liraglutide lixisenatide glp_combo alogliptin linagliptin sitagliptin saxagliptin vildagliptin dpp_combo ins_sub aspart glulisine lispro degludec detemir glargine ins_zinc isophane_ins protamine_zinc_ins aspart_biphasic lispro_biphasic isophane_biphasic insulin_rapid insulin_regular insulin_int_long insulin_ultralong insulin_premixed insulin_combo unqrx , by(patid)
save Drug_Exposures_B.dta, replace

////////////////////////////////////////////

timer off 1
timer list 1

exit
