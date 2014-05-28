core_async
=========

### production deploy  ###


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
RACK_ENV=development bundle exec sidekiq -r ./config/application.rb -C ./sidekiq.yml

## monitor ##
RACK_ENV=development bundle exec thin start -p 9090

##  schedule ##
RACK_ENV=development bundle exec clockwork ./config/sidekiq_schedule.rb










