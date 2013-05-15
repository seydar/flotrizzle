require 'open-uri'
require 'timers'
require 'redis'

require File.join(File.expand_path(File.dirname(__FILE__)), 'helpers.rb')

# The system shall poll 4 CDNs for a JSON configuration file.
cdns  = STDIN.read.split

REDIS = Redis.new

timers = Timers.new
# The system shall poll every CDN in 5 minute intervals.
every_five = timers.every(5 * 60) do
  cdns.threaded_each do |cdn|
    poll cdn do |data|
      # The system shall save the JSON configuration file in a meaningful way
      # in a Reddis.io data store upon successful poll.
      REDIS[cdn] = data.to_json

      # The system shall invoke a post script on every server specified in
      # the JSON configuration upon successful poll (simulate this, but show
      # code to SSH into a server).
      data['servers'].threaded_each do |server|
        puts "\n#{cdn.to_sym.object_id} | Connecting to " +
             "#{data['server_admins'].first}:***@#{server} | " +
             "`#{data['post_script']}`"

        connect_to server, data['server_admins'].first, "password" do |ssh|
          ssh.exec data['post_script']
        end
      end
    end
  end
end

loop do
  timers.wait
end

