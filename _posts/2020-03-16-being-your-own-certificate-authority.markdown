---
title: Being Your Own Certificate Authority
layout: post
subtitle: Useful openssl commands to create certificates
bigimg: /uploads/samobor-2018.jpg
tags: [openssl, x509, https]
---

Originally posted on [Medium](https://medium.com/@MiroslavResetar/being-ca-86b09ac175b1).

## Generating Self-Signed Certificates

From time to time there is a need to generate X.509 certificates. In some cases it is enough to generate self signed certificates. This can be achieved by one-line command such as:

```bash
openssl req -x509 -sha256 -nodes -days 365 -newkey rsa:2048 -keyout privateKey.key -out certificate.crt
```

Commands such as above can be found at The Most Common OpenSSL Commands, very usefull reference for OpenSSL tool. 
If, for some reason, self signed certificate is not what you need you can always be your own certificate authority.

## Generating Certificates Using Local CA

### Step 1: Root Key and Certificate

For CA you need private key and certificate. Private key can be generated with command:
```bash
openssl genrsa -des3 -out rootCA.key 4096
```

Above command created a file rootCA.key which has private key of length 4 KB and encoded in triple DES. Second step is to create public key for CA.

```bash
openssl req -x509 -new -nodes -key rootCA.key -sha256 -days 730 -out my-root-ca-cert.pem
```

### Step 2: Server(s) Key and Certificate

For each of the server we can use our root CA to sign certificates. But first we need to create private key for the server. Private key will not be shared with our CA. Command is similar to the first one for the CA:

```bash
openssl genrsa -out server-one-key.pem 2048
```

For this private key we stick to the defaults. It generates 2 kilobytes key which is not encrypted (so no password needed). 
Next step is to generate Certificate Signing Request (CSR) file

```bash
openssl req -new -key server-one-key.pem -out server-one-key.csr
```

We then need to use this .csr file together with root CA key and certificate to sign certificate for the server:

```bash
openssl x509 -req -in server-one-key.csr -CA my-root-ca-cert.pem -CAkey rootCA.key -CAcreateserial -out server-one-cert.pem -days 3650 -sha256
```

### Checking Certificates and Keys

In the end two nice commands to check key and certificate:
To check private key

```bash
openssl rsa -in server-one-key.pem -check
```

To check certificate

```bash
openssl x509 -in server-one-cert.pem -text -noout
```

Hope it helps somewhat.
Miro
