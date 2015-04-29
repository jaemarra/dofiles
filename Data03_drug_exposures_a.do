//  program:    Data03_drug_exposures_a.do
//  task:		Generate variables indicating drug exposures in CPRD Dataset, using individual Therapy files
//  project: 	Incretins--Comparative mortality and CV outcomes (CPRD)
//  author:     MA \ May2014 Modified JM \ Jan2015


clear all
capture log close
set more off

log using Data03a.smcl, replace

timer clear 1
timer on 1

//#1 Prepare Therapy files for drug exposures extraction.

//Drop all unnecessary variables to speed up the runtime
forval i=0/49 {
	use Therapy_`i', clear

	merge m:1 patid using Censor, nogen
	keep patid gemscriptcode rxdate2 qty ndd studyentrydate_cprd2 tod2 deathdate2 lcd2 end_h end_o issueseq
	save Therapy_`i'dm, replace
	clear
}

//#2 Generate binary variables to indicate exposure to each class of antiabetic agent of interest using gemscript codes (1=exposed, 0=never exposed).

forval i=0/49 {
	use Therapy_`i'dm, clear
// Short-acting insulins (could include intermediate- and long-acting because of use of word "insulin"...but could miss some without it)
local shortinscodes = "(4841007|82381020|49835020|49830020|58583020|55081020|58584020|79661020|5798007|4837007|58580020|55087020|74874020|3712007|49847020|52197020|49944020|54941020|55080020|74960020|79670020|3713007|79669020|79667020|79664020|50442020|4153007|79674020|79671020|70111020|74957020|79673020|79666020|59680020|67848020|51331020|59681020|59679020|63811020|3710007|55084020|52542020|49843020|50163020|79676020|55179020|80649020|81314020|82387020|82442020|79663020|56543020|80653020|80663020|82033020|79190020|79182020|79677020|78521020|76207020|83429020|80651020|88021020|50497020|81577020|88216020|88212020|84438020|80667020|88019020|87908020|87906020|84439020|88828020|90297020|90209020|90337020|90339020|90295020|90658020|90311020|90199020|90191020|90427020|90333020|90331020|90335020|52830020|4835007|4836007|5797007|3311007|54128020|54127020|6862007|79706020|3212007|4834007|79702020|69694020|63796020|3717007|6860007|3310007|4831007|3935007|59685020|49940020|23007|80932020|63802020|57900020|85937020|79708020|84665020|82035020|76875020|83427020|80950020|87904020|90265020|90654020|90271020|90277020|90319020|90227020|90195020|90329020|90313020|90213020|70082020|3953007|3715007|59676020|3451007|63781020|3716007|69774020|79705020|79704020|80959020|80960020|80952020|59684020|78930020|82196020|63840020|3704007|3705007|57909020|51532020|80944020|80948020|79678020|80664020|86387020|90477020|63790020|57906020|3955007|84620020|80954020|84628020|80930020|84674020|90321020|90479020|90343020|90323020|90305020|90325020|90469020|90459020|89726020|90275020|90307020|3714007|63825020|3923007|63818020|80931020|80958020|90273020|90263020|90652020|90451020|90435020|90465020|90185020|3708007|78679020|83171020|63808020|3707007|80946020|83173020|84675020|70102020|90181020|90287020|90203020|90219020|5522007|54038020|63793020|63834020|86389020|57903020|74965020|79710020|90309020|6532007|80956020|90455020|90463020|90757020|3709007|63805020|89723020|90215020|!3474903|!3498103|90289020|90207020|2399007|2397007|79680020|!3473801|!3471801|90443020|80966020|90205020|90183020|74963020|80965020|80962020|90225020|78682020|90385020|90387020|!3480103|70187020|!3477701|79711020|!3477601|!3522501|80963020|!8504807|21007|84932020|90187020|2401007|90293020|90467020|90283020|90189020|90255020|!3510610|63828020|22007|90291020|90441020|3204007|70202020|2400007|90257020|!3474503|90259020|90447020|90197020|90193020|90267020|90303020|90449020|70184020|80928020|86843020|2398007|82443020|90437020|90445020|90177020|90279020|70049020|!3474502|90233020|90341020|90433020|90315020|89720020|90461020|!3510609|3205007|90285020|86928020|91628020|54131020|63843020|90429020|90247020|!3510611|90243020|90317020|3207007|96775020|90723020|96777020|90725020|!8505221|76722020|76723020|55079020|50501020|55090020|99756020|99846020|90241020|93242020|90281020|90660020|90439020|96779020|90457020|90755020|90251020|90719020|90721020|90179020|63831020|93946020|93948020|1735021|55761020|2997021|2998021|95966020|95964020|95962020|5081021|90239020|53971020|63837020|97822020|90249020|9333021|9326021|98797020|97820020|98795020|79955020|90253020|99132020|99330020|99839020|353021|54156020|72169020|50689020|13928021|13929021|14442021|12559020|14443021|10359020|10331020|12583020|12692020|12696020|12557020|33102020|29293020|12634020|12588020|6430020|12564020|13476020|39935020|36452020|80971020|12693020|47932020|47930020|12614020|6427020|17903020|47929020|47927020|47928020|9797020|15741021|10356020|6405020|15739021|47931020|15743021|99328020|15740021|15742021|15744021|6412020|6425020|12590020|12632020)"
gen insulins_short = 0
replace insulins_short = 1 if regexm(gemscriptcode, "(4841007|82381020|49835020|49830020|58583020|55081020|58584020|79661020|5798007|4837007|58580020|55087020|74874020|3712007|49847020|52197020|49944020|54941020|55080020|74960020|79670020|3713007|79669020|79667020|79664020|50442020|4153007|79674020|79671020|70111020|74957020|79673020|79666020|59680020|67848020|51331020|59681020|59679020|63811020|3710007|55084020|52542020|49843020|50163020|79676020|55179020|80649020|81314020|82387020|82442020|79663020|56543020|80653020|80663020|82033020|79190020|79182020|79677020|78521020|76207020|83429020|80651020|88021020|50497020|81577020|88216020|88212020|84438020|80667020|88019020|87908020|87906020|84439020|88828020|90297020|90209020|90337020|90339020|90295020|90658020|90311020|90199020|90191020|90427020|90333020|90331020|90335020|52830020|4835007|4836007|5797007|3311007|54128020|54127020|6862007|79706020|3212007|4834007|79702020|69694020|63796020|3717007|6860007|3310007|4831007|3935007|59685020|49940020|23007|80932020|63802020|57900020|85937020|79708020|84665020|82035020|76875020|83427020|80950020|87904020|90265020|90654020|90271020|90277020|90319020|90227020|90195020|90329020|90313020|90213020|70082020|3953007|3715007|59676020|3451007|63781020|3716007|69774020|79705020|79704020|80959020|80960020|80952020|59684020|78930020|82196020|63840020|3704007|3705007|57909020|51532020|80944020|80948020|79678020|80664020|86387020|90477020|63790020|57906020|3955007|84620020|80954020|84628020|80930020|84674020|90321020|90479020|90343020|90323020|90305020|90325020|90469020|90459020|89726020|90275020|90307020|3714007|63825020|3923007|63818020|80931020|80958020|90273020|90263020|90652020|90451020|90435020|90465020|90185020|3708007|78679020|83171020|63808020|3707007|80946020|83173020|84675020|70102020|90181020|90287020|90203020|90219020|5522007|54038020|63793020|63834020|86389020|57903020|74965020|79710020|90309020|6532007|80956020|90455020|90463020|90757020|3709007|63805020|89723020|90215020|!3474903|!3498103|90289020|90207020|2399007|2397007|79680020|!3473801|!3471801|90443020|80966020|90205020|90183020|74963020|80965020|80962020|90225020|78682020|90385020|90387020|!3480103|70187020|!3477701|79711020|!3477601|!3522501|80963020|!8504807|21007|84932020|90187020|2401007|90293020|90467020|90283020|90189020|90255020|!3510610|63828020|22007|90291020|90441020|3204007|70202020|2400007|90257020|!3474503|90259020|90447020|90197020|90193020|90267020|90303020|90449020|70184020|80928020|86843020|2398007|82443020|90437020|90445020|90177020|90279020|70049020|!3474502|90233020|90341020|90433020|90315020|89720020|90461020|!3510609|3205007|90285020|86928020|91628020|54131020|63843020|90429020|90247020|!3510611|90243020|90317020|3207007|96775020|90723020|96777020|90725020|!8505221|76722020|76723020|55079020|50501020|55090020|99756020|99846020|90241020|93242020|90281020|90660020|90439020|96779020|90457020|90755020|90251020|90719020|90721020|90179020|63831020|93946020|93948020|1735021|55761020|2997021|2998021|95966020|95964020|95962020|5081021|90239020|53971020|63837020|97822020|90249020|9333021|9326021|98797020|97820020|98795020|79955020|90253020|99132020|99330020|99839020|353021|54156020|72169020|50689020|13928021|13929021|14442021|12559020|14443021|10359020|10331020|12583020|12692020|12696020|12557020|33102020|29293020|12634020|12588020|6430020|12564020|13476020|39935020|36452020|80971020|12693020|47932020|47930020|12614020|6427020|17903020|47929020|47927020|47928020|9797020|15741021|10356020|6405020|15739021|47931020|15743021|99328020|15740021|15742021|15744021|6412020|6425020|12590020|12632020)")
label variable insulins_short " (bnfgrouping) Short-acting insulins exposure: 0=no exp, 1=exp"

// Intermediate- and long-acting insulins
local longinscodes = "(49835020|55081020|79661020|58580020|55087020|74874020|3712007|49944020|54941020|55080020|74960020|79669020|79671020|70111020|74957020|79673020|79666020|51331020|59681020|59679020|52542020|49843020|50163020|79676020|82442020|79663020|56543020|79190020|78521020|76207020|83429020|87908020|87906020|90297020|90337020|90339020|90295020|90427020|90333020|90331020|90335020|52830020|54128020|54127020|79702020|69694020|63796020|49940020|80932020|63802020|57900020|84665020|82035020|76875020|83427020|87904020|90265020|90654020|90271020|90277020|90319020|90329020|90213020|70082020|59676020|69774020|79705020|79704020|80959020|80960020|80952020|59684020|63840020|51532020|63790020|57906020|80954020|84628020|80930020|90321020|90479020|90323020|90325020|90459020|90275020|63825020|80931020|80958020|90273020|90263020|90652020|90435020|78679020|70102020|90219020|54038020|63793020|57903020|74965020|79710020|80956020|90455020|90757020|63805020|90215020|79680020|90443020|80966020|74963020|80965020|80962020|78682020|!3480103|70187020|79711020|90283020|90255020|90441020|2400007|90257020|90259020|90267020|70184020|80928020|82443020|90279020|70049020|90433020|90315020|90461020|86928020|63843020|90429020|90247020|90243020|90317020|76722020|55079020|50501020|55090020|90241020|93242020|90281020|90660020|90457020|90755020|93946020|55761020|95964020|95962020|53971020|97822020|98797020|97820020|98795020|79955020|99132020|99330020|99839020|50689020|10359020|10331020|12634020|6430020|80971020|47932020|47930020|12614020|17903020|47929020|47927020|47928020|12566020|10356020|47931020|12590020|12632020)"
gen insulins_intlong = 0
replace insulins_intlong = 1 if regexm(gemscriptcode, "`longinscodes'") 
label variable insulins_intlong " (bnfgrouping) Intermediate- and long-acting insulins exposure: 0=no exp, 1=exp"

// Any insulin (incl 2 above groups)
gen insulin = 0
replace insulin = 1 if insulins_short==1|insulins_intlong==1
label variable insulin "Any insulin exposure: 0=no exposure, 1=exp"

// Sulfonylureas
local sucodes = "(62964020|62969020|60964020|59349020|60965020|58649020|59442020|59348020|57865020|85843020|86064020|85842020|62965020|62970020|85844020|85849020|85850020|85851020|48857020|51527020|48941020|48942020|49354020|4325007|67123020|86115020|79392020|67130020|49698020|79090020|51335020|49685020|49355020|90777020|5628007|59658020|55431020|50420020|62973020|67122020|91011020|67127020|62065020|57866020|86560020|67126020|4327007|59973020|63043020|57687020|48981020|59657020|61258020|59500020|56629020|57864020|59501020|56406020|57688020|79774020|50736020|56213020|49729020|49728020|49739020|57807020|59042020|59788020|50743020|59191020|72686020|94881020|53403020|49738020|53404020|!2927101|57661020|98455020|98457020|59538020|96782020|95099020|64408020|98124020|55743020|162021|94946020|67587020|6454020|75238020|6450020|92795020|71529020|93429020|15505021|6443020)"
gen sulfonylurea = 0
replace sulfonylurea = 1 if regexm(gemscriptcode, "`sucodes'")
label variable sulfonylurea "Sulfonylurea exposure: 0=no exp, 1=exp"

// Biguanides (metformin is only one)
local metcodes = "(59546020|59547020|87778020|4728007|5764007|87314020|88736020|49689020|88490020|88486020|49690020|4729007|87308020|87304020|87306020|87310020|88484020|88518020|88516020|91464020|88488020|88738020|4727007|87312020|91560020|!4475601|79819020|79820020|64461020|91562020|91566020|91466020|50018020|50023020|54086020|54085020|63619020|50022020|53448020|60544020|53447020|55463020|50019020|55462020|94757020|94759020|95310020|95312020|94763020|94761020|95535020|96700020|96702020|96915020|96921020|96919020|96917020|87095020|74697020|95970020|98591020|74074020|99303020|99997020|365021|69565020|10132020|10871020|10131020|45093020|6549020|6537020|10870020|10129020|6535020|41441020|6538020|45092020|45094020|10134020|10130020|45213020|63023020|45095020|91995020|46992020|69568020|46994020|84275020|6530020|66298020|46993020|15731021|15681021)"
gen metformin = 0
replace metformin = 1 if regexm(gemscriptcode, "`metcodes'")
label variable metformin "Metformin exposure: 0=no exp, 1=exp"

// TZDs
local tzdcodes = "(48025020|82943020|77121020|82944020|87229020|87314020|88490020|88486020|82308020|77122020|87091020|83356020|87308020|87304020|87306020|87310020|88484020|88518020|88516020|85666020|88488020|82309020|87312020|91560020|87093020|77117020|77118020|86032020|91562020|5182007|91566020|65350020|65353020|65890020|82942020|84572020|48026020|66927020|82307020|78160020|11887020|78157020|93429020|85647020|40568020)"
gen tzd = 0
replace tzd = 1 if regexm(gemscriptcode, "`tzdcodes'")
label variable tzd "tzd exposure: 0=no exp, 1=exp"

// DPP-4 Inhibitors
local dppcodes = "(93519020|93521020|94757020|94104020|94759020|94763020|94109020|94761020|97586020|97590020|95970020|98591020|99663020|99665020|361021|363021|40627020|40625020|40628020|40626020|45093020|45092020|45094020|45095020|46992020|46994020|46993020)"
gen dpp = 0
replace dpp = 1 if regexm(gemscriptcode, "`dppcodes'")
label variable dpp "DPP-4 inhibitor exposure: 0=no exp, 1=exp"

// GLP-1 Receptor Agonists
local glpcodes = "(93411020|93407020|93413020|93405020|97165020|97163020|71021|74021|47959020|47955020|47957020|47956020|47960020|47958020)"
gen glp = 0 
replace glp = 1 if regexm(gemscriptcode, "`glpcodes'") 
label variable glp "GLP-1 RA exposure: 0=no exp, 1=exp"

// Other antidiabetics
local otherDMcodes="(52463020|52464020|54150020|86569020|86570020|54151020|78046020|78047020|78045020|78050020|78051020|78052020|86568020|86573020|86572020|86574020|92273020|92271020|92269020|7000020|46671020|46672020|46673020|46674020)"
gen otherantidiab = 0 
replace otherantidiab = 1 if regexm(gemscriptcode, "`otherDMcodes'") 
label variable otherantidiab "Other antidiabetic exposure: 0=no exp, 1=exp"

//#3 Encode an rxtype categorical variable for the classes of antidiabetic agents of interest

gen rxtype=.
replace rxtype=0 if inlist(sulfonylurea, 1)
replace rxtype=1 if inlist(dpp, 1)
replace rxtype=2 if inlist(glp, 1)
replace rxtype=3 if inlist(insulin, 1)
replace rxtype=4 if inlist(tzd, 1)
replace rxtype=5 if inlist(otherantidiab, 1)
replace rxtype=6 if inlist(metformin, 1)
label var rxtype "Antidiabetic prescription type: 0=SU, 1=DPP, 2=GLP, 3=insulin, 4=tzd, 5=other, 6=met, 99=combo"
label define rxtypelabels 0 "SU" 1 "DPP" 2 "GLP" 3 "insulin" 4 "TZD" 5 "other" 6 "metformin" 7 "mdcombo" 8 "mtcombo" 99 "combination"
label values rxtype rxtypelabels

//drop all irrelevant prescriptions
drop if rxtype==.

//#4 Collapse exact duplicate prescriptions assuming that they were used over time but obtained on one day

//check for exact duplicates and collapse over date, type, and amt while summing qty
bysort patid rxdate2 gemscriptcode ndd qty issueseq: gen multiplicity= cond(_N==1,0,_n)
bysort patid rxdate2 gemscriptcode ndd qty issueseq: egen qtysum=sum(qty)if multiplicity>0
replace qty=qtysum if multiplicity==1
drop if multiplicity>1
drop qtysum
label var multiplicity "Indicates whether prescription was collapsed due to multiplicity 1=yes, 0=no"
drop gemscriptcode issueseq
save Therapy_`i'dm2, replace
}
use Therapy_0dm2, clear
save adm_drug_exposures, replace
erase "Therapy_0dm2.dta"
forval i=1/49	{
use adm_drug_exposures
append using Therapy_`i'dm2
save adm_drug_exposures, replace
erase "Therapy_`i'dm2.dta"
}
clear
use adm_drug_exposures, clear

//identify combo pills and account for each class exposure (metformin, tzd, and dpp)
egen codesum=rowtotal(metformin tzd dpp glp insulin otherantidiab sulfonylurea)
label var codesum "Indicator for combo pills: 1=not combo; >1=combo pill"
expand codesum, generate(integratedrx)
label var integratedrx "Indicator for part of a combo pill: 1=orginially combo"
replace rxtype= 7 if codesum==2&metformin==1&dpp==1
replace rxtype= 8 if codesum==2&metformin==1&tzd==1
replace metformin=0 if integratedrx==1
replace tzd=0 if codesum==2& integratedrx==0
replace dpp=0 if codesum==2& integratedrx==0
label drop rxtypelabels
label define rxtypelabels 0 "SU" 1 "DPP" 2 "GLP" 3 "insulin" 4 "TZD" 5 "other" 6 "metformin" 7 "mdcombo" 8 "mtcombo" 99 "combination"
label values rxtype rxtypelabels

//#5 Generate count variables.

//enumerate overall prescription order WITHIN EACH CLASS; CLASSES NOT ORDERED
sort patid rxtype rxdate2
bysort patid rxtype: gen wirxtypeorder=_n
label var wirxtypeorder "Overall prescription order within each antidiabetic class"
//enumerate exposure to classes
bysort patid wirxtypeorder: gen classexp=_n if wirxtypeorder==1
label var classexp "Prescription order within each class (rxtype) ties not boken"
//enumerate exposure order to each class of antidiabetic
bysort patid: egen exporder=rank(rxdate2) if classexp!=., track
label var exporder "Order of exposure to antidiabetic classes, ties not broken"

//#5a Generate OVERALL date variables: firstdate(should=studyentrydate), metformint0 (should=cohortentrydate), and indext0 (should=indexdate).

//pull out first antidiabetic prescription date ever
bysort patid:egen firstdate = min(rxdate2) if rxtype<.
format first %td
label var firstdate "Earliest date for any antidiabetic prescription (should=studyentrydate)"

//generate an indicator for each prescription denoting whether it matches the earliest date or not
gen firstexp=0
replace firstexp=1 if firstdate==rxdate2
label var firstexp "Indicator for whether rxdate2 for each prescription was the earliest date. 1=first, 0=after"

//#5b Pull out types of antidiabetic combination exposures for OVERALL primary exposure date

//pull out first prescription type- THIS IS NOT UNIQUE. There may be multiple first prescriptions per patid (combos or duplicates of rxtype)
gen firstadmrxs=.
replace firstadmrxs=rxtype if firstexp==1
label values firstadmrxs rxtypelabels
label var firstadmrxs "Class (rxtype) of first antidiabetic prescription ever"
//pull out one (of duplicates) and identify all first prescriptions whether metoformin, metformin combos, or other combos
//generate a string var of first rxtypes
decode firstadmrxs if firstadmrxs!=., gen(rxtype_f)
label var rxtype_f "String var of all prescriptions on earliest date (includes duplicates and combos)"
drop firstadmrxs
//return one of each rxtype if present anywhere in the patid's firsttype, then fill for the patid.
bysort patid: gen frx8=regexs(0) if regexm(rxtype_f, "mtcombo")
xfill frx8, i(patid)
bysort patid: gen frx7=regexs(0) if regexm(rxtype_f, "mdcombo")
xfill frx7, i(patid)
bysort patid: gen frx6=regexs(0) if regexm(rxtype_f, "metformin")
xfill frx6, i(patid)
bysort patid: gen frx5=regexs(0) if regexm(rxtype_f, "other")
xfill frx5, i(patid)
bysort patid: gen frx4=regexs(0) if regexm(rxtype_f, "TZD")
xfill frx4, i(patid)
bysort patid: gen frx3=regexs(0) if regexm(rxtype_f, "insulin")
xfill frx3, i(patid)
bysort patid: gen frx2=regexs(0) if regexm(rxtype_f, "GLP")
xfill frx2, i(patid)
bysort patid: gen frx1=regexs(0) if regexm(rxtype_f, "DPP")
xfill frx1, i(patid)
bysort patid: gen frx0=regexs(0) if regexm(rxtype_f, "SU")
xfill frx0, i(patid)
//return one copy of the concatenated "first" prescription for each patid.
sort classexp
egen firstadmrx=concat(frx6 frx0 frx1 frx2 frx3 frx4 frx5 frx7 frx8) if classexp==1
label var firstadmrx "Exact first aDM prescription for each patid"
gen firstadmrxdate=firstdate if firstadmrx!=""
format firstadmrxdate %td
label var firstadmrxdate "Date associated with the first admrx exposure for each patid"
drop frx* rxtype_f 
//create a flag for patid's with ineligible first prescriptions, combo first prescriptions (met+any), and simple met
gen firstcat=3
replace firstcat=1 if firstadmrx=="metformin"
replace firstcat=2 if regexm(firstadmrx, "metformin[a-zA-Z]")
replace firstcat=2 if regexm(firstadmrx, "[a-zA-Z]combo$")
bysort patid: egen firstcats=min(firstcat)
replace firstcat=firstcats
label var firstcat "Category of first aDM rx: 1=met 1st cohort, 2=metcombo 1st cohort, 3=inelgible"
drop firstcats
//flag if first antidiabetic is something other than metformin
bysort patid: gen byte cohort_b=1 if firstcat==1
replace cohort_b=0 if cohort_b!=1
label var cohort_b "Binary indicator for metformin cohort: 1=metformin only first;  0=other antidiabetic first"
//drop if metformin NOT the first antidiabetic agent or combination agent
//replace the rxtype with individual components for combopills
gen combomarker=.
replace combomarker=1 if (rxtype==7|rxtype==8)
replace rxtype=6 if rxtype==8& metformin==1
replace rxtype=4 if rxtype==8& tzd==1
replace rxtype=6 if rxtype==7& metformin==1
replace rxtype=1 if rxtype==7& dpp==1
drop integratedrx
//recast counts
drop wirxtypeorder classexp exporder
sort patid rxtype rxdate2
bysort patid rxtype: gen wirxtypeorder=_n
label var wirxtypeorder "Overall prescription order within each antidiabetic class"
//enumerate exposure to classes
bysort patid wirxtypeorder: gen classexp=_n if wirxtypeorder==1
label var classexp "Prescription order within each class (rxtype) ties not boken"
//enumerate exposure order to each class of antidiabetic
bysort patid: egen exporder=rank(rxdate2) if classexp!=., track
label var exporder "Order of exposure to antidiabetic classes, ties not broken"
//generate a binary indicator for patients in metformin first cohort experiencing metformin monotherapy
bysort patid: egen monomet_b=max(exporder) if cohort_b==1
replace monomet_b=0 if monomet_b!=1 &cohort_b==1
label var monomet_b "Metformin monotherapy or not(0= NOT mono, 1= metformin monotherapy)"
notes monomet_b: This variable only includes values for patients in the metformin only first cohort. If metfromin combination first or some other adm first, their patid is associated with a missing value for this variable.
//#5c Pull out types of antidiabetic combination exposures for OVERALL second exposure date (INDEXDATE)

//generate an identifier for WHOLE BASE COHORT (165,292) of second antidiabetic agent exposure
bysort patid: egen indexdate=min(rxdate2) if exporder==2
format indexdate %td
label var indexdate "Date of first exposure to a second antidiabetic"
notes indexdate: This is the second exposure to any antidiabetic for the whole cohort.
gen second=1 if rxdate2==indexdate
replace second=0 if second!=1
label var second "Indicator for 1st exposure to 2nd antidiabetic: 1=index exposure, 0=not index exposure"
//generate a variable for rxtype if index
gen indextype = rxtype if second==1
label values indextype rxtypelabels
label var indextype "rxtype of index prescription(s)"
//identify each one (of duplicates) and combination antidiabetics that match indexdate
decode indextype, gen(rxtype_i)
bysort patid: gen crx6=regexs(0) if regexm(rxtype_i, "metformin")
xfill crx6, i(patid)
bysort patid: gen crx5=regexs(0) if regexm(rxtype_i, "other")
xfill crx5, i(patid)
bysort patid: gen crx4=regexs(0) if regexm(rxtype_i, "TZD")
xfill crx4, i(patid)
bysort patid: gen crx3=regexs(0) if regexm(rxtype_i, "insulin")
xfill crx3, i(patid)
bysort patid: gen crx2=regexs(0) if regexm(rxtype_i, "GLP")
xfill crx2, i(patid)
bysort patid: gen crx1=regexs(0) if regexm(rxtype_i, "DPP")
xfill crx1, i(patid)
bysort patid: gen crx0=regexs(0) if regexm(rxtype_i, "SU")
xfill crx0, i(patid)
//return one copy per patid of the antidiabetic or combination at indexdate
sort patid second
bysort patid second: gen flag=_n if second==1
egen secondadmrx=concat(crx6 crx0 crx1 crx2 crx3 crx4 crx5) if flag==1
gen seconddate=indexdate
format seconddate %td
drop crx* flag rxtype_i

//generate an indicator for WHOLE BASE COHORT (165292) patients with a third antidiabetic exposure
bysort patid: egen thirddate=min(rxdate2) if exporder==3
format thirddate %td
label var thirddate "Date of third exposure to any antidiabetic agent"
gen third=1 if rxdate2==thirddate
replace third=0 if third!=1
label var third "Indicator for third antidiabetic exposure: 1=third exposure, 0=not third"
//generate a variable for rxtype if third
gen thirdtype = rxtype if third==1
label values thirdtype rxtypelabels
label var thirdtype "rxtype of third exposure antidiabetic agent(s)"
//identify each one (of duplicates) and combination antidiabetics that match thirddate
decode thirdtype, gen(rxtype_3)
bysort patid: gen trx6=regexs(0) if regexm(rxtype_3, "metformin")
xfill trx6, i(patid)
bysort patid: gen trx5=regexs(0) if regexm(rxtype_3, "other")
xfill trx5, i(patid)
bysort patid: gen trx4=regexs(0) if regexm(rxtype_3, "TZD")
xfill trx4, i(patid)
bysort patid: gen trx3=regexs(0) if regexm(rxtype_3, "insulin")
xfill trx3, i(patid)
bysort patid: gen trx2=regexs(0) if regexm(rxtype_3, "GLP")
xfill trx2, i(patid)
bysort patid: gen trx1=regexs(0) if regexm(rxtype_3, "DPP")
xfill trx1, i(patid)
bysort patid: gen trx0=regexs(0) if regexm(rxtype_3, "SU")
xfill trx0, i(patid)
//return one copy per patid of the antidiabetic or combination at thirddate
sort patid third
bysort patid third: gen flag=_n if third==1
egen thirdadmrx=concat(trx6 trx0 trx1 trx2 trx3 trx4 trx5) if flag==1
drop trx* flag rxtype_3 third thirdtype 

//generate an indicator for WHOLE BASE COHORT (165292) patients with a fourth antidiabetic exposure
bysort patid: egen fourthdate=min(rxdate2) if exporder==4
format fourthdate %td
label var fourthdate "Date of fourth exposure to any antidiabetic agent"
gen fourth=1 if rxdate2==fourthdate
replace fourth=0 if fourth!=1
label var fourth "Indicator for fourth antidiabetic exposure: 1=fourth exposure, 0=not fourth"
//generate a variable for rxtype if third
gen fourthtype = rxtype if fourth==1
label values fourthtype rxtypelabels
label var fourthtype "rxtype of fourth exposure antidiabetic agent(s)"
//identify each one (of duplicates) and combination antidiabetics that match fourthdate
decode fourthtype, gen(rxtype_4)
bysort patid: gen orx6=regexs(0) if regexm(rxtype_4, "metformin")
xfill orx6, i(patid)
bysort patid: gen orx5=regexs(0) if regexm(rxtype_4, "other")
xfill orx5, i(patid)
bysort patid: gen orx4=regexs(0) if regexm(rxtype_4, "TZD")
xfill orx4, i(patid)
bysort patid: gen orx3=regexs(0) if regexm(rxtype_4, "insulin")
xfill orx3, i(patid)
bysort patid: gen orx2=regexs(0) if regexm(rxtype_4, "GLP")
xfill orx2, i(patid)
bysort patid: gen orx1=regexs(0) if regexm(rxtype_4, "DPP")
xfill orx1, i(patid)
bysort patid: gen orx0=regexs(0) if regexm(rxtype_4, "SU")
xfill orx0, i(patid)
//return one copy per patid of the antidiabetic or combination at fourthdate
sort patid fourth
bysort patid fourth: gen flag=_n if fourth==1
egen fourthadmrx=concat(orx6 orx0 orx1 orx2 orx3 orx4 orx5) if flag==1
drop orx* flag rxtype_4 fourth fourthtype 

//generate an indicator for WHOLE BASE COHORT (165292) patients with a fifth antidiabetic exposure
bysort patid: egen fifthdate=min(rxdate2) if exporder==5
format fifthdate %td
label var fifthdate "Date of fifth exposure to any antidiabetic agent"
gen fifth=1 if rxdate2==fifthdate
replace fifth=0 if fifth!=1
label var fifth "Indicator for fifth antidiabetic exposure: 1=fifth exposure, 0=not fifth"
//generate a variable for rxtype if third
gen fifthtype = rxtype if fifth==1
label values fifthtype rxtypelabels
label var fifthtype "rxtype of fifth exposure antidiabetic agent(s)"
//identify each one (of duplicates) and combination antidiabetics that match fourthdate
decode fifthtype, gen(rxtype_5)
bysort patid: gen vrx6=regexs(0) if regexm(rxtype_5, "metformin")
xfill vrx6, i(patid)
bysort patid: gen vrx5=regexs(0) if regexm(rxtype_5, "other")
xfill vrx5, i(patid)
bysort patid: gen vrx4=regexs(0) if regexm(rxtype_5, "TZD")
xfill vrx4, i(patid)
bysort patid: gen vrx3=regexs(0) if regexm(rxtype_5, "insulin")
xfill vrx3, i(patid)
bysort patid: gen vrx2=regexs(0) if regexm(rxtype_5, "GLP")
xfill vrx2, i(patid)
bysort patid: gen vrx1=regexs(0) if regexm(rxtype_5, "DPP")
xfill vrx1, i(patid)
bysort patid: gen vrx0=regexs(0) if regexm(rxtype_5, "SU")
xfill vrx0, i(patid)
//return one copy per patid of the antidiabetic or combination at fifthdate
sort patid fifth
bysort patid fifth: gen flag=_n if fifth==1
egen fifthadmrx=concat(vrx6 vrx0 vrx1 vrx2 vrx3 vrx4 vrx5) if flag==1
drop vrx* flag rxtype_5 fifth fifthtype

//generate an indicator for WHOLE BASE COHORT (165292) patients with a sixth antidiabetic exposure
bysort patid: egen sixthdate=min(rxdate2) if exporder==6
format sixthdate %td
label var sixthdate "Date of sixth exposure to any antidiabetic agent"
gen sixth=1 if rxdate2==sixthdate
replace sixth=0 if sixth!=1
label var sixth "Indicator for sixth antidiabetic exposure: 1=sixth exposure, 0=not sixth"
//generate a variable for rxtype if third
gen sixthtype = rxtype if sixth==1
label values sixthtype rxtypelabels
label var sixthtype "rxtype of sixth exposure antidiabetic agent(s)"
//identify each one (of duplicates) and combination antidiabetics that match fourthdate
decode sixthtype, gen(rxtype_6)
bysort patid: gen srx6=regexs(0) if regexm(rxtype_6, "metformin")
xfill srx6, i(patid)
bysort patid: gen srx5=regexs(0) if regexm(rxtype_6, "other")
xfill srx5, i(patid)
bysort patid: gen srx4=regexs(0) if regexm(rxtype_6, "TZD")
xfill srx4, i(patid)
bysort patid: gen srx3=regexs(0) if regexm(rxtype_6, "insulin")
xfill srx3, i(patid)
bysort patid: gen srx2=regexs(0) if regexm(rxtype_6, "GLP")
xfill srx2, i(patid)
bysort patid: gen srx1=regexs(0) if regexm(rxtype_6, "DPP")
xfill srx1, i(patid)
bysort patid: gen srx0=regexs(0) if regexm(rxtype_6, "SU")
xfill srx0, i(patid)
//return one copy per patid of the antidiabetic or combination at sixthdate
sort patid sixth
bysort patid sixth: gen flag=_n if sixth==1
egen sixthadmrx=concat(srx6 srx0 srx1 srx2 srx3 srx4 srx5) if flag==1
drop srx* flag rxtype_6 sixth sixthtype  

//generate an indicator for WHOLE BASE COHORT (165292) patients with a seventh antidiabetic exposure
bysort patid: egen seventhdate=min(rxdate2) if exporder==7
format seventhdate %td
label var seventhdate "Date of seventh exposure to any antidiabetic agent"
gen seventh=1 if rxdate2==seventhdate
replace seventh=0 if seventh!=1
label var seventh "Indicator for seventh antidiabetic exposure: 1=seventh exposure, 0=not seventh"
//generate a variable for rxtype if third
gen seventhtype = rxtype if seventh==1
label values seventhtype rxtypelabels
label var seventhtype "rxtype of seventh exposure antidiabetic agent(s)"
//identify each one (of duplicates) and combination antidiabetics that match fourthdate
decode seventhtype, gen(rxtype_7)
bysort patid: gen erx6=regexs(0) if regexm(rxtype_7, "metformin")
xfill erx6, i(patid)
bysort patid: gen erx5=regexs(0) if regexm(rxtype_7, "other")
xfill erx5, i(patid)
bysort patid: gen erx4=regexs(0) if regexm(rxtype_7, "TZD")
xfill erx4, i(patid)
bysort patid: gen erx3=regexs(0) if regexm(rxtype_7, "insulin")
xfill erx3, i(patid)
bysort patid: gen erx2=regexs(0) if regexm(rxtype_7, "GLP")
xfill erx2, i(patid)
bysort patid: gen erx1=regexs(0) if regexm(rxtype_7, "DPP")
xfill erx1, i(patid)
bysort patid: gen erx0=regexs(0) if regexm(rxtype_7, "SU")
xfill erx0, i(patid)
//return one copy per patid of the antidiabetic or combination at sixthdate
sort patid seventh
bysort patid seventh: gen flag=_n if seventh==1
egen seventhadmrx=concat(erx6 erx0 erx1 erx2 erx3 erx4 erx5) if flag==1
drop erx* flag rxtype_7 seventh seventhtype  

//#6 Generate and apply censor date
egen tx= rowmin(tod2 deathdate2 lcd2)
label var tx "Censor date: earliest of tod, deathdate, or lcd"
format tx %td

//#7 Generate predicted and next prescription date WITHIN EACH CLASS

//Generate a prediction factor to account for the expected length of exposure for each prescription
gen predfactor=.
replace predfactor = (qty/ndd)*1.5 if rxtype!=.
replace predfactor=90 if predfactor==.
replace predfactor=30 if predfactor<30
replace predfactor=90 if (qty>500|ndd<0.5|(ndd>.5&ndd<1))
replace predfactor=365 if predfactor>=365
recast int predfactor, force
label var predfactor "Factor used to predict next prescription date"
notes predfactor: (qty/numeric daily dose)*1.5 OR 90 days if missing qty or ndd OR 365 if predfactor>=365

//Pull out first, predicted, next, and last prescription dates WITHIN EACH CLASS
//Generate exposure start time variables for each class of antidiabetic (rxtype)
foreach var of varlist metformin sulfonylurea dpp glp insulin tzd otherantidiab  {
bysort patid: egen `var't0= min(rxdate2) if `var'==1
format `var't0 %td
label var `var't0 "First `var' exposure date"
}

//Confirm the indexdate generated above matches the indexdate generated using the earliest exposure WITHIN EACH CLASS
egen index=rowmin(sulfonylureat0 dppt0 glpt0 insulint0 tzdt0 otherantidiabt0) if cohort_b==1
format index %td
bysort patid: egen indext0=min(index)
format indext0 %td
drop index
rename indext0 index
label var index "Index date (earliest date of exposure to a second antidiabetic)"
rename indexdate indext0
label var indext0 "Index date (earliest date of exposure to a second antidiabetic)"

//Generate exposure stop time variables WITHIN EACH CLASS of antidiabetic (rxtype)
foreach var of varlist metformin sulfonylurea dpp glp insulin tzd otherantidiab {
bysort patid: egen `var't2= max(rxdate2) if `var'==1
format `var't2 %td	
label var `var't2 "Last `var' prescription date ever"
bysort patid: gen `var'tx=`var't2+predfactor
bysort patid: replace `var'tx=tx if `var'tx>tx &`var'tx!=.
format `var'tx %td
label var `var'tx "Last ever exposure date to `var' (including predfactor and censor date)"
}

//Generate the predicted next prescription date WITHIN EACH CLASS
foreach var of varlist metformin sulfonylurea dpp glp insulin tzd otherantidiab {
sort patid rxtype rxdate2
bysort patid rxtype: gen `var'_pred = (rxdate2+predfactor) if `var'==1
format `var'_pred %td
label var `var'_pred "Next PREDICTED prescription date for `var'"
//Pull out the actual next prescription date
bysort patid rxtype: gen `var'_next = rxdate2[_n+1] if `var'==1
format `var'_next %td
label var `var'_next "Next OBSERVED presciption date for `var'"
}

//#8 Generate gap variables between predicted and observed prescription dates WITHIN EACH CLASS

//Generate variable for number of days beyond the predicted date the actual next prescription was filled
foreach var of varlist metformin sulfonylurea dpp glp insulin tzd otherantidiab {
bysort patid: gen `var'_gap = `var'_next-`var'_pred if `var'_next!=.&`var'_pred!=.
label var `var'_gap "Number of days past predicted refill date for `var' "
}

//#9 Generate duration for EXPOSED intervals FOR EACH PRESCRIPTION

//pull out every t0 (start switch or add drug class of interest) and associated t1 (stop, discontonuous prescription filling history, end of study)
gen exposure_b=.
label var exposure_b "Exposure binary for antiDM:continuous==1, discontinuous==0, NOT of interest==."
//Generate every start and stop date covering an exposed period or unexposed period
gen t0=.
gen t1=.
gen duration=.
replace t0=rxdate2
format t0 t1 %td
label var t0 "Start date of each prescription filled and each unexposure period (t0 for each exposure duration and t0 for each gap duration)"
notes t0: "t0 contains every rxdate2 as the start date of each exposure duration as well as every expanded date for the start date of each gap duration"
label var t1 "Stop date for each prescription filled and the end of each gap date"
notes t1: "t1 contains the stop dates associated with each t0 as either the end of a prescription (rxdate+predfactor OR next prescription filled date), the end of a gap duration (next prescription filled), or the censor date. Whichever comes first."

local rxlist "0 1 2 3 4 5 6"
local x=0
foreach var of varlist sulfonylurea dpp glp insulin tzd otherantidiab metformin {
local x=`x'+1
local next:word `x' of `rxlist'
replace t1=(t0+predfactor) if t0==`var't2 &rxtype==`next'
replace exposure_b=1 if t1!=. 
replace t1=`var'_next if `var'_gap<=0 &rxtype==`next'
replace exposure_b=1 if `var'_gap<=0 &rxtype==`next'
replace t1=`var'_pred if `var'_gap>0 & `var'_gap<. &rxtype==`next'
}

//#10 Generate duration for UNEXPOSED intervals

//expand the observations to build in unexposed durations
gen isgap=.
//generate a variable to flag gaps for expansion
foreach var of varlist metformin sulfonylurea dpp glp insulin tzd otherantidiab {
replace isgap=2 if `var'_gap>=1 & `var'_gap<.
}
//expand and enumerate in the count gap (ctgap) variable
expand isgap
label var isgap "Identifies gaps and is used to expand so the gap can have a start and stop date (t0 an t1)"
bysort patid rxtype rxdate2: gen ctgap= _n if isgap==2
label var ctgap "Enumerates the gaps identified by isgap"
replace exposure_b=0 if ctgap==2
drop if ctgap==3

//Populate t0 and t1 accourding to the gaps and associated predicted and next rx dates
//SU
replace t0=sulfonylurea_pred if ctgap==2 & rxtype==0
replace t1=sulfonylurea_next if ctgap==2 & rxtype==0
//DPP
replace t0=dpp_pred if ctgap==2 & rxtype==1
replace t1=dpp_next if ctgap==2 & rxtype==1
//GLP
replace t0=glp_pred if ctgap==2 & rxtype==2
replace t1=glp_next if ctgap==2 & rxtype==2
//Insulin
replace t0=insulin_pred if ctgap==2 & rxtype==3
replace t1=insulin_next if ctgap==2 & rxtype==3
//TZD
replace t0=tzd_pred if ctgap==2 & rxtype==4
replace t1=tzd_next if ctgap==2 & rxtype==4
//Other
replace t0=otherantidiab_pred if ctgap==2 & rxtype==5
replace t1=otherantidiab_next if ctgap==2 & rxtype==5
//Metformin
replace t0=metformin_pred if ctgap==2 & rxtype==6
replace t1=metformin_next if ctgap==2 & rxtype==6
//Populate exposure binary to indicate exposed/unexposed status
replace exposure_b=0 if isgap==2& ctgap==2
replace exposure_b=1 if isgap==2& ctgap==1
replace t1=tx if t1>=tx
replace t0=tx if t0>=tx

//Generate gap counts
foreach var of varlist metformin sulfonylurea dpp glp insulin tzd otherantidiab {
replace `var'_gap=t1-t0 if exposure_b==0
replace `var'_gap=0 if exposure_b==1
}
bysort patid rxtype: gen sulfonylureagaprun = sum(sulfonylurea_gap) if (sulfonylurea_gap>=1 & sulfonylurea_gap<. &exposure_b==0& rxtype==0)
bysort patid rxtype: gen dppgaprun = sum(dpp_gap) if (dpp_gap>=1 & dpp_gap<. &exposure_b==0& rxtype==1)
bysort patid rxtype: gen glpgaprun = sum(glp_gap) if (glp_gap>=1 & glp_gap<. &exposure_b==0& rxtype==2)
bysort patid rxtype: gen insulingaprun = sum(insulin_gap) if (insulin_gap>=1 & insulin_gap<. &exposure_b==0& rxtype==3)
bysort patid rxtype: gen tzdgaprun = sum(tzd_gap) if (tzd_gap>=1 & tzd_gap<. &exposure_b==0& rxtype==4)
bysort patid rxtype: gen otherantidiabgaprun = sum(otherantidiab_gap) if (otherantidiab_gap>=1 & otherantidiab_gap<. &exposure_b==0& rxtype==5)
bysort patid rxtype: gen metformingaprun = sum(metformin_gap) if (metformin_gap>=1 & metformin_gap<. &exposure_b==0& rxtype==6)

foreach var of varlist metformin sulfonylurea dpp glp insulin tzd otherantidiab	{
bysort patid: egen `var'gaptot = max(`var'gaprun) if `var'gaprun!=.
drop `var'gaprun
replace `var'gaptot=0 if `var'gaptot==.& exposure_b==1
label var `var'gaptot "Total days of gaps in `var' exposure per patid"
}
//#11 Generate OVERALL FOLLOW-UP duration: total follow-up time available minus gaptime (TCC)

//first generate last date of exposure (time between cohort entry and censor date in days)
bysort patid: egen lastdate= max(t1)
label var lastdate "Last date of exposure (max t1)"
format lastdate %td
gen tcc=.
replace tcc=lastdate-firstdate if lastdate!=. &firstdate!=.
label var tcc "Time between cohort entry date and censor date in days"
//then generate the time between the first exposure to each class and the censor date
bysort patid: egen suend=max(t1) if rxtype==0 & t1!=.
bysort patid: egen subegin=min(t0) if rxtype==0
gen sulfonylureatic = suend-subegin
label var sulfonylureatic "The total days between 1st and censor or last date of exposure to su"
bysort patid: egen dppend=max(t1) if rxtype==1 & t1!=.
bysort patid: egen dppbegin=min(t0) if rxtype==1
gen dpptic = dppend-dppbegin
label var dpptic "The total days between 1st and censor or last date of exposure to dpp"
bysort patid: egen glpend=max(t1) if rxtype==2 & t1!=.
bysort patid: egen glpbegin=min(t0) if rxtype==2
gen glptic = glpend-glpbegin
label var glptic "The total days between 1st and censor or last date of exposure to glp"
bysort patid: egen insend=max(t1) if rxtype==3 & t1!=.
bysort patid: egen insbegin=min(t0) if rxtype==3
gen insulintic =insend-insbegin
label var insulintic "The total days between 1st and censor or last date of exposure to ins"
bysort patid: egen tzdend=max(t1) if rxtype==4 & t1!=.
bysort patid: egen tzdbegin=min(t0) if rxtype==4
gen tzdtic = tzdend-tzdbegin
label var tzdtic "The total days between 1st and censor or last date of exposure to tzd"
bysort patid: egen othend=max(t1) if rxtype==5 & t1!=.
bysort patid: egen othbegin=min(t0) if rxtype==5
gen otherantidiabtic = othend-othbegin
label var otherantidiabtic "The total days between 1st and censor or last date of exposure to oth"
bysort patid: egen metend=max(t1) if rxtype==6 & t1!=.
bysort patid: egen metbegin=min(t0) if rxtype==6
gen metformintic = metend-metbegin
label var metformintic "The total days between 1st and censor or last date of exposure to met"
drop *end *begin

//then generate the duration of each t0/t1 interval 
replace duration=t1-t0 if t1!=. & t0!=.
label var duration "Duration of exposure for each prescription or prescription gap interval" 
//FINALLY, generate a variable for the total exposed days (duration)
foreach var of varlist metformin sulfonylurea dpp glp insulin tzd otherantidiab	{
gen `var'totexp = .
bysort patid rxtype: replace `var'totexp=`var'tic -`var'gaptot if `var'tic!=.&`var'gaptot!=.
label var `var'totexp "Total days exposed to `var'"
notes `var'totexp: Calculation is time from index date to censor date minus gaps
}

//Create a variable for last continuous exposure
sort patid rxdate2 rxtype
gen ts=.
replace ts=t1[_n-1] if exposure_b==0
bysort patid rxtype: replace ts=t1 if _n==1
bysort patid rxtype: egen t1s=min(ts)
label var t1s "Last continuous exposure to class; stands for t1'short'"
drop ts
format t1s %td
//Create a variable for ever used `var'
gen eversu=1 if exporder!=.& rxtype==0
bysort patid: egen ever0= max(eversu)
gen everdpp=1 if exporder!=.& rxtype==1
bysort patid: egen ever1= max(everdpp)
gen everglp=1 if exporder!=.& rxtype==2
bysort patid: egen ever2= max(everglp)
gen everins=1 if exporder!=.& rxtype==3
bysort patid: egen ever3= max(everins)
gen evertzd=1 if exporder!=.& rxtype==4
bysort patid: egen ever4= max(evertzd)
gen everoth=1 if exporder!=.& rxtype==5
bysort patid: egen ever5= max(everoth)
gen evermet=1 if exporder!=.& rxtype==6
bysort patid: egen ever6= max(evermet)
drop eversu everdpp everglp everins evertzd everoth evermet
local rxlist "sulfonylurea DPP GLP insulin TZD otherantidiab"
local x=0
forval i=0/6 {
local x=`x'+1
local next:word `x' of rxlist
label var ever`i' " Ever exposed to rxtype=`next'"
}
//#12 Determine how many classes of antidiabetic agents each patient was exposed to over the course of the study

//#13 Generate unique drugs used variable
bysort patid: egen unqrx=max(exporder)

//#14 Generate metformin overlap indicator
gen metoverlap_b=0
gen metoverlap =0
gen overlapstart=.
gen overlapend=.
bysort patid: gen lastmet = metformint2 if metformint2==rxdate2
bysort patid: egen pred = max(predfactor) if metformint2==rxdate2 &rxtype==6
xfill lastmet, i(patid)
xfill pred, i(patid)
bysort patid: replace overlapend= lastmet+pred
replace overlapend=. if rxtype==6
replace metoverlap_b = 1 if overlapend>t0 & rxtype!=6 &overlapend!=.
label var metoverlap_b "Binary indicator for antidiabetic agent overlap with metformin 1=overlap, 0=no overlap"
replace overlapstart =t0 if metoverlap_b==1
replace overlapend=t1 if overlapend>t1&rxtype!=6
bysort patid rxtype: egen lastmetoverlap = max(overlapend) if overlapend!=.
bysort patid rxtype: egen firstmetoverlap = min(overlapstart) 
bysort patid rxtype: replace metoverlap = overlapend-overlapstart if overlapend!=. & overlapstart!=.
replace metoverlap =. if exposure_b==0
bysort patid rxtype: gen totmetoverlap = lastmetoverlap-firstmetoverlap
drop overlapend overlapstart lastmet pred lastmetoverlap firstmetoverlap

//Calculate adherence
local rxlist "0 1 2 3 4 5 6"
local x=0
gen adherence=.
foreach var of varlist sulfonylurea dpp glp insulin tzd otherantidiab metformin {
local x=`x'+1
local next:word `x' of `rxlist'
replace adherence = `var'gaptot/`var'tic if exporder!=. & rxtype==`next'
}
//Tidy up the labels
label var firstadmrx "The first antidiabetic regimen"
label var firstadmrxdate "The date associated with the first antidiabetic regimen"
foreach numb in second third fourth fifth sixth seventh {
label var `numb'admrx "The `numb' antidiabetic regimen"
labe var `numb'date "The date associated with the `numb' antidiabetic regimen"
}
label var unqrx "Number of unique antidiabetic medications"
save Drug_Exposures_a.dta, replace

//################### generate "dates" dataset for future use########################
use Drug_Exposures_a.dta
keep patid studyentrydate_cprd2 metformint0 indext0 
collapse (min) studyentrydate_cprd2 metformint0 indext0, by(patid)
rename metformint0 cohortentrydate
rename indext0 indexdate
save Dates.dta, replace
clear

//################### generate "analytic variables" dataset for  use########################
use Drug_Exposures_a.dta
keep patid firstadmrx firstadmrxdate secondadmrx seconddate thirdadmrx thirddate fourthadmrx fourthdate fifthadmrx fifthdate sixthadmrx sixthdate seventhadmrx seventhdate ever* tx cohort_b unqrx
xfill firstadmrx firstadmrxdate secondadmrx seconddate thirdadmrx thirddate fourthadmrx fourthdate fifthadmrx fifthdate sixthadmrx sixthdate seventhadmrx seventhdate, i(patid)
collapse (first) firstadmrx firstadmrxdate secondadmrx seconddate thirdadmrx thirddate fourthadmrx fourthdate fifthadmrx fifthdate sixthadmrx sixthdate seventhadmrx seventhdate ever* tx cohort_b unqrx, by(patid)
//tidy labels
label var firstadmrx "The first antidiabetic regimen"
label var firstadmrxdate "The date associated with the first antidiabetic regimen"
foreach numb in second third fourth fifth sixth seventh {
label var `numb'admrx "The `numb' antidiabetic regimen"
labe var `numb'date "The date associated with the `numb' antidiabetic regimen"
}
local x=0
local names "sulfonylurea GLP-1RA DPP-4I insulin thiazolidinedione other-antidiabetic metformin"
forval i=0/6	{
local x= `x'+1
local next:word `x' of `names'
label var ever`i' "Indicator for ever exposed: 1=exposed to `next' otherwise missing "
}
label var tx "Censor date: calculated as earliest of lcd, tod, deathdate"
label var cohort_b "Metformin only first cohort: 1=met first; 0=other or met combo first"
label var unqrx "Total number of unique antidiabetic classes exposed to"
//merge with analytic variables.dta file generated in Data01_import.do: patid linked_practices hes_e death_e lsoa_e cprd_e start end lcd2 tod2 deathdate2 dod2
merge 1:1 patid using Analytic_variables, keep(match master) nogen
label var linked_practice "Indicator for linked practices: 1=linked to any secondary source; 0=cprd only source"
label var hes_e "Indicator for linked to HES: 1=linked; 0=not linked"
label var death_e "Indicator for linked to ONS: 1=linked; 0=not linked"
label var lsoa_e "Indicator for linked to LSOA: 1=linked; 0=not linked"
label var cprd_e "Indicator for CPRD: 1 for all patids"
save Analytic_variables_a.dta, replace
//############################## generate wide dataset for ###################################
use Drug_Exposures_a.dta, clear
keep patid rxtype t0 t1 t1s exporder exposure_b
bysort patid rxtype: egen exposuret0=min(t0) if exporder!=.&exposure_b==1
gen exposuret1=.
replace exposuret1=t1s if exposuret0!=.
bysort patid rxtype:egen exposuretf=max(t1) if t1!=.
drop if exposuret0==.
format exposure* %td
//rectangularize
fillin patid rxtype
//drop duplicates
bysort patid rxtype exporder: gen dupa = cond(_N==1,0,_n)
drop if dupa>1
drop dupa
//reshape to wide
keep patid rxtype exposuret0 exposuret1 exposuretf
reshape wide exposuret0 exposuret1 exposuretf, i(patid) j(rxtype)
local x=0
local names "sulfonylurea GLP-1RA DPP-4I insulin thiazolidinedione other-antidiabetic metformin"
forval i=0/6	{
local x= `x'+1
local next:word `x' of `names'
label var exposuret0`i' "First ever exposure to `next'"
label var exposuret1`i' "Last CONTINUOUS exposure to `next'"
label var exposuretf`i' "Last ever exposure to `next'"
}
//merge with ALL analytic variables
merge m:1 patid using Analytic_variables_a, keep(match master) nogen
label var tx "Censor date calculated as first of lcd, tod"
label var cohort_b "Binary indicator; 1=metformin first only cohort; 0=not in cohort"
label var unqrx "Number of unique antidiabetic medications"
save Drug_Exposures_a_wide.dta, replace
/////////////////////////////////////////FOR INITIAL DATA EXTRACTION, YOU CAN USE THE CODE BELOW TO GET SOME DESCRIPTIVE STATS////////////////////////////////////////
/*
//Duration between cohort entry date and initial exposure to a second antidiabetic agent
foreach var of varlist sulfonylurea dpp glp insulin tzd otherantidiab {
bysort patid rxtype: gen tci`var'= `var't0-cohortentrydate if `var'==1 & cohortentrydate!=. & `var't0>cohortentrydate
label var tci`var' "Time from first metformin (cohort entry date) to first exposure to `var' (indexdate)"
summarize tci`var', detail
}

//Duration of first CONTINUOUS exposure to each agent
foreach var of varlist metformin sulfonylurea dpp glp insulin tzd otherantidiab {
bysort patid rxtype: egen `var'stop1= min(`var't1)
format `var'stop1 %td
bysort patid: gen `var'_duration= `var'stop1-`var't0
gen `var'_dur=.
replace `var'_dur= `var'_duration if `var'==1 & num==1
drop `var'stop1 `var'_duration
}
foreach var of varlist metformin sulfonylurea dpp glp insulin tzd otherantidiab {
summarize `var'_totexp, detail
}
*/

timer off 1
timer list 1

exit
log close
