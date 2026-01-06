#!/QOpenSys/pkgs/bin/bash 
# Install acme.sh in $HOME directory
# Parameters $1 Email address associated with the Let's Encrypt Account

# This should come from .profile but doesn't seem to work - acme.sh
PATH=/QOpenSys/pkgs/bin:$PATH
export PATH PASE_PATH 

echo Running AcmeInstall.sh

# This is where the code is downloaded to
cd $HOME/acme.sh-master
# Change the default Certficate Authority to Let's Encrypyt
# change acme.sh into acme.shNew then save original and rename New back to original
# This is so the ZeroSSL is not initiated on the first run (it only gives you 3 free certficates)
/tmp/ritfori/code/acmesedinstall.sh $HOME

# Change the HOME directory to your Let's Encrypt Home will be rest at the end of this script
#export HOME=$HOME/.acme.sh
# Make sure we can find the certficate / TLS for CURL
export CURL_CA_BUNDLE=$HOME/.curl.pem
# Install Let's Encrypt (copy code and add configuration)
acme.sh --install --no-cron --home $HOME/.acme.sh --cert-home $HOME/acme/data/certs --email $1 --accountkey $HOME/acme/acct/account.key --accountconf $HOME/acme/acct/account.conf --log $HOME/acme/log/acme_setup2.log
# Attach License
cp LICENSE.md $HOME/.acme.sh/LICENSE.md
