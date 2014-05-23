
app_root = File.expand_path('../..',__FILE__)

env = ENV['RACK_ENV']||'production'

case env
when 'development'
  unicorn_rb = "#{app_root}/config/unicorn.rb"
else
  unicorn_rb = "#{app_root}/config/unicorn.production.rb"
end

puts 'deploying sidekiq_web ...'

cmd = "RACK_ENV=#{env} cd #{app_root} && bundle exec unicorn -c #{unicorn_rb} -D"

puts "#{cmd}"

system(cmd)

puts 'deploying sidekiq_web DONE'

# puts 'press any key to continue...'
# name = STDIN.gets



