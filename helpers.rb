require 'json'
require 'thread'
require 'net/ssh'
require 'gmail'

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
  puts "\n#{cdn.to_sym.object_id} | Polling CDN #{cdn}"
  data = JSON.load open(cdn)
  blk.call data
  data
rescue => e
  email cdn, e
end

# Connect to a server via SSH
def connect_to(server, login, password, &blk)
  blk.call
  Net::SSH.start(server, login, :password => password) {|ssh| blk.call ssh }
end

# The system shall email the CDN, time of failure, and a link to view the
# activity log to the system administrators specified in last successful JSON
# configuration upon a poll failure.
def email(cdn, e)
  data = JSON.load REDIS[cdn]
  link = "http://logserver.flocasts.com/#{cdn.to_sym.object_id}"

  tox  = data['server_admins']
  from = 'flocast.bordercollie@gmail.com'
  subj = '[ERROR] ' + cdn
  text = [link, "\n", e.message, e.class, e.backtrace].join "\n"

  Gmail.new from, 'flocastayo' do |gmail|
    gmail.deliver do
      to tox
      subject subj
      text_part { body text }
    end
  end
end

