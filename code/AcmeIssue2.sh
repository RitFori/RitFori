#!/QOpenSys/pkgs/bin/bash 
# Issue the first certificate for DCM
# Parameters $1 Certificate Domain Name in full
#            $2 Token for Domain certificate issue and renew with ""
#            $3 Application to associate with the Certficate


# This should come from .profile but doesn't seem to work - acme.sh
PATH=/QOpenSys/pkgs/bin:$PATH
export PATH PASE_PATH

echo Running AcmeIssue2.sh
cd $HOME/.acme.sh

# export token for domain
export CF_Token=$2

# acme.sh DNS API for validation should be automatic - list here https://github.com/acmesh-official/acme.sh/wiki/dnsapi
#    OR you can use DNS alias mode here https://github.com/acmesh-official/acme.sh/wiki/DNS-alias-mode 
#       willl need to add --challenge-alias and --dns
acme.sh --issue --force --dns dns_cf -d $1 --keylength ec-384 --always-force-new-domain-key --log $HOME/acme/log/$1_issue2.log

# Remove Token from Config file
$HOME/acme/source/acmesedconfig.sh $HOME

# Current Domain in Global Variable for DCM
db2util "create or replace variable DCMDOMAIN varchar(253) DEFAULT '$1'"  

# add info needed for DCM into LETABLE
echo "   INSERT DCM INFO to LETABLE * $(date) * "
db2util "insert into LETABLE values ('$1', '"TOKEN"', '$2', current timestamp)"
db2util "insert into LETABLE values ('$1', 'CERTAPP', '$3', current timestamp)"
db2util "insert into LETABLE values ('$1', 'LAST_CERTIFICATE', null, current timestamp)"
db2util "insert into LETABLE values ('$1', 'CURRENT_CERTIFICATE', null, current timestamp)"
