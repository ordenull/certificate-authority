certificate-authority
=====================

## Overview

A tool for creating and managing a functioning intranet certificate authority.
Designed to live in a small encrypted file container.

## Usage

Use the `data/globals.sh-sample` as a template to create `data/globals.sh` :

    # Private Key Length
    BITS=2048

    # Nickname will be the CN of the certificate
    NICKNAME="Widgets Incorporated Root CA"

    # Organization or company name
    ORGANIZATION="Widgets Incorporated"

    # Country code
    COUNTRY="US"

    # CA certificate URL (optional, comment out if not used)
    CRT_URL="pki.widgets.com/root.crt"

    # Certificate revocation list URL (optional, comment out if not used)
    CRL_URL="pki.widgets.com/root.crl"

Generate CA key, certificate and other data :

    ./authority-generate.sh

    The '/media/crypt/data/private/random_seed' is missing, making a new one
    Generating an openssl configuration file in /media/crypt/data/generated.cnf
    Generating a 2048 bit private RSA key
    Generating a self signed certificate with for Widgets Incorporated Root CA
    The CA serial number tracker is missing, a new one will be generated.
    The CA revocation number tracker is missing, a new one will be generated.
    The CA index is missing, a new one will be generated.
    All done, you can now distribute '/media/crypt/data/Widgets Incorporated Root CA.crt' to your users

Generate a certificate for one of your servers :

    ./request-generate.sh ilo.example.com
    Generating a 2048 bit private key
    Generating a certificate signing request
    Generated CSR with the filename '/media/crypt/data/ilo.example.com/ilo.example.com.csr'
    If you now wish to sign it, use:
    No aliases:          ./request-sign.sh ilo.example.com
    Web server alias:    ./request-sign.sh ilo.example.com www.ilo.example.com
    Wildcard:            ./request-sign.sh ilo.example.com *.ilo.example.com

Sign the request with the certificate authority :


    ./request-sign.sh ilo.example.com *.ilo.example.com
    Generating a /media/crypt/data/conf/usr_cert.cnf openssl config file
    Including DNS alias: *.ilo.example.com
    Generating an openssl configuration file in /media/crypt/data/generated.cnf
    Using configuration from /media/crypt/data/generated.cnf
    Check that the request matches the signature
    Signature ok
    Certificate Details:
            Serial Number: 223195403517952 (0xcafebabe0000)
            Validity
                Not Before: Sep 14 21:14:08 2013 GMT
                Not After : Sep 14 21:14:08 2014 GMT
            Subject:
                countryName               = US
                organizationName          = Widgets Incorporated
                commonName                = ilo.example.com
            X509v3 extensions:
                X509v3 Extended Key Usage: 
                    TLS Web Server Authentication, TLS Web Client Authentication
                X509v3 Subject Alternative Name: 
                    DNS:ilo.example.com, DNS:*.ilo.example.com
                Authority Information Access: 
                    CA Issuers - URI:pki.widgets.com/root.crt
    
                X509v3 Subject Key Identifier: 
                    C7:4A:A1:EB:D1:43:56:28:DB:EA:DF:DC:AA:90:97:33:23:73:7B:70
                X509v3 Authority Key Identifier: 
                    keyid:0F:B1:D0:2E:A5:52:F8:FE:75:32:B2:9F:AE:33:A1:4C:6B:37:3B:A2
    
                X509v3 CRL Distribution Points: 
    
                    Full Name:
                      URI:pki.widgets.com/root.crl
    
                X509v3 Basic Constraints: 
                    CA:FALSE
    Certificate is to be certified until Sep 14 21:14:08 2014 GMT (365 days)

    Write out database with 1 new entries
    Data Base Updated
    Signed a certificate with the filename '/media/crypt/data/ilo.example.com/ilo.example.com.crt'

## Tips

Keep your private keys, private. Save them on encrypted storage such as TrueCrypt or keep them
on a machine that's isolated from the network with resonable physical security.

##Copyright and License

Copyright (C) 2013 [Stan Borbat](http://stan.borbat.com)

Stan Borbat can be contacted at: stan@borbat.com

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

  http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.
