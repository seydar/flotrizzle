require 'open-uri'
require 'json'
require 'timers'
require 'redis'
require 'thread'
require 'net/ssh'

REDIS = Redis.new "/tmp/demo.sock"

def poll(cdn)
  # The system shall save the JSON configuration file in a meaningful way in a
  # Reddis.io data store upon successful poll.
  data = JSON.load open(cdn)
  REDIS.set cdn, data.to_json

  follow_config data
end

def follow_config(data)
  # The system shall invoke a post script on every server specified in the JSON
  # configuration upon successful poll (simulate this, but show code to SSH into
  # a server).
  data['servers'].each do |server|
    Thread.new do
      Net::SSH.start server,
                     data['server_admins'].first,
                     :password => "password" do |ssh|
        ssh.exec data['post_script']
      end
    end
  end
end

# The system shall poll 4 CDNs for a JSON configuration file.
cdns = STDIN.read.split

# The system shall poll every CDN in 5 minute intervals.
timers.every(5 * 60) { cdns.each {|cdn| Thread.new { poll cdn } } }

