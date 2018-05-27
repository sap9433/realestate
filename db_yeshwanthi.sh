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

create table composed as
select 
A.PARID as PARID, 
PROPERTYHOUSENUM,
PROPERTYFRACTION,
PROPERTYADDRESS,
PROPERTYCITY,
PROPERTYSTATE,
PROPERTYUNIT,
PROPERTYZIP,
WARD,
BLOCK_LOT,
max(A.F_Filing_Date) as \`filing_date:1\`,
case_id,
docket_type,
F_amount as  \`amount:1\`,                 
plaintiff,
max(A.L_FILING_DATE) as FILING_DATE,
DTD,
LIEN_DESCRIPTION,
LAST_DOCKET_ENTRY,
L_AMOUNT as AMOUNT,
TAX_YEAR,
SATISFIED,
max(A.INSPECTION_DATE) as INSPECTION_DATE,
INSPECTION_RESULT,
VIOLATION,
LOCATION,
NEIGHBORHOOD,
OWNERDESC,
CLASSDESC,
USEDESC,
SALEDATE,
SALEPRICE,
SALEDESC,
PREVSALEDATE,
PREVSALEPRICE,
STORIES,
YEARBLT,
EXTFINISH_DESC,
GRADEDESC,
TOTALROOMS,
BEDROOMS,
FULLBATHS,
HALFBATHS,
FINISHEDLIVINGAREA
from
(select
A.PARID,coalesce(F.filing_date,'NA') As F_Filing_Date,
coalesce(L.FILING_DATE ,'NA') AS L_FILING_DATE,
coalesce(INSPECTION_DATE ,'NA') AS INSPECTION_DATE,
PROPERTYHOUSENUM,PROPERTYFRACTION,PROPERTYADDRESS,PROPERTYCITY,PROPERTYSTATE,
PROPERTYUNIT,PROPERTYZIP,F.WARD ,F.BLOCK_LOT,F.case_id,F.docket_type,F.amount As F_AMOUNT,                 
plaintiff,DTD,LIEN_DESCRIPTION,LAST_DOCKET_ENTRY,L.AMOUNT as L_AMOUNT,TAX_YEAR,SATISFIED,
INSPECTION_RESULT,VIOLATION,LOCATION,NEIGHBORHOOD,OWNERDESC,CLASSDESC,USEDESC,SALEDATE,SALEPRICE,
SALEDESC,PREVSALEDATE,PREVSALEPRICE,STORIES,YEARBLT,EXTFINISH_DESC,GRADEDESC,
TOTALROOMS,BEDROOMS,FULLBATHS,HALFBATHS,FINISHEDLIVINGAREA
from assesments  as A 
left outer join liens L on (A.parid=L.pin)
left outer join violations V on (A.parid=V.parcel)
left outer join foreclosure F on (A.parid=F.pin)
where (L.pin is not null or V.parcel is not null or F.pin is not null)
) A
join
(select  
A.PARID, 
coalesce(max(F.filing_date),'NA') As F_Filing_Date,
coalesce(max(L.FILING_DATE),'NA') as l_filing_date,
coalesce(max(INSPECTION_DATE),'NA') as inspection_date
from assesments  as A 
left outer join liens L on (A.parid=L.pin)
left outer join violations V on (A.parid=V.parcel)
left outer join foreclosure F on (A.parid=F.pin)
where (L.pin is not null or V.parcel is not null or F.pin is not null)
group by parid
order by parid)b
on (a.parid =b.parid
and a.f_filing_date = b.f_filing_date 
and a.l_filing_date= b.l_filing_date and a.inspection_date= b.inspection_date )
group by A.parid
order by A.parid;

drop table assesments;
drop table liens;
drop table foreclosure;
drop table violations;

EOF

echo 'Successfully update DB. Now manually execute-  sudo mv ~/Downloads/realdb.db /usr/local/realdb.db'