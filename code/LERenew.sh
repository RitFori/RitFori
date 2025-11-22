#!/QOpenSys/pkgs/bin/bash
# Renew Let's Encrypt Certficate into JKS
# Parameters $1 Certificate Domain Name in full
#            $2 certicate to renew into DCM YES/NO ?  

PATH=/QOpenSys/pkgs/bin:$PATH
export PATH PASE_PATH

echo "running LERenew"
# Get current user for start of path
toppath=/$("whoami")
cd /$toppath/acme/source

# Put Current Domain in Global Variable for DCM
if [ "$2" == YES ]; then
   db2util "create or replace variable DCMDOMAIN varchar(253) DEFAULT '$1'" 
fi 

# Domain Path
domain=$1

# Renew Let's Encrypt certificate
LERenewCert.sh $1

# Renew JKS certificate if JKS domain is the same as the renewing domain
jks_domain=$(db2util "values(RITFORI.JKSDOMAIN)")
jks_domain=${jks_domain//\"/}
echo DOMAIN $domain/ JKSDOMAIN $jks_domain/
if  [ "$jks_domain" == "$domain" ];  then
   echo "JKS"
   LERenewJKS.sh
fi

# Renew DCM certificate if DCM certificate is required
if [ "$2" == YES ]; then
   echo "DCM"
   DCM_Domain_Cert.sh
fi 