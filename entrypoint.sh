#!/bin/bash

if [[ -z  $DOMAIN_NAME ]];
then
  echo "you should set DOMAIN_NAME variable "
  exit -1
fi

CERTIFICATE_DIRECTORY=/etc/myssl
mkdir -p $CERTIFICATE_DIRECTORY

if [[ ! -f $CERTIFICATE_DIRECTORY/privkey.pem ]];
then
cat > v3.ext <<EOF
subjectKeyIdentifier   = hash
authorityKeyIdentifier = keyid:always,issuer:always
basicConstraints       = CA:TRUE
keyUsage               = digitalSignature, nonRepudiation, keyEncipherment, dataEncipherment, keyAgreement, keyCertSign
subjectAltName         = DNS:$DOMAIN_NAME, DNS:*.$DOMAIN_NAME
issuerAltName          = issuer:copy
EOF
  openssl genrsa -out $CERTIFICATE_DIRECTORY/privkey.pem 2048
  openssl req -new -key $CERTIFICATE_DIRECTORY/privkey.pem -out $CERTIFICATE_DIRECTORY/request.csr -subj "/CN=*.$DOMAIN_NAME"
  openssl x509 -req -in $CERTIFICATE_DIRECTORY/request.csr -signkey $CERTIFICATE_DIRECTORY/privkey.pem -out $CERTIFICATE_DIRECTORY/certificate.pem -days 3650 -sha256 -extfile v3.ext
fi

if [[ ! -f $CERTIFICATE_DIRECTORY/ssl-dhparams.pem ]];
then
  openssl dhparam -out $CERTIFICATE_DIRECTORY/ssl-dhparams.pem 2048
fi

nginx -g "daemon off;" &

exec "$@"