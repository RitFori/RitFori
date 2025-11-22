#!/QOpenSys/pkgs/bin/bash
# Remove Token from Config file for security reasons
# Parameters $1 Top Level Directory
cd $1/acme/acct
sed -i 's/SAVED_CF_Token='\'.*'/SAVED_CF_Token='\'\'/'' account.conf
