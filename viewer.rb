require 'sinatra'

class Log
  attr_accessor :log

  def initialize
    @log = ""
  end

  def clear
    @log.clear
  end

  def prepend(*pieces)
    [*pieces].reverse.each do |piece|
      log.prepend piece
      log.prepend "<br />"
    end
  end

  def connect(cdn, command)
    prepend "Connecting to #{cdn}, executing #{command}"
  end

  def poll(cdn)
    prepend "Polling #{cdn}"
  end

  def other(line)
    prepend line
  end
end

# Sinatra does funky magic with class-methods and instance-methods
# and I don't really want to spend the time to figure it out and make
# it better right now. Settling for a copout.
# # Sinatra does funky magic with class-methods and instance-methods
# and I don't really want to spend the time to figure it out and make
# it better right now. Settling for a copout.
LOG = Log.new

Thread.new do
  STDIN.each_line do |line|
    case line
    when /^connecting to (.+)/i
      parts = $1.split('|').map {|p| p.strip }
      LOG.connect parts[0], parts[1..-1].join('|')
    when /polling cdn (.+)/i
      LOG.poll $1
    else
      LOG.other line.inspect
    end
  end
end

class LogViewer < Sinatra::Base
  get '/log' do
    LOG.log
  end

  get '/clear' do
    LOG.clear
  end
end

LogViewer.run!

