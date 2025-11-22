#!/QOpenSys/pkgs/bin/bash 
# Issue the first certificate for an account
# Parameters $1 Top Level Directory
#            $2 Certificate Domain Name in full
#            $3 Token for Domain certificate issue and renew with ""

# This should come from .profile but doesn't seem to work - acme.sh
PATH=/QOpenSys/pkgs/bin:$PATH
export PATH PASE_PATH

echo Running AcmeIssue1.sh
cd $1/.acme.sh

# export token for domain
export CF_Token=$3

# acme.sh DNS API for validation should be automatic - list here https://github.com/acmesh-official/acme.sh/wiki/dnsapi
#    OR you can use DNS alias mode here https://github.com/acmesh-official/acme.sh/wiki/DNS-alias-mode 
#       will need to add --challenge-alias and --dns
acme.sh --issue --force --dns dns_cf -d $2 --keylength ec-384 --always-force-new-domain-key --log $1/acme/log/acme_issue1.log

# Remove Token from Config file for security reasons
/tmp/ritfori/code/acmesedconfig.sh $1
