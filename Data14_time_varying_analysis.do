//  program:    Data14_time_varying_analysis.do
//  task:		Generate longitudinal data for A1c and BMI to compare the mediating effect of time dependent
//				covariates in a stepwise time-varying Cox model.
//  project: 	Incretins--Comparative mortality and CV outcomes (CPRD)
//  author:     JM \ Sep2015


//Start with long form data

//Drop everything not needed in the analyses

//Expand and populate to generate the number of time samples wanted

//Generate c variable

//stset

//Generate c*time variable

//COMPLETE CASE ANALYSIS

//stcox i.indextype `mvmodel' ctime

//MULTIPLE IMPUTATION ANALYSIS

//insert MI code

//Re-generate c*time variable

//stcox i.indextype `mvmodel_mi' ctime
