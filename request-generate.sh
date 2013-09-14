#!/bin/bash

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
source lib/functions.sh

load_config
verify_ca

if [ $# -lt 1 ]; then
  echo "usage: $0 example.com"
  exit 1;
fi
CN="$1"; shift

mkdir -p "$DATA/$CN"

print_info "Generating a $BITS bit private key"
rm -f "$DATA/$CN/$CN.key"
# OpenSSL doesn't seem to update the random seed file automatically
# I am not sure if it's safe to use the same seed for the CA and all
# other RSA keys, so i'll leave it out for now
# -rand $DATA/private/random_seed
openssl genrsa -out "$DATA/$CN/$CN.key" $BITS >> $LOG 2>&1 || {
  print_error "Unable to create an RSA private key for $CN"
  exit 1;
}

print_info "Generating a certificate signing request"

SUBJECT="/CN=$CN/O=$ORGANIZATION/C=$COUNTRY"

rm -f "$DATA/$CN/$CN.csr"
openssl req -new -config "$DATA/generated.cnf" \
                 -subj "$SUBJECT" \
                 -key "$DATA/$CN/$CN.key" \
                 -out "$DATA/$CN/$CN.csr" >> $LOG 2>&1

if [ ! -e "$DATA/$CN/$CN.csr" ]; then
  print_error "Unable to create a certificate signing request for $CN"
  exit 1
fi

print_info "Generated CSR with the filename '$DATA/$CN/$CN.csr'"
print_info "If you now wish to sign it, use:"
print_info "    No aliases:          ./request-sign.sh $CN"
print_info "    Web server alias:    ./request-sign.sh $CN www.$CN"
print_info "    Wildcard:            ./request-sign.sh $CN *.$CN"
