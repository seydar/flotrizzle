REDIS = Redis.new "/tmp/demo.sock"
cdns = STDIN.read.split

loop do
  cdns.each do |cdn|
    data = REDIS.get cdn
    Thread.new { follow_config data }
  end
end

