#!/usr/bin/env bash
# Change default acme.sh
# Parameters $1 Top Level Directory
cd $1/acme.sh-master
# if there is not a acmecopy.sh already then
#   change shebang from #!/usr/bin/env to #!/QOpenSys/pkgs/bin/bash/ 
#   add a CHANGE NOTIFICATION
#   change DEFAULT_CA=$CA_ZEROSSL to DEFAILT_CA=$CA_LETSENCRYPT_V2 
# endif
# set the authority for acme.sh
if [ ! -f acmecopy.sh ]; then
  cp acme.sh acmecopy.sh
  d1="$(date -d "$date" +"%b %d %Y")"
  shebang1='#!/usr/bin/env sh'
  note1='#!/QOpenSys/pkgs/bin/bash\n\n# Modification Notification to acme.sh - Modified '
  note2=' to change shebang (1st line) to IBM i\n#    and change DEFAULT_CA to LETSENCRYPT before registering the account'
  change="$note1 $d1 $note2"
  sed -i "s:$shebang1:${change}:" acme.sh
  sed -i 's:#!/usr/bin/env sh:#!/QOpenSys/pkgs/bin/bash\n# Modification Notification to acme.sh - Modified $(d1) to change shebang (1st line) to IBM i\n#    and change DEFAULT_CA to LETSENCRYPT before registering the account:' acme.sh
  sed -i 's/DEFAULT_CA=$CA_ZEROSSL/DEFAULT_CA=$CA_LETSENCRYPT_V2/' acme.sh
fi
chmod 700 acme.sh