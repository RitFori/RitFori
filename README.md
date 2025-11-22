# RitFori
IBM i Let's Encrypt Automation – Almost \
Created by  Rowton IT Solutions Ltd and Forever-i Ltd

## Introduction
### Abbreviations

* ACME		- Open Source software that will create and renew Let’s Encrypt certificates 
					 available at https://github.com/acmesh-official/acme.sh  
* CA			- Certificate Authority Root and Intermediate certificates needed on the IBM i for both the DCM and JKS 				
* DCM 		- Digital Certificate Manager – IBM I certficate store
* JKS			- Java Key Store (alternative certficate store)
* RSE API - Remote System Explorer API – used to import, associate certificate application and delete certificates in the DCM
* TLD			- Top Level Domain – the end part of your domain name e.g. .com  .co.uk  .eu 

### What is this software?

This appliaction currently called RitFori is an attempt to fully automate the creation and renewal of TLS (or SSL) certificates from Let’s Encrypt.  At the moment there are a couple things that can only be done manually, but only once.

TLS is important for applications.  It encrypts the traffic between the user and the IBM i so that it cannot be read by hackers.  Most applications that use HTTP web pages need TLS, as modern browsers are insisting on the use of HTTPS which needs TLS.  More recently they have blocked the advanced, “I want to ignore the lack of security” too.

### About this software

This is a first attempt to create a usable apllication for automating Let’s Encrypt certificates.  

RitFori has been written and tested on V7.4 and V7.5.  The domain tested is registered on Cloudflare which has an API that automates the Let’s Encrypt DNS Challenge by supplying an API token.  Domains with other suppliers may not work without changes.

RitFori does not currently work on V7.6. This will be investigated later.  Wildcard domains have not been tested.

Your certficates will be created as a TLS 1.3 ECC certificate with 384 length (ECDSA SHA-384). It will be stored in 
* /*usrprf*/acme/data/certs/*name.domain.TLD_ecc*

The Library is called RITFORI, so it may be an idea to create the user profile as RITFORI, but you can have any profile you want. It is a very good idea to only use this user for only Let’s Encypt. The security is set up so that only this user has access (except for other *ALLOBJ users).  The parameters entered are stored in a table in the RITFORI library that are masked so that only your user profile has access except for users with *SECADM or *SYSADM).


**There are 4 initial steps**
1. **Create a User Profile**, **Sign On**, compile and run **Acme Setup 1**. This sets up the user for SSH (required) and sets up the basic environment (Library and Directory structure).
2. **Sign off and on again**. Run **Acme Setup 2**. This installs and registers your account for “acme-official / acme.sh”. Then it creates a JKS with Let’s Encrypt CAs, issues your first certificate and adds it to the JKS.
3. This is the manual part. You need to configure ADMIN5 (IBM i Apache HTTP server) with the JKS as the TLS. You also have to add an Application name to the DCM, if you are going to use your certificate from the DCM and it needs an application.
4. Run **DCM Setup 3** if required.  This imports the Let’s Encrypt CAs and your certificate into the DCM and also attaches the application.

**The repeatable steps – can be run as scheduled jobs**
1. **Renew** your certificate.  This includes replacing the certificate in the JKS and the DCM if required moving the application from the old certificate to the new one.
2. Run **LE_ADMIN5** to restart ADMIN5 so it picks up the new JKS.
3. Restart your TLS applications to pick the renewed certificate – you must do this manually or create a scheduled job to do so, when required.  The previous certificate will be used until this step is completed or the certficate expires.
4. Finally **DCM Delete Certificate** to remove the older certificate, if required.

Normally you can use the same certificate for the RSE API and your applications.  The new certificate will not be used until the applications are restarted.
