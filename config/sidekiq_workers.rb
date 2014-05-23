
app_root = File.expand_path('../..',__FILE__)

env = ENV['RACK_ENV']||'production'

puts 'deploying sidekiq_workers ...'

cmd ="RACK_ENV=#{env} cd #{app_root} && bundle exec sidekiq -r #{app_root}/config/application.rb -C #{app_root}/sidekiq.yml -d"

puts "#{cmd}"

system(cmd)

puts 'deploying sidekiq_workers DONE'
