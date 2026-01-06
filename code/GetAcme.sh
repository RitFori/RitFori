#!/QOpenSys/pkgs/bin/bash

# Download acme code (needs to be uncommented)
# unzip acme code for ececution

echo Running GetAcme.sh
cd /tmp/ritfori 
PATH=/QOpenSys/pkgs/bin:$PATH
wget --ca-certificate=.curl.pem -O acme.zip 'https://github.com/acmesh-official/acme.sh/archive/refs/heads/master.zip'
topdir=$HOME
unzip -q acme.zip -d $topdir
cd $topdir/acme.sh-master
cp acme.sh acme_ORIG.sh
