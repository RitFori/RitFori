#!/QOpenSys/pkgs/bin/bash
# Renew Let's Encrypt Certficate into JKS

# This should come from .profile but doesn't seem to work - acme.sh
PATH=/QOpenSys/pkgs/bin:$PATH
export PATH PASE_PATH

echo "Running LERenewJKS"
# Get current user for start of path
toppath=$HOME
# Log Path
logpath=$toppath/acme/log

# Domain Path
jks_domain=$(db2util "values(RITFORI.JKSDOMAIN)")
domain=${jks_domain//\"/}
domainpath=${domain}_ecc
# 
   cd $toppath/acme/data/certs/$domainpath
   # Get JKS password
   pass=$(db2util "select LEVALUE from LETABLE where LETYPE='CERT' and LEDOMAIN='$domain'")
   pass=${pass//\"/}
   # then add the Domain cert
   # Combine certficate with private key
   # use file for password as openssl doesn't like $pass
   rm -f pass.txt 
   touch pass.txt
   echo $pass > pass.txt
   openssl pkcs12 -export -inkey $domain.key -in $domain.cer -name $domain -out $domain.pfx -passout file:pass.txt
   # replace in JKS
   keytool -importkeystore -srckeystore $domain.pfx -srcstoretype pkcs12 -destkeystore lekeystore.jks -srcstorepass $pass -deststorepass $pass -keypass $pass -storetype PKCS12 --noprompt
   rm pass.txt
   rm -f $domain.pfx
