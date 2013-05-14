require 'sinatra'
require 'sinatra/async'

# Sinatra does funky magic with class-methods and instance-methods
# and I don't really want to spend the time to figure it out and make
# it better right now. Settling for a copout.
LOG = ''

class LogViewer < Sinatra::Base
  register Sinatra::Async

  get '/' do
    log
  end

  get '/clear' do
    LOG.clear
  end

  def connect(cdn, command)
    LOG << "Connecting to #{cdn}, executing #{command}"
    LOG << "<br />"
  end

  def poll(cdn)
    LOG << "Polling #{cdn}"
    LOG << "<br />"
  end

  def other(line)
    LOG << line
    LOG << "<br />"
  end
end

def log
  LogViewer.new!
end

Thread.new do
  STDIN.each_line do |line|
    case line
    when /connecting to (.+) | (.*)/i
      log.connect $1, $2
    when /polling cdn (.+)/i
      log.poll $1
    else
      log.other line
    end
  end
end

