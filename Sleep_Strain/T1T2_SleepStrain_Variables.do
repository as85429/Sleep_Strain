********************************************************************************
* How does daily sleep and sleep quality are associated with marital strain?
* HARP T1 and T2 Diary data construction/cleaning of variables
* by Asya Saydam (asyasaydam@utexas.edu)
* Fall 2024
********************************************************************************

************************
******* merge diaries *******
************************
cd   		"T:"
clear       all
capture log close
set			maxvar 120000
local 		logdate = string( d(`c(current_date)'), "%dCY.N.D" )
log 		using "T:\asya\logs\SleepStrainPAA_variables.log", replace


use "T:\asya\data_created\SleepT1diaryBEFOREreshape", clear
merge m:m cid rid using "T:\asya\data\HARP\FINAL DATASETS\FINAL files\T1T2baseline_FINAL"
drop _merge
merge m:m cid rid using "T:\asya\data_created\SleepT2diaryBEFOREreshape"
drop _merge


sort cid rid sid day
numlabel, add

drop if rtyp == 4
keep if mstat_t2 == 1
replace 	sgend = 1 if genrelns == 1 & sgend == .	// added sgend to missing people
replace 	sgend = 2 if genrelns == 4 & sgend == . & rgend == 2


recode rtyp 1/2=1 3=2, gen(ssds)
label define ssds 1 "Same-sex couples" 2 "Different-sex couples"
label value ssds ssds
fre ssds




****************************************************************
****************** Essential variables check *******************
****************************************************************
mdesc rgend sgend
replace sgend = 1 if rid == 26127
replace sgend = 2 if rid == 41871

mdesc 		genrelns sgend rgend cid rid // missings on the major set!
gen fem=(rgend==2)
gen pfem=(sgend==2)

// "numdays" creation
sort cid rid day
bys rid: gen numdays=_N
la var numdays "Number of diary days completed - T1"
tab numdays

sort cid rid day_t2
bys rid: gen numdays_t2=_N
la var numdays_t2 "Number of diary days completed - T2"
tab numdays_t2

*************************************
********* SLEEP VARIABLES *********
*************************************

// Few suggest sleeping 20 hours 
sum dhrsleep // there are people who sleep 0 or 20 hours. Is that possible?
tab dhrsleep
*replace dhrsleep = 13 if dhrsleep > 13 & dhrsleep != . // If we want to topcode sleep duration


// Creating average sleep duration variable and averaging it
bys rid: egen avgsleep = mean(dhrsleep)
gen avgsleepr = round(avgsleep, 1)
// Replacing for those who miss couple of days with the average
replace dhrsleep = avgsleepr if dhrsleep == .
sum dhrsleep avgsleep
drop dhrsleep 
rename avgsleep dhrsleep

bys rid: egen avgsleepqual = mean(sleepqual)
gen avgsleepqualr = round(avgsleepqual, 1)
replace sleepqual = avgsleepqualr if sleepqual == .
*drop avgsleepqual



*bys rid: egen avgsleep_t2 = mean(dhrsleep_t2)
gen avgsleepr_t2 = round(avgsleep_t2, 1)
replace dhrsleep_t2 = avgsleepr_t2 if dhrsleep_t2 == .
sum dhrsleep_t2 avgsleep_t2
drop dhrsleep_t2
rename avgsleep_t2 dhrsleep_t2


bys rid: egen avgsleepqual_t2 = mean(sleepqual_t2)
gen avgsleepqualr_t2 = round(avgsleepqual_t2, 1)
replace sleepqual_t2 = avgsleepqualr_t2 if sleepqual_t2 == .
*drop avgsleepqual_t2

sum sleepqual* avgsleepqual*


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
la var strain "Daily Marital Strain - T1"
sum strain
hist strain

egen strainavg =rowmean(spsdown listmore spsincon bothered)
la var strainavg "Daily Marital Strain - T1"
sum strainavg
hist strainavg

// 798 missing

********************************************
*********** MARITAL STRAIN at T2 ***********
********************************************

*DAILY MARITAL STRAIN
*Indirect - alpha=.78
sum spsdown_t2 listmore_t2 spsincon_t2 bothered_t2
tab1 spsdown_t2 listmore_t2 spsincon_t2 bothered_t2,m

factor spsdown_t2 listmore_t2 spsincon_t2 bothered_t2
alpha spsdown_t2 listmore_t2 spsincon_t2 bothered_t2,item


// Taking the sum
egen strain_t2 = rowtotal(spsdown_t2 listmore_t2 spsincon_t2 bothered_t2), missing
la var strain_t2 "Daily Marital Strain - T2"
sum strain_t2
hist strain_t2

// Taking the average
egen strainavg_t2 =rowmean(spsdown_t2 listmore_t2 spsincon_t2 bothered_t2)
la var strainavg_t2 "Daily Marital Strain (Avg) - T2"
sum strainavg_t2
hist strainavg_t2



*****************************************
******** Sleep PARTNER VARIABLES ********
*****************************************

sort cid rid day
 foreach var in dhrsleep sleepqual strain strainavg {
 	gen sp_`var'=. // var = name of study variable
    by cid: replace sp_`var'=`var'[_n+numdays] if pid==1
    by cid: replace sp_`var'=`var'[_n-numdays] if pid==2
 }
 

 la var sp_dhrsleep "Daily Spousal Sleep - T1"
 la var sp_sleepqual "Daily Spousal Sleep Quality - T1"
 la var sp_strain "Daily Spousal Marital Strain - T1"
 la var sp_strainavg "Daily Spousal Marital Strain (Avg) - T1"


sort cid rid day_t2
 foreach var in dhrsleep_t2 sleepqual_t2 strain_t2 strainavg_t2 {
 	gen sp_`var'=. // var = name of study variable
    by cid: replace sp_`var'=`var'[_n+numdays] if pid==1
    by cid: replace sp_`var'=`var'[_n-numdays] if pid==2
 }
 

 la var sp_dhrsleep_t2 "Daily Spousal Sleep - T2"
 la var sp_sleepqual_t2 "Daily Spousal Sleep Quality - T2"
 la var sp_strain_t2 "Daily Spousal Marital Strain - T2"
 la var sp_strainavg_t2 "Daily Spousal Marital Strain (Avg) - T2"
 
 mdesc dhrsleep_t2 sleepqual_t2 strain_t2 sp_* // There are missings still! I drop them
 drop if sp_dhrsleep_t2 == . | sp_sleepqual_t2 ==. | sp_strain_t2 == .

 hist strainavg_t2
 hist strainavg
 
 
*******************************************
***************  covariates ***************
*******************************************

recode worksit 3/7=0 1/2=1, gen(cworking) 
label define cworking 0 "Not working" 1 "Currently working"
label values cworking cworking

recode worksit_t2 3/7=0 1/2=1, gen(cworking_t2) 
label values cworking_t2 cworking

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




mdesc 	cid rid rgend sgend genrelns ///
		rage yrsliv kidinhh college cworking race day day_t2 ///
		strain strain_t2 sp_strain sp_strain_t2 ///
		strainavg strainavg_t2 ///
		dhrsleep dhrsleep_t2 sp_dhrsleep sp_dhrsleep_t2 ///
		sleepqual sleepqual_t2 sp_sleepqual sp_sleepqual_t2
		
		
browse 	cid rid rage yrsliv kidinhh college cworking race day ///
		strain strain_t2 sp_strain sp_strain_t2 ///
		dhrsleep dhrsleep_t2 sp_dhrsleep sp_dhrsleep_t2 ///
		sleepqual sleepqual_t2 sp_sleepqual sp_sleepqual_t2 if day_t2 == . 
		
browse 	cid rid rage yrsliv kidinhh college cworking race day ///
		strain strain_t2 sp_strain sp_strain_t2 ///
		dhrsleep dhrsleep_t2 sp_dhrsleep sp_dhrsleep_t2 ///
		sleepqual sleepqual_t2 sp_sleepqual sp_sleepqual_t2 if cid == 227 | cid == 249 | cid ==314 | cid == 629 | cid == 633 | cid == 670 
		
		

		// these people have missing T2 data, so I drop them as a couple
drop if cid == 227 | cid == 249 | cid ==314 | cid == 629 | cid == 633 | cid == 670


		replace cworking = cworking_t2 if cworking == .
		drop if day_t2 == .
		
		// for very few missing strain (3) and strain at time 2(7)a, I replace for each other
		replace strainavg = strainavg_t2 if strainavg == . 
		replace strainavg_t2 = strainavg if strainavg_t2 == . 

keep 	cid rid pid rgend sgend genrelns fem pfem day day_t2 ///
		rage rage_t2 yrsliv yrsliv_t2 kidinhh college educ cworking cworking_t2 race ///
		strain* sp_str* ///
		dhrsleep dhrsleep_t2 sp_dhrsleep sp_dhrsleep_t2 ///
		sleepqual sleepqual_t2 sp_sleepqual sp_sleepqual_t2

		
		*******
		** Rename
		*****

	label var dhrsleep "Respondent Daily Sleep Duration at T1"
	label var dhrsleep_t2 "Respondent Daily Sleep Duration at T2"
	label var sp_dhrsleep "Spousal Daily Sleep Duration at T1"
	label var sp_dhrsleep_t2 "Spousal Daily Sleep Duration at T2"
	
	label var sleepqual "Respondent Daily Sleep Quality at T1"
	label var sleepqual_t2 "Respondent Daily Sleep Quality at T2"
	label var sp_sleepqual "Spousal Daily Sleep Quality at T1"
	label var sp_sleepqual_t2 "Spousal Daily Sleep Quality at T2"
	
	label define fem 0 "Respondent man" 1 "Respondent woman"
	label define pfem 0 "Partner man" 1 "Partner woman"
	label val fem fem
	label val pfem pfem
	
	label var yrsliv "Relationship Duration"
	label var yrsliv_t2 "Relationship Duration (T2)"
	label var rage "Respondent age"
	label var rage_t2 "Respondent age (T2)"
	
	label define kidinhh 0 "No children in hh" 1 "Children in hh"
	label val kidinhh kidinhh
	

save  "T:\asya\data_created\SleepT1T2diaryfordesc", replace

	