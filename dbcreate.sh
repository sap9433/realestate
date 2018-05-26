#!/bin/bash
echo 'Download all 4 csvs in your download folder and rename them as assessments.csv,liens.csv,foreclosure.csv, violations.csv'
assesments=~/Downloads/assessments.csv
liens=~/Downloads/liens.csv
foreclosure=~/Downloads/foreclosure.csv
violations=~/Downloads/violations.csv

echo 'Successfully started DB update. Hope you updated CSV paths before running me.'

touch ~/Downloads/realdb.db
sqlite3 ~/Downloads/realdb.db <<EOF
.header on
.mode csv
.import  $assesments assesments
.import  $liens liens
.import  $foreclosure foreclosure
.import  $violations violations

CREATE INDEX ass_PARID
ON assesments (PARID);

drop view lv_outer_join_f;
drop view l_outer_join_v;

Create View l_outer_join_v as
select distinct(PIN) as PIN ,BLOCK_LOT,FILING_DATE,DTD,LIEN_DESCRIPTION, WARD,LAST_DOCKET_ENTRY,AMOUNT,TAX_YEAR,SATISFIED,
INSPECTION_DATE,INSPECTION_RESULT,VIOLATION,LOCATION,NEIGHBORHOOD from (select PIN,BLOCK_LOT,FILING_DATE,DTD,LIEN_DESCRIPTION,l.WARD as WARD,LAST_DOCKET_ENTRY,l.AMOUNT as AMOUNT,TAX_YEAR,SATISFIED,
INSPECTION_DATE,INSPECTION_RESULT,VIOLATION,LOCATION,NEIGHBORHOOD
from `liens` as l LEFT OUTER JOIN `violations` as v on l.pin = v.parcel
UNION ALL 
select PIN,BLOCK_LOT,FILING_DATE,DTD,LIEN_DESCRIPTION,l.WARD as WARD,LAST_DOCKET_ENTRY,l.AMOUNT as AMOUNT,TAX_YEAR,SATISFIED,
INSPECTION_DATE,INSPECTION_RESULT,VIOLATION,LOCATION,NEIGHBORHOOD
from `violations` as v LEFT OUTER JOIN `liens` as l on l.pin = v.parcel) order by FILING_DATE ASC,INSPECTION_DATE ASC;



Create View lv_outer_join_f as
select distinct(PIN) as PIN,f_filing_date,`case_id`,`docket_type`,f_amount,`plaintiff`,
	BLOCK_LOT,FILING_DATE,DTD,LIEN_DESCRIPTION,WARD,LAST_DOCKET_ENTRY,AMOUNT,TAX_YEAR,SATISFIED,
INSPECTION_DATE,INSPECTION_RESULT,VIOLATION,LOCATION,NEIGHBORHOOD from
(select f.pin as pin,f.filing_date as f_filing_date,`case_id`,`docket_type`,f.amount as f_amount,`plaintiff`,
	lv.BLOCK_LOT as BLOCK_LOT,lv.FILING_DATE as FILING_DATE,DTD,LIEN_DESCRIPTION,lv.ward as WARD,LAST_DOCKET_ENTRY,lv.AMOUNT as AMOUNT,TAX_YEAR,SATISFIED,
INSPECTION_DATE,INSPECTION_RESULT,VIOLATION,LOCATION,NEIGHBORHOOD
from l_outer_join_v as lv LEFT OUTER JOIN `foreclosure` as f on f.pin = lv.pin 
UNION ALL
select f.pin as pin,f.filing_date as f_filing_date,`case_id`,`docket_type`,f.amount as f_amount,`plaintiff`,
	lv.BLOCK_LOT as BLOCK_LOT,lv.FILING_DATE as FILING_DATE,DTD,LIEN_DESCRIPTION,lv.ward as WARD,LAST_DOCKET_ENTRY,lv.AMOUNT as AMOUNT,TAX_YEAR,SATISFIED,
INSPECTION_DATE,INSPECTION_RESULT,VIOLATION,LOCATION,NEIGHBORHOOD
from `foreclosure` as f LEFT OUTER JOIN l_outer_join_v as lv on f.pin = lv.pin) order by f_filing_date ASC;

create table composed as select PARID,PROPERTYHOUSENUM,PROPERTYFRACTION,PROPERTYADDRESS,PROPERTYCITY,PROPERTYSTATE,PROPERTYUNIT,PROPERTYZIP,OWNERDESC,CLASSDESC,USEDESC,
RECORDDATE,SALEDATE	,SALEPRICE,SALEDESC,PREVSALEDATE,PREVSALEPRICE,FAIRMARKETTOTAL,STORIES,YEARBLT,EXTFINISH_DESC,GRADEDESC,TOTALROOMS,BEDROOMS,
FULLBATHS,HALFBATHS,FINISHEDLIVINGAREA,
f_filing_date as `filing_date:1`,`case_id`,`docket_type`,f_amount as `amount:1`,`plaintiff`,BLOCK_LOT,FILING_DATE,DTD,LIEN_DESCRIPTION,ward,LAST_DOCKET_ENTRY,AMOUNT,TAX_YEAR,
SATISFIED,INSPECTION_DATE,INSPECTION_RESULT,VIOLATION,LOCATION,NEIGHBORHOOD
from `assesments` as a JOIN lv_outer_join_f as lvf on lvf.pin = a.PARID;
EOF

echo 'Successfully update DB. Now manually execute-  sudo mv ~/Downloads/realdb.db /usr/local/realdb.db'