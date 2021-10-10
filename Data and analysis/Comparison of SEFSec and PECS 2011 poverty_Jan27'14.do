#delim;
clear;
clear matrix;
set more 1;
set mem 200m;

*******************************************************************************************
*******************************************************************************************
**     DATE:       Dec 2013 - Jan 2014
**     PROGRAM:    Comparison of SEFSec and PECS 2011 poverty estimates
**     AUTHORS:    LSmith
**     PURPOSE:    Compare estimates of "deep" and "relative" poverty using the SEFSecs and PECS 2011 data sets
********************************************************************************************
********************************************************************************************;

*We will first calculate the percent of households poor and then the percent of people living in poor households;

********** Create person-level file for each survey;

*SEFSec;
use "C:\AA_LISACAT\aa_TANGO\Palestine SEFSec\data\SEFSec\2011\Roster.dta", clear; 
keep id00 hr01;
save "C:\AA_LISACAT\aa_TANGO\Palestine SEFSec\data\outfiles\SEFSec_people.dta", replace; 

*PECS;
use "C:\AA_LISACAT\aa_TANGO\Palestine SEFSec\data\PECS\2011\roster.dta", clear;
keep id00 d1;
save "C:\AA_LISACAT\aa_TANGO\Palestine SEFSec\data\outfiles\PECS_people.dta", replace; 


*****************************************************************
*****************************************************************
*  Percent of households poor
*****************************************************************
*****************************************************************;

*Note:  For all calculations using daily USD poverty lines;

#delim;
use "C:\AA_LISACAT\aa_TANGO\Palestine SEFSec\data\outfiles\SEFSec_PECS 2011_expenditures.dta", clear;

*Indicator variable for deep poverty;
gen pov_deep=0 if exp_tot_ae_real~=.;
replace pov_deep=1 if (exp_tot_ae_real/30)/3.58<=5.39 & exp_tot_ae_real~=.;

*Indicator variable for relative poverty;
gen pov_rel=0 if exp_tot_ae_real~=.;
replace pov_rel=1 if (exp_tot_ae_real/30)/3.58<=6.76 & exp_tot_ae_real~=.;

keep ID00 SEFSec rw exp_tot_ae_real pov*;
sum;
save "C:\AA_LISACAT\aa_TANGO\Palestine SEFSec\data\outfiles\SEFSec_PECS 2011_poverty_USDlines.dta", replace;

********** SEFSec;
#delim;
use "C:\AA_LISACAT\aa_TANGO\Palestine SEFSec\data\outfiles\SEFSec_PECS 2011_poverty_USDlines.dta", clear;
keep if SEFSec==1;
svyset [pweight=rw];
svy: mean pov_deep pov_rel; 

*By region;
rename ID00 hhid;
merge 1:1 hhid using "C:\AA_LISACAT\aa_TANGO\Palestine SEFSec\data\PECS\2011\outfiles\hhinfo_SEFSec2011.dta";
svy: mean exp_tot_ae_real pov_deep pov_rel, over(Westbank);


********** PECS;
#delim;
use "C:\AA_LISACAT\aa_TANGO\Palestine SEFSec\data\outfiles\SEFSec_PECS 2011_poverty_USDlines.dta", clear;
keep if SEFSec==0;
svyset [pweight=rw];
svy: mean pov_deep pov_rel; 

*By region;
rename ID00 hhid;
merge 1:1 hhid using "C:\AA_LISACAT\aa_TANGO\Palestine SEFSec\data\PECS\2011\outfiles\hhinfo_PECS2011.dta";
svy: mean exp_tot_ae_real pov_deep pov_rel, over(Westbank);


*****************************************************************
*****************************************************************
*  Percent of people poor
*****************************************************************
*****************************************************************;

********** SEFSec;
#delim;
use "C:\AA_LISACAT\aa_TANGO\Palestine SEFSec\data\outfiles\SEFSec_PECS 2011_poverty_USDlines.dta", clear;
keep if SEFSec==1;
rename ID00 id00;
merge 1:m id00 using "C:\AA_LISACAT\aa_TANGO\Palestine SEFSec\data\outfiles\SEFSec_people.dta";
drop if _merge==2; drop _merge;
sort id00 hr01;
svyset [pweight=rw];
svy: mean pov_deep* pov_rel*; 

********** PECS;
use "C:\AA_LISACAT\aa_TANGO\Palestine SEFSec\data\outfiles\SEFSec_PECS 2011_poverty_USDlines.dta", clear;
keep if SEFSec==0;
rename ID00 id00;
merge 1:m id00 using "C:\AA_LISACAT\aa_TANGO\Palestine SEFSec\data\outfiles\PECS_people.dta";
drop if _merge==2; drop _merge;
sort id00 d1;
svyset [pweight=rw];
svy: mean pov_deep pov_rel; 

