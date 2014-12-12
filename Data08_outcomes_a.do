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
merge m:1 patid using Patient2, keep(match) nogen
compress

// #2 Generate binary variables coding for each OUTCOME clinical event. 
// Code so 0=no event and 1=event. For each event: generate, replace, label
// Based on readcode variable, source of readcodes identified for each outcome/source.

////// #2a All-cause mortality

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
replace stroke_g = 1 if regexm(readcode, "G61..00|G61..11|G61..12|G610.00|G611.00|G612.00|G613.00|G614.00|G615.00|G616.00|G617.00|G618.00|G61X.00|G61X000|G61X100|G61z.00|G63..11|G631.12|G63y000|G64..11|G64..12|G64..13|G640.00|G640000|G64z.00|G64z200|G64z300|G66..00|G66..11|G66..12|G66..13|G667.00|G668.00|G6W..00|G6X..00|Gyu6200|Gyu6300|Gyu6400|Gyu6500|Gyu6600|Gyu6E00|Gyu6F00|Gyu6G00|G31y.00|4369b|1477|4310|4389|4309m|4380|8520m|4300|4309|4350|8520a|4319cr")
replace stroke_g = 0 if constype!=3
label variable stroke_g  "Stroke (gold) 1=event 0=no event"

// CV death
// readcode source: Lo Re, PDS, 2012 (Supplemental Appendix C); 

gen cvdeath_g = 0
replace cvdeath_g = 1 if regexm(readcode, "G2101|G2111|G21z1|G30..|G300.|G301.|G3010|G3011|G301z|G302.|G303.|G304.|G305.|G306.|G307.|G3070|G3071|G308.|G309.|G30A.|G30B.|G30X.|G30X0|G30y.|G30y0|G30y1|G30y2|G30yz|G30z.|G38..|G380.|G381.|G382.|G383.|G384.|G38z.|Gyu34|G35..|G350.|G351.|G353.|Gyu35|G35X.|Gyu36|G36..|G360.|G361.|G362.|G363.|G364.|G365.|G366.|G501.|Gyu31|G310.|G3110|G312.|G31y.|G31y0|G31y1|G31y2|G31y3|G31yz|Gyu32|G32..|G34..|G340.|G3400|G3401|G341.|G3410|G3411|G3412|G3413|G341z|G342.|G343.|G344.|G34y.|G34y0|G34y1|G34yz|G34z.|G34z0|G3y..|G3z..|G5y2.|Gyu33|G40..|G400.|G40z.|G401.|G4010|G4011|G402.|G52..|G52y.|G52y0|G52y1|G52y2|G52y3|G52y4|G52y5|G52y6|G52y7|G52yz|G52z.|Gyu5F|Gyu5G|G55..|G550.|G551.|G552.|G553.|G554.|G5540|G5541|G5542|G5543|G5544|G5545|G554z|G555.|G559.|G55A.|G55y.|G55y0|G55z.|G5yy0|G5yy1|G5yy3|G5yy4|Gyu5M|Gyu5N|Gyu5P|G56..|G560.|G561.|G5610|G5611|G5612|G5613|G5614|G561z|G562.|G5620|G5621|G562z|G563.|Gyu5U|Gyu5V|G564.|G565.|G5650|G5651|G5652|G5653|G5654|G5655|G565z|G566.|G5660|G5661|G5662|G566z|G567.|G5670|G5671|G5672|G5673|G5674|G567z|G56y.|G56y0|G56y1|G56y2|G56y3|G56y4|G56y5|G56yz|G56z.|G56z0|G56zz|Gyu5W|Gyu5X|Gyu5Y|G575.|G5750|G5751|G5752|G5753|G575z|G5751||G57..|G570.|G5700|G5701|G5702|G5703|G570z|G571.|G572.|G5720|G5721|G572z|G57y7|G57y9|G57yA|G573.|G5730|G5731|G5732|G5733|G5734|G5735|G573z|G574.|G5740|G5741|G574z|G576.|G5760|G5761|G5762|G5763|G5764|G5765|G576z|G577.|G57y.|G57y0|G57y1|G57y2|G57y3|G57y4|G57y5|G57y6|G57yz|G57z.|Gyu5a|Gyu5Z|G58..|G580.|G5800|G5801|G5802|G5803|G5804|G581.|G5810|G582.|G583.|G58z.|G60..|G600.|G601.|G602.|G603.|G604.|G605.|G606.|G60X.|G60z.|Gyu6.|Gyu60|Gyu61|Gyu6E|G61..|G610.|G611.|G612.|G613.|G614.|G615.|G616.|G617.|G618.|G61X.|G61X0|G61X1|G61z.|Gyu62|Gyu6F|G62..|G620.|G621.|G622.|G623.|G62z.|G63y0|G63y1|G64..|G6400|G6410|G64z.|G64z0|G64z2|G64z3|G64z4|G6760|G6W..|G6X..|Gyu63|Gyu64|Gyu6G|G65z1|G66..|G667.|G668.|G669.|G63..|G630.|G631.|G632.|G633.|G634.|G63y.|G63z.|Gyu65|G640.|G641.|G64z1|G677.|G6770|G6771|G6772|G6773|G6774|Gyu66|G6730|G6732|G676.|G67A.|G674.|G68..|G680.|G681.|G682.|G683.|G68W.|G68X.|Gyu6B|Gyu6C|G700.|G8010|G8016|G80y0|G80y1|G80y2|G80y3|G80y4|G80y5|G80y6|G80y7|G80y8|G801.|G8011|G8012|G8013|G8014|G8015|G8017|G8018|G8019|G801A|G801B|G801C|G801D|G801E|G801F|Gyu80|SP122|G801z|G802.|G8020|G80y.|G80y9|G80yz|Gyu81|G80..|G80z.|G80z0|G80z1|G80zz|G8...|Gyu8.|G81..|G820.|G822.|G8220|G823.|G801C|G801E|G801F|G801z|G801.11|G801.11|G801.13|G801.11|G801.13|G824.|G801.11|G801.13|G801.11|G801.13|G82..|G82y.|Gyu82|G82z.|G82z0|G82z1|G82zz")
label variable cvdeath_g  "CV Death (gold) 1=event 0=no event"

////// #2c Secondary Outcomes
//         Components of composite plus other CV endpoints of interest - myocardial infarction, stroke, heart failure, cardiac arrhythmia, unstable angina, or urgent revascularization)
// Code binary variable for each source of outcome info (CPRD GOLD "_g", ONS "_o", HES "_h", combo "_all")

// Heart failure 
// readcode source: Tzoulaki, BMJ, 2009 (Supplemental Appendix Table 2); 
gen heartfail_g = 0
replace heartfail_g = 1 if regexm(readcode, "G210100|G211100|G21z011|G21z100|G232.00|G234.00|G58..00|G58..11|G580.00|G580.11|G580.12|G580.13|G580.14|G580000|G580100|G580200|G580300|G581.00|G581.11|G581.12|G581.13|G581000|G582.00|G58z.00|G58z.12|G5yy900|G5yyA00")
replace heartfail_g = 0 if constype!=3
label variable heartfail_g "Heart failure (gold) 1=event 0=no event"

// cardiac arrhythmia
// readcode source: Huerta, Epidemiology, 2005 (ArticlePlus) (this paper ID'd from Khan systematic review)
gen arrhythmia_g = 0
replace arrhythmia_g = 1 if regexm(readcode, "G57..00|G570.00|G570000|G570100|G570200|G570300|G570z00|G571.00|G57..11|G571.11|G572.00|G572000|G572100|G572z00|G573.00|G573000|G573100|G573200|G573z00|G574.00|G574000|G574011|G574100|G574z00|G576.00|G576000|G576011|G576100|G576.11|G576200|G576300|G576400|G576500|G576z00|G577.00|G57y.00|G57y.14|G57y500|G57y600|G57y700|G57y900|G57yA00|G57yz00|G57z.00|G5yy500|Gyu5A00|R050.00|R050.11|2426|2427|243..11|2432|24B8.00|327..00|328..00|328Z.00|3264|3272|3273|3274|3282|7936A00")
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
replace revasc_g = 1 if regexm(readcode, "792..00|792..11|7920|7920.11|7920000|7920100|7920200|7920300|7920y00|7920z00|7921|7921.11|7921000|7921100|7921200|7921300|7921y00|7921z00|7922|7922.11|7922000|7922100|7922200|7922300|7922y00|7922z00|7923|7923.11|7923000|7923100|7923200|7923300|7923y00|7923z00|7924|7924000|7924100|7924200|7924300|7924400|7924500|7924y00|7924z00|7925|7925.11|7925000|7925011|7925012|7925100|7925200|7925300|7925311|7925312|7925400|7925y00|7925z00|7926|7926000|7926100|7926200|7926300|7926y00|7926z00|7927|7927200|7927300|7927y00|7927z00|792B.00|792C.00|792C000|792Cy00|792Cz00|792D.00|792Dy00|792Dz00|792y.00|SP00300|7927000|7927100|7927400|7927500|7928|7928.11|7928000|7928100|7928200|7928300|7928y00|7928z00|7929|7929000|7929100|7929111|7929200|7929300|7929400|7929500|7929600|7929y00|7929z00|792A.00|792A000|792B000|792B100|792By00|792Bz00|792z.00|7A1A000|7A54000|7A6G100|SP01200|7A20.00|7A20000|7A20100|7A20200|7A20300|7A20311|7A20400|7A20500|7A20600|7A20700|7A20y00|7A20z00|7A22.00|7A22000|7A22100|7A22200|7A22300|7A22y00|7A22z00")
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
		}

		foreach y of local outcome {
		by patid: egen `y'_date_temp_s = min(eventdate2) if `y'==1 & eventdate2>studyentrydate_cprd2 
		format `y'_date_temp_s %td
		by patid: egen `y'_date_s = min(`y'_date_temp_s)
		format `y'_date_s %td
		drop `y'_date_temp_s
		}

collapse (min) cohortentrydate indexdate studyentrydate studyentrydate_cprd2 deathdate2  myoinfarct_g_date_i stroke_g_date_i cvdeath_g_date_i ///
				heartfail_g_date_i arrhythmia_g_date_i angina_g_date_i revasc_g_date_i myoinfarct_g_date_s stroke_g_date_s ///
				cvdeath_g_date_s heartfail_g_date_s arrhythmia_g_date_s angina_g_date_s revasc_g_date_s (max) maincohort metcohort ///
				death_g myoinfarct_g stroke_g cvdeath_g heartfail_g arrhythmia_g angina_g revasc_g, by(patid)
compress
save Outcomes_gold_`file'.dta, replace
}

use Outcomes_gold_Clinical001_2, clear 
append using Outcomes_gold_Clinical002_2
append using Outcomes_gold_Clinical003_2
append using Outcomes_gold_Clinical004_2
append using Outcomes_gold_Clinical005_2
append using Outcomes_gold_Clinical006_2
append using Outcomes_gold_Clinical007_2
append using Outcomes_gold_Clinical008_2
append using Outcomes_gold_Clinical009_2
append using Outcomes_gold_Clinical010_2
append using Outcomes_gold_Clinical011_2
append using Outcomes_gold_Clinical012_2
append using Outcomes_gold_Clinical013_2

save Outcomes_gold.dta, replace

////////////////////////////////////////////

timer off 1 
timer list 1

exit
log close
