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
acme.sh --issue --force --dns dns_cf -d $1 --keylength ec-384 --always-force-new-domain-key --log $HOME/acme/log/acme_issue1.log --ca-bundle $curlca

# Remove Token from Config file for security reasons
/tmp/ritfori/code/acmesedconfig.sh $HOME

if grep -Fq  "Cert success." $toppath/acme/log/acme_issue1.log; then 
    db2util "insert into LERESULTS values ($domain, 'ISSUE1', '', 'Certificate renewed $domain', 0, current timestamp)"
    printf "\e[32m! Certificate issue success $domain \033\e[0m \n"
    RETURN=0
else 
    db2util "insert into LERESULTS values ($domain, 'ISSUE1', '', 'Certificate renew failed $domain', 1, current timestamp)"
    printf "\e[31mX Certificate issue failed $domain \033\e[0m \n"
    RETURN=1
fi

exit $RETURN