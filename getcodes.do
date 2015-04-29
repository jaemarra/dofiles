//  program:    Codes_Read_Generate.do
//  task:		Use Stata to generate a list of Read codes for various outcomes and comorbidities.
//				Once dataset of each outcome/comorbidity is made, export to excel
//				where it can be formatted to then put list of codes into other .do files as needed. 
//  project: 	CPRD Sample Dataset Analysis
//  author:     MA \ May2014 | JMG \ Jan 2015

//	status:		IN PROGRESS 
// 				modified from code in Dave & Petersen, PDS, 2009; 18: 704-707

clear all
capture log close
set more off

log using getcodes.log, replace

// Metformin
use product.dta, clear
rename productname productname_1
rename drugsubstance drugsubstance_1
gen metformin = 0
replace metformin = 1 if regexm(prod_bnfcode, "06010202")
replace metformin = 1 if regexm(drugsubstance_1, "(glucophage|avandamet|competact|efficib|eucreas|glubrava|icandra|janumet|jentadueto|komboglyze|ristfor|velmetia|vipdomet|zomarist)")
replace metformin = 1 if regexm(drugsubstance_1, "(metformin)")
replace metformin = 1 if regexm(productname_1, "(glucophage|avandamet|competact|efficib|eucreas|glubrava|icandra|janumet|jentadueto|komboglyze|ristfor|velmetia|vipdomet|zomarist)")
replace metformin = 1 if regexm(productname_1, "(metformin)")
label variable metformin "Metformin"
keep if metformin==1
drop metformin
export excel prodcode gemscriptcode productname using drugcodes.xls, sheet("Metformin") sheetmodify

// SU
use product.dta, clear
rename productname productname_1
rename drugsubstance drugsubstance_1
gen sulfonylurea = 0
replace sulfonylurea = 1 if regexm(prod_bnfcode, "06010201")
replace sulfonylurea = 1 if regexm(drugsubstance_1, "(diamicron|amaryl|minodiab|avaglim|tandemact)")
replace sulfonylurea = 1 if regexm(drugsubstance_1, "(glibenclamide|gliclazide|glimepiride|glipizide|tolbutamide)")
replace sulfonylurea = 1 if regexm(productname_1, "(diamicron|amaryl|minodiab|avaglim|tandemact)")
replace sulfonylurea = 1 if regexm(productname_1, "(glibenclamide|gliclazide|glimepiride|glipizide|tolbutamide)")
label variable sulfonylurea "Sulfonylurea"
keep if sulfonylurea==1
drop sulfonylurea
export excel prodcode gemscriptcode productname using drugcodes.xls, sheet("Sulfonylurea") sheetmodify

// DPP-4I
use product.dta, clear
rename productname productname_1
rename drugsubstance drugsubstance_1
gen dpp = 0
replace dpp = 1 if regexm(prod_bnfcode, "06010203") & regexm(drugsubstance_1, "(alogliptin|linagliptin|saxagliptin|sitagliptin|vildagliptin)")      
replace dpp = 1 if regexm(prod_bnfcode, "06010203") & regexm(drugsubstance_1, "(vipdomet|vipidia|incresync|trajenta|jentadueto|onglyza|komboglyze|januvia|janumet|efficib|ristaben|ristfor|tesavel|velmetia|xelevia|galvus|eucreas|icandra|jalra|xiliarx|zomarist)")
replace dpp = 1 if regexm(prod_bnfcode, "06010203") & regexm(productname_1, "(alogliptin|linagliptin|saxagliptin|sitagliptin|vildagliptin)")      
replace dpp = 1 if regexm(prod_bnfcode, "06010203") & regexm(productname_1, "(vipdomet|vipidia|incresync|trajenta|jentadueto|onglyza|komboglyze|januvia|janumet|efficib|ristaben|ristfor|tesavel|velmetia|xelevia|galvus|eucreas|icandra|jalra|xiliarx|zomarist)")
replace dpp = 1 if regexm(drugsubstance_1, "(alogliptin|linagliptin|saxagliptin|sitagliptin|vildagliptin)")      
replace dpp = 1 if regexm(drugsubstance_1, "(vipdomet|vipidia|incresync|trajenta|jentadueto|onglyza|komboglyze|januvia|janumet|efficib|ristaben|ristfor|tesavel|velmetia|xelevia|galvus|eucreas|icandra|jalra|xiliarx|zomarist)")
replace dpp = 1 if regexm(productname_1, "(alogliptin|linagliptin|saxagliptin|sitagliptin|vildagliptin)")      
replace dpp = 1 if regexm(productname_1, "(vipdomet|vipidia|incresync|trajenta|jentadueto|onglyza|komboglyze|januvia|janumet|efficib|ristaben|ristfor|tesavel|velmetia|xelevia|galvus|eucreas|icandra|jalra|xiliarx|zomarist)")
label variable dpp "DPP-4 inhibitor"
keep if dpp==1
drop dpp
export excel prodcode gemscriptcode productname using drugcodes.xls, sheet("DPP-4i") sheetmodify

// GLP-1RA
use product.dta, clear
rename productname productname_1
rename drugsubstance drugsubstance_1
gen glp = 0
replace glp = 1 if regexm(prod_bnfcode, "06010203") & regexm(drugsubstance_1, "(Exenatide|liraglutide|lixisenatide)")        
replace glp = 1 if regexm(prod_bnfcode, "06010203") & regexm(drugsubstance_1, "(byetta|bydureon|victoza|lyxumia)")
replace glp = 1 if regexm(prod_bnfcode, "06010203") & regexm(productname_1, "(exenatide|liraglutide|lixisenatide)")            
replace glp = 1 if regexm(prod_bnfcode, "06010203") & regexm(productname_1, "(byetta|bydureon|victoza|lyxumia)")
replace glp = 1 if regexm(drugsubstance_1, "(Exenatide|liraglutide|lixisenatide)")            
replace glp = 1 if regexm(drugsubstance_1, "(byetta|bydureon|victoza|lyxumia)")
replace glp = 1 if regexm(productname_1, "(Exenatide|liraglutide|lixisenatide)")           
replace glp = 1 if regexm(productname_1, "(byetta|bydureon|victoza|lyxumia)")
label variable glp "GLP-1 RA"
keep if glp==1
drop glp
export excel prodcode gemscriptcode productname using drugcodes.xls, sheet("GLP-1 RA") sheetmodify

// Insulins- short
use product.dta, clear
rename productname productname_1
rename drugsubstance drugsubstance_1
gen insulins_short = 0
replace insulins_short = 1 if regexm(prod_bnfcode, "06010101") & ! regexm(prod_bnfcode, "(06010103|91020000)") 
replace insulins_short = 1 if regexm(drugsubstance_1, "(hypurin bovine neutral|hypurin porcine neutral|actrapid|humulin s|insuman rapid|novorapid|novomix|apidra|humalog|liprolog|actraphane|exubera|mixtard|monotard|protaphane|ultratard|velosulin|ryzodeg)")
replace insulins_short = 1 if regexm(drugsubstance_1, "(insulin|insulin aspart|insulin glulisine|insulin lispro)") & ! regexm(prod_bnfcode, "(06010103|91020000)")
replace insulins_short = 1 if regexm(productname_1, "(hypurin bovine neutral|hypurin porcine neutral|actrapid|humulin s|insuman rapid|novorapid|novomix|apidra|humalog|liprolog|actraphane|exubera|mixtard|monotard|protaphane|ultratard|velosulin|ryzodeg)")
replace insulins_short = 1 if regexm(productname_1, "(insulin|insulin aspart|insulin glulisine|insulin lispro)") & ! regexm(prod_bnfcode, "(06010103|91020000)")
label variable insulins_short "Short-acting insulins"
keep if insulins_short==1
drop insulins_short
export excel prodcode gemscriptcode productname using drugcodes.xls, sheet("Ins-short") sheetmodify

// Insulins Intermediate-Long
use product.dta, clear
rename productname productname_1
rename drugsubstance drugsubstance_1
gen insulins_intlong = 0
replace insulins_intlong = 1 if regexm(prod_bnfcode, "06010102") & ! regexm(prod_bnfcode, "(06010103|91020000)")
replace insulins_intlong = 1 if regexm(drugsubstance_1, "(tresiba|levemir|lantus|hypurin bovine lente|hypurin bovine isophane|hypurin porcine isophane|insulatard|humulin i|insuman basal|hypurin bovine protamine zinc|novomix 30|humalog mix25|humalog mix50|hypurin porcine 30/70 mix|humulin m3|insuman comb|optisulin|ryzodeg)")
replace insulins_intlong = 1 if regexm(drugsubstance_1, "(insulin degludec|insulin detemir|insulin glargine|insulin zinc suspension|isophane insulin|protamine zinc insulin|biphasic insulin aspart|biphasic insulin lispro| biphasic isophane insulin)") & ! regexm(prod_bnfcode, "(06010103|91020000)")
replace insulins_intlong = 1 if regexm(productname_1, "(tresiba|levemir|lantus|hypurin bovine lente|hypurin bovine isophane|hypurin porcine isophane|insulatard|humulin i|insuman basal|hypurin bovine protamine zinc|novomix 30|humalog mix25|humalog mix50|hypurin porcine 30/70 mix|humulin m3|insuman comb|optisulin|ryzodeg)")
replace insulins_intlong = 1 if regexm(productname_1, "(insulin degludec|insulin detemir|insulin glargine|insulin zinc suspension|isophane insulin|protamine zinc insulin|biphasic insulin aspart|biphasic insulin lispro| biphasic isophane insulin)") & ! regexm(prod_bnfcode, "(06010103|91020000)")
label variable insulins_intlong "Intermediate- and long-acting insulins"
keep if insulins_intlong==1
drop insulins_intlong
export excel prodcode gemscriptcode productname using drugcodes.xls, sheet("Ins-int_long") sheetmodify

// TZD
use product.dta, clear
rename productname productname_1
rename drugsubstance drugsubstance_1
gen tzd = 0
replace tzd = 1 if regexm(prod_bnfcode, "06010203") & regexm(drugsubstance_1, "(rosiglitazone|troglitazone|pioglitazone)")
replace tzd = 1 if regexm(prod_bnfcode, "06010203") & regexm(drugsubstance_1, "(avandia|avandamet|avaglim|nyracta|venvia|romozin|actos|competact|glidipion|glubrava|glustin|paglitaz|sepioglin|tandemact|incresync)")
replace tzd = 1 if regexm(prod_bnfcode, "06010203") & regexm(productname_1, "(rosiglitazone|troglitazone|pioglitazone)")
replace tzd = 1 if regexm(prod_bnfcode, "06010203") & regexm(productname_1, "(avandia|avandamet|avaglim|nyracta|venvia|romozin|actos|competact|glidipion|glubrava|glustin|paglitaz|sepioglin|tandemact|incresync)")
replace tzd = 1 if regexm(drugsubstance_1, "(rosiglitazone|troglitazone|pioglitazone)")
replace tzd = 1 if regexm(drugsubstance_1, "(avandia|avandamet|avaglim|nyracta|venvia|romozin|actos|competact|glidipion|glubrava|glustin|paglitaz|sepioglin|tandemact|incresync)")
replace tzd = 1 if regexm(productname_1, "(rosiglitazone|troglitazone|pioglitazone)")
replace tzd = 1 if regexm(productname_1, "(avandia|avandamet|avaglim|nyracta|venvia|romozin|actos|competact|glidipion|glubrava|glustin|paglitaz|sepioglin|tandemact|incresync)")
label variable tzd "TZD"
keep if tzd==1
drop tzd
export excel prodcode gemscriptcode productname using drugcodes.xls, sheet("TZD") sheetmodify

// Other antidiabetic medications
use product.dta, clear
rename productname productname_1
rename drugsubstance drugsubstance_1
gen otherantidiab = 0 
replace otherantidiab = 1 if regexm(prod_bnfcode, "06010203") & regexm(drugsubstance_1, "(acarbose|dapagliflozin|nateglinide|repaglinide|canagliflozin)")               
replace otherantidiab = 1 if regexm(prod_bnfcode, "06010203") & regexm(drugsubstance_1, "(glucobay|forxiga|starlix|tranzec|prandin|enyglid|novonorm|invokana)")
replace otherantidiab = 1 if regexm(prod_bnfcode, "06010203") & regexm(productname_1, "(acarbose|dapagliflozin|nateglinide|repaglinide|canagliflozin)")                   
replace otherantidiab = 1 if regexm(prod_bnfcode, "06010203") & regexm(productname_1, "(glucobay|forxiga|starlix|tranzec|prandin|enyglid|novonorm|invokana)")
replace otherantidiab = 1 if regexm(drugsubstance_1, "(acarbose|dapagliflozin|nateglinide|repaglinide|canagliflozin)")                   
replace otherantidiab = 1 if regexm(drugsubstance_1, "(glucobay|forxiga|starlix|tranzec|prandin|enyglid|novonorm|invokana)")
replace otherantidiab = 1 if regexm(productname_1, "(acarbose|dapagliflozin|nateglinide|repaglinide|canagliflozin)")                
replace otherantidiab = 1 if regexm(productname_1, "(glucobay|forxiga|starlix|tranzec|prandin|enyglid|novonorm|invokana)")
label variable otherantidiab "Other antidiabetics"
keep if otherantidiab==1
drop otherantidiab
export excel prodcode gemscriptcode productname using drugcodes.xls, sheet("Other") sheetmodify

// #4. In Excel, for each event type, convert the list of codes (each in an individual cell) into one cell with | between codes, 
// 			so they can be dropped into OutcomeEvents.do and Covariates.do.

// Directions:				
//To make string of codes from different cells of codes (using example range of A1:A10Éfill in proper range):					
					
//in cell you want string in, type :    =transpose(A1:A10&"|")					
//			DO NOT HIT ENTER		
//			press F9 (fn+fastforward on my laptop)..this will turn display from range into the actual values in that range		
//			type: concatenate      after equal sign, before bracket at start of string		
//			change curly brackets {} at both ends to regular ones ()		
//			now press ENTER		
//			*this will give a final | after the last code, delete this | in Stata once the string is pasted in there.		

////////////////////////////////////////////

exit
log close
