#!/QOpenSys/pkgs/bin/bash 
# Change /USRPRF to Users Home directory

cd $HOME/acme/acct
NewHome=$HOME
if [ ! -f account.copy ]; then
  cp account.conf account.copy
  sed -i "s:/$(whoami):$NewHome:i" account.conf
fi
