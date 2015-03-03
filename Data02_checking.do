//  program:    Data02_checking.do
//  task:		Check .dta files generated in Data02_support for data normality
//  project: 	Incretins--Comparative mortality and CV outcomes (CPRD)
//  author:     JM \ Jan2015


clear all
capture log close
set more off

timer clear 1
timer on 1

//DATA02_SUPPORT
//Bnfcodes.dta ***ONLY 2,120 bnf codes***
clear all
capture log close
log using Bnfcodes.smcl
use Bnfcodes.dta
compress
describe
mdesc
codebook, compact
log close

//commondosages
clear all
capture log close
log using commondosages.smcl
use commondosages.dta
compress
codebook, compact
log close

//medical
clear all
capture log close
log using medical.smcl
use medical.dta, clear
compress
describe
codebook, compact
mdesc
log close

//packtype
clear all
capture log close
log using packtype.smcl
use packtype.dta
compress
describe
codebook, compact
log close

//product
clear all
capture log close
log using product.smcl
use product.dta, clear
compress
describe
codebook, compact
mdesc
log close

//scoremethod *******OMITTED*******

//hes
clear all
capture log close
log using hes.smcl
use hes.dta, clear
compress
describe
codebook, compact
mdesc
log close










