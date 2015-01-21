//  program:    Data08_outcomes_a.do
//  task:		Generate variables for clinical events (outcomes of interest) using CPRD-GOLD (other .do files for HES, ONS and composite)
//  project: 	Incretins--Comparative mortality and CV outcomes (CPRD)
//  author:     MA \ May2014 \ jmg modified June2014 Modified JM \ Nov 2014

clear all
capture log close
set more off

log using Data08a.smcl, replace
timer on 1

// #1 Merge Dates dataset with Clinical and Additional

foreach file in Clinical001_2 Clinical002_2 Clinical003_2 Clinical004_2 Clinical005_2 Clinical006_2 Clinical007_2 Clinical008_2 ///
				Clinical009_2 Clinical010_2 Clinical011_2 Clinical012_2 Clinical013_2 {
use `file', clear
sort patid
merge m:1 patid using Dates, keep(match) nogen
keep if eventdate2>studyentrydate_cprd2
sort patid
joinby patid adid using Additional, unmatched(master) _merge(Additional_merge)
merge m:1 patid using Patient, keep(match) nogen
compress
save `file'a.dta, replace
}
clear

// #2 Generate binary variables coding for each OUTCOME clinical event. 
// Code so 0=no event and 1=event. For each event: generate, replace, label
// Based on readcode variable, source of readcodes identified for each outcome/source.

//PRIMARY OUTCOMES
////// #2a All-cause mortality
foreach file in Clinical001_2a Clinical002_2a Clinical003_2a Clinical004_2a Clinical005_2a Clinical006_2a Clinical007_2a Clinical008_2a ///
				Clinical009_2a Clinical010_2a Clinical011_2a Clinical012_2a Clinical013_2a {

use `file', clear
gen death_g = (deathdate2!=.)
label var death_g "Indicator for death using CPRD algorithm"

////// #2b Composite of major CV-related morbidity and mortality (non-fatal/fatal MI, non-fatal/fatal stroke, CV death)
// Code binary variable for each source of outcome info (CPRD GOLD "_g", ONS "_o", HES "_h", combo "_all")

// Myocardial Infarction
// readcode source: Delaney, BMC Cardiovascular Disorders, 2007 (Additional File 1); 
gen myoinfarct_g = 0 
replace myoinfarct_g = 1 if regexm(readcode, "323..00|G30X.00|G361.00|G361.00|G362.00|G362.00|4100N|4109TE|4109TM|4119N|14A4.00|3234|G304.00|G308.00|G30y200|G366.00|G366.00|4129MC|4140|G307.00|G34y100|G360.00|G360.00|G305.00|4109CR|4129N|G30..15|G300.00|G344.00|G38..00|4129RE|G302.00|G303.00|4109TL|3235|G301.00|G301000|G31y200|G5y1.00|322..00|322Z.00|G30..17|4149|14A3.00|G381.00|G306.00|G30..00|G30z.00|G32..12|G350.00|4100NA|4109CL|4109N|4109NA|4109NH|4129AM|4109NC|4129NS")
replace myoinfarct_g = 0 if constype!=3
label variable myoinfarct_g "MI (gold) 1=event 0=no event"

// Stroke
// readcode source: most from Lo Re, PDS, 2012 (Supplemental Appendix B) -- final 12 (OXMIS codes??) from unknown source; 
gen stroke_g = 0
replace stroke_g = 1 if regexm(readcode, "I11.0|I21.?|I22.?|I23.?|I24.?|I25.?|I26.?|I40.?|I42.?|I44.?|I45.?|I46.?|I46.1|I47.?|I48.?|I49.?|I50.?|I60.?|I61.?|I62.?|I63.?|I64.?|I65.?|I66.?|I67.0|I67.6|I67.7|I69.?|I70.0|I81|I82.0|I82.3|I82.4x|I82.60|I82.62|I82.A1x|I82.B1x|I82.C1x|I82.890|I82.90")
replace stroke_g = 0 if constype!=3
label variable stroke_g  "Stroke (gold) 1=event 0=no event"

// CV death
// readcode source: Lo Re, PDS, 2012 (Supplemental Appendix C); 

gen cvdeath_g = 0
replace cvdeath_g = 1 if regexm(readcode, "G2101|G2111|G21z1|G30..|G300.|G301.|G3010|G3011|G301z|G302.|G303.|G304.|G305.|G306.|G307.|G3070|G3071|G308.|G309.|G30a.|G30b.|G30x.|G30x0|G30y.|G30y0|G30y1|G30y2|G30yz|G30z.|G38..|G380.|G381.|G382.|G383.|G384.|G38z.|Gyu34|G35..|G350.|G351.|G353.|Gyu35|G35x.|Gyu36|G36..|G360.|G361.|G362.|G363.|G364.|G365.|G366.|G501.|Gyu31|G310.|G3110|G312.|G31y.|G31y0|G31y1|G31y2|G31y3|G31yz|Gyu32|G32..|G34..|G340.|G3400|G3401|G341.|G3410|G3411|G3412|G3413|G341z|G342.|G343.|G344.|G34y.|G34y0|G34y1|G34yz|G34z.|G34z0|G3y..|G3z..|G5y2.|Gyu33|G40..|G400.|G40z.|G401.|G4010|G4011|G402.|G52..|G52y.|G52y0|G52y1|G52y2|G52y3|G52y4|G52y5|G52y6|G52y7|G52yz|G52z.|Gyu5f|Gyu5g|G55..|G550.|G551.|G552.|G553.|G554.|G5540|G5541|G5542|G5543|G5544|G5545|G554z|G555.|G559.|G55a.|G55y.|G55y0|G55z.|G5yy0|G5yy1|G5yy3|G5yy4|Gyu5m|Gyu5n|Gyu5p|G56..|G560.|G561.|G5610|G5611|G5612|G5613|G5614|G561z|G562.|G5620|G5621|G562z|G563.|Gyu5u|Gyu5v|G564.|G565.|G5650|G5651|G5652|G5653|G5654|G5655|G565z|G566.|G5660|G5661|G5662|G566z|G567.|G5670|G5671|G5672|G5673|G5674|G567z|G56y.|G56y0|G56y1|G56y2|G56y3|G56y4|G56y5|G56yz|G56z.|G56z0|G56zz|Gyu5w|Gyu5x|Gyu5y|G575.|G5750|G5751|G5752|G5753|G575z|G5751|G57..|G570.|G5700|G5701|G5702|G5703|G570z|G571.|G572.|G5720|G5721|G572z|G57y7|G57y9|G57ya|G573.|G5730|G5731|G5732|G5733|G5734|G5735|G573z|G574.|G5740|G5741|G574z|G576.|G5760|G5761|G5762|G5763|G5764|G5765|G576z|G577.|G57y.|G57y0|G57y1|G57y2|G57y3|G57y4|G57y5|G57y6|G57yz|G57z.|Gyu5a|Gyu5z|G58..|G580.|G5800|G5801|G5802|G5803|G5804|G581.|G5810|G582.|G583.|G58z.|G60..|G600.|G601.|G602.|G603.|G604.|G605.|G606.|G60x.|G60z.|Gyu6.|Gyu60|Gyu61|Gyu6e|G61..|G610.|G611.|G612.|G613.|G614.|G615.|G616.|G617.|G618.|G61x.|G61x0|G61x1|G61z.|Gyu62|Gyu6f|G62..|G620.|G621.|G622.|G623.|G62z.|G63y0|G63y1|G64..|G6400|G6410|G64z.|G64z0|G64z2|G64z3|G64z4|G6760|G6w..|G6x..|Gyu63|Gyu64|Gyu6g|G65z1|G66..|G667.|G668.|G669.|G63..|G630.|G631.|G632.|G633.|G634.|G63y.|G63z.|Gyu65|G640.|G641.|G64z1|G677.|G6770|G6771|G6772|G6773|G6774|Gyu66|G6730|G6732|G676.|G67a.|G674.|G68..|G680.|G681.|G682.|G683.|G68w.|G68x.|Gyu6b|Gyu6c|G700.|G8010|G8016|G80y0|G80y1|G80y2|G80y3|G80y4|G80y5|G80y6|G80y7|G80y8|G801.|G8011|G8012|G8013|G8014|G8015|G8017|G8018|G8019|G801a|G801b|G801c|G801d|G801e|G801f|Gyu80|Sp122|G801z|G802.|G8020|G80y.|G80y9|G80yz|Gyu81|G80..|G80z.|G80z0|G80z1|G80zz|G8..,.|Gyu8.|G81..|G820.|G822.|G8220|G823.|G801c|G801e|G801f|G801z|G801.11|G801.11|G801.13|G801.11|G801.13|G824.|G801.11|G801.13|G801.11|G801.13|G82..|G82y.|Gyu82,G82z.|G82z0|G82z1|G82zz")
label variable cvdeath_g  "CV Death (gold) 1=event 0=no event"


// Components of composite plus other CV endpoints of interest - myocardial infarction, stroke, heart failure, cardiac arrhythmia, unstable angina, or urgent revascularization)
// Code binary variable for each source of outcome info (CPRD GOLD "_g", ONS "_o", HES "_h", combo "_all")

//SECONDARY OUTCOMES
// Heart failure 
// readcode source: Tzoulaki, BMJ, 2009 (Supplemental Appendix Table 2); 
gen heartfail_g = 0
replace heartfail_g = 1 if regexm(readcode, "G580.00|G58..00|G58z.00|8HBE.00|662T.00|662W.00|1O1..00|9Or..00|9Or3.00|662p.00|9Or4.00|9Or0.00|8CL3.00|67D4.00|679X.00|G580400|9Or5.00|9Or2.00|9Or1.00")
replace heartfail_g = 0 if constype!=3
label variable heartfail_g "Heart failure (gold) 1=event 0=no event"

// cardiac arrhythmia
// readcode source: Huerta, Epidemiology, 2005 (ArticlePlus) (this paper ID'd from Khan systematic review)
gen arrhythmia_g = 0
replace arrhythmia_g = 1 if regexm(readcode, "4279EA|4272D|G575.00|SP11000|G575000|G575z00|G574011,7L1H.13|K3093|328|328Z.00|3283|3282|2241|G571.00|G57yA00|4279AC|G575100|4279E|G574000|G574.00|G574z00|4279GL|G574100|G571.11|4279HV")
replace arrhythmia_g = 0 if constype!=3
label variable arrhythmia_g "Cardiac arrhythmia (gold) 1=event 0=no event"

// unstable angina (first occurance of hospitalization or death)
// readcode source:
gen angina_g = 0
replace angina_g = 1 if regexm(readcode, "G311.13|G311100")
replace angina_g = 0 if constype!=3
label variable angina_g "Unstable angina (gold) 1=event 0=no event"

// urgent revascularization (first occurance of hospitalization or death)==CV procedures
// readcode source: Lo Re, PDS, 2012 (Supplemental Appendix B)
gen revasc_g = 0
replace revasc_g = 1 if regexm(readcode, "792..00|792..11|7920.00|7920.11|7920000|7920100|7920200|7920300|7920y00|7920z00|7921.00|7921.11|7921000|7921100|7921200|7921300|7921y00|7921z00|7922.00|7922.11|7922000|7922100|7922200|7922300|7922y00|7922z00|7923.00|7923.11|7923000|7923100|7923200|7923300|7923y00|7923z00|7924.00|7924000|7924100|7924200|7924300|7924400|7924500|7924y00|7924z00|7925.00|7925.11|7925000|7925011|7925012|7925100|7925200|7925300|7925311|7925312|7925400|7925y00|7925z00|7926.00|7926000|7926100|7926200|7926300|7926y00|7926z00|7927.00|7927200|7927300|7927y00|7927z00|792b.00|792c.00|792c000|792Cy00|792Cz00|792d.00|792Dy00|792Dz00|792y.00|Sp00300|7927000|7927100|7927400|7927500|7928.00|7928.11|7928000|7928100|7928200|7928300|7928y00|7928z00|7929.00|7929000|7929100|7929111|7929200|7929300|7929400|7929500|7929600|7929y00|7929z00|792a.00|792a000|792b000|792b100|792By00|792Bz00|792z.00|7a1a000|7a54000|7a6g100|Sp01200|7a20.00|7a20000|7a20100|7a20200|7a20300|7a20311|7a20400|7a20500|7a20600|7a20700|7a20y00|7a20z00|7a22.00|7a22000|7a22100|7a22200|7a22300|7a22y00|7a22z00")
replace revasc_g = 0 if constype!=3
label variable revasc_g "Revascularization (gold) 1=event 0=no event"


// #3 Generate dates for events after indexdate and studyentrydate
sort patid eventdate2
local outcome myoinfarct_g stroke_g cvdeath_g heartfail_g arrhythmia_g angina_g revasc_g 

		foreach x of local outcome {
		by patid: egen `x'_date_temp_i = min(eventdate2) if `x'==1 & eventdate2>indexdate 
		format `x'_date_temp_i %td
		by patid: egen `x'_date_i = min(`x'_date_temp_i)
		format `x'_date_i %td
		drop `x'_date_temp_i
		label var `x'_date_i "Earliest date of episode recorded for events after index date"
		}

		foreach y of local outcome {
		by patid: egen `y'_date_temp_s = min(eventdate2) if `y'==1 & eventdate2>studyentrydate_cprd2 
		format `y'_date_temp_s %td
		by patid: egen `y'_date_s = min(`y'_date_temp_s)
		format `y'_date_s %td
		drop `y'_date_temp_s
		label var `x'_date_i "Earliest date of episode recorded for events after study entry date"
		}

collapse (min) cohortentrydate indexdate studyentrydate deathdate2 studyentrydate_cprd2 myoinfarct_g_date_i stroke_g_date_i cvdeath_g_date_i ///
				heartfail_g_date_i arrhythmia_g_date_i angina_g_date_i revasc_g_date_i myoinfarct_g_date_s stroke_g_date_s ///
				cvdeath_g_date_s heartfail_g_date_s arrhythmia_g_date_s angina_g_date_s revasc_g_date_s (max) maincohort metcohort ///
				death_g myoinfarct_g stroke_g cvdeath_g heartfail_g arrhythmia_g angina_g revasc_g, by(patid)
compress
save Outcomes_gold_`file'.dta, replace
}

use Outcomes_gold_Clinical001_2a, clear 
append using Outcomes_gold_Clinical002_2a
append using Outcomes_gold_Clinical003_2a
append using Outcomes_gold_Clinical004_2a
append using Outcomes_gold_Clinical005_2a
append using Outcomes_gold_Clinical006_2a
append using Outcomes_gold_Clinical007_2a
append using Outcomes_gold_Clinical008_2a
append using Outcomes_gold_Clinical009_2a
append using Outcomes_gold_Clinical010_2a
append using Outcomes_gold_Clinical011_2a
append using Outcomes_gold_Clinical012_2a
append using Outcomes_gold_Clinical013_2a

save Outcomes_gold.dta, replace

////////////////////////////////////////////

timer off 1 
timer list 1

exit
log close
