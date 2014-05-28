
app_root = File.expand_path('..',__FILE__)
env = ENV['RACK_ENV']||'production'

require 'daemons'

puts "Attention!!! : current ENVIRONMENT is #{env} !!!"

sleep 3

command, set_num = ARGV[0], ARGV[1].to_i

def system_run(cmd)
  system(cmd)
  puts cmd
end

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

if ['start','stop','restart'].include?(command)

  args = ARGV.to_a.join(' ')

  system_run("RACK_ENV=#{env} ruby #{app_root}/deploy.rb sidekiq #{args}")

  system_run("RACK_ENV=#{env} ruby #{app_root}/deploy.rb web #{args}")

  system_run("RACK_ENV=#{env} ruby #{app_root}/deploy.rb schedule #{args}")

  begin
    ARGV[0] = command
    Daemons.run("#{app_root}/config/sidkiq_subscribe")
    puts_useful_msg('subscribe','sidkiq_subscribe')
  rescue Exception => e
    puts "#{Time.now} #{e.class}: #{e.message} \n #{e.backtrace.join("\n")}"
  end

  sleep 5

  cmd = "ps -ef | grep 'sidekiq\|core_async/config/unicorn.rb\|sidekiq_schedule\|sidkiq_subscribe'"
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


