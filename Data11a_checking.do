//  program:    Data11a_checking.do
//  task:		Check .dta files generated in Data11_servicescovariates_a for data normality
//  project: 	Incretins--Comparative mortality and CV outcomes (CPRD)
//  author:     JM \ Jan2015


clear all
capture log close
set more off

timer clear 1
timer on 1

//DATA11_SERVICESCOVARIATES_A
//Clin_Serv
clear all
capture log close
log using Clin_Serv.smcl
use Clin_Serv.dta
compress
describe
mdesc
codebook, compact
tab servtype
tab physician_visit_b
hist nr_data, frequency
save graph Graph nr_data_Clin_Serv.gph

log close

//Clin_Serv_i
clear all
capture log close
log using Clin_Serv_i.smcl
use Clin_Serv_i.dta
tab prx_servvalue_g_i 
hist serv_total_g_i,frequency
save graph Graph serv_total_g_i_Clin_Serv_i.gph
tab prx_serv_g_i_b
compress
describe
mdesc
codebook, compact
log close

//Clin_Serv_c
clear all
capture log close
log using Clin_Serv_c.smcl
use Clin_Serv_c.dta, clear
tab prx_servvalue_g_c 
hist serv_total_g_c,frequency
save graph Graph serv_total_g_c_Clin_Serv_c.gph
tab prx_serv_g_c_b
compress
describe
codebook, compact
mdesc
log close

//Clin_Serv_s
clear all
capture log close
log using Clin_Serv_s.smcl
use Clin_Serv_s.dta
tab prx_servvalue_g_s 
hist serv_total_g_s,frequency
save graph Graph serv_total_g_s_Clin_Serv_s.gph
tab prx_serv_g_s_b
compress
describe
codebook, compact
log close

timer off 1


