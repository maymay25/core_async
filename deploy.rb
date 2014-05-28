
require 'find'

app_root = File.expand_path('..',__FILE__)
env = ENV['RACK_ENV']||'production'

command, type = ARGV[0], ARGV[1]

def ps_ef_grep(msg)
  cmd = "ps -ef | grep #{msg}"
  puts "\nuse following line to check process\n> #{cmd}"
end

def fetch_sidekiq_pid_files(path)
  left_str = "sidekiq.pid."
  str_length = left_str.length
  pid_files = Find.find(path).to_a.select{|path| file_name=File.basename(path) ; file_name[0,str_length]==left_str }
  pid_files.sort_by{|path| path.split('.')[-1].to_i }
end

case type
when 'sidekiq'
  process_sum = (tmp=ARGV[2].to_i)>0 ? tmp : 1
  case command
  when 'stop'
    pid_path = "#{app_root}/tmp/pids/sidekiq"
    pid_files = fetch_sidekiq_pid_files(pid_path)
    if pid_files.length > 0
      pid_files.each do |file|
        system("kill `cat #{file}`")
      end
    else
      puts "there was no pid files found, maybe already stoped. check it yourself."
    end
  when 'start','restart'
    pid_path = "#{app_root}/tmp/pids/sidekiq"
    pid_files = fetch_sidekiq_pid_files(pid_path)
    pid_sum = pid_files.length
    if pid_sum > 0
      if process_sum > pid_sum
        pid_files.each do |file|
          system("kill -usr2 `cat #{file}`")
        end
        (pid_sum..(process_sum-1)).each do |n|
          system("RACK_ENV=#{env} bundle exec ruby #{app_root}/config/sidekiq_workers.rb -P #{pid_path}/sidekiq.pid.#{n}")
        end
      elsif process_sum < pid_sum
        cache_sum = 0
        pid_files.each do |file|
          if cache_sum < process_sum
            system("kill -usr2 `cat #{file}`")
            cache_sum += 1
          else
            system("kill `cat #{file}`")
          end
        end
      elsif process_sum == pid_sum
        pid_files.each do |file|
          system("kill -usr2 `cat #{file}`")
        end
      end
    else
      process_sum.times do |n|
        system("RACK_ENV=#{env} bundle exec ruby #{app_root}/config/sidekiq_workers.rb -P #{pid_path}/sidekiq.pid.#{n}")
      end
    end
  end
  ps_ef_grep('sidekiq')
when 'web'
  case command
  when 'start'
    system("RACK_ENV=#{env} bundle exec ruby #{app_root}/config/sidekiq_web.rb")
  when 'stop'
    system("kill `cat #{app_root}/tmp/pids/core_async_web.pid`")
  when 'restart'
    system("kill -usr2 `cat #{app_root}/tmp/pids/core_async_web.pid`")
  end
  ps_ef_grep('core_async/config/unicorn.rb')
when 'schedule'
  case command
  when 'start'
    system("RACK_ENV=#{env} bundle exec clockworkd -c #{app_root}/config/sidekiq_schedule.rb --pid-dir=#{app_root}/tmp/pids --log-dir=#{app_root}/log --log start")
  when 'stop'
    system("RACK_ENV=#{env} bundle exec clockworkd -c #{app_root}/config/sidekiq_schedule.rb --pid-dir=#{app_root}/tmp/pids --log-dir=#{app_root}/log --log stop")
  when 'restart'
    system("RACK_ENV=#{env} bundle exec clockworkd -c #{app_root}/config/sidekiq_schedule.rb --pid-dir=#{app_root}/tmp/pids --log-dir=#{app_root}/log --log restart")
  end
  ps_ef_grep('sidekiq_schedule')
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