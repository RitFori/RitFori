#!/QOpenSys/pkgs/bin/bash
# Download a trusted certficate for CURL needed for acme.sh install
echo Running GetCurlCert.sh
PATH=/QOpenSys/pkgs/bin:$PATH
topdir=$HOME
cd $topdir
wget -qO .curl.pem http://curl.haxx.se/ca/cacert.pem --no-check-certificate
