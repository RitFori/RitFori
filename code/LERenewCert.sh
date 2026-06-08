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
rm $toppath/acme/log/renewcert_$domain.log
touch $toppath/acme/log/renewcert_$domain.log

# setup LE CA bundle
curlca=$HOME/acme/data/certs/ca-bundle.pem
acme.sh --renew --force -d $domain --keylength ec-384 --always-force-new-domain-key  --log $toppath/acme/log/renewcert_$domain.log --ca-bundle $curlca --preferred-chain "Root YE"

# Remove Token from Config file for security reasons
$HOME/acme/source/acmesedconfig.sh $HOME

if n=$(grep "Cert success." $toppath/acme/log/renewcert_$domain.log); then 
    db2util "insert into LERESULTS values ('$domain', 'RENEW', 'OK', 'Cert Renew', 'Certificate renew successful for $domain', current timestamp)"
    echo "Certificate renew SUCCESS $domain"
    RETURN=0
else 
    db2util "insert into LERESULTS values ('$domain', 'RENEW', 'X', 'Cert Renew', 'Certificate renew failed for $domain', current timestamp)"
    echo "Certificate renew FAILED $domain"
    RETURN=1
fi

exit $RETURN
