# Nexpose Scan Problem Monitor

require "nexpose"

# Need this since Ruby 2.x tries to use any set proxies.
ENV['http_proxy'] = nil
ENV['https_proxy'] = nil

# Set Nexpose user/pw
user = "<username>"
pass = "<password>"

# Set Nexpose console hostname and email address to send from.
nexpose_host = "<hostname or IP>"
nexpose_email = "<nexpose@example.com>"

def sendEmails(message)
    recipients = {
        "<your name>" => "<your.email@example.com>"
    }

    recipients.each do |name,addr|
        message = <<MESSAGE_END
From: Nexpose <#{nexpose_email}>
To: #{name} <#{addr}>
Subject: Possible Scan Problem
Importance: High

#{message}
MESSAGE_END

        # Send via local mail relay by default (sendmail/postfix/etc)
        Net::SMTP.start('localhost') do |smtp|
            smtp.send_message message, nexpose_email, addr
        end
    end
end
        

include Nexpose

# Create connection and log into Nexpose console.
nsc = Nexpose::Connection.new(nexpose_host, user, pass)
nsc.login

# Check for assets completed or being scanned if a scan has been running longer than this many minutes.
minutesAfterStart = 20

scans = nsc.activity

scans.each do |scan|
    # Alert if scan is in a failed state.
    if ["aborted", "error", "unknown"].include?(scan.status)
         sendEmails("#{nsc.sites.find {|s| s.id == scan.scan_id}.name} (#{scan.scan_id}) is in state #{scan.status}")
    end

    # If the scan has been running longer than minutesAfterStart, check the scan activity.
    if (Time.now.to_i - scan.start_time.to_time.to_i) > (minutesAfterStart * 60)
        diffMinutes = (Time.now.to_i - scan.start_time.to_time.to_i).to_f / 60.0
        ss = nsc.scan_statistics(scan.scan_id)
        if ss.tasks.active == 0 and ss.tasks.completed == 0
            # If no assets are being scanned and none have finished scanning...
            site = nsc.sites.find {|s| s.id == scan.site_id}
            sendEmails("#{site.name} (#{scan.scan_id.to_s}) has not scanned any assets since it started #{diffMinutes.round(2).to_s} minutes ago.")
        elsif ss.tasks.active == 0 and ss.tasks.pending > 0
            # If no assets are being scanned, but some are pending...
            site = nsc.sites.find {|s| s.id == scan.site_id}
            sendEmails("#{site.name} (#{scan.scan_id.to_s}) appears to have stopped scanning. No assets are currently being scanned and #{ss.tasks.pending.to_s} assets are still pending.")
        end
    end
end

