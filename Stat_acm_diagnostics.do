//  program:    Stat_acm_diagnostics.do
//  task:		Statistical analysis for all-cause mortality
//  project: 	Incretins--Comparative mortality and CV outcomes (CPRD)
//  author:     JM \ June 2015  
//				

clear all
capture log close Stat_acm_diagnostics
set more off
log using Stat_diagnostics.smcl, name(Stat_acm_diagnostics) replace
timer on 1

capture ssc install table1
capture net install collin.pkg

use Stat_acm_cc, clear

//CRUDE RATES
tab indextype acm, row
//Generate person-years, incidence rate, and 95%CI as well as hazard ratio
label var indextype "Exposure"
stptime, by(indextype) per(1000)
**********************************************************MODEL DIAGNOSTICS SECTION*********************************************
**********************************************************Tesing the PH Assumption*************************************************
//generate the log log plot for PH assumption 
stphplot, by(indextype) saving(lnlnplot, replace)
graph export lnlnplot.pdf, replace

//non-zero slope for time-dependent covariates
stcox indextype_2 indextype_3 indextype_4 indextype_5 indextype_6 `mvmodel', cformat(%6.2f) pformat(%5.3f) sformat(%6.2f)  nolog noshow
estat phtest, rank detail
stcox i.indextype `mvmodel', schoenfeld(sch*) scaledsch(sca*)
stphtest, detail
***********************************************************Testing collinearity******************************************************
collin indextype_2 indextype_3 indextype_4 indextype_5 indextype_6 age_indexdate gender dmdur metoverlap bmicat1 bmicat3 bmicat4 bmicat5 bmicat6 bmicat7 smokingstatus1 smokingstatus2 smokingstatus4 drinkstatus1 drinkstatus2 drinkstatus4 a1ccat1 a1ccat3 a1ccat4 a1ccat5 a1ccat6 sbpcat1 sbpcat3 sbpcat4 sbpcat5 sbpcat6 sbpcat7 ckdcat2 ckdcat3 ckdcat4 ckdcat5 ckdcat6 mdvisits2 mdvisits3 ndrugs2 ndrugs3 cci2 cci3 mi_i stroke_i hf_i arr_i ang_i revasc_i htn_i afib_i pvd_i statin_i calchan_i betablock_i anticoag_oral_i antiplat_i ace_arb_renin_i diuretics_all_i *_post
************************************************************Goodness of Fit Tests*************************************************
stcox i.indextype `mvmodel', cformat(%6.2f) pformat(%5.3f) sformat(%6.2f) efron nolog noshow estimate
//cox-snell cumulative hazard slope should ~=1
predict cs, csnell
stset cs, fail(acm) 
sts gen H=na
line H cs cs, sort ytitle("Goodness of Fit") legend(cols(1))
**********************************************************Concordance*************************************************
quietly stcox indextype_2 indextype_3 indextype_4 indextype_5 indextype_6 `mvmodel', cformat(%6.2f) pformat(%5.3f) sformat(%6.2f) efron nolog noshow estimate
estat concordance

**********************************************************Functional Form Tests*************************************************
stcox i.indextype `mvmodel', cformat(%6.2f) pformat(%5.3f) sformat(%6.2f) efron nolog noshow estimate
predict mg, mgale
lowess mg `age_indexdate' //can repeat this for any non-factor variable you like
linktest, efron nolog estimate
**********************************************************Influential Outliers Tests*************************************************
stcox i.indextype `mvmodel', cformat(%6.2f) pformat(%5.3f) sformat(%6.2f)
predict dfb
scatter dfb _t, yline(0) mlabel(patid) msymbol(i)

stcox i.indextype `mvmodel', cformat(%6.2f) pformat(%5.3f) sformat(%6.2f) efron nolog noshow estimate
predict ld, ldisplace
scatter ld _t, yline(0) mlabel(patid) msymbol(i)

stcox i.indextype `mvmodel', cformat(%6.2f) pformat(%5.3f) sformat(%6.2f) efron nolog noshow estimate
predict lm, lmax
scatter lm _t, yline(0) mlabel(patid) msymbol(i)

timer off 1
log close
