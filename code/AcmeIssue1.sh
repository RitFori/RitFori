#!/QOpenSys/pkgs/bin/bash 
# Issue the first certificate for an account
# Parameters $1 Certificate Domain Name in full
#            $2 Token for Domain certificate issue and renew with ""

# This should come from .profile but doesn't seem to work - acme.sh
PATH=/QOpenSys/pkgs/bin:$PATH
export PATH PASE_PATH

echo Running AcmeIssue1.sh
cd $HOME/.acme.sh

# Domain
domain=$1
# export token for domain
export CF_Token=$2
# setup Curl CA bundle
curlca=$HOME/.curl.pem 

# acme.sh DNS API for validation should be automatic - list here https://github.com/acmesh-official/acme.sh/wiki/dnsapi
#    OR you can use DNS alias mode here https://github.com/acmesh-official/acme.sh/wiki/DNS-alias-mode 
#       will need to add --challenge-alias and --dns
acme.sh --issue --force --dns dns_cf -d $1 --keylength ec-384 --always-force-new-domain-key --log $HOME/acme/log/acme_issue1_$1.log --ca-bundle $curlca

# Remove Token from Config file for security reasons
/tmp/ritfori/code/acmesedconfig.sh $HOME

if n=$(grep "Cert success." $HOME/acme/log/acme_issue1_$domain.log); then
    db2util "insert into LERESULTS values ('$domain', 'ISSUE1', 'OK', 'Main Cert Issue', 'Certificate issued for $domain', current timestamp)"
    echo "Certificate issue 1 SUCCESS for $domain"
    RETURN=0
else 
    db2util "insert into LERESULTS values ('$domain', 'ISSUE1', 'X', 'Main Cert Issue', 'Certificate issue failed for $domain', current timestamp)"
    echo "Certificate issue 1 FAILED for $domain"
    RETURN=1
fi

exit $RETURN