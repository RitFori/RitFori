#!/QOpenSys/pkgs/bin/bash
# Import Domain Certificate to DCM

PATH=/QOpenSys/pkgs/bin:$PATH
export PATH PASE_PATH

echo "Running DCM_Domain_Cert" 
#
# Get current user for start of path
toppath=/$("whoami")
# Log Path
logpath=$toppath/acme/log
# Get domain from db - returns with " "
domain=$(db2util "values(RITFORI.DCMDOMAIN)")
# change " to blank
domain=${domain//\"/}
# Domain Path
domainpath=$toppath/acme/data/certs/${domain}_ecc
  
   # Get RSEAPI Session Token
   gs_status=$(db2util "select RITFORI.DCMGETSESS('$domain') from sysibm.sysdummy1")
   
   if [[ "$gs_status" == '"201"' ]]; then 
      # Convert to PKCS12
      cd $domainpath
      pass=$(db2util "select LEVALUE from LETABLE where LETYPE='CERT' and LEDOMAIN='$domain'")
      pass=${pass//\"/}
      rm -f pass.txt 
      touch pass.txt
      echo $pass > pass.txt
      openssl pkcs12 -export -inkey $domain.key -in $domain.cer -name $domain -out $domain.pfx -passout file:pass.txt
      # Convert to text 
      base64 -w 0 $domain.pfx > base64.txt
      # Import Domain Certificate to DCM
      ic_status=$(db2util "select RITFORI.DCMIMPCERT('$domain') from sysibm.sysdummy1")
      if [[ "$ic_status" == '"204"' ]]; then
         echo "$domain certificate imported to DCM"
         # Add Aplication to certificate in DCM
         ap_status=$(db2util "select RITFORI.DCMASCAPP('$domain') from sysibm.sysdummy1")
      else
         echo "$domain certificate FAILED to import with status $ic_status"   
      fi
      rm -f pass.txt
   else 
      echo "$domain get session token FAILED with status $gs_status"    
   fi

   # Delete RSEAPI Session Token
   ds_status=$(db2util "select RITFORI.DCMDLTSESS('$domain') from sysibm.sysdummy1")

