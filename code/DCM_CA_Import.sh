#!/QOpenSys/pkgs/bin/bash
# Import each Let's Encrypt CAs into DCM
# Parameters $1 CA Certificate Name

PATH=/QOpenSys/pkgs/bin:$PATH
export PATH PASE_PATH

# Get domain from db - returns with " "
domain=$(db2util "values(RITFORI.JKSDOMAIN)")
# change " to '
domain=$(echo $domain | sed "s/\"/'/g")

touch $HOME/acme/log/DCM_CA_Import_$1.log
echo running DCM_CA_Import
# Get Session Token from LETABLE
sqltxt='db2util "select LEVALUE from LETABLE where LETYPE = *SESSION* and '
sqltxt=$(echo $sqltxt | sed "s/\*/'/g")
sqltxt="$sqltxt"" ""LEDOMAIN = $domain"' "'
token=$(eval $sqltxt)
# execute the sql and place the result into $dpass 
dpass=$(db2util "select LEVALUE from LETABLE where LETYPE='SYSTEM'")
# remove " from $dpass and $token
dpass=$(echo $dpass | sed "s/\"//g")
token=$(echo $token | sed "s/\"//g")

# remove '' from $domain
domain=$(echo $domain | sed "s/\'//g")
cd /tmp/ritfori/code
# create and edit a script to import the Let's Encrypt CAs into the DCM
cp CA_Curl.txt CA_Curl.sh
sed -i 's:$TOPDIR:'$HOME':' CA_Curl.sh 
sed -i 's/$DOMAIN/'$domain'/' CA_Curl.sh
# sed delimiter is # to delete ' from Domain name
sed -i "s#/'#/#" CA_Curl.sh
sed -i "s#':#:#" CA_Curl.sh
sed -i 's/$TOKEN/'$token'/' CA_Curl.sh
sed -i 's/$PASS/'$dpass'/' CA_Curl.sh
sed -i 's/$ALIAS/'$1'/' CA_Curl.sh
cert=\"$(cat /tmp/ritfori/LE_CAs/$1.txt)\"}\'
echo $cert >> CA_Curl.sh
CA_Curl.sh
rm CA_Curl.sh
# Check Log file for successful session token (bearer)
if n=$(grep "HTTP/1.1 204 No Content" $HOME/acme/log/DCM_CA_Import_$1.log); then
    echo "CA certificate $1 SUCCESSFULLLY imported to DCM"
    RETURN=0
else
    echo "CA certificate $1 FAILED to import to DCM"
    RETURN=1
fi

exit $RETURN
