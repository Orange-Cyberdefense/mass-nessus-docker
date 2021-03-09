#!/bin/bash
# Runs the Nessus daemon and check if still running every 60s

# Start the first process
/etc/init.d/nessusd start -D
status=$?
if [ $status -ne 0 ]; then
  echo "Failed to start nessusd: $status"
  exit $status
fi

while sleep 60; do
  ps aux |grep nessusd |grep -q -v grep
  NESSUS_STATUS=$?

  if [ $NESSUS_STATUS -ne 0 ]; then
    echo "Re-starting Nessus"
    /etc/init.d/nessusd restart -D
  fi
done
