
require 'find'
require 'fileutils'

app_root = File.expand_path('..',__FILE__)
env = ENV['RACK_ENV']||'production'

command, type = ARGV[0], ARGV[1]

def ps_ef_grep(msg,other_msg=nil)
  cmd = "ps -ef | grep #{msg}"
  str = "\ntips: some useful line\n> #{cmd}"
  if other_msg
    str += "\n#{other_msg}"
  end
  puts str
end

def fetch_sidekiq_pid_files
  path = "#{app_root}/tmp/pids/sidekiq"
  left_str = "sidekiq.pid."
  str_length = left_str.length
  pid_files = Find.find(path).to_a.select{|path| file_name=File.basename(path) ; file_name[0,str_length]==left_str }
  pid_files.sort_by{|path| path.split('.')[-1].to_i }
end

def destroy_sidekiq_pid_files
  path = "#{app_root}/tmp/pids/sidekiq"
  left_str = "sidekiq.pid."
  str_length = left_str.length
  pid_files = Find.find(path).to_a.select{|path| file_name=File.basename(path) ; file_name[0,str_length]==left_str }
  FileUtils.rm pid_files
end

def system_run(cmd)
  system(cmd)
  puts cmd
end

case type
when 'sidekiq'
  process_sum = (tmp=ARGV[2].to_i)>0 ? tmp : 1
  case command
  when 'stop'
    pid_files = fetch_sidekiq_pid_files
    if pid_files.length > 0
      pid_files.each do |file|
        system_run("kill `cat #{file}`")
      end
    else
      puts "there was no pid files found, maybe already stoped. check it yourself."
    end
    destroy_sidekiq_pid_files
  when 'start','restart'
    pid_files = fetch_sidekiq_pid_files
    pid_sum = pid_files.length
    if pid_sum > 0
      if process_sum > pid_sum
        pid_files.each do |file|
          system_run("kill -usr2 `cat #{file}`")
        end
        (pid_sum..(process_sum-1)).each do |n|
          system_run("RACK_ENV=#{env} bundle exec ruby #{app_root}/config/sidekiq_workers.rb #{n}")
        end
      elsif process_sum < pid_sum
        cache_sum = 0
        pid_files.each do |file|
          if cache_sum < process_sum
            system_run("kill -usr2 `cat #{file}`")
            cache_sum += 1
          else
            system_run("kill `cat #{file}`")
          end
        end
      elsif process_sum == pid_sum
        pid_files.each do |file|
          system_run("kill -usr2 `cat #{file}`")
        end
      end
    else
      process_sum.times do |n|
        system_run("RACK_ENV=#{env} bundle exec ruby #{app_root}/config/sidekiq_workers.rb #{n}")
      end
    end
  end
  ps_ef_grep('sidekiq',"> tail log/sidekiq.log -n 200 \n> if you want remove all pids, use `stop`")
when 'web'
  case command
  when 'start'
    system_run("RACK_ENV=#{env} bundle exec ruby #{app_root}/config/sidekiq_web.rb")
  when 'stop'
    system_run("kill `cat #{app_root}/tmp/pids/core_async_web.pid`")
  when 'restart'
    system_run("kill -usr2 `cat #{app_root}/tmp/pids/core_async_web.pid`")
  end
  ps_ef_grep('core_async/config/unicorn.rb')
when 'schedule'
  case command
  when 'start'
    system_run("RACK_ENV=#{env} bundle exec clockworkd -c #{app_root}/config/sidekiq_schedule.rb --pid-dir=#{app_root}/tmp/pids --log-dir=#{app_root}/log --log start")
  when 'stop'
    system_run("RACK_ENV=#{env} bundle exec clockworkd -c #{app_root}/config/sidekiq_schedule.rb --pid-dir=#{app_root}/tmp/pids --log-dir=#{app_root}/log --log stop")
  when 'restart'
    system_run("RACK_ENV=#{env} bundle exec clockworkd -c #{app_root}/config/sidekiq_schedule.rb --pid-dir=#{app_root}/tmp/pids --log-dir=#{app_root}/log --log restart")
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