#!/QOpenSys/pkgs/bin/bash
# Setup SSH .profile

echo Running SSH_profile.sh - no messages means it worked. $(date)

cd $HOME
if [ ! -f .profile ]; then  
   cat << EOF >> .profile
PATH=/QOpenSys/pkgs/bin:\$PATH
export PATH PASE_PATH
EOF
fi   
if [ ! -f .bashrc ]; then  
   cat << EOF >> .bashrc
PATH=/QOpenSys/pkgs/bin:\$PATH
export PATH PASE_PATH
EOF
fi  