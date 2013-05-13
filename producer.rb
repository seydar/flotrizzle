require 'open-uri'
require 'json'
require 'timers'
require 'redis'
require 'thread'

REDIS = Redis.new "/tmp/demo.sock"

def poll(cdn)
  # The system shall save the JSON configuration file in a meaningful way in a
  # Reddis.io data store upon successful poll.
  data = JSON.load open(cdn)
  REDIS.set cdn, data.to_json

  Thread.new { follow_config data }
end

# The system shall poll 4 CDNs for a JSON configuration file.
cdns = STDIN.read.split

# The system shall poll every CDN in 5 minute intervals.
timers.every(5 * 60) { cdns.each {|cdn| Thread.new { poll cdn } } }

