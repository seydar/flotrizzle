require 'open-uri'
require 'json'
require 'timers'
require 'redis'
require 'thread'
require 'net/ssh'

module Enumerable
  # Since I was using this too much, this will run a block for each element
  # in an enumerable object in a separate thread, returning the threads in
  # an array at the end so you can #join them all if you'd like.
  def threaded_each(&blk)
    map {|i| Thread.new { blk.call i } }
  end
end

# HTTP request to CDN, parse the data, then do magic at it.
def poll(cdn, &blk)
  puts "\nPolling CDN #{cdn}"
  data = JSON.load open(cdn)
  blk.call data
  data
end

# Connect to a server via SSH
def connect_to(server, login, password, &blk)
  blk.call
  #Net::SSH.start(server, login, :password => password) {|ssh| blk.call ssh }
end

# The system shall poll 4 CDNs for a JSON configuration file.
cdns  = STDIN.read.split

REDIS = Redis.new

threads = []
timers = Timers.new
# The system shall poll every CDN in 5 minute intervals.
every_five = timers.every(5) do
  threads += cdns.threaded_each do |cdn|
    puts "\nStarting up #{cdn}"

    poll cdn do |data|
      # The system shall save the JSON configuration file in a meaningful way
      # in a Reddis.io data store upon successful poll.
      REDIS[cdn] = data.to_json

      # The system shall invoke a post script on every server specified in
      # the JSON configuration upon successful poll (simulate this, but show
      # code to SSH into a server).
      threads += data['servers'].threaded_each do |server|
        connect_to server, data['server_admins'].first, "password" do |ssh|
          puts "\nConnecting to #{data['server_admins']}:***@#{server} | " +
               "running `#{data['post_script']}`"
          #ssh.exec data['post_script']
        end
      end
    end
  end
end

#loop do
  timers.wait
  
  # This thread is live updating, so the iterator has to be as well
  i = 0
  while i < threads.size
    threads[i].join
    i += 1
  end
#end

