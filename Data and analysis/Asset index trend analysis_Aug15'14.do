#delim;
clear;
clear matrix;
set more 1;
set mem 200m;

*******************************************************************************************
*******************************************************************************************
**     DATE:       June 2014
**     PROGRAM:    Asset index trend analysis
**     AUTHORS:    LSmith
**     PURPOSE:    Testing whether asset poverty gives same poverty rates and trends as expenditure poverty
**			       using PECS 2009, 2010 and 2011 data
********************************************************************************************
********************************************************************************************;


*************************************************************************************
*************************************************************************************
*  Check for stability in relationship to total expenditures across the three surveys
*************************************************************************************
*************************************************************************************;

*Note:  Found from pre-explorations that breaking down education and age-sex composition into such fine categories does
*not produce stable coefficients.  So using hhh_educ_L for education and two variables for age-sex composition;

*See spreadsheet "Comparison of coefficients in regressions.xls" for results of Rounds;

#delim; 
*First round:  All variables;
use "C:\AA_LISACAT\aa_TANGO\Palestine SEFSec\data\outfiles\PhaseII\asset index variables_PECS2011.dta", clear;
merge 1:1 hhid using "C:\AA_LISACAT\aa_TANGO\Palestine SEFSec\data\outfiles\PECS 2011_expenditures_PhaseII.dta";
gen lnexp=ln(exp_tot_ae_real_2011);
regress lnexp asset1-asset16 br_density bathroom_p heating_gke hhsize p16_30 p30p femhead agehhh  hhh_educ_L refugee urban Westbank;
recode asset* bathroom_p heating_gke p16_30 p30p femhead hhh_educ_L refugee urban Westbank (1=100);
svyset [pweight=rw];
svy: mean asset1-asset16 br_density bathroom_p heating_gke hhsize p16_30 p30p femhead agehhh hhh_educ_L refugee  
urban Westbank exp_tot_ae_real_2011;

use "C:\AA_LISACAT\aa_TANGO\Palestine SEFSec\data\outfiles\PhaseII\asset index variables_PECS2010.dta", clear;
merge 1:1 hhid using "C:\AA_LISACAT\aa_TANGO\Palestine SEFSec\data\outfiles\PECS 2010_expenditures_PhaseII.dta";
gen lnexp=ln(exp_tot_ae_real_2010);
regress lnexp asset1-asset16 br_density bathroom_p heating_gke hhsize p16_30 p30p femhead agehhh  hhh_educ_L refugee urban Westbank;
recode asset* bathroom_p heating_gke p16_30 p30p femhead hhh_educ_L refugee urban Westbank (1=100);
svyset [pweight=rw];
svy: mean asset1-asset16 br_density bathroom_p heating_gke hhsize p16_30 p30p femhead agehhh hhh_educ_L refugee  
urban Westbank exp_tot_ae_real_2010;

use "C:\AA_LISACAT\aa_TANGO\Palestine SEFSec\data\outfiles\PhaseII\asset index variables_PECS2009.dta", clear;
merge 1:1 hhid using "C:\AA_LISACAT\aa_TANGO\Palestine SEFSec\data\outfiles\PECS 2009_expenditures_PhaseII.dta";
gen lnexp=ln(exp_tot_ae_real_2009);
regress lnexp asset1-asset16 br_density bathroom_p heating_gke hhsize p16_30 p30p femhead agehhh  hhh_educ_L refugee urban Westbank;
recode asset* bathroom_p heating_gke p16_30 p30p femhead hhh_educ_L refugee urban Westbank (1=100);
svyset [pweight=rw];
svy: mean asset1-asset16 br_density bathroom_p heating_gke hhsize p16_30 p30p femhead agehhh hhh_educ_L refugee  
urban Westbank exp_tot_ae_real_2009;

#delim;
*Second round:  Drop non-asset variables that are not significant over the three periods: urban bathroom_p;
use "C:\AA_LISACAT\aa_TANGO\Palestine SEFSec\data\outfiles\PhaseII\asset index variables_PECS2011.dta", clear;
merge 1:1 hhid using "C:\AA_LISACAT\aa_TANGO\Palestine SEFSec\data\outfiles\PECS 2011_expenditures_PhaseII.dta";
gen lnexp=ln(exp_tot_ae_real_2011);
regress lnexp asset1-asset3 asset4 asset5 asset6-asset16  hhsize refugee p16_30 p30p femhead agehhh  hhh_educ_L
br_density heating_gke Westbank;

use "C:\AA_LISACAT\aa_TANGO\Palestine SEFSec\data\outfiles\PhaseII\asset index variables_PECS2010.dta", clear;
merge 1:1 hhid using "C:\AA_LISACAT\aa_TANGO\Palestine SEFSec\data\outfiles\PECS 2010_expenditures_PhaseII.dta";
gen lnexp=ln(exp_tot_ae_real_2010);
regress lnexp asset1-asset3 asset4 asset5 asset6-asset16  hhsize refugee p16_30 p30p femhead agehhh  hhh_educ_L
br_density heating_gke Westbank;

use "C:\AA_LISACAT\aa_TANGO\Palestine SEFSec\data\outfiles\PhaseII\asset index variables_PECS2009.dta", clear;
merge 1:1 hhid using "C:\AA_LISACAT\aa_TANGO\Palestine SEFSec\data\outfiles\PECS 2009_expenditures_PhaseII.dta";
gen lnexp=ln(exp_tot_ae_real_2009);
regress lnexp asset1-asset3 asset4 asset5 asset6-asset16  hhsize refugee p16_30 p30p femhead agehhh  hhh_educ_L
br_density heating_gke Westbank;

#delim;
*Third round:  Drop remaining non-asset variables that are not stable over the three periods;
use "C:\AA_LISACAT\aa_TANGO\Palestine SEFSec\data\outfiles\PhaseII\asset index variables_PECS2011.dta", clear;
merge 1:1 hhid using "C:\AA_LISACAT\aa_TANGO\Palestine SEFSec\data\outfiles\PECS 2011_expenditures_PhaseII.dta";
gen lnexp=ln(exp_tot_ae_real_2011);
regress lnexp asset1-asset3 asset4 asset5 asset6-asset16  hhsize refugee femhead heating_gke;

use "C:\AA_LISACAT\aa_TANGO\Palestine SEFSec\data\outfiles\PhaseII\asset index variables_PECS2010.dta", clear;
merge 1:1 hhid using "C:\AA_LISACAT\aa_TANGO\Palestine SEFSec\data\outfiles\PECS 2010_expenditures_PhaseII.dta";
gen lnexp=ln(exp_tot_ae_real_2010);
regress lnexp asset1-asset3 asset4 asset5 asset6-asset16  hhsize refugee femhead heating_gke;

use "C:\AA_LISACAT\aa_TANGO\Palestine SEFSec\data\outfiles\PhaseII\asset index variables_PECS2009.dta", clear;
merge 1:1 hhid using "C:\AA_LISACAT\aa_TANGO\Palestine SEFSec\data\outfiles\PECS 2009_expenditures_PhaseII.dta";
gen lnexp=ln(exp_tot_ae_real_2009);
regress lnexp asset1-asset3 asset4 asset5 asset6-asset16  hhsize refugee femhead heating_gke;

#delim;
*Fourth round:  Drop asset variables that are not stable over the three periods;
use "C:\AA_LISACAT\aa_TANGO\Palestine SEFSec\data\outfiles\PhaseII\asset index variables_PECS2011.dta", clear;
merge 1:1 hhid using "C:\AA_LISACAT\aa_TANGO\Palestine SEFSec\data\outfiles\PECS 2011_expenditures_PhaseII.dta";
gen lnexp=ln(exp_tot_ae_real_2011);
regress lnexp asset2 asset5 asset6 asset9-asset12 asset14-asset16 heating_gke hhsize femhead refugee; 
recode asset* refugee femhead heating (1=100);
svyset [pweight=rw];
svy: mean asset2 asset5 asset6 asset9-asset12 asset14-asset16 heating hhsize femhead refugee;  

use "C:\AA_LISACAT\aa_TANGO\Palestine SEFSec\data\outfiles\PhaseII\asset index variables_PECS2010.dta", clear;
merge 1:1 hhid using "C:\AA_LISACAT\aa_TANGO\Palestine SEFSec\data\outfiles\PECS 2010_expenditures_PhaseII.dta";
gen lnexp=ln(exp_tot_ae_real_2010);
regress lnexp asset2 asset5 asset6 asset9-asset12 asset14-asset16 heating_gke hhsize femhead refugee; 

use "C:\AA_LISACAT\aa_TANGO\Palestine SEFSec\data\outfiles\PhaseII\asset index variables_PECS2009.dta", clear;
merge 1:1 hhid using "C:\AA_LISACAT\aa_TANGO\Palestine SEFSec\data\outfiles\PECS 2009_expenditures_PhaseII.dta";
gen lnexp=ln(exp_tot_ae_real_2009);
regress lnexp asset2 asset5 asset6 asset9-asset12 asset14-asset16 heating_gke hhsize femhead refugee; 

#delim;
*Drop radio/recorder and solar heater (after dropped radio/recorder it got unstable);
use "C:\AA_LISACAT\aa_TANGO\Palestine SEFSec\data\outfiles\PhaseII\asset index variables_PECS2011.dta", clear;
merge 1:1 hhid using "C:\AA_LISACAT\aa_TANGO\Palestine SEFSec\data\outfiles\PECS 2011_expenditures_PhaseII.dta";
gen lnexp=ln(exp_tot_ae_real_2011);
regress lnexp asset5 asset6 asset9-asset12 asset15 asset16 heating_gke hhsize femhead refugee; 
*recode asset* refugee femhead heating (1=100);
*svyset [pweight=rw];
*svy: mean asset2 asset5 asset6 asset9-asset12 asset14-asset16 heating hhsize femhead refugee;  

use "C:\AA_LISACAT\aa_TANGO\Palestine SEFSec\data\outfiles\PhaseII\asset index variables_PECS2010.dta", clear;
merge 1:1 hhid using "C:\AA_LISACAT\aa_TANGO\Palestine SEFSec\data\outfiles\PECS 2010_expenditures_PhaseII.dta";
gen lnexp=ln(exp_tot_ae_real_2010);
regress lnexp asset5 asset6 asset9-asset12 asset15 asset16 heating_gke hhsize femhead refugee; 

use "C:\AA_LISACAT\aa_TANGO\Palestine SEFSec\data\outfiles\PhaseII\asset index variables_PECS2009.dta", clear;
merge 1:1 hhid using "C:\AA_LISACAT\aa_TANGO\Palestine SEFSec\data\outfiles\PECS 2009_expenditures_PhaseII.dta";
gen lnexp=ln(exp_tot_ae_real_2009);
regress lnexp asset5 asset6 asset9-asset12 asset15 asset16 heating_gke hhsize femhead refugee; 

#delim;
*Drop female household head;
use "C:\AA_LISACAT\aa_TANGO\Palestine SEFSec\data\outfiles\PhaseII\asset index variables_PECS2011.dta", clear;
merge 1:1 hhid using "C:\AA_LISACAT\aa_TANGO\Palestine SEFSec\data\outfiles\PECS 2011_expenditures_PhaseII.dta";
gen lnexp=ln(exp_tot_ae_real_2011);
regress lnexp asset5 asset6 asset9-asset12 asset15 asset16 heating_gke hhsize refugee; 
*recode asset* refugee femhead heating (1=100);
*svyset [pweight=rw];
*svy: mean asset2 asset5 asset6 asset9-asset12 asset14-asset16 heating hhsize femhead refugee;  

use "C:\AA_LISACAT\aa_TANGO\Palestine SEFSec\data\outfiles\PhaseII\asset index variables_PECS2010.dta", clear;
merge 1:1 hhid using "C:\AA_LISACAT\aa_TANGO\Palestine SEFSec\data\outfiles\PECS 2010_expenditures_PhaseII.dta";
gen lnexp=ln(exp_tot_ae_real_2010);
regress lnexp asset5 asset6 asset9-asset12 asset15 asset16 heating_gke hhsize refugee; 

use "C:\AA_LISACAT\aa_TANGO\Palestine SEFSec\data\outfiles\PhaseII\asset index variables_PECS2009.dta", clear;
merge 1:1 hhid using "C:\AA_LISACAT\aa_TANGO\Palestine SEFSec\data\outfiles\PECS 2009_expenditures_PhaseII.dta";
gen lnexp=ln(exp_tot_ae_real_2009);
regress lnexp asset5 asset6 asset9-asset12 asset15 asset16 heating_gke hhsize refugee; 



*************************************************************************************
*************************************************************************************
*  Comparison of asset indexes with expenditures
*************************************************************************************
*************************************************************************************;

*******************************
* PECS 2011
*******************************;

#delim;
use "C:\AA_LISACAT\aa_TANGO\Palestine SEFSec\data\outfiles\PhaseII\asset index variables_PECS2011.dta", clear;
rename hhid ID00;
merge 1:1 ID00 using "C:\AA_LISACAT\aa_TANGO\Palestine SEFSec\data\outfiles\PECS 2011_hhsize.dta";
drop _merge;
rename ID00 hhid;

******************* Create indexes;

***** PCA-based index;
pca asset5 asset6 asset9-asset12 asset15 asset16;
*All enter positively into component 1;
predict index_pc;
gen index_pc_ae=index_pc/hhae;
*hist index_pc_ae;

***** Count index with all assets;
egen index_count=rowtotal(asset5 asset6 asset9-asset12 asset15 asset16);
gen index_count_ae=index_count/hhae;
*hist index_count;

***** Regression-based index with ln(tot_exp_ae_real) as dependent variable;
merge 1:1 hhid using "C:\AA_LISACAT\aa_TANGO\Palestine SEFSec\data\outfiles\PECS 2011_expenditures_PhaseII.dta";
gen lnexp=ln(exp_tot_ae_real_2011);
regress lnexp asset5 asset6 asset9-asset12 asset15 asset16 heating_gke hhsize refugee;
predict index_reg_ln;
*hist index_reg;
sum lnexp index_reg_ln;
gen index_reg=exp(index_reg_ln);

/*
twoway (kdensity lnexp) (kdensity index_reg_ln), xtitle(Asset index value) 
legend(ring(0) pos(2) 
label(1 "lnexp_actual") label(2 "lnexp_index")); 

twoway (kdensity exp_tot_ae_real_2011) (kdensity index_reg), xtitle(Asset index value) 
legend(ring(0) pos(2) 
label(1 "exp_actual") label(2 "exp_index")); 

pwcorr lnexp index_reg_ln;
*/;

***** Regression-based index with ln(tot_exp_ae_real) as dependent variable and only assets as independent variables;
regress lnexp asset5 asset6 asset9-asset12 asset15 asset16;
predict index_reg_assets_ln;
gen index_reg_assets=exp(index_reg_assets_ln);
kdensity index_reg_assets;

******************* Compare to total expenditures;
pwcorr exp_tot_ae_real_2011 index_pc_ae index_count_ae index_reg index_reg_assets;
spearman exp_tot_ae_real_2011 index_pc_ae index_count_ae index_reg index_reg_assets, stats(p);

sum;
drop _merge;
save "C:\AA_LISACAT\aa_TANGO\Palestine SEFSec\data\outfiles\PhaseII\asset indexes_PECS2011.dta", replace;

*Try recreating PC asset index (will need below);
egen stdasset5=std(asset5);
egen stdasset6=std(asset6);
egen stdasset9=std(asset9);
egen stdasset10=std(asset10);
egen stdasset11=std(asset11);
egen stdasset12=std(asset12);
egen stdasset15=std(asset15);
egen stdasset16=std(asset16);

#delim;
gen index_pc_alt=
stdasset5	*	0.2148	+
stdasset6	*	0.4527	+
stdasset9	*	0.3823	+
stdasset10	*	0.3589	+
stdasset11	*	0.157	+
stdasset12	*	0.3775	+
stdasset15	*	0.4293	+
stdasset16	*	0.35;	
sum index_pc index_pc_alt;
twoway (kdensity index_pc) (kdensity index_pc_alt), xtitle(Asset index value) 
legend(ring(0) pos(2) 
label(1 "Index_pc") label(2 "Index_pc_alt")); 
*Exactly the same;

		 
*******************************
* PECS 2010
*******************************;

#delim;
use "C:\AA_LISACAT\aa_TANGO\Palestine SEFSec\data\outfiles\PhaseII\asset index variables_PECS2010.dta", clear;
rename hhid ID00;
merge 1:1 ID00 using "C:\AA_LISACAT\aa_TANGO\Palestine SEFSec\data\outfiles\PECS 2010_hhsize.dta";
drop _merge;
rename ID00 hhid;

******************* Create indexes;

***** PCA-based index ;
pca asset5 asset6 asset9-asset12 asset15 asset16;
*All enter positively into component 1;
predict index_pc;
gen index_pc_ae=index_pc/hhae;
*hist index_pc_ae;

***** Count index with all assets;
egen index_count=rowtotal(asset5 asset6 asset9-asset12 asset15 asset16);
gen index_count_ae=index_count/hhae;
*hist index_count;

***** Regression-based index with ln(tot_exp_ae_real) as dependent variable;
merge 1:1 hhid using "C:\AA_LISACAT\aa_TANGO\Palestine SEFSec\data\outfiles\PECS 2010_expenditures_PhaseII.dta";
drop _merge;
gen lnexp=ln(exp_tot_ae_real_2010);
regress lnexp asset5 asset6 asset9-asset12 asset15 asset16 heating_gke hhsize refugee;
predict index_reg_ln;
*hist index_reg;
sum lnexp index_reg_ln;
gen index_reg=exp(index_reg_ln);
kdensity index_reg;

***** Regression-based index with ln(tot_exp_ae_real) as dependent variable and only assets as independent variables;
regress lnexp asset5 asset6 asset9-asset12 asset15 asset16;
predict index_reg_assets_ln;
gen index_reg_assets=exp(index_reg_assets_ln);
kdensity index_reg_assets;

******************* Compare to total expenditures;
pwcorr exp_tot_ae_real_2010 index_pc_ae index_count_ae index_reg index_reg_assets;
spearman exp_tot_ae_real_2010 index_pc_ae index_count_ae index_reg index_reg_assets, stats(p);

save "C:\AA_LISACAT\aa_TANGO\Palestine SEFSec\data\outfiles\PhaseII\asset indexes_PECS2010.dta", replace;


*******************************
* PECS 2009
*******************************;

#delim;
use "C:\AA_LISACAT\aa_TANGO\Palestine SEFSec\data\outfiles\PhaseII\asset index variables_PECS2009.dta", clear;
rename hhid ID00;
merge 1:1 ID00 using "C:\AA_LISACAT\aa_TANGO\Palestine SEFSec\data\outfiles\PECS 2009_hhsize.dta";
drop _merge;
rename ID00 hhid;

******************* Create indexes;

***** PCA-based index ;
pca asset5 asset6 asset9-asset12 asset15 asset16;
*All enter positively into component 1;
predict index_pc;
gen index_pc_ae=index_pc/hhae;
*hist index_pc_ae;

***** Count index with all assets;
egen index_count=rowtotal(asset5 asset6 asset9-asset12 asset15 asset16);
gen index_count_ae=index_count/hhae;
*hist index_count;

***** Regression-based index with ln(tot_exp_ae_real) as dependent variable;
merge 1:1 hhid using "C:\AA_LISACAT\aa_TANGO\Palestine SEFSec\data\outfiles\PECS 2009_expenditures_PhaseII.dta";
drop _merge;
gen lnexp=ln(exp_tot_ae_real_2009);
regress lnexp asset5 asset6 asset9-asset12 asset15 asset16 heating_gke hhsize refugee;
predict index_reg_ln;
*hist index_reg;
sum lnexp index_reg_ln;
gen index_reg=exp(index_reg_ln);
kdensity index_reg;

***** Regression-based index with ln(tot_exp_ae_real) as dependent variable and only assets as independent variables;
regress lnexp asset5 asset6 asset9-asset12 asset15 asset16;
predict index_reg_assets_ln;
gen index_reg_assets=exp(index_reg_assets_ln);
kdensity index_reg_assets;

******************* Compare to total expenditures;
pwcorr exp_tot_ae_real_2009 index_pc_ae index_count_ae index_reg index_reg_assets;
spearman exp_tot_ae_real_2009 index_pc_ae index_count_ae index_reg index_reg_assets, stats(p);


save "C:\AA_LISACAT\aa_TANGO\Palestine SEFSec\data\outfiles\PhaseII\asset indexes_PECS2009.dta", replace;

*************************************************************************************
*************************************************************************************
*  Create comparative densities of distributions 
*************************************************************************************
*************************************************************************************;

#delim;
use "C:\AA_LISACAT\aa_TANGO\Palestine SEFSec\data\outfiles\PhaseII\asset indexes_PECS2011.dta", clear;

egen max=max(exp_tot_ae_real);  
egen min=min(exp_tot_ae_real); 
gen exp_tot_ae_01=(exp_tot_ae_real-min)*1/(max-min); 
*kdensity exp_tot_ae_01;
drop max min;

********** Principal components index;
egen max=max(index_pc_ae);  
egen min=min(index_pc_ae); 
gen index_pc_ae_01=(index_pc_ae-min)*1/(max-min); 
*kdensity index_pc_ae_01;
drop max min;
twoway (kdensity exp_tot_ae_01) (kdensity index_pc_ae_01), xtitle(Asset index value) 
legend(ring(0) pos(2) 
label(1 "Total expenditures (per AE)") label(2 "PC asset index")); 

********** Count index;
egen max=max(index_count_ae);  
egen min=min(index_count_ae); 
gen index_count_ae_01=(index_count_ae-min)*1/(max-min); 
*kdensity index_count_ae_01;
drop max min;
twoway (kdensity exp_tot_ae_01) (kdensity index_count_ae_01), xtitle(Asset index value) 
legend(ring(0) pos(2) 
label(1 "Expenditures per adult equivalent") label(2 "Count asset index")); 


********** Regression index with all stable expenditure correlates;
egen max=max(index_reg);  
egen min=min(index_reg); 
gen index_reg_01=(index_reg-min)*1/(max-min); 
kdensity index_reg_01;
drop max min;

****When on 0-1 scale;
twoway (kdensity exp_tot_ae_01) (kdensity index_reg_01), xtitle(Asset index value) 
legend(ring(0) pos(2) 
label(1 "Expenditures per adult equivalent") label(2 "Regression index 1")); 

****When on 0-1 un-scaled;
twoway (kdensity exp_tot_ae_real_2011) (kdensity index_reg), xtitle(Asset index value) 
legend(ring(0) pos(2) 
label(1 "Expenditures per adult equivalent") label(2 "Regression index 1")); 

#delim;
kdensity exp_tot_ae_real_2011;
kdensity exp_tot_ae_01;

#delim;
kdensity index_reg;
kdensity index_reg_01;


********** Regression index with stable assets;
egen max=max(index_reg_assets);  
egen min=min(index_reg_assets); 
gen index_reg_assets_01=(index_reg_assets-min)*1/(max-min); 
drop max min;

****When on 0-1 scale;
#delim;
twoway (kdensity exp_tot_ae_01) (kdensity index_reg_assets_01), xtitle(Asset index value) 
legend(ring(0) pos(2) 
label(1 "Expenditures per adult equivalent") label(2 "Regression index 2")); 

****When un-scaled;
twoway (kdensity exp_tot_ae_real_2011) (kdensity index_reg_assets), xtitle(Asset index value) 
legend(ring(0) pos(2) 
label(1 "Expenditures per adult equivalent") label(2 "Regression index 2")); 

kdensity index_reg_assets;
kdensity index_reg_assets_01;


*************************************************************************************
*************************************************************************************
*  Calculate poverty prevalences 
*************************************************************************************
*************************************************************************************;

*Note:  Using daily USD per adult equivalent poverty lines sent by Rana Hannoun on 6/19/14;

*******************************
* PECS 2011
*******************************;

#delim;
use "C:\AA_LISACAT\aa_TANGO\Palestine SEFSec\data\outfiles\PhaseII\asset indexes_PECS2011.dta", clear;
keep if exp_tot_ae_real~=. & index_reg~=.;

********** Straight from actual data:  Does regression index give close poverty rates?;
*Deep poverty;
gen pov_deep=0;
replace pov_deep=100 if (exp_tot_ae_real/30)/3.59<=5.77;
gen pov_deep_index_reg=0;
replace pov_deep_index_reg=100 if (index_reg/30)/3.59<=5.77;

*Relative poverty;
gen pov_rel=0;
replace pov_rel=100 if (exp_tot_ae_real/30)/3.59<=7.23;
gen pov_rel_index_reg=0;
replace pov_rel_index_reg=100 if (index_reg/30)/3.59<=7.23;

sum pov_deep* pov_rel*;
*Answer:  No, regression index does not give close poverty rates.  Need to set "consistent" poverty line;

********** Choosing index value for poverty line to reproduce actual poverty rates;

*What index value yields the actual poverty prevalence?;
svyset [pweight=rw];
svy: mean pov_deep pov_rel;
svy: mean pov_deep pov_rel, over(Westbank);
*This doesn't exactly match data given in Table 3.9 of Phase I report because the 2010 poverty lines were used 
*for the 2011 SEFSec analysis, which is where we got the poverty lines (from the syntax file);
*Also note slight difference in exchange rate used;

#delim;
use "C:\AA_LISACAT\aa_TANGO\Palestine SEFSec\data\outfiles\PhaseII\asset indexes_PECS2011.dta", clear;
keep if exp_tot_ae_real~=. & index_reg~=.;
svyset [pweight=rw];
*Targeting 9.8 for deep poverty and 20.3 for relative poverty;

*PC index;
gen pov_deep_pc=0; replace pov_deep_pc=100 if index_pc_ae<=-0.56; 
svy: mean pov_deep_pc;

gen pov_rel_pc=0; replace pov_rel_pc=100 if index_pc_ae<=-0.39;
svy: mean pov_rel_pc;

svy: mean pov_deep_pc pov_rel_pc, over(Westbank);

*Count index;
gen pov_deep_count=0; replace pov_deep_count=100 if index_count_ae<= 0.24;
svy: mean pov_deep_count;

gen pov_rel_count=0; replace pov_rel_count=100 if index_count_ae<= 0.338;
svy: mean pov_rel_count;

svy: mean pov_deep_count pov_rel_count, over(Westbank);

*Regression index 1;
gen pov_deep_reg=0; replace pov_deep_reg=100 if index_reg<=795;
svy: mean pov_deep_reg;

gen pov_rel_reg=0; replace pov_rel_reg=100 if index_reg<=909;
svy: mean pov_rel_reg;

svy: mean pov_deep_reg pov_rel_reg, over(Westbank);

*Regression index 2;
*Can't use because lowest value yields higher poverty rate than actual;
gen pov_deep_reg_a=0; replace pov_deep_reg_a=100 if index_reg_assets<=900.8;
svy: mean pov_deep_reg_a;

gen pov_rel_reg_a=0; replace pov_rel_reg_a=100 if index_reg_assets<900.8;
svy: mean pov_rel_reg_a;

********** Sensitivity-specificity analysis;
*Deep poverty;
gen pov_deep=0;
replace pov_deep=100 if (exp_tot_ae_real/30)/3.59<=5.77;
gen pov_deep_index_reg=0;
replace pov_deep_index_reg=100 if (index_reg/30)/3.59<=5.77;

*Relative poverty;
gen pov_rel=0;
replace pov_rel=100 if (exp_tot_ae_real/30)/3.59<=7.23;
gen pov_rel_index_reg=0;
replace pov_rel_index_reg=100 if (index_reg/30)/3.59<=7.23;

#delim;
tab pov_deep_pc pov_deep;
tab pov_rel_pc pov_rel;

#delim;
tab pov_deep_count pov_deep;
tab pov_rel_count pov_rel;

#delim;
tab pov_deep_reg pov_deep;
tab pov_rel_reg pov_rel;

*West Bank;
#delim;
tab pov_deep_pc pov_deep if Westbank==1;
tab pov_rel_pc pov_rel if Westbank==1;

#delim;
tab pov_deep_count pov_deep if Westbank==1;
tab pov_rel_count pov_rel if Westbank==1;

#delim;
tab pov_deep_reg pov_deep if Westbank==1;
tab pov_rel_reg pov_rel if Westbank==1;

*Gaza;
#delim;
tab pov_deep_pc pov_deep if Westbank==0;
tab pov_rel_pc pov_rel if Westbank==0;

#delim;
tab pov_deep_count pov_deep if Westbank==0;
tab pov_rel_count pov_rel if Westbank==0;

#delim;
tab pov_deep_reg pov_deep if Westbank==0;
tab pov_rel_reg pov_rel if Westbank==0;


*******************************
* PECS 2010
*******************************;

*********** Calculate actual poverty prevalences;
#delim;
use "C:\AA_LISACAT\aa_TANGO\Palestine SEFSec\data\outfiles\PhaseII\asset indexes_PECS2010.dta", clear;
rename hhid ID00;
merge 1:1 ID00 using "C:\AA_LISACAT\aa_TANGO\Palestine SEFSec\data\outfiles\PECS 2010_hhsize.dta";
drop _merge;
rename ID00 hhid;

keep if exp_tot_ae_real~=.;

*Deep poverty;
gen pov_deep=0;
replace pov_deep=100 if (exp_tot_ae_real/30)/3.73<=5.39;

*Relative poverty;
gen pov_rel=0;
replace pov_rel=100 if (exp_tot_ae_real/30)/3.73<=6.76;

svyset [pweight=rw];
svy: mean pov_deep pov_rel;

/*
Number of strata =       1          Number of obs    =    3749
Number of PSUs   =    3749          Population size  = 3750.54
                                    Design df        =    3748

--------------------------------------------------------------
             |             Linearized
             |       Mean   Std. Err.     [95% Conf. Interval]
-------------+------------------------------------------------
    pov_deep |   10.82355   .5301505      9.784142    11.86296
     pov_rel |   20.68851   .6896744      19.33634    22.04069
--------------------------------------------------------------

*/;

********** Calculate poverty rates using 2011 indexes; 

*** PC index;
egen stdasset5=std(asset5);
egen stdasset6=std(asset6);
egen stdasset9=std(asset9);
egen stdasset10=std(asset10);
egen stdasset11=std(asset11);
egen stdasset12=std(asset12);
egen stdasset15=std(asset15);
egen stdasset16=std(asset16);

gen index_pc_ae_2010=
(stdasset5	*	0.2148	+
 stdasset6	*	0.4527	+
 stdasset9	*	0.3823	+
 stdasset10	*	0.3589	+
 stdasset11	*	0.157	+
 stdasset12	*	0.3775	+
 stdasset15	*	0.4293	+
 stdasset16	*	0.35)/hhae;	

*** Count index;
egen index_count_2010=rowtotal(asset5 asset6 asset9 asset10 asset11 asset12 asset15 asset16);
gen index_count_ae_2010=index_count_2010/hhae;

*** Regression index 1;
gen lnexp_reg=
asset5	*	0.2038478	+	
asset6	*	0.0822892	+	
asset9	*	0.114842	+	
asset10	*	0.138965	+	
asset11	*	0.1990026	+	
asset12	*	0.1043746	+	
asset15	*	0.1389588	+	
asset16	*	0.3149219	+	
heating_gke	*	0.125733	+	
hhsize	*	-0.0640301	+	
refugee	*	-0.070123	+	6.983422;
kdensity lnexp_reg;
gen index_reg_2010=exp(lnexp_reg);
kdensity index_reg_2010; 

***************** Calculate poverty prevalences (not deflating poverty lines);
*Deep poverty;
gen pov_deep_pc=0;         replace pov_deep_pc=100         if index_pc_ae_2010<=-0.56;
gen pov_deep_count=0;      replace pov_deep_count=100      if index_count_ae_2010<=0.24;
gen pov_deep_reg=0;        replace pov_deep_reg=100        if index_reg_2010<=795;

*Relative poverty;
gen pov_rel_pc=0;         replace pov_rel_pc=100         if index_pc_ae_2010<=-0.39;
gen pov_rel_count=0;      replace pov_rel_count=100      if index_count_ae_2010<=0.338;
gen pov_rel_reg=0;        replace pov_rel_reg=100        if index_reg_2010<=909;

svyset [pweight=rw];
svy: mean pov_deep* pov_rel*;
svy: mean pov_deep* pov_rel* if Westbank==1;
svy: mean pov_deep* pov_rel* if Westbank==0;


/*
***************** Calculate poverty prevalences, deflating poverty lines;
*Deep poverty;
gen pov_deep_pc=0;         replace pov_deep_pc=100         if index_pc_ae_2010<=-0.56*0.934;
gen pov_deep_count=0;      replace pov_deep_count=100      if index_count_ae_2010<=0.24*0.934;
gen pov_deep_reg=0;        replace pov_deep_reg=100        if index_reg_2010<=795*0.934;

*Relative poverty;
gen pov_rel_pc=0;         replace pov_rel_pc=100         if index_pc_ae_2010<=-0.39*0.934;
gen pov_rel_count=0;      replace pov_rel_count=100      if index_count_ae_2010<=0.338*0.934;
gen pov_rel_reg=0;        replace pov_rel_reg=100        if index_reg_2010<=909*0.934;

svyset [pweight=rw];
svy: mean pov_deep* pov_rel*;
*/;

********** Sensitivity-specificity analysis;
#delim;
tab pov_deep_pc pov_deep;
tab pov_rel_pc pov_rel;

#delim;
tab pov_deep_count pov_deep;
tab pov_rel_count pov_rel;

#delim;
tab pov_deep_reg pov_deep;
tab pov_rel_reg pov_rel;

*West Bank;
#delim;
tab pov_deep_pc pov_deep if Westbank==1;
tab pov_rel_pc pov_rel if Westbank==1;

#delim;
tab pov_deep_count pov_deep if Westbank==1;
tab pov_rel_count pov_rel if Westbank==1;

#delim;
tab pov_deep_reg pov_deep if Westbank==1;
tab pov_rel_reg pov_rel if Westbank==1;

*Gaza;
#delim;
tab pov_deep_pc pov_deep if Westbank==0;
tab pov_rel_pc pov_rel if Westbank==0;

#delim;
tab pov_deep_count pov_deep if Westbank==0;
tab pov_rel_count pov_rel if Westbank==0;

#delim;
tab pov_deep_reg pov_deep if Westbank==0;
tab pov_rel_reg pov_rel if Westbank==0;

*******************************
* PECS 2009
*******************************;

*********** Calculate actual poverty prevalences;
#delim;
use "C:\AA_LISACAT\aa_TANGO\Palestine SEFSec\data\outfiles\PhaseII\asset indexes_PECS2009.dta", clear;
rename hhid ID00;
merge 1:1 ID00 using "C:\AA_LISACAT\aa_TANGO\Palestine SEFSec\data\outfiles\PECS 2009_hhsize.dta";
drop _merge;
rename ID00 hhid;

keep if exp_tot_ae_real~=.;

*Deep poverty;
gen pov_deep=0;
replace pov_deep=100 if (exp_tot_ae_real/30)/3.92<=4.95;

*Relative poverty;
gen pov_rel=0;
replace pov_rel=100 if (exp_tot_ae_real/30)/3.92<=6.20;

svyset [pweight=rw];
svy: mean pov_deep pov_rel;

/*
Number of strata =       1          Number of obs    =    3843
Number of PSUs   =    3843          Population size  = 3844.73
                                    Design df        =    3842

--------------------------------------------------------------
             |             Linearized
             |       Mean   Std. Err.     [95% Conf. Interval]
-------------+------------------------------------------------
    pov_deep |   9.766663   .5144945      8.757955    10.77537
     pov_rel |   19.29804   .6800242       17.9648    20.63128
--------------------------------------------------------------
*/;

********** Calculate poverty rates using 2011 indexes; 

*** PC index;
egen stdasset5=std(asset5);
egen stdasset6=std(asset6);
egen stdasset9=std(asset9);
egen stdasset10=std(asset10);
egen stdasset11=std(asset11);
egen stdasset12=std(asset12);
egen stdasset15=std(asset15);
egen stdasset16=std(asset16);

gen index_pc_ae_2010=
(stdasset5	*	0.2148	+
 stdasset6	*	0.4527	+
 stdasset9	*	0.3823	+
 stdasset10	*	0.3589	+
 stdasset11	*	0.157	+
 stdasset12	*	0.3775	+
 stdasset15	*	0.4293	+
 stdasset16	*	0.35)/hhae;	

*** Count index;
egen index_count_2010=rowtotal(asset5 asset6 asset9 asset10 asset11 asset12 asset15 asset16);
gen index_count_ae_2010=index_count_2010/hhae;

*** Regression index 1;
gen lnexp_reg=
asset5	*	0.2038478	+	
asset6	*	0.0822892	+	
asset9	*	0.114842	+	
asset10	*	0.138965	+	
asset11	*	0.1990026	+	
asset12	*	0.1043746	+	
asset15	*	0.1389588	+	
asset16	*	0.3149219	+	
heating_gke	*	0.125733	+	
hhsize	*	-0.0640301	+	
refugee	*	-0.070123	+	6.983422;
gen index_reg_2010=exp(lnexp_reg);

***************** Calculate poverty prevalences (not deflating poverty lines);
*Deep poverty;
gen pov_deep_pc=0;         replace pov_deep_pc=100         if index_pc_ae_2010<=-0.56;
gen pov_deep_count=0;      replace pov_deep_count=100      if index_count_ae_2010<=0.24;
gen pov_deep_reg=0;        replace pov_deep_reg=100        if index_reg_2010<=795;

*Relative poverty;
gen pov_rel_pc=0;         replace pov_rel_pc=100         if index_pc_ae_2010<=-0.39;
gen pov_rel_count=0;      replace pov_rel_count=100      if index_count_ae_2010<=0.338;
gen pov_rel_reg=0;        replace pov_rel_reg=100        if index_reg_2010<=909;

svyset [pweight=rw];
svy: mean pov_deep* pov_rel*;
svy: mean pov_deep* pov_rel* if Westbank==1;
svy: mean pov_deep* pov_rel* if Westbank==0;


********** Sensitivity-specificity analysis;
#delim;
tab pov_deep_pc pov_deep;
tab pov_rel_pc pov_rel;

#delim;
tab pov_deep_count pov_deep;
tab pov_rel_count pov_rel;

#delim;
tab pov_deep_reg pov_deep;
tab pov_rel_reg pov_rel;

*West Bank;
#delim;
tab pov_deep_pc pov_deep if Westbank==1;
tab pov_rel_pc pov_rel if Westbank==1;

#delim;
tab pov_deep_count pov_deep if Westbank==1;
tab pov_rel_count pov_rel if Westbank==1;

#delim;
tab pov_deep_reg pov_deep if Westbank==1;
tab pov_rel_reg pov_rel if Westbank==1;

*Gaza;
#delim;
tab pov_deep_pc pov_deep if Westbank==0;
tab pov_rel_pc pov_rel if Westbank==0;

#delim;
tab pov_deep_count pov_deep if Westbank==0;
tab pov_rel_count pov_rel if Westbank==0;

#delim;
tab pov_deep_reg pov_deep if Westbank==0;
tab pov_rel_reg pov_rel if Westbank==0;
