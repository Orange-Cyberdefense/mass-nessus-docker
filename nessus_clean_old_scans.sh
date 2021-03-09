#!/bin/bash
# Deletes all scans older than X days/weeks

username="CHUSERNAME"
password="CHPASSWORD"
api_token="a9a84777-ac99-4a56-87fb-443232cdb95a"


#nessus_js=$(curl https://127.0.0.1:8834/nessus6.js -s --insecure -X GET )
#api_token=$(echo $nessus_js | sed 's/^.*\([a-z0-9]\{8\}-[a-z0-9]\{4\}-[a-z0-9]\{4\}-[a-z0-9]\{4\}-[a-z0-9]\{12\}\).*$/\1/')
#echo $api_token

data="{\"username\":\"$username\",\"password\":\"$password\"}"
token=$(curl https://127.0.0.1:8834/session -s --insecure -X POST -H "Content-Type: application/json" --data $data | cut -d ":" -f 2 | cut -d "\"" -f 2) # getting the authentication token
scans=$(curl https://127.0.0.1:8834/scans\? -s --insecure -X GET -H "X-Cookie: token=$token" | jq '.scans[] | .creation_date, .id') # getting the list of scans, retaining only creation_date and id

time_now=$(date +"%s") # timestamp from now
time_past=$((time_now-1209600)) # timestamp from 2 weeks ago


index=0
to_delete=0

for i in $scans
do
  if (( $to_delete > 0)) #creation_date too old, now getting the ID
  then
    echo "Deleting id $i aged $(date -d @$to_delete)"
    curl https://127.0.0.1:8834/scans/$i --insecure -X DELETE -H "X-Cookie: token=$token" -H "Content-Type: application/json"  -H "X-API-Token: $api_token"
    to_delete=0
  fi

  if [ $((index%2)) -eq 0 ] # creation_date
  then
    if (( $i < $time_past )) # if creation_date is older that time_past
    then
      to_delete=$i
    fi
  fi
  index=$((index+1))
done

echo "Done"
