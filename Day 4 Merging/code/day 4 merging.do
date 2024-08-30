//Name: Katharine Sadowski
//Purpose: Merging Tutorial 
//Use case: Creating a major/occupation crosswalk - determine the number of people from X major, employed in Y occupation

/******************************
*Table of Contents 

*UCLA Tutorial: https://stats.oarc.ucla.edu/stata/modules/combining-data/

X. Review of Data Cleaning  
1. Merging 1:1 and 1:m (1 to 1 and 1 to many) 
	A. option 1: ", gen(your_var_name)" 
	B. option 2: ", nogen"
	C. Other types of merges (not covered) fuzzy merges and many to many merges
2. Checking the data after the merge   
3. Common errors and how to deal with them 
*********************************/ 

global cd "~\Stata Coding Class\"

*1. Bringing in Data 
	import delimited "$cd\Day 4 Merging\data\ba_jobs.csv", varnames(1) clear 

	*Converting 6 digit major code (CIP6) into 2 digit
	tostring cip6, replace force
	replace cip6=subinstr(cip6, ".", "", .)
	drop if cip6=="NA"
	
	*do you need leading zero's? two options
	replace cip6="0"+cip6 if strlen(cip6)==5 //first option
	drop if strlen(cip6)<6
	drop cip6 
	
	gen cip6 = string(cip6 ,"%05.0f") //second option 
	
	*creating a 2 digit MAjor code & destringing 
	gen cip2=substr(cip6, 1, 2)
	destring cip2, replace
	drop if cip2==99
		
	*Converting 6 digit occupation code (SOC6) into 2 digit
	drop if soc6=="NA"
	replace soc6=subinstr(soc6, "-", "", .)
	gen soc2=substr(soc6, 1, 2)
	drop if soc2=="99" | soc2=="55"
	replace soc2="11" if soc2=="No"
	destring soc2, replace
	
	
*2. CIP2/SOC2 distribution  	
	
	*Counting the total number of observations per major/occupation
	gen unique=1 //every row is a unique observation 
	collapse (sum) unique, by(cip2 soc2) 
	sort cip2 soc2
	save "$cd\Day 4 Merging\data\samp.dta", replace 
		
	*Imputation scheme
	clear all 
	import excel "$cd\Day 4 Merging\data\cip.xlsx", sheet("CIP2") firstrow clear //this is our MASTER dataset 
	expand 22 //let's create duplicates of each variable 
	bysort cip2: gen n=_n //foreach CIP let's create a unique identifier n that goes from 1 to n 
	merge m:1 n using "$cd\Day 4 Merging\data\soc2.dta", nogen //soc2.dta is our USING dataset
	drop n
	save "$cd\Day 4 Merging\data\impute.dta", replace 
	
	*Connecting data and converting to zeros 
	use "$cd\Day 4 Merging\data\samp.dta", clear 
	merge 1:1 cip2 soc2 using "$cd\Day 4 Merging\data\impute.dta", gen(m1) //generates a variable m1 that allows us to see the match between the two datasets 
	drop if soc2==22 //these aren't in our imputed dataset
	drop if inlist(cip2, 2, 6, 28, 39, 60, 61) //not BA majors - incorrect codes in ba_job file
	replace unique=0 if m1==2
	sort cip2 soc2
	drop m1 
	
	*Fun last bit creating new variables 
	order cip2 Description soc2 soc2_desc unique
	bysort cip2: egen cip_total=sum(unique)
	gen soc_cip_prop=(unique/cip_total)*100
	
*3. Common errors & decoding what they mean 

    //"variable [X] does not uniquely identify observations in the using data"
    //"variable [X] does not uniquely identify observations in the master data"
    //"variable [X] is string in master but numeric in using"
	

