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
    LOG.log
  end

  get '/clear' do
    LOG.clear
  end

  get '/jquery.js' do
    File.read 'jquery.js'
  end
end

LogViewer.run!

