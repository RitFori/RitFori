#!/QOpenSys/pkgs/bin/bash  
# Register your account with Let's Encrypt

# This should come from .profile but doesn't seem to work - acme.sh
PATH=/QOpenSys/pkgs/bin:$PATH
export PATH PASE_PATH 

echo Running AcmeRegister.sh
cd /tmp/ritfori/LE_CAs                                            
leca=$HOME/acme/data/certs/ca-bundle.pem                          
cat e7.pem e8.pem e9.pem isrg_root_x1.pem isrg_root_x2.pem > $leca

cd $HOME/.acme.sh

#export CURL_CA_BUNDLE=$HOME/acme/.curl.pem

# Set Let's Encrypt as default again just  to be safe (NOT zerossl - only gives you 3 free certficates)
acme.sh --server letsencrypt --set-default-ca --server letsencrypt --always-force-new-domain-key

# Resister Account - will generate an Account key
acme.sh --register-account --ca-bundle $leca 
