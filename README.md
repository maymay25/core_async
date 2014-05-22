core_async
=========

### deploy ( sidekiq + monitor ) ###

ruby deploy.rb start

ruby deploy.rb stop

ruby deploy.rb restart


### only monitor ###

kill `cat /tmp/core_async.pid`

cd /srv/core_async && bundle exec unicorn -c /srv/core_async/config/unicorn.rb -D

kill -USR2 `cat /tmp/core_async.pid`



### development ###

RACK_ENV=development ruby deploy.rb start

RACK_ENV=development ruby deploy.rb stop

RACK_ENV=development ruby deploy.rb restart


### dev on windows ###

## sidekiq ###
bundle exec sidekiq -r ./config/application.rb -C ./sidekiq.yml -e development

## monitor ##
bundle exec thin start -p 9090











