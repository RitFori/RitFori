
#!/QOpenSys/pkgs/bin/bash 
# Install acme.sh in $HOME directory
# Parameters $1 Top Level Directory
#            $2 Email address associated with the Let's Encrypt Account

# This should come from .profile but doesn't seem to work - acme.sh
PATH=/QOpenSys/pkgs/bin:$PATH
export PATH PASE_PATH 

echo Running AcmeInstall.sh

# This is where the code is downloaded to
cd $1/acme.sh-master
# Change the default Certficate Authority to Let's Encrypyt
# change acme.sh into acme.shNew then save original and rename New back to original
# This is so the ZeroSSL is not initiated on the first run (it only gives you 3 free certficates)
/tmp/ritfori/code/acmesedinstall.sh $1

# Change the HOME directory to your Let's Encrypt Home will be rest at the end of this script
#export HOME=$1/.acme.sh
# Make sure we can find the certficate / TLS for CURL
export CURL_CA_BUNDLE=$1/.curl.pem
# Install Let's Encrypt (copy code and add configuration)
acme.sh --install --no-cron --home $1/.acme.sh --cert-home $1/acme/data/certs --email $2 --accountkey $1/acme/acct/account.key --accountconf $1/acme/acct/account.conf --log $1/acme/log/acme_setup2.log
# Attach License
cp LICENSE.md $1/.acme.sh/LICENSE.md
