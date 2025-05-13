********************************************************************************
* How does sleep patterns are associcated with marital strain? or vice versa
* How couple concordance for sleep behavior look like?
* by Asya Saydam (asyasaydam@utexas.edu)
* Fall 2024
********************************************************************************

******************** 
** Project set up ** 
********************
** later to push to github **


cd
global basecode "T:\github_new\Projects\HARP\Sleep"

**************************************************
********* Merge files and recode variables ********
**************************************************

do "$basecode\T1_SleepStrain_Analysis.do" // all the coding is here.
do "$basecode\T1T2_SleepStrain_Variables.do" // merges with T2