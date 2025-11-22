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
RSEAPI_Session.sh $domain

certname=isrg_root_x2
DCM_CA_Import.sh $certname $domain
certname=isrg_root_x1
DCM_CA_Import.sh $certname $domain
certname=e7
DCM_CA_Import.sh $certname $domain
certname=e8 
DCM_CA_Import.sh $certname $domain
certname=e9 
DCM_CA_Import.sh $certname $domain

# create and edit a script to delete the session token and letable entry
cp DCM_DltCurl.txt DCM_DltCurl.sh
sed -i 's/$AUTH/'$(whoami)'/' DCM_DltCurl.sh 
sed -i 's/$DOMAIN/'$domain/ DCM_DltCurl.sh
# Get Session Token from LETABLE
sqltxt='db2util "select LEVALUE from LETABLE where LETYPE = *SESSION* and '
sqltxt=$(echo $sqltxt | sed "s/\*/'/g")
sqltxt="$sqltxt"" ""LEDOMAIN=$domain"' "'
echo SQLTXT $sqltxt
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
