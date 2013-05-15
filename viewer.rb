require 'sinatra'

class Log
  attr_accessor :log

  def initialize
    @log = []
  end

  def clear
    @log.clear
  end

  def prepend(piece)
    log.unshift "<br />"
    log.unshift piece
    log.unshift "#{Time.now} "
  end

  def connect(id, cdn, command)
    prepend "Connecting to #{cdn} (#{id}), executing #{command}"
  end

  def poll(id, cdn)
    prepend "Polling #{cdn} (#{id})"
  end

  def other(line)
    prepend line
  end
end

# Sinatra does funky magic with class-methods and instance-methods
# and I don't really want to spend the time to figure it out and make
# it better right now. Settling for a copout.
LOGS = Hash.new {|h, k| h[k] = Log.new }

Thread.new do
  begin
    STDIN.each_line do |line|
      case line.chomp
      when /connecting to/i
        parts = line.chomp.split '|'
        id  = parts[0].strip
        cdn = parts[1].strip.match(/connecting to (.+)$/i).captures[0]
        cmd = parts[2..-1].join('|').strip

        LOGS[:main].connect id, cdn, cmd
        LOGS[id.to_i].connect id, cdn, cmd
      when /polling cdn/i
        parts = line.chomp.split '|'
        id  = parts[0].strip
        cdn = parts[1].strip.match(/polling cdn (.+)/i).captures[0]

        LOGS[:main].poll id, cdn
        LOGS[id.to_i].poll id, cdn
      when ""
      else
        LOGS[:main].other line.chomp.inspect
      end
    end
  rescue => e
    p e
  end
end

class LogViewer < Sinatra::Base
  get '/' do
    <<-END
<html>
  <head>
    <script type='text/javascript' src='/jquery.js'></script>
    <script>
      function updateBody(){
        $.ajax({
          url: "log",
          type: "GET",
          success: function(data) { $('body').html(data); },
          dataType: 'html'
        });

        setTimeout(updateBody, 5000);
      }
      updateBody();
    </script>
  </head>
  <body>
  </body>
</html>
END
  end

  get '/log' do
    puts "responding"
    LOGS[:main].log.join
  end

  get '/clear' do
    LOGS[:main].clear
  end

  get '/jquery.js' do
    File.read 'jquery.js'
  end

  get %r{(\d+)} do
    LOGS[params[:captures].first.to_i].log.join
  end
end

LogViewer.run!

