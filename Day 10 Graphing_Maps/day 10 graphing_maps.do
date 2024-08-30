//Name: Katharine Sadowski
//Date: August 8, 2023
//Purpose: Day 10 Graphing/Maps   

/**************************************************
*Table of Contents
*X.   Bringing in data 
      Census Tiger shapefiles can be found here and placed in the Day 10 Data folder 
	  https://www.census.gov/geographies/mapping-files/time-series/geo/tiger-line-file.html
*1.   Graphing 
*2.   GRMAP: https://www.stata.com/support/faqs/graphics/spmap-and-maps/
**************************************************/

global cd "~\Stata Coding Class\Day 10 graphing_maps\Data"

*X. Install Packages for Mapping 
	ssc install spmap
	ssc install shp2dta
	ssc install mif2dta

*1. Graphing with Stata's US life expectancy data  
	sysuse uslifeexp.dta, clear 
		
	*Histogram 
	hist le, percent 
	
	*Scatter plot 
	scatter le_female year 
	
	*Line graph 
	line le_female year if year>1900 & year<1920

	*Twoway figures  
	twoway (line le_male year if year>1900 & year<1920) (line le_female year if year>1900 & year<1920)
	
	*Adding options 
	twoway (line le_male year if year>1900 & year<1920) (line le_female year if year>1900 & year<1920), title("Yearly Life Expectancy 1900-1920") legend(label(1 "Male") label(2 "Female")) xline(1918)
	
	*Reshape & graph 
	keep le_male le_female year 
	reshape long le_, i(year) j(sex, str)
	twoway (line le year if sex=="male" & year>1900 & year<1920) (line le year if sex=="female" & year>1900 & year<1920), title("Yearly Life Expectancy 1900-1920") legend(label(1 "Male") label(2 "Female")) xline(1918) ytitle("Life Expectancy") xtitle("") ylabel(0(10)60)

	
*2. Mapping State/County Data
	*A. State Data
	*converts shapefile to dataset (creates 2 datasets regular & shape file)
	cd "$cd\tl_2019_us_state\" //have to define where the new datasets will be saved 
	spshape2dta "$cd\tl_2019_us_state\tl_2019_us_state.shp", saving(us_states) replace 
	
	*get the data ready for mapping
	use "$cd\tl_2019_us_state\us_states.dta", clear 
	drop if inlist(STATEFP, "02", "15", "60", "66", "69", "72", "78") //removing non-contiguous areas 
	
	*creating an indicator for graphing (randomly choosing)
	gen rand=0 
	replace rand=1 if inlist(STATEFP, "04", "06", "08", "09", "10", "16", "18", "19") 
	
	*required 3 steps before graphing 
	grmap, activate
	xtset, clear
	spset, modify shpfile(us_states_shp)  
	
	*actually graphing the data 
	grmap rand //basic graph 
	grmap rand, fcolor(white bluishgray) legend(label(2 "No Data") label(3 "Random")) legend(title("Random Status", size(*0.5))) //adding options to make it prettier 
	
	*B. County Data
	*convert to shapefile 
	cd "$cd\tl_2019_us_county"	
	spshape2dta tl_2019_us_county.shp, saving(us_counties) replace
	
	*load data and prepare for mapping 
	use us_counties.dta, clear
	drop if inlist(STATEFP, "02", "15", "60", "66", "69", "72", "78") //removing non-contiguous areas 
	gen rand=0
	replace rand=1 if inlist(STATEFP, "04", "06", "08", "09", "10", "16", "18", "19") 
	
	*set the map 
	grmap, activate
	xtset, clear
	spset, modify shpfile(us_counties_shp)
	
	*graph the map 
	grmap rand, legend(label(2 "No Data") label(3 "Random Data")) legend(title("Random Data", size(*0.5)))  ocolor(gray gray) fcolor(white bluishgray) osize(*0.5)

	*D. Overlay state data on top of county data 
	grmap rand, legend(label(2 "No Data") label(3 "Random Data")) legend(title("Random Data", size(*0.5)))  ocolor(gray gray) fcolor(white bluishgray) osize(*0.5) polygon(data("$cd\tl_2019_us_state\us_states_shp.dta") select(drop if inlist(_ID,32, 35, 36, 37, 41, 42, 50)))
		 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 