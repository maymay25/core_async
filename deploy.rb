
require 'find'
require 'fileutils'
require 'daemons'

app_root = File.expand_path('..',__FILE__)
env = ENV['RACK_ENV']||'production'

type, command, set_num = ARGV[0], ARGV[1], ARGV[2].to_i

def puts_useful_msg(type,msg,other_msg=nil)
  sleep 1
  str = "\ntips for #{type}"
  cmd = "ps -ef | grep #{msg}"
  str += "\n> #{cmd}"
  if other_msg
    str += "\n#{other_msg}"
  end
  str += "\n  "
  puts str
end

def fetch_sidekiq_pid_files(app_root)
  path = "#{app_root}/tmp/pids/sidekiq"
  left_str = "sidekiq.pid."
  str_length = left_str.length
  pid_files = Find.find(path).to_a.select{|path| file_name=File.basename(path) ; file_name[0,str_length]==left_str }
  pid_files.sort_by{|path| path.split('.')[-1].to_i }
end

def destroy_sidekiq_pid_files(app_root)
  path = "#{app_root}/tmp/pids/sidekiq"
  left_str = "sidekiq.pid."
  str_length = left_str.length
  pid_files = Find.find(path).to_a.select{|path| file_name=File.basename(path) ; file_name[0,str_length]==left_str }
  FileUtils.rm pid_files
end

def system_run(cmd)
  puts cmd
  system(cmd)
end

case type
when 'sidekiq'
  case command
  when 'stop'
    pid_files = fetch_sidekiq_pid_files(app_root)
    if pid_files.length > 0
      pid_files.each do |file|
        system_run("sidekiqctl stop #{file} 30")
      end
    else
      puts "there was no pid files found, maybe already stoped. check it yourself."
    end
  when 'start','restart'
    pid_files = fetch_sidekiq_pid_files(app_root)
    pid_sum = pid_files.length
    if pid_sum > 0
      pid_files.each do |file|
        system_run("sidekiqctl stop #{file} 30")
      end
    end
    current_process_sum = set_num>0 ? set_num : (pid_sum>0 ? pid_sum : 1)
    current_process_sum.times do |n|
      system_run("RACK_ENV=#{env} bundle exec ruby #{app_root}/config/sidekiq_workers.rb #{n}")
    end
  when 'clean'
    destroy_sidekiq_pid_files(app_root)
  end
  puts_useful_msg('sidekiq','sidekiq',"> tail log/sidekiq.log -n 200 \n> remove all sidekiq pid files, use `ruby deploy.rb sidekiq clean`")
when 'web'
  case command
  when 'start'
    system_run("RACK_ENV=#{env} bundle exec ruby #{app_root}/config/sidekiq_web.rb")
  when 'stop'
    system_run("kill `cat #{app_root}/tmp/pids/core_async_web.pid`")
  when 'restart'
    system_run("kill -usr2 `cat #{app_root}/tmp/pids/core_async_web.pid`")
  end
  puts_useful_msg('web','core_async/config/unicorn.rb')
when 'schedule'
  case command
  when 'start'
    system_run("RACK_ENV=#{env} bundle exec clockworkd -c #{app_root}/config/sidekiq_schedule.rb --pid-dir=#{app_root}/tmp/pids --log-dir=#{app_root}/log --log start")
  when 'stop'
    system_run("RACK_ENV=#{env} bundle exec clockworkd -c #{app_root}/config/sidekiq_schedule.rb --pid-dir=#{app_root}/tmp/pids --log-dir=#{app_root}/log --log stop")
  when 'restart'
    system_run("RACK_ENV=#{env} bundle exec clockworkd -c #{app_root}/config/sidekiq_schedule.rb --pid-dir=#{app_root}/tmp/pids --log-dir=#{app_root}/log --log restart")
  end
  puts_useful_msg('schedule','sidekiq_schedule')
when 'subscribe'
  ARGV[0] = command
  puts "#{ARGV[0]} Daemons.run(\"#{app_root}/config/sidkiq_subscribe.rb\")"
  Daemons.run("#{app_root}/config/sidkiq_subscribe.rb")
  puts_useful_msg('subscribe','sidkiq_subscribe')
else
  msg = <<-EOF

    usage :

    1. start sidekiq workers
       >>  ruby deploy.rb sidekiq [cmd] [process_sum]

    2. start sidekiq web monitor
       >>  ruby delopy.rb web [cmd]

    3. start schedule tasks
       >>  ruby deploy.rb schedule [cmd]

    4. start subscribe tasks
       >>  ruby deploy.rb subscribe [cmd]

    tips :

      1. cmd is either [ start | stop | restart ]

      2. default ENVIRONMENT is `production`. change it with RACK_ENV
         >>  RACK_ENV=development ruby deploy.rb *ARGV

  EOF
  puts msg
end