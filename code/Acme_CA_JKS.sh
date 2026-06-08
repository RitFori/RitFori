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
#curl -L https://letsencrypt.org/certs/gen-y/root-ye.pem > root-ye.pem
#tail -n +2 root-ye.pem | head -n -1 | tr -d '\n' > root-ye.txt
#curl -L https://letsencrypt.org/certs/gen-y/int-ye1.pem > int-ye1.pem 
#tail -n +2 int-ye1.pem | head -n -1 | tr -d '\n' > int-ye1.txt
#curl -L https://letsencrypt.org/certs/gen-y/int-ye2.pem > int-ye2.pem 
#tail -n +2 int-ye2.pem | head -n -1 | tr -d '\n' > int-ye2.txt
#curl -L https://letsencrypt.org/certs/gen-y/int-ye3.pem > int-ye3.pem 
#tail -n +2 int-ye3.pem | head -n -1 | tr -d '\n' > int-ye3.txt
cat int-ye1.pem int-ye2.pem int-ye3.pem root-ye.pem > $HOME/acme/data/certs/ca-bundle.pem

# Create JKS and import Let's Encrypt CA certficates
cd $domainpath
keytool -import -alias root-ye -file /tmp/ritfori/LE_CAs/root-ye.pem -keystore lekeystore.jks -storepass $pass -storetype PKCS12 -trustcacerts -noprompt
keytool -import -alias int-ye1 -file /tmp/ritfori/LE_CAs/int-ye1.pem  -keystore lekeystore.jks -storepass $pass -storetype PKCS12 -trustcacerts -noprompt
keytool -import -alias int-ye2 -file /tmp/ritfori/LE_CAs/int-ye2.pem  -keystore lekeystore.jks -storepass $pass -storetype PKCS12 -trustcacerts -noprompt
keytool -import -alias int-ye3 -file /tmp/ritfori/LE_CAs/int-ye3.pem  -keystore lekeystore.jks -storepass $pass -storetype PKCS12 -trustcacerts -noprompt
