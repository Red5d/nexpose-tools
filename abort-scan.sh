#! /bin/bash

# Script for clearing a stuck Nexpose scan

# Display list of running scans
sudo -u nxpgsql -H -- /opt/rapid7/nexpose/nsc/nxpgsql/pgsql/bin/psql -nU nxpgsql -d nexpose -c "SET search_path = nxsilo_default;SELECT * FROM scans WHERE status = 'U';"
scanid=0
# If scan ID number not already given as the first parameter, ask for it.
if [ "$1" == "" ];then
  echo -n "Enter scan ID number to abort: "
  read scanid
else
  scanid=$1
fi

# Confirm action
echo -n "Confirm: Abort scan $scanid (y/n)?: "
read yesno
if [ "$yesno" == "y" ];then
  # Update scan status and end time in db to clear it.
  sudo -u nxpgsql -H -- /opt/rapid7/nexpose/nsc/nxpgsql/pgsql/bin/psql -nU nxpgsql -d nexpose -c "SET search_path = nxsilo_default;UPDATE dispatched_scans SET status='R' WHERE scan_id = $scanid; UPDATE scans SET end_time = now(), status = 'A' WHERE scan_id = $scanid;"
else
  echo "Cancelled"
  exit 0
fi
