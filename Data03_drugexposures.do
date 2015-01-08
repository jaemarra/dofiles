//  program:    Data03_drugexposures.do
//  task:		Generate variables indicating drug exposures in CPRD Dataset, using individual Therapy files
//  project: 	Incretins--Comparative mortality and CV outcomes (CPRD)
//  author:     MA \ May2014 Modified JM \ Nov2014


clear all
capture log close
set more off

log using Data03test.smcl, replace
timer on 1

forval i=0/10 {
	use Therapy_`i', clear	 
////// #1 make labels case-consistent
// create new variable "productname_1" as the lowercase version of "productname"
generate productname_1=lower(productname)
label variable productname_1 "productname in lower case"
// create new variable "drugsubstance_1" as the lowercase version of "drugsubstance"
generate drugsubstance_1=lower(drugsubstance)
label variable drugsubstance_1 "drugsubstance in lower case"

////// #2 Generate binary variables coding for each antidiabetic drug exposure. Code so 0=no exposure and 1=exposure. For each drug exposure: generate, replace, label
// to avoid picking up insulin-related equipment (syringes, needles) exclude bnfcode 06010103 and 91020000
//codes are from BNF (antidiabetic drugs may have additional drugs from EMA list)

// Short-acting insulins (could include intermediate- and long-acting because of use of word "insulin"...but could miss some without it)
gen insulins_short = 0
replace insulins_short = 1 if regexm(prod_bnfcode, "06010101") & ! regexm(prod_bnfcode, "(06010103|91020000)") 
replace insulins_short = 1 if regexm(drugsubstance_1, "(hypurin bovine neutral|hypurin porcine neutral|actrapid|humulin s|insuman rapid|novorapid|novomix|apidra|humalog|liprolog|actraphane|exubera|mixtard|monotard|protaphane|ultratard|velosulin|ryzodeg)")
replace insulins_short = 1 if regexm(drugsubstance_1, "(insulin|insulin aspart|insulin glulisine|insulin lispro)") & ! regexm(prod_bnfcode, "(06010103|91020000)")
replace insulins_short = 1 if regexm(productname_1, "(hypurin bovine neutral|hypurin porcine neutral|actrapid|humulin s|insuman rapid|novorapid|novomix|apidra|humalog|liprolog|actraphane|exubera|mixtard|monotard|protaphane|ultratard|velosulin|ryzodeg)")
replace insulins_short = 1 if regexm(productname_1, "(insulin|insulin aspart|insulin glulisine|insulin lispro)") & ! regexm(prod_bnfcode, "(06010103|91020000)")
label variable insulins_short " (bnfgrouping) Short-acting insulins exposure: 0=no exp, 1=exp"

// Intermediate- and long-acting insulins (could include short-acting because of use of word "insulin"...but could miss some without it)
gen insulins_intlong = 0
replace insulins_intlong = 1 if regexm(prod_bnfcode, "06010102") & ! regexm(prod_bnfcode, "(06010103|91020000)")
replace insulins_intlong = 1 if regexm(drugsubstance_1, "(tresiba|levemir|lantus|hypurin bovine lente|hypurin bovine isophane|hypurin porcine isophane|insulatard|humulin i|insuman basal|hypurin bovine protamine zinc|novomix 30|humalog mix25|humalog mix50|hypurin porcine 30/70 mix|humulin m3|insuman comb|optisulin|ryzodeg)")
replace insulins_intlong = 1 if regexm(drugsubstance_1, "(insulin degludec|insulin detemir|insulin glargine|insulin zinc suspension|isophane insulin|protamine zinc insulin|biphasic insulin aspart|biphasic insulin lispro| biphasic isophane insulin)") & ! regexm(prod_bnfcode, "(06010103|91020000)")
replace insulins_intlong = 1 if regexm(productname_1, "(tresiba|levemir|lantus|hypurin bovine lente|hypurin bovine isophane|hypurin porcine isophane|insulatard|humulin i|insuman basal|hypurin bovine protamine zinc|novomix 30|humalog mix25|humalog mix50|hypurin porcine 30/70 mix|humulin m3|insuman comb|optisulin|ryzodeg)")
replace insulins_intlong = 1 if regexm(productname_1, "(insulin degludec|insulin detemir|insulin glargine|insulin zinc suspension|isophane insulin|protamine zinc insulin|biphasic insulin aspart|biphasic insulin lispro| biphasic isophane insulin)") & ! regexm(prod_bnfcode, "(06010103|91020000)")
label variable insulins_intlong " (bnfgrouping) Intermediate- and long-acting insulins exposure: 0=no exp, 1=exp"

// Any insulin (incl 2 above groups)
gen insulin = 0
replace insulin = 1 if insulins_short==1|insulins_intlong==1
label variable insulin "Any insulin exposure: 0=no exposure, 1=exp"

// Sulfonylureas
gen sulfonylurea = 0
replace sulfonylurea = 1 if regexm(prod_bnfcode, "06010201")
replace sulfonylurea = 1 if regexm(drugsubstance_1, "(diamicron|amaryl|minodiab|avaglim|tandemact)")
replace sulfonylurea = 1 if regexm(drugsubstance_1, "(glibenclamide|gliclazide|glimepiride|glipizide|tolbutamide)")
replace sulfonylurea = 1 if regexm(productname_1, "(diamicron|amaryl|minodiab|avaglim|tandemact)")
replace sulfonylurea = 1 if regexm(productname_1, "(glibenclamide|gliclazide|glimepiride|glipizide|tolbutamide)")
label variable sulfonylurea "Sulfonylurea exposure: 0=no exp, 1=exp"

// Biguanides (metformin is only one)
gen metformin = 0
replace metformin = 1 if regexm(prod_bnfcode, "06010202")
replace metformin = 1 if regexm(drugsubstance_1, "(glucophage|avandamet|competact|efficib|eucreas|glubrava|icandra|janumet|jentadueto|komboglyze|ristfor|velmetia|vipdomet|zomarist)")
replace metformin = 1 if regexm(drugsubstance_1, "(metformin)")
replace metformin = 1 if regexm(productname_1, "(glucophage|avandamet|competact|efficib|eucreas|glubrava|icandra|janumet|jentadueto|komboglyze|ristfor|velmetia|vipdomet|zomarist)")
replace metformin = 1 if regexm(productname_1, "(metformin)")
label variable metformin "Metformin exposure: 0=no exp, 1=exp"

// TZDs
gen tzd = 0 
replace tzd = 1 if regexm(prod_bnfcode, "06010203") & regexm(drugsubstance_1, "(rosiglitazone|troglitazone|pioglitazone)")
replace tzd = 1 if regexm(prod_bnfcode, "06010203") & regexm(drugsubstance_1, "(avandia|avandamet|avaglim|nyracta|venvia|romozin|actos|competact|glidipion|glubrava|glustin|paglitaz|sepioglin|tandemact|incresync)")
replace tzd = 1 if regexm(prod_bnfcode, "06010203") & regexm(productname_1, "(rosiglitazone|troglitazone|pioglitazone)")
replace tzd = 1 if regexm(prod_bnfcode, "06010203") & regexm(productname_1, "(avandia|avandamet|avaglim|nyracta|venvia|romozin|actos|competact|glidipion|glubrava|glustin|paglitaz|sepioglin|tandemact|incresync)")
replace tzd = 1 if regexm(drugsubstance_1, "(rosiglitazone|troglitazone|pioglitazone)")
replace tzd = 1 if regexm(drugsubstance_1, "(avandia|avandamet|avaglim|nyracta|venvia|romozin|actos|competact|glidipion|glubrava|glustin|paglitaz|sepioglin|tandemact|incresync)")
replace tzd = 1 if regexm(productname_1, "(rosiglitazone|troglitazone|pioglitazone)")
replace tzd = 1 if regexm(productname_1, "(avandia|avandamet|avaglim|nyracta|venvia|romozin|actos|competact|glidipion|glubrava|glustin|paglitaz|sepioglin|tandemact|incresync)")
label variable tzd "tzd exposure: 0=no exp, 1=exp"

// DPP-4 Inhibitors
gen dpp = 0 
replace dpp = 1 if regexm(prod_bnfcode, "06010203") & regexm(drugsubstance_1, "(alogliptin|linagliptin|saxagliptin|sitagliptin|vildagliptin)")      
replace dpp = 1 if regexm(prod_bnfcode, "06010203") & regexm(drugsubstance_1, "(vipdomet|vipidia|incresync|trajenta|jentadueto|onglyza|komboglyze|januvia|janumet|efficib|ristaben|ristfor|tesavel|velmetia|xelevia|galvus|eucreas|icandra|jalra|xiliarx|zomarist)")
replace dpp = 1 if regexm(prod_bnfcode, "06010203") & regexm(productname_1, "(alogliptin|linagliptin|saxagliptin|sitagliptin|vildagliptin)")      
replace dpp = 1 if regexm(prod_bnfcode, "06010203") & regexm(productname_1, "(vipdomet|vipidia|incresync|trajenta|jentadueto|onglyza|komboglyze|januvia|janumet|efficib|ristaben|ristfor|tesavel|velmetia|xelevia|galvus|eucreas|icandra|jalra|xiliarx|zomarist)")
replace dpp = 1 if regexm(drugsubstance_1, "(alogliptin|linagliptin|saxagliptin|sitagliptin|vildagliptin)")      
replace dpp = 1 if regexm(drugsubstance_1, "(vipdomet|vipidia|incresync|trajenta|jentadueto|onglyza|komboglyze|januvia|janumet|efficib|ristaben|ristfor|tesavel|velmetia|xelevia|galvus|eucreas|icandra|jalra|xiliarx|zomarist)")
replace dpp = 1 if regexm(productname_1, "(alogliptin|linagliptin|saxagliptin|sitagliptin|vildagliptin)")      
replace dpp = 1 if regexm(productname_1, "(vipdomet|vipidia|incresync|trajenta|jentadueto|onglyza|komboglyze|januvia|janumet|efficib|ristaben|ristfor|tesavel|velmetia|xelevia|galvus|eucreas|icandra|jalra|xiliarx|zomarist)")
label variable dpp "DPP-4 inhibitor exposure: 0=no exp, 1=exp"

// GLP-1 Receptor Agonists
gen glp = 0 
replace glp = 1 if regexm(prod_bnfcode, "06010203") & regexm(drugsubstance_1, "(exenatide|liraglutide|lixisenatide)")        
replace glp = 1 if regexm(prod_bnfcode, "06010203") & regexm(drugsubstance_1, "(byetta|bydureon|victoza|lyxumia)")
replace glp = 1 if regexm(prod_bnfcode, "06010203") & regexm(productname_1, "(exenatide|liraglutide|lixisenatide)")            
replace glp = 1 if regexm(prod_bnfcode, "06010203") & regexm(productname_1, "(byetta|bydureon|victoza|lyxumia)")
replace glp = 1 if regexm(drugsubstance_1, "(exenatide|liraglutide|lixisenatide)")            
replace glp = 1 if regexm(drugsubstance_1, "(byetta|bydureon|victoza|lyxumia)")
replace glp = 1 if regexm(productname_1, "(exenatide|liraglutide|lixisenatide)")           
replace glp = 1 if regexm(productname_1, "(byetta|bydureon|victoza|lyxumia)")
label variable glp "GLP-1 RA exposure: 0=no exp, 1=exp"

// Other antidiabetics
gen otherantidiab = 0 
replace otherantidiab = 1 if regexm(prod_bnfcode, "06010203") & regexm(drugsubstance_1, "(acarbose|dapagliflozin|nateglinide|repaglinide|canagliflozin)")               
replace otherantidiab = 1 if regexm(prod_bnfcode, "06010203") & regexm(drugsubstance_1, "(glucobay|forxiga|starlix|tranzec|prandin|enyglid|novonorm|invokana)")
replace otherantidiab = 1 if regexm(prod_bnfcode, "06010203") & regexm(productname_1, "(acarbose|dapagliflozin|nateglinide|repaglinide|canagliflozin)")                   
replace otherantidiab = 1 if regexm(prod_bnfcode, "06010203") & regexm(productname_1, "(glucobay|forxiga|starlix|tranzec|prandin|enyglid|novonorm|invokana)")
replace otherantidiab = 1 if regexm(drugsubstance_1, "(acarbose|dapagliflozin|nateglinide|repaglinide|canagliflozin)")                   
replace otherantidiab = 1 if regexm(drugsubstance_1, "(glucobay|forxiga|starlix|tranzec|prandin|enyglid|novonorm|invokana)")
replace otherantidiab = 1 if regexm(productname_1, "(acarbose|dapagliflozin|nateglinide|repaglinide|canagliflozin)")                
replace otherantidiab = 1 if regexm(productname_1, "(glucobay|forxiga|starlix|tranzec|prandin|enyglid|novonorm|invokana)")
label variable otherantidiab "Other antidiabetic exposure: 0=no exp, 1=exp"

////// #3 Generate indicator variables for each insulin and incretin agent.

//exenatide
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

//liraglutide
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

//lixisenatide
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

//GLP-1 combo
gen glp_combo = 0
replace glp_combo = 1 if exenatide==1|liraglutide==1|lixisenatide==1
label variable glp_combo "GLP-1 RA exposure combination of ind agents: 0=no exp, 1=exp"

//alogliptin
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

//linagliptin
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

//sitagliptin
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

//saxagliptin
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

//vildagliptin
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

//DPP-4 combo
gen dpp_combo = 0
replace dpp_combo = 1 if alogliptin==1|linagliptin==1|sitagliptin==1|saxagliptin==1|vildagliptin==1
label variable dpp_combo "DPP-4 Inhibitor exposure combination of ind agents: 0=no exp, 1=exp"

//insulin (sub-category)
gen ins_sub = 0
replace ins_sub = 1 if regexm(prod_bnfcode, "06010101") & ! regexm(prod_bnfcode, "(06010103|91020000)")
replace ins_sub = 1 if regexm(drugsubstance_1, "(hypurin bovine neutral|hypurin porcine neutral|actrapid|humulin s|insuman rapid|actraphane|exubera|mixtard|monotard|protaphane|ultratard|velosulin)")
replace ins_sub = 1 if regexm(drugsubstance_1, "(insulin)") & ! regexm(prod_bnfcode, "(06010103|91020000)")
replace ins_sub = 1 if regexm(productname_1, "(hypurin bovine neutral|hypurin porcine neutral|actrapid|humulin s|insuman rapid|actraphane|exubera|mixtard|monotard|protaphane|ultratard|velosulin)")
replace ins_sub = 1 if regexm(productname_1, "(insulin)") & ! regexm(prod_bnfcode, "(06010103|91020000)")
label variable ins_sub "Insulin (sub-category) exposure: 0=no exp, 1=exp"

//insulin aspart
gen aspart = 0
replace aspart = 1 if regexm(prod_bnfcode, "06010101") & ! regexm(prod_bnfcode, "(06010103|91020000)")
replace aspart = 1 if regexm(drugsubstance_1, "(novomix|novorapid|ryzodeg)")
replace aspart = 1 if regexm(drugsubstance_1, "(insulin aspart)") & ! regexm(prod_bnfcode, "(06010103|91020000)")
replace aspart = 1 if regexm(productname_1, "(novomix|novorapid|ryzodeg)")
replace aspart = 1 if regexm(productname_1, "(insulin aspart)") & ! regexm(prod_bnfcode, "(06010103|91020000)")
label variable aspart "Insulin aspart exposure: 0=no exp, 1=exp"

//insulin glulisine
gen glulisine = 0
replace glulisine = 1 if regexm(prod_bnfcode, "06010101") & ! regexm(prod_bnfcode, "(06010103|91020000)")
replace glulisine = 1 if regexm(drugsubstance_1, "apidra")
replace glulisine = 1 if regexm(drugsubstance_1, "(insulin glulisine)") & ! regexm(prod_bnfcode, "(06010103|91020000)")
replace glulisine = 1 if regexm(productname_1, "apidra")
replace glulisine = 1 if regexm(productname_1, "(insulin glulisine)") & ! regexm(prod_bnfcode, "(06010103|91020000)")
label variable glulisine "Insulin glulisine exposure: 0=no exp, 1=exp"

//insulin lispro
gen lispro = 0
replace lispro = 1 if regexm(prod_bnfcode, "06010101") & ! regexm(prod_bnfcode, "(06010103|91020000)")
replace lispro = 1 if regexm(drugsubstance_1, "(humalog|liprolog)")
replace lispro = 1 if regexm(drugsubstance_1, "(insulin lispro)") & ! regexm(prod_bnfcode, "(06010103|91020000)")
replace lispro = 1 if regexm(productname_1, "(humalog|liprolog)")
replace lispro = 1 if regexm(productname_1, "(insulin lispro)") & ! regexm(prod_bnfcode, "(06010103|91020000)")
label variable lispro "Insulin lispro exposure: 0=no exp, 1=exp"

//insulin degludec
gen degludec = 0
replace degludec = 1 if regexm(prod_bnfcode, "06010102") & ! regexm(prod_bnfcode, "(06010103|91020000)")
replace degludec = 1 if regexm(drugsubstance_1, "(tresiba|ryzodeg)")
replace degludec = 1 if regexm(drugsubstance_1, "(insulin degludec)") & ! regexm(prod_bnfcode, "(06010103|91020000)")
replace degludec = 1 if regexm(productname_1, "(tresiba|ryzodeg)")
replace degludec = 1 if regexm(productname_1, "(insulin degludec)") & ! regexm(prod_bnfcode, "(06010103|91020000)")
label variable degludec "Insulin degludec exposure: 0=no exp, 1=exp"

//insulin detemir
gen detemir = 0
replace detemir = 1 if regexm(prod_bnfcode, "06010102") & ! regexm(prod_bnfcode, "(06010103|91020000)")
replace detemir = 1 if regexm(drugsubstance_1, "levimir")
replace detemir = 1 if regexm(drugsubstance_1, "(insulin detemir)") & ! regexm(prod_bnfcode, "(06010103|91020000)")
replace detemir = 1 if regexm(productname_1, "levimir")
replace detemir = 1 if regexm(productname_1, "(insulin detemir)") & ! regexm(prod_bnfcode, "(06010103|91020000)")
label variable detemir "Insulin detemir exposure: 0=no exp, 1=exp"

//insulin glargine
gen glargine = 0
replace glargine = 1 if regexm(prod_bnfcode, "06010102") & ! regexm(prod_bnfcode, "(06010103|91020000)")
replace glargine = 1 if regexm(drugsubstance_1, "(lantus|optisulin)")
replace glargine = 1 if regexm(drugsubstance_1, "(insulin glargine)") & ! regexm(prod_bnfcode, "(06010103|91020000)")
replace glargine = 1 if regexm(productname_1, "(lantus|optisulin)")
replace glargine = 1 if regexm(productname_1, "(insulin glargine)") & ! regexm(prod_bnfcode, "(06010103|91020000)")
label variable glargine "Insulin glargine exposure: 0=no exp, 1=exp"

//insulin zinc suspension
gen ins_zinc = 0
replace ins_zinc = 1 if regexm(prod_bnfcode, "06010102") & ! regexm(prod_bnfcode, "(06010103|91020000)")
replace ins_zinc = 1 if regexm(drugsubstance_1, "(hypurin bovine lente)")
replace ins_zinc = 1 if regexm(drugsubstance_1, "(insulin zinc suspension)") & ! regexm(prod_bnfcode, "(06010103|91020000)")
replace ins_zinc = 1 if regexm(productname_1, "(hypurin bovine lente)")
replace ins_zinc = 1 if regexm(productname_1, "(insulin zinc suspension)") & ! regexm(prod_bnfcode, "(06010103|91020000)")
label variable ins_zinc "Insulin zinc suspension exposure: 0=no exp, 1=exp"

//isophane insulin
gen isophane_ins = 0
replace isophane_ins = 1 if regexm(prod_bnfcode, "06010102") & ! regexm(prod_bnfcode, "(06010103|91020000)")
replace isophane_ins = 1 if regexm(drugsubstance_1, "(hypurin bovine isophane|hypurin porcine isophane|insulatard|humulin i|insuman basal)")
replace isophane_ins = 1 if regexm(drugsubstance_1, "(isophane insulin)") & ! regexm(prod_bnfcode, "(06010103|91020000)")
replace isophane_ins = 1 if regexm(productname_1, "(hypurin bovine isophane|hypurin porcine isophane|insulatard|humulin i|insuman basal)")
replace isophane_ins = 1 if regexm(productname_1, "(isophane insulin)") & ! regexm(prod_bnfcode, "(06010103|91020000)")
label variable isophane_ins "Isophane insulin exposure: 0=no exp, 1=exp"

//protamine zinc insulin
gen protamine_zinc_ins = 0
replace protamine_zinc_ins = 1 if regexm(prod_bnfcode, "06010102") & ! regexm(prod_bnfcode, "(06010103|91020000)")
replace protamine_zinc_ins = 1 if regexm(drugsubstance_1, "(hypurin bovine protamine zinc)")
replace protamine_zinc_ins = 1 if regexm(drugsubstance_1, "(protamine zinc insulin)") & ! regexm(prod_bnfcode, "(06010103|91020000)")
replace protamine_zinc_ins = 1 if regexm(productname_1, "(hypurin bovine protamine zinc)")
replace protamine_zinc_ins = 1 if regexm(productname_1, "(protamine zinc insulin)") & ! regexm(prod_bnfcode, "(06010103|91020000)")
label variable protamine_zinc_ins "Protamine zinc insulin exposure: 0=no exp, 1=exp"

//biphasic insulin aspart
gen aspart_biphasic = 0
replace aspart_biphasic = 1 if regexm(prod_bnfcode, "06010102") & ! regexm(prod_bnfcode, "(06010103|91020000)")
replace aspart_biphasic = 1 if regexm(drugsubstance_1, "(novomix 30)")
replace aspart_biphasic = 1 if regexm(drugsubstance_1, "(biphasic insulin aspart)") & ! regexm(prod_bnfcode, "(06010103|91020000)")
replace aspart_biphasic = 1 if regexm(productname_1, "(novomix 30)")
replace aspart_biphasic = 1 if regexm(productname_1, "(biphasic insulin aspart)") & ! regexm(prod_bnfcode, "(06010103|91020000)")
label variable aspart_biphasic "Biphasic insulin aspart exposure: 0=no exp, 1=exp"

//biphasic insulin lispro
gen lispro_biphasic = 0
replace lispro_biphasic = 1 if regexm(prod_bnfcode, "06010102") & ! regexm(prod_bnfcode, "(06010103|91020000)")
replace lispro_biphasic = 1 if regexm(drugsubstance_1, "(humalog mix25|humalog mix50)")
replace lispro_biphasic = 1 if regexm(drugsubstance_1, "(biphasic insulin lispro)") & ! regexm(prod_bnfcode, "(06010103|91020000)")
replace lispro_biphasic = 1 if regexm(productname_1, "(humalog mix25|humalog mix50)")
replace lispro_biphasic = 1 if regexm(productname_1, "(biphasic insulin lispro)") & ! regexm(prod_bnfcode, "(06010103|91020000)")
label variable lispro_biphasic "Biphasic insulin lispro exposure: 0=no exp, 1=exp"

//biphasic isophane insulin
gen isophane_biphasic = 0
replace isophane_biphasic = 1 if regexm(prod_bnfcode, "06010102") & ! regexm(prod_bnfcode, "(06010103|91020000)")
replace isophane_biphasic = 1 if regexm(drugsubstance_1, "(hypurin porcine 30/70 mix|humulin m3|insuman comb)")
replace isophane_biphasic = 1 if regexm(drugsubstance_1, "(biphasic isophane insulin)") & ! regexm(prod_bnfcode, "(06010103|91020000)")
replace isophane_biphasic = 1 if regexm(productname_1, "(hypurin porcine 30/70 mix|humulin m3|insuman comb)")
replace isophane_biphasic = 1 if regexm(productname_1, "(biphasic isophane insulin)") & ! regexm(prod_bnfcode, "(06010103|91020000)")
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

////// #4 Generate variables for cohorts.

// new metformin users
sort patid
by patid: egen metcohort= max(metformin)
label variable metcohort "New Metformin Users"

// 2nd antidiabetic drug
gen other = 0
replace other = 1 if insulin==1 | sulfonylurea==1 | tzd==1 | dpp==1 | glp==1 | otherantidiab==1 
by patid: egen everother= max(other)
label variable everother "Antidiabetic exposure (other than metformin)"

// main analytic cohort (metformin + 2nd antidiabetic drug) Be sure to use qualifier 'if maincohort==1' on any analysis of main cohort!
// restrict to where otherstart date is greater than met startdate (see below, after dates coded for)
gen maincohort = 0
replace maincohort = 1 if metcohort==1 & everother==1 
label variable maincohort "Main Analytic Cohort"

// cohort for secondary analysis (any antidiabetic exposure) **********ISN'T THIS THE SAME AS STUDYENTRYDATE???**************
gen studyentry = 0
replace studyentry = 1 if metformin==1|insulin==1|sulfonylurea==1|tzd==1|dpp==1|glp==1|otherantidiab==1
by patid: egen everstudyentry= max(studyentry)
label variable everstudyentry "Any antidiabetic exposure (secondary analysis)"

////// #5 Generate start dates of metformin and 2nd (other) antidiabetic agents.

sort patid rxdate2
//first date of metformin
by patid: egen met_startdate_temp= min(rxdate2) if metformin==1
format met_startdate_temp %td
by patid: egen met_startdate = min(met_startdate_temp)
format met_startdate %td
label variable met_startdate "Metformin start date"
gen cohortentrydate = met_startdate
format cohortentrydate %td
label variable cohortentrydate "Cohort entry date (metformin start date)"
drop met_startdate_temp
by patid: egen other_startdate_temp= min(rxdate2) if insulin==1|sulfonylurea==1|tzd==1|dpp==1|glp==1|otherantidiab==1 
format other_startdate_temp %td
by patid: egen other_startdate = min(other_startdate_temp)
format other_startdate %td
gen indexdate = other_startdate if !missing(cohortentrydate)
format indexdate %td
label variable indexdate "Index date (2nd antidiabetic start date)"
drop other_startdate_temp

// start date of 2nd antidiabetic agent must be at least one day greater than met start date in main analytic cohort
replace maincohort=0 if other_startdate<=met_startdate 

// start date of any antidiabetic exposure (for secondary analysis)
by patid: egen studyentrydate_temp= min(rxdate2) if metformin==1|insulin==1|sulfonylurea==1|tzd==1|dpp==1|glp==1|otherantidiab==1 
format studyentrydate_temp %td
by patid: egen studyentrydate = min(studyentrydate_temp)
format studyentrydate %td

label variable studyentrydate "Study entry date (start date any antidiabetic exposure)"
drop studyentrydate_temp

// keep only observations with any antidiabetic drug exposure
sort patid
keep if everstudyentry==1

////// #6 Potential medication confounders drug exposure. Code so 0=no exposure and 1=exposure. Based on the categories of BNF codes as indicated by JMG. 
// restrict to exposure in year prior to both cohort entry and index date (see end of this section for loops for this)

// H2 receptor antagonists
gen h2recep = 0 
replace h2recep = 1 if regexm(prod_bnfcode, "010301..") 
replace h2recep = 1 if regexm(drugsubstance_1, "(tagamet|zantac)")
replace h2recep = 1 if regexm(drugsubstance_1, "(cimetidine|famotidine|nizatidine|ranitidine)")
replace h2recep = 1 if regexm(productname_1, "(tagamet|zantac)")
replace h2recep = 1 if regexm(productname_1, "(cimetidine|famotidine|nizatidine|ranitidine)")
label variable h2recep "H2 receptor antagonist exposure: 0=no exp, 1=exp"

// Proton pump inhibitors
gen ppi = 0 
replace ppi = 1 if regexm(prod_bnfcode, "010305..")
replace ppi = 1 if regexm(drugsubstance_1, "(nexium|zoton|losec|protium|pariet)")
replace ppi = 1 if regexm(drugsubstance_1, "(esomeprazole|lansoprazole|omeprazole|pantprazole|rabeprazole)")
replace ppi = 1 if regexm(productname_1, "(nexium|zoton|losec|protium|pariet)")
replace ppi = 1 if regexm(productname_1, "(esomeprazole|lansoprazole|omeprazole|pantprazole|rabeprazole)")
label variable ppi "Proton pump inhibitor exposure: 0=no exp, 1=exp"

// Corticosteroids (GI)
// restrict to oral (nroute==51) **note code # may change when using real dataset
gen cortico_gi = 0 
replace cortico_gi = 1 if regexm(prod_bnfcode, "010502..") & nroute==51
replace cortico_gi = 1 if regexm(drugsubstance_1, "(clipper|budenofalk|entocort|colifoam|predsol)") & nroute==51
replace cortico_gi = 1 if regexm(drugsubstance_1, "(beclometasone|budesonide|hydrocortisone|prednisolone)") & nroute==51
replace cortico_gi = 1 if regexm(productname_1, "(clipper|budenofalk|entocort|colifoam|predsol)") & nroute==51
replace cortico_gi = 1 if regexm(productname_1, "(beclometasone|budesonide|hydrocortisone|prednisolone)") & nroute==51
label variable cortico_gi "Corticosteroid (GI) exposure:0=no exp, 1=exp"

// thiazide and related diuretics 
gen thiazdiur = 0 
replace thiazdiur = 1 if regexm(prod_bnfcode, "020201..")
replace thiazdiur = 1 if regexm(drugsubstance_1, "(hygroton|navidrex|natrilex|ethibide|tensaid|diurexan)")
replace thiazdiur = 1 if regexm(drugsubstance_1, "(bendroflumethazide|bendrofluazide|chlortalidone|chlorthalidone|cyclopenthiazide|indapamide|metolazone|xipamide)")
replace thiazdiur = 1 if regexm(productname_1, "(hygroton|navidrex|natrilex|ethibide|tensaid|diurexan)")
replace thiazdiur = 1 if regexm(productname_1, "(bendroflumethazide|bendrofluazide|chlortalidone|chlorthalidone|cyclopenthiazide|indapamide|metolazone|xipamide)")
label variable thiazdiur "thiazide and related diuretic exposure: 0=no exp, 1=exp"

// loop diuretics 
gen loopdiur = 0 
replace loopdiur = 1 if regexm(prod_bnfcode, "020202..")
replace loopdiur = 1 if regexm(drugsubstance_1, "(lasix|torem)")
replace loopdiur = 1 if regexm(drugsubstance_1, "(bumetanide|furosemide|frusemide|torasemide)")
replace loopdiur = 1 if regexm(productname_1, "(lasix|torem)")
replace loopdiur = 1 if regexm(productname_1, "(bumetanide|furosemide|frusemide|torasemide)")
label variable loopdiur "loop diuretic exposure: 0=no exp, 1=exp"

// Potassium-sparing diuretics and aldosterone antagonists
gen potsparediur_aldos = 0 
replace potsparediur_aldos = 1 if regexm(prod_bnfcode, "020203..")
replace potsparediur_aldos = 1 if regexm(drugsubstance_1, "(dytac|inspra|aldactone)")
replace potsparediur_aldos = 1 if regexm(drugsubstance_1, "(amiloride|triamterene|eplerenone|spironolactone)")
replace potsparediur_aldos = 1 if regexm(productname_1, "(dytac|inspra|aldactone)")
replace potsparediur_aldos = 1 if regexm(productname_1, "(amiloride|triamterene|eplerenone|spironolactone)")
label variable potsparediur_aldos "Potassium-sparing diuretic and aldosterone antagonist exposure: 0=no exp, 1=exp"

// Potassium-sparing diuretics with other diuretics
gen potsparediur_other = 0 
replace potsparediur_other = 1 if regexm(prod_bnfcode, "020204..")
replace potsparediur_other = 1 if regexm(drugsubstance_1, "(navispare|dyazide|kalspare|frusene|lasilactone)")
replace potsparediur_other = 1 if regexm(drugsubstance_1, "(amilozide|amilofruse|triamterzide|flumactone)")
replace potsparediur_other = 1 if regexm(productname_1, "(navispare|dyazide|kalspare|frusene|lasilactone)")
replace potsparediur_other = 1 if regexm(productname_1, "(amilozide|amilofruse|triamterzide|flumactone)")
label variable potsparediur_other "Potassium-sparing diuretic with other diuretic exposure: 0=no exp, 1=exp"

// Antiarrhythmic drugs
gen antiarrhythmic = 0 
replace antiarrhythmic = 1 if regexm(prod_bnfcode, "0203....")
replace antiarrhythmic = 1 if regexm(drugsubstance_1, "(adenocor|adenoscan|multaq|cordarone|rythmodan|tambocor|arythmol|lignocaine)")
replace antiarrhythmic = 1 if regexm(drugsubstance_1, "(adenosine|dronedarone|amiodarone|disopyramide|flecainide|propafenone|lidocaine)")
replace antiarrhythmic = 1 if regexm(productname_1, "(adenocor|adenoscan|multaq|cordarone|rythmodan|tambocor|arythmol|lignocaine)")
replace antiarrhythmic = 1 if regexm(productname_1, "(adenosine|dronedarone|amiodarone|disopyramide|flecainide|propafenone|lidocaine)")
label variable antiarrhythmic "antiarrhythmic exposure: 0=no exp, 1=exp"

// Beta-blockers 
gen betablock = 0 
replace betablock = 1 if regexm(prod_bnfcode, "0204....")
replace betablock = 1 if regexm(drugsubstance_1, "(inderal|sectral|tenormin|tenidone|kalten|tenoret|tenoretic|beta-adalat|tenif|cardicor|emcor|celectol|brevibloc|trandate|betaloc|lopresor|corgard|nebilet|trasicor|visken|viskaldix|beta-cardone|sotacor)")
replace betablock = 1 if regexm(drugsubstance_1, "(propranolol|acebutolol|atenolol|bisoprolol|carvedilol|celiprolol|esmolol|labetolol|metoprolol|nadolol|nebivolol|oxprenolol|pindolol|sotalol|timolol)")
replace betablock = 1 if regexm(productname_1, "(inderal|sectral|tenormin|tenidone|kalten|tenoret|tenoretic|beta-adalat|tenif|cardicor|emcor|celectol|brevibloc|trandate|betaloc|lopresor|corgard|nebilet|trasicor|visken|viskaldix|beta-cardone|sotacor)")
replace betablock = 1 if regexm(productname_1, "(propranolol|acebutolol|atenolol|bisoprolol|carvedilol|celiprolol|esmolol|labetolol|metoprolol|nadolol|nebivolol|oxprenolol|pindolol|sotalol|timolol)")
label variable betablock "beta-blocker exposure: 0=no exp, 1=exp"

// ACE Inhibitors
gen acei = 0 
replace acei = 1 if regexm(prod_bnfcode, "02050501")
replace acei = 1 if regexm(drugsubstance_1, "(capoten|zidocapt|capozide|vascace|innovace|innozide|tanatril|zestril|carace|zestoretic|perdix|coversyl|accupro|accuretic|tritace|triapin|gopten|tarka)")
replace acei = 1 if regexm(drugsubstance_1, "(captopril|cilazapril|enalapril|fosinopril|imidapril|lisinopril|moexipril|perindopril|quinapril|ramipril|tandolapril)")
replace acei = 1 if regexm(productname_1, "(capoten|zidocapt|capozide|vascace|innovace|innozide|tanatril|zestril|carace|zestoretic|perdix|coversyl|accupro|accuretic|tritace|triapin|gopten|tarka)")
replace acei = 1 if regexm(productname_1, "(captopril|cilazapril|enalapril|fosinopril|imidapril|lisinopril|moexipril|perindopril|quinapril|ramipril|tandolapril)")
label variable acei "ACE inhibitor exposure: 0=no exp, 1=exp"

// Angiotensin II receptor antagonist
gen angiotensin2recepant = 0 
replace angiotensin2recepant = 1 if regexm(prod_bnfcode, "02050502")
replace angiotensin2recepant = 1 if regexm(drugsubstance_1, "(edarbi|amias|teveten|aprovel|coaprovel|cozaar|olmetec|sevikar|micardis|diovan)")
replace angiotensin2recepant = 1 if regexm(drugsubstance_1, "(azilsartan medoxomil|candesartan cilexetil|eprosartan|irbesartan|losartan|olmesartan medoximil|telmisartan|valsartan)")
replace angiotensin2recepant = 1 if regexm(productname_1, "(edarbi|amias|teveten|aprovel|coaprovel|cozaar|olmetec|sevikar|micardis|diovan)")
replace angiotensin2recepant = 1 if regexm(productname_1, "(azilsartan medoxomil|candesartan cilexetil|eprosartan|irbesartan|losartan|olmesartan medoximil|telmisartan|valsartan)")
label variable angiotensin2recepant "Angiotensin II receptor antagonist exposure: 0=no exp, 1=exp"

// Renin Inhibitors
gen renini = 0 
replace renini = 1 if regexm(prod_bnfcode, "02050503")
replace renini = 1 if regexm(drugsubstance_1, "(rasilez)")
replace renini = 1 if regexm(drugsubstance_1, "(aliskiren)")
replace renini = 1 if regexm(productname_1, "(rasilez)")
replace renini = 1 if regexm(productname_1, "(aliskiren)")
label variable renini "Renin inhibitor exposure: 0=no exp, 1=exp"

// Drugs affecting renin angiotensin system (RAS) (includes 3 above groups)
gen ras = 0 
replace ras = 1 if acei==1|angiotensin2recepant==1|renini==1
label variable ras "ras exposure: 0=no exp, 1=exp"

// nitrates 
gen nitrates = 0 
replace nitrates = 1 if regexm(prod_bnfcode, "020601..")
replace nitrates = 1 if regexm(drugsubstance_1, "(coro-nitro|glytrin|gtn|nitrolingual|nitromin|nitrocine|nitronal|deponit|minitran|nitro-dur|percutol|transiderm-nitro|angitak|isoket|ismo|chemydur|elantan|imdur|isib|isodur|isotard|modisal|monomax|monomil|monosorb|zemon)")
replace nitrates = 1 if regexm(drugsubstance_1, "(glyceral trinitrate|isosorbide dinitrate|isosorbide mononitrate)")
replace nitrates = 1 if regexm(productname_1, "(coro-nitro|glytrin|gtn|nitrolingual|nitromin|nitrocine|nitronal|deponit|minitran|nitro-dur|percutol|transiderm-nitro|angitak|isoket|ismo|chemydur|elantan|imdur|isib|isodur|isotard|modisal|monomax|monomil|monosorb|zemon)")
replace nitrates = 1 if regexm(productname_1, "(glyceral trinitrate|isosorbide dinitrate|isosorbide mononitrate)")
label variable nitrates "nitrates exposure: 0=no exp, 1=exp"

// calcium channel blockers 
gen calchan = 0 
replace calchan = 1 if regexm(prod_bnfcode, "020602..")
replace calchan = 1 if regexm(drugsubstance_1, "(istin|exforge|tildiem|adizem|angitil|calcicard|dilcardia|dilzem|slozem|viazem|zemtard|plendil|prescal|zanidip|cardene|adalat|adipine|coracten|fortipine|nifedipress|tensipine|valni|nimotop|cordilox|securon|univer|verapress|vertab)")
replace calchan = 1 if regexm(drugsubstance_1, "(amlodipine|diltiazem|felodipine|isradipine|lacidipine|lercanidipine|nicardipine|nifedipine|nimodipine|verapamil)")
replace calchan = 1 if regexm(productname_1, "(istin|exforge|tildiem|adizem|angitil|calcicard|dilcardia|dilzem|slozem|viazem|zemtard|plendil|prescal|zanidip|cardene|adalat|adipine|coracten|fortipine|nifedipress|tensipine|valni|nimotop|cordilox|securon|univer|verapress|vertab)")
replace calchan = 1 if regexm(productname_1, "(amlodipine|diltiazem|felodipine|isradipine|lacidipine|lercanidipine|nicardipine|nifedipine|nimodipine|verapamil)")
label variable calchan "calcium channel blocker exposure: 0=no exp, 1=exp"

// oral anticoagulant
gen anticoag_oral = 0 
replace anticoag_oral = 1 if regexm(prod_bnfcode, "020802..")
replace anticoag_oral = 1 if regexm(drugsubstance_1, "(sinthrome|pradaxa|eliquis|xarelto)")
replace anticoag_oral = 1 if regexm(drugsubstance_1, "(warfarin|acenocoumarol|phenindione|dabigatran|apixaban|rivaroxaban)")
replace anticoag_oral = 1 if regexm(productname_1, "(sinthrome|pradaxa|eliquis|xarelto)")
replace anticoag_oral = 1 if regexm(productname_1, "(warfarin|acenocoumarol|phenindione|dabigatran|apixaban|rivaroxaban)")
label variable anticoag_oral "Oral anticoagulant exposure: 0=no exp, 1=exp"

// antiplatelet 
gen antiplat = 0 
replace antiplat = 1 if regexm(prod_bnfcode, "0209....")
replace antiplat = 1 if regexm(drugsubstance_1, "(reopro|plavix|asasantin|integrilin|efient|brilique|aggrastat)")
replace antiplat = 1 if regexm(drugsubstance_1, "(abciximab|aspirin|acetylsalicylic acid|clopidogrel|dipyridamole|eptifibatide|prasugrel|ticagrelor|tirofiban)")
replace antiplat = 1 if regexm(productname_1, "(reopro|plavix|asasantin|integrilin|efient|brilique|aggrastat)")
replace antiplat = 1 if regexm(productname_1, "(abciximab|aspirin|acetylsalicylic acid|clopidogrel|dipyridamole|eptifibatide|prasugrel|ticagrelor|tirofiban)")
label variable antiplat "antiplatelet exposure: 0=no exp, 1=exp"

// statins 
gen statin = 0 
replace statin = 1 if regexm(prod_bnfcode, "021204..")
replace statin = 1 if regexm(drugsubstance_1, "(lipitor|lescol|lipostat|crestor|zocor|inegy)")
replace statin = 1 if regexm(drugsubstance_1, "(atorvastatin|fluvastatin|pravastatin|rosuvastatin|simvastatin)")
replace statin = 1 if regexm(productname_1, "(lipitor|lescol|lipostat|crestor|zocor|inegy)")
replace statin = 1 if regexm(productname_1, "(atorvastatin|fluvastatin|pravastatin|rosuvastatin|simvastatin)")
label variable statin "statin exposure: 0=no exp, 1=exp"

// fibrates
gen fibrates = 0 
replace fibrates = 1 if regexm(prod_bnfcode, "021203..")
replace fibrates = 1 if regexm(drugsubstance_1, "(bezalip|lipantil|lopid)")
replace fibrates = 1 if regexm(drugsubstance_1, "(bezafibrate|ciprofibrate|fenofibrate|gemfibrozil)")
replace fibrates = 1 if regexm(productname_1, "(bezalip|lipantil|lopid)")
replace fibrates = 1 if regexm(productname_1, "(bezafibrate|ciprofibrate|fenofibrate|gemfibrozil)")
label variable fibrates "fibrates exposure: 0=no exp, 1=exp"

// ezetimibe
gen ezetimibe = 0 
replace ezetimibe = 1 if regexm(prod_bnfcode, "021202..")
replace ezetimibe = 1 if regexm(drugsubstance_1, "(ezetrol)")
replace ezetimibe = 1 if regexm(drugsubstance_1, "(ezetimibe)")
replace ezetimibe = 1 if regexm(productname_1, "(ezetrol)")
replace ezetimibe = 1 if regexm(productname_1, "(ezetimibe)")
label variable ezetimibe "ezetimibe exposure: 0=no exp, 1=exp"

// bile acid sequestrants
gen bileacidseq = 0 
replace bileacidseq = 1 if regexm(prod_bnfcode, "021201..")
replace bileacidseq = 1 if regexm(drugsubstance_1, "(cholestagel|questran|colestid)")
replace bileacidseq = 1 if regexm(drugsubstance_1, "(colesevelam|colestyramine|colestipol)")
label variable bileacidseq "Bile acid sequestrants exposure: 0=no exp, 1=exp"

// lipid-regulating drugs (includes above 4 groups)
gen lipidreg = 0 
replace lipidreg = 1 if statin==1|fibrates==1|ezetimibe==1|bileacidseq==1
label variable lipidreg "Lipid-regulating drug exposure: 0=no exp, 1=exp"

// Bronchodilators
gen bronchodil = 0 
replace bronchodil = 1 if regexm(prod_bnfcode, "0301....")
replace bronchodil = 1 if regexm(drugsubstance_1, "(bambec|atimos modulite|foradil|oxis|onbrez|ventamax|ventolin|airomir|asmasal|easyhaler salbutamol|pulvinal|salamol|salbulin|serevent|bricanyl|eklira genuair|seebri|atrovent|respontin|spiriva|nuelin|slo-phyllin|uniphyllin continus|phyllocontin|combivent)")
replace bronchodil = 1 if regexm(drugsubstance_1, "(bambuterol|formoterol fumarate|eformoterol fumarate|indacaterol|albutamol|albuterol|salmeterol|terbutaline|ephedrine|aclidinium bromide|glycopyrronium|ipratropium bromide|tiotropium|theophylline|aminophylline)")
replace bronchodil = 1 if regexm(productname_1, "(bambec|atimos modulite|foradil|oxis|onbrez|ventamax|ventolin|airomir|asmasal|easyhaler salbutamol|pulvinal|salamol|salbulin|serevent|bricanyl|eklira genuair|seebri|atrovent|respontin|spiriva|nuelin|slo-phyllin|uniphyllin continus|phyllocontin|combivent)")
replace bronchodil = 1 if regexm(productname_1, "(bambuterol|formoterol fumarate|eformoterol fumarate|indacaterol|albutamol|albuterol|salmeterol|terbutaline|ephedrine|aclidinium bromide|glycopyrronium|ipratropium bromide|tiotropium|theophylline|aminophylline)")
label variable bronchodil "Bronchodilator exposure:0=no exp, 1=exp"

// Corticosteroids, inhaled
gen cortico_inh = 0 
replace cortico_inh = 1 if regexm(prod_bnfcode, "0302....")
replace cortico_inh = 1 if regexm(drugsubstance_1, "(asmabec|becodisks|clenil modulite|qvar|fostair|budelin|pulmicort|symbicort|alvesco|flixotide|flutiform|seretide|asmanex)")
replace cortico_inh = 1 if regexm(drugsubstance_1, "(beclometasone|beclomethasone|budesonide|ciclesonide|fluticasone|mometasone)")
replace cortico_inh = 1 if regexm(productname_1, "(asmabec|becodisks|clenil modulite|qvar|fostair|budelin|pulmicort|symbicort|alvesco|flixotide|flutiform|seretide|asmanex)")
replace cortico_inh = 1 if regexm(productname_1, "(beclometasone|beclomethasone|budesonide|ciclesonide|fluticasone|mometasone)")
label variable cortico_inh "Inhaled corticosteroid exposure:0=no exp, 1=exp"

// Leukotriene receptor anatagonists
gen leukotri = 0 
replace leukotri = 1 if regexm(prod_bnfcode, "030302..")
replace leukotri = 1 if regexm(drugsubstance_1, "(singulair|accolate)")
replace leukotri = 1 if regexm(drugsubstance_1, "(montelukast|zafirlukast)")
replace leukotri = 1 if regexm(productname_1, "(singulair|accolate)")
replace leukotri = 1 if regexm(productname_1, "(montelukast|zafirlukast)")
label variable leukotri "Leukotriene receptor antagonist exposure:0=no exp, 1=exp"

// Antihistamines
gen antihist = 0 
replace antihist = 1 if regexm(prod_bnfcode, "030401..")
replace antihist = 1 if regexm(drugsubstance_1, "(ilaxten|neoclarityn|telfast|mizollen|rupafin|piriton|tavegil|periactin|atarax|ucerax|zaditen|phenergan)")
replace antihist = 1 if regexm(drugsubstance_1, "(acrivastine|bilastine|cetirizine|desloratidine|fexofenadine|levocetirizine|loratidine|mizolastine|rupatadine|alimemazine|trimeprazine|chlorphenamine|chlorpheniramine|clemastine|cyproheptadine|hydroxyzine|ketotifen|promethazine)")
replace antihist = 1 if regexm(productname_1, "(ilaxten|neoclarityn|telfast|mizollen|rupafin|piriton|tavegil|periactin|atarax|ucerax|zaditen|phenergan)")
replace antihist = 1 if regexm(productname_1, "(acrivastine|bilastine|cetirizine|desloratidine|fexofenadine|levocetirizine|loratidine|mizolastine|rupatadine|alimemazine|trimeprazine|chlorphenamine|chlorpheniramine|clemastine|cyproheptadine|hydroxyzine|ketotifen|promethazine)")
label variable antihist "Antihistamine exposure:0=no exp, 1=exp"

// Hypnotics and Anxiolytics
gen hyp_anx = 0 
replace hyp_anx = 1 if regexm(prod_bnfcode, "0401....")
replace hyp_anx = 1 if regexm(drugsubstance_1, "(dalmane|sonata|stilnoct|zopiclone|zimovane|chloral mixture|chloral elixir|welldorm|xyrem|circadin)")
replace hyp_anx = 1 if regexm(drugsubstance_1, "(nitrazepam|flurazepam|loprazolam|lormetazepam|temazepan|zaleplon|zolpidem|zopiclone|chloral hydrate|clomethiazole|chlormethiazole|promethazine|sodium oxybate|melatonin|diazepam|alprazolam|chlordiazepoxide|lorazepam|oxazepam|buspirone|meprobamate)")
replace hyp_anx = 1 if regexm(productname_1, "(dalmane|sonata|stilnoct|zopiclone|zimovane|chloral mixture|chloral elixir|welldorm|xyrem|circadin)")
replace hyp_anx = 1 if regexm(productname_1, "(nitrazepam|flurazepam|loprazolam|lormetazepam|temazepan|zaleplon|zolpidem|zopiclone|chloral hydrate|clomethiazole|chlormethiazole|promethazine|sodium oxybate|melatonin|diazepam|alprazolam|chlordiazepoxide|lorazepam|oxazepam|buspirone|meprobamate)")
label variable hyp_anx "Hypnotic/Anxiolytic exposure:0=no exp, 1=exp"

// Drugs used in psychoses and related disorders
gen psychoses = 0 
replace psychoses = 1 if regexm(prod_bnfcode, "0402....")
replace psychoses = 1 if regexm(drugsubstance_1, "(anquil|largactil|depixol|fluanxol|dozic|haldol|serenace|nozinan|fentazin|orap|dolmatil|sulpor|stelazine|clopixol|solian|abilify|clozaril|denzapine|zaponex|zyprexa|invega|seroquel|risperdal|modecate|zypadhera|xeplion|piportil|sycrest|depakote|convulex|camcolit|liskonum|priadel|li-liquid)")
replace psychoses = 1 if regexm(drugsubstance_1, "(benperidol|chlorpromazine|flupentixol|flupenthixol|haloperidol|levomepromazine|methotrimeprazine|pericyazine|periciazine|perphenazine|pimozide|prochlorperazine|promazine|sulpiride|trifluoperazine|zuclopenthixol|amisulpride|aripiprazole|clozapine|olanzapine|paliperidone|quetiapine|risperidone|flupentixol decanoate|flupenthixol decanoate|fluphenazine decanoate|pipotiazine|pipothiazine|asenapine|valproic acid|lithium)")
replace psychoses = 1 if regexm(productname_1, "(anquil|largactil|depixol|fluanxol|dozic|haldol|serenace|nozinan|fentazin|orap|dolmatil|sulpor|stelazine|clopixol|solian|abilify|clozaril|denzapine|zaponex|zyprexa|invega|seroquel|risperdal|modecate|zypadhera|xeplion|piportil|sycrest|depakote|convulex|camcolit|liskonum|priadel|li-liquid)")
replace psychoses = 1 if regexm(productname_1, "(benperidol|chlorpromazine|flupentixol|flupenthixol|haloperidol|levomepromazine|methotrimeprazine|pericyazine|periciazine|perphenazine|pimozide|prochlorperazine|promazine|sulpiride|trifluoperazine|zuclopenthixol|amisulpride|aripiprazole|clozapine|olanzapine|paliperidone|quetiapine|risperidone|flupentixol decanoate|flupenthixol decanoate|fluphenazine decanoate|pipotiazine|pipothiazine|asenapine|valproic acid|lithium)")
label variable psychoses "Drugs used in psychoses and related disorders exposure:0=no exp, 1=exp"

// Antidepressants
gen antidepress = 0 
replace antidepress = 1 if regexm(prod_bnfcode, "0403....")
replace antidepress = 1 if regexm(drugsubstance_1, "(triptafen|anafranil|prothiaden|sinepin|allegron|surmontil|molipaxin|nardil|manerix|cipramil|cipralex|prozac|faverin|seroxat|lustral|valdoxan|cymbalta|yentreve|depixol|zispin|edronax|efexor)")
replace antidepress = 1 if regexm(drugsubstance_1, "(amitriptyline|clomipramine|dosulepin|dothiepin|doxepin|imipramine|lofepramine|nortriptyline|trimipramine|mianserin|trazodone|phenelzine|isocarboxazid|tranylcypromine|moclobemide|citalopram|escitalopram|fluoxetine|fluvoxamine|paroxetine|sertraline|agomelatine|duloxetine|flupentixol|mirtazapine|reboxetine|tryptophan|venlafaxine)")
replace antidepress = 1 if regexm(productname_1, "(triptafen|anafranil|prothiaden|sinepin|allegron|surmontil|molipaxin|nardil|manerix|cipramil|cipralex|prozac|faverin|seroxat|lustral|valdoxan|cymbalta|yentreve|depixol|zispin|edronax|efexor)")
replace antidepress = 1 if regexm(productname_1, "(amitriptyline|clomipramine|dosulepin|dothiepin|doxepin|imipramine|lofepramine|nortriptyline|trimipramine|mianserin|trazodone|phenelzine|isocarboxazid|tranylcypromine|moclobemide|citalopram|escitalopram|fluoxetine|fluvoxamine|paroxetine|sertraline|agomelatine|duloxetine|flupentixol|mirtazapine|reboxetine|tryptophan|venlafaxine)")
label variable antidepress "Antidepressant exposure:0=no exp, 1=exp"

// Antiobesity
gen antiobes = 0
replace antiobes = 1 if regexm(prod_bnfcode, "0405....")
replace antiobes = 1 if regexm(drugsubstance_1, "(xenical)")
replace antiobes = 1 if regexm(drugsubstance_1, "(orlistat)")
replace antiobes = 1 if regexm(productname_1, "(xenical)")
replace antiobes = 1 if regexm(productname_1, "(orlistat)")
label variable antiobes "Antiobesity drug exposure:0=no exp, 1=exp"

// Opioid analgesics (CNS)
gen opioid1 = 0
replace opioid1 = 1 if regexm(prod_bnfcode, "040702..|15010403")
replace opioid1 = 1 if regexm(drugsubstance_1, "(temgesic|butrans|transtec|df118 forte|dhc continus| abstral|effentora|actiq|instanyl|pecfent|durogesic|palladone|meptid|oramorph|sevredol|filnarine|morphgesic|mst continus|zomorph|mxl|cyclimorph|oxynorm|oxycontin|targincat|pamergan|palexia|zamadol|zydol|larapam|mabron|marol|maxitram|tramquel|zeridame|tradorec)")
replace opioid1 = 1 if regexm(drugsubstance_1, "(buprenorphine|codeine|diamorphine|heroin|dihydrocodeine|dipipanone|fentanyl|hydromorphone|meptazinol|methadone|morphine|oxycodone|papaveretum|pentazocine|pethidine|tapentadol|tramadol)")
replace opioid1 = 1 if regexm(productname_1, "(temgesic|butrans|transtec|df118 forte|dhc continus| abstral|effentora|actiq|instanyl|pecfent|durogesic|palladone|meptid|oramorph|sevredol|filnarine|morphgesic|mst continus|zomorph|mxl|cyclimorph|oxynorm|oxycontin|targincat|pamergan|palexia|zamadol|zydol|larapam|mabron|marol|maxitram|tramquel|zeridame|tradorec)")
replace opioid1 = 1 if regexm(productname_1, "(buprenorphine|codeine|diamorphine|heroin|dihydrocodeine|dipipanone|fentanyl|hydromorphone|meptazinol|methadone|morphine|oxycodone|papaveretum|pentazocine|pethidine|tapentadol|tramadol)")
label variable opioid1 "Opioid analgesic (CNS) exposure:0=no exp, 1=exp"

// Antiepileptics
gen antiepilep = 0
replace antiepilep = 1 if regexm(prod_bnfcode, "0408....")
replace antiepilep = 1 if regexm(drugsubstance_1, "(tegretol|carbagen|zebinix|trileptal|emeside|zarontin|neurontin|lyrica|vimapt|lamictal|keppra|fycompa|mysoline|epanutin|trobalt|inovelon|gabitril|topamax|epilim|episenta|epival|convulex|depakote|sabril|zongran|rivotril|buccolam)")
replace antiepilep = 1 if regexm(drugsubstance_1, "(carbamazepine|eslicarbazepine|oxcarbazapine|ethosuximide|gabapentin|pregabalin|lacosamide|lamotrigine|levetiracetam|perampanel|phenobarbital|phenobarbitone|primidone|phenytoin|retigabine|rufinamide|tiagabine|topiramate|valproate|vigabatrin|zonisamide|clobazam|clonazepam|diazepam|fosphenytoin|lorazepam|midazolam)")
replace antiepilep = 1 if regexm(productname_1, "(tegretol|carbagen|zebinix|trileptal|emeside|zarontin|neurontin|lyrica|vimapt|lamictal|keppra|fycompa|mysoline|epanutin|trobalt|inovelon|gabitril|topamax|epilim|episenta|epival|convulex|depakote|sabril|zongran|rivotril|buccolam)")
replace antiepilep = 1 if regexm(productname_1, "(carbamazepine|eslicarbazepine|oxcarbazapine|ethosuximide|gabapentin|pregabalin|lacosamide|lamotrigine|levetiracetam|perampanel|phenobarbital|phenobarbitone|primidone|phenytoin|retigabine|rufinamide|tiagabine|topiramate|valproate|vigabatrin|zonisamide|clobazam|clonazepam|diazepam|fosphenytoin|lorazepam|midazolam)")
label variable antiepilep "Antiepileptic exposure:0=no exp, 1=exp"

// Antiparkinsons, dopaminergic
gen antipark_dop = 0
replace antipark_dop = 1 if regexm(prod_bnfcode, "040901..")
replace antipark_dop = 1 if regexm(drugsubstance_1, "(apogo|cabaser|mirapexin|adartrel|requip|neupro|madopar|sinemet|duodopa|caramet|stalevo|azilect|eldepryl|zelapar|comtess|tasmar|symmetrel|lysovir)")
replace antipark_dop = 1 if regexm(drugsubstance_1, "(apomorphine|bromocriptine|cabergoline|pergolide|pramipexole|ropinirole|rotigotine|co-beneldopa|co-careldopa|rasagiline|selegiline|entacapone|tolcapone|amantadine|levodopa)")
replace antipark_dop = 1 if regexm(productname_1, "(apogo|cabaser|mirapexin|adartrel|requip|neupro|madopar|sinemet|duodopa|caramet|stalevo|azilect|eldepryl|zelapar|comtess|tasmar|symmetrel|lysovir)")
replace antipark_dop = 1 if regexm(productname_1, "(apomorphine|bromocriptine|cabergoline|pergolide|pramipexole|ropinirole|rotigotine|co-beneldopa|co-careldopa|rasagiline|selegiline|entacapone|tolcapone|amantadine|levodopa)")
label variable antipark_dop "Antiparkison's dopaminergic drug exposure:0=no exp, 1=exp"

// restrict antibiotics to oral (nroute==51) **note code # may change when using real dataset
// Penicillins
gen penicillin = 0
replace penicillin = 1 if regexm(prod_bnfcode, "050101..") & nroute==51
replace penicillin = 1 if regexm(drugsubstance_1, "(crystapen|negaban|amoxil|penbritin|augmentin|magnapen|tazocin|timentin|selexid)") & nroute==51
replace penicillin = 1 if regexm(drugsubstance_1, "(benzylpenicillin|penicillin g|phenoxymethylpenicillin|penicillin v|flucloxacillin|temocillin|amoxicillin|amoxycillin|ampicillin|co-amoxiclav|co-fluampicil|piperacillin with tazobactam|ticarcillin with calvulanic acid|pivmecillinam)") & nroute==51
replace penicillin = 1 if regexm(productname_1, "(crystapen|negaban|amoxil|penbritin|augmentin|magnapen|tazocin|timentin|selexid)") & nroute==51
replace penicillin = 1 if regexm(productname_1, "(benzylpenicillin|penicillin g|phenoxymethylpenicillin|penicillin v|flucloxacillin|temocillin|amoxicillin|amoxycillin|ampicillin|co-amoxiclav|co-fluampicil|piperacillin with tazobactam|ticarcillin with calvulanic acid|pivmecillinam)") & nroute==51
label variable penicillin "Penicillin exposure: 0=no exp, 1=exp"

// Cephalosporins, carbapenems and other beta-lactams
gen ceph_carb_betalac = 0
replace ceph_carb_betalac = 1 if regexm(prod_bnfcode, "050102..") & nroute==51
replace ceph_carb_betalac = 1 if regexm(drugsubstance_1, "(distaclor|ceporex|keflex|suprax|orelox|zinforo|fortum|kefadim|rocephin|zinacef|zinnat|doribax|invanz|primaxin|meronem|azactam|cayston)") & nroute==51
replace ceph_carb_betalac = 1 if regexm(drugsubstance_1, "(cefaclor|cefadroxil|cefalexin|cephalexin|cefixime|cefotaxime|cefpodoxime|cefradine|ceftaroline|ceftazidime|ceftriaxone|cefuroxime|doripenem|ertapenem|imipenem with cilastatin|meropenem|aztreonam)") & nroute==51
replace ceph_carb_betalac = 1 if regexm(productname_1, "(distaclor|ceporex|keflex|suprax|orelox|zinforo|fortum|kefadim|rocephin|zinacef|zinnat|doribax|invanz|primaxin|meronem|azactam|cayston)") & nroute==51
replace ceph_carb_betalac = 1 if regexm(productname_1, "(cefaclor|cefadroxil|cefalexin|cephalexin|cefixime|cefotaxime|cefpodoxime|cefradine|ceftaroline|ceftazidime|ceftriaxone|cefuroxime|doripenem|ertapenem|imipenem with cilastatin|meropenem|aztreonam)") & nroute==51
label variable ceph_carb_betalac "Cephalosporins, carbapenems and other beta-lactams exposure: 0=no exp, 1=exp"

// Tetracyclines
gen tetracyc = 0
replace tetracyc = 1 if regexm(prod_bnfcode, "050103..") & nroute==51
replace tetracyc = 1 if regexm(drugsubstance_1, "(vibramycin|efracea|tetralysal|tygacil)") & nroute==51
replace tetracyc = 1 if regexm(drugsubstance_1, "(tetracycline|demeclocycline|doxycycline|lymecycline|minocycline|oxytetracycline|tigecycline)") & nroute==51
replace tetracyc = 1 if regexm(productname_1, "(vibramycin|efracea|tetralysal|tygacil)") & nroute==51
replace tetracyc = 1 if regexm(productname_1, "(tetracycline|demeclocycline|doxycycline|lymecycline|minocycline|oxytetracycline|tigecycline)") & nroute==51
label variable tetracyc "Tetracycline exposure: 0=no exp, 1=exp"

// Aminoglycosides
gen aminoglyc = 0
replace aminoglyc = 1 if regexm(prod_bnfcode, "050104..")  & nroute==51
replace aminoglyc = 1 if regexm(drugsubstance_1, "(cidomycin|genticin|amikin|bramitob|tobi)") & nroute==51
replace aminoglyc = 1 if regexm(drugsubstance_1, "(gentamicin|amikacin|neomycin|tobramycin)") & nroute==51
replace aminoglyc = 1 if regexm(productname_1, "(cidomycin|genticin|amikin|bramitob|tobi)") & nroute==51
replace aminoglyc = 1 if regexm(productname_1, "(gentamicin|amikacin|neomycin|tobramycin)") & nroute==51
label variable aminoglyc "Aminoglycoside exposure: 0=no exp, 1=exp"

// Macrolides
gen macrolide = 0
replace macrolide = 1 if regexm(prod_bnfcode, "050105..") & nroute==51
replace macrolide = 1 if regexm(drugsubstance_1, "(zithromax|klaricid|erymax|erythrocin|erythroped|ketek)") & nroute==51
replace macrolide = 1 if regexm(drugsubstance_1, "(azithromycin|clarithromycin|erythromycin|telithromycin)") & nroute==51
replace macrolide = 1 if regexm(productname_1, "(zithromax|klaricid|erymax|erythrocin|erythroped|ketek)") & nroute==51
replace macrolide = 1 if regexm(productname_1, "(azithromycin|clarithromycin|erythromycin|telithromycin)") & nroute==51
label variable macrolide "Macrolide exposure: 0=no exp, 1=exp"

// Clindamycin
gen clinda = 0
replace clinda = 1 if regexm(prod_bnfcode, "050106..") & nroute==51
replace clinda = 1 if regexm(drugsubstance_1, "(dalacin)") & nroute==51
replace clinda = 1 if regexm(drugsubstance_1, "(clindamycin)") & nroute==51
replace clinda = 1 if regexm(productname_1, "(dalacin)") & nroute==51
replace clinda = 1 if regexm(productname_1, "(clindamycin)") & nroute==51
label variable clinda "Clindamycin exposure: 0=no exp, 1=exp"

// Some other antibiotics
gen otherantibiot = 0
replace otherantibiot = 1 if regexm(prod_bnfcode, "050107..") & nroute==51
replace otherantibiot = 1 if regexm(drugsubstance_1, "(kemicetine|fucidin|vancocin|targocid|cubicin|zyvox|colomycin|promixin|colobreathe|targaxan|xifaxanta|dificlir)") & nroute==51
replace otherantibiot = 1 if regexm(drugsubstance_1, "(chloramphenicol|sodium fusidate|vancomycin|teicoplanin|daptomycin|linezolid|colistimethate|colistin sulfomethate|rifaximin|fidaxomycin)") & nroute==51
replace otherantibiot = 1 if regexm(productname_1, "(kemicetine|fucidin|vancocin|targocid|cubicin|zyvox|colomycin|promixin|colobreathe|targaxan|xifaxanta|dificlir)") & nroute==51
replace otherantibiot = 1 if regexm(productname_1, "(chloramphenicol|sodium fusidate|vancomycin|teicoplanin|daptomycin|linezolid|colistimethate|colistin sulfomethate|rifaximin|fidaxomycin)") & nroute==51
label variable otherantibiot "Other antibiotic exposure: 0=no exp, 1=exp"

// Sulfonamides and trimethoprim
gen sulfo_trimeth = 0
replace sulfo_trimeth = 1 if regexm(prod_bnfcode, "050108..") & nroute==51
replace sulfo_trimeth = 1 if regexm(drugsubstance_1, "(septrin)") & nroute==51
replace sulfo_trimeth = 1 if regexm(drugsubstance_1, "(co-trimoxazole|sulfadiazine|sulphadiazine|trimethoprim)") & nroute==51
replace sulfo_trimeth = 1 if regexm(productname_1, "(septrin)") & nroute==51
replace sulfo_trimeth = 1 if regexm(productname_1, "(co-trimoxazole|sulfadiazine|sulphadiazine|trimethoprim)") & nroute==51
label variable sulfo_trimeth "Sulfonamides and trimethoprim exposure: 0=no exp, 1=exp"

// Antituberculosis drugs
gen antituberc = 0
replace antituberc = 1 if regexm(prod_bnfcode, "050109..") & nroute==51
replace antituberc = 1 if regexm(drugsubstance_1, "(zinamide|mycobutin|rifadin|rimactane|rifater|rifinah|voractiv)") & nroute==51
replace antituberc = 1 if regexm(drugsubstance_1, "(capreomycin|cycloserine|ethambutol|isoniazid|pyrazinamide|rifabutin|rifampicin|streptomycin)") & nroute==51
replace antituberc = 1 if regexm(productname_1, "(zinamide|mycobutin|rifadin|rimactane|rifater|rifinah|voractiv)") & nroute==51
replace antituberc = 1 if regexm(productname_1, "(capreomycin|cycloserine|ethambutol|isoniazid|pyrazinamide|rifabutin|rifampicin|streptomycin)") & nroute==51
label variable antituberc "Antituberculosis drug exposure: 0=no exp, 1=exp"

// Antileprotic drugs
gen antileprotic = 0
replace antileprotic = 1 if regexm(prod_bnfcode, "050110..") & nroute==51
replace antileprotic = 1 if regexm(drugsubstance_1, "(dapsone|clofazimine)") & nroute==51
replace antileprotic = 1 if regexm(productname_1, "(dapsone|clofazimine)") & nroute==51
label variable antileprotic "Antileprotic drug exposure: 0=no exp, 1=exp"

// Metronidazole and tinidazole 
gen metro_tinidazole = 0
replace metro_tinidazole = 1 if regexm(prod_bnfcode, "050111..") & nroute==51
replace metro_tinidazole = 1 if regexm(drugsubstance_1, "(flagyl|metrolyl|fasigyn)") & nroute==51
replace metro_tinidazole = 1 if regexm(drugsubstance_1, "(metronidazole|tinidazole)") & nroute==51
replace metro_tinidazole = 1 if regexm(productname_1, "(flagyl|metrolyl|fasigyn)") & nroute==51
replace metro_tinidazole = 1 if regexm(productname_1, "(metronidazole|tinidazole)") & nroute==51
label variable metro_tinidazole "Metronidazole and tinidazole exposure: 0=no exp, 1=exp"

// Quinolones 
gen quinolone = 0
replace quinolone = 1 if regexm(prod_bnfcode, "050112..") & nroute==51
replace quinolone = 1 if regexm(drugsubstance_1, "(ciproxin|tavanic|avelox|utinor|tarivid)") & nroute==51
replace quinolone = 1 if regexm(drugsubstance_1, "(ciprofloxacin|levofloxacin|moxifloxacin|nalidixic|norfloxacin|ofloxacin)") & nroute==51
replace quinolone = 1 if regexm(productname_1, "(ciproxin|tavanic|avelox|utinor|tarivid)") & nroute==51
replace quinolone = 1 if regexm(productname_1, "(ciprofloxacin|levofloxacin|moxifloxacin|nalidixic|norfloxacin|ofloxacin)") & nroute==51
label variable quinolone "Quinolone exposure: 0=no exp, 1=exp"

// Urinary Tract Infections 
gen uti_drugs = 0
replace uti_drugs = 1 if regexm(prod_bnfcode, "050113..") & nroute==51
replace uti_drugs = 1 if regexm(drugsubstance_1, "(furadantin|macrodantin|macrobid|hiprex)") & nroute==51
replace uti_drugs = 1 if regexm(drugsubstance_1, "(nitrofurantoin|methenamine hippurate|hexamine hippurate)") & nroute==51
replace uti_drugs = 1 if regexm(productname_1, "(furadantin|macrodantin|macrobid|hiprex)") & nroute==51
replace uti_drugs = 1 if regexm(productname_1, "(nitrofurantoin|methenamine hippurate|hexamine hippurate)") & nroute==51
label variable uti_drugs "UTI drug exposure: 0=no exp, 1=exp"

// Antibacterials (includes above 13 groups)
gen antibacterial = 0
replace antibacterial = 1 if penicillin==1|ceph_carb_betalac==1|tetracyc==1|aminoglyc==1|macrolide==1|clinda==1|otherantibiot==1|sulfo_trimeth==1|antituberc==1|antileprotic==1|metro_tinidazole==1|quinolone==1|uti_drugs==1
label variable antibacterial "Antibacterial drug exposure: 0=no exp, 1=exp"

// Antifungal drugs
gen antifungal = 0
replace antifungal = 1 if regexm(prod_bnfcode, "0502....")
replace antifungal = 1 if regexm(drugsubstance_1, "(diflucan|sporanox|noxafil|vfend|nizoral|fungizone|abelcet|ambisome|ecalta|cancidas|mycamine|ancotil|fulsovin|lamisil)")
replace antifungal = 1 if regexm(drugsubstance_1, "(fluconazole|itraconazole|posaconazole|voriconazole|ketoconazole|amphotericin|anidulafungin|caspofungin|micafungin|flucytosine|griseofulvin|terbinafine)")
replace antifungal = 1 if regexm(productname_1, "(diflucan|sporanox|noxafil|vfend|nizoral|fungizone|abelcet|ambisome|ecalta|cancidas|mycamine|ancotil|fulsovin|lamisil)")
replace antifungal = 1 if regexm(productname_1, "(fluconazole|itraconazole|posaconazole|voriconazole|ketoconazole|amphotericin|anidulafungin|caspofungin|micafungin|flucytosine|griseofulvin|terbinafine)")
label variable antifungal "Antifungal exposure:0=no exp, 1=exp"

// Antiviral drugs
gen antiviral = 0
replace antiviral = 1 if regexm(prod_bnfcode, "0503....")
replace antiviral = 1 if regexm(drugsubstance_1, "(ziagen|kivexa|trizivir|videx|emtriva|epivir|zeffix|zerit|viread|truvada|atripla|eviplera|retrovir|combivir|reyataz|prezista|telzir|crixivan|kaletra|norvir|invirase|aptivus|sustiva|intelence|viramune|edurant|fuzeon|celsentri|isentress|zorivax|famvir|imunovir|valtrex|vistide|cymevene|foscavir|valcyte|hepsera|baraclude|sebivo|victrelis|incivo|lysovir|symmetrel|tamiflu|relenza|synagis|copegus|rebetol|virazole)")
replace antiviral = 1 if regexm(drugsubstance_1, "(abacavir|didanosine|ddi|emtricitabine|ftc|lamivudine|3tc|stavudine|d4t|tenofovir disoproxil|zidovudine|zidovudine and lamivudine|azidothymadine|azt|atazanavir|darunavir|fosamprenavir|indinavir|lopinavir with ritonavir|ritonavir|saquinavir|tipranavir|efavirenz|etravirine|nevirapine|rilpivirine|enfuvirtide|maraviroc|raltegravir|aciclovir|acyclovir|famciclovir|inosine pranobex|inosine acedoben dimepranol|valaciclovir|cidofovir|ganciclovir|foscarnet|valganciclovir|adefovir dipivoxil|entecavir|telbivudine|boceprevir|telaprevir|amantadine|oseltamivir|zanamivir|palivizumab|ribavirin|tribavirin)")
replace antiviral = 1 if regexm(productname_1, "(ziagen|kivexa|trizivir|videx|emtriva|epivir|zeffix|zerit|viread|truvada|atripla|eviplera|retrovir|combivir|reyataz|prezista|telzir|crixivan|kaletra|norvir|invirase|aptivus|sustiva|intelence|viramune|edurant|fuzeon|celsentri|isentress|zorivax|famvir|imunovir|valtrex|vistide|cymevene|foscavir|valcyte|hepsera|baraclude|sebivo|victrelis|incivo|lysovir|symmetrel|tamiflu|relenza|synagis|copegus|rebetol|virazole)")
replace antiviral = 1 if regexm(productname_1, "(abacavir|didanosine|ddi|emtricitabine|ftc|lamivudine|3tc|stavudine|d4t|tenofovir disoproxil|zidovudine|zidovudine and lamivudine|azidothymadine|azt|atazanavir|darunavir|fosamprenavir|indinavir|lopinavir with ritonavir|ritonavir|saquinavir|tipranavir|efavirenz|etravirine|nevirapine|rilpivirine|enfuvirtide|maraviroc|raltegravir|aciclovir|acyclovir|famciclovir|inosine pranobex|inosine acedoben dimepranol|valaciclovir|cidofovir|ganciclovir|foscarnet|valganciclovir|adefovir dipivoxil|entecavir|telbivudine|boceprevir|telaprevir|amantadine|oseltamivir|zanamivir|palivizumab|ribavirin|tribavirin)")
label variable antiviral "Antiviral exposure:0=no exp, 1=exp"

// Antiprotozoal drugs
gen antiprotoz = 0
replace antiprotoz = 1 if regexm(prod_bnfcode, "0504....")
replace antiprotoz = 1 if regexm(drugsubstance_1, "(riamet|avloclor|malarivon|nivaquine|paludrine/avloclor|lariam|eurartesim|paludrine|malarone|daraprim|diloxanide|pentostam|wellvone|pentacarinat)")
replace antiprotoz = 1 if regexm(drugsubstance_1, "(artemether with lumefantrine|chloroquine|mefloquine|piperaquine phosphate with artenimol| piperaquine tetraphosphate with dihydroartemisinin|primaquine|proguanil|proguanil hydrochloride with atovaquone|pyrimethamine|pyrimethamine with sulfadoxine|quinine|doxycycline|diloxanide furoate|metronidazole|tinidazole|mepacrine|sodium stibogluconate|atovaquone|pentamidine isetionate)")
replace antiprotoz = 1 if regexm(productname_1, "(riamet|avloclor|malarivon|nivaquine|paludrine/avloclor|lariam|eurartesim|paludrine|malarone|daraprim|diloxanide|pentostam|wellvone|pentacarinat)")
replace antiprotoz = 1 if regexm(productname_1, "(artemether with lumefantrine|chloroquine|mefloquine|piperaquine phosphate with artenimol| piperaquine tetraphosphate with dihydroartemisinin|primaquine|proguanil|proguanil hydrochloride with atovaquone|pyrimethamine|pyrimethamine with sulfadoxine|quinine|doxycycline|diloxanide furoate|metronidazole|tinidazole|mepacrine|sodium stibogluconate|atovaquone|pentamidine isetionate)")
label variable antiprotoz "Antiprotozoal exposure:0=no exp, 1=exp"

// Anthelmintics
gen anthelmintic = 0 
replace anthelmintic = 1 if regexm(prod_bnfcode, "0505....")
replace anthelmintic = 1 if regexm(drugsubstance_1, "(vermox|pripsen)")
replace anthelmintic = 1 if regexm(drugsubstance_1, "(mebendazole|piperazine)")
replace anthelmintic = 1 if regexm(productname_1, "(vermox|pripsen)")
replace anthelmintic = 1 if regexm(productname_1, "(mebendazole|piperazine)")
label variable anthelmintic "Anthelmintic exposure:0=no exp, 1=exp"

// Thyroid hormones
gen thyroidhorm = 0
replace thyroidhorm = 1 if regexm(prod_bnfcode, "060201..")
replace thyroidhorm = 1 if regexm(drugsubstance_1, "(triiodothyronine)")
replace thyroidhorm = 1 if regexm(drugsubstance_1, "(levothyroxine|liothyronine)")
replace thyroidhorm = 1 if regexm(productname_1, "(triiodothyronine)")
replace thyroidhorm = 1 if regexm(productname_1, "(levothyroxine|liothyronine)")
label variable thyroidhorm "Thyroid hormone exposure: 0=no exp, 1=exp"

// Corticosteroids (endocrine)
// restrict to oral (nroute==51) **note code # may change when using real dataset
gen cortico_endocr = 0 
replace cortico_endocr = 1 if regexm(prod_bnfcode, "0603....") & nroute==51
replace cortico_endocr = 1 if regexm(drugsubstance_1, "(betnesol|calcort|efcortesol|solu-cortef|plenadren|medrone|solu-medrone|depo-medrone|lodotra|kenalog)") & nroute==51
replace cortico_endocr = 1 if regexm(drugsubstance_1, "(betamethasone|deflazacort|dexamethasone|hydrocortisone|methylprednisolone|prednisolone|prednisone|triamcinolone)") & nroute==51
replace cortico_endocr = 1 if regexm(productname_1, "(betnesol|calcort|efcortesol|solu-cortef|plenadren|medrone|solu-medrone|depo-medrone|lodotra|kenalog)") & nroute==51
replace cortico_endocr = 1 if regexm(productname_1, "(betamethasone|deflazacort|dexamethasone|hydrocortisone|methylprednisolone|prednisolone|prednisone|triamcinolone)") & nroute==51
label variable cortico_endocr "Corticosteroid (endocrine) exposure:0=no exp, 1=exp"

// Estrogens and HRT
gen estro_hrt = 0
replace estro_hrt = 1 if regexm(prod_bnfcode, "06040101")
replace estro_hrt = 1 if regexm(drugsubstance_1, "(premique|prempak-c|angeliq|climagest|climesse|clinorette|cyclo-progynova|elleste-duet|evorel|femoston|femseven conti|femseven sequi|indivina|kilofem|kilovance|novofem|nuvelle|tridestra|trisequens|premarin|bedol|climaval|elleste-solo|elleste solo|estraderm|estradot|oestrogel|progynova|sandrena|zumenon|hormonin|livial|evista)")
replace estro_hrt = 1 if regexm(drugsubstance_1, "(tibolone|ethinylestradiol|ethinyloestradiol|raloxifene)")
replace estro_hrt = 1 if regexm(productname_1, "(premique|prempak-c|angeliq|climagest|climesse|clinorette|cyclo-progynova|elleste-duet|evorel|femoston|femseven conti|femseven sequi|indivina|kilofem|kilovance|novofem|nuvelle|tridestra|trisequens|premarin|bedol|climaval|elleste-solo|elleste solo|estraderm|estradot|oestrogel|progynova|sandrena|zumenon|hormonin|livial|evista)")
replace estro_hrt = 1 if regexm(productname_1, "(tibolone|ethinylestradiol|ethinyloestradiol|raloxifene)")
label variable estro_hrt "Estrogen and HRT exposure: 0=no exp, 1=exp"

// Bisphosphonates
gen bisphos = 0 
replace bisphos = 1 if regexm(prod_bnfcode, "060602..") & regexm(drugsubstance_1, "(fosamax|fosavance|didronel|aredia|bondronat|bonviva|actonel|bonefos|clasteon|loron|aclasta|zometa)")
replace bisphos = 1 if regexm(prod_bnfcode, "060602..") & regexm(drugsubstance_1, "(alendronic acid|disodium etidronate|disodium pamidronate|ibandronic acid|risedronate sodium|sodium clodronate|zoledronic acid)")
replace bisphos = 1 if regexm(prod_bnfcode, "060602..") & regexm(productname_1, "(fosamax|fosavance|didronel|aredia|bondronat|bonviva|actonel|bonefos|clasteon|loron|aclasta|zometa)")
replace bisphos = 1 if regexm(prod_bnfcode, "060602..") & regexm(productname_1, "(alendronic acid|disodium etidronate|disodium pamidronate|ibandronic acid|risedronate sodium|sodium clodronate|zoledronic acid)")
replace bisphos = 1 if regexm(drugsubstance_1, "(fosamax|fosavance|didronel|aredia|bondronat|bonviva|actonel|bonefos|clasteon|loron|aclasta|zometa)")
replace bisphos = 1 if regexm(drugsubstance_1, "(alendronic acid|disodium etidronate|disodium pamidronate|ibandronic acid|risedronate sodium|sodium clodronate|zoledronic acid)")
replace bisphos = 1 if regexm(productname_1, "(fosamax|fosavance|didronel|aredia|bondronat|bonviva|actonel|bonefos|clasteon|loron|aclasta|zometa)")
replace bisphos = 1 if regexm(productname_1, "(alendronic acid|disodium etidronate|disodium pamidronate|ibandronic acid|risedronate sodium|sodium clodronate|zoledronic acid)")
label variable bisphos "Bisphosphonate drug exposure: 0=no exp, 1=exp"

// Cytotoxic drugs
gen cytotoxic = 0
replace cytotoxic = 1 if regexm(prod_bnfcode, "0801....")
replace cytotoxic = 1 if regexm(drugsubstance_1, "(levact|myleran|busilvex|gliadel|leukeran|estracyt|alkeran|tepadina|daunoxome|caelyx|myocet|pharmorubicin|zavedos|onkotrone|vidaza|xeloda|leustat|litak|evoltra|depocyte|dacogen|fludara|gemzar|puri-nethol|xaluprine|atriance|alimta|tomudex|teysuno|lanvis|etopophos|vepesid|velbe|oncovin|eldisine|javlor|navelbine|amsidine|trisenox|avastin|targretin|velcade|adcetris|removab|erbitux|erwinase|temodal|halaven|hydrea|yervoy|lysodren|vectibix|nipent|perjeta|photofrin|foscan|inlyta|xalkori|sprycel|tarceva|afinitor|votubia|iressa|glivec|tyverb|tasigna|votrient|jakavi|nexavar|sutent|torisel|caprelsa|zelboraf|jevtana|taxotere|abraxane|campto|hycamtin|yondelis|herceptin|vesanoid)")
replace cytotoxic = 1 if regexm(drugsubstance_1, "(bendamustine|busulfan|busulphan|carmustine|chlorambucil|cyclophosphamide|estramustine|ifosfamide|lomustine|melphalan|thiotepa|treosulfan|bleomycin|dactinomycin|actinomycin d|daunorubicin|doxorubicin|epirubicin|idarubicin|mitomycin|mitoxantrone|mitozantrone|azacitidine|capecitabine|cladribine|clofarabine|cytarabine|decitabine|fludarabine|fluorouracil|gemcitabine|mercaptopurine|6-mercaptopurine|methotrexate|nelarabine|pemetrexed|raltitrexed|tegafur with gemeracil and oteracil|tioguanine|thioguanine|etoposide|vnblastine|vincristine|vindesine|vinflunine|vinorelbine|amsacrine|arsenic trioxide|bevacizumab|bexarotene|bortezomib|brentuximab vedotin|catumaxomab|cetuximab|crisantaspase|dacarbazine|temozolomide|eribulin|hydroxycarbamide|hydroxyurea|ipilimumab|mitotane|panitumumab|pentostatin|pertuzumab|carboplatin|cisplatin|oxaliplatin|porfimer|temoporfin|procarbazine|axitinib|crizotinib|dasatinib|erlotinib|everolimus|gefitinib|imatinib|lapatinib|nilotinib|pazopanib|ruxolitinib|sorafenib|sunitinib|temsirolimus|vandetanib|vemurafenib|cabazitaxel|docetaxel|paclitaxel|irinotecan|topotecan|trabectedin|trastuzumab|tretinoin)")
replace cytotoxic = 1 if regexm(productname_1, "(levact|myleran|busilvex|gliadel|leukeran|estracyt|alkeran|tepadina|daunoxome|caelyx|myocet|pharmorubicin|zavedos|onkotrone|vidaza|xeloda|leustat|litak|evoltra|depocyte|dacogen|fludara|gemzar|puri-nethol|xaluprine|atriance|alimta|tomudex|teysuno|lanvis|etopophos|vepesid|velbe|oncovin|eldisine|javlor|navelbine|amsidine|trisenox|avastin|targretin|velcade|adcetris|removab|erbitux|erwinase|temodal|halaven|hydrea|yervoy|lysodren|vectibix|nipent|perjeta|photofrin|foscan|inlyta|xalkori|sprycel|tarceva|afinitor|votubia|iressa|glivec|tyverb|tasigna|votrient|jakavi|nexavar|sutent|torisel|caprelsa|zelboraf|jevtana|taxotere|abraxane|campto|hycamtin|yondelis|herceptin|vesanoid)")
replace cytotoxic = 1 if regexm(productname_1, "(bendamustine|busulfan|busulphan|carmustine|chlorambucil|cyclophosphamide|estramustine|ifosfamide|lomustine|melphalan|thiotepa|treosulfan|bleomycin|dactinomycin|actinomycin d|daunorubicin|doxorubicin|epirubicin|idarubicin|mitomycin|mitoxantrone|mitozantrone|azacitidine|capecitabine|cladribine|clofarabine|cytarabine|decitabine|fludarabine|fluorouracil|gemcitabine|mercaptopurine|6-mercaptopurine|methotrexate|nelarabine|pemetrexed|raltitrexed|tegafur with gemeracil and oteracil|tioguanine|thioguanine|etoposide|vnblastine|vincristine|vindesine|vinflunine|vinorelbine|amsacrine|arsenic trioxide|bevacizumab|bexarotene|bortezomib|brentuximab vedotin|catumaxomab|cetuximab|crisantaspase|dacarbazine|temozolomide|eribulin|hydroxycarbamide|hydroxyurea|ipilimumab|mitotane|panitumumab|pentostatin|pertuzumab|carboplatin|cisplatin|oxaliplatin|porfimer|temoporfin|procarbazine|axitinib|crizotinib|dasatinib|erlotinib|everolimus|gefitinib|imatinib|lapatinib|nilotinib|pazopanib|ruxolitinib|sorafenib|sunitinib|temsirolimus|vandetanib|vemurafenib|cabazitaxel|docetaxel|paclitaxel|irinotecan|topotecan|trabectedin|trastuzumab|tretinoin)")
label variable cytotoxic "Cytotoxic drug exposure:0=no exp, 1=exp"

// Antiproliferative immunosuppressants
gen antiprolif = 0 
replace antiprolif = 1 if regexm(prod_bnfcode, "080201..")
replace antiprolif = 1 if regexm(drugsubstance_1, "(imuran|cellcept|myofortic )")
replace antiprolif = 1 if regexm(drugsubstance_1, "(azathioprine|mycophenolate mofetil)")
replace antiprolif = 1 if regexm(productname_1, "(imuran|cellcept|myofortic )")
replace antiprolif = 1 if regexm(productname_1, "(azathioprine|mycophenolate mofetil)")
label variable antiprolif "Antiproliferative immunosuppresant exposure:0=no exp, 1=exp"

// Corticosteroids and other immunosuppressants
// none of these specific drugs are actually corticosteroids
gen otherimmunosuppress = 0
replace otherimmunosuppress = 1 if regexm(prod_bnfcode, "080202..")
replace otherimmunosuppress = 1 if regexm(drugsubstance_1, "(thymoglobuline|simulect|nulojix|capimmune|capsporin|deximune|neoral|sandimmun|rapamune|adoport|capexion|modigraf|prograf|tacni|vivadex|advagraf)")
replace otherimmunosuppress = 1 if regexm(drugsubstance_1, "(antithymocyte immunoglobulin|basiliximab|belatacept|ciclosporin|cyclosporin|sirolimus|tacrolimus)")
replace otherimmunosuppress = 1 if regexm(productname_1, "(thymoglobuline|simulect|nulojix|capimmune|capsporin|deximune|neoral|sandimmun|rapamune|adoport|capexion|modigraf|prograf|tacni|vivadex|advagraf)")
replace otherimmunosuppress = 1 if regexm(productname_1, "(antithymocyte immunoglobulin|basiliximab|belatacept|ciclosporin|cyclosporin|sirolimus|tacrolimus)")
label variable otherimmunosuppress "Corticosteroids and other immunosuppresant exposure:0=no exp, 1=exp"

// Antilymphocyte monoclonal antibodies
gen antilymph_mab = 0
replace antilymph_mab =1 if regexm(prod_bnfcode, "0982030..")
replace antilymph_mab = 1 if regexm(drugsubstance_1, "(arzerra|mabthera)")
replace antilymph_mab = 1 if regexm(drugsubstance_1, "(ofatumumab|rituximab)")
replace antilymph_mab = 1 if regexm(productname_1, "(arzerra|mabthera)")
replace antilymph_mab = 1 if regexm(productname_1, "(ofatumumab|rituximab)")
label variable antilymph_mab "Antilymphocyte monoclonal antibody exposure:0=no exp, 1=exp"

// Other immunomodulating drugs
gen otherimmunomodul = 0
replace otherimmunomodul = 1 if regexm(prod_bnfcode, "080204..")
replace otherimmunomodul = 1 if regexm(drugsubstance_1, "(introna|roferon-a|pegasys|viraferonpeg|avonex|rebif|betaferon|extavia|immukin|proleukin|immucyst|oncotice|ilaris|gilenya|copaxone|ceplene|revlimid|thalidomide celgene|mepact|tysabri)")
replace otherimmunomodul = 1 if regexm(drugsubstance_1, "(interferon alfa|peginterferon alfa|interferon beta|interferon gamma-1b|aldesleukin|bacillus calmette-guerin|anakinumab|fingolimod|glatiramer acetate|histamine dihydrochloride|lenalidomide|thalidomide|mifamurtide|natalizumab)")
replace otherimmunomodul = 1 if regexm(productname_1, "(introna|roferon-a|pegasys|viraferonpeg|avonex|rebif|betaferon|extavia|immukin|proleukin|immucyst|oncotice|ilaris|gilenya|copaxone|ceplene|revlimid|thalidomide celgene|mepact|tysabri)")
replace otherimmunomodul = 1 if regexm(productname_1, "(interferon alfa|peginterferon alfa|interferon beta|interferon gamma-1b|aldesleukin|bacillus calmette-guerin|anakinumab|fingolimod|glatiramer acetate|histamine dihydrochloride|lenalidomide|thalidomide|mifamurtide|natalizumab)")
label variable otherimmunomodul "Other immunomodulating drug exposure:0=no exp, 1=exp"

// All drugs affecting the immune system
gen immunosuppress_all = 0
replace immunosuppress_all = 1 if antiprolif==1 | otherimmunosuppress==1 | antilymph_mab==1 | otherimmunomodul==1
label variable immunosuppress_all "Any immunosuppressant drug exposure:0=no exp, 1=exp"

// Oral iron
gen iron_oral = 0
replace iron_oral = 1 if regexm(prod_bnfcode, "09010101")
replace iron_oral = 1 if regexm(drugsubstance_1, "(ironorm|feospan|ferrograd|fefol|fersamal|galfer|pregaday|niferex|sytron)")
replace iron_oral = 1 if regexm(drugsubstance_1, "(ferrous sulfate|ferrous fumarate|ferrous gluconate|polysaccharide-iron complex|sodium feredetate|sodium ironedetate)")
replace iron_oral = 1 if regexm(productname_1, "(ironorm|feospan|ferrograd|fefol|fersamal|galfer|pregaday|niferex|sytron)")
replace iron_oral = 1 if regexm(productname_1, "(ferrous sulfate|ferrous fumarate|ferrous gluconate|polysaccharide-iron complex|sodium feredetate|sodium ironedetate)")
label variable iron_oral "Oral iron exposure: 0=no exp, 1=exp"

// Parenteral iron
gen iron_parenteral = 0
replace iron_parenteral = 1 if regexm(prod_bnfcode, "09010102")
replace iron_parenteral = 1 if regexm(drugsubstance_1, "(ferinject|rienso|cosmofer|monofer|venofer)")
replace iron_parenteral = 1 if regexm(drugsubstance_1, "(ferric carboxymaltose|ferumoxytol|iron dextran|iron isomaltoside 1000|iron sucrose)")
replace iron_parenteral = 1 if regexm(productname_1, "(ferinject|rienso|cosmofer|monofer|venofer)")
replace iron_parenteral = 1 if regexm(productname_1, "(ferric carboxymaltose|ferumoxytol|iron dextran|iron isomaltoside 1000|iron sucrose)")
label variable iron_parenteral "Parenteral iron exposure: 0=no exp, 1=exp"

// Oral potassium
gen potassium_oral = 0
replace potassium_oral = 1 if regexm(prod_bnfcode, "09020101")
replace potassium_oral = 1 if regexm(drugsubstance_1, "(kay-cee-l|sando-k|slow-k|calcium resonium|resonium a|sorbisterit)")
replace potassium_oral = 1 if regexm(drugsubstance_1, "(potassium chloride|polystyrene sulfonate resin)")
replace potassium_oral = 1 if regexm(productname_1, "(kay-cee-l|sando-k|slow-k|calcium resonium|resonium a|sorbisterit)")
replace potassium_oral = 1 if regexm(productname_1, "(potassium chloride|polystyrene sulfonate resin)")
label variable potassium_oral "Oral potassium exposure: 0=no exp, 1=exp"

// Multivitamins preparation
gen multivit = 0
replace multivit = 1 if regexm(prod_bnfcode, "090607..")
replace multivit = 1 if regexm(drugsubstance_1, "(abidec|dalivit|forceval|ketovite)")
replace multivit = 1 if regexm(productname_1, "(abidec|dalivit|forceval|ketovite)")
label variable multivit "Multivitamin exposure: 0=no exp, 1=exp"

// NSAIDS
gen nsaid = 0
replace nsaid = 1 if regexm(prod_bnfcode, "100101..")
replace nsaid = 1 if regexm(drugsubstance_1, "(preservex|emflex|celebrex|seractil|keral|voltarol|dyloject|diclomax|motifene|arthrotec|etopan|lodine|arcoxia|fenopron|froben|brufen|fenbid|orudis|oruvail|axorid|ponstan|relifex|naprosyn|vimovo|napratec|brexidol|feldene|mobiflex|surgam)")
replace nsaid = 1 if regexm(drugsubstance_1, "(aceclofenac|acemetacin|celecoxib|dexibuprofen|dexketoprofen|diclofenac potassium|diclofenac sodium|etodolca|etoricoxib|fenoprofen|fluriprofen|ibuprofen|indometacin|indomethacin|ketoprofen|mefenamic acid|meloxicam|nabumetone|naproxen|piroxicam|sulindac|tenoxicam|tiaprofenic acid)")
replace nsaid = 1 if regexm(productname_1, "(preservex|emflex|celebrex|seractil|keral|voltarol|dyloject|diclomax|motifene|arthrotec|etopan|lodine|arcoxia|fenopron|froben|brufen|fenbid|orudis|oruvail|axorid|ponstan|relifex|naprosyn|vimovo|napratec|brexidol|feldene|mobiflex|surgam)")
replace nsaid = 1 if regexm(productname_1, "(aceclofenac|acemetacin|celecoxib|dexibuprofen|dexketoprofen|diclofenac potassium|diclofenac sodium|etodolca|etoricoxib|fenoprofen|fluriprofen|ibuprofen|indometacin|indomethacin|ketoprofen|mefenamic acid|meloxicam|nabumetone|naproxen|piroxicam|sulindac|tenoxicam|tiaprofenic acid)")
label variable nsaid "NSAID exposure: 0=no exp, 1=exp"


// Systemic corticosteroids- not utilized

//Local corticosteroid injections
//restrict to oral (nroute==51) **note code # may change when using real dataset
//since restricting to oral, none of these drugs are applicable as they are all injections
gen cortico_inject = 0
replace cortico_inject = 1 if regexm(prod_bnfcode, "10010202")
replace cortico_inject = 1 if regexm(drugsubstance_1, "(dexamethasone|hydrocortistab|depo-medrone|deltastab|adcortyl|kenalog)")
replace cortico_inject = 1 if regexm(productname_1, "(dexamethasone|hydrocortistab|depo-medrone|deltastab|adcortyl|kenalog)")
label variable cortico_inject "Corticosteroid (local inj) exposure:0=no exp, 1=exp"

// Antigout drugs
gen antigout = 0 
replace antigout = 1 if regexm(prod_bnfcode, "100104..") & regexm(drugsubstance_1, "(zyloric|adenuric)")
replace antigout = 1 if regexm(prod_bnfcode, "100104..") & regexm(drugsubstance_1, "(colchicine|canakinumab|allopurinol|febuxostat|probenecid|sulfinpyrazone|sulphinpyrazone)")
replace antigout = 1 if regexm(prod_bnfcode, "100104..") & regexm(productname_1, "(zyloric|adenuric)")
replace antigout = 1 if regexm(prod_bnfcode, "100104..") & regexm(productname_1, "(colchicine|canakinumab|allopurinol|febuxostat|probenecid|sulfinpyrazone|sulphinpyrazone)")
replace antigout = 1 if regexm(drugsubstance_1, "(zyloric|adenuric)")
replace antigout = 1 if regexm(drugsubstance_1, "(colchicine|canakinumab|allopurinol|febuxostat|probenecid|sulfinpyrazone|sulphinpyrazone)")
replace antigout = 1 if regexm(productname_1, "(zyloric|adenuric)")
replace antigout = 1 if regexm(productname_1, "(colchicine|canakinumab|allopurinol|febuxostat|probenecid|sulfinpyrazone|sulphinpyrazone)")
label variable antigout "Antigout drug exposure: 0=no exp, 1=exp"

// Antirheumatic disease Drugs
gen antirheum = 0
replace antirheum = 1 if regexm(prod_bnfcode, "100103..")
replace antirheum = 1 if regexm(drugsubstance_1, "(myocrisin|distamine|plaquenil|arava|metoject|orencia|humira|kineret|benlysta|cimzia|ebrel|simponi|remicade|roactemra|salazopyrin )")
replace antirheum = 1 if regexm(drugsubstance_1, "(sodium aurothiomalate|penicillamine|chloroquine|hydroxychloroquine sulfate|azathioprine|ciclosporin|cyclosporin|leflunomide|methotrexate|abatacept|adalimumab|anakinra|belimumab|certolizumab pegol|etanercept|golimumab|infliximab|rituximab|tocilizumab|sulfasalazine|sulphasalazine)")
replace antirheum = 1 if regexm(productname_1, "(myocrisin|distamine|plaquenil|arava|metoject|orencia|humira|kineret|benlysta|cimzia|ebrel|simponi|remicade|roactemra|salazopyrin )")
replace antirheum = 1 if regexm(productname_1, "(sodium aurothiomalate|penicillamine|chloroquine|hydroxychloroquine sulfate|azathioprine|ciclosporin|cyclosporin|leflunomide|methotrexate|abatacept|adalimumab|anakinra|belimumab|certolizumab pegol|etanercept|golimumab|infliximab|rituximab|tocilizumab|sulfasalazine|sulphasalazine)")
label variable antirheum "Antirheumatic drug exposure: 0=no exp, 1=exp"

//Vaccines and antisera (14.4) Vaccine records are in a separate file called Immunisation (see Immunisation.do)

// Benzodiazepine
gen benzo = 0
replace benzo = 1 if regexm(prod_bnfcode, "15010401")
replace benzo = 1 if regexm(drugsubstance_1, "(hypnovel)")
replace benzo = 1 if regexm(drugsubstance_1, "(diazepam|lorazepam|midazolam|temazepam)")
replace benzo = 1 if regexm(productname_1, "(hypnovel)")
replace benzo = 1 if regexm(productname_1, "(diazepam|lorazepam|midazolam|temazepam)")
label variable benzo "Benzodiazepine exposure: 0=no exp, 1=exp" 

// Opioid analgesics
gen opioid2 = 0
replace opioid2 = 1 if regexm(prod_bnfcode, "15010403")
replace opioid2 = 1 if regexm(drugsubstance_1, "(repifen|sublimaze|ultiva)")
replace opioid2 = 1 if regexm(drugsubstance_1, "(alfentanil|fentanyl|remifentanil)")
replace opioid2 = 1 if regexm(productname_1, "(repifen|sublimaze|ultiva)")
replace opioid2 = 1 if regexm(productname_1, "(alfentanil|fentanyl|remifentanil)")
label variable opioid2 "Opioid analgesic (anaes) exposure: 0=no exp, 1=exp"

// Any opioid (from CNS-4.7.2 and anaesthesia-15.1.4.3 sections)
gen opioid = 0 
replace opioid = 1 if opioid1==1|opioid2==1
label variable opioid "any opioid exposure: 0=no exp, 1=exp"

// Any oral corticosteroid (from GI-1.5.2 and endocrine-6.3 sections)
gen cortico_oral = 0
replace cortico_oral = 1 if cortico_gi==1|cortico_endocr==1
label variable cortico_oral "any oral corticosteroid exposure: 0=no exp, 1=exp"

// Loops to restrict to exposure one year prior to cohortentrydate, indexdate and studyentrydate. Be sure to use var_c, var_i and var_s when using these binary variables in analysis!!!

			foreach x of varlist h2recep ppi cortico_gi thiazdiur loopdiur potsparediur_aldos potsparediur_other antiarrhythmic betablock            /// 
					acei angiotensin2recepant renini ras nitrates calchan anticoag_oral antiplat statin fibrates ezetimibe bileacidseq      ///
					lipidreg bronchodil cortico_inh leukotri antihist hyp_anx psychoses antidepress antiobes opioid1 antiepilep antipark_dop ///
					penicillin ceph_carb_betalac tetracyc aminoglyc macrolide clinda otherantibiot sulfo_trimeth antituberc antileprotic     ///
					metro_tinidazole quinolone uti_drugs antibacterial antifungal antiviral antiprotoz anthelmintic thyroidhorm cortico_endocr ///
					estro_hrt bisphos cytotoxic antiprolif otherimmunosuppress antilymph_mab otherimmunomodul immunosuppress_all iron_oral     ///
					iron_parenteral potassium_oral multivit nsaid antigout antirheum benzo opioid2 opioid cortico_oral {             
			generate `x'_c = 0										
			replace `x'_c = 1 if `x'==1 & rxdate2>=cohortentrydate-365 & rxdate2<cohortentrydate
			}

			foreach y of varlist h2recep ppi cortico_gi thiazdiur loopdiur potsparediur_aldos potsparediur_other antiarrhythmic betablock            /// 
					acei angiotensin2recepant renini ras nitrates calchan anticoag_oral antiplat statin fibrates ezetimibe bileacidseq      ///
					lipidreg bronchodil cortico_inh leukotri antihist hyp_anx psychoses antidepress antiobes opioid1 antiepilep antipark_dop ///
					penicillin ceph_carb_betalac tetracyc aminoglyc macrolide clinda otherantibiot sulfo_trimeth antituberc antileprotic     ///
					metro_tinidazole quinolone uti_drugs antibacterial antifungal antiviral antiprotoz anthelmintic thyroidhorm cortico_endocr ///
					estro_hrt bisphos cytotoxic antiprolif otherimmunosuppress antilymph_mab otherimmunomodul immunosuppress_all iron_oral     ///
					iron_parenteral potassium_oral multivit nsaid antigout antirheum benzo opioid2 opioid cortico_oral {             
			generate `y'_i = 0										
			replace `y'_i = 1 if `y'==1 & rxdate2>=indexdate-365 & rxdate2<indexdate
			}

			foreach z of varlist h2recep ppi cortico_gi thiazdiur loopdiur potsparediur_aldos potsparediur_other antiarrhythmic betablock            /// 
					acei angiotensin2recepant renini ras nitrates calchan anticoag_oral antiplat statin fibrates ezetimibe bileacidseq      ///
					lipidreg bronchodil cortico_inh leukotri antihist hyp_anx psychoses antidepress antiobes opioid1 antiepilep antipark_dop ///
					penicillin ceph_carb_betalac tetracyc aminoglyc macrolide clinda otherantibiot sulfo_trimeth antituberc antileprotic     ///
					metro_tinidazole quinolone uti_drugs antibacterial antifungal antiviral antiprotoz anthelmintic thyroidhorm cortico_endocr ///
					estro_hrt bisphos cytotoxic antiprolif otherimmunosuppress antilymph_mab otherimmunomodul immunosuppress_all iron_oral     ///
					iron_parenteral potassium_oral multivit nsaid antigout antirheum benzo opioid2 opioid cortico_oral {             
			generate `z'_s = 0										
			replace `z'_s = 1 if `z'==1 & rxdate2>=studyentrydate_cprd2-365 & rxdate2<studyentrydate_cprd2
			}

			
////// #7 Generate continuous variable for number of unique drugs for one year prior to study entry date, cohort entry date and index date.

encode prod_bnfcode, gen(prod_bnfcode2)
sort patid prod_bnfcode2 rxdate2
by patid prod_bnfcode2: generate num = _n
by patid: egen drugnum_un = count(prod_bnfcode2) if num==1 

by patid: egen drugnum_un_c_temp = count(prod_bnfcode2) if num==1 & rxdate2>=cohortentrydate-365 & rxdate2<cohortentrydate
by patid: egen drug_num_un_c = min(drugnum_un_c_temp)
drop drugnum_un_c_temp

by patid: egen drugnum_un_i_temp = count(prod_bnfcode2) if num==1 & rxdate2>=indexdate-365 & rxdate2<indexdate
by patid: egen drug_num_un_i = min(drugnum_un_i_temp)
drop drugnum_un_i_temp

by patid: egen drugnum_un_s_temp = count(prod_bnfcode2) if num==1 & rxdate2>=studyentrydate_cprd2-365 & rxdate2<studyentrydate_cprd2
by patid: egen drug_num_un_s = min(drugnum_un_s_temp)
drop drugnum_un_s_temp

////// #8 Calculate duration, gaps and stop dates of antidiabetic meds
// Generate duration of exposure (dur) and duration of exposure corrected for non-adherence (dur_c) variables
//***********NEED TO ADDRESS THIS****************** 
***time dependent confounding***
/*replace ndd = 1 if ndd==0
replace ndd = 1 if ndd==.
replace qty = 84 if qty==0
replace qty = 84 if qty==.*/

sort patid prod_bnfcode2 rxdate2

gen dur = .
//replace dur=qty/ndd
gen dur_c =dur*1.5 if dur <.
replace dur_c =90 if dur_c >.

// Generate first date of rx for antidiabetic medication
gen rxdate2_first = studyentrydate
format rxdate2_first %td

// Generate date for next expected rx
gen rxdate2_pred = rxdate2+dur_c 
format rxdate2_pred %td

// Generate date for next rx based on lead variable
by patid prod_bnfcode2: gen rxdate2_next = rxdate2[_n+1]
format rxdate2_next %td

// Generate gap dates for antidiabetic medications
gen gap = rxdate2_pred-rxdate2_next if (metformin==1|insulin==1|sulfonylurea==1|tzd==1|dpp==1|glp==1|otherantidiab==1) 

// Generate stop dates for antidiabetic medications based on duration of exposure and gap dates
gen rxdate2_stop = rxdate2_pred if (gap<0|gap==.) & (metformin==1|insulin==1|sulfonylurea==1|tzd==1|dpp==1|glp==1|otherantidiab==1)
format rxdate2_stop %td

// Generate final rx date and final exposure date for antidiabetic medications 
by patid prod_bnfcode2 : egen rxdate2_last_temp = max(rxdate2) if metformin==1|insulin==1|sulfonylurea==1|tzd==1|dpp==1|glp==1|otherantidiab==1
format rxdate2_last_temp %td
by patid prod_bnfcode2 : egen rxdate2_last= max(rxdate2_last_temp)
format rxdate2_last %td 
drop rxdate2_last_temp

gen rxdate2_last_pred = rxdate2_last + dur_c
format rxdate2_last_pred %td

//////	#9 Generate continuous variable for medication adherence and binary variable (0=MPR<0.8; 1=MPR>=0.8)
// MPR = days supply (dur) / days in year before date of interest after first rx
// Have to generate top and bottom values of ratio to calculate MPR.
// for index date
sort patid prod_bnfcode2 rxdate2

by patid prod_bnfcode2: egen mpr_start_i = min(rxdate2) if rxdate2>=indexdate-365 & rxdate2<indexdate
format mpr_start_i %td
gen mpr_dur_i = indexdate - mpr_start_i

by patid prod_bnfcode2: egen mpr_top_i = sum(dur) if rxdate2>=indexdate-365 & rxdate2<indexdate

gen mpr_i = mpr_top_i/mpr_dur_i
label variable mpr_i "MPR for year prior to index date"

gen mpr_i_b =.
replace mpr_i_b = 0 if mpr_i<0.8
replace mpr_i_b = 1 if mpr_i>=0.8 & !missing(mpr_i)
label variable mpr_i_b "MPR-indexdate (binary) 0=<0.8, 1=>=0.8"

by patid: egen avg_mpr_i = mean(mpr_i) if rxdate2>=indexdate-365 & rxdate2<indexdate
label variable avg_mpr_i "Average MPR-index date" 
 
gen avg_mpr_i_b=.
replace avg_mpr_i_b = 0 if avg_mpr_i<0.8
replace avg_mpr_i_b = 1 if avg_mpr_i>=0.8 & !missing(mpr_i)
label variable avg_mpr_i_b " Avg MPR prior to index date (binary) 0=<0.8, 1=>=0.8"

//for cohort entry date
sort patid prod_bnfcode2 rxdate2
by patid prod_bnfcode2: egen mpr_start_c = min(rxdate2) if rxdate2>=cohortentrydate-365 & rxdate2<cohortentrydate
format mpr_start_c %td
gen mpr_dur_c = cohortentrydate - mpr_start_c

by patid prod_bnfcode2: egen mpr_top_c = sum(dur) if rxdate2>=cohortentrydate-365 & rxdate2<cohortentrydate

gen mpr_c = mpr_top_c/mpr_dur_c
label variable mpr_c "MPR for year prior to cohort entry date"

gen mpr_c_b =.
replace mpr_c_b = 0 if mpr_c<0.8
replace mpr_c_b = 1 if mpr_c>=0.8 & !missing(mpr_c)
label variable mpr_c_b "MPR-cohortentry (binary) 0=<0.8, 1=>=0.8"

by patid: egen avg_mpr_c = mean(mpr_c) if rxdate2>=cohortentrydate-365 & rxdate2<cohortentrydate 
label variable avg_mpr_c "Average MPR-cohortentry" 

gen avg_mpr_c_b=.
replace avg_mpr_c_b = 0 if avg_mpr_c<0.8
replace avg_mpr_c_b = 1 if avg_mpr_c>=0.8 & !missing(mpr_c)
label variable avg_mpr_c_b " Avg MPR prior to cohort entry date (binary) 0=<0.8, 1=>=0.8"

//for study entry date
sort patid prod_bnfcode2 rxdate2
by patid prod_bnfcode2: egen mpr_start_s = min(rxdate2) if rxdate2>=studyentrydate_cprd2-365 & rxdate2<studyentrydate_cprd2
format mpr_start_s %td
gen mpr_dur_s = cohortentrydate - mpr_start_s

by patid prod_bnfcode2: egen mpr_top_s = sum(dur) if rxdate2>=studyentrydate_cprd2-365 & rxdate2<studyentrydate_cprd2

gen mpr_s = mpr_top_s/mpr_dur_s
label variable mpr_s "MPR for year prior to study entry date"

gen mpr_s_b =.
replace mpr_s_b = 0 if mpr_s<0.8
replace mpr_s_b = 1 if mpr_s>=0.8 & !missing(mpr_s)
label variable mpr_s_b "MPR-studyentry (binary) 0=<0.8, 1=>=0.8"

by patid: egen avg_mpr_s = mean(mpr_s) if rxdate2>=studyentrydate_cprd2-365 & rxdate2<studyentrydate_cprd2
label variable avg_mpr_s "Average MPR-studyentry" 

gen avg_mpr_s_b=.
replace avg_mpr_s_b = 0 if avg_mpr_s<0.8
replace avg_mpr_s_b = 1 if avg_mpr_s>=0.8 & !missing(mpr_s)
label variable avg_mpr_s_b " Avg MPR prior to study entry date (binary) 0=<0.8, 1=>=0.8"
	
collapse (max) rxdate2 studyentrydate_cprd2 group_cut insulins_short insulins_intlong insulin sulfonylurea metformin tzd ///
				dpp glp otherantidiab exenatide liraglutide lixisenatide glp_combo alogliptin linagliptin sitagliptin saxagliptin ///
				vildagliptin dpp_combo ins_sub aspart glulisine lispro degludec detemir glargine ins_zinc isophane_ins protamine_zinc_ins ///
				aspart_biphasic lispro_biphasic isophane_biphasic insulin_rapid insulin_regular insulin_int_long insulin_ultralong ///
				insulin_premixed insulin_combo metcohort other everother maincohort studyentry everstudyentry met_startdate cohortentrydate ///
				other_startdate indexdate studyentrydate h2recep ppi cortico_gi thiazdiur loopdiur potsparediur_aldos potsparediur_other ///
				antiarrhythmic betablock acei angiotensin2recepant renini ras nitrates calchan anticoag_oral antiplat statin fibrates ezetimibe ///
				bileacidseq lipidreg bronchodil cortico_inh leukotri antihist hyp_anx psychoses antidepress antiobes opioid1 antiepilep ///
				antipark_dop penicillin ceph_carb_betalac tetracyc aminoglyc macrolide clinda otherantibiot sulfo_trimeth antituberc antileprotic ///
				metro_tinidazole quinolone uti_drugs antibacterial antifungal antiviral antiprotoz anthelmintic thyroidhorm cortico_endocr ///
				estro_hrt bisphos cytotoxic antiprolif otherimmunosuppress antilymph_mab otherimmunomodul immunosuppress_all iron_oral ///
				iron_parenteral potassium_oral multivit nsaid antigout antirheum benzo opioid2 opioid cortico_oral h2recep_c ppi_c cortico_gi_c ///
				thiazdiur_c loopdiur_c potsparediur_aldos_c potsparediur_other_c antiarrhythmic_c betablock_c acei_c angiotensin2recepant_c renini_c ///
				ras_c nitrates_c calchan_c anticoag_oral_c antiplat_c statin_c fibrates_c ezetimibe_c bileacidseq_c lipidreg_c bronchodil_c ///
				cortico_inh_c leukotri_c antihist_c hyp_anx_c psychoses_c antidepress_c antiobes_c opioid1_c antiepilep_c antipark_dop_c penicillin_c ///
				ceph_carb_betalac_c tetracyc_c aminoglyc_c macrolide_c clinda_c otherantibiot_c sulfo_trimeth_c antituberc_c antileprotic_c ///
				metro_tinidazole_c quinolone_c uti_drugs_c antibacterial_c antifungal_c antiviral_c antiprotoz_c anthelmintic_c thyroidhorm_c ///
				cortico_endocr_c estro_hrt_c bisphos_c cytotoxic_c antiprolif_c otherimmunosuppress_c antilymph_mab_c otherimmunomodul_c ///
				immunosuppress_all_c iron_oral_c iron_parenteral_c potassium_oral_c multivit_c nsaid_c antigout_c antirheum_c benzo_c opioid2_c ///
				opioid_c cortico_oral_c h2recep_i ppi_i cortico_gi_i thiazdiur_i loopdiur_i potsparediur_aldos_i potsparediur_other_i antiarrhythmic_i ///
				betablock_i acei_i angiotensin2recepant_i renini_i ras_i nitrates_i calchan_i anticoag_oral_i antiplat_i statin_i fibrates_i ezetimibe_i ///
				bileacidseq_i lipidreg_i bronchodil_i cortico_inh_i leukotri_i antihist_i hyp_anx_i psychoses_i antidepress_i antiobes_i opioid1_i ///
				antiepilep_i antipark_dop_i penicillin_i ceph_carb_betalac_i tetracyc_i aminoglyc_i macrolide_i clinda_i otherantibiot_i sulfo_trimeth_i ///
				antituberc_i antileprotic_i metro_tinidazole_i quinolone_i uti_drugs_i antibacterial_i antifungal_i antiviral_i antiprotoz_i ///
				anthelmintic_i thyroidhorm_i cortico_endocr_i estro_hrt_i bisphos_i cytotoxic_i antiprolif_i otherimmunosuppress_i antilymph_mab_i ///
				otherimmunomodul_i immunosuppress_all_i iron_oral_i iron_parenteral_i potassium_oral_i multivit_i nsaid_i antigout_i antirheum_i benzo_i ///
				opioid2_i opioid_i cortico_oral_i h2recep_s ppi_s cortico_gi_s thiazdiur_s loopdiur_s potsparediur_aldos_s potsparediur_other_s ///
				antiarrhythmic_s betablock_s acei_s angiotensin2recepant_s renini_s ras_s nitrates_s calchan_s anticoag_oral_s antiplat_s statin_s ///
				fibrates_s ezetimibe_s bileacidseq_s lipidreg_s bronchodil_s cortico_inh_s leukotri_s antihist_s hyp_anx_s psychoses_s antidepress_s ///
				antiobes_s opioid1_s antiepilep_s antipark_dop_s penicillin_s ceph_carb_betalac_s tetracyc_s aminoglyc_s macrolide_s clinda_s ///
				otherantibiot_s sulfo_trimeth_s antituberc_s antileprotic_s metro_tinidazole_s quinolone_s uti_drugs_s antibacterial_s antifungal_s ///
				antiviral_s antiprotoz_s anthelmintic_s thyroidhorm_s cortico_endocr_s estro_hrt_s bisphos_s cytotoxic_s antiprolif_s ///
				otherimmunosuppress_s antilymph_mab_s otherimmunomodul_s immunosuppress_all_s iron_oral_s iron_parenteral_s potassium_oral_s multivit_s ///
				nsaid_s antigout_s antirheum_s benzo_s opioid2_s opioid_s cortico_oral_s prod_bnfcode2 num drugnum_un drug_num_un_c drug_num_un_i ///
				drug_num_un_s dur dur_c rxdate2_first rxdate2_pred rxdate2_next gap rxdate2_stop rxdate2_last rxdate2_last_pred mpr_start_i mpr_dur_i ///
				mpr_top_i mpr_i mpr_i_b avg_mpr_i avg_mpr_i_b mpr_start_c mpr_dur_c mpr_top_c mpr_c mpr_c_b avg_mpr_c avg_mpr_c_b mpr_start_s mpr_dur_s ///
				mpr_top_s mpr_s mpr_s_b avg_mpr_s avg_mpr_s_b, by(patid)
compress
save Exposures_`i'.dta, replace
	}
use Exposures_0, clear 
forval i=1/10 {		
	append using Exposures_`i'
	}
save Exposures.dta, replace

////////////////////////////////////////////

timer off 1
timer list 1

exit
log close
