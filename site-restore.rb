require "nexpose"
require "io/console"
require "yaml"

# Nexpose Site Restore tool
#
# Restores the full configuration of Nexpose sites from yaml files created by the site-backup.rb tool.
# This includes assigned assets, scan templates, schedules, etc.
#
# Example: ruby site-restore.rb <Nexpose console host> <site1.yml> <site2.yml> ...
# You will be prompted to log in, then it will go through each .yml file you specified and check for an existing site with that name.
# If a site is found with that name, it will first confirm the overwite action, then restore the config to that existing site.
# If no sites with that name are found, it will ask to create and restore to a new site.

# Need this since Ruby 2.x tries to use proxies.
ENV['http_proxy'] = nil
ENV['https_proxy'] = nil

include Nexpose

# Create connection and login
puts "Nexpose Login"
puts "-------------"
print "Username: "
username = $stdin.gets.chomp
print "Password: "
password = STDIN.noecho(&:gets).chomp
puts

server = ARGV[0]
ARGV.shift

@nsc = Connection.new(server, username, password)
@nsc.login

ARGV.each do |rFile|
    sitename = rFile.sub('.yml', '').gsub('%', '/').sub('.\\', '')
    puts "Checking for site: "+sitename+"..."

    namesIds = {}
    @nsc.sites.each {|site| namesIds[site.name] = site.id}

    site = ""
    if namesIds.keys.include?(sitename)
        site = Site.load(@nsc, namesIds[sitename])
        puts "Found existing site: "+sitename+" ("+site.id.to_s+")"
        print "Restore from file and overwrite this site? (y/n): "
        yesno = $stdin.gets.chomp
        if yesno != 'y'
            puts "Cancelling..."
            exit
        end
    else
        puts "No site named "+sitename+" found."
        print "Create it and restore to it? (y/n): "
        yesno = $stdin.gets.chomp
        if yesno != 'y'
            puts "Cancelling"
            exit
        end
    end

    puts "Loading restore file..."
    restoreSite = YAML.load(File.read(rFile))

    if site == ""
        restoreSite.id = -1
    else
        restoreSite.id = site.id
    end

    puts "Restoring site: "+sitename+"..."

    restoreSite.save(@nsc)

    puts "Done"
end