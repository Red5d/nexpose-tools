#! /bin/bash

/opt/rapid7/nexpose/nsc/nxpgsql/pgsql/bin/psql -f fix-site-numbers.sql -U nxpgsql nexpose
