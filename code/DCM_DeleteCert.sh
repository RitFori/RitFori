#!/QOpenSys/pkgs/bin/bash
# Import Domain Certificate to DCM

PATH=/QOpenSys/pkgs/bin:$PATH
export PATH PASE_PATH

echo "Running DCM_DeleteCert" 
#
# Get current user for start of path
toppath=/$("whoami")
# Get domain from db - returns with " "
domain=$(db2util "values(RITFORI.DCMDOMAIN)")
# change " to blank
domain=${domain//\"/}
# Domain Path
domainpath=$toppath/acme/data/certs/${domain}_ecc
  
   # Get RSEAPI Session Token
   gs_status=$(db2util "select RITFORI.DCMGETSESS('$domain') from sysibm.sysdummy1")
   
   if [[ "$gs_status" == '"201"' ]]; then 
      # Delete Domain Certificate to DCM
      dc_status=$(db2util "select RITFORI.DCMDLTCERT('$domain') from sysibm.sysdummy1")
      if [[ "$dc_status" == '"204"' ]]; then
         echo "$domain certificate deleted from DCM"
      else
         echo "$domain certificate FAILED to delete from DCM with status $dc_status"   
      fi
   else 
      echo "$domain get session token FAILED with status $gs_status"    
   fi

   # Delete RSEAPI Session Token
   ds_status=$(db2util "select RITFORI.DCMDLTSESS('$domain') from sysibm.sysdummy1")

