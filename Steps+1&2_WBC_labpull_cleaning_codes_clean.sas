/*/*/*/*/*/*/*/*/*/*/*/*/*/*/*/*/*/*/*/*/*/*/*/*/*/*/*/*/*/*/*/*/*/*/*/*/*/*/*/*/*/*/**/*/*/*/*/*/*/*/*/*/*/*/*/*/*/*/*/*/*/*/*/*/*/*/*/*/*/*/
* 
* Below code will pull WBC labs from CDW using SAS Pass Thru and will save the WBC lab pull table as a SAS dataset for further cleaning.
* This code also creates a final lab value for each patient-day while inpatient.
*
* Date Created: 11/4/2021
* Author: Jennifer Cano (this code is a modified version of Shirley Wang's code)
*
*/*/*/*/*/*/*/*/*/*/*/*/*/*/*/*/*/*/*/*/*/*/*/*/*/*/*/*/*/*/*/*/*/*/*/*/*/*/*/*/*/*/*/**/*/*/*/*/*/*/*/*/*/*/*/*/*/*/*/*/*/*/*/*/*/*/*/*/*/*/*/;

%let DATASRCs= /*insert your data source here*/;

libname sasout /*'insert file path'*/;

/*Step 1 - pull data from CDW using SAS Pass Thru*/

PROC SQL  ;
CONNECT TO SQLSVR AS TUNNEL (DATASRC=&DATASRCs. &SQL_OPTIMAL. )  ;

/*pull in all loincsids*/
EXECUTE (
select LOINC, Component, Sta3n, LOINCSID
into #loinc
from [CDWWork].[Dim].[loinc]
where loinc in ('26464-8','49498-9','6690-2','804-5')
) BY TUNNEL;

EXECUTE (
/*pull in Labchemtest*/
SELECT Labchemtestsid, LabChemTestName, LabChemPrintTestName, Sta3n
into #labtestnames
FROM  [CDWWork].[Dim].[LabChemTest]
WHERE labchemtestname in ('WBC',
'WBC (REFERENCE LAB)',
'ZWBC (RETIRED 6/29/05)',
'.WBC (MINOT AFB)DC 6/8/10', 
'AUTO WBC','CBC/WBC EX',
'COOK WBC',
'CORRECTED WBC',
'CORRECTED WBC-------0',
'C-WBC-CBOC',
'HOPC-WBC',
'LEG WBC',
'MH WBC (WET PREP)',
'MN WBC',
'NAVY STAT WBC',
'NEW WBC',
'OB-WBC',
'Q-WBC DC"D',
'T-CELL WBC',
'TOTAL WBC',
'Total WBC',
'Total WBC Count (AML)',
'Wbc',
'WBC------------------',
'WBC  -',
'WBC - SCAN Dc"d 1-21-08',
'WBC (AA)',
'WBC (AUTOMATED)',
'WBC (AUTOMATED) WR',
'WBC (BEFORE 5/9/06)',
'WBC (DO NOT USE)',
'WBC (FCM)',
'WBC (FOR ANC CALC.)',
'WBC (FV)',
'WBC (LABCORP)',
'WBC (MV)',
'WBC (ORS)',
'WBC (REFERENCE LAB)',
'WBC (RESEARCH PANEL) (TO 6/13/05)',
'WBC (thru 10/6/09)',
'WBC (V2)',
'WBC {Reference Lab}',
'WBC {St. George}',
'WBC AUTO',
'WBC AUTO  -',
'WBC COUNT',
'WBC COUNT (K/uL)',
'WBC Dc"d 1-21-08',
'WBC SCAN Dc"D 4-9-09',
'WBC(CBOC)',
'WBC(EST)',
'WBC(PRE-2/2/12)',
'WBC*',
'WBC/uL',
'WBC2',
'WBC-auto (V1FC)',
'WBC--------------CSFO',
'WBC-FL',
'WBC"S',
'Z++WBC-OUTSIDE LAB',
'ZHS WBC',
'ZSJWBC(DC"D 5-10)',
'ZWBC (RETIRED 6/29/05)',
'zzz WBC(BRAD)',
'WBC (for CD4/CD8)',
'z*INACT*WBC (4-1-10)',
'ZSJUAWBC(DC"D 5-10)',
'WHITE BLOOD CELLS Thru 2/12/07',
'TOTAL WHITE BLOOD COUNT',
'WHITE CELL COUNT',
'WHITE CELLS, TOTAL')
) BY TUNNEL;

EXECUTE (
/*pull WBC loincsids and labchemtestsids from CDW for 2013-2018*/
SELECT distinct a.LabChemSID, a.LabSubjectSID,  a.Sta3n, a.LabPanelIEN, a.LabPanelSID, a.LongAccessionNumberUID, a.ShortAccessionNumber,
       a.LabChemTestSID, a.PatientSID, a.LabChemSpecimenDateTime, a.LabChemSpecimenDateSID, a.LabChemCompleteDateTime, a.LabChemCompleteDateSID,
       a.LabChemResultValue, a.LabChemResultNumericValue, a.TopographySID, a.LOINCSID, a.Units, a.RefHigh, a.RefLow, d.Topography
into #WBC2013_2018
FROM  src.Chem_PatientLabChem AS A
INNER JOIN #loinc b on  a.Loincsid=b.Loincsid 
LEFT JOIN [CDWWork].[Dim].[topography] AS d ON A.TopographySID =D.TopographySID
	WHERE a.LabChemSpecimenDateTime >= '2013-01-01' and a.LabChemSpecimenDateTime < '2019-01-01'  and a.CohortName='Cohort20210503' 

UNION

SELECT distinct a.LabChemSID, a.LabSubjectSID,  a.Sta3n, a.LabPanelIEN, a.LabPanelSID, a.LongAccessionNumberUID, a.ShortAccessionNumber,
       a.LabChemTestSID, a.PatientSID, a.LabChemSpecimenDateTime, a.LabChemSpecimenDateSID, a.LabChemCompleteDateTime, a.LabChemCompleteDateSID,
       a.LabChemResultValue, a.LabChemResultNumericValue, a.TopographySID, a.LOINCSID, a.Units, a.RefHigh, a.RefLow, d.Topography
FROM src.Chem_PatientLabChem a         
INNER JOIN #labtestnames b ON a.labchemtestsid=b.labchemtestsid 
LEFT JOIN [CDWWork].[Dim].[topography] AS d ON A.TopographySID =D.TopographySID
     WHERE a.LabChemSpecimenDateTime >= '2013-01-01' and a.LabChemSpecimenDateTime < '2019-01-01'  and a.CohortName='Cohort20210503' 
) BY TUNNEL;

/*get unique PatientICN and save table as SAS data set*/
CREATE TABLE sasout.wbc2013_2018 AS 
SELECT  *
	FROM CONNECTION TO TUNNEL ( 
select distinct a.*, b.PatientICN
from #WBC2013_2018 a
left join Src.SPatient_SPatient b on a.patientsid=b.PatientSID
);

DISCONNECT FROM TUNNEL ;
QUIT ;


/*Step 2 - cleaning */

/*remove duplicate labs*/
PROC SORT DATA=sasout.wbc2013_2018 nodupkey; 
BY  patientSID  sta3n LabChemTestSID  LOINCSID Units LabChemResultNumericValue LabChemSpecimenDateTime;
RUN;

/*create new date and time variables*/
data wbc2013_2018;
set sasout.wbc2013_2018;
LabSpecimenDate=datepart(LabChemSpecimenDateTime);
LabSpecimenTime=timepart(LabChemSpecimenDateTime);
year=year(LabSpecimenDate);
format LabSpecimenDate mmddyy10.;
format LabSpecimenTime time8.;
keep Sta3n year LabChemTestSID PatientSID LabChemResultValue LabChemResultNumericValue TopographySID LOINCSID Units RefHigh RefLow Topography LabChemSpecimenDateTime LabSpecimenDate LabSpecimenTime patienticn;
run;

/*change patienticn into numeric*/   
DATA wbc2013_2018 (rename=patienticn2=patienticn);
SET wbc2013_2018;
patienticn2 = input(patienticn, 10.);
drop patienticn;
RUN;

/*clean up units and create new field: clean_unit*/
data wbc2013_2018;
set wbc2013_2018;
Units2=upcase(units); /*turn all units into uppercase*/
units3=compress(Units2,'.'); /*removes '.' in units*/
clean_unit = compress(units3); /*removes all blanks (by default - specify options to remove other chars)*/
drop  units2 units3 units;
run;

/*check lab value missingness*/

*check which LabChemResultValues (categorical var) not missing when LabChemResultNumericValue (numeric var) is missing;
*numeric values without characters from LabChemResultValues get copied into LabChemResultNumericValue, so some 
numeric values including characters need to be cleaned and then manually merged into LabChemResultNumericValue;
proc freq data=wbc2013_2018 order=freq;
tables LabChemResultValue;
where LabChemResultValue is not missing and LabChemResultNumericValue is missing;
run;

*there are many LabChemResultValues written as numbers with commas;
*remove commas from LabChemResultValues and copy numbers into LabChemResultNumericValue;
data LabChemResult_no_comma;
set wbc2013_2018;
format LabChemResultNumericValue_nc 21.4 ;     
LabChemResultNumericValue_nc = compress(LabChemResultValue,','); 
where LabChemResultValue is not missing and LabChemResultNumericValue is missing;
run;

*create new LabChemResultNumericValue2 in wbc data set to merge with LabChemResultNumericValue_nc created in 
LabChemResult_no_comma data set - will have to merge data sets then use coalesce to fill in missing values in original data set;
data wbc2013_2018_v2;
set wbc2013_2018;
format LabChemResultNumericValue2 21.4 ;  
LabChemResultNumericValue2 = LabChemResultNumericValue;
run;

*create blank LabChemResultNumericValue_nc var to then merge columns;
data wbc2013_2018_v2;
set wbc2013_2018_v2;
format LabChemResultNumericValue_nc 21.4;
LabChemResultNumericValue_nc = .;
run;

*merge data sets;
proc sort data=wbc2013_2018_v2;
by patienticn LabSpecimenDate LabSpecimenTime LabChemTestSID;
run;
proc sort data=LabChemResult_no_comma;
by patienticn LabSpecimenDate LabSpecimenTime LabChemTestSID;
run;
data wbc2013_2018_v3;
merge wbc2013_2018_v2 LabChemResult_no_comma;
by patienticn LabSpecimenDate LabSpecimenTime LabChemTestSID;
run;

*merge LabChemResultNumericValue2 and LabChemResultNumericValue_nc columns;
data wbc2013_2018_v4;
set wbc2013_2018_v3;
LabChemResultNumericValue_new = coalesce(LabChemResultNumericValue2, LabChemResultNumericValue_nc);
run;

/*get table to send to PI with incorrect LabChemResultValue*/
proc freq data=wbc2013_2018_v4 order=freq;
tables LabChemResultValue;
where LabChemResultValue is not missing and LabChemResultNumericValue_new is missing;
run;

*re-code select LabChemResultNumeric values per PI;
*import list of original LabChemResultValue's;
proc import datafile="insert file path"
out= names dbms=csv replace;
getnames=yes;
guessingrows=max;
run;
*extract all values to create macro list to copy into array;
proc sql;
	select catt("'", value, "'")
	into :NamesList separated by ' '
	from names;
	quit;
%put &NamesList;

data wbc2013_2018_v4;
set wbc2013_2018_v4;
array orig [12] $5 _temporary_ ('<3' '<200' '>182' '>100' '<1.0' '<0.6' '<0.5' '<0.2' '<0.03' '<1' '0-4' '<0.1');
array new [12] _temporary_ (
2
199
183
101
0.9
0.5
0.4
0.1
0.02
0
0
0
);
	do i=1 to dim(orig);
		if LabChemResultValue = orig[i] then LabChemResultNumericValue = new[i];
	end;
run;

proc print data=wbc2013_2018_v4;
where LabChemResultValue = '<200';
run;

*Clean RefHigh and RefLow (reference range) variables;
proc freq data=wbc2013_2018_v4 order= freq;
tables RefHigh RefLow;

DATA wbc2013_2018_v4;
SET wbc2013_2018_v4;
RefHigh2=compress(RefHigh,'"'); /*removes '"' */
RefHigh_clean_cat = compress(RefHigh2); /*removes all blanks (by default - specify options to remove other chars)*/

RefLow2=compress(RefLow,'"'); /*removes '"' */
RefLow_clean_cat = compress(RefLow2); /*removes all blanks (by default - specify options to remove other chars)*/
drop RefHigh2 RefLow2 ;
run;

proc freq data=wbc2013_2018_v4 order= freq;
tables RefHigh_clean_cat RefLow_clean_cat;
run; 

DATA wbc2013_2018_v4;
SET wbc2013_2018_v4 (drop=RefLow_clean RefHigh_clean);
if RefLow_clean_cat = "Lessthan8.4" then RefLow_clean_cat = "<8.4";
if RefLow_clean_cat = "6.9ORLESS" then RefLow_clean_cat = "<=6.9";
run;

*re-code select Ref values per PI;
data wbc2013_2018_v4 (drop= i n j);
set wbc2013_2018_v4;
array orig_hi [4] $14 _temporary_ ('<150' '<200' "<200WBC'S/cumm" '<300');
array new_hi [4] _temporary_ (150
200
200
300);
	do n=1 to dim(orig_hi);
		if RefHigh_clean_cat = orig_hi[n] then RefHigh_clean_cat = new_hi[n];
	end;

array orig_lo [6] $12 _temporary_ ('4.0-10.0K/ul'
'>60'
'<150'
'<200'
'<200/UL'
'<500');
array new_lo [6] _temporary_ (
4
60
150
200
200
500);
	do j=1 to dim(orig_lo);
		if 
RefLow_clean_cat = orig_lo[j] then RefLow_clean_cat = new_lo[j];
	end;
run;

proc print data=wbc2013_2018_v4 (obs= 1000);
where RefHigh_clean_cat ne RefHigh or RefLow_clean_cat ne RefLow;
run;

*check width and decimal places of numeric values for formatting in next step;
proc freq data=wbc2013_2018_v4 order= freq;
tables RefHigh_clean_cat RefLow_clean_cat;
run; 

*since will be compressing and only keeping digits and decimal points in next data step, need to change this to missing, otherwise 
will convert to a number and this value is to be excluded;
data wbc2013_2018_v4;
set wbc2013_2018_v4;
if RefLow_clean_cat = '-7' then RefLow_clean_cat = "";
run;

*remove any characters from Refs and convert to numeric;
data wbc2013_2018_v4;
set wbc2013_2018_v4;
RefLow_clean2 = compress(RefLow_clean_cat,'.' , 'kd'); *keep digits and decimal points;
RefLow_clean = input(RefLow_clean2, 5.);
RefHigh_clean2 = compress(RefHigh_clean_cat,'.' , 'kd');
RefHigh_clean = input(RefHigh_clean_cat, 6.);
drop RefLow_clean2 RefHigh_clean2;
run;

*Examine Topography and Units and create summary statistics;
proc sort data=wbc2013_2018_v4 ;
by Topography clean_unit;
run;

*create table of summary stats of labs by topography and units;
proc means data=wbc2013_2018_v4  n mean min p10 median p90 max;
class Topography clean_unit;
var LabChemResultNumericValue ;
where LabChemResultNumericValue ne .;
ods output summary=sasout.Lab ;
run;

*create table of summary stats of Refs by topography and units;
proc means data=wbc2013_2018_v4  mean median;
class Topography clean_unit;
var RefLow_clean RefHigh_clean ;
ods output summary=sasout.Refs;
run;

*create merged table to send to PIs;
proc sql;
create table top_unit_labs_refs as
select *
from sasout.Lab a
left join sasout.Refs b on a.Topography=b.Topography and
a.clean_unit = b.clean_unit;
quit;

proc export data=top_unit_labs_refs (drop= NObs VName_RefLow_clean VName_RefHigh_clean)
outfile = "insert file path"
dbms = xlsx replace;
sheet = 'WBC';
run;


*After PI review of labs by topography and units, several unit conversions needed ;

*check how many obs before deleting combos of topography and units to make sure correct number of obs after deleting;
proc means data=wbc2013_2018_v4 n mean min p10 median p90 max;
class Topography clean_unit;
var LabChemResultNumericValue ;
where LabChemResultNumericValue ne .;
ods output summary=Lab ;
run;

*import lists of excluded topography and units;
proc import datafile="insert file path"
out= names dbms=csv replace;
getnames=yes;
guessingrows=max;
run;

*extract all values to create macro list to exclude combos of ;
proc sql;
	select catt('"', Topography, '"')
	into :top_w separated by ' '
	from names;
	select catt('"', clean_unit, '"')
	into :units_w separated by ' '
	from names;
	quit;
%put &top_w;
%put &units_w;

options source source2 mprint symbolgen mlogic macrogen;

*exclude combinations of topography and clean_unit;
%macro exclude;
data wbc2013_2018_v5;
set wbc2013_2018_v4;

%do i=1 %to %sysfunc(countw(&top_w,' ',q));
	%let next1 = %scan(&top_w,&i,' ',q);
	%let next2 = %scan(&units_w,&i,' ',q);

		if topography = &next1 and clean_unit = &next2 then delete;
%end;
run;
%mend exclude;

%exclude

*confirm they are excluded;
proc means data=wbc2013_2018_v5 n mean min p10 median p90 max;
class Topography clean_unit;
var LabChemResultNumericValue ;
where LabChemResultNumericValue ne .;
ods output summary=Lab ;
run;

*apply physiological cutoffs per PIs;
data wbc2013_2018_v5;
set wbc2013_2018_v5;
if LabChemResultNumericValue < 0 or LabChemResultNumericValue > 300 then delete;
run;

*convert and edit units;
data wbc2013_2018_v5;
set wbc2013_2018_v5;
*convert units;
if topography = 'BLOOD' and clean_unit in ('CUMM','UL','CELLS/UL') then LabChemResultNumericValue = LabChemResultNumericValue/1000;
if topography = 'BLOOD' and clean_unit in ('#/CMM','COUNTS/UL') then LabChemResultNumericValue = LabChemResultNumericValue/10000;
*edit units;
if topography = 'BLOOD' and clean_unit in ('CUMM','#/CMM') then clean_unit = 'K/CMM';
if topography = 'BLOOD' and clean_unit in ('UL','CELLS/UL','COUNTS/UL') then clean_unit = 'K/UL';
run;

*unit conversion not needed here, but actual unit is wrong so will rename;
data wbc2013_2018_v5;
set wbc2013_2018_v5;
if topography = 'BLOOD' and clean_unit = '/UL' then clean_unit = 'K/UL';
if topography = 'BLOOD' and clean_unit = 'K/ML' then clean_unit = 'K/UL';
run;

/*Create data set with final lab value per date per patient*/

/*create count var of labs per date per pt in order of latest labs first and 
create final_wbc_daily var*/

proc sort data = wbc2013_2018_v5;
by patienticn labspecimendate descending labspecimentime;
run;

data finaldate_wbc;
set wbc2013_2018_v5;
by patienticn labspecimendate;
 retain n;
 if first.labspecimendate then n=1;
 else n = n+1;

if n = 1 then final_wbc_daily = LabChemResultNumericValue;
 run;

/*create data set only including final wbc labs*/
data sasout.final_wbc_daily_pre;
set finaldate_wbc;
where n=1;
run;


