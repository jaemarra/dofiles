//  program:    Data11b_checking.do
//  task:		Check .dta files generated in Data11_servicescovariates_b for data normality
//  project: 	Incretins--Comparative mortality and CV outcomes (CPRD)
//  author:     JM \ Jan2015


clear all
capture log close
set more off

timer clear 1
timer on 1

//DATA11_SERVICESCOVARIATES_B
//hes_serv
clear all
capture log close
log using hes_serv.smcl
use hes_serv.dta
compress
describe
mdesc
codebook, compact
log close

//hes_serv_s
clear all
capture log close
log using hes_serv_s.smcl
use hes_serv_s.dta
tab totservs_h_s
hist totservs_h_s,frequency
save graph Graph totservs_h_s_hes_serv_s.gph
hist prx_servvalue2_h_s,frequency
save graph Graph prx_servvalue2_h_s_hes_serv_s.gph
hist prx_servvalue3_h_s,frequency
save graph Graph prx_servvalue3_h_s_hes_serv_s.gph
hist prx_servvalue4_h_s,frequency
save graph Graph prx_servvalue4_h_s_hes_serv_s.gph
tab prx_serv2_h_s_b
tab prx_serv3_h_s_b
tab prx_serv4_h_s_b
compress
describe
mdesc
codebook, compact
log close

//hes_serv_c
clear all
capture log close
log using hes_serv_c.smcl
use hes_serv_c.dta, clear
tab totservs_h_c
hist totservs_h_c,frequency
save graph Graph totservs_h_c_hes_serv_c.gph
hist prx_servvalue2_h_c,frequency
save graph Graph prx_servvalue2_h_i_hes_serv_c.gph
hist prx_servvalue3_h_c,frequency
save graph Graph prx_servvalue3_h_i_hes_serv_c.gph
hist prx_servvalue4_h_c,frequency
save graph Graph prx_servvalue4_h_i_hes_serv_c.gph
tab prx_serv2_h_c_b
tab prx_serv3_h_c_b
tab prx_serv4_h_c_b
compress
describe
codebook, compact
mdesc
log close

//hes_serv_i
clear all
capture log close
log using hes_serv_i.smcl
use hes_serv_i.dta
tab totservs_h_i
hist totservs_h_i,frequency
save graph Graph totservs_h_i_hes_serv_i.gph
hist prx_servvalue2_h_i,frequency
save graph Graph prx_servvalue2_h_i_hes_serv_i.gph
hist prx_servvalue3_h_i,frequency
save graph Graph prx_servvalue3_h_i_hes_serv_i.gph
hist prx_servvalue4_h_i,frequency
save graph Graph prx_servvalue4_h_i_hes_serv_i.gph
tab prx_serv2_h_i_b
tab prx_serv3_h_i_b
tab prx_serv4_h_i_b
compress
describe
codebook, compact
log close

timer off 1


