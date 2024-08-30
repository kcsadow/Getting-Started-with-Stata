//Name: Katharine Sadowski
//Date: July 18, 2023
//Purpose: Day 8 Outputting Results  

/**************************************************
*Table of Contents
*1.   Cleaning Data 
*2.   Putexcel: https://www.stata.com/manuals/rptputexcel.pdf
*3.   Postfile: https://www.stata.com/manuals/ppostfile.pdf
*4.   Estout: http://repec.org/bocode/e/estout/esttab.html
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
		
*2. Putexcel  
	putexcel set "$cd\Day 8 Outputting Results\Results\ttest_table.xlsx", sheet("Ttest") modify
	
	matrix ttest_results=J(6, 3, .) //6 rows, 3 columns
	matrix list ttest_results
	
	local r=1
	levelsof grade, local(levels)
	foreach l of local levels {
		ttest meanscalescore2016=meanscalescore2017 if grade==`l' //compare # of obs - DIFFERENT
		matrix ttest_results[`r',1]=round(r(mu_1), .1)
		matrix ttest_results[`r',2]=round(r(mu_2), .1)
		matrix ttest_results[`r',3]=round(r(p), .1)
		local r=`r'+1
		putexcel A`r'="Grade `l'"
	}
	matrix list ttest_results
	
	putexcel B1="2016 Mean"
	putexcel C1="2017 Mean"
	putexcel D1="P-value"
	putexcel B2=matrix(ttest_results) 
	
	
*3. Postfile 
	tempname ttestparm
	tempfile outfile

	postfile `ttestparm' mu1 mu2 diff_p using `outfile',replace //names of your output
	levelsof grade, local(levels)
	foreach l of local levels {
		ttest meanscalescore2016=meanscalescore2017 if grade==`l' //compare # of obs - DIFFERENT
		post `ttestparm' (`r(mu_1)') (`r(mu_2)') (`r(p)') //your output variables 
	}
	postclose `ttestparm'
	
	preserve
	use `outfile',clear 
	export excel using "$cd\Day 8 Outputting Results\Results\ttestout.xlsx", firstrow(variables) replace
	restore	
	
*4. estout 
	reshape long meanscalescore, i(dbn grade) j(year)
	estpost ttest meanscalescore if grade==3 & (year==2016 | year==2017), by(year)
	esttab using "$cd\Day 8 Outputting Results\Results\ttest_esto.csv", cells("mu_1 mu_2 p  N_1") nonumber label replace
 
	
	
	
	