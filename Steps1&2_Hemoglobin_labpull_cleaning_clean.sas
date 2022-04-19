/*/*/*/*/*/*/*/*/*/*/*/*/*/*/*/*/*/*/*/*/*/*/*/*/*/*/*/*/*/*/*/*/*/*/*/*/*/*/*/*/*/*/**/*/*/*/*/*/*/*/*/*/*/*/*/*/*/*/*/*/*/*/*/*/*/*/*/*/*/*/
* 
* Below code will pull hemoglobin labs from CDW using SAS Pass Thru and will save the hemoglobin lab pull table as a SAS dataset for further cleaning.
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
where loinc in ('20509-6', '24360-0', '30313-1', '30350-3', '30351-1', '30352-9', '35183-3', '59260-0', '718-7', '14775-1', '30353-7', 
'30354-5', '33025-8', '33026-6', '48725-6', '54289-4', '55782-7', '61180-6', '75928-2', '76768-1', '76769-9','4635-9','717-9','721-9')
) BY TUNNEL;

EXECUTE (
/*pull in Labchemtest*/
SELECT Labchemtestsid, LabChemTestName, LabChemPrintTestName, Sta3n
into #labtestnames
FROM  [CDWWork].[Dim].[LabChemTest]
WHERE labchemtestname in ('HGB', 'HGB (V2)', 'Hemoglobin', 'HGB3', 'HEMOGLOBIN-----------', 'HGB (AA)', 'HGB (HB)', 'NEW HGB', 'HGB,Blood', 
'HGB (FV)', 'HB (HGB)', 'POC HGB', 'HGB*', 'HGB(5/25/17)', 'HEMOGLOBIN~disc 10/14', 'HGB (XN2000)', 'TOTAL HEMOGLOBIN (BGL4)', 'I-STAT HGB', 'GEM-THb (calculated)', 'HB (HGB)(GAS)', 
'iHEMOGLOBIN (new)', 'HEMOGLOBIN (POC)', 'AT- Hgb CALCU', 'POC-HEMOGLOBIN (HB)', 'HGB, ANC', 'iHEMOGLOBIN', 'HEMOGLOBIN, TOTAL (B-GAS)', 'HEMOGLOBIN (ABG)', 'ABG,ctHb', 
'ABG HGB', 'ANCILLARY HEMOGLOBIN', 'tHb (R)', 'HGB - (BLOOD GAS)', 'tHB..', 'POC HEMOGLOBIN (CALC.)', 'tHb', 'tHb (Arterial)', 'HGB(BMT)', 
'POC HEMOGLOBIN', 'TOTAL HGB-----------O', 'CTHB', 'TOTAL HGB', 'ISTAT HGB', 'BG HGB', 'HGB(LUFKIN)', 'HEMOGLOBIN (RT)', 'HGB (TOPC)', 
'HGB(s)', 'TOTAL HEMOGLOBIN', 'iSTAT HEMOGLOBIN', 'HGB (FS)', 'Hgb (BLOOD)', 'Hgb', 'HEMOGLOBIN-HEPARINIZED SYRINGE', 'FHHb', 'POC-HEMOGLOBIN', 'POC HGB ISTAT', 'ZZZtHb.', 
'HGB ABG (STL)', 'ISTAT-HGB #', 'ctHb (Hb)', 'GEM-THb (measured)','Hgb-iSTAT', 'HGB(KTY)', 'TOTAL HGB (SY)', 'tHb (RAPIDLAB)', 'WB HGB', 
'HGB(TMB)', 'tHb (Venous)', 'VBG,ctHb', 'THb   (BLOOD GAS)*ic', 'THB-POCART', 'HGB (MV)*INACT(1-1-15)', 'tHB', 'HB (tHb)', 'P-HGB', 'POC-HHB', 
'POC TOTAL HGB', 'CVICU-Hgb', 'Hgb calculated', 'HEMOGLOBIN (ISTAT)', 'I-STAT, HGB (STL-MA)','Hbcalc-i (hemoglobin)', 'HGB (iSTAT)', 'ISTAT HEMOGLOBIN', 
'HB (HGB)(AL)', 'I-STAT HEMOGLOBIN', 'ATS CTHB', 'HGB POC (BH/BU)', 'D-HgB', 'MN HGB', 'HEMOGLOBIN {i-STAT}', 'HGB(POC)', 'POC-tHb', 'tHb(GEM)', 'MVBG,ctHb', 
'THb', 'HB (RESP CARE)', 'I-HEMOGLOBIN', 'PB HGB', '.HGB (istat)', 'W-HEMOGLOBIN', 'tHb (PULM)', '_THB (OF ABG PANEL)', 'POC HgB', 'i-Hemoglobin', 
'iHGB', 'THB-POCVEN', 'HGB (HR)','ATS tHb', '_POC HGB', 'HGB-PIERRE','~TOTAL HEMOGLOBIN(THb)', 'BR-HGB', 'HGB ABG', 'HEMOGLOBIN (GAS)', 'tHb(dc"d 12/15/15)', 
'AT-HGB','HGB-COOX-Sea', 'Hgb (ATS)', 'RETICULOCYTE HEMOGLOBIN', '_HGB (I-STAT)', 'QUEST-HGB', 'REF-Hemoglobin', 'HGB {Reference Lab}', 'POC HEMOGLOBIN(CALCULATED)', 
'HGB_ANC', 'HGB-MMC', 'QUEST HEMOGLOBIN', 'LRL HEMOGLOBIN', '.HEMOGLOBIN(SL)', 'HEMOGLOBIN-QUEST(ELECTROPH)', 'HGB-SPL', 'tHGB-Tac', 'ELD HGB', 
'Anc Total Hgb', 'HEMOGLOBIN (096925)','HGB (LC) -', 'TOTAL HGB (POC)', 'HGB (LABCORP)', 'SALEM HGB-PB','HEMOGLOBIN (QUEST)', 'THB', 'TOT-Hb', 
'HATT-HGB', '(FFTH) HGB', 'HGB (HGB ELECTRO)', 'HGB---o', 'Hgb (Hgb Dis Panel)', 'HEMOGLOBIN, CALC (ISTAT)', 'HEMOGLOBIN2', 'HEMOGLOBIN POC', '(STRONG) HGB', 
'HEMOGLOBIN (ABG)*NE', 'Hb (ISTAT)', 'HGB (POCT)', '*POC TOTAL HEMOGLOBIN (WI)', 'HGB-ACL', 'tHb (HEMOGLOBIN-ABG)', 'MH HGB', 'LEG HGB', 
'HGB (CDH)','tHb(PA)', 'tHb(AO)', 'tHb(RA)', 'HEMOGLOBIN-iSTAT', 'HEMOGLOBIN(35489)', 'HGB(LABCORP)', 'TAMC HGB', 'HGB (NMMC)', 'spl hemoglobin', 'HEMOGLOBIN' )
) BY TUNNEL;

EXECUTE (
/*pull loincsids and labchemtestsids from CDW for 2013-2018*/
SELECT distinct a.LabChemSID, a.LabSubjectSID,  a.Sta3n, a.LabPanelIEN, a.LabPanelSID, a.LongAccessionNumberUID, a.ShortAccessionNumber,
       a.LabChemTestSID, a.PatientSID, a.LabChemSpecimenDateTime, a.LabChemSpecimenDateSID, a.LabChemCompleteDateTime, a.LabChemCompleteDateSID,
       a.LabChemResultValue, a.LabChemResultNumericValue, a.TopographySID, a.LOINCSID, a.Units, a.RefHigh, a.RefLow, d.Topography
into #Hemoglobin2013_2018
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
     WHERE  loincsid=-1 and    
      a.LabChemSpecimenDateTime >= '2013-01-01' and a.LabChemSpecimenDateTime < '2019-01-01'  and a.CohortName='Cohort20210503' 
) BY TUNNEL;


/*get unique PatientICN and save table as SAS data set*/
CREATE TABLE sasout.Hemoglobin_all_2013_2018 AS 
SELECT  *
	FROM CONNECTION TO TUNNEL ( 
select distinct a.*, b.PatientICN
from #Hemoglobin2013_2018 a
left join Src.SPatient_SPatient b on a.patientsid=b.PatientSID

);

DISCONNECT FROM TUNNEL ;
QUIT ;

 /*Step 2 - cleaning */

/*remove duplicate labs*/
PROC SORT DATA=sasout.Hemoglobin_all_2013_2018 nodupkey; 
BY  PatientSID Sta3n LabChemSpecimenDateTime LabChemResultNumericValue;
RUN;

/*create new date and time variables*/
DATA Hemoglobin_all_2013_2018_V2;
SET sasout.Hemoglobin_all_2013_2018;
LabSpecimenDate=datepart(LabChemSpecimenDateTime);
LabSpecimenTime=timepart(LabChemSpecimenDateTime);
format LabSpecimenDate mmddyy10.;
format LabSpecimenTime time8.;
keep Sta3n LabChemTestSID PatientSID LabChemResultValue LabChemResultNumericValue TopographySID LOINCSID Units RefHigh RefLow Topography LabSpecimenDate LabSpecimenTime patienticn;
RUN;

/*change patienticn into numeric*/   
DATA Hemoglobin_2013_2018_v4 (rename=patienticn2=patienticn);
SET Hemoglobin_all_2013_2018_V2;
patienticn2 = input(patienticn, 10.);
drop patienticn;
RUN;

/*clean up units and create new field: clean_unit*/
DATA Hemoglobin_2013_2018_v4;
SET Hemoglobin_2013_2018_v4;
Units2=upcase(units); /*turn all units into uppercase*/
units3=compress(Units2,'.'); /*removes '.' in units*/
clean_unit = compress(units3); /*removes all blanks (by default - specify options to remove other chars)*/
drop units2 units3 units;
RUN;


/*check lab value missingness*/

*check which LabChemResultValues not missing when LabChemResultNumericValue is missing;
proc freq data=Hemoglobin_2013_2018_v4 order=freq;
tables LabChemResultValue;
where LabChemResultValue is not missing and LabChemResultNumericValue is missing;
run;

*re-code select LabChemResultNumeric values per PI ;

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

data Hemoglobin_2013_2018_v4;
set Hemoglobin_2013_2018_v4;
array orig [17] $5 _temporary_ ('<0.2' '<0.5' '?11.3' '<3' '<30' '<5' '<4.5' '<4.9' '<5.0' '<5.1' '<6.0' '<6.3' '<6.5' '<6.8' '<10' '?9.3' '<10.0');
array new [17] _temporary_ (
0.1
0.4
11.3
2
29
4
4.4
4.8
4.9
5.0
5.9
6.2
6.4
6.7
9
9.3
9.9);
	do i=1 to dim(orig);
		if LabChemResultValue = orig[i] then LabChemResultNumericValue = new[i];
	end;
run;

*Clean RefHigh and RefLow (reference ranges) variables;
proc freq data=Hemoglobin_2013_2018_v4 order= freq;
tables RefHigh RefLow;

DATA Hemoglobin_2013_2018_v4;
SET Hemoglobin_2013_2018_v4;
RefHigh2=compress(RefHigh,'"'); /*removes '"' */
RefHigh_clean_cat = compress(RefHigh2); /*removes all blanks (by default - specify options to remove other chars)*/

RefLow2=compress(RefLow,'"'); /*removes '"' */
RefLow_clean_cat = compress(RefLow2); /*removes all blanks (by default - specify options to remove other chars)*/
drop RefHigh2 RefLow2 ;
run;

proc freq data=Hemoglobin_2013_2018_v4 order= freq;
tables RefHigh_clean_cat RefLow_clean_cat;
run; 

DATA Hemoglobin_2013_2018_v4;
SET Hemoglobin_2013_2018_v4;
if RefLow_clean_cat = "Lessthan8.4" then RefLow_clean_cat = "<8.4";
if RefLow_clean_cat = "6.9ORLESS" then RefLow_clean_cat = "<=6.9";
run;

*re-code select Ref values per PI;

*import list of original Ref's;
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

data Hemoglobin_2013_2018_v4 (drop= i n j);
set Hemoglobin_2013_2018_v4;
array orig_hi [2] $9 _temporary_ ('M:16F:15' 'M:16-F:15');
array new_hi [2] _temporary_ (16 16);
	do n=1 to dim(orig_hi);
		if RefHigh_clean_cat = orig_hi[n] then RefHigh_clean_cat = new_hi[n];
	end;

array orig_lo [9] $13 _temporary_ ('<0.1' '<=2' '<=6.9' '<7.0' '<8.4' '<10.1' 'M:13F:12' 'M:13-F:12' '13.0-18.0g/dL');
array new_lo [9] _temporary_ (
0.1
2
6.9
7
8.4
10
13
13
13);
	do j=1 to dim(orig_lo);
		if RefLow_clean_cat = orig_lo[j] then RefLow_clean_cat = new_lo[j];
	end;
run;

*check width and decimal places of numeric values for formatting in next step;
proc freq data=Hemoglobin_2013_2018_v4 order= freq;
tables RefHigh_clean_cat RefLow_clean_cat;
run; 

*remove any characters from Refs and convert to numeric;
data Hemoglobin_2013_2018_v4;
set Hemoglobin_2013_2018_v4;
RefLow_clean2 = compress(RefLow_clean_cat, , 'a'); *remove any alphabetic characters;
RefLow_clean = input(RefLow_clean2, 7.);
RefHigh_clean = input(RefHigh_clean_cat, 7.);
drop RefLow_clean2;
run;

*Examine Topography and Units and create summary statistics;
proc sort data=Hemoglobin_2013_2018_v4;
by Topography clean_unit;
run;

*create table of summary stats of labs by topography and units;
proc means data=Hemoglobin_2013_2018_v4 n mean min p10 median p90 max;
class Topography clean_unit;
var LabChemResultNumericValue ;
where LabChemResultNumericValue ne .;
ods output summary=sasout.Lab ;
run;

*create table of summary stats of Refs by topography and units;
proc means data=Hemoglobin_2013_2018_v4 mean median;
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

proc export data= top_unit_labs_refs (drop= NObs VName_RefLow_clean VName_RefHigh_clean)
outfile = "insert file path"
dbms = xlsx replace;
sheet = 'Hemoglobin';
run;

*check how many obs before deleting combos of topography and units to make sure correct number of obs after deleting;
proc means data=Hemoglobin_2013_2018_v4 n mean min p10 median p90 max;
class Topography clean_unit;
var LabChemResultNumericValue ;
where LabChemResultNumericValue ne .;
ods output summary=Lab ;
run;

*After PI review of labs by topography and units, no unit conversions needed;

*create macro lists of topography and units to be excluded;
options source source2 mprint symbolgen mlogic macrogen;

*since list was short did not need to import list as csv;
%let top_h = "BM ASP.,ILIAC CR." "FECES" "MIXED VENOUS" "PERITONEAL FLUID" "PLATELET POOR PLASMA" "PLEURAL FLUID, NOS" "BLOOD" "BLOOD" "PLASMA" "PLASMA" "SERUM" "SERUM";
%let units_h = "G/DL" "MGHB/G" "%" "GM/DL" "G/DL" "%" "PG" "MG%" "MG/DL" "MG%" "MG/DL" "PG";

*exclude combinations of topography and clean_unit;
%macro exclude;
data Hemoglobin_2013_2018_v5;
set Hemoglobin_2013_2018_v4;

%do i=1 %to %sysfunc(countw(&top_h,' ',q));
	%let next1 = %scan(&top_h,&i,' ',q);
	%let next2 = %scan(&units_h,&i,' ',q);

		if topography = &next1 and clean_unit = &next2 then delete;
%end;
run;
%mend exclude;

%exclude

*confirm they are excluded;
proc means data=Hemoglobin_2013_2018_v5 n mean min p10 median p90 max;
class Topography clean_unit;
var LabChemResultNumericValue ;
where LabChemResultNumericValue ne .;
ods output summary=Lab ;
run;

*apply physiological cutoffs per PIs;
data Hemoglobin_2013_2018_v5;
set Hemoglobin_2013_2018_v5;
if LabChemResultNumericValue < 4 or LabChemResultNumericValue > 24 then delete;
run;

/*Create data set with final lab value per date per patient*/
/*create count var of labs per date per pt in order of latest labs first and 
create final_hemoglobin_daily var*/
data finaldate_hgb;
set Hemoglobin_2013_2018_v5;
run;

proc sort data = finaldate_hgb;
by patienticn labspecimendate descending labspecimentime;
run;

data finaldate_hgb;
set finaldate_hgb;
by patienticn labspecimendate;
 retain n;
 if first.labspecimendate then n=1;
 else n = n+1;

if n = 1 then final_hemoglobin_daily = LabChemResultNumericValue;
 run;

/*create data set only including final Hemoglobin labs*/
data sasout.final_Hemoglobin_pretrim;
set finaldate_hgb;
where n=1;
run;
