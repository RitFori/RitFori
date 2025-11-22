#!/QOpenSys/pkgs/bin/bash
# Setup Tables with masked values for security
# Parameters $1 User Profile
#            $2 Certificate Domain Name in full
#            $3 Token for Domain certificate issue and renew with ""
#            $4 JKS keystore password
#            $5 LE account email

# This should come from .profile but doesn't seem to work - acme.sh
PATH=/QOpenSys/pkgs/bin:$PATH
export PATH PASE_PATH

echo Running Acme_Tables.sh

# create a table with masked VALUE for required 
echo "   CREATE LETABLE * $(date) * "
db2util "create or replace table LETABLE (LEDOMAIN  varchar(128) allocate(21), LETYPE varchar(20), LEVALUE varchar(253) allocate(25), LETIME timestamp)"
system "CLRPFM LETABLE"
# create a table for Install / Renew information
echo "   CREATE LERESULTS * $(date) * "
db2util "create or replace table LERESULTS (LEDOMAIN varchar(128) allocate(21), LETYPE char(20), LESTATUS char(3), LETITLE char(20), LEDETAIL varchar(256) allocate(100), LETIME timestamp)"
system "CLRPFM LERESULTS"
# add masked field to table
echo "   ADD MASK to LETABLE * $(date) * "
db2util "create or replace mask LEVALUE_MASK on LETABLE for column LEVALUE return case when (VERIFY_GROUP_FOR_USER(SESSION_USER, '$1') = 1) then LEVALUE else 'Value' end enable"
# activate mask
echo "   ACTIVATE MASK on LETABLE * $(date) * "
db2util "alter table LETABLE activate column access control"
# insert info needed so far
echo "   INSERT certificate INFO to LETABLE * $(date) * "
db2util "insert into LETABLE values ('$2', 'CERT', '$4', current timestamp), ('$2', '"TOKEN"', '$3', current timestamp)"
#) 2>&1 | tee -a /$1/acme/log/acme_tables.log
email=$(db2util "select LEVALUE from LETABLE where LETYPE='EMAIL' and LEDOMAIN is null")
# only insert e-mail  and JKS-Domain once
if [[ "$email" == '' ]]; then
   db2util "insert into LETABLE values (null, '"EMAIL"', '$5', current timestamp)"
   # Current Domain in Global Variable for Key Store
   db2util "create or replace variable JKSDOMAIN varchar(253) DEFAULT '$2'" 
fi 

