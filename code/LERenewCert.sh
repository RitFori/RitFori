#!/QOpenSys/pkgs/bin/bash
# Renew Let's Encrypt Certficate into DCM
# Parameters $1 Certificate Domain Name in full

# This should come from .profile but doesn't seem to work - acme.sh
PATH=/QOpenSys/pkgs/bin:$PATH
export PATH PASE_PATH

echo "Running LERenewCert"
#
# Get current user for start of path
toppath=$HOME
# Log Path
logpath=$toppath/acme/log

# Domain Path
domain=$1
domainpath=${domain}_ecc

# Certificate Token
token=$(db2util "select LEVALUE from LETABLE where LETYPE='TOKEN' and LEDOMAIN='$domain'")

cd  $toppath/.acme.sh
# export token for domain
export CF_Token=$token
rm $toppath/acme/data/certs/$domainpath/renewcert.log
touch $toppath/acme/data/certs/$domainpath/renewcert.log

acme.sh --renew --force -d $domain --keylength ec-384 --always-force-new-domain-key  --log $toppath/acme/data/certs/$domainpath/renewcert.log

if grep -Fq  "Cert success." $toppath/acme/data/certs/$domainpath/renewcert.log; then 
    db2util "insert into LERESULTS values ($domain, 'RENEW', '', 'Certificate renewed $domain', 0, current timestamp)"
    printf "\e[32m! Certificate renew success $domain \033\e[0m \n"
    RETURN=0
else 
    db2util "insert into LERESULTS values ($domain, 'RENEW', '', 'Certificate renew failed $domain', 1, current timestamp)"
    printf "\e[31mX Certificate renew failed $domain \033\e[0m \n"
    RETURN=1
fi

exit $RETURN
