//Name: Katharine Sadowski
//Purpose: Locals, Macros, Temporary Datasets, and loops Tutorial 
//Use case: Updating the major/occupation crosswalk from day 4

/**************************************************
*DEFINITIONS
*1. Locals - only active when you run a subset of code
*2. Global macro - active during entire Stata session
*3. Temporary files - only active when you run a subset of code
*4. Stored values - only active until you run something that overwrites the values
*5. Resource for loops - https://www.stata.com/support/faqs/data-management/try-all-values-with-foreach/
**************************************************
*TABLE OF CONTENTS:  
1. Bringing in Data   
2. Building Crosswalk  
3. Reviewing the data with loops  
**************************************************/

*1. Bringing in Data 
	global cd "~\Stata Coding Class\"
	dis "$cd"
	*import delimited "C:\Users\kcs3a\Box Sync\Cornell\Stata Coding Class\Day 4 Merging\data\ba_jobs.csv", varnames(1) clear 
	import delimited "$cd\Day 4 Merging\data\ba_jobs.csv", varnames(1) clear 

	*Converting 6 digit major code (CIP6) into 2 digit
	local l=2 //determine the level of digits we want for the CIP 
	tostring cip6, replace force
	replace cip6=subinstr(cip6, ".", "", .)
	drop if cip6=="NA"
	replace cip6="0"+cip6 if strlen(cip6)==5
	drop if strlen(cip6)<6
	gen cip`l'=substr(cip6, 1, 2)
	destring cip`l', replace
	drop if cip`l'==99
		
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
	*save "C:\Users\kcs3a\Box Sync\Cornell\Stata Coding Class\Day 4 Merging\data\samp.dta", replace 
	tempfile samp 
	save `samp', replace 
		
	*Imputation scheme
	preserve 
		use "$cd\Day 4 Merging\data\soc2.dta", clear 
		sum soc2
		return list //shows stored values 
		local obs=r(N) //saving the number of obs we need for expansion 
		dis `obs'
	restore 
	
	clear all 
	import excel "$cd\Day 4 Merging\data\cip.xlsx", sheet("CIP2") firstrow clear
	expand `obs' //previously handcoded expansion 22
	bysort cip2: gen n=_n
	merge m:1 n using "$cd\Day 4 Merging\data\soc2.dta", nogen
	drop n
	*save "$cd\Day 4 Merging\data\impute.dta", replace 
	tempfile impute 
	save `impute', replace
	
	*Connecting data and converting to zeros 
	use `samp', clear
	merge 1:1 cip2 soc2 using `impute', gen(m1)
	drop if soc2==22 //these aren't in our imputed dataset
	drop if inlist(cip2, 2, 6, 28, 39, 60, 61) //not BA majors - incorrect codes in ba_job file
	replace unique=0 if m1==2
	sort cip2 soc2
	drop m1 
	
	*Fun last bit creating new variables 
	order cip2 Description soc2 soc2_desc unique
	bysort cip2: egen cip_total=sum(unique)
	gen soc_cip_prop=(unique/cip_total)*100
	
	
*3. Reviewing the data with local/loop 
	*Loop through variables 
	foreach ed of varlist unique cip_total soc_cip_prop {
		rename `ed' `ed'_1 //renaming variables
	}
	
	*Define your own local values and loop through them
	local cip2 1 3 4 5 
	foreach l of local cip2 {
		dis `l'
	} 
	
	*Create a local of all of the cip2 values without listing them 
	levelsof cip2, local(levels) 
	foreach l of local levels {
		*dis `l'
		sum cip_total if cip2==`l' //print the summary stats for each cip2
	}

	*Looping through and bringing in multiple files 
	preserve 
		clear all
		tempfile temp 
		save `temp', replace emptyok
	restore 
	
	local file ba_1 ba_2
	foreach l of local file {
		dis "`l'"
		import excel "$cd\Day 4 Merging\data\\`l'.xlsx", sheet("Sheet1") firstrow clear
		gen samp="`l'"
		append using `temp' 
		save `temp', replace 
	} 
	
	use `temp', clear 
	drop if missing(cip6)

	*Forvalue loops - looping 	
	forvalues i=1/2 {
		dis `i'
	}

	*Advanced - looping through parallel lists 
	preserve 
		clear all
		tempfile temp 
		save `temp', replace emptyok
	restore 
 
	local file_name ba_1 ba_2
	local source source_1 source_2 
	local n: word count `file_name'
	forvalues i=1/`n' {
		local a : word `i' of `file_name'
		local b : word `i' of `source'
		import excel "$cd\Day 4 Merging\data\\`a'.xlsx", sheet("Sheet1") firstrow clear
		gen source="`b'"
		append using `temp' 
		save `temp', replace 		
	}
	
	use `temp', clear 
	drop if missing(cip6)
	

	
	
	
	
