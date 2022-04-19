/*/*/*/*/*/*/*/*/*/*/*/*/*/*/*/*/*/*/*/*/*/*/*/*/*/*/*/*/*/*/*/*/*/*/*/*/*/*/*/*/*/*/**/*/*/*/*/*/*/*/*/*/*/*/*/*/*/*/*/*/*/*/*/*/*/*/*/*/*/*/
* 
* Below code will pull neutrophil labs from CDW using SAS Pass Thru and will save the neutrophil lab pull table as a SAS dataset for further cleaning.
* This code also creates a final lab value for each patient-day while inpatient.
*
* Date Created: 10/21/2021
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
  where loinc in ('26499-4','753-4','751-8','752-6', '35003-3')

)  BY TUNNEL  ;

CREATE TABLE sasout.labchemtests_neut AS
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
proc sort data=sasout.labchemtests_neut nodupkey;
	by PatientSID labchemtestname LabChemSpecimenDateTime sta3n LOINCSID; 
	run;

ods excel file="insert file path here";
proc freq data=sasout.labchemtests_neut; 
	table labchemtestname;
run;
ods excel close;

*import LabChemTestNames PI's decided to keep;
proc import datafile="insert file path here"
out= Neut_LabNames_csv dbms=csv replace;
getnames=yes;
guessingrows=max;
run;

*extract all lab names to create macro list to copy into following code below;
proc sql;
	select catt("'", labchemtestname, "'")
	into :Neut_LabNames_list separated by ','
	from Neut_LabNames_csv;
	quit;

%put &Neut_LabNames_list;

PROC SQL  ;
CONNECT TO SQLSVR AS TUNNEL (DATASRC=&DATASRCs. &SQL_OPTIMAL. )  ;

/*pull in labchemtestnames associated with LOINC codes*/
EXECUTE (

  select LOINC, Component, Sta3n, LOINCSID 
  into #loinc   
  from [CDWWork].[Dim].[loinc]
  where loinc in ('26499-4','753-4','751-8','752-6', '35003-3')

)  BY TUNNEL  ;

*pull in labchemtestnames following review from PIs;
EXECUTE (
/*pull in Labchemtest*/
SELECT Labchemtestsid, LabChemTestName, LabChemPrintTestName, Sta3n, 1 as PIselectLabName
into #labtestnames
FROM  [CDWWork].[Dim].[LabChemTest]
WHERE labchemtestname in ('NEUT #','ABSOLUTE NEUTROPHIL COUNT','NEUTROPHILS, ABSOLUTE','NE#','NEUT#','NEUTROPHIL #','ABSOLUTE NEUTROPHIL COUNT (AUTO)','NE #','NEUTROPHIL, ALTERNATE ABS','SEGS ABSOLUTE#','NEUTRO 
#','NEUTROPHILS,ABS (V2)','NEUTROPHIL, ABSOLUTE','NEUT ABS','NEUTROPHILS # (AUTO)','ABS NEUTROPHIL','NEUTROPHIL (#)','NEUTROPHIL, ABSOLUTE (5/2/2019)','NEUTRO ABSOLUTE CT.','NE#3','NEUT, 
ABS','Neutrophils (AUTO)','NEUTR #','NEUTROPHILS#','NEUTROPHIL # (AUTO)','Ne#','NEUTROPHIL, ABSOLUTE AUTOMATED','NE(10e3)','A NEUT #','NEUT# (AUTO)','NEUTROPHIL NUMBER','ABS 
NEUT','NEUTROPHIL,ABSOLUTE','TOTAL NEUTROPHIL','NE# (FV)','NEUT ABS.','NEUTROPHIL#','NEUTRO ABSOLUTE','ABS NEUT AUTOMATED','ABS. NEUTROPHIL COUNT','NEUTROPHIL #, ABSOLUTE','NEUTROPHIL-A','NEUTROPHIL 
ABS','NEUTROPHILS # -','NEUT-ABSOLUTE','NEUTRO #(D/C 5/25/17)','ABSOLUTE NEUTROPHILS(DCed 9-7-21)','NEUT ABSOLUTE CT','NEUTROPHILS ABSOLUTE','NEUTROPHILS #','ABSOLUTE NEUT COUNT','Absolute 
Neutrophils','NEUTROPHIL ABSOLUTE','ANC','NEUTROPHIL','ABSOLUTE NEUTROPHILS','ABSOLUTE NEUTROPHIL','NEUTRO#','ABS.NEUTROPHIL CT.(dc''d 061620)','Neut, Abs','ABSOLUTE POLY','NEUTRO,ABS(TOPC)AUTO','ANC 
#','NEUTRO # (AUTO)','NE# (FS)*INACT(10/1/2020)','NE# (MV)*INACT(1-1-15)','NEUT ABS (DCED 072313)','NE#4','Absolute Neutrophil Count','P-ABSOLUTE NEUTROPHILS (DC''ed 4720)','NEUTRO ABSOLUTE 
CT(WAM)','NEUTROPHILS, ABSOLUTE(M)','NEUTROPHIL, ABS','NEUTROPHILS #(M)','NEUT-ABS (BLOOD)','PB NEUT#','NEUT,ABS (DIFF)','W-NEUTROPHIL#','P-NEUTROPHIL (DC''ed 4820)','NEUTRO ABSOLUTE 
CALCULATED(WAM)','abs neutrophils, lca','ZMH ABSOLUTE NEUT BEFORE 1/28/14','D-Neutrophil (Abs) (dc''d)','ABS. NEUT CT(I)','MANUAL ABSOLUTE NEUTROPHIL COUNT*NE','NEUTROPHILS (ABS) (LABCORP)','NEUT ABS 
(LC) -','ABS NEUTROPHIL COUNT','ABS NEUTROPHIL MANUAL','SEGS+BANDS ABS','(IDM) NEUT ABSOL','ABSOLUTE NEUTROPHIL COUNT (man)','zzz ABSOLUTE NEUTROPHIL COUNT','LEG NEU#','(STRONG) NEUT ABSOL','(FFTH) 
ABS,NEUTROPHIL','Neutrophil Absolute (CDH)','#NEU (NMMC)','TAMC NEU#','.NEUTRO ABSOLUTE','NEUTROPHILS#(LABCORP)','COOK NE#','POC-NEUT,ABS','ZZ-NEUTROPHILS# QUEST(CBC)','ANC 
(Non-CAV)','NICL-NEUTROPHILS, ABS','.NEUT#','MANUAL ANC','NEUTROPHILS,ABSOLUTE(Fee Basis)','SALEM #NEUTROPHILS-PB','.NEUT ABS (NON-VA)','MV-NEUTRO #','NEUT # (<11/01/2017)','NEUT 
#-MANUAL-------O','ZZ-NEUTROPHILS(ABSOLUTE)-LCA','.NEUT #-TMCB','POLYNUCLEAR','.NEUTROPHILS (ABSOLUTE)','NEUT-ABSOLUTE(CD PANEL)','PMN''S','ABS.NEUTROPHIL (RFGH)','NEUT.# (MIDCOAST)','NEUT,ABS 
d/c','NE#2','#NEUT (NORDx)','.ABSOLUTE NEUTROPHIL','.NEUT ABS (OTHER VA)','ABS. NEUT (non-VA)','ABSOLUTE NEUTROPHILS(DLS)','NEUTRO#-OML','MAIL ABS NEUT-CO','NEUTROPHIL# (MCM)','NEUTROPHILS #, FLUID 
(AUTO)','PMN#','POLY N (BERK)','XNEUT,ABS','_NEUT#-MANUAL')
) BY TUNNEL;

EXECUTE (
/*pull loincsids and labchemtestsids from CDW for 2013-2018*/
SELECT distinct a.LabChemSID, a.LabSubjectSID,  a.Sta3n, a.LabPanelIEN, a.LabPanelSID, a.LongAccessionNumberUID, a.ShortAccessionNumber,
       a.LabChemTestSID, a.PatientSID, a.LabChemSpecimenDateTime, a.LabChemSpecimenDateSID, a.LabChemCompleteDateTime, a.LabChemCompleteDateSID,
       a.LabChemResultValue, a.LabChemResultNumericValue, a.TopographySID, a.LOINCSID, a.Units, a.RefHigh, a.RefLow, d.Topography
into #Neutrophil2013_2018
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
CREATE TABLE sasout.neutrophil_2013_2018 AS 
SELECT  *
	FROM CONNECTION TO TUNNEL ( 
select distinct a.*, b.PatientICN
from #Neutrophil2013_2018 a
left join Src.SPatient_SPatient b on a.patientsid=b.PatientSID
);

DISCONNECT FROM TUNNEL ;
QUIT ;


/*Step 2 - cleaning */

/*remove duplicate labs by patient, facility, time of specimen and result*/
PROC SORT DATA=sasout.neutrophil_2013_2018 nodupkey; 
BY PatientSID  Sta3n LabChemSpecimenDateTime LabChemResultNumericValue;
RUN;

/*create new date and time variables*/
data neutrophil_2013_2018;
set sasout.neutrophil_2013_2018;
LabSpecimenDate=datepart(LabChemSpecimenDateTime);
LabSpecimenTime=timepart(LabChemSpecimenDateTime);
year=year(LabSpecimenDate);
format LabSpecimenDate mmddyy10.;
format LabSpecimenTime time8.;
keep Sta3n year LabChemTestSID PatientSID LabChemResultValue LabChemResultNumericValue TopographySID LOINCSID Units RefHigh RefLow Topography LabSpecimenDate LabSpecimenTime patienticn;
run;

/*clean up units and create new field: clean_unit*/
data neutrophil_2013_2018;
set neutrophil_2013_2018;
Units2=upcase(units); /*turn all units into uppercase*/
units3=compress(Units2,'.'); /*removes '.' in units*/
clean_unit = compress(units3); /*removes all blanks (by default - specify options to remove other chars)*/
drop units2 units3 units ;
run;

/*change patienticn into numeric*/  
DATA neutrophil_2013_2018 (rename=patienticn2=patienticn);
SET neutrophil_2013_2018;
patienticn2 = input(patienticn, 10.);
year=year(LabSpecimenDate);
drop patienticn;
RUN;

/*check lab value missingness*/

*check which LabChemResultValues not missing when LabChemResultNumericValue is missing;
proc freq data=neutrophil_2013_2018 order=freq;
tables LabChemResultValue;
where LabChemResultValue is not missing and LabChemResultNumericValue is missing;
run;

*don't need to recode any LabChemResultNumericValue's per PI;

*Clean RefHigh and RefLow (reference ranges) variables;
proc freq data=neutrophil_2013_2018 order= freq;
tables RefHigh RefLow;

DATA neutrophil_2013_2018;
SET neutrophil_2013_2018;
RefHigh2=compress(RefHigh,'"'); /*removes '"' */
RefHigh_clean_cat = compress(RefHigh2); /*removes all blanks (by default - specify options to remove other chars)*/

RefLow2=compress(RefLow,'"'); /*removes '"' */
RefLow_clean_cat = compress(RefLow2); /*removes all blanks (by default - specify options to remove other chars)*/
drop RefHigh2 RefLow2 ;
run;

proc freq data=neutrophil_2013_2018 order= freq;
tables RefHigh_clean_cat RefLow_clean_cat;
run; 

*don't need to recode any Ref values per PI;

*check width and decimal places of numeric values for formatting in next step;
proc freq data=neutrophil_2013_2018 order= freq;
tables RefLow_clean_cat RefHigh_clean_cat;
run; 

*since will be compressing and only keeping digits and decimal points in next data step, need to change this to missing, otherwise 
will convert to a number and these values are to be excluded;
data neutrophil_2013_2018 ;
set neutrophil_2013_2018;
if RefHigh_clean_cat = '<25%' then RefHigh_clean_cat = "";
if RefHigh_clean_cat = '<3%' then RefHigh_clean_cat = "";
run;

*remove any characters from Refs and convert to numeric;
data neutrophil_2013_2018;
set neutrophil_2013_2018 ;
RefLow_clean2 = compress(RefLow_clean_cat,'.' , 'kd'); *keep digits and decimal points;
RefLow_clean = input(RefLow_clean2, 4.);
RefHigh_clean2 = compress(RefHigh_clean_cat,'.' , 'kd');
RefHigh_clean = input(RefHigh_clean_cat, 5.);
drop RefLow_clean2 RefHigh_clean2;
run;

*Examine Topography and Units and create summary statistics;
proc sort data=neutrophil_2013_2018 ;
by Topography clean_unit;
run;

*create table of summary stats of labs by topography and units;
proc means data=neutrophil_2013_2018 n mean min p10 median p90 max;
class Topography clean_unit;
var LabChemResultNumericValue ;
where LabChemResultNumericValue ne .;
ods output summary=sasout.Lab ;
run;

*create table of summary stats of Refs by topography and units;
proc means data=neutrophil_2013_2018  mean median;
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
sheet = 'Neutrophil';
run;

*After PI review of labs by topography and units, several unit conversions needed;

*2 units include quotation marks - need to remove because 'exclude' macro not running;
data neutrophil_2013_2018;
set neutrophil_2013_2018;
clean_unit=compress(clean_unit,'"'); /*removes '"' in units*/
run;

*check how many obs before deleting combos of topography and units to make sure correct number of obs after deleting;
proc means data=neutrophil_2013_2018 n mean min p10 median p90 max;
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
	into :top_n separated by ' '
	from names;
	select catt('"', clean_unit, '"')
	into :units_n separated by ' '
	from names;
	quit;
%put &top_n;
%put &units_n;

*exclude combinations of topography and clean_unit;
%macro exclude;
data neutrophil_2013_2018_v2;
set neutrophil_2013_2018;

%do i=1 %to %sysfunc(countw(&top_n,' ',q));
	%let next1 = %scan(&top_n,&i,' ',q);
	%let next2 = %scan(&units_n,&i,' ',q);

		if topography = &next1 and clean_unit = &next2 then delete;
%end;
run;
%mend exclude;

%exclude

*confirm they are excluded;
proc means data=neutrophil_2013_2018_v2 n mean min p10 median p90 max;
class Topography clean_unit;
var LabChemResultNumericValue ;
where LabChemResultNumericValue ne .;
ods output summary=Lab ;
run;

*convert and edit units;
data neutrophil_2013_2018_v2;
set neutrophil_2013_2018_v2;
*convert units;
if topography = 'BLOOD' and clean_unit in ('/UL','CELLS/UL','CMM','UL','CELL/UL','CELLS/MCL','X10((9)/ML') 
then LabChemResultNumericValue = LabChemResultNumericValue/1000;
*edit units;
if topography = 'BLOOD' and clean_unit in ('/UL','CELLS/UL','CMM','UL','CELL/UL','CELLS/MCL','X10((9)/ML') 
then clean_unit = 'K/UL';
run;

*apply physiological cutoffs per PIs;
data neutrophil_2013_2018_v2;
set neutrophil_2013_2018_v2;
if LabChemResultNumericValue < 0 or LabChemResultNumericValue > 300 then delete;
run;

/*Create data set with final lab value per date per patient*/

/*create count var of labs per date per pt in order of latest labs first and 
create final_neut_daily var*/
data finaldate_neut;
set neutrophil_2013_2018_v2;
run;

proc sort data = finaldate_neut;
by patienticn labspecimendate descending labspecimentime;
run;

data finaldate_neut;
set finaldate_neut;
by patienticn labspecimendate;
 retain n;
 if first.labspecimendate then n=1;
 else n = n+1;

if n = 1 then final_neut_daily = LabChemResultNumericValue;
 run;

/*create data set only including final neutrophil labs*/
data sasout.final_neut_daily_2013_2018;
set finaldate_neut;
where n=1;
run;

