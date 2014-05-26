

app_root = File.expand_path('..',__FILE__)
env = ENV['RACK_ENV']||'production'

command, type = ARGV[0], ARGV[1]

case type
when 'workers'
  process_sum = (tmp=ARGV[2].to_i)>0 ? tmp : 1
  case command
  when 'start'
  process_sum.times do
    system("RACK_ENV=#{env} ruby #{app_root}/config/sidekiq_workers.rb")
  end
  when 'stop'
    #TODO
  when 'restart'
    #TODO
  end
when 'web'
  case command
  when 'start'
    system("RACK_ENV=#{env} ruby #{app_root}/config/sidekiq_web.rb")
  when 'stop'
    #TODO
  when 'restart'
    #TODO
  end
when 'schedule'
  case command
  when 'start'
    system("RACK_ENV=#{env} ruby #{app_root}/config/sidekiq_common_schedule.rb")
    system("RACK_ENV=#{env} ruby #{app_root}/config/sidekiq_news_rss_schedule.rb")
  when 'stop'
    #TODO
  when 'restart'
    #TODO
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