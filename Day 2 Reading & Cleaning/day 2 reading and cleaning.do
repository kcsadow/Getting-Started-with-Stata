//Name: Katharine Sadowski
//Date: June 6, 2023
//Purpose: Day 2 Reading and Cleaning Data

/**************************************************
*Table of Contents
*1.     Pulling in Data
*2.     Data Checks
*3.     Simple Cleaning Tricks
*4.     Summarizing Data 
*Extra: Resources for helping when you're stuck
        A. ChatGPT
		B. UCLA https://stats.oarc.ucla.edu/stata/seminars/stata-16-class-notes/stata-class-notes-modifying-data/
		C. Google (and Nick Cox)
**************************************************/

global cd "~\Stata Coding Class\" //fill in with where the file is located - you can find this by right clicking on the file and getting the path

*1. Pulling in Data
	
	*A. Excel 
	*import excel "$cd\Day 2 Reading & Cleaning\Data\nyc_ela.xlsx", sheet("All") clear 
	
	*B. CSV
	*import delimited "$cd\Day 2 Reading & Cleaning\Data\nyc_ela_all.csv",  encoding(UTF-8) clear 
	
	*C. Stata 
	use "$cd\Day 2 Reading & Cleaning\Data\ny_sch.dta", clear
	
	*D. Other (IPEDS Access Database: location "C:\Users\kcs3a\Box Sync\Cornell\Stata Coding Class\Day 2 Reading & Cleaning\Data"
	*odbc load UNITID="UNITID" INSTNM="INSTNM" IALIAS="IALIAS" ADDR="ADDR" CITY="CITY" STABBR="STABBR" ZIP="ZIP" FIPS="FIPS" OBEREG="OBEREG" CHFNM="CHFNM" CHFTITLE="CHFTITLE" GENTELE="GENTELE" EIN="EIN" DUNS="DUNS" OPEID="OPEID" OPEFLAG="OPEFLAG" ADMINURL="ADMINURL", table("HD2021") clear lowercase
	
	
*2. Data Checks

	browse //look at the data 
	br 
	
	codebook year //see the number of missing variables, values 
	
	count if missing(zip_location) //count the number of times a variable is missing
	
	expand 2 //duplicate every row 
	
	egen tag=tag(year ncessch_num) //determine whether there are duplicates of a variable
	tab tag 
	
	duplicates tag year ncessch_num, gen(dup) //determine which pairs are duplicates 
	tab dup
	
	keep if tag==1 //this keeps only 1 observation for each sch x year 
	drop tag dup 
	
*3. Simple Cleaning Tricks
	
	*A. Generate new variables 
	egen group=group(year ncessch_num) //create a group variable based on some ID
	
	gen title1_yn=0 if !missing(title_i_eligible) & title_i_eligible==0
	replace title1_yn=1 if title_i_eligible==1
	tab title1_yn
		
	tab school_level, gen(sch_lev) //for categorical variables, this will create a new set of variables with the prefix sch_lev
	
	*B. Labeling variables 
	label var sch_lev1 "Prekindergarten"
	rename sch_lev1 sch_lev_pk
	
	*C. Cleaning variables 
	gen sch_name=school_name //always clean a copy of the variable - never the variable itself
	replace sch_name=subinstr(sch_name, "-", " ", .) //replaces - in string with a space
	replace sch_name=lower(sch_name)
	
	*D. Renaming variables 
	rename ncessch_num nces_id
	rename *, upper //converts all variable labels to lowercase 
	rename *, lower //converts all variable labels to lowercase 
	
*4. Summarizing Data 

	tab school_level //basic tabulation - one variable
	tab school_level title_i_eligible, chi2  //two variable (twoway) tabulation, with a chi2 distribution test
	
	sum enrollment, detail //summarizes the variable and adds additional info

	egen ind_yr_sch=tag(year ncessch_num) //creating an indicator for each school/year unique pair
	bysort ncessch_num: egen tot_panel_length=sum(ind_yr_sch) //this counts the total number of unique years a school is in the panel
	egen sch_tag=tag(ncessch_num) //tags each school one time 
	tab tot_panel_length if sch_tag==1 //this gives us the total # of schools in the panel for X # of years 
	
	*When thinking about determining your sample, you might want to limit it to ensure the sample is similar on observed characteristics
	*keep if tot_panel_length==11 //keep only schools where they appear every year in our panel 

	hist enrollment, graphregion(color(white)) percent  //histogram of the data with percent instead of frequency
	
	save "temp.dta", replace 
	
*****************************
	use "temp.dta", clear  //how do you determine where this goes? check Stata 
	
	collapse (mean) enrollment, by(year) //collapse the dataset to the level Y and determine the mean of X for each Y
	 
	
	
	
	
	