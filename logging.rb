require 'resque'
require 'tire'
require 'yajl/json_gem'
class Archive
  @queue = :logging

  def self.perform(ip, time)	
    puts "From queue " + @queue.to_s + ": (" + ip + ", " + time.to_s + ")"
	
	Tire.index 'logs' do      
      create
      store :ip => ip,   :time => time
      refresh
    end
	
  end
end

class RackMiddleware
  def initialize(appl)
    @appl = appl
  end
  def call(env)
    
    status, headers, body = @appl.call(env) # call our Sinatra app    
	loginfo = {}
    loginfo[:ip] =  "IP: #{env['REMOTE_ADDR']}"; # display on console
	loginfo[:time] = Time.now
	Resque.enqueue(Archive, loginfo[:ip], loginfo[:time])
    [status, headers, body]
  end
end