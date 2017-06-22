require "nexpose"
require "io/console"
require "yaml"

# Nexpose Site Backup tool
#
# Backs up full configuration of Nexpose sites to yaml files.
# This includes assigned assets, scan templates, schedules, etc.
#
# Example: ruby site-backup.rb <Nexpose console host>
# You will be prompted to log in, then asked for the ID number of the site(s) you want to back up.
# Sites will be saved as .yml files in the current directory and named with the site name.

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
puts ""

server = ARGV[0]
if ARGV.length > 0
    server = ARGV[0]
end
@nsc = Connection.new(server, username, password)
@nsc.login

puts "Enter a site ID number to back up its configs to a yml file. Enter 'exit' when finished."
print "Site ID: "
siteid = $stdin.gets.chomp

while siteid != "exit" do
    if siteid == "all"
        @nsc.sites.each do |s|
            site = Site.load(@nsc, s.id)
    
            sitename = site.name.gsub('/', '%')
            
            File.open(sitename+'.yml', 'wb'){|f|
                f.write(YAML.dump(site))
            }
            puts "Saved: "+sitename+'.yml'
        
            siteid = "exit"
        end
    else
        site = Site.load(@nsc, siteid)
        
        sitename = site.name.gsub('/', '%')
        
        File.open(sitename+'.yml', 'wb'){|f|
            f.write(YAML.dump(site))
        }
        puts "Saved: "+sitename+'.yml'
        
        puts
        print "Site ID: "
        siteid = $stdin.gets.chomp
    end
end
