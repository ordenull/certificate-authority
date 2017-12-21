#!/bin/bash

THRESHOLD=`expr 86400 \* 90`

TIMESTAMP=$(date +%s)

while IFS= read -r -d '' certificate; do
  DATE=`openssl x509 -in "${certificate}" -text -noout | grep "Not After" | sed -E "s/.*: //"`
  EXPIRATION=`date -jf '%b %d %T %Y %Z' +%s "${DATE}"`
  LEFT=`expr $EXPIRATION - $TIMESTAMP`

  if [ "$LEFT" -lt "$THRESHOLD" ]; then
    echo $DATE $certificate
  fi
done < <(find . -type f -name '*.crt' -print0)
