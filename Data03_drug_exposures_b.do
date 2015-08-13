//  program:    Data03_drug_exposures_b.do
//  task:		Generate variables indicating subclass antidiabetic drug exposures in CPRD Dataset using individual Therapy files
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

//exenatide BID
local exenBIDcodes="(93411020|93407020|93413020|93405020)"
gen exenatideBID = 0
replace exenatideBID = 1 if regexm(gemscriptcode, "`exenBIDcodes'") 

//exenatide qweekly
local exenQWKcodes="(00071021|00074021)"
gen exenatideQWK = 0
replace exenatideQWK = 1 if regexm(gemscriptcode, "`exenQWKcodes'") 

//liraglutide
local liracodes="(97165020|97163020)"
gen liraglutide = 0 
replace liraglutide = 1 if regexm(gemscriptcode, "`liracodes'")  

//lixisenatide
local lixicodes="(47959020|47955020|47957020|47956020|47960020|47958020)"
gen lixisenatide = 0 
replace lixisenatide = 1 if regexm(gemscriptcode, "`lixicodes'")

//alogliptin not available in the UK: no codes found
//local alocodes="()"
gen alogliptin = 0 
//replace alogliptin = 1 if regexm(gemscriptcode, "`alocodes'")     
//label variable alogliptin "Alogliptin exposure: 0=no exp, 1=exp"

//linagliptin
local linacodes="(00361021|00363021|45093020|45092020|45094020|45095020)"
gen linagliptin = 0 
replace linagliptin = 1 if regexm(gemscriptcode, "`linacodes'")  

//sitagliptin
local sitacodes="(93519020|93521020|95970020|98591020|40627020|40625020|40628020|40626020)"
gen sitagliptin = 0 
replace sitagliptin = 1 if regexm(gemscriptcode, "`sitacodes'")

//saxagliptin
local saxacodes="(97586020|97590020|99663020|99665020|46992020|46994020|46993020)"
gen saxagliptin = 0 
replace saxagliptin = 1 if regexm(gemscriptcode, "`saxacodes'")

//vildagliptin
local vildacodes="(94757020|94104020|94759020|94763020|94109020|94761020)"
gen vildagliptin = 0 
replace vildagliptin = 1 if regexm(gemscriptcode, "`vildacodes'")

//Set local macros for the unique drug exposures
local rxlist = "exenatide exenatideBID exenatideQWK liraglutide lixisenatide alogliptin linagliptin sitagliptin saxagliptin vildagliptin"

//Generate the variable for totals
egen unqrx= anycount(`rxlist'), values(1)

save drugexpb`i', replace
timer off 2
timer list 2
}


use drugexpb0, clear 
forval i=1/49 {		
	append using drugexpb`i'
	}
save Drug_Exposures_B.dta, replace
drop gemscriptcode
collapse (max) exenatide liraglutide lixisenatide alogliptin linagliptin sitagliptin saxagliptin vildagliptin unqrx, by(patid)
label variable exenatide "Exenatide exposure: 0=no exp, 1=exp"    
label variable liraglutide "Liraglutide exposure: 0=no exp, 1=exp"      
label variable lixisenatide "Lixisenatide exposure: 0=no exp, 1=exp"
label variable linagliptin "Linagliptin exposure: 0=no exp, 1=exp"      
label variable sitagliptin "Sitagliptin exposure: 0=no exp, 1=exp"
label variable saxagliptin "Saxagliptin exposure: 0=no exp, 1=exp"     
label variable vildagliptin "Vildagliptin exposure: 0=no exp, 1=exp"
label var unqrx "Total number of unique antidiabetic subclasses exposed to"
rename unqrx unqrx_b
forval i=0/49 {		
	erase drugexpb`i'.dta
	}
save Drug_Exposures_B.dta, replace

////////////////////////////////////////////

timer off 1
timer list 1

exit
