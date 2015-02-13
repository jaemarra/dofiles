//  program:    Data_checking.do
//  task:		Generate variables indicating drug exposures in CPRD Dataset, using individual Therapy files
//  project: 	Incretins--Comparative mortality and CV outcomes (CPRD)
//  author:     JM \ Jan2015


clear all
capture log close
set more off
set trace on
log using DataCheck.smcl, replace
timer on 1

codebook

labelbook

ssc install grubbs

foreach var of varlist {
tabulate
summarize
histogram, saving(gr`var', replace)
grubbs `var' level(99)
}

timer off 1
