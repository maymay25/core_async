
app_root = File.expand_path('..',__FILE__)
env = ENV['RACK_ENV']||'production'

puts "Attention!!! : current ENVIRONMENT is #{env} !!!"

sleep 3

command, set_num = ARGV[0], ARGV[1].to_i

if ['start','stop','restart'].include?(command)

  args = ARGV.join(' ')

  system("RACK_ENV=#{env} bundle exec ruby #{app_root}/deploy.rb sidekiq #{args}")

  system("RACK_ENV=#{env} bundle exec ruby #{app_root}/deploy.rb web #{args}")

  system("RACK_ENV=#{env} bundle exec ruby #{app_root}/deploy.rb subscribe #{args}")

  system("RACK_ENV=#{env} bundle exec ruby #{app_root}/deploy.rb schedule #{args}")

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


