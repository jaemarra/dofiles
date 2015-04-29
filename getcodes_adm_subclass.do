//  program:    getcodes_sub_admdrugs.do
//  task:		Use Stata to generate a list of gemscript codes for subclasses of antidiabetics
//				and export to excel where they can be formatted and listed for future use
//				note: modified from code in Dave & Petersen, PDS, 2009; 18: 704-707
//				 
//  project: 	CPRD Sample Dataset Analysis
//  author:     JM \ Jan 2015

//	status:		COMPLETED 

clear all
capture log close
set more off

log using getcodes_cov.txt, replace

//prepare product.dta
use product
replace productname=lower(productname)
replace drugsubstance= lower(drugsubstance)
save product, replace
clear

//EXTRACT AND EXPORT CODES FOR SUBCLASSES OF INSULIN AND INCRETINS
//INSULIN
//Insulin (sub-category)
use product.dta, clear
rename productname productname_1
rename drugsubstance drugsubstance_1
gen ins_sub = 0
replace ins_sub = 1 if regexm(prod_bnfcode, "06010101") & ! regexm(prod_bnfcode, "(06010103|91020000)")
replace ins_sub = 1 if regexm(drugsubstance_1, "(hypurin bovine neutral|hypurin porcine neutral|actrapid|humulin s|insuman rapid|actraphane|exubera|mixtard|monotard|protaphane|ultratard|velosulin)")
replace ins_sub = 1 if regexm(drugsubstance_1, "(insulin)") & ! regexm(prod_bnfcode, "(06010103|91020000)")
replace ins_sub = 1 if regexm(productname_1, "(hypurin bovine neutral|hypurin porcine neutral|actrapid|humulin s|insuman rapid|actraphane|exubera|mixtard|monotard|protaphane|ultratard|velosulin)")
replace ins_sub = 1 if regexm(productname_1, "(insulin)") & ! regexm(prod_bnfcode, "(06010103|91020000)")
label variable ins_sub "Insulin (sub-category) exposure: 0=no exp, 1=exp"
keep if ins_sub==1
drop ins_sub
export excel prodcode gemscriptcode productname using sub_admdrugcodes.xls, sheet("ins_sub") sheetmodify firstrow(variables)

//Insulin aspart
use product.dta, clear
rename productname productname_1
rename drugsubstance drugsubstance_1
gen aspart = 0
replace aspart = 1 if regexm(prod_bnfcode, "06010101") & ! regexm(prod_bnfcode, "(06010103|91020000)")
replace aspart = 1 if regexm(drugsubstance_1, "(novomix|novorapid|ryzodeg)")
replace aspart = 1 if regexm(drugsubstance_1, "(insulin aspart)") & ! regexm(prod_bnfcode, "(06010103|91020000)")
replace aspart = 1 if regexm(productname_1, "(novomix|novorapid|ryzodeg)")
replace aspart = 1 if regexm(productname_1, "(insulin aspart)") & ! regexm(prod_bnfcode, "(06010103|91020000)")
label variable aspart "Insulin aspart exposure: 0=no exp, 1=exp"
keep if aspart==1
drop aspart
export excel prodcode gemscriptcode productname using sub_admdrugcodes.xls, sheet("aspart") sheetmodify firstrow(variables)

//Insulin glulisine
use product.dta, clear
rename productname productname_1
rename drugsubstance drugsubstance_1
gen glulisine = 0
replace glulisine = 1 if regexm(prod_bnfcode, "06010101") & ! regexm(prod_bnfcode, "(06010103|91020000)")
replace glulisine = 1 if regexm(drugsubstance_1, "apidra")
replace glulisine = 1 if regexm(drugsubstance_1, "(insulin glulisine)") & ! regexm(prod_bnfcode, "(06010103|91020000)")
replace glulisine = 1 if regexm(productname_1, "apidra")
replace glulisine = 1 if regexm(productname_1, "(insulin glulisine)") & ! regexm(prod_bnfcode, "(06010103|91020000)")
label variable glulisine "Insulin glulisine exposure: 0=no exp, 1=exp"
keep if glulisine==1
drop glulisine
export excel prodcode gemscriptcode productname using sub_admdrugcodes.xls, sheet("glulisine") sheetmodify firstrow(variables)

//Insulin lispro
use product.dta, clear
rename productname productname_1
rename drugsubstance drugsubstance_1
gen lispro = 0
replace lispro = 1 if regexm(prod_bnfcode, "06010101") & ! regexm(prod_bnfcode, "(06010103|91020000)")
replace lispro = 1 if regexm(drugsubstance_1, "(humalog|liprolog)")
replace lispro = 1 if regexm(drugsubstance_1, "(insulin lispro)") & ! regexm(prod_bnfcode, "(06010103|91020000)")
replace lispro = 1 if regexm(productname_1, "(humalog|liprolog)")
replace lispro = 1 if regexm(productname_1, "(insulin lispro)") & ! regexm(prod_bnfcode, "(06010103|91020000)")
label variable lispro "Insulin lispro exposure: 0=no exp, 1=exp"
keep if lispro==1
drop lispro
export excel prodcode gemscriptcode productname using sub_admdrugcodes.xls, sheet("lispro") sheetmodify firstrow(variables)

//Insulin degludec
use product.dta, clear
rename productname productname_1
rename drugsubstance drugsubstance_1
gen degludec = 0
replace degludec = 1 if regexm(prod_bnfcode, "06010102") & ! regexm(prod_bnfcode, "(06010103|91020000)")
replace degludec = 1 if regexm(drugsubstance_1, "(tresiba|ryzodeg)")
replace degludec = 1 if regexm(drugsubstance_1, "(insulin degludec)") & ! regexm(prod_bnfcode, "(06010103|91020000)")
replace degludec = 1 if regexm(productname_1, "(tresiba|ryzodeg)")
replace degludec = 1 if regexm(productname_1, "(insulin degludec)") & ! regexm(prod_bnfcode, "(06010103|91020000)")
label variable degludec "Insulin degludec exposure: 0=no exp, 1=exp"
keep if degludec==1
drop degludec
export excel prodcode gemscriptcode productname using sub_admdrugcodes.xls, sheet("degludec") sheetmodify firstrow(variables)

//Insulin detemir
use product.dta, clear
rename productname productname_1
rename drugsubstance drugsubstance_1
gen detemir = 0
replace detemir = 1 if regexm(prod_bnfcode, "06010102") & ! regexm(prod_bnfcode, "(06010103|91020000)")
replace detemir = 1 if regexm(drugsubstance_1, "levimir")
replace detemir = 1 if regexm(drugsubstance_1, "(insulin detemir)") & ! regexm(prod_bnfcode, "(06010103|91020000)")
replace detemir = 1 if regexm(productname_1, "levimir")
replace detemir = 1 if regexm(productname_1, "(insulin detemir)") & ! regexm(prod_bnfcode, "(06010103|91020000)")
label variable detemir "Insulin detemir exposure: 0=no exp, 1=exp"
keep if detemir==1
drop detemir
export excel prodcode gemscriptcode productname using sub_admdrugcodes.xls, sheet("detemir") sheetmodify firstrow(variables)

//Insulin glargine
use product.dta, clear
rename productname productname_1
rename drugsubstance drugsubstance_1
gen glargine = 0
replace glargine = 1 if regexm(prod_bnfcode, "06010102") & ! regexm(prod_bnfcode, "(06010103|91020000)")
replace glargine = 1 if regexm(drugsubstance_1, "(lantus|optisulin)")
replace glargine = 1 if regexm(drugsubstance_1, "(insulin glargine)") & ! regexm(prod_bnfcode, "(06010103|91020000)")
replace glargine = 1 if regexm(productname_1, "(lantus|optisulin)")
replace glargine = 1 if regexm(productname_1, "(insulin glargine)") & ! regexm(prod_bnfcode, "(06010103|91020000)")
label variable glargine "Insulin glargine exposure: 0=no exp, 1=exp"
keep if glargine==1
drop glargine
export excel prodcode gemscriptcode productname using sub_admdrugcodes.xls, sheet("glargine") sheetmodify firstrow(variables)

//Insulin zinc suspension
use product.dta, clear
rename productname productname_1
rename drugsubstance drugsubstance_1
gen ins_zinc = 0
replace ins_zinc = 1 if regexm(prod_bnfcode, "06010102") & ! regexm(prod_bnfcode, "(06010103|91020000)")
replace ins_zinc = 1 if regexm(drugsubstance_1, "(hypurin bovine lente)")
replace ins_zinc = 1 if regexm(drugsubstance_1, "(insulin zinc suspension)") & ! regexm(prod_bnfcode, "(06010103|91020000)")
replace ins_zinc = 1 if regexm(productname_1, "(hypurin bovine lente)")
replace ins_zinc = 1 if regexm(productname_1, "(insulin zinc suspension)") & ! regexm(prod_bnfcode, "(06010103|91020000)")
label variable ins_zinc "Insulin zinc suspension exposure: 0=no exp, 1=exp"
keep if ins_zinc==1
drop ins_zinc
export excel prodcode gemscriptcode productname using sub_admdrugcodes.xls, sheet("ins_zinc") sheetmodify firstrow(variables)

//Isophane insulin
use product.dta, clear
rename productname productname_1
rename drugsubstance drugsubstance_1
gen isophane_ins = 0
replace isophane_ins = 1 if regexm(prod_bnfcode, "06010102") & ! regexm(prod_bnfcode, "(06010103|91020000)")
replace isophane_ins = 1 if regexm(drugsubstance_1, "(hypurin bovine isophane|hypurin porcine isophane|insulatard|humulin i|insuman basal)")
replace isophane_ins = 1 if regexm(drugsubstance_1, "(isophane insulin)") & ! regexm(prod_bnfcode, "(06010103|91020000)")
replace isophane_ins = 1 if regexm(productname_1, "(hypurin bovine isophane|hypurin porcine isophane|insulatard|humulin i|insuman basal)")
replace isophane_ins = 1 if regexm(productname_1, "(isophane insulin)") & ! regexm(prod_bnfcode, "(06010103|91020000)")
label variable isophane_ins "Isophane insulin exposure: 0=no exp, 1=exp"
keep if isophane_ins==1
drop isophane_ins
export excel prodcode gemscriptcode productname using sub_admdrugcodes.xls, sheet("isophane_ins") sheetmodify firstrow(variables)

//Protamine zinc insulin
use product.dta, clear
rename productname productname_1
rename drugsubstance drugsubstance_1
gen protamine_zinc_ins = 0
replace protamine_zinc_ins = 1 if regexm(prod_bnfcode, "06010102") & ! regexm(prod_bnfcode, "(06010103|91020000)")
replace protamine_zinc_ins = 1 if regexm(drugsubstance_1, "(hypurin bovine protamine zinc)")
replace protamine_zinc_ins = 1 if regexm(drugsubstance_1, "(protamine zinc insulin)") & ! regexm(prod_bnfcode, "(06010103|91020000)")
replace protamine_zinc_ins = 1 if regexm(productname_1, "(hypurin bovine protamine zinc)")
replace protamine_zinc_ins = 1 if regexm(productname_1, "(protamine zinc insulin)") & ! regexm(prod_bnfcode, "(06010103|91020000)")
label variable protamine_zinc_ins "Protamine zinc insulin exposure: 0=no exp, 1=exp"
keep if protamine_zinc_ins==1
drop protamine_zinc_ins
export excel prodcode gemscriptcode productname using sub_admdrugcodes.xls, sheet("protamine_zinc_ins") sheetmodify firstrow(variables)

//Biphasic insulin aspart
use product.dta, clear
rename productname productname_1
rename drugsubstance drugsubstance_1
gen aspart_biphasic = 0
replace aspart_biphasic = 1 if regexm(prod_bnfcode, "06010102") & ! regexm(prod_bnfcode, "(06010103|91020000)")
replace aspart_biphasic = 1 if regexm(drugsubstance_1, "(novomix 30)")
replace aspart_biphasic = 1 if regexm(drugsubstance_1, "(biphasic insulin aspart)") & ! regexm(prod_bnfcode, "(06010103|91020000)")
replace aspart_biphasic = 1 if regexm(productname_1, "(novomix 30)")
replace aspart_biphasic = 1 if regexm(productname_1, "(biphasic insulin aspart)") & ! regexm(prod_bnfcode, "(06010103|91020000)")
label variable aspart_biphasic "Biphasic insulin aspart exposure: 0=no exp, 1=exp"
keep if aspart_biphasic==1
drop aspart_biphasic
export excel prodcode gemscriptcode productname using sub_admdrugcodes.xls, sheet("aspart_biphasic") sheetmodify firstrow(variables)

//Biphasic insulin lispro
use product.dta, clear
rename productname productname_1
rename drugsubstance drugsubstance_1
gen lispro_biphasic = 0
replace lispro_biphasic = 1 if regexm(prod_bnfcode, "06010102") & ! regexm(prod_bnfcode, "(06010103|91020000)")
replace lispro_biphasic = 1 if regexm(drugsubstance_1, "(humalog mix25|humalog mix50)")
replace lispro_biphasic = 1 if regexm(drugsubstance_1, "(biphasic insulin lispro)") & ! regexm(prod_bnfcode, "(06010103|91020000)")
replace lispro_biphasic = 1 if regexm(productname_1, "(humalog mix25|humalog mix50)")
replace lispro_biphasic = 1 if regexm(productname_1, "(biphasic insulin lispro)") & ! regexm(prod_bnfcode, "(06010103|91020000)")
label variable lispro_biphasic "Biphasic insulin lispro exposure: 0=no exp, 1=exp"
keep if lispro_biphasic==1
drop lispro_biphasic
export excel prodcode gemscriptcode productname using sub_admdrugcodes.xls, sheet("lispro_biphasic") sheetmodify firstrow(variables)

//Biphasic isophane insulin 
use product.dta, clear
rename productname productname_1
rename drugsubstance drugsubstance_1
gen isophane_biphasic = 0
replace isophane_biphasic = 1 if regexm(prod_bnfcode, "06010102") & ! regexm(prod_bnfcode, "(06010103|91020000)")
replace isophane_biphasic = 1 if regexm(drugsubstance_1, "(hypurin porcine 30/70 mix|humulin m3|insuman comb)")
replace isophane_biphasic = 1 if regexm(drugsubstance_1, "(biphasic isophane insulin)") & ! regexm(prod_bnfcode, "(06010103|91020000)")
replace isophane_biphasic = 1 if regexm(productname_1, "(hypurin porcine 30/70 mix|humulin m3|insuman comb)")
replace isophane_biphasic = 1 if regexm(productname_1, "(biphasic isophane insulin)") & ! regexm(prod_bnfcode, "(06010103|91020000)")
label variable isophane_biphasic "Biphasic isophane insulin exposure: 0=no exp, 1=exp"
keep if isophane_biphasic==1
drop isophane_biphasic
export excel prodcode gemscriptcode productname using sub_admdrugcodes.xls, sheet("isophane_biphasic") sheetmodify firstrow(variables)

//INCRETINS
//Exenatide
use product.dta, clear
rename productname productname_1
rename drugsubstance drugsubstance_1
gen exenatide = 0 
replace exenatide = 1 if regexm(prod_bnfcode, "06010203") & regexm(drugsubstance_1, "exenatide")        
replace exenatide = 1 if regexm(prod_bnfcode, "06010203") & regexm(drugsubstance_1, "(byetta|bydureon)")
replace exenatide = 1 if regexm(prod_bnfcode, "06010203") & regexm(productname_1, "exenatide")            
replace exenatide = 1 if regexm(prod_bnfcode, "06010203") & regexm(productname_1, "(byetta|bydureon)")
replace exenatide = 1 if regexm(drugsubstance_1, "exenatide")            
replace exenatide = 1 if regexm(drugsubstance_1, "(byetta|bydureon)")
replace exenatide = 1 if regexm(productname_1, "exenatide")           
replace exenatide = 1 if regexm(productname_1, "(byetta|bydureon)")
label variable exenatide "Exenatide exposure: 0=no exp, 1=exp"
keep if exenatide==1
drop exenatide
export excel prodcode gemscriptcode productname using sub_admdrugcodes.xls, sheet("exenatide") sheetmodify firstrow(variables)

//Liraglutide
use product.dta, clear
rename productname productname_1
rename drugsubstance drugsubstance_1
gen liraglutide = 0 
replace liraglutide = 1 if regexm(prod_bnfcode, "06010203") & regexm(drugsubstance_1, "liraglutide")       
replace liraglutide = 1 if regexm(prod_bnfcode, "06010203") & regexm(drugsubstance_1, "victoza")
replace liraglutide = 1 if regexm(prod_bnfcode, "06010203") & regexm(productname_1, "liraglutide")            
replace liraglutide = 1 if regexm(prod_bnfcode, "06010203") & regexm(productname_1, "victoza")
replace liraglutide = 1 if regexm(drugsubstance_1, "liraglutide")            
replace liraglutide = 1 if regexm(drugsubstance_1, "victoza")
replace liraglutide = 1 if regexm(productname_1, "liraglutide")           
replace liraglutide = 1 if regexm(productname_1, "victoza")
label variable liraglutide "Liraglutide exposure: 0=no exp, 1=exp"
keep if liraglutide==1
drop liraglutide
export excel prodcode gemscriptcode productname using sub_admdrugcodes.xls, sheet("liraglutide") sheetmodify firstrow(variables)

//Lixisenatide
use product.dta, clear
rename productname productname_1
rename drugsubstance drugsubstance_1
gen lixisenatide = 0 
replace lixisenatide = 1 if regexm(prod_bnfcode, "06010203") & regexm(drugsubstance_1, "lixisenatide")        
replace lixisenatide = 1 if regexm(prod_bnfcode, "06010203") & regexm(drugsubstance_1, "lyxumia")
replace lixisenatide = 1 if regexm(prod_bnfcode, "06010203") & regexm(productname_1, "lixisenatide")            
replace lixisenatide = 1 if regexm(prod_bnfcode, "06010203") & regexm(productname_1, "lyxumia")
replace lixisenatide = 1 if regexm(drugsubstance_1, "lixisenatide")            
replace lixisenatide = 1 if regexm(drugsubstance_1, "lyxumia")
replace lixisenatide = 1 if regexm(productname_1, "lixisenatide")           
replace lixisenatide = 1 if regexm(productname_1, "lyxumia")
label variable lixisenatide "Lixisenatide exposure: 0=no exp, 1=exp"
keep if lixisenatide==1
drop lixisenatide
export excel prodcode gemscriptcode productname using sub_admdrugcodes.xls, sheet("lixisenatide") sheetmodify firstrow(variables)

//Alogliptin
use product.dta, clear
rename productname productname_1
rename drugsubstance drugsubstance_1
gen alogliptin = 0 
replace alogliptin = 1 if regexm(prod_bnfcode, "06010203") & regexm(drugsubstance_1, "alogliptin")      
replace alogliptin = 1 if regexm(prod_bnfcode, "06010203") & regexm(drugsubstance_1, "(vipdomet|vipidia|incresync)")
replace alogliptin = 1 if regexm(prod_bnfcode, "06010203") & regexm(productname_1, "alogliptin")     
replace alogliptin = 1 if regexm(prod_bnfcode, "06010203") & regexm(productname_1, "(vipdomet|vipidia|incresync)")
replace alogliptin = 1 if regexm(drugsubstance_1, "alogliptin")       
replace alogliptin = 1 if regexm(drugsubstance_1, "(vipdomet|vipidia|incresync)")
replace alogliptin = 1 if regexm(productname_1, "alogliptin")     
replace alogliptin = 1 if regexm(productname_1, "(vipdomet|vipidia|incresync)")
label variable alogliptin "Alogliptin exposure: 0=no exp, 1=exp"
keep if alogliptin==1
drop alogliptin
capture export excel prodcode gemscriptcode productname using sub_admdrugcodes.xls, sheet("alogliptin") sheetmodify firstrow(variables)

//Linagliptin
use product.dta, clear
rename productname productname_1
rename drugsubstance drugsubstance_1
gen linagliptin = 0 
replace linagliptin = 1 if regexm(prod_bnfcode, "06010203") & regexm(drugsubstance_1, "linagliptin")      
replace linagliptin = 1 if regexm(prod_bnfcode, "06010203") & regexm(drugsubstance_1, "(trajenta|jentadueto)")
replace linagliptin = 1 if regexm(prod_bnfcode, "06010203") & regexm(productname_1, "linagliptin")     
replace linagliptin = 1 if regexm(prod_bnfcode, "06010203") & regexm(productname_1, "(trajenta|jentadueto)")
replace linagliptin = 1 if regexm(drugsubstance_1, "linagliptin")       
replace linagliptin = 1 if regexm(drugsubstance_1, "(trajenta|jentadueto)")
replace linagliptin = 1 if regexm(productname_1, "linagliptin")     
replace linagliptin = 1 if regexm(productname_1, "(trajenta|jentadueto)")
label variable linagliptin "Linagliptin exposure: 0=no exp, 1=exp"
keep if linagliptin==1
drop linagliptin
export excel prodcode gemscriptcode productname using sub_admdrugcodes.xls, sheet("linagliptin") sheetmodify firstrow(variables)

//Sitagliptin
use product.dta, clear
rename productname productname_1
rename drugsubstance drugsubstance_1
gen sitagliptin = 0 
replace sitagliptin = 1 if regexm(prod_bnfcode, "06010203") & regexm(drugsubstance_1, "sitagliptin")      
replace sitagliptin = 1 if regexm(prod_bnfcode, "06010203") & regexm(drugsubstance_1, "(januvia|janumet|efficib|ristaben|ristfor|tesavel|velmetia|xelevia)")
replace sitagliptin = 1 if regexm(prod_bnfcode, "06010203") & regexm(productname_1, "sitagliptin")     
replace sitagliptin = 1 if regexm(prod_bnfcode, "06010203") & regexm(productname_1, "(januvia|janumet|efficib|ristaben|ristfor|tesavel|velmetia|xelevia)")
replace sitagliptin = 1 if regexm(drugsubstance_1, "sitagliptin")       
replace sitagliptin = 1 if regexm(drugsubstance_1, "(januvia|janumet|efficib|ristaben|ristfor|tesavel|velmetia|xelevia)")
replace sitagliptin = 1 if regexm(productname_1, "sitagliptin")     
replace sitagliptin = 1 if regexm(productname_1, "(januvia|janumet|efficib|ristaben|ristfor|tesavel|velmetia|xelevia)")
label variable sitagliptin "Sitagliptin exposure: 0=no exp, 1=exp"
keep if sitagliptin==1
drop sitagliptin
export excel prodcode gemscriptcode productname using sub_admdrugcodes.xls, sheet("sitagliptin") sheetmodify firstrow(variables)

//Saxagliptin
use product.dta, clear
rename productname productname_1
rename drugsubstance drugsubstance_1
gen saxagliptin = 0 
replace saxagliptin = 1 if regexm(prod_bnfcode, "06010203") & regexm(drugsubstance_1, "saxagliptin")      
replace saxagliptin = 1 if regexm(prod_bnfcode, "06010203") & regexm(drugsubstance_1, "(onglyza|komboglyze)")
replace saxagliptin = 1 if regexm(prod_bnfcode, "06010203") & regexm(productname_1, "saxagliptin")     
replace saxagliptin = 1 if regexm(prod_bnfcode, "06010203") & regexm(productname_1, "(onglyza|komboglyze)")
replace saxagliptin = 1 if regexm(drugsubstance_1, "saxagliptin")       
replace saxagliptin = 1 if regexm(drugsubstance_1, "(onglyza|komboglyze)")
replace saxagliptin = 1 if regexm(productname_1, "saxagliptin")     
replace saxagliptin = 1 if regexm(productname_1, "(onglyza|komboglyze)")
label variable saxagliptin "Saxagliptin exposure: 0=no exp, 1=exp"
keep if saxagliptin==1
drop saxagliptin
export excel prodcode gemscriptcode productname using sub_admdrugcodes.xls, sheet("saxagliptin") sheetmodify firstrow(variables)

//Vildagliptin
use product.dta, clear
rename productname productname_1
rename drugsubstance drugsubstance_1
gen vildagliptin = 0 
replace vildagliptin = 1 if regexm(prod_bnfcode, "06010203") & regexm(drugsubstance_1, "vildagliptin")      
replace vildagliptin = 1 if regexm(prod_bnfcode, "06010203") & regexm(drugsubstance_1, "(galvus|eucreas|icandra|jalra|xiliarx|zomarist)")
replace vildagliptin = 1 if regexm(prod_bnfcode, "06010203") & regexm(productname_1, "vildagliptin")     
replace vildagliptin = 1 if regexm(prod_bnfcode, "06010203") & regexm(productname_1, "(galvus|eucreas|icandra|jalra|xiliarx|zomarist)")
replace vildagliptin = 1 if regexm(drugsubstance_1, "vildagliptin")       
replace vildagliptin = 1 if regexm(drugsubstance_1, "(galvus|eucreas|icandra|jalra|xiliarx|zomarist)")
replace vildagliptin = 1 if regexm(productname_1, "vildagliptin")     
replace vildagliptin = 1 if regexm(productname_1, "(galvus|eucreas|icandra|jalra|xiliarx|zomarist)")
label variable vildagliptin "Vildagliptin exposure: 0=no exp, 1=exp"
keep if vildagliptin==1
drop vildagliptin
export excel prodcode gemscriptcode productname using sub_admdrugcodes.xls, sheet("vildagliptin") sheetmodify firstrow(variables)

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
