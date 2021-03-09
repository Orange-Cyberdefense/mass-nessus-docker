#!/bin/bash
# Downloads the latest release of Nessus from officiel website for Debian on AMD64

releases=$(curl https://www.tenable.com/downloads/api/v1/public/pages/nessus -X GET -s | jq '.downloads[] | .id, .file')

index=0
id=0
for i in $releases
do
  if [ $((index%2)) -eq 0 ] # ID
  then
    id=$i
  else # file name
    if echo $i | grep -qE "debian.*amd64"
    then
      break
    fi
  fi
  index=$((index+1))
done

url="https://www.tenable.com/downloads/api/v1/public/pages/nessus/downloads/$id/download?i_agree_to_tenable_license_agreement=true"
wget -O nessus.deb --quiet --user-agent='Mozilla/5.0 (Windows NT 10.0; WOW64; rv:48.0) Gecko/20100101 Firefox/48.0' --header='Upgrade-Insecure-Requests: 1' $url
