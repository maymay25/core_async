
app_root = File.expand_path('../..',__FILE__)

env = ENV['RACK_ENV']||'production'

def system_run(cmd)
  system(cmd)
  puts cmd
end

puts 'deploying sidekiq_workers ...'

n = ARGV[0].to_i

system_run("RACK_ENV=#{env} cd #{app_root} && bundle exec sidekiq -r #{app_root}/config/application.rb -C #{app_root}/sidekiq.yml -P #{app_root}/tmp/pids/sidekiq/sidekiq.pid.#{n} -d")

puts 'deploying sidekiq_workers DONE'
