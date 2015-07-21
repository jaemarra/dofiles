//  program:    Stat_stroke_diagnostics.do
//  task:		Statistical analysis for all-cause mortality
//  project: 	Incretins--Comparative mortality and CV outcomes (CPRD)
//  author:     JM \ July 2015  
//				

clear all
capture log close Stat_stroke_diagnostics
set more off
log using Stat_diagnostics.smcl, name(Stat_stroke_diagnostics) replace
timer on 1

capture ssc install table1
capture net install collin.pkg

**********************************************************KM and survival curves****************************************************
use Stat_stroke_mi, clear
sts graph, by(indextype) saving(kmplot_stroke, replace)  
tempfile d0
save `d0', replace
forvalues i = 1/20{
  tempfile d`i'
  use `d0', clear
  mi extract `i'
  qui stcox i.indextype `mvmodel_mi'
  stcurve, survival at1(indextype=0) at2(indextype=1) at3(indextype=2) at4(indextype=3) at5(indextype=4) at6(indextype=5) outfile(`d`i'', replace)
  use `d0', clear
  append using `d`i''
  save, replace
}
use `d0', clear
collapse (mean) surv2 (mean) surv3 (mean) surv4 (mean) surv5 (mean) surv6  (mean) surv7, by(_t)
sort _t
twoway scatter surv2 _t, c(stairstep) ms(i) || scatter surv3 _t, c(stairstep) ms(i) || scatter surv4 _t, c(stairstep) ms(i) || scatter surv5 _t, c(stairstep) ms(i) || scatter surv6 _t, c(stairstep) ms(i) || scatter surv7 _t, c(stairstep) ms(i) ti("Averaged Curves") saving(avgkmplot_stroke, replace)
**********************************************************Other tests of PH Assumption*************************************************
//generate the log log plot for PH assumption 
stphplot, by(indextype) saving(lnlnplot, replace)
graph export lnlnplot.pdf, replace

//non-zero slope for time-dependent covariates
stcox indextype_2 indextype_3 indextype_4 indextype_5 indextype_6 `mvmodel', cformat(%6.2f) pformat(%5.3f) sformat(%6.2f)  nolog noshow
estat phtest, rank detail
stcox i.indextype `mvmodel', schoenfeld(sch*) scaledsch(sca*)
stphtest, detail

//repeat this test plot for each time-dependent variable of interest if you want to look at them individually
//stphtest, plot(age_indexdate) msym(oh)
***********************************************************Testing collinearity******************************************************
collin indextype_2 indextype_3 indextype_4 indextype_5 indextype_6 age_indexdate gender dmdur metoverlap bmicat1 bmicat3 bmicat4 bmicat5 bmicat6 bmicat7 smokestatus1 smokestatus2 smokestatus4 drinkstatus1 drinkstatus2 drinkstatus4 a1ccat1 a1ccat3 a1ccat4 a1ccat5 a1ccat6 sbpcat1 sbpcat3 sbpcat4 sbpcat5 sbpcat6 sbpcat7 ckdcat2 ckdcat3 ckdcat4 ckdcat5 ckdcat6 mdvisits2 mdvisits3 ndrugs2 ndrugs3 cci2 cci3 mi_i stroke_i hf_i arr_i ang_i revasc_i htn_i afib_i pvd_i statin_i calchan_i betablock_i anticoag_oral_i antiplat_i ace_arb_renin_i diuretics_all_i *_post


timer off 1
log close Stat_stroke_diagnostics
