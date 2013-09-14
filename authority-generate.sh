#!/bin/bash

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
source lib/functions.sh

load_config

generate_openssl_config

if [ -e "$DATA/${NICKNAME}.crt" ]; then
  print_error "$DATA/${NICKNAME}.crt exists; You already have an active CA named '$NICKNAME'"
  exit 1
fi

if [ -e "$DATA/private/${NICKNAME}.key" ]; then
  print_warning "$DATA/private/${NICKNAME}.key already exists? Trustfully assuming you generated the CA private key yourself, we won't overwrite it"
else
  print_info "Generating a $BITS bit private RSA key"
  openssl genrsa -rand "$DATA/private/random_seed" -out "$DATA/private/$NICKNAME".key $BITS >> $LOG 2>&1 || {
    print_error "Unable to create an RSA private key for the new CA"
    exit 1;
  }
fi

if [ -L "$DATA/private/authority.key" ]; then
  rm "$DATA/private/authority.key"
fi
ln -s "$DATA/private/$NICKNAME".key "$DATA/private/authority.key"

print_info "Generating a self signed certificate with for $NICKNAME"
SUBJECT="/CN=$NICKNAME/O=$ORGANIZATION/C=$COUNTRY"
openssl req -x509 -new -nodes -days 3650 \
       -subj "$SUBJECT" \
       -config "$DATA/generated.cnf" \
       -key "$DATA/private/authority.key" \
       -out "$DATA/$NICKNAME.crt" >> $LOG 2>&1

if [ ! -e "$DATA/${NICKNAME}.crt" ]; then
  print_error "Unable to create a self signed certificate"
  exit 1
fi

if [ -L "$DATA/authority.crt" ]; then
  rm "$DATA/authority.crt"
fi
ln -s "$DATA/$NICKNAME".crt "$DATA/authority.crt"

verify_ca

print_info "All done, you can now distribute '$DATA/$NICKNAME.crt' to your users"
