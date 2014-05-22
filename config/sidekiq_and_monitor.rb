require 'daemons'

case ENV['RACK_ENV']
when 'development'

system('RACK_ENV=development cd /srv/core_async && bundle exec unicorn -c /srv/core_async/config/unicorn.rb -D')

system('RACK_ENV=development bundle exec sidekiq -r /srv/core_async/config/application.rb -C /srv/core_async/sidekiq.yml -e development -D')

else

system('RACK_ENV=production cd /srv/ting/http/core_async/current && bundle exec unicorn -c /srv/ting/http/core_async/current/config/unicorn.rb -D')

system('RACK_ENV=production cd /srv/ting/http/core_async/current && bundle exec sidekiq -r /srv/ting/http/core_async/current/config/application.rb -C /srv/ting/http/core_async/current/sidekiq.yml -e production -D')

end


