capture program drop charlsonread
program define charlsonread, byable(recall)
version 9.1
//modified: Jan2015 / JM
syntax [varlist] [if] [in], icd(string) ///
[idvar(varname) cmbprfx(string)  assign0 wtchrl cmorb noshow]
*Move all comorbidity variables to front of dataset
order `cmbprfx'*
marksample touse, novarlist
keep if `touse'
display "CHARLSON COMORBIDITY MACRO WITH ICD OR READ/OXMIS"
display "Providing Summary of CHARLSON INDEX � USING ICD or READ/OXMIS-`icd� DATA"
if "`show'" != "noshow" {
display "OPTIONS SELECTED: "
display "INPUT DATA:   ICD or READ/OXMIS-`icd'"
if "`idvar'" != "" {
	display "OBSERVATIONAL UNIT: Patients"
	}
	else {
		display "OBSERVATIONAL UNIT: Visits"
		}
display "ID VARIABLE NAME (Given only if Unit is Patients): `idvar'"
display "PREFIX of COMORBIDITY VARIABLES:  `cmbprfx'"
if "`assign0'"=="" {
      display "HIERARCHY METHOD APPLIED: NO"
      }
      else {
       display "HIERARCHY METHOD APPLIED: YES"
}
if "`wtchrl'"=="" {
      display "SUMMARIZE CHARLSON INDEX and WEIGHTS: NO"
      }
      else {
       display "SUMMARIZE CHARLSON INDEX and WEIGHTS: YES"
}
if "`cmorb'"=="" {
      display "SUMMARIZE INDIVIDUAL COMORBIDITIES: NO"
      }
      else {
       display "SUMMARIZE INDIVIDUAL COMORBIDITIES: YES"
}
}
set more off
capture drop ch1-ch17
capture drop ynch1-ynch17
capture drop weightch1-weightch17 wcharlsum charlindex

display "Please wait. Thank you!"

 forvalues i=1/17 {
    gen ch`i'=0
   }

 if "`cmbprfx'" != "" {
  	unab varlist: `cmbprfx'*
  	}	

  local ord = 1
  local n : word count `varlist'
  display "Program takes a few minutes - there are up to `n' ICD/READ `icd' codes per subject."
  while `ord' <= `n' {
     local cmb : word `ord' of `varlist'

 display "Iteration `ord' of `n' - Program is running - Please wait"

*Acute Myocardial Infarction
if "`icd'"=="9" {
	quietly replace ch1=1 if inlist(substr(`cmb',1,3), "410" , "412")
}
else if "`icd'"=="10" {
	quietly replace ch1=1 if inlist(substr(`cmb',1,3),"I21","I22") | inlist(substr(`cmb',1,4),"I252")
}
else if "`icd'"=="00" {
	quietly replace ch1=1 if regexm(`cmb', "(G301.00|G30z.00|G30..14|G30..15|G305.00|4109TC|G307.00|14AH.00|G30y.00|G303.00|4109NC|G30..00|G300.00|G32..12|G30X000|G30..13|G307100|G307000|G301100|G32..00|G30..17|G32..11|G30..12|429 AH|G30yz00|G302.00)")
}

*Congestive Heart Failure
if "`icd'"=="9" {
      quietly replace ch2=1 if inlist(substr(`cmb',1,3), "428")
}
else if "`icd'"=="10" {
	quietly replace ch2=1 if inlist(substr(`cmb',1,3),"I43","I50") | /*
*/ inlist(substr(`cmb',1,4),"I099", "I110", "I130", "I132","I255","I420", "I425", "I426", "I427") | /*
*/ inlist(substr(`cmb',1,4),"I428", "I429", "P290")
}
else if "`icd'"=="00" {
	quietly replace ch2=1 if regexm(`cmb', "(4271B|G58z.12|G580200|G232.00|4271H|4271|G58z.11|662W.00|7824FM|G554000|G580300|G580.12|8B29.00|4270C|G580.11|G582.00|14AM.00|G581000|SP11111|G580100|8CL3.00|425 CC|4271A|G581.00|4270|G58..00|7824AC|G580.00|14A6.00|7824BW|G58..11|1O1..00|402 C|G580000|4270R|8H2S.00|4270CC|G58z.00|4270D|7824FH)")
}
	
*Peripheral Vascular Disease
if "`icd'"=="9" {
	quietly replace ch3=1 if inlist(substr(`cmb',1,4), "4439","V434","7854") | /*
*/ inlist(substr(`cmb',1,3),"441")	
}
else if "`icd'"=="10" {
	quietly replace ch3=1 if inlist(substr(`cmb',1,3),"I70", "I71") | /*
*/ inlist(substr(`cmb',1,4),"I731","I738", "I739", "I771", "I790", "I792", "K551", "K558","K559") | /*
*/ inlist(substr(`cmb',1,4) ,"Z958", "Z959")
}
else if "`icd'"=="00" {
	quietly replace ch3=1 if regexm(`cmb', "(G714000|7A13411|R054.00|G715.00|14AE.00|G73..00|Gyu7100|G710.00|G73y.00|G731100|G713000|G715000|g71..00|R054200|G732000|4439A|G732.00|G716000|G732400|4459TE|7A13.11|7A11311|G73yz00|C107.12|4459FT|6075GM|R054300|2I16.00|G714100|G732100|G732200|R054z00|G73z000|G716.00|4410N|G73z011|7A11211|G712.00|G73..11|4459CR|G711.00|G73z.00|G73zz00|G71z.00|G713.00|7A14.11|4419|14NB.00|G71..00|G713.11|Gyu7200|G732300|R054000|G714.11|G714.00|Gyu7400|G718.00|7A14411|4439GD|4459N|4430G|G711.11)")
}

*Cerebrovascular Disease
if "`icd'"=="9" {
	quietly replace ch4=1 if inlist(substr(`cmb',1,3), "430", "431", "432", "433", "434", "435", "436","437", "438")
}
else if "`icd'"=="10" {
	quietly replace ch4=1 if inlist(substr(`cmb',1,3), "G45", "G46", "I60", "I61", "I62", "I63") | /*
*/ inlist(substr(`cmb',1,3),"I64","I65","I66", "I67", "I68", "I69") | /*
*/ inlist(substr(`cmb',1,4),"H340")
}
else if "`icd'"=="00" {
	quietly replace ch4=1 if regexm(`cmb', "(G6z..00|G62z.00|G613.00|G6...00|G67..00|G61X100|8520M|G63z.00|G60X.00|G606.00|S628.00|4380|G65z.00|G63..12|7004300|G67y.00|4319CE|Gyu6600|G68W.00|4309M|G63..00|G65zz00|G61z.00|G671.00|4389|G65y.00|F11x200|G677400|G60..00|Gyu6.00|4310|G61..11|G63y.00|G623.00|S621.00|G6y..00|G65..00|Gyu6700|G618.00|Gyu6500|1477|Gyu6D00|G603.00|G604.00|G681.00|Gyu6200|G602.00|G67z.00|G61X000|G61X.00|G671z00|G641000|Gyu6F00|G617.00|G680.00|4319CR|S627.00|G60z.00|8520A|4350|S62..12|G633.00|G61..12|G600.00|G601.00|G61..00|G605.00|G68..00|Gyu6100|S620.00|4300|Gyu6000|4309|G66..11|G660.00|662M.00|G669.00|G661.00|G66..00|G667.00|G66..13|G666.00|G663.00|G664.00|G665.00|G668.00|G66..12|14A7.00|G662.00|14A7.12|G64..13|4369B)")
}

*Dementia
if "`icd'"=="9" {
	quietly replace ch5=1 if inlist(substr(`cmb',1,3), "290")
}
else if "`icd'"=="10" {
	quietly replace ch5=1 if inlist(substr(`cmb',1,3),"F00", "F01", "F02", "F03", "G30") | /*
*/ inlist(substr(`cmb',1,4), "F051", "G311")
}
else if "`icd'"=="00" {
	quietly replace ch5=1 if regexm(`cmb', "(299 B|E001z00|E004200|Eu00z11|E001000|2930|Eu01z00|Eu02500|Eu00112|E004.11|Eu02z14|E041.00|Eu01111|Eu02z16|Eu00.00|794 D|Eu02z00|Eu00011|E004.00|Eu02.00|Eu01000|Eu01100|299 G|E000.00|E004z00|Eu02y00|E001.00|Eu00z00|Eu01y00|Eu01.11|Eu00113|E004000|E00..12|Eu00200|E00..11|E004300|E004100|2900|Eu00100|Eu01.00|2901A|Eu02z13|1461|Eu01200|e000.00|Eu00012|Eu00000|Eu01300)")
}
	
*Chronic Pulmonary Disease
if "`icd'"=="9" {
	quietly replace ch6=1 if inlist(substr(`cmb',1,3), "490","491","492","493","494","495","496","500","501") | /*
*/ inlist(substr(`cmb',1,3), "502", "503", "504", "505") | /*
*/ inlist(substr(`cmb',1,4), "5064")
}
else if "`icd'"=="10" {
     quietly replace ch6=1 if inlist(substr(`cmb',1,3),"J40", "J41", "J42", "J43", "J44", "J45", "J46", "J47") | /*
*/ inlist(substr(`cmb',1,3),"J60", "J61", "J62", "J63", "J64", "J65", "J66", "J67") | /*
*/ inlist(substr(`cmb',1,4),"I278", "I279", "J684", "J701", "J703")
}
else if "`icd'"=="00" {
     quietly replace ch6=1 if regexm(`cmb', "(Hyu4300|H35y500|H442.00|H33z011|H35zz00|H321.00|L5161B|493 AB|H35y600|663V100|H354.00|H352000|H32y.00|H420.00|493 NA|H33..00|H352.00|H310.00|H351.00|H330.14|493 GR|K3441B|H30..11|H312.00|663V300|H341.00|493|663v.00|493 EP|H31yz00|663V000|5192BY|H35y700|663V200|H34z.00|663s.00|492|H332.00|663N100|5161F|H355.00|H310z00|H33zz11|493 AA|H41z.00|490 T|663N000|663e.00|H42z.00|H464200|663h.00|663t.00|H330.13|H35..00|9OJA.11|H33z000|H3z..11|H33z.00|H32y100|493 JC|493 KB|H320.00|491 E|H322.00|H35z.00|491 BS|493 BG|493 GS|663|H353.00|H330.12|66YP.00|H32yz00|663f.00|H42..00|493 AI|H460.00|493 KA|493 HT|5151|H312z00|H32y200|493 BD|493 BI|173c.00|H31y.00|H33zz13|114 PF|H43z.00|H330111|H30..00|H4z..00|H41..00|9OJ1.00|H352100|H331.00|H331.11|1761|H31..00|491 AC|H350.00|466 D|H334.00|H582.00|H57yz00|491 R|H311.00|H31y100|H320200|663N.00|H310100|H4y1000|1O2..00|H464000|H331000|H33z200|H340.00|H410.00|H333.00|493 AC|493 BR|8H2P.00|H40..00|493 HR|691 TM|493 EB|14B4.00|H320z00|H310000|H313.00|H31z.00|H331z00|H434.00|H34..00|H312100|H352z00|H331100|H35yz00|H435.00|H33z111|H35y300|466 BC|h33z100|663r.00|H32z.00|H330z00|H33..11|H32y000|663q.00|H464100|Hyu4000|493 D|H330011|H43..00|493 EA|493 AJ|H423.00|518|H460z00|H330000|491|H35z100|491 BT|663u.00|493 AD|663P.00|H57y.00|5192CM|H311000|H581.00|5199CL|H45..00|H311z00|SK07.00|7832AB|Hyu4100|H300.00|663w.00|H440.00|H356.00|H30z.00|663p.00|1780|66YC.00|H432.00|H32..00|H312000|663W.00|490|H320000|6.63E+102|H312011|H441.00|H311100|H33zz12|L4930LO|493 A|H430.00|5152|H331111|H431.00|Hyu3000|H47y000|H35y.00|H330.00|173A.00)")
}

*Rheumatologic Disease (Connective Tissue Disease) - 
if "`icd'"=="9" {
	quietly replace ch7=1 if inlist(substr(`cmb',1,4), "7100", "7101", "7104", "7140", "7141", "7142") | /*
*/ inlist(substr(`cmb',1,3),"725") | /*
*/ inlist(substr(`cmb',1,5), "71481")
}
else if "`icd'"=="10" {
quietly replace ch7=1 if inlist(substr(`cmb',1,3),"M05", "M32", "M33", "M34", "M06") | /*
*/ inlist(substr(`cmb',1,4),"M315", "M351", "M353", "M360")
}
else if "`icd'"=="00" {
quietly replace ch7=1 if regexm(`cmb', "(7341AA|N041.00|718|7179FN|7123|Nyu1000|N001200|N04y011|7124A|N001000|N001.12|N040B00|N000300|N04y012|N047.00|N000.00|N040J00|7341AD|N04X.00|Nyu1G00|N040A00|N040300|N240000|N240200|L 151F|N200.00|N20..00|7340C|N040900|N000100|2A42.00|N000400|N040M00|N040800|N2y..00|H572.00|N04..00|N040P00|7179GA|G5yA.00|7340BC|H57y400|K01x411|N001.11|7161|7123CR|N000000|N040T00|N040.00|N04y111|Nyu4500|L 151E|N240z00|7121|718 AH|N040L00|N231400|7340A|Nyu1200|715 MR|F396600|F396400|N042100|N040G00|7341CL|N040200|N040H00|N040D00|718 BH|N040F00|N060.11|Nyu4300|Nyu1100|7179GB|N004.00|H57y100|N040E00|N040600|N240.00|N040C00|F396100|7341|7340D|N040K00|N001.00|N2z..00|7179PR|N040500|N000200|K01x400|H570.00|N000z00|N040700|N240700|7179G|N040400|N04y000|7340BA|7341AC|F371200|6954|7149A)")
}

*Peptic Ulcer Disease
if "`icd'"=="9" {
quietly replace ch8=1 if inlist(substr(`cmb',1,3), "531", "532", "533", "534") 
}
else if "`icd'"=="10" {
     quietly replace ch8=1 if inlist(substr(`cmb',1,3),"K25","K26", "K27","K28") 
}
else if "`icd'"=="00" {
     quietly replace ch8=1 if regexm(`cmb', "(J120y00|761D600|J14y400|J13..00|5310TM|J102000|5349GJ|J12yz00|K424|J11..12|5310|J141200|J110.00|J12y.00|J121y00|J110111|J11yy00|5329|J111y00|J111100|J14..15|J131y00|J110y00|J13z.00|J11..11|J110300|761Jz00|J14y100|J121400|J130z00|J12y400|J11y100|J140400|J12y000|J122.00|J121000|J14y200|J11..00|J141y00|5340GJ|J141300|J11y400|J13y.00|J131.00|J120z00|J140000|J110200|J111400|J121.00|J14yy00|J14..12|J130.00|J11y200|J120300|5329PT|7627|J120100|5320PT|J13y300|J14y300|5310PT|J131300|J111111|761J000|J120200|J130200|761J111|J140100|J12y200|J111z00|5329BD|J11yz00|J14z.00|J14y000|J11z.00|J14y.00|J141z00|J13yy00|7612111|J12yy00|J111000|J110000|J130000|5330|J111300|J140300|J13y000|J14..00|J11y.00|1956|J120.00|J130400|J141400|J13y100|J120000|J121300|7627000|J131z00|J13..11|J130y00|J112.00|J110z00|J111.00|J110400|J121z00|5339|J131000|J12..00|J141.00|J11y000|J111200|J123.00|K4271|J13y400|761J100|J131400|5349MR|J11z.12|J14yz00|ZV12711|J130100|7612500|J120400|ZV12C00|5319PT|J12y300|J13yz00|761J.11|5320|J111211|J12z.00|J140200|J131100|J141000|J131200|J124.00|K458 PT|J130300|J11y300|J141100|J121111|5319PP|761Jy00|J140z00|J140y00|J13y200|J110100|5319TM|5339DB|761J.00|J140.00)")
}

*Mild Liver Disease 
if "`icd'"=="9" {
	quietly replace ch9=1 if inlist(substr(`cmb',1,4),"5712", "5714","5715","5716") | /*
*/ inlist(substr(`cmb',1,5),"57140", "57141", "57149") 
}
else if "`icd'"=="10" {
     quietly replace ch9=1 if inlist(substr(`cmb',1,3), "B18",  "K73",  "K74") | /* 
*/ inlist(substr(`cmb',1,4),"K700", "K701", "K702", "K703", "K709", "K713", "K714", "K715", "K717") | /*
*/ inlist(substr(`cmb',1,4),"K760", "K762", "K763", "K764", "K768", "K769", "Z944") 
}
else if "`icd'"=="00" {
	quietly replace ch9=1 if regexm(`cmb', "(J616100|J615400|J616z00|J614.00|J614y00|J615100|J635600|C350012|J615z14|5719HP|J617000|J615z11|J614100|J615000|5719CH|5719CB|J615y00|J615z00|J612.00|J615A00|J615.11|J615300|5719PB|5730CA|5719CL|5710MC|J615C00|J615z13|J614300|Jyu7100|J61..00|J615F00|C310400|5710CA|J615z12|J616000|J616.00|J615.00|J633.00|J615700|J614000|J600200|J615B00|5719MA|070 G|J61y300|J614200|J601200|J615111|J612.11|J614z00)")
}
	
*Diabetes without complications
if "`icd'"=="9" {
	quietly replace ch10=1 if inlist(substr(`cmb',1,4), "2500", "2501", "2502", "2503", "2507")
}
else if "`icd'"=="10" {
	quietly replace ch10=1 if inlist(substr(`cmb',1,4),"E100", "E101", "E106", "E108", "E109") | /*
*/ inlist(substr(`cmb',1,4),"E110", "E111", "E116", "E118", "E119", "E120", "E121", "E126", "E128") | /*
*/ inlist(substr(`cmb',1,4),"E129","E130", "E131", "E136", "E138", "E139", "E140", "E141") | /*
*/ inlist(substr(`cmb',1,4),"E146", "E148", "E149")
}
else if "`icd'"=="00" {
	quietly replace ch10=1 if regexm(`cmb', "(66AJ.11|C108600|C101100|C10M.00|C103000|C109500|C109900|C109412|C10FG00|C109.11|C109G11|C10z.00|C10EM11|C107200|250 GA|C10FJ00|C108911|C102z00|250 HC|250 AK|G73y000|250 E|66AJ.00|C109J12|C109F12|C109300|C108400|C10F900|C10y.00|C10F.11|C10FL00|250 NT|C109G00|C109G12|66A5.00|C109511|L180600|250 PR|C10FN00|C10E400|C10zy00|C10D.00|C107z00|C10EN00|250 CT|C101000|C100011|250 JA|C108411|250 A|C103.00|C107.11|250 JL|250 AN|C10E500|C109400|C10yy00|250 AB|C109711|C10A000|C10F.00|C109J11|8A13.00|C108.00|C10EG00|C108E12|C108.13|C107100|C10A100|C102000|250 AT|C109411|C10F500|250 JK|C102100|C108E11|C109K00|250 G|66AJz00|C10FJ11|C108500|C109J00|C10E800|C108812|C107400|C10G.00|C10EM00|66AV.00|L180500|C10FP00|C100.00|C10E600|C109D12|C10FF00|C108.12|C109.00|C109D00|C10zz00|C10EE00|66AS.00|C107000|C10E412|C10E900|C101y00|C10FL11|250 DR|250 NH|250 DC|C109712|Cyu2.00|C10..00|C10EA00|C100z00|C103z00|C108G00|C108E00|C101.00|C10E812|C10F700|66AK.00|C10B000|C100111|C10E.00|8H2J.00|2500AH|1434|C108811|C10E.12|C100100|C10F400|C10z100|L180X00|8BL2.00|C10yz00|C102.00|C10A.00|C108.11|C101z00|C10FD00|C108800|250 HP|C10EK00|250 AD|C10H.00|C107.00|C10D.11|C107300|C109F11|C109D11|C10EL00|C100112|C10FM00|Cyu2000|C109.12|C103y00|C109.13|C108511|C10EN11|C109700|250 H|C10y100|C10E.11|C10N.00|C10F711|66AI.00|C100000)")
}
	
*Diabetes with chronic complications
if "`icd'"=="9" {
	quietly replace ch11=1 if inlist(substr(`cmb',1,4), "2504", "2505", "2506") 
}
else if "`icd'"=="10" {
	quietly replace ch11=1 if inlist(substr(`cmb',1,4),"E102","E103", "E104", "E105", "E107", "E112") | /*
*/ inlist(substr(`cmb',1,4),"E113" , "E114", "E115", "E117", "E122", "E123", "E124", "E125") | /*
*/ inlist(substr(`cmb',1,4), "E127","E132", "E133", "E134", "E135", "E137", "E142") | /*
*/ inlist(substr(`cmb',1,4), "E143", "E144", "E145", "E147")
}
else if "`icd'"=="00" {
	quietly replace ch11=1 if regexm(`cmb', "(F464000|C109212|C104000|C109111|2BBP.00|C108C11|C108H00|C109C00|C108B00|C106100|C108000|C109H00|C108200|C10F100|2BBQ.00|C109011|F420200|C105000|C10FR00|C109100|250 F|C10FE00|C108712|C106.13|F420.00|C109612|C109B00|F420600|C105y00|C109E11|C10FB00|C10FA00|C10F611|C10E200|C108B11|C109600|F381300|C106z00|C104y00|2BBV.00|C108711|F420400|250 LG|C109C12|C106.11|K01x111|C108D00|C108212|C108100|F3y0.00|F372.12|F420300|C10F011|2BBl.00|C10FC00|C10EF00|C109E12|C108D11|C109B11|C10F200|C10EB00|C109H12|F420800|C108700|C10EC00|250 M|F374z00|C109112|250 N|2BBL.00|C109012|C109000|C109200|F420700|C106.12|2BBS.00|C109E00|C10F600|C108C00|C108211|C10E000|C109H11|C106.00|C109611|F372.11|2BBk.00|F420z00|C105z00|C105100|C10ED00|C108F11|C108011|C10FC11|C108012|C109A11|F381311|C109C11|C10EQ00|C109A00|C108F00|C104.11|2BBR.00|C108J12|C10FB11|C106y00|250 LK|C10FH00|C10F000|C105.00|F420100|C109211|C104z00|C10E100)")
}

*Hemiplegia or Paraplegia
if "`icd'"=="9" {
     quietly replace ch12=1 if inlist(substr(`cmb',1,3), "342") | /*
*/ inlist(substr(`cmb',1,4), "3441") 
}
else if "`icd'"=="10" {
   quietly replace ch12=1 if inlist(substr(`cmb',1,3),"G81", "G82") | /*
*/  inlist(substr(`cmb',1,4), "G041", "G114", "G801", "G802", "G830", "G831", "G832", "G833", "G834") | /*
*/  inlist(substr(`cmb',1,4), "G839")
}
else if "`icd'"=="00" {
   quietly replace ch12=1 if regexm(`cmb', "(F241000|343 PR|F222.00|2835|4360HP|344 G|F22z.00|F230000|2833|344 BF|344 BL|F221.00|F223.00|F230.11|F241100|4380HP|F241.00|344 B|F141.00|344 BR|F220.00|F22..00|344 SH)")
}
   
*Renal Disease
if "`icd'"=="9" {
     quietly replace ch13=1 if inlist(substr(`cmb',1,4),"5830","5831","5832","5834","5836","5837") | /*
*/ inlist(substr(`cmb',1,3),"582", "585", "586", "588")
}
else if "`icd'"=="10" {
     quietly replace ch13=1 if inlist(substr(`cmb',1,3), "N18", "N19") | /*
*/ inlist(substr(`cmb',1,4), "N052", "N053", "N054", "N055", "N056", "N057", "N250") | /*
*/ inlist(substr(`cmb',1,4), "I120", "I131", "N032", "N033", "N034", "N035", "N036", "N037") | /*
*/ inlist(substr(`cmb',1,4), "Z490", "Z491", "Z492", "Z940", "Z992")
}
else if "`icd'"=="00" {
     quietly replace ch13=1 if regexm(`cmb', "(5932MN|K080000|K032z00|K080100|583 MA|K04z.00|5930AR|K101100|K02z.00|K060.11|K021.00|K023.00|5932A|583 MP|K032y00|1Z11.00|583 A|K041.00|K032y13|583 GC|K0...00|K02..12|K08yz00|5930A|583 MN|K081.00|K080.00|K0A3400|K06..00|K0A3200|K034.00|K02y200|5932EC|7598A|K03..00|K05..00|K0A5500|K101000|K02..00|K080300|5930R|5932KH|1Z13.00|K032.00|K012.00|K0A3300|1Z14.00|Kyu2.00|K08z.00|K050.00|5932E|K100000|K04y.00|14D1.00|K02..11|1Z10.00|K032000|582 N|K03..11|K042.00|K022.00|K032y14|K080200|K001.00|1Z12.00|K02yz00|K02y300|K080z00|K019.00|K035.00|K0A3700|K08y000|Kyu2100|K0A3500|K02y000|K100100|Kyu2000)")
}
	 
*Cancer
if "`icd'"=="9" {
   quietly replace ch14=1 if (substr(`cmb',1,3)>="140" & substr(`cmb',1,3)<="172") |     /* 
*/ (substr(`cmb',1,3)>="174" & substr(`cmb',1,3)<="195") |  /*
*/ (substr(`cmb',1,3)>="200" & substr(`cmb',1,3)<="208")
}
else if "`icd'"=="10" {
   quietly replace ch14=1 if inlist(substr(`cmb',1,3), "C00", "C01", "C02", "C03", "C04", "C05", "C06", "C07") | /* 
*/ inlist(substr(`cmb',1,3),"C08", "C09", "C10", "C11", "C12", "C13", "C14") | /*
*/ inlist(substr(`cmb',1,3),"C15", "C16", "C17", "C18", "C19" ) | /*
*/ inlist(substr(`cmb',1,3),"C20", "C21", "C22", "C23", "C24", "C25", "C26" ) | /*
*/ inlist(substr(`cmb',1,3),"C30", "C31", "C32", "C33", "C34", "C37", "C38", "C39" ) | /*
*/ inlist(substr(`cmb',1,3),"C40", "C41", "C43", "C45", "C46", "C47", "C48", "C49", "C50") | /*
*/ inlist(substr(`cmb',1,3),"C51", "C52", "C53", "C54", "C55", "C56", "C57", "C58", "C60") | /*
*/ inlist(substr(`cmb',1,3),"C61", "C62", "C63", "C64", "C65", "C66", "C67", "C68", "C69") | /*
*/ inlist(substr(`cmb',1,3),"C70", "C71", "C72", "C73", "C74", "C75", "C76") | /*
*/ inlist(substr(`cmb',1,3),"C81", "C82", "C83", "C84", "C85", "C88") | /*
*/ inlist(substr(`cmb',1,3),"C90", "C91", "C92", "C93", "C94", "C95", "C96", "C97")
}
else if "`icd'"=="00" {
	quietly replace ch14=1 if regexm(`cmb', "(B072.00|B18y100|B173.00|B337100|B335.00|B614500|B63..00|B001.00|B04y.00|B072100|B072000|B612600|B626400|2022CL|B305700|B49..00|B430300|B627C11|Byu3300|B03z.00|B340z00|B627D00|B332000|1579A|1719LM|1890HM|B600700|B062100|B600300|1726AN|1719RB|B000.00|1538B|ZV10511|B41z.00|149 CT|B4A1z00|B304400|B00y.00|B51y100|Byu1200|1621D|B07z.00|B242.00|185 CA|B333z00|B42..00|B471100|B4A3.00|2104EP|B626500|B616000|B02z.00|B315300|B308.00|B675.00|Byu4.00|Byu9.00|B62x000|B17y000|B141.12|B132.00|B330.00|B627500|1739CS|1700AM|B630.00|B62x200|B502.00|B62x400|ZV10y11|B305000|B11..00|B222100|B106.00|ByuD.00|B544.00|B066.00|B62..00|Byu5400|B101.00|Byu1000|1899A|B66y000|B68y.00|B326.00|B203.00|ZV10400|B610600|B313.00|B31z000|1709B|B041.00|2072AE|B615100|201 MH|B114.00|B620.11|Byu5A00|B3...11|B613.00|B610200|B490.00|ZV10112|B523z00|B615000|B310200|1619C|B220.00|B336z00|B213200|B339.00|B180200|1719|B651000|B441.00|B231.00|B004100|1959AD|B308900|B337z00|1602A|Byu5100|B240.00|B62y500|B30z.00|B161.00|1991C|B322z00|B311100|188 RH|B204.00|B325200|B24y.00|B308.11|B303.00|2001BL|B225.00|B327100|B1z1100|B620300|B602.00|B224z00|1589MP|B622100|B163.00|B161200|1709A|B515.00|B102.00|B312200|B454.00|B080.00|B03y.00|B013000|B327000|174 PN|B064.00|B013.00|ZV10018|2040|B300000|B6z..00|1991A|174 C|2051GR|B51yz00|B624z00|B412.00|B201000|2061|2050|B10z.00|203 FR|ZV10y00|B011z00|B103.00|1929MN|B310.00|1829A|2070BM|201|B334100|B61z.00|B333100|1528LA|B310000|1830AU|B612800|B523200|1710AC|B300700|B33y.00|B653z00|B325600|B601800|B111.00|1579C|B22z.11|B18y400|B521200|B180000|B641.00|2020BR|B072z00|B....11|2062|B34y000|B224.00|B304000|B315100|B12..00|B311200|2022BK|B622600|B626z00|B611200|B550300|B6y0.11|B306.00|149 AT)") | /*
*/ regexm(`cmb', "( B69..00|2049|B613100|B616100|B624.00|B410z00|2020FB|1529A|B524W00|B30W.00|B327300|B620600|B326100|B68..00|B482.00|B327900|B151000|B67y000|B500100|B327.00|B60..00|1959DC|B24..00|B627700|B45X.00|B601600|B601500|B510300|B21..00|B430211|B014.00|B326400|B62z700|186 TA|186 AN|186 RC|B337400|ZV10414|1450A|B200100|B201.00|B205.00|B21y.00|B220100|B612100|B335200|B325100|B631.00|B305100|B500200|B67yz00|ByuD200|2029AL|1929GL|B41..00|B160.11|B331000|B323000|B4...00|B302100|B30X.00|B322000|1929AC|B61..00|B471.00|B500000|ByuDF00|B62y.00|B523100|B626300|1621CB|B54X.00|B54y.00|B18..00|1870A|B30..11|2060|B150200|2049AT|B31..00|B650.00|B661.00|B306500|B200z00|B615200|B18z.00|B621300|B52..00|2059MR|B55y000|B304.00|B62z200|B55y100|B1z..00|2072EL|B524300|B1z1.00|B55y200|B55z.00|1459A|Byu5011|B303100|B34..00|208 BL|B070.00|1519A|1520A|B680.00|B51z.00|1569A|B232.00|150 C|B302z00|B11..11|1619CV|B510000|Byu7200|B308100|B20y.00|B662.00|B62y300|B314100|Byu5800|B344.00|B524600|1562A|B30..12|B33..12|B550200|1929A|B337000|B133.00|1711AH|ZV10214|Byu2.00|B454.11|159 C|B350z00|1959BE|B2...11|B06z.00|1409A|B52y.00|B41y000|1703A|B064100|B222.00|1736AB|B610700|1561A|B630200|B52z.00|2069|B001000|2059NT|1739B|B150000|1620A|1959AC|B222z00|B512100|B601200|B602600|B....00|B000000|Byu4000|B524000|B550.00|B34y.00|B308C00|B040.00|1539C|B303000|B065.00|B430z00|B003.00|B137.00|ZV10y14|B625700|1959AF|B300600|1830A|B241.00|B62y100|B61z400|B510100|B506.00|ByuD700|B540z00|Byu2200|B410000|B691.00|B326000|B49y.00|B630300|B612000|1841AN|B313300|B308700|B616.00|B41..11|B430.00|B483.00|1991MT|B200000|B307z00|B17yz00|159|B323100|B05..00|1890BL|B513.00|1991MR|144 C|By...00|193 C|B507.00|1830C|B616z00|B311300|B305z00)") | /*
*/ regexm(`cmb', "(Byu3200|B010.00|B602200|B0z..00|B134.11|B030.00|B621500|B071.00|1419A|B625200|B625300|188 A|B625.00|B113.00|B501.00|B213000|B62x100|1719A|B322.00|Byu0.00|B316.00|B06y.00|B3...00|B510400|ByuD900|1991NC|B141.00|B63z.00|B545z00|B073000|B306z00|B18y700|B326z00|B6y1.00|B611600|B41y100|186 EM|B62x.00|1700A|B4z..00|B333500|ZV10411|B004300|1731AC|1992L|B600000|B651.11|B150z00|1429B|1899T|B326300|ZV10713|B496.00|1419AA|B337.00|B43..00|B626200|B0zz.00|B345.00|ByuA100|1618A|1878C|B2z..00|2059MP|1959CA|B337600|B313z00|1709C|B44z.00|186 CH|1929D|Byu5200|B64y100|149 A|ByuDE00|B622.00|B180100|B410.00|B325700|1631A|B16y.00|1709D|186 T|1959CF|1530CC|B615500|B241100|B004z00|B02y.00|1429C|B201z00|B616200|B335100|B005.00|B517200|B0z1.00|B600100|B492.00|B161z00|B5...00|1959CD|B61z000|B2...00|2029LD|B622z00|B335400|B4A1000|Byu2400|B411.00|ByuA.00|ByuDD00|B315000|B495.00|B340100|1610A|B542000|B333000|B010z00|208 CE|B324100|B65y100|B314z00|B500z00|B312400|B311000|B340.00|B00zz00|B241000|B241300|ZV10416|185 A|B630.12|186 BL|B350.00|B690.00|B181.00|B508.00|1892C|1890R|B486.00|B62y600|B554.00|B150.00|B524X00|B443.00|B342.00|B213100|B620800|B337300|2079ED|B551200|B311500|B613300|Byu2300|ByuE.00|B410100|Byu6.00|B660.00|B311z00|B624300|B305.11|B620000|B621100|B621400|B00z100|2050DR|1729B|B622700|B230.00|B10z.11|B62zz00|B224100|ZV10000|150 B|B504.00|Byu5.00|B653000|B334000|B66..00|2059E|B622500|1959AG|B22y.00|1719RH|180 A|B540.11|B440.00|1538AN|ZV10714|B307100|B612.00|B613z00|1991M|2070|B55y.00|B420.00|B331200|1736AM|B62z600|1510A|B300C00|B4A1.00|ByuDC00|B625600|B5...11|B110.00|B553z00|B221100|B550z00|B517z00|B33z.00|186 C|2050MM|ByuDA00|B6...00|B672.00|B67..00|B142000|B521000|Byu2500|B337200)") | /*
*/ regexm(`cmb', "(203 KA|B612400|B211.00|1419C|B337500|B333300|B17z.00|B524400|B011000|B501100|B073z00|B06yz00|B64y000|B062200|B553.00|B327500|B622000|2070BL|B32y000|B47z.00|B517100|203 A|B337700|1621A|2070MA|B500300|B32z.00|B4A..00|B615600|B623100|1739C|B514.00|150 A|B515100|B315200|Byu5000|B325500|1541C|B524.00|190 B|B315z00|B517.00|B303400|B524100|1879A|2059M|B627400|B323.00|1943A|B450000|B444.00|B3y..00|B30..00|B45y000|B175.00|1542C|B174.00|B4Az.00|B335000|B056.00|B452.00|B03..00|B18y600|B627600|1439A|1702P|ZV10700|B305.12|B336200|B611z00|ZV10y16|B62z.00|203|B140.00|B681.00|1533AD|ZV10011|B341.00|B0zy.00|B300z00|1550AP|B431z00|B062z00|B004000|1891C|B4A2.00|B310z00|B003100|B223100|B182.00|B305600|1530AD|1601AM|B651z00|B003300|B002200|B060000|B521.00|B00z.00|B431.00|ZV10012|ByuE000|B470000|1550BP|B304300|B11y000|B600400|B117.00|B305800|B611000|B212.00|B100.00|B62y400|B430000|B507100|B612500|B61zz00|2022GR|B303200|B601700|B66z.00|B180.00|B60z.00|B50z.00|B620500|1890NR|B600.00|B516.00|B523.00|B001z00|Byu1100|B1...11|B52W.00|B616800|2029CH|1942A|B49y000|B067.00|B621z00|1731AL|B624400|B4y..00|1890MB|B65z.00|B110100|B302.00|1551A|208 RV|B011100|B334z00|B011.00|B64y200|ByuD300|1959DF|B337800|B610800|2059MC|B23y.00|B346.00|B17..00|B1z2.00|1579CL|B063.00|B623300|B313100|B303500|1878|B64..00|B150100|B49z.00|B48..00|B682.00|B450100|B602800|B620400|B302200|B62y000|B347.00|1539A|B22z.00|2022LK|B625000|B323300|193 A|2051MC|B060100|1519DA|B223000|2079PC|B471000|B615800|188 TC|B17y.00|B213.00|B062300|B68z.00|B610400|B18y000|B61z300|ZV10712|B002300|B1zy.00|B442.00|B042.00|Byu1.00|1420A|1520B|B12z.00|B21z.00|174 DL|B517000|1890AD|B08..00|B111100|B317.00|B13z.00|B10..00|B301.00|B335500|B306100|B335A00)") | /*
*/ regexm(`cmb', "(B325800|B327800|1542A|B623600|Byu4300|ZV10y13|B304200|B04z.00|ZV10111|B550400|B551000|B670.11|B620.00|B61z600|B66..12|B652.00|B63y.00|B630000|B11z.00|B48z.00|B540.00|B312100|B626100|1538C|B305D00|B223z00|1830MC|B623700|1959DE|1925GN|B0...11|2104CM|174 DC|2072DG|B222000|B327z00|2020|1551C|B55yz00|B013100|Byu7300|1959AB|B023.00|B310500|Byu5600|ByuD000|B552.00|B520z00|B082.00|B625.11|B312000|B501000|B201200|B241400|2072MA|ByuC000|1959BB|1550A|B67z.00|B18y.00|B620z00|B327200|B53..00|2059MB|1709AK|B545200|B65yz00|B431000|ByuDF11|B337900|B308600|Byu2100|B62x300|ZV10100|B000100|B611700|B061.00|Byu8.00|B335700|1701A|Byu9000|1959AE|188 CT|B65y000|1736CN|1830TT|B01z.00|1829C|B33z000|B41y.00|186 NT|B43z.00|B517300|2071|B201100|B20..00|B143.00|B623z00|1729L|1959DA|B14..00|B520100|209 HM|B485.00|B510500|B540000|B314000|B308D00|1735C|B48y200|B050.11|B003z00|B612300|ZV10513|B450z00|B62z000|B020.00|B67y.00|B000z00|B622800|B01y.00|1991MC|B64y.00|1560A|B055000|B051.00|B614100|B004200|B05z.00|2050PM|B497.00|B073.00|B670.00|B24X.00|B45z.00|1529B|B221000|1739A|B138.00|B451.00|B512000|B620100|B310300|B002000|B430200|B002z00|1959BD|203 T|B161000|B062.00|ZV10200|B24z.00|1899C|B307000|B308200|B308A00|B022.00|B32..00|208 HC|B627200|1550B|B600600|188 RC|1600A|B630.11|B335z00|2020FR|B111000|1733AC|1541A|B35z000|B055z00|B11y100|B300200|B50..00|B123.00|1950|B50y.00|B071z00|B625500|B51y200|B054.00|B120.00|B553000|ZV10.00|B23z.00|ZV10016|B602300|B54..00|B22..00|B61z500|B51..00|B600200|B35..00|B602000|Byu8100|2059BA|B071000|Byu4100|ZV10412|B621.00|B62z100|1450C|B25..00|ZV10017|B623000|185 C|B6y..00|B627300|B308000|1830AD|174 CI|B610100|ZV10500|2070MM|B51y000|B523000|B310100|B051100|1959CB|B327400)") | /*
*/ regexm(`cmb', "(190 A|B555.00|B35zz00|B326500|B1zz.00|B332.00|ZV10019|2070MG|1719AC|B335900|Byu1300|B013z00|1735CP|B601400|B323500|B51..11|B226.00|1723C|B0...00|B26..00|1550BH|B220z00|B62z500|B616400|B611.00|B16..00|B553100|1719FB|B332z00|1621AB|B333200|B2z0.00|B501z00|B300500|1560C|B521z00|2104DN|B624200|B305.00|B315.00|1739CM|1608CM|B615300|B200300|ZV10417|B060.00|B627C00|B136.00|B221.00|1538A|B615400|B00..00|B003000|B671.11|203 N|B303z00|B131.00|Byu5700|B010000|1519AA|1959BA|1608A|B305400|B141.11|Byu3.00|B060z00|B336500|B300.00|B625400|209 CL|B624800|1733AF|B626800|Byu3100|B006.00|ZV10413|ZV10113|ZV10014|B62x500|B470z00|ByuD600|1409C|B616700|B306200|1519CL|B613800|159 CD|B520200|B621800|2020BB|1736AN|B62z800|174 PB|B622300|193 AG|B18yz00|B626.00|B324000|B621000|B121.00|B1z1000|B480.00|203 HC|B332100|B601.00|B65..00|B170.00|193 TD|B325000|B02..00|B051300|B307.00|ZV10600|B124.00|1538CN|B611800|B614800|B62z400|ZV10212|B45y.00|1621C|B007.00|B512z00|B310400|203 PL|B13z.11|B623800|Byu7100|B051200|1619A|B430100|B610500|B223.00|B545100|B08z.00|B152.00|B1...00|B323400|B615z00|B613200|1959DD|B322100|B321.00|B651200|Byu..00|1609A|Byu2000|B6y1.11|B626000|B215.00|B0z0.00|ByuD800|B671.00|B624100|B541.00|B545.00|1929DG|ZV10613|B470200|B626600|ByuA000|B6z0.00|B674.00|B614400|208 VA|B312z00|B06y000|B602400|B494.00|2001WD|B335600|B45..00|B336300|B470300|B3...12|B62y700|B134.00|B510200|ZV10512|B615.00|Byu5500|B48y.00|B051000|B062000|B503.00|ByuD400|B610.00|Byu5900|B220000|B305300|B54z.00|191 A|B13y.00|B450.00|B40..00|B001100|B51y.00|B545000|B312300|1922A|1639MA|B12y.00|B602z00|B160.00|B520000|2051|B13..00|2102MP|B542.00|B335300|B52X.00|B333.00|B110111|B306300|B481.00|B61z800|B62y200|1820C|B507z00|B612z00|201 ML)") | /*
*/ regexm(`cmb', "(B18y500|B602700|159 A|B614z00|B073100|B616500|B334.00|B620700|B61z700|203 HG|B64yz00|B612700|B551z00|B610300|ZV10211|B180z00|1601A|188 C|1734AC|186 A|B304100|B627W00|B081.00|B512.00|B064z00|B213300|ZV10612|B627100|1550C|B084.00|B491.00|B522.00|B312600|B308800|B308z00|B309.00|B313000|B18y300|B47z.12|2079|B62xX00|B303300|B451000|2041|2022|1739BP|B620200|1719B|208|1533A|B627000|B331.00|B33..15|B327700|186 B|B304z00|1729|1723A|Byu8200|B610z00|B055100|B600z00|B336400|Byu7000|B105.00|1519C|B470.00|B616600|B66y.00|B11yz00|B23..00|B602500|B060200|B4Ay.00|B614300|B004.00|B511.00|B336000|B61z100|B221z00|B43y.00|1959DB|B00..11|B33..14|B305C00|B614.00|1630A|1849A|1841C|B172.00|174 A|B59zX00|2022ML|191 BC|B150300|B611100|B621600|B015.00|B213z00|B04..00|B331100|B30z000|2022AF|B6y0.00|B624500|2079AL|B012.00|B305A00|1841A|B33..00|ByuA200|B640.00|1925NB|B62z300|1991AD|1959CE|B614000|B010.11|B48yz00|B510z00|B053.00|B311.00|B083.00|B550100|ZV10013|B135.00|B487.00|B151z00|B65y.00|1562C|B64..11|B151300|B01..00|1892A|186 TM|B074.00|B110z00|1530AC|181 C|B326200|1959BC|B308300|B122.00|B064000|2102A|B017.00|B2zz.00|ZV10300|B651.00|B300400|2049AD|B32y.00|1719F|B44y.00|203 HA|B10y.00|B46..00|B00z000|2104AD|B210.00|B162.00|B206.00|B110000|B11y.00|147 A|B306400|B325z00|B300100|B300300|1550HB|ZV10711|B142.11|B305500|1830T|1924NF|B308400|1890C|B551.00|B4...11|B500.00|B314.00|1529C|B335800|B642.00|B312500|B305900|B325400|B484.00|B48y100|B60y.00|B624700|B142.00|B300A00|Byu4200|1929EP|B336100|ZV10015|B47..00|B611400|1940A|B4A4.00|B515z00|B332200|B540100|B300900|B325.00|B1z0.00|1735A|B161300|2079MK|2070MC|B002100|B621700|174 AN|B542z00|Bz...00|B151100|B601300|B112.00|B507000|B623500)") | /*
*/ regexm(`cmb', "(1950MA|201 G|B2zy.00|B055.00|B630100|1538AD|B672.11|B016.00|B002.00|B613000|2022LE|B350100|B622200|B115.00|B505.00|B130.00|B692.00|B1z0.11|B601100|B493.00|B6...11|B62yz00|B641.11|B243.00|1960AC|B625800|B33X.00|B161211|B613700|B623400|B612200|Byu7.00|B1z1z00|B673.00|B4A0000|ByuD100|B453.00|B47z.11|B623200|B15z.00|B627.00|B07y.00|1468A|B600500|B470100|B611500|B520.00|B14z.00|B151400|191 MB|149 C|B16z.00|B241200|ByuA300|B057.00|1719H|B302000|B524200|ZV10611|B051z00|B050.00|B161100|1890A|B66yz00|B325300|B336.00|ByuD500|B116.00|B41yz00|B003200|B4A1100|B510.00|B151.00|B200.00|B104.00|B111z00|1709AC|B553200|B241z00|1820A|B440.11|B34z.00|B542100|Byu3000|B622400|B625z00|1959CC|B3z..00|B515000|1459C|B653.00|B222.11|209|B62x600|1561C|B616300|B600800|B624.11|B4A0.00|1480C|B07..00|B601000|B615700|180 C|B324z00|1601AC|B601z00|B653100|Byu5300|ZV10415|B05z000|B61z200|2020FL|B307200|B627X00|ZV10y12|1529BL|B621200|2001|B300800|2050RA|1732AC|B214.00|1890W|B200200|B306000|1719M|1550HC|B48y000|B06..00|1620C|1923|B55..00|B350000|B31y.00|2022BM|Byu8000|B613500|B312.00|B613600|B550000|B071100|B05y.00|B44..00|1991CR|1519BL|1519B|B0z2.00|B432.00|B20z.00|1460A|ZV10z00|ZV10y15|B14y.00|1539AT|B171.00|B624600|B626700|1890CH|B64z.00|B201300|B614200|B543.00|1702D|B151200|1840A|B551100|B524500|B623.00|B610000|B614700|B4A..11|B550500|B624000|2102AP|B320.00|B08y.00|B62y800|B340000|B625100|B323200|2021|1460C|1519L|B327600|B34..11|B525.00|B66..11|1950A|B18y200|B4Ay000|B224000|B31z.00|B311400|1959AA|B323z00|B333400|B073200|1942AM|B313200|B052.00|2050MB|B305200|B343.00|B62zz11|B602100|B521100|B35z.00|B627800|B611300|B021.00|B031.00|B324.00|B451z00|B34yz00|B15..00|2000|B308500|B202.00|B613400|B614600|ZV10213)")
} 

*Moderate or Severe Liver Disease
if "`icd'"=="9" {
   quietly replace ch15=1 if inlist(substr(`cmb',1,4), "5722", "5723", "5724", "5728") | /*	
*/ inlist(substr(`cmb',1,4), "4560", "4561", "4562") | /*
*/ inlist(substr(`cmb',1,5), "45620", "45621")
}
else if "`icd'"=="10" {
   quietly replace ch15=1 if inlist(substr(`cmb',1,4), "K704", "K711", "K721", "K729", "K765", "K766", "K767") | /*
*/ inlist(substr(`cmb',1,4), "I850", "I859", "I864", "I982")
}
else if "`icd'"=="00" {
   quietly replace ch15=1 if regexm(`cmb', "(G852300|J62z.00|G851.00|Gyu9400|J62y.00|G852000|573 HR|J624.00|5719PH|G850.00|G852.00|J622.00|G858.00|G85..11|J623.00|G852200|A704z00|760F300|573 B|G852100|G852z00)")
}
	
*Metastatic Carcinoma
if "`icd'"=="9" {
	quietly replace ch16=1 if inlist(substr(`cmb',1,3), "196", "197", "198", "199")
}
else if "`icd'"=="10" {
     quietly replace ch16=1 if inlist(substr(`cmb',1,3), "C77", "C78", "C79", "C80")
}
else if "`icd'"=="00" {
     quietly replace ch16=1 if regexm(`cmb', "(B561400|B58y900|B5y..00|B562300|B563300|B575.00|B575100|1976A|B58y300|B5z..00|B58y411|B564200|B58y600|B586.00|B573.00|1968M|1977|B593.00|B58..00|B581200|B563100|B56..11|B574200|ByuC.00|B58y800|B561300|B58yz00|B574z00|B560500|B562.00|B562000|B576z00|B561800|B560700|B562100|B56..00|B574000|B564000|B582100|B577.11|B564100|1970|B574100|B56y.00|B590.11|B582000|209 BL|B583z00|B576.00|B153.00|1972B|B565.00|B563z00|B58y.00|1976M|B572.00|B57..12|B560100|B582300|B57..00|B561200|B592.00|B582500|B581100|B560200|B583100|B59z.00|B561600|B564.00|1985|B576000|B560000|B561700|B563.00|B592X00|1969M|B58y500|1983AM|B58y200|B58y211|B57z.00|B582400|B587.00|B582200|1989M|B581.00|B58y000|B590.00|B57..11|1972A|B58y700|B565200|B58y400|1973M|B575000|B561000|B583000|B58y100|B565300|B582z00|B565100|1969A|B582600|B585000|ByuC100|B560600|B560900|ByuC700|B562z00|1989|B571.00|B560800|B580.00|2022MT|1982|B563000|B560.00|1990C|ByuC800|B560z00|B575z00|B583200|ByuC500|B570.00|B58z.00|B577.00|B56z.00|B565000|B591.00|ByuC400|B563200|209 BF|1977M|B564z00|ByuC300|B582.00|B581z00|B561100|B581000|B585.00|B565z00|B562400|1977A|B583.00|B561.00|B576200|B574.00|B594.00|B584.00|B562200|B58..11|ByuC200|B57y.00|1990NB|1990M|B59..00|B561900|B561z00|B561500|B565400|1970M|ByuC600|B560400|1983|B576100|1983M|B560300)")
}

*AIDS/HIV
if "`icd'"=="9" {
	quietly replace ch17=1 if inlist(substr(`cmb',1,3), "042", "043", "044")
}
else if "`icd'"=="10" {
    quietly replace ch17=1 if inlist(substr(`cmb',1,3),"B20", "B21", "B22", "B24")
}
else if "`icd'"=="00" {
	quietly replace ch17=1 if regexm(`cmb', "(A788W00|A788V00|AyuC.00|A789000|A788400|AyuC600|A788X00|A788z00|AyuC900|AyuC300|A789200|A788500|AyuC000|AyuCD00|AyuCC00|A789600|AyuC200|A789900|A789.00|A789A00|AyuC100|A788300|A788.00|AyuCB00|799MD|A789100|A789500|A788200|A788U00|A788y00|A788600|L7990A|A789300|AyuC500|A789X00|AyuC700|A788100|AyuC800|AyuC400|A789400|A789800|AyuCA00)")
}   
	 local ord=`ord'+1
}

*hierarchy adjustments
***************************** 
if "`assign0'" != "" {
 quietly replace ch9=0 if ch15>0 & ch9>0
 quietly replace ch10=0 if ch11>0 & ch10>0
 quietly replace ch14=0 if ch16>0 & ch14>0 
 }
*****************************

*SUM THE FREQUENCIES of COMORBIDITIES over multiple patient records for each comobidity group
*Each ynchi will be 0 or 1, indicating absence or presence of comorbidity
*If multiple patient records, i.e. idvar option present

if "`idvar'" != "" {
bysort `idvar': egen ynch1 = max(ch1)
bysort `idvar': egen ynch2 = max(ch2)
bysort `idvar': egen ynch3 = max(ch3)
bysort `idvar': egen ynch4 = max(ch4)
bysort `idvar': egen ynch5 = max(ch5)
bysort `idvar': egen ynch6 = max(ch6)
bysort `idvar': egen ynch7 = max(ch7)
bysort `idvar': egen ynch8 = max(ch8)
bysort `idvar': egen ynch9 = max(ch9)
bysort `idvar': egen ynch10 = max(ch10)
bysort `idvar': egen ynch11 = max(ch11)
bysort `idvar': egen ynch12 = max(ch12)
bysort `idvar': egen ynch13 = max(ch13)
bysort `idvar': egen ynch14 = max(ch14)
bysort `idvar': egen ynch15 = max(ch15)
bysort `idvar': egen ynch16 = max(ch16)
bysort `idvar': egen ynch17 = max(ch17)
*RETAIN ONLY LAST OBSERVATION FOR EACH PATIENT	
	set output error /*To prevent statement re number of deleted observations being printed*/
	bysort `idvar':  keep if _n == _N
	set output proc /*Return to default messages*/
	keep `idvar' ynch1-ynch17
	}
	else {
		forvalues i=1/17 {
			rename ch`i' ynch`i'
			}
		}
 
display "Total Number of Observational Units (Visits OR Patients): " _N 

*If multiple records per patient retain only newly created binary comorbidity variables
*Otherwise retain all input data as well
		
*charlson index calculated from sum of weighted comorbidities

  forvalues i=1/17 {
    gen weightch`i'=0
    quietly replace weightch`i'=1 if ynch`i'==1
    }
  
*Change weights for more serious comorbidites (for calculation of charlson index, based on sum of weights)

  quietly replace weightch12=2 if ynch12>0
  quietly replace weightch13=2 if ynch13>0
  quietly replace weightch14=2 if ynch14>0
  quietly replace weightch15=3 if ynch15>0
  quietly replace weightch16=6 if ynch16>0
  quietly replace weightch17=6 if ynch17>0

  egen wcharlsum=rsum(weightch*)

  gen charlindex=0
  quietly replace charlindex=1 if wcharlsum==1
  quietly replace charlindex=2 if wcharlsum>=2
 
label var ynch1 "AMI (Acute Myocardial)"
  label var ynch2 "CHF (Congestive Heart)"
  label var ynch3 "PVD (Peripheral Vascular)"
  label var ynch4 "CEVD (Cerebrovascular"
  label var ynch5 "Dementia"
  label var ynch6 "COPD (Chronic Obstructive Pulmonary)"
  label var ynch7 "Rheumatoid Disease"
  label var ynch8 "PUD (Peptic Ulcer)"
  label var ynch9 "Mild LD (Liver)"
  label var ynch10 "Diabetes"
  label var ynch11 "Diabetes + Complications"
  label var ynch12 "HP/PAPL (Hemiplegia or Paraplegia)"
  label var ynch13 "RD (Renal)"
  label var ynch14 "Cancer"
  label var ynch15 "Moderate/Severe LD (Liver)"
  label var ynch16 "Metastic Cancer"
  label var ynch17 "AIDS"

  label var wcharlsum "Weighted Charlson Sum"
  label var charlindex "CHARLSON INDEX"
  
*Advise to check version of input data, in case of no recognized comorbidities
  egen smchindx = sum(charlindex)
  if smchindx == 0 {
	display "NOTE: NO RECOGNIZED COMORBIDITY CODES - "
	display "Please check VERSION of input data and icd option."
	}

*Output summaries as requested
  
  if "`wtchrl'" != "" {
    tab charlindex 
    tab wcharlsum 
    sum wcharlsum 
    }
  
 forvalues i=1/17 {
    if "`cmorb'" != "" {
    tab ynch`i'
      }
}

end



