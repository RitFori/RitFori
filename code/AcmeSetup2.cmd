 ACMESetup2: CMD        PROMPT('Lets Encrypt Setup DCM')
             PARM       KWD(EMAIL) TYPE(*CHAR) LEN(128) MIN(1) +
                        ALWUNPRT(*NO) ALWVAR(*NO) CASE(*MIXED) +  
                        PROMPT('E-Mail' 1)
             PARM       KWD(CERTNAME) TYPE(*CHAR) LEN(64) MIN(1) +
                        ALWUNPRT(*NO) ALWVAR(*NO) CASE(*MIXED) +  
                        PROMPT('Domain/Certficate Name' 2)
             PARM       KWD(TOKEN) TYPE(*CHAR) LEN(42) MIN(1) +
                        ALWUNPRT(*NO) ALWVAR(*NO) CASE(*MIXED) +  
                        DSPINPUT(*NO) PROMPT('Domain Token' 3)
             PARM       KWD(JKSPASS) TYPE(*CHAR) LEN(32) MIN(1) +
                        ALWUNPRT(*NO) ALWVAR(*NO) CASE(*MIXED) +  
                        DSPINPUT(*NO) PROMPT('JKS Password' 4)                        
