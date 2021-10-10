#delim;
clear;
clear matrix;
set more 1;
set mem 200m;

*******************************************************************************************
*******************************************************************************************
**     DATE:       June 2014
**     PROGRAM:    Calculation of total expenditures for PECS surveys
**     AUTHORS:    LSmith
**     PURPOSE:    Calculate total expenditures per adult equivalent for PECS 2009-PECS 2011 surveys
********************************************************************************************
********************************************************************************************;

*Note:  Using the method of calculating "total consumption" from the PCBS 2011 report (p.61).

*************************************************************************************
*************************************************************************************
*  Calculate hhsize and adult equivalents for each data set 
*************************************************************************************
*************************************************************************************;

****************
* PECS 2011
****************;

#delim;
use "C:\AA_LISACAT\aa_TANGO\Palestine SEFSec\data\PECS\2011\roster.dta", clear;
gen ones=1;
gen adult=0;  replace adult=1 if d5>18;
gen child=0;  replace child=1 if d5<=18;
egen num_adult=sum(adult), by(id00);
egen num_child=sum(child), by(id00);

collapse (sum) hhsize=ones (mean) num_adult num_child, by(id00);

gen hhae_PCBS_2011=(num_adult + 0.46*num_child)^0.89;
sum hhae_PCBS;

drop num*;
rename id00 ID00;
save "C:\AA_LISACAT\aa_TANGO\Palestine SEFSec\data\outfiles\PECS 2011_hhsize.dta", replace;
*4,317 hholds;
sum;
*Mean hhsize=6.01;


****************
* PECS 2010
****************;

#delim;
use "C:\AA_LISACAT\aa_TANGO\Palestine SEFSec\data\PECS\2010\roster.dta", clear;
gen ones=1;
gen adult=0;  replace adult=1 if D5>18;
gen child=0;  replace child=1 if D5<=18;
egen num_adult=sum(adult), by(ID00);
egen num_child=sum(child), by(ID00);

collapse (sum) hhsize=ones (mean) num_adult num_child, by(ID00);

gen hhae_PCBS_2010=(num_adult + 0.46*num_child)^0.89;
sum hhae_PCBS;

drop num*;
save "C:\AA_LISACAT\aa_TANGO\Palestine SEFSec\data\outfiles\PECS 2010_hhsize.dta", replace;
*3,757 hholds;
sum;
*Mean hhsize=6.02;

****************
* PECS 2009
****************;

#delim;
use "C:\AA_LISACAT\aa_TANGO\Palestine SEFSec\data\PECS\2009\Roaster.dta", clear;
gen ones=1;
gen adult=0;  replace adult=1 if D5>18;
gen child=0;  replace child=1 if D5<=18;
egen num_adult=sum(adult), by(ID00);
egen num_child=sum(child), by(ID00);

collapse (sum) hhsize=ones (mean) num_adult num_child, by(ID00);

gen hhae_PCBS_2009=(num_adult + 0.46*num_child)^0.89;
sum hhae_PCBS;

drop num*;
save "C:\AA_LISACAT\aa_TANGO\Palestine SEFSec\data\outfiles\PECS 2009_hhsize.dta", replace;
*4,848 hholds;
sum;
*Mean hhsize=6.02;

	
*************************************************************************************
*************************************************************************************
*  Calculate expenditures per adult equivalent and per capita for each data set
*************************************************************************************
*************************************************************************************;

*********************************************
* PECS 2011
********************************************;

#delim;
*Note:  Using the file with aggregates already calculated for this;
use "C:\AA_LISACAT\aa_TANGO\Palestine SEFSec\data\PECS\2011\MainGrps.dta", clear;
sum;
*No missings;

*The variable TOT_Cons is the aggregate;
gen exp_tot_noCPI_2011=TOT_Cons;
sum exp_tot_noCPI_2011;

***** Deflate by the CPI;
merge 1:1 ID00 using "C:\AA_LISACAT\aa_TANGO\Palestine SEFSec\data\PECS\2011\Cover.dta", keepusing(ID01 rw);
drop if _merge==2; drop _merge;

*Using the spatial CPI in the file "Poverty and spacial CPI-2013 1.xls" sent by Rana Hannoun on 6/19/14; 
gen exp_tot_real_2011=exp_tot_noCPI/1.18 if ID01==41;
replace exp_tot_real_2011=exp_tot_noCPI/1.02 if (ID01<51 & ID01~=41);
replace exp_tot_real_2011=exp_tot_noCPI/0.93 if ID01>50;
sum exp_tot_real_2011;

***** Calculate expenditures per adult equivalent and per capita;
merge 1:1 ID00 using "C:\AA_LISACAT\aa_TANGO\Palestine SEFSec\data\outfiles\PECS 2011_hhsize.dta";
drop if _merge==2; drop _merge;

gen exp_tot_ae_real_2011=exp_tot_real_2011/hhae_PCBS_2011;
gen exp_tot_pc_real_2011=exp_tot_real_2011/hhsize;

*Clean data;
*hist exp_tot_ae_real;
drop if exp_tot_ae_real>10000;
*8 cases dropped;

keep ID00 exp_tot_real_2011 exp_tot_ae_real_2011 exp_tot_pc_real_2011 rw;
rename ID00 hhid;
save "C:\AA_LISACAT\aa_TANGO\Palestine SEFSec\data\outfiles\PECS 2011_expenditures_PhaseII.dta", replace;

svyset [pweight=rw];
svy: mean exp_tot_pc_real_2011;

*********************************************
* PECS 2010
********************************************;

#delim;
use "C:\AA_LISACAT\aa_TANGO\Palestine SEFSec\data\PECS\2010\maingrpnis.dta", clear;
sum;
*No missings;

*The variable TOT_Cons is the aggregate;
gen exp_tot_noCPI_2011=Tot_cons;
sum exp_tot_noCPI_2011;

***** Deflate by the CPI;
merge 1:1 ID00 using "C:\AA_LISACAT\aa_TANGO\Palestine SEFSec\data\PECS\2010\Cover.dta", keepusing(Area rw);
drop if _merge==2; drop _merge;

*Using the spatial CPI in the file "Poverty and spacial CPI-2013 1.xls" sent by Rana Hannoun on 6/19/14; 
*Note:  Can't separate out Jerusalem from the others because no governorate variable given for this data set (ID01);
gen exp_tot_real_2010=exp_tot_noCPI/1.01 if Area~=4;
replace exp_tot_real_2010=exp_tot_noCPI/0.94 if Area==4 ;
sum exp_tot_real_2010;

***** Calculate expenditures per adult equivalent and per capita;
merge 1:1 ID00 using "C:\AA_LISACAT\aa_TANGO\Palestine SEFSec\data\outfiles\PECS 2010_hhsize.dta";
drop if _merge==2; drop _merge;

gen exp_tot_ae_real_2010=exp_tot_real_2010/hhae_PCBS_2010;
gen exp_tot_pc_real_2010=exp_tot_real_2010/hhsize;

*Clean data;
*hist exp_tot_ae_real;
drop if exp_tot_ae_real>10000;
*8 cases dropped;

keep ID00 exp_tot_real_2010 exp_tot_ae_real_2010 exp_tot_pc_real_2010 rw;
rename ID00 hhid;
save "C:\AA_LISACAT\aa_TANGO\Palestine SEFSec\data\outfiles\PECS 2010_expenditures_PhaseII.dta", replace;

svyset [pweight=rw];
svy: mean exp_tot_pc_real_2010;

*********************************************
* PECS 2009
********************************************;

#delim;
use "C:\AA_LISACAT\aa_TANGO\Palestine SEFSec\data\PECS\2009\maingrpsJd.dta", clear;
sum;
*No missings;

*The variable TOT_CONS is the aggregate;
gen exp_tot_noCPI_2009=TOT_CONS;
sum exp_tot_noCPI_2009;

***** Deflate by the CPI;
merge 1:1 ID00 using "C:\AA_LISACAT\aa_TANGO\Palestine SEFSec\data\PECS\2009\Cover.dta", keepusing(Area rw);
drop if _merge==2; drop _merge;

*Using the spatial CPI in the file "Poverty and spacial CPI-2013 1.xls" sent by Rana Hannoun on 6/19/14; 
*Note:  Can't separate out Jerusalem from the others because no governorate variable given for this data set (ID01);
gen exp_tot_real_2009=exp_tot_noCPI/1.01 if Area~=1;
replace exp_tot_real_2009=exp_tot_noCPI/0.94 if Area==1;
sum exp_tot_real_2009;

***** Convert to NIS;
replace exp_tot_real_2009=exp_tot_real_2009*5.55;

***** Calculate expenditures per adult equivalent and per capita;
merge 1:1 ID00 using "C:\AA_LISACAT\aa_TANGO\Palestine SEFSec\data\outfiles\PECS 2009_hhsize.dta";
drop if _merge==2; drop _merge;

gen exp_tot_ae_real_2009=exp_tot_real_2009/hhae_PCBS_2009;
gen exp_tot_pc_real_2009=exp_tot_real_2009/hhsize;

*Clean data;
*hist exp_tot_ae_real;
drop if exp_tot_ae_real>10000;
*5 cases dropped;

keep ID00 exp_tot_real_2009 exp_tot_ae_real_2009 exp_tot_pc_real_2009 rw;
rename ID00 hhid;
save "C:\AA_LISACAT\aa_TANGO\Palestine SEFSec\data\outfiles\PECS 2009_expenditures_PhaseII.dta", replace;

svyset [pweight=rw];
svy: mean exp_tot_pc_real_2009;


