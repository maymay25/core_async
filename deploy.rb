

app_root = File.expand_path('..',__FILE__)
env = ENV['RACK_ENV']||'production'

command, type = ARGV[0], ARGV[1]

case type
when 'workers'
  process_sum = (tmp=ARGV[2].to_i)>0 ? tmp : 1
  case command
  when 'start'
  process_sum.times do
    system("RACK_ENV=#{env} bundle exec ruby #{app_root}/config/sidekiq_workers.rb")
    sleep 3
    cmd = "ps -ef | grep sidekiq"
    puts "\n******** #{cmd} ********"
    system(cmd)
  end
  when 'stop'
    #TODO
  when 'restart'
    #TODO
  end
when 'web'
  case command
  when 'start'
    system("RACK_ENV=#{env} bundle exec ruby #{app_root}/config/sidekiq_web.rb")
    sleep 3
    cmd = "ps -ef | grep core_async/config/unicorn.rb"
    puts "\n******** #{cmd} ********"
    system(cmd)
  when 'stop'
    system("kill `cat #{app_root}/tmp/pids/core_async_web.pid`")
  when 'restart'
    system("kill -usr2 `cat #{app_root}/tmp/pids/core_async_web.pid`")
  end

when 'schedule'
  case command
  when 'start'
    system("RACK_ENV=#{env} bundle exec clockworkd -c #{app_root}/config/sidekiq_schedule.rb --pid-dir=#{app_root}/tmp/pids --log-dir=#{app_root}/log --log start")
    sleep 3
    cmd = "ps -ef | grep sidekiq_schedule"
    puts "\n******** #{cmd} ********"
    system(cmd)
  when 'stop'
    system("RACK_ENV=#{env} bundle exec clockworkd -c #{app_root}/config/sidekiq_schedule.rb --pid-dir=#{app_root}/tmp/pids --log-dir=#{app_root}/log --log stop")
  when 'restart'
    system("RACK_ENV=#{env} bundle exec clockworkd -c #{app_root}/config/sidekiq_schedule.rb --pid-dir=#{app_root}/tmp/pids --log-dir=#{app_root}/log --log restart")
  end
else
  msg = <<-EOF

    usage :

    1. start sidekiq workers

       >>  ruby deploy.rb start workers [process_sum]

    2. start sidekiq web monitor

       >>  ruby delopy.rb start web

    3. start schedule tasks

       >>  ruby deploy.rb start schedule

    tips :

      1. default ENVIRONMENT is `production`. change it with RACK_ENV

         >>  RACK_ENV=development ruby deploy.rb *ARGV

  EOF
  puts msg
end