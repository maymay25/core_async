

app_root = File.expand_path('..',__FILE__)

command = ARGV[0]
type = ARGV[1]

case type
when 'workers'
  process_sum = (tmp=ARGV[2].to_i)>0 ? tmp : 1
  process_sum.times do
    system("ruby #{app_root}/config/sidekiq_workers.rb #{command}")
  end
when 'web'
  system("ruby #{app_root}/config/sidekiq_web.rb #{command}")
when 'schedule'
  system("ruby #{app_root}/config/sidekiq_schedule.rb #{command}")
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

      1. default ENVIRONMENT is `production`. 

         >>  RACK_ENV=development ruby deploy.rb *ARGV

  EOF
  puts msg
end