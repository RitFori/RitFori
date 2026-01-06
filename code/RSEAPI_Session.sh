#!/QOpenSys/pkgs/bin/bash
# Import certificate into DCM ???
# Parameters $1 Domain

PATH=/QOpenSys/pkgs/bin:$PATH
export PATH PASE_PATH

echo "Running RSEAPI_Session"
# Get domain from db - returns with " "
domain=$(db2util "values(RITFORI.JKSDOMAIN)")
# change " to '
domain=$(echo $domain | sed "s/\"/'/g")
# domaintxt= null domain for password (only one user)
domaintxt=$(echo LEDOMAIN IS NULL)
# create the beginning sql
sqltxt='db2util "select LEVALUE from LETABLE where LETYPE=*MAIN* and '
# change * to '
sqltxt=$(echo $sqltxt | sed "s/\*/'/g")
# put the 2 sql texts together
pwdtxt="$sqltxt"" ""$domaintxt"' "'
# execute the sql placing the result into $pwd
pwd=$(eval "$pwdtxt")
#echo $pwdtxt
#echo $pwd
# remove " from $pwd
pwd=$(echo $pwd | sed "s/\"//g")

# Delete any possible left over Session records
# domaintxt is the current certificate name
domaintxt=$(echo LEDOMAIN=$domain)
sqltxt='db2util "delete from LETABLE where LETYPE = *SESSION* and '
sqltxt=$(echo $sqltxt | sed "s/\*/'/g")
sqltxt="$sqltxt"" ""$domaintxt"' "'
eval "$sqltxt"

# Get RSE API Session Token using CURL in order to add the CA certficates to the DCM
#  The SQL version will not work yet because it expects the CA certificates to be in the DCM
# -i Include protocol response headers in the output 
# -o Write to file instead of stdout
# -v Make the operation more talkative
# remove '' from $domain
domain=${domain//\'/}
#echo $domain
# create and edit a script to import the Let's Encrypt CAs into the DCM
cp DCM_Curl.txt DCM_Curl.sh
sed -i 's:$TOPDIR:'$HOME':' DCM_Curl.sh 
sed -i 's/$DOMAIN/'$domain/ DCM_Curl.sh
# sed delimiter is # to delete ' from Domain name
#sed -i "s#/'#/#" DCM_Curl.sh
#sed -i "s#':#:#" DCM_Curl.sh
sed -i 's/$AUTH/'$(whoami)'/' DCM_Curl.sh 
sed -i 's/$PSWD/'$pwd'/' DCM_Curl.sh

DCM_Curl.sh
rm DCM_Curl.sh

# Check Log file for successful session token
if grep -Fq  "HTTP/1.1 201 Created" /tmp/ritfori/code/tmp/RSEAPI_Session.log; then 
    #Get the token from the log file
    token=$(awk '/Authorization:/{print $NF}' /tmp/ritfori/code/tmp/RSEAPI_Session.log)
    # remove the end of line
    token="${token%%[[:cntrl:]]}"
    domain=$(echo $1 | sed "s/'//g")
    # write the result to LETABLE
    db2util "insert into LETABLE values ('$domain', 'SESSION', '$token', current timestamp)"
    printf "\e[32m! Session Token success for $domain \033\e[0m \n"
    rm /tmp/ritfori/code/tmp/RSEAPI_Session.log
else
    printf "\e[31mX Session Token failed for $domain \033\e[0m \n"
    RETURN=64
    exit $RETURN
fi


