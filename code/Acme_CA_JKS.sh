#!/QOpenSys/pkgs/bin/bash
# Import Let's Encrypt CAs to JKS (Java Keystore) needed for DCM

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
domainpath=$HOME/acme/data/certs/
domainpath=$domainpath$domain
ecc=_ecc
domainpath=$domainpath$ecc
mkdir $domainpath

# Already downloaded
cd /tmp/ritfori/LE_CAs
#curl -L https:/letsencrypt.org/certs/isrgrootx1.pem > isrg_root_x1.pem
#curl -L https://letsencrypt.org/certs/isrg-root-x2.pem > isrg_root_x2.pem
#curl -L https://letsencrypt.org/certs/2024/e7.pem > e7.pem
#curl -L https://letsencrypt.org/certs/2024/e8.pem > e8.pem
#curl -L https://letsencrypt.org/certs/2024/e9.pem > e9.pem
cat e7.pem e8.pem e9.pem isrg_root_x1.pem isrg_root_x2.pem > $HOME/acme/data/certs/ca-bundle.pem

cd $domainpath

# Create JKS and import Let's Encrypt CA certficates
keytool -import -alias isrg_root_x1 -file /tmp/ritfori/LE_CAs/isrg_root_x1.pem -keystore lekeystore.jks -storepass $pass -storetype PKCS12 -trustcacerts -noprompt
keytool -import -alias isrg_root_x2 -file /tmp/ritfori/LE_CAs/isrg_root_x2.pem -keystore lekeystore.jks -storepass $pass -storetype PKCS12 -trustcacerts -noprompt
keytool -import -alias e7 -file /tmp/ritfori/LE_CAs/e7.pem -keystore lekeystore.jks -storepass $pass -storetype PKCS12 -trustcacerts -noprompt
keytool -import -alias e8 -file /tmp/ritfori/LE_CAs/e8.pem -keystore lekeystore.jks -storepass $pass -storetype PKCS12 -trustcacerts -noprompt
keytool -import -alias e9 -file /tmp/ritfori/LE_CAs/e9.pem -keystore lekeystore.jks -storepass $pass -storetype PKCS12 -trustcacerts -noprompt
