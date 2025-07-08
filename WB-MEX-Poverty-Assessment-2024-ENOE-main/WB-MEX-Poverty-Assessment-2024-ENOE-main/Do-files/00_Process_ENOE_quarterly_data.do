*! v0.6 iosoriorodarte@worldbank.org 11/18/2023
*! v0.5 iosoriorodarte@worldbank.org 03/24/2023
*! v0.4 iosoriorodarte@worldbank.org 03/02/2023
*! v0.2 esuarezmoran@worldbank.org 12/09/2022
*! v0.1 iosoriordarte@worldbank.org 13/07/2022
/*******************************************************************************
ENOE Surveys from 2005 to 2020 were harmonized using the World Bank 
Global Labor Database (GLD V03 template)
Visit: https://github.com/worldbank/gld

Developed by:
	Israel Osorio Rodarte
	Brenda Samaniego de la Parra
	Eugenia Suarez Moran
*******************************************************************************/

clear
frame reset

*-- Set up paths
global path "C:/Users/Alex/Downloads/GLD"
global temp "$path/PANEL/temp"

*-- Set parts to run
local part0  ""
local part1  "yes"
local part2  "yes"

local iniyear = 2005
local finyear = 2025

//
// ********************************************************************************
// * Part 1. Append Panel and Incorporate Variables
// ********************************************************************************
// if "`part1'"=="yes" {
//			
// 	****************************************************************************
// 	* Declare myfrappend
// 	cap program drop myfrappend
// 	program define myfrappend
// 		version 16
// 		syntax varlist, from(string)
//
// 		confirm frame `from'
//
// 		// Step 1: Ensure types match before assignment
// 		foreach var of varlist `varlist' {
// 			// Check variable existence
// 			capture frame `from': confirm variable `var'
// 			if _rc {
// 				noi di as error "⚠️ Variable `var' not found in frame `from'"
// 				continue
// 			}
// 			capture confirm variable `var'
// 			if _rc {
// 				noi di as error "⚠️ Variable `var' not found in current frame"
// 				continue
// 			}
//
// 			// Get types and string lengths from both frames
// 			frame `from' {
// 				capture confirm numeric variable `var'
// 				if _rc {
// 					local from_type = "str"
// 					// Get string length
// 					quietly summarize `var' if `var' != ""
// 					if r(N) > 0 {
// 						local from_len = 0
// 						quietly levelsof `var', local(levels)
// 						foreach level of local levels {
// 							local len = length("`level'")
// 							if `len' > `from_len' {
// 								local from_len = `len'
// 							}
// 						}
// 						// Ensure minimum length
// 						if `from_len' < 10 {
// 							local from_len = 10
// 						}
// 					}
// 					else {
// 						local from_len = 10
// 					}
// 				}
// 				else {
// 					local from_type = "num"
// 					local from_len = 0
// 				}
// 			}
//			
// 			frame default {
// 				capture confirm numeric variable `var'
// 				if _rc {
// 					local def_type = "str"
// 					// Get string length
// 					quietly summarize `var' if `var' != ""
// 					if r(N) > 0 {
// 						local def_len = 0
// 						quietly levelsof `var', local(levels)
// 						foreach level of local levels {
// 							local len = length("`level'")
// 							if `len' > `def_len' {
// 								local def_len = `len'
// 							}
// 						}
// 						// Ensure minimum length
// 						if `def_len' < 10 {
// 							local def_len = 10
// 						}
// 					}
// 					else {
// 						local def_len = 10
// 					}
// 				}
// 				else {
// 					local def_type = "num"
// 					local def_len = 0
// 				}
// 			}
//
// 			// Handle type mismatches
// 			if "`from_type'" != "`def_type'" {
// 				noi di as text "⚠️ Type mismatch for `var': converting default:`def_type' → `from_type'"
//
// 				if "`from_type'" == "num" {
// 					frame default {
// 						// Convert string to numeric
// 						capture destring `var', replace force
// 						if _rc {
// 							// If destring fails, create numeric version
// 							capture drop `var'_temp
// 							encode `var', gen(`var'_temp)
// 							drop `var'
// 							rename `var'_temp `var'
// 						}
// 					}
// 				}
// 				else if "`from_type'" == "str" {
// 					frame default {
// 						// Convert numeric to string with adequate length
// 						local max_len = max(`def_len', `from_len')
// 						if `max_len' < 20 {
// 							local max_len = 20
// 						}
// 						tostring `var', replace format(%20.0g) force
// 						// Ensure adequate string length
// 						recast str`max_len' `var', force
// 					}
// 				}
// 			}
// 			else if "`from_type'" == "str" & "`def_type'" == "str" {
// 				// Both are strings, ensure adequate length
// 				local max_len = max(`def_len', `from_len')
// 				if `max_len' < 20 {
// 					local max_len = 20
// 				}
// 				frame default {
// 					capture recast str`max_len' `var', force
// 				}
// 			}
//
// 			// Final type check
// 			frame default {
// 				capture confirm numeric variable `var'
// 				local def_type_final = cond(_rc, "str", "num")
// 			}
//			
// 			if "`def_type_final'" != "`from_type'" {
// 				noi di as error "❌ Type still mismatched after conversion for `var'. Skipping variable."
// 				continue
// 			}
// 		}
//
// 		// Step 2: Append values safely
// 		frame `from': local obstoadd = _N
// 		if `obstoadd' == 0 {
// 			noi di as text "⚠️ No observations to append from frame `from'"
// 			exit
// 		}
//		
// 		local startn = _N + 1
// 		set obs `=_N + `obstoadd''
//
// 		foreach var of varlist `varlist' {
// 			// Skip if variable had type issues
// 			capture confirm variable `var'
// 			if _rc continue
//			
// 			frame `from' {
// 				capture confirm variable `var'
// 				if _rc continue
// 			}
//			
// 			// Perform the replacement with multiple fallback strategies
// 			local success = 0
//			
// 			// Strategy 1: Direct replacement
// 			capture replace `var' = _frval(`from', `var', _n - `startn' + 1) in `startn'/L
// 			if _rc == 0 {
// 				local success = 1
// 			}
//			
// 			// Strategy 2: Force string conversion if direct replacement fails
// 			if `success' == 0 {
// 				noi di as text "⚠️ Direct replacement failed for `var', trying string conversion..."
//				
// 				// Convert both to string temporarily
// 				capture {
// 					tempvar temp_var
// 					frame `from' {
// 						tostring `var', gen(`temp_var') force
// 					}
// 					tostring `var', replace force
// 					replace `var' = _frval(`from', `temp_var', _n - `startn' + 1) in `startn'/L
// 					frame `from' {
// 						drop `temp_var'
// 					}
// 				}
// 				if _rc == 0 {
// 					local success = 1
// 					noi di as text "✅ String conversion successful for `var'"
// 				}
// 			}
//			
// 			// Strategy 3: Manual loop if batch replacement fails
// 			if `success' == 0 {
// 				noi di as text "⚠️ Batch replacement failed for `var', trying manual loop..."
//				
// 				capture {
// 					frame `from': local from_obs = _N
// 					forvalues i = 1/`from_obs' {
// 						local obs_num = `startn' + `i' - 1
// 						if `obs_num' <= _N {
// 							local val = _frval(`from', `var', `i')
// 							replace `var' = `val' in `obs_num'
// 						}
// 					}
// 				}
// 				if _rc == 0 {
// 					local success = 1
// 					noi di as text "✅ Manual loop successful for `var'"
// 				}
// 			}
//			
// 			// Strategy 4: Fill with missing values if all else fails
// 			if `success' == 0 {
// 				noi di as error "❌ All strategies failed for `var'. Filling with missing values to preserve structure."
//				
// 				// Determine appropriate missing value type
// 				capture confirm numeric variable `var'
// 				if _rc == 0 {
// 					// Numeric variable - use . for missing
// 					replace `var' = . in `startn'/L
// 				}
// 				else {
// 					// String variable - use "" for missing
// 					replace `var' = "" in `startn'/L
// 				}
// 				local success = 1
// 			}
//			
// 			if `success' == 0 {
// 				noi di as error "❌ CRITICAL: Unable to handle variable `var' - this should not happen!"
// 			}
// 		}
//		
// 		noi di as text "✅ Successfully appended `obstoadd' observations from frame `from'"
// 	end
//
//
// // 		cap program drop myfrappend
// // 		program myfrappend
// // 			version 16
// //
// // 			syntax varlist, from(string)
// //
// // 			confirm frame `from'
// //
// // 			foreach var of varlist `varlist' {
// // 				confirm var `var'
// // 				frame `from' : confirm var `var'
// // 			}
// //
// // 			frame `from': local obstoadd = _N
// //
// // 			local startn = _N+1
// // 			set obs `=_N+`obstoadd''
// //
// // 			foreach var of varlist `varlist' {
// // 				replace `var' = _frval(`from',`var',_n-`startn'+1) in `startn'/L
// // 			}
// // 		end
// 	****************************************************************************			
//			
// 	frame change default
// 	cap frame drop frameglobal
//	
// 	local cycle = 1
// 	forvalues yyyy =  `iniyear'/`finyear' {
// 	forvalues qq = 1/4 {
// 		clear
// 		local counter = (`yyyy'-2005)*4 + `qq'
//		
// 		if !inlist(`counter', 62) & `counter' <= 81 {
// 				noi di "MEX_`yyyy'_ENOE-Q`qq'"
// 				if `yyyy' == 2014 & `qq' == 1 {
// 					set trace on
// 					set tracedepth 1
// 				}		
// 				if `yyyy' >= 2014 & `qq' == 3 {
// 					set trace off
// 				}	
// 					use "$path/Data/MEX_`yyyy'_ENOE-Q`qq'/MEX_`yyyy'_ENOE_V01_M_V06_A_GLD/Data/Harmonized/MEX_`yyyy'_ENOE_V01_M_V06_A_GLD_ALL.dta", clear
// 				noi di "------"
// 				noi di ""
// 				if _N == 0 {
// 				  di as error "⚠️ File exists but is empty: `yyyy' Q`qq'"
// 				  continue
// 				}				
//		
// 			* Add quarter variable
// 			qui {
// 				cap gen byte quarter = `qq'
// 				cap gen union = . 
// 				cap gen healthins = . 
// 				cap gen subnatid3 = .
// 				cap gen socialsec = .	
// 				cap gen industrycat_isic = .
// 				cap gen industrycat10 = .
// 				cap gen industrycat4 = .
// 				cap gen industrycat_isic_2 = . 
// 				cap gen industrycat10_2 = .
// 				cap gen industrycat4_2 = .
// 				cap gen p3r_anio = .
// 				cap gen p3r_mes = .
// 				cap gen p3r = .
// 				cap gen p3s = . 
// 				cap gen p3t = .
// 				cap gen p3t_anio = .
// 				cap gen p3t_mes = .
// 				cap gen loc = .
// 				cap gen mun = .
// 				cap gen firmsize_l_2 = .
// 				cap gen tipo = ""
// 				cap gen mes_cal = ""
// 				cap gen ca = ""
//				
// 				foreach var in p2a_dia p2a_sem p2a_mes p2a_anio p2b_dia  p2b_sem p2b_mes p2b_anio p2b p2d1 ///
// 							   p2d2 p2d3 p2d4 p2d5 p2d6 p2d7 p2d8 p2d9 p2d10 p2d11 p2d99 p3n p3r_anio		///
// 							   p3r_mes p3r p3s p3t_anio p3t_mes {
// 					cap gen `var' = .
// 				}
//				
// 			}
//
// 			* APPEND FRAMES
// 			if `cycle' == 1 {	
// 				frame put _all, into(frameglobal)
// 				frame change default
// 			}
// 			else {
// 				frame change frameglobal
// 				quietly myfrappend _all, from(default)
// 				frame change default
// 			}
//			
// 			local cycle = `cycle'+1
// 		}
// 	}
// 	}
//
// 	frame change frameglobal
// 	compress
//	
// 	* Delete duplicates
// 		duplicates report
// 		duplicates drop
//
// 	* Clean unnecesary variables
// 		drop countrycode survname survey vermast veralt harmonization subnatid3 loc
//
// 	* Encode string variables
// 		foreach var in icls_v isced_version isco_version isic_version subnatid1 subnatid2 {
// 			capture confirm numeric variable `var'
// 			if _rc {
// 				encode `var', gen(s`var')
// 				drop `var'
// 				rename s`var' `var'
// 			}
// 			else {
// 				noi di "Variable `var' is already numberic"
// 			}
// 		}
//		
// 	* Informal/Formal/Unemployed population
// 		clonevar informal = emp_ppal
// 			label var informal "Classification of employment by formal/informal/unemployed"
// 			recode informal (0=3)
// 			recode informal (2=0)
// 			label def informal 1 "Informal" 0 "Formal" 3 "Not Employed", replace
// 			label val informal informal		
//	
// 	* Fix wrong label in subnatid1
// 		label de lblsubnatid1 1 "Aguascalientes" 2 "Baja California" 3 "Baja California Sur" 4 "Campeche" 5 "Coahuila de Zaragoza" 6 "Colima" 7 "Chiapas" 8 "Chihuahua" 9 "Ciudad de Mexico" 10 "Durango" 11 "Guanajuato" 12 "Guerrero" 13 "Hidalgo" 14 "Jalisco" 15 "Mexico" 16 "Michoacan de Ocampo" 17 "Morelos" 18 "Nayarit" 19 "Nuevo Leon" 20 "Oaxaca" 21 "Puebla" 22 "Queretaro de Arteaga" 23 "Quintana Roo" 24 "San Luis Potosi" 25 "Sinaloa" 26 "Sonora" 27 "Tabasco" 28 "Tamaulipas" 29 "Tlaxcala" 30 "Veracruz de Ignacio de la Llave" 31 "Yucatan" 32 "Zacatecas", replace
// 		label values subnatid1 lblsubnatid1
//
// 	* Fix labels in subnatid2
// 		label define lblsubnatid2 1 "Ciudad de Mexico" 2 "Guadalajara" 3 "Monterrey" 4 "Puebla" 5 "Leon" 6 "Torreon" 7 "San Luis Potosi" 8 "Merida" 9 "Chihuahua" 10 "Tampico" 12 "Veracruz" 13 "Acapulco" 14 "Aguascalientes" 15 "Morelia" 16 "Toluca" 17 "Saltillo" 18 "Villahermosa" 19 "Tuxtla Gutierrez" 20 "Juarez" 21 "Tijuana" 24 "Culiacan" 25 "Hermosillo" 26 "Durango" 27 "Tepic" 28 "Campeche" 29 "Cuernavaca" 30 "Coatzacoalcos" 31 "Oaxaca" 32 "Zacatecas" 33 "Colima" 36 "Queretaro" 39 "Tlaxcala" 40 "La Paz" 41 "Cancun" 42 "Ciudad del Carmen" 43 "Pachuca" 44 "Mexicali" 46 "Reynosa" 52 "Tapachula" 81 "Complemento Urbano Rural", replace
// 		label values subnatid2 lblsubnatid2
//
// 	* Create a completeness score for the 22 duplicates
// 	gen completeness = 0
// 	foreach var of varlist age male lstatus wage_total empstat {
// 		replace completeness = completeness + 1 if !missing(`var')
// 	}
//
// 	* Keep the most complete observation for each duplicate group
// 	bysort pid year quarter n_ent (completeness): keep if _n == _N
//
// 	* Clean up
// 	drop completeness
//
// 	* Verify
// 	isid pid year quarter n_ent	
// 	* Check Individual Identifier
// 	*isid report pid year quarter n_ent tipo
//
//
// 	***************************
// 	* Generate Panel Variables
// 	***************************
//
// 	egen foliop = concat(cd_a ent con v_sel n_hog h_mud n_ren) if tipo!="2"
// 	egen folioh = concat(cd_a ent con v_sel n_hog h_mud)       if tipo!="2"
//
// 	gen byte time = ((year-2005)*4) + quarter
// 		label variable time "Time, quarterly (2005.Q1 = 1)"
//		
// 	destring n_ent, replace
// 	gen byte panel = (time - n_ent) + 1 
//		
// 	label variable panel "Panel Time ID (2005.Q1 to 2006.Q1==1)"
//			
// 	sort panel foliop n_ent
// 	egen pid_p = group(panel foliop) if tipo!="2"
//	
//		
// 	* Missing month
// 		cap drop mis_int_month
// 		bys pid_p: egen mis_int_month = max((int_month == .))
// 			* drop if mis_int_month == 1 // This is a restriction for q_panel now
// 		gen datem = ym(int_year,int_month)
// 		format datem %tm
//
// 		gen dateq = yq(int_year,quarter)
// 		format dateq %tq
//		
// 	* Individuals in Quarterly Panel
//
// 	/*SAMPLE RESTRICTIONS*/ 
// 	/* drop individuals */ 
// 		gen q_panel = .
//			
// 			// Identifying time frames that permit completion of 5 interviews
// 			//      Already coded in the variable panel		
// 			// Marking individuals with 5 interviews
// 			bys pid_p: gen Ninterviews = _N if pid_p!=.
//			
// 			* Identifying individuals between 15 and 64 throught the sample
// 			gen _a1564_n = (age>=15 & age<=64) 
// 			bys pid_p: egen a1564_n = sum(_a1564_n) if pid_p!=.
// 			gen A1564 = (a1564_n == Ninterviews) if pid_p!=.
// 				drop _a1564_n a1564_n
//				
// 			* Mark individuals with 3-month interview spans				
// 			sort pid_p dateq
// 				by pid_p: gen _timelapse = datem - datem[_n-1] if pid_p!=.
// 				by pid_p: egen timelapse = mean(_timelapse) if pid_p!=.
// 				gen timelapse3month = (timelapse == 3) if pid_p!=.
// 					drop _timelapse timelapse
//			
// 			* Mark individuals suited for panel
// 			replace q_panel = (Ninterviews>=2 & Ninterviews<=5 & A1564==1 & timelapse3month==1) if panel!=.
//			
// 		label var q_panel "Individuals 15-64, 5 interviews, 3-months"
//		
// 		/* Check sequential interview numbers. 
// 		The variable n_ent does not always coincide with a sequential interview number 
// 		(e.g., when unable to interview a household)
// 		*/
// 		bys pid_p (dateq): gen int_num = _n if pid_p!=.
// 		tab int_num n_ent if q_panel==1
//		
// 		** RECODE/replace VARIABLES THAT ARE ONLY CAPTURED DURING EMPLOYMENT SPELLS 
// 		gen firmsizev2 = firmsize_l 
// 		recode firmsizev2 .= 0 if lstatus == 2 | lstatus == 3
//		
// 	* SVYSET
// 		svyset psu [pweight=weight], strata(strata)
//	
// 	* LF Participation
// 	gen particip = (lstatus == 1 | lstatus == 2) 
// 		recode particip 0 = . if lstatus == . 
// 		label define lblparticip 1 "LF Participation" 0 "Out of LF" 
// 	label values particip lblparticip
//	
// 	* IND
// 	rename industrycat10 ind
//
// 	* Age Category
// 	gen age_catego = round(age/10,1)
//	
// 	* Married
// 	gen married    = (marital== 1)
//	
// 	* There are unlabeled occupations. Will recode as "NA"
// 	* Will also code as NA if occup or ind is missing but lstatus = employed
// 	foreach v in ind occup {
//
// 		local lbe`v' : value label `v'
// 		label list `lbe`v''
// 		local tc = `r(max)'+1
// 		recode `v' 0 = `tc' if lstatus == 1
// 		recode `v' . = `tc' if lstatus == 1
// 		label define `lbe`v'' `tc' "NA", add
//		
// 		count if `v' == 0 
// 		local nn = `r(N)'
// 		if `nn' == 0 {
// 			recode `v' . = 0 if lstatus == 2 | lstatus == 3
// 			local lbe`v' : value label `v'
// 			label define `lbe`v'' 0 "Not Employed", add
//			
// 		} 
// 		else { 
// 			local lbe`v' : value label `v'
// 			label list `lbe`v''
// 			local tc = `r(max)'+1
// 			recode `v' . = `tc' if lstatus == 2 | lstatus == 3
// 			label define `lbe`v'' `tc' "Not Employed", add
// 		} 
// 	}	
//	
// 	compress
//	
// 	order year-int_month quarter panel pid_p
//	
// 	save "$path/PANEL/DATA/MEX_2005_2025_ENOE_V01_M_V06_A_GLD_FULLSAMPLE.dta", replace	
// 	frame reset	
//
// }






	
********************************************************************************
* Part 2. Panel of Workers Quarterly
********************************************************************************
if "`part2'"=="yes" {

	* Create a balance database
	use pid_p n_ent q_panel tipo if q_panel==1 using "$path/PANEL/DATA/MEX_2005_2025_ENOE_V01_M_V06_A_GLD_FULLSAMPLE.dta", clear
		tab tipo, m
		drop tipo
		* duplicates report 
		reshape wide q_panel, i(pid_p) j(n_ent)
		reshape long q_panel, i(pid_p) j(n_ent)
		
		* We need to identify individuals that missed the first interview
			gen _miss_first = 1 if q_panel==. & n_ent==1
			by pid_p: egen miss_first = sum(_miss_first)
		
			clonevar q_panel2 = q_panel
			replace  q_panel2 = . if miss_first==1
				drop _miss_first
				drop q_panel
			
			keep if q_panel2==1
			drop miss_first

		reshape wide q_panel2, i(pid_p) j(n_ent)
		reshape long q_panel2, i(pid_p) j(n_ent)
			replace q_panel2=1 
			
		tab n_ent
		isid pid_p n_ent
		tempfile balanced
		save `balanced', replace
		
	use "$path/PANEL/DATA/MEX_2005_2025_ENOE_V01_M_V06_A_GLD_FULLSAMPLE.dta", clear

	count /*24,246,404*/
	
	* Panel that follows workers for up to 5 quarters
		keep if q_panel==1
		* duplicates report pid_p dateq
		tempfile data
		save `data', replace
		
	use `balanced'
	merge 1:1 pid_p n_ent using `data'
		order q_panel, before(q_panel2)
		keep if q_panel2==1
		drop _merge
		xtset pid_p n_ent	// This should be a strongly balanced panel
		
	** Identify temporary or permanent attrition 
	gen att_dummy = (dateq==.)

	/* NOTE: We could, for some observations, try to correct for temporary 
	attrition using the tenure variable. Let's chat about whether we want to 
	do that. */

	* There is no attrition between first and second interview - by definition in q_panel
	* probit att_dummy l1.i.age_catego#l1.i.male#l1.i.married#l1.i.literacy if l.att_dummy==0 & (n_ent>=1 & n_ent<=2)
	
	gen ratio = 1
	gen attweight = .	
	replace attweight = weight if n_ent==1|n_ent==2
	
	forval i = 3/5 {
		probit att_dummy l1.i.age_catego#l1.i.male#l1.i.married#l1.i.literacy if l.att_dummy==0 & n_ent==`i'
			predict p_ur if n_ent==`i'
		
		sum att_dummy if l.att_dummy==0 & (n_ent==`i')
			scalar p_r = r(mean)
		
		replace ratio = p_ur/p_r if n_ent==`i'
			drop p_ur
			scalar drop p_r

		replace attweight = weight * ratio if n_ent==`i'
	}	
	
	* Saving rotating panel data with the 5 interviews/quarters
	save "$path/PANEL/DATA/MEX_2005_2025_PANEL_QUARTER_EXPORTS.dta", replace
	* 12,219,965
	frame reset
}
