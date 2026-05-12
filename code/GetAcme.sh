#!/QOpenSys/pkgs/bin/bash

# Download acme code (needs to be uncommented)
# unzip acme code for ececution

PATH=/QOpenSys/pkgs/bin:$PATH
export PATH PASE_PATH 

echo Running GetAcme.sh
cd /tmp/ritfori 

# setup Curl CA bundle
curlca=$HOME/.curl.pem 

wget --ca-certificate=$curlca -O acme.zip 'https://github.com/acmesh-official/acme.sh/archive/refs/heads/master.zip'
topdir=$HOME
unzip -q acme.zip -d $topdir
cd $topdir/acme.sh-master
cp acme.sh acme_ORIG.sh
