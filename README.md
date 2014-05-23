core_async
=========

### production deploy  ###

# start all service #

ruby deploy.rb start all


# web #

ruby deploy.rb start web

ruby deploy.rb stop web

ruby deploy.rb restart web


# schedule #

ruby deploy.rb start schedule

ruby deploy.rb stop schedule

ruby deploy.rb restart schedule


# workers #

ruby deploy.rb start workers 2


### test service ###

RACK_ENV=development ruby deploy.rb [?ARGV]



### dev on windows ###

## sidekiq ###
bundle exec sidekiq -r ./config/application.rb -C ./sidekiq.yml

## monitor ##
bundle exec thin start -p 9090











