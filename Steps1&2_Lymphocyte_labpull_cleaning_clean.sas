/*/*/*/*/*/*/*/*/*/*/*/*/*/*/*/*/*/*/*/*/*/*/*/*/*/*/*/*/*/*/*/*/*/*/*/*/*/*/*/*/*/*/**/*/*/*/*/*/*/*/*/*/*/*/*/*/*/*/*/*/*/*/*/*/*/*/*/*/*/*/
* 
* Below code will pull lymphocyte labs from CDW using SAS Pass Thru and will save the lymphocyte lab pull table as a SAS dataset for further cleaning.
* This code also creates a final lab value for each patient-day while inpatient.
*
* Date Created: 10/12/2021
* Author: Jennifer Cano (this code is a modified version of Shirley Wang's code)
*
*/*/*/*/*/*/*/*/*/*/*/*/*/*/*/*/*/*/*/*/*/*/*/*/*/*/*/*/*/*/*/*/*/*/*/*/*/*/*/*/*/*/*/**/*/*/*/*/*/*/*/*/*/*/*/*/*/*/*/*/*/*/*/*/*/*/*/*/*/*/*/;

%let DATASRCs= /*insert your data source here*/;
%let studyname= /*insert your study CDW database name here*/;

libname sasout /*'insert file path'*/;

/*Step 1 - pull data from CDW using SAS Pass Thru*/

PROC SQL  ;
CONNECT TO SQLSVR AS TUNNEL (DATASRC=&DATASRCs. &SQL_OPTIMAL. )  ;

/*pull in labchemtestnames to send to PIs for review*/
EXECUTE (
  
  select LOINC, Component, Sta3n, LOINCSID 
  into #tempLOIN  
  from [CDWWork].[Dim].[loinc]
  where loinc in ('732-8','731-0')

)  BY TUNNEL  ;

CREATE TABLE sasout.labchemtests_lymph AS
SELECT  *
  FROM CONNECTION TO TUNNEL ( 
/*pull in labchemtestnames to send to PIs for review*/
SELECT a.LabChemTestSID, a.PatientSID, a.sta3n, a.LabChemSpecimenDateTime, a.LOINCSID,  c.labchemtestname 
FROM  [&studyname].[Src].[Chem_PatientLabChem] AS A
INNER join #tempLOIN as b 
                on a.Loincsid=b.Loincsid 
LEFT JOIN [CDWWork].[Dim].[labchemtest] as c on a.Labchemtestsid=c.Labchemtestsid
WHERE (a.LabChemSpecimenDateTime >= '20130101' AND a.LabChemSpecimenDateTime < '20190101') 
       and (a.LabChemResultNumericValue is NOT NULL)

);

DISCONNECT FROM TUNNEL ;
QUIT ;

/*construct frequency table of labchemtestnames and export to Excel to send to PIs for review*/
proc sort data=sasout.labchemtests_lymph nodupkey;
	by PatientSID labchemtestname LabChemSpecimenDateTime sta3n LOINCSID; 
	run;

ods excel file="insert file path here";
proc freq data=sasout.labchemtests_lymph; 
	table labchemtestname;
run;
ods excel close;

*import LabChemTestNames PI's decided to keep;
proc import datafile="insert file path here"
out= Lymp_LabNames_csv dbms=csv replace;
getnames=yes;
guessingrows=max;
run;

*extract all lab names to create macro list to copy into following code below;
proc sql;
	select catt("'", labchemtestname, "'")
	into :Lymph_LabNames_list separated by ','
	from Lymp_LabNames_csv;
	quit;

%put &Lymph_LabNames_list;

PROC SQL  ;
CONNECT TO SQLSVR AS TUNNEL (DATASRC=&DATASRCs. &SQL_OPTIMAL. )  ;

/*pull in labchemtestnames associated with LOINC codes*/
EXECUTE (
  
  select LOINC, Component, Sta3n, LOINCSID 
  into #loinc   
  from [CDWWork].[Dim].[loinc]
  where loinc in ('732-8','731-0')

)  BY TUNNEL  ;

*pull in labchemtestnames following review from PIs;
EXECUTE (
/*pull in Labchemtest*/
SELECT Labchemtestsid, LabChemTestName, LabChemPrintTestName, Sta3n, 1 as PIselectLabName
into #labtestnames
FROM  [CDWWork].[Dim].[LabChemTest]
WHERE labchemtestname in ('LYMPH #','LY #','LYMPHOCYTES, ABSOLUTE','LY#','ABSOLUTE LYMPHOCYTE COUNT','LYMPH#','ABSOLUTE LYMPHOCYTE COUNT (AUTO)','LYMPHS #','LYMPHS ABSOLUTE#','LYMPHS,ABS (V2)','LYMPHOCYTE #','LYMPH, 
ABS','LYMPHOCYTES # (AUTO)','LYMPHS, ABSOLUTE','ABS LYMPHOCYTE','LYMPHOCYTES (#)','LYMPHOCYTE, ABSOLUTE (5/2/2019)','A LY#','LYMPHS#','LYMPH ABSOLUTE CT.','LYMPHOCYTES ABSOLUTE','LY#3','Lymphocytes 
(AUTO)','LYMPHOCYTE (AUTO)','ABS LYMPH','LYMPH # (SS)','LYMPHOCYTE # (AUTO)','Ly#','LYMPH, ABSOLUTE AUTOMATED','LYMPHOCYTE ABS (AUTO)','ABSOLUTE LYMPH COUNT','A LYMPH #','LYMP# 
(AUTO)','Lymph(10e3)','LYMPHOCYTE NUMBER','LYMPH, ABSOLUTE','LYMPHOCYTE, ABS','LYMPH ABS','ABSOLUTE LYMPH#','TOTAL LYMPHOCYTE','LY# (FV)','LYMPH ABS.','ABSOLUTE LYMPHOCYTES','LYMPH ABSOLUTE','ABS 
LYMPH AUTOMATED','LYMPH #-AUTO--------O','ABS. LYMPHOCYTE COUNT','LYMPH #, ABSOLUTE','LYMPH, ABSOLUTE CT','LYMPH-A','LYMPHS # -','LYMPH-ABSOLUTE','LYMPHOCYTE, ABSOLUTE','LYMPH #(D/C 
5/25/17)','A-LYMPH #','ABSOLUTE LYMPHS(DCed 9-7-21)','LYMPHOCYTES #','Absolute Lymphocytes','LYMPH#(CAL)','LYMPHS ABSOLUTE','ABSOLUTE LYMPHOCYTES # (MANUAL)','LYMPHS','LYMPHOCYTE, ALTERNATE 
ABS','LYMPHS (V2)','LY#AUTO','Lymph, Abs','LYMPH,ABS(TOPC)AUTO','LYMPH # (AUTO)','ABS LYMPHS AUTOMATED (DISCONTINUED)','LY# (FS)*INACT(10/1/2020)','LYMPH #(s)','M LYMPH #','Lymphocytes (Manual)','NEW 
LYMPH, ABSOLUTE','LY# (MV)*INACT(1-1-15)','LYMPHS ABS (DCED 072313)','ABS. LYMPHOCYTE #','LYMPHOCYTE SUM','M LYMPH#','LY#4','P-ABSOLUTE LYMPHS (DC''ed 4720)','TOTAL LYMPHOCYTE 
COUNT','LYMPHOCYTES,ABSOLUTE','LYMP# (MAN DIFF)','LYMPHOCYTES #(M)','Lymphocytes, Abs.','MN LYM#','LYMPHOCYTE COUNT','LYMPHS (ABS)','TOTAL LYMPH COUNT-Q','D-Lymphs (Abs) (dc''d)','PB LYMPH#','ABS 
LYMPH (FCM)','LYMPHOCYTE,ABSOLUTE','LYMPHOCYTES,ABS-WI,CO','W-LYMPHS#','Lymphs, Absolute','ZZLymphocytes,Abs(Dcd)','LY# (HR)*INACT(10-2-18)','abs lymphs, lca','LYMPH#-PR','LYMPHOCYTE ABSOLUTE','TOTAL 
LYMPH CT.','ABSOLUTE LYMPH #','ZMH ABSOLUTE LYMPH BEFORE 1/28/14','BR-LY# AUTO','ABS LYMPH (V1FC)','LYMPHOCYTES, ABSOLUTE(M)','ABSOLUTE LYMPHOCYTE','LYMPHOCYTES 
ABSOLUTE,blood','ABS.LYMPHS/uL','Lymphocytes, Absolute','LYMPHOCYTES, ABSOLUTE(79248)','TOTAL LYMPHS','LYMPHS#(BMT)','ELD LY#','LRL LYMPHOCYTE ABSOLUTE','ABSOLUTE LYMPH','Lymphocyte 
Absolutes','ZZZLYMPHS ABSOLUTE (LC)','LYMPHS ABS -','ABS.LYMPHS WR','LYMPHS (ABSOLUTE)','LYMPHS ABS (LABCORP)','(IDM) LYMPH ABSOL','NO. LYMPH','ABS LYMPH (BOS)','LYMPHOCYTES, TOTAL','LYMPHS, ABSOLUTE 
COUNT','ABS LYMPH (b)','LEG LYM#','(STRONG) LYMPH ABSOL','(FFTH) ABS,LYMPHOCYTE','ABS LYMPHS (LSA)','_LYMPHOCYTE, ABSOLUTE','POC LY#','LYMPHOCYTES, ABSOLUTE -','Lymphocyte Absolute (CDH)','#LYM 
(NMMC)','TAMC LYMPH#','LYMPHS ABS. (LC)','.LYMPH ABSOLUTE','Lymphocytes, Absolute (Quest)','LYMPHOCYTES # (MANUAL)','LYMPHOCYTES-SO','LYMPHOCYTES','LYMPHS#(LABCORP)','ZZ-LYMPHOCYTES# QUEST(CBC)','ABS 
LYMPH MANUAL','Lymphocytes Absolute SPL','ABS# LYMPHOCYTES','.LYMPH#','#LYMPHS (PB)','LYMPHS,ABSOLUTE(Fee Basis)','MV-LYMPH #','.LYMPH ABS (NON-VA)','ZZ-LYMPHS(ABSOLUTE)LCA','.LYMPHS 
#-TMCB','LYMPHOCYTES, ABSOLUTE*ne','.LYMPHS (ABSOLUTE)','LYMPHS-ABS(CD PANEL)','zzz ABSOLUTE LYMPHOCYTE COUNT','ABS.LYMPHOCYTE (RFGH)','ZZ-ABS LYMPHS/uL','LYMPH,ABS d/c','LYMPH 
(ABSOLUTE)','Lymph','#LYM (NORDx)','.ABSOLUTE LYMPHOCYTE','LYMPH#-OML','LYMPHOCYTE (CV)','LYMPH','.LYMPH ABS (OTHER VA)','LY#2 Dc''d','LYMPH # (<11/01/2017)','LYMPH 
(BERK)','LYMPH#(SPHEM)-BK','_LYMPHS#-MANUAL')
) BY TUNNEL;

EXECUTE (
/*pull loincsids and labchemtestsids from CDW for 2013-2018*/
SELECT distinct a.LabChemSID, a.LabSubjectSID,  a.Sta3n, a.LabPanelIEN, a.LabPanelSID, a.LongAccessionNumberUID, a.ShortAccessionNumber,
       a.LabChemTestSID, a.PatientSID, a.LabChemSpecimenDateTime, a.LabChemSpecimenDateSID, a.LabChemCompleteDateTime, a.LabChemCompleteDateSID,
       a.LabChemResultValue, a.LabChemResultNumericValue, a.TopographySID, a.LOINCSID, a.Units, a.RefHigh, a.RefLow, d.Topography
into #Lymphocyte2013_2018
FROM  src.Chem_PatientLabChem AS A
INNER JOIN #loinc b on  a.Loincsid=b.Loincsid 
LEFT JOIN [CDWWork].[Dim].[topography] AS d ON A.TopographySID =D.TopographySID
	WHERE a.LabChemSpecimenDateTime >= '2013-01-01' and a.LabChemSpecimenDateTime < '2019-01-01' and a.CohortName='Cohort20210503' 

UNION

SELECT distinct a.LabChemSID, a.LabSubjectSID,  a.Sta3n, a.LabPanelIEN, a.LabPanelSID, a.LongAccessionNumberUID, a.ShortAccessionNumber,
       a.LabChemTestSID, a.PatientSID, a.LabChemSpecimenDateTime, a.LabChemSpecimenDateSID, a.LabChemCompleteDateTime, a.LabChemCompleteDateSID,
       a.LabChemResultValue, a.LabChemResultNumericValue, a.TopographySID, a.LOINCSID, a.Units, a.RefHigh, a.RefLow, d.Topography
FROM src.Chem_PatientLabChem a         
INNER JOIN #labtestnames b ON a.labchemtestsid=b.labchemtestsid 
LEFT JOIN [CDWWork].[Dim].[topography] AS d ON A.TopographySID =D.TopographySID
     WHERE a.LabChemSpecimenDateTime >= '2013-01-01' and a.LabChemSpecimenDateTime < '2019-01-01' and a.CohortName='Cohort20210503' 
) BY TUNNEL;

/*get unique PatientICN and save table as SAS data set*/
CREATE TABLE sasout.lymphocyte_2013_2018 AS 
SELECT  *
	FROM CONNECTION TO TUNNEL ( 
select distinct a.*, b.PatientICN
from #Lymphocyte2013_2018 a
left join Src.SPatient_SPatient b on a.patientsid=b.PatientSID
);

DISCONNECT FROM TUNNEL ;
QUIT ;


/*Step 2 - cleaning */

/*remove duplicate labs by patient, facility, time of specimen and result*/
PROC SORT DATA=sasout.lymphocyte_2013_2018 nodupkey; 
BY PatientSID  Sta3n LabChemSpecimenDateTime LabChemResultNumericValue;
RUN;

/*create new date and time variables*/
data lymphocyte_2013_2018;
set sasout.lymphocyte_2013_2018;
LabSpecimenDate=datepart(LabChemSpecimenDateTime);
LabSpecimenTime=timepart(LabChemSpecimenDateTime);
year=year(LabSpecimenDate);
format LabSpecimenDate mmddyy10.;
format LabSpecimenTime time8.;
keep Sta3n year LabChemTestSID PatientSID LabChemResultValue LabChemResultNumericValue TopographySID LOINCSID Units RefHigh RefLow Topography LabSpecimenDate LabSpecimenTime patienticn;
run;

/*clean up units and create new field: clean_unit*/
data lymphocyte_2013_2018;
set lymphocyte_2013_2018;
Units2=upcase(units); /*turn all units into uppercase*/
units3=compress(Units2,'.'); /*removes '.' in units*/
clean_unit = compress(units3); /*removes all blanks (by default - specify options to remove other chars)*/
drop units2 units3 units ;
run;

/*change patienticn into numeric*/  
DATA lymphocyte_2013_2018 (rename=patienticn2=patienticn);
SET lymphocyte_2013_2018;
patienticn2 = input(patienticn, 10.);
year=year(LabSpecimenDate);
drop patienticn;
RUN;

/*check lab value missingness*/

*check which LabChemResultValues not missing when LabChemResultNumericValue is missing;
proc freq data=lymphocyte_2013_2018 order=freq;
tables LabChemResultValue;
where LabChemResultValue is not missing and LabChemResultNumericValue is missing;
run;

*don't need to recode any LabChemResultNumericValue's per PI;

*Clean RefHigh and RefLow (reference ranges) variables;
proc freq data=lymphocyte_2013_2018 order= freq;
tables RefHigh RefLow;

DATA lymphocyte_2013_2018;
SET lymphocyte_2013_2018;
RefHigh2=compress(RefHigh,'"'); /*removes '"' */
RefHigh_clean_cat = compress(RefHigh2); /*removes all blanks (by default - specify options to remove other chars)*/

RefLow2=compress(RefLow,'"'); /*removes '"' */
RefLow_clean_cat = compress(RefLow2); /*removes all blanks (by default - specify options to remove other chars)*/
drop RefHigh2 RefLow2 ;
run;

proc freq data=lymphocyte_2013_2018 order= freq;
tables RefHigh_clean_cat RefLow_clean_cat;
run;

*don't need to recode any Ref values per PI;

*check width and decimal places of numeric values for formatting in next step;
proc freq data=lymphocyte_2013_2018  order= freq;
tables RefLow_clean_cat RefHigh_clean_cat;
run; 

*since will be compressing and only keeping digits and decimal points in next data step, need to change this to missing, otherwise 
will convert to a number and these values are to be excluded;
data lymphocyte_2013_2018 ;
set lymphocyte_2013_2018;
if RefLow_clean_cat = '0.8-5.0K/uL' then RefLow_clean_cat = "";
if RefHigh_clean_cat = '850-3900' then RefHigh_clean_cat = "";
run;

*remove any characters from Refs and convert to numeric;
data lymphocyte_2013_2018;
set lymphocyte_2013_2018 ;
RefLow_clean2 = compress(RefLow_clean_cat,'.' , 'kd'); *keep digits and decimal points;
RefLow_clean = input(RefLow_clean2, 5.);
RefHigh_clean2 = compress(RefHigh_clean_cat,'.' , 'kd');
RefHigh_clean = input(RefHigh_clean_cat, 4.);
drop RefLow_clean2 RefHigh_clean2;
run;

*Examine Topography and Units and create summary statistics;
proc sort data=lymphocyte_2013_2018 ;
by Topography clean_unit;
run;

*create table of summary stats of labs by topography and units;
proc means data=lymphocyte_2013_2018 n mean min p10 median p90 max;
class Topography clean_unit;
var LabChemResultNumericValue ;
where LabChemResultNumericValue ne .;
ods output summary=sasout.Lab ;
run;

*create table of summary stats of Refs by topography and units;
proc means data=lymphocyte_2013_2018  mean median;
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
sheet = 'Lymphocyte';
run;

*After PI review of labs by topography and units, several unit conversions needed;

*3 units include quotation marks - need to remove because 'exclude' macro not running;
data lymphocyte_2013_2018;
set lymphocyte_2013_2018;
clean_unit=compress(clean_unit,'"'); /*removes '"' in units*/
run;

*check how many obs before deleting combos of topography and units to make sure correct number of obs after deleting;
proc means data=lymphocyte_2013_2018 n mean min p10 median p90 max;
class Topography clean_unit;
var LabChemResultNumericValue ;
where LabChemResultNumericValue ne .;
ods output summary=Lab ;
run;

*create macro lists of topography and units to be excluded;
options source source2 mprint symbolgen mlogic macrogen;

proc import datafile="insert file path"
out= names dbms=csv replace;
getnames=yes;
guessingrows=max;
run;
*extract all values to create macro list to exclude combos of topography and units;
proc sql;
	select catt('"', Topography, '"')
	into :top_l separated by ' '
	from names;
	select catt('"', clean_unit, '"')
	into :units_l separated by ' '
	from names;
	quit;
%put &top_l;
%put &units_l;

*exclude combinations of topography and clean_unit;
%macro exclude;
data lymphocyte_2013_2018;
set lymphocyte_2013_2018;

%do i=1 %to %sysfunc(countw(&top_l,' ',q));
	%let next1 = %scan(&top_l,&i,' ',q);
	%let next2 = %scan(&units_l,&i,' ',q);

		if topography = &next1 and clean_unit = &next2 then delete;
%end;
run;
%mend exclude;

%exclude

*confirm they are excluded;
proc means data=lymphocyte_2013_2018 n mean min p10 median p90 max;
class Topography clean_unit;
var LabChemResultNumericValue ;
where LabChemResultNumericValue ne .;
ods output summary=Lab ;
run;

*import units list for conversions;
proc import datafile="insert file path"
out= units_csv dbms=csv replace;
getnames=yes;
guessingrows=max;
run;
*extract units to create macro list to copy into following code;
proc sql;
	select catt("'", unit, "'")
	into :units_list separated by ','
	from units_csv;
	quit;

%put &units_list;

*convert units;
data lymphocyte_2013_2018_v2;
set lymphocyte_2013_2018;
*convert units;
if topography = 'BLOOD' and clean_unit in (
'/UL','CELLS/UL','CELLS/CMM','#/CUMM','10E6/L','#/CMM','UL','CMM','COUNT/MM3','CELLS/MCL','WBC/UL','CELL/UL',
'850-3900','/CUMM','CELLS/ML','850','CELLE/UL','CELLS/L','CELLS/U/L','PERCCM','PERCMM','1780','CELLES/UL','CELLS//UL',
'CELLS/YL','CELLSU/L','CELLSUL','CESSL/UL') then LabChemResultNumericValue = LabChemResultNumericValue/1000;
if topography = 'Blood' and clean_unit = 'CELLS/UL' then LabChemResultNumericValue = LabChemResultNumericValue/1000;
if topography = 'PLASMA' and clean_unit in ('CELLS/UL', 'CMM', 'U/L', '/UL') then LabChemResultNumericValue = LabChemResultNumericValue/1000;
if topography = 'WHOLE BLOOD' and clean_unit = 'CELLS/UL' then LabChemResultNumericValue = LabChemResultNumericValue/1000;
*edit units;
if topography = 'BLOOD' and clean_unit in (
'/UL','CELLS/UL','CELLS/CMM','#/CUMM','10E6/L','#/CMM','UL','CMM','COUNT/MM3','CELLS/MCL','WBC/UL','CELL/UL',
'850-3900','/CUMM','CELLS/ML','850','CELLE/UL','CELLS/L','CELLS/U/L','PERCCM','PERCMM','1780','CELLES/UL','CELLS//UL',
'CELLS/YL','CELLSU/L','CELLSUL','CESSL/UL') then clean_unit = 'K/UL';
if topography = 'Blood' and clean_unit = 'CELLS/UL' then clean_unit = 'K/UL';
if topography = 'PLASMA' and clean_unit in ('CELLS/UL', 'CMM', 'U/L', '/UL') then clean_unit = 'K/UL';
if topography = 'WHOLE BLOOD' and clean_unit = 'CELLS/UL' then clean_unit = 'K/UL';
run;

*apply physiological cutoffs per PIs;
data lymphocyte_2013_2018_v2;
set lymphocyte_2013_2018_v2;
if LabChemResultNumericValue < 0 or LabChemResultNumericValue > 300 then delete;
run;

/*Create data set with final lab value per date per patient*/

/*create count var of labs per date per pt in order of latest labs first and 
create final_lymph_daily var*/
data finaldate_lymph;
set lymphocyte_2013_2018_v2;
run;

proc sort data = finaldate_lymph;
by patienticn labspecimendate descending labspecimentime;
run;

data finaldate_lymph;
set finaldate_lymph;
by patienticn labspecimendate;
 retain n;
 if first.labspecimendate then n=1;
 else n = n+1;

if n = 1 then final_lymph_daily = LabChemResultNumericValue;
 run;

/*create data set only including final platelet labs*/
data sasout.final_lymph_daily_2013_2018;
set finaldate_lymph;
where n=1;
run;
