//Name: Katharine Sadowski
//Date: July 18, 2023
//Purpose: Day 8 Putexcel (one of many options to output results)

/**************************************************
*Table of Contents
*1.   Cleaning Data 
*2.   Ttest Part 1 
*3.   Reshaping Data 
*4.   Ttest Part 2
*5.   Storing Values in a Matrix
**************************************************/

global cd "~\Stata Coding Class\"

*1. Pulling in School ELA Test Scores for NYC 
	import excel "$cd\Day 2 Reading & Cleaning\Data\nyc_ela.xlsx", sheet("All") firstrow clear 
	rename *, lower
	replace meanscalescore="" if meanscalescore=="s"
	destring meanscalescore, replace 
	drop if missing(meanscalescore)
	keep dbn grade year meanscalescore
	drop if grade=="All Grades" 
	destring grade, replace
	reshape wide meanscalescore, i(dbn grade) j(year)
		
*5. Define a matrix 
	putexcel set "$cd\Results\Day 7 Results\"
	
	matrix ttest_results=J(6, 3, .) //6 rows, 3 columns
	matrix list ttest_results
	
	local r=1
	levelsof grade, local(levels)
	foreach l of local levels {
		ttest meanscalescore2016=meanscalescore2017 if grade==`l' //compare # of obs - DIFFERENT
		matrix ttest_results[`r',1]=r(mu_1)
		matrix ttest_results[`r',2]=r(mu_2)
		matrix ttest_results[`r',3]=round(r(p), .1)
		local r=`r'+1
	}
	matrix list ttest_results
	
	putexcel 

	preserve 
		svmat ttest_results
		keep ttest_results*
		drop if missing(ttest_results1)
		count if ttest_results3<0.001
		save "temp"
	restore 
	
	
	
	
	
	