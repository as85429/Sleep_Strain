********************************************************************************
* How does daily sleep and sleep quality are associated with marital strain?
* HARP T1 Diary data ONLY
* by Asya Saydam (asyasaydam@utexas.edu)
* Fall 2024
* Templates: Michael Garcia Template do files
********************************************************************************

cd   		"T:"
clear       all
capture log close
set			maxvar 120000
local 		logdate = string( d(`c(current_date)'), "%dCY.N.D" )
log 		using "T:\asya\logs\SleepStrain`logdate'_variables.log", replace




********************************************************************************
* Sleep Project
* HARP T1 and T2 Baseline data + Diary Data
* by Asya Saydam (asyasaydam@utexas.edu)
* Summer 2024
* Templates: Michael Garcia Template do files
******************************************************************************

preserve
use "T:\asya\data\HARP\FINAL DATASETS\FINAL files\37404-0001-Data", clear
tolower 
keep cid rid sid
save "T:\asya\data\HARP\FINAL DATASETS\FINAL files\T1Baseline", replace
restore

***********************************
********DIARY SLEEP MEASURES*******
***********************************

********************************************************************************
********************************************************************************
******************************************************************************** 
******************************************************************************** 
*** T1 diary
******************************************************************************** 
********************************************************************************

use "T:\asya\data\HARP\FINAL DATASETS\FINAL files\T1Baseline", clear
duplicates report cid rid sid


use 		"T:\asya\data\HARP\FINAL DATASETS\FINAL files\T1T2baseline_t1t2diary_FINAL", clear
drop cid
merge m:1 rid using "T:\asya\data\HARP\FINAL DATASETS\FINAL files\T1Baseline", keepusing(cid)
*drop 			_merge
*save            "T:\asya\data\HARP\mergedbaseline1diary1.dta", replace


drop *_t2
fre mstat
keep if mstat== 1




mdesc cid rid sid genrelns
browse rid cid sid 

replace sid = 8528 if rid == 4213

tab mstat, m




/*
bro cid rid if inlist(rid, ///
1025, 1066, 1393, 1531, 1684, 1849, 2163, 2279, 2721, 2754, ///
3120, 3288, 3599, 3624, 3629, 4154, 4376, 4516, 4543, 4826, ///
4981, 5216, 5375, 6443, 7012, 7383, 7698, 7832, 7895, 7908, ///
8797, 9186, 9253, 9387, 9843)
*/


recode rtyp 1/2=1 3=2, gen(ssds)
label define ssds 1 "Same-sex couples" 2 "Different-sex couples"
label value ssds ssds
fre ssds


*** for days ***
sort cid rid day
bys rid: gen numdays=_N if day != . 
la var numdays "Number of diary days completed at T1"
tab numdays


bro cid if numdays < 6
// cid == 196, 549, 814 have less than 6 days.

// drop these who are missing 6 days and less
// drop if inlist(cid, 196, 549, 814)


** make sure to keep descrp
fre educ //  R's highest level education
fre rage // respondent age
fre worksit // respondent work situation
fre raceth // race & ethnicity
fre kidinhh // kid in the household
fre yrsliv 


// This basically describes the number of people who miss days;
// 6 people only have 6 days of data, 10 people have 7 days, 30 people have 8 days of data, 50 people have 9 days of data, 660 people have complete)
unique rid 	if numdays < 7 // 6
unique rid  if numdays < 8 // 16
unique rid  if numdays < 9 // 46
unique rid  if numdays < 10 // 96
unique rid 	if numdays == 10 // 660



**** number of children
	egen numkid = rownonmiss(agekidhh1 agekidhh2 agekidhh3 agekidhh4 agekidhh5 agekidhh6)


* Loop through variables and recode if there is any child aged under 12
forval i = 1/6 {
    recode agekidhh`i' 0/12=1 13/40=0, gen(agekid`i')
}
	egen numkid12 = anycount(agekid1 agekid2 agekid3 agekid4 agekid5 agekid6), value(1)
	label var numkid12 "Number of kids under 12"

* Loop through variables and recode if there is any child aged under 12
forval i = 1/6 {
    recode agekidhh`i' 0/12=1 13/40=0, gen(agekidp`i')
}


	egen numkid6 = anycount(agekidp1 agekidp2 agekidp3 agekidp4 agekidp5 agekidp6), value(1)
	label var numkid6 "Number of kids under 6"



gen kidage = 0
replace kidage = 1 if kidinhh == 1 & inlist(agekid1, agekid2, agekid3, agekid4, agekid5, agekid6, 1)
 // have kid 12 and under 
label define kidage 0 "None/older child" 1 "Child age 12 and under in hh"
label values kidage kidage


* Loop through variables and recode if there is any child aged under 12
forval i = 1/6 {
    recode agekidhh`i' 0/1=0 2/5=1 6/12=2 13/18=3 19/40=4, gen(agekidki`i')
}

	egen numkidless2 = anycount(agekidki1 agekidki2 agekidki3 agekidki4 agekidki5 agekidki6), value(0)
	label var numkidless2 "Number of kids under 2"
	
	egen numkid25 = anycount(agekidki1 agekidki2 agekidki3 agekidki4 agekidki5 agekidki6), value(1)
	label var numkid25 "Number of kids ages 2-5 in hh"
	
	egen numkid612 = anycount(agekidki1 agekidki2 agekidki3 agekidki4 agekidki5 agekidki6), value(2)
	label var numkid612 "Number of kids ages 6-12 in hh"
	
	egen numkid18 = anycount(agekidki1 agekidki2 agekidki3 agekidki4 agekidki5 agekidki6), value(0 1 2 3)
	label var numkid18 "Number of kids ages less than 18 in hh"




* Loop through variables and recode if there is any child aged under 18
forval i = 1/6 {
    recode agekidhh`i' 0/18=0 19/40=1, gen(agekido`i')
}
gen kidage18 = 0
replace kidage18 = 1 if kidinhh == 1 & inlist(agekido1, agekido2, agekido3, agekido4, agekido5, agekido6, 0)
 // have kid 18 and under 
label define kidage18 0 "None/older child" 1 "Child age 18 and under in hh"
label values kidage18 kidage18



* Loop through variables and recode if there is any child aged under 2
forval i = 1/6 {
    recode agekidhh`i' 0/2=0 3/40=1, gen(agekidu`i')
}
gen kidage2 = 0
replace kidage2 = 1 if kidinhh == 1 & inlist(agekidu1, agekidu2, agekidu3, agekidu4, agekidu5, agekidu6, 0)
 // have kid 12 and under 
label define kidage2 0 "None/older child" 1 "Child age 2 and under in hh"
label values kidage2 kidage2





save  "T:\asya\temp\SleepT1diaryBEFOREreshapeline151", replace
use  "T:\asya\temp\SleepT1diaryBEFOREreshapeline151", clear

***   Main variables to use
******************************************************************************** 
*Daily hours slept (dhrsleep): "How many hours did you sleep last night?"
******************************************************************************** 
********************************************************************************************
*Daily sleep quality (sleepqual): "How would you rate your overall sleep quality last night?"
************************************************************************
*******************
****** RECODE *****
*******************
*** for days ***
sort cid rid day
bys rid: gen numdays_t2=_N if day != . 
la var numdays "Number of diary days completed at T1"
tab numdays

browse cid rid day numdays dhrsleep sleepqual if numdays_t2 < 7
*drop if day_t2 == .  // DROP if anyone misses day_t2
drop if numdays < 6



*** Create partner variables ***
*******GETTING STARTED********
sort cid rid sid
bys cid: gen pid=1 if rid<sid
bys cid: replace pid=2 if rid>=sid // need pid to create a partner variables 

mdesc pid


keep cid rid sid pid rgend sgend rtyp genrelns day mstat ///
		dhrsleep sleepqual ///
		spsdown listmore spsincon bothered ///
		strfinan strhous strshlth strfamr strwork strlife ///
		educ rage worksit raceth kidinhh yrsliv kidage* kidage18 numkid* 
		


		/*list inlist(rid, ///
1025, 1066, 1393, 1531, 1684, 1849, 2163, 2279, 2721, 2754, ///
3120, 3288, 3599, 3624, 3629, 4154, 4376, 4516, 4543, 4826, ///
4981, 5216, 5375, 6443, 7012, 7383, 7698, 7832, 7895, 7908, ///
8797, 9186, 9253, 9387, 9843)	*/




save  "T:\asya\data_created\SleepT1diaryBEFOREreshape", replace


********************************************************************************
********************************************************************************
******************************************************************************** 
******************************************************************************** 

********************************************************************************
********************************************************************************
******************************************************************************** 
******************************************************************************** 


use "T:\asya\data_created\SleepT1diaryBEFOREreshape", clear


recode rtyp 1/2=1 3=2, gen(ssds)
label define ssds 1 "Same-sex couples" 2 "Different-sex couples"
label value ssds ssds
fre ssds


// "numdays" creation
sort cid rid day
bys rid: gen numdays=_N
la var numdays "Number of diary days completed - T1"
tab numdays

drop if numdays <6 // to be included in the sample both spouses had to to complete at least 6 of the 10 diary questionaries.

mdesc 		genrelns sgend rgend cid rid // missings on the major set!
gen fem=(rgend==2)
gen pfem=(sgend==2)



* Step 1: Count how many unique rids each cid has
bysort cid (rid): gen tag = _n == 1   // tag one row per cid
egen n_rid = count(rid), by(cid)

* Step 2: Create a flag for single-person cids
gen single_cid = (n_rid == 1)
sum single_cid n_rid
tab single_cid n_rid

*************************************
********* SLEEP VARIABLES *********
*************************************

**** understanding sleep variables ****


sum dhrsleep
sum sleepqual

misstable sum dhrsleep sleepqual


count if dhrsleep != . & sleepqual != . // if both are not missing
count if dhrsleep == . & sleepqual == . // 6 both are 




preserve
gen miss_sleep = missing(dhrsleep)
collapse (sum) miss_days = miss_sleep ///
         (mean) avg_sleep = dhrsleep ///
         (max) max_sleep = dhrsleep ///
         (first) cid, by(rid)
tab miss_days
restore


** If I drop for the marital status in line 179 then;
/*. tab miss_days

      (sum) |
 miss_sleep |      Freq.     Percent        Cum.
------------+-----------------------------------
          0 |        749       99.07       99.07
          1 |          6        0.79       99.87
          2 |          1        0.13      100.00
------------+-----------------------------------
      Total |        756      100.00

100.00

. 
. */

// How many people suggest sleeping more than 8 hours on average?
preserve
collapse (mean) avg_sleep = dhrsleep, by(rid)
count if avg_sleep > 8 // 91 people 
restore


// How many people suggest sleeping more than 9 hours?
preserve
collapse (mean) avg_sleep = dhrsleep, by(rid)
count if avg_sleep > 9 // 11 people 
restore

// How many people have at least one day with more than 9 hours of sleep?
gen sleep_gt9 = dhrsleep > 9 if !missing(dhrsleep)    // create a binary variable to see if slept more than 9 hours
bysort rid (day): egen any_sleep_gt9 = max(sleep_gt9) // crate a binary variable if out of 10 days, one slept any day more than 9 hours
egen ccag = tag(rid)									  // This creates a variable tag that equals 1 only on the first row for each person (rid), and 0 elsewhere.
count if any_sleep_gt9 == 1 & ccag == 1				  // This gives the total number of unique rids where any_sleep_gt9 == 1 — that is, they had at least one day with more than 9 hours of sleep.
//141

	
// Few suggest sleeping 20 hours 
sum dhrsleep // there are people who sleep 0 or 20 hours. Is that possible?
tab dhrsleep

* 🔹 1. Calculate the 95th percentile
sum dhrsleep, detail

count if dhrsleep > 13 & dhrsleep != .  // Only 11 cases show up
replace dhrsleep = 13 if dhrsleep > 13 & dhrsleep != . // If we want to topcode sleep duration 
label define sleep_lbl 13 "13+ hours (topcoded)"
label values dhrsleep sleep_lbl


// Creating average sleep duration variable and averaging it

*** creating average for each person

mdesc dhrsleep


// Step 1: Compute person-level average sleep
bysort rid: egen avgsleep = mean(dhrsleep)
gen avgsleepr = round(avgsleep, 1)

// Step 2: Replace missing values with that person's average
gen dhrsleep_imputed_self = 0  // initialize the flag
replace dhrsleep_imputed_self = 1 if missing(dhrsleep)
replace dhrsleep = avgsleepr if missing(dhrsleep)

sum dhrsleep avgsleep avgsleepr, detail


mdesc dhrsleep sleepqual

bys rid: egen avgsleepqual = mean(sleepqual)
gen avgsleepqualr = round(avgsleepqual, 1)
replace sleepqual = avgsleepqualr if sleepqual == .
*drop avgsleepqual


save  "T:\asya\temp\SleepStrainbeforeMarStrainT1", replace
use  "T:\asya\temp\SleepStrainbeforeMarStrainT1", clear



********************************************
*********** MARITAL STRAIN at T1 ***********
********************************************

*DAILY MARITAL STRAIN
*Indirect - alpha=.78
mdesc spsdown listmore spsincon bothered
sum spsdown listmore spsincon bothered
tab1 spsdown listmore spsincon bothered,m

factor spsdown listmore spsincon bothered 
alpha spsdown listmore spsincon bothered,item // .78 [same w Michael's]

egen strain =rowtotal(spsdown listmore spsincon bothered), missing
la var strain "Daily Marital Strain"
sum strain
hist strain

egen strainavg =rowmean(spsdown listmore spsincon bothered)
la var strainavg "Daily Marital Strain"
sum strainavg
hist strainavg
mdesc strainavg

// 5 missing

/*
sum strainavg
return list
replace strainavg = r(mean) if strainavg == .
*/

* Step 1: Compute each respondent's average strain (ignoring missing)
bysort rid: egen mean_strain = mean(strainavg)

* Step 2: Replace missing values with their own average
replace strainavg = mean_strain if missing(strainavg)

* Optional: Flag which values were imputed
gen strainavg_imputed_self = missing(strainavg)
replace strainavg_imputed_self = 1 if strainavg == mean_strain & missing(strainavg_imputed_self)
replace strainavg_imputed_self = 0 if missing(strainavg_imputed_self)

* Step 3: (Optional) Drop helper variable
drop mean_strain



*****************************************
******** Sleep PARTNER VARIABLES ********
*****************************************

sort cid rid day
 foreach var in dhrsleep sleepqual strain strainavg {
 	gen sp_`var'=. // var = name of study variable
    by cid: replace sp_`var'=`var'[_n+numdays] if pid==1
    by cid: replace sp_`var'=`var'[_n-numdays] if pid==2
 }
 

 la var sp_dhrsleep "Daily Spousal Sleep"
 la var sp_sleepqual "Daily Spousal Sleep Quality"
 la var sp_strain "Daily Spousal Marital Strain"
 la var sp_strainavg "Daily Spousal Marital Strain (Avg)"


 
 
 
*******************************************
***************  covariates ***************
*******************************************

recode worksit 3/7=0 1/2=1, gen(cworking) 
label define cworking 0 "Not working" 1 "Currently working"
label values cworking cworking
replace cworking = 0 if cworking == .


recode raceth 2/7=0, gen(race)
label define race 0 "Non white" 1 "Non-hispanic white"
label values race race 
fre race 

fre educ // education
recode educ 1/4=0 5/6=1, gen(college) 
label define college 0 "Some years of college or less" 1 "College degree or higher+" 
label values college college

recode educ 1/5=0 6=1, gen(postgrad)
label define postgrad 0 "College and less" 1 "Postgraduate"
label values postgrad postgrad
fre postgrad 

recode educ 1/4=0 5=1 6=2, gen(education)
label define education 0 "Some college or less" 1 "College degree" 2 "Postgraduate/professional"
label values education education




mdesc 	cid rid rgend sgend genrelns ///
		rage yrsliv kidinhh kidage* numkid* college cworking race day ///
		strain sp_strain ///
		strainavg ///
		dhrsleep sp_dhrsleep ///
		sleepqual sp_sleepqual

	label var dhrsleep "Respondent Daily Sleep Duration"
	label var sp_dhrsleep "Spousal Daily Sleep Duration"
	
	label var sleepqual "Respondent Daily Sleep Quality"
	label var sp_sleepqual "Spousal Daily Sleep Quality"
	
	label define fem 0 "Respondent man" 1 "Respondent woman"
	label define pfem 0 "Partner man" 1 "Partner woman"
	label val fem fem
	label val pfem pfem
	
	label var yrsliv "Relationship Duration"
	label var rage "Respondent age
	
	label define kidinhh 0 "No children in hh" 1 "Children in hh"
	label val kidinhh kidinhh

		
		save  "T:\asya\data_created\SleepT1diaryfordesc", replace
		
		log close
		
********************************************************************************
********************************************************************************
******************************************************************************** 
******************************************************************************** 


cd   		"T:"
clear       all
capture log close
set			maxvar 120000
local 		logdate = string( d(`c(current_date)'), "%dCY.N.D" )
log 		using "T:\asya\logs\SleepStrainPAAT`logdate'_variables.log", replace


// use what data you prepped you need if T1 or T2

*use  "T:\asya\data_created\SleepT1T2diaryfordesc", clear  
use  "T:\asya\data_created\SleepT1diaryfordesc", clear
	

mdesc strainavg rag college race cworking kidage* numkid* 



***********************************************
*** SLEEEP STRAIN CORRELATION ***
***********************************************
	
	corr dhrsleep sleepqual
	
	** within person-level
	* Person-mean center both variables
	bysort rid: egen mean_dur = mean(dhrsleep)
	bysort rid: egen mean_qual = mean(sleepqual)

	gen dur_centered = dhrsleep - mean_dur
	gen qual_centered = sleepqual - mean_qual

	* Correlation of within-person deviations
	corr dur_centered qual_centered 
	//0.5455
	
	
	**** Person-level correlation (between-person)
	preserve
	* Collapse to person level
	collapse (mean) sleep_avg = sleepqual dhr_avg = dhrsleep, by(rid)
	corr sleep_avg dhr_avg // 0.4299
	restore
	
		
***********************************************
***DAILY SLEEP PREDICTING MARITAL STRAIN T1 ***
***********************************************



*Empty Model for ICC
mixed strain || cid:, cov(exc) reml
estat icc //  .1991496 
// Kroegers and Powers 2018 indicate that:
/*"Results from an empty MLM with reported health status as the outcome indicate
an intraclass correlation (ICC) of 0.63" meaning that reported health
 status values within dyads are highly correlated.*/
 /*Considering this .2 seems low, and we can suggest that strain within dyads 
 are not highly correlated*/
******************************************************************

global cov c.rage i.college i.cworking i.race c.numkid6 c.yrsliv c.day

foreach var of varlist dhrsleep sleepqual { 
	
*MODEL 1 - ACTOR-REPORTED
	eststo Model`var'1: mixed strainavg c.`var' i.fem i.pfem $cov || cid: R.pid, nocon cov(exc) || cid: R.day
	
*MODEL 2 - ACTOR & PARTNER-REPORTED
	eststo Model`var'2: mixed strainavg c.`var' c.sp_`var' i.fem i.pfem $cov || cid: R.pid, nocon cov(exc) || cid: R.day

*MODEL 3 - ACTOR-REPORTED EFFECT BY GROUP (controlling for spouse-reported effect)
	eststo Model`var'3: mixed strainavg c.`var'##i.fem##i.pfem c.sp_`var' $cov || cid: R.pid, nocon cov(exc) || cid: R.day
	
	margins, dydx(`var') over(fem pfem)
	margins, dydx(`var') over(fem pfem) pwcompare(effects)
	
*MODEL 4 - SPOUSE-REPORTED EFFECT BY GROUP (controlling for actor-reported effect)
	eststo Model`var'4: mixed strainavg c.`var' c.sp_`var'##i.fem##i.pfem $cov || cid: R.pid, nocon cov(exc) || cid: R.day

	margins, dydx(sp_`var') over(fem pfem)
	margins, dydx(sp_`var') over(fem pfem) pwcompare(effects)
	
	******** Table output ********
	
}


	esttab Modeldhrsleep1 Modeldhrsleep2 Modeldhrsleep3 Modeldhrsleep4 using "T:\asya\results\SleepStrainkid18_T1.html", star(+ 0.1 * 0.05 ** 0.01 *** 0.001) b(2) t(2) label varlabels(_cons Constant) replace sca(F) se legend level(90) nogaps nonumbers lines title("Estimates From Multilevel Regression Models Testing Respondent- and Spouse-Reported Sleep Duration on Respondent Marital Strain on (n =756 Individuals, 378 Couples)") mtitles("Model 1" "Model 2" "Model 3" "Model 4") depvars nobaselevels interaction(" * ") fonttbl(\f0\fnil Times New Roman; )  addnote("Source: HARP 2014-2015")

	
	esttab Modelsleepqual1 Modelsleepqual2 Modelsleepqual3 Modelsleepqual4 using "T:\asya\results\SleepQualityStrainkid18_T1.html", star(+ 0.1 * 0.05 ** 0.01 *** 0.001) b(2) t(2) label varlabels(_cons Constant lns1_1_1 Partner_variance) replace sca(F) se legend level(90) nogaps nonumbers lines title("Estimates From Multilevel Regression Models Testing Respondent- and Spouse-Reported Sleep Quality on Respondent Marital Strain on (n =756 Individuals, 378 Couples)") mtitles("Model 1" "Model 2" "Model 3" "Model 4") depvars nobaselevels interaction(" * ") fonttbl(\f0\fnil Times New Roman; )  addnote("Source: HARP 2014-2015")

	

	label var dhrsleep "Respondent Daily Sleep Duration"
	label var sleepqual "Respondent Daily Sleep Quality"
	
	
	est restore Modeldhrsleep2
	margins, at(dhrsleep=(3(1)10)) post
	marginsplot,  graphregion(color(white)) name(dhrsleep, replace) title(" ") ytitle("Daily Marital Strain") ///
	legend(position(3)) legend(cols(1)) recast(line) recastci(rarea) ciopt(color(%5)) noci nolab noseparator ///
	ylab(1.2(.2)1.6) 
	graph export "T:\asya\results\dhrsleepAllSample_4525.svg", replace
	
	est restore Modelsleepqual2
	margins, at(sleepqual=(1(1)5)) post
	marginsplot,  graphregion(color(white)) name(sleepqual, replace) title(" ") ytitle("Daily Marital Strain") ///
	legend(position(3)) legend(cols(1)) recast(line) recastci(rarea) ciopt(color(%5)) noci nolab noseparator ///
	ylab(1.2(.2)1.6)
	graph export "T:\asya\results\sleepqualAllSample_4525.svg", replace
	
	
	

	
	est restore Modeldhrsleep3
	margins, over(fem pfem) at(dhrsleep=(0(1)13)) post
	marginsplot,  graphregion(color(white)) name(dhrsleep, replace) title(" ") ytitle("Daily Marital Strain") ///
	legend(position(3)) legend(cols(1)) recast(line) recastci(rarea) ciopt(color(%5)) noci nolab noseparator ///
	ylab(1.2(.2)1.8) ///
	xlab(0(1)13) ///
	xlab(0 "0" 1 "1" 2 "2" 3 "3" 4 "4" 5 "5" 6 "6" 7 "7" 8 "8" 9 "9" 10 "10" 11 "11" 12 "12" 13 "13") ///
	legend(order(1 "Men w Men" 2 "Men w Women" 3 "Women w Men" 4 "Women w Women")) ///
	legend(title("Family Types")) ///
	plot1opts(lpattern("l") lcolor(black)) ///
	plot2opts(lpattern("-") lcolor(black)) ///
	plot3opts(lpattern(".") lcolor(black)) ///
	plot4opts(lpattern(".-") lcolor(black)) 
	graph export "T:\asya\results\dhrsleepGend_4525.svg", replace
	graph export "T:\asya\results\dhrsleepGend_4525.png", replace
	
	
	
	est restore Modeldhrsleep4
	margins, over(fem pfem) at(sp_dhrsleep=(0(1)13)) post
	marginsplot,  graphregion(color(white)) name(sp_dhrsleep, replace) title(" ") ytitle("Daily Marital Strain") ///
	legend(position(3)) legend(cols(1)) recast(line) recastci(rarea) ciopt(color(%5)) noci nolab noseparator ///
	ylab(1.2(.2)1.8) ///
	xlab(0(1)13) ///
	xlab(0 "0" 1 "1" 2 "2" 3 "3" 4 "4" 5 "5" 6 "6" 7 "7" 8 "8" 9 "9" 10 "10" 11 "11" 12 "12" 13 "13") ///
	legend(order(1 "Men w Men" 2 "Men w Women" 3 "Women w Men" 4 "Women w Women")) ///
	legend(title("Family Types")) ///
	plot1opts(lpattern("l") lcolor(black)) ///
	plot2opts(lpattern("-") lcolor(black)) ///
	plot3opts(lpattern(".") lcolor(black)) ///
	plot4opts(lpattern(".-") lcolor(black)) 
	
	
	graph export "T:\asya\results\spdhrsleepGend_4525.svg", replace
	graph export "T:\asya\results\spdhrsleepGend_4525.png", replace
	
	
	

	est restore Modelsleepqual3
	margins, over(fem pfem) at(sleepqual=(1(1)5)) post
	marginsplot,  graphregion(color(white)) name(sleepqual, replace) title(" ") ytitle("Daily Marital Strain") ///
	legend(position(3)) legend(cols(1)) recast(line) recastci(rarea) ciopt(color(%5)) noci nolab noseparator ///
	ylab(1.2(.2)1.8) ///
	legend(order(1 "Men w Men" 2 "Men w Women" 3 "Women w Men" 4 "Women w Women")) ///
	legend(title("Family Types")) ///
	plot1opts(lpattern("l") lcolor(black)) ///
	plot2opts(lpattern("-") lcolor(black)) ///
	plot3opts(lpattern(".") lcolor(black)) ///
	plot4opts(lpattern(".-") lcolor(black)) 

	
	/**FIGURE 4-2: Predicted sleep quality (T1) by daily sleep duration (T1; -1 SD to 1 SD)
	foreach var of varlist sleepqual { 
	eststo Model`var'3: mixed strainavg c.`var'##i.fem##i.pfem c.sp_`var' $cov || cid: R.pid, nocon cov(exc) || cid: R.day
	margins, over(fem pfem) at(`var'=(1(1)5)) post
	marginsplot,  graphregion(color(white)) name(`var'T1, replace)
	}*/
	

	

	
	desctable c.strainavg c.dhrsleep c.sleepqual ///
		c.rage i.college i.cworking i.race c.numkid i.kidage2 c.numkid6 c.yrsliv, ///
		stat(mean sd) filename("T:\asya\results\SleepStrainish") ///
		group(genrelns) title("Table 1. Sample characteristics by Union Type, HARP 2014-2015")
	
	
	desctable c.strainavg c.dhrsleep c.sleepqual ///
		c.rage i.college i.cworking i.race c.numkid i.kidage2 c.numkid6 c.yrsliv, ///
		stat(mean sd) filename("T:\asya\results\SleepStrainTotalish") ///
		title("Table 1. Sample characteristics by Union Type, HARP 2014-2015")	
		
		
		
	****** Testing for nonlinearity ********
	
	
	
	gen dhrssq = dhrsleep * dhrsleep
	la var dhrssq "Sleep duration(sq)"
	
	gen sp_dhrssqq = sp_dhrsleep * sp_dhrsleep
	la var sp_dhrssqq "Spouse Sleep duration(sq)"
	
	***********************************************
***DAILY SLEEP PREDICTING MARITAL STRAIN T1 ***
***********************************************

 

*Empty Model for ICC
mixed strain || cid:, cov(exc) reml
estat icc //  .1991496 
// Kroegers and Powers 2018 indicate that:
/*"Results from an empty MLM with reported health status as the outcome indicate
an intraclass correlation (ICC) of 0.63" meaning that reported health
 status values within dyads are highly correlated.*/
 /*Considering this .2 seems low, and we can suggest that strain within dyads 
 are not highly correlated*/
******************************************************************

global cov c.rage i.college i.cworking i.race c.numkid6 c.yrsliv c.day

	
*MODEL 1 - ACTOR-REPORTED without squared term
	eststo Modeltest0: mixed strainavg c.dhrsleep i.fem i.pfem $cov || cid: R.pid, nocon cov(exc) || cid: R.day
	
*MODEL 2 - ACTOR-REPORTED with squared term
	eststo Modeltest1: mixed strainavg c.dhrsleep c.dhrssq i.fem i.pfem $cov || cid: R.pid, nocon cov(exc) || cid: R.day

est restore Modeltest1
margins, at(dhrsleep=(0(1)12))
marginsplot, recast(line) ciopts(recast(rline)) name(Rsleep, replace)
	
	* estimated 
	predict fitter
	
	* descriptively plots marital strain agains duration
twoway (scatter strainavg dhrsleep) ///
       (line fitter dhrsleep, sort lcolor(blue)), ///
       ytitle("Marital Strain") xtitle("Sleep Duration") name(fitter, replace)
	
	*to have a smoother
	predict fixedfit, xb
twoway (scatter strainavg dhrsleep) ///
       (line  fixedfit dhrsleep, sort lcolor(blue)), ///
       ytitle("Marital Strain") xtitle("Sleep Duration") name(fixedfit, replace)
	   
	     
	
	esttab Modeltest0 Modeltest1 using "T:\asya\results\SleepStrainSqTEST.html", star(+ 0.1 * 0.05 ** 0.01 *** 0.001) b(2) t(2) label varlabels(_cons Constant) replace sca(F) se legend level(90) nogaps nonumbers lines title("Estimates From Multilevel Regression Models Testing Respondent- and Spouse-Reported Sleep Duration on Respondent Marital Strain on (n =756 Individuals, 378 Couples)") mtitles("Model 1" "Model 2") depvars nobaselevels interaction(" * ") fonttbl(\f0\fnil Times New Roman; )  addnote("Source: HARP 2014-2015")

	************************************************
	*************Sensitivity Test*******************
	************************************************
	
	*MODEL 2 - ACTOR-REPORTED with squared term
	eststo Modeltest4: mixed strainavg c.dhrsleep i.fem i.pfem $cov if dhrsleep <9 || cid: R.pid, nocon cov(exc) || cid: R.day	   
	
	eststo Modeltest5: mixed strainavg c.dhrsleep i.fem i.pfem $cov if dhrsleep >9 || cid: R.pid, nocon cov(exc) || cid: R.day	
	
	
	eststo Modeltest6: mixed strainavg c.dhrsleep i.fem i.pfem $cov if dhrsleep <8 || cid: R.pid, nocon cov(exc) || cid: R.day	   
	eststo Modeltest7: mixed strainavg c.dhrsleep i.fem i.pfem $cov if dhrsleep >=8|| cid: R.pid, nocon cov(exc) || cid: R.day	
	
		esttab Modeltest6 Modeltest7 using "T:\asya\results\SleepStrainTEST.html", star(+ 0.1 * 0.05 ** 0.01 *** 0.001) b(2) t(2) label varlabels(_cons Constant) replace sca(F) se legend level(90) nogaps nonumbers lines title("Estimates From Multilevel Regression Models Testing Respondent- and Spouse-Reported Sleep Duration on Respondent Marital Strain on (n =756 Individuals, 378 Couples)") mtitles("Model Less8" "Model 8andmore") depvars nobaselevels interaction(" * ") fonttbl(\f0\fnil Times New Roman; )  addnote("Source: HARP 2014-2015")
	
	
	
***** Here I am testing AIC/BIC directly to understand if squared term is a better fit and there is a nonlinearity
est restore Modeltest0
estat ic

est restore Modeltest1
estat ic 

esttab Modeltest0 Modeltest1, stats(aic bic ll N, fmt(3 3 3 0)) label

//
/*
. est restore Model0
(results Model0 are active now)

. estat ic

Akaike's information criterion and Bayesian information criterion

-----------------------------------------------------------------------------
       Model |          N   ll(null)  ll(model)      df        AIC        BIC
-------------+---------------------------------------------------------------
      Model0 |      7,396          .  -5405.719      15   10841.44   10945.07
-----------------------------------------------------------------------------
Note: BIC uses N = number of observations. See [R] IC note.

. 
. est restore Model1
(results Model1 are active now)

. estat ic 

Akaike's information criterion and Bayesian information criterion

-----------------------------------------------------------------------------
       Model |          N   ll(null)  ll(model)      df        AIC        BIC
-------------+---------------------------------------------------------------
      Model1 |      7,396          .   -5403.52      16   10839.04   10949.58
-----------------------------------------------------------------------------
Note: BIC uses N = number of observations. See [R] IC note.


The model including a squared term had a slightly lower AIC, suggesting a modest improvement in fit. However, BIC favored the more parsimonious linear model, indicating that evidence for a nonlinear association is limited.

*/
	
	
	
	
*MODEL 3 - PARTNER-REPORTED
	eststo Modelsp3: mixed strainavg c.sp_dhrsleep c.dhrsleep i.fem i.pfem $cov || cid: R.pid, nocon cov(exc) || cid: R.day
*MODEL 4 - PARTNER-REPORTED with squared 
	eststo Modelsp4: mixed strainavg c.sp_dhrsleep c.dhrsleep c.sp_dhrssqq i.fem i.pfem $cov || cid: R.pid, nocon cov(exc) || cid: R.day
	
		esttab Modelsp3 Modelsp4 using "T:\asya\results\SleepStrainSpouseTEST.html", star(+ 0.1 * 0.05 ** 0.01 *** 0.001) b(2) t(2) label varlabels(_cons Constant) replace sca(F) se legend level(90) nogaps nonumbers lines title("Estimates From Multilevel Regression Models Testing Respondent- and Spouse-Reported Sleep Duration on Spousal Marital Strain on (n =756 Individuals, 378 Couples)") mtitles("Model Nosq" "Model Sq") depvars nobaselevels interaction(" * ") fonttbl(\f0\fnil Times New Roman; )  addnote("Source: HARP 2014-2015")
	
	
est restore Modelsp3
estat ic

est restore Modelsp4
estat ic 

/*
. estat ic

Akaike's information criterion and Bayesian information criterion

-----------------------------------------------------------------------------
       Model |          N   ll(null)  ll(model)      df        AIC        BIC
-------------+---------------------------------------------------------------
    Modelsp3 |      7,396          .  -5409.741      16   10851.48   10962.02
-----------------------------------------------------------------------------
Note: BIC uses N = number of observations. See [R] IC note.

. 
. est restore Modelsp4
(results Modelsp4 are active now)

. estat ic 

Akaike's information criterion and Bayesian information criterion

-----------------------------------------------------------------------------
       Model |          N   ll(null)  ll(model)      df        AIC        BIC
-------------+---------------------------------------------------------------
    Modelsp4 |      7,396          .  -5409.737      17   10853.47   10970.92
-----------------------------------------------------------------------------
Note: BIC uses N = number of observations. See [R] IC note.
*/
	
	
* Make sure Model4 is restored
est restore Modelsp4

* Margins at values of sleep duration
margins, at(sp_dhrsleep=(0(1)13))

* Plot predicted values
marginsplot, recast(line) ciopts(recast(rline)) ///
    title("Predicted Marital Strain by Sleep Duration") ///
    ytitle("Predicted Marital Strain") ///
    xtitle("Sleep Duration (hours)") name(SSleep, replace)

predict fitto
twoway (scatter strainavg sp_dhrsleep) ///
       (line fitto sp_dhrsleep, sort lcolor(blue)), ///
       ytitle("Marital Strain") xtitle("Spouse Sleep Duration") name(fitto, replace)
	
	
*MODEL 3 - ACTOR-REPORTED EFFECT BY GROUP (controlling for spouse-reported effect)
	eststo Model3: mixed strainavg c.dhrsleep##i.fem##i.pfem c.dhrssq c.sp_`var' $cov || cid: R.pid, nocon cov(exc) || cid: R.day
	
	margins, dydx(`var') over(fem pfem)
	margins, dydx(`var') over(fem pfem) pwcompare(effects)
	
*MODEL 4 - SPOUSE-REPORTED EFFECT BY GROUP (controlling for actor-reported effect)
	eststo Model4: mixed strainavg c.dhrsleep c.sp_dhrsleep##i.fem##i.pfem $cov || cid: R.pid, nocon cov(exc) || cid: R.day

	margins, dydx(sp_`var') over(fem pfem)
	margins, dydx(sp_`var') over(fem pfem) pwcompare(effects)
	
	******** Table output ********
	


	
		