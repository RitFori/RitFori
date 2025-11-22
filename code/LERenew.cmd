LERENEW:    CMD        PROMPT('LETS ENCRYPT RENEW CERTIFICATE')    
            PARM       KWD(CERTNAME) TYPE(*CHAR) LEN(128) MIN(1) +  
                          PROMPT('Domain/Certficate Name' 1)                  
            PARM       KWD(DCM_YN) TYPE(*CHAR) LEN(3) RSTD(*YES) +
                          VALUES(YES NO) MIN(1) ALWUNPRT(*NO) +    
                          ALWVAR(*NO) PGM(*NO) CASE(*MONO) +       
                          PROMPT('Renew in DCM YES/NO' 2)            
