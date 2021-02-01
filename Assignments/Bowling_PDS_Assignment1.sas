/**********************************************************************
Author: Magon Bowling
Date: January 30, 2021
Product: Assignment 1
**********************************************************************/

/**********************************************************************
****************************Import the data****************************
**********************************************************************/
%web_drop_table(WORK.IMPORT);

FILENAME REFFILE '/home/u50186522/sasuser.v94/STAT 6969/Class Work/class1.csv';

PROC IMPORT DATAFILE=REFFILE
	DBMS=CSV
	OUT=WORK.IMPORT;
	GETNAMES=YES;
RUN;

/*********************************************************************
*********Change the name of the file from work.import to tax**********
*********************************************************************/
data tax; set work.import;
run;

/*********************************************************************
********************View the contents of the data*********************
*********************************************************************/
proc contents data=tax;
run;

/*********************************************************************
******Create columns in the table that correlate to the tax form******
*********************************************************************/
*Convert FAGI to a numerical variable;
data tax1; set tax;
fagi2 = input(fagi, dollar10.2);
drop FAGI;
rename fagi2 = fagi;
run;
*Identify conversion;
data tax1; set tax1;
format fagi dollar10.2;
run;
*Check proc contents for changes;
proc contents data=tax1;
run;
*Create columns from the tax form;
data tax2; set tax1;
%let exempt_amount = 590;
%let tax_rate1 = 0.0495;
%let tax_rate2 = 0.06;
%let tax_rate3 = 0.013;
line4 = fagi;
if line4 = . then line4 = 0;
line5 = additions;
if line5 = . then line5 = 0;
line6 = line4 + line5;
line7 = state_refund;
line8 = subtractions;
line9 = line6 - line7 - line8;
*line9 = line6 - sum(line7, line8);
line10 = line9*&tax_rate1;
line11 = utah_exemptions*&exempt_amount;
line12 = federal_deductions;
line13 = line11 + line12;
line14 = state_inc_deducted_on_5a;
line15 = line14 - line13;
line16 = line15*&tax_rate2;
line17 = line17;
line18 = max(line9 - line17, 0);
line19 = line18*&tax_rate3;
line20 = max(line16 - line19, 0);
line22 = max(line10 - line20, 0);
run;

/*********************************************************************
**********Identify how much cummulative money everyone pays***********
*********************************************************************/
proc means data=tax2 sum n;
var line22;
run;

/*********************************************************************
***1. Using a Bernoulli distribution of 20% of the population and a 
random seed of 7584, assuming this 20% are tax exempt, what is the 
mean tax liability for the individuals that pay income tax?
*********************************************************************/
data tax3; set tax2;
%let exempt_amount = 590;
%let tax_rate1 = 0.0495;
%let tax_rate2 = 0.06;
%let tax_rate3 = 0.013;
call streaminit(7584);
population = rand('Bernoulli', 0.20);
line4 = fagi;
if line4 = . then line4 = 0;
line5 = additions;
if line5 = . then line5 = 0;
line6 = line4 + line5;
line7 = state_refund;
line8 = subtractions;
line9 = line6 - line7 - line8;
*line9 = line6 - sum(line7, line8);
line10 = line9*&tax_rate1;
line11 = utah_exemptions*&exempt_amount;
line12 = federal_deductions;
line13 = line11 + line12;
line14 = state_inc_deducted_on_5a;
line15 = line14 - line13;
line16 = line15*&tax_rate2;
line17 = line17;
line18 = max(line9 - line17, 0);
line19 = line18*&tax_rate3;
line20 = max(line16 - line19, 0);
line22 = max(line10 - line20, 0);
if population = 1 then line22 = .;
run;
*Mean tax liability;
proc means data=tax3 mean;
var line22;
run;

/*********************************************************************
***2. What is the average and median income tax by phase-out(line17)?
*********************************************************************/
proc means data=tax3 mean median;
var line22;
by line17;
run;

/*********************************************************************
***3. Looking at some tax policy change, let's say policymakers decide
to increase the dependent exemption to help out larger families.  How
many individuals see a decrease if the dependent exemption amount is 
increased to $3,113?
*********************************************************************/
data tax4; set tax3;
%let exempt_amount1 = 3113;
%let tax_rate1 = 0.0495;
%let tax_rate2 = 0.06;
%let tax_rate3 = 0.013;
line4alt = fagi;
if line4alt = . then line4alt = 0;
line5alt = additions;
if line5alt = . then line5alt = 0;
line6alt = line4alt + line5alt;
line7alt = state_refund;
line8alt = subtractions;
line9alt = line6alt - sum(line7alt, line8alt);
line10alt = line9alt*&tax_rate1;
line11alt = utah_exemptions*&exempt_amount1;
line12alt = federal_deductions;
line13alt = line11alt + line12alt;
line14alt = state_inc_deducted_on_5a;
line15alt = line14alt - line13alt;
line16alt = line15alt*&tax_rate2;
line17 = line17;
line18alt = max(line9alt - line17, 0);
line19alt = line18alt*&tax_rate3;
line20alt = max(line16alt - line19alt, 0);
line22alt = max(line10alt - line20alt, 0);
difference = line22alt - line22;
run;
*Sum of decrease in tax for individuals with larger families;
proc means data=tax4 sum;
var difference;
run;

/*********************************************************************
***4. What about social security?  What is policymakers decided not to 
tax social security?  Use a random seed of 7584 for 25% of the 
population, with 50% of their income from social security, and exempt
it.  How much of a tax is it?
**********************************************************************/
data tax5; set tax3;
%let exempt_amount = 590;
%let tax_rate1 = 0.0495;
%let tax_rate2 = 0.06;
%let tax_rate3 = 0.013;
call streaminit(7584);
social_security_recipient = rand('Bernoulli', 0.25);
line4alt = fagi;
if line4alt = . then line4alt = 0;
if social_security_recipient = 1 then line4alt = line4alt*0.5;
line5alt = additions;
if line5alt = . then line5alt = 0;
line6alt = line4alt + line5alt;
line7alt = state_refund;
line8alt = subtractions;
line9alt = line6alt - sum(line7alt, line8alt);
line10alt = line9alt*&tax_rate1;
line11alt = utah_exemptions*&exempt_amount;
line12alt = federal_deductions;
line13alt = line11alt + line12alt;
line14alt = state_inc_deducted_on_5a;
line15alt = line14alt - line13alt;
line16alt = line15alt*&tax_rate2;
line17 = line17;
line18alt = max(line9alt - line17alt, 0);
line19alt = line18alt*&tax_rate3;
line20alt = max(line16alt - line19alt, 0);
line22alt = max(line10alt - line20alt, 0);
difference = line22alt - line22;
run;
*Tax cut amount for state;
proc means data=tax5 sum;
var difference;
run;

/**********************************************************************
***5. Plot scenarios 2 and 3 in Tableau.
**********************************************************************/
*Export the tax3 file to a .csv;
proc export data=work.tax3
            outfile=_dataout
            dbms=csv replace;
run;

%let _DATAOUT_MIME_TYPE=text/csv;
%let _DATAOUT_NAME=tax3.csv;

*Export the tax4 file to a .csv;
proc export data=work.tax4
            outfile=_dataout
            dbms=csv replace;
run;

%let _DATAOUT_MIME_TYPE=text/csv;
%let _DATAOUT_NAME=tax4.csv;

/**********************************************************************
***6. What if policymakers decide to say: "Everyone with income below
$400,000 gets a tax cut from 30% of FAGI to 28% of FAGI, while for those
with income above $400,000, they'll pay the 28% on their first $400,000
in income and 50% on any income above $400,000."  What's the tax change
overall for this group?  Plot in Tableau.
***********************************************************************/
*Create a baseline state tax and a new state tax;
data tax6; set tax5;
baseline_state_tax = 0;
new_state_tax = 0;
baseline_state_tax = 0.30*fagi;
if fagi lt 400000 then new_state_tax = 0.28*fagi;
if fagi ge 400000 then new_state_tax = 0.28*400000 + 0.50*(fagi-400000);
difference = new_state_tax - baseline_state_tax;
run;
*Tax change for the overall group;
proc means data=tax6 sum;
var difference;
run;

*Export the tax6 file to a .csv;
proc export data=work.tax6
            outfile=_dataout
            dbms=csv replace;
run;

%let _DATAOUT_MIME_TYPE=text/csv;
%let _DATAOUT_NAME=tax6.csv;
