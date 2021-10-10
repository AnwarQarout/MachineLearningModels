#delim;
clear;
clear matrix;
set memory 150m;
set more 1;

*********************************************************************
*********************************************************************
**     DATE:       June 2014
**     PROGRAM:    Asset index variables_PECS
**     AUTHOR:     LSmith 
**     PURPOSE:    Create variables to potentially include in asset index using PECS 2011, 2010 and 2009 data
*********************************************************************
*********************************************************************;
 
***************************************************************
***************************************************************
*  2011 
***************************************************************
***************************************************************;

*****************************************
*  Geographical areas, sampling weights 
*****************************************;

use "C:\AA_LISACAT\aa_TANGO\Palestine SEFSec\data\PECS\2011\Cover.dta", clear;
rename ID00 hhid;
codebook hhid;
*4,317 households;
label var hhid "Household identification number";

*** Sampling weights;
rename rw samplewt;

gen Westbank=0;
replace Westbank=1 if region==1;
tab Westbank;

*** Creating variable urban;
*Note:  This variable has three categories:  urban, rural and refugee camp;
gen urban=0;
replace urban=1 if loc_type==1;
tab urban, missing;

sort hhid;
keep hhid samplewt urban Westbank;
save "C:\AA_LISACAT\aa_TANGO\Palestine SEFSec\data\PECS\2011\outfiles\temp1.dta", replace;


********************************
* Household size and refugee status
********************************;

#delim;
use "C:\AA_LISACAT\aa_TANGO\Palestine SEFSec\data\PECS\2011\Roster.dta", clear;
rename id00 hhid;
codebook hhid;
* 4,317 households;

tab d6, missing;
gen ref=1 if d6==1;
replace ref=0 if d6==2;

gen ones=1;
egen hhsize=sum(ones), by(hhid);
egen count_ref=sum(ref), by(hhid);
collapse (mean) count_ref hhsize, by(hhid);
tab count_ref, missing;

gen refugee=0;  replace refugee=1 if count_ref>0;
tab refugee;

keep hhid hhsize refugee;
sort hhid;
save "C:\AA_LISACAT\aa_TANGO\Palestine SEFSec\data\PECS\2011\outfiles\temp2.dta", replace;

********************************************************
* Number of household adult equivalents 
*********************************************************;

use "C:\AA_LISACAT\aa_TANGO\Palestine SEFSec\data\PECS\2011\Roster.dta", clear;

gen adult=0;  replace adult=1 if d5>18;
gen child=0;  replace child=1 if d5<=18;
egen num_adult=sum(adult), by(id00);
egen num_child=sum(child), by(id00);
collapse (mean) num_adult num_child, by(id00);
gen hhae=(num_adult + 0.46*num_child)^0.89;
label var hhae "Number of adult equivalents";

rename id00 hhid;
keep hhid hhae;
sort hhid;
save "C:\AA_LISACAT\aa_TANGO\Palestine SEFSec\data\PECS\2011\outfiles\temp3.dta", replace;


*************************************************************
* Age-sex composition 
**************************************************************;

#delim;
use "C:\AA_LISACAT\aa_TANGO\Palestine SEFSec\data\PECS\2011\Roster.dta", clear;
rename id00 hhid;
codebook hhid;
* 4,317 households;

rename d5 agey;
rename d4 sex;

*** Create age categories (catage);
gen     catage=1  if agey < 1 & agey~=.;
replace catage=2  if agey >=1  & agey <  2 & agey~=.;
replace catage=3  if agey >=2  & agey <  3 & agey~=.;
replace catage=4  if agey >=3  & agey <  5 & agey~=.;
replace catage=5  if agey >=5  & agey <  7 & agey~=.;
replace catage=6  if agey >=7  & agey < 10 & agey~=.;
replace catage=7  if agey >=10 & agey < 12 & agey~=.;
replace catage=8  if agey >=12 & agey < 14 & agey~=.;
replace catage=9  if agey >=14 & agey < 16 & agey~=.;
replace catage=10 if agey >=16 & agey < 18 & agey~=.;
replace catage=11 if agey >=18 & agey < 30 & agey~=.;
replace catage=12 if agey >=30 & agey < 60 & agey~=.;
replace catage=13 if agey >=60 ;
tab catage, missing;
* None missing;

*** Create age groups (agegroup);
gen     agegroup=1  if catage <=9  & catage~=.;
replace agegroup=2  if catage ==10|catage==11;
replace agegroup=3  if catage >=12 & catage~=.;
tab agegroup, missing;
* None missing;

*** Bring in household size variable;
sort hhid;
merge hhid using "C:\AA_LISACAT\aa_TANGO\Palestine SEFSec\data\PECS\2011\outfiles\temp2.dta";
tab _merge; drop if _merge==2; drop _merge;

*** Create age-sex groups;
capture prog drop agesex2;
program define agesex2;
  gen b= (agegroup==`2' & sex==`3') if agegroup~=.;
  egen c=sum(b) if agegroup~=., by(hhid);
  gen `1'=(c*100)/hhsize;
  drop b;
  drop c;
end;
agesex2 mx0_16   1   1;
agesex2 mx16_30  2   1;
agesex2 mx30p    3   1;
agesex2 fx0_16   1   2;
agesex2 fx16_30  2   2;
agesex2 fx30p    3   2;

egen pm0_16 =mean(mx0_16), by(hhid);  
egen pm16_30=mean(mx16_30), by(hhid);  
egen pm30p=  mean(mx30p), by(hhid);  
egen pf0_16= mean(fx0_16), by(hhid);  
egen pf16_30=mean(fx16_30), by(hhid);  
egen pf30p=  mean(fx30p), by(hhid);  

*** Collapse to household level;
collapse pm0_16 pm16_30 pm30p pf0_16 pf16_30 pf30p, by(hhid);

label var pm0  "Percent males 0-16";
label var pm16 "Percent males 16-30";
label var pm30 "Percent males 30p";
label var pf0  "Percent females 0-16";
label var pf16 "Percent females 16-30";
label var pf30 "Percent females 30p";

*** Make sure percentages add to 100;
gen horse=pf0+pf16+pf30+pm0+pm16+pm30;
**There should be no other number than "100";
tab horse, missing;
* All 100 percent;
drop horse;

gen p16_30=pm16+pf16;
gen p30p=  pm30p+pf30p;

sort hhid;
save "C:\AA_LISACAT\aa_TANGO\Palestine SEFSec\data\PECS\2011\outfiles\temp4.dta", replace;


****************************************************************
* Age, sex and education of household head  
****************************************************************;

#delim;
use "C:\AA_LISACAT\aa_TANGO\Palestine SEFSec\data\PECS\2011\Roster.dta", clear;
rename id00 hhid;
codebook hhid;
* 4,317 households;;

rename d5 agey;
rename d4 sex;
rename d3 relation;
tab relation, missing;

*** Only keep household heads;
keep if relation==1;

*** Create variable to identify female headed household;
gen femhead=1 if sex==2;
replace femhead=0 if sex==1;
tab femhead, missing;
* 0 missing, OK;

*** Create variable with age of household head;
gen agehhh=agey;

***** Education of hhh;
*illiterate-read or write?;
tab d16, missing;

gen hhh_educ_L=0; replace hhh_educ_L=1 if d16==1 | d16==2;
gen hhh_educ_P=0; replace hhh_educ_P=1 if d16==3 | d16==4;
gen hhh_educ_Sh=0; replace hhh_educ_Sh=1 if d16>=5 & d16~=.;
sum hhh*;

keep hhid femhead agehhh hhh*;
label var femhead "Female headed household";
label var agehhh "Age of household head (years)";

sort hhid;
save "C:\AA_LISACAT\aa_TANGO\Palestine SEFSec\data\PECS\2011\outfiles\temp5.dta", replace;

****************************************************************
*  Assets (durables)
****************************************************************;

#delim;
use "C:\AA_LISACAT\aa_TANGO\Palestine SEFSec\data\PECS\2011\Dwelling.dta", clear;
rename ID00 hhid;

*Refrigerator;
gen asset1=0; replace asset1=1 if h21_2==1;
*Solar heater;
gen asset2=0; replace asset2=1 if h21_3==1;
*Washing machine;
gen asset3=0; replace asset3=1 if h21_4==1;
*Dishwasher;
gen asset4=0; replace asset4=1 if h21_6==1;
*Central heating;
gen asset5=0; replace asset5=1 if h21_7==1;
*Vacuum cleaner;
gen asset6=0; replace asset6=1 if h21_8==1;
*Home library;
gen asset7=0; replace asset7=1 if h21_10==1;
*TV;
gen asset8=0; replace asset8=1 if h21_11==1;
*VCR/DVD;
gen asset9=0; replace asset9=1 if h21_12==1;
*Telephone;
gen asset10=0; replace asset10=1 if h21_13==1;
*Cell phone;
gen asset11=0; replace asset11=1 if h21_15==1;
*Computer;
gen asset12=0; replace asset12=1 if h21_16==1;
*Satellite dish;
gen asset13=0; replace asset13=1 if h21_17==1;
*Radio/recorder;
gen asset14=0; replace asset14=1 if h21_19==1;
*Microwave;
gen asset15=0; replace asset15=1 if h21_18==1;
*Private car;
gen asset16=0; replace asset16=1 if h21_1==1;

keep hhid asset*;
sort hhid;
save "C:\AA_LISACAT\aa_TANGO\Palestine SEFSec\data\PECS\2011\outfiles\temp7.dta", replace;


****************************************************************
*  Dwelling characteristics 
****************************************************************;
#delim;
use "C:\AA_LISACAT\aa_TANGO\Palestine SEFSec\data\PECS\2011\Dwelling.dta", clear;
*codebook ID00;

********** Density of members per bedroom; 
rename ID00 hhid;
merge 1:1 hhid using "C:\AA_LISACAT\aa_TANGO\Palestine SEFSec\data\PECS\2011\outfiles\hhinfo_pecs2011.dta";
keep if _merge==3; drop _merge;
gen br_density=hhsize/h6;

********* Whether there is a bathroom with piped water; 
tab h11, missing; 
gen bathroom_p=0 if h11~=.;  replace bathroom_p=1 if h11==1;
tab bathroom_p, missing;

********* Heating from gas, kerosene or electric;
tab h13_2, missing;

gen heating_gke=0 if h13_2~=.;
replace heating_gke=1 if h13_2==1 | h13_2==2 | h13_2==3;

keep hhid br_density bathroom_p heating_gke*;
sort hhid;
save "C:\AA_LISACAT\aa_TANGO\Palestine SEFSec\data\PECS\2011\outfiles\temp8.dta", replace;

****************************************************************
*  Merge files 
****************************************************************;

use "C:\AA_LISACAT\aa_TANGO\Palestine SEFSec\data\PECS\2011\outfiles\temp1.dta", replace;
merge hhid using "C:\AA_LISACAT\aa_TANGO\Palestine SEFSec\data\PECS\2011\outfiles\temp2.dta"; drop _merge; sort hhid;
merge hhid using "C:\AA_LISACAT\aa_TANGO\Palestine SEFSec\data\PECS\2011\outfiles\temp3.dta"; drop _merge; sort hhid;
merge hhid using "C:\AA_LISACAT\aa_TANGO\Palestine SEFSec\data\PECS\2011\outfiles\temp4.dta"; drop _merge; sort hhid;
merge hhid using "C:\AA_LISACAT\aa_TANGO\Palestine SEFSec\data\PECS\2011\outfiles\temp5.dta"; drop _merge; sort hhid;
merge hhid using "C:\AA_LISACAT\aa_TANGO\Palestine SEFSec\data\PECS\2011\outfiles\temp7.dta"; drop _merge; sort hhid;
merge hhid using "C:\AA_LISACAT\aa_TANGO\Palestine SEFSec\data\PECS\2011\outfiles\temp8.dta"; drop _merge; sort hhid;

sort hhid;
save "C:\AA_LISACAT\aa_TANGO\Palestine SEFSec\data\outfiles\PhaseII\asset index variables_PECS2011.dta", replace;

erase "C:\AA_LISACAT\aa_TANGO\Palestine SEFSec\data\PECS\2011\outfiles\temp1.dta";
erase "C:\AA_LISACAT\aa_TANGO\Palestine SEFSec\data\PECS\2011\outfiles\temp2.dta";
erase "C:\AA_LISACAT\aa_TANGO\Palestine SEFSec\data\PECS\2011\outfiles\temp3.dta";
erase "C:\AA_LISACAT\aa_TANGO\Palestine SEFSec\data\PECS\2011\outfiles\temp4.dta";
erase "C:\AA_LISACAT\aa_TANGO\Palestine SEFSec\data\PECS\2011\outfiles\temp5.dta";
erase "C:\AA_LISACAT\aa_TANGO\Palestine SEFSec\data\PECS\2011\outfiles\temp7.dta"; 
erase "C:\AA_LISACAT\aa_TANGO\Palestine SEFSec\data\PECS\2011\outfiles\temp8.dta"; 


***************************************************************
***************************************************************
*  2010 
***************************************************************
***************************************************************;

*****************************************
*  Geographical areas, sampling weights 
*****************************************;

#delim;
use "C:\AA_LISACAT\aa_TANGO\Palestine SEFSec\data\PECS\2010\Cover.dta", clear;
rename ID00 hhid;
codebook hhid;
*3,757 households;
label var hhid "Household identification number";

*** Sampling weights;
rename rw samplewt;

gen Westbank=0;
replace Westbank=1 if region==1;
tab Westbank;

*** Creating variable urban;
*Note:  This variable has three categories:  urban, rural and refugee camp;
gen urban=0;
replace urban=1 if loctype==1;
tab urban, missing;

sort hhid;
keep hhid samplewt urban Westbank;
save "C:\AA_LISACAT\aa_TANGO\Palestine SEFSec\data\PECS\2010\outfiles\temp1.dta", replace;


********************************
* Household size and refugee status
********************************;

#delim;
use "C:\AA_LISACAT\aa_TANGO\Palestine SEFSec\data\PECS\2010\Roster.dta", clear;
rename ID00 hhid;

tab D6, missing;
gen ref=1 if D6==1;
replace ref=0 if D6==2;

gen ones=1;
egen hhsize=sum(ones), by(hhid);
egen count_ref=sum(ref), by(hhid);
collapse (mean) count_ref hhsize, by(hhid);
tab count_ref, missing;

gen refugee=0;  replace refugee=1 if count_ref>0;
tab refugee;

keep hhid hhsize refugee;
sort hhid;
save "C:\AA_LISACAT\aa_TANGO\Palestine SEFSec\data\PECS\2010\outfiles\temp2.dta", replace;

********************************************************
* Number of household adult equivalents 
*********************************************************;

#delim;
use "C:\AA_LISACAT\aa_TANGO\Palestine SEFSec\data\PECS\2010\Roster.dta", clear;

gen adult=0;  replace adult=1 if D5>18;
gen child=0;  replace child=1 if D5<=18;
egen num_adult=sum(adult), by(ID00);
egen num_child=sum(child), by(ID00);
collapse (mean) num_adult num_child, by(ID00);
gen hhae=(num_adult + 0.46*num_child)^0.89;
label var hhae "Number of adult equivalents";

rename ID00 hhid;
keep hhid hhae;
sort hhid;
save "C:\AA_LISACAT\aa_TANGO\Palestine SEFSec\data\PECS\2010\outfiles\temp3.dta", replace;


*************************************************************
* Age-sex composition 
**************************************************************;

#delim;
use "C:\AA_LISACAT\aa_TANGO\Palestine SEFSec\data\PECS\2010\Roster.dta", clear;
rename ID00 hhid;

rename D5 agey;
rename D4 sex;

*** Create age categories (catage);
gen     catage=1  if agey < 1 & agey~=.;
replace catage=2  if agey >=1  & agey <  2 & agey~=.;
replace catage=3  if agey >=2  & agey <  3 & agey~=.;
replace catage=4  if agey >=3  & agey <  5 & agey~=.;
replace catage=5  if agey >=5  & agey <  7 & agey~=.;
replace catage=6  if agey >=7  & agey < 10 & agey~=.;
replace catage=7  if agey >=10 & agey < 12 & agey~=.;
replace catage=8  if agey >=12 & agey < 14 & agey~=.;
replace catage=9  if agey >=14 & agey < 16 & agey~=.;
replace catage=10 if agey >=16 & agey < 18 & agey~=.;
replace catage=11 if agey >=18 & agey < 30 & agey~=.;
replace catage=12 if agey >=30 & agey < 60 & agey~=.;
replace catage=13 if agey >=60 ;
tab catage, missing;
* None missing;

*** Create age groups (agegroup);
gen     agegroup=1  if catage <=9  & catage~=.;
replace agegroup=2  if catage ==10|catage==11;
replace agegroup=3  if catage >=12 & catage~=.;
tab agegroup, missing;
* None missing;

*** Bring in household size variable;
sort hhid;
merge hhid using "C:\AA_LISACAT\aa_TANGO\Palestine SEFSec\data\PECS\2010\outfiles\temp2.dta";
tab _merge; drop if _merge==2; drop _merge;

*** Create age-sex groups;
capture prog drop agesex2;
program define agesex2;
  gen b= (agegroup==`2' & sex==`3') if agegroup~=.;
  egen c=sum(b) if agegroup~=., by(hhid);
  gen `1'=(c*100)/hhsize;
  drop b;
  drop c;
end;
agesex2 mx0_16   1   1;
agesex2 mx16_30  2   1;
agesex2 mx30p    3   1;
agesex2 fx0_16   1   2;
agesex2 fx16_30  2   2;
agesex2 fx30p    3   2;

egen pm0_16 =mean(mx0_16), by(hhid);  
egen pm16_30=mean(mx16_30), by(hhid);  
egen pm30p=  mean(mx30p), by(hhid);  
egen pf0_16= mean(fx0_16), by(hhid);  
egen pf16_30=mean(fx16_30), by(hhid);  
egen pf30p=  mean(fx30p), by(hhid);  

*** Collapse to household level;
collapse pm0_16 pm16_30 pm30p pf0_16 pf16_30 pf30p, by(hhid);

label var pm0  "Percent males 0-16";
label var pm16 "Percent males 16-30";
label var pm30 "Percent males 30p";
label var pf0  "Percent females 0-16";
label var pf16 "Percent females 16-30";
label var pf30 "Percent females 30p";

*** Make sure percentages add to 100;
gen horse=pf0+pf16+pf30+pm0+pm16+pm30;
**There should be no other number than "100";
tab horse, missing;
* All 100 percent;
drop horse;

gen p16_30=pm16+pf16;
gen p30p=  pm30p+pf30p;

sort hhid;
save "C:\AA_LISACAT\aa_TANGO\Palestine SEFSec\data\PECS\2010\outfiles\temp4.dta", replace;


****************************************************************
* Age, sex and education of household head  
****************************************************************;

#delim;
use "C:\AA_LISACAT\aa_TANGO\Palestine SEFSec\data\PECS\2010\Roster.dta", clear;
rename ID00 hhid;

rename D5 agey;
rename D4 sex;
rename D3 relation;
tab relation, missing;

*** Only keep household heads;
keep if relation==1;

*** Create variable to identify female headed household;
gen femhead=1 if sex==2;
replace femhead=0 if sex==1;
tab femhead, missing;
* 0 missing, OK;

*** Create variable with age of household head;
gen agehhh=agey;

***** Education of hhh;
*illiterate-read or write?;
tab D16, missing;

gen hhh_educ_L=0; replace hhh_educ_L=1 if D16==1 | D16==2;
gen hhh_educ_P=0; replace hhh_educ_P=1 if D16==3 | D16==4;
gen hhh_educ_Sh=0; replace hhh_educ_Sh=1 if D16>=5 & D16~=.;
sum hhh*;


keep hhid femhead agehhh hhh*;
label var femhead "Female headed household";
label var agehhh "Age of household head (years)";

sort hhid;
save "C:\AA_LISACAT\aa_TANGO\Palestine SEFSec\data\PECS\2010\outfiles\temp5.dta", replace;


****************************************************************
*  Assets (durables)
****************************************************************;

#delim;
use "C:\AA_LISACAT\aa_TANGO\Palestine SEFSec\data\PECS\2010\Dwelling.dta", clear;
rename ID00 hhid;

*Refrigerator;
gen asset1=0; replace asset1=1 if H21_2==1;
*Solar heater;
gen asset2=0; replace asset2=1 if H21_3==1;
*Washing machine;
gen asset3=0; replace asset3=1 if H21_4==1;
*Dishwasher;
gen asset4=0; replace asset4=1 if H21_6==1;
*Central heating;
gen asset5=0; replace asset5=1 if H21_7==1;
*Vacuum cleaner;
gen asset6=0; replace asset6=1 if H21_8==1;
*Home library;
gen asset7=0; replace asset7=1 if H21_10==1;
*TV;
gen asset8=0; replace asset8=1 if H21_11==1;
*VCR/DVD;
gen asset9=0; replace asset9=1 if H21_12==1;
*Telephone;
gen asset10=0; replace asset10=1 if H21_13==1;
*Cell phone;
****NOTE:  For 2011 it is "Cellcom";
gen asset11=0; replace asset11=1 if Mobile==1;
*Computer;
gen asset12=0; replace asset12=1 if H21_16==1;
*Satellite dish;
gen asset13=0; replace asset13=1 if H21_17==1;
*Radio/recorder;
gen asset14=0; replace asset14=1 if H21_19==1;
*Microwave;
gen asset15=0; replace asset15=1 if H21_18==1;
*Private car;
gen asset16=0; replace asset16=1 if H21_1==1;

keep hhid asset*;
sort hhid;
save "C:\AA_LISACAT\aa_TANGO\Palestine SEFSec\data\PECS\2010\outfiles\temp7.dta", replace;


****************************************************************
*  Dwelling characteristics 
****************************************************************;

#delim;
use "C:\AA_LISACAT\aa_TANGO\Palestine SEFSec\data\PECS\2010\Dwelling.dta", clear;
rename ID00 hhid;

********** Density of members per bedroom; 
sort hhid;
merge hhid using "C:\AA_LISACAT\aa_TANGO\Palestine SEFSec\data\PECS\2010\outfiles\temp2.dta";
keep if _merge==3; drop _merge;
gen br_density=hhsize/H6;

********* Whether there is a bathroom with piped water; 
tab H11, missing; 
gen bathroom_p=0 if H11~=.;  replace bathroom_p=1 if H11==1;
tab bathroom_p, missing;

********* Heating from gas, kerosene or electric;
tab H13_2, missing;

gen heating_gke=0 if H13_2~=.;
replace heating_gke=1 if H13_2==1 | H13_2==2 | H13_2==3;

keep hhid br_density bathroom_p heating_gke*;
sort hhid;
save "C:\AA_LISACAT\aa_TANGO\Palestine SEFSec\data\PECS\2010\outfiles\temp8.dta", replace;

****************************************************************
*  Merge files 
****************************************************************;

use "C:\AA_LISACAT\aa_TANGO\Palestine SEFSec\data\PECS\2010\outfiles\temp1.dta", replace;
merge hhid using "C:\AA_LISACAT\aa_TANGO\Palestine SEFSec\data\PECS\2010\outfiles\temp2.dta"; drop _merge; sort hhid;
merge hhid using "C:\AA_LISACAT\aa_TANGO\Palestine SEFSec\data\PECS\2010\outfiles\temp3.dta"; drop _merge; sort hhid;
merge hhid using "C:\AA_LISACAT\aa_TANGO\Palestine SEFSec\data\PECS\2010\outfiles\temp4.dta"; drop _merge; sort hhid;
merge hhid using "C:\AA_LISACAT\aa_TANGO\Palestine SEFSec\data\PECS\2010\outfiles\temp5.dta"; drop _merge; sort hhid;
merge hhid using "C:\AA_LISACAT\aa_TANGO\Palestine SEFSec\data\PECS\2010\outfiles\temp7.dta"; drop _merge; sort hhid;
merge hhid using "C:\AA_LISACAT\aa_TANGO\Palestine SEFSec\data\PECS\2010\outfiles\temp8.dta"; drop _merge; sort hhid;

sort hhid;
save "C:\AA_LISACAT\aa_TANGO\Palestine SEFSec\data\outfiles\PhaseII\asset index variables_PECS2010.dta", replace;

erase "C:\AA_LISACAT\aa_TANGO\Palestine SEFSec\data\PECS\2010\outfiles\temp1.dta";
erase "C:\AA_LISACAT\aa_TANGO\Palestine SEFSec\data\PECS\2010\outfiles\temp2.dta";
erase "C:\AA_LISACAT\aa_TANGO\Palestine SEFSec\data\PECS\2010\outfiles\temp3.dta";
erase "C:\AA_LISACAT\aa_TANGO\Palestine SEFSec\data\PECS\2010\outfiles\temp4.dta";
erase "C:\AA_LISACAT\aa_TANGO\Palestine SEFSec\data\PECS\2010\outfiles\temp5.dta";
erase "C:\AA_LISACAT\aa_TANGO\Palestine SEFSec\data\PECS\2010\outfiles\temp7.dta"; 
erase "C:\AA_LISACAT\aa_TANGO\Palestine SEFSec\data\PECS\2010\outfiles\temp8.dta"; 


***************************************************************
***************************************************************
*  2009 
***************************************************************
***************************************************************;

*****************************************
*  Geographical areas, sampling weights 
*****************************************;

#delim;
use "C:\AA_LISACAT\aa_TANGO\Palestine SEFSec\data\PECS\2009\Cover.dta", clear;
rename ID00 hhid;
codebook hhid;
*3,848 households;
label var hhid "Household identification number";

*** Sampling weights;
rename rw samplewt;

gen Westbank=0;
replace Westbank=1 if Region==1;
tab Westbank;

*** Creating variable urban;
*Note:  This variable has three categories:  urban, rural and refugee camp;
gen urban=0;
replace urban=1 if loc_type==1;
tab urban, missing;

sort hhid;
keep hhid samplewt urban Westbank;
save "C:\AA_LISACAT\aa_TANGO\Palestine SEFSec\data\PECS\2009\outfiles\temp1.dta", replace;


********************************
* Household size and refugee status
********************************;

#delim;
use "C:\AA_LISACAT\aa_TANGO\Palestine SEFSec\data\PECS\2009\Roaster.dta", clear;
rename ID00 hhid;
codebook hhid;
* 4,317 households;

tab D6, missing;
gen ref=1 if D6==1;
replace ref=0 if D6==2;

gen ones=1;
egen hhsize=sum(ones), by(hhid);
egen count_ref=sum(ref), by(hhid);
collapse (mean) count_ref hhsize, by(hhid);
tab count_ref, missing;

gen refugee=0;  replace refugee=1 if count_ref>0;
tab refugee;

keep hhid hhsize refugee;
sort hhid;
save "C:\AA_LISACAT\aa_TANGO\Palestine SEFSec\data\PECS\2009\outfiles\temp2.dta", replace;

********************************************************
* Number of household adult equivalents 
*********************************************************;

#delim;
use "C:\AA_LISACAT\aa_TANGO\Palestine SEFSec\data\PECS\2009\Roaster.dta", clear;

gen adult=0;  replace adult=1 if D5>18;
gen child=0;  replace child=1 if D5<=18;
egen num_adult=sum(adult), by(ID00);
egen num_child=sum(child), by(ID00);
collapse (mean) num_adult num_child, by(ID00);
gen hhae=(num_adult + 0.46*num_child)^0.89;
label var hhae "Number of adult equivalents";

rename ID00 hhid;
keep hhid hhae;
sort hhid;
save "C:\AA_LISACAT\aa_TANGO\Palestine SEFSec\data\PECS\2009\outfiles\temp3.dta", replace;


*************************************************************
* Age-sex composition 
**************************************************************;

#delim;
use "C:\AA_LISACAT\aa_TANGO\Palestine SEFSec\data\PECS\2009\Roaster.dta", clear;
rename ID00 hhid;

rename D5 agey;
rename D4 sex;

*** Create age categories (catage);
gen     catage=1  if agey < 1 & agey~=.;
replace catage=2  if agey >=1  & agey <  2 & agey~=.;
replace catage=3  if agey >=2  & agey <  3 & agey~=.;
replace catage=4  if agey >=3  & agey <  5 & agey~=.;
replace catage=5  if agey >=5  & agey <  7 & agey~=.;
replace catage=6  if agey >=7  & agey < 10 & agey~=.;
replace catage=7  if agey >=10 & agey < 12 & agey~=.;
replace catage=8  if agey >=12 & agey < 14 & agey~=.;
replace catage=9  if agey >=14 & agey < 16 & agey~=.;
replace catage=10 if agey >=16 & agey < 18 & agey~=.;
replace catage=11 if agey >=18 & agey < 30 & agey~=.;
replace catage=12 if agey >=30 & agey < 60 & agey~=.;
replace catage=13 if agey >=60 ;
tab catage, missing;
* None missing;

*** Create age groups (agegroup);
gen     agegroup=1  if catage <=9  & catage~=.;
replace agegroup=2  if catage ==10|catage==11;
replace agegroup=3  if catage >=12 & catage~=.;
tab agegroup, missing;
* None missing;

*** Bring in household size variable;
sort hhid;
merge hhid using "C:\AA_LISACAT\aa_TANGO\Palestine SEFSec\data\PECS\2009\outfiles\temp2.dta";
tab _merge; drop if _merge==2; drop _merge;

*** Create age-sex groups;
capture prog drop agesex2;
program define agesex2;
  gen b= (agegroup==`2' & sex==`3') if agegroup~=.;
  egen c=sum(b) if agegroup~=., by(hhid);
  gen `1'=(c*100)/hhsize;
  drop b;
  drop c;
end;
agesex2 mx0_16   1   1;
agesex2 mx16_30  2   1;
agesex2 mx30p    3   1;
agesex2 fx0_16   1   2;
agesex2 fx16_30  2   2;
agesex2 fx30p    3   2;

egen pm0_16 =mean(mx0_16), by(hhid);  
egen pm16_30=mean(mx16_30), by(hhid);  
egen pm30p=  mean(mx30p), by(hhid);  
egen pf0_16= mean(fx0_16), by(hhid);  
egen pf16_30=mean(fx16_30), by(hhid);  
egen pf30p=  mean(fx30p), by(hhid);  

*** Collapse to household level;
collapse pm0_16 pm16_30 pm30p pf0_16 pf16_30 pf30p, by(hhid);

label var pm0  "Percent males 0-16";
label var pm16 "Percent males 16-30";
label var pm30 "Percent males 30p";
label var pf0  "Percent females 0-16";
label var pf16 "Percent females 16-30";
label var pf30 "Percent females 30p";

*** Make sure percentages add to 100;
gen horse=pf0+pf16+pf30+pm0+pm16+pm30;
**There should be no other number than "100";
tab horse, missing;
* All 100 percent;
drop horse;

gen p16_30=pm16+pf16;
gen p30p=  pm30p+pf30p;

sort hhid;
save "C:\AA_LISACAT\aa_TANGO\Palestine SEFSec\data\PECS\2009\outfiles\temp4.dta", replace;


****************************************************************
* Age, sex and education of household head  
****************************************************************;

#delim;
use "C:\AA_LISACAT\aa_TANGO\Palestine SEFSec\data\PECS\2009\Roaster.dta", clear;
rename ID00 hhid;

rename D5 agey;
rename D4 sex;
rename D3 relation;
tab relation, missing;

*** Only keep household heads;
keep if relation==1;

*Drop extra hholds;
drop if (hhid==3406 |
hhid==3434 |
hhid==7904 |
hhid==968  |
hhid==6474 |
hhid==6736 |
hhid==10062 |
hhid==15304 |
hhid==4598  |
hhid==1594  |
hhid==3732  |
hhid==2364  |
hhid==14040 |
hhid==3372)  & D1~=1;

*** Create variable to identify female headed household;
gen femhead=1 if sex==2;
replace femhead=0 if sex==1;
tab femhead, missing;
* 0 missing, OK;

*** Create variable with age of household head;
gen agehhh=agey;

***** Education of hhh;
tab D16, missing;
gen hhh_educ_L=0; replace hhh_educ_L=1 if D16==1 | D16==2;
gen hhh_educ_P=0; replace hhh_educ_P=1 if D16==3 | D16==4;
gen hhh_educ_S=0; replace hhh_educ_S=1 if D16>=5 & D16~=.;
*Assume 5 missing values are in category one;
replace hhh_educ_L=1 if D16==.;
sum hhh*;

keep hhid femhead agehhh hhh*;
label var femhead "Female headed household";
label var agehhh "Age of household head (years)";

sort hhid;
save "C:\AA_LISACAT\aa_TANGO\Palestine SEFSec\data\PECS\2009\outfiles\temp5.dta", replace;


****************************************************************
*  Assets (durables)
****************************************************************;

#delim;
use "C:\AA_LISACAT\aa_TANGO\Palestine SEFSec\data\PECS\2009\Dwelling.dta", clear;
rename ID00 hhid;

*Refrigerator;
gen asset1=0; replace asset1=1 if H21_2==1;
*Solar heater;
gen asset2=0; replace asset2=1 if H21_3==1;
*Washing machine;
gen asset3=0; replace asset3=1 if H21_4==1;
*Dishwasher;
gen asset4=0; replace asset4=1 if H21_6==1;
*Central heating;
gen asset5=0; replace asset5=1 if H21_7==1;
*Vacuum cleaner;
gen asset6=0; replace asset6=1 if H21_8==1;
*Home library;
gen asset7=0; replace asset7=1 if H21_10==1;
*TV;
gen asset8=0; replace asset8=1 if H21_11==1;
*VCR/DVD;
gen asset9=0; replace asset9=1 if H21_12==1;
*Telephone;
gen asset10=0; replace asset10=1 if H21_13==1;
*Cell phone;
*Need to check to see if comparable with 2010 and 2011;
gen asset11=0; replace asset11=1 if (H21_14==1|H21_15==1);
*Computer;
gen asset12=0; replace asset12=1 if H21_16==1;
*Satellite dish;
gen asset13=0; replace asset13=1 if H21_17==1;
*Radio/recorder;
gen asset14=0; replace asset14=1 if H21_19==1;
*Microwave;
gen asset15=0; replace asset15=1 if H21_18==1;
*Private car;
gen asset16=0; replace asset16=1 if H21_1==1;

keep hhid asset*;
sort hhid;
save "C:\AA_LISACAT\aa_TANGO\Palestine SEFSec\data\PECS\2009\outfiles\temp7.dta", replace;


****************************************************************
*  Dwelling characteristics 
****************************************************************;

#delim;
use "C:\AA_LISACAT\aa_TANGO\Palestine SEFSec\data\PECS\2009\Dwelling.dta", clear;
*codebook ID00;

********** Density of members per bedroom; 
rename ID00 hhid;
merge 1:1 hhid using "C:\AA_LISACAT\aa_TANGO\Palestine SEFSec\data\PECS\2009\outfiles\temp2.dta";
keep if _merge==3; drop _merge;
gen br_density=hhsize/H6;

********* Whether there is a bathroom with piped water; 
tab H11, missing; 
gen bathroom_p=0 if H11~=.;  replace bathroom_p=1 if H11==1;
tab bathroom_p, missing;

********* Heating from gas, kerosene, electric or solar;
tab H13_2, missing;

gen heating_gke=0 if H13_2~=.;
replace heating_gke=1 if H13_2==1 | H13_2==2 | H13_2==3;

keep hhid br_density bathroom_p heating_gke*;
sort hhid;
save "C:\AA_LISACAT\aa_TANGO\Palestine SEFSec\data\PECS\2009\outfiles\temp8.dta", replace;

****************************************************************
*  Merge files 
****************************************************************;

use "C:\AA_LISACAT\aa_TANGO\Palestine SEFSec\data\PECS\2009\outfiles\temp1.dta", replace;
merge hhid using "C:\AA_LISACAT\aa_TANGO\Palestine SEFSec\data\PECS\2009\outfiles\temp2.dta"; drop _merge; sort hhid;
merge hhid using "C:\AA_LISACAT\aa_TANGO\Palestine SEFSec\data\PECS\2009\outfiles\temp3.dta"; drop _merge; sort hhid;
merge hhid using "C:\AA_LISACAT\aa_TANGO\Palestine SEFSec\data\PECS\2009\outfiles\temp4.dta"; drop _merge; sort hhid;
merge hhid using "C:\AA_LISACAT\aa_TANGO\Palestine SEFSec\data\PECS\2009\outfiles\temp5.dta"; drop _merge; sort hhid;
merge hhid using "C:\AA_LISACAT\aa_TANGO\Palestine SEFSec\data\PECS\2009\outfiles\temp7.dta"; drop _merge; sort hhid;
merge hhid using "C:\AA_LISACAT\aa_TANGO\Palestine SEFSec\data\PECS\2009\outfiles\temp8.dta"; drop _merge; sort hhid;

sort hhid;
save "C:\AA_LISACAT\aa_TANGO\Palestine SEFSec\data\outfiles\PhaseII\asset index variables_PECS2009.dta", replace;

erase "C:\AA_LISACAT\aa_TANGO\Palestine SEFSec\data\PECS\2009\outfiles\temp1.dta";
erase "C:\AA_LISACAT\aa_TANGO\Palestine SEFSec\data\PECS\2009\outfiles\temp2.dta";
erase "C:\AA_LISACAT\aa_TANGO\Palestine SEFSec\data\PECS\2009\outfiles\temp3.dta";
erase "C:\AA_LISACAT\aa_TANGO\Palestine SEFSec\data\PECS\2009\outfiles\temp4.dta";
erase "C:\AA_LISACAT\aa_TANGO\Palestine SEFSec\data\PECS\2009\outfiles\temp5.dta";
erase "C:\AA_LISACAT\aa_TANGO\Palestine SEFSec\data\PECS\2009\outfiles\temp7.dta"; 
erase "C:\AA_LISACAT\aa_TANGO\Palestine SEFSec\data\PECS\2009\outfiles\temp8.dta"; 
