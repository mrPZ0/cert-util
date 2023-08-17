#!/bin/bash
url=$1
site=$(echo $url | awk -F'/' '{print $3}')
openssl s_client -connect  $site:443 -showcerts #2>&1 | openssl x509 -noout -issuer -subject -dates