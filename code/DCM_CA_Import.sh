#!/QOpenSys/pkgs/bin/bash
# Import each Let's Encrypt CAs into DCM
# Parameters $1 CA Certificate Name
#            $2 JKS Domain

PATH=/QOpenSys/pkgs/bin:$PATH
export PATH PASE_PATH

echo running DCM_CA_Import
# Get Session Token from LETABLE
sqltxt='db2util "select LEVALUE from LETABLE where LETYPE = *SESSION* and '
sqltxt=$(echo $sqltxt | sed "s/\*/'/g")
sqltxt="$sqltxt"" ""LEDOMAIN=$2"' "'
token=$(eval $sqltxt)
# execute the sql and place the result into $dpass 
dpass=$(db2util "select LEVALUE from LETABLE where LETYPE='SYSTEM'")
# remove " from $dpass and $token
dpass=$(echo $dpass | sed "s/\"//g")
token=$(echo $token | sed "s/\"//g")

# remove '' from $domain
domain=$(echo $2 | sed "s/\'//g")
cd /tmp/ritfori/code
# create and edit a script to import the Let's Encrypt CAs into the DCM
cp CA_Curl.txt CA_Curl.sh
sed -i 's/$AUTH/'$(whoami)'/' CA_Curl.sh 
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
if grep -Fq  "HTTP/1.1 204 No Content" /tmp/ritfori/code/tmp/setupCAs_Import.log; then
    printf "\e[32m! CA certificate $1 successfully imported to DCM \033\e[0m \n"
else
    printf "\e[31mX CA certificate $1 failed to import to DCM \033\e[0m \n"
    RETURN=64
    exit $RETURN
fi
