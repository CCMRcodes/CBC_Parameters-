/*/*/*/*/*/*/*/*/*/*/*/*/*/*/*/*/*/*/*/*/*/*/*/*/*/*/*/*/*/*/*/*/*/*/*/*/*/*/*/*/*/*/**/*/*/*/*/*/*/*/*/*/*/*/*/*/*/*/*/*/*/*/*/*/*/*/*/*/*/*/
* 
* Below code will pull platelet labs from CDW using SAS Pass Thru and will save the platelet lab pull table as a SAS dataset for further cleaning.
* This code also creates a final lab value for each patient-day while inpatient.
*
* Date Created: 10/21/2021
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
where loinc in ('13056-7','26515-7','26516-5','777-3','778-1','49497-1')
) BY TUNNEL;

EXECUTE (
/*pull in Labchemtest*/
SELECT Labchemtestsid, LabChemTestName, LabChemPrintTestName, Sta3n
into #labtestnames
FROM  [CDWWork].[Dim].[LabChemTest]
WHERE labchemtestname in ('PLT', 'PLATELET COUNT', 'PLATELETS', 'PLT (V2)', 'PLT*', 'PLATELET', 'PLTS', 'PLT CT', 'Pltct', 'PLATELETS:', 'PLT3', 
'PLATELET COUNT-------', 'PLATELET (AA)', 'PLT (FV)', 'PLT(D/C 5/25/17)', 'PLATELET CT', 'PLATELET COUNT  -', 'PLATELET~disc 10/14', 'PLT (XN2000)', 
'PLT (COUNT)', 'PLT COUNT', 'PLT-AUTO', 'PLT(BMT)', 'PLT(LUFKIN)', 'PLATELET (TOPC)', 'PLT (FS)', 'PLT(s)', 'PLT(KTY)', 'PLT(TMB)', 'PLT (MV)*INACT(1-1-15)', 
'P-PLATELET COUNT', 'PLT (ESTM)', 'D-Platelets', 'MN PLT', 'MANUAL PLATELETS', 'PB PLT', 'W-PLATELETS', 'plt, lca', 'PLT (HR)', 'PLTCOUNT-COAG PANEL-O', 
'PLT-PIERRE', 'BR-PLT', 'PLT COUNT ESTIMATE', 'PLT (CD4/CD8)', 'PLATELET (BLUE TOP)', 'PLATELET ONLY(auto)', 'OR PLATELET', 'PLT-MMC', 'PLATELET IN CITRATE ANTICOAGULANT', 
'PLATELET CNT (BLUE TOP)', 'LRL PLATELET', 'PLATELET COUNT FOR PLT CLUMPS', 'PLT, BLUE TOP*', 'PLATELETS (LABCORP)', 'CIT PLATELET', 'ELD PLT', 
'PLATELETS (096925)', 'PLATELETS', 'CITRATED PLT', 'PLTS (LC) -', 'PLATELET (CITRATED)', 'PLATELET COUNT (CITRATE)', 'PLATELET COUNT-BLUE TOP', 'PLT (LABCORP)', 
'SALEM PLATELETS-PB', 'PLT-BTT', '*PLT COUNT', 'HATT-PLT', '(FFTH) PLT', 'Sp.Pl.(Blue)', 'CITRATE PLATELET COUNT', '(STRONG) PLT', 'CITRATED PLATELET COUNT', 
'PLT-ACL', '_PLT (UW)', '_PLT-BTT (LOW PLT ONLY)', 'MH PLATELET COUNT', 'LEG PLT', 'PLATELET BLUE', 'PLT (CDH)', 'PLATELETS(LABCORP)', 'TAMC PLT', 
'PLT (NMMC)')
) BY TUNNEL;

EXECUTE (
/*pull loincsids and labchemtestsids from CDW for 2013-2018*/
SELECT distinct a.LabChemSID, a.LabSubjectSID,  a.Sta3n, a.LabPanelIEN, a.LabPanelSID, a.LongAccessionNumberUID, a.ShortAccessionNumber,
       a.LabChemTestSID, a.PatientSID, a.LabChemSpecimenDateTime, a.LabChemSpecimenDateSID, a.LabChemCompleteDateTime, a.LabChemCompleteDateSID,
       a.LabChemResultValue, a.LabChemResultNumericValue, a.TopographySID, a.LOINCSID, a.Units, a.RefHigh, a.RefLow, d.Topography
into #Platelets2013_2018
FROM  src.Chem_PatientLabChem AS A
INNER JOIN #loinc b on  a.Loincsid=b.Loincsid 
LEFT JOIN [CDWWork].[Dim].[topography] AS d ON A.TopographySID =D.TopographySID
	WHERE a.LabChemSpecimenDateTime >= '2013-01-01' and a.LabChemSpecimenDateTime < '2019-01-01'   and a.CohortName='Cohort20210503' 

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
CREATE TABLE sasout.platelet_all_2013_2018 AS 
SELECT  *
	FROM CONNECTION TO TUNNEL ( 
select distinct a.*, b.PatientICN
from #Platelets2013_2018 a
left join Src.SPatient_SPatient b on a.patientsid=b.PatientSID
);

DISCONNECT FROM TUNNEL ;
QUIT ;

/*Step 2 - cleaning */

/*remove duplicate labs by patient, facility, time of specimen and result*/
PROC SORT DATA=sasout.platelet_all_2013_2018 nodupkey; 
BY PatientSID  Sta3n LabChemSpecimenDateTime LabChemResultNumericValue;
RUN;

/*create new date and time variables*/
data platelet_all_2013_2018;
set sasout.platelet_all_2013_2018;
LabSpecimenDate=datepart(LabChemSpecimenDateTime);
LabSpecimenTime=timepart(LabChemSpecimenDateTime);
year=year(LabSpecimenDate);
format LabSpecimenDate mmddyy10.;
format LabSpecimenTime time8.;
keep Sta3n year LabChemTestSID PatientSID LabChemResultValue LabChemResultNumericValue TopographySID LOINCSID Units RefHigh RefLow Topography LabSpecimenDate LabSpecimenTime patienticn;
run;

/*clean up units and create new field: clean_unit*/
data platelet_all_2013_2018;
set platelet_all_2013_2018;
Units2=upcase(units); /*turn all units into uppercase*/
units3=compress(Units2,'.'); /*removes '.' in units*/
clean_unit = compress(units3); /*removes all blanks (by default - specify options to remove other chars)*/
drop units2 units3 units ;
run;

/*change patienticn into numeric*/  
DATA platelet_all_2013_2018 (rename=patienticn2=patienticn);
SET platelet_all_2013_2018;
patienticn2 = input(patienticn, 10.);
year=year(LabSpecimenDate);
drop patienticn;
RUN;

/*check lab value missingness*/

*check which LabChemResultValues not missing when LabChemResultNumericValue is missing;
proc freq data=platelet_all_2013_2018 order=freq;
tables LabChemResultValue;
where LabChemResultValue is not missing and LabChemResultNumericValue is missing;
run;

*don't need to recode any LabChemResultNumericValue's per PI;

*Clean RefHigh and RefLow (reference ranges) variables;
proc freq data=platelet_all_2013_2018 order= freq;
tables RefHigh RefLow;

DATA platelet_all_2013_2018;
SET platelet_all_2013_2018;
RefHigh2=compress(RefHigh,'"'); /*removes '"' */
RefHigh_clean_cat = compress(RefHigh2); /*removes all blanks (by default - specify options to remove other chars)*/

RefLow2=compress(RefLow,'"'); /*removes '"' */
RefLow_clean_cat = compress(RefLow2); /*removes all blanks (by default - specify options to remove other chars)*/
drop RefHigh2 RefLow2 ;
run;

proc freq data=platelet_all_2013_2018 order= freq;
tables RefHigh_clean_cat RefLow_clean_cat;
run; 

*don't need to recode any Ref values per PI;

*remove any characters from Refs and convert to numeric;
*check width and decimal places of numeric values for formatting in next step;
proc freq data=platelet_all_2013_2018 order= freq;
tables RefHigh_clean_cat RefLow_clean_cat;
run; 

*since will be compressing and only keeping digits and decimal points in next data step, need to change this to missing, otherwise 
will convert to a number and this value is to be excluded;
data platelet_all_2013_2018 ;
set platelet_all_2013_2018;
if RefLow_clean_cat = '150-375K/uL' then RefLow_clean_cat = "";
run;

data platelet_all_2013_2018;
set platelet_all_2013_2018;
RefLow_clean2 = compress(RefLow_clean_cat,'.' , 'kd'); *keep digits and decimal points;
RefLow_clean = input(RefLow_clean2, 5.);
RefHigh_clean2 = compress(RefHigh_clean_cat,'.' , 'kd');
RefHigh_clean = input(RefHigh_clean_cat, 5.);
drop RefLow_clean2 RefHigh_clean2;
run;

*Examine Topography and Units and create summary statistics;
proc sort data=platelet_all_2013_2018 ;
by Topography clean_unit;
run;

*create table of summary stats of labs by topography and units;
proc means data=platelet_all_2013_2018 n mean min p10 median p90 max;
class Topography clean_unit;
var LabChemResultNumericValue ;
where LabChemResultNumericValue ne .;
ods output summary=sasout.Lab ;
run;

*create table of summary stats of Refs by topography and units;
proc means data=platelet_all_2013_2018  mean median;
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
sheet = 'Platelets';
run;

*After PI review of labs by topography and units, no unit conversions needed;

*check how many obs before deleting combos of topography and units to make sure correct number of obs after deleting;
proc means data=platelet_all_2013_2018 n mean min p10 median p90 max;
class Topography clean_unit;
var LabChemResultNumericValue ;
where LabChemResultNumericValue ne .;
ods output summary=Lab ;
run;

*create macro lists of topography and units to be excluded;
options source source2 mprint symbolgen mlogic macrogen;

*since list was short did not need to import list as csv;
%let top_p = "BLOOD" "BM ASP.,ILIAC CR." "PLATELET POOR PLASMA" "PLATELET RICH PLASMA" "PPP" "BLOOD";
%let units_p = "%" "K/CMM" "K/CUMM" "K/CMM" "X10(3)/UL" "FL";

*exclude combinations of topography and clean_unit;
%macro exclude;
data platelet_all_2013_2018_v2;
set platelet_all_2013_2018;

%do i=1 %to %sysfunc(countw(&top_p,' ',q));
	%let next1 = %scan(&top_p,&i,' ',q);
	%let next2 = %scan(&units_p,&i,' ',q);

		if topography = &next1 and clean_unit = &next2 then delete;
%end;
run;
%mend exclude;

%exclude

*confirm they are excluded;
proc means data=platelet_all_2013_2018_v2 n mean min p10 median p90 max;
class Topography clean_unit;
var LabChemResultNumericValue ;
where LabChemResultNumericValue ne .;
ods output summary=Lab ;
run;

*apply physiological cutoffs per PIs;
data platelet_all_2013_2018_v2;
set platelet_all_2013_2018_v2;
if LabChemResultNumericValue < 10 or LabChemResultNumericValue > 1500 then delete;
run;

/*Create data set with final lab value per date per patient*/

/*create count var of labs per date per pt in order of latest labs first and 
create final_platelet_daily var*/
data finaldate_plate;
set platelet_all_2013_2018_v2;
run;

proc sort data = finaldate_plate;
by patienticn labspecimendate descending labspecimentime;
run;

data finaldate_plate;
set finaldate_plate;
by patienticn labspecimendate;
 retain n;
 if first.labspecimendate then n=1;
 else n = n+1;

if n = 1 then final_platelet_daily = LabChemResultNumericValue;
 run;

/*create data set only including final platelet labs*/
data sasout.final_platelet_daily_pre;
set finaldate_plate;
where n=1;
run;
