#!/QOpenSys/pkgs/bin/bash
# Setup Tables records for DCM functions
# Parameters $1 Top Level Directory (Default /RITFORI) 
#            $2 Certificate Domain Name in full
#            $3 User password
#            $4 DCM *SYSTEM password
#            $5 Certficate assigned Applications

# This should come from .profile but doesn't seem to work - acme.sh
PATH=/QOpenSys/pkgs/bin:$PATH
export PATH PASE_PATH

echo Running DCM_Tables.sh

# Current Domain in Global Variable for DCM
db2util "create or replace variable DCMDOMAIN varchar(253) DEFAULT '$2'"    
# add info needed for DCM into LETABLE
echo "   INSERT DCM INFO to LETABLE * $(date) * "
runalready=$(db2util "select LEVALUE from LETABLE where LETYPE='MAIN' and LEDOMAIN is null")
# only inser e-mail once
if [[ "$runalready" == '' ]]; then
   db2util "insert into LETABLE values (null, 'MAIN', '$3', current timestamp)"
   db2util "insert into LETABLE values (null, 'SYSTEM', '$4', current timestamp)"
   db2util "insert into LETABLE values ('$2', 'CERTAPP', '$5', current timestamp)"
   db2util "insert into LETABLE values ('$2', 'LAST_CERTIFICATE', null, current timestamp)"
   db2util "insert into LETABLE values ('$2', 'CURRENT_CERTIFICATE', null, current timestamp)"
fi
