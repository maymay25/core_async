
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

  sleep 5

  cmd = 'ps -ef | grep "sidekiq\|core_async/config/unicorn.rb\|sidekiq_schedule\|sidkiq_subscribe"'
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


