//Name: Katharine Sadowski
//Date: June 14, 2023
//Purpose: Day 3 APIs
//Data can be stored in a variety of formats - so let's explore an increasingly common storage system - APIs

/**************************************************
*Table of Contents
*X. Set up Keys 
*1. Urban Education Data 
*2. Census (IPUMS/ACS)
    Requires a key
**************************************************/

**************************
*X. Set Up  
*Sometimes you have to install packages that aren't standard in Stata
**************************

ssc install educationdata
ssc install getcensus 
ssc install jsonio
global key_ //fill in with your key - to get a key go to https://api.census.gov/data/key_signup.html

****************************************************
*1. Urban Institute - Education Data  
*Source:  https://educationdata.urban.org/documentation/
****************************************************

*Pulling in IPEDS college data from 2011-2013 for Florida (FIPS 12)
educationdata using "college ipeds directory", sub(year=2011:2013 fips=12) clear

*Check to make sure dataset is unique at school-year level 
egen sch_yr=tag(unitid year)
tab sch_yr //check this count against total obs in the dataset
drop sch_yr


****************************************************
*2. Census - ACS 5-year estimates - Education Data 
*Source: NHGIS https://www.nhgis.org/
****************************************************

*Pulling in data 
clear all
getcensus B15003, geography(zcta) sample(5) years(2010-2021) key($key_) //Education table - 5 year ACS, ZIP x Year 
keep if state==36 //new york only

*Converting variables 
rename b15003_001e total_pop //rename to total population 
drop *m
egen hs_less=rowtotal(b15003_002e-b15003_018e) //sum all rows where education is HS or less
egen some_coll=rowtotal(b15003_019e b15003_020e) //sum all rows where education is some college
rename b15003_021e aa_some //renaming to AA 
egen ba_plus=rowtotal( b15003_022e b15003_023e b15003_024e b15003_025e) //create BA plus variable

*Creaitng percentages 
gen edu_hs_p=(hs/total_pop)*100 
gen edu_some_coll_p=(some_coll/total_pop)*100
gen edu_aa_p=(aa/total_pop )*100
gen edu_ba_plus_p=(ba_plus/total_pop )*100

*Final data preparations  
keep year zipcodetabulationarea edu_hs_p edu_some_coll_p edu_aa_p edu_ba_plus_p
rename zipcodetabulationarea zip 
destring zip, replace 
