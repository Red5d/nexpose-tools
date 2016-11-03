# Email all defined recipients if any Nexpose engines are offline.

require "nexpose"
require 'net/smtp'

# Need this since Ruby 2.x tries to use any set proxies.
ENV['http_proxy'] = nil
ENV['https_proxy'] = nil

include Nexpose

# Set Nexpose user/pw
user = "<username>"
pass = "<password>"

# Set Nexpose hostname and email address to send from
nexpose_host = "<hostname or IP>"
nexpose_email = "<nexpose@example.com>"

# Define recipient names/addresses
recipients = {
    '<your name>' => '<your.email@example.com>'
}

# Create connection and log into Nexpose console.
nsc = Connection.new(nexpose_host, user, pass)
nsc.login

# Check for offline engines.
offline = ""
nsc.engines.each do |eng|
    if eng.status != "Active"
        offline=offline+eng.name+" ("+eng.address+"): "+eng.status+"\n\n"
    end
end

if offline != ""
    recipients.each do |name,addr|
        message = <<MESSAGE_END
From: Nexpose <#{nexpose_email}>
To: #{name} <#{addr}>
Subject: Scan Engines Offline
Importance: High

The following scan engines are offline:
#{offline}
MESSAGE_END

        # Use the mail relay on localhost by default (sendmail/postfix/etc)
        Net::SMTP.start('localhost') do |smtp|
            smtp.send_message message, nexpose_email, addr
        end
    end
end
