#!/QOpenSys/pkgs/bin/bash
# Remove Token from Config file for security reasons

cd $HOME/acme/acct
sed -i 's/SAVED_CF_Token='\'.*'/SAVED_CF_Token='\'\'/'' account.conf
