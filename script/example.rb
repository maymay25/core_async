
ENV['RACK_ENV']||='development'

app_root = File.expand_path('../..',__FILE__)

require "#{app_root}/config/core_async_server.rb"


#some custom code

#trackset = TrackSet1.first

# hash = trackset.attributes.symbolize_keys.merge(uid: 11111, op_type: 2)

# p hash[:title]

trackset = TrackSet1.new(uid:11111,op_type:2)

p trackset
