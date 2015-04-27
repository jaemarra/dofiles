//  program:    getcodes_covdrugs.do
//  task:		Use Stata to generate a list of gemscript codes for covariate drugs
//				and export to excel where it can be formatted and listed for future use
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
replace drugsubstance= lower( drugsubstance)
save product, replace
clear

//EXTRACT AND EXPORT CODES FOR EACH CATEGORY OF COVARIATE
//H2 receptor antagonists
use product.dta, clear
rename productname productname_1
rename drugsubstance drugsubstance_1
gen h2recep = 0 
replace h2recep = 1 if regexm(prod_bnfcode, "010301..") 
replace h2recep = 1 if regexm(drugsubstance_1, "(tagamet|zantac)")
replace h2recep = 1 if regexm(drugsubstance_1, "(cimetidine|famotidine|nizatidine|ranitidine)")
replace h2recep = 1 if regexm(productname_1, "(tagamet|zantac)")
replace h2recep = 1 if regexm(productname_1, "(cimetidine|famotidine|nizatidine|ranitidine)")
label variable h2recep "H2 receptor antagonist exposure: 0=no exp, 1=exp"
keep if h2recep==1
drop h2recep
export excel prodcode gemscriptcode productname using cov_drugcodes.xls, sheet("h2recep") sheetmodify firstrow(variables)

//Proton-pump inhibitors
use product.dta, clear
rename productname productname_1
rename drugsubstance drugsubstance_1
gen ppi = 0 
replace ppi = 1 if regexm(prod_bnfcode, "010305..")
replace ppi = 1 if regexm(drugsubstance_1, "(nexium|zoton|losec|protium|pariet)")
replace ppi = 1 if regexm(drugsubstance_1, "(esomeprazole|lansoprazole|omeprazole|pantprazole|rabeprazole)")
replace ppi = 1 if regexm(productname_1, "(nexium|zoton|losec|protium|pariet)")
replace ppi = 1 if regexm(productname_1, "(esomeprazole|lansoprazole|omeprazole|pantprazole|rabeprazole)")
label variable ppi "Proton pump inhibitor exposure: 0=no exp, 1=exp"
keep if ppi==1
drop ppi
export excel prodcode gemscriptcode productname using cov_drugcodes.xls, sheet("ppi") sheetmodify firstrow(variables)

//Corticosteroids (GI)
use product.dta, clear
rename productname productname_1
rename drugsubstance drugsubstance_1
gen cortico_gi = 0 
replace cortico_gi = 1 if regexm(prod_bnfcode, "010502..")
replace cortico_gi = 1 if regexm(drugsubstance_1, "(clipper|budenofalk|entocort|colifoam|predsol)") 
replace cortico_gi = 1 if regexm(drugsubstance_1, "(beclometasone|budesonide|hydrocortisone|prednisolone)") 
replace cortico_gi = 1 if regexm(productname_1, "(clipper|budenofalk|entocort|colifoam|predsol)") 
replace cortico_gi = 1 if regexm(productname_1, "(beclometasone|budesonide|hydrocortisone|prednisolone)") 
label variable cortico_gi "Corticosteroid (GI) exposure:0=no exp, 1=exp"
keep if cortico_gi==1
drop cortico_gi
export excel prodcode gemscriptcode productname using cov_drugcodes.xls, sheet("cortico_gi") sheetmodify firstrow(variables)

//Thiazide and related diuretics
use product.dta, clear
rename productname productname_1
rename drugsubstance drugsubstance_1
gen thiazdiur = 0 
replace thiazdiur = 1 if regexm(prod_bnfcode, "020201..")
replace thiazdiur = 1 if regexm(drugsubstance_1, "(hygroton|navidrex|natrilex|ethibide|tensaid|diurexan)")
replace thiazdiur = 1 if regexm(drugsubstance_1, "(bendroflumethazide|bendrofluazide|chlortalidone|chlorthalidone|cyclopenthiazide|indapamide|metolazone|xipamide)")
replace thiazdiur = 1 if regexm(productname_1, "(hygroton|navidrex|natrilex|ethibide|tensaid|diurexan)")
replace thiazdiur = 1 if regexm(productname_1, "(bendroflumethazide|bendrofluazide|chlortalidone|chlorthalidone|cyclopenthiazide|indapamide|metolazone|xipamide)")
label variable thiazdiur "thiazide and related diuretic exposure: 0=no exp, 1=exp"
keep if thiazdiur==1
drop thiazdiur
export excel prodcode gemscriptcode productname using cov_drugcodes.xls, sheet("thiazdiur") sheetmodify firstrow(variables)

//Loop diuretics
use product.dta, clear
rename productname productname_1
rename drugsubstance drugsubstance_1
gen loopdiur = 0 
replace loopdiur = 1 if regexm(prod_bnfcode, "020202..")
replace loopdiur = 1 if regexm(drugsubstance_1, "(lasix|torem)")
replace loopdiur = 1 if regexm(drugsubstance_1, "(bumetanide|furosemide|frusemide|torasemide)")
replace loopdiur = 1 if regexm(productname_1, "(lasix|torem)")
replace loopdiur = 1 if regexm(productname_1, "(bumetanide|furosemide|frusemide|torasemide)")
label variable loopdiur "loop diuretic exposure: 0=no exp, 1=exp"
keep if loopdiur==1
drop loopdiur
export excel prodcode gemscriptcode productname using cov_drugcodes.xls, sheet("loopdiur") sheetmodify firstrow(variables)

//// Potassium-sparing diuretics and aldosterone antagonists
use product.dta, clear
rename productname productname_1
rename drugsubstance drugsubstance_1
gen potsparediur_aldos = 0 
replace potsparediur_aldos = 1 if regexm(prod_bnfcode, "020203..")
replace potsparediur_aldos = 1 if regexm(drugsubstance_1, "(dytac|inspra|aldactone)")
replace potsparediur_aldos = 1 if regexm(drugsubstance_1, "(amiloride|triamterene|eplerenone|spironolactone)")
replace potsparediur_aldos = 1 if regexm(productname_1, "(dytac|inspra|aldactone)")
replace potsparediur_aldos = 1 if regexm(productname_1, "(amiloride|triamterene|eplerenone|spironolactone)")
label variable potsparediur_aldos "Potassium-sparing diuretic and aldosterone antagonist exposure: 0=no exp, 1=exp"
keep if potsparediur_aldos==1
drop potsparediur_aldos
export excel prodcode gemscriptcode productname using cov_drugcodes.xls, sheet("potsparediur_aldos") sheetmodify firstrow(variables)

//Potassium-sparing diuretics with other diuretics
use product.dta, clear
rename productname productname_1
rename drugsubstance drugsubstance_1
gen potsparediur_other = 0 
replace potsparediur_other = 1 if regexm(prod_bnfcode, "020204..")
replace potsparediur_other = 1 if regexm(drugsubstance_1, "(navispare|dyazide|kalspare|frusene|lasilactone)")
replace potsparediur_other = 1 if regexm(drugsubstance_1, "(amilozide|amilofruse|triamterzide|flumactone)")
replace potsparediur_other = 1 if regexm(productname_1, "(navispare|dyazide|kalspare|frusene|lasilactone)")
replace potsparediur_other = 1 if regexm(productname_1, "(amilozide|amilofruse|triamterzide|flumactone)")
label variable potsparediur_other "Potassium-sparing diuretic with other diuretic exposure: 0=no exp, 1=exp"
keep if potsparediur_other==1
drop potsparediur_other
export excel prodcode gemscriptcode productname using cov_drugcodes.xls, sheet("potsparediur_other") sheetmodify firstrow(variables)

//Antiarrhythmic
use product.dta, clear
rename productname productname_1
rename drugsubstance drugsubstance_1
gen antiarrhythmic = 0 
replace antiarrhythmic = 1 if regexm(prod_bnfcode, "0203....")
replace antiarrhythmic = 1 if regexm(drugsubstance_1, "(adenocor|adenoscan|multaq|cordarone|rythmodan|tambocor|arythmol|lignocaine)")
replace antiarrhythmic = 1 if regexm(drugsubstance_1, "(adenosine|dronedarone|amiodarone|disopyramide|flecainide|propafenone|lidocaine)")
replace antiarrhythmic = 1 if regexm(productname_1, "(adenocor|adenoscan|multaq|cordarone|rythmodan|tambocor|arythmol|lignocaine)")
replace antiarrhythmic = 1 if regexm(productname_1, "(adenosine|dronedarone|amiodarone|disopyramide|flecainide|propafenone|lidocaine)")
label variable antiarrhythmic "antiarrhythmic exposure: 0=no exp, 1=exp"
keep if antiarrhythmic==1
drop antiarrhythmic
export excel prodcode gemscriptcode productname using cov_drugcodes.xls, sheet("antiarrhythmic") sheetmodify firstrow(variables)

//Beta-blockers
use product.dta, clear
rename productname productname_1
rename drugsubstance drugsubstance_1
gen betablock = 0 
replace betablock = 1 if regexm(prod_bnfcode, "0204....")
replace betablock = 1 if regexm(drugsubstance_1, "(inderal|sectral|tenormin|tenidone|kalten|tenoret|tenoretic|beta-adalat|tenif|cardicor|emcor|celectol|brevibloc|trandate|betaloc|lopresor|corgard|nebilet|trasicor|visken|viskaldix|beta-cardone|sotacor)")
replace betablock = 1 if regexm(drugsubstance_1, "(propranolol|acebutolol|atenolol|bisoprolol|carvedilol|celiprolol|esmolol|labetolol|metoprolol|nadolol|nebivolol|oxprenolol|pindolol|sotalol|timolol)")
replace betablock = 1 if regexm(productname_1, "(inderal|sectral|tenormin|tenidone|kalten|tenoret|tenoretic|beta-adalat|tenif|cardicor|emcor|celectol|brevibloc|trandate|betaloc|lopresor|corgard|nebilet|trasicor|visken|viskaldix|beta-cardone|sotacor)")
replace betablock = 1 if regexm(productname_1, "(propranolol|acebutolol|atenolol|bisoprolol|carvedilol|celiprolol|esmolol|labetolol|metoprolol|nadolol|nebivolol|oxprenolol|pindolol|sotalol|timolol)")
label variable betablock "beta-blocker exposure: 0=no exp, 1=exp"
keep if betablock==1
drop betablock
export excel prodcode gemscriptcode productname using cov_drugcodes.xls, sheet("betablock") sheetmodify firstrow(variables)

//ACE inhibitors
use product.dta, clear
rename productname productname_1
rename drugsubstance drugsubstance_1
gen acei = 0 
replace acei = 1 if regexm(prod_bnfcode, "02050501")
replace acei = 1 if regexm(drugsubstance_1, "(capoten|zidocapt|capozide|vascace|innovace|innozide|tanatril|zestril|carace|zestoretic|perdix|coversyl|accupro|accuretic|tritace|triapin|gopten|tarka)")
replace acei = 1 if regexm(drugsubstance_1, "(captopril|cilazapril|enalapril|fosinopril|imidapril|lisinopril|moexipril|perindopril|quinapril|ramipril|tandolapril)")
replace acei = 1 if regexm(productname_1, "(capoten|zidocapt|capozide|vascace|innovace|innozide|tanatril|zestril|carace|zestoretic|perdix|coversyl|accupro|accuretic|tritace|triapin|gopten|tarka)")
replace acei = 1 if regexm(productname_1, "(captopril|cilazapril|enalapril|fosinopril|imidapril|lisinopril|moexipril|perindopril|quinapril|ramipril|tandolapril)")
label variable acei "ACE inhibitor exposure: 0=no exp, 1=exp"
keep if acei==1
drop acei
export excel prodcode gemscriptcode productname using cov_drugcodes.xls, sheet("acei") sheetmodify firstrow(variables)

//Angiotensin II receptor antagonists
use product.dta, clear
rename productname productname_1
rename drugsubstance drugsubstance_1
gen angiotensin2recepant = 0 
replace angiotensin2recepant = 1 if regexm(prod_bnfcode, "02050502")
replace angiotensin2recepant = 1 if regexm(drugsubstance_1, "(edarbi|amias|teveten|aprovel|coaprovel|cozaar|olmetec|sevikar|micardis|diovan)")
replace angiotensin2recepant = 1 if regexm(drugsubstance_1, "(azilsartan medoxomil|candesartan cilexetil|eprosartan|irbesartan|losartan|olmesartan medoximil|telmisartan|valsartan)")
replace angiotensin2recepant = 1 if regexm(productname_1, "(edarbi|amias|teveten|aprovel|coaprovel|cozaar|olmetec|sevikar|micardis|diovan)")
replace angiotensin2recepant = 1 if regexm(productname_1, "(azilsartan medoxomil|candesartan cilexetil|eprosartan|irbesartan|losartan|olmesartan medoximil|telmisartan|valsartan)")
label variable angiotensin2recepant "Angiotensin II receptor antagonist exposure: 0=no exp, 1=exp"
keep if angiotensin2recepant==1
drop angiotensin2recepant
export excel prodcode gemscriptcode productname using cov_drugcodes.xls, sheet("angiotensin2recepant") sheetmodify firstrow(variables)

// Renin Inhibitors
use product.dta, clear
rename productname productname_1
rename drugsubstance drugsubstance_1
gen renini = 0 
replace renini = 1 if regexm(prod_bnfcode, "02050503")
replace renini = 1 if regexm(drugsubstance_1, "(rasilez)")
replace renini = 1 if regexm(drugsubstance_1, "(aliskiren)")
replace renini = 1 if regexm(productname_1, "(rasilez)")
replace renini = 1 if regexm(productname_1, "(aliskiren)")
label variable renini "Renin inhibitor exposure: 0=no exp, 1=exp"
keep if renini==1
drop renini
export excel prodcode gemscriptcode productname using cov_drugcodes.xls, sheet("renini") sheetmodify firstrow(variables)

//Nitrates
use product.dta, clear
rename productname productname_1
rename drugsubstance drugsubstance_1
gen nitrates = 0 
replace nitrates = 1 if regexm(prod_bnfcode, "020601..")
replace nitrates = 1 if regexm(drugsubstance_1, "(coro-nitro|glytrin|gtn|nitrolingual|nitromin|nitrocine|nitronal|deponit|minitran|nitro-dur|percutol|transiderm-nitro|angitak|isoket|ismo|chemydur|elantan|imdur|isib|isodur|isotard|modisal|monomax|monomil|monosorb|zemon)")
replace nitrates = 1 if regexm(drugsubstance_1, "(glyceral trinitrate|isosorbide dinitrate|isosorbide mononitrate)")
replace nitrates = 1 if regexm(productname_1, "(coro-nitro|glytrin|gtn|nitrolingual|nitromin|nitrocine|nitronal|deponit|minitran|nitro-dur|percutol|transiderm-nitro|angitak|isoket|ismo|chemydur|elantan|imdur|isib|isodur|isotard|modisal|monomax|monomil|monosorb|zemon)")
replace nitrates = 1 if regexm(productname_1, "(glyceral trinitrate|isosorbide dinitrate|isosorbide mononitrate)")
label variable nitrates "nitrates exposure: 0=no exp, 1=exp"
keep if nitrates==1
drop nitrates
export excel prodcode gemscriptcode productname using cov_drugcodes.xls, sheet("nitrates") sheetmodify firstrow(variables)

//Calcium Channel Blockers
use product.dta, clear
rename productname productname_1
rename drugsubstance drugsubstance_1
gen calchan = 0 
replace calchan = 1 if regexm(prod_bnfcode, "020602..")
replace calchan = 1 if regexm(drugsubstance_1, "(istin|exforge|tildiem|adizem|angitil|calcicard|dilcardia|dilzem|slozem|viazem|zemtard|plendil|prescal|zanidip|cardene|adalat|adipine|coracten|fortipine|nifedipress|tensipine|valni|nimotop|cordilox|securon|univer|verapress|vertab)")
replace calchan = 1 if regexm(drugsubstance_1, "(amlodipine|diltiazem|felodipine|isradipine|lacidipine|lercanidipine|nicardipine|nifedipine|nimodipine|verapamil)")
replace calchan = 1 if regexm(productname_1, "(istin|exforge|tildiem|adizem|angitil|calcicard|dilcardia|dilzem|slozem|viazem|zemtard|plendil|prescal|zanidip|cardene|adalat|adipine|coracten|fortipine|nifedipress|tensipine|valni|nimotop|cordilox|securon|univer|verapress|vertab)")
replace calchan = 1 if regexm(productname_1, "(amlodipine|diltiazem|felodipine|isradipine|lacidipine|lercanidipine|nicardipine|nifedipine|nimodipine|verapamil)")
label variable calchan "calcium channel blocker exposure: 0=no exp, 1=exp"
keep if calchan==1
drop calchan
export excel prodcode gemscriptcode productname using cov_drugcodes.xls, sheet("calchan") sheetmodify firstrow(variables)

//Anticoagulants (oral)
use product.dta, clear
rename productname productname_1
rename drugsubstance drugsubstance_1
gen anticoag_oral = 0 
replace anticoag_oral = 1 if regexm(prod_bnfcode, "020802..")
replace anticoag_oral = 1 if regexm(drugsubstance_1, "(sinthrome|pradaxa|eliquis|xarelto)")
replace anticoag_oral = 1 if regexm(drugsubstance_1, "(warfarin|acenocoumarol|phenindione|dabigatran|apixaban|rivaroxaban)")
replace anticoag_oral = 1 if regexm(productname_1, "(sinthrome|pradaxa|eliquis|xarelto)")
replace anticoag_oral = 1 if regexm(productname_1, "(warfarin|acenocoumarol|phenindione|dabigatran|apixaban|rivaroxaban)")
label variable anticoag_oral "Oral anticoagulant exposure: 0=no exp, 1=exp"
keep if anticoag_oral==1
drop anticoag_oral
export excel prodcode gemscriptcode productname using cov_drugcodes.xls, sheet("anticoag_oral") sheetmodify firstrow(variables)

//Antiplatelets
use product.dta, clear
rename productname productname_1
rename drugsubstance drugsubstance_1
gen antiplat = 0 
replace antiplat = 1 if regexm(prod_bnfcode, "0209....")
replace antiplat = 1 if regexm(drugsubstance_1, "(reopro|plavix|asasantin|integrilin|efient|brilique|aggrastat)")
replace antiplat = 1 if regexm(drugsubstance_1, "(abciximab|aspirin|acetylsalicylic acid|clopidogrel|dipyridamole|eptifibatide|prasugrel|ticagrelor|tirofiban)")
replace antiplat = 1 if regexm(productname_1, "(reopro|plavix|asasantin|integrilin|efient|brilique|aggrastat)")
replace antiplat = 1 if regexm(productname_1, "(abciximab|aspirin|acetylsalicylic acid|clopidogrel|dipyridamole|eptifibatide|prasugrel|ticagrelor|tirofiban)")
label variable antiplat "antiplatelet exposure: 0=no exp, 1=exp"
keep if antiplat==1
drop antiplat
export excel prodcode gemscriptcode productname using cov_drugcodes.xls, sheet("antiplat") sheetmodify firstrow(variables)

//Statins
use product.dta, clear
rename productname productname_1
rename drugsubstance drugsubstance_1
gen statin = 0 
replace statin = 1 if regexm(prod_bnfcode, "021204..")
replace statin = 1 if regexm(drugsubstance_1, "(lipitor|lescol|lipostat|crestor|zocor|inegy)")
replace statin = 1 if regexm(drugsubstance_1, "(atorvastatin|fluvastatin|pravastatin|rosuvastatin|simvastatin)")
replace statin = 1 if regexm(productname_1, "(lipitor|lescol|lipostat|crestor|zocor|inegy)")
replace statin = 1 if regexm(productname_1, "(atorvastatin|fluvastatin|pravastatin|rosuvastatin|simvastatin)")
label variable statin "statin exposure: 0=no exp, 1=exp"
keep if statin==1
drop statin
export excel prodcode gemscriptcode productname using cov_drugcodes.xls, sheet("statin") sheetmodify firstrow(variables)

//Fibrates
use product.dta, clear
rename productname productname_1
rename drugsubstance drugsubstance_1
gen fibrates = 0 
replace fibrates = 1 if regexm(prod_bnfcode, "021203..")
replace fibrates = 1 if regexm(drugsubstance_1, "(bezalip|lipantil|lopid)")
replace fibrates = 1 if regexm(drugsubstance_1, "(bezafibrate|ciprofibrate|fenofibrate|gemfibrozil)")
replace fibrates = 1 if regexm(productname_1, "(bezalip|lipantil|lopid)")
replace fibrates = 1 if regexm(productname_1, "(bezafibrate|ciprofibrate|fenofibrate|gemfibrozil)")
label variable fibrates "fibrates exposure: 0=no exp, 1=exp"
keep if fibrates==1
drop fibrates
export excel prodcode gemscriptcode productname using cov_drugcodes.xls, sheet("fibrates") sheetmodify firstrow(variables)

//Ezetimibe
use product.dta, clear
rename productname productname_1
rename drugsubstance drugsubstance_1
gen ezetimibe = 0 
replace ezetimibe = 1 if regexm(prod_bnfcode, "021202..")
replace ezetimibe = 1 if regexm(drugsubstance_1, "(ezetrol)")
replace ezetimibe = 1 if regexm(drugsubstance_1, "(ezetimibe)")
replace ezetimibe = 1 if regexm(productname_1, "(ezetrol)")
replace ezetimibe = 1 if regexm(productname_1, "(ezetimibe)")
label variable ezetimibe "ezetimibe exposure: 0=no exp, 1=exp"
keep if ezetimibe==1
drop ezetimibe
export excel prodcode gemscriptcode productname using cov_drugcodes.xls, sheet("ezetimibe") sheetmodify firstrow(variables)

//Bile acid sequestrants
use product.dta, clear
rename productname productname_1
rename drugsubstance drugsubstance_1
gen bileacidseq = 0 
replace bileacidseq = 1 if regexm(prod_bnfcode, "021201..")
replace bileacidseq = 1 if regexm(drugsubstance_1, "(cholestagel|questran|colestid)")
replace bileacidseq = 1 if regexm(drugsubstance_1, "(colesevelam|colestyramine|colestipol)")
label variable bileacidseq "Bile acid sequestrants exposure: 0=no exp, 1=exp"
keep if bileacidseq==1
drop bileacidseq
export excel prodcode gemscriptcode productname using cov_drugcodes.xls, sheet("bileacidseq") sheetmodify firstrow(variables)

//Bronchodilators
use product.dta, clear
rename productname productname_1
rename drugsubstance drugsubstance_1
gen bronchodil = 0 
replace bronchodil = 1 if regexm(prod_bnfcode, "0301....")
replace bronchodil = 1 if regexm(drugsubstance_1, "(bambec|atimos modulite|foradil|oxis|onbrez|ventamax|ventolin|airomir|asmasal|easyhaler salbutamol|pulvinal|salamol|salbulin|serevent|bricanyl|eklira genuair|seebri|atrovent|respontin|spiriva|nuelin|slo-phyllin|uniphyllin continus|phyllocontin|combivent)")
replace bronchodil = 1 if regexm(drugsubstance_1, "(bambuterol|formoterol fumarate|eformoterol fumarate|indacaterol|albutamol|albuterol|salmeterol|terbutaline|ephedrine|aclidinium bromide|glycopyrronium|ipratropium bromide|tiotropium|theophylline|aminophylline)")
replace bronchodil = 1 if regexm(productname_1, "(bambec|atimos modulite|foradil|oxis|onbrez|ventamax|ventolin|airomir|asmasal|easyhaler salbutamol|pulvinal|salamol|salbulin|serevent|bricanyl|eklira genuair|seebri|atrovent|respontin|spiriva|nuelin|slo-phyllin|uniphyllin continus|phyllocontin|combivent)")
replace bronchodil = 1 if regexm(productname_1, "(bambuterol|formoterol fumarate|eformoterol fumarate|indacaterol|albutamol|albuterol|salmeterol|terbutaline|ephedrine|aclidinium bromide|glycopyrronium|ipratropium bromide|tiotropium|theophylline|aminophylline)")
label variable bronchodil "Bronchodilator exposure:0=no exp, 1=exp"
keep if bronchodil==1
drop bronchodil
export excel prodcode gemscriptcode productname using cov_drugcodes.xls, sheet("bronchodil") sheetmodify firstrow(variables)

//Corticosteroids (inhaled)
use product.dta, clear
rename productname productname_1
rename drugsubstance drugsubstance_1
gen cortico_inh = 0 
replace cortico_inh = 1 if regexm(prod_bnfcode, "0302....")
replace cortico_inh = 1 if regexm(drugsubstance_1, "(asmabec|becodisks|clenil modulite|qvar|fostair|budelin|pulmicort|symbicort|alvesco|flixotide|flutiform|seretide|asmanex)")
replace cortico_inh = 1 if regexm(drugsubstance_1, "(beclometasone|beclomethasone|budesonide|ciclesonide|fluticasone|mometasone)")
replace cortico_inh = 1 if regexm(productname_1, "(asmabec|becodisks|clenil modulite|qvar|fostair|budelin|pulmicort|symbicort|alvesco|flixotide|flutiform|seretide|asmanex)")
replace cortico_inh = 1 if regexm(productname_1, "(beclometasone|beclomethasone|budesonide|ciclesonide|fluticasone|mometasone)")
label variable cortico_inh "Inhaled corticosteroid exposure:0=no exp, 1=exp"
keep if cortico_inh==1
drop cortico_inh
export excel prodcode gemscriptcode productname using cov_drugcodes.xls, sheet("cortico_inh") sheetmodify firstrow(variables)

//Leukotriene receptor antagonists
use product.dta, clear
rename productname productname_1
rename drugsubstance drugsubstance_1
gen leukotri = 0 
replace leukotri = 1 if regexm(prod_bnfcode, "030302..")
replace leukotri = 1 if regexm(drugsubstance_1, "(singulair|accolate)")
replace leukotri = 1 if regexm(drugsubstance_1, "(montelukast|zafirlukast)")
replace leukotri = 1 if regexm(productname_1, "(singulair|accolate)")
replace leukotri = 1 if regexm(productname_1, "(montelukast|zafirlukast)")
label variable leukotri "Leukotriene receptor antagonist exposure:0=no exp, 1=exp"
keep if leukotri==1
drop leukotri
export excel prodcode gemscriptcode productname using cov_drugcodes.xls, sheet("leukotri") sheetmodify firstrow(variables)

//Antihistamines
use product.dta, clear
rename productname productname_1
rename drugsubstance drugsubstance_1
gen antihist = 0 
replace antihist = 1 if regexm(prod_bnfcode, "030401..")
replace antihist = 1 if regexm(drugsubstance_1, "(ilaxten|neoclarityn|telfast|mizollen|rupafin|piriton|tavegil|periactin|atarax|ucerax|zaditen|phenergan)")
replace antihist = 1 if regexm(drugsubstance_1, "(acrivastine|bilastine|cetirizine|desloratidine|fexofenadine|levocetirizine|loratidine|mizolastine|rupatadine|alimemazine|trimeprazine|chlorphenamine|chlorpheniramine|clemastine|cyproheptadine|hydroxyzine|ketotifen|promethazine)")
replace antihist = 1 if regexm(productname_1, "(ilaxten|neoclarityn|telfast|mizollen|rupafin|piriton|tavegil|periactin|atarax|ucerax|zaditen|phenergan)")
replace antihist = 1 if regexm(productname_1, "(acrivastine|bilastine|cetirizine|desloratidine|fexofenadine|levocetirizine|loratidine|mizolastine|rupatadine|alimemazine|trimeprazine|chlorphenamine|chlorpheniramine|clemastine|cyproheptadine|hydroxyzine|ketotifen|promethazine)")
label variable antihist "Antihistamine exposure:0=no exp, 1=exp"
keep if antihist==1
drop antihist
export excel prodcode gemscriptcode productname using cov_drugcodes.xls, sheet("antihist") sheetmodify firstrow(variables)

//Hypnotics and anxiolytics
use product.dta, clear
rename productname productname_1
rename drugsubstance drugsubstance_1
gen hyp_anx = 0 
replace hyp_anx = 1 if regexm(prod_bnfcode, "0401....")
replace hyp_anx = 1 if regexm(drugsubstance_1, "(dalmane|sonata|stilnoct|zopiclone|zimovane|chloral mixture|chloral elixir|welldorm|xyrem|circadin)")
replace hyp_anx = 1 if regexm(drugsubstance_1, "(nitrazepam|flurazepam|loprazolam|lormetazepam|temazepan|zaleplon|zolpidem|zopiclone|chloral hydrate|clomethiazole|chlormethiazole|promethazine|sodium oxybate|melatonin|diazepam|alprazolam|chlordiazepoxide|lorazepam|oxazepam|buspirone|meprobamate)")
replace hyp_anx = 1 if regexm(productname_1, "(dalmane|sonata|stilnoct|zopiclone|zimovane|chloral mixture|chloral elixir|welldorm|xyrem|circadin)")
replace hyp_anx = 1 if regexm(productname_1, "(nitrazepam|flurazepam|loprazolam|lormetazepam|temazepan|zaleplon|zolpidem|zopiclone|chloral hydrate|clomethiazole|chlormethiazole|promethazine|sodium oxybate|melatonin|diazepam|alprazolam|chlordiazepoxide|lorazepam|oxazepam|buspirone|meprobamate)")
label variable hyp_anx "Hypnotic/Anxiolytic exposure:0=no exp, 1=exp"
keep if hyp_anx==1
drop hyp_anx
export excel prodcode gemscriptcode productname using cov_drugcodes.xls, sheet("hyp_anx") sheetmodify firstrow(variables)

//Drugs used for psychoses and related disorders
use product.dta, clear
rename productname productname_1
rename drugsubstance drugsubstance_1
gen psychoses = 0 
replace psychoses = 1 if regexm(prod_bnfcode, "0402....")
replace psychoses = 1 if regexm(drugsubstance_1, "(anquil|largactil|depixol|fluanxol|dozic|haldol|serenace|nozinan|fentazin|orap|dolmatil|sulpor|stelazine|clopixol|solian|abilify|clozaril|denzapine|zaponex|zyprexa|invega|seroquel|risperdal|modecate|zypadhera|xeplion|piportil|sycrest|depakote|convulex|camcolit|liskonum|priadel|li-liquid)")
replace psychoses = 1 if regexm(drugsubstance_1, "(benperidol|chlorpromazine|flupentixol|flupenthixol|haloperidol|levomepromazine|methotrimeprazine|pericyazine|periciazine|perphenazine|pimozide|prochlorperazine|promazine|sulpiride|trifluoperazine|zuclopenthixol|amisulpride|aripiprazole|clozapine|olanzapine|paliperidone|quetiapine|risperidone|flupentixol decanoate|flupenthixol decanoate|fluphenazine decanoate|pipotiazine|pipothiazine|asenapine|valproic acid|lithium)")
replace psychoses = 1 if regexm(productname_1, "(anquil|largactil|depixol|fluanxol|dozic|haldol|serenace|nozinan|fentazin|orap|dolmatil|sulpor|stelazine|clopixol|solian|abilify|clozaril|denzapine|zaponex|zyprexa|invega|seroquel|risperdal|modecate|zypadhera|xeplion|piportil|sycrest|depakote|convulex|camcolit|liskonum|priadel|li-liquid)")
replace psychoses = 1 if regexm(productname_1, "(benperidol|chlorpromazine|flupentixol|flupenthixol|haloperidol|levomepromazine|methotrimeprazine|pericyazine|periciazine|perphenazine|pimozide|prochlorperazine|promazine|sulpiride|trifluoperazine|zuclopenthixol|amisulpride|aripiprazole|clozapine|olanzapine|paliperidone|quetiapine|risperidone|flupentixol decanoate|flupenthixol decanoate|fluphenazine decanoate|pipotiazine|pipothiazine|asenapine|valproic acid|lithium)")
label variable psychoses "Drugs used in psychoses and related disorders exposure:0=no exp, 1=exp"
keep if psychoses==1
drop psychoses
export excel prodcode gemscriptcode productname using cov_drugcodes.xls, sheet("psychoses") sheetmodify firstrow(variables)

//Antidepressants
use product.dta, clear
rename productname productname_1
rename drugsubstance drugsubstance_1
gen antidepress = 0 
replace antidepress = 1 if regexm(prod_bnfcode, "0403....")
replace antidepress = 1 if regexm(drugsubstance_1, "(triptafen|anafranil|prothiaden|sinepin|allegron|surmontil|molipaxin|nardil|manerix|cipramil|cipralex|prozac|faverin|seroxat|lustral|valdoxan|cymbalta|yentreve|depixol|zispin|edronax|efexor)")
replace antidepress = 1 if regexm(drugsubstance_1, "(amitriptyline|clomipramine|dosulepin|dothiepin|doxepin|imipramine|lofepramine|nortriptyline|trimipramine|mianserin|trazodone|phenelzine|isocarboxazid|tranylcypromine|moclobemide|citalopram|escitalopram|fluoxetine|fluvoxamine|paroxetine|sertraline|agomelatine|duloxetine|flupentixol|mirtazapine|reboxetine|tryptophan|venlafaxine)")
replace antidepress = 1 if regexm(productname_1, "(triptafen|anafranil|prothiaden|sinepin|allegron|surmontil|molipaxin|nardil|manerix|cipramil|cipralex|prozac|faverin|seroxat|lustral|valdoxan|cymbalta|yentreve|depixol|zispin|edronax|efexor)")
replace antidepress = 1 if regexm(productname_1, "(amitriptyline|clomipramine|dosulepin|dothiepin|doxepin|imipramine|lofepramine|nortriptyline|trimipramine|mianserin|trazodone|phenelzine|isocarboxazid|tranylcypromine|moclobemide|citalopram|escitalopram|fluoxetine|fluvoxamine|paroxetine|sertraline|agomelatine|duloxetine|flupentixol|mirtazapine|reboxetine|tryptophan|venlafaxine)")
label variable antidepress "Antidepressant exposure:0=no exp, 1=exp"
keep if antidepress==1
drop antidepress
export excel prodcode gemscriptcode productname using cov_drugcodes.xls, sheet("antidepress") sheetmodify firstrow(variables)

//Antiobesity
use product.dta, clear
rename productname productname_1
rename drugsubstance drugsubstance_1
gen antiobes = 0
replace antiobes = 1 if regexm(prod_bnfcode, "0405....")
replace antiobes = 1 if regexm(drugsubstance_1, "(xenical)")
replace antiobes = 1 if regexm(drugsubstance_1, "(orlistat)")
replace antiobes = 1 if regexm(productname_1, "(xenical)")
replace antiobes = 1 if regexm(productname_1, "(orlistat)")
label variable antiobes "Antiobesity drug exposure:0=no exp, 1=exp"
keep if antiobes==1
drop antiobes
export excel prodcode gemscriptcode productname using cov_drugcodes.xls, sheet("antiobes") sheetmodify firstrow(variables)

//Opioid analgesics (CNS)
use product.dta, clear
rename productname productname_1
rename drugsubstance drugsubstance_1
gen opioid1 = 0
replace opioid1 = 1 if regexm(prod_bnfcode, "040702..|15010403")
replace opioid1 = 1 if regexm(drugsubstance_1, "(temgesic|butrans|transtec|df118 forte|dhc continus| abstral|effentora|actiq|instanyl|pecfent|durogesic|palladone|meptid|oramorph|sevredol|filnarine|morphgesic|mst continus|zomorph|mxl|cyclimorph|oxynorm|oxycontin|targincat|pamergan|palexia|zamadol|zydol|larapam|mabron|marol|maxitram|tramquel|zeridame|tradorec)")
replace opioid1 = 1 if regexm(drugsubstance_1, "(buprenorphine|codeine|diamorphine|heroin|dihydrocodeine|dipipanone|fentanyl|hydromorphone|meptazinol|methadone|morphine|oxycodone|papaveretum|pentazocine|pethidine|tapentadol|tramadol)")
replace opioid1 = 1 if regexm(productname_1, "(temgesic|butrans|transtec|df118 forte|dhc continus| abstral|effentora|actiq|instanyl|pecfent|durogesic|palladone|meptid|oramorph|sevredol|filnarine|morphgesic|mst continus|zomorph|mxl|cyclimorph|oxynorm|oxycontin|targincat|pamergan|palexia|zamadol|zydol|larapam|mabron|marol|maxitram|tramquel|zeridame|tradorec)")
replace opioid1 = 1 if regexm(productname_1, "(buprenorphine|codeine|diamorphine|heroin|dihydrocodeine|dipipanone|fentanyl|hydromorphone|meptazinol|methadone|morphine|oxycodone|papaveretum|pentazocine|pethidine|tapentadol|tramadol)")
label variable opioid1 "Opioid analgesic (CNS) exposure:0=no exp, 1=exp"
keep if opioid1==1
drop opioid1
export excel prodcode gemscriptcode productname using cov_drugcodes.xls, sheet("opioid1") sheetmodify firstrow(variables)

//Antiepileptics
use product.dta, clear
rename productname productname_1
rename drugsubstance drugsubstance_1
gen antiepilep = 0
replace antiepilep = 1 if regexm(prod_bnfcode, "0408....")
replace antiepilep = 1 if regexm(drugsubstance_1, "(tegretol|carbagen|zebinix|trileptal|emeside|zarontin|neurontin|lyrica|vimapt|lamictal|keppra|fycompa|mysoline|epanutin|trobalt|inovelon|gabitril|topamax|epilim|episenta|epival|convulex|depakote|sabril|zongran|rivotril|buccolam)")
replace antiepilep = 1 if regexm(drugsubstance_1, "(carbamazepine|eslicarbazepine|oxcarbazapine|ethosuximide|gabapentin|pregabalin|lacosamide|lamotrigine|levetiracetam|perampanel|phenobarbital|phenobarbitone|primidone|phenytoin|retigabine|rufinamide|tiagabine|topiramate|valproate|vigabatrin|zonisamide|clobazam|clonazepam|diazepam|fosphenytoin|lorazepam|midazolam)")
replace antiepilep = 1 if regexm(productname_1, "(tegretol|carbagen|zebinix|trileptal|emeside|zarontin|neurontin|lyrica|vimapt|lamictal|keppra|fycompa|mysoline|epanutin|trobalt|inovelon|gabitril|topamax|epilim|episenta|epival|convulex|depakote|sabril|zongran|rivotril|buccolam)")
replace antiepilep = 1 if regexm(productname_1, "(carbamazepine|eslicarbazepine|oxcarbazapine|ethosuximide|gabapentin|pregabalin|lacosamide|lamotrigine|levetiracetam|perampanel|phenobarbital|phenobarbitone|primidone|phenytoin|retigabine|rufinamide|tiagabine|topiramate|valproate|vigabatrin|zonisamide|clobazam|clonazepam|diazepam|fosphenytoin|lorazepam|midazolam)")
label variable antiepilep "Antiepileptic exposure:0=no exp, 1=exp"
keep if antiepilep==1
drop antiepilep
export excel prodcode gemscriptcode productname using cov_drugcodes.xls, sheet("antiepilep") sheetmodify firstrow(variables)

//Antiparkinsons, dopaminergic
use product.dta, clear
rename productname productname_1
rename drugsubstance drugsubstance_1
gen antipark_dop = 0
replace antipark_dop = 1 if regexm(prod_bnfcode, "040901..")
replace antipark_dop = 1 if regexm(drugsubstance_1, "(apogo|cabaser|mirapexin|adartrel|requip|neupro|madopar|sinemet|duodopa|caramet|stalevo|azilect|eldepryl|zelapar|comtess|tasmar|symmetrel|lysovir)")
replace antipark_dop = 1 if regexm(drugsubstance_1, "(apomorphine|bromocriptine|cabergoline|pergolide|pramipexole|ropinirole|rotigotine|co-beneldopa|co-careldopa|rasagiline|selegiline|entacapone|tolcapone|amantadine|levodopa)")
replace antipark_dop = 1 if regexm(productname_1, "(apogo|cabaser|mirapexin|adartrel|requip|neupro|madopar|sinemet|duodopa|caramet|stalevo|azilect|eldepryl|zelapar|comtess|tasmar|symmetrel|lysovir)")
replace antipark_dop = 1 if regexm(productname_1, "(apomorphine|bromocriptine|cabergoline|pergolide|pramipexole|ropinirole|rotigotine|co-beneldopa|co-careldopa|rasagiline|selegiline|entacapone|tolcapone|amantadine|levodopa)")
label variable antipark_dop "Antiparkison's dopaminergic drug exposure:0=no exp, 1=exp"
keep if antipark_dop==1
drop antipark_dop
export excel prodcode gemscriptcode productname using cov_drugcodes.xls, sheet("antipark_dop") sheetmodify firstrow(variables)

//Penicillin
use product.dta, clear
rename productname productname_1
rename drugsubstance drugsubstance_1
gen penicillin = 0
replace penicillin = 1 if regexm(prod_bnfcode, "050101..")
replace penicillin = 1 if regexm(drugsubstance_1, "(crystapen|negaban|amoxil|penbritin|augmentin|magnapen|tazocin|timentin|selexid)")
replace penicillin = 1 if regexm(drugsubstance_1, "(benzylpenicillin|penicillin g|phenoxymethylpenicillin|penicillin v|flucloxacillin|temocillin|amoxicillin|amoxycillin|ampicillin|co-amoxiclav|co-fluampicil|piperacillin with tazobactam|ticarcillin with calvulanic acid|pivmecillinam)")
replace penicillin = 1 if regexm(productname_1, "(crystapen|negaban|amoxil|penbritin|augmentin|magnapen|tazocin|timentin|selexid)")
replace penicillin = 1 if regexm(productname_1, "(benzylpenicillin|penicillin g|phenoxymethylpenicillin|penicillin v|flucloxacillin|temocillin|amoxicillin|amoxycillin|ampicillin|co-amoxiclav|co-fluampicil|piperacillin with tazobactam|ticarcillin with calvulanic acid|pivmecillinam)")
label variable penicillin "Penicillin exposure: 0=no exp, 1=exp"
keep if penicillin==1
drop penicillin
export excel prodcode gemscriptcode productname using cov_drugcodes.xls, sheet("penicillin") sheetmodify firstrow(variables)

// Cephalosporins, carbapenems and other beta-lactams
use product.dta, clear
rename productname productname_1
rename drugsubstance drugsubstance_1
gen ceph_carb_betalac = 0
replace ceph_carb_betalac = 1 if regexm(prod_bnfcode, "050102..")
replace ceph_carb_betalac = 1 if regexm(drugsubstance_1, "(distaclor|ceporex|keflex|suprax|orelox|zinforo|fortum|kefadim|rocephin|zinacef|zinnat|doribax|invanz|primaxin|meronem|azactam|cayston)")
replace ceph_carb_betalac = 1 if regexm(drugsubstance_1, "(cefaclor|cefadroxil|cefalexin|cephalexin|cefixime|cefotaxime|cefpodoxime|cefradine|ceftaroline|ceftazidime|ceftriaxone|cefuroxime|doripenem|ertapenem|imipenem with cilastatin|meropenem|aztreonam)")
replace ceph_carb_betalac = 1 if regexm(productname_1, "(distaclor|ceporex|keflex|suprax|orelox|zinforo|fortum|kefadim|rocephin|zinacef|zinnat|doribax|invanz|primaxin|meronem|azactam|cayston)")
replace ceph_carb_betalac = 1 if regexm(productname_1, "(cefaclor|cefadroxil|cefalexin|cephalexin|cefixime|cefotaxime|cefpodoxime|cefradine|ceftaroline|ceftazidime|ceftriaxone|cefuroxime|doripenem|ertapenem|imipenem with cilastatin|meropenem|aztreonam)")
label variable ceph_carb_betalac "Cephalosporins, carbapenems and other beta-lactams exposure: 0=no exp, 1=exp"
keep if ceph_carb_betalac==1
drop ceph_carb_betalac
export excel prodcode gemscriptcode productname using cov_drugcodes.xls, sheet("ceph_carb_betalac") sheetmodify firstrow(variables)

//Tetracyclines
use product.dta, clear
rename productname productname_1
rename drugsubstance drugsubstance_1
gen tetracyc = 0
replace tetracyc = 1 if regexm(prod_bnfcode, "050103..")
replace tetracyc = 1 if regexm(drugsubstance_1, "(vibramycin|efracea|tetralysal|tygacil)")
replace tetracyc = 1 if regexm(drugsubstance_1, "(tetracycline|demeclocycline|doxycycline|lymecycline|minocycline|oxytetracycline|tigecycline)")
replace tetracyc = 1 if regexm(productname_1, "(vibramycin|efracea|tetralysal|tygacil)")
replace tetracyc = 1 if regexm(productname_1, "(tetracycline|demeclocycline|doxycycline|lymecycline|minocycline|oxytetracycline|tigecycline)")
label variable tetracyc "Tetracycline exposure: 0=no exp, 1=exp"
keep if tetracyc==1
drop tetracyc
export excel prodcode gemscriptcode productname using cov_drugcodes.xls, sheet("tetracyc") sheetmodify firstrow(variables)

//Aminoglycosides
use product.dta, clear
rename productname productname_1
rename drugsubstance drugsubstance_1
gen aminoglyc = 0
replace aminoglyc = 1 if regexm(prod_bnfcode, "050104..")
replace aminoglyc = 1 if regexm(drugsubstance_1, "(cidomycin|genticin|amikin|bramitob|tobi)")
replace aminoglyc = 1 if regexm(drugsubstance_1, "(gentamicin|amikacin|neomycin|tobramycin)")
replace aminoglyc = 1 if regexm(productname_1, "(cidomycin|genticin|amikin|bramitob|tobi)")
replace aminoglyc = 1 if regexm(productname_1, "(gentamicin|amikacin|neomycin|tobramycin)")
label variable aminoglyc "Aminoglycoside exposure: 0=no exp, 1=exp"
keep if aminoglyc==1
drop aminoglyc
export excel prodcode gemscriptcode productname using cov_drugcodes.xls, sheet("aminoglyc") sheetmodify firstrow(variables)

//Macrolides
use product.dta, clear
rename productname productname_1
rename drugsubstance drugsubstance_1
gen macrolide = 0
replace macrolide = 1 if regexm(prod_bnfcode, "050105..")
replace macrolide = 1 if regexm(drugsubstance_1, "(zithromax|klaricid|erymax|erythrocin|erythroped|ketek)")
replace macrolide = 1 if regexm(drugsubstance_1, "(azithromycin|clarithromycin|erythromycin|telithromycin)")
replace macrolide = 1 if regexm(productname_1, "(zithromax|klaricid|erymax|erythrocin|erythroped|ketek)")
replace macrolide = 1 if regexm(productname_1, "(azithromycin|clarithromycin|erythromycin|telithromycin)")
label variable macrolide "Macrolide exposure: 0=no exp, 1=exp"
keep if macrolide==1
drop macrolide
export excel prodcode gemscriptcode productname using cov_drugcodes.xls, sheet("macrolide") sheetmodify firstrow(variables)

//Clindamycin
use product.dta, clear
rename productname productname_1
rename drugsubstance drugsubstance_1
gen clinda = 0
replace clinda = 1 if regexm(prod_bnfcode, "050106..")
replace clinda = 1 if regexm(drugsubstance_1, "(dalacin)")
replace clinda = 1 if regexm(drugsubstance_1, "(clindamycin)")
replace clinda = 1 if regexm(productname_1, "(dalacin)")
replace clinda = 1 if regexm(productname_1, "(clindamycin)")
label variable clinda "Clindamycin exposure: 0=no exp, 1=exp"
keep if clinda==1
drop clinda
export excel prodcode gemscriptcode productname using cov_drugcodes.xls, sheet("clinda") sheetmodify firstrow(variables)

//Some other antibiotics
use product.dta, clear
rename productname productname_1
rename drugsubstance drugsubstance_1
gen otherantibiot = 0
replace otherantibiot = 1 if regexm(prod_bnfcode, "050107..")
replace otherantibiot = 1 if regexm(drugsubstance_1, "(kemicetine|fucidin|vancocin|targocid|cubicin|zyvox|colomycin|promixin|colobreathe|targaxan|xifaxanta|dificlir)")
replace otherantibiot = 1 if regexm(drugsubstance_1, "(chloramphenicol|sodium fusidate|vancomycin|teicoplanin|daptomycin|linezolid|colistimethate|colistin sulfomethate|rifaximin|fidaxomycin)")
replace otherantibiot = 1 if regexm(productname_1, "(kemicetine|fucidin|vancocin|targocid|cubicin|zyvox|colomycin|promixin|colobreathe|targaxan|xifaxanta|dificlir)")
replace otherantibiot = 1 if regexm(productname_1, "(chloramphenicol|sodium fusidate|vancomycin|teicoplanin|daptomycin|linezolid|colistimethate|colistin sulfomethate|rifaximin|fidaxomycin)")
label variable otherantibiot "Other antibiotic exposure: 0=no exp, 1=exp"
keep if otherantibiot==1
drop otherantibiot
export excel prodcode gemscriptcode productname using cov_drugcodes.xls, sheet("otherantibiot") sheetmodify firstrow(variables)

// Sulfonamides and trimethoprim
use product.dta, clear
rename productname productname_1
rename drugsubstance drugsubstance_1
gen sulfo_trimeth = 0
replace sulfo_trimeth = 1 if regexm(prod_bnfcode, "050108..")
replace sulfo_trimeth = 1 if regexm(drugsubstance_1, "(septrin)")
replace sulfo_trimeth = 1 if regexm(drugsubstance_1, "(co-trimoxazole|sulfadiazine|sulphadiazine|trimethoprim)")
replace sulfo_trimeth = 1 if regexm(productname_1, "(septrin)")
replace sulfo_trimeth = 1 if regexm(productname_1, "(co-trimoxazole|sulfadiazine|sulphadiazine|trimethoprim)")
label variable sulfo_trimeth "Sulfonamides and trimethoprim exposure: 0=no exp, 1=exp"
keep if sulfo_trimeth==1 
drop sulfo_trimeth
export excel prodcode gemscriptcode productname using cov_drugcodes.xls, sheet("sulfo_trimeth") sheetmodify firstrow(variables)

//Antituberculosis drugs
use product.dta, clear
rename productname productname_1
rename drugsubstance drugsubstance_1
gen antituberc = 0
replace antituberc = 1 if regexm(prod_bnfcode, "050109..")
replace antituberc = 1 if regexm(drugsubstance_1, "(zinamide|mycobutin|rifadin|rimactane|rifater|rifinah|voractiv)")
replace antituberc = 1 if regexm(drugsubstance_1, "(capreomycin|cycloserine|ethambutol|isoniazid|pyrazinamide|rifabutin|rifampicin|streptomycin)")
replace antituberc = 1 if regexm(productname_1, "(zinamide|mycobutin|rifadin|rimactane|rifater|rifinah|voractiv)")
replace antituberc = 1 if regexm(productname_1, "(capreomycin|cycloserine|ethambutol|isoniazid|pyrazinamide|rifabutin|rifampicin|streptomycin)")
label variable antituberc "Antituberculosis drug exposure: 0=no exp, 1=exp"
keep if antituberc==1
drop antituberc
export excel prodcode gemscriptcode productname using cov_drugcodes.xls, sheet("antituberc") sheetmodify firstrow(variables)

//Antileprotic drugs
use product.dta, clear
rename productname productname_1
rename drugsubstance drugsubstance_1
gen antileprotic = 0
replace antileprotic = 1 if regexm(prod_bnfcode, "050110..")
replace antileprotic = 1 if regexm(drugsubstance_1, "(dapsone|clofazimine)")
replace antileprotic = 1 if regexm(productname_1, "(dapsone|clofazimine)")
label variable antileprotic "Antileprotic drug exposure: 0=no exp, 1=exp"
keep if antileprotic==1
drop antileprotic
export excel prodcode gemscriptcode productname using cov_drugcodes.xls, sheet("antileprotic") sheetmodify firstrow(variables)

// Metronidazole and tinidazole 
use product.dta, clear
rename productname productname_1
rename drugsubstance drugsubstance_1
gen metro_tinidazole = 0
replace metro_tinidazole = 1 if regexm(prod_bnfcode, "050111..")
replace metro_tinidazole = 1 if regexm(drugsubstance_1, "(flagyl|metrolyl|fasigyn)")
replace metro_tinidazole = 1 if regexm(drugsubstance_1, "(metronidazole|tinidazole)")
replace metro_tinidazole = 1 if regexm(productname_1, "(flagyl|metrolyl|fasigyn)")
replace metro_tinidazole = 1 if regexm(productname_1, "(metronidazole|tinidazole)")
label variable metro_tinidazole "Metronidazole and tinidazole exposure: 0=no exp, 1=exp"
keep if metro_tinidazole==1
drop metro_tinidazole
export excel prodcode gemscriptcode productname using cov_drugcodes.xls, sheet("metro_tinidazole") sheetmodify firstrow(variables)

//Quinolones
use product.dta, clear
rename productname productname_1
rename drugsubstance drugsubstance_1
gen quinolone = 0
replace quinolone = 1 if regexm(prod_bnfcode, "050112..")
replace quinolone = 1 if regexm(drugsubstance_1, "(ciproxin|tavanic|avelox|utinor|tarivid)")
replace quinolone = 1 if regexm(drugsubstance_1, "(ciprofloxacin|levofloxacin|moxifloxacin|nalidixic|norfloxacin|ofloxacin)")
replace quinolone = 1 if regexm(productname_1, "(ciproxin|tavanic|avelox|utinor|tarivid)")
replace quinolone = 1 if regexm(productname_1, "(ciprofloxacin|levofloxacin|moxifloxacin|nalidixic|norfloxacin|ofloxacin)")
label variable quinolone "Quinolone exposure: 0=no exp, 1=exp"
keep if quinolone==1
drop quinolone
export excel prodcode gemscriptcode productname using cov_drugcodes.xls, sheet("quinolone") sheetmodify firstrow(variables)

//UTI drugs
use product.dta, clear
rename productname productname_1
rename drugsubstance drugsubstance_1
gen uti_drugs = 0
replace uti_drugs = 1 if regexm(prod_bnfcode, "050113..") 
replace uti_drugs = 1 if regexm(drugsubstance_1, "(furadantin|macrodantin|macrobid|hiprex)") 
replace uti_drugs = 1 if regexm(drugsubstance_1, "(nitrofurantoin|methenamine hippurate|hexamine hippurate)") 
replace uti_drugs = 1 if regexm(productname_1, "(furadantin|macrodantin|macrobid|hiprex)") 
replace uti_drugs = 1 if regexm(productname_1, "(nitrofurantoin|methenamine hippurate|hexamine hippurate)") 
label variable uti_drugs "UTI drug exposure: 0=no exp, 1=exp"
keep if uti_drugs==1
drop uti_drugs
export excel prodcode gemscriptcode productname using cov_drugcodes.xls, sheet("uti_drugs") sheetmodify firstrow(variables)

//Antifungal drugs
use product.dta, clear
rename productname productname_1
rename drugsubstance drugsubstance_1
gen antifungal = 0
replace antifungal = 1 if regexm(prod_bnfcode, "0502....")
replace antifungal = 1 if regexm(drugsubstance_1, "(diflucan|sporanox|noxafil|vfend|nizoral|fungizone|abelcet|ambisome|ecalta|cancidas|mycamine|ancotil|fulsovin|lamisil)")
replace antifungal = 1 if regexm(drugsubstance_1, "(fluconazole|itraconazole|posaconazole|voriconazole|ketoconazole|amphotericin|anidulafungin|caspofungin|micafungin|flucytosine|griseofulvin|terbinafine)")
replace antifungal = 1 if regexm(productname_1, "(diflucan|sporanox|noxafil|vfend|nizoral|fungizone|abelcet|ambisome|ecalta|cancidas|mycamine|ancotil|fulsovin|lamisil)")
replace antifungal = 1 if regexm(productname_1, "(fluconazole|itraconazole|posaconazole|voriconazole|ketoconazole|amphotericin|anidulafungin|caspofungin|micafungin|flucytosine|griseofulvin|terbinafine)")
label variable antifungal "Antifungal exposure:0=no exp, 1=exp"
keep if antifungal==1
drop antifungal
export excel prodcode gemscriptcode productname using cov_drugcodes.xls, sheet("antifungal") sheetmodify firstrow(variables)

//Antiviral drugs
use product.dta, clear
rename productname productname_1
rename drugsubstance drugsubstance_1
gen antiviral = 0
replace antiviral = 1 if regexm(prod_bnfcode, "0503....")
replace antiviral = 1 if regexm(drugsubstance_1, "(ziagen|kivexa|trizivir|videx|emtriva|epivir|zeffix|zerit|viread|truvada|atripla|eviplera|retrovir|combivir|reyataz|prezista|telzir|crixivan|kaletra|norvir|invirase|aptivus|sustiva|intelence|viramune|edurant|fuzeon|celsentri|isentress|zorivax|famvir|imunovir|valtrex|vistide|cymevene|foscavir|valcyte|hepsera|baraclude|sebivo|victrelis|incivo|lysovir|symmetrel|tamiflu|relenza|synagis|copegus|rebetol|virazole)")
replace antiviral = 1 if regexm(drugsubstance_1, "(abacavir|didanosine|ddi|emtricitabine|ftc|lamivudine|3tc|stavudine|d4t|tenofovir disoproxil|zidovudine|zidovudine and lamivudine|azidothymadine|azt|atazanavir|darunavir|fosamprenavir|indinavir|lopinavir with ritonavir|ritonavir|saquinavir|tipranavir|efavirenz|etravirine|nevirapine|rilpivirine|enfuvirtide|maraviroc|raltegravir|aciclovir|acyclovir|famciclovir|inosine pranobex|inosine acedoben dimepranol|valaciclovir|cidofovir|ganciclovir|foscarnet|valganciclovir|adefovir dipivoxil|entecavir|telbivudine|boceprevir|telaprevir|amantadine|oseltamivir|zanamivir|palivizumab|ribavirin|tribavirin)")
replace antiviral = 1 if regexm(productname_1, "(ziagen|kivexa|trizivir|videx|emtriva|epivir|zeffix|zerit|viread|truvada|atripla|eviplera|retrovir|combivir|reyataz|prezista|telzir|crixivan|kaletra|norvir|invirase|aptivus|sustiva|intelence|viramune|edurant|fuzeon|celsentri|isentress|zorivax|famvir|imunovir|valtrex|vistide|cymevene|foscavir|valcyte|hepsera|baraclude|sebivo|victrelis|incivo|lysovir|symmetrel|tamiflu|relenza|synagis|copegus|rebetol|virazole)")
replace antiviral = 1 if regexm(productname_1, "(abacavir|didanosine|ddi|emtricitabine|ftc|lamivudine|3tc|stavudine|d4t|tenofovir disoproxil|zidovudine|zidovudine and lamivudine|azidothymadine|azt|atazanavir|darunavir|fosamprenavir|indinavir|lopinavir with ritonavir|ritonavir|saquinavir|tipranavir|efavirenz|etravirine|nevirapine|rilpivirine|enfuvirtide|maraviroc|raltegravir|aciclovir|acyclovir|famciclovir|inosine pranobex|inosine acedoben dimepranol|valaciclovir|cidofovir|ganciclovir|foscarnet|valganciclovir|adefovir dipivoxil|entecavir|telbivudine|boceprevir|telaprevir|amantadine|oseltamivir|zanamivir|palivizumab|ribavirin|tribavirin)")
label variable antiviral "Antiviral exposure:0=no exp, 1=exp"
keep if antiviral==1
drop antiviral
export excel prodcode gemscriptcode productname using cov_drugcodes.xls, sheet("antiviral") sheetmodify firstrow(variables)

//Antiprotozoal drugs
use product.dta, clear
rename productname productname_1
rename drugsubstance drugsubstance_1
gen antiprotoz = 0
replace antiprotoz = 1 if regexm(prod_bnfcode, "0504....")
replace antiprotoz = 1 if regexm(drugsubstance_1, "(riamet|avloclor|malarivon|nivaquine|paludrine/avloclor|lariam|eurartesim|paludrine|malarone|daraprim|diloxanide|pentostam|wellvone|pentacarinat)")
replace antiprotoz = 1 if regexm(drugsubstance_1, "(artemether with lumefantrine|chloroquine|mefloquine|piperaquine phosphate with artenimol| piperaquine tetraphosphate with dihydroartemisinin|primaquine|proguanil|proguanil hydrochloride with atovaquone|pyrimethamine|pyrimethamine with sulfadoxine|quinine|doxycycline|diloxanide furoate|metronidazole|tinidazole|mepacrine|sodium stibogluconate|atovaquone|pentamidine isetionate)")
replace antiprotoz = 1 if regexm(productname_1, "(riamet|avloclor|malarivon|nivaquine|paludrine/avloclor|lariam|eurartesim|paludrine|malarone|daraprim|diloxanide|pentostam|wellvone|pentacarinat)")
replace antiprotoz = 1 if regexm(productname_1, "(artemether with lumefantrine|chloroquine|mefloquine|piperaquine phosphate with artenimol| piperaquine tetraphosphate with dihydroartemisinin|primaquine|proguanil|proguanil hydrochloride with atovaquone|pyrimethamine|pyrimethamine with sulfadoxine|quinine|doxycycline|diloxanide furoate|metronidazole|tinidazole|mepacrine|sodium stibogluconate|atovaquone|pentamidine isetionate)")
label variable antiprotoz "Antiprotozoal exposure:0=no exp, 1=exp"
keep if antiprotoz==1
drop antiprotoz
export excel prodcode gemscriptcode productname using cov_drugcodes.xls, sheet("antiprotoz") sheetmodify firstrow(variables)

//Antihelminthics
use product.dta, clear
rename productname productname_1
rename drugsubstance drugsubstance_1
gen anthelmintic = 0 
replace anthelmintic = 1 if regexm(prod_bnfcode, "0505....")
replace anthelmintic = 1 if regexm(drugsubstance_1, "(vermox|pripsen)")
replace anthelmintic = 1 if regexm(drugsubstance_1, "(mebendazole|piperazine)")
replace anthelmintic = 1 if regexm(productname_1, "(vermox|pripsen)")
replace anthelmintic = 1 if regexm(productname_1, "(mebendazole|piperazine)")
label variable anthelmintic "Anthelmintic exposure:0=no exp, 1=exp"
keep if anthelmintic==1
drop anthelmintic
export excel prodcode gemscriptcode productname using cov_drugcodes.xls, sheet("anthelmintic") sheetmodify firstrow(variables)

//Thyroid hormones
use product.dta, clear
rename productname productname_1
rename drugsubstance drugsubstance_1
gen thyroidhorm = 0
replace thyroidhorm = 1 if regexm(prod_bnfcode, "060201..")
replace thyroidhorm = 1 if regexm(drugsubstance_1, "(triiodothyronine)")
replace thyroidhorm = 1 if regexm(drugsubstance_1, "(levothyroxine|liothyronine)")
replace thyroidhorm = 1 if regexm(productname_1, "(triiodothyronine)")
replace thyroidhorm = 1 if regexm(productname_1, "(levothyroxine|liothyronine)")
label variable thyroidhorm "Thyroid hormone exposure: 0=no exp, 1=exp"
keep if thyroidhorm==1
drop thyroidhorm
export excel prodcode gemscriptcode productname using cov_drugcodes.xls, sheet("thyroidhorm") sheetmodify firstrow(variables)

//Corticosteroids (endocrine)
use product.dta, clear
rename productname productname_1
rename drugsubstance drugsubstance_1
gen cortico_endocr = 0 
replace cortico_endocr = 1 if regexm(prod_bnfcode, "0603....") 
replace cortico_endocr = 1 if regexm(drugsubstance_1, "(betnesol|calcort|efcortesol|solu-cortef|plenadren|medrone|solu-medrone|depo-medrone|lodotra|kenalog)") 
replace cortico_endocr = 1 if regexm(drugsubstance_1, "(betamethasone|deflazacort|dexamethasone|hydrocortisone|methylprednisolone|prednisolone|prednisone|triamcinolone)") 
replace cortico_endocr = 1 if regexm(productname_1, "(betnesol|calcort|efcortesol|solu-cortef|plenadren|medrone|solu-medrone|depo-medrone|lodotra|kenalog)") 
replace cortico_endocr = 1 if regexm(productname_1, "(betamethasone|deflazacort|dexamethasone|hydrocortisone|methylprednisolone|prednisolone|prednisone|triamcinolone)") 
label variable cortico_endocr "Corticosteroid (endocrine) exposure:0=no exp, 1=exp"
keep if cortico_endocr==1
drop cortico_endocr
export excel prodcode gemscriptcode productname using cov_drugcodes.xls, sheet("cortico_endocr") sheetmodify firstrow(variables)

//Estrogens and HRT
use product.dta, clear
rename productname productname_1
rename drugsubstance drugsubstance_1
gen estro_hrt = 0
replace estro_hrt = 1 if regexm(prod_bnfcode, "06040101")
replace estro_hrt = 1 if regexm(drugsubstance_1, "(premique|prempak-c|angeliq|climagest|climesse|clinorette|cyclo-progynova|elleste-duet|evorel|femoston|femseven conti|femseven sequi|indivina|kilofem|kilovance|novofem|nuvelle|tridestra|trisequens|premarin|bedol|climaval|elleste-solo|elleste solo|estraderm|estradot|oestrogel|progynova|sandrena|zumenon|hormonin|livial|evista)")
replace estro_hrt = 1 if regexm(drugsubstance_1, "(tibolone|ethinylestradiol|ethinyloestradiol|raloxifene)")
replace estro_hrt = 1 if regexm(productname_1, "(premique|prempak-c|angeliq|climagest|climesse|clinorette|cyclo-progynova|elleste-duet|evorel|femoston|femseven conti|femseven sequi|indivina|kilofem|kilovance|novofem|nuvelle|tridestra|trisequens|premarin|bedol|climaval|elleste-solo|elleste solo|estraderm|estradot|oestrogel|progynova|sandrena|zumenon|hormonin|livial|evista)")
replace estro_hrt = 1 if regexm(productname_1, "(tibolone|ethinylestradiol|ethinyloestradiol|raloxifene)")
label variable estro_hrt "Estrogen and HRT exposure: 0=no exp, 1=exp"
keep if estro_hrt==1
drop estro_hrt
export excel prodcode gemscriptcode productname using cov_drugcodes.xls, sheet("estro_hrt") sheetmodify firstrow(variables)

//Bisphosphonates
use product.dta, clear
rename productname productname_1
rename drugsubstance drugsubstance_1
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
keep if bisphos==1
drop bisphos
export excel prodcode gemscriptcode productname using cov_drugcodes.xls, sheet("bisphos") sheetmodify firstrow(variables)

//Cytotoxic drugs
use product.dta, clear
rename productname productname_1
rename drugsubstance drugsubstance_1
gen cytotoxic = 0
replace cytotoxic = 1 if regexm(prod_bnfcode, "0801....")
replace cytotoxic = 1 if regexm(drugsubstance_1, "(levact|myleran|busilvex|gliadel|leukeran|estracyt|alkeran|tepadina|daunoxome|caelyx|myocet|pharmorubicin|zavedos|onkotrone|vidaza|xeloda|leustat|litak|evoltra|depocyte|dacogen|fludara|gemzar|puri-nethol|xaluprine|atriance|alimta|tomudex|teysuno|lanvis|etopophos|vepesid|velbe|oncovin|eldisine|javlor|navelbine|amsidine|trisenox|avastin|targretin|velcade|adcetris|removab|erbitux|erwinase|temodal|halaven|hydrea|yervoy|lysodren|vectibix|nipent|perjeta|photofrin|foscan|inlyta|xalkori|sprycel|tarceva|afinitor|votubia|iressa|glivec|tyverb|tasigna|votrient|jakavi|nexavar|sutent|torisel|caprelsa|zelboraf|jevtana|taxotere|abraxane|campto|hycamtin|yondelis|herceptin|vesanoid)")
replace cytotoxic = 1 if regexm(drugsubstance_1, "(bendamustine|busulfan|busulphan|carmustine|chlorambucil|cyclophosphamide|estramustine|ifosfamide|lomustine|melphalan|thiotepa|treosulfan|bleomycin|dactinomycin|actinomycin d|daunorubicin|doxorubicin|epirubicin|idarubicin|mitomycin|mitoxantrone|mitozantrone|azacitidine|capecitabine|cladribine|clofarabine|cytarabine|decitabine|fludarabine|fluorouracil|gemcitabine|mercaptopurine|6-mercaptopurine|methotrexate|nelarabine|pemetrexed|raltitrexed|tegafur with gemeracil and oteracil|tioguanine|thioguanine|etoposide|vnblastine|vincristine|vindesine|vinflunine|vinorelbine|amsacrine|arsenic trioxide|bevacizumab|bexarotene|bortezomib|brentuximab vedotin|catumaxomab|cetuximab|crisantaspase|dacarbazine|temozolomide|eribulin|hydroxycarbamide|hydroxyurea|ipilimumab|mitotane|panitumumab|pentostatin|pertuzumab|carboplatin|cisplatin|oxaliplatin|porfimer|temoporfin|procarbazine|axitinib|crizotinib|dasatinib|erlotinib|everolimus|gefitinib|imatinib|lapatinib|nilotinib|pazopanib|ruxolitinib|sorafenib|sunitinib|temsirolimus|vandetanib|vemurafenib|cabazitaxel|docetaxel|paclitaxel|irinotecan|topotecan|trabectedin|trastuzumab|tretinoin)")
replace cytotoxic = 1 if regexm(productname_1, "(levact|myleran|busilvex|gliadel|leukeran|estracyt|alkeran|tepadina|daunoxome|caelyx|myocet|pharmorubicin|zavedos|onkotrone|vidaza|xeloda|leustat|litak|evoltra|depocyte|dacogen|fludara|gemzar|puri-nethol|xaluprine|atriance|alimta|tomudex|teysuno|lanvis|etopophos|vepesid|velbe|oncovin|eldisine|javlor|navelbine|amsidine|trisenox|avastin|targretin|velcade|adcetris|removab|erbitux|erwinase|temodal|halaven|hydrea|yervoy|lysodren|vectibix|nipent|perjeta|photofrin|foscan|inlyta|xalkori|sprycel|tarceva|afinitor|votubia|iressa|glivec|tyverb|tasigna|votrient|jakavi|nexavar|sutent|torisel|caprelsa|zelboraf|jevtana|taxotere|abraxane|campto|hycamtin|yondelis|herceptin|vesanoid)")
replace cytotoxic = 1 if regexm(productname_1, "(bendamustine|busulfan|busulphan|carmustine|chlorambucil|cyclophosphamide|estramustine|ifosfamide|lomustine|melphalan|thiotepa|treosulfan|bleomycin|dactinomycin|actinomycin d|daunorubicin|doxorubicin|epirubicin|idarubicin|mitomycin|mitoxantrone|mitozantrone|azacitidine|capecitabine|cladribine|clofarabine|cytarabine|decitabine|fludarabine|fluorouracil|gemcitabine|mercaptopurine|6-mercaptopurine|methotrexate|nelarabine|pemetrexed|raltitrexed|tegafur with gemeracil and oteracil|tioguanine|thioguanine|etoposide|vnblastine|vincristine|vindesine|vinflunine|vinorelbine|amsacrine|arsenic trioxide|bevacizumab|bexarotene|bortezomib|brentuximab vedotin|catumaxomab|cetuximab|crisantaspase|dacarbazine|temozolomide|eribulin|hydroxycarbamide|hydroxyurea|ipilimumab|mitotane|panitumumab|pentostatin|pertuzumab|carboplatin|cisplatin|oxaliplatin|porfimer|temoporfin|procarbazine|axitinib|crizotinib|dasatinib|erlotinib|everolimus|gefitinib|imatinib|lapatinib|nilotinib|pazopanib|ruxolitinib|sorafenib|sunitinib|temsirolimus|vandetanib|vemurafenib|cabazitaxel|docetaxel|paclitaxel|irinotecan|topotecan|trabectedin|trastuzumab|tretinoin)")
label variable cytotoxic "Cytotoxic drug exposure:0=no exp, 1=exp"
keep if cytotoxic==1
drop cytotoxic
export excel prodcode gemscriptcode productname using cov_drugcodes.xls, sheet("cytotoxic") sheetmodify firstrow(variables)

//Antiproliferative immunosuppressants
use product.dta, clear
rename productname productname_1
rename drugsubstance drugsubstance_1
gen antiprolif = 0 
replace antiprolif = 1 if regexm(prod_bnfcode, "080201..")
replace antiprolif = 1 if regexm(drugsubstance_1, "(imuran|cellcept|myofortic )")
replace antiprolif = 1 if regexm(drugsubstance_1, "(azathioprine|mycophenolate mofetil)")
replace antiprolif = 1 if regexm(productname_1, "(imuran|cellcept|myofortic )")
replace antiprolif = 1 if regexm(productname_1, "(azathioprine|mycophenolate mofetil)")
label variable antiprolif "Antiproliferative immunosuppresant exposure:0=no exp, 1=exp"
keep if antiprolif==1
drop antiprolif
export excel prodcode gemscriptcode productname using cov_drugcodes.xls, sheet("antiprolif") sheetmodify firstrow(variables)

//Other immunosuppressants
use product.dta, clear
rename productname productname_1
rename drugsubstance drugsubstance_1
gen otherimmunosuppress = 0
replace otherimmunosuppress = 1 if regexm(prod_bnfcode, "080202..")
replace otherimmunosuppress = 1 if regexm(drugsubstance_1, "(thymoglobuline|simulect|nulojix|capimmune|capsporin|deximune|neoral|sandimmun|rapamune|adoport|capexion|modigraf|prograf|tacni|vivadex|advagraf)")
replace otherimmunosuppress = 1 if regexm(drugsubstance_1, "(antithymocyte immunoglobulin|basiliximab|belatacept|ciclosporin|cyclosporin|sirolimus|tacrolimus)")
replace otherimmunosuppress = 1 if regexm(productname_1, "(thymoglobuline|simulect|nulojix|capimmune|capsporin|deximune|neoral|sandimmun|rapamune|adoport|capexion|modigraf|prograf|tacni|vivadex|advagraf)")
replace otherimmunosuppress = 1 if regexm(productname_1, "(antithymocyte immunoglobulin|basiliximab|belatacept|ciclosporin|cyclosporin|sirolimus|tacrolimus)")
label variable otherimmunosuppress "Corticosteroids and other immunosuppresant exposure:0=no exp, 1=exp"
keep if otherimmunosuppress==1
drop otherimmunosuppress
export excel prodcode gemscriptcode productname using cov_drugcodes.xls, sheet("otherimmunosuppress") sheetmodify firstrow(variables)

//Anti-lymphocyte monoclonal antibodies
use product.dta, clear
rename productname productname_1
rename drugsubstance drugsubstance_1
gen antilymph_mab = 0
replace antilymph_mab =1 if regexm(prod_bnfcode, "0982030..")
replace antilymph_mab = 1 if regexm(drugsubstance_1, "(arzerra|mabthera)")
replace antilymph_mab = 1 if regexm(drugsubstance_1, "(ofatumumab|rituximab)")
replace antilymph_mab = 1 if regexm(productname_1, "(arzerra|mabthera)")
replace antilymph_mab = 1 if regexm(productname_1, "(ofatumumab|rituximab)")
label variable antilymph_mab "Antilymphocyte monoclonal antibody exposure:0=no exp, 1=exp"
keep if antilymph_mab==1
drop antilymph_mab
export excel prodcode gemscriptcode productname using cov_drugcodes.xls, sheet("antilymph_mab") sheetmodify firstrow(variables)

//Other immunomodulating drugs
use product.dta, clear
rename productname productname_1
rename drugsubstance drugsubstance_1
gen otherimmunomodul = 0
replace otherimmunomodul = 1 if regexm(prod_bnfcode, "080204..")
replace otherimmunomodul = 1 if regexm(drugsubstance_1, "(introna|roferon-a|pegasys|viraferonpeg|avonex|rebif|betaferon|extavia|immukin|proleukin|immucyst|oncotice|ilaris|gilenya|copaxone|ceplene|revlimid|thalidomide celgene|mepact|tysabri)")
replace otherimmunomodul = 1 if regexm(drugsubstance_1, "(interferon alfa|peginterferon alfa|interferon beta|interferon gamma-1b|aldesleukin|bacillus calmette-guerin|anakinumab|fingolimod|glatiramer acetate|histamine dihydrochloride|lenalidomide|thalidomide|mifamurtide|natalizumab)")
replace otherimmunomodul = 1 if regexm(productname_1, "(introna|roferon-a|pegasys|viraferonpeg|avonex|rebif|betaferon|extavia|immukin|proleukin|immucyst|oncotice|ilaris|gilenya|copaxone|ceplene|revlimid|thalidomide celgene|mepact|tysabri)")
replace otherimmunomodul = 1 if regexm(productname_1, "(interferon alfa|peginterferon alfa|interferon beta|interferon gamma-1b|aldesleukin|bacillus calmette-guerin|anakinumab|fingolimod|glatiramer acetate|histamine dihydrochloride|lenalidomide|thalidomide|mifamurtide|natalizumab)")
label variable otherimmunomodul "Other immunomodulating drug exposure:0=no exp, 1=exp"
keep if otherimmunomodul==1
drop otherimmunomodul
export excel prodcode gemscriptcode productname using cov_drugcodes.xls, sheet("otherimmunomodul") sheetmodify firstrow(variables)

//Oral iron
use product.dta, clear
rename productname productname_1
rename drugsubstance drugsubstance_1
gen iron_oral = 0
replace iron_oral = 1 if regexm(prod_bnfcode, "09010101")
replace iron_oral = 1 if regexm(drugsubstance_1, "(ironorm|feospan|ferrograd|fefol|fersamal|galfer|pregaday|niferex|sytron)")
replace iron_oral = 1 if regexm(drugsubstance_1, "(ferrous sulfate|ferrous fumarate|ferrous gluconate|polysaccharide-iron complex|sodium feredetate|sodium ironedetate)")
replace iron_oral = 1 if regexm(productname_1, "(ironorm|feospan|ferrograd|fefol|fersamal|galfer|pregaday|niferex|sytron)")
replace iron_oral = 1 if regexm(productname_1, "(ferrous sulfate|ferrous fumarate|ferrous gluconate|polysaccharide-iron complex|sodium feredetate|sodium ironedetate)")
label variable iron_oral "Oral iron exposure: 0=no exp, 1=exp"
keep if iron_oral==1
drop iron_oral
export excel prodcode gemscriptcode productname using cov_drugcodes.xls, sheet("iron_oral") sheetmodify firstrow(variables)

//Parenteral iron
use product.dta, clear
rename productname productname_1
rename drugsubstance drugsubstance_1
gen iron_parenteral = 0
replace iron_parenteral = 1 if regexm(prod_bnfcode, "09010102")
replace iron_parenteral = 1 if regexm(drugsubstance_1, "(ferinject|rienso|cosmofer|monofer|venofer)")
replace iron_parenteral = 1 if regexm(drugsubstance_1, "(ferric carboxymaltose|ferumoxytol|iron dextran|iron isomaltoside 1000|iron sucrose)")
replace iron_parenteral = 1 if regexm(productname_1, "(ferinject|rienso|cosmofer|monofer|venofer)")
replace iron_parenteral = 1 if regexm(productname_1, "(ferric carboxymaltose|ferumoxytol|iron dextran|iron isomaltoside 1000|iron sucrose)")
label variable iron_parenteral "Parenteral iron exposure: 0=no exp, 1=exp"
keep if iron_parenteral==1
drop iron_parenteral
export excel prodcode gemscriptcode productname using cov_drugcodes.xls, sheet("iron_parenteral") sheetmodify firstrow(variables)

//Oral potassium
use product.dta, clear
rename productname productname_1
rename drugsubstance drugsubstance_1
gen potassium_oral = 0
replace potassium_oral = 1 if regexm(prod_bnfcode, "09020101")
replace potassium_oral = 1 if regexm(drugsubstance_1, "(kay-cee-l|sando-k|slow-k|calcium resonium|resonium a|sorbisterit)")
replace potassium_oral = 1 if regexm(drugsubstance_1, "(potassium chloride|polystyrene sulfonate resin)")
replace potassium_oral = 1 if regexm(productname_1, "(kay-cee-l|sando-k|slow-k|calcium resonium|resonium a|sorbisterit)")
replace potassium_oral = 1 if regexm(productname_1, "(potassium chloride|polystyrene sulfonate resin)")
label variable potassium_oral "Oral potassium exposure: 0=no exp, 1=exp"
keep if potassium_oral==1
drop potassium_oral
export excel prodcode gemscriptcode productname using cov_drugcodes.xls, sheet("potassium_oral") sheetmodify firstrow(variables)

//Multivitamin preparations
use product.dta, clear
rename productname productname_1
rename drugsubstance drugsubstance_1
gen multivit = 0
replace multivit = 1 if regexm(prod_bnfcode, "090607..")
replace multivit = 1 if regexm(drugsubstance_1, "(abidec|dalivit|forceval|ketovite)")
replace multivit = 1 if regexm(productname_1, "(abidec|dalivit|forceval|ketovite)")
label variable multivit "Multivitamin exposure: 0=no exp, 1=exp"
keep if multivit==1
drop multivit
export excel prodcode gemscriptcode productname using cov_drugcodes.xls, sheet("multivit") sheetmodify firstrow(variables)

//NSAIDs
use product.dta, clear
rename productname productname_1
rename drugsubstance drugsubstance_1
gen nsaid = 0
replace nsaid = 1 if regexm(prod_bnfcode, "100101..")
replace nsaid = 1 if regexm(drugsubstance_1, "(preservex|emflex|celebrex|seractil|keral|voltarol|dyloject|diclomax|motifene|arthrotec|etopan|lodine|arcoxia|fenopron|froben|brufen|fenbid|orudis|oruvail|axorid|ponstan|relifex|naprosyn|vimovo|napratec|brexidol|feldene|mobiflex|surgam)")
replace nsaid = 1 if regexm(drugsubstance_1, "(aceclofenac|acemetacin|celecoxib|dexibuprofen|dexketoprofen|diclofenac potassium|diclofenac sodium|etodolca|etoricoxib|fenoprofen|fluriprofen|ibuprofen|indometacin|indomethacin|ketoprofen|mefenamic acid|meloxicam|nabumetone|naproxen|piroxicam|sulindac|tenoxicam|tiaprofenic acid)")
replace nsaid = 1 if regexm(productname_1, "(preservex|emflex|celebrex|seractil|keral|voltarol|dyloject|diclomax|motifene|arthrotec|etopan|lodine|arcoxia|fenopron|froben|brufen|fenbid|orudis|oruvail|axorid|ponstan|relifex|naprosyn|vimovo|napratec|brexidol|feldene|mobiflex|surgam)")
replace nsaid = 1 if regexm(productname_1, "(aceclofenac|acemetacin|celecoxib|dexibuprofen|dexketoprofen|diclofenac potassium|diclofenac sodium|etodolca|etoricoxib|fenoprofen|fluriprofen|ibuprofen|indometacin|indomethacin|ketoprofen|mefenamic acid|meloxicam|nabumetone|naproxen|piroxicam|sulindac|tenoxicam|tiaprofenic acid)")
label variable nsaid "NSAID exposure: 0=no exp, 1=exp"
keep if nsaid==1
drop nsaid
export excel prodcode gemscriptcode productname using cov_drugcodes.xls, sheet("nsaid") sheetmodify firstrow(variables)

//Local corticosteroid injections
use product.dta, clear
rename productname productname_1
rename drugsubstance drugsubstance_1
gen cortico_inject = 0
replace cortico_inject = 1 if regexm(prod_bnfcode, "10010202")
replace cortico_inject = 1 if regexm(drugsubstance_1, "(dexamethasone|hydrocortistab|depo-medrone|deltastab|adcortyl|kenalog)")
replace cortico_inject = 1 if regexm(productname_1, "(dexamethasone|hydrocortistab|depo-medrone|deltastab|adcortyl|kenalog)")
label variable cortico_inject "Corticosteroid (local inj) exposure:0=no exp, 1=exp"
keep if cortico_inject==1
drop cortico_inject
export excel prodcode gemscriptcode productname using cov_drugcodes.xls, sheet("cortico_inject") sheetmodify firstrow(variables)

//Antigout drugs
use product.dta, clear
rename productname productname_1
rename drugsubstance drugsubstance_1
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
keep if antigout==1
drop antigout
export excel prodcode gemscriptcode productname using cov_drugcodes.xls, sheet("antigout") sheetmodify firstrow(variables)

//Antirheumatic disease drugs
use product.dta, clear
rename productname productname_1
rename drugsubstance drugsubstance_1
gen antirheum = 0
replace antirheum = 1 if regexm(prod_bnfcode, "100103..")
replace antirheum = 1 if regexm(drugsubstance_1, "(myocrisin|distamine|plaquenil|arava|metoject|orencia|humira|kineret|benlysta|cimzia|ebrel|simponi|remicade|roactemra|salazopyrin )")
replace antirheum = 1 if regexm(drugsubstance_1, "(sodium aurothiomalate|penicillamine|chloroquine|hydroxychloroquine sulfate|azathioprine|ciclosporin|cyclosporin|leflunomide|methotrexate|abatacept|adalimumab|anakinra|belimumab|certolizumab pegol|etanercept|golimumab|infliximab|rituximab|tocilizumab|sulfasalazine|sulphasalazine)")
replace antirheum = 1 if regexm(productname_1, "(myocrisin|distamine|plaquenil|arava|metoject|orencia|humira|kineret|benlysta|cimzia|ebrel|simponi|remicade|roactemra|salazopyrin )")
replace antirheum = 1 if regexm(productname_1, "(sodium aurothiomalate|penicillamine|chloroquine|hydroxychloroquine sulfate|azathioprine|ciclosporin|cyclosporin|leflunomide|methotrexate|abatacept|adalimumab|anakinra|belimumab|certolizumab pegol|etanercept|golimumab|infliximab|rituximab|tocilizumab|sulfasalazine|sulphasalazine)")
label variable antirheum "Antirheumatic drug exposure: 0=no exp, 1=exp"
keep if antirheum==1
drop antirheum
export excel prodcode gemscriptcode productname using cov_drugcodes.xls, sheet("antirheum") sheetmodify firstrow(variables)

// Benzodiazepine
use product.dta, clear
rename productname productname_1
rename drugsubstance drugsubstance_1
gen benzo = 0
replace benzo = 1 if regexm(prod_bnfcode, "15010401")
replace benzo = 1 if regexm(drugsubstance_1, "(hypnovel)")
replace benzo = 1 if regexm(drugsubstance_1, "(diazepam|lorazepam|midazolam|temazepam)")
replace benzo = 1 if regexm(productname_1, "(hypnovel)")
replace benzo = 1 if regexm(productname_1, "(diazepam|lorazepam|midazolam|temazepam)")
label variable benzo "Benzodiazepine exposure: 0=no exp, 1=exp" 
keep if benzo==1
drop benzo
export excel prodcode gemscriptcode productname using cov_drugcodes.xls, sheet("benzo") sheetmodify firstrow(variables)

// Opioid analgesics
use product.dta, clear
rename productname productname_1
rename drugsubstance drugsubstance_1
gen opioid2 = 0
replace opioid2 = 1 if regexm(prod_bnfcode, "15010403")
replace opioid2 = 1 if regexm(drugsubstance_1, "(repifen|sublimaze|ultiva)")
replace opioid2 = 1 if regexm(drugsubstance_1, "(alfentanil|fentanyl|remifentanil)")
replace opioid2 = 1 if regexm(productname_1, "(repifen|sublimaze|ultiva)")
replace opioid2 = 1 if regexm(productname_1, "(alfentanil|fentanyl|remifentanil)")
label variable opioid2 "Opioid analgesic (anaes) exposure: 0=no exp, 1=exp"
keep if opioid2==1
drop opioid2
export excel prodcode gemscriptcode productname using cov_drugcodes.xls, sheet("opioid2") sheetmodify firstrow(variables)


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
