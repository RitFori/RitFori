# RitFori
IBM i Let's Encrypt Automation – Almost \
Created by  Rowton IT Solutions Ltd and Forever-i Ltd
Developed by Terry Bartlett (Forever-i)

## Introduction
### Abbreviations
 
* ACME - Is an IETF standard see https://datatracker.ietf.org/doc/html/rfc8555/ 
* acme.sh		- Open Source ACME client software that will create and renew Let’s Encrypt certificates, available at https://github.com/acmesh-official/acme.sh
* API - Application Program Interface - A program that supplies a service, often between organisations.
* CA			- Certificate Authority Root and Intermediate certificates needed on the IBM i for both the DCM and JKS 
* CSR		- Certificate Signing Request - including a private key				
* DCM 		- Digital Certificate Manager – IBM i certificate store
* JKS			- Java Key Store (alternative certificate store)
* RSE API - Remote System Explorer API – used to import, associate certificate application and delete certificates in the DCM
* TLD			- Top Level Domain – the end part of your domain name e.g. .com  .co.uk  .eu 

### What is this software?

This application currently called RitFori is an attempt to fully automate the creation and renewal of TLS (or SSL) certificates from Let’s Encrypt.  At the moment there are a couple things that can only be done manually, but only once.

TLS is important for applications.  It encrypts the traffic between the user and the IBM i so that it cannot be read by hackers.  Most applications that use web pages need TLS, as modern browsers are insisting on the use of HTTPS which needs TLS certificates.  More recently they have blocked the advanced, “I want to ignore the lack of security” too.  The lifetime of TLS certificates, for major browsers, are becoming shorter to ensure better security.  Currently it is 200 days. This is changing to 100 days on the 15th March 2027 and 47 days on 15th March 2029 by major browsers.

Let's Encrypt use 90 days, changing to 45 days 13 May 2026, 64 days 10 February 2027 and 45 days 16th February 2028.  Hence the requirement for automation.

### About this software

This is a first attempt to create a usable application for automating Let’s Encrypt certificates. It is a work in progress, any suggestions for improvements are welcome.

It was designed for use with web servers hosted on the IBM i, mostly for internal network use.  Only the main domain name e.g. example.com needs to be registered on an external DNS with an API key for verification of ownership, subdomains can also be registered e.g. subdomain.example.com

RitFori has been written and tested on V7.4 and V7.5.  The domain tested is registered on Cloudflare which has an API that automates the Let’s Encrypt DNS Challenge by supplying an API token.  Domains with other suppliers may not work without changes.

RitFori does not currently work on V7.6. This will be investigated later.  Wildcard domains have not been tested.

Currently this is for one non wild card certificate. However it can be used for more than one certificate. I will add another program for this shortly.

Your certificates will be created as a TLS 1.3 ECC certificate with 384 length (ECDSA SHA-384). It will be stored in 
* /*HOMEDIR*/acme/data/certs/*name.domain.TLD_ecc*

The Library is called RITFORI, so it may be an idea to create the user profile as RITFORI, but you can have any profile you want. It is a very good idea to only use this user for only Let’s Encrypt. The security is set up so that only this user has access (except for other *ALLOBJ users).  The parameters entered are stored in a table in the RITFORI library that are masked so that only your user profile has access except for users with *SECADM or *SYSADM.


**There are 6 initial steps**
1. **Download the Instructions PDF** In a browser go to https://github.com/RitFori/RitFori/blob/main/Instructions.pdf and click the "Download raw file" button (top right).  Read this document first.  There is also an "Instructions-Copy_and_Paste.txt" to make things easier.
2. **Create a User Profile**, **Download the repository**, copy it to your IBM i to /tmp
3. **Sign On**, **Unzip the repository** to /tmp/ritfori, compile and run **Acme Setup 1**. This sets up the user for SSH (required) and sets up the basic environment (Library and Directory structure).
4. **Sign off and on again**. Run **Acme Setup 2**. This installs and registers your account for “acme-official / acme.sh”. Then it creates a JKS with Let’s Encrypt CAs, issues your first certificate and adds it to the JKS.
5. This is the manual part. You need to configure ADMIN5 (IBM i Apache HTTP server) with the JKS as the TLS. You also have to add an Application name to the DCM, if you are going to use your certificate from the DCM and it needs an application.
6. Run **DCM Setup 3** if required.  This imports the Let’s Encrypt CAs and your certificate into the DCM and also attaches the application.

**The repeatable steps – can be run as scheduled jobs**
1. **Renew** your certificate.  This includes replacing the certificate in the JKS and the DCM if required moving the application from the old certificate to the new one.  The new certficate will not be used until the applications are restarted.
2. Run **LE_ADMIN5** to restart ADMIN5 so it picks up the new JKS.
3. Restart your TLS applications to pick the renewed certificate – you must do this manually or create a scheduled job to do so, when required.  The previous certificate will be used until this step is completed or the certificate expires.
4. Finally **DCM Delete Certificate** to remove the older certificate, before the next renew.

Normally you can use the same certificate for the RSE API and your applications.  The new certificate will not be used until the applications are restarted.

## Technical Details

### acme.sh

This repository uses Let's Encrypt for certificates (because it is free to use and a non-profit organisation) and acme.sh, ACME client, because it is a long standing open source repository.

acme.sh is used to create and renew TLS certificates.  It can be used with many Certificate providers.  I chose to use Let's Encrypt because it is free to use and is a nonprofit organisation.  It also has comprehensive documentation https://letsencrypt.org/docs/ & https://letsencrypt.org/how-it-works/

### Let's Encrypt

There are limits for using Let's Encrypt https://letsencrypt.org/docs/staging-environment/.  If you need to test acme.sh independently of this software you can use --staging on a --issue (create) but not on a --renew.  Don't use the same domain as a production one in use.

All the Let's Encrypt CAs are stored in github https://github.com/letsencrypt/website/tree/main/static/certs. The current CAs are in /2024.  Some new ones are in /gen-y which will be implemented on the 13th May 2026.  If you want to test using the new CAs you will need to add --cert-profile tlsserver before the 13th May.

### Ritfori does the following 
### * SETUP only
1. Creates a new account with Let's Encrypt using acme.sh.  This creates a key pair for your account.
2. Creates a new certificate using acme.sh. 
   - acme.sh does the following
     - Using your account - checks the ownership of the requested domain by using the DNS method.  Using an API token supplied by your DSN provider it finds your DNS entry and adds a TXT record to that subdomain or domain.  This is also known as acme-challenge.
	 - This record is then checked.  There is a delay loop to allow sufficient time.  If the token is incorrect, the record will not have been created.
	 - A CSR is created and sent to Let's Encrypt
	 - A certificate is requested from Let's Encrypt.  A number of files are returned, if successful.
	 - These TXT record is removed from the domain.

     - ** There are a number of methods other verification methods available.  The main one is Webroot which places a file onto your web server.  See https://github.com/acmesh-official/acme.sh?tab=readme-ov-file#%EF%B8%8F-supported-modes for other methods.

3. This certificate is then added to a JKS, along with the CA certificates.  This is because we need to use the IBM RSE APIs to put the certificates into the DCM.  In order to do this we need a TLS certificate for the RSE APIs. Chicken and Egg! 
4. Currently only able to be done manually using Web (HTTP) Administrator for i.  Enable TLS to the RSE API / ADMIN5 using the JKS.  Then restart ADMIN5.
5. Currently only able to be done manually using the DCM. Add an Application Definition will be added to certificate in the DCM.
6. Adds the certificate and it's CA certificates to the DCM.
7. Adds the Application Definition to the certificate.
8. The new certificate will be used by users after the HTTP server of your application is restarted.

### * Repeated Steps - can be added to a job scheduler
1. Renew the certificate before 90 days is up.  Let's Encrypt recommends 60 days.  This can be automated using a job scheduler.  The new certficate will be replaced in the JKS (for the first domain certficate created on the partition).  It will replaced in the DCM if the parameter is set to 'YES', in case there are only applications that don't require the DCM.
2. Restart ADMIN5 when convenient
3. Restart your applications when convenient
4. Delete the previous certificate before the next renew









