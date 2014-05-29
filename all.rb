
app_root = File.expand_path('..',__FILE__)
env = ENV['RACK_ENV']||'production'

require 'daemons'

puts "Attention!!! : current ENVIRONMENT is #{env} !!!"

sleep 3

command, set_num = ARGV[0], ARGV[1].to_i

def system_run(cmd)
  puts cmd
  system(cmd)
end

if ['start','stop','restart'].include?(command)

  args = ARGV.to_a.join(' ')

  system_run("RACK_ENV=#{env} ruby #{app_root}/deploy.rb sidekiq #{args}")

  system_run("RACK_ENV=#{env} ruby #{app_root}/deploy.rb web #{args}")

  system_run("RACK_ENV=#{env} ruby #{app_root}/deploy.rb schedule #{args}")

  system_run("RACK_ENV=#{env} ruby #{app_root}/deploy.rb subscribe #{args}")

  sleep 1

  if command!='stop'
    tips = "\n\nWARNING: `web` and `schedule` should manual check their logs to ensure if they are running well."
    tips += "\n> web: tail log/unicorn.core_async_web.log -n 50 -f "
    tips += "\n> schedule: tail log/clockworkd.sidekiq_schedule.output -n 50 -f "
    tips += "\n> sidekiq: tail log/sidekiq.log -n 50 -f "
    tips += "\n> subscribe: tail log/subscribe/#{Time.now.strftime('%Y-%m-%d')}.log -n 50 -f "
    tips += "\n "
    puts tips
  end

  sleep 4

  cmd = 'ps -ef | grep "sidekiq\|core_async/config/unicorn.rb\|sidekiq_schedule\|sidekiq_subscribe"'
  system_run(cmd)

else

  msg = <<-EOF

    usage :

    1. start all servers [ sidekiq | schedule | subscribe | web ]
       >>  ruby all.rb [cmd] [process_sum]

    tips :

      1. cmd is either [ start | stop | restart ]

      2. default ENVIRONMENT is `production`. change it with RACK_ENV
         >>  RACK_ENV=development ruby deploy.rb *ARGV

  EOF
  puts msg

end


