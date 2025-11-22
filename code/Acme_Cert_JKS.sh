#!/QOpenSys/pkgs/bin/bash
# Import Let's Encrypt Certificate to JKS (Java Keystore) needed for DCM
# Parameters $1 Top Level Directory

PATH=/QOpenSys/pkgs/bin:$PATH
export PATH PASE_PATH

echo Running Acme_CA_JKS.sh

# Setup parameters 
# domain = the sub domain name with single quotes for the SELECT statement
#          then it is without quotes for the directoryname
# pass = the password without double quotes
# domainpath = the path in separate statements because of the / and _ charaters
domain=$(db2util "values(RITFORI.JKSDOMAIN)")
domain=${domain//\"/\'}
pass=$(db2util "select LEVALUE from LETABLE where LETYPE='CERT' and LEDOMAIN=$domain")
pass=${pass//\"/ }
domain=${domain//\'/}
domainpath=$1/acme/data/certs/
domainpath=$domainpath$domain
ecc=_ecc
domainpath=$domainpath$ecc

cd $domainpath

# Add the Domain cert
# Combine certficate with private key
# use file for password as openssl doesn't like $pass
rm -f pass.txt 
touch pass.txt
echo $pass > pass.txt
openssl pkcs12 -export -inkey $domain.key -in $domain.cer -name $domain -out $domain.pfx -passout file:pass.txt
# add to JKS
keytool -importkeystore -srckeystore $domain.pfx -srcstoretype pkcs12 -destkeystore lekeystore.jks -srcstorepass $pass -deststorepass $pass -keypass $pass -storetype PKCS12
#not used but might be useful - line to delete certificate but leave CAs in the keystore
#keytool -delete -alias $domain -srckeystore $domain.pfx -keystore lekeystore.jks -storepass $pass
rm pass.txt
rm -f $domain.pfx
