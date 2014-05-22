puts 'starting...'

require File.expand_path('../config/application',  __FILE__)

require 'sidekiq/web'

map '/' do
  run Sidekiq::Web
end

puts 'starting...ok'

unless RUBY_PLATFORM =~ /mingw/
  memory_usage = (`ps -o rss= -p #{$$}`.to_i / 1024.00).round(2)
  puts "=> Memory usage: #{memory_usage} Mb"
end