//Name: Katharine Sadowski
//Date: August 2, 2023
//Purpose: Day 9 Regressions   

/**************************************************
*Table of Contents
*1.   Cleaning Data 
*2.   Putexcel: https://www.stata.com/manuals/rptputexcel.pdf
*3.   Postfile: https://www.stata.com/manuals/ppostfile.pdf
*4.   Estout: http://repec.org/bocode/e/estout/esttab.html
**************************************************/

global cd "~\Stata Coding Class\Day 9 Regressions\Data"

*1. Simple regressions  
	*Categorical v continuous variables 
	sysuse auto, clear 
	reg mpg price weight length  
	
	reg mpg c.price c.weight c.length i.make //error 
	
	egen make_=group(make)
	reg mpg c.price c.weight c.length i.make_ //no error - ommitted variables
	
	tab make, gen(make_2_)
	reg mpg c.price c.weight c.length make_2_1- make_2_74
	
	*Linear combinations 
	gen price_weight=price+weight
	reg mpg price weight price_weight //omitted
	
	*Exponentials
	gen price2=price*price
	reg mpg weight price price2 //allowed
		
*2. Standard Errors 
	*Pulling in census data 
	import delimited "$cd\census.csv", clear  
	
	reg learn hours //OLS
	reg learn hours, vce(robust) //OLS + robust standard errors 
	reg learn hours, cluster(state) //OLS + clustered standard errors 
	
*3. Fixed Effects 	
	areg learn hours, absorb(state) //not always right SE
	
	xtset state 
	xtreg learn hours, fe //correct SE
	
	reghdfe learn hours, absorb(state) //correct SE

*4. 2-way Fixed Effects (or more)
	*slight data manipulation 
	generate random = runiform()
	sum random
	gen year=2017 if random<r(mean)
	replace year=2018 if missing(year)
	
	areg learn hours, absorb(state year) //error 
	
	xtset state year //error 
	xtreg learn hours, fe
	
	xtset state 
	xtreg learn hours year, fe 
	
	reghdfe learn hours, absorb(state year) //can absorb more than one variable 
	reghdfe learn hours, absorb(state##year) //can take the interaction of these
	
