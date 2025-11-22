#!/QOpenSys/pkgs/bin/bash 
# Issue the first certificate for DCM
# Parameters $1 Top Level Directory
#            $2 Certificate Domain Name in full
#            $3 Token for Domain certificate issue and renew with ""

#  ***???    $3 DNS Validation API type

# This should come from .profile but doesn't seem to work - acme.sh
PATH=/QOpenSys/pkgs/bin:$PATH
export PATH PASE_PATH

echo Running AcmeIssue2.sh
cd $1/.acme.sh

# export token for domain
export CF_Token=$3

# acme.sh DNS API for validation should be automatic - list here https://github.com/acmesh-official/acme.sh/wiki/dnsapi
#    OR you can use DNS alias mode here https://github.com/acmesh-official/acme.sh/wiki/DNS-alias-mode 
#       willl need to add --challenge-alias and --dns
acme.sh --issue --force --dns dns_cf -d $2 --keylength ec-384 --always-force-new-domain-key --log $1/acme/log/$2_issue2.log

# Remove Token from Config file
$1/acme/source/acmesedconfig.sh $1

# Current Domain in Global Variable for DCM
db2util "create or replace variable DCMDOMAIN varchar(253) DEFAULT '$2'"  

# add info needed for DCM into LETABLE
echo "   INSERT DCM INFO to LETABLE * $(date) * "
db2util "insert into LETABLE values ('$2', '"TOKEN"', '$3', current timestamp)"
db2util "insert into LETABLE values ('$2', 'CERTAPP', '$4', current timestamp)"
db2util "insert into LETABLE values ('$2', 'LAST_CERTIFICATE', null, current timestamp)"
db2util "insert into LETABLE values ('$2', 'CURRENT_CERTIFICATE', null, current timestamp)"
