 SETUP3:     CMD        PROMPT('Lets Encrypt Setup DCM')
             PARM       KWD(CERTNAME) TYPE(*CHAR) LEN(32) MIN(1) +      
                        PROMPT('Domain/Certficate Name' 1) 
             PARM       KWD(USRPWD) TYPE(*CHAR) LEN(32) MIN(1) +          
                        ALWUNPRT(*NO) ALWVAR(*NO) CASE(*MIXED) +  
                        DSPINPUT(*NO) PROMPT('User Password' 2) 
             PARM       KWD(DCMPWD) TYPE(*CHAR) LEN(32) MIN(1) +          
                        ALWUNPRT(*NO) ALWVAR(*NO) CASE(*MIXED) +  
                        DSPINPUT(*NO) PROMPT('DCM Password' 3)
             PARM       KWD(CERTAPP) TYPE(*CHAR) LEN(32) MIN(1) +   
                        ALWUNPRT(*NO) ALWVAR(*NO) CASE(*MIXED) +  
                        PROMPT('Certificate Application Name' 4)                                            
