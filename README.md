# Nexpose Tools

This is a group of useful scripts that I use to monitor and fix issues that sometimes come up in Nexpose.

## Dependencies
All shell scripts need to be run from an account with sudo/root access, and all ruby scripts require Ruby 2.x, the "nexpose" gem, and a valid account on the Nexpose console with access to the resources that the script checks.

- - - -

## abort-scan.sh
This is an interactive script that allows for cancelling a stuck scan by updating its entry in the database. NOTE: This should only be used as a last resort when a scan is completely stuck and not actually running. This can happen if two or more scans are started using the same engine at the same time for example. The scan can get stuck before starting in this case and the engine is never really assigned to the scan.

Run the script on the Console server from an account that has sudo access. Also, local connections to the Nexpose database must be set to "trust" in */opt/rapid7/nexpose/nsc/nxpgsql/nxpdata/pg_hba.conf*. If you need to add the "trust" line to that conf file, run this command after editing it to reload the config:

    sudo -u nxpgsql /opt/rapid7/nexpose/nsc/nxpgsql/pgsql/bin/pg_ctl -D /opt/rapid7/nexpose/nsc/nxpgsql/nxpdata reload

When running the script, a list of running scans (as seen by the database) will be presented and you will be asked to enter the scan ID number for the scan that you'd like to cancel.


## engine-check.rb
This is a monitoring script intended to be run from a cron job. It checks the list of associated scan engines on the Nexpose Console using the API and emails the defined names/addresses if any are offline.

Before running, edit the script and fill in the variables for the nexpose hostname and email, as well as the Nexpose account to use, and the dictionary of recipients to send alerts to. The script uses the local mail relay (sendmail/postfix/etc) by default, so make sure that's configured or change it to a different one.


## fix-site-numbers sh/sql
This shell script is a tool for running the SQL query (in the .sql file) on the Nexpose database to fix a problem where some scan sites don't show up. Another symptom is that if you edit a Nexpose User, a series of error messages with an "Ok" button will pop up that have to be closed before getting to the user editing page.

Like the abort-scan.sh script, this needs to be run on the Console server and requires that local connections to the database be set to "trust".


## nexpose-problemmonitor.rb
This is a monitoring script intended to be run from a cron job. It will first check if any scans are in a failed state and email an alert to the defined recipients if so. If a Nexpose scan has been running longer than "X" minutes (where X is a configurable value), it will check to see if any assets have been scanned or are being scanned and will email an alert if no assets have been scanned yet. This is for alerting you if a scan gets stuck when trying to start.

Like the engine-check.rb script, edit the script to fill in the proper hostname, email, mail relay, and Nexpose account variables before using. 


## oid-check.sh
This is a tool for checking for bad OIDs in the Nexpose database. It will email the defined recipients using sendmail if a bad OID is detected.

If you do have an OID error, you can find the bad OID by starting a manual dump of the database (basically what the script does) with the following command. If you get an error with an OID pretty quickly, cancel with Ctrl+c and go to the next step. Only one bad OID at a time will be shown, so if you get one and delete it, re-run the db dump test. If no errors show up after about 10 seconds, you should be fine. 

    sudo /opt/rapid7/nexpose/nsc/nxpgsql/pgsql/bin/pg_dump -U nxpgsql -Fc  -f /backup_test.dump nexpose

If you do have OID errors, you can delete them with the following command. Replace 123456789 with the OID in the error message.

    sudo /opt/rapid7/nexpose/nsc/nxpgsql/pgsql/bin/psql -U nxpgsql -d nexpose -c "DELETE FROM pg_proc WHERE pronamespace = 123456789;"


## nsc_parser.py
This is a python module for parsing Nexpose logs. It returns a list of objects (one for each line) with the values parsed out into attributes.

Example usage:

    import nsc_parser
    log = nsc_parser.parse('/opt/rapid7/nexpose/nsc/logs/nsc.log')

