require 'open-uri'
require 'json'
require 'timers'
require 'redis'
require 'thread'
require 'net/ssh'

module Enumerable
  def threaded_each(&blk)
    map {|i| Thread.new { blk.call i } }
  end
end

def poll(cdn, &blk)
  puts "Polling CDN"
  data = JSON.load open(cdn)
  blk.call data
  data
end

def connect_to(server, login, password, &blk)
  puts "Connecting to #{login}:***@#{server}"
  #Net::SSH.start(server, login, :password => password) {|ssh| blk.call ssh }
end

# The system shall poll 4 CDNs for a JSON configuration file.
cdns  = STDIN.read.split

REDIS = Redis.new "/tmp/demo.sock"

# The system shall poll every CDN in 5 minute intervals.
timers.every(5 * 60) do
  cdns.threaded_each do |cdn|
    poll cdn do |data|
      # The system shall save the JSON configuration file in a meaningful way
      # in a Reddis.io data store upon successful poll.
      REDIS.set cdn, data.to_json

      # The system shall invoke a post script on every server specified in
      # the JSON configuration upon successful poll (simulate this, but show
      # code to SSH into a server).
      data['servers'].threaded_each do |server|
        connect_to server, data['server_admins'].first, "password" do |ssh|
          ssh.exec data['post_script']
        end
      end
    end
  end
end

