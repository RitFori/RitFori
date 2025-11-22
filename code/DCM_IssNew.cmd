IssueNew:    CMD        PROMPT('Lets Encrypt Setup DCM')
             PARM       KWD(CERTNAME) TYPE(*CHAR) LEN(32) MIN(1) +      
                        PROMPT('Domain/Certficate Name' 1) 
             PARM       KWD(CERTAPP) TYPE(*CHAR) LEN(32) MIN(1) +   
                        ALWUNPRT(*NO) ALWVAR(*NO) CASE(*MIXED) +  
                        PROMPT('Certificate Application Name' 2)  
             PARM       KWD(TOKEN) TYPE(*CHAR) LEN(42) MIN(1) +
                        ALWUNPRT(*NO) ALWVAR(*NO) CASE(*MIXED) +  
                        DSPINPUT(*NO) PROMPT('Domain Token' 3)                                                                  
