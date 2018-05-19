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

create table composed as select *
 from assesments as a join
 (select * from liens as l join
 (select * from violations as v join foreclosure as f on v.PARCEL = f.pin) as vf
 on vf.PARCEL = l.PIN) as flv on a.PARID = flv.PIN;
EOF

echo 'Successfully update DB. Now manually execute-  sudo mv ~/Downloads/realdb.db /usr/local/realdb.db'