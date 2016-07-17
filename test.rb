require 'resque'
require 'sinatra'
require 'tire'
require 'yajl/json_gem'
require 'csv'
require 'savon'
require 'json'
class Archive
  @queue = :logging

  def self.perform(ip, time, id)	
    puts "From queue " + @queue.to_s 
	
	Tire.index 'logs2' do      
      create
      store :ip => ip,   :time => time, :id => id
      refresh
    end
	
  end
end
get '/get/:id' do |id|
	Resque.enqueue(Archive, request.ip, Time.now.to_s, id.strip)
  'Welcome to all'
end