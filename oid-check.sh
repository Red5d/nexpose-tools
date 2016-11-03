#! /bin/bash

# Check for bad OIDs in Nexpose database.

timeout 5s /opt/rapid7/nexpose/nsc/nxpgsql/pgsql/bin/pg_dump -U nxpgsql -Fc -f /tmp/oid-check.dump nexpose

if [ ! -f /tmp/oid-check.dump ];then
    sendmail "your.email@example.com" <<EOF
Subject: testing oid check
From: Nexpose <nexpose@example.com>
Bad OIDs detected in the Nexpose Database. Remove them before backing up.
EOF
else
  rm /tmp/oid-check.dump
fi

