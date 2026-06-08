#!/QOpenSys/pkgs/bin/bash
# Import Let's Encrypt CAs into DCM

PATH=/QOpenSys/pkgs/bin:$PATH
export PATH PASE_PATH

echo Running DCM_CA.sh

# Get domain from db - returns with " "
domain=$(db2util "values(RITFORI.JKSDOMAIN)")
# change " to '
domain=$(echo $domain | sed "s/\"/'/g")

cd /tmp/ritfori/code

# Get RSEAPI Session Token
rm $HOME/acme/log/RSEAPI_Session.log 2> /dev/null || true
touch $HOME/acme/log/RSEAPI_Session.log
export LANG=en_US.UTF-8; RSEAPI_Session.sh $domain >> $HOME/acme/log/RSEAPI_Session.log 2>&1 

certname=root-ye
touch $HOME/acme/log/DCM_CA_Import_$certname.log
export LANG=en_US.UTF-8; DCM_CA_Import.sh $certname >> $HOME/acme/log/DCM_CA_Import_$certname.log 2>&1
certname=int-ye1
touch $HOME/acme/log/DCM_CA_Import_$certname.log
export LANG=en_US.UTF-8; DCM_CA_Import.sh $certname >> $HOME/acme/log/DCM_CA_Import_$certname.log 2>&1
certname=int-ye2
touch $HOME/acme/log/DCM_CA_Import_$certname.log
export LANG=en_US.UTF-8; DCM_CA_Import.sh $certname >> $HOME/acme/log/DCM_CA_Import_$certname.log 2>&1

# create and edit a script to delete the session token and letable entry
cp DCM_DltCurl.txt DCM_DltCurl.sh
sed -i 's:$TOPDIR:'$HOME':' DCM_DltCurl.sh 
sed -i 's/$DOMAIN/'$domain/ DCM_DltCurl.sh
# Get Session Token from LETABLE
sqltxt='db2util "select LEVALUE from LETABLE where LETYPE = *SESSION* and '
sqltxt=$(echo $sqltxt | sed "s/\*/'/g")
sqltxt="$sqltxt"" ""LEDOMAIN=$domain"' "'
token=$(eval $sqltxt | sed "s/\"//g")
sed -i 's/$TOKEN/'$token'/' DCM_DltCurl.sh
DCM_DltCurl.sh
rm DCM_DltCurl.sh

# Delete Session record
sqltxt='db2util "delete from LETABLE where LETYPE = *SESSION* and '
sqltxt=$(echo $sqltxt | sed "s/\*/'/g")
domaintxt=$(echo LEDOMAIN=$domain)
sqltxt="$sqltxt"" ""$domaintxt"' "'
token=$(eval $sqltxt)
